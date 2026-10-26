-- Follow-up to the four received CSVs. All statements are read-only.
-- Run 1-4 separately and export each complete result with the filename shown.
-- Statement 5 is optional lookup-name discovery; it reads no procedure records.
-- No model deployment, source modification or INFORMATION_SCHEMA access is needed.

-- 1 -> 05_claim_line_columns.csv
-- Existing 01_claim_line_columns.csv contains the provider-location schema:
-- MMIS_PROVLOC_DIM_SK, MMIS_PROVIDER_ID, NPI_ID, etc., not claim-line columns.
-- Retain that useful export, but collect this exact object as well.
DESC TABLE TRN__TN_DE.MART_EDW_SV.CLAIM_LINE_TFACT;

-- 2 -> 06_dental_grain.csv
-- Aggregates only; no claim/member identifiers are exported.
WITH dental AS (
    SELECT CLAIM_ICN_NBR, CLAIM_LINE_NBR, BENEFICIARY_ID, CLAIM_STATUS_CD
    FROM TRN__TN_DE.MART_EDW_SV.CLAIM_LINE_TFACT C
    WHERE UPPER(TRIM(C.CLAIM_CATEGORY_CD)) = 'DENTAL'
      AND C.CLAIM_STATUS_CD IN ('P', 'D')
      AND C.CLAIM_VOID_IND = 'N'
      AND C.LAST_CLAIM_IND = 'Y'
), key_counts AS (
    SELECT CLAIM_ICN_NBR, CLAIM_LINE_NBR, COUNT(*) AS row_count
    FROM dental
    GROUP BY CLAIM_ICN_NBR, CLAIM_LINE_NBR
), icn_status AS (
    SELECT CLAIM_ICN_NBR,
           MAX(IFF(CLAIM_STATUS_CD = 'P', 1, 0)) AS has_paid,
           MAX(IFF(CLAIM_STATUS_CD = 'D', 1, 0)) AS has_denied
    FROM dental
    WHERE CLAIM_ICN_NBR IS NOT NULL
    GROUP BY CLAIM_ICN_NBR
)
SELECT
    (SELECT COUNT(*) FROM dental) AS CLAIM_LINE_COUNT,
    (SELECT COUNT(DISTINCT CLAIM_ICN_NBR) FROM dental) AS UNDUPLICATED_CLAIM_COUNT,
    (SELECT COUNT(DISTINCT BENEFICIARY_ID) FROM dental) AS UNDUPLICATED_MEMBER_COUNT,
    (SELECT COUNT(*) FROM dental WHERE CLAIM_ICN_NBR IS NULL OR CLAIM_LINE_NBR IS NULL) AS NULL_LINE_KEYS,
    (SELECT COUNT(*) FROM key_counts WHERE row_count > 1) AS DUPLICATE_KEY_GROUPS,
    (SELECT COALESCE(SUM(row_count - 1), 0) FROM key_counts) AS EXCESS_ROWS,
    (SELECT MAX(row_count) FROM key_counts) AS MAX_ROWS_PER_KEY,
    (SELECT COUNT(*) FROM icn_status WHERE has_paid = 1 AND has_denied = 1) AS ICNS_WITH_BOTH_STATUSES;

-- 3 -> 07_dental_monthly.csv
-- Paid dates in the exports cover 2025-06-29 through 2026-06-12, but services
-- extend much further back. Profile both date bases before choosing a window.
-- No service-month maturity or continuous data coverage is assumed here.
WITH dental AS (
    SELECT CLAIM_PAID_DT, CLAIM_FIRST_SERVICE_DT, CLAIM_STATUS_CD,
           CLAIM_ICN_NBR, BENEFICIARY_ID, LINE_PAID_AMT
    FROM TRN__TN_DE.MART_EDW_SV.CLAIM_LINE_TFACT C
    WHERE UPPER(TRIM(C.CLAIM_CATEGORY_CD)) = 'DENTAL'
      AND C.CLAIM_STATUS_CD IN ('P', 'D')
      AND C.CLAIM_VOID_IND = 'N'
      AND C.LAST_CLAIM_IND = 'Y'
), date_roles AS (
    SELECT 'Paid' AS DATE_BASIS, CLAIM_PAID_DT AS REPORTING_DT,
           CLAIM_STATUS_CD, CLAIM_ICN_NBR, BENEFICIARY_ID, LINE_PAID_AMT
    FROM dental
    UNION ALL
    SELECT 'Service' AS DATE_BASIS, CLAIM_FIRST_SERVICE_DT AS REPORTING_DT,
           CLAIM_STATUS_CD, CLAIM_ICN_NBR, BENEFICIARY_ID, LINE_PAID_AMT
    FROM dental
)
SELECT DATE_BASIS, DATE_TRUNC('MONTH', REPORTING_DT) AS REPORTING_MONTH,
       CLAIM_STATUS_CD, COUNT(*) AS CLAIM_LINE_COUNT,
       COUNT(DISTINCT CLAIM_ICN_NBR) AS CLAIM_COUNT,
       COUNT(DISTINCT BENEFICIARY_ID) AS MEMBER_COUNT,
       COUNT_IF(LINE_PAID_AMT = 0) AS ZERO_PAID_LINES,
       SUM(LINE_PAID_AMT) AS PAID_AMOUNT
FROM date_roles
GROUP BY DATE_BASIS, REPORTING_MONTH, CLAIM_STATUS_CD
ORDER BY DATE_BASIS, REPORTING_MONTH, CLAIM_STATUS_CD;

-- 4 -> 08_dental_service_paid_lag.csv
-- Quantify the historical service tail; this is not a full claims runout study.
WITH dental AS (
    SELECT CLAIM_STATUS_CD, CLAIM_ICN_NBR, BENEFICIARY_ID, LINE_PAID_AMT,
           CLAIM_FIRST_SERVICE_DT, CLAIM_PAID_DT,
           DATEDIFF(DAY, CLAIM_FIRST_SERVICE_DT, CLAIM_PAID_DT) AS lag_days
    FROM TRN__TN_DE.MART_EDW_SV.CLAIM_LINE_TFACT C
    WHERE UPPER(TRIM(C.CLAIM_CATEGORY_CD)) = 'DENTAL'
      AND C.CLAIM_STATUS_CD IN ('P', 'D')
      AND C.CLAIM_VOID_IND = 'N'
      AND C.LAST_CLAIM_IND = 'Y'
), bucketed AS (
    SELECT *, CASE
        WHEN lag_days IS NULL THEN '0 Missing service/paid date'
        WHEN lag_days < 0 THEN '1 Paid before service'
        WHEN lag_days <= 30 THEN '2 0-30 days'
        WHEN lag_days <= 90 THEN '3 31-90 days'
        WHEN lag_days <= 365 THEN '4 91-365 days'
        WHEN lag_days <= 730 THEN '5 366-730 days'
        ELSE '6 731+ days'
    END AS LAG_BUCKET
    FROM dental
)
SELECT CLAIM_STATUS_CD, LAG_BUCKET,
       COUNT(*) AS CLAIM_LINE_COUNT,
       COUNT(DISTINCT CLAIM_ICN_NBR) AS CLAIM_COUNT,
       COUNT(DISTINCT BENEFICIARY_ID) AS MEMBER_COUNT,
       MIN(CLAIM_FIRST_SERVICE_DT) AS FIRST_SERVICE_DT,
       MAX(CLAIM_FIRST_SERVICE_DT) AS LATEST_SERVICE_DT,
       MIN(lag_days) AS MIN_LAG_DAYS,
       MAX(lag_days) AS MAX_LAG_DAYS,
       SUM(LINE_PAID_AMT) AS PAID_AMOUNT
FROM bucketed
GROUP BY CLAIM_STATUS_CD, LAG_BUCKET
ORDER BY CLAIM_STATUS_CD, LAG_BUCKET;

-- 5 -> 09_procedure_objects.csv (OPTIONAL)
-- If you already know the procedure lookup object, send its name/DDL instead.
-- SHOW may expose objects visible to your role; no rows means no visible match,
-- not proof that no lookup exists. Return an access error if listing is blocked.
SHOW OBJECTS LIKE '%PROC%' IN SCHEMA TRN__TN_DE.MART_EDW_SV;
