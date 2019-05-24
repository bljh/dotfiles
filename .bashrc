# .bashrc:

# This file is sourced by all *interactive* bash shells on startup.  This
# file *should generate no output* or it will break the scp and rcp commands.

# A quick function to check if a command exists
cmdexists()
{
	type "${@}" 1>/dev/null 2>&1
}

# I want my ~/bin and various sbin dirs to be part of my PATH
export PATH="${HOME}/bin:$HOME/.local/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:${PATH}:/usr/X11R6/bin:/usr/X11R6/sbin"

# To reduce disk spinups, and to increase privacy, store my bash history in /tmp
#export HISTFILE="/tmp/.bash_history_$USER"
# A bit of security to prevent other users from doing symlink attacks and such.
# If the history file is not a regular file, or is not owned by me, delete it
# and create a new with sensible permissions
#if ! [ -f "$HISTFILE" ] || [ "$UID" != "$(stat -t "$HISTFILE"|cut -d' ' -f5)" ];
#then
#	rm -f "$HISTFILE"
#	touch "$HISTFILE"
#	chmod 600 "$HISTFILE"
#fi
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

alias netstat='netstat --wide'
alias ip='ip -human -color -oneline -brief'

# Use git for config files. To apply to a new system:
# alias config='/usr/bin/git --git-dir=$HOME/.configrepo/ --work-tree=$HOME'
# config config --local status.showUntrackedFiles no
# git clone --bare <git-repo-url> $HOME/.configrepo
# config checkout
alias config='/usr/bin/git --git-dir=$HOME/.configrepo/ --work-tree=$HOME'

if cmdexists lynx; then
	# I hate those stupid delays in lynx
	alias lynx="lynx -nopause"
	# WWW home page, mostly (only?) used by lynx
	export WWW_HOME="https://www.startpage.com/"
fi

cmdexists yagtd && alias todo='yagtd -c ~/todo.txt'

# I want pass (password manager) to use the primary clipboard
export PASSWORD_STORE_X_SELECTION=primary

# When using mosh, don't let mosh alter the title
export MOSH_TITLE_NOPREFIX=y

# If minicom is available, setup my preferred parameters
if cmdexists minicom; then
	export MINICOM="-c on -o"
fi

# Enable bash completion
if [ -n "$BASH_COMPLETION" ] && [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# Regular security
umask 0022

# Automatically cd into directories when entered  as commands
shopt -s autocd

# Powerline bling
# https://www.youtube.com/watch?v=_D6RkmgShvU
#if cmdexists powerline-daemon; then
#	export TERM="xterm-256color"
#	powerline-daemon -q
#	POWERLINE_BASH_CONTINUATION=1
#	POWERLINE_BASH_SELECT=1
#	if [ -f /usr/share/powerline/bindings/bash/powerline.sh ]; then
#		. /usr/share/powerline/bindings/bash/powerline.sh
#	fi
#fi

# Liquidprompt bling
test -e /usr/share/liquidprompt/liquidprompt && . /usr/share/liquidprompt/liquidprompt
