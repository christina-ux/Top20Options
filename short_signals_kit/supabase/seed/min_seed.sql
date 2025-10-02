-- PolicyEdge Short Signals Kit v1 - Minimal Seed Data
-- Sample data for testing and demonstration

-- Insert sample lenders
INSERT INTO peai.lenders (lender_id, lender_name, lender_type, primary_regulator, total_assets, tier1_capital_ratio, leverage_ratio, rwa, stress_test_participant, org_id) VALUES
('WFC_001', 'Wells Fargo Bank', 'Commercial Bank', 'OCC', 1900000000000, 0.125, 0.085, 1200000000000, true, 'demo'),
('BAC_001', 'Bank of America', 'Commercial Bank', 'OCC', 2400000000000, 0.135, 0.090, 1500000000000, true, 'demo'),
('JPM_001', 'JPMorgan Chase Bank', 'Commercial Bank', 'OCC', 2600000000000, 0.145, 0.095, 1400000000000, true, 'demo'),
('USB_001', 'U.S. Bank', 'Commercial Bank', 'OCC', 550000000000, 0.115, 0.080, 350000000000, true, 'demo'),
('PNC_001', 'PNC Bank', 'Commercial Bank', 'OCC', 460000000000, 0.120, 0.082, 290000000000, true, 'demo');

-- Insert sample warehouse facilities
INSERT INTO peai.warehouse (facility_id, lender_id, facility_size, outstanding_balance, advance_rate, margin_call_trigger, current_margin_excess, asset_type, geographic_concentration, org_id) VALUES
('WH_WFC_001', 'WFC_001', 5000000000, 3800000000, 0.75, 0.05, 450000000, 'Conforming Mortgages', 'CA,TX,FL', 'demo'),
('WH_BAC_001', 'BAC_001', 4500000000, 3200000000, 0.78, 0.06, 290000000, 'Jumbo Mortgages', 'CA,NY,NJ', 'demo'),
('WH_JPM_001', 'JPM_001', 6000000000, 4100000000, 0.80, 0.05, 180000000, 'Mixed Portfolio', 'Nationwide', 'demo'),
('WH_USB_001', 'USB_001', 2000000000, 1600000000, 0.72, 0.08, 240000000, 'Conforming Mortgages', 'MW,SE', 'demo'),
('WH_PNC_001', 'PNC_001', 1800000000, 1200000000, 0.75, 0.07, 125000000, 'Jumbo Mortgages', 'PA,OH,IL', 'demo');

-- Insert sample enforcement actions
INSERT INTO peai.enforcement (action_id, agency, institution_name, action_type, action_date, penalty_amount, description, status, url, org_id) VALUES
('ENF_2024_001', 'CFPB', 'Wells Fargo Bank', 'Civil Money Penalty', '2024-08-15', 85000000, 'HMDA reporting violations and discriminatory lending practices', 'Final', 'https://www.consumerfinance.gov/enforcement/actions/wells-fargo-2024/', 'demo'),
('ENF_2024_002', 'OCC', 'Bank of America', 'Consent Order', '2024-07-22', 125000000, 'Fair lending violations in mortgage origination', 'Active', 'https://www.occ.gov/news-issuances/news-releases/2024/nr-occ-2024-78.html', 'demo'),
('ENF_2024_003', 'FDIC', 'Regional Bank Corp', 'Cease and Desist Order', '2024-09-05', 15000000, 'Unsafe and unsound banking practices in warehouse lending', 'Active', 'https://www.fdic.gov/news/enforcement-actions/', 'demo'),
('ENF_2024_004', 'CFPB', 'JPMorgan Chase Bank', 'Civil Money Penalty', '2024-06-30', 75000000, 'Truth in Lending Act violations and improper fee assessments', 'Final', 'https://www.consumerfinance.gov/enforcement/actions/jpmorgan-2024/', 'demo'),
('ENF_2024_005', 'OCC', 'U.S. Bank', 'Written Agreement', '2024-08-01', 35000000, 'CRA compliance deficiencies and redlining concerns', 'Active', 'https://www.occ.gov/news-issuances/enforcement-actions/', 'demo');

-- Insert sample loan data
INSERT INTO peai.loans (loan_id, originator, servicer, property_type, occupancy_type, loan_purpose, original_balance, current_balance, note_rate, maturity_date, ltv, cltv, dti, credit_score, property_state, property_zip, delinquency_status, modification_flag, org_id) VALUES
('LOAN_001', 'Wells Fargo Bank', 'Wells Fargo Bank', 'SFR', 'Owner Occupied', 'Purchase', 450000, 425000, 0.0325, '2054-08-01', 0.80, 0.80, 0.35, 720, 'CA', '94105', 'current', false, 'demo'),
('LOAN_002', 'Bank of America', 'Bank of America', 'SFR', 'Owner Occupied', 'Refinance', 380000, 365000, 0.0350, '2053-09-15', 0.75, 0.75, 0.32, 745, 'TX', '77001', 'current', false, 'demo'),
('LOAN_003', 'JPMorgan Chase Bank', 'JPMorgan Chase Bank', 'CONDO', 'Owner Occupied', 'Purchase', 525000, 510000, 0.0375, '2054-01-20', 0.85, 0.85, 0.40, 680, 'NY', '10001', '30_days', false, 'demo'),
('LOAN_004', 'U.S. Bank', 'U.S. Bank', 'SFR', 'Second Home', 'Purchase', 625000, 605000, 0.0400, '2053-12-10', 0.90, 0.90, 0.28, 765, 'FL', '33101', 'current', false, 'demo'),
('LOAN_005', 'PNC Bank', 'PNC Bank', 'SFR', 'Owner Occupied', 'Cash-out Refi', 425000, 400000, 0.0425, '2054-03-05', 0.88, 0.88, 0.42, 695, 'PA', '19101', '60_days', true, 'demo');

-- Insert sample tranches
INSERT INTO peai.tranches (tranche_id, deal_id, tranche_class, original_balance, current_balance, coupon_rate, wac, wam, subordination_pct, credit_enhancement, rating, rating_agency, org_id) VALUES
('TRN_DEMO_01_AAA', 'DEMO_DEAL_01', 'AAA', 600000000, 580000000, 0.0285, 0.0325, 340, 0.06, 0.08, 'AAA', 'Moody''s', 'demo'),
('TRN_DEMO_01_AA', 'DEMO_DEAL_01', 'AA', 150000000, 145000000, 0.0315, 0.0325, 340, 0.04, 0.06, 'AA2', 'Moody''s', 'demo'),
('TRN_DEMO_01_A', 'DEMO_DEAL_01', 'A', 100000000, 98000000, 0.0385, 0.0325, 340, 0.02, 0.04, 'A3', 'Moody''s', 'demo'),
('TRN_DEMO_01_BBB', 'DEMO_DEAL_01', 'BBB', 75000000, 72000000, 0.0485, 0.0325, 340, 0.015, 0.02, 'Baa3', 'Moody''s', 'demo'),
('TRN_DEMO_02_AAA', 'DEMO_DEAL_02', 'AAA', 800000000, 775000000, 0.0295, 0.0335, 355, 0.055, 0.075, 'AAA', 'S&P', 'demo');

-- Insert sample cyber incidents
INSERT INTO peai.cyber (incident_id, institution_name, incident_date, incident_type, severity_level, data_compromised, regulatory_notification, estimated_cost, org_id) VALUES
('CYB_2024_001', 'Regional Financial Corp', '2024-07-15', 'Data Breach', 'High', true, true, 12500000, 'demo'),
('CYB_2024_002', 'Community Bank Trust', '2024-08-22', 'Ransomware', 'Critical', false, true, 8750000, 'demo'),
('CYB_2024_003', 'Metro Credit Union', '2024-06-08', 'Phishing Attack', 'Medium', true, false, 2100000, 'demo');

-- Insert sample signals (historical)
INSERT INTO peai.signals (signal_id, model_id, model_name, symbol, signal_type, signal_strength, threshold_breach, target_price, confidence_score, evidence, composite_score, org_id, created_at) VALUES
('SIG_DEMO_001', 1, 'Tranche Default Curve Short', 'MBS_BBB', 'TRANCHE_SHORT', 0.82, true, null, 0.78, '{"scenario": "CCAR_2025_SEVERE", "tranche_loss_rate": 0.65}', 0.80, 'demo', '2024-09-20 10:30:00'),
('SIG_DEMO_002', 2, 'Regulatory Shock Short', 'WFC', 'REG_SHOCK', 0.75, true, null, 0.85, '{"penalty_amount": 85000000, "agency": "CFPB"}', 0.79, 'demo', '2024-09-21 14:15:00'),
('SIG_DEMO_003', 5, 'Warehouse Line Stress Arbitrage', 'JPM', 'WAREHOUSE_STRESS', 0.68, false, null, 0.72, '{"margin_call_amount": 45000000, "facility_id": "WH_JPM_001"}', 0.70, 'demo', '2024-09-22 09:45:00');

-- Insert sample run records
INSERT INTO peai.runs (run_id, model_id, model_version, scenario_name, parameters, status, started_at, completed_at, org_id) VALUES
('RUN_DEMO_001', 1, 'v1.0', 'CCAR_2025_SEVERE', '{"hpi_change": -0.28, "unemployment": 10.0}', 'completed', '2024-09-20 10:25:00', '2024-09-20 10:35:00', 'demo'),
('RUN_DEMO_002', 2, 'v1.0', 'Enforcement_Sweep', '{"lookback_days": 30, "min_penalty": 1000000}', 'completed', '2024-09-21 14:10:00', '2024-09-21 14:20:00', 'demo'),
('RUN_DEMO_003', 5, 'v1.0', 'Rate_Shock_Base', '{"rate_increase": 0.015, "hpi_decline": 0.15}', 'completed', '2024-09-22 09:40:00', '2024-09-22 09:50:00', 'demo');