#!/bin/sh

if [ ! -d octavia ]; then
    git clone -b wallaby-eol https://opendev.org/openstack/octavia
fi

if [ ! -d ovn-octavia-provider ]; then
    git clone -b wallaby-eol https://opendev.org/openstack/ovn-octavia-provider
fi

. ./build.env
export CONTROLLER_HOST HM_IP CAFILE \
       RABBIT_PASSWORD DB_PASSWORD OCTAVIA_PASSWORD ADMIN_PASSWORD \
       AMP_IMAGE_OWNER_ID AMP_SECGROUP_LIST AMP_FLAVOR_ID AMP_BOOT_NETWORK_LIST

envsubst < etc/octavia.conf.template > etc/octavia.conf

PROJECT_DIR=$PWD
export PROJECT_DIR
envsubst '${PROJECT_DIR}' < octavia.yaml.template > octavia.yaml

podman build -t octavia:wallaby .
