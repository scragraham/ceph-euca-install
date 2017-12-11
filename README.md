# Eucalyptus Ceph Installation

These set of playbooks mimic the steps that are outlined at http://docs.ceph.com/docs/master/start/quick-ceph-deploy/

Because of the need to install Hammer and some quirks, these playbooks are a *quick and dirty* way to deploy a ceph cluster. Tested with hammer and jewel.

If use of jewel and luminous are desired, it is advised to utilize ceph-ansible from Ceph. 

## Install

### Overview
The ceph-install playbook goes through the installation process outlined in the ceph documentation.
The minimal install requires 3 nodes. In these playbooks the admin node is the same as the initial mon node and 
has only been tested that way.

### Get the playbooks/scripts
git clone https://github.com/scragraham/ceph-euca-install

### Prerequisites
Ansible must be installed, with the following groups populated:

```
[cephadmin] # one host
[cephosds]
[cephmoninitial] # one hosts, the same as cephadmin if desired.
[cephmonremaining]
```

The cephall and cephmons groups don't need to be modified.
```
[cephmons:children]
cephmoninitial
cephmonremaining

[cephall:children]
cephosds
cephmons
```

An example inventory file with 3 nodes, 3 mons, 3 osds:
```
[cephadmin]
ceph1

[cephosds]
ceph1
ceph2
ceph3

[cephmoninitial]
ceph1

[cephmonremaining]
ceph2
ceph3

[cephmons:children]
cephmoninitial
cephmonremaining

[cephall:children]
cephosds
cephmons
```

### Examine group_vars/*

Examine the files in group_vars to see if you need to modify anything. 
Of note would be the public_network setting in group_vars/cephadmin. If you
do not set this to the CIDR of your public network interface ceph-deploy will fail 
when starting certain services.

Modification of ceph_release should be done via the command line

### Run the playbooks

First generate the ceph-deploy hashed password:
This script will set the ceph deploy hashed password in group_vars/all
```
# ./gen-ceph-deploy-password.sh
```

To install the Ceph Cluster:
```
# ansible-playbook ceph-install.yml
```

To install 'hammer' instead of Jewel (default) run the following instead:
```
# ansible-playbook ceph-install.yml -e "ceph_release=hammer"
```

### Configure Ceph for eucalyptus

To configure ceph artifacts for eucalyptus use:
```
# ./ceph-euca-setup.sh
```

Artifacts will be in the directory: euca-artifacts 
 * ceph.client.eucalyptus.keyring 
 * ceph.conf
 * rgw_credentials.txt

## Tearing down the cluster (really)

This playbook will nuke the cluster. To the ground. There is no coming back from this:
```
# ansible-playbook ceph-nuke.yml
```

The ceph-nuke playbook will ask for confirmation to proceed, hit Enter to continue. Ctrl-C 'a' to exit.
