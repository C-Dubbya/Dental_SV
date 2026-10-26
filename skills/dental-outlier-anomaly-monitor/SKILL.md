---
name: dental-outlier-anomaly-monitor
description: Investigate unusual Dental claims, spend, denial, procedure or provider changes using comparable periods and freshness checks. Use for on-demand anomaly analysis; not causal attribution, fraud determination or scheduled monitoring.
---

# Dental Outlier and Anomaly Monitor

## Model integration

Use the semantic view's named counts, amounts and `DENIED_CLAIM_LINE_RATE` under identical date, status, population and attribution rules in both periods. For a rate change report percentage-point change and numerator/denominator counts, distinguishing it from relative percent change.

Compute relative change with a zero-safe denominator; a zero baseline makes percent change undefined, not zero or infinity. Without a specified comparison, use the two calendar months preceding the month containing the selected date basis's maximum, consistent with the semantic view's relative-period rule. Disclose the dates and avoid implying complete claims runout. If comparable history is absent, report that limitation rather than inventing a baseline. Rank only over the same observed universe and distinguish zero activity from missing/unretrieved data. Monitoring here is an on-demand analysis, not authorization to schedule jobs or send alerts.


## Purpose
Identify unusual shifts in TennCare Dental claims activity and distinguish likely data freshness issues from substantive changes in utilization, spend, denials, or mix.

## Use this skill when
Use this skill when the user asks:

- Did anything unusual happen in dental this month?
- Are there anomalies in dental claims?
- What changed the most?
- Which providers or procedure codes moved sharply?

## Required analyst behavior

- Use `DENTAL_CLAIMS_SV` for every factual result.
- Compare like with like:
  - same date basis
  - same status scope
  - same metric definition
- Quantify:
  - current value
  - comparison value
  - absolute change
  - percent change
- Check whether the latest period may be partial before interpreting a decline as real.

## Procedure

1. Determine the metric family:
   - claims
   - lines
   - utilizers
   - paid amount
   - denied lines / denied line rate
   - procedure mix
   - provider concentration
   - geography
2. Resolve period and comparison method:
   - month over month
   - trailing baseline
   - year over year if available/requested
3. Compute current versus comparison values.
4. Rank the largest movers by relevant dimension.
5. Check for alternative explanations:
   - partial month
   - enrichment unknown growth
   - service-versus-paid timing differences
6. Summarize the anomaly and likely interpretation boundaries.

## Guardrails

- Do not present anomalies as causal findings.
- Partial-month recency issues must be considered first.
- Unknown-category growth may reflect enrichment gaps rather than real business change.
- Use the correct claim/header versus line outcome rules for denial-related anomalies.

## Output requirements
Lead with the largest observed change:

- "The largest observed change was a X shift in [metric] in [period], concentrated in [dimension]."

Then include:

- current value
- comparison value
- absolute and percent change
- main drivers
- caveated interpretation

Always include a concise basis statement covering:

- date basis
- resolved period
- status scope
- metric definition
- comparison denominator where relevant

## Example prompts

- What changed the most in dental this month?
- Show dental anomalies by procedure code.
- Which providers had the largest shifts in spend?
- Is the latest decline real or just a partial month?
