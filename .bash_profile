# bash_profile:
if [ -n "${BASH_VERSION}" ] ; then
	use_color=false
	safe_term=${TERM//[^[:alnum:]]/.}	# sanitize TERM

	if [[ -f /etc/DIR_COLORS ]] ; then
		grep -q "^TERM ${safe_term}" /etc/DIR_COLORS && use_color=true
	elif type -p dircolors >/dev/null ; then
		if dircolors --print-database | grep -q "^TERM ${safe_term}" ; then
			use_color=true
		fi
	else
		case "$safe_term" in
			xterm) use_color=true ;;
		esac
	fi
fi

#This file is sourced by bash when you log in interactively.
[ -f ~/.bashrc ] && . ~/.bashrc


# A quick function to check if a command exists
cmdexists()
{
	type "${@}" 1>/dev/null 2>&1
}

# Screen and X11 window title
title() {
	echo -ne "\033k${title}\033\\"
}
xtitle() {
	echo -ne "\033]0;${*}\007"
}

# TODO: Consider using tput setaf and tput sgr0 instead
# https://github.com/lhunath/scripts/blob/master/bashlib/bashlib#L210
if [ "${use_color}" = "true" ]; then
	COL_BLACK="\033[0;30m"
	COL_DARKGRAY="\033[1;30m"
	COL_RED="\033[0;31m"
	COL_LIGHTRED="\033[1;31m"
	COL_GREEN="\033[0;32m"
	COL_LIGHTGREEN="\033[1;32m"
	COL_BROWN="\033[0;33m"
	COL_YELLOW="\033[1;33m"
	COL_BLUE="\033[0;34m"
	COL_LIGHTBLUE="\033[1;34m"
	COL_PURPLE="\033[0;35m"
	COL_LIGHTPURPLE="\033[1;35m"
	COL_CYAN="\033[0;36m"
	COL_LIGHTCYAN="\033[1;36m"
	COL_LIGHTGRAY="\033[0;37m"
	COL_WHITE="\033[1;37m"
	COL_RESET="\033[0;0m"
else
	COL_BLACK=""
	COL_DARKGRAY=""
	COL_RED=""
	COL_LIGHTRED=""
	COL_GREEN=""
	COL_LIGHTGREEN=""
	COL_BROWN=""
	COL_YELLOW=""
	COL_BLUE=""
	COL_LIGHTBLUE=""
	COL_PURPLE=""
	COL_LIGHTPURPLE=""
	COL_CYAN=""
	COL_LIGHTCYAN=""
	COL_LIGHTGRAY=""
	COL_WHITE=""
	COL_RESET=""
fi

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
	debian_chroot=$(cat /etc/debian_chroot)
fi

# If we are working in a virtual console...
if [ "${TERM}" = "linux" ]; then
	# Change the beep frequency and length
	setterm -bfreq 400 -blength 100
	# Change the font to something more pleasing
	#setfont ka8x16thin-1
fi

# gpg-agent, for managing my gpg key
if [ -d "${HOME}/.gnupg" ] && cmdexists gpg-agent; then

	# New way to start gpg-agent, implied by calling gpgconf.
	# If you get errors such as "inappropriate ioctl for device", try:
	# gpg-connect-agent /bye
	# Also check https://www.gnupg.org/documentation/manuals/gnupg-devel/Common-Problems.html
	export GPG_TTY=$(tty)
	echo UPDATESTARTUPTTY | gpg-connect-agent >/dev/null
	unset SSH_AGENT_PID
	if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
		export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
	fi

	# If an ssh-agent is already present, preserve it and use it
	#if [ -n "$SSH_AUTH_SOCK" ]; then
	#	mySSH_AUTH_SOCK="$SSH_AUTH_SOCK"
	#	if [ -n "$SSH_AGENT_PID" ]; then
	#		mySSH_AGENT_PID="$SSH_AGENT_PID"
	#	fi
	#fi
	#unset mySSH_AUTH_SOCK mySSH_AGENT_PID
	## Try to take over an existing gpg-agent
	#if [ -f "${HOME}/.gnupg/gpg-agent-info-$HOSTNAME" ]; then
	#	. "${HOME}/.gnupg/gpg-agent-info-$HOSTNAME"
	#elif [ -f "${HOME}/.gnupg/.gpg-agent-info" ]; then
	#	. "${HOME}/.gnupg/.gpg-agent-info"
	#fi
	#export GPG_AGENT_INFO
	#export SSH_AUTH_SOCK
	#export SSH_AGENT_PID
	## If taking over an existing session failed, start a new session.
	## The format of GPG_AGENT_INFO seems to be "socket:agentpid:1". Don't know what
	## the "1" at the end means.
	#if [ ! -S "${GPG_AGENT_INFO%%:*:*}" ]; then
	#	# If no gpg-agent is running, start one
	#	rm -f "$HOME/.gnupg/gpg-agent-info" "$HOME/.gnupg/gpg-agent-info-$HOSTNAME"
	#	if [ ! -S "$SSH_AUTH_SOCK" ]; then
	#		eval $(gpg-agent -s --daemon --enable-ssh-support --default-cache-ttl 7200)
	#	else
	#		eval $(gpg-agent -s --daemon -default-cache-ttl 7200)
	#	fi
	#fi
	## Is SSH_AUTH_SOCK was already set before this script was loaded, restore it
	#if [ -n "$mySSH_AUTH_SOCK" ] ; then
	#	export SSH_AUTH_SOCK="$mySSH_AUTH_SOCK"
	#	if [ -n "$mySSH_AGENT_PID" ]; then
	#		export SSH_AGENT_PID="$mySSH_AGENT_PID"
	#	else
	#		unset SSH_AGENT_PID
	#	fi
	#	unset mySSH_AUTH_SOCK mySSH_AGENT_PID
	#fi
fi

# ssh-agent, for managing my ssh keys
if [ ! -S "$SSH_AUTH_SOCK" ] && cmdexists netstat && cmdexists ssh-agent; then
	# Attempt to take over an existing ssh-agent
	for SSH_AUTH_SOCK in /tmp/ssh-*/agent.*; do
		if [ -O "$SSH_AUTH_SOCK" ] && [ -S "$SSH_AUTH_SOCK" ] && [ -w "$SSH_AUTH_SOCK" ] && [ -r "$SSH_AUTH_SOCK" ]; then
			break
		fi
		unset SSH_AUTH_SOCK
	done
	# If taking over an existing session failed, start a new session
	if [ ! -S "$SSH_AUTH_SOCK" ] && cmdexists ssh-agent; then
		eval $(ssh-agent -s -t 7200|grep -v '^echo')
	fi
fi

# Use afuse and sshfs for auto mounting remote directories under ~/net
if cmdexists afuse; then
	if cmdexists sshfs && [ -d ~/net ] && ! mountpoint -q ~/net; then
	afuse -o mount_template='sshfs -oreconnect -oServerAliveInterval=15 -oServerAliveCountMax=3 -oControlMaster=no -oPasswordAuthentication=no -oConnectTimeout=3 -oIdentityFile=~/.ssh/sshfs.key %r: %m' -o unmount_template='fusermount -u -z %m' ~/net
	fi
fi
if cmdexists gphotofs && [ -d ~/mnt/gphotofs ] && ! mountpoint -q ~/mnt/gphotofs; then
	gphotofs ~/mnt/gphotofs
fi

# If screen is available, configured, and we're not inside a screen session,
# then use screen as login shell
#if [ "$SHLVL" = 1 ] && [ "$TERM" != "screen" ] && cmdexists screen && test -e "$HOME/.screenrc"; then
#	((SHLVL+=1)); export SHLVL
#	screen -xRl
#	echo "screen login shell exited with status: $?"
#fi

##uncomment the following to activate bash-completion:
[ -f /etc/profile.d/bash-completion ] && source /etc/profile.d/bash-completion

if [ -d "$HOME/.Private" ] && [ -e "$HOME/.ecryptfs/Private.mnt" ] && cmdexists ecryptfs-mount-private && ! mountpoint -q "$(cat "$HOME/.ecryptfs/Private.mnt")"; then
	echo "Note: ecryptfs is locked. Use ecryptfs-mount-private to unlock"
fi

# Allow quick switching between qwerty and dvorak
if [ "$DISPLAY" ]; then
	asdf() { setxkbmap -layout "dvorak" -variant 'us' -option 'ctrl:nocaps'; }
	aoei() { setxkbmap -layout "dk" -variant 'nodeadkeys' -option 'ctrl:nocaps'; }
	aoeu() { aoei; }
fi

# Auto-logout after 5 mins if I'm root
if [ "$USER" = "root" ] || [ "$UID" = "0" ]; then
	export TMOUT="300"
fi

# Local man pages
if test -d "$HOME/.manpath" && cmdexists manpath; then
	export MANPATH="$(manpath -q):$HOME/.manpath"
fi

if [ "$XDG_RUNTIME_DIR" ]; then
	export MPD_HOST="$XDG_RUNTIME_DIR/mpd/socket"
fi
