// PolicyEdge Short Signals Kit v1 - Supabase Edge Function
// Insert signals cleanly with validation

import { serve } from "https://deno.land/std@0.177.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface SignalRequest {
  signal_id?: string
  model_id: number
  model_name: string
  symbol?: string
  signal_type: string
  signal_strength: number
  confidence_score: number
  target_price?: number
  evidence?: any
  org_id: string
  run_id?: string
  scenario_name?: string
}

interface ValidationResult {
  isValid: boolean
  errors: string[]
  warnings: string[]
}

function validateSignal(signal: SignalRequest): ValidationResult {
  const errors: string[] = []
  const warnings: string[] = []

  // Required fields
  if (!signal.model_id) errors.push('model_id is required')
  if (!signal.model_name) errors.push('model_name is required')
  if (!signal.signal_type) errors.push('signal_type is required')
  if (!signal.org_id) errors.push('org_id is required')

  // Numeric validations
  if (typeof signal.signal_strength !== 'number' || signal.signal_strength < 0 || signal.signal_strength > 1) {
    errors.push('signal_strength must be a number between 0 and 1')
  }
  
  if (typeof signal.confidence_score !== 'number' || signal.confidence_score < 0 || signal.confidence_score > 1) {
    errors.push('confidence_score must be a number between 0 and 1')
  }

  // Type validations
  const validSignalTypes = ['TRANCHE_SHORT', 'REG_SHOCK', 'WAREHOUSE_STRESS', 'CYBER_INCIDENT', 'ENFORCEMENT_ACTION']
  if (!validSignalTypes.includes(signal.signal_type)) {
    errors.push(`signal_type must be one of: ${validSignalTypes.join(', ')}`)
  }

  // Warnings for optional but recommended fields
  if (!signal.symbol) warnings.push('symbol is recommended for most signal types')
  if (!signal.evidence || Object.keys(signal.evidence).length === 0) {
    warnings.push('evidence is recommended for signal validation')
  }

  return {
    isValid: errors.length === 0,
    errors,
    warnings
  }
}

function calculateCompositeScore(
  signalStrength: number,
  confidenceScore: number,
  modelWeight: number = 1.0,
  recencyHours: number = 0
): number {
  // Normalize inputs
  const strengthNorm = Math.max(0, Math.min(1, signalStrength))
  const confidenceNorm = Math.max(0, Math.min(1, confidenceScore))
  const weightNorm = Math.max(0.1, Math.min(2.0, modelWeight))
  
  // Recency decay factor
  const recencyFactor = Math.max(0.1, Math.exp(-recencyHours / 24.0))
  
  // Weighted composite
  const composite = (
    (strengthNorm * 0.4) +
    (confidenceNorm * 0.4) +
    (weightNorm * 0.2)
  ) * recencyFactor
  
  return Math.max(0, Math.min(1, composite))
}

function determineThresholdBreach(compositeScore: number, signalType: string): boolean {
  const thresholds = {
    'TRANCHE_SHORT': 0.75,
    'REG_SHOCK': 0.70,
    'WAREHOUSE_STRESS': 0.80,
    'CYBER_INCIDENT': 0.65,
    'ENFORCEMENT_ACTION': 0.70
  }
  
  const threshold = thresholds[signalType] || 0.75
  return compositeScore >= threshold
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Initialize Supabase client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false,
        },
      }
    )

    // Parse request body
    const signal: SignalRequest = await req.json()

    // Validate input
    const validation = validateSignal(signal)
    if (!validation.isValid) {
      return new Response(
        JSON.stringify({
          error: 'Validation failed',
          details: validation.errors,
          warnings: validation.warnings
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        },
      )
    }

    // Generate signal ID if not provided
    if (!signal.signal_id) {
      signal.signal_id = `${signal.signal_type}_${signal.model_id}_${Date.now()}`
    }

    // Calculate composite score
    const compositeScore = calculateCompositeScore(
      signal.signal_strength,
      signal.confidence_score,
      1.0, // default model weight
      0    // new signal, no recency decay
    )

    // Determine threshold breach
    const thresholdBreach = determineThresholdBreach(compositeScore, signal.signal_type)

    // Prepare signal data for insertion
    const signalData = {
      signal_id: signal.signal_id,
      model_id: signal.model_id,
      model_name: signal.model_name,
      symbol: signal.symbol,
      signal_type: signal.signal_type,
      signal_strength: signal.signal_strength,
      threshold_breach: thresholdBreach,
      target_price: signal.target_price,
      confidence_score: signal.confidence_score,
      evidence: signal.evidence || {},
      composite_score: compositeScore,
      org_id: signal.org_id,
      raw_data: {
        request_timestamp: new Date().toISOString(),
        run_id: signal.run_id,
        scenario_name: signal.scenario_name,
        validation_warnings: validation.warnings
      }
    }

    // Insert signal into database
    const { data, error } = await supabaseClient
      .from('peai.signals')
      .insert([signalData])
      .select()

    if (error) {
      console.error('Database error:', error)
      return new Response(
        JSON.stringify({
          error: 'Database insertion failed',
          details: error.message
        }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        },
      )
    }

    // Log audit trail
    const auditData = {
      action_type: 'signal_insert',
      table_name: 'peai.signals',
      record_id: data[0]?.id,
      org_id: signal.org_id,
      new_values: signalData,
      user_id: 'system', // Could be extracted from JWT
      ip_address: req.headers.get('x-forwarded-for') || 'unknown'
    }

    await supabaseClient
      .from('peai.audit_log')
      .insert([auditData])

    // Return success response
    return new Response(
      JSON.stringify({
        success: true,
        signal_id: signal.signal_id,
        composite_score: compositeScore,
        threshold_breach: thresholdBreach,
        data: data[0],
        warnings: validation.warnings
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      },
    )

  } catch (error) {
    console.error('Function error:', error)
    return new Response(
      JSON.stringify({
        error: 'Internal server error',
        details: error.message
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      },
    )
  }
})