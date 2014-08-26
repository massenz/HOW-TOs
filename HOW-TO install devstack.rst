================================
Openstack dev install (devstack)
================================

Issues during installation
--------------------------

Missing MySQL client module::

    cannot import MySQLdb

eventually solved by intalling a mixture of::

    sudo apt-get install python-mysqldb
    pip install mysql-python

(but probably, the above failed because of the following issue).

Then missing ``mysql_config`` when installing mysqldb python interface
solved by::

    sudo apt-get install libmysqlclient-dev

Incorrect version of `six`

AttributeError: 'Module_six_moves_urllib_parse' object has no attribute 'SplitResult'
https://bugs.launchpad.net/devstack/+bug/1316328

Solved by::

    # pip install -U six
    Upgrades six to 1.6.1 and it works.

Virtualenv
----------

Unsure whether it is actually used if activated before running ``stack.sh``.

    