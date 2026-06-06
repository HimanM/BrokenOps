import yaml
import os
import subprocess
import asyncio
import asyncssh
from fastapi import FastAPI, HTTPException, WebSocket, WebSocketDisconnect, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
from typing import List, Optional
from lab_parser import LabParser
import subprocess
from lab_parser import LabParser
from cloud_init import CloudInitBuilder
from engine import LabEngine
import time
import glob
from contextlib import asynccontextmanager
import httpx

LAB_TIMEOUT_SECONDS = 3600

async def cleanup_expired_labs():
    while True:
        try:
            vms_dir = os.path.join(PROJECT_ROOT, "data", "vms")
            if os.path.exists(vms_dir):
                ready_files = glob.glob(os.path.join(vms_dir, "*.ready"))
                now = time.time()
                for ready_file in ready_files:
                    mtime = os.path.getmtime(ready_file)
                    if now - mtime >= LAB_TIMEOUT_SECONDS:
                        lab_id = os.path.basename(ready_file).replace(".ready", "")
                        print(f"Lab {lab_id} expired. Stopping VM.")
                        # Parse lab to get VM name and stop it
                        try:
                            parser = LabParser(PROJECT_ROOT)
                            engine = LabEngine()
                            lab_config = parser.parse_lab(lab_id)
                            vm_name = lab_config["vm"]["name"]
                            engine.stop_vm(vm_name)
                            engine.close()
                        except Exception as e:
                            print(f"Error stopping expired lab {lab_id}: {e}")
                        
                        try:
                            os.remove(ready_file)
                        except Exception:
                            pass
        except Exception as e:
            print(f"Error in cleanup task: {e}")
            
        await asyncio.sleep(60)

@asynccontextmanager
async def lifespan(app: FastAPI):
    task = asyncio.create_task(cleanup_expired_labs())
    yield
    task.cancel()

app = FastAPI(title="BrokenOps Backend", lifespan=lifespan)

# Initialize global components
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
if os.path.exists(os.path.join(BASE_DIR, "data")):
    PROJECT_ROOT = BASE_DIR
else:
    PROJECT_ROOT = os.path.join(BASE_DIR, "..")

def map_to_host_path(path: str) -> str:
    host_root = os.environ.get("HOST_PROJECT_ROOT")
    if host_root and path.startswith("/app"):
        return path.replace("/app", host_root, 1)
    return path

LABS_DIR = os.path.join(PROJECT_ROOT, "labs")
DATA_DIR = os.path.join(PROJECT_ROOT, "data")
IMAGES_DIR = os.path.join(DATA_DIR, "images")
VMS_DIR = os.path.join(DATA_DIR, "vms")

os.makedirs(VMS_DIR, exist_ok=True)

parser = LabParser(LABS_DIR)
cloud_builder = CloudInitBuilder(VMS_DIR)
engine = LabEngine()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class LabInfo(BaseModel):
    id: str
    name: str
    category: str
    difficulty: str
    description: dict

@app.get("/labs", response_model=List[LabInfo])
def list_labs():
    labs = []
    if os.path.exists(LABS_DIR):
        for lab_folder in os.listdir(LABS_DIR):
            lab_yaml = os.path.join(LABS_DIR, lab_folder, "lab.yaml")
            if os.path.exists(lab_yaml):
                with open(lab_yaml, "r") as f:
                    data = yaml.safe_load(f)
                    labs.append(LabInfo(
                        id=data.get("id"),
                        name=data.get("name"),
                        category=data.get("category"),
                        difficulty=data.get("difficulty"),
                        description=data.get("description", {})
                    ))
    return labs

@app.get("/labs/{lab_id}")
def get_lab(lab_id: str):
    try:
        return parser.parse_lab(lab_id)
    except FileNotFoundError:
        raise HTTPException(status_code=404, detail="Lab not found")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/labs/{lab_id}/launch")
def launch_lab(lab_id: str):
    try:
        lab_config = parser.parse_lab(lab_id)
        
        vm_name = lab_config["vm"]["name"]
        memory_mb = lab_config["vm"]["memory"]
        vcpus = lab_config["vm"]["cpu"]
        disk_size = str(lab_config["vm"]["disk"])
        exposed_ports = lab_config.get("exposed_ports", [])
        
        # Paths
        base_image_path = os.path.join(IMAGES_DIR, "ubuntu-24.04-base.qcow2")
        overlay_path = os.path.join(VMS_DIR, f"{vm_name}-overlay.qcow2")
        cloud_init_yaml_path = os.path.join(LABS_DIR, lab_id, lab_config["cloud_init"])
        
        # Verify base image exists
        if not os.path.exists(base_image_path):
            raise HTTPException(status_code=500, detail="Base image not found. Please download it first.")
            
        ready_file = os.path.join(PROJECT_ROOT, "data", "vms", f"{lab_id}.ready")
        if os.path.exists(ready_file):
            try:
                os.remove(ready_file)
            except Exception:
                pass
                
        engine.stop_vm(vm_name)
        
        if os.path.exists(overlay_path):
            os.remove(overlay_path)
            
        # Create overlay qcow2 using the host path for the backing file (with -u to skip check)
        base_image_path_host = map_to_host_path(base_image_path)
        subprocess.run([
            "qemu-img", "create", "-f", "qcow2", "-F", "qcow2", "-u",
            "-b", base_image_path_host, overlay_path, disk_size
        ], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        
        # Read cloud-init user-data
        with open(cloud_init_yaml_path, "r") as f:
            user_data_content = f.read().replace("\r\n", "\n").replace("\r", "\n")
            
        # Inject SSH key
        ssh_pub_key_path = os.path.join(PROJECT_ROOT, "keys", "id_ed25519.pub")
        if os.path.exists(ssh_pub_key_path):
            with open(ssh_pub_key_path, "r") as f:
                pub_key = f.read().strip()
                
            # Parse YAML to safely append to users block
            try:
                ud_yaml = yaml.safe_load(user_data_content) or {}
                
                # Allow root SSH login
                ud_yaml["disable_root"] = False
                if "users" not in ud_yaml or not isinstance(ud_yaml["users"], list):
                    ud_yaml["users"] = [{"name": "root", "ssh_authorized_keys": []}]
                
                if "runcmd" not in ud_yaml or not isinstance(ud_yaml["runcmd"], list):
                    ud_yaml["runcmd"] = []
                ud_yaml["runcmd"].insert(0, "systemctl restart ssh || systemctl restart sshd")
                ud_yaml["runcmd"].insert(0, "sed -i 's/.*PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/* || true")

                # Find root user or create it
                root_user = next((u for u in ud_yaml["users"] if isinstance(u, dict) and u.get("name") == "root"), None)
                if not root_user:
                    root_user = {"name": "root", "ssh_authorized_keys": []}
                    ud_yaml["users"].append(root_user)
                
                if "ssh_authorized_keys" not in root_user:
                    root_user["ssh_authorized_keys"] = []
                    
                root_user["ssh_authorized_keys"].append(pub_key)
                
                user_data_content = "#cloud-config\n" + yaml.dump(ud_yaml, width=10000)
            except Exception as e:
                print(f"Warning: Failed to parse user-data YAML: {e}")

        # Build cloud-init ISO
        iso_path = cloud_builder.build_iso(vm_name, user_data_content)
        
        # Launch VM
        success = engine.launch_vm(
            name=vm_name,
            disk_path=overlay_path,
            cloud_iso_path=iso_path,
            memory_mb=memory_mb,
            vcpus=vcpus,
            exposed_ports=exposed_ports
        )
        
        if not success:
            raise HTTPException(status_code=500, detail="Failed to launch Libvirt VM")
            
        return {"status": "launched", "lab_id": lab_id, "vm_name": vm_name, "exposed_ports": exposed_ports}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.delete("/labs/{lab_id}/stop")
def stop_lab(lab_id: str):
    try:
        lab_config = parser.parse_lab(lab_id)
        vm_name = lab_config["vm"]["name"]
        
        engine.stop_vm(vm_name) # Ignore success/failure so reset works
        
        ready_file = os.path.join(PROJECT_ROOT, "data", "vms", f"{lab_id}.ready")
        if os.path.exists(ready_file):
            try:
                os.remove(ready_file)
            except Exception:
                pass
            
        return {"status": "stopped", "lab_id": lab_id}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/labs/{lab_id}/reset")
def reset_lab(lab_id: str):
    try:
        # First stop the lab
        stop_lab(lab_id)
        # Then launch it (launch cleans up the old overlay)
        return launch_lab(lab_id)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/labs/{lab_id}/status")
async def lab_status(lab_id: str):
    try:
        lab_config = parser.parse_lab(lab_id)
        vm_name = lab_config["vm"]["name"]
        exposed_ports = lab_config.get("exposed_ports", [])
        
        vm_ip = engine.get_vm_ip(vm_name)
        if not vm_ip:
            return {"status": "stopped", "ip": None, "port_mappings": {}}
            
        # We have an IP, check if cloud-init is done
        ssh_key_path = os.path.join(PROJECT_ROOT, "keys", "id_ed25519")
        try:
            async with asyncssh.connect(vm_ip, username="root", client_keys=[ssh_key_path], known_hosts=None, connect_timeout=1) as conn:
                result = await conn.run("cloud-init status", check=False)
                if "status: running" in str(result.stdout):
                    return {"status": "provisioning", "ip": vm_ip, "port_mappings": {}}
                else:
                    ready_file = os.path.join(PROJECT_ROOT, "data", "vms", f"{lab_id}.ready")
                    if not os.path.exists(ready_file):
                        with open(ready_file, "w") as f:
                            f.write("ready")
                        
                        # Setup port forwarding when VM becomes ready
                        if exposed_ports:
                            port_mappings = engine.setup_port_forwards(vm_name, exposed_ports)
                            print(f"Port mappings for {vm_name}: {port_mappings}")
                    
                    # Get current port mappings
                    port_mappings = engine.get_port_mappings(vm_name)
                    
                    mtime = os.path.getmtime(ready_file)
                    elapsed = time.time() - mtime
                    remaining = int(max(0, LAB_TIMEOUT_SECONDS - elapsed))
                    
                    if remaining <= 0:
                        stop_lab(lab_id)
                        return {"status": "stopped", "ip": None, "port_mappings": {}}
                    
                    # Get server hostname/IP
                    import socket
                    hostname = socket.gethostname()
                    host_ip = socket.gethostbyname(hostname)
                    
                    return {
                        "status": "running", 
                        "ip": vm_ip, 
                        "remaining_seconds": remaining,
                        "port_mappings": port_mappings,
                        "host_ip": host_ip,
                        "hostname": hostname
                    }
        except Exception:
            # SSH not ready yet
            return {"status": "provisioning", "ip": vm_ip, "port_mappings": {}}
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.websocket("/labs/{lab_id}/terminal")
async def websocket_terminal(websocket: WebSocket, lab_id: str):
    await websocket.accept()
    
    try:
        lab_config = parser.parse_lab(lab_id)
        vm_name = lab_config["vm"]["name"]
        
        # Poll for IP address (wait for boot)
        vm_ip = None
        for _ in range(30): # Wait up to 30s
            vm_ip = engine.get_vm_ip(vm_name)
            if vm_ip:
                break
            await asyncio.sleep(1)
            
        if not vm_ip:
            await websocket.send_text("\r\n[Error] Could not obtain VM IP address.\r\n")
            await websocket.close()
            return
            
        await websocket.send_text(f"\r\n[Info] Connecting to VM at {vm_ip}...\r\n")
        
        priv_key_path = os.path.join(PROJECT_ROOT, "keys", "id_ed25519")
        
        conn = None
        for _ in range(15): # Try for up to 30 seconds
            try:
                conn = await asyncssh.connect(vm_ip, username='root', client_keys=[priv_key_path], known_hosts=None)
                break
            except Exception:
                await asyncio.sleep(2)
                
        if not conn:
            await websocket.send_text("\r\n[Error] SSH Connection timed out. VM may still be booting.\r\n")
            await websocket.close()
            return
            
        async with conn:
            async with conn.create_process('bash', term_type='xterm') as process:
                await websocket.send_text("\r\n[Info] Connected!\r\n")
                
                async def read_stdout():
                    try:
                        while not process.stdout.at_eof():
                            data = await process.stdout.read(4096)
                            if data:
                                await websocket.send_text(data)
                    except Exception:
                        pass
                        
                async def read_stderr():
                    try:
                        while not process.stderr.at_eof():
                            data = await process.stderr.read(4096)
                            if data:
                                await websocket.send_text(data)
                    except Exception:
                        pass
                        
                async def read_ws():
                    import json
                    try:
                        while True:
                            msg = await websocket.receive_text()
                            try:
                                payload = json.loads(msg)
                                if payload.get("type") == "data":
                                    process.stdin.write(payload["data"])
                                elif payload.get("type") == "resize":
                                    process.change_terminal_size(payload["cols"], payload["rows"], 0, 0)
                            except json.JSONDecodeError:
                                process.stdin.write(msg)
                    except WebSocketDisconnect:
                        process.terminate()
                        
                await asyncio.gather(read_stdout(), read_stderr(), read_ws())
                
    except Exception as e:
        await websocket.send_text(f"\r\n[Error] Terminal failed: {str(e)}\r\n")
    finally:
        try:
            await websocket.close()
        except Exception:
            pass

@app.post("/labs/{lab_id}/verify")
async def verify_lab(lab_id: str):
    try:
        lab_config = parser.parse_lab(lab_id)
        vm_name = lab_config["vm"]["name"]
        verify_script = lab_config.get("verify_script")
        
        if not verify_script:
            return {"score": "100", "output": "No verification script provided. Automatically passed."}
            
        script_path = os.path.join(LABS_DIR, lab_id, verify_script)
        if not os.path.exists(script_path):
            raise HTTPException(status_code=400, detail=f"Verify script {verify_script} not found in lab.")
            
        vm_ip = engine.get_vm_ip(vm_name)
        if not vm_ip:
            raise HTTPException(status_code=400, detail="VM is not running or hasn't obtained an IP yet.")
            
        priv_key_path = os.path.join(PROJECT_ROOT, "keys", "id_ed25519")
        
        with open(script_path, "r") as f:
            script_content = f.read().replace("\r\n", "\n").replace("\r", "\n")
            
        async with asyncssh.connect(vm_ip, username='root', client_keys=[priv_key_path], known_hosts=None) as conn:
            # Run the script by piping it to bash
            result = await conn.run('sudo bash', input=script_content, check=False)
            
            output = result.stdout + result.stderr
            score = "100" if result.exit_status == 0 else "0"
            
            return {"score": score, "output": output}
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.api_route("/labs/{lab_id}/proxy/{vm_port:int}/{path:path}", methods=["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS", "HEAD"])
async def proxy_to_vm(lab_id: str, vm_port: int, path: str, request: Request):
    """Reverse proxy requests to VM exposed ports"""
    try:
        lab_config = parser.parse_lab(lab_id)
        vm_name = lab_config["vm"]["name"]
        exposed_ports = lab_config.get("exposed_ports", [])
        
        # Security check: only allow proxying to exposed ports
        if vm_port not in exposed_ports:
            raise HTTPException(status_code=403, detail=f"Port {vm_port} is not exposed by this lab")
        
        # Get VM IP and port mapping info
        port_info = engine.get_vm_port_info(vm_name, vm_port)
        if not port_info:
            raise HTTPException(status_code=503, detail=f"Port {vm_port} not available. Lab may not be running.")
        
        vm_ip, host_port = port_info
        
        # Build target URL
        target_url = f"http://{vm_ip}:{vm_port}/{path}"
        if request.url.query:
            target_url += f"?{request.url.query}"
        
        # Forward the request
        async with httpx.AsyncClient(timeout=30.0) as client:
            # Get request body if present
            body = await request.body()
            
            # Forward headers (exclude host)
            headers = {k: v for k, v in request.headers.items() if k.lower() != 'host'}
            
            response = await client.request(
                method=request.method,
                url=target_url,
                headers=headers,
                content=body,
                follow_redirects=False
            )
            
            # Return proxied response
            return StreamingResponse(
                content=response.iter_bytes(),
                status_code=response.status_code,
                headers=dict(response.headers),
                media_type=response.headers.get('content-type')
            )
            
    except httpx.RequestError as e:
        raise HTTPException(status_code=502, detail=f"Failed to connect to VM service: {str(e)}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
