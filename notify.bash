#!/bin/bash

# Minimal duration of last commands to notify it.
NOTIFY_MIN_SECONDS=${NOTIFY_MIN_SECONDS-10}

# Variable to store output without subshell. String or array.
__notify_ret=

# Command to send notification
__notify=notify-client

__notify_is_focused() {
    # Use xdotool to check whether the terminal window is focused.
    test -n "${NOTIFY_TITLE}"
    local escaped_title=$(sed 's/[][()\.^$?*+]/\\&/g' <<< "${NOTIFY_TITLE}")
    focused_window=$(xdotool getwindowfocus)
    my_window=$(xdotool search --name "${escaped_title}")
    test "${focused_window}" = "${my_window}"
}

__notify_guess_window_title() {
    # If not on TMUX and we have an inherited title, use it. Because we don't control the terminal title.
    if [ -z "${TMUX-}" -a -n "${__NOTIFY_INHERIT_TITLE-}" ] ; then
        __notify_ret="${__NOTIFY_INHERIT_TITLE}"
        return
    fi

    local fqdn=${__notify_fqdn}
    if [ -n "${TMUX-}" ] ; then
        # Hack to manage old debian version. Can't tell which of byobu or tmux or else needs to be checked.
        if [ "${__notify_legacy_debian}" = 0 ]; then
            # Let byobu update pane title
            __notify_ret="$fqdn ($$)"
            return
        else
            # This is the default byobu title, recomputed
            local ips=($(hostname --all-ip-addresses))
            __notify_ret="${LOGNAME}@$fqdn (${ips[0]}) - byobu"
            return
        fi
    else
        # Put this in ~/.config/byobu/.tmux.conf:
        #
        #     set -g set-titles on
        #     set -g set-titles-string '#(hostname --fqdn) (#{pane_pid})'
        __notify_ret="${PANE_TITLE-bash} $fqdn ($$)"
        return
    fi
}

__notify_update_title() {
    __notify_guess_window_title
    export NOTIFY_TITLE="${__notify_ret}"
    # Pass NOTIFY_TITLE to ssh connections through LC_* hack.
    export LC_NOTIFY_TITLE="${NOTIFY_TITLE}"
    # Send title to terminal emulator.
    echo -ne "\033]2;${NOTIFY_TITLE}\007"
}

__notify_maybe() {
    # To test this function:
    #
    # NOTIFY_MIN_SECONDS=0 NOTIFY_TITLE=toto ./notify.bash __notify_maybe 0 $(HISTTIMEFORMAT="%s " history 1)
    #

    local exit_code=$1
    shift  # Skip history index.
    local cmdstart="$2"
    local last_command="${@:3}"

    if __notify_is_focused ; then
        # bash is focused. skip.
        return
    fi

    # If command last command was started before last run, just ignore it.
    if [ $cmdstart -le ${__NOTIFY_TIMESTAMP-0} ] ; then
        return
    fi

    now=$(date +%s)
    elapsed_seconds=$((now - cmdstart))

    if [ $elapsed_seconds -lt ${NOTIFY_MIN_SECONDS} ] ; then
        return
    fi

    if [ ${exit_code} -eq 0 ] ; then
        args=(
            --icon utilites-terminal
            --hint int:transient:1
            "Command exited on ${NOTIFY_TITLE}."
        )
    else
        args=(
            --icon gtk-dialog-error
            --urgency critical
            "Command failed on ${NOTIFY_TITLE}!"
        )
    fi
    $__notify --app-name "${SHELL##*/}" "${args[@]}"  "$last_command"
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

    __notify_update_title

    # Wait one seconds so that Window manager can update the title. This way, we
    # avoid to consider current window as unfocused. Then, check command status
    # in background.
    ((sleep 1; __notify_maybe $last_exit_status "${last_entry[@]}" &>/dev/null )&)

    export __NOTIFY_TIMESTAMP=$(date +%s)
}

# Setup on sourcing in .bashrc.
bootstrap() {
    # If you change FQDN, you should exec $SHELL to update this.
    __notify_fqdn=$(hostname --fqdn)

    # Save whether we have a configurable tmux title or if we must stick to default.
    if [ -f /etc/debian_version ] && printf '8.0\n%s' $(</etc/debian_version) | sort --version-sort --check=quiet 2>/dev/null ; then
        __notify_legacy_debian=0
    else
        __notify_legacy_debian=1
    fi

    # Choose notify-send for remote.
    if [ -n "${SSH_CLIENT-}" ] ; then
        __notify=notify-send
    fi

    # Reset timestamp to ignore previous history.
    export __NOTIFY_TIMESTAMP=$(date +%s)

    # On shell init, if on SSH connections, not within tmux, LC_NOTIFY_TITLE contains
    # passthrough hack…
    if [ -n "${SSH_CONNECTION-}" -a -z "${NOTIFY_TITLE-}" -a -n "${LC_NOTIFY_TITLE-}" ] ;
    then
        # Save the inherited title
        export __NOTIFY_INHERIT_TITLE="${LC_NOTIFY_TITLE}"
    fi

    __notify_update_title
}

if [ $# = 0 ]; then
    bootstrap
else
    # You can test any code by calling ./notify.bash my_command line. e.g.
    # ./notify.bash __notify_guess_window_title
    set -eux
    "$@"
    echo "${__notify_ret}"
    set +eux
fi
