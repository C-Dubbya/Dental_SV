---
name: dental-anatomy-service-units
description: Analyze recorded Dental teeth, surfaces and compatible service quantities without multiplying claim lines or dollars. Use for anatomy-specific activity and unit questions, not diagnoses or completed-treatment counts.
---

# Dental Anatomy and Service Units

## Source and grain

Use `DENTAL_CLAIMS_SV` for every factual result. Preserve source-line identity as `CLAIM_ICN_NBR` plus `CLAIM_LINE_NBR`. Recorded anatomy belongs to a member and source line, not to a globally unique tooth.

- Tooth attributes are `TOOTH_NBR_CD` and `TOOTH_NBR_DESC`. A distinct member-tooth count uses `BENEFICIARY_ID` plus the recorded tooth code, with missing/placeholder anatomy reported separately; it is not a count of teeth treated successfully.
- Surface attributes are `TOOTH_SURFACE_1_CD` through `TOOTH_SURFACE_5_CD` and their corresponding descriptions. Discover actual source values before applying a surface filter.
- `TOOTH_QUADRANT_CD` and `TOOTH_QUADRANT_DESC` are available but prior profiling found no usable quadrants. Query current population before concluding availability; do not infer quadrants or primary/permanent dentition from tooth codes without an approved crosswalk.
- Units use `SUM_BILLED_SERVICE_QTY` and `SUM_ALLOWED_SERVICE_QTY`. Lines use `COUNT_CLAIM_LINE`; these are different measures. Quantities must remain within compatible procedure-code units.

## Analysis procedure

1. Resolve exact procedure code/list, anatomy question, period, date basis and header/detail status. Default ordinary activity to header P; preserve zero-dollar lines. Explicit procedure timing uses `LINE_FIRST_SERVICE_DT` and `LINE_SERVICE_YR_MONTH_NBR`; do not silently change profile alignment from claim-header service date.
2. Return `PROCEDURE_CD` and `PROCEDURE_DESC`, requested anatomy, named counts/quantities and `SUM_LINE_PAID_AMT` as appropriate. Preserve unknown anatomy unless the user explicitly requests a documented restriction.
3. For an any-surface question, OR the five slots in one predicate or build a distinct source-line key set before joining to measures. A matching surface in two slots must count the line and its dollars once.
4. If surface-level expansion is explicitly requested, deduplicate repeated surface values within each line. A multi-surface line can still appear under multiple surfaces: disclose overlapping attribution, compute the unduplicated total separately, and never sum expanded surface dollars as total spend.
5. For anatomy completeness, separate procedure groups with validated anatomy requirements from procedures without such requirements. If requirements are unknown, report recorded-field availability only; blank anatomy alone is not a defect or evidence of no care.

## Interpretation and output

Report the recorded anatomy, procedure scope, compatible unit definition, status and date anchor. Include unknown coverage and any overlapping attribution. Allowed quantities can be positive on denied details and do not establish approval. Do not sum tooth/surface codes, call quantities visits, or infer disease, clinical appropriateness, completed care or treatment outcomes.

## Example requests

- Show billed and allowed units by recorded tooth for procedure D2393, retaining unknown tooth values.
- Find lines containing a specified surface in any slot without multiplying paid amount.
- Compare recorded anatomy completeness by exact procedure code, without assuming all codes require a tooth number.
