# Dental discovery: exports 10-13 and implemented changes

Reviewed 2026-10-26. Procedure/context (911 rows), status/date (3 rows) and field-coverage (44 rows) exports reconcile by claim-header status to `02_dental_baseline.csv` for line counts and paid amounts. Procedure zero-paid counts and allowed/billed sums also reconcile. Source execution timestamps were not provided. Dental semantic-view deployment/compilation and reference-join coverage are still pending.

## Header versus detail outcome

| Claim status | Line status | Lines | Paid amount |
| --- | --- | ---: | ---: |
| D | D | 182,061 | $0.00 |
| P | D | 249,050 | $0.00 |
| P | P | 4,633,079 | $286,872,460.41 |

True detail-line denial rate is 431,111 / 5,064,190 = 8.51%. The earlier 3.60% is the share of lines on denied claim headers. Of 443,673 zero-dollar lines on paid headers, 249,050 are denied details and 194,623 are paid details. Zero dollars alone cannot determine outcome.

Implemented: preserve base header P/D scope and default paid-claim baseline; expose independent line status, PAID_LINES/DENIED_LINES filters, true line-outcome metrics, header-scope line counts and DENIED_HEADER_LINE_SHARE. No implicit detail-status restriction was added to the fact or paid-claim baseline.

## Dates and financial channel

Claim and line first service dates differ on 1,313 denied-header lines and 5,550 paid-header lines. Both first/last line dates are populated; no reversed claim or line service ranges were found. Changing from claim first service to line first service does not resolve the negative-lag population or dollars. The 302,768 paid-header negative-lag lines still carry $17,634,265.44. They remain included; the cause is unresolved.

All groups report ENCOUNTER_IND = Y, contract F / Fee for service encounter, and payment level D / Detail. Encounter-paid dollars are zero. These are observed source markers, not evidence of no encounter records. All exported row-load/update timestamps are 2026-07-29 17:10:59.358; that describes row timestamps, not necessarily the date of a complete warehouse refresh.

Implemented: explicit claim-versus-line dates, separate line monthly grouping, financial-channel attributes and negative-lag counts. Retain claim-header service/profile alignment as the default; a future anchor change must be explicit and validated.

## Procedure, quantity and anatomy

- Each of the 518 observed raw procedure values has one source description in the export. Only BLANK / Not Populated lacks a usable source name. Display source descriptions directly; no reference join is needed to do so.
- Source CCS category 997 puts the D-prefixed codes in one broad CDT category. Numeric codes use 32 or 227; BLANK stays Not Populated. These fields cannot alone isolate preventive, restorative or other requested dental clinical cohorts.
- Billed and allowed quantities have no null/negative values; their aggregate totals are identical by code/status group. This does not prove equality on every individual row. Positive allowed quantities also occur on denied lines, so they do not establish approval or paid service.
- Paid-header quantities total 4,886,360, with range 0-11. The 146 zero-quantity paid-header lines belong to BLANK; denied-header quantities total 182,158, with range 1-8. Quantity meaning remains procedure-specific.
- Candidate-present rendering identifiers and positive rendering provider-location keys cover every profiled line. This does not establish current dimension match/uniqueness or an individual-dentist role for every provider.
- Candidate tooth number coverage: 1,385,789 paid-header and 56,170 denied-header lines. Any-surface coverage: 489,880 and 20,397 respectively. Quadrant and first-modifier candidate coverage are zero. Candidate screens exclude a short set of placeholders; raw code meaning remains source-dependent.

Implemented: source procedure names and exploratory CCS attributes, explicitly billed/allowed quantity facts and metrics, tooth/surface source attributes, and rendering keys/current reference role. No clinical code membership was invented, and no tooth/quantity/description presence restriction was added to base scope.

## Direct age and plan context

Claim-side program N/A occurs on 4,239,829 paid-header lines carrying $239,985,709.76. Raw claim HEALTH_PROGRAM_CD alone cannot classify a complete Medicaid population. Keep claim-recorded plan, operative assignment and claim organization roles separate; validate plan lookup matches before classifying programs.

Source ages differ from exact claim-DOB/line-date ages on 681 paid-header and 491 denied-header lines. DOB falls after line service on 77 and 228 lines respectively. Calculated age must retain an unknown/invalid category rather than silently using the standard profile age band or requiring a PMPM match.

Implemented: source-age provenance plus calculated age at claim and line first service; claim-recorded plan/program fields and a separate current claim-plan lookup role. The existing operative PMPM profile stays available for residence/program-assignment attributes, with explicit attribution. No benefit entitlement or enrollment denominator is inferred from either role.

## Remaining release gate

Run [reference_joins.sql](../validation/reference_joins.sql) to check current dimension keys, rendering/billing/claim-plan/organization coverage and inherited operative profile candidates/ties. DDL uses real current-row reference sources; declaring UNIQUE is not proof their keys are unique. Then compile the Dental semantic view/agent in Snowflake and reconcile representative semantic results against the source exports, especially header-versus-line denial cases.

Further broad schema discovery and sample collection are unnecessary for the implemented scope. Approved clinical service-category crosswalks, completed-treatment/visit definitions, dental entitlement and formal enrollment-based measures remain separate requirement decisions.
