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

# This file is sourced by bash when you log in interactively.
[ -f ~/.bashrc ] && . ~/.bashrc


# A quick function to check if a command exists
cmdexists()
{
	type "${@}" 1>/dev/null 2>&1
}

# Screen and X11 window title
screentitle() {
   echo -ne "\033k${*}\033\\"
}
xtitle() {
   echo -ne "\033]0;${*}\007"
}
title() {
	screentitle "${@}"
	xtitle "${@}"
}

if [ "$SSH_CONNECTION" ]; then
	xtitle "$HOSTNAME"
fi

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
fi

# Use afuse and sshfs for auto mounting remote directories under ~/net
if cmdexists afuse; then
	if cmdexists sshfs && [ -d ~/net ] && ! mountpoint -q ~/net; then
	afuse -o mount_template='sshfs -oreconnect -oServerAliveInterval=15 -oServerAliveCountMax=3 -oControlMaster=no -oPasswordAuthentication=no -oConnectTimeout=3 -oIdentityFile=~/.ssh/sshfs.key %r: %m' -o unmount_template='fusermount -u -z %m' ~/net
	fi
fi

# Bash completion
[ -f /etc/profile.d/bash-completion ] && source /etc/profile.d/bash-completion

# If an ecryptfs dir is present but locked, notify the user who might want a hint to unlock it
if [ -d "$HOME/.Private" ] && [ -e "$HOME/.ecryptfs/Private.mnt" ] && cmdexists ecryptfs-mount-private && ! mountpoint -q "$(cat "$HOME/.ecryptfs/Private.mnt")"; then
	echo "Note: ecryptfs is locked. Use ecryptfs-mount-private to unlock"
fi

# A few shorthands for switching between US dvorak and Danish qwerty
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
