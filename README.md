Dynamic address auto-updater for IP traffic forwarding script
=============================================================
+ Linux OS & IPv4 only
+ Edit "ipupdater.conf" to re-configure
+ Doesn't work with any other shells that use iptables

Short description
=============================================================
+ This script shell resolves and forwards traffic for a dynamic DNS client using iptablesv4.
+ Uses restore for a reason, so we can restore these rules on system start-up or reboot. (Manual setup)

Requirements
=============================================================
+ Make sure IPv4 forwarding option is enabled in your configuration file: /etc/sysctl.conf