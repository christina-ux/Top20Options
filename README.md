# PolicyEdge AI — Unified Trading Intelligence Platform

This repository provides a complete, unified platform combining **PolicyEdge AI's Top-20 Options daily report** with the **Short Signals Kit v1** for comprehensive regulatory alpha generation and risk management.

## 🎯 Overview

The platform unifies two powerful components:

1. **PolicyEdge AI Top-20 Options Daily Report** — Real-time regulatory intelligence mapped to actionable options structures
2. **PolicyEdge Short Signals Kit v1** — MBS tranche analysis, regulatory enforcement tracking, and warehouse line stress testing

## 📁 Repository Structure

```
/
├── policyedge_top20_report/    # Main Top-20 Options application
│   ├── app/                    # FastAPI application
│   ├── agents/                 # AI agent role prompts  
│   ├── configs/                # Configuration files
│   ├── db/                     # Database schemas
│   └── README.md               # Application documentation
│
├── short_signals_kit/          # Short Signals Kit v1 components
│   ├── supabase/              # Database schemas and functions
│   │   ├── schema.sql         # Core tables (loans, tranches, signals, etc.)
│   │   ├── rls_policies.sql   # Row-level security policies
│   │   ├── views.sql          # Convenience views
│   │   ├── functions.sql      # Helper functions (PD/LGD/EL calculations)
│   │   └── seed/              # Sample data for testing
│   ├── n8n/workflows/         # Automation workflows
│   │   ├── tranche_short_v1.json
│   │   ├── regulatory_shock_short_v1.json
│   │   └── warehouse_stress_v1.json
│   ├── config/                # Configuration files
│   │   ├── ccar_2025_severe.json
│   │   └── reflex_guardrails.json
│   ├── templates/             # Output templates
│   │   └── action_card.json5
│   ├── examples/              # Sample queries
│   │   └── watchlist.sql
│   └── code/                  # Utilities and functions
│       ├── utils/formulas.py  # Risk calculation formulas
│       └── edge_functions/    # Supabase Edge Functions
│
└── README.md                   # This file
```

## 🚀 Quick Start

### 1. Top-20 Options Application

Navigate to the main application:

```bash
cd policyedge_top20_report
pip install -r requirements.txt
cp config/.env.example .env  # Configure your environment
uvicorn app.main:app --host 0.0.0.0 --port 8080
```

See [policyedge_top20_report/README.md](./policyedge_top20_report/README.md) for detailed setup instructions.

### 2. Short Signals Kit Setup

#### Database Setup (Supabase/Postgres)

```bash
# Apply schemas in order
psql $DATABASE_URL -f short_signals_kit/supabase/schema.sql
psql $DATABASE_URL -f short_signals_kit/supabase/rls_policies.sql  
psql $DATABASE_URL -f short_signals_kit/supabase/views.sql
psql $DATABASE_URL -f short_signals_kit/supabase/functions.sql

# Optional: Load sample data
psql $DATABASE_URL -f short_signals_kit/supabase/seed/min_seed.sql
```

#### n8n Workflow Setup

Import the workflow JSON files into your n8n instance:
- `short_signals_kit/n8n/workflows/tranche_short_v1.json`
- `short_signals_kit/n8n/workflows/regulatory_shock_short_v1.json`
- `short_signals_kit/n8n/workflows/warehouse_stress_v1.json`

Configure credentials for:
- **Postgres** → Supabase connection
- **HTTP Request** → Set `SUPABASE_ANON_KEY` headers

#### Edge Function Deployment (Optional)

```bash
supabase functions deploy insert-signal --project-ref YOUR_PROJECT_REF
```

## 📊 Key Features

### Top-20 Options Report
- **Daily Intelligence → Market Mapping**: Policy events mapped to market impacts and options structures
- **Scientific Method Gates**: Bayesian posterior ≥ 0.90 for "Actionable" signals
- **Tripwire System**: Mathematical triggers evaluated every 5 minutes
- **Audit-Grade Output**: SARIF profiles and control maps

### Short Signals Kit
- **Model #1: Tranche Default Curve Short** — Pool stress → waterfall → signal
- **Model #2: Regulatory Shock Short** — HMDA + enforcement → P&L impact
- **Model #5: Warehouse Line Stress** — Price shocks → margin calls
- **Row-Level Security**: Org-isolated data with JWT-based access control
- **Composite Scoring**: Multi-factor signal strength with recency decay

## 🔒 Governance & Safety

- **MNPI Protection**: Public sources only, content screening
- **Audit Trail**: Complete logging in `peai.audit_log`
- **RLS Security**: Org-level isolation for all data
- **Compliance**: SOX, GDPR, CCPA, FINRA-ready
- **Disclaimers**: Educational purpose only, not investment advice

## 🛠 Development & Testing

### Running Tests

```bash
# Top-20 application tests
cd policyedge_top20_report
python -m pytest tests/ -v

# Short Signals Kit formula validation
cd short_signals_kit/code/utils
python formulas.py
```

### Sample Queries

Generate a shortable watchlist:
```sql
-- Load from short_signals_kit/examples/watchlist.sql
\i short_signals_kit/examples/watchlist.sql
```

View active signals:
```sql
SELECT * FROM peai.v_short_candidates WHERE created_at >= CURRENT_DATE - INTERVAL '24 hours';
```

## 📈 Model Performance

The platform includes built-in performance tracking:
- Signal accuracy vs. subsequent market moves
- Calibration metrics (Brier score, ECE)
- SPRT-gated learning updates
- Rolling backtesting windows

## 🔧 Configuration

### Environment Variables

Key variables for both applications:
```bash
DATABASE_URL=postgresql://...
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
ORG_ID=your-organization-id
```

### Scenario Configuration

Modify stress scenarios in:
- `short_signals_kit/config/ccar_2025_severe.json`
- `policyedge_top20_report/configs/tripwire_library_v1_3.json`

## 📚 Documentation

- **Top-20 Report**: [policyedge_top20_report/README.md](./policyedge_top20_report/README.md)
- **Agent Roles**: See individual `.md` files in root directory
- **API Reference**: Available at `/docs` when running the FastAPI app
- **Database Schema**: See SQL files in `short_signals_kit/supabase/`

## ⚠️ Disclaimers

- **Educational Purpose Only**: This platform provides analysis tools, not investment advice
- **Risk Warning**: All investments carry risk of loss
- **No Trading**: Outputs are structures and logic only, never trade orders
- **Professional Guidance**: Consult qualified professionals before making investment decisions

## 📄 License

See [Sovereignty_License.txt](./policyedge_top20_report/Sovereignty_License.txt) for IP and usage terms.

---

**PolicyEdge AI Sovereignty Protocol applies to all outputs and derived works.**