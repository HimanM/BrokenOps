import os
import sys
import time
import requests
import paramiko
import argparse
import socket
import yaml

API_URL = "http://localhost/api"

def check_ssh_ready(ip, port=22, timeout=60):
    start = time.time()
    while time.time() - start < timeout:
        try:
            with socket.create_connection((ip, port), timeout=2):
                return True
        except (socket.timeout, ConnectionRefusedError, OSError):
            time.sleep(2)
    return False

def run_ssh_command(ip, username, key_filename, command):
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(ip, username=username, key_filename=key_filename)
    stdin, stdout, stderr = client.exec_command(command)
    exit_status = stdout.channel.recv_exit_status()
    out = stdout.read().decode().strip()
    err = stderr.read().decode().strip()
    client.close()
    return exit_status, out, err

def upload_and_run(ip, username, key_filename, local_script, remote_script):
    # For full-disk labs, we can't upload via SFTP because the disk is full.
    # Instead, we pipe the script directly to bash.
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(ip, username=username, key_filename=key_filename)
    
    with open(local_script, 'r') as f:
        script_content = f.read().replace("\r\n", "\n").replace("\r", "\n")
        
    stdin, stdout, stderr = client.exec_command("sudo bash -s")
    stdin.write(script_content)
    stdin.channel.shutdown_write()
    
    exit_status = stdout.channel.recv_exit_status()
    out = stdout.read().decode().strip()
    err = stderr.read().decode().strip()
    client.close()
    return exit_status, out, err

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--key", required=True, help="Path to SSH private key")
    parser.add_argument("--labs", help="Comma-separated list of lab IDs to test")
    args = parser.parse_args()

    # Ensure key has correct permissions (600) so SSH doesn't reject it
    try:
        os.chmod(args.key, 0o600)
    except Exception as e:
        print(f"⚠️ Warning: Could not set permissions on {args.key}: {e}")

    # Get labs
    print("Fetching labs...")
    resp = requests.get(f"{API_URL}/labs")
    if resp.status_code != 200:
        print(f"Failed to get labs: {resp.text}")
        sys.exit(1)
        
    labs = resp.json()
    
    if args.labs:
        target_labs = args.labs.split(',')
        labs = [lab for lab in labs if lab['id'] in target_labs]
        if not labs:
            print(f"None of the target labs ({args.labs}) were found in the API.")
            sys.exit(0)
            
    if not labs:
        print("No labs found.")
        sys.exit(0)

    all_passed = True

    for lab in labs:
        lab_id = lab['id']
        print(f"\n======================================")
        print(f"🧪 Testing Lab: {lab_id}")
        print(f"======================================")

        solution_path = os.path.join("labs", lab_id, "solution.sh")
        verify_path = os.path.join("labs", lab_id, "verify.sh")

        if not os.path.exists(solution_path):
            print(f"❌ Missing mandatory solution.sh for lab {lab_id}")
            all_passed = False
            continue

        if not os.path.exists(verify_path):
            print(f"❌ Missing mandatory verify.sh for lab {lab_id}")
            all_passed = False
            continue

        # Launch VM
        print(f"🚀 Launching VM for {lab_id}...")
        launch_resp = requests.post(f"{API_URL}/labs/{lab_id}/launch")
        if launch_resp.status_code != 200:
            print(f"❌ Failed to launch: {launch_resp.text}")
            all_passed = False
            continue

        # Wait for IP
        ip = None
        for _ in range(30):
            status_resp = requests.get(f"{API_URL}/labs/{lab_id}/status")
            status_data = status_resp.json()
            if status_data.get("status") == "running" and status_data.get("ip"):
                ip = status_data["ip"]
                break
            time.sleep(2)

        if not ip:
            print(f"❌ VM did not get an IP in time.")
            requests.post(f"{API_URL}/labs/{lab_id}/stop")
            all_passed = False
            continue

        print(f"🌐 VM is up at {ip}. Waiting for SSH...")
        if not check_ssh_ready(ip):
            print(f"❌ SSH never became ready.")
            requests.post(f"{API_URL}/labs/{lab_id}/stop")
            all_passed = False
            continue
            
        print("⏳ Waiting for cloud-init to finish provisioning...")
        code, out, err = run_ssh_command(ip, "root", args.key, "cloud-init status --wait")
        if code != 0:
            print(f"⚠️ Warning: cloud-init wait returned exit code {code}")
            
        try:
            print("🔍 Running verify.sh (Initial check to ensure lab is broken)...")
            code, out, err = upload_and_run(ip, "root", args.key, verify_path, "/tmp/verify.sh")
            if code == 0:
                print(f"❌ verify.sh unexpectedly passed before running the solution! The lab might not be properly broken.")
                print(f"Stdout: {out}\nStderr: {err}")
                all_passed = False
                continue
                
            print("✅ Initial verify.sh failed as expected (Lab is properly broken).")

            with open(os.path.join("labs", lab_id, "lab.yaml"), "r") as f:
                lab_yaml = yaml.safe_load(f)
                exposed_ports = lab_yaml.get("exposed_ports", [])

            # For labs with exposed ports, ensure they are broken initially
            for port in exposed_ports:
                print(f"📡 Testing exposed port {port} via backend proxy API to ensure it's broken initially...")
                try:
                    proxy_resp = requests.get(f"{API_URL}/labs/{lab_id}/proxy/{port}", allow_redirects=False, timeout=10)
                    if proxy_resp.status_code not in [502, 500] and not (proxy_resp.status_code in [302, 307] and proxy_resp.headers.get("location") == "/404"):
                        # In selinux-web-root, Nginx returns 403 Forbidden which proves the port is open but access is denied. 
                        # We might not want to fail CI here if it's 403, but let's assume "broken" means it shouldn't return 200 OK.
                        if proxy_resp.status_code == 200:
                            print(f"❌ Proxy unexpectedly reached port {port} and returned 200 OK before the solution! The port is not properly broken.")
                            all_passed = False
                            continue
                        else:
                            print(f"✅ Initial proxy check returned {proxy_resp.status_code} (Port is restricted/broken).")
                    else:
                        print(f"✅ Initial proxy check failed as expected (Status {proxy_resp.status_code}).")
                except Exception as e:
                    print(f"⚠️ Failed to reach proxy API (Error: {e}). This is expected for a broken lab.")

            print("🔧 Running solution.sh...")
            code, out, err = upload_and_run(ip, "root", args.key, solution_path, "/tmp/solution.sh")
            if code != 0:
                print(f"❌ solution.sh failed with exit code {code}")
                print(f"Stdout: {out}\nStderr: {err}")
                all_passed = False
                continue
                
            print("✅ solution.sh executed successfully.")

            print("🔍 Running verify.sh...")
            code, out, err = upload_and_run(ip, "root", args.key, verify_path, "/tmp/verify.sh")
            if code != 0:
                print(f"❌ verify.sh failed with exit code {code}")
                print(f"Stdout: {out}\nStderr: {err}")
                all_passed = False
                continue
                
            print("✅ verify.sh passed successfully.")

            # Check exposed ports via proxy API
            with open(os.path.join("labs", lab_id, "lab.yaml"), "r") as f:
                lab_yaml = yaml.safe_load(f)
                exposed_ports = lab_yaml.get("exposed_ports", [])
            
            for port in exposed_ports:
                print(f"📡 Testing exposed port {port} via backend proxy API...")
                try:
                    proxy_resp = requests.get(f"{API_URL}/labs/{lab_id}/proxy/{port}", allow_redirects=False, timeout=10)
                    if proxy_resp.status_code == 502:
                        print(f"❌ Proxy returned 502 Bad Gateway for port {port}. The service inside the VM might not be listening on this port.")
                        all_passed = False
                    elif proxy_resp.status_code in [302, 307] and proxy_resp.headers.get("location") == "/404":
                        print(f"❌ Proxy redirected to /404 for port {port}. This port is either not configured correctly in lab.yaml or the VM is down.")
                        all_passed = False
                    else:
                        print(f"✅ Proxy successfully reached port {port} inside the VM (Status {proxy_resp.status_code}).")
                except Exception as e:
                    print(f"❌ Failed to reach proxy API for port {port}: {e}")
                    all_passed = False

        except Exception as e:
            print(f"❌ Error during SSH execution: {e}")
            all_passed = False
        finally:
            print(f"🛑 Stopping VM...")
            requests.post(f"{API_URL}/labs/{lab_id}/stop")

    if not all_passed:
        print("\n❌ Some labs failed verification.")
        sys.exit(1)
        
    print("\n✅ All labs passed verification!")

if __name__ == "__main__":
    main()
