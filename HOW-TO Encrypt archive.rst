==============================
HOW-TO Encrypt an archive file
==============================


:source:  http://askubuntu.com/questions/95920/encrypt-tar-gz-file-on-create
:created: 2016-05-14


Private/Public keypair
----------------------

Create the private key (one-off)::

    openssl genrsa -out ~/.ssh/key.pem 2048
    chmod 400 ~/.ssh/key.pem

then extract the public key from it::

    openssl rsa -in ~/.ssh/key.pem  -out ~/.ssh/key.pub -outform PEM -pubout

**NOTE** The whole mechanism revolves around keeping the secret key ``key.pem``,
well, **secret**.  This is the **only critical part of the scheme**.

Everything else, can be either public (eg, ``key.pub``) or stored without too
much concern for security (eg, the ``.enc`` encrypted files).


Encrypt the archive
-------------------

You then create the archive any which way you want::

    tar cfz maps.tar.gz Documents/maps

To encrypt the archive, create a one-time passphrase::

    openssl rand 32 -out pass.bin

this is a binary, but clear-text, file that will be used as the encryption secret::

    openssl enc -aes-256-cbc -pass file:pass.bin <maps.tar.gz >maps.tar.gz.ser

Once used, the encryption secret is itself encrypted using the generated keys::

    openssl rsautl -encrypt -pubin -inkey key.pub <pass.bin >pass.enc

Now, both the archive and the encryption secret can be stored securely.

**Important**
  After encryption, **the clear-text encryption secret MUST be securely deleted**

::

    shred -uz pass.bin

If necessary, it can be retrieved using the encrypted version and the secret key.


Decryption
----------

If necessary to retrieve the archived data, you must first decrypt the passphrase::

    openssl rsautl -decrypt -inkey key.pem <pass.enc >pass.bin

and then use it to decrypt the archive::

    openssl enc -aes-256-cbc -d -pass file:pass.bin <maps.tar.gz.ser >maps.tar.gz

The advantage of using (and encrypting) a separate secret is that if, for whatever reason, the
secret key is compromised, only the passphrase(s) need to be re-encrypted (using a newly created
keypair) while the more expensive-to-process archives can be left alone.

Obviously, **keep the key material (secret key) and confidential information (encrypted archives) separate!**
(however, the passphrase and archives could be, in principle stored alongside).
