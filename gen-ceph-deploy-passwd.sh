#!/bin/bash
#set -x 

read -s -p "Password:" password
hashed_pass=$(python -c "import crypt;print \"%s\" % crypt.crypt(\"$password\")")

# Use | for sed command since the hased password can have forward slashes
sed -i.bak "s|\(ceph_deploy_password:\).*|\1 \'$hashed_pass\'|" group_vars/all
echo 
