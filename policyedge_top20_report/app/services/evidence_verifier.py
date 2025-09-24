from ..utils.bayes import posterior_from_likelihoods

def verify_and_label(top_rows: list[dict], prior: float=0.55, likelihoods: list[float]=[1.0]) -> list[dict]:
    labeled = []
    for row in top_rows:
        post = posterior_from_likelihoods(prior, likelihoods)
        publish_as = "Actionable" if post >= 0.90 else "MonitoringOnly"
        nr = dict(row); nr["posterior"] = round(post,4); nr["publish_as"] = publish_as
        labeled.append(nr)
    return labeled
