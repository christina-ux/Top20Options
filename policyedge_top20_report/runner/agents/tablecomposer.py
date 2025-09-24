
def run(**k):
    import os, json, pathlib, datetime
    out = pathlib.Path(k.get('output_dir','./runs'))
    out.mkdir(parents=True, exist_ok=True)
    # Read config if exists
    cfg_path = pathlib.Path("configs/table_composer.yaml")
    top_k = 20
    if cfg_path.exists():
        import yaml
        cfg = yaml.safe_load(cfg_path.read_text())
        top_k = int(cfg.get("top_k", 20))
    # Stub: write empty Top-K JSON and Top‑20 markdown path expected by Publisher
    (out/'top_signals.json').write_text(json.dumps({"top_k": top_k, "signals": []}, indent=2))
    rep_dir = pathlib.Path("report")
    rep_dir.mkdir(parents=True, exist_ok=True)
    top20_md = pathlib.Path("report/reg_alpha_top20.md")
    if not top20_md.exists():
        top20_md.write_text("# Top‑20 Regulatory Alpha (stub)\n\n_EVIDENCE_GAP: live feeds not connected._\n")
    return {'artifact': 'reg_alpha_top20.md', 'top_k': top_k}
