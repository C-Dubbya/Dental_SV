# Dental discovery: exports 05-09

Reviewed 2026-10-26. Evidence: `05_claim_line_columns.csv`, `06_dental_grain.csv`, `07_dental_monthly.csv`, `08_dental_service_paid_lag.csv`, and `09_procedure_objects.csv`, reconciled against `02_dental_baseline.csv`. Execution timestamps were not supplied. These are source-profile findings; Dental DDL is still a starter and has not been compiled/deployed here.

## Confirmed grain and totals

- 5,064,190 source lines, 1,378,823 distinct ICNs and 589,605 distinct members.
- ICN + line number has no missing keys, no duplicate groups and a maximum of one row per pair.
- No ICN has both paid and denied statuses in this extracted population. This is an observed property, not a permanent business invariant.
- There are 41,326 members represented in both statuses, derived from paid members + denied members minus the unduplicated member total. Member counts still must not be added across status groups.
- Monthly paid- and service-date line counts, zero-paid counts and amount totals each reconcile exactly to the baseline by status. Lag-bucket lines and paid amounts also reconcile by status. Decimal arithmetic was used for dollars.

## Date window and priority anomaly

Paid-month rows cover June 2025 through June 2026. Boundary months are partial: the actual paid-date range is 2025-06-29 through 2026-06-12. July 2025 through May 2026 form 11 complete calendar months within those observed bounds. This does not establish financial completeness or mature service cohorts.

Service-month rows reach 2002 on denied lines and 2011 on paid lines; these are historical tails inside the available payment population, not complete service-year histories. A service-basis cohort remains bounded by the available source payment data.

302,768 paid lines (6.20% of paid lines) have payment dates 1-4 days before CLAIM_FIRST_SERVICE_DT. They carry $17,634,265.44 (6.15% of paid dollars). Another 548 denied lines have the same negative-lag range. No explanation is established yet. Do not remove these rows or infer erroneous payments from the date comparison alone.

The schema exposes LINE_FIRST_SERVICE_DT and LINE_LAST_SERVICE_DT separately from claim header service dates. Compare these before choosing a line-service date or changing the inherited profile anchor. The next query also cross-tabulates LINE_STATUS_CD against CLAIM_STATUS_CD; the existing scope intentionally remains header P/D pending evidence and a business decision.

## Confirmed field availability

The corrected claim schema has 316 columns. These fields are now documented in source metadata, but their Dental population and usability are not yet established:

| Area | Confirmed source fields | Next decision |
| --- | --- | --- |
| Procedure context | PROCEDURE_CD, PROCEDURE_DESC, PROCEDURE_DIM_SK, SERVICE_PROCEDURE_CCS_CATEGORY_CD/DESC | Test description/classification coverage and stability; assess source categories before defining dental cohorts. |
| Rendering provider | RENDER_MMIS_PROVIDER_ID, RENDER_MMIS_PROVLOC_ID, RENDER_MMIS_PROVLOC_DIM_SK; alternate RENDER_PROVIDER_ID and ID type | Profile usable keys, then test current-row provider joins and role labels. |
| Service quantities | BILL_QTY and ALLOW_QTY | Profile null/zero/negative/extreme values by procedure; preserve billed versus allowed units. |
| Dental anatomy | TOOTH_NBR_CD/DESC, TOOTH_QUADRANT_CD/DESC, TOOTH_SURFACE_1 through 5 codes/descriptions | Test actual Dental population and placeholder values before exposing tooth-specific measures. |
| Dates/status | LINE_FIRST_SERVICE_DT, LINE_LAST_SERVICE_DT, LINE_STATUS_CD/DESC, claim header dates/status | Resolve date anchor and line-status interpretation without silently changing fact scope. |
| Service context | POS_CD/DESC, modifiers, EMERGENCY_CD/DESC, EPSDT_FP_CD/DESC | Population/meaning checks before adding filters or business service definitions. |
| Financial channel | ENCOUNTER_IND, CONTRACT_TYPE_CD/DESC, PAYMENT_LEVEL_CD/DESC | Use actual source markers to assess payment channels; CLAIM_TYPE_CD = D alone cannot identify a channel. |
| Claim-side demographics/program | BENEFICIARY_BIRTH_DT, BENEFICIARY_AGE_YRS/MTHS, HEALTH_PLAN_ID, HEALTH_PROGRAM_CD | Test source age against line-service/DOB calculation and available plan/program values. Direct claim-side slices may avoid unnecessary PMPM dependence for some questions. |
| Source row timestamps | DE_LOAD_TS, DE_UPDT_TS | Can describe observed row timestamps; their maxima do not prove a complete refresh. |

PROCEDURE_DIM is a confirmed visible view. The object listing also includes CCS procedure mappings and inpatient surgical procedure sources. Listing metadata reports zero rows on these views, which does not establish that the underlying views are empty. No reference join/cardinality is validated yet. Source descriptions already on the claim may support initial displays without adding another dimension join.

## Procedure export replacement

The current `03_dental_procedure_profile.csv` has 911 selected examples: 496 P and 415 D. It has LINE_PAID_AMT/LINE_ALLOW_AMT rather than aggregate counts and sums. It replaced the originally reviewed aggregate file. The earlier aggregate reconciliation is a recorded historical finding, not reproducible from this replacement alone. The next procedure-context export restores full aggregate evidence while adding confirmed source descriptions and quantities. No additional selected sample rows are required.

## Next collection

Run statements 1-3 in [dental_fields_collection.sql](dental_fields_collection.sql):

1. `10_dental_procedure_context.csv`: complete code/description/source-category profile with amounts and quantity distributions.
2. `11_dental_status_dates.csv`: claim versus line status/date comparisons and financial-channel markers, including negative-date-lag reconciliation.
3. `12_dental_field_coverage.csv`: rendering/tooth/quantity-context availability through the selected fields, plus direct source age/program/plan slices. Candidate-present string screens are preliminary and do not establish valid codes or successful reference matches.

Optional statement 4 returns PROCEDURE_DIM columns for a future targeted reference check. There is no need to inventory the warehouse further. After field population is known, validate only the provider/member/plan joins and service definitions needed for the initial model.
