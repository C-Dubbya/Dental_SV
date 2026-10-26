-- Dental specification refined from source exports 01-16 and 22.
-- Semantic smoke PASS reported by user 2026-10-26; individual outputs not supplied here.
-- Base scope remains claim-header P/D. Line outcome is a separate, profiled attribute.
create or replace semantic view DENTAL_CLAIMS_SV
    tables (
        DENTAL_CLAIM_LINE_FACT as (
            SELECT
                CLAIM_ICN_NBR, CLAIM_LINE_NBR, BENEFICIARY_ID,
                BILL_MMIS_PROVIDER_ID, BILL_MMIS_PROVLOC_ID, MCO_ID,
                RENDER_MMIS_PROVIDER_ID, RENDER_MMIS_PROVLOC_ID,
                CLAIM_CATEGORY_CD, CLAIM_CATEGORY_DESC, CLAIM_TYPE_CD, CLAIM_TYPE_DESC,
                CLAIM_STATUS_CD, CLAIM_PAID_DT, CLAIM_FIRST_SERVICE_DT,
                CLAIM_LAST_SERVICE_DT, LINE_FIRST_SERVICE_DT, LINE_LAST_SERVICE_DT,
                LINE_STATUS_CD, LINE_STATUS_DESC,
                BENEFICIARY_BIRTH_DT, BENEFICIARY_AGE_YRS,
                HEALTH_PLAN_ID, HEALTH_PROGRAM_CD,
                ENCOUNTER_IND, CONTRACT_TYPE_CD, CONTRACT_TYPE_DESC,
                PAYMENT_LEVEL_CD, PAYMENT_LEVEL_DESC, POS_CD, POS_DESC,
                PROVIDER_SERVICE_COUNTY_CD, PROVIDER_SERVICE_COUNTY_NM,
                PROCEDURE_CD, PROCEDURE_DESC,
                SERVICE_PROCEDURE_CCS_CATEGORY_CD, SERVICE_PROCEDURE_CCS_CATEGORY_DESC,
                BILL_QTY, ALLOW_QTY,
                TOOTH_NBR_CD, TOOTH_NBR_DESC, TOOTH_QUADRANT_CD, TOOTH_QUADRANT_DESC,
                TOOTH_SURFACE_1_CD, TOOTH_SURFACE_1_DESC,
                TOOTH_SURFACE_2_CD, TOOTH_SURFACE_2_DESC,
                TOOTH_SURFACE_3_CD, TOOTH_SURFACE_3_DESC,
                TOOTH_SURFACE_4_CD, TOOTH_SURFACE_4_DESC,
                TOOTH_SURFACE_5_CD, TOOTH_SURFACE_5_DESC,
                LINE_BILL_AMT, LINE_ALLOW_AMT,
                LINE_ENCOUNTER_ALLOW_AMT, LINE_PAID_AMT, LINE_ENCOUNTER_PAID_AMT,
                LINE_CO_PAY_AMT
            FROM TRN__TN_DE.MART_EDW_SV.CLAIM_LINE_TFACT C
            WHERE UPPER(TRIM(C.CLAIM_CATEGORY_CD)) = 'DENTAL'
                AND C.CLAIM_STATUS_CD IN ('P', 'D')
                AND C.CLAIM_VOID_IND = 'N'
                AND C.LAST_CLAIM_IND = 'Y'
        ) comment='Final, non-void Dental lines on paid (P) or denied (D) claim headers. Source row identifier is CLAIM_ICN_NBR plus CLAIM_LINE_NBR; exports confirm uniqueness for the profiled population. A paid claim can contain denied lines: LINE_STATUS_CD is the detail outcome. No procedure-presence, age, plan, program, or dual-status restriction is embedded. Dental category comparison is case-normalized.',
        BENEFICIARY_DIM as (
            SELECT * FROM TRN__TN_DE.MART_EDW_SV.BENEFICIARY_DIM
            WHERE DE_CURRENT_ROW_IND = 'Y'
        ) unique (BENEFICIARY_ID) comment='Current member demographics. Current-row business-key uniqueness was confirmed in the source validation export. This is not an enrollment denominator.',
        BENEFICIARY_PROFILE_DIM as (
            WITH DENTAL_BENEFICIARY AS (
                SELECT DISTINCT C.BENEFICIARY_ID, C.CLAIM_FIRST_SERVICE_DT, D.YR_MONTH_NBR
                FROM TRN__TN_DE.MART_EDW_SV.CLAIM_LINE_TFACT C
                JOIN (
                    SELECT * FROM TRN__TN_DE.MART_EDW_SV.DATE_DIM
                    WHERE DE_CURRENT_ROW_IND = 'Y'
                ) D ON C.CLAIM_FIRST_SERVICE_DT = D.CALENDAR_DT
                WHERE UPPER(TRIM(C.CLAIM_CATEGORY_CD)) = 'DENTAL'
                    AND C.CLAIM_STATUS_CD IN ('P', 'D')
                    AND C.CLAIM_VOID_IND = 'N'
                    AND C.LAST_CLAIM_IND = 'Y'
            )
            SELECT
                D.BENEFICIARY_ID, D.CLAIM_FIRST_SERVICE_DT, B.BIRTH_DT,
                P.BENEFICIARY_AGE_GROUP_CD, P.BENEFICIARY_COUNTY_CD,
                P.HEALTH_PLAN_ID, H.HEALTH_PROGRAM_CD,
                P.MCO_NM AS ASSIGNED_MCO_NM, P.DBM_ID, P.DBM_IND,
                P.DUAL_IND, P.DCS_IND, P.DCS_CUSTODY_IND,
                P.KATIE_BECKETT_IND, P.TNCHIP_IND, P.MCHIP_IND, P.SCHIP_IND,
                P.PREGNANCY_IND, P.POSTPARTUM_IND,
                P.LTSS_CHOICES_IND, P.LTSS_CHOICES_ECF_IND,
                P.AID_CATEGORY_CD, P.BENEFIT_CATEGORY_CD
            FROM DENTAL_BENEFICIARY D
            JOIN TRN__TN_DE.MART_EDW_SV.BENEFICIARY_ELIGIBILITY_PER_MEMBER_PER_MONTH P
                ON D.BENEFICIARY_ID = P.BENEFICIARY_ID
                AND D.YR_MONTH_NBR = P.BENEFICIARY_ELIGIBILITY_YR_MONTH
                AND D.CLAIM_FIRST_SERVICE_DT BETWEEN P.ELIGIBILITY_BEGIN_DT AND P.ELIGIBILITY_END_DT
            JOIN (
                SELECT * FROM TRN__TN_DE.MART_EDW_SV.BENEFICIARY_DIM
                WHERE DE_CURRENT_ROW_IND = 'Y'
            ) B ON D.BENEFICIARY_ID = B.BENEFICIARY_ID
            JOIN (
                SELECT * FROM TRN__TN_DE.MART_EDW_SV.HEALTH_PLAN_DIM
                WHERE DE_CURRENT_ROW_IND = 'Y'
            ) H ON P.HEALTH_PLAN_ID = H.HEALTH_PLAN_ID
            QUALIFY ROW_NUMBER() OVER (
                PARTITION BY D.BENEFICIARY_ID, D.CLAIM_FIRST_SERVICE_DT
                ORDER BY P.HIER_NBR, P.HEALTH_PLAN_ID
            ) = 1
        ) unique (BENEFICIARY_ID, CLAIM_FIRST_SERVICE_DT) comment='One selected operative health-plan profile per Dental member and claim service date, ordered by HIER_NBR then HEALTH_PLAN_ID. The reviewed sample has overlapping source periods but PMPM row-months only from May 2025 through June 2026. Most unmatched Dental profiles occur in service months absent from the PMPM sample; remaining gaps involve missing members/member-months or non-covering eligibility spans. Preserve unmatched claims with unknown assignment and do not generalize sample gaps to lack of coverage. Profile breakouts attribute claims to selected assignment, not dental entitlement or the complete enrollment population. DBM-specific meaning remains unvalidated.',
        HEALTH_PLAN_DIM as (
            SELECT * FROM TRN__TN_DE.MART_EDW_SV.HEALTH_PLAN_DIM
            WHERE DE_CURRENT_ROW_IND = 'Y'
        ) unique (HEALTH_PLAN_ID) comment='Current health-plan reference for operative member assignment. Labels alone do not prove dental benefit coverage.',
        CLAIM_PLAN_DIM as (
            SELECT * FROM TRN__TN_DE.MART_EDW_SV.HEALTH_PLAN_DIM
            WHERE DE_CURRENT_ROW_IND = 'Y'
        ) unique (HEALTH_PLAN_ID) comment='Current plan reference for the plan code recorded on the Dental claim, separate from operative PMPM assignment. Current keys are unique but the source validation found 86.66 percent of paid lines unmatched. Preserve raw claim-plan codes and unknown lookup labels through LEFT JOINs; this role cannot independently classify the complete Dental population.',
        BILLING_PROVLOC_DIM as (
            SELECT * FROM TRN__TN_DE.MART_EDW_SV.MMIS_PROVLOC_DIM
            WHERE DE_CURRENT_ROW_IND = 'Y'
        ) unique (MMIS_PROVIDER_ID, MMIS_PROVLOC_ID) comment='Current billing provider-location reference. Current business keys are unique and all profiled Dental lines match the composite key. Billing identity remains separate from rendering provider.',
        RENDERING_PROVLOC_DIM as (
            SELECT * FROM TRN__TN_DE.MART_EDW_SV.MMIS_PROVLOC_DIM
            WHERE DE_CURRENT_ROW_IND = 'Y'
        ) unique (MMIS_PROVIDER_ID, MMIS_PROVLOC_ID) comment='Current attributes for the recorded rendering provider/location. Current composite keys are unique and all profiled Dental lines match, with no predicted fanout. Preserve LEFT JOIN behavior for future unmatched records. Rendering provider remains separate from billing and is not automatically an individual dentist.',
        MCO_DIM as (
            SELECT * FROM TRN__TN_DE.MART_EDW_SV.MCO_DIM
            WHERE DE_CURRENT_ROW_IND = 'Y'
        ) unique (MCO_ID) comment='Current organization reference for claim MCO_ID. Current keys are unique and all profiled Dental lines match. Business interpretation as dental payer versus administrator still requires source definitions.',
        BENEFICIARY_COUNTY_DIM as (
            SELECT * FROM TRN__TN_DE.MART_EDW_SV.COUNTY_DIM
            WHERE DE_CURRENT_ROW_IND = 'Y'
        ) unique (COUNTY_CD) comment='Current county reference for member residence geography.',
        SERVICE_COUNTY_DIM as (
            SELECT * FROM TRN__TN_DE.MART_EDW_SV.COUNTY_DIM
            WHERE DE_CURRENT_ROW_IND = 'Y'
        ) unique (COUNTY_CD) comment='Current county reference for the service county recorded on the claim. This does not establish access or travel distance.',
        PAID_DATE_DIM as (
            SELECT * FROM TRN__TN_DE.MART_EDW_SV.DATE_DIM
            WHERE DE_CURRENT_ROW_IND = 'Y'
        ) unique (CALENDAR_DT) comment='Current calendar reference for financial completion dates.',
        SERVICE_DATE_DIM as (
            SELECT * FROM TRN__TN_DE.MART_EDW_SV.DATE_DIM
            WHERE DE_CURRENT_ROW_IND = 'Y'
        ) unique (CALENDAR_DT) comment='Current calendar reference for claim first service dates.'
    )
    relationships (
        FACT_TO_MEMBER as DENTAL_CLAIM_LINE_FACT(BENEFICIARY_ID) references BENEFICIARY_DIM(BENEFICIARY_ID),
        FACT_TO_PROFILE as DENTAL_CLAIM_LINE_FACT(BENEFICIARY_ID, CLAIM_FIRST_SERVICE_DT) references BENEFICIARY_PROFILE_DIM(BENEFICIARY_ID, CLAIM_FIRST_SERVICE_DT),
        PROFILE_TO_PLAN as BENEFICIARY_PROFILE_DIM(HEALTH_PLAN_ID) references HEALTH_PLAN_DIM(HEALTH_PLAN_ID),
        FACT_TO_CLAIM_PLAN as DENTAL_CLAIM_LINE_FACT(HEALTH_PLAN_ID) references CLAIM_PLAN_DIM(HEALTH_PLAN_ID),
        PROFILE_TO_COUNTY as BENEFICIARY_PROFILE_DIM(BENEFICIARY_COUNTY_CD) references BENEFICIARY_COUNTY_DIM(COUNTY_CD),
        FACT_TO_BILLING as DENTAL_CLAIM_LINE_FACT(BILL_MMIS_PROVIDER_ID, BILL_MMIS_PROVLOC_ID) references BILLING_PROVLOC_DIM(MMIS_PROVIDER_ID, MMIS_PROVLOC_ID),
        FACT_TO_RENDERING as DENTAL_CLAIM_LINE_FACT(RENDER_MMIS_PROVIDER_ID, RENDER_MMIS_PROVLOC_ID) references RENDERING_PROVLOC_DIM(MMIS_PROVIDER_ID, MMIS_PROVLOC_ID),
        FACT_TO_ORGANIZATION as DENTAL_CLAIM_LINE_FACT(MCO_ID) references MCO_DIM(MCO_ID),
        FACT_TO_SERVICE_COUNTY as DENTAL_CLAIM_LINE_FACT(PROVIDER_SERVICE_COUNTY_CD) references SERVICE_COUNTY_DIM(COUNTY_CD),
        FACT_TO_PAID_DATE as DENTAL_CLAIM_LINE_FACT(CLAIM_PAID_DT) references PAID_DATE_DIM(CALENDAR_DT),
        FACT_TO_SERVICE_DATE as DENTAL_CLAIM_LINE_FACT(CLAIM_FIRST_SERVICE_DT) references SERVICE_DATE_DIM(CALENDAR_DT)
    )
    facts (
        DENTAL_CLAIM_LINE_FACT.CLAIM_LINE_NBR as CLAIM_LINE_NBR comment='Line number within ICN; combine both fields for source-row identity.',
        DENTAL_CLAIM_LINE_FACT.LINE_PAID_AMT as LINE_PAID_AMT comment='Source line paid amount and default spend measure. Dental source sums reconcile across status, date and role diagnostics. Disclose header versus detail status; do not combine with encounter amounts implicitly.',
        DENTAL_CLAIM_LINE_FACT.LINE_ALLOW_AMT as LINE_ALLOW_AMT comment='Source line allowed amount; report separately from paid.',
        DENTAL_CLAIM_LINE_FACT.LINE_BILL_AMT as LINE_BILL_AMT comment='Source line billed amount; report separately from paid.',
        DENTAL_CLAIM_LINE_FACT.LINE_ENCOUNTER_ALLOW_AMT as LINE_ENCOUNTER_ALLOW_AMT comment='Source encounter allowed amount. Completeness and meaning require dental profiling.',
        DENTAL_CLAIM_LINE_FACT.LINE_ENCOUNTER_PAID_AMT as LINE_ENCOUNTER_PAID_AMT comment='Source encounter paid amount. Validate Dental field population and financial-channel meaning for the queried scope; do not assume it is zero or substitute it for line paid amount.',
        DENTAL_CLAIM_LINE_FACT.LINE_CO_PAY_AMT as LINE_CO_PAY_AMT comment='Source line copay amount; do not infer the full member liability.',
        DENTAL_CLAIM_LINE_FACT.BILLED_SERVICE_QTY as BILL_QTY comment='Source billed service quantity; aggregate within compatible procedure-code units. Does not establish visits or completed treatment.',
        DENTAL_CLAIM_LINE_FACT.ALLOWED_SERVICE_QTY as ALLOW_QTY comment='Source allowed quantity. The profile reports positive values even on denied lines, so quantity alone does not establish paid/approved care.',
        DENTAL_CLAIM_LINE_FACT.PAID_CLAIMS labels = (filter) as CLAIM_STATUS_CD = 'P' comment='Lines on paid Dental claim headers; includes denied details and zero-paid lines.',
        DENTAL_CLAIM_LINE_FACT.DENIED_CLAIMS labels = (filter) as CLAIM_STATUS_CD = 'D' comment='Lines on denied Dental claim headers; final-record status is not the full submission history.',
        DENTAL_CLAIM_LINE_FACT.PAID_LINES labels = (filter) as LINE_STATUS_CD = 'P' comment='Paid detail-line outcome within the base header P/D scope. A paid detail can have zero dollars.',
        DENTAL_CLAIM_LINE_FACT.DENIED_LINES labels = (filter) as LINE_STATUS_CD = 'D' comment='Denied detail-line outcome, including denied details on paid claim headers.'
    )
    dimensions (
        DENTAL_CLAIM_LINE_FACT.BENEFICIARY_ID as BENEFICIARY_ID with synonyms=('member ID','Medicaid ID') comment='Claim member identifier. Return only for explicitly requested internal member detail.',
        DENTAL_CLAIM_LINE_FACT.CLAIM_ICN_NBR as CLAIM_ICN_NBR with synonyms=('claim','ICN') comment='Claim identifier; count distinctly. One claim can contain many procedure lines.',
        DENTAL_CLAIM_LINE_FACT.CLAIM_STATUS_CD as CLAIM_STATUS_CD comment='Claim-header status: P paid, D denied. Does not identify each detail-line outcome.',
        DENTAL_CLAIM_LINE_FACT.CLAIM_DISPOSITION as CASE CLAIM_STATUS_CD WHEN 'P' THEN 'Paid claim' WHEN 'D' THEN 'Denied claim' END comment='Human-readable claim-header status; separate from LINE_DISPOSITION.',
        DENTAL_CLAIM_LINE_FACT.LINE_STATUS_CD as LINE_STATUS_CD comment='Detail-line outcome. Denied lines can occur on paid claims; use this for line denials.',
        DENTAL_CLAIM_LINE_FACT.LINE_DISPOSITION as CASE LINE_STATUS_CD WHEN 'P' THEN 'Paid line' WHEN 'D' THEN 'Denied line' ELSE 'Other or unknown line status' END comment='Human-readable detail-line outcome.',
        DENTAL_CLAIM_LINE_FACT.CLAIM_FIRST_SERVICE_DT as CLAIM_FIRST_SERVICE_DT with synonyms=('claim service date','service date') comment='Claim-header first service date. Retained default service anchor and PMPM profile anchor. Can differ from line service date; no distinct-date visit measure is defined.',
        DENTAL_CLAIM_LINE_FACT.CLAIM_LAST_SERVICE_DT as CLAIM_LAST_SERVICE_DT comment='Claim-header last service date.',
        DENTAL_CLAIM_LINE_FACT.LINE_FIRST_SERVICE_DT as LINE_FIRST_SERVICE_DT with synonyms=('line service date','procedure service date') comment='First service date for the individual detail line. Use when the request specifies line/procedure service timing. Negative paid-date lag remains present on this basis.',
        DENTAL_CLAIM_LINE_FACT.LINE_LAST_SERVICE_DT as LINE_LAST_SERVICE_DT comment='Last service date for the individual detail line.',
        DENTAL_CLAIM_LINE_FACT.LINE_SERVICE_YR_MONTH_NBR as TO_NUMBER(TO_CHAR(LINE_FIRST_SERVICE_DT, 'YYYYMM')) comment='YYYYMM for explicit line-service monthly reporting.',
        DENTAL_CLAIM_LINE_FACT.CLAIM_PAID_DT as CLAIM_PAID_DT with synonyms=('paid date','payment date') comment='Financial completion date. Use for default spend reporting.',
        DENTAL_CLAIM_LINE_FACT.PROCEDURE_CD as PROCEDURE_CD with synonyms=('procedure code','dental code','CDT code') comment='Raw procedure code. Preserve text, numeric-format codes and BLANK sentinel rows. Do not impose a D-prefix filter on the Dental population.',
        DENTAL_CLAIM_LINE_FACT.PROCEDURE_DESC as PROCEDURE_DESC with synonyms=('procedure description','procedure name') comment='Procedure description carried on the claim; the aggregate export confirms one description per observed code. BLANK has Not Populated description. This does not establish an approved service-category crosswalk.',
        DENTAL_CLAIM_LINE_FACT.SERVICE_PROCEDURE_CCS_CATEGORY_CD as SERVICE_PROCEDURE_CCS_CATEGORY_CD comment='Source CCS code for exploration/display. Observed category 997 groups D-prefixed codes broadly; it does not isolate preventive/restorative Dental categories.',
        DENTAL_CLAIM_LINE_FACT.SERVICE_PROCEDURE_CCS_CATEGORY_DESC as SERVICE_PROCEDURE_CCS_CATEGORY_DESC comment='Source CCS category label; retain Not Populated and raw-code unknowns. Do not derive clinical cohorts from a category-label wildcard.',
        DENTAL_CLAIM_LINE_FACT.CLAIM_TYPE_CD as CLAIM_TYPE_CD comment='Source claim type; observed D / DENTAL CLAIMS. Financial-channel attributes are ENCOUNTER_IND and CONTRACT_TYPE_CD rather than this claim-type code.',
        DENTAL_CLAIM_LINE_FACT.CLAIM_TYPE_DESC as CLAIM_TYPE_DESC comment='Source claim-type label. Do not infer a financial channel from an unvalidated code.',
        DENTAL_CLAIM_LINE_FACT.MCO_ID as MCO_ID comment='Organization key on the claim; join to MCO_NM for display.',
        DENTAL_CLAIM_LINE_FACT.BILL_MMIS_PROVIDER_ID as BILL_MMIS_PROVIDER_ID comment='Billing provider key. Retain separately from the location key.',
        DENTAL_CLAIM_LINE_FACT.BILL_MMIS_PROVLOC_ID as BILL_MMIS_PROVLOC_ID comment='Billing location key; combine with billing provider ID.',
        DENTAL_CLAIM_LINE_FACT.RENDER_MMIS_PROVIDER_ID as RENDER_MMIS_PROVIDER_ID comment='Rendering provider key recorded on the claim; preserve separately from billing provider.',
        DENTAL_CLAIM_LINE_FACT.RENDER_MMIS_PROVLOC_ID as RENDER_MMIS_PROVLOC_ID comment='Rendering location key; use together with rendering provider ID.',
        DENTAL_CLAIM_LINE_FACT.CLAIM_HEALTH_PLAN_ID as HEALTH_PLAN_ID comment='Health-plan code recorded on the claim. Different attribution role from the selected operative PMPM plan.',
        DENTAL_CLAIM_LINE_FACT.CLAIM_HEALTH_PROGRAM_CD as HEALTH_PROGRAM_CD comment='Raw program recorded on the claim; N/A is common in the profile, so this field alone cannot define complete Medicaid membership.',
        DENTAL_CLAIM_LINE_FACT.SOURCE_BENEFICIARY_AGE_YRS as BENEFICIARY_AGE_YRS comment='Source age documented as years at line first service date. Small mismatches and DOB-after-service records were observed; use explicitly calculated age with invalid values separate for exact age cohorts.',
        DENTAL_CLAIM_LINE_FACT.CLAIM_BENEFICIARY_BIRTH_DT as BENEFICIARY_BIRTH_DT comment='DOB captured on the claim. Separate from current member reference DOB.',
        DENTAL_CLAIM_LINE_FACT.AGE_AT_SERVICE_NBR as CASE WHEN BENEFICIARY_BIRTH_DT IS NOT NULL AND CLAIM_FIRST_SERVICE_DT >= BENEFICIARY_BIRTH_DT THEN DATEDIFF(YEAR, BENEFICIARY_BIRTH_DT, CLAIM_FIRST_SERVICE_DT) - IFF(DATEADD(YEAR, DATEDIFF(YEAR, BENEFICIARY_BIRTH_DT, CLAIM_FIRST_SERVICE_DT), BENEFICIARY_BIRTH_DT) > CLAIM_FIRST_SERVICE_DT, 1, 0) END comment='Whole-year age from claim DOB at claim-header first service date. NULL for missing or DOB-after-service data. Does not require a PMPM profile.',
        DENTAL_CLAIM_LINE_FACT.AGE_AT_LINE_SERVICE_NBR as CASE WHEN BENEFICIARY_BIRTH_DT IS NOT NULL AND LINE_FIRST_SERVICE_DT >= BENEFICIARY_BIRTH_DT THEN DATEDIFF(YEAR, BENEFICIARY_BIRTH_DT, LINE_FIRST_SERVICE_DT) - IFF(DATEADD(YEAR, DATEDIFF(YEAR, BENEFICIARY_BIRTH_DT, LINE_FIRST_SERVICE_DT), BENEFICIARY_BIRTH_DT) > LINE_FIRST_SERVICE_DT, 1, 0) END comment='Whole-year age from claim DOB at line first service date. NULL for missing/invalid values. Use for explicit line-service age requests.',
        DENTAL_CLAIM_LINE_FACT.ENCOUNTER_IND as ENCOUNTER_IND comment='Source encounter indicator. All profiled Dental lines are Y; this does not define a distinct visit identifier.',
        DENTAL_CLAIM_LINE_FACT.CONTRACT_TYPE_CD as CONTRACT_TYPE_CD comment='Source contract type; all profiled Dental lines have F. Preserve without a hardcoded exclusion.',
        DENTAL_CLAIM_LINE_FACT.CONTRACT_TYPE_DESC as CONTRACT_TYPE_DESC comment='Source contract label; observed Fee for service encounter.',
        DENTAL_CLAIM_LINE_FACT.PAYMENT_LEVEL_CD as PAYMENT_LEVEL_CD comment='Source payment-level code; observed D with label Detail.',
        DENTAL_CLAIM_LINE_FACT.PAYMENT_LEVEL_DESC as PAYMENT_LEVEL_DESC comment='Source payment-level description.',
        DENTAL_CLAIM_LINE_FACT.POS_CD as POS_CD comment='Place-of-service code recorded on the claim; source population observed but individual code meanings require discovery.',
        DENTAL_CLAIM_LINE_FACT.POS_DESC as POS_DESC comment='Source place-of-service label; distinct from provider identity and geographic county.',
        DENTAL_CLAIM_LINE_FACT.TOOTH_NBR_CD as TOOTH_NBR_CD comment='Tooth number code recorded on the line. Not populated for every procedure; preserve missing/placeholder records.',
        DENTAL_CLAIM_LINE_FACT.TOOTH_NBR_DESC as TOOTH_NBR_DESC comment='Source tooth-number description.',
        DENTAL_CLAIM_LINE_FACT.TOOTH_QUADRANT_CD as TOOTH_QUADRANT_CD comment='Source quadrant code. Candidate-present screening found no populated quadrants in this extract; do not invent quadrant classifications.',
        DENTAL_CLAIM_LINE_FACT.TOOTH_QUADRANT_DESC as TOOTH_QUADRANT_DESC comment='Source quadrant description.',
        DENTAL_CLAIM_LINE_FACT.TOOTH_SURFACE_1_CD as TOOTH_SURFACE_1_CD comment='First recorded tooth-surface slot; a slot is not a separate procedure or line.',
        DENTAL_CLAIM_LINE_FACT.TOOTH_SURFACE_1_DESC as TOOTH_SURFACE_1_DESC comment='Source first tooth-surface description.',
        DENTAL_CLAIM_LINE_FACT.TOOTH_SURFACE_2_CD as TOOTH_SURFACE_2_CD comment='Second recorded tooth-surface slot.',
        DENTAL_CLAIM_LINE_FACT.TOOTH_SURFACE_2_DESC as TOOTH_SURFACE_2_DESC comment='Source second tooth-surface description.',
        DENTAL_CLAIM_LINE_FACT.TOOTH_SURFACE_3_CD as TOOTH_SURFACE_3_CD comment='Third recorded tooth-surface slot.',
        DENTAL_CLAIM_LINE_FACT.TOOTH_SURFACE_3_DESC as TOOTH_SURFACE_3_DESC comment='Source third tooth-surface description.',
        DENTAL_CLAIM_LINE_FACT.TOOTH_SURFACE_4_CD as TOOTH_SURFACE_4_CD comment='Fourth recorded tooth-surface slot.',
        DENTAL_CLAIM_LINE_FACT.TOOTH_SURFACE_4_DESC as TOOTH_SURFACE_4_DESC comment='Source fourth tooth-surface description.',
        DENTAL_CLAIM_LINE_FACT.TOOTH_SURFACE_5_CD as TOOTH_SURFACE_5_CD comment='Fifth recorded tooth-surface slot.',
        DENTAL_CLAIM_LINE_FACT.TOOTH_SURFACE_5_DESC as TOOTH_SURFACE_5_DESC comment='Source fifth tooth-surface description.',
        DENTAL_CLAIM_LINE_FACT.PROVIDER_SERVICE_COUNTY_CD as PROVIDER_SERVICE_COUNTY_CD comment='Source service-county key.',
        DENTAL_CLAIM_LINE_FACT.PROVIDER_SERVICE_COUNTY_NM as PROVIDER_SERVICE_COUNTY_NM comment='Source service-county label; role differs from member residence and billing location.',
        BENEFICIARY_DIM.BENEFICIARY_ID as BENEFICIARY_ID comment='Current reference member key for joins and distinct counts.',
        BENEFICIARY_DIM.BIRTH_DT as BIRTH_DT comment='Current reference date of birth; validate missing and future values.',
        BENEFICIARY_DIM.GENDER_CD as GENDER_CD comment='Source demographic sex/gender code; preserve source meaning.',
        BENEFICIARY_DIM.RACE_ETHNICITY_DESC as RACE_ETHNICITY_DESC comment='Current reference race/ethnicity description; retain unknown categories.',
        BENEFICIARY_PROFILE_DIM.BENEFICIARY_ID as BENEFICIARY_ID comment='Member key on selected operative service-date profile.',
        BENEFICIARY_PROFILE_DIM.CLAIM_FIRST_SERVICE_DT as CLAIM_FIRST_SERVICE_DT comment='Profile service-date key; join with member ID.',
        BENEFICIARY_PROFILE_DIM.PROFILE_AGE_AT_CLAIM_SERVICE_NBR as CASE WHEN BIRTH_DT IS NOT NULL AND CLAIM_FIRST_SERVICE_DT >= BIRTH_DT THEN DATEDIFF(YEAR, BIRTH_DT, CLAIM_FIRST_SERVICE_DT) - IFF(DATEADD(YEAR, DATEDIFF(YEAR, BIRTH_DT, CLAIM_FIRST_SERVICE_DT), BIRTH_DT) > CLAIM_FIRST_SERVICE_DT, 1, 0) END comment='Profile-DOB age at the claim-header service date. Use only for explicitly profile-based age analysis; fact AGE_AT_SERVICE_NBR avoids unnecessary PMPM dependence.',
        BENEFICIARY_PROFILE_DIM.BENEFICIARY_AGE_GROUP_CD as BENEFICIARY_AGE_GROUP_CD comment='Delivered standard profile age band; do not assume it matches a dental measure specification.',
        BENEFICIARY_PROFILE_DIM.BENEFICIARY_COUNTY_CD as BENEFICIARY_COUNTY_CD comment='Member residence county key at service.',
        BENEFICIARY_PROFILE_DIM.HEALTH_PLAN_ID as HEALTH_PLAN_ID comment='Operative health-plan assignment key at service; join for display.',
        BENEFICIARY_PROFILE_DIM.HEALTH_PROGRAM_CD as HEALTH_PROGRAM_CD comment='Federal program on the selected operative assignment.',
        BENEFICIARY_PROFILE_DIM.ASSIGNED_MCO_NM as ASSIGNED_MCO_NM comment='MCO on selected operative member assignment. This is separate from the organization on the Dental claim.',
        BENEFICIARY_PROFILE_DIM.DBM_ID as DBM_ID comment='DBM assignment key on selected operative PMPM row; validate dental-specific completeness before using.',
        BENEFICIARY_PROFILE_DIM.DBM_IND as DBM_IND comment='DBM assignment indicator on selected operative PMPM row; not proof of benefit entitlement.',
        BENEFICIARY_PROFILE_DIM.DUAL_IND as DUAL_IND comment='Dual status at service from selected profile; no exclusion is built in.',
        BENEFICIARY_PROFILE_DIM.DCS_IND as DCS_IND comment='DCS-related program indicator on selected profile.',
        BENEFICIARY_PROFILE_DIM.DCS_CUSTODY_IND as DCS_CUSTODY_IND comment='DCS custody indicator on selected profile.',
        BENEFICIARY_PROFILE_DIM.KATIE_BECKETT_IND as KATIE_BECKETT_IND comment='Katie Beckett indicator on selected profile.',
        BENEFICIARY_PROFILE_DIM.TNCHIP_IND as TNCHIP_IND comment='TNCHIP source indicator; reconcile to plan hierarchy before defining populations.',
        BENEFICIARY_PROFILE_DIM.MCHIP_IND as MCHIP_IND comment='MCHIP source indicator on selected profile.',
        BENEFICIARY_PROFILE_DIM.SCHIP_IND as SCHIP_IND comment='SCHIP source indicator on selected profile.',
        BENEFICIARY_PROFILE_DIM.PREGNANCY_IND as PREGNANCY_IND comment='Pregnancy flag at service; not a complete pregnancy episode.',
        BENEFICIARY_PROFILE_DIM.POSTPARTUM_IND as POSTPARTUM_IND comment='Postpartum flag at service; not a complete episode history.',
        BENEFICIARY_PROFILE_DIM.LTSS_CHOICES_IND as LTSS_CHOICES_IND comment='CHOICES assignment indicator at service.',
        BENEFICIARY_PROFILE_DIM.LTSS_CHOICES_ECF_IND as LTSS_CHOICES_ECF_IND comment='ECF CHOICES assignment indicator at service.',
        BENEFICIARY_PROFILE_DIM.AID_CATEGORY_CD as AID_CATEGORY_CD comment='Internal eligibility aid category; requires a validated code definition.',
        BENEFICIARY_PROFILE_DIM.BENEFIT_CATEGORY_CD as BENEFIT_CATEGORY_CD comment='Internal benefit category; requires a validated code definition.',
        HEALTH_PLAN_DIM.HEALTH_PLAN_ID as HEALTH_PLAN_ID comment='Current plan key.',
        HEALTH_PLAN_DIM.HEALTH_PLAN_DESC as HEALTH_PLAN_DESC with synonyms=('health plan','benefit plan') comment='Operative member plan label. Dollar breakouts use assignment attribution, not payment responsibility.',
        HEALTH_PLAN_DIM.STATE_HEALTH_PROGRAM_CD as STATE_HEALTH_PROGRAM_CD comment='State program on the assigned plan; validate code values before defining Medicaid or CHIP populations.',
        CLAIM_PLAN_DIM.CLAIM_PLAN_DESC as HEALTH_PLAN_DESC comment='Current label via the plan code recorded on the claim. Most profiled paid lines do not match; display raw CLAIM_HEALTH_PLAN_ID alongside the label and retain unknown labels. Never substitute operative assignment silently.',
        CLAIM_PLAN_DIM.CLAIM_PLAN_STATE_PROGRAM_CD as STATE_HEALTH_PROGRAM_CD comment='Current program through the claim-recorded plan lookup. Match coverage is incomplete; filtering this field intentionally restricts to matched/classified claims and requires coverage disclosure.',
        BILLING_PROVLOC_DIM.MMIS_PROVIDER_ID as MMIS_PROVIDER_ID comment='Billing reference provider key.',
        BILLING_PROVLOC_DIM.MMIS_PROVLOC_ID as MMIS_PROVLOC_ID comment='Billing reference location key; retain the composite join.',
        BILLING_PROVLOC_DIM.BILLING_PROVIDER_NM as PROVIDER_NM with synonyms=('billing provider') comment='Billing provider name. Does not identify a rendering dentist.',
        BILLING_PROVLOC_DIM.BILLING_NPI_ID as NPI_ID comment='Billing NPI; multiple provider-location keys may share it.',
        BILLING_PROVLOC_DIM.BILLING_PROVIDER_TYPE_DESC as PROVIDER_TYPE_DESC comment='Current billing provider type.',
        BILLING_PROVLOC_DIM.BILLING_SPECIALTY_DESC as PRIMARY_PROVIDER_SPECIALTY_DESC comment='Current billing provider specialty; do not present as rendering specialty.',
        BILLING_PROVLOC_DIM.BILLING_COUNTY_NM as PROVLOC_COUNTY_NM comment='Current billing location county; different from member residence or recorded service county.',
        RENDERING_PROVLOC_DIM.RENDERING_PROVIDER_NM as PROVIDER_NM with synonyms=('rendering provider','rendering dentist') comment='Current name via the recorded rendering provider/location pair. Full source match coverage is observed; check provider type before labeling every entity an individual dentist.',
        RENDERING_PROVLOC_DIM.RENDERING_NPI_ID as NPI_ID comment='Current rendering-location NPI; multiple source IDs/locations may share an NPI.',
        RENDERING_PROVLOC_DIM.RENDERING_PROVIDER_TYPE_DESC as PROVIDER_TYPE_DESC comment='Current rendering provider type; supports identifying individual versus other provider types.',
        RENDERING_PROVLOC_DIM.RENDERING_SPECIALTY_DESC as PRIMARY_PROVIDER_SPECIALTY_DESC comment='Current rendering provider specialty; separate from billing specialty.',
        RENDERING_PROVLOC_DIM.RENDERING_COUNTY_NM as PROVLOC_COUNTY_NM comment='Current address county of the recorded rendering location; separate from source service county and member residence.',
        MCO_DIM.MCO_ID as MCO_ID comment='Claim organization reference key.',
        MCO_DIM.MCO_NM as MCO_NM with synonyms=('claim organization') comment='Organization label via claim MCO_ID. Dental payer/administrator meaning and organization mappings require validation against Dental source definitions.',
        MCO_DIM.MCO_TYPE_DESC as MCO_TYPE_DESC comment='Current organization type description.',
        BENEFICIARY_COUNTY_DIM.BENEFICIARY_COUNTY_NM as COUNTY_NM with synonyms=('member county','residence county') comment='Residence county from selected operative service-date profile.',
        BENEFICIARY_COUNTY_DIM.BENEFICIARY_GRAND_REGION_NM as GRAND_REGION_NM comment='Residence grand-region label.',
        SERVICE_COUNTY_DIM.SERVICE_COUNTY_NM as COUNTY_NM with synonyms=('service county') comment='County via the service-county code on the Dental claim.',
        SERVICE_COUNTY_DIM.SERVICE_GRAND_REGION_NM as GRAND_REGION_NM comment='Recorded service grand-region label.',
        PAID_DATE_DIM.PAID_YR_NBR as YR_NBR comment='Calendar paid year.',
        PAID_DATE_DIM.PAID_YR_MONTH_NBR as YR_MONTH_NBR comment='Paid YYYYMM; use for chronological monthly grouping and sorting.',
        PAID_DATE_DIM.PAID_SFY_NBR as TRY_TO_NUMBER(STATE_FY_TXT) comment='Source Tennessee fiscal year number; validate source formatting. July-June fiscal boundaries can also be applied directly to paid dates.',
        SERVICE_DATE_DIM.SERVICE_YR_NBR as YR_NBR comment='Calendar service year.',
        SERVICE_DATE_DIM.SERVICE_YR_MONTH_NBR as YR_MONTH_NBR comment='Service YYYYMM; use for monthly service trends.',
        SERVICE_DATE_DIM.SERVICE_SFY_NBR as TRY_TO_NUMBER(STATE_FY_TXT) comment='Source Tennessee service fiscal year number.'
    )
    metrics (
        DENTAL_CLAIM_LINE_FACT.COUNT_CLAIM as COUNT(DISTINCT CLAIM_ICN_NBR) with synonyms=('claims','unique claims') comment='Distinct ICNs. This does not count visits, encounters, procedures, or teeth.',
        DENTAL_CLAIM_LINE_FACT.COUNT_CLAIM_LINE as COUNT(*) with synonyms=('claim lines','lines') comment='Source claim-line count, not service units.',
        DENTAL_CLAIM_LINE_FACT.COUNT_CLAIM_BENEFICIARY as COUNT(DISTINCT BENEFICIARY_ID) with synonyms=('members','utilizers','unique members') comment='Distinct members with included claims. Denominator is utilizers, not all eligible members. Never sum across groups.',
        DENTAL_CLAIM_LINE_FACT.COUNT_PAID_CLAIM as COUNT(DISTINCT IFF(CLAIM_STATUS_CD = 'P', CLAIM_ICN_NBR, NULL)) comment='Distinct ICNs with paid claim-header status; does not count paid details.',
        DENTAL_CLAIM_LINE_FACT.COUNT_DENIED_CLAIM as COUNT(DISTINCT IFF(CLAIM_STATUS_CD = 'D', CLAIM_ICN_NBR, NULL)) comment='Distinct ICNs with denied claim-header status. Use COUNT_CLAIM_WITH_DENIED_LINE for any denied detail.',
        DENTAL_CLAIM_LINE_FACT.COUNT_PAID_CLAIM_LINE as COUNT_IF(LINE_STATUS_CD = 'P') comment='Detail lines with paid LINE_STATUS_CD, including zero-dollar paid details. Separate from all lines on paid claim headers.',
        DENTAL_CLAIM_LINE_FACT.COUNT_DENIED_CLAIM_LINE as COUNT_IF(LINE_STATUS_CD = 'D') comment='Denied detail lines, including denied details on paid claim headers.',
        DENTAL_CLAIM_LINE_FACT.COUNT_LINES_ON_PAID_CLAIMS as COUNT_IF(CLAIM_STATUS_CD = 'P') comment='All lines on paid claim headers, including denied details. Matches the original header-P utilization baseline.',
        DENTAL_CLAIM_LINE_FACT.COUNT_LINES_ON_DENIED_CLAIMS as COUNT_IF(CLAIM_STATUS_CD = 'D') comment='All lines on denied claim headers.',
        DENTAL_CLAIM_LINE_FACT.COUNT_CLAIM_WITH_DENIED_LINE as COUNT(DISTINCT IFF(LINE_STATUS_CD = 'D', CLAIM_ICN_NBR, NULL)) comment='Distinct ICNs with at least one denied detail, including paid claims. This is not COUNT_DENIED_CLAIM.',
        DENTAL_CLAIM_LINE_FACT.DENIED_CLAIM_LINE_RATE as COUNT_IF(LINE_STATUS_CD = 'D') / NULLIF(COUNT_IF(LINE_STATUS_CD IN ('P','D')), 0) comment='Denied detail lines divided by paid plus denied detail lines in scope. Retain both header statuses for an overall line denial rate. Observed source profile: 8.51 percent.',
        DENTAL_CLAIM_LINE_FACT.DENIED_HEADER_LINE_SHARE as COUNT_IF(CLAIM_STATUS_CD = 'D') / NULLIF(COUNT_IF(CLAIM_STATUS_CD IN ('P','D')), 0) comment='Share of lines belonging to denied claim headers; not a detail-line denial rate. Observed profile: 3.60 percent.',
        DENTAL_CLAIM_LINE_FACT.SUM_LINE_PAID_AMT as SUM(LINE_PAID_AMT) with synonyms=('spend','paid amount','cost') comment='Sum of source line paid amounts. Paid spend requires P status. Completeness and encounter interpretation need dental validation.',
        DENTAL_CLAIM_LINE_FACT.SUM_LINE_ALLOWED_AMT as SUM(LINE_ALLOW_AMT) comment='Sum of allowed amounts.',
        DENTAL_CLAIM_LINE_FACT.SUM_LINE_BILLED_AMT as SUM(LINE_BILL_AMT) comment='Sum of billed amounts.',
        DENTAL_CLAIM_LINE_FACT.SUM_LINE_CO_PAY_AMT as SUM(LINE_CO_PAY_AMT) comment='Sum of recorded copays.',
        DENTAL_CLAIM_LINE_FACT.SUM_LINE_ENCOUNTER_ALLOWED_AMT as SUM(LINE_ENCOUNTER_ALLOW_AMT) comment='Sum of encounter allowed amounts, reported separately.',
        DENTAL_CLAIM_LINE_FACT.SUM_LINE_ENCOUNTER_PAID_AMT as SUM(LINE_ENCOUNTER_PAID_AMT) comment='Sum of encounter paid amounts, reported separately.',
        DENTAL_CLAIM_LINE_FACT.COUNT_LINES_WITH_ALLOWED as COUNT_IF(LINE_ALLOW_AMT <> 0) comment='Lines with nonzero allowed amounts.',
        DENTAL_CLAIM_LINE_FACT.COUNT_LINES_WITH_BILLED as COUNT_IF(LINE_BILL_AMT <> 0) comment='Lines with nonzero billed amounts.',
        DENTAL_CLAIM_LINE_FACT.COUNT_LINES_WITH_COPAY as COUNT_IF(LINE_CO_PAY_AMT <> 0) comment='Lines with nonzero copays.',
        DENTAL_CLAIM_LINE_FACT.COUNT_LINES_WITH_ENCOUNTER_PAID as COUNT_IF(LINE_ENCOUNTER_PAID_AMT <> 0) comment='Lines with nonzero encounter paid amounts.',
        DENTAL_CLAIM_LINE_FACT.COUNT_DISTINCT_PROCEDURE as COUNT(DISTINCT PROCEDURE_CD) comment='Distinct observed procedure-code values, not number of services rendered.',
        DENTAL_CLAIM_LINE_FACT.COUNT_DISTINCT_BILLING_PROVIDER as COUNT(DISTINCT BILL_MMIS_PROVIDER_ID) comment='Distinct billing provider IDs, not rendering dentists or enrolled network capacity.',
        DENTAL_CLAIM_LINE_FACT.COUNT_DISTINCT_BILLING_LOCATION as COUNT(DISTINCT BILL_MMIS_PROVIDER_ID, BILL_MMIS_PROVLOC_ID) comment='Distinct billing provider-location pairs with non-null keys.',
        DENTAL_CLAIM_LINE_FACT.COUNT_DISTINCT_RENDERING_PROVIDER as COUNT(DISTINCT RENDER_MMIS_PROVIDER_ID) comment='Distinct source rendering provider IDs, not distinct dentists by NPI or network capacity.',
        DENTAL_CLAIM_LINE_FACT.COUNT_DISTINCT_RENDERING_LOCATION as COUNT(DISTINCT RENDER_MMIS_PROVIDER_ID, RENDER_MMIS_PROVLOC_ID) comment='Distinct source rendering provider-location pairs; not visits.',
        DENTAL_CLAIM_LINE_FACT.SUM_BILLED_SERVICE_QTY as SUM(BILL_QTY) with synonyms=('billed units') comment='Sum of source billed quantity. Use within compatible procedure units; do not sum unlike service units as procedures or visits.',
        DENTAL_CLAIM_LINE_FACT.SUM_ALLOWED_SERVICE_QTY as SUM(ALLOW_QTY) with synonyms=('allowed units') comment='Sum of source allowed quantity, including positive quantities observed on denied details. Always disclose status and do not label as paid services.',
        DENTAL_CLAIM_LINE_FACT.PAID_PER_CLAIM as SUM(LINE_PAID_AMT) / NULLIF(COUNT(DISTINCT CLAIM_ICN_NBR), 0) comment='Paid amount per unique ICN; not cost per visit.',
        DENTAL_CLAIM_LINE_FACT.PAID_PER_UTILIZER as SUM(LINE_PAID_AMT) / NULLIF(COUNT(DISTINCT BENEFICIARY_ID), 0) comment='Paid amount per claim utilizer; not per enrollee or PMPM.',
        DENTAL_CLAIM_LINE_FACT.CLAIMS_PER_UTILIZER as COUNT(DISTINCT CLAIM_ICN_NBR) / NULLIF(COUNT(DISTINCT BENEFICIARY_ID), 0) comment='Distinct ICNs per claim utilizer; not visits per member.',
        DENTAL_CLAIM_LINE_FACT.LATEST_PAID_DT as MAX(CLAIM_PAID_DT) comment='Latest financial completion date under current scope.',
        DENTAL_CLAIM_LINE_FACT.LATEST_SERVICE_DT as MAX(CLAIM_FIRST_SERVICE_DT) comment='Latest claim-header first service date under current scope.',
        DENTAL_CLAIM_LINE_FACT.LATEST_LINE_SERVICE_DT as MAX(LINE_FIRST_SERVICE_DT) comment='Latest line first service date under current scope.',
        DENTAL_CLAIM_LINE_FACT.COUNT_LINES_PAID_BEFORE_CLAIM_SERVICE as COUNT_IF(CLAIM_PAID_DT < CLAIM_FIRST_SERVICE_DT) comment='Data-quality count: paid-date precedes claim-header service date. Does not establish erroneous payment.',
        DENTAL_CLAIM_LINE_FACT.COUNT_LINES_PAID_BEFORE_LINE_SERVICE as COUNT_IF(CLAIM_PAID_DT < LINE_FIRST_SERVICE_DT) comment='Data-quality count: paid-date precedes line service date. Do not exclude these records implicitly.'
    )
    comment='TennCare Dental lines on final non-void paid and denied claim headers. Separate claim-header and detail-line outcomes; source procedure descriptions and CCS exploration fields; billed/allowed quantities; recorded tooth/surface detail; billing and rendering roles; claim organizations; direct claim age/plan attributes; and operative profile enrichment. Source validation confirms unique current reference keys and full provider/claim-organization matches, but large claim-plan lookup gaps and some missing operative profiles. Preserve unmatched claims and revalidate reconciliation after relevant source or model changes. No approved clinical cohort crosswalk, visit definition, enrollment denominator, clinical outcome or official quality-measure implementation is implied.'
    ai_sql_generation 'SCOPE AND GRAIN
- Use the named metrics and columns. Category, final-version and non-void filters are embedded in the fact.
- Default spend and claim-based utilization retain CLAIM_STATUS_CD = ''P'', including its denied details and zero-paid lines, matching the baseline. Label this as paid-claim scope. Explicit paid-detail utilization uses PAID_LINES (LINE_STATUS_CD = ''P''); explicit denied lines use DENIED_LINES (LINE_STATUS_CD = ''D'') across both header statuses unless a header scope is requested. Denied claims use DENIED_CLAIMS (CLAIM_STATUS_CD = ''D'').
- Claim-header and line outcomes differ. For overall line denials keep both header statuses and return LINE_DISPOSITION, COUNT_PAID_CLAIM_LINE, COUNT_DENIED_CLAIM_LINE and DENIED_CLAIM_LINE_RATE. Do not add a paid-header filter to an overall denial-rate request. For header comparisons use CLAIM_DISPOSITION, header claim counts and COUNT_LINES_ON_PAID_CLAIMS/COUNT_LINES_ON_DENIED_CLAIMS. DENIED_HEADER_LINE_SHARE is a header-based line share, not a detail denial rate.
- Claims = COUNT_CLAIM, lines = COUNT_CLAIM_LINE, members = COUNT_CLAIM_BENEFICIARY. Never label any of these as visits, procedures performed, units or teeth.
- Paid and denied ICN counts may overlap. Distinct members and claims are not additive across months, procedures or organizations; compute unduplicated totals separately.
- Paid status may include zero amounts. Never add LINE_PAID_AMT > 0 as an implicit utilization criterion.

DATES AND MEASURES
- Default spend uses CLAIM_PAID_DT; unqualified service/utilization timing retains CLAIM_FIRST_SERVICE_DT (claim-header first service). Explicit detail/procedure service timing uses LINE_FIRST_SERVICE_DT and LINE_SERVICE_YR_MONTH_NBR. Do not silently change the service-date anchor: profile alignment remains claim-header first service. State the exact date basis.
- Tennessee SFY N is July 1 of N-1 through June 30 of N; use half-open date bounds. Bare years are calendar years.
- Resolve relative periods from MAX of the applicable date over paid Dental lines. Last N months excludes the month containing that maximum; return resolved bounds. With no period, use the SFY containing the applicable data maximum and disclose partial-year coverage.
- Monthly trends group/order by YYYYMM. Data-recency answers return both latest paid and latest service dates and never imply a known refresh timestamp.
- Spend = SUM_LINE_PAID_AMT; allowed, billed, copay and encounter amounts stay separate. Dental source profiling found zero encounter-paid values despite ENCOUNTER_IND = Y and contract F (Fee for service encounter); do not infer absence of encounters from dollar population. This is historical evidence, not an invariant. For an alternative dollar measure return claim and line counts, its available nonzero count and paid amount as context.
- Billed/allowed service units use SUM_BILLED_SERVICE_QTY/SUM_ALLOWED_SERVICE_QTY. Group by procedure code and description and preserve compatible units. Allowed quantity is positive on observed denied details, so it is not proof of approval or paid treatment. Do not sum unrelated procedure units into a visit or procedure count.
- Negative paid/service lag occurs on both claim- and line-date bases in the profiled source. Keep the rows and explain the unresolved source-date anomaly when relevant; do not invent a correction, shift dates or infer improper payment. Available paid months cover only part of SFY 2026 and historical service tails do not establish complete older service years.
- Use NULLIF for division. A missing denominator returns NULL, not zero.

ENRICHMENT AND MEDICAID SLICES
- LEFT JOIN reference dimensions for claim enrichment so missing profiles, providers, organizations and geography remain unknown categories. Explicit population filters can intentionally restrict records; disclose the restriction and unresolved profile counts. Join profile on BOTH member ID and claim-header service date; each billing/rendering location on BOTH role-specific provider and location ID. Never join billing keys to the rendering role.
- Profile and claim-plan lookup gaps are confirmed in the source. A plan/profile breakout must retain a visible unknown category and reconcile total lines and paid amount to the un-enriched scope. Do not apply WHERE joined_dimension.key IS NOT NULL or exclude unknown labels unless explicitly requested. If a tool query drops unmatched records, correct the join or report that the requested full-population breakout could not be retrieved.
- The reviewed sample has overlapping source periods, but PMPM row-months cover only May 2025 through June 2026 while Dental service history extends earlier. Source diagnostics explain missing profiles through absent source months, absent members/member-months and non-covering member-month spans. Label the unmatched group No matching PMPM record satisfying member/month/service-date criteria in supplied sample or unknown profile assignment; a span mismatch does not mean no member-month row exists. Long/open-ended eligibility-span boundaries do not establish historical PMPM month availability. Do not infer uninsured status, ineligibility or a production source defect. Keep exact matching, do not substitute another month or widen intervals, and do not exclude older Dental claims implicitly. Reassess these sample-specific bounds when data changes.
- Profile selection follows HIER_NBR then HEALTH_PLAN_ID. When grouping/filtering by profile attributes or associated plan/residence labels, disclose operative health-plan assignment at service date as the attribution basis. Claim organization, assigned MCO and DBM assignment are separate roles.
- No plan, program, age, dual-status or DBM exclusion is implicit. Use source-defined labels and confirmed code values; discover values before guessing them.
- Exact claim-service age uses fact AGE_AT_SERVICE_NBR (claim DOB at claim first service); explicit line-service age uses AGE_AT_LINE_SERVICE_NBR. An under-21 request uses valid calculated ages 0-20. Keep unknown/invalid ages separate and do not require PMPM solely to derive age. SOURCE_BENEFICIARY_AGE_YRS and profile age have distinct provenance; do not substitute one silently. Fiscal-year-end age requires the explicitly requested anchor.
- CLAIM_HEALTH_PLAN_ID, CLAIM_HEALTH_PROGRAM_CD and CLAIM_PLAN_DESC describe the plan recorded on the claim, not operative assignment. Raw claim HEALTH_PROGRAM_CD is often N/A and most paid lines do not match CLAIM_PLAN_DIM; neither path independently defines complete Medicaid/CHIP populations. For claim-plan reporting select raw code and lookup label separately, with unknown labels visible. Never silently fall back to an operative plan/program. A requested matched-program filter must disclose the excluded/unclassified population. Do not classify TNXIX or another code without a confirmed definition.
- Member residence, billing-location county and service county are distinct. None proves travel distance or adequate access.
- Billing provider and recorded rendering provider are separate roles. Current composite-key checks found full matches with no fanout for both in the profiled source; preserve LEFT JOIN behavior on new data. An unspecified provider request defaults to billing, with the role disclosed. Distinct source rendering IDs are not distinct individual dentists or enrolled network capacity. Claim MCO_ID matches the reference but its dental administrator/payer interpretation is still unresolved.

PROCEDURE ANALYSIS
- Use exact PROCEDURE_CD values or an explicit client-supplied list. Display PROCEDURE_DESC from the claim as a separate column; no reference join is required for it. Preserve leading characters and zeros. Preserve BLANK/Not Populated records as unknown classification; the observed numeric-format codes remain in Dental scope.
- Do not invent preventive, diagnostic, restorative, extraction, orthodontic, sealant, fluoride, anesthesia, or emergency procedure lists. Ask for a code list or report raw-code distribution when a governed mapping is absent.
- Procedure-code claims describe billed exposure; they do not establish diagnosis, disease prevalence, completed treatment or clinical outcomes.
- A raw code count and a claim-line count do not establish units. Use the source-quantity metrics for units. A member-service-date count does not establish visits; a visit measure requires an approved definition.
- Source tooth numbers/surfaces support recorded-detail analysis within member/procedure/date context. Surface slots are repeated attributes of one source line: an any-surface predicate uses OR across slots, and unpivoting must not multiply line counts or dollars. Never sum tooth codes or treat a tooth number as globally unique. Missing tooth/surface data is not proof of no treatment; quadrant screening found no usable values in this extract.
- Rankings use the requested measure and preserve the original date/population filters. Top N within a group uses a partitioned rank. Return procedure codes and separately supplied descriptions as separate columns.
- Return member identifiers only for explicitly requested internal member detail.'
    ai_question_categorization 'ANSWERABLE: paid and denied Dental claims with explicit header/line outcomes, detail-line denial rates, distinct claim utilizers, financial amounts, source procedure descriptions, billed/allowed units within compatible procedure groups, recorded tooth/surface details, billing and rendering provider activity, claim organizations, claim-recorded age/plan attributes, and operative service-date member slices available in this model. Missing reference coverage remains visible.
UNCLEAR: visits, completed treatments, emergency dental, preventive/restorative/other procedure groups without an approved code list, individual dentists versus source provider IDs, or payer/DBM attribution when available roles do not resolve the request. Explain the missing definition and offer recorded procedure/provider results where useful.
UNANSWERABLE from this model: all-enrollee utilization rates, PMPM, continuous-enrollment measures, benefit entitlement, coverage/medical necessity determinations, disease prevalence, clinical outcomes, authorization or denial reasons, and dental work billed outside the Dental category. Do not infer those from tooth details, quantities or source CCS classification. Explain the missing source or definition. A claims-utilizer proxy may be offered with its denominator stated.
Do not describe a claims-based proxy as CMS-416, a Core Set measure or a HEDIS result without the exact reporting-year specification, population/eligibility denominator and validated service mapping.';
