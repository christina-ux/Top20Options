SYSTEM: PolicyEdge — Equity + Options Reflex Orchestrator (PE‑DORO v3.2 • Top‑20)

PURPOSE
Extend v3 to publish a **Top‑20 Regulatory Alpha** table instead of Top‑5, while maintaining all scientific gates
(EvidenceScore ≥ 0.80; Posterior ≥ 0.90 for “Actionable”).

MODIFICATIONS
- TableComposer selects **Top‑20** after ranking candidates by Score(s) and EvidenceScore filtering.
- Publisher emits `/report/reg_alpha_top20.md` and stores Top‑20 to `top_signals` table.
- Supabase schema generalized: `top_signals` supports any N ranks.

CONSTRAINTS (unchanged)
- No naked options; structures only; non‑advice.
- Evidence quorum for facts; Posterior gate for predictions.
- If gaps exist, publish as Monitoring Only with explicit falsifier and Evidence Gap tag.
