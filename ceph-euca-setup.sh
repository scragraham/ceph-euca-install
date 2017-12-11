#!/bin/bash

if ! $(ceph osd pool ls | grep -q euca); then
    echo "Generating volume and snapshot pools"
    ceph osd pool create eucavolumes 64
    ceph osd pool create eucasnapshots 64
fi

if [ ! -e euca-artifacts ]; then
    echo "Generating block storage keyring (rdb)"
    mkdir euca-artifacts
fi

if ! $(ceph auth list 2>&1 | grep -q euca); then
    echo "Generating S3 user for radosgw"
    ceph auth get-or-create client.eucalyptus mon 'allow r' osd 'allow rwx pool=rbd, allow rwx pool=eucasnapshots, allow rwx pool=eucavolumes, allow x' -o euca-artifacts/ceph.client.eucalyptus.keyring
fi

if ! $(radosgw-admin metadata list user | grep -q euca); then
    echo "Generating radowsgw (rgw) S3 user"
    radosgw-admin user create --uid=eucas3 --display-name="Eucalyptus S3 User" | egrep '(user"|access_key|secret_key)' > euca-artifacts/rgw_credentials.txt
fi

echo "Copying ceph.conf file"
cp /etc/ceph/ceph.conf euca-artifacts/ceph.conf
