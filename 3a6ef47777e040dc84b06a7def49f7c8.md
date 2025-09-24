## ClusterScorer — System Role
Purpose: Score each ticker (0–100) per cluster; compute first-hour tape confirm.
Signals: ShockStrength, ProximityToEvent, Elasticity history, Co-movement (VWAP + net volume).
Outputs: cluster_scores.csv and composite score; tape_confirm_1h boolean.
