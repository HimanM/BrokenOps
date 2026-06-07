import libvirt
import xml.etree.ElementTree as ET
import os

DEFAULT_NETWORK_XML = """
<network>
  <name>default</name>
  <forward mode='nat'/>
  <bridge name='virbr0' stp='on' delay='0'/>
  <ip address='192.168.122.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.122.2' end='192.168.122.254'/>
    </dhcp>
  </ip>
</network>
"""

class LabEngine:
    def __init__(self, qemu_uri: str = "qemu:///system"):
        try:
            self.conn = libvirt.open(qemu_uri)
        except libvirt.libvirtError as e:
            print(f"Failed to connect to libvirt: {e}")
            self.conn = None

    def _map_to_host_path(self, path: str) -> str:
        host_root = os.environ.get("HOST_PROJECT_ROOT")
        if host_root and path.startswith("/app"):
            return path.replace("/app", host_root, 1)
        return path

    def _generate_domain_xml(self, name, memory_mb, vcpus, disk_path, cloud_iso_path):
        disk_path_host = self._map_to_host_path(disk_path)
        cloud_iso_path_host = self._map_to_host_path(cloud_iso_path)
        
        # Check if KVM is available, otherwise fallback to QEMU TCG
        domain_type = "kvm"
        if not os.path.exists("/dev/kvm"):
            print("WARNING: /dev/kvm not found. Falling back to 'qemu' (TCG) emulation.", flush=True)
            domain_type = "qemu"

        # A simple QEMU/KVM domain XML
        xml = f"""
        <domain type='{domain_type}'>
          <name>{name}</name>
          <memory unit='MiB'>{memory_mb}</memory>
          <vcpu placement='static'>{vcpus}</vcpu>
          <os>
            <type arch='x86_64' machine='pc'>hvm</type>
            <boot dev='hd'/>
          </os>
          <devices>
            <disk type='file' device='disk'>
              <driver name='qemu' type='qcow2'/>
              <source file='{disk_path_host}'/>
              <target dev='vda' bus='virtio'/>
            </disk>
            <disk type='file' device='cdrom'>
              <driver name='qemu' type='raw'/>
              <source file='{cloud_iso_path_host}'/>
              <target dev='hda' bus='ide'/>
              <readonly/>
            </disk>
            <serial type='file'>
              <source path='/var/log/libvirt/qemu/{name}-serial.log'/>
              <target port='0'/>
            </serial>
            <console type='file'>
              <source path='/var/log/libvirt/qemu/{name}-serial.log'/>
              <target type='serial' port='0'/>
            </console>
            <interface type='network'>
              <source network='default'/>
              <model type='virtio'/>
            </interface>
            <graphics type='vnc' port='-1'/>
          </devices>
        </domain>
        """
        return xml

    def ensure_default_network(self):
        if not self.conn:
            return False, "Not connected to libvirt"

        try:
            network = self.conn.networkLookupByName("default")
        except libvirt.libvirtError:
            try:
                network = self.conn.networkDefineXML(DEFAULT_NETWORK_XML)
            except libvirt.libvirtError as e:
                return False, f"libvirt default network is missing and could not be defined: {e}"

        try:
            if not network.isActive():
                network.create()
            network.setAutostart(1)
            return True, ""
        except libvirt.libvirtError as e:
            return False, (
                "libvirt default network is not active and could not be started. "
                "On the host, run: sudo virsh net-start default && sudo virsh net-autostart default. "
                f"Original error: {e}"
            )

    def launch_vm(self, name: str, disk_path: str, cloud_iso_path: str, memory_mb: int = 1024, vcpus: int = 1):
        if not self.conn:
            return False, "Not connected to libvirt"

        network_ok, network_error = self.ensure_default_network()
        if not network_ok:
            return False, network_error
        
        xml = self._generate_domain_xml(name, memory_mb, vcpus, disk_path, cloud_iso_path)
        
        # Check if domain exists
        try:
            dom = self.conn.lookupByName(name)
            if dom.isActive():
                dom.destroy()
            dom.undefine()
        except libvirt.libvirtError:
            pass

        try:
            dom = self.conn.createXML(xml, 0)
            return True, ""
        except libvirt.libvirtError as e:
            print(f"ERROR: Failed to create VM {name}: {e}", flush=True)
            # Log the XML for debugging
            print(f"DEBUG: XML used for {name}:\n{xml}", flush=True)
            return False, str(e)

    def get_vm_ip(self, name: str) -> str:
        if not self.conn:
            return None
        try:
            dom = self.conn.lookupByName(name)
            # Fetch DHCP leases from the default network interface
            ifaces = dom.interfaceAddresses(libvirt.VIR_DOMAIN_INTERFACE_ADDRESSES_SRC_LEASE, 0)
            if ifaces:
                for (name, val) in ifaces.items():
                    if val['addrs']:
                        for ipaddr in val['addrs']:
                            if ipaddr['type'] == libvirt.VIR_IP_ADDR_TYPE_IPV4:
                                return ipaddr['addr']
            return None
        except libvirt.libvirtError:
            return None

    def stop_vm(self, name: str) -> bool:
        if not self.conn:
            return False
        try:
            dom = self.conn.lookupByName(name)
            if dom.isActive():
                dom.destroy() # Forcefully shutdown
            dom.undefine() # Remove definition
            return True
        except libvirt.libvirtError as e:
            print(f"Failed to stop VM {name}: {e}")
            return False

    def close(self):
        if self.conn:
            self.conn.close()
