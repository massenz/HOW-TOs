# HOW-TO GPG keys & Signed committs

## Create a GPG Key

    gpg --full-generate-key

choose `RSA` and select `4096` as the length.

Pick the `ID` you want to use and [copy to GitHub](https://help.github.com/enterprise/2.11/user/articles/adding-a-new-gpg-key-to-your-github-account/):

    KEY_ID=$(gpg --list-secret-keys --keyid-format LONG | \
        grep '^sec\s*rsa4096/\(\S*\)' -o | cut -d '/' -f 2) 

On a Mac:

    echo $KEY_ID | pbcopy

## Download GPG Suite

From [GPG Tools](https://gpgtools.org) and install:

    wget https://releases.gpgtools.org/GPG_Suite-2018.1.dmg && 
        open GPG_Suite-2018.1.dmg

The first time you commit with a GPG signature (`git commit -S`) it will ask for the passphrase and offer to save it in MacOS Keychain.


## Configure git to sign commits by default

    git config --global commit.gpgsign true

