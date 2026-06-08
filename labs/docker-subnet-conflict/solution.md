### The Issue
The container was attached to a custom Docker network (`broken_net`) configured with a subnet that overlaps with the host's primary physical network interface. Because the host's IP falls within this container subnet, the container's networking stack assumes that IP address is on the local Docker network segment. Instead of routing the traffic through the default gateway, it attempts to find the host locally on the Docker bridge via ARP, which fails.

### Step-by-Step Fix

1. **Verify the problem**:
   Confirm that the container cannot reach the host IP (`10.99.99.99` in this lab).
   ```bash
   HOST_IP="10.99.99.99"
   docker exec app_container ping -c 1 $HOST_IP
   ```

2. **Inspect the container's network**:
   Find out which network the container is connected to.
   ```bash
   docker inspect app_container | grep -A 10 "Networks"
   ```
   You will see it is attached to `broken_net`.

3. **Inspect the Docker network**:
   Look at the subnet configuration for `broken_net` and compare it to the host's subnet.
   ```bash
   docker network inspect broken_net
   ip a
   ```
   You will notice the `Subnet` matches the host's physical network.

4. **Fix the configuration**:
   To fix this, you must recreate the network with a safe, non-conflicting private RFC1918 subnet (e.g., `172.30.0.0/24`).
   
   Remove the container (or disconnect it):
   ```bash
   docker rm -f app_container
   ```
   
   Remove the conflicting network:
   ```bash
   docker network rm broken_net
   ```
   
   Create a new safe network:
   ```bash
   docker network create --subnet=172.30.0.0/24 safe_net
   ```
   
   Restart the container on the new network:
   ```bash
   docker run -d --name app_container --network safe_net alpine sleep infinity
   ```

5. **Verify the fix**:
   ```bash
   docker exec app_container ping -c 1 $HOST_IP
   ```
   The ping should now succeed.
