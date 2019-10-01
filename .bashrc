# .bashrc:

# Use git for managing config files
# Source of idea: https://www.atlassian.com/git/tutorials/dotfiles
alias config='/usr/bin/git --git-dir="$HOME/.configrepo/" --work-tree="$HOME"'
# To apply to a new system, add the alias above and run:
# git clone --bare https://github.com/ttytyper/dotfiles.git "$HOME/.configrepo"
# config config --local status.showUntrackedFiles no
# config checkout # Will tell you if you need to move any pre-existing files out of the way. Use --force to delete all of them
# config submodule update --init --recursive

# This file is sourced by all *interactive* bash shells on startup.  This
# file *should generate no output* or it will break the scp and rcp commands.

# A quick function to check if a command exists
cmdexists()
{
	type "${@}" 1>/dev/null 2>&1
}

# I want my ~/bin and various sbin dirs to be part of my PATH
export PATH="${HOME}/bin:$HOME/.local/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:${PATH}:/usr/X11R6/bin:/usr/X11R6/sbin"

# Don't log commands that begin with space, and also don't log repeated commands
export HISTCONTROL="ignoreboth"

# I don't want less to log anything
export LESSHISTFILE="-"
export LESSHISTSIZE=0

if cmdexists locale && locale -a 2>/dev/null|grep -q '^en_DK\.utf8$'; then
	export LANGUAGE="en_DK.UTF-8"
	export LANG="en_DK.UTF-8"
	export LC_ALL="en_DK.UTF-8"
else
	# Fall back to POSIX locale if all preferred locales fail
	export LC_ALL="C"
fi
#export TZ="CET"

# I prefer vim, if available. Otherwise nano
if cmdexists vim; then
	export EDITOR="`which vim`"
elif cmdexists nano; then
	export EDITOR="`which nano`"
fi

# As pager, I prefer less, if available. Otherwise more
if cmdexists less; then
	export PAGER=less
elif cmdexists more; then
	export PAGER=more
fi

# colors for ls, etc.
# Warning: This might break in non-GNU versions of ls
if [ "${use_color}" ]; then
	alias ls="ls --color=auto -hF"
	alias ll="ls --color -lhF"
	alias lla="ls --color -lAhF"
	alias l1="ls --color -1hF"
else
	alias ls="ls -h"
	alias ll="ls -lh"
	alias lla="ls -lAh"
	alias l1="ls -1h"
fi
alias l="ll"

alias netstat='netstat --wide'
alias ip='ip -human -color -oneline -brief'

if cmdexists lynx; then
	# I hate those stupid delays in lynx
	alias lynx="lynx -nopause"
	# WWW home page, mostly (only?) used by lynx
	export WWW_HOME="https://www.startpage.com/"
fi

# I want pass (password manager) to use the primary clipboard
export PASSWORD_STORE_X_SELECTION=primary

# Enable bash completion
if [ -n "$BASH_COMPLETION" ] && [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# Regular security
umask 0022

# Automatically cd into directories when entered  as commands
shopt -s autocd

# Liquidprompt bling. Only runs in interactive shells, not from scripts, scp etc.
if [[ $- = *i* ]]; then
	LP_BATTERY_THRESHOLD=10
	LP_HOSTNAME_ALWAYS=1
	LP_USER_ALWAYS=0
	if [ -e "$HOME/.local/liquidprompt/liquidprompt" ]; then
		source "$HOME/.local/liquidprompt/liquidprompt"
	elif [ -e /usr/share/liquidprompt/liquidprompt ]; then
		source /usr/share/liquidprompt/liquidprompt
	fi
fi
