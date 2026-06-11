### The Issue
Firewall rules in `iptables` are processed in **sequential order** from top to bottom. The first rule that matches a packet determines its fate (ACCEPT, DROP, REJECT). 

In this case, a broad `DROP` rule was added that covered a range of ports including port 80. Although an `ACCEPT` rule for port 80 also existed, it was placed *after* the `DROP` rule. Consequently, all HTTP traffic was dropped before it could reach the `ACCEPT` rule.

### Step-by-Step Fix

1. **Verify the service state**:
   ```bash
   sudo systemctl status nginx
   ```
   Confirm that the service is `active (running)`.

2. **Test locally**:
   ```bash
   curl -I http://localhost
   ```
   This should return `HTTP/1.1 200 OK` (because loopback is allowed).

3. **Inspect the firewall rules**:
   ```bash
   sudo iptables -L INPUT -n --line-numbers
   ```
   Identify the conflicting rules:
   *   A `DROP` rule for `dpts:80:100`.
   *   An `ACCEPT` rule for `dpt:80` further down the list.

4. **Fix the rule order**:
   You can either delete the rules and add them in the correct order, or insert the `ACCEPT` rule before the `DROP` rule.
   
   Identify the line number of the `DROP` rule (e.g., line 4).
   Insert the `ACCEPT` rule at that position:
   ```bash
   sudo iptables -I INPUT 4 -p tcp --dport 80 -j ACCEPT
   ```

5. **Clean up**:
   Remove the old, now redundant `ACCEPT` rule at the bottom of the list.
   ```bash
   sudo iptables -D INPUT [old_line_number]
   ```

6. **Verify the fix**:
   Check the rule order again to ensure the `ACCEPT` for port 80 precedes any broader `DROP` rules.
