# How to Make Verified GitHub Commits

*Created by M. Massenzio, 2021-12-24*

GitHub has a [set of detailed instructions](https://docs.github.com/en/authentication/managing-commit-signature-verification), however, if you know your way around a Linux shell and basic understanding of how keys work, this is a condensed TL;DR version.

Also, with minimal effort it could automated (I am guessing even uploading the key to GitHub via API) in a shell script.

Here is the sequence of commands, along with the relevant output:

```
gpg --generate-key

gpg --list-keys
    pub   rsa3072 2021-12-25 [SC] [expires: 2023-12-25]
          A6D*******************************72EE84
    uid           [ultimate] Marco Massenzio <*@m****nz.io>
    sub   rsa3072 2021-12-25 [E] [expires: 2023-12-25]

GPG_KEY=A6D*******************************72EE84
gpg --keyserver keyserver.ubuntu.com \
    --send-keys $GPG_KEY

gpg --list-signatures --keyid-format 0xshort
    pub   rsa3072/0x0B*****4 2021-12-25 [SC] [expires: 2023-12-25]
          A6D*******************************72EE84
    uid           [ultimate] Marco Massenzio <*@m****nz.io>
    sig 3        0x0B*****4 2021-12-25  Marco Massenzio <*@m****nz.io>
    sub   rsa3072/0x4******D 2021-12-25 [E] [expires: 2023-12-25]
    sig          0x0B*****4 2021-12-25  Marco Massenzio <*@m****nz.io>

GPG_ID="0x0B*****4"
gpg --armor --export $GPG_ID
```

Finally, [update your GitHub settings](https://docs.github.com/en/authentication/managing-commit-signature-verification/adding-a-new-gpg-key-to-your-github-account) to add the new **public** GPG key (which was printed out to console with the `--export` command).

Edit the `.git/config` local file (or the global one `${HOME}/.gitconfig`) to add the identity of the signature:

```
git config --global commit.gpgsign true
git config --global user.signingkey $GPG_ID
```

(use `--local` to only change the settings in the current git repository)

Or you can manually edit the file:

```
[user]
    name = Marco Massenzio
    email = <<email@example.com>>
    # The value in $GPG_ID
    signingkey = 0x0B*****4
```

Now, every commit from this user will be marked as `verified` by GitHub (provided that the configured user's email matches the GPG Key email).

Incidentally, much of this is needed to [publish Maven JARs to Maven Central](https://central.sonatype.org/publish/release/); this will be the topic for a (much longer) future post.
