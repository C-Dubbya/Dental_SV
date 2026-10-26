---
name: dental-data-freshness-monitor
description: Assess Dental paid, claim-service and line-service recency and recent monthly volume when users ask about data currency, partial periods or reporting readiness. Date maxima are not refresh or completeness certification.
---

# Dental Data Freshness Monitor

## Model integration

Use `LATEST_PAID_DT`, `LATEST_SERVICE_DT` and `LATEST_LINE_SERVICE_DT`; the lowercase names below are output aliases, not additional semantic columns. For monthly context use `PAID_YR_MONTH_NBR` and `SERVICE_YR_MONTH_NBR` with `COUNT_CLAIM`, `COUNT_CLAIM_LINE` and `SUM_LINE_PAID_AMT`.

Compare a consistent population and header-status scope across date bases. Recency queries normally use header P; disclose any broader requested scope. A mid-month maximum and reduced volume suggest a potentially partial reporting period, not proven load failure or completeness. Older service periods can still have incomplete claims runout even when their last service date is month-end. Do not approve publication solely from date maxima or volume trends.


## Purpose
Assess how current the TennCare Dental claims data is, identify the latest available dates in the model, and assess whether recent reporting periods appear partial, without certifying completeness or publication readiness from dates alone.

## Use this skill when
Use this skill when the user asks questions like:

- How current is the dental claims data?
- What is the latest paid date?
- What is the latest service date?
- Is the latest month complete?
- Can we publish this month's dental dashboard?

## Required analyst behavior

- Use `DENTAL_CLAIMS_SV` for every factual result.
- Return both paid-date and service-date recency.
- Check:
  - latest claim paid date
  - latest claim-header first service date
  - latest line first service date
- For monthly context, use recent month trends and compare the latest month with prior months.
- Default spend and claim-based utilization to `CLAIM_STATUS_CD = 'P'`.
- Do not imply a warehouse refresh timestamp unless one is explicitly present in the source.
- If the latest month is visibly lower than prior months and the latest date falls mid-month, describe the observed period as potentially partial rather than declaring missing data or a failed load.

## Procedure

1. Query the latest available:
   - `latest_paid_dt`
   - `latest_service_dt`
   - `latest_line_service_dt`
2. Pull recent monthly trends on:
   - paid claims
   - claim lines
   - paid amount
3. Produce trends on both:
   - `CLAIM_PAID_DT` basis
   - `CLAIM_FIRST_SERVICE_DT` basis
4. Compare the most recent month to prior 3–6 months.
5. Flag:
   - likely partial latest month
   - abrupt drops in volume
   - obvious service-versus-paid lag patterns
6. If relevant, report known date anomalies such as paid dates preceding service dates without excluding them.

## Guardrails

- Do not describe date presence as proof of data completeness.
- Do not equate latest service date with latest payment processing date.
- Do not relabel claims as visits.
- Keep claim-header and line-level date anchors distinct.
- Low recent volume alone does not establish partial data. Describe the observed change and date coverage; do not assert a failed load without evidence.

## Output requirements
Lead with the finding:

- "Dental claims data currently runs through YYYY-MM-DD."

Then include:

- latest claim paid date
- latest claim-header first service date
- latest line first service date
- brief interpretation of whether the latest month appears partial
- recent monthly context if useful

Always include a concise basis statement covering:

- date basis
- resolved period
- status scope
- population
- measure and denominator where relevant

## Example prompts

- How current is the dental data?
- Is June complete yet?
- Show me the latest dental paid date and latest service date.
- Does the latest dental month look partial?
