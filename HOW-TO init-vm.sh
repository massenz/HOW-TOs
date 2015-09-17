#!/bin/bash
#
# HOW-TO Initialize a freshly baked VM for a Python repository
#
# This script installs virtualenv, wrapper and git, clones the repo
# and updates the dependencies in `requirements.txt`
#
# Takes one argument, the name of the repo.
# Usage: init-repo NAME

source ${HOME}/Dropbox/development/scripts/utils.sh


if [[ -z $1 ]]; then
    errmsg "Must provide the name of the repo."
    exit 1
fi

if [[ -z $(which pip) ]]; then
    wget https://bootstrap.pypa.io/get-pip.py
    wrap "sudo python" get-pip.py 
fi

wrap sudo pip install --upgrade virtualenv
wrap sudo pip install --upgrade virtualenvwrapper

if [[ -z ${WORKON_HOME} ]]; then
    mkdir -p ${HOME}/venv
    echo "export WORKON_HOME=\$HOME/venv" >> .bashrc 
    echo "source /usr/local/bin/virtualenvwrapper.sh" >> .bashrc 
    source .bashrc 
else
    source /usr/local/bin/virtualenvwrapper.sh
fi

if [[ -z $(which git) ]]; then
    wrap "sudo apt-get" install git
fi

wrap git clone https://github.com/massenz/$1.git
cd $1

mkvirtualenv $1
if [[ $? == 0 && -e requirements.txt ]]; then
    pip install -r requirements.txt --upgrade
fi
msg "Repository $1 cloned"
