def score_and_top5(reg_impact_rows: list[dict], options_map: dict) -> list[dict]:
    # TODO: implement scoring (DollarImpact, Immediacy, Tradeability, EvidenceScore, Ripple)
    # For now, return up to 5 placeholders in input order.
    top = []
    for i, r in enumerate(reg_impact_rows[:5], start=1):
        top.append({
            "rank": i,
            "signal": r.get("signal",""),
            "agency": r.get("agency",""),
            "dollar_impact_usd": r.get("dollar_impact_usd"),
            "tradable_unit": r.get("tradable_unit"),
            "options_play": None,
            "posterior": None,
            "publish_as": "MonitoringOnly",
            "citations": r.get("citations", [])
        })
    return top
