-- Read-only Dental discovery. Run section 1 first, then batch sections 2-7.
-- No current-date assumptions or additional population restrictions.
-- No INFORMATION_SCHEMA access is required. Direct SELECT access is still required.

-- 1. Column-name handoff from an existing Dental row; no claim values are returned.
-- KEEP_NULL retains column names even when the sampled value is NULL.
-- This returns names only, not declared SQL types, comments, meanings or completeness.
-- If no Dental row exists, this returns no row; that does not prove columns are absent.
-- If row-object construction is unsupported or blocked, stop and use a manual DESC export.
WITH one_dental_row AS (
    SELECT OBJECT_CONSTRUCT_KEEP_NULL(*) AS row_shape
    FROM TRN__TN_DE.MART_EDW_SV.CLAIM_LINE_TFACT
    WHERE UPPER(TRIM(CLAIM_CATEGORY_CD)) = 'DENTAL'
    LIMIT 1
)
SELECT ARRAY_SORT(OBJECT_KEYS(row_shape)) AS column_names
FROM one_dental_row;

-- 2. Exact Dental category values and statuses before other exclusions.
SELECT CLAIM_CATEGORY_CD, CLAIM_STATUS_CD, CLAIM_VOID_IND, LAST_CLAIM_IND,
       COUNT(*) AS source_lines,
       MIN(CLAIM_FIRST_SERVICE_DT) AS first_service_dt,
       MAX(CLAIM_FIRST_SERVICE_DT) AS latest_service_dt,
       MAX(CLAIM_PAID_DT) AS latest_paid_dt
FROM TRN__TN_DE.MART_EDW_SV.CLAIM_LINE_TFACT
WHERE UPPER(TRIM(CLAIM_CATEGORY_CD)) = 'DENTAL'
GROUP BY CLAIM_CATEGORY_CD, CLAIM_STATUS_CD, CLAIM_VOID_IND, LAST_CLAIM_IND
ORDER BY CLAIM_CATEGORY_CD, CLAIM_STATUS_CD, CLAIM_VOID_IND, LAST_CLAIM_IND;

-- 3. Baseline status counts and missing keys. This includes P zero-dollar lines.
SELECT CLAIM_STATUS_CD,
       COUNT(*) AS claim_line_count,
       COUNT(DISTINCT CLAIM_ICN_NBR) AS claim_count,
       COUNT(DISTINCT BENEFICIARY_ID) AS member_count,
       COUNT_IF(CLAIM_ICN_NBR IS NULL OR CLAIM_LINE_NBR IS NULL) AS null_line_keys,
       COUNT_IF(BENEFICIARY_ID IS NULL) AS null_member_keys,
       COUNT_IF(CLAIM_FIRST_SERVICE_DT IS NULL) AS null_service_dates,
       COUNT_IF(CLAIM_PAID_DT IS NULL) AS null_paid_dates,
       MIN(CLAIM_FIRST_SERVICE_DT) AS first_service_dt,
       MAX(CLAIM_FIRST_SERVICE_DT) AS latest_service_dt,
       MIN(CLAIM_PAID_DT) AS first_paid_dt,
       MAX(CLAIM_PAID_DT) AS latest_paid_dt,
       SUM(LINE_PAID_AMT) AS paid_amount
FROM TRN__TN_DE.MART_EDW_SV.CLAIM_LINE_TFACT C
WHERE UPPER(TRIM(C.CLAIM_CATEGORY_CD)) = 'DENTAL'
  AND C.CLAIM_STATUS_CD IN ('P','D')
  AND C.CLAIM_VOID_IND = 'N'
  AND C.LAST_CLAIM_IND = 'Y'
GROUP BY CLAIM_STATUS_CD
ORDER BY CLAIM_STATUS_CD;

-- 4. Candidate claim-line key uniqueness, without exporting identifiable rows.
WITH key_counts AS (
    SELECT CLAIM_ICN_NBR, CLAIM_LINE_NBR, COUNT(*) AS row_count
    FROM TRN__TN_DE.MART_EDW_SV.CLAIM_LINE_TFACT C
    WHERE UPPER(TRIM(C.CLAIM_CATEGORY_CD)) = 'DENTAL'
      AND C.CLAIM_STATUS_CD IN ('P','D')
      AND C.CLAIM_VOID_IND = 'N'
      AND C.LAST_CLAIM_IND = 'Y'
    GROUP BY CLAIM_ICN_NBR, CLAIM_LINE_NBR
)
SELECT COUNT(*) AS candidate_keys,
       COUNT_IF(row_count > 1) AS duplicate_key_groups,
       SUM(row_count - 1) AS excess_rows,
       MAX(row_count) AS max_rows_per_key
FROM key_counts;

-- 5. Financial channels by status/type. Do not infer type meanings from codes.
SELECT CLAIM_STATUS_CD, CLAIM_TYPE_CD, CLAIM_TYPE_DESC,
       COUNT(*) AS lines,
       COUNT(DISTINCT CLAIM_ICN_NBR) AS claims,
       COUNT(DISTINCT BENEFICIARY_ID) AS members,
       COUNT_IF(LINE_PAID_AMT IS NULL) AS null_paid_lines,
       COUNT_IF(LINE_PAID_AMT = 0) AS zero_paid_lines,
       COUNT_IF(LINE_PAID_AMT < 0) AS negative_paid_lines,
       COUNT_IF(LINE_PAID_AMT > 0) AS positive_paid_lines,
       COUNT_IF(LINE_ENCOUNTER_PAID_AMT <> 0) AS nonzero_encounter_paid_lines,
       COUNT_IF(LINE_PAID_AMT <> 0 AND LINE_ENCOUNTER_PAID_AMT <> 0) AS both_paid_channels_lines,
       SUM(LINE_PAID_AMT) AS paid_amount,
       SUM(LINE_ALLOW_AMT) AS allowed_amount,
       SUM(LINE_BILL_AMT) AS billed_amount,
       SUM(LINE_ENCOUNTER_PAID_AMT) AS encounter_paid_amount,
       SUM(LINE_ENCOUNTER_ALLOW_AMT) AS encounter_allowed_amount,
       SUM(LINE_CO_PAY_AMT) AS copay_amount
FROM TRN__TN_DE.MART_EDW_SV.CLAIM_LINE_TFACT C
WHERE UPPER(TRIM(C.CLAIM_CATEGORY_CD)) = 'DENTAL'
  AND C.CLAIM_STATUS_CD IN ('P','D')
  AND C.CLAIM_VOID_IND = 'N'
  AND C.LAST_CLAIM_IND = 'Y'
GROUP BY CLAIM_STATUS_CD, CLAIM_TYPE_CD, CLAIM_TYPE_DESC
ORDER BY CLAIM_STATUS_CD, CLAIM_TYPE_CD;

-- 6. Two date bases. Includes incomplete terminal months and null date buckets.
WITH dental AS (
    SELECT CLAIM_PAID_DT, CLAIM_FIRST_SERVICE_DT, CLAIM_STATUS_CD,
           CLAIM_ICN_NBR, BENEFICIARY_ID, LINE_PAID_AMT
    FROM TRN__TN_DE.MART_EDW_SV.CLAIM_LINE_TFACT C
    WHERE UPPER(TRIM(C.CLAIM_CATEGORY_CD)) = 'DENTAL'
      AND C.CLAIM_STATUS_CD IN ('P','D')
      AND C.CLAIM_VOID_IND = 'N'
      AND C.LAST_CLAIM_IND = 'Y'
), dated AS (
    SELECT 'Paid' AS date_basis, CLAIM_PAID_DT AS reporting_dt, * FROM dental
    UNION ALL
    SELECT 'Service' AS date_basis, CLAIM_FIRST_SERVICE_DT AS reporting_dt, * FROM dental
)
SELECT date_basis, DATE_TRUNC('MONTH', reporting_dt) AS reporting_month,
       CLAIM_STATUS_CD, COUNT(*) AS lines,
       COUNT(DISTINCT CLAIM_ICN_NBR) AS claims,
       COUNT(DISTINCT BENEFICIARY_ID) AS members,
       SUM(LINE_PAID_AMT) AS paid_amount
FROM dated
GROUP BY date_basis, reporting_month, CLAIM_STATUS_CD
ORDER BY date_basis, reporting_month, CLAIM_STATUS_CD;

-- 7. Full raw procedure distribution (all dates); missing codes remain visible.
-- This is not a procedure crosswalk or a count of services/units/visits.
SELECT PROCEDURE_CD, CLAIM_STATUS_CD, COUNT(*) AS lines,
       COUNT(DISTINCT CLAIM_ICN_NBR) AS claims,
       COUNT(DISTINCT BENEFICIARY_ID) AS members,
       SUM(LINE_PAID_AMT) AS paid_amount
FROM TRN__TN_DE.MART_EDW_SV.CLAIM_LINE_TFACT C
WHERE UPPER(TRIM(C.CLAIM_CATEGORY_CD)) = 'DENTAL'
  AND C.CLAIM_STATUS_CD IN ('P','D')
  AND C.CLAIM_VOID_IND = 'N'
  AND C.LAST_CLAIM_IND = 'Y'
GROUP BY PROCEDURE_CD, CLAIM_STATUS_CD
ORDER BY CLAIM_STATUS_CD, paid_amount DESC NULLS LAST, PROCEDURE_CD;
