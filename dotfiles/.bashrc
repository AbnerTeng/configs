#!/bin/bash
export PATH="/Users/abnerteng/git-fuzzy/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"

alias home='cd ~/abnerteng'
alias vim=$(find /opt/homebrew/Cellar/vim -name vim -type f | sort -Vr | head -n 1)


parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

virtualenv_info() {
    [[ -n "$VIRTUAL_ENV" ]] && echo "(venv:${VIRTUAL_ENV##*/})"
}


# Terminal Prompt
PS1="\[\e[0;97m\]\t\[\e[m\]"
PS1+=" "    # space
PS1+="\[\e[0;93m\]\u\[\e[m\]"    # username
PS1+=" "    # space
PS1+="\[\e[0;95m\]\W\[\e[m\]"    # current directory
PS1+=" "    # space
PS1+="\[\033[32m\]\$(parse_git_branch)\[\033[00m\]"    # current branch
PS1+=" "    # space
PS1+="\[\e[0;91m\]\$(virtualenv_info)\[\e[m\]$ "

export PS1;
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
ctags=/opt/homebrew/bin/ctags

HISTTIMEFORMAT="%F %T "
