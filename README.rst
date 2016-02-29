############################
 Desktop notification proxy
############################

An TCP proxy and client to send libnotify desktop notification. This allow you
te receive notification from remote computer, for example from persistent IRC
client over SSH.


Setup
-----

On your desktop station:

- Install ``libnotify-bin`` and python3.
- Put ``notify-proxy`` in ``~/.local/bin/``.
- Put ``notify-proxy.desktop`` in ``~/.config/autostart``.
- Setup ``RemoteForward 1216 127.0.0.1:1216`` in ``~/.ssh/config`` or use
  ``ssh -R 1216:localhost:1216``.

On servers:

- Copy ``notify-client``.

Now, use ``notify-client`` just like ``notify-send``, long options are
compatible.

.. code-block:: console


   $ notify-client Summary "Long body"


Credits
-------

- Call ``notify-client`` on highlight on irssi with `ramnes/highlight_cmd
  <https://github.com/ramnes/hilightcmd>`_.
- Initial idea stolen from `itsamenathan/libnotify-over-ssh
<https://github.com/itsamenathan/libnotify-over-ssh>`_.
