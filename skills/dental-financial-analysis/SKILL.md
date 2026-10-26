---
name: dental-financial-analysis
description: Compare Dental billed, allowed, paid and encounter amounts and explain spend changes through volume, procedure mix and average paid amounts. Use for descriptive financial analysis, not contracted-fee compliance or member-liability determinations.
---

# Dental Financial Analysis

## Measures and scope

Use `DENTAL_CLAIMS_SV` and its named measures. Default spend to header `CLAIM_STATUS_CD = 'P'`, including denied details and zero-paid lines; explicitly paid-detail analysis uses `LINE_STATUS_CD = 'P'`. Keep the same status population in every numerator, denominator and comparison period.

| Request | Semantic measure |
| --- | --- |
| Paid amount | `SUM_LINE_PAID_AMT` |
| Billed amount | `SUM_LINE_BILLED_AMT` |
| Allowed amount | `SUM_LINE_ALLOWED_AMT` |
| Recorded copay | `SUM_LINE_CO_PAY_AMT` |
| Encounter allowed / paid | `SUM_LINE_ENCOUNTER_ALLOWED_AMT` / `SUM_LINE_ENCOUNTER_PAID_AMT` |
| Paid per claim / utilizer | `PAID_PER_CLAIM` / `PAID_PER_UTILIZER` |

For alternative dollar measures include `COUNT_CLAIM`, `COUNT_CLAIM_LINE`, paid amount and the available companion nonzero count: `COUNT_LINES_WITH_BILLED`, `COUNT_LINES_WITH_ALLOWED`, `COUNT_LINES_WITH_COPAY` or `COUNT_LINES_WITH_ENCOUNTER_PAID`. No dedicated encounter-allowed nonzero metric exists; do not invent one. An unpopulated field is not evidence that its underlying business activity is absent.

## Comparisons and decomposition

- Resolve the same date basis, comparable windows, procedure definitions, provider/organization roles and population for both periods. Honor explicitly requested periods rather than silently narrowing them to align coverage; distinguish partial periods and preserve unknown groupings. Paid date is the ordinary spend default; explicit procedure-service timing uses line service date.
- Return current/prior amounts, absolute change and zero-safe percent change. Do not average subgroup ratios; derive total ratios from their underlying totals. A billed-minus-paid or allowed-minus-paid difference is a descriptive difference, not automatically savings, underpayment, balance billing or member liability.
- For spend drivers, start with exact procedure code plus source description and use source lines as an explicit activity denominator when compatible units are not established. Average paid per line is `SUM_LINE_PAID_AMT / NULLIF(COUNT_CLAIM_LINE, 0)`, not a contracted fee.
- For a requested two-factor decomposition within a comparable code cell, let Q be the selected volume and R be paid amount / Q. With positive volume in both periods, use volume effect `(Q1 - Q0) * R0` and average-paid effect `Q1 * (R1 - R0)`; these reconcile to the cell's paid change. Sum cell effects, not averages. Label the selected order; the second term includes interaction and may reflect unmeasured mix, not fee changes.
- Keep newly observed codes, absent comparison cells, missing measures and zero/nonpositive quantity denominators separate rather than forcing an undefined rate. State residual/non-comparable dollars and reconcile the full change. Absence of a code in returned results is not zero until successful complete period queries establish that.
- Only use quantities as Q within validated compatible units and identical line scope. If selecting positive-quantity rows for a requested unit-rate analysis, disclose excluded lines/dollars. Do not silently drop zero quantity or zero paid records from ordinary spend.

## Financial-channel boundaries

`ENCOUNTER_IND`, `CONTRACT_TYPE_CD`, `CONTRACT_TYPE_DESC` and `PAYMENT_LEVEL_DESC` describe source markers. Discover their actual values; encounter-paid dollars can be zero even on encounter-flagged rows. Do not add encounter amounts to line paid amount, interpret a source label as a validated reimbursement methodology, or infer capitation, negotiated rates or complete payer liability without the corresponding evidence.

Coordination of benefits, other-payer liability, remittance adjustments, fee-schedule compliance and net cost are not established by the current exposed measures. Explain the missing evidence and offer the supported descriptive comparison. Provider differences require procedure/case-mix caveats and are not performance or fraud determinations.

## Output

Lead with the financial finding; state exact measures, dates, status, volume denominator, financial/attribution role and any residual. Member/profile breakouts use selected operative assignment, not payment responsibility. Keep source amounts separate and retain unknown categories.
