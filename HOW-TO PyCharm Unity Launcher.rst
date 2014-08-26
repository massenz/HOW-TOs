HOW-TO PyCharm Unity Launcher
-----------------------------

In order to have a functioning and valid Unity launcher for PyCharm, it is
not sufficient to just create[2] a ``pycharm.desktop`` in either the 'local'
folder (``${HOME}/.local/share/applications``) or the 'global' one (
``/usr/share/applications``).

For some reason a launcher ``jetbrains-pycharm.desktop`` gets created in the
system applications folder, and it points to the wrong place (``/opt/pycharm-2.6.1``).

The only fix is to edit[1] that one and make it look like the following::

    $ cat /usr/share/applications/jetbrains-pycharm.desktop 
    [Desktop Entry]
    Version=1.0
    Type=Application
    Name=PyCharm
    Exec="/opt/pycharm/bin/pycharm.sh" %f
    Icon=/opt/pycharm/bin/pycharm.png
    Comment=Develop with pleasure!
    Categories=Development;IDE;
    Terminal=false
    StartupNotify=true

In my system, ``/opt/pycharm`` is a symbolic link to the 'real' installation directory::

    $ ll /opt/pycharm
    lrwxrwxrwx 1 root root 18 Oct 19 20:10 /opt/pycharm -> /opt/pycharm-3.0.1

Notes
-----

[1] there is a utility to validate desktop files: ``desktop-file-validate``
[2] it would be possible to install a desktop launcher (instead of manually copying it)
    or even 'construct' one using the CLI options for ``desktop-file-install``
