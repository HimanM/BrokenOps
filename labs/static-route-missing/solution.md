### The Issue
By default, most systems only have a default gateway for external traffic and local routes for directly connected networks. If a network path is not directly reachable and is not on the internet, an explicit **static route** is required to tell the operating system which gateway to use for that specific destination CIDR.

### Step-by-Step Fix

1. **Verify the lack of connectivity**:
   ```bash
   ping -c 3 10.50.0.1
   ```
   You will get "Destination Net Unreachable" or a timeout.

2. **Check the routing table**:
   ```bash
   ip route show
   ```
   Confirm that there is no entry for `10.50.0.0/24`.

3. **Identify the correct gateway**:
   The scenario specifies that `192.168.123.1` is the gateway for this internal traffic.

4. **Add a persistent route in Netplan**:
   Ubuntu uses Netplan for network configuration. Edit your Netplan file (usually in `/etc/netplan/`).
   ```yaml
   network:
     version: 2
     renderer: networkd
     ethernets:
       eth0:
         dhcp4: true
         routes:
           - to: 10.50.0.0/24
             via: 192.168.123.1
   ```

5. **Apply the configuration**:
   ```bash
   sudo netplan apply
   ```

6. **Verify the fix**:
   Check the routing table again.
   ```bash
   ip route show | grep 10.50.0.0
   ```
   You should now see the route. Pinging the gateway or a host in that range (if simulated) should now work.
