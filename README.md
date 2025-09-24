# PolicyEdge Top20Options - Vercel Deployment

This repository contains the PolicyEdge Daily Equity + Options Reflex Report system organized for deployment on Vercel.

## System Overview

The system automatically generates a daily report with four key blocks:

1. **Today's Market Shift** - Current market state summary (SPY, QQQ, IWM, TLT, BTC, leaders, breadth)
2. **Intelligence → Market Mapping** - Table mapping policy signals to market impacts and options strategies  
3. **Tripwires to Drive Options Flow** - Status and evidence for key regulatory triggers
4. **What to Consider Placing Today** - Specific options structures based on regulatory analysis

## Deployment Structure

```
├── api/                    # Vercel serverless functions (Python)
│   ├── full-report.py     # Complete daily report endpoint
│   ├── market-shift.py    # Market data block endpoint
│   ├── intelligence-mapping.py  # Intelligence table endpoint
│   ├── tripwires.py       # Tripwire status endpoint
│   ├── structures.py      # Options structures endpoint
│   └── report_generator.py # Core report generation logic
├── public/                # Static web interface
│   └── index.html         # Dashboard for viewing reports
├── policyedge_top20_report/ # Original FastAPI application
└── vercel.json            # Vercel deployment configuration
```

## API Endpoints

Once deployed on Vercel, the following endpoints will be available:

- `GET /api/full-report` - Complete daily report (all four blocks)
- `GET /api/market-shift` - Today's Market Shift block only
- `GET /api/intelligence-mapping` - Intelligence → Market Mapping table only
- `GET /api/tripwires` - Tripwires status block only
- `GET /api/structures` - Options structures block only

## Web Interface

Access the dashboard at the root URL to view the formatted daily report with interactive controls.

## Local Development

To run locally for testing:

```bash
# Install dependencies
pip install -r requirements.txt

# Run the original FastAPI app
cd policyedge_top20_report
uvicorn app.main:app --reload --port 8080

# Or test the report generator directly
python -c "from api.report_generator import report_generator; print(report_generator.generate_full_report())"
```

## Vercel Deployment

1. Connect this repository to your Vercel project
2. Vercel will automatically detect the Python functions in `/api/`
3. Set environment variables in Vercel dashboard if needed:
   - `DATABASE_URL` (optional - for live data)
   - `MARKET_API_KEY` (optional - for real market data)
   - `POLICY_API_KEY` (optional - for real policy feeds)

## Features

- **Serverless Architecture**: Each API endpoint runs as a separate Vercel function
- **Static Frontend**: Fast-loading HTML dashboard with JavaScript interactions
- **Mock Data**: Includes realistic sample data for demonstration
- **Modular Design**: Each report block can be accessed independently
- **Real-time Generation**: Reports generated fresh on each request

## Sample Output

The system generates reports in this format:

```markdown
# Equity + Options Reflex Report — September 24, 2025

## Today's Market Shift
- SPY +0.8%, QQQ +1.2%, IWM +0.4%; TLT -0.3%
- Leaders: NVDA (+3.2%), AAPL (+1.8%), MSFT (+1.1%)
- Breadth A/D: 2.1:1 (advancing:declining); VWAP states noted
- Crypto: BTC +2.1%

## Intelligence → Market Mapping
[Table with policy signals, market impacts, and options strategies]

## Tripwires (status & evidence)
[Status of key regulatory triggers with evidence]

## What to Consider (structures only)
[Specific options structures based on analysis]
```

## License

© PolicyEdge AI - IP protected under Sovereignty Protocol. Educational/informational use only, no investment advice provided.