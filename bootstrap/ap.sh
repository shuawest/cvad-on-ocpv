#!/bin/sh

# ENV_GUID=2pqmt

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

. $SCRIPT_DIR/../env-defaults.sh

echo "ansible-playbook -i inventories/hosts-${ENV_GUID}.ini --extra-vars \"secrets_file=${SCRIPT_DIR}/../env-${ENV_GUID}.yaml\" $@"

ansible-playbook -i inventories/hosts-${ENV_GUID}.ini --extra-vars "secrets_file=${SCRIPT_DIR}/../env-${ENV_GUID}.yaml" $@

