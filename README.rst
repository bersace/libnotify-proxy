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
- Detect focused terminal (X11 Window) to inhibit notification.


Setup
=====

Notify last command in bash
---------------------------

Put this in your ``.bashrc``::

  . path/to/notify-last-command
  PROMPT_COMMAND='_EC=$? ; notify_last_command $_EC ;'


Detect focused tmux pane
------------------------

Setup tmux in ``~/.config/byobu/.tmux.conf`` or so::

  set -g set-titles on
  set -g set-titles-string '#(hostname --fqdn) (#{pane_pid})'


Notify over SSH
---------------

On your desktop station:

- Install ``notify-send``, ``xdotool`` and Python.
- Install ``notify-proxy`` and ``notify-is-focused`` scripts in your ``PATH``.
- Put ``notify-proxy.desktop`` in ``~/.config/autostart``.
- Launch ``notify-proxy`` or open a new desktop session.
- Setup ``RemoteForward 1216 127.0.0.1:1216`` in ``~/.ssh/config`` or use
  ``ssh -R 1216:localhost:1216``.


On remote servers:

- Setup bash as above.
- Install Python.
- Install ``notify-client`` in your ``PATH``.

Now, use ``notify-client`` just like ``notify-send``, long options are
compatible.

.. code-block:: console

   $ notify-client Summary "Long body"


IRSSI Setup
-----------

- Install IRSSI perl script `ramnes/highlight_cmd
  <https://github.com/ramnes/hilightcmd>`_. (Requires `CPAN
  Text::Sprintf::Named
  <http://search.cpan.org/~shlomif/Text-Sprintf-Named-0.0402/lib/Text/Sprintf/Named.pm>`_)
- ``/set hilightcmd_systemcmd notify-client "%(message)s" &``

That's it.


Credits
-------

Initial idea stolen from `itsamenathan/libnotify-over-ssh
<https://github.com/itsamenathan/libnotify-over-ssh>`_.
