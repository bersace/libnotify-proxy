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
- Detect focused terminal (X11 Window, Terminator tab, tmux pane) to inhibit
  notification.


Setup
=====

Notify last command
-------------------

Put this in your ``.bashrc``::

  . path/to/notify-last-command
  PROMPT_COMMAND='_EC=$? ; notify_last_command $_EC ;'


Detect focused tmux pane
------------------------

Setup tmux in ``~/.config/byobu/.tmux.conf`` or so::

  set -g set-titles on
  set -g set-titles-string '#(hostname --fqdn) (byobu@#(basename ${TMUX%%%%,*})#D)'
  set -g update-environment "DISPLAY SSH_AGENT_PID SSH_AUTH_SOCK -SSH_CONNECTION TERMINATOR_UUID WINDOWID XAUTHORITY"


Notify over SSH
---------------

On your desktop station:

- Install ``notify-send`` and Python.
- Install `psutil <https://pypi.python.org/pypi/psutil>`_, `PyYAML
  <https://pypi.python.org/pypi/PyYAML>`_ Python packages.
- Install ``notify-proxy`` and ``notify-is-focused`` scripts in your ``PATH``.
- Put ``notify-proxy.desktop`` in ``~/.config/autostart``.
- Send ``WINDOWID`` and ``TERMINATOR_UUID`` via ``LC_*`` hack in ``.bashrc``::

    if [ ${WINDOWID-} ] ; then
        export LC_WINDOWID=${WINDOWID}
    fi

    if [ ${TERMINATOR_UUID-} ]; then
        export LC_TERMINATOR_UUID=${TERMINATOR_UUID}
    fi
- Launch ``notify-proxy`` or open a new desktop session.
- Setup ``RemoteForward 1216 127.0.0.1:1216`` in ``~/.ssh/config`` or use
  ``ssh -R 1216:localhost:1216``.


On remote servers:

- Install Python.
- Install ``notify-client`` in your ``PATH``.
- Fetch ``WINDOWID`` and ``TERMINATOR_UUID`` in ``~/.profile``::

    if [ ${LC_WINDOWID-} ] ; then
        export WINDOWID=$LC_WINDOWID
    fi


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
