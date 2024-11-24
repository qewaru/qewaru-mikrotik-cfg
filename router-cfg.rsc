#############################################
#             My router config              #
#############################################
# Device:		Mikrotik hAP ax3    #
# RouterOS:		v7.16.1		    #
#############################################

#############################################
# 		Goal overview		    #
#############################################

# Security
## Restricted access to router control panel

# VLANs
## 10 = Default VLAN for recognized devices
## 99 = Base/managment VLAN


#############################################
#                 Naming		    #
#############################################

/system identity set name=Router


#############################################
#               Basic security		    #
#############################################

# Disabling all entries except WinBox and web
/ip service
set telnet disabled=yes
set ftp disabled=yes
set www address= 192.168.1.1/24
set ssh disabled=yes
set api disabled=yes
set winbox address= 192.168.1.1/24
set api-ssl disabled=yes

# Restricting Winbox access by interface
/tool mac-server set allowed-interface-list=BASE
/tool mac-server mac-winbox set allowed-interface-list=BASE

# Changing discovery setting to only Base VLAN
/ip neighbor discovery-settings set discover-interface-list=BASE


#############################################
#                  Bridge		    #
#############################################

# Bridge assignment
/interface bridge add name=bridge vlan-filtering=no

# Adding ports to the bridge
/interface bridge port
add bridge=bridge frame-types=admit-only-vlan-tagged interface=ether2
add bridge=bridge frame-types=admit-only-vlan-tagged interface=ether3
add bridge=bridge frame-types=admit-only-vlan-tagged interface=ether4
add bridge=bridge interface=ether5
add bridge=bridge frame-types=admit-only-vlan-tagged interface=wifi1
add bridge=bridge frame-types=admit-only-vlan-tagged interface=wifi2


#############################################
#                Trunk ports		    #
#############################################

# Leaving "ether5" port as "emergency" port
/interface bridge vlan
add bridge=bridge tagged=bridge,ether2,ether3,ether4,wifi1,wifi2 untagged=ether5 vlan-ids=10
add bridge=bridge tagged=bridge,ether2,ether3,ether4 untagged=ether5 vlan-ids=99


#############################################
#        IPs, VLANs, DHCP creation	    #
#############################################

# Creating 2 pools for Base VLAN and VLAN-10
/interface bridge
add name=vlan10-pool ranges=192.168.10.2-192.168.10.254
add name=vlan-base-pool ranges=192.168.1.2-192.168.1.254

# Creating 2 VLANs interfaces
/interface vlan
add interface=bridge name=vlan-10 vlan-id=10
add interface=bridge name=vlan-base vlan-id=99

# Assigning IPs to VLANs
/ip address
add address=192.168.1.1/24 interface=vlan-base
add address=192.168.10.1/24 interface=vlan-10

# DHCP service connection
/ip dhcp-server
add address-pool=vlan10-pool interface=vlan-10 lease-time=24h name=vlan10-dhcp
add address-pool=vlan-base-pool interface=vlan-base lease-time=24h name=vlan-base-dhcp

/ip dhcp-server network
add address=192.168.1.0/24 dns-server=192.168.1.1 gateway=192.168.1.1
add address=192.168.10.0/24 dns-server=192.168.1.1 gateway=192.168.10.1


#############################################
#               Interface Lists	    	    #
#############################################

/interface list
add name=WAN
add name=LAN
add name=BASE
add name=VLAN


/interface list member
add interface=bridge list=LAN
add interface=ether1 list=WAN
add interface=vlan-10 list=VLAN
add interface=vlan-base list=BASE
add interface=vlan-base list=VLAN


#############################################
#       Internet conn., DNS, Wi-Fi	    #
#############################################

# DNS and Internet configuration
/ip dhcp-client add interface=ether1 use-peer-dns=no use-peer-ntp=yes
/ip dns set allow-remote-requests=yes servers=8.8.8.8

# Wi-Fi configuration
/interface wifi
set [ find default-name=wifi1 ] channel.band=5ghz-ax .width=20/40/80mhz configuration.country=Latvia .mode=ap .ssid="5g-wifi" disabled=no security.authentication-types=wpa2-psk,wpa3-psk
set [ find default-name=wifi2 ] channel.band=2ghz-ax configuration.country=Latvia .mode=ap .ssid="2g-wifi" disabled=no security.authentication-types=wpa2-psk,wpa3-psk


#############################################
#               Firewall & NAT 		    #
#############################################

# Default masquerade
/ip firewall nat add action=masquerade chain=srcnat out-interface-list=WAN
  
# Adding Base VLAN IP range to the "allow-me" list
/ip firewall address-list add address=192.168.1.0/24 list=allow-me

# Fasttrack for high-speed connections
/ip firewall filter add action=fasttrack-connection chain=forward connection-state=established,related hw-offload=yes
/ip firewall mangle
add action=accept chain=prerouting connection-state=established,related
add action=accept chain=forward connection-state=established,related
add action=accept chain=postrouting connection-state=established,related

# Filtering
/ip firewall filter
## Input
add action=reject chain=input connection-state=new dst-port=8291 protocol=tcp reject-with=tcp-reset src-address-list=!allow-me
add action=accept chain=input connection-state=established,related
add action=accept chain=input in-interface-list=VLAN
add action=accept chain=input in-interface=base-vlan
add chain=input action=drop log=yes log-prefix="I-DROP:"
## Forward
add action=accept chain=forward connection-state=established,related
add action=accept chain=forward connection-state=new in-interface-list=VLAN out-interface-list=WAN
add chain=forward action=drop log=yes log-prefix="F-DROP:"


#############################################
#               Enabling VLANs 		    #
#############################################

#Tagging packets over the trunk ports
/interface bridge port
set bridge=bridge ingress-filtering=yes frame-types=admit-only-vlan-tagged [find interface=ether2]
set bridge=bridge ingress-filtering=yes frame-types=admit-only-vlan-tagged [find interface=ether3]
set bridge=bridge ingress-filtering=yes frame-types=admit-only-vlan-tagged [find interface=ether4]
set bridge=bridge ingress-filtering=yes frame-types=admit-only-vlan-tagged [find interface=wifi1]
set bridge=bridge ingress-filtering=yes frame-types=admit-only-vlan-tagged [find interface=wifi2]

/interface bridge set bridge vlan-filtering=yes
