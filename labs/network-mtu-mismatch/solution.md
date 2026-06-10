### The Issue
MTU (Maximum Transmission Unit) defines the largest size of a packet that can be sent over a network interface. The standard MTU for Ethernet is **1500 bytes**. 

If the server's MTU is set significantly lower than the rest of the network path, large packets (like those used in HTTP responses) will be fragmented or dropped if the "Don't Fragment" (DF) bit is set. Conversely, small packets like ICMP (ping) often fall below the low threshold and continue to work, masking the underlying connectivity problem.

### Step-by-Step Fix

1. **Verify the symptom**:
   Try to download the large test file.
   ```bash
   curl http://localhost/largefile.bin -o /dev/null
   ```
   The command will likely hang or fail.

2. **Test with different packet sizes**:
   Use `ping` with the `-s` (size) and `-M do` (don't fragment) flags to find the limit.
   ```bash
   ping -s 500 -M do localhost  # Works
   ping -s 1472 -M do localhost # Fails
   ```

3. **Check interface configuration**:
   ```bash
   ip link show eth0
   ```
   You will see `mtu 600` in the output.

4. **Inspect persistent configuration**:
   Check the Netplan configuration files.
   ```bash
   cat /etc/netplan/60-mtu.yaml
   ```
   You will find `mtu: 600` explicitly set.

5. **Fix the configuration**:
   Edit the file and set `mtu: 1500` (or remove the line to use the default).
   ```yaml
   ethernets:
     eth0:
       dhcp4: true
       mtu: 1500
   ```

6. **Apply the fix**:
   ```bash
   sudo ip link set dev eth0 mtu 1500
   sudo netplan apply
   ```

7. **Verify the fix**:
   The `curl` command should now succeed immediately.
