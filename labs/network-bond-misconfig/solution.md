### The Issue
Network bonding (also known as EtherChannel or trunking) allows multiple network interfaces to act as one. The `mode` parameter defines how traffic is distributed. 

In this scenario, the bond was configured with `mode: active-backup`, which only utilizes one interface for redundancy. The requirement was for `balance-alb` (Adaptive Load Balancing), which provides both increased bandwidth and redundancy without requiring special switch support.

### Step-by-Step Fix

1. **Verify the current bond status**:
   ```bash
   cat /proc/net/bonding/bond0
   ```
   Look for the `Bonding Mode` line. You will see it is set to `fault-tolerance (active-backup)`.

2. **Inspect the Netplan configuration**:
   ```bash
   cat /etc/netplan/60-bond.yaml
   ```
   Identify that the `mode` under `parameters` is set to `active-backup`.

3. **Update the configuration**:
   Edit the Netplan file and change the mode to `balance-alb`. It's also good practice to include an `mii-monitor-interval`.
   ```yaml
   bonds:
     bond0:
       interfaces: [eth1, eth2]
       parameters:
         mode: balance-alb
         mii-monitor-interval: 100
   ```

4. **Apply the changes**:
   ```bash
   sudo netplan apply
   ```

5. **Verify the fix**:
   Check the bond status again.
   ```bash
   cat /proc/net/bonding/bond0
   ```
   The `Bonding Mode` should now be `adaptive load balancing`.
