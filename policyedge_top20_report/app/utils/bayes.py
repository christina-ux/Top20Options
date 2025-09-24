def posterior_from_likelihoods(prior: float, likelihoods: list[float]) -> float:
    # likelihoods are likelihood ratios (LR+); posterior = (prior_odds * ΠLR) / (1 + prior_odds * ΠLR)
    if prior <= 0 or prior >= 1:
        raise ValueError("prior must be in (0,1)")
    odds = prior / (1 - prior)
    lr_prod = 1.0
    for lr in likelihoods:
        lr_prod *= max(lr, 1e-6)
    post_odds = odds * lr_prod
    return post_odds / (1 + post_odds)
