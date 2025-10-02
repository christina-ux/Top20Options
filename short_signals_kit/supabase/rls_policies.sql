-- PolicyEdge Short Signals Kit v1 - Row Level Security Policies
-- RLS per org with auth.jwt()->>'org_id' gate

-- Enable RLS on all peai tables
alter table peai.loans enable row level security;
alter table peai.tranches enable row level security;
alter table peai.lenders enable row level security;
alter table peai.enforcement enable row level security;
alter table peai.warehouse enable row level security;
alter table peai.cyber enable row level security;
alter table peai.signals enable row level security;
alter table peai.runs enable row level security;
alter table peai.audit_log enable row level security;

-- Policies for loans table
create policy "loans_org_isolation" on peai.loans
    for all using (org_id = (auth.jwt() ->> 'org_id'));

-- Policies for tranches table
create policy "tranches_org_isolation" on peai.tranches
    for all using (org_id = (auth.jwt() ->> 'org_id'));

-- Policies for lenders table
create policy "lenders_org_isolation" on peai.lenders
    for all using (org_id = (auth.jwt() ->> 'org_id'));

-- Policies for enforcement table
create policy "enforcement_org_isolation" on peai.enforcement
    for all using (org_id = (auth.jwt() ->> 'org_id'));

-- Policies for warehouse table
create policy "warehouse_org_isolation" on peai.warehouse
    for all using (org_id = (auth.jwt() ->> 'org_id'));

-- Policies for cyber table
create policy "cyber_org_isolation" on peai.cyber
    for all using (org_id = (auth.jwt() ->> 'org_id'));

-- Policies for signals table
create policy "signals_org_isolation" on peai.signals
    for all using (org_id = (auth.jwt() ->> 'org_id'));

-- Policies for runs table
create policy "runs_org_isolation" on peai.runs
    for all using (org_id = (auth.jwt() ->> 'org_id'));

-- Policies for audit_log table
create policy "audit_log_org_isolation" on peai.audit_log
    for all using (org_id = (auth.jwt() ->> 'org_id'));

-- Service role bypasses RLS - for system operations
create policy "service_role_bypass_loans" on peai.loans
    for all to service_role using (true);

create policy "service_role_bypass_tranches" on peai.tranches
    for all to service_role using (true);

create policy "service_role_bypass_lenders" on peai.lenders
    for all to service_role using (true);

create policy "service_role_bypass_enforcement" on peai.enforcement
    for all to service_role using (true);

create policy "service_role_bypass_warehouse" on peai.warehouse
    for all to service_role using (true);

create policy "service_role_bypass_cyber" on peai.cyber
    for all to service_role using (true);

create policy "service_role_bypass_signals" on peai.signals
    for all to service_role using (true);

create policy "service_role_bypass_runs" on peai.runs
    for all to service_role using (true);

create policy "service_role_bypass_audit_log" on peai.audit_log
    for all to service_role using (true);