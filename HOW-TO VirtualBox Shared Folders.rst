Mounting Shared Folders on VirtualBox
=====================================

Follow the Virtual Box HOW-TO_, which essentially boils down to
adding the Shared Folder via the ``Machine >> Settings >> Shared Folders``
menu.

.. _HOW-TO: https://forums.virtualbox.org/viewtopic.php?t=15868

Once that's done, do **not** select "Mount Automatically", but do
select "Make Permanent."

Create a folder on the system, and make it accessible to your user
(and group too, if you want); this is what I typically use::

    sudo mkdir /mnt/shared
    sudo chown :users /mnt/shared
    sudo chmod 2775 /mnt/shared
    
Whatever you call it, **do not call it the same name as the shared folder**;
this causes the mount to fail.

To mount the shared folder (called, say, ``host``) you then can use::

    sudo mount -t vboxsf -o rw,uid=1000,gid=1000 host /mnt/shared

and then check that you can access it, create files, etc. without ``sudo``.

To make it permanent, add the following to ``/etc/rc.local``::

    # Adding Shared Folders auto-mount at startup:
    mount -t vboxsf -o rw,uid=1000,gid=1000 host /mnt/shared
