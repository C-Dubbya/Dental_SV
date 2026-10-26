# Initial Dental discovery findings

Evidence: `01_claim_line_columns.csv`, `02_dental_baseline.csv`, `03_dental_procedure_profile.csv`, and `04_dental_examples.csv`. Reviewed 2026-10-26. Source extraction/run timestamps were not supplied. These findings describe the exported population, not deployed Dental semantic-view results.

Later update: `03_dental_procedure_profile.csv` was replaced with selected example rows rather than the original aggregate export. The aggregate reconciliations below describe the original review. For current source-grain, date, schema and next-action findings, see [exports 05-09 review](second_findings.md).

## Reconciliation and baseline

The procedure export contains 911 rows (415 denied and 496 paid code/status/type groups). Its line counts, paid-line sign/null counts, and paid/allowed/billed/encounter-paid sums reconcile exactly to the baseline for each status/type. Its distinct procedure counts also reconcile. Financial comparisons used decimal arithmetic. Distinct member/ICN counts across procedure groups were not summed.

| Measure | Paid status P | Denied status D |
| --- | ---: | ---: |
| Claim lines | 4,882,129 | 182,061 |
| Distinct ICNs within status | 1,310,623 | 68,200 |
| Distinct members within status | 582,566 | 48,365 |
| Line paid amount | $286,872,460.41 | $0.00 |
| Zero-paid lines | 443,673 (9.09%) | 182,061 (100%) |
| Distinct observed procedure values | 496 | 415 |

Total lines are 5,064,190; the line denial rate is 3.60% for this exported scope. ICN/member totals across statuses remain unknown because overlap was not measured. Paid status does not mean positive payment; preserve all P lines for paid utilization.

Both statuses have `CLAIM_TYPE_CD = 'D'`, with description `DENTAL CLAIMS`. This is observed claim-type evidence, not proof of a fee-for-service/encounter/capitation channel. Encounter paid, encounter allowed and copay sums are zero in both baseline rows; encounter-paid nonzero counts are zero. Null/sign detail for encounter-allowed and copay fields was not exported, so zero sums alone do not establish that every source value is zero.

The baseline reports no null line/member/date keys, no null paid amount, and no negative paid lines. Its missing-procedure test covers null/whitespace only and misses the observed `BLANK` sentinel.

## Procedure evidence

There are 518 distinct raw procedure values across both statuses. By text format:

- Paid: 495 distinct `D` + four-digit values, plus `BLANK` on 146 lines carrying $4,077.00. Keep those lines in base utilization/spend and expose the missing classification.
- Denied: 413 distinct `D` + four-digit values, plus numeric strings `99188` and `99429`, nine lines each. Preserve these in Dental category scope; do not impose an unrequested D-code-only restriction.
- Code formatting does not establish the code system, description or clinical service-category membership. A real procedure lookup or client-approved mapping is still required.
- Ninety-three paid-status procedure values have no paid dollars, spanning 1,329 lines. Separately, zero-paid lines also occur in procedure groups with positive total dollars. Neither case should be silently excluded.

Highest-paid raw codes are `D1120` ($17,424,900.84), `D2740` ($16,335,499.59), and `D0120` ($16,034,635.34). No clinical names or service groups have been assigned from model memory.

## Dates and schema gaps

Paid-date bounds across the exports are 2025-06-29 through 2026-06-12. Service dates reach 2002-07-30 on denied lines and 2011-03-29 on paid lines. Latest service is 2026-06-12. These minima/maxima do not prove continuous historical coverage; investigate monthly volumes and service-to-paid lag before selecting reporting windows. A service-year analysis over these rows is bounded by the source's available payment population.

`01_claim_line_columns.csv` has 57 provider-location columns, including `MMIS_PROVLOC_DIM_SK`, `MMIS_PROVIDER_ID`, `MMIS_PROVLOC_ID`, `NPI_ID`, specialty, taxonomy and geography. It has no claim/member keys. It appears to describe the known MMIS provider-location source, not CLAIM_LINE_TFACT; the export itself does not include the originating object name. Keep it as useful provider metadata, and collect the claim-line schema under a new filename.

`04_dental_examples.csv` contains 200 denied rows and no paid rows. The original ordering and global 200-row cap selected denied combinations first. It is a selected example set, not balanced status coverage or a statistical sample. The collection query now caps examples separately by status; re-export is optional because complete aggregate evidence is already available.

## Next actions

Run [next_collection.sql](next_collection.sql) statements 1-4 and return the named CSVs:

1. Correct CLAIM_LINE_TFACT schema: enables exact procedure-reference, rendering, quantity/tooth and other Dental field discovery without guessed names.
2. Source-grain and cross-status overlap check: confirms claim-line uniqueness and unduplicated claim/member totals.
3. Paid/service monthly volumes: establishes useful analysis windows and any gaps or anomalous historical tails.
4. Service-to-paid lag: quantifies how much of the very old service-date tail affects the available paid population.

Optional statement 5 lists visible procedure-related objects. A known procedure lookup name or existing Dental SQL example can replace this step. Listing results alone do not validate a join; a targeted lookup schema and uniqueness/coverage check will follow.

The next batch after these results will target confirmed procedure and provider fields plus the operative profile/member slices required for initial Dental questions. No additional full claim-row sample, broad dimension dump or enrollment study is required now.
