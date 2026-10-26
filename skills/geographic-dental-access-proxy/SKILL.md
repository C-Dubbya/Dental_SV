---
name: geographic-dental-access-proxy
description: Summarize Dental claims by residence, recorded service or provider-location geography with visible unknowns. Use for county and region comparisons; these are claims-based patterns, not validated access-adequacy measures.
---

# Geographic Dental Access Proxy

## Model integration

Residence uses `BENEFICIARY_COUNTY_DIM.BENEFICIARY_COUNTY_NM` and `BENEFICIARY_GRAND_REGION_NM` through the selected operative profile. Recorded service geography uses `SERVICE_COUNTY_DIM.SERVICE_COUNTY_NM` and `SERVICE_GRAND_REGION_NM`. Provider-location geography uses `BILLING_PROVLOC_DIM.BILLING_COUNTY_NM` or `RENDERING_PROVLOC_DIM.RENDERING_COUNTY_NM`.

Default unspecified county requests to member residence, disclose that role and retain missing profiles/counties. Do not synthesize provider regions or travel distances from county names. Where the model lacks a requested geography mapping, state the limitation and offer the available role-specific county fields. Measures use named counts and `SUM_LINE_PAID_AMT`; distinct utilizers are not county enrollment denominators.


## Purpose
Summarize TennCare Dental claims activity by geography while clearly distinguishing member residence, recorded service county, and provider-location geography.

## Use this skill when
Use this skill when the user asks:

- Which counties have the most dental claims or spend?
- Where are dental services being delivered?
- Show dental activity by county or region.
- Compare residence and service geography.

## Required analyst behavior

- Use `DENTAL_CLAIMS_SV` for every factual result.
- Distinguish among:
  - residence county
  - service county
  - billing location county
  - rendering location county
- If using residence or other profile-based attributes, state that attribution follows the selected operative health-plan assignment at service date.
- Preserve unknown geography categories through LEFT JOIN behavior.

## Procedure

1. Determine which geographic role the user wants.
2. Resolve period and date basis.
3. Pull requested metrics:
   - claims
   - lines
   - utilizers
   - paid amount
4. Group by county or region.
5. If requested, compare two geography roles separately rather than blending them.
6. Summarize the leading counties or regions.

## Guardrails

- Do not describe these results as access adequacy.
- Do not infer travel distance from county fields.
- Residence county, service county, and provider-location county are distinct concepts.
- Unknown geography categories may reflect enrichment gaps rather than absence of care.

## Output requirements
Lead with the geographic finding:

- "By residence county, [County] had the highest dental paid amount in the requested period."

Then include:

- geography role used
- requested metrics
- ranking or trend output as needed

Always include a concise basis statement covering:

- date basis
- resolved period
- geography role
- status scope
- measure and denominator

## Example prompts

- Show dental spend by residence county.
- Which service counties have the most dental claims?
- Compare residence county and billing location county patterns.
- Summarize dental activity by grand region.
