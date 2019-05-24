# .bash_logout
if [ $SHLVL -le 1 ]; then
	# If this shell is our last remaining login shell, clear things
	if cmdexists w && cmdexists grep && cmdexists wc && [ $(w|grep "^$USER "|wc -l) -le 1 ]; then
		# Clear any sudo cache on logout, to prevent subsequent sessions from
		# getting escalated privileges
		#cmdexists sudo && sudo -k
		# Kill ssh-agent to avoid leaving it running
		if [ -n "$SSH_AGENT_PID" ] && cmdexists ssh-agent; then
			#kill $SSH_AGENT_PID
			pkill -u "$UID" ssh-agent
		fi
	fi
	# If we were logged in with ssh from a screen session, reset the screen
	# window title (to the local shell name, even if possibly not the same as
	# remote shell)
	if [ "$SSH_CONNECTION" != "" ] && [ "$TERM" = "screen" ]; then
		echo -n -e "\033k${SHELL##*/}\033\\"
	fi
fi

# If we were in a virtual console..
if [ "${TERM}" = "linux" ]; then
	# Reset the font as a curtesy to the next user
	#setfont
	# Clear the screen for privacy
	clear
fi
