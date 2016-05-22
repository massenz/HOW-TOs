=================
chef installation
=================

:author: M. Massenzio (m.massenzio@gmail.com)
:date: 2013-08-15

virtual machines
----------------

Created under virtualbox, as Ubuntu Server 12.04, using the `ISO image`_ from
Canonical (the actual download is on the QNAP ``multimedia`` share under the
``iso-images`` folder).

Once installation is completed, configure the NIC as a ``Bridged Adapter``
and it should use DHCP to acquire an IP address from the gateway.

Current settings::

     chef-server    192.168.1.129
     chef-client    192.168.1.130

modified ``/etc/hosts`` on both instances to look something like::

    $ cat /etc/hosts 

    192.168.1.50    mordor
    192.168.1.129   chef-server    
    192.168.1.1     gateway
    192.168.1.2     beregond

To make my life marginally simpler, set user/password to be ``chef``/``chef``;
as this violates default min password length, edit ``/etc/pam.d/common-password``
and change the line to::

    password    [success=1 default=ignore]  pam_unix.so minlen=1 sha512

also, to avoid the need to type a password each time you ``sudo`` do this
in ``/etc/sudoers``::

    # Allow members of group `sudo` to execute any command
    %sudo    ALL=(ALL:ALL) ALL

    # do not require password for user chef to sudo
    chef ALL=NOPASSWD:ALL

finally, so that I can ssh into these boxes without having to type every time
the password, from ``mordor``::

    scp .ssh/id_rsa.pub chef@chef-server:
    ssh chef@chef-server
    cat id_rsa.pub >> .ssh/authorized_keys

Cloning VMs
+++++++++++

An issue that crops up when cloning VMs (as in this instance) is that the MAC
address of the NIC changes, but ``udev`` will append (instead of replacing)
the new NIC's definition, thus causing ``eth0`` to be unrecognized.

The simple solution is to completely empty ``70-persistent-net.rules`` and 
reboot::

    sudo rm /etc/udev/rules.d/70-persistent-net.rules
    sudo reboot now

See `here`_ for more details.

installation
------------

Follow the instruction on the `installation page`_ for client and server.

post-install
------------

Follow the `guide`_ after installation to get chef up and running.

The Web UI should now be up and running at https://chef-server/
(note this is different from what the book and older documentation
may state, as the port is now default 443, **no longer 4040**).


.. _guide: http://www.opscode.com/blog/2013/03/11/chef-11-server-up-and-running/
.. _installation page: http://www.opscode.com/chef/install/
.. _ISO image: http://www.ubuntu.com/download/server
.. _here: https://forums.virtualbox.org/viewtopic.php?t=7749