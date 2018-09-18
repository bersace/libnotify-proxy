# Desktop notification proxy

A TCP proxy and client to send libnotify desktop notification. This allow you te
receive notification from remote computer, for example from persistent IRC
client over SSH.


## Features

-   Notify last command status.
-   Notify over SSH.
-   Inhibit notification when current bash shell is focused.


## Notify last command in bash

-   Install `xdotool`.
-   Put this in your `.bashrc`:

        . path/to/notify.bash
        PROMPT_COMMAND='_EC=$? ; notify_last_command $_EC ;'

-   Open a new terminal to test it with:

        sleep 11; true
        sleep 11; false

    Remember to focus another X11 window to see the notification. notify.bash
    inhibit notification from command on focused terminal.


## Detect focused byobu pane

-   Copy `tmux.conf` as `~/.config/byobu/.tmux.conf`.
-   Recreate byobu session.
-   Test like bash above.


## Notify over SSH

On your desktop station:

-   Install `libnotify-bin` and Python.
-   Install `notify-proxy` script in your `PATH`.
-   Put `notify-proxy.desktop` in `~/.config/autostart`.
-   Launch `notify-proxy` or open a new desktop session.
-   Setup `RemoteForward 1216 127.0.0.1:1216` in `~/.ssh/config` or use
    `ssh -R 1216:localhost:1216`.

On remote servers:

-   Install `notify-client` in your `PATH`.
-   Install `notify.bash` and setup bashrc and byobu as above.
-   You don\'t need `xdotool`.
-   Test as above.

Now, use `notify-client` just like `notify-send`, long options are
compatible.

``` console
$ NOTIFY_TITLE=__unfocused__ notify-client Shown
$ notify-client Inhibited
```

## IRSSI Setup

-   Install IRSSI perl script
    [ramnes/highlight\_cmd](https://github.com/ramnes/hilightcmd).
    (Requires [CPAN
    Text::Sprintf::Named](http://search.cpan.org/~shlomif/Text-Sprintf-Named-0.0402/lib/Text/Sprintf/Named.pm))
-   `/set hilightcmd_systemcmd notify-client --hint int:transient:1 --hint string:category:im.received "%(message)s" &`
-   Hilight from another IRC client to test it.

That\'s it.


## References

-   Initial idea stolen from
    [itsamenathan/libnotify-over-ssh](https://github.com/itsamenathan/libnotify-over-ssh).
-   [GNOME notifications
    specs](https://developer.gnome.org/notification-spec/) including
    hints and categories.
