HOW-TO Kill a Remote TTY session
--------------------------------

The `original article`_ describes it so::


You can kill a Unix login session remotely by sending a hangup signal (SIGHUP) to the process 
running the login session. To do this, follow the steps below:

- Identify the shell you want to kill. To determine your current tty, from your Unix shell
  prompt, enter::

    tty

- To show all of your running processes, enter::

    ps -fu $USER

You should see something like this::

  PID    TT  STAT   TIME COMMAND
  13964  v5   I      0:00 elm
  13126  ue   S      0:00 -bash (bash)
  13133  ue   R      0:00 ps x
  13335  v5   S      0:00 -bash (bash)

In the first column, "PID" stands for "process ID". The second column shows the tty 
to which your processes are connected. 

The dash (-) before a process name shows that the process is a login shell.

- To remove the remote shell, look for the processes with a dash and choose the process 
  number that is not for your current tty. Then issue the following command::

  kill -HUP {processid}

Replace ``{processid}`` with the process ID number you identified.

When you send a SIGHUP (by entering ``kill -HUP`` or ``kill -1``) to a login shell, all 
the processes that were started in the shell will be killed as well 
(unless they were in the background). 

``SIGHUP`` is good because it allows applications like Elm and Emacs to exit gracefully, 
leaving your files intact.

.. _original article: https://kb.iu.edu/d/adqw
