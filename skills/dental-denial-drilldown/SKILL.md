---
name: dental-denial-drilldown
description: Analyze Dental denied claims, denied detail lines and denial rates while preserving claim-header versus detail-line status and explicit denominators. Use for denial trends and procedure or provider denial breakouts.
---

# Dental Denial Drilldown

## Model integration

Map denied claims to `COUNT_DENIED_CLAIM`; denied details to `COUNT_DENIED_CLAIM_LINE`; claims with any denied detail to `COUNT_CLAIM_WITH_DENIED_LINE`; detail denial rate to `DENIED_CLAIM_LINE_RATE`; header-D line share to `DENIED_HEADER_LINE_SHARE`.

For an unspecified denial rate, use the model's detail-line rate over both header statuses and state that definition. Return `COUNT_DENIED_CLAIM_LINE` as numerator and `COUNT_PAID_CLAIM_LINE + COUNT_DENIED_CLAIM_LINE` as denominator. Do not filter to line D before computing the rate: that would discard its paid-line denominator. A denied-header line share uses `COUNT_LINES_ON_DENIED_CLAIMS / COUNT_CLAIM_LINE` within the base header P/D scope, not a unique-claim denial rate. Preserve explicit user restrictions and label conditional rates accordingly.


## Purpose
Analyze dental denials correctly by separating claim-header denials from detail-line denials and reporting the correct denominator for each rate.

## Use this skill when
Use this skill when the user asks:

- What is the dental denial rate?
- How many denied claims are there?
- Which procedures or providers have the most denials?
- Are denials increasing over time?

## Required analyst behavior

- Use `DENTAL_CLAIMS_SV` for every factual result.
- Distinguish:
  - claim-header denial = `CLAIM_STATUS_CD = 'D'`
  - denied detail line = `LINE_STATUS_CD = 'D'`
- For overall line denial analysis:
  - retain both header statuses
  - use `LINE_STATUS_CD`
- For denied claims:
  - use header status `D`
- Report numerator and denominator explicitly for all rates.
- Do not infer line outcome from claim-header outcome.

## Procedure

1. Identify whether the user wants:
   - denied claims
   - denied lines
   - claims with at least one denied line
   - denied line rate
   - denied-header line share
2. Resolve period and date basis.
3. Pull trend and/or requested breakout.
4. If requested, breakout by:
   - procedure code
   - billing provider
   - recorded rendering provider
   - claim organization
   - geography
   - plan role
5. Present the metric with its correct denominator and a short interpretation.

## Guardrails

- Never present header-D line share as a line denial rate.
- Paid claims can contain denied detail lines.
- Do not use denial reasons; they are not available from this model.
- Do not filter to paid claim headers when the user asks for an overall denied line rate unless they explicitly request that header scope.

## Output requirements
Lead with the definition-aware result:

- "The denied detail-line rate was X, defined as denied lines divided by paid plus denied lines in scope."

Then include:

- exact scope
- numerator
- denominator
- breakout or trend if requested

Always include a concise basis statement covering:

- date basis
- resolved period
- header or line status scope
- population
- measure and denominator

## Example prompts

- What is the dental denial rate this year?
- Show denied lines by procedure code.
- Compare denied claims and denied lines by month.
- Which providers have the highest dental line denial rate?
