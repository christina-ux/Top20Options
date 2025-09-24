from fastapi import APIRouter

router = APIRouter()

@router.get("/live")
def live():
    return {"status": "ok"}

@router.get("/ready")
def ready():
    # TODO: add provider/db checks
    return {"status": "ready"}
