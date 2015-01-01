HOW-TO Reset a VM user password
===============================

If you forget the user's password for a VM, the simplest solution is to restart
the VM into ``single user`` mode.

Originally the fix found on `this thread`_ on AskUbuntu_

1. Reboot the VM and, during the GRUB splash-screen, hit ``ESC``

2. With the list of options available, hit the ``e`` key and, in the
   editor presented, add ``single`` at the end of a line similar to
   this one::

        linux /boot/vmlinux-3.13...-generic root=UUID=<uuid> ro

    so that it looks like this::

        linux /boot/vmlinux-3.13...-generic root=UUID=<uuid> ro single

3. you will be presented with a console and the root prompt (`#`): use the
   ``passwd`` command to change your user's password::

        # passwd marco

If you can't even remember which user(s) were configured, the easiest
way is to ``ls /home`` - or use the following::

    # cat /etc/passwd | grep -e "/bin/bash$" | cut -f1 -d: | sort


.. _this thread: http://askubuntu.com/questions/132965/how-do-i-boot-into-single-user-mode-from-grub
.. _AskUbuntu: http://askubuntu.com
