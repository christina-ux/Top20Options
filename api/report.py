import sys
import os

# Add the policyedge_top20_report directory to Python path
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'policyedge_top20_report'))

from fastapi import FastAPI
from fastapi.responses import JSONResponse
from .report_generator import report_generator

app = FastAPI(title="PolicyEdge Daily Report API", version="1.0")

@app.get("/")
async def root():
    return {"service": "PolicyEdge Daily Report API", "version": "1.0"}

@app.get("/api/market-shift")
async def get_market_shift():
    """Get Today's Market Shift block"""
    try:
        result = report_generator.generate_market_shift()
        return JSONResponse(content=result)
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)

@app.get("/api/intelligence-mapping")
async def get_intelligence_mapping():
    """Get Intelligence → Market Mapping table"""
    try:
        result = report_generator.generate_intelligence_mapping()
        return JSONResponse(content=result)
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)

@app.get("/api/tripwires")
async def get_tripwires():
    """Get Tripwires to Drive Options Flow block"""
    try:
        result = report_generator.generate_tripwires()
        return JSONResponse(content=result)
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)

@app.get("/api/structures")
async def get_structures():
    """Get What to Consider Placing Today block"""
    try:
        result = report_generator.generate_structures_to_consider()
        return JSONResponse(content=result)
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)

@app.get("/api/full-report")
async def get_full_report():
    """Get the complete daily Equity + Options Reflex Report"""
    try:
        result = report_generator.generate_full_report()
        return JSONResponse(content=result)
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)

# Export for Vercel
def handler(request):
    return app(request.get('scope', {}), request.get('receive'), request.get('send'))