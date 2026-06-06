# VM Port Forwarding Feature

## Overview
This feature enables remote access to ports exposed by lab VMs when BrokenOps is hosted on a network-accessible machine. Previously, VM ports (like nginx on port 80) were only accessible from the host machine. Now they can be accessed from any device on the network.

## How It Works

### 1. **Automatic Port Mapping**
When a lab is launched with `exposed_ports` defined in `lab.yaml`, the system:
- Detects the VM's IP address once it's provisioned
- Finds available host ports (starting from 10000 + vm_port)
- Sets up iptables rules to forward traffic from host ports to VM ports

### 2. **iptables Port Forwarding**
The system creates three iptables rules for each exposed port:
- **PREROUTING** rule: Handles external traffic coming to the host
- **OUTPUT** rule: Handles localhost traffic from the host itself
- **FORWARD** rule: Allows forwarding packets to the VM

Example:
```bash
# Forward host:10080 -> VM:80
iptables -t nat -A PREROUTING -p tcp --dport 10080 -j DNAT --to-destination 192.168.122.X:80
iptables -t nat -A OUTPUT -p tcp --dport 10080 -j DNAT --to-destination 192.168.122.X:80
iptables -A FORWARD -p tcp -d 192.168.122.X --dport 80 -j ACCEPT
```

### 3. **Automatic Cleanup**
When a lab is stopped or reset:
- All iptables rules are removed
- Port mappings are cleared from memory
- Ports become available for other labs

## Usage

### Lab Configuration
Define exposed ports in your `lab.yaml`:

```yaml
exposed_ports:
  - 80    # HTTP
  - 443   # HTTPS
  - 3000  # Custom application port
```

### User Experience
1. Launch a lab with exposed ports
2. Wait for provisioning to complete
3. See "Exposed Services" section in the UI with clickable links
4. Access services from any device using: `http://<host-ip>:<mapped-port>`

### API Response
The `/labs/{lab_id}/status` endpoint now returns:

```json
{
  "status": "running",
  "ip": "192.168.122.42",
  "port_mappings": {
    "80": 10080,
    "443": 10443
  },
  "host_ip": "192.168.1.100",
  "hostname": "brokenops-server",
  "remaining_seconds": 3420
}
```

## Technical Details

### Backend Changes

#### `engine.py`
- Added `port_forwards` tracking dictionary
- `_find_available_host_port()`: Finds free ports on the host
- `_setup_port_forward()`: Creates iptables rules
- `_remove_port_forward()`: Cleans up iptables rules
- `setup_port_forwards()`: Main method to configure forwarding
- `get_port_mappings()`: Returns current port mappings
- Updated `launch_vm()` to accept `exposed_ports` parameter
- Updated `stop_vm()` to clean up port forwards

#### `main.py`
- Modified `/labs/{lab_id}/launch` to pass `exposed_ports` to engine
- Enhanced `/labs/{lab_id}/status` to:
  - Setup port forwards when VM becomes ready
  - Return port mappings, host IP, and hostname
  - Include mappings in response

### Frontend Changes

#### `LabView.tsx`
- Added `PortMapping` and `LabStatus` interfaces
- Track `portMappings`, `hostIp`, and `hostname` state
- Display port mappings in "Exposed Services" section
- Show VM port → Host port mapping for each service
- Use `window.location.hostname` for accessible URLs
- Clear port mappings on stop/reset

## Network Requirements

### Host Machine
- Backend must run with `network_mode: "host"` (already configured)
- Container requires `NET_ADMIN` and `NET_RAW` capabilities for iptables (configured in docker-compose.yml)
- `iptables` must be installed in the backend container (added to Dockerfile)
- Host must allow iptables modifications (requires elevated permissions)
- Firewall must allow incoming connections on mapped ports (10000-65535 range)

### Example Firewall Configuration
```bash
# Allow port range for lab services
iptables -A INPUT -p tcp --dport 10000:65535 -j ACCEPT
```

Or with UFW:
```bash
ufw allow 10000:65535/tcp
```

## Security Considerations

1. **Port Range**: Mapped ports start from 10000 to avoid conflicts with system services
2. **Automatic Cleanup**: Ports are closed when labs are stopped
3. **Timeout**: Labs auto-expire after 1 hour, automatically cleaning up forwards
4. **Lab-Specific**: Only ports defined in `lab.yaml` are exposed

## Use Cases

### Classroom Environment
- Instructor hosts BrokenOps on `192.168.1.100`
- Students connect from laptops on same network
- Students can verify nginx fixes by visiting `http://192.168.1.100:10080`

### Remote Learning
- BrokenOps hosted on cloud server with public IP
- Students worldwide access labs
- All services (web servers, APIs, databases) are remotely accessible

### Team Training
- DevOps team practices troubleshooting together
- Everyone can test and verify fixes independently
- No need for VPN or complex SSH tunneling

## Troubleshooting

### Port Not Accessible
1. Check if port mapping exists: `GET /api/labs/{lab_id}/status`
2. Verify iptables rules: `iptables -t nat -L -n -v`
3. Check firewall: `ufw status` or `iptables -L INPUT`
4. Verify VM service is running: Use terminal to check service status

### Port Conflict
- System automatically finds next available port
- If port range exhausted (unlikely), lab will launch but without port forwards
- Check backend logs for port forwarding errors

### Cleanup Issues
- Port forwards are removed automatically on lab stop
- Manual cleanup: `iptables -t nat -F` (flushes all NAT rules - use with caution!)

## Future Enhancements

Potential improvements:
1. **Configurable Port Range**: Allow users to set preferred port ranges
2. **SSL/TLS Support**: Automatic SSL termination for HTTPS services
3. **Port Persistence**: Save port mappings across backend restarts
4. **Port Reservation**: Allow users to request specific host ports
5. **Multi-Protocol**: Support UDP port forwarding for DNS, VPN labs

## Related Files

- `backend/engine.py` - Port forwarding logic
- `backend/main.py` - API endpoints
- `frontend/src/pages/LabView.tsx` - UI display
- `labs/*/lab.yaml` - Port configuration

## Testing

To test the feature:

1. Configure a lab with exposed ports:
```yaml
exposed_ports:
  - 80
```

2. Launch the lab and wait for "ready" status

3. Check port mappings:
```bash
curl http://localhost:8000/api/labs/nginx-broken/status
```

4. Access the service:
```bash
curl http://localhost:10080
```

5. From another machine on the network:
```bash
curl http://<host-ip>:10080
```
