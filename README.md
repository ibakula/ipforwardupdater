Dynamic address auto-updater for IP traffic forwarding script
=============================================================
+ Works only on Linux based OS.
+ Configure DOMAIN and FIREWALL_RULES_PATH variables as you require.
+ DOMAIN = your dynamic DNS host name
+ FIREWALL_RULES_PATH = system path to your firewall rules file

Short description
=============================================================
+ Checks whether the IP of the dynamic DNS has updated every 3 hours, then update the forwarded IP.
+ Uses restore for a reason, so we can restore these rules on system start-up or reboot. (Manual setup)

Advisory
=============================================================
+ Currently used for 80 TCP port only. (http servers)
+ Make sure IPv4 forwarding option is enabled in your configuration file: /etc/sysctl.conf

"TODO"
=============================================================
+ Add custom ports support.