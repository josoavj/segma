from fastapi import APIRouter

router = APIRouter()


@router.get("/api/v1/health")
async def health():
    """Endpoint de santé basique"""
    return {"status": "ok"}
