### The Issue
The container was attached to a custom Docker network (`broken_net`) configured with an overlapping subnet (`8.8.8.0/24`). Because `8.8.8.8` falls within this subnet, the container's networking stack assumes that IP address is on the local network segment. Instead of routing the traffic through the default gateway to the internet, it attempts to find the host locally via ARP, which fails.

### Step-by-Step Fix

1. **Verify the problem**:
   Confirm that the container cannot reach external IPs.
   ```bash
   docker exec app_container ping -c 1 8.8.8.8
   ```

2. **Inspect the container's network**:
   Find out which network the container is connected to.
   ```bash
   docker inspect app_container | grep -A 10 "Networks"
   ```
   You will see it is attached to `broken_net`.

3. **Inspect the Docker network**:
   Look at the subnet configuration for `broken_net`.
   ```bash
   docker network inspect broken_net
   ```
   You will notice the `Subnet` is set to `8.8.8.0/24`.

4. **Fix the configuration**:
   To fix this, you must recreate the network with a safe, private RFC1918 subnet (e.g., `172.30.0.0/24`) or let Docker pick one automatically.
   
   Disconnect the container:
   ```bash
   docker network disconnect broken_net app_container
   ```
   
   Remove the conflicting network:
   ```bash
   docker network rm broken_net
   ```
   
   Create a new safe network:
   ```bash
   docker network create --subnet=172.30.0.0/24 safe_net
   ```
   
   Reconnect the container to the new network:
   ```bash
   docker network connect safe_net app_container
   ```

5. **Verify the fix**:
   ```bash
   docker exec app_container ping -c 1 8.8.8.8
   ```
   The ping should now succeed.
