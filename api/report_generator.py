import sys
import os
from typing import Dict, Any, List
import json
from datetime import datetime
import asyncio

# Add the policyedge_top20_report directory to Python path
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'policyedge_top20_report'))

from policyedge_top20_report.app.services.impact_modeler import compute_reg_impact
from policyedge_top20_report.app.services.dollar_impact_calculator import finalize_dollar_impact
from policyedge_top20_report.app.services.table_composer import score_and_top5
from policyedge_top20_report.app.services.options_structurer import build_structures_for_rows
from policyedge_top20_report.app.services.evidence_verifier import verify_and_label
from policyedge_top20_report.app.services.tripwire_evaluator import evaluate_tripwires


class ReportGenerator:
    def __init__(self):
        self.configs_dir = os.path.join(os.path.dirname(__file__), '..', 'policyedge_top20_report', 'configs')
        
    def load_json(self, filename: str) -> dict:
        """Load JSON configuration file"""
        try:
            path = os.path.join(self.configs_dir, filename)
            with open(path, 'r') as f:
                return json.load(f)
        except FileNotFoundError:
            return {}
    
    def generate_market_shift(self) -> Dict[str, Any]:
        """Generate Today's Market Shift block with mock data"""
        # In production, this would connect to real market data APIs
        market_data = {
            "pct_spy": "+0.8%",
            "pct_qqq": "+1.2%", 
            "pct_iwm": "+0.4%",
            "pct_tlt": "-0.3%",
            "pct_btc": "+2.1%",
            "leaders": "NVDA (+3.2%), AAPL (+1.8%), MSFT (+1.1%)",
            "ad_ratio": "2.1:1 (advancing:declining)",
            "vwap_notes": "SPY above VWAP, QQQ testing resistance"
        }
        
        return {
            "section": "Today's Market Shift",
            "data": market_data,
            "formatted": f"""- SPY {market_data['pct_spy']}, QQQ {market_data['pct_qqq']}, IWM {market_data['pct_iwm']}; TLT {market_data['pct_tlt']}
- Leaders: {market_data['leaders']}
- Breadth A/D: {market_data['ad_ratio']}; {market_data['vwap_notes']}
- Crypto: BTC {market_data['pct_btc']}
[Citations: Market data as of {datetime.now().strftime('%H:%M ET')}]"""
        }
    
    def generate_intelligence_mapping(self) -> Dict[str, Any]:
        """Generate Intelligence → Market Mapping table"""
        # Sample intelligence signals with market impact mapping
        mapping_data = [
            {
                "intelligence_signal": "CMS MA Rate Cuts (-2.5%)",
                "market_impact": "Insurance sector pressure, MA enrollment shifts",
                "options_read": "Bear put spreads on MA-heavy insurers",
                "source_refs": "CMS-2024-0042"
            },
            {
                "intelligence_signal": "CFPB Late Fee Cap ($8→$3)",
                "market_impact": "Credit card revenue hit ~$8B annually",
                "options_read": "Debit put spreads on fee-dependent issuers",
                "source_refs": "CFPB-2024-0001"
            },
            {
                "intelligence_signal": "DOE LNG Export Pause",
                "market_impact": "LNG developer capex delays, utility shifts",
                "options_read": "Puts on LNG developers + XLU call spreads",
                "source_refs": "DOE-2024-LNG"
            }
        ]
        
        # Format as markdown table
        rows = []
        for item in mapping_data:
            rows.append(f"| {item['intelligence_signal']} | {item['market_impact']} | {item['options_read']} | {item['source_refs']} |")
        
        formatted_table = "\n".join(rows)
        
        return {
            "section": "Intelligence → Market Mapping",
            "data": mapping_data,
            "formatted": formatted_table
        }
    
    def generate_tripwires(self) -> Dict[str, Any]:
        """Generate Tripwires to Drive Options Flow block"""
        # Load tripwire configuration
        tripwire_config = self.load_json('tripwire_library_v1_3.json')
        
        # Sample context for evaluation (in production, would be live metrics)
        context = {
            "cms_rate_delta": -2.5,
            "cfpb_rule_status": "Final",
            "doe_lng_permits": "Paused"
        }
        
        # Evaluate tripwires
        results = evaluate_tripwires(tripwire_config, context)
        
        # Generate sample tripwire status
        tripwire_status = [
            {
                "tripwire": "CMS Final Rate Negative",
                "status": "TRIGGERED",
                "evidence": "Rate delta -2.5% vs advance notice",
                "action": "Bear put spreads on MA insurers activated"
            },
            {
                "tripwire": "CFPB Late Fee Cap",
                "status": "MONITORING", 
                "evidence": "Rule finalized, court challenges pending",
                "action": "Debit put spreads prepared, waiting legal clarity"
            },
            {
                "tripwire": "Volatility Spike Guard",
                "status": "GREEN",
                "evidence": "VIX 18.2, within normal range",
                "action": "No defensive positioning needed"
            }
        ]
        
        # Format as structured block
        formatted_lines = []
        for item in tripwire_status:
            status_marker = "🔴" if item['status'] == "TRIGGERED" else "🟡" if item['status'] == "MONITORING" else "🟢"
            formatted_lines.append(f"**{item['tripwire']}** {status_marker} {item['status']}")
            formatted_lines.append(f"  Evidence: {item['evidence']}")
            formatted_lines.append(f"  Action: {item['action']}")
            formatted_lines.append("")
        
        return {
            "section": "Tripwires to Drive Options Flow",
            "data": tripwire_status,
            "formatted": "\n".join(formatted_lines)
        }
    
    def generate_structures_to_consider(self) -> Dict[str, Any]:
        """Generate What to Consider Placing Today block"""
        # Load options templates
        options_map = self.load_json('options_templates_map.json')
        
        # Sample regulatory impacts
        policy_events = [
            {
                "signal": "CMS MA Rate Cuts",
                "agency": "CMS",
                "dollar_impact_usd": 15000000000,  # $15B
                "tradable_unit": "UNH, HUM, CVS"
            },
            {
                "signal": "CFPB Credit Card Fees",
                "agency": "CFPB", 
                "dollar_impact_usd": 8000000000,   # $8B
                "tradable_unit": "JPM, BAC, COF"
            }
        ]
        
        # Process through the pipeline
        reg_intermediate = compute_reg_impact(policy_events)
        reg_final = finalize_dollar_impact(reg_intermediate)
        top_signals = score_and_top5(reg_final, options_map)
        structures = build_structures_for_rows(top_signals)
        verified_structures = verify_and_label(structures, prior=0.55, likelihoods=[1.0])
        
        # Format structures
        formatted_lines = []
        for i, structure in enumerate(verified_structures, 1):
            impact_usd = structure.get('dollar_impact_usd', 0) or 0
            impact_str = f"${impact_usd/1e9:.1f}B" if impact_usd > 0 else "TBD"
            
            formatted_lines.append(f"**{i}. {structure.get('signal', 'Signal')}-Related Structure**")
            formatted_lines.append(f"   Underlying: {structure.get('tradable_unit', 'N/A')}")
            formatted_lines.append(f"   Strategy: {structure.get('options_play', 'TBD')}")
            formatted_lines.append(f"   Risk Size: Based on {impact_str} impact")
            formatted_lines.append(f"   Confidence: {structure.get('posterior', 'Medium')}")
            formatted_lines.append("")
        
        return {
            "section": "What to Consider Placing Today", 
            "data": verified_structures,
            "formatted": "\n".join(formatted_lines)
        }
    
    def generate_full_report(self) -> Dict[str, Any]:
        """Generate the complete daily Equity + Options Reflex Report"""
        date_et = datetime.now().strftime('%B %d, %Y')
        
        # Generate all four blocks
        market_shift = self.generate_market_shift()
        intelligence_mapping = self.generate_intelligence_mapping()
        tripwires = self.generate_tripwires()
        structures = self.generate_structures_to_consider()
        
        # Load the report template
        template_path = os.path.join(os.path.dirname(__file__), '..', 'policyedge_top20_report', 'report', 'templates', 'report_template.md')
        try:
            with open(template_path, 'r') as f:
                template = f.read()
        except FileNotFoundError:
            template = """# Equity + Options Reflex Report — {DATE_ET}

## Today's Market Shift
{market_shift}

## Intelligence → Market Mapping
| Intelligence Signal | Likely Market Impact | Options Read (structures only) | Source Refs |
|---|---|---|---|
{mapping_rows}

## Tripwires (status & evidence)
{tripwires_block}

## What to Consider (structures only)
{structures_block}

## Method Note (PolicyEdge Protocol)
Feeds, timestamps, credibility results, posterior thresholds, evidence gaps, calibration metrics (Brier/ECE).

> Non‑advice. IP protected under Sovereignty Protocol.
"""
        
        # Fill in the template
        full_report = template.format(
            DATE_ET=date_et,
            pct_spy="+0.8%",
            pct_qqq="+1.2%", 
            pct_iwm="+0.4%",
            pct_tlt="-0.3%",
            pct_btc="+2.1%",
            leaders="NVDA (+3.2%), AAPL (+1.8%), MSFT (+1.1%)",
            ad_ratio="2.1:1 (advancing:declining)",
            market_shift=market_shift['formatted'],
            mapping_rows=intelligence_mapping['formatted'],
            tripwires_block=tripwires['formatted'],
            structures_block=structures['formatted']
        )
        
        return {
            "report_date": date_et,
            "sections": {
                "market_shift": market_shift,
                "intelligence_mapping": intelligence_mapping, 
                "tripwires": tripwires,
                "structures": structures
            },
            "full_report_markdown": full_report,
            "generated_at": datetime.now().isoformat()
        }

# Create global instance
report_generator = ReportGenerator()