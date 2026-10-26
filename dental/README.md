# Dental semantic view and agent

The standalone `Dental_SV` repository contains the Dental semantic model, agent, discovery evidence and validation materials. Its Git history is independent, with development starting on `main`.

## Initial implementation

- [DENTAL_CLAIMS_SV.sql](../ddl/DENTAL_CLAIMS_SV.sql): evidence-refined specification with separate claim/line outcomes, source procedure descriptions, billed/allowed quantities, recorded tooth/surface detail, billing/rendering roles, direct claim age/plan context and operative profile enrichment.
- [DENTAL_CLAIMS_AGENT.sql](../ddl/DENTAL_CLAIMS_AGENT.sql): Dental Analyst agent using GPT-5.4 and explicit status/date/provider/assignment rules.
- [Reference findings](discovery/reference_findings.md): source exports 14-16, confirmed joins and known claim-plan/profile gaps.
- [PMPM hypothesis results](discovery/pmpm_hypothesis_findings.md): export 22 confirms overlapping periods with limited PMPM row-month coverage and explains unmatched profiles.
- [Validation status](validation/README.md): source-reference checks are reviewed and the user reports the five-check semantic smoke suite passed; agent acceptance remains unconfirmed.
- [Dental evaluation cases](evaluations/dental_agent_eval_ui.csv): 32 UI-ready behavioral cases, including domain-specific workflow and deferral checks.
- [Dental skills and attachments](../README.md#skills-and-attachments): thirteen analytical workflows, trigger routing and staged-folder configuration. Anatomy/units, descriptive financial analysis and observed procedure sequences use existing semantic fields; service-family/code-edition, official-measure and administrator mappings remain evidence-gated.
- [Worksheet collection](discovery/README.md): preferred starting point; three direct SQL exports for schema, Dental baseline and procedure distribution, plus optional selected example rows.
- [CoWork discovery prompts](cowork_discovery_prompts.md): optional reference if source-query access becomes usable.
- [Source discovery SQL](discovery/source_profile.sql): additional scope, grain and monthly checks for follow-up.

Source exports 01-16 and 22 have been reviewed; current reference keys are unique and role diagnostics reconcile to the baseline with known claim-plan/profile gaps preserved. The user confirmed on 2026-10-26 that semantic smoke testing is complete and passed. Individual smoke result exports and the tested DDL revision have not been supplied here. Agent deployment, staged-skill loading and the 32 behavioral acceptance cases remain unconfirmed; the expanded skill workflows have not been runtime-tested. No deployment or re-execution was performed from this workspace.

The fact isolation follows the user's direction:

```sql
WHERE UPPER(TRIM(C.CLAIM_CATEGORY_CD)) = 'DENTAL'
  AND C.CLAIM_STATUS_CD IN ('P', 'D')
  AND C.CLAIM_VOID_IND = 'N'
  AND C.LAST_CLAIM_IND = 'Y'
```

The case-normalized category accepts `Dental` and `DENTAL`; the discovery SQL returns exact observed values. Procedure presence, plan, age, dual status, program and DBM assignment are not fact-scope restrictions.

All table-based `MART_EDW_SV` dimensions retain inline `DE_CURRENT_ROW_IND = 'Y'` selection. Current-row selection does not by itself prove uniqueness: each target key still needs a fanout check.

## Core analytical safeguards

Paid versus denied line semantics; distinct claim and member counts; separate source financial fields; paid versus service date; Tennessee July-June fiscal windows; billing provider-location composite keys; LEFT JOIN enrichment; distinct-total safeguards; visible missing profiles; and operative health-plan attribution disclosures.

The PMPM selector orders by `HIER_NBR, HEALTH_PLAN_ID`. Dental source checks show multiple candidates but no ties at the selected first ordering. Missing profiles affect 45,592 paid-header and 31,484 denied-header lines; preserve unknown assignments. The selected operative medical-plan profile still does not establish dental entitlement or complete DBM assignment.

Export 22 confirms the periods overlap, but PMPM row-month coverage is May 2025-June 2026 while Dental service dates extend earlier. Service months absent across PMPM explain 88.79% of missing paid profiles; remaining failures involve absent members/member-months or a service date outside the member-month spans. These source reasons are established, while sampling as their underlying cause remains unproven. Preserve exact matching and all claims; do not use long eligibility-span boundaries as complete PMPM history or substitute nearby-month rows.

Dental evidence shows 249,050 denied details on paid claim headers. Base scope/default paid-claim counts use header status; detail denial metrics use LINE_STATUS_CD. Fact-based calculated ages and claim-recorded plans avoid a PMPM dependency for those specific questions. Operative profile attributes retain their separate assignment role. Claim and line service dates are both exposed, with the claim-header anchor used by default.

## Evidence and remaining business decisions

| Topic | Evidence required before extension |
| --- | --- |
| Procedure identity and service cohorts | Source descriptions and quantities are profiled. Approved clinical service lists, reporting-year applicability and overlap/exclusion rules remain business decisions. |
| Visits and service units | Billed/allowed quantities and tooth/surface attributes are available. Visits, completed treatment and compatible cross-procedure units still require explicit definitions. |
| Providers and administrators | Billing/rendering/claim-organization source matches are complete with unique keys. Individual dentist identity and dental administrator/DBM meaning remain separate role decisions. |
| Medicaid populations | Direct age and raw program distributions are profiled. Raw claim programs and plan lookups have gaps; classify populations only with a stated, validated attribution and unknown coverage. |
| Financial measures | Paid/allowed/billed/encounter completeness by claim type, zero/negative paid lines, and documented financial-channel semantics. |
| Enrollment-based measures | Dental-specific benefit evidence, all eligible members including non-utilizers, member-month grain, coverage intervals, gaps and measure-year specifications. |
| Service-category crosswalk | Client examples or authoritative local mappings for preventive, diagnostic, restorative and other requested Dental services. |
| Data availability | Paid/service bounds, monthly volumes, lag and row timestamps are profiled. Negative lag is unresolved; no maximum timestamp establishes complete refresh or mature service cohorts. |

## Completion path

1. Completed: source schema, baseline, grain, monthly/lag, procedure/quantity context, and field coverage have been exported and reviewed. Initial collection scripts remain available as historical/reproduction references; do not rerun the whole discovery series.
2. Completed: exports 14-16 show unique/non-null current keys, full billing/rendering/claim-organization coverage, no first-order profile ties and no predicted fanout. Claim-plan lookup and operative-profile gaps are explicitly retained; no source namespace mapping was invented.
3. Completed per user confirmation on 2026-10-26: [semantic smoke testing](validation/semantic_smoke_tests.sql) passed. Verify staged-skill loading and compile/test the agent with [the Dental evaluation CSV](evaluations/dental_agent_eval_ui.csv) next. Inspect selected skills, generated SQL and final answers; only promote executed/reviewed examples into Dental VQRs after they pass.
4. Add approved Dental service lists from a client SQL/report example when available. Source descriptions and broad CCS category 997 do not establish preventive/restorative clinical cohorts. Additional enrollment/visit/outcome requirements remain separate extensions.

Initial scope includes claim spend, header/detail outcomes, source procedure descriptions, billing/rendering activity, procedure-specific billed/allowed units, recorded tooth/surface attributes and supported member slices. Broader eligibility denominators, continuous coverage, completed treatments, visit definitions and official reporting specifications can wait for a concrete requirement. Revalidate the semantic model after relevant changes; agent acceptance is the remaining execution gate.

Discovery itself requires no stage upload, deployment, permanent database object, policy change or production data modification.
