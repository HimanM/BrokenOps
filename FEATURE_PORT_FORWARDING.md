# VM Port Forwarding Feature (Reverse Proxy)

## Overview
This feature enables remote access to ports exposed by lab VMs when BrokenOps is hosted on a network-accessible machine. Previously, VM ports (like nginx on port 80) were only accessible from the host machine. Now they can be accessed from any device on the network through a secure reverse proxy.

## How It Works

### 1. **Reverse Proxy Architecture**
Instead of using iptables (which requires elevated privileges), the backend acts as a reverse proxy:
- Client requests go to `/api/labs/{lab_id}/proxy/{vm_port}/...`
- Backend forwards requests to the VM's internal IP
- Response is streamed back to the client
- **No elevated Docker capabilities required** (secure!)

### 2. **Port Mapping Tracking**
When a lab is launched with `exposed_ports` defined in `lab.yaml`, the system:
- Detects the VM's IP address once it's provisioned
- Allocates host port numbers for reference (10000 + vm_port)
- Tracks mappings in memory: `{vm_name: {vm_port: (vm_ip, host_port)}}`
- Sets up proxy routes dynamically

### 3. **Security**
- Only ports defined in `lab.yaml` can be accessed
- Backend validates port access before proxying
- No raw network access needed
- Standard FastAPI request/response handling

### 4. **Automatic Cleanup**
When a lab is stopped or reset:
- Port mappings are cleared from memory
- No iptables rules to clean up
- Simple and reliable

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
4. Access services via: `/api/labs/{lab_id}/proxy/{port}/`
5. Works from any device - no special network configuration needed!

### API Response
The `/labs/{lab_id}/status` endpoint returns:

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

### Proxy Endpoint
Access VM services via:
```
GET /api/labs/{lab_id}/proxy/{vm_port}/{path}
```

Examples:
- `GET /api/labs/nginx-broken/proxy/80/` - Access nginx homepage
- `GET /api/labs/nginx-broken/proxy/80/index.html` - Access specific file
- `POST /api/labs/app-lab/proxy/3000/api/users` - POST to API endpoint

## Technical Details

### Backend Changes

#### `engine.py`
- Added `port_forwards` tracking dictionary: `{vm_name: {vm_port: (vm_ip, host_port)}}`
- `_find_available_host_port()`: Finds free ports on the host (for reference)
- `setup_port_forwards()`: Creates port mapping metadata
- `get_port_mappings()`: Returns port mappings for UI
- `get_vm_port_info()`: Returns VM IP and host port for proxy
- Updated `launch_vm()` to accept `exposed_ports` parameter
- Updated `stop_vm()` to clean up port mappings

#### `main.py`
- Added `httpx` for async HTTP client
- New endpoint: `/labs/{lab_id}/proxy/{vm_port}/{path:path}`
  - Supports all HTTP methods (GET, POST, PUT, DELETE, etc.)
  - Validates port is in `exposed_ports`
  - Forwards headers and body
  - Streams response back to client
- Modified `/labs/{lab_id}/launch` to pass `exposed_ports` to engine
- Enhanced `/labs/{lab_id}/status` to:
  - Setup port forwards when VM becomes ready
  - Return port mappings, host IP, and hostname

### Frontend Changes

#### `LabView.tsx`
- Links point to `/api/labs/{lab_id}/proxy/{vm_port}/`
- Display shows "Proxied via Backend" instead of port numbers
- Opens in new tab for easy testing
- Works seamlessly from any network location

## Network Requirements

### Host Machine
- Backend must run with `network_mode: "host"` (already configured)
- **No elevated capabilities needed** ✅ (secure!)
- **No iptables required** ✅
- **No firewall configuration needed** ✅ (uses existing backend port)

## Security Advantages

### Compared to iptables approach:
1. **No elevated privileges**: No `NET_ADMIN` or `NET_RAW` capabilities
2. **Application-level control**: Full request/response inspection
3. **Easy logging**: Can log all proxied requests
4. **Rate limiting**: Can add rate limiting per lab/port
5. **Authentication**: Can add auth checks before proxying
6. **No host network pollution**: No iptables rules to manage

### Current Security Features:
- Port whitelist validation
- Only lab-specific ports accessible
- Standard HTTP security headers
- Request timeout (30 seconds)
- Automatic cleanup on lab stop

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
