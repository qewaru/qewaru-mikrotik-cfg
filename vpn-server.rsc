#############################################
#            VPN Server config              #
#############################################
# Device:		Mikrotik hAP ax3    #
# RouterOS:		v7.16.1		    #
#############################################

#############################################
#		 Preparations		    #
#############################################

# There are 2 ways to connect the user:
## With another MikroTik router on user end
## With WireGuard client app

# In my case, my client uses Wireguard app
# Config for client looks like this:

# [Interface]
# PrivateKey = xxx
# Address = 10.0.0.2/24 (should be assigned address from peers list)
# DNS = 8.8.8.8

# [Peer]
# PublicKey = server-public-key
# AllowedIPs = 0.0.0.0/1, ::/0
# Endpoint = 192.168.0.1:39257 (server public IP and port)


# Save user public key for later


#############################################
#		 Configuration  	    #
#############################################

# Creating WireGuard interface
# Change the port to whatever you like, also check the MTU and change if needed
/interface wireguard add listen-port=39257 mtu=1420 name=wireguard1

# Adding peer for another user
## Make sure, that for every new user is used new IP address (10.0.0.2/24, 10.0.0.3/24, 10.0.0.4/24...)
## For endpoint address use your public IP address, (!)public-key is users key
/interface wireguard peers add allowed-address=10.0.0.2/24 endpoint-address=192.168.0.1 endpoint-port=39257 interface=wireguard1 name=user1 public-key="user-public-key"

# Add IP address pool that will be used for WireGuard users
/ip address add address=10.0.0.1/24 interface=wireguard1 network=10.0.0.0

# Accepting input and forward from clients
/ip firewall filter
add action=accept chain=input dst-port=39257 protocol=udp
add action=accept chain=forward src-address=10.0.0.0/24

# Allowing internet traffic flow
/ip firewall nat add action=masquerade chain=srcnat out-interface=ether1 src-address=10.0.0.0/24

# Additional: Add users to VLAN (if configured)
/ip route add disabled=no dst-address=192.168.10.0/24 gateway=10.0.0.1 routing-table=main suppress-hw-offload=no
