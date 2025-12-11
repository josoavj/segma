"""Module API principal"""
from fastapi import APIRouter
from app.api.routes import segmentation, health

api_router = APIRouter()

# Inclure les routes
api_router.include_router(segmentation.router)
api_router.include_router(health.router)
