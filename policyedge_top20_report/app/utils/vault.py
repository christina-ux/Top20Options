import os, hashlib, json, time
from typing import Dict, Any

def sha256_bytes(b: bytes) -> str:
    h = hashlib.sha256(); h.update(b); return h.hexdigest()

def write_manifest(bundle_dir: str, files: Dict[str, bytes]) -> str:
    os.makedirs(bundle_dir, exist_ok=True)
    manifest = {"created": time.time(), "files": []}
    for name, data in files.items():
        path = os.path.join(bundle_dir, name)
        with open(path, "wb") as f: f.write(data)
        manifest["files"].append({"name": name, "sha256": sha256_bytes(data)})
    with open(os.path.join(bundle_dir, "manifest.json"), "w") as f:
        json.dump(manifest, f, indent=2)
    return os.path.join(bundle_dir, "manifest.json")
