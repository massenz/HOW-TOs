======================================
Deploying a Flask App to AWS Beanstalk
======================================

:Author: Marco Massenzio (m.massenzio@gmail.com)
:Version: 0.1
:Created: 2014-06-22
:Last updated: 2014-06-22

Overview
========

Deploying an application to AWS using Beanstalk_ and setting up autoscaling, monitoring and a number of other super useful features is very simple, and is extremely well-documented on AWS site.

However, even when following the `Beanstalk and Flask`_ *Getting Started* guide, there are a few gotchas and areas that are less than clear.

In the following (and subsequent posts) I'll document the steps necessary to deploy a simple file-ingestion REST API app I created for our own logs.

The code is availabe on *Github* in the `simple-flask`_ repo.

In the following I will assume that you have already followed the *Getting Started* guide and are familiar with the basics of AWS EC2, keypairs and security groups; also, there won't be much about Flask or Python here: the focus is on understanding some common scenarios when developing and deploying to AWS via Beanstalk.

Not your Grandma's Flask app
============================

As others have already noted, it is important to be aware of the following restrictions when creating a 'plain vanilla' Flask app for Beanstalk:

- the Flask app **must** be in an ``application.py`` file, at the top-level of the directory structure (this can be changed, but I haven't tried it: it works just fine this way, just be aware of it);

- the Flask app, well, can't be ``app``: it must be called ``application``, or nothing else will work::

        # Inside application.py
        import flask

        application = flask.Flask(__name__)

        @application.route('/')
        def index():
            ...

- your ``application.py`` will be **imported but not executed**: this is important, tripped me over initially, as none of the initialization methods got executed; use Flask's ``@application.before_first_request`` annotation for any initialization code;

- equally, you cannot pass command-line arguments, so all your carefully crafted ``argparse`` scripts/methods will go out the windows: to customize behavior in Beanstalk use OS Env variables instead (see `Option files`_ for how to do this programmatically).

Apart from that, though, you get a fully functional Flask application, and once you get the hang of it, you can have a monitored, massively scalable, secure application deployed in minutes: something that, in the pre-AWS era, would have easily taken weeks and a lot of sysadmin talent to achieve.

Option files
============

If you have followed along the tutorial on AWS developers' site, you know there are a couple of configuration directories added to your code::

    $ la
    total 72K
    drwxrwxr-x  9 marco marco 4.0K Jun 22 15:57 .
    drwxrwxr-x 11 marco marco 4.0K Jun 20 12:15 ..
    -rw-rw-r--  1 marco marco 8.3K Jun 22 15:57 application.py
    drwxrwxr-x  2 marco marco 4.0K Jun 22 15:57 .ebextensions
    drwxrwxr-x  2 marco marco 4.0K Jun 21 19:28 .elasticbeanstalk
    ...

The ``.elasticbeanstalk`` options file(s) contains mostly the values that you entered when running the ``eb init`` script, plus other environment-wide options: I haven't much fiddled with them, they mostly are sensible default values that can be left alone.

More interesting is the ``.ebextensions`` configuration file::

    $ cat .ebextensions/simple-flask.config
    # Elastic Bean extensions configuration file
    # Created by M. Massenzio, 2014-06-20

    # Use this to install packages necessary to run the app
    # packages:
    #   yum:
    #     libmemcached-devel: '0.31'

    # The following commands are executed in alpha order
    container_commands:
      # TODO: replace with an initialization script
      01createfolder:
         command: "mkdir -p /var/lib/migration-logs"
    #  99customize:
    #    command: "scripts/customize.sh"

    # You can specify any key-value pairs in the aws:elasticbeanstalk:application:environment namespace and it will be
    # passed in as environment variables on your EC2 instances
    option_settings:
      "aws:elasticbeanstalk:application:environment":
        FLASK_WORKDIR: "/var/lib/migration-logs"
        FLASK_DEBUG: "true"
        FLASK_SECRET_KEY: "n0tr3all7"
      "aws:elasticbeanstalk:container:python":
        WSGIPath: application.py
        NumProcesses: 3
        NumThreads: 20
      "aws:elasticbeanstalk:container:python:staticfiles":
        "/static/": "static/"

Of particular interest (as these can't be changed via the console management UI) are the ``container_commands`` which allow for pre-deployment scripts to be executed and the ability to configure OS Environment (and other) variables in the ``option_settings`` namespace.

And, as you can see, there's also an option to change the location of the ``static`` files.

How to reach the Application
============================

The app's URL is automatically generated by EB, and will look something like::

    http://simple-flask-env-xyz.elasticbeanstalk.com/

(you can see it in the EB console, top left, next to the application's name); this maps to an EIP (which is automatically allocated when deploying the app)::

    $ dig simple-flask-env-zyz.elasticbeanstalk.com

    ; <<>> DiG 9.8.1-P1 <<>> simple-flask-env-xxxxxxx.elasticbeanstalk.com
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 43956
    ;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 0

    ;; QUESTION SECTION:
    ;simple-flask-env-xyz.elasticbeanstalk.com. IN A

    ;; ANSWER SECTION:
    simple-flask-env-xyz.elasticbeanstalk.com. 59 IN A 172.223.29.18

    ;; Query time: 45 msec
    ;; SERVER: 127.0.0.1#53(127.0.0.1)
    ;; WHEN: Sun Jun 22 14:32:10 2014
    ;; MSG SIZE  rcvd: 82

Using `Route 53`_ this can be further mapped to a more 'memorable' URL (more importantly, to a sub-domain that you own, such as http://myapp.mydomain.com).


Connecting via SSH
==================

Creating a new keypair (in the EC2 console) will yield a ``Private Key`` file (``.pem``) to use when connecting via SSH::

    $ ssh -i .ssh/flask-logs.pem ec2-user@simple-flask-env-xyz.elasticbeanstalk.com

if the keypair was created in a different Region, it can be *imported*, extracting the public part::

    $ ssh-keygen -y >.ssh/flask-logs.pub
    Enter file in which the key is (.ssh/id_rsa): .ssh/flask-logs.pem

    $ cat .ssh/flask-logs.pub
    ssh-rsa AAAAfjafjeoijroeijh...afreir4eru09548309kljg95/HoUkfOsDGYb

then using the ``Import Key`` facility in the *Keypair management console*.

Updating the app after changes
==============================

The beauty of ``eb`` is that it works in conjunction with git and makes it dead easy to update the deployed app (in fact, this makes it really easy to automate deployment in production).

Once your changes are at a stage where you feel ready for a new deployment, just ``git commit`` your changes (optionally, ``git push`` to your ``origin`` repo) and then use ``git aws.push`` to push the update from the latest commit, even when outside of the ``develop`` branch (which is exactly how it should be)::

    $ git aws.push
    Updating the AWS Elastic Beanstalk environment simple-flask-env...
    Environment update initiated successfully.

Updating the configuration
--------------------------

The above, obviously, also works when modifying the configuration (see `Option files`_).  The configuration can be modified by editing the application's configuration script::

    $ vim .ebextensions/simple-flask.config
    # Elastic Bean extensions configuration file
    # Created by M. Massenzio, 2014-06-20

In the EB console OS Env vars are configured in the ``Configurations//Software Configuration`` pane.

Routing
=======

In a future blog post I will walk you through the steps necessary to add a custom URL that will point to your Flask app using `Route 53`_

Logs
====

Initially, when things were failing and I was seeing ``HTTP 500`` errors being returned, it was rather difficult to figure out what was going on: this is where the logs come in handy.

In the EB Console, the ``Logs`` page allows one to *snapshot logs* and see what went wrong; if you configure the Python ``logging`` module to emit logs to console (``stdout``), you can also see your app's logs in the ``/var/log/httpd/error_log`` (remember that your app is served via Apache's ``mod_wsgi`` module)::

    [Sun Jun 22 21:31:48.047413 2014] [core:notice] [pid 30480] AH00094: Command line: '/usr/sbin/httpd -D FOREGROUND'
    [Mon Jun 23 00:11:35.450713 2014] [:error] [pid 30481] 06/23/2014 00:11:35 [INFO] Uploading compressed logs data for 9999613...96330
    [Mon Jun 23 00:11:35.451629 2014] [:error] [pid 30481] 06/23/2014 00:11:35 [INFO] File /var/lib/migration-logs/9999613....96330/2014-06-23T00.11.35_migration_logs.txt saved, size 40 bytes
    [Mon Jun 23 00:11:43.579647 2014] [:error] [pid 30481] 06/23/2014 00:11:43 [INFO] Downloading logs data for 9999613...96330

Obviously, if you configure Python's logging to be sent to, for example, a rolling file appender, you can retrieve them via SSH (or scp, for that matter).

These logs will also contain the stacktraces of your exceptions, but I found this less than reliable when I was seeing some 500's but couldn't trace it back to the original error; for what is worth, you can prove this to yourself (log entries simplified for readability)::

    application.route('/raise')
    def raise_it():
        raise ValueError("This is expected to happen - but do I see it in the logs?")

will cause this to appear in the ``/var/log/httpd/error_log``::

     06/23/2014 00:19:56 [ERROR] Exception on /raise [GET]
     Traceback (most recent call last):
       File "/opt/python/run/venv/lib/python2.7/site-packages/flask/app.py", line 1817, in wsgi_app
         response = self.full_dispatch_request()
       File "/opt/python/run/venv/lib/python2.7/site-packages/flask/app.py", line 1477, in full_dispatch_request
         rv = self.handle_user_exception(e)
       File "/opt/python/run/venv/lib/python2.7/site-packages/flask/app.py", line 1381, in handle_user_exception
         reraise(exc_type, exc_value, tb)
       File "/opt/python/run/venv/lib/python2.7/site-packages/flask/app.py", line 1475, in full_dispatch_request
         rv = self.dispatch_request()
       File "/opt/python/run/venv/lib/python2.7/site-packages/flask/app.py", line 1461, in dispatch_request
         return self.view_functions[rule.endpoint](**req.view_args)
       File "/opt/python/current/app/application.py", line 207, in raise_it
         raise ValueError("This is expected to happen - but do I see it in the logs?")
     ValueError: This is expected to happen - but do I see it in the logs?

The easiest way to configure logging_ is::

    FORMAT = '%(asctime)-15s [%(levelname)s] %(message)s'
    DATE_FMT = '%m/%d/%Y %H:%M:%S'

    loglevel = logging.DEBUG if config.verbose else logging.INFO
    logging.basicConfig(format=FORMAT, datefmt=DATE_FMT, level=loglevel)



**Notes and Links**

.. _Route 53: http://aws.amazon.com/route53/
.. _Beanstalk: http://aws.amazon.com/documentation/elasticbeanstalk/
.. _Beanstalk and Flask: http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create_deploy_Python_flask.html
.. _simple-flask: https://github.com/massenz/simple-flask
.. _logging: https://docs.python.org/2/library/logging.html
