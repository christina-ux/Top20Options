-- PolicyEdge Short Signals Kit v1 - Main Schema
-- Tables for loans, tranches, lenders, enforcement, warehouse, cyber, signals, runs, audit

-- Enable required extensions
create extension if not exists "uuid-ossp";

-- Namespace for PolicyEdge AI tables
create schema if not exists peai;

-- Loans table - MBS loan-level data
create table if not exists peai.loans (
    id uuid primary key default gen_random_uuid(),
    created_at timestamptz default now(),
    loan_id text not null unique,
    originator text,
    servicer text,
    property_type text,
    occupancy_type text,
    loan_purpose text,
    original_balance numeric,
    current_balance numeric,
    note_rate numeric,
    maturity_date date,
    ltv numeric,
    cltv numeric,
    dti numeric,
    credit_score integer,
    property_state text,
    property_zip text,
    delinquency_status text,
    modification_flag boolean default false,
    org_id text not null,
    raw_data jsonb
);

-- Tranches table - MBS tranche information
create table if not exists peai.tranches (
    id uuid primary key default gen_random_uuid(),
    created_at timestamptz default now(),
    tranche_id text not null unique,
    deal_id text not null,
    tranche_class text,
    original_balance numeric,
    current_balance numeric,
    coupon_rate numeric,
    wac numeric,
    wam integer,
    subordination_pct numeric,
    credit_enhancement numeric,
    rating text,
    rating_agency text,
    org_id text not null,
    raw_data jsonb
);

-- Lenders table - Financial institutions
create table if not exists peai.lenders (
    id uuid primary key default gen_random_uuid(),
    created_at timestamptz default now(),
    lender_id text not null unique,
    lender_name text not null,
    lender_type text,
    primary_regulator text,
    total_assets numeric,
    tier1_capital_ratio numeric,
    leverage_ratio numeric,
    rwa numeric,
    stress_test_participant boolean default false,
    org_id text not null,
    raw_data jsonb
);

-- Enforcement table - Regulatory enforcement actions
create table if not exists peai.enforcement (
    id uuid primary key default gen_random_uuid(),
    created_at timestamptz default now(),
    action_id text not null unique,
    agency text not null,
    institution_name text,
    action_type text,
    action_date date,
    penalty_amount numeric,
    description text,
    status text,
    url text,
    org_id text not null,
    raw_data jsonb
);

-- Warehouse table - Warehouse line exposures
create table if not exists peai.warehouse (
    id uuid primary key default gen_random_uuid(),
    created_at timestamptz default now(),
    facility_id text not null,
    lender_id text references peai.lenders(lender_id),
    facility_size numeric,
    outstanding_balance numeric,
    advance_rate numeric,
    margin_call_trigger numeric,
    current_margin_excess numeric,
    asset_type text,
    geographic_concentration text,
    org_id text not null,
    raw_data jsonb
);

-- Cyber table - Cybersecurity incidents
create table if not exists peai.cyber (
    id uuid primary key default gen_random_uuid(),
    created_at timestamptz default now(),
    incident_id text not null unique,
    institution_name text,
    incident_date date,
    incident_type text,
    severity_level text,
    data_compromised boolean,
    regulatory_notification boolean,
    estimated_cost numeric,
    org_id text not null,
    raw_data jsonb
);

-- Signals table - Generated short signals
create table if not exists peai.signals (
    id uuid primary key default gen_random_uuid(),
    created_at timestamptz default now(),
    signal_id text not null unique,
    model_id integer not null,
    model_name text not null,
    symbol text,
    signal_type text not null,
    signal_strength numeric check (signal_strength between 0 and 1),
    threshold_breach boolean default false,
    target_price numeric,
    confidence_score numeric,
    evidence jsonb,
    composite_score numeric,
    org_id text not null,
    raw_data jsonb
);

-- Runs table - Model execution tracking
create table if not exists peai.runs (
    id uuid primary key default gen_random_uuid(),
    created_at timestamptz default now(),
    run_id text not null unique,
    model_id integer not null,
    model_version text,
    scenario_name text,
    parameters jsonb,
    status text,
    started_at timestamptz,
    completed_at timestamptz,
    error_message text,
    results_hash text,
    org_id text not null
);

-- Audit log table - All system actions
create table if not exists peai.audit_log (
    id uuid primary key default gen_random_uuid(),
    created_at timestamptz default now(),
    action_type text not null,
    table_name text,
    record_id uuid,
    user_id text,
    org_id text not null,
    old_values jsonb,
    new_values jsonb,
    ip_address inet,
    user_agent text
);

-- Create indexes for performance
create index if not exists idx_loans_org_id on peai.loans(org_id);
create index if not exists idx_loans_loan_id on peai.loans(loan_id);
create index if not exists idx_tranches_org_id on peai.tranches(org_id);
create index if not exists idx_tranches_deal_id on peai.tranches(deal_id);
create index if not exists idx_lenders_org_id on peai.lenders(org_id);
create index if not exists idx_enforcement_org_id on peai.enforcement(org_id);
create index if not exists idx_enforcement_agency on peai.enforcement(agency);
create index if not exists idx_warehouse_org_id on peai.warehouse(org_id);
create index if not exists idx_cyber_org_id on peai.cyber(org_id);
create index if not exists idx_signals_org_id on peai.signals(org_id);
create index if not exists idx_signals_model_id on peai.signals(model_id);
create index if not exists idx_signals_created_at on peai.signals(created_at);
create index if not exists idx_runs_org_id on peai.runs(org_id);
create index if not exists idx_runs_model_id on peai.runs(model_id);
create index if not exists idx_audit_org_id on peai.audit_log(org_id);
create index if not exists idx_audit_created_at on peai.audit_log(created_at);