
# cvad-on-ocpv: Citrix Virtual Apps and Desktops on OpenShift Virtualization

This repository provides the ansible, OpenShift gitops manifests, and scripts to install
CVAD on OpenShift Virtualization hosted in Red Hat's demo environment. It uses a bare metal
deployed lab in demo.redhat.com as the foundation to automate the installation on top. 

Currently, Citrix Virtual Apps and Desktops does not have an adaptor to control [KubeVirt](https://kubevirt.io/)
orchestrated virtual machines. However, they can be registered into the CVAD storefront, or the
CVAD DaaS, for connectivity.
## Plan

[2022-11-20 CVAD on OCPV Planning](https://docs.google.com/spreadsheets/d/1T9I_tRmAmbyD7S0gRh7kUQk6fUrHv3431eaBkleWczA/edit#gid=0)


## Usage Instructions

There are three main phases (2-4) of installing CVAD on OpenShift Virtualization

1. Prerequisites
2. Bootstrap with Ansible
3. GitOps Sync
4. Citrix Install with Ansible for Windows on AAP 2
5. Verifying the installation

### 1. Prerequisites

Request the "" lab environment on [demo.redhat.com](https://demo.redhat.com). 
a. Go to [demo.redhat.com](https://demo.redhat.com)
b. Login using your RHT SSO, or partner credentials
c. Go to the catalog menu item, search for `virtualization` in the search box above the catalog tiles.
d. Select "Hands on With OpenShift Virtualization", then click "Order".
e. For Purpose, select "Development - Solution Prototyping", or another option that best fits your situation. 
f. Enter an SF Opportunity if this is for a customer demo or workshop. 
g. You do not need to select "Enable workshop user interface". 
h. Read the warnings, and check the box to confirm you understand. 
i. Click Order. 
j. You will be brought to a screen that shows you the environment details, which will you need to configure 
   the bootstrap in the next phase, which you are start to set up as soon as you have the details.
   Note that you should not try to execute the bootstrap until provisioning is complete.   
k. Adjust the auto-stop and auto-destroy to minimize costs, but provide the lab to your timeline and bandwidth. 
l. Once provisioning is complete, log into the console and verify OpenShift with the stated credentials during ordering. The default user has kubeadmin privileges. Log in via the htpassword option on the login screen.  

Wait for the provisioning of the environment to complete before executing the bootstrap, 
but you can start to configure the bootstrap as soon as you have the environment URIs for 
the console and API, plus the bastion host IP address and SSH password. 

This will provide with a full cluster of OpenShift 4.10.x
- SSL/TLS secured
- 100GB storage managed by ODF
- three bare metal worker nodes with 16 VPUs and 16G ram each
- Preallocated Persistent Volumes with 100GB disks targeted for use by virtualization
- multiple virtual network devices defined for bridged network attachment (10.20.0.x, 192.168.3.x, 172.22.0.x)
- [OpenShift Virt will not yet be installed]
  
It is recommended to upgrade the cluster to OpenShift 4.11.x which the automation was based on.   

### 2. Bootstrap with Ansible

Ansible executed from a local machine will be used to verify the cluster is accessible, has the required 
resources, and bootstrap the installation of the OpenShift GitOps and Ansible Automation Platform services. 

Fork the repository [https://github.com/shuawest/cvad-on-ocpv](https://github.com/shuawest/cvad-on-ocpv) on github.

Log into the bastion host noted on the ordered environment. Change the user and hostnames as applicable to your environment. 
Then install the necessary packages to use git and ansible from it.  
```
ssh wjcgz-user@provision.wjcgz.dynamic.opentlc.com

sudo dnf install -y git 
git --version

# Currently the bastion is using py 3.6 but needs 3.9 for ansible via rpm channels
#sudo subscription-manager repos --enable ansible-2.9-for-rhel-8-x86_64-rpms
#sudo yum install ansible

# So install ansible through pip 
python3 -m pip install --user ansible
ansible --version

# Git clone your forked repository from GitHub
git clone git@github.com:shuawest/cvad-on-ocpv.git
cd cvad-on-ocpv
```

If you forked the repository to a private repo, or plan push any updates then generate an SSH key, and [configure your github account to use that ssh key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account?tool=webui&platform=linux).
```
ssh-keygen              # take the defaults
cat ~/.ssh/id_rsa.pub   # copy this output to add to github
```   

Copy the environment secrets from the template, and add the environment specific variables:
```
pwd             # you should be in the .../cvad-on-ocpv/ directory

# Copy the template using the name 'environment-secrets.yaml',
# which is in .gitignore and the ansible secrets path configuration.
cp environment-secrets-template.yaml environment-secrets.yaml

# Edit the environment variables to match the demo.redhat.com environment details
vi environment-secrets.yaml         

# Secure the vault to protect the secrets, and take note the password you set.
ansible-vault create environment-secrets.yaml

# Verify you can access the secrets
ansible-vault view environment-secrets.yaml
```

Download the virtual machine ISOs, guest tools installers, and Citrix installers to the bastion host. 
```
# make this an ansible playbook, unless manual download steps are required
# - Windows Server 2019 (available for 180 day trial on MS website)
# - Windows 10 (available for trial installation)
# - Virtio guest tools image
# - Citrix CVAD installer
```

*Serve up the ISOs and install exes via nginx in a podman container to be accessed by the lab environment. 
Alternatively consider creating a File share in ODF with these images mountable by the target hosts. 
Otherwise, load and provide them directly in OCP-Virt*


 



