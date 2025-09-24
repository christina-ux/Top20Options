-- Generalize top5_signals → top_signals (supports Top‑N)
create table if not exists top_signals (
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
create index if not exists idx_top_signals_ts_rank on top_signals(ts, rank);
