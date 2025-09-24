import json, os, time
from ..utils.logging_config import log
from ..services.impact_modeler import compute_reg_impact
from ..services.dollar_impact_calculator import finalize_dollar_impact
from ..services.table_composer import score_and_top5
from ..services.options_structurer import build_structures_for_rows
from ..services.evidence_verifier import verify_and_label
from ..services.tripwire_evaluator import evaluate_tripwires
from ..services.publisher import render_top5_table

# In a real deployment, replace with connectors & DB
CONFIG_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "..", "configs")
RUNS_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "..", "runs")
os.makedirs(RUNS_DIR, exist_ok=True)

def load_json(path):
    with open(path, "r") as f: return json.load(f)

def run_window(window: str):
    log("run_window_start", window=window)
    # 1) Fetch events/market (stub): use empty / sample policy events
    policy_events = []  # replace with connector results
    # 2) Impact modeling
    reg_intermediate = compute_reg_impact(policy_events)
    reg_final = finalize_dollar_impact(reg_intermediate)
    # 3) Compose Top‑5
    options_map = load_json(os.path.join(CONFIG_DIR, "options_templates_map.json"))
    top = score_and_top5(reg_final, options_map)
    top = build_structures_for_rows(top)
    # 4) Evidence gate
    top = verify_and_label(top, prior=0.55, likelihoods=[1.0])
    # 5) Render & persist
    table_md = render_top5_table(top)
    ts = int(time.time())
    with open(os.path.join(RUNS_DIR, f"top5_{window}_{ts}.md"), "w") as f: f.write(table_md)
    log("run_window_done", window=window, items=len(top))
    return {"window": window, "items": top}

def poll_tripwires():
    log("poll_tripwires")
    tripwires_cfg = load_json(os.path.join(CONFIG_DIR, "tripwire_library_v1_3.json"))
    ctx = {}  # TODO: populate with live metrics
    result = evaluate_tripwires(tripwires_cfg, ctx)
    return result
