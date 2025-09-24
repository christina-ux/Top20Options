import json, sys, time
def log(event: str, **kwargs):
    entry = {"ts": time.time(), "event": event, **kwargs}
    sys.stdout.write(json.dumps(entry) + "\n")
    sys.stdout.flush()
