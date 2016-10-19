Tunnelling a connection via server
----------------------------------

::

  ssh -N -p 245 marco@infinitebw.dyndns.org  -L  2110/mordor/22
       |                |                     |    |   \      `port on remote host
       |                `connecting host      |    |    remote host
       `no remote command execution           |    `local port
                                              `ssh tunnel

Connects to ibw's port 245 (this is NAT'd by the router to ``beregond``) and then will tunnel port 2110 on the **local** (-L) host to port 22 on ``mordor``

Tried from mordor itself::

  ssh -f -N -l admin -L 1234/mordor/22 beregond

in another shell, I've run::

  ssh -p 1234 localhost

to connect (back) to mordor.

``-f``  is probably unnecessary (puts ssh immediately in the background - use ``ps ax|grep ssh`` to recover the PID and, eventually, close the tunnel).


Script to enable tunnelling
---------------------------

The following is the script I use to enable tunnelling::


    #/bin/bash
    #
    # ssh_tunnel.sh, Created by M. Massenzio, 2011-08-04

    echo "SSH Tunnelling to mordor via infinitebw.dyndns.org"
    ssh -fNX -p 245 -L  2110/mordor/22 admin@infinitebw.dyndns.org
    ssh -X -l marco -p 2110 localhost

    PID=`ps ax | grep ".*ssh.*mordor" | grep -v 'grep' | sed 's/^ *//' | cut -f 1 -d ' '`
    echo "SSH Session terminated, killing the ssh tunnel: $PID"
    if [ -n "$PID" ]; then
      kill -3 $PID
    fi
    
Another example
---------------

::

    #!/bin/bash

    echo "SSH Tunnelling to marco.int via adm1.int"
    ssh -fNX -L 2110:10.200.11.190:22 root@10.200.10.5
    ssh -X -p 2110 localhost

    PID=`ps ax | grep ssh | grep "10.200" | grep -v 'grep' | sed 's/^ *//' | cut -f 1 -d ' '`
    echo "SSH Session terminated, killing the ssh tunnel: $PID"
    if [ -n "$PID" ]; then
      kill -3 $PID
    fi


SSH Automatic login
-------------------



The key pair are kept as follows (``alice@src`` wants to SSH as ``bob@dest``):

  1. key pair generated @src -- where you also keep the **private** key
  2. **public** key appended @dest to ``~/.ssh/authorized_keys``
  3. public key lists, at end, alice@src (bob@dest can be inferred from the ssh command)

The rationale is that the **public** key can be given to anyone, it is the ability to appending it to ``dest:/home/bob/.ssh/authorized_keys`` that *authorizes* ``alice@src`` (who owns the **private** key, hence is *authenticated*).

Upon connecting, it is the **private** key that certifies that the user that is trying to connect is really ``alice`` and really is coming from ``@src`` (only ``alice@src`` has access to it).

(Derived from this `Linux Problem`_)

.. _Linux Problem: http://linuxproblem.org/art_9.html
