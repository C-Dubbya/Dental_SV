---
name: provider-utilization-performance
description: Analyze Dental claims activity, spend and denials by billing or recorded rendering provider and location. Preserve provider roles; results are not individual-dentist quality scores or network-capacity estimates.
---

# Provider Utilization and Performance

## Model integration

Billing enrichment joins `BILL_MMIS_PROVIDER_ID` plus `BILL_MMIS_PROVLOC_ID` to `BILLING_PROVLOC_DIM`. Rendering enrichment joins `RENDER_MMIS_PROVIDER_ID` plus `RENDER_MMIS_PROVLOC_ID` to `RENDERING_PROVLOC_DIM`. Group at the requested provider or location grain; do not split a provider ranking into locations implicitly.

Display the matching `BILLING_PROVIDER_NM` / `RENDERING_PROVIDER_NM`, and use the role-specific NPI, type, specialty and county fields when requested. Names alone are not unique grouping keys. Standard measures use the view's named counts and `SUM_LINE_PAID_AMT`; denial analysis uses `COUNT_DENIED_CLAIM_LINE` and `DENIED_CLAIM_LINE_RATE` with both header statuses unless restricted explicitly. Return denominators with rate rankings and flag sparse groups rather than claiming clinical performance or fraud.


## Recorded care setting and comparable provider profiles

When requested, use `POS_CD` and `POS_DESC` to distinguish recorded treatment settings; billing/rendering county is location geography, not a place-of-service classification. Compare providers within the requested procedure, date, status, setting and unit scope before interpreting differences in paid amounts or activity. Sparse populations and different procedure mixes can explain rate differences; do not present a raw ranking as clinical quality or causal performance.

Use the procedure workflow for explicit sedation/anesthesia code lists, the anatomy workflow for tooth/surface questions, and the financial workflow for paid-versus-allowed or spend-driver comparisons. Co-recorded services in Dental claims do not establish the full facility/anesthesia bill, a care episode, network participation or benefit entitlement.

## Purpose
Summarize TennCare Dental claims activity by provider while preserving the distinction between billing provider and recorded rendering provider.

## Use this skill when
Use this skill when the user asks:

- Which providers drive the most dental spend?
- Show dental claims by dentist/provider.
- Compare billing and rendering provider activity.
- Which providers have the highest denial exposure?

## Required analyst behavior

- Use `DENTAL_CLAIMS_SV` for every factual result.
- If the user says "provider" without specifying, default to billing provider and disclose that role.
- Distinguish:
  - billing provider/location
  - recorded rendering provider/location
- Use the correct provider/location composite keys for enrichment.
- Preserve unknown provider categories through LEFT JOIN behavior.

## Procedure

1. Determine provider role:
   - billing
   - recorded rendering
2. Resolve period and date basis.
3. Pull requested metrics:
   - claims
   - lines
   - utilizers
   - paid amount
   - denied lines
   - denied line rate
   - top procedures
4. If requested, include supporting attributes such as:
   - provider name
   - provider type
   - specialty
   - county
   - NPI
5. Rank by the requested metric if applicable.

## Guardrails

- Distinct provider IDs are not automatically distinct individual dentists.
- Do not present provider counts as network adequacy or capacity.
- Billing and rendering roles must not be merged silently.
- Claims activity is not the same as completed care or visits.

## Output requirements
Lead with the provider-role-aware result:

- "Among billing providers, [Provider Name] had the highest paid amount in the requested period."

Then include:

- provider role used
- requested metric(s)
- provider identifiers or names
- breakout/trend if requested

Always include a concise basis statement covering:

- date basis
- resolved period
- provider role
- status scope
- measure and denominator

## Example prompts

- Show the top 25 billing providers by dental paid amount.
- Which rendering providers have the most denied lines?
- Compare provider activity by county.
- Trend the top billing providers by month.
