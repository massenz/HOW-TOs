# HOW TO Generate an SSL Certificate with letsencrypt.com

There is a wealth of documentation about how to generated a Certificate using
[letsencrypt](https://letsencrypt.org/getting-started/), the EFF free tool.

However, if you are using g-suite to manage your main website or want an SSL certificate to do
some testing during development, and may not have shell access to the WWW server (and, further,
you are unable to deploy the challenge file in the given location) things get a bit tricky.

See the [EFF Certbot documentation](https://certbot.eff.org/docs/intro.html) if you do have
shell or file access to your WWW server.

In the following I will outline the steps I followed to use the `--manaual` mode, with DNS
verification.

## Manual install of Certbot on Ubuntu

The version of `letsencrypt` that is packaged for Ubuntu 16.04 does not support DNS challenge
using the `manual` plugin, so you will need to download and install `certbot` manually
(which, I guess, is only appropriate):

```
cd ~/certbot
wget https://dl.eff.org/certbot-auto
chmod a+x certbot-auto
./certbot-auto
```

## Setup a TXT DNS record

See [this page](https://pressable.com/blog/2014/12/23/dns-record-types-explained/) for a clear
explanation of the major types of DNS records.

The DNS records for `alertavert.com` can be configured on the
[DNS Panel](https://ap.www.namecheap.com/Domains/DomainControlPanel/alertavert.com/advancedns)

YMMV here, but ultimately it requires being able to get on your domain registrar DNS management panel and set up a TXT record.

## Run `certbot` in `--manual` mode

This is the command to run (replace `alertavert.com` with your domain name), you can chain
several domains using the `-d` options several times:

```
$ ./certbot-auto certonly --manual --preferred-challenges dns -d alertavert.com
```

this will ask for the appropriate TXT record for each of the domains you specify:

```
Requesting root privileges to run certbot...
  /home/marco/.local/share/letsencrypt/bin/letsencrypt certonly --manual --preferred-challenges dns -d alertavert.com
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Obtaining a new certificate
Performing the following challenges:
dns-01 challenge for alertavert.com

-------------------------------------------------------------------------------
NOTE: The IP of this machine will be publicly logged as having requested this
certificate. If you're running certbot in manual mode on a machine that is not
your server, please ensure you're okay with that.

Are you OK with your IP being logged?
-------------------------------------------------------------------------------
(Y)es/(N)o: y

-------------------------------------------------------------------------------
Please deploy a DNS TXT record under the name
_acme-challenge.alertavert.com with the following value:

  <<< random value >>>

Once this is deployed,
-------------------------------------------------------------------------------
Press Enter to Continue
Waiting for verification...
Cleaning up challenges
Generating key (2048 bits): /etc/letsencrypt/keys/0000_key-certbot.pem
Creating CSR: /etc/letsencrypt/csr/0000_csr-certbot.pem

IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at
   /etc/letsencrypt/live/alertavert.com/fullchain.pem. Your cert will
   expire on 2017-05-21. To obtain a new or tweaked version of this
   certificate in the future, simply run certbot-auto again. To
   non-interactively renew *all* of your certificates, run
   "certbot-auto renew"
 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le
```

## Where is my certificate?

As the blurb above indicates, the certificate(s) are in the `live/` folder under
`/etc/letsencrypt`:

```
$ sudo find /etc/letsencrypt/
```
will yield, among (many) other things:
```
...
/etc/letsencrypt/live
/etc/letsencrypt/live/alertavert.com
/etc/letsencrypt/live/alertavert.com/privkey.pem
/etc/letsencrypt/live/alertavert.com/README
/etc/letsencrypt/live/alertavert.com/fullchain.pem
/etc/letsencrypt/live/alertavert.com/chain.pem
/etc/letsencrypt/live/alertavert.com/cert.pem
...
```
Profit!
