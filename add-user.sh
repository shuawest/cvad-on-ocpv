#!/bin/sh

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

. $SCRIPT_DIR/env-defaults.sh

echo "new username: "
read NEW_USER

echo "new password: "
read NEW_PASS

cat <<EOT > $SCRIPT_DIR/remote-user.sh
oc get secret htpass-secret -ojsonpath={.data.htpasswd} -n openshift-config | base64 --decode > users.htpasswd
htpasswd -bB users.htpasswd $NEW_USER $NEW_PASS
oc create secret generic htpass-secret --from-file=htpasswd=users.htpasswd --dry-run=client -o yaml -n openshift-config | oc replace -f -
oc adm groups add-users argocdadmins $NEW_USER
EOT

chmod a+x $SCRIPT_DIR/remote-user.sh

echo 
echo "copy htpasswd script to bastion"
rsync -P $SCRIPT_DIR/remote-user.sh $BASTION_USER@$BASTION_HOST:~/remote-user.sh

echo 
echo "execute htpasswd script on bastion"
ssh $BASTION_USER@$BASTION_HOST "~/remote-user.sh"

echo 
echo "remove htpasswd script from bastion"
ssh $BASTION_USER@$BASTION_HOST "rm -f ~/remote-user.sh"

echo 
echo "remove remote-user.sh script locally"
rm $SCRIPT_DIR/remote-user.sh


