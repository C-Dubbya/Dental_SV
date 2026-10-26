# First collection from a Snowflake worksheet

Exports 01-16 have been received and reviewed. See [reference validation findings](reference_findings.md): keys are unique, provider/claim-organization matches are complete, claim-plan matches are incomplete and some operative profiles are missing. Source diagnostics preserve baseline totals. Semantic smoke testing subsequently passed per user confirmation on 2026-10-26; see [current validation status and remaining agent acceptance](../validation/README.md). Earlier reviews remain historical source-discovery records in [initial_findings.md](initial_findings.md), [second_findings.md](second_findings.md) and [third_findings.md](third_findings.md).

Run [worksheet_collection.sql](worksheet_collection.sql) directly in a worksheet that can read the known claims table. CoWork is optional. Start with just three exports:

| Statement | Export filename | What it gives us |
| --- | --- | --- |
| 1 | `01_claim_line_columns.csv` | Actual column names, declared types and available comments from DESCRIBE. Reveals which dental fields/reference keys exist. |
| 2 | `02_dental_baseline.csv` | Dental status/type populations, available dates, missing fields, and candidate financial channels. |
| 3 | `03_dental_procedure_profile.csv` | Complete observed raw procedure distribution by status/type, with utilization and dollar context. |

Export complete result sets with headers, retaining procedure codes as text. Put the files here or attach them to the conversation. Return any error with its statement number; do not substitute guessed columns. These statements are supplied for execution, not represented as already run.

Statement 4 optionally returns up to 100 selected example rows per status using known shared fields. It excludes member, claim and provider identifiers from the output. It is useful for seeing value combinations but does not prove population coverage, financial completeness, source grain or business meaning. It may omit procedure/type groups. The received original example export contained only denied rows; the query now uses separate status caps. The full aggregate in statement 3 supplies population coverage, so another sample export is not required now.

The worksheet must allow DESCRIBE for statement 1 and direct SELECT for the others. If DESCRIBE is unavailable, copy the object-browser column list or use section 1 of [source_profile.sql](source_profile.sql), which returns column names only. Statements 2-4 need no catalog access or created objects. If the final Dental population is empty, report that result; scope/category investigation can then use section 2 of source_profile.sql.

## What happens after the exports

We will inspect the schema and actual code/amount distributions here, then prepare the next small SQL batch using confirmed field names. That batch will target:

- Procedure descriptions or a procedure reference key identified in the schema.
- Rendering provider, service quantity, tooth/surface or other useful Dental fields, if present.
- Claim-organization interpretation and the member-profile slices needed for the first client questions.
- Grain, monthly volume and join reconciliation needed before deploying the model.

No broad warehouse inventory or full dimension dump is needed initially. The existing branch supplies the shared dimension definitions. Any new lookup object still needs its actual name/key from source documentation, an existing Dental query or a targeted schema handoff.

An existing Dental report or SQL example is helpful if readily available; the three exports are sufficient to start the next implementation pass without it. Client definitions will still be needed before promoting raw procedure codes into named clinical service cohorts.

The broader [source_profile.sql](source_profile.sql) remains available for the later scope, grain and monthly checks. We will choose those checks based on the first results rather than requiring the whole discovery list upfront.
