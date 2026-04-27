# Splunk Searches

## Decision events
index=soc_cases source=ansible_ir_decision
| spath
| table incident_id actor_pack detected_src detected_dst detected_sig detected_mitre_technique suricata_hit_count zeek_hit_count decision_score ir_phase ir_escalate ir_containment_recommended

## Escalated cases
index=soc_cases source=ansible_ir_decision
| spath
| search ir_escalate=true
| stats count by actor_pack detected_mitre_technique ir_phase

## Case reports
index=soc_cases source=ansible_ir_case_report
| table _time host event.incident_id event.report
