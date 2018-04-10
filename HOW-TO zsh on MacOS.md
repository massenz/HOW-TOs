# HOW-TO Install ZSH on MacOS

## Install

See the [oh my zsh](https://github.com/robbyrussell/oh-my-zsh) repo; to install run:

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

## Update the init script

Replace (or merge) `.zshrc` with the saved `osx.zshrc`.

## Edit the theme

    subl ~/.oh-my-zsh/themes/agnoster.zsh-theme

Change this line in the `virtualenv_prompt` function:

    prompt_segment 239 214 "(`basename $virtualenv_path`)"

## Adjust Terminal fonts

Change terminal font to: Literation Mono Powerline 11pt
use the `Dark Gray` terminal profile.

