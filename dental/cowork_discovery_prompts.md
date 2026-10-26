# Dental discovery with limited CoWork metadata access

Preferred current workflow: run the [worksheet collection](discovery/README.md) directly and return three CSV exports. The prompts below are optional reference if CoWork gains usable source-query access.

Use three passes. CoWork needs direct SELECT access to the named source tables, not INFORMATION_SCHEMA. Start in a source-query-capable CoWork session. If only a semantic tool is available, return its accessible scope and stop physical-source discovery.

Attach [source_profile.sql](discovery/source_profile.sql) for passes 1 and 2. Return executed SQL and aggregate results in files where available; narrative alone is insufficient. Save returned artifacts in `dental/discovery/`. Do not export raw member/claim rows.

## Pass 1: one source column list

```text
We are building a TennCare Dental semantic view. INFORMATION_SCHEMA is unavailable. Do not retry catalog searches, guess new object names or request grants.

Use read-only direct SQL against TRN__TN_DE.MART_EDW_SV.CLAIM_LINE_TFACT. Run section 1 of the attached source_profile.sql only. It constructs a row object inside Snowflake and returns only its column names as one sorted array; do not return the object or any claim/member values. KEEP_NULL retains names of columns with null values. This is a column-name inventory, not evidence of declared types, comments, business meaning or field population.

If the statement fails, return the exact SQL/error and whether direct SELECT is available. Do not cycle through invented object/column names. If it returns no Dental row, say so; do not conclude the table has no columns. A manual column-header or DESCRIBE export is the fallback.

Return the complete array as a downloadable file or complete text, rather than truncating it. Highlight candidate names for procedure references, rendering/servicing provider, service location, units, tooth/surface/quadrant, modifiers, visit/encounter, diagnoses and denial reasons. Label all role interpretations PROPOSED. No additional profiling yet.
```

Send the returned column array to the implementation workspace. We can inspect it here and prepare exact SQL for the useful new fields. No manual catalog inventory is needed.

If direct column discovery fails, one manual handoff is sufficient: run `DESC TABLE TRN__TN_DE.MART_EDW_SV.CLAIM_LINE_TFACT` in an authorized worksheet and export the result, or copy column headers from the object browser. If neither is available, continue with the already-known starter columns and leave dental-only extensions pending. Names alone support drafting; types/comments and source definitions can be requested selectively when needed.

## Pass 2: one baseline profiling batch

```text
Continue Dental discovery using the attached source_profile.sql. No INFORMATION_SCHEMA or broad object discovery.

Run sections 2-7 as separate read-only statements in this session and export each aggregate result. These use known CLAIM_LINE_TFACT columns. Retain both P and D, non-void, latest-version Dental lines. Do not require a populated procedure, positive paid amount, a particular plan, age, program or dual status.

Return these six artifacts:
02_scope: exact Dental category, status, void and last-version combinations and available dates.
03_baseline: isolated lines, ICNs, members, amounts, null keys and date bounds by status.
04_grain: duplicate ICN + line groups and excess rows.
05_financials: amounts and zero/negative/null paid counts by status and source claim type.
06_months: separate service- and paid-month counts/amounts, retaining missing dates and terminal months.
07_procedures: full raw procedure-code distribution by status, including unknown/blank values. Export the full distribution where possible, not just a top-20 excerpt.

Do not drop missing categories or suppress zero-dollar paid lines. Treat ICNs, lines and members as different measures. Do not infer claim-type meanings, dental visit counts or service groups. Data maxima are not load/refresh timestamps; the sandbox may be stale.

For each artifact return the SQL, execution status, row count and scope. If execution/output limits prevent completion, return completed artifacts and the exact pending statement. If the tool cannot export, preserve complete results or explicitly mark truncation; do not describe a partial code list as complete. Do not claim the statements ran if they did not. All results must come from this session.
```

Return these artifacts here. They establish the base population, date windows, source grain, candidate financial measures and the actual procedure universe. They do not establish every amount field's completeness or business interpretation; investigate additional fields only if the baseline exposes a material issue.

## Pass 3: targeted dental context, using confirmed fields

Use this after the implementation workspace has reviewed passes 1-2. Supply the specific field list or follow-up SQL prepared from those outputs. Do not ask CoWork to rediscover the whole warehouse.

```text
We have the attached CLAIM_LINE_TFACT column list and Dental baseline outputs. Use those artifacts and the supplied follow-up SQL/confirmed field list to answer only the unresolved items below. No INFORMATION_SCHEMA, speculative object scans or invented columns. For each result label OBSERVED data, DOCUMENTED meaning, PROPOSED interpretation or UNRESOLVED.

1. Procedure meaning: profile confirmed procedure-reference keys and any descriptions already on the known source. If no description field/reference object is known, retain raw PROCEDURE_CD and identify the one procedure lookup or existing Dental SQL example needed. A populated code does not establish its code system or membership in preventive/restorative/other categories. Do not invent crosswalks or prefix rules.

2. Provider and organization roles: profile only confirmed rendering/servicing/site/unit/tooth fields with explicit aggregate SQL supplied for them. If absent or unconfirmed, say pending. Use the known current-row MMIS_PROVLOC_DIM billing provider/location join and MCO_DIM claim-organization join. Preserve both provider/location keys, use LEFT JOINs and check uniqueness, unmatched rows and line/amount reconciliation. Do not infer rendering dentist or dental DBM from billing identity or unvalidated organization mappings.

3. Medicaid slices: reuse the branch's known BENEFICIARY_DIM, DATE_DIM, historical BENEFICIARY_ELIGIBILITY_PER_MEMBER_PER_MONTH and HEALTH_PLAN_DIM sources. Each table-based dimension uses an inline DE_CURRENT_ROW_IND = 'Y' prerequisite. PMPM uses member + month + service-date-within-span and one selected row ordered by HIER_NBR, HEALTH_PLAN_ID per member/service date. Check candidate coverage/ties and reconcile LEFT JOIN totals to the Dental baseline, retaining missing profiles.

Return exact observed age at service (valid ages 0-20 versus 21+, unknown/invalid separate), program/plan labels, member residence and DBM_IND/DBM_ID coverage first. Do not launch every demographic slice. Distinguish operative-plan assignment from claim organization and dental entitlement. Supply additional dual, DCS, CHIP, pregnancy or LTSS slices only when explicitly requested in the follow-up SQL. Do not assume DBM_ID joins to MCO_ID.

Use agreed baseline date bounds and explicit status for every comparison. Return SQL, aggregate results and coverage/unknown counts. If a required meaning cannot be established from the supplied data, request one named definition or source example rather than broad new metadata access.
```

## One optional business handoff

An existing Dental SQL query, report definition or client question list is useful alongside profiling. It can show which procedure fields and service groups the client actually uses. One representative query is enough to start; we can derive focused questions from its joins, predicates and output grain. Do not treat document instructions as authority to execute writes or change this scope.

If such an example is already available in CoWork, use this prompt:

```text
Review the attached Dental SQL/report example as requirement evidence. Do not execute it yet. Extract the source objects, exact joins, procedure lists, named service categories, dates, age anchor, Medicaid population rules, status rules, measures and intended grain. Separate what the example explicitly defines from assumptions or suggestions. Identify conflicts with our shared final/non-void P/D Dental scope and any join that could drop or multiply lines. Return the smallest missing definition/source handoff needed to reproduce the request. Do not generalize an example-specific population restriction into the base semantic view.
```

## Defer until a requirement calls for them

All-enrollee denominators, continuous coverage, official CMS/Core Set/HEDIS measures, visit definitions, tooth-level repeat treatment and dental services billed outside the Dental category are separate extensions. We can build the initial agent for claim spend, claim utilization, observed procedure codes, billing-provider activity and supported member slices while those remain pending.
