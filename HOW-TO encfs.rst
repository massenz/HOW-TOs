=====================================
HOWTO: Encrypted directory with EncFS
=====================================


Overview
--------

This guide describes how to create encrypted directories. These can come in handy for laptop users, password lists and the like.

1. Install the software
^^^^^^^^^^^^^^^^^^^^^^^

::

    sudo apt-get install encfs fuse-utils
    sudo modprobe fuse

And since we don't want to modprobe each time we reboot, add ``fuse`` to ``/etc/modules`` (without quotes, on a line of its own)

2. Add yourself to the fuse group
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The installer creates a fuse group and to use fusermount you need to be in this group. You can do this with your favourite GUI admin tool or command line::

    sudo adduser <your username> fuse

3. Create a directory where your encrypted stuff will be stored
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

I put mine in my home dir, but you can put it anywhere you like::

    mkdir ~/.encrypted

4. Create a mountpoint
^^^^^^^^^^^^^^^^^^^^^^

This is the directory where you will mount the encrypted directory; through this path you can access the encrypted files::

    sudo mkdir /mnt/private
    sudo chown :users
    sudo chmod 2775 /mnt/private

5. Create the encrypted system and mount it
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The first time you try to mount the directory, encfs will create the encrypted filesystem. It works like the regular mount::

    encfs <folder to mount>  <mount point>

So for this example::

    encfs /home/$USER/.encrypted /mnt/private

Note that encfs wants absolute paths, i.e. starting with a ``/`` (or you can use shell expansion with ``~``)

6. Do the work
^^^^^^^^^^^^^^

Put some files in your ``/mnt/private`` folder and look in the ``~/.encrypted`` one: they will show up there, encrypted.

7. Unmount the encrypted filesystem
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Unmounting is as easy as::

    fusermount -u /mnt/private

8. Goto step 5
^^^^^^^^^^^^^^

Repeat! EncFS will only create the filesystem once, after that first time it will ask for a password and mount your directory.


Remember to keep the two directories apart: in this example the ``.encrypted`` folder holds your encrypted data and should not be used directly. The gateway to access this data is ``private`` or whatever you want to call it.


Sites used
----------

    - `This HOW-TO`_
    - `The main EncFS site`_
    - `How-To Mount a remote SSH filesystem using sshfs`_


.. _This HOW-TO: http://ubuntuforums.org/showthread.php?t=148600

.. _How-To Mount a remote SSH filesystem using sshfs:   http://ubuntu.wordpress.com/2005/10/28/how-to-mount-a-remote-ssh-filesystem-using-sshfs/

.. _The main EncFS site: http://arg0.net/wiki/encfs
