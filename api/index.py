import sys
import os

# Add the policyedge_top20_report directory to Python path
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'policyedge_top20_report'))

from policyedge_top20_report.app.main import app

# Export the app for Vercel
def handler(request):
    return app(request.get('scope', {}), request.get('receive'), request.get('send'))