---
name: plan-attribution-enrichment-qa
description: Assess Dental claim-plan and operative-profile attribution, unmatched categories and enrichment reconciliation. Use for plan-breakout reliability, unknown-plan questions or comparisons of assignment and claim-recorded roles.
---

# Plan Attribution and Enrichment QA

## Model integration

Claim-recorded code is `DENTAL_CLAIM_LINE_FACT.CLAIM_HEALTH_PLAN_ID`, with lookup label `CLAIM_PLAN_DIM.CLAIM_PLAN_DESC`. Operative assignment uses `BENEFICIARY_PROFILE_DIM.HEALTH_PLAN_ID` and `HEALTH_PLAN_DIM.HEALTH_PLAN_DESC`; assigned MCO uses `ASSIGNED_MCO_NM`, while claim organization uses `MCO_DIM.MCO_NM`. DBM fields are assignment identifiers/indicators, not a validated administrator-name crosswalk.

Join the profile on member plus claim-header service date and preserve LEFT JOIN behavior. Report baseline and grouped `COUNT_CLAIM_LINE` and `SUM_LINE_PAID_AMT` under identical filters; differences indicate dropped or multiplied records, not an acceptable full-population breakout. Distinct claims or members can appear in both matched and unmatched groups across lines/dates: compute each and the overall distinct denominator independently, and do not sum these groups or imply their shares partition people. Prefer additive line/dollar shares for reconciliation. Use current tool results, never fixed historical match percentages from documentation.


## Administrator transitions and comparability

For a supplied transition date or documented administrator change, compare source identifiers, lookup match rates, unknown-profile shares and financial/status distributions under comparable service- and paid-date windows. Separate a change in coding/submission or enrichment from a change in actual recorded procedure activity; do not assert causality.

[TennCare's dental-management announcement](https://www.tn.gov/tenncare/news/2025/10/30/tenncare-announces-change-in-dental-plan-management.html) is policy context, not a claim-level administrator crosswalk. Do not assign an administrator from date alone, rename claim organizations automatically or fill unknown plans from the announcement. Require a validated effective-dated source-identifier mapping for administrator-attributed results. Preserve raw identifiers and unknowns while that mapping is unavailable, and do not treat current reference labels as historical assignment evidence.

## Purpose
Evaluate plan-based and profile-based dental reporting for lookup gaps, unknown categories, and attribution differences between claim-recorded and operative assigned plan roles.

## Use this skill when
Use this skill when the user asks:

- Why are there unknown plan values?
- Can I trust this plan breakout?
- What's the difference between claim plan and assigned plan?
- How much dental activity is unmatched in plan enrichment?

## Required analyst behavior

- Use `DENTAL_CLAIMS_SV` for every factual result.
- Distinguish among:
  - raw claim-recorded plan code
  - claim-plan lookup label
  - operative assigned plan at service date
  - assigned MCO / DBM where relevant
- Preserve unknown and unmatched categories.
- Reconcile grouped totals back to the un-enriched scope before presenting a full-population breakout.
- Never substitute operative assignment for an unmatched claim-recorded plan.

## Procedure

1. Identify which plan role the user wants.
2. Resolve period and date basis.
3. Produce counts and paid amount for:
   - matched categories
   - unknown/unmatched categories
4. Quantify the unknown/unmatched share.
5. If requested, compare distributions across plan roles.
6. Summarize whether the breakout is suitable for interpretation at full population or only matched subset.

## Guardrails

- Claim-recorded plan and operative assigned plan are different roles.
- Unknown categories must stay visible.
- Do not silently drop unmatched rows.
- If a matched-only filter is explicitly requested, disclose excluded/unclassified coverage.

## Output requirements
Lead with a reliability finding:

- "The requested plan breakout contains an unknown/unmatched segment representing X of claims and Y of paid amount."

Then include:

- plan role used
- unknown/unmatched share
- matched breakout
- attribution caveat

Always include a concise basis statement covering:

- date basis
- resolved period
- attribution role
- status scope
- measure and denominator

## Example prompts

- Show dental paid amount by assigned plan with unknown retained.
- How much of the dental data is unmatched in claim-plan lookup?
- Compare claim-recorded plan and assigned plan distributions.
- Is the plan breakout reliable enough for reporting?
