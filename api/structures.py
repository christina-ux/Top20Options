from .report_generator import report_generator
from fastapi import FastAPI
from fastapi.responses import JSONResponse

app = FastAPI()

@app.get("/")
async def get_structures():
    """What to Consider Placing Today block"""
    try:
        result = report_generator.generate_structures_to_consider()
        return JSONResponse(content=result)
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)

def handler(request):
    return app(request.get('scope', {}), request.get('receive'), request.get('send'))