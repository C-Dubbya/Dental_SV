---
name: dental-cohort-slice-builder
description: Build Dental claim-based subgroup comparisons by exact age, operative profile flags, assigned plans and program fields. Use for Medicaid population slices; no diagnosis, entitlement or all-enrollee denominator is implied.
---

# Dental Cohort Slice Builder

## Model integration

Use fact `AGE_AT_SERVICE_NBR` or `AGE_AT_LINE_SERVICE_NBR` for the requested age anchor. Under 21 means valid ages 0-20, not the profile's 0-18 band. Preserve unknown/invalid ages.

Profile flags include `DUAL_IND`, `PREGNANCY_IND`, `POSTPARTUM_IND`, `DCS_IND`, `DCS_CUSTODY_IND`, `KATIE_BECKETT_IND`, `LTSS_CHOICES_IND`, `LTSS_CHOICES_ECF_IND`, `TNCHIP_IND`, `MCHIP_IND` and `SCHIP_IND`. Discover actual values before applying code-based restrictions; a missing flag is not N. CHOICES and ECF CHOICES are separate fields.

Explicit line-service analysis changes fact age/date, not the profile's claim-header service-date anchor; disclose both when combined. For an explicitly restricted subgroup, retain the requested restriction but quantify unresolved classification as context rather than silently adding unknowns to the cohort. Compute any utilizer-share denominator distinctly over the same requested scope; overlapping groups do not sum to a population total.


## Pediatric, adult and formal-report boundaries

An under-21 versus adult claims comparison is descriptive exposure, not proof of dental eligibility, benefit compliance or EPSDT performance. Profile pregnancy/postpartum and program indicators are assignment slices, not complete entitlement histories; do not impose benefit rules or exclusions from age or a flag alone.

For a named official measure, obtain the reporting-year specification, reporting calendar, age anchor, eligible denominator, continuous-coverage rules, provider/service scope and approved code set before calculation. Do not relabel Tennessee July-June SFY or age at service as the specification's required basis. For example, [CMS-416 instructions](https://www.medicaid.gov/medicaid/benefits/downloads/cms-416-instructions.pdf) specify federal-year reporting and year-end age plus eligibility requirements; retrieve the version for the requested year rather than applying an evergreen rule from this skill.

The current model does not establish the eligible population including non-utilizers, continuous enrollment or all oral-health services billed in other claim categories. Explain these gaps and offer a clearly named claims-utilizer alternative only when it answers the user's intent. A skill cannot turn a partial claims numerator into a validated official measure.

## Purpose
Standardize commonly requested TennCare Dental subgroup analyses so cohort-based reporting uses explicit, consistent rules.

## Use this skill when
Use this skill when the user asks for dental results by:

- age
- dual status
- pregnancy or postpartum
- DCS
- Katie Beckett
- CHOICES
- CHIP / program-related fields
- assigned plan or assigned MCO/DBM

## Required analyst behavior

- Use `DENTAL_CLAIMS_SV` for every factual result.
- For age-at-service requests:
  - use `AGE_AT_SERVICE_NBR` on claim-header service basis
  - use `AGE_AT_LINE_SERVICE_NBR` on line-service basis
- Keep unknown/invalid ages separate.
- Do not require profile enrichment solely to derive age if fact age is sufficient.
- For profile-based attributes, state that attribution follows the selected operative health-plan assignment at service date.
- Preserve missing-profile categories when material.

## Procedure

1. Identify the requested cohort dimension.
2. Determine whether it is:
   - fact-based
   - claim-recorded
   - profile-based
3. Resolve period and date basis.
4. Pull requested metrics by cohort.
5. Preserve unknown categories.
6. Reconcile totals where useful and summarize the leading differences.

## Guardrails

- No implicit population exclusion.
- Claims-utilizer percentages are not all-enrollee utilization rates.
- Missing profile assignment does not imply ineligibility.
- Raw claim program fields may not fully classify Medicaid/CHIP populations without validated definitions.

## Output requirements
Lead with the cohort finding:

- "Within the requested cohort breakout, [group] accounted for the highest [metric] in the period."

Then include:

- cohort definition used
- unknown or invalid group if material
- requested metrics
- trend or ranking if requested

Always include a concise basis statement covering:

- date basis
- resolved period
- cohort definition
- attribution basis if profile-based
- measure and denominator

## Example prompts

- Show dental spend by age band.
- Compare dual and non-dual dental utilizers.
- Break out dental claims by pregnancy status.
- Show dental paid amount by assigned MCO within children under 21.
