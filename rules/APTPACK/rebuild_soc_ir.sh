#!/usr/bin/env bash
set -euo pipefail

mkdir -p \
  inventory \
  group_vars \
  playbooks \
  roles/suricata_collect/tasks \
  roles/suricata_collect/templates \
  roles/wazuh_collect/tasks \
  roles/splunk_collect/tasks \
  roles/host_triage/tasks \
  roles/decision_engine/tasks \
  roles/firewall_block/tasks \
  roles/report_case/tasks \
  artifacts

cat > inventory/hosts.yml <<'YAML'
all:
  hosts:
    soc-admin:
      ansible_connection: local
      ansible_user: soc-admin

    ids-management:
      ansible_host: 192.168.20.148
      ansible_user: ids-management

    splunk:
      ansible_host: 192.168.122.181
      ansible_user: splunk
YAML

cat > group_vars/all.yml <<'YAML'
incident_id: "IR-{{ lookup('pipe', 'date +%Y%m%d-%H%M%S') }}"
case_artifact_root: "/home/soc-admin/soc-ir-automation/artifacts"
case_artifact_dir: "{{ case_artifact_root }}/{{ incident_id }}"

suricata_eve_path: "/var/log/suricata/eve.json"
suricata_fast_path: "/var/log/suricata/fast.log"

wazuh_agent_log: "/var/ossec/logs/ossec.log"
wazuh_agent_conf: "/var/ossec/etc/ossec.conf"

splunk_api_scheme: "https"
splunk_api_host: "127.0.0.1"
splunk_api_port: 8089
splunk_index: "main"
splunk_user: "admin"
splunk_password: "Kill9114319"

pipeline_test_string: "GPL ATTACK_RESPONSE id check returned root"
pipeline_test_sid: "2100498"

containment_enabled: false
containment_block_target: ""
firewall_block_comment: "SOC IR automated containment"

report_owner: "soc-admin"
report_group: "soc-admin"
YAML

cat > playbooks/ir_suricata_alert.yml <<'YAML'
---
- name: End-to-end IR workflow for Suricata alert
  hosts: soc-admin
  gather_facts: false
  vars:
    target_host: "ids-management"
  tasks:
    - name: Ensure case artifact directory exists
      ansible.builtin.file:
        path: "{{ case_artifact_dir }}"
        state: directory
        mode: "0750"

    - name: Collect Suricata evidence
      ansible.builtin.include_role:
        name: suricata_collect
      vars:
        collect_host: "{{ target_host }}"

    - name: Collect Wazuh evidence
      ansible.builtin.include_role:
        name: wazuh_collect
      vars:
        collect_host: "{{ target_host }}"

    - name: Collect Splunk evidence
      ansible.builtin.include_role:
        name: splunk_collect

    - name: Perform host triage
      ansible.builtin.include_role:
        name: host_triage
      vars:
        collect_host: "{{ target_host }}"

    - name: Run decision engine
      ansible.builtin.include_role:
        name: decision_engine

    - name: Render case report
      ansible.builtin.include_role:
        name: report_case
YAML

cat > playbooks/triage_collect.yml <<'YAML'
---
- name: Triage collection only
  hosts: soc-admin
  gather_facts: false
  vars:
    target_host: "ids-management"
  tasks:
    - name: Ensure case artifact directory exists
      ansible.builtin.file:
        path: "{{ case_artifact_dir }}"
        state: directory
        mode: "0750"

    - name: Collect Suricata evidence
      ansible.builtin.include_role:
        name: suricata_collect
      vars:
        collect_host: "{{ target_host }}"

    - name: Collect Wazuh evidence
      ansible.builtin.include_role:
        name: wazuh_collect
      vars:
        collect_host: "{{ target_host }}"

    - name: Collect Splunk evidence
      ansible.builtin.include_role:
        name: splunk_collect

    - name: Perform host triage
      ansible.builtin.include_role:
        name: host_triage
      vars:
        collect_host: "{{ target_host }}"
YAML

cat > playbooks/containment_block_src.yml <<'YAML'
---
- name: Containment block of source IP
  hosts: soc-admin
  gather_facts: false
  tasks:
    - name: Fail if containment target is not set
      ansible.builtin.fail:
        msg: "Set containment_block_target, for example: -e containment_block_target=217.160.0.187"
      when: containment_block_target | length == 0

    - name: Run firewall block role
      ansible.builtin.include_role:
        name: firewall_block
YAML

cat > playbooks/validate_pipeline.yml <<'YAML'
---
- name: Validate full SOC pipeline
  hosts: soc-admin
  gather_facts: false
  vars:
    target_host: "ids-management"
  tasks:
    - name: Ensure validation artifact directory exists
      ansible.builtin.file:
        path: "{{ case_artifact_dir }}"
        state: directory
        mode: "0750"

    - name: Validate Suricata local alert presence
      ansible.builtin.shell: |
        grep -F "{{ pipeline_test_string }}" {{ suricata_eve_path }} | tail -n 10
      args:
        executable: /bin/bash
      delegate_to: "{{ target_host }}"
      register: validate_suricata
      changed_when: false

    - name: Save Suricata validation
      ansible.builtin.copy:
        dest: "{{ case_artifact_dir }}/validate_suricata.txt"
        content: "{{ validate_suricata.stdout | default('') }}"

    - name: Validate Wazuh collection status
      ansible.builtin.shell: |
        systemctl status wazuh-agent --no-pager -l
        echo '---'
        grep -R "eve.json\|suricata" /var/ossec/etc /var/ossec/etc/shared 2>/dev/null
      args:
        executable: /bin/bash
      delegate_to: "{{ target_host }}"
      register: validate_wazuh
      changed_when: false

    - name: Save Wazuh validation
      ansible.builtin.copy:
        dest: "{{ case_artifact_dir }}/validate_wazuh.txt"
        content: "{{ validate_wazuh.stdout | default('') }}"

    - name: Validate Splunk indexed evidence
      ansible.builtin.shell: |
        curl -k -u {{ splunk_user | quote }}:{{ splunk_password | quote }} \
          https://{{ splunk_api_host }}:{{ splunk_api_port }}/services/search/jobs/export \
          -d search='search index={{ splunk_index }} sourcetype=suricata:json "{{ pipeline_test_string }}" | spath | eval sig_id=mvindex('\''alert.signature_id'\'',0), sig=mvindex('\''alert.signature'\'',0), src=mvindex(src_ip,0), dst=mvindex(dest_ip,0) | table _time host source src dst sig_id sig' \
          -d output_mode=json
      args:
        executable: /bin/bash
      delegate_to: splunk
      register: validate_splunk
      changed_when: false

    - name: Save Splunk validation
      ansible.builtin.copy:
        dest: "{{ case_artifact_dir }}/validate_splunk.json"
        content: "{{ validate_splunk.stdout | default('') }}"
YAML

cat > playbooks/close_case.yml <<'YAML'
---
- name: Close IR case
  hosts: soc-admin
  gather_facts: false
  tasks:
    - name: Ensure case artifact directory exists
      ansible.builtin.file:
        path: "{{ case_artifact_dir }}"
        state: directory
        mode: "0750"

    - name: Build final case closure note
      ansible.builtin.copy:
        dest: "{{ case_artifact_dir }}/closure.txt"
        mode: "0640"
        content: |
          Incident ID: {{ incident_id }}
          Status: Closed
          Closed At: {{ lookup('pipe', 'date --iso-8601=seconds') }}
          Summary:
          - Suricata detection observed
          - Wazuh ingestion validated
          - Splunk indexing validated
          - Case artifacts retained under {{ case_artifact_dir }}

    - name: Render final case report
      ansible.builtin.include_role:
        name: report_case
YAML

cat > roles/suricata_collect/tasks/main.yml <<'YAML'
---
- name: Collect recent Suricata alerts from eve.json
  ansible.builtin.shell: |
    grep '"event_type":"alert"' {{ suricata_eve_path }} | tail -n 20
  args:
    executable: /bin/bash
  delegate_to: "{{ collect_host }}"
  register: suricata_eve_recent
  changed_when: false

- name: Collect matching pipeline test alerts from eve.json
  ansible.builtin.shell: |
    grep -F "{{ pipeline_test_string }}" {{ suricata_eve_path }} | tail -n 20
  args:
    executable: /bin/bash
  delegate_to: "{{ collect_host }}"
  register: suricata_pipeline_hits
  changed_when: false

- name: Collect Suricata fast log tail if present
  ansible.builtin.shell: |
    test -f {{ suricata_fast_path }} && tail -n 50 {{ suricata_fast_path }} || true
  args:
    executable: /bin/bash
  delegate_to: "{{ collect_host }}"
  register: suricata_fast_recent
  changed_when: false

- name: Save recent eve alerts
  ansible.builtin.copy:
    dest: "{{ case_artifact_dir }}/suricata_eve_recent.log"
    mode: "0640"
    content: "{{ suricata_eve_recent.stdout | default('') }}"

- name: Save matching Suricata pipeline hits
  ansible.builtin.copy:
    dest: "{{ case_artifact_dir }}/suricata_pipeline_hits.log"
    mode: "0640"
    content: "{{ suricata_pipeline_hits.stdout | default('') }}"

- name: Save Suricata fast log tail
  ansible.builtin.copy:
    dest: "{{ case_artifact_dir }}/suricata_fast_recent.log"
    mode: "0640"
    content: "{{ suricata_fast_recent.stdout | default('') }}"
YAML

cat > roles/suricata_collect/templates/case_summary.j2 <<'J2'
Incident ID: {{ incident_id }}
Case directory: {{ case_artifact_dir }}

Summary
=======
Source IP: {{ detected_src | default('unknown') }}
Destination IP: {{ detected_dst | default('unknown') }}
Signature ID: {{ detected_sig_id | default('unknown') }}
Signature: {{ detected_sig | default('unknown') }}
Category: {{ detected_category | default('unknown') }}
Severity: {{ detected_severity | default('unknown') }}

Decision
========
Escalation: {{ ir_escalate | default(false) }}
Containment recommended: {{ ir_containment_recommended | default(false) }}

Artifacts
=========
- suricata_eve_recent.log
- suricata_pipeline_hits.log
- wazuh_agent_status.txt
- wazuh_ossec_log_tail.txt
- splunk_suricata_hits.json
- host_triage.txt
J2

cat > roles/wazuh_collect/tasks/main.yml <<'YAML'
---
- name: Collect Wazuh agent status
  ansible.builtin.shell: |
    systemctl status wazuh-agent --no-pager -l
  args:
    executable: /bin/bash
  delegate_to: "{{ collect_host }}"
  register: wazuh_agent_status
  changed_when: false

- name: Collect Wazuh ossec.conf Suricata references
  ansible.builtin.shell: |
    grep -R "suricata\|eve.json" /var/ossec/etc /var/ossec/etc/shared 2>/dev/null
  args:
    executable: /bin/bash
  delegate_to: "{{ collect_host }}"
  register: wazuh_suricata_conf
  changed_when: false

- name: Collect Wazuh ossec.log tail
  ansible.builtin.shell: |
    tail -n 100 {{ wazuh_agent_log }}
  args:
    executable: /bin/bash
  delegate_to: "{{ collect_host }}"
  register: wazuh_log_tail
  changed_when: false

- name: Save Wazuh agent status
  ansible.builtin.copy:
    dest: "{{ case_artifact_dir }}/wazuh_agent_status.txt"
    mode: "0640"
    content: "{{ wazuh_agent_status.stdout | default('') }}"

- name: Save Wazuh Suricata config references
  ansible.builtin.copy:
    dest: "{{ case_artifact_dir }}/wazuh_suricata_conf.txt"
    mode: "0640"
    content: "{{ wazuh_suricata_conf.stdout | default('') }}"

- name: Save Wazuh log tail
  ansible.builtin.copy:
    dest: "{{ case_artifact_dir }}/wazuh_ossec_log_tail.txt"
    mode: "0640"
    content: "{{ wazuh_log_tail.stdout | default('') }}"
YAML

cat > roles/splunk_collect/tasks/main.yml <<'YAML'
---
- name: Query Splunk for Suricata alert hits
  ansible.builtin.shell: |
    curl -k -u {{ splunk_user | quote }}:{{ splunk_password | quote }} \
      https://{{ splunk_api_host }}:{{ splunk_api_port }}/services/search/jobs/export \
      -d search='search index={{ splunk_index }} sourcetype=suricata:json "{{ pipeline_test_string }}" | spath | eval sig_id=mvindex('\''alert.signature_id'\'',0), sig=mvindex('\''alert.signature'\'',0), category=mvindex('\''alert.category'\'',0), severity=mvindex('\''alert.severity'\'',0), src=mvindex(src_ip,0), dst=mvindex(dest_ip,0) | table _time host source src dst sig_id sig category severity' \
      -d output_mode=json
  args:
    executable: /bin/bash
  delegate_to: splunk
  register: splunk_suricata_hits
  changed_when: false

- name: Query Splunk host activity for ids-management
  ansible.builtin.shell: |
    curl -k -u {{ splunk_user | quote }}:{{ splunk_password | quote }} \
      https://{{ splunk_api_host }}:{{ splunk_api_port }}/services/search/jobs/export \
      -d search='search index={{ splunk_index }} host=ids-management earliest=-60m latest=now | head 100' \
      -d output_mode=json
  args:
    executable: /bin/bash
  delegate_to: splunk
  register: splunk_host_recent
  changed_when: false

- name: Save Splunk Suricata hits
  ansible.builtin.copy:
    dest: "{{ case_artifact_dir }}/splunk_suricata_hits.json"
    mode: "0640"
    content: "{{ splunk_suricata_hits.stdout | default('') }}"

- name: Save Splunk recent host activity
  ansible.builtin.copy:
    dest: "{{ case_artifact_dir }}/splunk_host_recent.json"
    mode: "0640"
    content: "{{ splunk_host_recent.stdout | default('') }}"
YAML

cat > roles/host_triage/tasks/main.yml <<'YAML'
---
- name: Collect host triage bundle
  ansible.builtin.shell: |
    echo "=== hostname ==="
    hostname
    echo "=== ip addr ==="
    ip addr
    echo "=== routes ==="
    ip route
    echo "=== listening sockets ==="
    ss -tulpn
    echo "=== last logins ==="
    last -n 20
    echo "=== recent auth log ==="
    tail -n 50 /var/log/auth.log
    echo "=== recent Suricata alerts ==="
    grep '"event_type":"alert"' {{ suricata_eve_path }} | tail -n 20
  args:
    executable: /bin/bash
  delegate_to: "{{ collect_host }}"
  register: host_triage_bundle
  changed_when: false

- name: Save host triage bundle
  ansible.builtin.copy:
    dest: "{{ case_artifact_dir }}/host_triage.txt"
    mode: "0640"
    content: "{{ host_triage_bundle.stdout | default('') }}"
YAML

cat > roles/decision_engine/tasks/main.yml <<'YAML'
---
- name: Read Suricata pipeline hits
  ansible.builtin.slurp:
    src: "{{ case_artifact_dir }}/suricata_pipeline_hits.log"
  register: decision_suricata_hits

- name: Set default incident facts
  ansible.builtin.set_fact:
    detected_src: "unknown"
    detected_dst: "unknown"
    detected_sig_id: "unknown"
    detected_sig: "unknown"
    detected_category: "unknown"
    detected_severity: "unknown"
    ir_escalate: false
    ir_containment_recommended: false

- name: Parse first matching Suricata hit
  ansible.builtin.set_fact:
    parsed_suricata_hit: "{{ (decision_suricata_hits.content | b64decode).splitlines()[-1] | from_json }}"
  when: (decision_suricata_hits.content | b64decode | trim | length) > 0

- name: Set detection facts from parsed event
  ansible.builtin.set_fact:
    detected_src: "{{ parsed_suricata_hit.src_ip }}"
    detected_dst: "{{ parsed_suricata_hit.dest_ip }}"
    detected_sig_id: "{{ parsed_suricata_hit.alert.signature_id }}"
    detected_sig: "{{ parsed_suricata_hit.alert.signature }}"
    detected_category: "{{ parsed_suricata_hit.alert.category }}"
    detected_severity: "{{ parsed_suricata_hit.alert.severity }}"
    ir_escalate: true
    ir_containment_recommended: true
  when: parsed_suricata_hit is defined

- name: Write decision output
  ansible.builtin.copy:
    dest: "{{ case_artifact_dir }}/decision.json"
    mode: "0640"
    content: |
      {
        "incident_id": "{{ incident_id }}",
        "detected_src": "{{ detected_src }}",
        "detected_dst": "{{ detected_dst }}",
        "detected_sig_id": "{{ detected_sig_id }}",
        "detected_sig": "{{ detected_sig }}",
        "detected_category": "{{ detected_category }}",
        "detected_severity": "{{ detected_severity }}",
        "ir_escalate": {{ ir_escalate | lower }},
        "ir_containment_recommended": {{ ir_containment_recommended | lower }}
      }
YAML

cat > roles/firewall_block/tasks/main.yml <<'YAML'
---
- name: Fail if block target missing
  ansible.builtin.fail:
    msg: "containment_block_target must be set"
  when: containment_block_target | length == 0

- name: Apply temporary ufw deny rule on ids-management
  ansible.builtin.shell: |
    ufw status numbered
    ufw deny from {{ containment_block_target }} comment "{{ firewall_block_comment }}"
    ufw status numbered
  args:
    executable: /bin/bash
  delegate_to: ids-management
  become: true
  register: ufw_block_result
  changed_when: true

- name: Save containment action log
  ansible.builtin.copy:
    dest: "{{ case_artifact_dir }}/containment_block.txt"
    mode: "0640"
    content: "{{ ufw_block_result.stdout | default('') }}"
YAML

cat > roles/report_case/tasks/main.yml <<'YAML'
---
- name: Render case summary report
  ansible.builtin.template:
    src: "roles/suricata_collect/templates/case_summary.j2"
    dest: "{{ case_artifact_dir }}/case_summary.txt"
    mode: "0640"

- name: Write markdown case report
  ansible.builtin.copy:
    dest: "{{ case_artifact_dir }}/case_report.md"
    mode: "0640"
    content: |
      # Incident Case Report

      **Incident ID:** {{ incident_id }}

      ## Detection
      - Source IP: {{ detected_src | default('unknown') }}
      - Destination IP: {{ detected_dst | default('unknown') }}
      - Signature ID: {{ detected_sig_id | default('unknown') }}
      - Signature: {{ detected_sig | default('unknown') }}
      - Category: {{ detected_category | default('unknown') }}
      - Severity: {{ detected_severity | default('unknown') }}

      ## Decision
      - Escalate: {{ ir_escalate | default(false) }}
      - Containment Recommended: {{ ir_containment_recommended | default(false) }}

      ## Evidence Files
      - `suricata_eve_recent.log`
      - `suricata_pipeline_hits.log`
      - `wazuh_agent_status.txt`
      - `wazuh_suricata_conf.txt`
      - `wazuh_ossec_log_tail.txt`
      - `splunk_suricata_hits.json`
      - `splunk_host_recent.json`
      - `host_triage.txt`
      - `decision.json`
YAML

echo "Build complete."
find . -maxdepth 4 -type f | sort
