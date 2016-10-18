# HOW-TO Publish a Pyton Package on PyPi


## Create a setup.py file

__NOTE__
> Do __not__ confuse `setuptools` with `distutils` - this is the correct import
> for `setup.py`:

    from setuptools import setup


The arguments for `setup()` are documented [here](https://packaging.python.org/distributing/#setup-args)
and are non-trivial: a good example is my [filecrypt](https://github.com/massenz/filecrypt)'s
`setup.py` file.

The trickiest part is figuring out the packages, modules and the script files: probably best
to think aobut it in advance, but it was possible to rectify that during setup.

The biggest challenge is to come up with a top-level package name that does not conflict
with an existing one.

>As far as I can tell, it's currently mostly a process of trial-and-error, see below.

Once the `setup.py` is in decent shape, you can try and build a wheel:

    python setup.py bdist_wheel

After doing that, it's good practice to create a new virtualenv, and try to install the new
package in that one:

    pip install dist/my-project.whl

this is particularly useful to test out whether the `console_scripts` have been correctly
configured.

If you use _classifiers_ such as in:

        classifiers=[
            'Development Status :: 4 - Beta',
            'Intended Audience :: System Administrators',
            'License :: OSI Approved :: Apache Software License',
            'Programming Language :: Python :: 3'
        ]

then make sure to consult the [classifiers list][] as anything else will cause an error and
prevent registration.

## Register your Project

__NOTE__
> The instructions given to use `twine` for this step did not work for me. YMMV

Unless you have already have an account on PyPi, you will need to
[create one](https://pypi.python.org/pypi?%3Aaction=register_form) and login.

You can then head to the [Registration Form][] and upload your `PKG_INFO` file:
this has been created in a `<prj name>.egg-info` directory: this may take a bit
of back and forth, while you try to appease the Gods of PyPi to accept your configuration choices.


## Upload to PyPi

Once registration succeeds, the actual upload is rather easy, using `twine`:

    twine upload dist/*

provided you have a valid `~/.pypirc` it will just ask for the password and do the needful:

```
$ cat ~/.pypirc
[distutils]
index-servers=pypi

[pypi]
repository = https://upload.pypi.org/legacy/
username = <username>
```


[Registration Form]: https://pypi.python.org/pypi?%3Aaction=submit_form
[classifiers list]: https://pypi.python.org/pypi?%3Aaction=list_classifiers
