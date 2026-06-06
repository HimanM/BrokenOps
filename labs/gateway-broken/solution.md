### The Issue

A custom Netplan configuration file `/etc/netplan/99-custom.yaml` was introduced. This configuration disables standard route inheritance from the DHCP server (`use-routes: false`) and manually sets the default gateway to `192.168.122.99`, which is a dead IP. This blocks any network routing outside the local `192.168.122.0/24` subnet.

### Step-by-Step Fix

1. **Verify routing details**:
   Check the current routing configuration of the system:
   ```bash
   ip route show
   ```
   You will notice that the `default via` route points to `192.168.122.99` instead of `192.168.122.1`.

2. **Check Netplan directory**:
   List files in the Netplan configuration folder:
   ```bash
   ls /etc/netplan/
   ```
   You should see a file named `/etc/netplan/99-custom.yaml` which overrides default settings.

3. **Remove the offending configuration file**:
   Since the VM obtains its IP and standard routes correctly from DHCP, you can safely remove the custom override file:
   ```bash
   sudo rm /etc/netplan/99-custom.yaml
   ```

4. **Apply configuration**:
   Apply the restored Netplan settings:
   ```bash
   sudo netplan apply
   ```

5. **Verify connectivity**:
   Check the routing table again and verify you can reach the internet:
   ```bash
   ip route show
   ping -c 2 8.8.8.8
   ```
