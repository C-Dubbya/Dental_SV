# Dental deployment validation

Source exports 01-16 have been reviewed. Current reference keys are unique and non-null, billing/rendering/claim-organization coverage is complete, and selected operative profiles have no first-order ties. Claim-plan lookup and operative-profile gaps remain visible and are documented in [the source validation findings](../discovery/reference_findings.md).

## Current status

The user confirmed on 2026-10-26 that [semantic smoke testing](semantic_smoke_tests.sql) is complete and passed. Record the five-check suite as PASS on that basis. Individual result exports, execution timestamps and the tested DDL revision were not supplied here; this is not an independently re-executed or row-by-row reviewed result.

Semantic smoke completion is separate from agent deployment, staged-skill availability and behavioral acceptance, which remain unconfirmed. Passing reconciliation does not eliminate known source lookup/profile gaps or validate unsupported clinical, benefit or enrollment measures.

## Optional PMPM sample-overlap hypothesis check

Export 22 has been received and reviewed. [Results](../discovery/pmpm_hypothesis_findings.md) confirm overlapping periods with limited PMPM row-month availability; most missing profiles involve globally absent source months. The SQL remains available for reproduction on a fuller dataset.

Run the single physical-source statement in [pmpm_overlap_hypothesis.sql](pmpm_overlap_hypothesis.sql), exporting `22_pmpm_overlap_hypothesis.csv`. It needs no semantic-view deployment and does not change the join rules.

- `GLOBAL_SPAN_RANGES_OVERLAP = Yes` establishes overlap of the source span envelopes only. It does not establish continuous coverage, dental entitlement or individual member/date completeness; open-ended spans can make the envelope very broad.
- Reason 05 identifies members absent from the PMPM sample; 06 identifies service months absent across the PMPM sample; 07 identifies missing member-months when both member and source month exist separately.
- Reasons 08-09 identify member-month rows without a valid eligibility span covering the service date.
- Reasons 03-04 and 10-11 identify date/member/plan reference problems that would contradict a blanket explanation of missing PMPM rows.
- `LINES_WITH_DATE_COVERING_PMPM` independently identifies whether the PMPM row exists despite a failed reference match. A reason is the first applicable failure, so use these independent counts too when multiple conditions fail.

If ranges overlap, the known missing-profile counts reconcile, and failed matches fall into absent PMPM member/month or non-covering span reasons, the result supports the missing matching-record explanation. It still cannot prove sampling caused those absences; that requires comparison to a fuller source. If rows have date-covering PMPM data but fail reference joins, investigate those joins instead.

On the unchanged source, repeated `STATUS_NO_PROFILE_LINES` should be P = 45,592 and D = 31,484; repeated paid-header missing-profile dollars should be $3,040,227.21. Treat these as prior-snapshot cross-checks, not permanent thresholds. Sum reason-level line counts and amounts once per status; do not sum repeated status/bounds columns or distinct member/claim counts across reasons. YYYYMM comparisons are normalized to numbers explicitly; unparseable PMPM months are reported. Exact candidate matching uses the DATE_DIM month while calendar-month coverage is tested independently.

## Reproduction and remaining agent acceptance

1. For reproduction or after relevant DDL/source changes, compile [DENTAL_CLAIMS_SV.sql](../../ddl/DENTAL_CLAIMS_SV.sql) with the target context `TRN__TN_DE.SBX_ETL`; the agent tool resource points to that fully qualified view. The DDL files use unqualified CREATE names, so set the context deliberately before running each. The completed run was performed outside this workspace.
2. Rerun the five statements in [semantic_smoke_tests.sql](semantic_smoke_tests.sql) when revalidation is needed. They compare the live physical source to the compiled semantic view; no fixed dollar or count snapshot is used as the executable expectation. Retain results 17-21 with the tested DDL revision and execution context when available; they have not been provided here for the reported PASS.
3. On reruns, review every TEST_RESULT and require PASS on non-empty scopes. Compilation/runtime errors are blocked checks, not passes. Join-retention differences are release failures: preserve unknown plan/profile rows before presenting full-population results.
4. Upload the thirteen [Dental skill folders](../../README.md#skills-and-attachments) to their configured `@TRN__TN_DE.AGENTS.SKILLS_INT_STG/<skill-name>` paths, retaining each `SKILL.md` and supporting reference subfolders. Verify stage access and skill/reference loading in the deployment environment; local files and DDL references do not prove deployed availability. Compile [DENTAL_CLAIMS_AGENT.sql](../../ddl/DENTAL_CLAIMS_AGENT.sql), then run the 32 cases in [the Dental evaluation dataset](../evaluations/dental_agent_eval_ui.csv), inspecting selected skills, generated SQL, tool results and final answer. Include cross-workflow routes, surface-level non-additivity, undefined financial rates, cross-period follow-up and refusal to infer unsupported eligibility/clinical/payment conclusions. These are behavioral acceptance cases, not verified-query assertions or pre-scored results; the prior semantic smoke PASS does not validate these newly added workflows.

## Smoke coverage

| Export | Check |
| --- | --- |
| `17_semantic_baseline.csv` | Total source lines/ICNs/members/dollars and separate header/detail counts. |
| `18_semantic_status.csv` | Header/detail cross-tab, including denied details on paid claims. |
| `19_semantic_join_retention.csv` | Lines and dollars retained through billing/rendering/claim organization, claim-plan, operative plan and residence breakouts. |
| `20_semantic_procedure_units.csv` | Per-code/status counts, dollars and billed/allowed quantities, including BLANK codes and zero-paid lines. |
| `21_semantic_age.csv` | Exact under-21/21+ bands and unknown/invalid ages without PMPM dependence. |

The join-retention test sums additive line/dollar metrics only. It does not sum distinct claim/member groups. A passing grand total does not independently validate every label, policy rule, time window or source code meaning; review representative group outputs and generated joins as part of acceptance.

No further broad schema discovery is needed for the current scope. New clinical service cohorts, benefit entitlement, visit definitions and formal enrollment-based measures still require the relevant business definitions. Claim-plan namespace repair should be treated as a separate mapping decision; do not fill unmatched codes from the operative profile automatically.
