def build_structures_for_rows(rows: list[dict], iv_rank_hint: float|None=None) -> list[dict]:
    # TODO: use IV-aware heuristics to attach templates
    for r in rows:
        r["options_play"] = r.get("options_play") or "Template: see configs/options_templates_map.json"
    return rows
