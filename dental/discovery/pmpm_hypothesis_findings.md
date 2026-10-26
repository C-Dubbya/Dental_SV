# PMPM sample-overlap hypothesis: export 22

Reviewed 2026-10-26. Evidence: `22_pmpm_overlap_hypothesis.csv`, reconciled to the status baseline in export 02 and missing-profile totals in export 16. Source execution time was not supplied. This is a physical-source diagnostic, not a compiled semantic-view result.

## Finding

Claim and PMPM periods overlap, but available PMPM **row-months** span only **202505 through 202606**. Dental services extend into earlier years. Although the global PMPM eligibility-span envelope is 1983-02-01 through 2299-12-31, those long/open-ended intervals do not establish historical PMPM member-month availability. The profile requires both the matching member-month and a span covering the service date.

Most missing profiles therefore occur where the sample has no PMPM records for the service month. Other failures involve absent members/member-months or a service date outside the available member-month intervals. No failed profile has a date-covering, matching-member/month PMPM record. There are no reported current-beneficiary or health-plan failures after satisfying those PMPM criteria.

## Non-overlapping breakdown using the independent coverage columns

The exported CASE reasons prioritize the first failure. The table below regroups them using `LINES_WITH_SERVICE_MONTH_IN_PMPM` so members absent in an entirely absent source month are counted once under the source-month gap.

| Situation | Paid-header lines | Denied-header lines |
| --- | ---: | ---: |
| Service month absent across the PMPM sample | 40,482 | 27,061 |
| Source month exists, but member absent from PMPM sample | 1,668 | 2,040 |
| Member and source month exist, but member-month row absent | 2,793 | 1,639 |
| Member-month exists, but service date falls outside its spans | 649 | 744 |
| **Total without selected profile** | **45,592** | **31,484** |

Source-month gaps account for **88.79%** of missing paid-header profiles and **85.95%** of missing denied-header profiles. A further 27 paid-header and 393 denied-header lines also lack a current DATE_DIM row, but all of those service months are absent from PMPM too. They are included in the first row above, not added again.

Among lines in service months that have any PMPM rows:

- Paid-header scope: 4,841,647 lines; 5,110 have no profile (**0.106%**).
- Denied-header scope: 155,000 lines; 4,423 have no profile (**2.85%**).

These are descriptive scope comparisons, not proposed changes to fact filters. Distinct member/claim counts cannot be added across reasons. The regrouped table supports line counts only: the export does not split dollars inside the mixed first-failure reason groups, so exact dollars must not be assigned to the regrouped categories. Total missing-profile paid amount remains **$3,040,227.21**, reconciling to export 16.

## Hypothesis assessment and implementation

The result supports the explanation that the supplied extract lacks PMPM records satisfying the claim member/month/service-date criteria, despite overlapping source periods. It does not independently prove that sampling caused the omissions or that coverage was absent in the underlying operational source. The service-date-outside-span category has member-month rows, so it must not be described as an absent member-month.

No join broadening or date correction is justified. Retain exact member/month/span matching and preserve unmatched claims with unknown profile attributes. Do not use long eligibility-span boundaries to substitute PMPM rows from other months. Do not hardcode May 2025 or another date as a Dental fact exclusion. Reassess month coverage against a fuller/refreshed dataset.

All reason-level line/paid totals reconcile to export 02. Unmatched line/paid totals reproduce export 16. Reported duplicate date/member-reference counts are zero. There is no additional broad discovery requirement from this result; continue with [semantic compilation and smoke tests](../validation/README.md).
