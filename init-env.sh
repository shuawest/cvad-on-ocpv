#!/bin/sh

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo "Environment Guid: "
read GUID

echo "bastion password: "
read BASTION_PASS

# Log into the bastion host, and get the kubeadmin pass
OCP_USER="kubeadmin"
sshpass -p "$BASTION_PASS" ssh-copy-id -o StrictHostKeyChecking=no $GUID-user@provision.$GUID.dynamic.opentlc.com
OCP_PASS=`ssh -o StrictHostKeyChecking=no $GUID-user@provision.$GUID.dynamic.opentlc.com "sudo cat /home/lab-user/install/auth/kubeadmin-password"`

IP_ADDR=`dig +short console-openshift-console.apps.$GUID.dynamic.opentlc.com | grep -v '.com'`

cat <<EOT > $SCRIPT_DIR/env-$GUID.yaml
targetenv:
  guid: $GUID
  bastion_host: provision.$GUID.dynamic.opentlc.com
  bastion_user: $GUID-user
  bastion_pass: $BASTION_PASS
  ocp:
    cluster_ip: $IP_ADDR
    new_domain: $GUID.milabs.io
    new_console: https://console-openshift-console.apps.$GUID.milabs.io/
    base_domain: apps.$GUID.dynamic.opentlc.com
    console: https://console-openshift-console.apps.$GUID.dynamic.opentlc.com/
    api: "https://api.ocp.example.com:6443"
    user: $OCP_USER
    pass: $OCP_PASS 
EOT

cat <<EOT > $SCRIPT_DIR/bootstrap/inventories/hosts-$GUID.ini
[all]
client   ansible_connection=local

[bastion]
provision.$GUID.dynamic.opentlc.com
EOT


cat <<EOT > $SCRIPT_DIR/env-defaults.sh
#!/bin/sh

export GUID=$GUID
export BASTION_PASS=$BASTION_PASS
export BASTION_HOST=provision.$GUID.dynamic.opentlc.com
export BASTION_USER=$GUID-user
export KUBEADMIN_PASS=$OCP_PASS 
EOT

chmod a+x $SCRIPT_DIR/env-defaults.sh

$SCRIPT_DIR/ap.sh bootstrap/playbooks/bastion/test.yaml

$SCRIPT_DIR/ap.sh bootstrap/playbooks/bastion/prereqs.yaml

$SCRIPT_DIR/ap.sh bootstrap/playbooks/openshift/prereqs.yaml

$SCRIPT_DIR/ap.sh bootstrap/playbooks/openshift/facts.yaml



