-- PolicyEdge AI Unified Supabase Schema (v3)

create table if not exists signals (
  id uuid primary key default gen_random_uuid(),
  ts timestamptz not null,
  symbol text not null,
  pct_change numeric,
  vwap_state text,
  ad_ratio numeric,
  iv_rank numeric,
  raw jsonb,
  citations jsonb
);

create table if not exists policy_events (
  id uuid primary key default gen_random_uuid(),
  ts timestamptz not null,
  agency text not null,
  doc_id text,
  category text,
  headline text,
  type text,
  status text,
  section text,
  impact_hint text,
  url text,
  citations jsonb
);

create table if not exists mapping_table (
  id uuid primary key default gen_random_uuid(),
  ts timestamptz not null,
  intelligence_signal text,
  market_impact text,
  options_read text,
  source_refs jsonb
);

create table if not exists reg_impact (
  id uuid primary key default gen_random_uuid(),
  ts timestamptz not null,
  signal text,
  agency text,
  dollar_impact_usd numeric,
  tradable_unit text,
  formula_text text,
  inputs_json jsonb,
  lo_hi_band jsonb,
  citations jsonb
);

create table if not exists structures (
  id uuid primary key default gen_random_uuid(),
  ts timestamptz not null,
  mapping_id uuid,
  structure_id text,
  type text,
  dte_band text,
  long_delta_band text,
  short_delta_band text,
  hedge_rule text,
  notes text
);

create table if not exists tripwire_hits (
  id uuid primary key default gen_random_uuid(),
  ts timestamptz not null,
  exp_id text,
  tw_id text not null,
  status text check (status in ('TRUE','FALSE','SUPPRESSED')),
  metrics_snapshot jsonb,
  guard_state jsonb,
  action_card jsonb
);

create table if not exists trades_log (
  id uuid primary key default gen_random_uuid(),
  ts timestamptz not null,
  exp_id text,
  tw_id text,
  structure_id text,
  risk_units numeric,
  outcome_1h numeric,
  outcome_1d numeric,
  pnl_proxy numeric,
  notes text
);

create table if not exists learning_proposals (
  id uuid primary key default gen_random_uuid(),
  ts timestamptz not null,
  tw_id text,
  proposal jsonb,
  confidence numeric,
  diff jsonb,
  approved boolean default false
);

create table if not exists evidence_objects (
  id uuid primary key default gen_random_uuid(),
  ts timestamptz not null,
  kind text check (kind in ('market','policy','options','archival')),
  source text not null,
  url text,
  doc_id text,
  section text,
  checksum text,
  notes text
);

create table if not exists citations (
  id uuid primary key default gen_random_uuid(),
  ts timestamptz not null,
  claim_id text,
  evidence_id uuid references evidence_objects(id),
  quality_score numeric,
  independence_flag boolean
);

create table if not exists predictions (
  id uuid primary key default gen_random_uuid(),
  ts timestamptz not null,
  exp_id text,
  claim_id text not null,
  prior numeric,
  likelihoods jsonb,
  posterior numeric,
  publish_as text check (publish_as in ('Actionable','MonitoringOnly')),
  falsifier text,
  brier numeric,
  ece numeric,
  notes text
);

create table if not exists pool_members (
  exp_id text,
  ticker text,
  cluster text,
  bias text,
  primary key (exp_id, ticker)
);

create table if not exists experiment_runs (
  exp_id text,
  run_ts timestamptz,
  window text check (window in ('preopen','midday','eod','poll')),
  artifacts jsonb,
  primary key (exp_id, run_ts, window)
);

create table if not exists cluster_scores (
  exp_id text,
  ticker text,
  ts timestamptz,
  cluster text,
  score numeric,
  tape_confirm_1h boolean,
  composite_score numeric
);

create table if not exists risk_inputs (
  exp_id text,
  ticker text,
  ts timestamptz,
  atr14 numeric,
  iv_rank numeric,
  spread_max_loss numeric,
  target_var_bps numeric
);

create table if not exists risk_allocations (
  id uuid primary key default gen_random_uuid(),
  exp_id text,
  ts timestamptz not null,
  ticker text,
  structure_id text,
  risk_bps numeric,
  units numeric,
  notional_est numeric
);

create table if not exists top5_signals (
  id uuid primary key default gen_random_uuid(),
  ts timestamptz not null,
  rank int not null,
  signal text not null,
  agency text not null,
  dollar_impact_usd numeric,
  tradable_unit text,
  options_play text,
  posterior numeric,
  publish_as text check (publish_as in ('Actionable','MonitoringOnly')),
  citations jsonb
);
