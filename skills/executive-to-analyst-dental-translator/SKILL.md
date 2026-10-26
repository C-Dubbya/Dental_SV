---
name: executive-to-analyst-dental-translator
description: Resolve broad Dental business questions into explicit measures, dates, status, roles, populations, denominators and grain. Use when material ambiguity needs governing defaults or clarification before an analytical workflow.
---

# Executive-to-Analyst Dental Translator

## Model integration

Use the semantic view's supported defaults first: paid date for ordinary spend, header P for ordinary claims/utilization, billing for unspecified provider, and the model's governed period when omitted. Overall line denial analysis instead retains both header statuses and uses detail outcomes. Do not ask for period/date/provider clarification when a supported default resolves the question.

For an unresolved plan role that materially changes the question, ask one concise question distinguishing claim organization, claim-recorded plan and operative assigned plan/MCO/DBM. A resolved brief is the internal self-contained Analyst request, not a substitute for executing the user's analysis. Return the brief itself when the user requests planning or requirements only; otherwise execute the relevant workflow and report its result with a concise basis. Skills and prior conversation resolve intent but cannot supply factual values.


## Purpose
Translate broad or ambiguous TennCare Dental business questions into a governed analytic specification before data retrieval begins.

## Use this skill when
Use this skill when the user asks vague questions such as:

- How is dental doing?
- Show utilization by plan.
- Are denials getting worse?
- Which dentists drive cost?
- What are the biggest dental issues?

## Required analyst behavior
Before executing analysis, resolve the question into explicit choices for:

- measure
- date basis
- status scope
- provider/organization/plan role
- cohort or population slice
- denominator
- output grain

Use `DENTAL_CLAIMS_SV` terminology and rules when forming the resolved analysis question.

## Procedure

1. Parse the business question.
2. Identify ambiguities that would materially change the answer.
3. Convert the request into a structured analysis brief with:
   - measure
   - date basis
   - status scope
   - attribution role
   - population slice
   - output grain
4. If a safe default is supported, state it explicitly.
5. If ambiguity remains material and unresolved by domain rules, ask a clarification question.
6. After resolution, hand off to the appropriate execution workflow.

## Guardrails

- Do not guess when multiple materially different interpretations exist.
- Claims, lines, utilizers, and paid amount must stay distinct.
- Plan role must be explicit:
  - claim organization
  - claim-recorded plan
  - operative assigned plan/MCO/DBM
- Provider role must be explicit:
  - billing provider
  - recorded rendering provider
- No unsupported enrollment denominator or PMPM should be inferred.

## Output requirements
For a specification-only request, return a short analysis brief with the fields below. For an analytical request, use these fields internally to form the Analyst request, execute the appropriate workflow, and return the finding with its basis rather than stopping at the brief:

- original business question
- resolved analysis question
- measure
- date basis
- status scope
- attribution role
- cohort/population slice
- output grain
- required caveats

Ask a clarification question only if material ambiguity remains after applying supported defaults; otherwise proceed to execution for analytical requests.

## Example prompts

- How is dental doing?
- Show dental utilization by plan.
- Which providers are driving cost?
- Give me a dental summary for leadership.
