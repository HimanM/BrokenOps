### Objective

A teammate changed DNS settings on this server. Since then, the machine can reach raw IP addresses (for example `8.8.8.8`) but domain names (for example `google.com`) fail to resolve.

Your task is to:
1. Confirm the difference between IP connectivity and DNS lookup.
2. Investigate the resolver configuration.
3. Fix DNS so domain name resolution works again.

### Useful Commands
- `ping -c 2 google.com`
- `ping -c 2 8.8.8.8`
- `cat /etc/resolv.conf`
- `systemctl status systemd-resolved`
