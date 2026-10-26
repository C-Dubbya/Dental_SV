# TennCare Dental claims

Standalone `Dental_SV` repository for the TennCare Dental semantic view, agent, skills and validation evidence. Development starts on `main`; this repository has independent Git history.

## Model and review materials

- [Semantic view](ddl/DENTAL_CLAIMS_SV.sql): final, non-void Dental claim lines on paid or denied claim headers, with separate detail-line outcomes, financial measures, procedure descriptions, provider roles and member context.
- [Agent](ddl/DENTAL_CLAIMS_AGENT.sql): Dental analysis instructions and Cortex Analyst tool configuration.
- [Model scope and evidence](dental/README.md): supported capabilities, source findings and remaining business decisions.
- [Validation handoff](dental/validation/README.md): compilation steps and five source-versus-semantic smoke tests.
- [Agent evaluation cases](dental/evaluations/dental_agent_eval_ui.csv): 32 UI-ready behavioral acceptance cases, including domain-specific skill guardrails.
- [Discovery evidence](dental/discovery/README.md): source exports, collection SQL and findings, including [PMPM coverage results](dental/discovery/pmpm_hypothesis_findings.md).

Source diagnostics have been reviewed. The user confirmed completion and PASS of the semantic smoke suite on 2026-10-26. This is a user-reported execution result; per-check output files have not been supplied here. Agent acceptance and staged-skill loading remain separate, unconfirmed checks.

## Skills and attachments

The `skills/` directory is the controlled authoring copy of thirteen Dental workflows. The [agent DDL](ddl/DENTAL_CLAIMS_AGENT.sql) selects relevant skills from staged folders; measures, joins and data definitions remain owned by `DENTAL_CLAIMS_SV`. Skills shape Analyst requests and never supply factual results.

| Skill | Use |
| --- | --- |
| [dental-anatomy-service-units](skills/dental-anatomy-service-units/SKILL.md) | Recorded teeth/surfaces, non-multiplying attribution and compatible service units. |
| [dental-financial-analysis](skills/dental-financial-analysis/SKILL.md) | Separate source amounts, descriptive financial comparisons and spend drivers. |
| [dental-longitudinal-service-patterns](skills/dental-longitudinal-service-patterns/SKILL.md) | Observed member/member-tooth sequences, repeat intervals and follow-up windows. |
| [dental-data-freshness-monitor](skills/dental-data-freshness-monitor/SKILL.md) | Latest dates, partial reporting periods and recency context. |
| [monthly-dental-kpi-pack](skills/monthly-dental-kpi-pack/SKILL.md) | Monthly claims, lines, utilizers, spend and ratios. |
| [dental-denial-drilldown](skills/dental-denial-drilldown/SKILL.md) | Claim-header versus detail-line denials and rate denominators. |
| [procedure-code-explorer](skills/procedure-code-explorer/SKILL.md) | Exact-code activity, care settings, supplied sedation lists, service-family and code-edition governance. |
| [provider-utilization-performance](skills/provider-utilization-performance/SKILL.md) | Billing versus recorded rendering provider analysis. |
| [plan-attribution-enrichment-qa](skills/plan-attribution-enrichment-qa/SKILL.md) | Claim-plan/operative assignment roles, unknowns and reconciliation. |
| [geographic-dental-access-proxy](skills/geographic-dental-access-proxy/SKILL.md) | Residence, service and provider-location geography. |
| [dental-outlier-anomaly-monitor](skills/dental-outlier-anomaly-monitor/SKILL.md) | Comparable-period changes, movers and anomaly caveats. |
| [dental-cohort-slice-builder](skills/dental-cohort-slice-builder/SKILL.md) | Exact age and supported member/profile subgroup slices. |
| [executive-to-analyst-dental-translator](skills/executive-to-analyst-dental-translator/SKILL.md) | Resolve broad questions into an explicit Analyst request. |

The DDL uses the existing stage-path convention `@TRN__TN_DE.AGENTS.SKILLS_INT_STG/<skill-name>`. Upload each complete skill folder, preserving `<skill-name>/SKILL.md` and supporting `references/` subfolders, before compiling the agent. Stage existence, access and file availability have not been verified here; no upload or deployment was performed. These are on-demand workflows, not scheduled monitors.

## Backlog

### Validation and release readiness

- [x] Complete semantic-view smoke testing: user reported PASS on 2026-10-26 for the five-check suite, including source reconciliation and unknown-preserving enrichment.
- [ ] Upload/revalidate the thirteen skill folders and updated agent routing, then execute/review the 32 agent evaluation cases. Semantic smoke PASS does not establish agent or new-workflow acceptance; the underlying semantic query logic is unchanged by the skill additions.
- [ ] Investigate paid dates preceding service dates; preserve source dates and records until the cause is established.

### Business definitions needed

- [ ] Confirm the claim-plan code namespace and dental administrator/DBM attribution, including effective-dated identifiers across administrator changes. Compare source/match coverage before and after a documented transition; do not assign administrators from dates alone or substitute operative assignments for unmatched claim plans.
- [ ] Obtain approved, effective-dated service-family lists for diagnostic, preventive, restorative, endodontic, periodontal, prosthodontic, oral surgery, orthodontic and adjunctive activity. Record ownership, code edition, purpose, exclusions and category overlap; test unmapped coverage and mapping fanout. Source descriptions, broad CCS labels and benefit coverage lists are not interchangeable clinical or official-measure crosswalks.
- [ ] Obtain authorized historical CDT editions/change mappings and approved sedation/anesthesia lists when those questions are required. Validate code applicability by procedure service date and retain unverified/unmapped codes; do not infer validity or clinical administration from source labels.
- [ ] Agree compatible quantity units and anatomy requirements by procedure code before interpreting unit-rate comparisons or recorded-anatomy completeness as quality checks.

### Deferred — additional evidence or expanded scope

- [ ] Denial recovery, appeals and resubmission outcomes: require submission/adjustment lineage, reason codes, remittance history and event dates. Current final-version header/detail outcomes cannot establish a denial-to-payment lifecycle; obtain those sources before building recovery metrics.
- [ ] Authorization and benefit-frequency-limit compliance: require effective-dated plan rules, authorization decisions, dental entitlement history and sufficient prior-service history. First document the client rule and reporting period; repeat claims alone do not prove a violation.
- [ ] Contracted-fee compliance, coordination of benefits and other-payer/member liability: require applicable contracts/fee schedules, payer sequencing, other-payer amounts and adjustments. Current billed/allowed/paid/copay differences support descriptive analysis only; profile and expose validated supplemental sources before claiming underpayment, savings or liability.
- [ ] Network adequacy and unmet need: require an eligible-population denominator, participating-provider roster, individual/provider-location identity, participation dates and suitable capacity/geographic evidence. Current claims activity and county patterns remain utilization proxies, not evidence of appointment access or available network capacity.
- [ ] Official EPSDT/CMS-416, Core Set or other quality measures: require the requested reporting-year specification, eligibility including non-utilizers, continuous-coverage rules, age/calendar anchors and approved service/provider mappings. Validate any required oral-health services outside the Dental category in a separately authorized scope; do not relabel a claims-utilizer proxy as an official measure.
- [ ] Completed treatment, visits and clinical outcomes: obtain explicit episode/visit definitions and, where needed, clinical records or linked medical/facility evidence. Observed procedure sequences are supported now but do not prove completion, success, treatment failure or avoidable emergency care. Cross-domain outcome work is not part of the current Dental-only model.

### Requirement-driven enhancements

- [ ] Promote supplied/approved service crosswalks and the new domain workflows into executed, reviewed verified-query examples after agent evaluation. Skill definitions and expected evaluation behavior are not verification results.
