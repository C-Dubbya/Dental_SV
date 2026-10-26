---
name: procedure-code-explorer
description: Profile Dental procedure codes, source descriptions and recorded care settings; govern service-family lists, sedation-code exposure and historical code comparability when references are supplied. Do not invent clinical crosswalks or code validity.
---

# Procedure Code Explorer

## Model integration

Use `COUNT_CLAIM`, `COUNT_CLAIM_LINE`, `COUNT_CLAIM_BENEFICIARY` and `SUM_LINE_PAID_AMT` for the standard measures. Billed/allowed amounts use `SUM_LINE_BILLED_AMT` / `SUM_LINE_ALLOWED_AMT`; quantities use `SUM_BILLED_SERVICE_QTY` / `SUM_ALLOWED_SERVICE_QTY`, not line counts.

Default ordinary spend/utilization to header P; denial-focused questions follow the model's header/detail rules rather than inheriting a paid-header restriction. Include companion claim/line counts, available nonzero counts and paid amount for alternative dollar measures as required by the semantic view. Preserve source codes, including numeric-format and BLANK values; do not add a D-prefix restriction. Keep quantity units within compatible procedure groups.


## Service families, code editions and care settings

Read [service-definition governance](references/service-definition-governance.md) when the request needs clinical service families, cross-year code validity or sedation/anesthesia groupings. The reference supplies governance rules, not an approved code list. Ask for an exact list or offer raw-code profiling when membership is unavailable; an explicit user list can be analyzed as user-defined without claiming permanent governance.

For setting questions use `POS_CD` and `POS_DESC`, preserving unknowns. Provider address is not the treatment setting. For supplied sedation/anesthesia codes, state whether co-occurrence means same claim or same member and line-service date; count each qualifying source line once. Dental claims do not establish complete hospital/facility/anesthesia spending or clinical appropriateness.

Raw-code historical trends remain answerable even when a code-edition reference is unavailable; historical validity or replacement-code equivalence is then unverified, not automatically invalid. Do not interpret a source description or coverage list as a clinical category, an official measure list or proof of benefit entitlement.

## Purpose
Profile TennCare Dental activity using raw procedure codes and source procedure descriptions without inventing unsupported dental service-category mappings.

## Use this skill when
Use this skill when the user asks:

- What are the top dental procedure codes?
- How much was paid for code DXXXX?
- Which procedure codes drive the most utilization or spend?
- Show procedure mix over time.

## Required analyst behavior

- Use `DENTAL_CLAIMS_SV` for every factual result.
- Use exact `PROCEDURE_CD` values.
- Always display `PROCEDURE_DESC` alongside `PROCEDURE_CD`.
- Preserve BLANK / Not Populated procedure values when material.
- If the user asks for clinical categories without a validated code list, do not invent a crosswalk; either ask for a code list or provide raw-code profiling.

## Procedure

1. Determine whether the user wants:
   - a specific code or code list
   - top N codes
   - a time trend
   - a denial-oriented procedure analysis
2. Resolve period and date basis.
3. Pull requested measures such as:
   - claims
   - lines
   - utilizers
   - paid amount
   - billed amount
   - allowed amount
   - billed quantity
   - allowed quantity
4. If trending, group by YYYYMM.
5. If ranking, sort by the requested metric and limit to top N.
6. Return code and description together.

## Guardrails

- Do not call procedure exposure a diagnosis.
- Do not interpret line counts or quantities as visits.
- Allowed quantity can be positive on denied lines; state that when quantities are used.
- Do not create unsupported preventive/restorative/extraction groupings.

## Output requirements
Lead with the top code-level finding:

- "Procedure code DXXXX (Description) had the highest paid amount in the requested period."

Then include:

- code
- description
- requested metrics
- trend or ranking output

Always include a concise basis statement covering:

- date basis
- resolved period
- status scope
- procedure scope
- measure and denominator where relevant

## Example prompts

- Show the top 20 dental procedure codes by paid amount.
- Trend D1120 by month.
- Which procedure codes have the most denied lines?
- Compare procedure mix this quarter versus last quarter.
