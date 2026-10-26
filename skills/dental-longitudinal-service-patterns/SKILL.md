---
name: dental-longitudinal-service-patterns
description: Analyze observed Dental member and member-tooth procedure sequences, repeat intervals and follow-up claims. Use for longitudinal claims patterns, not continuous enrollment, clinical retreatment, duplicate-payment findings or treatment success.
---

# Dental Longitudinal Service Patterns

## Define the observation contract

Use `DENTAL_CLAIMS_SV` for every factual result. Resolve index procedure/list, later procedure/list, member versus member-tooth grain, index period, lookback, follow-up window, same-day handling and status. If the request supplies no usable code list, ask for it or offer raw-code exploration; do not infer treatment pathways from labels.

- Use `LINE_FIRST_SERVICE_DT` for procedure-sequence timing, with `LINE_LAST_SERVICE_DT` when an explicitly defined interval requires it. State the line-service anchor; profile enrichment still uses member plus claim-header first service date.
- Default ordinary exposure to paid headers; disclose that this includes denied details. If the question requires paid-detail exposure, use the explicit detail-status scope. Never infer outcome from positive dollars.
- Source row key is `CLAIM_ICN_NBR` plus `CLAIM_LINE_NBR`. Deduplicate by that key before sequence joins. Member-tooth matching also requires `BENEFICIARY_ID` and a usable `TOOTH_NBR_CD`; do not match all unknown tooth values as if they were one tooth.
- For an unspecified index choice, use the first observed qualifying line in the requested index period per requested member/member-tooth grain and disclose it. This is not first-ever care or a clinical new start. A washout claim requires the specified lookback and visible source limitations.

## Sequence construction

1. Build index and qualifying follow-up sets separately under the resolved filters. Pull follow-up data beyond the index-period end through the requested follow-up limit; a report-year filter must not truncate a crossing-year follow-up window.
2. Unless explicitly requested otherwise, follow-up begins strictly after the index service date and includes the defined endpoint. Same-date lines are co-recorded activity, not an ordered clinical sequence. Claim/line IDs can break processing ties but cannot establish clinical order.
3. For one row per index member/member-tooth, select the earliest qualifying later date and count any qualifying follow-up once. Many-to-many procedure joins must not multiply index counts, later claims or dollars. When amounts are requested, aggregate distinct qualifying source lines once at the requested attribution grain.
4. Define observation maturity against the applicable source service-date bounds: use the maximum Dental line-service date for the same base status population, not the last occurrence of the follow-up code. Separate index rows whose follow-up window extends beyond that maximum, report their count, and disclose any explicitly chosen mature-window restriction. A window falling inside source bounds still does not prove complete runout or individual continuous observability.
5. Report index and observed-follow-up counts with explicit denominators. Cross-tab observed follow-up versus window-contained-in-source-range so an immature window with an already observed follow-up is not counted twice in a three-way total. If restricting a rate to mature windows, apply that restriction to both numerator and denominator and report excluded indexes separately. Do not describe absence of a later claim as disenrollment, unmet need, interrupted care or treatment failure. Do not require PMPM matching merely to sequence the claims.

## Limits and output

Repeated same-code/member/tooth lines are candidates for descriptive review, not confirmed duplicate payments or retreatment. Different dates, surfaces, provider roles, benefit rules and unavailable adjustment history may matter. Anatomy changes or missing teeth identifiers can prevent tooth-level linkage; report these separately, without imputing primary/permanent dentition or a quadrant.

Return member IDs only when explicitly requested for internal case review; otherwise aggregate. State code lists, index selection, grain, date/status scope, window endpoints, same-day rule and observation limitations. A paid claim is not proof of completed treatment, and observed co-occurrence is not a clinical pathway or outcome.

## Example requests

- For members with an explicitly supplied index code, how many have a supplied follow-up code within 90 days?
- Describe intervals between repeated occurrences of the same code on the same recorded member-tooth combination.
- Show the first observed qualifying procedure in the index period without calling it the member's first-ever treatment.
