from fastapi import APIRouter
from ..tasks.orchestrator import run_window, poll_tripwires

router = APIRouter()

@router.post("/preopen")
def preopen():
    return run_window("preopen")

@router.post("/midday")
def midday():
    return run_window("midday")

@router.post("/eod")
def eod():
    return run_window("eod")

@router.post("/poll")
def poll():
    return poll_tripwires()
