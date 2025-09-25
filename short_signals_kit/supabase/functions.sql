-- PolicyEdge Short Signals Kit v1 - Helper Functions
-- Including compute_composite_score() helper and score clamps

-- Function to compute composite score from multiple signal inputs
create or replace function peai.compute_composite_score(
    p_signal_strength numeric,
    p_confidence_score numeric,
    p_model_weight numeric default 1.0,
    p_recency_hours numeric default 24.0
) 
returns numeric
language plpgsql
as $$
declare
    v_composite numeric;
    v_recency_factor numeric;
    v_strength_normalized numeric;
    v_confidence_normalized numeric;
begin
    -- Normalize inputs to 0-1 range
    v_strength_normalized := greatest(0, least(1, coalesce(p_signal_strength, 0)));
    v_confidence_normalized := greatest(0, least(1, coalesce(p_confidence_score, 0)));
    
    -- Calculate recency decay factor (fresher signals get higher weight)
    v_recency_factor := greatest(0.1, exp(-p_recency_hours / 24.0));
    
    -- Composite score formula: weighted average with recency decay
    v_composite := (
        (v_strength_normalized * 0.4) +
        (v_confidence_normalized * 0.4) +
        (p_model_weight * 0.2)
    ) * v_recency_factor;
    
    -- Clamp final score to 0-1 range
    return greatest(0, least(1, v_composite));
end;
$$;

-- Function to clamp scores within valid ranges
create or replace function peai.clamp_score(
    p_score numeric,
    p_min_val numeric default 0.0,
    p_max_val numeric default 1.0
)
returns numeric
language plpgsql
immutable
as $$
begin
    return greatest(p_min_val, least(p_max_val, coalesce(p_score, p_min_val)));
end;
$$;

-- Function to calculate probability of default (PD) using logistic regression
create or replace function peai.calculate_pd(
    p_ltv numeric,
    p_dti numeric, 
    p_credit_score numeric,
    p_unemployment_rate numeric default 3.5
)
returns numeric
language plpgsql
immutable
as $$
declare
    v_logit numeric;
    v_pd numeric;
begin
    -- Simplified logistic regression model for PD
    -- Coefficients based on typical mortgage default models
    v_logit := -4.5 
        + (coalesce(p_ltv, 0.8) - 0.8) * 3.0
        + (coalesce(p_dti, 0.3) - 0.3) * 2.5
        + (700 - coalesce(p_credit_score, 700)) * 0.01
        + coalesce(p_unemployment_rate, 3.5) * 0.15;
    
    -- Convert logit to probability
    v_pd := 1.0 / (1.0 + exp(-v_logit));
    
    return peai.clamp_score(v_pd, 0.001, 0.999);
end;
$$;

-- Function to calculate loss given default (LGD)
create or replace function peai.calculate_lgd(
    p_ltv numeric,
    p_property_type text default 'SFR',
    p_property_state text default 'CA',
    p_hpi_change numeric default 0.0
)
returns numeric  
language plpgsql
immutable
as $$
declare
    v_base_lgd numeric;
    v_hpi_adjustment numeric;
    v_property_adjustment numeric;
    v_lgd numeric;
begin
    -- Base LGD varies by property type
    case p_property_type
        when 'SFR' then v_base_lgd := 0.25;  -- Single Family Residence
        when 'CONDO' then v_base_lgd := 0.35; -- Condominium
        when 'COOP' then v_base_lgd := 0.45;  -- Cooperative
        when 'MFR' then v_base_lgd := 0.40;   -- Multi-Family Residence
        else v_base_lgd := 0.30;
    end case;
    
    -- Adjust for LTV (higher LTV = higher LGD)
    v_base_lgd := v_base_lgd + greatest(0, (coalesce(p_ltv, 0.8) - 0.8) * 0.5);
    
    -- Adjust for HPI changes (falling prices = higher LGD)
    v_hpi_adjustment := greatest(-0.20, least(0.20, -coalesce(p_hpi_change, 0) * 0.5));
    
    -- State-specific adjustments (simplified)
    case p_property_state
        when 'CA', 'NY', 'MA' then v_property_adjustment := -0.05; -- Lower LGD in high-value markets
        when 'NV', 'FL', 'AZ' then v_property_adjustment := 0.10;  -- Higher LGD in volatile markets  
        else v_property_adjustment := 0.0;
    end case;
    
    v_lgd := v_base_lgd + v_hpi_adjustment + v_property_adjustment;
    
    return peai.clamp_score(v_lgd, 0.05, 0.95);
end;
$$;

-- Function to calculate expected loss (EL = PD * LGD * EAD)
create or replace function peai.calculate_expected_loss(
    p_current_balance numeric,
    p_ltv numeric,
    p_dti numeric,
    p_credit_score numeric,
    p_property_type text default 'SFR',
    p_property_state text default 'CA',
    p_hpi_change numeric default 0.0,
    p_unemployment_rate numeric default 3.5
)
returns numeric
language plpgsql
immutable
as $$
declare
    v_pd numeric;
    v_lgd numeric;
    v_ead numeric;
    v_el numeric;
begin
    -- Calculate components
    v_pd := peai.calculate_pd(p_ltv, p_dti, p_credit_score, p_unemployment_rate);
    v_lgd := peai.calculate_lgd(p_ltv, p_property_type, p_property_state, p_hpi_change);
    v_ead := coalesce(p_current_balance, 0); -- Exposure at Default
    
    -- Expected Loss = PD * LGD * EAD
    v_el := v_pd * v_lgd * v_ead;
    
    return v_el;
end;
$$;

-- Function to update composite scores for existing signals
create or replace function peai.refresh_composite_scores()
returns void
language plpgsql
as $$
begin
    update peai.signals
    set composite_score = peai.compute_composite_score(
        signal_strength,
        confidence_score,
        1.0, -- default model weight
        extract(epoch from (now() - created_at)) / 3600.0 -- hours since creation
    )
    where created_at >= current_date - interval '7 days';
end;
$$;

-- Grant execute permissions to authenticated users
grant execute on function peai.compute_composite_score(numeric, numeric, numeric, numeric) to authenticated;
grant execute on function peai.clamp_score(numeric, numeric, numeric) to authenticated;
grant execute on function peai.calculate_pd(numeric, numeric, numeric, numeric) to authenticated;
grant execute on function peai.calculate_lgd(numeric, text, text, numeric) to authenticated;
grant execute on function peai.calculate_expected_loss(numeric, numeric, numeric, numeric, text, text, numeric, numeric) to authenticated;
grant execute on function peai.refresh_composite_scores() to authenticated;