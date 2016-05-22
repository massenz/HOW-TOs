===================================
HOW-TO Install TensorFlow on Ubuntu
===================================

Install Python SciPy stack
--------------------------

These packages are required by ``matplotlib``::

    sudo apt-get install -y libpng-dev libfreetype6-dev

Then the actual Python 3 libraries::

    sudo apt-get install -y python3-numpy python3-scipy python3-matplotlib \
        python3-pandas python-sympy python3-nose

Create a virtual environment that uses the system-wide packages::

     mkvirtualenv --system-site-packages -p `which python3` tf

You may also need Jupyter_ to support notebooks::

    pip install -U jupyter

Matplotlib Backend Issue
^^^^^^^^^^^^^^^^^^^^^^^^

You may get a warning to the effect that...

    ``The Gtk3Agg backend is known to not work on Python 3.x with pycairo``

and, indeed, when trying to plot a graph, a blank window will open.

To fix this::

    sudo apt-get install -y  python3-pyqt5
    sudo vim /usr/local/lib/python3.4/dist-packages/matplotlib/mpl-data/matplotlibrc

and change the following line to::

    backend : qt5agg

See this `StackOverflow question`_ for more details.


TensorFlow
----------

Install ``TensorFlow`` from Google::

    pip3 install --upgrade https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-0.8.0-cp34-cp34m-linux_x86_64.whl

(this is the Linux version, with CUDA support).

Download from the CUDA_ website the package ``cuda-repo-ubuntu1404-7-5-local_7.5-18_amd64.deb``
(currently saved in ``/data/ISOs/``), install it (``dpkg -i``) and then run::

    sudo apt-get install -y cuda

To make this work, you'll need to add the CUDA libraries to the search path::

    export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH

Test
----

To ensure it all works, load the ``test_install_tf.npyb`` from ``Dropbox/development`` and
run it::

    jupyter notebook ${HOME}/Dropbox/development/test_install_tf.npyb


Useful links
------------

- TensorFlow_
- CUDA_
- TensorFlow `github repo`_

.. _TensorFlow: https://www.tensorflow.org/versions/r0.8/get_started/os_setup.html
.. _CUDA:https://developer.nvidia.com/cuda-downloads
.. _github repo: https://github.com/tensorflow/tensorflow
.. _StackOverflow question: http://stackoverflow.com/questions/27749664/python-matplotlib-cairo-error
