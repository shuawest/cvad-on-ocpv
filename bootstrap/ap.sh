#!/bin/sh

ENV_GUID=khgqr

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo "ansible-playbook -i inventories/hosts-${ENV_GUID}.ini --extra-vars \"secrets_file=${SCRIPT_DIR}/../env-${ENV_GUID}.yaml\" $@"

ansible-playbook -i inventories/hosts-${ENV_GUID}.ini --extra-vars "secrets_file=${SCRIPT_DIR}/../env-${ENV_GUID}.yaml" $@

