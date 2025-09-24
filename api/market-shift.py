from .report_generator import report_generator
from fastapi import FastAPI
from fastapi.responses import JSONResponse

app = FastAPI()

@app.get("/")
async def get_market_shift():
    """Today's Market Shift block"""
    try:
        result = report_generator.generate_market_shift()
        return JSONResponse(content=result)
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)

def handler(request):
    return app(request.get('scope', {}), request.get('receive'), request.get('send'))