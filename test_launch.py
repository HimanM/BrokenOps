from backend.lab_parser import LabParser
from backend.engine import LabEngine
import os

engine = LabEngine()
try:
    print("Stopping first...")
    engine.stop_vm("nginx-lab")
    print("Launching...")
    base = os.path.abspath("data/images/ubuntu-24.04-base.qcow2")
    overlay = os.path.abspath("data/vms/nginx-lab-overlay.qcow2")
    iso = os.path.abspath("data/vms/nginx-lab-cloud-init.iso")
    print(engine.launch_vm("nginx-lab", overlay, iso, 1024, 1))
except Exception as e:
    print(e)
