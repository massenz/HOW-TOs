# HOW-TO Install ZSH on MacOS

## Install

Use `brew` for the `zsh` shell:

    brew update
    brew install zsh

Then, see the [oh my zsh](https://github.com/robbyrussell/oh-my-zsh) repo; to install run:

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"


## Update the init script

Replace (or merge) `.zshrc` with the saved `osx.zshrc`.

## Edit the theme

    subl ~/.oh-my-zsh/themes/agnoster.zsh-theme

Change this line in the `virtualenv_prompt` function:

    prompt_segment 239 214 "(`basename $virtualenv_path`)"

## Adjust Terminal fonts

Install the [Powerline fonts](https://github.com/powerline/fonts):

    git clone https://github.com/powerline/fonts.git --depth=1
    cd fonts/
    ./install.sh

Change terminal font to one of the Powerline fonts, and, optionally,
use the `Dark Gray` terminal profile.

## Add link to Sublime

While you're at it, you may as well add a link to Sublime Text:

    ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" ${USR_LOCAL}/bin/subl
