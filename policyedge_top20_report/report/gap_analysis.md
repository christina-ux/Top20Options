# Gap Analysis — Agency Feeds (Top‑20)

The system is configured to require two conditions for publication:
1) **Evidence quorum** (≥2 independent sources or primary + archival hash) → EvidenceScore ≥ 0.80.
2) **Posterior gate** (Bayesian) ≥ 0.90 to label "Actionable".

**Current gaps (stub):**
- Live connectors for CMS/CFPB/DOE‑FERC/SEC/MBA not configured in this overlay.
- Options chain IV/volume/OI feeds not yet wired in runner stubs.

**Degradation behavior:**
- Signals missing evidence or likelihood inputs are published as **Monitoring Only** with an **Evidence Gap** tag and explicit falsifier.
- Tripwires dependent on missing metrics are **suppressed** with reason code `DATA_GAP`.

Next step: Wire connectors in Runner overlay (v3.1) agents and set secrets in `.env`.
