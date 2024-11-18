
# **MikroTik Router/Switch VLAN configuration**

This repository contains the config files for a MikroTik hAP ax3 router and Mikrotik CRS326-24G-2S+ switch. The setup is designed to create a basic VLAN-based network with management and default VLANs and Wi-Fi integration.

---

## Table of Contents
1. [Goals](#goals)
2. [Device configuration](#device-configuration)
3. [How to use](#how-to-use)

---

## Goals

### Security
- Restrict access to the router's and switch's control panel (WinBox/web) to devices in the **management VLAN (BASE VLAN)**.
- Disable unused services for improved security.

### VLANs
- **VLAN 10 (Default VLAN):** For recognized devices, with IP range `192.168.10.0/24`.
- **VLAN 99 (Base VLAN):** Management VLAN, used for router administration, with IP range `192.168.1.0/24`.

### Centralized Management
   - Router handles all DHCP, DNS, and NAT services.
   - Switch operates in bridge mode for VLAN tagging and segmentation.

### Wi-Fi
- Configure two Wi-Fi networks with secure protocols (`WPA2-PSK` and `WPA3-PSK`):
  - **5GHz Wi-Fi**
  - **2.4GHz Wi-Fi**

---

## Device configuration

### Router

The router configuration can be found in `router-cfg.rsc`. Key elements:
- **VLAN Interfaces and IP Pools:**
  - **VLAN 10:** `192.168.10.0/24`
  - **VLAN 99:** `192.168.1.0/24`
- **Firewall Rules:**
  - Allows management access from VLAN 99.
  - Blocks unauthorized access to sensitive services.
  - Enables internet access for all VLANs.
- **Wi-Fi Setup:**
  - Separate SSIDs for 5 GHz and 2.4 GHz bands with WPA2/WPA3 encryption.
- **Emergency Port:** 
  - `ether5` is untagged and reserved for fallback access.



---

### Switch

The switch configuration can be found in `switch-cfg.rsc`. Key elements:
- **Bridge and VLAN Setup:**
  - All switch ports are part of a single bridge.
  - VLAN tagging is applied on the bridge for proper segmentation.
- **Trunk Port:**
  - `ether1` is configured as the trunk port for VLAN tagging.
- **Odd/Even Port Assignments:**
  - Odd ports (e.g., `ether3, ether5, ...`) are assigned to VLAN 99.
  - Even ports (e.g., `ether2, ether4, ...`) are assigned to VLAN 10.


---

## How to Use

1. **Router Configuration:**
   - Upload `router-config.rsc` to the Mikrotik router.
   - Import the configuration via terminal:
     ```bash
     /import file=router-config.rsc
     ```

2. **Switch Configuration:**
   - Upload `switch-config.rsc` to the Mikrotik switch.
   - Import the configuration via terminal:
     ```bash
     /import file=switch-config.rsc
     ```


3. **Adjust as Needed:**
   - Update IP pools or VLAN settings based on your requirements.
   - Test with dummy devices to ensure VLAN tagging works as expected.
