GCM - what I did
----------------

GCM docs: http://developer.android.com/google/gcm/gs.html

1. Set up `Google Play SDK`_
   Using the SDK Manager, essentially install all Google Extras (at the bottom of list)
   Make sure you download the Google API SDK, and select that one in IntelliJ as
   the chosen SDK;

2. copied the ``google-play-service_lib`` into my own copy (as the documentation
   says)::

        $ cp -r ${ANDROID_SDK}/extras/google/google_play_services/libproject/google-play-services_lib/ ~/Dev/

3. Created a new ``module`` in IntelliJ:

     a. ``File / Import Module...``
     b. Pick the directory (``~/Dev/GooglePlay``)
     c. Import module from external model --> Choose Gradle
     d. Use customizable gradle wrapper (whatever that means)

   Make sure, in the Module Settings page to add the Android Framework
   'nature' to this module, so the resources will be exported.

4. Add the dependency in your Project (use Module Settings / Modules,
   'Dependencies' tab, click on ``+`` and pick the ``google-play-service_lib``
   module)

   Remember to add the ``google-play-services.jar`` in the ``lib`` directory
   as an **exported** dependency to the ``google-play-service_lib`` project
   **and** this project itself as a dependency to the Android client app.


Setup a Google API Project
^^^^^^^^^^^^^^^^^^^^^^^^^^

Navigate to the `Developers Console`_ and create a new project.
This gave me the following Project ID: ``empyrean-box-482`` and then enabled
Google Cloud Messaging for Android API.

You will need this Project ID (as the ``senderId`` in the Android app): see
`Register for GCM`_ section.

Using the steps below in `Setting up a Keystore & Key`_ I created a new API key,
using this for the SHA1 signature::

    BA:12:34:E3:ED:F5:B3:D9:65:35:84:87:C0:0F:85:BC:DB:40:75:06;com.alertavert.android.apps.cloudmessaging

The API key::

    AIzaSyCGSzC3P82fjg1YNeznjcTt2qjGOkp0Ti4

This can be seen in the credentials_ page.

Setting up a Keystore & Key
^^^^^^^^^^^^^^^^^^^^^^^^^^^

I used IntelliJ, could have been possible using ``keytool`` but that didn't work
initially.
Selecting the project, choose *Build / Generate Signed APK...* then follow the
instructions to create a new Keystore::

    Location: ~/.android/debug.jks
    Password: android
    Key: debug_key
    Password: android

    $ keytool -exportcert -alias debug_key -keystore .android/debug.jks -list -v
    Enter keystore password:  `android`
    Alias name: debug_key
    Creation date: Feb 5, 2014
    Entry type: PrivateKeyEntry
    Certificate chain length: 1
    Certificate[1]:
    Owner: CN=Marco Massenzio, OU=eng, O=com.rivermeadow, L=San Jose, ST=CA, C=US
    Issuer: CN=Marco Massenzio, OU=eng, O=com.rivermeadow, L=San Jose, ST=CA, C=US
    Serial number: 52f2c0e2
    Valid from: Wed Feb 05 14:53:22 PST 2014 until: Sun Jan 30 14:53:22 PST 2039
    Certificate fingerprints:
         MD5:  5F:9A:B6:9E:0E:55:82:8F:2A:71:00:C2:2E:DD:02:9A
         SHA1: BA:12:34:E3:ED:F5:B3:D9:65:35:84:87:C0:0F:85:BC:DB:40:75:06
         SHA256: E2:0C:53:67:21:4D:7B:DE:9E:6B:D3:7B:7D:3D:5E:72:BA:52:71:EC:63:0A:9A:50:4A:34:9B:BE:32:38:34:C2
         Signature algorithm name: SHA1withRSA
         Version: 3

Now you can use the SHA1 signature in the Google API project Public Key dialog

Setting up HTTP client (Third-party Server)
-------------------------------------------

Using `Apache HttpClient`_ libraty (see example code in ``NotificationServer``)
follow the instruction here_ to set up the POST request.

Make sure to remove Android SDK from the classpath for the server and replace
it with the Java SDK, or you will get an impenetrable ``Stub!`` exception.

A complete example can be found at the `open source site`_


Creating the Android Client
---------------------------

Mostly followed the `GCM Client`_ tutorial, still looking to find out where
to import the ``WakefulBroadcastReceiver`` (it's not part of the Google
API SDK).






.. _open source site: http://code.google.com/p/gcm
.. _Google Play SDK: http://developer.android.com/google/play-services/setup.html
.. _Developers Console: https://cloud.google.com/console/project
.. _credentials: https://cloud.google.com/console/project/apps~empyrean-box-482/apiui/credential
.. _Apache HttpClient: http://hc.apache.org/httpcomponents-client-ga
.. _here: http://developer.android.com/google/gcm/http.html
.. _Register for GCM: http://developer.android.com/google/gcm/client.html
