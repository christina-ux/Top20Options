from fastapi import FastAPI
from .routers import run, health

app = FastAPI(title="PolicyEdge Regulatory Alpha Runner", version="3.1")

app.include_router(health.router, prefix="/health", tags=["health"])
app.include_router(run.router, prefix="/run", tags=["run"])

@app.get("/")
def root():
    return {"service": "policyedge-reg-alpha-runner", "version": "3.1"}
