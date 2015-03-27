#!/bin/bash


#
INSTALL_DIR=/opt/devstack
LOCAL_CONF=${INSTALL_DIR}/local.conf
USER=ubuntu

# System prep
apt-get install -y git screen vim apache2 memcached

sed -i 's/80/0.0.0.0:80/' /etc/apache2/ports.conf

mkdir ${INSTALL_DIR}
chown ${USER} ${INSTALL_DIR}

# get devstack
su -l ${USER} -c 'git clone https://github.com/openstack-dev/devstack.git -b stable/juno /opt/devstack'

# Write local.conf
cat <<EOF >> ${LOCAL_CONF}
[[local|localrc]]
ADMIN_PASSWORD=stack448
DATABASE_PASSWORD=$ADMIN_PASSWORD
RABBIT_PASSWORD=$ADMIN_PASSWORD
SERVICE_PASSWORD=$ADMIN_PASSWORD
SERVICE_TOKEN=$ADMIN_PASSWORD

# Images
# Use this image when creating test instances
# user: cirros, password: cubswin:)
IMAGE_URLS+=",http://cdn.download.cirros-cloud.net/0.3.2/cirros-0.3.2-x86_64-disk.img"
# user: fedora, 
IMAGE_URLS+=",http://cloud.fedoraproject.org/fedora-20.x86_64.qcow2"
 
# Branches
KEYSTONE_BRANCH=stable/juno
NOVA_BRANCH=stable/juno
NEUTRON_BRANCH=stable/juno
SWIFT_BRANCH=stable/juno
GLANCE_BRANCH=stable/juno
CINDER_BRANCH=stable/juno
HEAT_BRANCH=stable/juno
CEILOMETER_BRANCH=stable/juno
HORIZON_BRANCH=stable/juno

# Neutron
disable_service n-net
enable_service neutron,q-svc,q-agt,q-dhcp,q-meta
Q_PLUGIN=ml2
Q_AGENT_EXTRA_OVS_OPTS=(tenant_network_type=local)
OVS_VLAN_RANGE=physnet1
PHYSICAL_NETWORK=physnet1
OVS_PHYSICAL_BRIDGE=br-eth2
 
NETWORK_GATEWAY=10.121.0.1
PUBLIC_NETWORK_GATEWAY=10.131.0.1
FIXED_RANGE=10.121.0.0/24
FLOATING_RANGE=10.131.0.0/25

# Swift Configuration
ENABLED_SERVICES+=,s-proxy,s-object,s-container,s-account
SWIFT_REPLICAS=1
SWIFT_HASH=66a3d6b56c1f479c8b4e70ab5c2000f5

# Ceilometer
CEILOMETER_BACKEND=mongo
enable_service ceilometer-acompute ceilometer-acentral ceilometer-anotification ceilometer-collector
enable_service ceilometer-alarm-evaluator,ceilometer-alarm-notifier
enable_service ceilometer-api
 
# Enable Logging
LOGFILE=/opt/stack/logs/stack.sh.log
VERBOSE=True
LOG_COLOR=false
SCREEN_LOGDIR=/opt/stack/logs
EOF
chown ${USER}:${USER} ${LOCAL_CONF}

# bring it up
su -l ${USER} -c "${INSTALL_DIR}/stack.sh"
