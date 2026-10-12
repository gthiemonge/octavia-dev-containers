#!/bin/sh
# Generate build.env by querying the running OpenStack environment.
# Source your credentials before running: source /opt/stack/openrc admin admin

set -e

: "${OS_AUTH_URL:?OS_AUTH_URL not set — source your openrc first}"

# Derive controller host from OS_AUTH_URL (strip scheme, path and port)
CONTROLLER_HOST=$(echo "${OS_AUTH_URL}" | sed 's|https\?://||; s|[:/].*||')

# HM_IP is the IP octavia's health manager binds to (lb-mgmt network interface).
# Override via environment if it differs from CONTROLLER_HOST.
HM_IP=${HM_IP:-${CONTROLLER_HOST}}

CAFILE=/opt/stack/data/ca-bundle.pem

# Read a value from devstack's local.conf, ignoring variable-expanded lines.
LOCALRC=/opt/stack/local.conf
read_localrc() {
    [ -f "${LOCALRC}" ] && awk -F= "/^${1}=[^\$]/{print \$2; exit}" "${LOCALRC}"
}

RABBIT_PASSWORD=${RABBIT_PASSWORD:-$(read_localrc RABBIT_PASSWORD)}
RABBIT_PASSWORD=${RABBIT_PASSWORD:-password}

DB_PASSWORD=${DB_PASSWORD:-$(read_localrc DATABASE_PASSWORD)}
DB_PASSWORD=${DB_PASSWORD:-password}

OCTAVIA_PASSWORD=${OCTAVIA_PASSWORD:-$(read_localrc OCTAVIA_PASSWORD)}
OCTAVIA_PASSWORD=${OCTAVIA_PASSWORD:-password}

ADMIN_PASSWORD=${ADMIN_PASSWORD:-$(read_localrc ADMIN_PASSWORD)}
ADMIN_PASSWORD=${ADMIN_PASSWORD:-password}

# Query OpenStack for resource IDs
AMP_IMAGE_OWNER_ID=$(openstack project show service -f value -c id)
AMP_SECGROUP_LIST=$(openstack security group show lb-mgmt-sec-grp -f value -c id)
AMP_FLAVOR_ID=$(openstack flavor show amphora -f value -c id)
AMP_BOOT_NETWORK_LIST=$(openstack network show lb-mgmt-net -f value -c id)

cat > build.env <<EOF
CONTROLLER_HOST=${CONTROLLER_HOST}
HM_IP=${HM_IP}
CAFILE=${CAFILE}

RABBIT_PASSWORD=${RABBIT_PASSWORD}
DB_PASSWORD=${DB_PASSWORD}
OCTAVIA_PASSWORD=${OCTAVIA_PASSWORD}
ADMIN_PASSWORD=${ADMIN_PASSWORD}

AMP_IMAGE_OWNER_ID=${AMP_IMAGE_OWNER_ID}
AMP_SECGROUP_LIST=${AMP_SECGROUP_LIST}
AMP_FLAVOR_ID=${AMP_FLAVOR_ID}
AMP_BOOT_NETWORK_LIST=${AMP_BOOT_NETWORK_LIST}
EOF

echo "build.env written."
