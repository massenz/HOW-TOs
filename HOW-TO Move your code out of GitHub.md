# HOW-TO Move your code out of GitHub

As everyone knows by now, Microsoft has bought Github for several $BN's.

Depending on your point of view, this can be either a catastrophe or a disaster: nothing good can possibly come out of it, apart from, possibly, having prevented Github (the corporation) going into a steady, sad decline, as they seemed unable to figure how to turn out a profit and remain a sustainable, independent entity.

While I don't necessarily believe any particularly evil intent on the part of the Dark Force of Redmond, I do (strongly) believe in corporate incompentece: in this, I am a great believer in Occam's Razor, as brilliantly paraphrased by Napoleon: "Do not assume malice, where incompentence is a simpler answer."

Having seen the dreadful state of various tools and services that Microsoft has acquired over the years (Skype, anyone?) it is not unreasonable to expect they'll be able to achieve the unthinkable: bloat the platform with pointless, confusing, marketing-driven features: dumbing it down to cater to the Windoze script kiddies, probably adding video streaming, or social "feeds", or whatever makes Millenials shimmer with excitement; while at the same time reducing its usefulness for the core users, the hard-core Linux/OSS developers.

At any rate, I'm outta here, as they say; and if you want to get out too, here's how to move your repo to [Bitbucket](http://bitbucket.org): added benefit? You get unlimited private repos too!

## Migrate the repo to Bitbucket

After creating an account, on the left side click on the `+` icon and in the menu that appears, select `IMPORT / Repository`, and then enter the Github URL in the box; fill in the remaining fields, click on "Import repository" and you're pretty much done here.

## Update your local `.git/config`

In your newly created repository, click on `Overview`, you'll see the repo SSH URL at the very top of the page (if it shows HTTPS, change the dropdown): copy and paste that.

In your local repository, edit your `.git/config` file, updating the following line:

    [remote "origin"]
    url = git@bitbucket.org:marco/filecrypt.git

use whatever URL was presented for your repository.

There is a way using the `git remote` command to remove Github as the `origin` and replace it with Bitbucket, too:

    git remote remove origin && \
        git remote add origin <URL>

## Update docs & Tell others

Don't forget to update any URLs you may have in documentation and other files with the new repository (Web) URL; also, it would be kinda rude not to tell other contributors (hell, give them heads-up before doing it, why not) so don't forget to do that too.

## Delete your Github repository

And show Microsoft your middle finger while doing it too.
