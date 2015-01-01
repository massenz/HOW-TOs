HOW-TO Setup Epson Workforce 630
================================

:Author: M. Massenzio
:Date: 2013-01-13

Drivers
-------

Must be downloaded from the `Epson download center`_ and are usually something like::

    $ ll Downloads/epson-workforce-630/
    total 2.4M
    -rw-rw-r-- 1 marco marco 1.9M Jan 13 22:41 epson-inkjet-printer-workforce-635-nx625-series_1.0.1-1lsb3.2_amd64.deb
    -rw-rw-r-- 1 marco marco 399K Jan 13 22:43 iscan_2.29.1-5~usb0.1.ltdl7_amd64.deb
    -rw-rw-r-- 1 marco marco  31K Jan 13 22:53 iscan-data_1.20.0-1_all.deb
    -rw-rw-r-- 1 marco marco  29K Jan 13 22:43 iscan-network-nt_1.1.0-2_amd64.deb

**NOTE** the scanner driver **must** be the one for ``ltdl7``, **not** the one for ``ltdl3``
pay attention when downloading the correct file.

The sequence of installs is critical, as it will not work otherwise.

* first install the printer driver;

* before installing the iscan packages, I had to install the ``lsb-core``, ``lsb-printing`` 
and the ``xsltproc`` packages::

    $ sudo apt-get install lsb-printing lsb-core xsltproc 

* then the iscan-data package::

    $ sudo dpkg -i Downloads/iscan-data_1.20.0-1_all.deb 

* followed by the main Image Scan! package::
    
    $ sudo dpkg -i Downloads/iscan_2.29.1-5~usb0.1.ltdl7_amd64.deb 

* lastly, the network plugin::
    
    $ sudo dpkg -i Downloads/iscan-network-nt_1.1.0-2_amd64.deb 

Configuring SANE
----------------

There are detailed instructions in the manual_, but it all boils down to simply adding this
line to ``/etc/sane.d/epkowa.conf``::

    net 192.168.1.223 1865

Obviously, if you add an entry in ``/etc/hosts`` to point a server name to the same IP address::

    workforce630     192.168.1.223

this will work too::

    net workforce630 1865


.. _Epson download center: http://download.ebz.epson.net/dsc/search/01/search/?OSC=LX
.. _manual: http://a1227.g.akamai.net/f/1227/40484/1d/download.ebz.epson.net/dsc/f/01/00/02/09/20/d04d37e6e9a0767668b0d6ea220b512b522389b2/userg_revQ_e.pdf
