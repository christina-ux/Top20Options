def compute_reg_impact(policy_events: list[dict]) -> list[dict]:
    results = []
    for ev in policy_events:
        # TODO: apply cluster-specific formulas; attach citations
        results.append({
            "signal": ev.get("headline",""),
            "agency": ev.get("agency",""),
            "dollar_impact_usd": None,
            "tradable_unit": None,
            "formula_text": None,
            "inputs_json": ev,
            "lo_hi_band": None,
            "citations": []
        })
    return results
