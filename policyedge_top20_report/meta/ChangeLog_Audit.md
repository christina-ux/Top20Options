# ChangeLog & Audit — v3 Unification

**Scope audited**: v2.1 (core orchestrator), v2.2 (28‑ticker test pool; ClusterScorer, RiskSizer, experiment tables), v2.3 (Top‑5 Regulatory Alpha; DollarImpactCalculator; TableComposer).

## What changed
- **Consolidated agents**: Added DollarImpactCalculator + TableComposer; retained ClusterScorer/RiskSizer; unified EvidenceVerifier gates.
- **Tripwire library**: Lifted to v1.3 with five canonical regulatory tripwires (CMS, CFPB, DOE/FERC LNG, SEC disclosure, MBA delinquency) plus macro/flow rules.
- **DB schema**: Merged prior tables and add‑ons into a single SQL (`supabase_schema_unified_v3.sql`). 
- **DAG**: Combined the best of v2.2 and v2.3; clarified order so evidence gating precedes publish.
- **Scientific method**: Posterior ≥ 0.90 gate, EvidenceScore quorum, rolling calibration (Brier/ECE), SPRT‑gated learning updates.
- **Artifacts**: Standardized report templates; Top‑5 table; Vault SARIF profile and control map.

## Backwards compatibility
- v2.2 experiment tables (pool_members, cluster_scores, risk_inputs, experiment_runs) retained.
- v2.3 top5_signals table added; predictions/evidence/citations unchanged.

## Risks & mitigations
- **Data gaps**: Mark EVIDENCE_GAP and downgrade to Monitoring Only.
- **Anomalous prints**: MarketManipulation pack suppression.
- **Over‑confidence**: Calibration metrics + isotonic regression; Actionable requires Posterior ≥ 0.90.
