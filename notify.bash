#!/bin/bash -eux

# Minimal duration of last commands to notify it.
NOTIFY_MIN_SECONDS=${NOTIFY_MIN_SECONDS-10}

# Variable to store output without subshell cost. String or array.
__notify_ret=

# Setup on sourcing in .bashrc.
__notify_bootstrap() {
	# Save current windows title. Export it to notify-client
	__notify_guess_window_title
	__NOTIFY_TITLE="${__notify_ret}"
	__notify_ret=
}

# This is the prompt command entry point, receiving last command exit status as
# argument.
notify_last_command() {
	local last_exit_status=$1
	local last_entry=($(HISTTIMEFORMAT="%s " history 1))

	# Skip if history is empty
	if [ "${#last_entry[@]}" -eq 0 ] ; then
		return
	fi

	# Check in background.
	((__notify_maybe $last_exit_status "${last_entry[@]}" &>/dev/null )&)
}

__notify_guess_window_title() {
	# On shell init, guess our terminal window title.
	local fqdn
	local ips
	local legacy_debian

	if [ -n "${NOTIFY_TITLE-}" ] ; then
		__notify_ret=$NOTIFY_TITLE
		return
	fi

	# On shell init, if on SSH connections, not within tmux, LC_IDENTIFICATION
	# contains passthrough hack…
	if [ -n "${SSH_CONNECTION-}" -a -z "${TMUX-}" -a -n "${LC_IDENTIFICATION-}" ] ;
	then
		# Save the inherited title
		__notify_ret="${LC_IDENTIFICATION#libnotify:}"
		unset LC_IDENTIFICATION
		return
	fi

	# Save whether we have a configurable tmux title or if we must stick to
	# default.
	if [ -f /etc/debian_version ] && printf '8.0\n%s' $(</etc/debian_version) | sort --version-sort --check=quiet 2>/dev/null ; then
		legacy_debian=0
	else
		legacy_debian=1
	fi

	fqdn=$(hostname --fqdn)
	if [ -n "${TMUX-}" ] && [ "$legacy_debian" = 1 ]; then
		# This is the default byobu title, recomputed
		ips=($(hostname --all-ip-addresses))
		__notify_ret="${LOGNAME}@$fqdn (${ips[0]}) - byobu"
		return
	else
		# This the needle for notify : hostname and SHELL PID.
		# Put this in ~/.config/byobu/.tmux.conf:
		#
		#     set -g set-titles on
		#     set -g set-titles-string '#(hostname --fqdn) (#{pane_pid})'
		__notify_ret="$fqdn ($$)"
		return
	fi
}

__notify_update_title() {
	# Pass NOTIFY_TITLE to ssh connections through LC_* hack.
	export LC_IDENTIFICATION="libnotify:${__NOTIFY_TITLE}"
	# Send title to terminal emulator.
	echo -ne "\033]2;${NOTIFY_TITLE}\007"
}

__notify_maybe() {
	# To test this function:
	#
	# NOTIFY_MIN_SECONDS=0 NOTIFY_TITLE=toto ./notify.bash __notify_maybe 0 $(HISTTIMEFORMAT="%s " history 1)

	local exit_code=$1
	shift  # Skip history index.
	local cmdstart="$2"
	local last_command="${@:3}"

	if [ -z "${EPOCHSECONDS-}" ] ; then
		EPOCHSECONDS="$(date +%s)"
	fi
	elapsed_seconds=$((EPOCHSECONDS - cmdstart))
	if [ $elapsed_seconds -lt ${NOTIFY_MIN_SECONDS} ] ; then
		return
	fi

	command=${last_command[0]}
	if [[ "less|man|more|pager" =~ $command ]] ; then
		# Ignore known long command.
		return
	fi

	if [ ${exit_code} -eq 0 ] ; then
		args=(
			--icon utilites-terminal
			--hint int:transient:1
			"Command exited on ${__NOTIFY_TITLE}."
		)
	else
		args=(
			--icon gtk-dialog-error
			--urgency critical
			"Command failed on ${__NOTIFY_TITLE}!"
		)
	fi
	NOTIFY_TITLE=$__NOTIFY_TITLE notify-send --app-name "${SHELL##*/}" "${args[@]}"  "$last_command"
}


if [ $# = 0 ]; then
	# When sourced by .bashrc, bootstrap, set title on let .bashrc edit
	# PROMPT_COMMAND.
	__notify_bootstrap
	__notify_update_title
else
	# You can test any code by calling ./notify.bash my_command line. e.g.
	# ./notify.bash __notify_guess_window_title
	__notify_bootstrap
	"$@"
	echo "${__notify_ret}"
	set +eux
fi
