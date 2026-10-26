# Dental service definitions and code editions

Read this reference when a request needs service-family membership, code validity across years, or anesthesia/sedation code lists. It describes the evidence needed to use a mapping; it does not supply an approved crosswalk.

## Mapping contract

Use a client-approved reporting definition or an authorized, reviewed reference. Record the owner, purpose, source/version, exact code values, service-date effective bounds, inclusions/exclusions, compatible units and whether groups overlap. Distinguish descriptive service families from benefit coverage lists and formal quality-measure code sets; one cannot substitute for another.

Potential descriptive families include diagnostic, preventive, restorative, endodontic, periodontal, prosthodontic, oral surgery, orthodontic and adjunctive services. Their names do not establish membership. Do not create prefix ranges, description wildcards or a broad CCS category as an automatic clinical crosswalk. An explicit user-supplied list can be used verbatim for that request, labeled user-defined; it does not become a permanent governed category without approval.

For an effective-dated mapping, match code and the designated procedure service date, ordinarily `LINE_FIRST_SERVICE_DT`. Validate one mapping per intended code/date/category and avoid multiplying source lines through overlapping ranges. If categories overlap, disclose non-additive group totals and compute the unduplicated overall total separately. Keep unmapped codes/lines and dates visible; report mapped coverage before claiming complete service mix.

## Historical code validity

CDT changes through annual updates; the applicable code version follows service date, not paid date. [ADA coding guidance](https://www.ada.org/resources/practice/dental-insurance/frequently-asked-questions-regarding-dental-codes) explains annual maintenance and service-date applicability. Consult an authorized edition/change history for the period requested; do not copy a complete proprietary codebook into the skill.

The current semantic view supplies recorded code/description, not an edition-validity or replacement-code table. Without that reference, report observed cross-year code activity and mark validity unverified, not invalid. Do not automatically map retired codes to current codes or assume revised descriptions preserve comparability. Preserve numeric-format codes and unknowns in the Dental population.

## Setting and sedation context

Use the source `POS_CD` / `POS_DESC` for recorded setting. An approved sedation/anesthesia list identifies billed code exposure only. Same-claim or same-member/same-line-service-date co-occurrence must use an explicit grain and must not multiply unrelated procedure lines or dollars. It does not prove an anesthetic administration record, clinical indication, safety outcome, emergency status or complete facility/anesthesia spending. Services billed outside the Dental category remain outside this view.
