"""
PolicyEdge Short Signals Kit v1 - Reference Formulas
Reference formulas for PD/LGD/EL and composite signals
"""

import math
import numpy as np
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass


@dataclass
class LoanData:
    """Loan-level data structure"""
    loan_id: str
    ltv: float
    dti: float
    credit_score: int
    property_type: str
    property_state: str
    current_balance: float
    delinquency_status: str


@dataclass
class MacroScenario:
    """Macroeconomic scenario parameters"""
    unemployment_rate: float
    hpi_change: float
    gdp_change: float
    interest_rate_change: float


def calculate_pd_logistic(
    ltv: float,
    dti: float, 
    credit_score: int,
    unemployment_rate: float = 3.5,
    coefficients: Optional[Dict[str, float]] = None
) -> float:
    """
    Calculate Probability of Default using logistic regression
    
    Args:
        ltv: Loan-to-value ratio (0.0 to 1.0+)
        dti: Debt-to-income ratio (0.0 to 1.0+)
        credit_score: FICO score (300-850)
        unemployment_rate: Unemployment rate (0.0 to 15.0+)
        coefficients: Model coefficients (optional)
    
    Returns:
        Probability of default (0.0 to 1.0)
    """
    if coefficients is None:
        coefficients = {
            'intercept': -4.5,
            'ltv': 3.0,
            'dti': 2.5,
            'credit_score': -0.01,
            'unemployment': 0.15
        }
    
    # Normalize inputs
    ltv_norm = max(0, min(2.0, ltv)) - 0.8
    dti_norm = max(0, min(1.0, dti)) - 0.3
    credit_norm = 700 - max(300, min(850, credit_score))
    unemp_norm = max(0, min(20, unemployment_rate))
    
    # Calculate logit
    logit = (coefficients['intercept'] + 
             coefficients['ltv'] * ltv_norm +
             coefficients['dti'] * dti_norm + 
             coefficients['credit_score'] * credit_norm +
             coefficients['unemployment'] * unemp_norm)
    
    # Convert to probability
    pd = 1.0 / (1.0 + math.exp(-logit))
    
    return max(0.001, min(0.999, pd))


def calculate_lgd_base(
    ltv: float,
    property_type: str = 'SFR',
    property_state: str = 'CA',
    hpi_change: float = 0.0
) -> float:
    """
    Calculate Loss Given Default
    
    Args:
        ltv: Loan-to-value ratio
        property_type: Property type (SFR, CONDO, COOP, MFR)
        property_state: Property state code
        hpi_change: House price index change (decimal)
    
    Returns:
        Loss given default (0.0 to 1.0)
    """
    # Base LGD by property type
    base_lgd_map = {
        'SFR': 0.25,    # Single Family Residence
        'CONDO': 0.35,  # Condominium
        'COOP': 0.45,   # Cooperative
        'MFR': 0.40,    # Multi-Family Residence
    }
    base_lgd = base_lgd_map.get(property_type, 0.30)
    
    # LTV adjustment
    ltv_adjustment = max(0, (ltv - 0.8) * 0.5)
    
    # HPI adjustment (falling prices increase LGD)
    hpi_adjustment = max(-0.20, min(0.20, -hpi_change * 0.5))
    
    # State-specific adjustments
    state_adjustments = {
        'CA': -0.05, 'NY': -0.05, 'MA': -0.05,  # High-value markets
        'NV': 0.10, 'FL': 0.10, 'AZ': 0.10,     # Volatile markets
    }
    state_adjustment = state_adjustments.get(property_state, 0.0)
    
    lgd = base_lgd + ltv_adjustment + hpi_adjustment + state_adjustment
    
    return max(0.05, min(0.95, lgd))


def calculate_expected_loss(
    loan: LoanData,
    scenario: MacroScenario
) -> Dict[str, float]:
    """
    Calculate Expected Loss (EL = PD * LGD * EAD)
    
    Args:
        loan: Loan data
        scenario: Macroeconomic scenario
    
    Returns:
        Dictionary with PD, LGD, EAD, and EL values
    """
    pd = calculate_pd_logistic(
        loan.ltv, 
        loan.dti, 
        loan.credit_score,
        scenario.unemployment_rate
    )
    
    lgd = calculate_lgd_base(
        loan.ltv,
        loan.property_type,
        loan.property_state, 
        scenario.hpi_change
    )
    
    ead = loan.current_balance  # Exposure at Default
    
    el = pd * lgd * ead
    
    return {
        'pd': pd,
        'lgd': lgd,
        'ead': ead,
        'el': el,
        'el_rate': pd * lgd  # EL as rate
    }


def calculate_composite_score(
    signal_strength: float,
    confidence_score: float,
    model_weight: float = 1.0,
    recency_hours: float = 24.0
) -> float:
    """
    Calculate composite signal score with recency decay
    
    Args:
        signal_strength: Raw signal strength (0-1)
        confidence_score: Model confidence (0-1)
        model_weight: Model weight (0-2)
        recency_hours: Hours since signal generation
    
    Returns:
        Composite score (0-1)
    """
    # Normalize inputs
    strength_norm = max(0, min(1, signal_strength))
    confidence_norm = max(0, min(1, confidence_score))
    weight_norm = max(0.1, min(2.0, model_weight))
    
    # Recency decay factor
    recency_factor = max(0.1, math.exp(-recency_hours / 24.0))
    
    # Weighted composite
    composite = (
        (strength_norm * 0.4) +
        (confidence_norm * 0.4) +
        (weight_norm * 0.2)
    ) * recency_factor
    
    return max(0, min(1, composite))


def stress_test_portfolio(
    loans: List[LoanData],
    scenarios: List[MacroScenario],
    correlation_matrix: Optional[np.ndarray] = None
) -> Dict[str, any]:
    """
    Run stress tests on loan portfolio
    
    Args:
        loans: List of loan data
        scenarios: List of stress scenarios
        correlation_matrix: Asset correlation matrix (optional)
    
    Returns:
        Stress test results
    """
    results = {}
    
    for i, scenario in enumerate(scenarios):
        scenario_losses = []
        scenario_details = []
        
        for loan in loans:
            loss_calc = calculate_expected_loss(loan, scenario)
            scenario_losses.append(loss_calc['el'])
            scenario_details.append({
                'loan_id': loan.loan_id,
                **loss_calc
            })
        
        total_exposure = sum(loan.current_balance for loan in loans)
        total_el = sum(scenario_losses)
        loss_rate = total_el / total_exposure if total_exposure > 0 else 0
        
        results[f'scenario_{i+1}'] = {
            'scenario_params': scenario.__dict__,
            'total_exposure': total_exposure,
            'total_expected_loss': total_el,
            'loss_rate': loss_rate,
            'loan_details': scenario_details
        }
    
    return results


def calculate_tranche_subordination(
    pool_losses: float,
    tranche_attachment: float,
    tranche_detachment: float,
    pool_balance: float
) -> Dict[str, float]:
    """
    Calculate tranche losses using subordination waterfall
    
    Args:
        pool_losses: Total pool losses (dollar amount)
        tranche_attachment: Attachment point (0-1)
        tranche_detachment: Detachment point (0-1)
        pool_balance: Total pool balance
    
    Returns:
        Tranche loss calculations
    """
    loss_rate = pool_losses / pool_balance if pool_balance > 0 else 0
    
    # Tranche losses based on subordination
    if loss_rate <= tranche_attachment:
        tranche_loss_rate = 0.0
    elif loss_rate >= tranche_detachment:
        tranche_loss_rate = 1.0
    else:
        tranche_loss_rate = ((loss_rate - tranche_attachment) / 
                           (tranche_detachment - tranche_attachment))
    
    tranche_size = (tranche_detachment - tranche_attachment) * pool_balance
    tranche_loss = tranche_loss_rate * tranche_size
    
    return {
        'pool_loss_rate': loss_rate,
        'tranche_loss_rate': tranche_loss_rate,
        'tranche_size': tranche_size,
        'tranche_loss': tranche_loss,
        'attachment_point': tranche_attachment,
        'detachment_point': tranche_detachment
    }


def validate_signal_thresholds(
    signals: List[Dict],
    thresholds: Dict[str, float]
) -> List[Dict]:
    """
    Validate signals against configured thresholds
    
    Args:
        signals: List of signal dictionaries
        thresholds: Threshold configuration
    
    Returns:
        Filtered and validated signals
    """
    validated = []
    
    for signal in signals:
        composite = signal.get('composite_score', 0)
        confidence = signal.get('confidence_score', 0)
        evidence_count = len(signal.get('evidence', []))
        
        if (composite >= thresholds.get('composite_score_minimum', 0.7) and
            confidence >= thresholds.get('confidence_threshold', 0.8) and
            evidence_count >= thresholds.get('evidence_required_sources', 2)):
            
            signal['threshold_breach'] = True
            validated.append(signal)
        else:
            signal['threshold_breach'] = False
            signal['rejection_reason'] = 'Below thresholds'
    
    return validated


# Example usage and testing functions
if __name__ == "__main__":
    # Test data
    test_loan = LoanData(
        loan_id="TEST_001",
        ltv=0.85,
        dti=0.35,
        credit_score=720,
        property_type="SFR",
        property_state="CA",
        current_balance=400000,
        delinquency_status="current"
    )
    
    test_scenario = MacroScenario(
        unemployment_rate=8.0,
        hpi_change=-0.20,
        gdp_change=-0.035,
        interest_rate_change=0.02
    )
    
    # Run calculations
    el_result = calculate_expected_loss(test_loan, test_scenario)
    print(f"Expected Loss Results: {el_result}")
    
    composite = calculate_composite_score(0.85, 0.80, 1.2, 12.0)
    print(f"Composite Score: {composite:.3f}")