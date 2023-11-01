# shellcheck shell=sh
# Initialization script for bash

if [ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]
then
    source /usr/share/git-core/contrib/completion/git-prompt.sh

    export GIT_PS1_SHOWDIRTYSTATE=true
    export GIT_PS1_SHOWUNTRACKEDFILES=true
    export GIT_PS1_SHOWSTASHSTATE=true
    export GIT_PS1_SHOWUPSTREAM="auto"

    export PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '
fi
