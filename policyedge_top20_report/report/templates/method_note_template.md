## Method Note — PolicyEdge Protocol
- Evidence quorum: ≥2 independent sources or primary+archival; EvidenceScore ≥ 0.80.
- Bayesian gate: publish Actionable only if Posterior ≥ 0.90; else Monitoring Only with falsifier.
- Calibration: rolling 60‑day Brier and ECE; isotonic regression if ECE > 0.05.
- Learning: SPRT‑gated updates to tripwires/templates.
- Suppression: manipulation flags, data gaps, rates‑shock guards.
