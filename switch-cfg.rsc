#############################################
#             My switch config              #
#############################################
# Device:	Mikrotik CRS326-24G-2S+     #
# RouterOS:		v7.16.1		    #
# SwOS:			v2.17		    #
#############################################

#############################################
# 		Goal overview		    #
#############################################

# Security
## Restricted access to switch control panel

# VLANs
## 10 = Default VLAN for recognized devices
## 99 = Base/managment VLAN
## Assign odd ports to VLAN-99 and even ports
## to VLAN-10


#############################################
#                 Naming		    #
#############################################

/system identity set name=Switch


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

#Listing
/interface list
add name=WAN
add name=LAN
add name=BASE
add name=VLAN


#############################################
#                  Bridge		    #
#############################################

# Bridge assignment
/interface bridge add name=bridge vlan-filtering=no

# Adding ports to the bridge
/interface bridge port
add bridge=bridge frame-types=admit-only-untagged-and-priority-tagged interface=ether2 pvid=10
add bridge=bridge frame-types=admit-only-untagged-and-priority-tagged interface=ether3 pvid=99
add bridge=bridge frame-types=admit-only-untagged-and-priority-tagged interface=ether4 pvid=10
add bridge=bridge frame-types=admit-only-untagged-and-priority-tagged interface=ether5 pvid=99
add bridge=bridge frame-types=admit-only-untagged-and-priority-tagged interface=ether6 pvid=10
add bridge=bridge frame-types=admit-only-untagged-and-priority-tagged interface=ether7 pvid=99
add bridge=bridge frame-types=admit-only-untagged-and-priority-tagged interface=ether8 pvid=10
add bridge=bridge frame-types=admit-only-untagged-and-priority-tagged interface=ether9 pvid=99
add bridge=bridge frame-types=admit-only-untagged-and-priority-tagged interface=ether10 pvid=10
add bridge=bridge frame-types=admit-only-untagged-and-priority-tagged interface=ether11 pvid=99
add bridge=bridge frame-types=admit-only-untagged-and-priority-tagged interface=ether12 pvid=10
add bridge=bridge frame-types=admit-only-untagged-and-priority-tagged interface=ether13 pvid=99
add bridge=bridge frame-types=admit-only-untagged-and-priority-tagged interface=ether14 pvid=10
add bridge=bridge frame-types=admit-only-untagged-and-priority-tagged interface=ether15 pvid=99
add bridge=bridge frame-types=admit-only-untagged-and-priority-tagged interface=ether16 pvid=10
add bridge=bridge frame-types=admit-only-untagged-and-priority-tagged interface=ether17 pvid=99
add bridge=bridge frame-types=admit-only-untagged-and-priority-tagged interface=ether18 pvid=10
add bridge=bridge frame-types=admit-only-untagged-and-priority-tagged interface=ether19 pvid=99
add bridge=bridge frame-types=admit-only-untagged-and-priority-tagged interface=ether20 pvid=10
add bridge=bridge frame-types=admit-only-untagged-and-priority-tagged interface=ether21 pvid=99
add bridge=bridge frame-types=admit-only-untagged-and-priority-tagged interface=ether22 pvid=10
add bridge=bridge frame-types=admit-only-untagged-and-priority-tagged interface=ether23 pvid=99
add bridge=bridge frame-types=admit-only-untagged-and-priority-tagged interface=ether24 pvid=10
# SFP+ ports are not used in my setup, so they are left in bridge without any changes
add bridge=bridge interface=sfp-sfpplus1
add bridge=bridge interface=sfp-sfpplus2


#############################################
#                Trunk ports		    #
#############################################

# Ether1 will be the trunk port
add bridge=bridge frame-types=admit-only-vlan-tagged interface=ether1

/interface bridge vlan
add bridge=bridge tagged=ether1 vlan-ids=10
add bridge=bridge tagged=bridge,ether1 vlan-ids=99


#############################################
#        	IP Addressing		    #
#############################################

/interface vlan add interface=bridge name=vlan-base vlan-id=99

#Router will handle DHCP, DNS and other IP services


#############################################
#          Interface List Members	    #
#############################################

/interface list member
add interface=bridge list=LAN
add interface=ether1 list=WAN
add interface=vlan-10 list=VLAN
add interface=vlan-base list=BASE
add interface=vlan-base list=VLAN

#############################################
#               Enabling VLANs 		    #
#############################################

/interface bridge set bridge vlan-filtering=yes