def sprt_accept(log_likelihood_sum: float, alpha=0.05, beta=0.2) -> bool:
    import math
    A = (1 - beta) / alpha
    return log_likelihood_sum >= math.log(A)
