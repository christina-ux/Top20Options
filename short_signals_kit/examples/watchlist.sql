-- PolicyEdge Short Signals Kit v1 - Sample Watchlist Query
-- Generate shortable watchlist from signals and market data

-- Main watchlist query
with signal_summary as (
    select 
        symbol,
        count(*) as signal_count,
        max(composite_score) as max_composite,
        avg(confidence_score) as avg_confidence,
        max(created_at) as latest_signal,
        array_agg(distinct model_name) as active_models,
        array_agg(distinct signal_type) as signal_types
    from peai.v_short_candidates
    where created_at >= current_date - interval '3 days'
        and composite_score >= 0.6
    group by symbol
),
market_filters as (
    select 
        symbol,
        signal_count,
        max_composite,
        avg_confidence,
        latest_signal,
        active_models,
        signal_types,
        -- Scoring criteria
        case 
            when max_composite >= 0.9 then 'A+'
            when max_composite >= 0.8 then 'A' 
            when max_composite >= 0.7 then 'B+'
            when max_composite >= 0.6 then 'B'
            else 'C'
        end as grade,
        -- Risk assessment
        case
            when signal_count >= 3 and max_composite >= 0.8 then 'HIGH'
            when signal_count >= 2 and max_composite >= 0.7 then 'MEDIUM'
            else 'LOW'
        end as risk_level,
        -- Urgency scoring
        case
            when latest_signal >= current_date - interval '6 hours' then 'IMMEDIATE'
            when latest_signal >= current_date - interval '24 hours' then 'HIGH'
            when latest_signal >= current_date - interval '48 hours' then 'MEDIUM'
            else 'LOW'
        end as urgency
    from signal_summary
)
select 
    mf.symbol,
    mf.grade,
    mf.risk_level,
    mf.urgency,
    mf.signal_count,
    round(mf.max_composite::numeric, 3) as max_composite_score,
    round(mf.avg_confidence::numeric, 3) as avg_confidence_score,
    mf.latest_signal,
    mf.active_models,
    mf.signal_types,
    
    -- Add fundamental filters (placeholder - would connect to market data)
    '{{MARKET_CAP}}' as market_cap,
    '{{AVG_VOLUME}}' as avg_volume_90d,
    '{{BETA}}' as beta,
    '{{IMPLIED_VOL}}' as implied_volatility,
    
    -- Shortability indicators
    case
        when mf.signal_count >= 2 
            and mf.max_composite >= 0.75
            and mf.avg_confidence >= 0.70
        then 'SHORTABLE'
        else 'MONITOR'
    end as recommendation,
    
    -- Suggested position size (as percentage of portfolio)
    case 
        when mf.grade in ('A+', 'A') and mf.risk_level = 'HIGH' then '2.0%'
        when mf.grade in ('A+', 'A') and mf.risk_level = 'MEDIUM' then '1.5%'
        when mf.grade = 'B+' and mf.risk_level in ('HIGH', 'MEDIUM') then '1.0%'
        when mf.grade = 'B' then '0.5%'
        else '0.25%'
    end as suggested_position_size,
    
    -- Risk management levels
    case
        when mf.max_composite >= 0.9 then '5%'  -- tight stop
        when mf.max_composite >= 0.8 then '7%'
        when mf.max_composite >= 0.7 then '10%'
        else '15%'
    end as stop_loss_pct,
    
    -- Time horizon
    case
        when 'TRANCHE_SHORT' = any(mf.signal_types) then '3-6 months'
        when 'REG_SHOCK' = any(mf.signal_types) then '1-3 months'  
        when 'WAREHOUSE_STRESS' = any(mf.signal_types) then '2-4 weeks'
        else '1-2 months'
    end as time_horizon

from market_filters mf
where mf.signal_count >= 1
    and mf.max_composite >= 0.6
    and mf.avg_confidence >= 0.65
order by 
    case mf.urgency
        when 'IMMEDIATE' then 1
        when 'HIGH' then 2
        when 'MEDIUM' then 3
        else 4
    end,
    mf.max_composite desc,
    mf.signal_count desc
limit 20;

-- Supporting queries for additional analysis

-- Query 2: Sector concentration check
with sector_exposure as (
    select 
        '{{SECTOR}}' as sector,  -- Would be populated from market data
        symbol,
        max_composite_score
    from (
        -- Reuse main query logic here or create as view
        select symbol, max(composite_score) as max_composite_score
        from peai.v_short_candidates
        where created_at >= current_date - interval '3 days'
        group by symbol
    ) t
)
select 
    sector,
    count(*) as symbol_count,
    round(avg(max_composite_score)::numeric, 3) as avg_score,
    array_agg(symbol order by max_composite_score desc) as symbols
from sector_exposure
group by sector
having count(*) >= 2
order by avg_score desc;

-- Query 3: Model performance for watchlist
select 
    model_name,
    count(distinct symbol) as symbols_covered,
    avg(composite_score) as avg_score,
    count(*) filter (where threshold_breach = true) as breach_count,
    max(created_at) as latest_signal
from peai.v_short_candidates
where created_at >= current_date - interval '7 days'
group by model_name
order by avg_score desc;

-- Query 4: Historical performance validation
-- This would compare signals to subsequent price movements
-- (requires market data integration)
select 
    signal_id,
    symbol,
    signal_type,
    composite_score,
    created_at as signal_date,
    '{{SUBSEQUENT_RETURN_1D}}' as return_1d,
    '{{SUBSEQUENT_RETURN_5D}}' as return_5d,
    '{{SUBSEQUENT_RETURN_20D}}' as return_20d,
    case 
        when '{{SUBSEQUENT_RETURN_5D}}'::numeric < -0.02 then 'SUCCESS'
        when '{{SUBSEQUENT_RETURN_5D}}'::numeric > 0.02 then 'FAILED'
        else 'NEUTRAL'
    end as outcome_5d
from peai.signals
where created_at >= current_date - interval '30 days'
    and threshold_breach = true
order by created_at desc;