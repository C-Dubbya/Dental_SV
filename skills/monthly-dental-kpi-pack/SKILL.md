---
name: monthly-dental-kpi-pack
description: Produce monthly Dental claims, lines, utilizers, spend and per-utilizer scorecards with explicit dates, status scope and attribution roles. Use for analytical summaries, not building dashboard software or scheduling jobs.
---

# Monthly Dental KPI Pack

## Model integration

Use `COUNT_CLAIM`, `COUNT_CLAIM_LINE`, `COUNT_CLAIM_BENEFICIARY`, `SUM_LINE_PAID_AMT`, `PAID_PER_CLAIM`, `PAID_PER_UTILIZER` and `CLAIMS_PER_UTILIZER`. Group and order by `PAID_YR_MONTH_NBR` or `SERVICE_YR_MONTH_NBR`; explicit line-service trends use `LINE_SERVICE_YR_MONTH_NBR`.

Resolve periods using the semantic-view defaults, not the machine clock. Compute distinct period totals independently, including across monthly rows; do not sum monthly utilizers. Recompute ratios from their underlying period measures instead of averaging subgroup ratios. Return resolved dates and disclose partial periods. This workflow produces an on-demand analysis; it does not create a dashboard application or schedule recurring execution.


## Purpose
Produce a standardized monthly TennCare Dental claims summary using explicit, governed definitions for claims, lines, utilizers, and financial measures.

## Use this skill when
Use this skill when the user asks for:

- a monthly dental KPI summary
- a dental dashboard
- recurring claims/utilization/spend reporting
- executive or operational dental scorecards

## Required analyst behavior

- Use `DENTAL_CLAIMS_SV` for every factual result.
- Default spend and claim-based utilization to `CLAIM_STATUS_CD = 'P'`.
- State the date basis explicitly:
  - `CLAIM_PAID_DT` for paid-date reporting
  - `CLAIM_FIRST_SERVICE_DT` for service-date reporting
- Distinguish:
  - claims = `COUNT_CLAIM`
  - lines = `COUNT_CLAIM_LINE`
  - utilizers = `COUNT_CLAIM_BENEFICIARY`
  - spend = `SUM_LINE_PAID_AMT`
- Do not call claims visits.
- Do not describe utilizers as all enrollees.
- Do not compute grand totals by summing subgroup distinct counts.

## Procedure

1. Resolve:
   - requested period
   - date basis
   - requested breakout
2. Pull monthly metrics:
   - claims
   - lines
   - utilizers
   - paid amount
   - paid per claim
   - paid per utilizer
   - claims per utilizer
3. If requested, add breakouts by one or more of:
   - claim organization
   - billing provider
   - recorded rendering provider
   - procedure code
   - residence county
   - service county
   - operative assigned plan
   - claim-recorded plan
4. If using profile attributes, state that attribution follows the selected operative health-plan assignment at service date.
5. Return a time series and summarize the main directional finding.

## Guardrails

- Claims, lines, utilizers, and spend are distinct measures; never relabel one as another.
- Paid claims may contain denied detail lines.
- No PMPM or all-enrollee utilization denominator is implied.
- Preserve unknown categories when enrichment joins are involved.
- If no period is supplied, use the semantic-view default and disclose the resolved period.

## Output requirements
Lead with the main KPI finding:

- "In YYYYMM, paid-claim dental spend was $X across Y distinct claims and Z utilizers."

Then provide:

- concise trend summary
- comparison to prior period if requested
- native table for multi-row output
- chart when helpful for monthly trend interpretation

Always include a concise basis statement covering:

- date basis
- resolved period
- status scope
- population
- measure and denominator where relevant

## Example prompts

- Give me a monthly dental KPI pack for this fiscal year.
- Show dental claims, utilizers, and spend by month.
- Create an executive dental scorecard.
- Trend monthly dental paid amount and claims.
