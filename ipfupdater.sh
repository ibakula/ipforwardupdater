#!/bin/bash

loadConfig() {
    CONFIG_PATH="./ipfupdater.conf"
    if [ -f "$CONFIG_PATH" ] && [ -n "$CONFIG_PATH" ]; then
            source $CONFIG_PATH
    else
            echo "\$CONFIG_PATH is not valid."
            exit 1
    fi
    shellInfo
}

shellInfo() {
    echo "IPFUpdater v1.1"
    echo "This script shell resolves and forwards traffic for a dynamic DNS client using iptablesv4."
    echo "Copyright (c) 1971 No_ONE"
}

generateFirewallPortRangeList() {
    if [ -n "TCP_PORTS_RANGE" ]; then
            local FIRST_TCP_PORT=0
            local LAST_TCP_PORT=0
            local COUNT_TCP_PORTS=0
            for i in $TCP_PORTS_RANGE
            do
                    ((COUNT_TCP_PORTS++))
                    if [ $COUNT_TCP_PORTS == 2 ]; then
                            LAST_TCP_PORT=$i
                    else
                            FIRST_TCP_PORT=$i
                    fi
            done
            if [ $COUNT_TCP_PORTS -eq 2 ] && [ $FIRST_TCP_PORT -lt $LAST_TCP_PORT ]; then
                    for (( c=$FIRST_TCP_PORT; c<=$LAST_TCP_PORT; ++c ))
                    do
                            echo "-A PREROUTING -p tcp -m tcp --dport $c -j DNAT --to-destination $1:$c" >> $FIREWALL_RULES_PATH
                    done
            else
                    echo "TCP Ports range configured incorrectly and rules were not applied, it may only consist of 2 ports (start_port-end_port, where start_port < end_port)"
            fi
    fi
    if [ -n "$UDP_PORTS_RANGE" ]; then
            local FIRST_UDP_PORT=0
            local LAST_UDP_PORT=0
            local COUNT_UDP_PORTS=0
            for u in $UDP_PORTS_RANGE
            do
                    ((COUNT_UDP_PORTS++))
                    if [ $COUNT_UDP_PORTS == 2 ]; then
                            LAST_UDP_PORT=$u
                    else
                            FIRST_UDP_PORT=$u
                    fi
            done
            if [ $COUNT_UDP_PORTS -eq 2 ] && [ $FIRST_UDP_PORT -lt $LAST_UDP_PORT ]; then
                    for (( n=$FIRST_UDP_PORT; n<=$LAST_UDP_PORT; ++n ))
                    do
                            echo "-A PREROUTING -p udp -m udp --dport $n -j DNAT --to-destination $1:$n" >> $FIREWALL_RULES_PATH
                    done
            else
                    echo "UDP Ports range configured incorrectly and rules were not applied, it may only consist of 2 ports (start_port-end_port, where start_port < end_port)"
            fi
    fi
}

generateFirewallPortRules() {
    for i in $TCP_PORTS
    do
            echo "-A PREROUTING -p tcp -m tcp --dport $i -j DNAT --to-destination $1:$i" >> $FIREWALL_RULES_PATH 
    done
    for i in $UDP_PORTS
    do
            echo "-A PREROUTING -p udp -m udp --dport $i -j DNAT --to-destination $1:$i" >> $FIREWALL_RULES_PATH
    done
    generateFirewallPortRangeList $1
}

generateFirewallRules() {
    rm $FIREWALL_RULES_PATH
    echo "# Generated by iptables-save v1.4.14 at $(getCurrentTimeHour)h$(getCurrentTimeMinutes)m" > $FIREWALL_RULES_PATH
    echo "*nat" >> $FIREWALL_RULES_PATH
    echo ":PREROUTING ACCEPT [33:2860]" >> $FIREWALL_RULES_PATH
    echo ":POSTROUTING ACCEPT [0:0]" >> $FIREWALL_RULES_PATH
    echo ":OUTPUT ACCEPT [0:0]" >> $FIREWALL_RULES_PATH
    generateFirewallPortRules $1
    echo "-A POSTROUTING -j MASQUERADE" >> $FIREWALL_RULES_PATH
    echo "COMMIT" >> $FIREWALL_RULES_PATH
    echo "# Completed at $(getCurrentTimeHour)h$(getCurrentTimeMinutes)m" >> $FIREWALL_RULES_PATH
    echo "# Generated by iptables-save v1.4.14 at $(getCurrentTimeHour)h$(getCurrentTimeMinutes)m" >> $FIREWALL_RULES_PATH
    echo "*mangle" >> $FIREWALL_RULES_PATH
    echo ":PREROUTING ACCEPT [2190:149745]" >> $FIREWALL_RULES_PATH
    echo ":INPUT ACCEPT [2132:146424]" >> $FIREWALL_RULES_PATH
    echo ":FORWARD ACCEPT [58:3321]" >> $FIREWALL_RULES_PATH
    echo ":OUTPUT ACCEPT [2042:148760]" >> $FIREWALL_RULES_PATH
    echo ":POSTROUTING ACCEPT [2054:148489]" >> $FIREWALL_RULES_PATH
    echo "COMMIT" >> $FIREWALL_RULES_PATH
    echo "# Completed at $(getCurrentTimeHour)h$(getCurrentTimeMinutes)m" >> $FIREWALL_RULES_PATH
    echo "# Generated by iptables-save v1.4.14 at $(getCurrentTimeHour)h$(getCurrentTimeMinutes)m" >> $FIREWALL_RULES_PATH
    echo "*filter" >> $FIREWALL_RULES_PATH
    echo ":INPUT ACCEPT [2132:146424]" >> $FIREWALL_RULES_PATH
    echo ":FORWARD ACCEPT [58:3321]" >> $FIREWALL_RULES_PATH
    echo ":OUTPUT ACCEPT [1996:145168]" >> $FIREWALL_RULES_PATH
    echo "COMMIT" >> $FIREWALL_RULES_PATH
    echo "# Completed at $(getCurrentTimeHour)h$(getCurrentTimeMinutes)m" >> $FIREWALL_RULES_PATH
}

updateFirewallRules() {
    iptables-restore < $FIREWALL_RULES_PATH
}

getIp() {
    local IP=`dig +short $DOMAIN`
    echo $IP
}

sendUpdateMessage() {
    echo "Update, current IP: " $CURRENT_IP "Time:" $(getCurrentTimeHour)"h"$(getCurrentTimeMinutes)"m"
}

getCurrentTimeHour() {
    date +"%H"
}

getCurrentTimeMinutes() {
    date +"%M"
}

loadConfig
CURRENT_IP="0.0.0.0"
NEW_IP=$CURRENT_IP

echo $(sendUpdateMessage)

while true;
do
        NEW_IP=$("getIp")
        if [ $CURRENT_IP = $NEW_IP ]; then 
                echo "No update called, IP remains the same."
        else
                CURRENT_IP=$NEW_IP
                generateFirewallRules $NEW_IP
                updateFirewallRules
                sendUpdateMessage
        fi
        sleep 3h
done
