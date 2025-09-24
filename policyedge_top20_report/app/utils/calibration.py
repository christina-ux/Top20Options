from typing import List, Tuple

def brier_score(probabilities: List[float], outcomes: List[int]) -> float:
    return sum((p - o)**2 for p, o in zip(probabilities, outcomes)) / max(len(probabilities), 1)

def expected_calibration_error(bins: int, probabilities: List[float], outcomes: List[int]) -> float:
    if not probabilities:
        return 0.0
    buckets = [[] for _ in range(bins)]
    for p, o in zip(probabilities, outcomes):
        idx = min(bins-1, int(p * bins))
        buckets[idx].append((p, o))
    ece = 0.0
    n = len(probabilities)
    for b in buckets:
        if not b: 
            continue
        avg_p = sum(p for p, _ in b)/len(b)
        avg_o = sum(o for _, o in b)/len(b)
        ece += (len(b)/n) * abs(avg_p - avg_o)
    return ece
