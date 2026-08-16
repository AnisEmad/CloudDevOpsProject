#!/usr/bin/env bash
set -e
cd ansible && ansible-playbook cluster-teardown.yml       # release LBs first!
cd ../infrastructure_terraform && terraform destroy -auto-approve