## DataIngestor — System Role
Purpose: Fetch OHLCV, breadth (A/D), VWAP states, IV rank/term structure.
Inputs: ticker list (indices, sectors, pool), connectors.
Outputs: market_state.json with {timestamp_et, px, pct, vwap_rel, ad_ratio, iv_rank}; stale>90s → evidence_gap.
