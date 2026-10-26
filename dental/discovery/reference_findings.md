# Dental reference validation: exports 14-16

Reviewed 2026-10-26 against `02_dental_baseline.csv`. Counts and amounts reconcile by claim-header status. These results validate source keys and predicted LEFT JOIN behavior; compiled semantic queries and agent responses remain untested.

## Reference keys and role coverage

All six current reference business keys have zero duplicate groups, zero excess rows and zero null keys: beneficiary, claim organization, county, date, health plan and provider/location. They remain filtered inline to `DE_CURRENT_ROW_IND = 'Y'` in the Dental model.

Billing provider/location, rendering provider/location and claim organization have full source match coverage for both statuses. No source row has multiple reference matches, and predicted LEFT JOIN counts/amounts preserve the baseline. Provider-role semantics remain separate: full matching does not prove every rendering entity is an individual dentist or that claim organization is the dental benefit administrator.

Claim-recorded plan lookup has substantial gaps:

| Header status | Unmatched lines | Share of status lines | Paid amount on unmatched lines |
| --- | ---: | ---: | ---: |
| P | 4,230,840 | 86.66% | $238,848,216.51 |
| D | 123,518 | 67.84% | $0.00 |

These reference keys are unique, so this is missing correspondence rather than fanout. The query does not identify the cause or establish an alternative mapping. Do not auto-map source plan codes, equate an unmatched plan with non-Medicaid, or substitute the operative assigned plan. Preserve raw claim-plan codes and unknown lookup labels. An INNER JOIN or a filter excluding null lookup values would discard the amounts above.

Implemented: current-match evidence in provider/reference comments; explicit unknown claim-plan handling and no automatic fallback in semantic SQL guidance and agent instructions. The claim-recorded lookup remains an optional reporting role with its limitations disclosed.

## Operative service-date profiles

| Header status | Lines without profile | Paid amount without profile | Lines with multiple candidates | Lines with tied first ordering |
| --- | ---: | ---: | ---: | ---: |
| P | 45,592 | $3,040,227.21 | 341,437 | 0 |
| D | 31,484 | $0.00 | 31,170 | 0 |

Paid missing-profile lines represent 0.93% of paid-header lines; denied missing-profile lines represent 17.29% of denied-header lines. These are line-level coverage measures, not distinct missing-member counts.

User-provided source knowledge interprets these failed matches as no PMPM record matching the claim service date, with a subsequent clarification that this is sample data and the claim/PMPM time periods should overlap. Use the sample-qualified label **No matching PMPM record in supplied sample at claim service date**. Sample incompleteness is a possible explanation; the exact cause is not established by export 16, which measured failed candidate matches without isolating each upstream join reason. Broad date-range overlap does not establish member/date row completeness. Retain claims/dollars with unknown profile attributes, and preserve exact member/month/service-within-span matching. Do not force matches using nearby months or infer a production defect, absence of coverage or non-overlapping periods. Reassess the coverage evidence on a fuller dataset.

Follow-up export 22 now resolves the source-match reasons: PMPM row-month coverage is May 2025-June 2026; 88.79% of missing paid profiles fall in service months absent across PMPM, with other failures involving absent members/member-months or non-covering spans. See [the hypothesis results](pmpm_hypothesis_findings.md). This supports the missing qualifying-record explanation without establishing why the sample omissions occurred.

Multiple candidates are resolved by the existing `HIER_NBR, HEALTH_PLAN_ID` selector; no first-order ties occur in this extract. The candidate-count diagnostic LEFT JOIN preserves all source lines/amounts. It does not execute the semantic engine's join plan or validate DBM entitlement/clinical population definitions.

Implemented: preserve unknown assignment and require grouped-total reconciliation for residence and operative plan/program slices. Keep direct claim age and raw claim-plan analysis independent of the profile join. Do not replace a missing operative assignment with a claim-recorded plan silently.

## Source discovery complete for initial scope

The current claim-line model can proceed to compilation/runtime validation without additional broad schema or sample collection. Remaining execution:

1. Compile the Dental semantic view in its intended schema.
2. Run [semantic_smoke_tests.sql](../validation/semantic_smoke_tests.sql), returning results 17-21. Unknown-plan/profile preservation is a release requirement; a failing semantic join-retention check must be fixed before claiming full-population breakouts.
3. Compile the Dental agent and run [the evaluation CSV](../evaluations/dental_agent_eval_ui.csv), reviewing generated SQL and final answers. Expected behavior is not a pre-scored pass.

An approved Dental service crosswalk, claim-plan namespace repair, dental entitlement, visit/completed-treatment definitions and official enrollment-based measures remain separate business/mapping decisions. They are not implied by passing source-key tests and do not prevent testing the currently implemented claims scope.
