import libvirt
import xml.etree.ElementTree as ET
import os
import subprocess
import json

class LabEngine:
    def __init__(self, qemu_uri: str = "qemu:///system"):
        try:
            self.conn = libvirt.open(qemu_uri)
        except libvirt.libvirtError as e:
            print(f"Failed to connect to libvirt: {e}")
            self.conn = None
        self.port_forwards = {}  # Track port forwards: {vm_name: {vm_port: host_port}}

    def _map_to_host_path(self, path: str) -> str:
        host_root = os.environ.get("HOST_PROJECT_ROOT")
        if host_root and path.startswith("/app"):
            return path.replace("/app", host_root, 1)
        return path

    def _generate_domain_xml(self, name, memory_mb, vcpus, disk_path, cloud_iso_path):
        disk_path_host = self._map_to_host_path(disk_path)
        cloud_iso_path_host = self._map_to_host_path(cloud_iso_path)
        # A simple QEMU/KVM domain XML
        xml = f"""
        <domain type='kvm'>
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

    def _find_available_host_port(self, start_port: int = 10080) -> int:
        """Find an available port on the host starting from start_port"""
        import socket
        port = start_port
        while port < 65535:
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
                try:
                    s.bind(('0.0.0.0', port))
                    return port
                except OSError:
                    port += 1
        raise Exception("No available ports found")

    def _setup_port_forward(self, vm_ip: str, vm_port: int, host_port: int):
        """Setup iptables port forwarding from host to VM"""
        try:
            # Add PREROUTING rule for external traffic
            subprocess.run([
                'iptables', '-t', 'nat', '-A', 'PREROUTING',
                '-p', 'tcp', '--dport', str(host_port),
                '-j', 'DNAT', '--to-destination', f'{vm_ip}:{vm_port}'
            ], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            
            # Add OUTPUT rule for localhost traffic
            subprocess.run([
                'iptables', '-t', 'nat', '-A', 'OUTPUT',
                '-p', 'tcp', '--dport', str(host_port),
                '-j', 'DNAT', '--to-destination', f'{vm_ip}:{vm_port}'
            ], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            
            # Add FORWARD rule to allow forwarding
            subprocess.run([
                'iptables', '-A', 'FORWARD',
                '-p', 'tcp', '-d', vm_ip,
                '--dport', str(vm_port),
                '-j', 'ACCEPT'
            ], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            
            print(f"Port forward configured: host:{host_port} -> {vm_ip}:{vm_port}")
            return True
        except subprocess.CalledProcessError as e:
            print(f"Failed to setup port forward: {e}")
            return False

    def _remove_port_forward(self, vm_ip: str, vm_port: int, host_port: int):
        """Remove iptables port forwarding rules"""
        try:
            # Remove PREROUTING rule
            subprocess.run([
                'iptables', '-t', 'nat', '-D', 'PREROUTING',
                '-p', 'tcp', '--dport', str(host_port),
                '-j', 'DNAT', '--to-destination', f'{vm_ip}:{vm_port}'
            ], check=False, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            
            # Remove OUTPUT rule
            subprocess.run([
                'iptables', '-t', 'nat', '-D', 'OUTPUT',
                '-p', 'tcp', '--dport', str(host_port),
                '-j', 'DNAT', '--to-destination', f'{vm_ip}:{vm_port}'
            ], check=False, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            
            # Remove FORWARD rule
            subprocess.run([
                'iptables', '-D', 'FORWARD',
                '-p', 'tcp', '-d', vm_ip,
                '--dport', str(vm_port),
                '-j', 'ACCEPT'
            ], check=False, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            
        except Exception as e:
            print(f"Failed to remove port forward: {e}")

    def setup_port_forwards(self, name: str, exposed_ports: list):
        """Setup port forwarding for a VM's exposed ports"""
        vm_ip = self.get_vm_ip(name)
        if not vm_ip:
            print(f"Cannot setup port forwards: VM {name} has no IP")
            return {}
        
        if name not in self.port_forwards:
            self.port_forwards[name] = {}
        
        port_mappings = {}
        for vm_port in exposed_ports:
            try:
                host_port = self._find_available_host_port(10000 + vm_port)
                if self._setup_port_forward(vm_ip, vm_port, host_port):
                    self.port_forwards[name][vm_port] = host_port
                    port_mappings[vm_port] = host_port
            except Exception as e:
                print(f"Failed to forward port {vm_port}: {e}")
        
        return port_mappings

    def launch_vm(self, name: str, disk_path: str, cloud_iso_path: str, memory_mb: int = 1024, vcpus: int = 1, exposed_ports: list = None):
        if not self.conn:
            raise Exception("Not connected to libvirt")
        
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
            return True
        except libvirt.libvirtError as e:
            print(f"Failed to create VM {name}: {e}")
            return False

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

    def get_port_mappings(self, name: str) -> dict:
        """Get port mappings for a VM"""
        return self.port_forwards.get(name, {})

    def stop_vm(self, name: str) -> bool:
        if not self.conn:
            return False
        try:
            # Clean up port forwards
            if name in self.port_forwards:
                vm_ip = self.get_vm_ip(name)
                if vm_ip:
                    for vm_port, host_port in self.port_forwards[name].items():
                        self._remove_port_forward(vm_ip, vm_port, host_port)
                del self.port_forwards[name]
            
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
