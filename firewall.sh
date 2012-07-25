#!/bin/bash

# Default SSH Port
SSH_PORT=${1:-22}
echo Using port $SSH_PORT for SSH...

# Flush all current rules from iptables
iptables -F

# SSH (non-standard port)
iptables -A INPUT -p tcp --dport $SSH_PORT -j ACCEPT

# HTTP/HTTPS web traffic
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Ping
iptables -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT

# Accept packets belonging to established and related connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Localhost
iptables -A INPUT -i lo -j ACCEPT

# Local Network
# iptables -A INPUT -s 192.168.0.0/24 -j ACCEPT

# Log Dropped Connections
# iptables -A INPUT -m limit --limit 30/minute -j LOG --log-level 7 --log-prefix "Dropped by firewall: "
# iptables -A INPUT -j LOG --log-level 7 --log-prefix "Dropped by firewall: "

# Set default policies for INPUT, FORWARD and OUTPUT chains
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Save settings (Debian/Ubuntu)
iptables-save > /etc/default/iptables

# Save settings (CentOS/RedHat)
# /sbin/service iptables save

# List rules
iptables -L -v

# Restore on system boot
cat > /etc/network/if-up.d/iptables << EOF
#!/bin/sh
iptables-restore < /etc/default/iptables
EOF

