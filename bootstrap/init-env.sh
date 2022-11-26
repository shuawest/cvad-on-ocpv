#!/bin/sh

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo "Environment Guid: "
read GUID

echo "bastion password: "
read BASTION_PASS

IP_ADDR=`dig +short console-openshift-console.apps.$GUID.dynamic.opentlc.com | grep -v '.com'`

cat <<EOT > $SCRIPT_DIR/../env-$GUID.yaml
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
    user: developer
    pass: r3dh4t1! 
EOT

cat <<EOT > $SCRIPT_DIR/inventories/hosts-$GUID.ini
[all]
client   ansible_connection=local

[bastion]
provision.$GUID.dynamic.opentlc.com
EOT


cat <<EOT > $SCRIPT_DIR/../env-defaults.sh
#!/bin/sh

export ENV_GUID=$GUID
EOT
chmod a+x $SCRIPT_DIR/../env-defaults.sh

pushd $SCRIPT_DIR

./ap.sh playbooks/bastion/test.yaml

./ap.sh playbooks/bastion/prereqs.yaml

./ap.sh playbooks/openshift/prereqs.yaml

./ap.sh playbooks/openshift/facts.yaml

popd


