=======================
Linux networking how-to
=======================

Simple DHCP autoconfiguration
-----------------------------

::

    $ cat /etc/network/interfaces
    auto lo
    iface lo inet loopback

    auto eth0
    iface eth0 inet dhcp

    auto eth1
    iface eth1 inet dhcp


HOW-TO Create a static IP configuration
---------------------------------------

Change the ``/etc/network/interfaces`` entry for the NIC to something like::

    iface eth0 inet static
    address 192.168.1.100
    netmask 255.255.255.0
    network 192.168.1.0
    broadcast 192.168.1.255
    gateway 192.168.1.1
 
Save and close the file. Restart the network::

    $ sudo /etc/init.d/networking restart

Multiple static IPs
^^^^^^^^^^^^^^^^^^^

::

    $ cat /etc/network/interfaces
    auto lo
    iface lo inet loopback

    iface eth0 inet static
       address 192.168.235.133 
       netmask 255.255.255.0
       network 192.168.235.0
       broadcast 192.168.1.255
       gateway 192.168.235.2

    iface eth1 inet static
       address 172.16.131.131 
       netmask 255.255.255.0


Define new DNS servers
-----------------------

Edit ``/etc/resolv.conf``::

    search google.com
    nameserver 192.168.1.1
    nameserver 8.8.8.8
    nameserver 8.8.4.4


Change IP address and netmask from command line
-----------------------------------------------

Activate network interface ``eth0`` with a new IP (``192.168.1.50``) and netmask::

    $ sudo ifconfig eth0 192.168.1.50 netmask 255.255.255.0 up
    
Use of ``netstat``
------------------

Display current active Internet connections (servers and established connection)::

    $ netstat -nat

Display open ports::

    $ sudo netstat -tulp

    $ sudo netstat -tulpn

Display network interfaces stats (RX/TX etc)::

    $ netstat -i

Display output for active/established connections only::

    $ netstat -e
    $ netstat -te
    $ netstat -tue

where, ``t`` is for TCP, ``u`` for UDP and ``e`` for established.

References
----------

    [1] http://www.cyberciti.biz/tips/howto-ubuntu-linux-convert-dhcp-network-configuration-to-static-ip-configuration.html

