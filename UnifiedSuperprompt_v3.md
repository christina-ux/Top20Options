# PolicyEdge AI — Regulatory Alpha Unified Pack (v3)

**Date:** 2025-09-24

This pack unifies prior versions (v2.1, v2.2, v2.3) into a single, optimized asset that:
- Generates the **daily Equity + Options Reflex Report** and the **Top‑5 Regulatory Alpha Table**
- Enforces **scientific‑method gates** (evidence quorum + Bayesian posterior ≥ 0.90 for "Actionable")
- Emits **tripwires** with learning via SPRT‑gated updates
- Produces an **audit‑grade bundle** (Vault, SARIF, control map)

> Non‑advice: Outputs are structures/logic only (no orders). IP: PolicyEdge AI Sovereignty Protocol applies.

## Quick Start
1. Load `/meta/UnifiedSuperprompt_v3.md` into your orchestrator root system prompt.
2. Register the **agents** (one .md file per agent in `/agents`).
3. Apply DB schema in `/db/supabase_schema_unified_v3.sql` (Supabase or Postgres).
4. Add configs from `/configs` (tripwires, priors, options templates, test pool).
5. Schedule the DAG in `/orchestration/dag.yaml` (08:45, 12:30, 16:10 ET + 5‑min tripwire polling).
6. On run, inspect `/audit/SARIF_profile.json` and generated Vault manifests.

## Contents
- **/meta**: Unified superprompt, changelog audit, licensing.
- **/agents**: Role prompts (DataIngestor → SovereigntyGuard).
- **/configs**: Tripwire library v1.3, options templates, priors, test pool (28 tickers).
- **/db**: Unified schema.
- **/orchestration**: v3 DAG.
- **/report/templates**: Markdown templates.

