HOW-TO git submodules
=====================

Adding a submodule
------------------

::

    TODO: re-create example

Moving up a Release
-------------------

If you want to move a submodule up one release, see how to `specify a tag`_; 
in summary it's something like::
  
  cd Freddy/
  git co 2.0.2
  cd ..
  git add Freddy
  git ci -m"Update Freddy (JSON) release to 2.0.2"
  git push

on the other developers' machines::

  git pull --rebase
  git submodule update

(the last one implies ``--checkout`` which is what brings the module to match the
super-project's recorded commit for the submodule).  

References
----------

- ``git submodule`` `man page`_

- How to `specify a tag`_

.. _man page: http://git-scm.com/docs/git-submodule
.. _specify a tag: http://stackoverflow.com/questions/1777854/git-submodules-specify-a-branch-tag

