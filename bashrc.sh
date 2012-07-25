#!/bin/bash

function parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

alias grep='grep --color'

alias l='ls -AlG'

GREEN='0;32m'
CYAN='0;36m'
GOLD='0;33m'
LIGHT_GREEN='1;32m'
YELLOW='1;33m'
RED='0;31m'
MAGENTA='0;35m'
BLUE='0;34m'
GRAY='1;30m'
RESET='00m'
LIGHT_BLUE='1;34m'

export PS1='\[\033[$GREEN\]\u@\h:\[\033[$LIGHT_GREEN\]\w\[\033[$RESET\]\[\033[$YELLOW\]$(parse_git_branch)\[\033[$RESET\]\$ '

export HISTFILESIZE=5000
export HISTCONTROL=ignoredups:erasedups
export HISTIGNORE="&:ls:ls *:[bf]g:exit"

