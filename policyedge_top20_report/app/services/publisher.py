def render_top5_table(rows: list[dict]) -> str:
    lines = []
    lines.append("+-------+-------------------------+--------------+-----------------------+---------------------------+")
    lines.append("| Rank  | Signal (Agency)         | Dollar Impact| Tradable Unit         | Options Play              |")
    lines.append("+-------+-------------------------+--------------+-----------------------+---------------------------+")
    for r in rows:
        di = f"~${(r['dollar_impact_usd']/1e9):.1f}B" if r.get("dollar_impact_usd") else "N/A"
        op = r.get("options_play","N/A")
        sig = (r.get("signal","")[:20] + "...") if len(r.get("signal",""))>23 else r.get("signal","")
        lines.append(f"| {r.get('rank',0):<5} | {sig} ({r.get('agency','')}) | {di:<12} | {r.get('tradable_unit','N/A'):<21} | {op:<25} |")
    lines.append("+-------+-------------------------+--------------+-----------------------+---------------------------+")
    return "\n".join(lines)
