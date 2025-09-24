# PolicyEdge AI — Top‑20 Options Daily Report

This repository provides a complete deployment package for **PolicyEdge AI’s Top‑20 Options daily report**.  It merges the core PolicyEdge regulatory alpha orchestrator with a live runner and the Top‑20 overlay, producing a real‑time, auditable daily report that ranks the 20 most impactful regulatory signals and translates them into risk‑defined options structures.

## Key Features

1. **Today’s Market Shift**
   - Summarizes the current market state each run, including percentage moves across major indices (SPY, QQQ, IWM, TLT), key AI leaders (NVDA, AAPL), sector proxies (XLF, XLE, SMH), and crypto (BTC).  The snapshot is sharp and audit–style, providing essential context for the day.

2. **Intelligence → Market Mapping**
   - A tabular mapping from PolicyEdge intelligence signals (e.g. labour softening, wildfire/grid reforms, tariff/trade actions, AI capex) to likely market impacts and a corresponding options read.  Each row carries citation IDs linking back to the underlying policy event or market state.

3. **Tripwires to Drive Options Flow**
   - Mathematical rule‑based triggers evaluated every five minutes.  When conditions are met (e.g. `IWM/SPY ≥ 1.5%` and breadth `A/D ≥ 1.8` for 120 minutes), the system emits an ActionCard containing a structure template, hedges and exit rules.  Guards suppress triggers during adverse regimes (e.g. rate shocks).

4. **What to Consider Placing Today** (structures only)
   - Lists risk‑defined option structures derived from policy analysis and fired tripwires.  Includes DTE and delta bands, hedges and exit conditions, but never issues financial advice.  Structures are labelled **Actionable** only if the Bayesian posterior ≥ 0.90; otherwise they appear as **Monitoring Only** with an explicit falsifier.

## Contents

- **meta/** – Unified system prompt (`UnifiedSuperprompt_v3_2_Top20.md`) and Sovereignty licence.
- **agents/** – Human‑readable role prompts for each agent (DataIngestor, PolicyWatcher, SignalSynthesizer, etc.).
- **configs/** – Configuration files:
  - `tripwire_library_v1_3.json` – canonical tripwires and structures,
  - `options_templates_map.json` – option structure templates,
  - `base_rates_priors.json` – Bayesian priors,
  - `test_pool.json` – example 28‑ticker harness (optional),
  - `table_composer.yaml` – Top‑20 ranking weights and publication gates.
- **db/** – Supabase/Postgres schemas:
  - `supabase_schema_unified_v3.sql` – full unified database,
  - `supabase_schema_top_signals.sql` – generalised top signals table for Top‑N.
- **app/** – FastAPI application with connectors, services, tasks and utilities.
- **orchestration/** – DAG definition (`dag.yaml`) scheduling pre‑open, mid‑day, EOD runs and 5‑minute tripwire polling.
- **report/templates/** – Markdown templates for the Top‑20 report, method notes and generic report shell.
- **audit/** – SARIF profile and control map template for audit bundling.
- **config/.env.example** – Sample environment variables to connect to your database and data providers.
- **requirements.txt** – Python dependencies.

Additional overlay artefacts such as the Top‑20 table composer script (`runner/agents/tablecomposer.py`) and a gap analysis report are included for further customisation.

## Setup

1. **Install dependencies**

```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
```

2. **Configure environment**

Copy `config/.env.example` to `.env` and fill in your database connection (`DATABASE_URL` or `SUPABASE_URL`/`SUPABASE_ANON_KEY`) along with any provider API keys for market data, policy feeds and options chains.

3. **Prepare the database**

Apply the SQL schemas in `db/` to your Postgres or Supabase instance:

```bash
psql $DATABASE_URL -f db/supabase_schema_unified_v3.sql
psql $DATABASE_URL -f db/supabase_schema_top_signals.sql
```

4. **Run the service**

Launch the FastAPI app locally:

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8080
```

Scheduled runs can be triggered via the endpoints or by a scheduler such as APScheduler or cron.  Key endpoints include:

- `POST /run/preopen` – run the pre‑open report,
- `POST /run/midday` – run the mid‑day update,
- `POST /run/eod` – run the end‑of‑day report,
- `POST /poll/tripwires` – evaluate tripwires.

All runs produce artefacts under `runs/` and an audit bundle in `audit/` with a SHA‑256 manifest.

## Deployment on Vercel

While this repository includes a FastAPI backend, deploying to Vercel typically requires an adapter (e.g. using `vercel‑python`).  You can wrap the FastAPI app as a serverless function under the `api` directory or run it as a standalone microservice using Vercel’s Serverless Functions.  Ensure environment variables are properly set in your Vercel project settings.

---

This package adheres to the PolicyEdge Sovereignty Protocol.  All outputs are structures/logic only and constitute **non‑advice**.  Ensure you review and comply with applicable securities regulations before acting on any information.
