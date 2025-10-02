-- PolicyEdge Short Signals Kit v1 - Convenience Views
-- Including v_short_candidates view

-- View for active short signal candidates
create or replace view peai.v_short_candidates as
select 
    s.signal_id,
    s.model_name,
    s.symbol,
    s.signal_type,
    s.signal_strength,
    s.threshold_breach,
    s.target_price,
    s.confidence_score,
    s.composite_score,
    s.evidence,
    s.created_at,
    r.scenario_name,
    r.parameters as run_parameters
from peai.signals s
join peai.runs r on r.model_id = s.model_id 
    and r.created_at::date = s.created_at::date
where s.threshold_breach = true
    and s.confidence_score > 0.7
    and s.created_at >= current_date - interval '7 days'
order by s.composite_score desc, s.created_at desc;

-- View for model performance summary
create or replace view peai.v_model_performance as
select 
    s.model_id,
    s.model_name,
    count(*) as total_signals,
    count(*) filter (where s.threshold_breach = true) as breach_signals,
    avg(s.signal_strength) as avg_strength,
    avg(s.confidence_score) as avg_confidence,
    avg(s.composite_score) as avg_composite,
    max(s.created_at) as last_signal_date
from peai.signals s
where s.created_at >= current_date - interval '30 days'
group by s.model_id, s.model_name
order by avg_composite desc;

-- View for tranche exposure summary
create or replace view peai.v_tranche_exposure as
select 
    t.deal_id,
    t.tranche_class,
    t.rating,
    t.current_balance,
    t.subordination_pct,
    t.credit_enhancement,
    count(l.id) as loan_count,
    sum(l.current_balance) as total_loan_balance,
    avg(l.ltv) as avg_ltv,
    avg(l.dti) as avg_dti,
    avg(l.credit_score) as avg_credit_score,
    count(*) filter (where l.delinquency_status != 'current') as delinquent_loans
from peai.tranches t
left join peai.loans l on l.loan_id in (
    select jsonb_array_elements_text(t.raw_data->'loan_ids')
)
group by t.deal_id, t.tranche_class, t.rating, t.current_balance, 
         t.subordination_pct, t.credit_enhancement
order by t.current_balance desc;

-- View for lender risk profile
create or replace view peai.v_lender_risk as
select 
    l.lender_id,
    l.lender_name,
    l.lender_type,
    l.primary_regulator,
    l.total_assets,
    l.tier1_capital_ratio,
    l.leverage_ratio,
    count(e.id) as enforcement_actions,
    sum(e.penalty_amount) as total_penalties,
    count(c.id) as cyber_incidents,
    count(w.id) as warehouse_facilities,
    sum(w.outstanding_balance) as total_warehouse_exposure
from peai.lenders l
left join peai.enforcement e on e.institution_name ilike '%' || l.lender_name || '%'
left join peai.cyber c on c.institution_name ilike '%' || l.lender_name || '%'  
left join peai.warehouse w on w.lender_id = l.lender_id
group by l.lender_id, l.lender_name, l.lender_type, l.primary_regulator,
         l.total_assets, l.tier1_capital_ratio, l.leverage_ratio
order by l.total_assets desc;

-- View for enforcement action trends
create or replace view peai.v_enforcement_trends as
select 
    date_trunc('month', e.action_date) as action_month,
    e.agency,
    e.action_type,
    count(*) as action_count,
    sum(e.penalty_amount) as total_penalties,
    avg(e.penalty_amount) as avg_penalty
from peai.enforcement e
where e.action_date >= current_date - interval '24 months'
group by date_trunc('month', e.action_date), e.agency, e.action_type
order by action_month desc, total_penalties desc;

-- View for warehouse stress scenarios
create or replace view peai.v_warehouse_stress as
select 
    w.facility_id,
    w.lender_id,
    w.facility_size,
    w.outstanding_balance,
    w.advance_rate,
    w.margin_call_trigger,
    w.current_margin_excess,
    w.asset_type,
    -- Calculate stress scenarios
    case 
        when w.current_margin_excess < w.facility_size * 0.05 then 'HIGH_RISK'
        when w.current_margin_excess < w.facility_size * 0.10 then 'MEDIUM_RISK'
        else 'LOW_RISK'
    end as stress_level,
    (w.outstanding_balance / w.advance_rate) as collateral_value_implied,
    (w.facility_size - w.outstanding_balance) as available_capacity
from peai.warehouse w
where w.outstanding_balance > 0
order by w.current_margin_excess asc;