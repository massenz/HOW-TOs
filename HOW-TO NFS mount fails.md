# Enable NFS Mount


## Symptom


When mounting a valid share, NFS denies access:

    $ mount /mnt/backup
    mount.nfs: access denied by server while mounting beregond:/share/USBDisk1

Related - to unmount a stale handle:

    sudo umount --force -vvv -l /mnt/shared

## Solution


The mount point is not `exported`.
Find out where the mount point points to on the client side:

    $ cat /etc/fstab
    # /etc/fstab: static file system information.
    ...
    # Backup disk on 1TB external USB drive - no auto mount
    beregond:/share/USBDisk1 /mnt/backup       nfs    defaults,users,noexec,noauto    0       0


On the server side:

    $ ssh admin@beregond
    # ll /share/USBDisk1
    lrwxrwxrwx    1 admin    administ        20 Feb 21 00:03 /share/USBDisk1 -> /share/external/sdt1/

    # cat /etc/exports
    "/share/MD0_DATA/Download" *(rw,async,no_root_squash,insecure)
    "/share/MD0_DATA/Multimedia" *(rw,async,no_root_squash,insecure)
    "/share/MD0_DATA/Public" *(rw,async,no_root_squash,insecure)
    "/share/MD0_DATA/Web" *(rw,async,no_root_squash,insecure)

As you can see, `/share/external/sdt1/` is not there, edit the file and add the line:

    "/share/external/sdt1" *(rw,async,no_root_squash,insecure)

Then use (this is the **critical** part):

    [~] # exportfs -a

You'll get a bunch of error messages:

    exportfs: /etc/exports [5]: Neither 'subtree_check' or 'no_subtree_check' specified for export "*:/share/external/sdt1".
    Assuming default behaviour ('no_subtree_check').
    NOTE: this default has changed since nfs-utils version 1.0.x

but that's fine, they can be ignored.

Finally:

    $ mount /mnt/backup

will work as expected.
