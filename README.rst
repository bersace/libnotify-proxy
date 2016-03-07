############################
 Desktop notification proxy
############################

An TCP proxy and client to send libnotify desktop notification. This allow you
te receive notification from remote computer, for example from persistent IRC
client over SSH.


Features
========

- Notify last command status.
- Notify over SSH.
- Inhibit notification when current bash shell is focused.


Setup
=====

Notify last command in bash
---------------------------

- Install ``xdotool``.
- Install ``notify-is-focused`` in your ``PATH``.
- Put this in your ``.bashrc``::

    . path/to/notify-last-command
    PROMPT_COMMAND='_EC=$? ; notify_last_command $_EC ;'
- Open a new terminal to test it with::

    sleep 11; true
    sleep 11; false

  Remember to focus another X11 window to see the notification.


Detect focused byobu pane
-------------------------

- Copy ``tmux.conf`` as ``~/.config/byobu/.tmux.conf``.
- Recreate byobu session.
- Test like bash above.


Notify over SSH
---------------

On your desktop station:

- Install ``libnotify-bin`` and Python.
- Install ``notify-proxy`` scripts in your ``PATH``.
- Put ``notify-proxy.desktop`` in ``~/.config/autostart``.
- Launch ``notify-proxy`` or open a new desktop session.
- Setup ``RemoteForward 1216 127.0.0.1:1216`` in ``~/.ssh/config`` or use
  ``ssh -R 1216:localhost:1216``.


On remote servers:

- Install ``notify-last-command`` and setup bashrc and byobu as above.
- You don't need ``xdotool`` or ``notify-is-focused``.
- Install ``notify-client`` in your ``PATH``.
- Test as above.

Now, use ``notify-client`` just like ``notify-send``, long options are
compatible.

.. code-block:: console

   $ NOTIFY_TITLE=__unfocused__ notify-client Shown
   $ notify-client Inhibited


IRSSI Setup
-----------

- Install IRSSI perl script `ramnes/highlight_cmd
  <https://github.com/ramnes/hilightcmd>`_. (Requires `CPAN
  Text::Sprintf::Named
  <http://search.cpan.org/~shlomif/Text-Sprintf-Named-0.0402/lib/Text/Sprintf/Named.pm>`_)
- ``/set hilightcmd_systemcmd notify-client --hint int:transient:1 --hint string:category:im.received "%(message)s" &``
- Hilight from another IRC client to test it.

That's it.


References
-------

- Initial idea stolen from `itsamenathan/libnotify-over-ssh
  <https://github.com/itsamenathan/libnotify-over-ssh>`_.
- `GNOME notifications specs
  <http://www.galago-project.org/specs/notification/0.9/x211.html>`_ including
  hints and categories.
