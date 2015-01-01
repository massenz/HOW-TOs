===================
Openstack Road Test
===================

:Author: Marco Massenzio
:Created: 2014-05-20
:Updated: 2014-10-25

Configuration
-------------

Setting up VBox VMs
^^^^^^^^^^^^^^^^^^^

$ sudo vim /etc/network/interfaces

iface eth1 inet static
address 192.168.56.51
netmask 255.255.255.0
network 192.168.56.0
gateway 192.168.56.1
broadcast 192.168.56.255

$ sudo vim /etc/hosts

# Openstack VMs
192.168.56.101   controller      # Openstack Controller VM
192.168.56.102   storage         # Openstack Storage (Cinder) VM
192.168.56.103   compute         # Openstack Compute (Nova) VM
192.168.56.104   network         # Openstack Network (Neutron) VM
192.168.56.100   os-template     # Openstack template


Setup the DevStack instance
^^^^^^^^^^^^^^^^^^^^^^^^^^^

    $ cat local.conf
    # local.conf for devstack
    # Created MM, 2014-05-16

    # phase|config filename
    [[local|localrc]]

    # Credentials
    ADMIN_PASSWORD=devstack
    MYSQL_PASSWORD=devstack
    RABBIT_PASSWORD=devstack
    SERVICE_PASSWORD=devstack
    SERVICE_TOKEN=token

    #Enable/Disable Services
    disable_service n-net
    enable_service q-svc
    enable_service q-agt
    enable_service q-dhcp
    enable_service q-l3
    enable_service q-meta
    enable_service neutron
    enable_service tempest

    HOST_IP=192.168.235.145
    FLOATING_RANGE=192.168.1.0/24
    PUBLIC_NETWORK_GATEWAY=192.168.1.1
    FIXED_RANGE=10.0.0.0/24

    #Stable Branches
    NOVA_BRANCH=stable/icehouse
    CINDER_BRANCH=stable/icehouse
    GLANCE_BRANCH=stable/icehouse
    HORIZON_BRANCH=stable/icehouse
    KEYSTONE_BRANCH=stable/icehouse
    NEUTRON_BRANCH=stable/icehouse

    #NEUTRON CONFIG
    Q_USE_DEBUG_COMMAND=True

    #CINDER CONFIG
    VOLUME_BACKING_FILE_SIZE=10240M

    #GENERAL CONFIG
    API_RATE_LIMIT=False

    # Output
    LOGFILE=/var/log/devstack/stack.sh.log
    VERBOSE=True
    LOG_COLOR=False
    SCREEN_LOGDIR=/var/log/devstack


Cleanup & Restart
-----------------

To clean up an installation (or restart a failed one) use::

    cd /opt/devstack
    ./unstack.sh
    ./clean.sh
    sudo rm -rf /opt/stack
    sudo reboot


Restarting Devstack
-------------------

DevStack is not intended for production, so things like services starting
automatically after reboot, don't work.

If you reboot your system and want to continue with the same configuration you
had before reboot, you must take some manual steps.

After you reboot, you must run the run the ``rejoin-stack.sh`` script::

    sudo losetup -f /opt/stack/data/stack-volumes-backing-file
    /opt/devstack/rejoin-stack.sh &


User Management
---------------

Setup autocompletion and tenant:user for CLI::

    $ source /opt/stack/python-novaclient/tools/nova.bash_completion
    $ source openrc demo demo


    $ nova image-list
+--------------------------------------+---------------------------------+--------+--------+
| ID                                   | Name                            | Status | Server |
+--------------------------------------+---------------------------------+--------+--------+
| 21818b9a-4175-444b-b105-3a42acf6819f | cirros-0.3.1-x86_64-uec         | ACTIVE |        |
| fde4d991-0525-4365-9214-09346c9421c4 | cirros-0.3.1-x86_64-uec-kernel  | ACTIVE |        |
| efff2c28-b8d5-4625-a0a9-03f05bc1154a | cirros-0.3.1-x86_64-uec-ramdisk | ACTIVE |        |
+--------------------------------------+---------------------------------+--------+--------+

    $ nova delete  712ee1b9-ddbb-42e0-82ec-472817494bfd
        Request to delete server 712ee1b9-ddbb-42e0-82ec-472817494bfd has been accepted.

Use ``admin`` user:tenant::

    $ source openrc admin admin
    $ keystone tenant-create --name RiverMeadow
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
| description |                                  |
|   enabled   |               True               |
|      id     | 025c471a750b4249beebe92518721a86 |
|     name    |           RiverMeadow            |
+-------------+----------------------------------+

    $ keystone tenant-list
+----------------------------------+--------------------+---------+
|                id                |        name        | enabled |
+----------------------------------+--------------------+---------+
| 025c471a750b4249beebe92518721a86 |    RiverMeadow     |   True  |
| 31c54f5c1f724bfeba5300ac9d9db12b |       admin        |   True  |
| b7055238f21048f59f15721995616ea3 |      alt_demo      |   True  |
| f7ee9783d645431590e65a8fe9f17a67 |        demo        |   True  |
| 5b647d0110424682aba878ccf19075f2 | invisible_to_admin |   True  |
| 0b6d7cd4cf0940d59ee30fb1558a9475 |      service       |   True  |
+----------------------------------+--------------------+---------+

    $ keystone role-list
+----------------------------------+------------------+
|                id                |       name       |
+----------------------------------+------------------+
| 3cbc625c7b85474e98dae1ec583ab298 |      Member      |
| cae6ee33cd4d4700a0ad213508e510d4 |  ResellerAdmin   |
| 9fe2ff9ee4384b1894a90878d3e92bab |     _member_     |
| 5044240ac7ba4abdb80849fe4007d03d |      admin       |
| 5f3594a270324bdd9c5604ca044d23c7 |   anotherrole    |
| 403b44611ed546f886e951f9051e6747 | heat_stack_owner |
| b7babb4d933a4c488344d6028cc4027b | heat_stack_user  |
| ae58aced1cab405eb88525c78ba29315 |     service      |
+----------------------------------+------------------+

    $ keystone user-create --name="marco" --pass=zekret \
        --tenant-id 025c471a750b4249beebe92518721a86 \
        --email="marco@rivermeadow.com"

+----------+----------------------------------+
| Property |              Value               |
+----------+----------------------------------+
|  email   |      marco@rivermeadow.com       |
| enabled  |               True               |
|    id    | 0d205afaf7f64c90ba70701cdd4550af |
|   name   |              marco               |
| tenantId | 025c471a750b4249beebe92518721a86 |
| username |              marco               |
+----------+----------------------------------+


    $ keystone user-list --tenant-id 025c471a750b4249beebe92518721a86
+----------------------------------+-------+---------+-----------------------+
|                id                |  name | enabled |         email         |
+----------------------------------+-------+---------+-----------------------+
| 0d205afaf7f64c90ba70701cdd4550af | marco |   True  | marco@rivermeadow.com |
+----------------------------------+-------+---------+-----------------------+

    $ keystone role-list
+----------------------------------+------------------+
|                id                |       name       |
+----------------------------------+------------------+
| 3cbc625c7b85474e98dae1ec583ab298 |      Member      |
| cae6ee33cd4d4700a0ad213508e510d4 |  ResellerAdmin   |
| 9fe2ff9ee4384b1894a90878d3e92bab |     _member_     |
| 5044240ac7ba4abdb80849fe4007d03d |      admin       |
| 5f3594a270324bdd9c5604ca044d23c7 |   anotherrole    |
| 403b44611ed546f886e951f9051e6747 | heat_stack_owner |
| b7babb4d933a4c488344d6028cc4027b | heat_stack_user  |
| ae58aced1cab405eb88525c78ba29315 |     service      |
+----------------------------------+------------------+

Setup user ``marco`` (``0d205afaf7f64c90ba70701cdd4550af``) for tenant ``RiverMeadow``
(``025c471a750b4249beebe92518721a86``) to be a ``Member`` (``3cbc625c7b85474e98dae1ec583ab298``)::

    $ keystone user-role-add \
        --tenant-id 025c471a750b4249beebe92518721a86 \
        --user-id 0d205afaf7f64c90ba70701cdd4550af \
        --role-id 3cbc625c7b85474e98dae1ec583ab298

Network Management
------------------

Start by creating a private network for RM tenant::

    (neutron) net-create --tenant-id 025c471a750b4249beebe92518721a86 RM_NETWORK

+---------------------------+--------------------------------------+
| Field                     | Value                                |
+---------------------------+--------------------------------------+
| admin_state_up            | True                                 |
| id                        | d8b196df-3c16-4d68-9f4d-742196467b08 |
| name                      | RM_NETWORK                           |
| provider:network_type     | local                                |
| provider:physical_network |                                      |
| provider:segmentation_id  |                                      |
| shared                    | False                                |
| status                    | ACTIVE                               |
| subnets                   |                                      |
| tenant_id                 | 025c471a750b4249beebe92518721a86     |
+---------------------------+--------------------------------------+

Then create a subnet (specified in ``CIDR`` format) and add it to the private network::

    (neutron) subnet-create --tenant-id 025c471a750b4249beebe92518721a86 RM_NETWORK 172.24.220.0/24

+------------------+----------------------------------------------------+
| Field            | Value                                              |
+------------------+----------------------------------------------------+
| allocation_pools | {"start": "172.24.220.2", "end": "172.24.220.254"} |
| cidr             | 172.24.220.0/24                                    |
| dns_nameservers  |                                                    |
| enable_dhcp      | True                                               |
| gateway_ip       | 172.24.220.1                                       |
| host_routes      |                                                    |
| id               | f540fafc-578f-4569-94f2-9c3a1f752ff1               |
| ip_version       | 4                                                  |
| name             |                                                    |
| network_id       | d8b196df-3c16-4d68-9f4d-742196467b08               |
| tenant_id        | 025c471a750b4249beebe92518721a86                   |
+------------------+----------------------------------------------------+

To connect the private network to the outside world (and the rest of Openstack) you will need
a routed connected it to the network::

    (neutron) router-create --tenant-id 025c471a750b4249beebe92518721a86 RM_ROUTER

+-----------------------+--------------------------------------+
| Field                 | Value                                |
+-----------------------+--------------------------------------+
| admin_state_up        | True                                 |
| external_gateway_info |                                      |
| id                    | 717b3d69-bee6-44f1-8464-b415f2e984ac |
| name                  | RM_ROUTER                            |
| status                | ACTIVE                               |
| tenant_id             | 025c471a750b4249beebe92518721a86     |
+-----------------------+--------------------------------------+

::

    (neutron) router-interface-add 717b3d69-bee6-44f1-8464-b415f2e984ac \
        f540fafc-578f-4569-94f2-9c3a1f752ff1

    Added interface eeb9ca6d-8170-451f-81a4-7ec2fd4126cf to
    router 717b3d69-bee6-44f1-8464-b415f2e984ac.

Finally, hook up the router with the external network::

    $ neutron net-external-list

+----------------------------------+--------+---------------------------------------------+
| id                               | name   | subnets                                     |
+----------------------------------+--------+---------------------------------------------+
| 7926b49b-cad4-30b-8f7b-20ecc9e6e | public | 2f935db5-d304-8628-b09f56003 192.168.1.0/24 |
+----------------------------------+--------+---------------------------------------------+

::

    $ neutron router-gateway-set 717b3d69-bee6-44f1-8464-b415f2e984ac \
        7926b49b-cad4-430b-8f7b-20ecc9e4cd6e

    Set gateway for router 717b3d69-bee6-44f1-8464-b415f2e984ac

    $ neutron router-show 717b3d69-bee6-44f1-8464-b415f2e984ac

+-----------------------+---------------------------------------------------------------------+
| Field                 | Value                                                               |
+-----------------------+---------------------------------------------------------------------+
| admin_state_up        | True                                                                |
| external_gateway_info | {"network_id": "7926b-430b-8f7b-20ecc9e4cd6e", "enable_snat": true} |
| id                    | 717b3d69-bee6-44f1-842e984ac                                        |
| name                  | RM_ROUTER                                                           |
| routes                |                                                                     |
| status                | ACTIVE                                                              |
| tenant_id             | 025c471a750b4249beebea86                                            |
+-----------------------+---------------------------------------------------------------------+


Create a Public Network
-----------------------

Start by creating a new public network, called ``public_net`` (can be given any name you like)::


    (neutron) net-create public_net --router:external=True
    Created a new network:

+---------------------------+--------------------------------------+
| Field                     | Value                                |
+---------------------------+--------------------------------------+
| admin_state_up            | True                                 |
| id                        | 5a66f8dd-7ae5-4ec0-850d-576afcd3c3c7 |
| name                      | public_net                           |
| provider:network_type     | local                                |
| provider:physical_network |                                      |
| provider:segmentation_id  |                                      |
| router:external           | True                                 |
| shared                    | False                                |
| status                    | ACTIVE                               |
| subnets                   |                                      |
| tenant_id                 | 4b67cebe1c0344acab3a4b9083fb8cbe     |
+---------------------------+--------------------------------------+

Associate with it a subnet (specifying the gateway and the allocation pool) without DHCP::

    (neutron) subnet-create --gateway 192.168.2.1 \
        --allocation-pool start=192.168.2.2,end=192.168.2.254 \
        --enable_dhcp=False \
        public_net 192.168.2.0/24

+------------------+--------------------------------------------------+
| Field            | Value                                            |
+------------------+--------------------------------------------------+
| allocation_pools | {"start": "192.168.2.2", "end": "192.168.2.254"} |
| cidr             | 192.168.2.0/24                                   |
| dns_nameservers  |                                                  |
| enable_dhcp      | False                                            |
| gateway_ip       | 192.168.2.1                                      |
| host_routes      |                                                  |
| id               | ea6f649f-d5ff-4565-a1ec-7a3abf74856e             |
| ip_version       | 4                                                |
| name             |                                                  |
| network_id       | 5a66f8dd-7ae5-4ec0-850d-576afcd3c3c7             |
| tenant_id        | 4b67cebe1c0344acab3a4b9083fb8cbe                 |
+------------------+--------------------------------------------------+
