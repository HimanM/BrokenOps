### The Issue
Modern Linux distributions (especially those using `systemd-networkd` or `Predictable Network Interface Names`) often name network interfaces based on their hardware location (e.g., `ens3`, `enp0s3`) rather than simple indices like `eth0`, `eth1`.

In this case, the Netplan configuration was attempting to configure an interface named `eth1`, but the actual hardware was detected and named `ens4` by the operating system. Because of this mismatch, Netplan could not apply the settings to the correct device, leaving the secondary interface unconfigured.

### Step-by-Step Fix

1. **List all network interfaces**:
   ```bash
   ip addr show
   ```
   OR
   ```bash
   ip link show
   ```
   Identify an interface that is `DOWN` or doesn't have an IP, likely named `ens4`.

2. **Inspect the Netplan configuration**:
   ```bash
   cat /etc/netplan/60-internal-nic.yaml
   ```
   Notice that the configuration block is under `eth1:`.

3. **Correct the interface name**:
   Edit the file and change `eth1` to `ens4`.
   ```yaml
   network:
     version: 2
     renderer: networkd
     ethernets:
       ens4:
         dhcp4: false
         addresses: [10.10.10.10/24]
   ```

4. **Apply the configuration**:
   ```bash
   sudo netplan apply
   ```

5. **Verify the fix**:
   Check if `ens4` now has the correct IP address.
   ```bash
   ip addr show ens4
   ```
