import os
import platform
import re
import sys
from xml.etree import ElementTree
sys.path.append("..")
import lib.libsf as libsf
from lib.libsf import mylog

# Determine if we are on Windows or unix-ish
if platform.system().lower().startswith("win"):
    windows = True
else:
    windows = False

# See if this is the first time boot or not
if windows:
    donefile = r"C:\cft\client_daemons\firstbootdone"
else:
    donefile = "/opt/cft/client_daemons/firstbootdone"
if os.path.exists(donefile):
    mylog.info("Skipping firstboot setup because firstboot has alread been run")
    sys.exit(0)

mylog.info("Detecting hypervisor")
hypervisor = libsf.GuessHypervisor().lower()

# Make sure we are not on a physical machine
if "physical" in hypervisor:
    mylog.info("Skipping firstboot because this machine does not look like a VM guest.")
    sys.exit(0)

# Get the name of my virtual machine container from the hypervisor
new_hostname = ""

# Try VMware
if not new_hostname:
    command = None
    if windows and os.path.exists("C:\Program Files\VMware\VMware Tools\vmtoolsd.exe"):
        command = r'"C:\Program Files\VMware\VMware Tools\vmtoolsd.exe" --cmd "info-get guestinfo.hostname"'
    elif os.path.exists("/usr/sbin/vmtoolsd"):
        command = '/usr/sbin/vmtoolsd --cmd "info-get guestinfo.hostname" 2>/dev/null'
    if command:
        retcode, stdout, stderr = libsf.RunCommand(command)
        if retcode == 0:
            mylog.info("Detected we are a VMware guest")
            new_hostname = stdout.strip()
            mylog.info("My VM name is " + new_hostname)

# Try XenServer
if not new_hostname:
    command = None
    if windows:
        command = 'powershell -NoProfile -NonInteractive -NoLogo -ExecutionPolicy Unrestricted -Command ./xenstore_getname.ps1'
    elif os.path.exists("/usr/bin/xenstore-read"):
        command = '/usr/bin/xenstore-read name 2>/dev/null'
    if command:
        retcode, stdout, stderr = libsf.RunCommand(command)
        if retcode == 0:
            mylog.info("Detected we are a Xen guest")
            new_hostname = stdout.strip()
            mylog.info("My VM name is " + new_hostname)

# Try HyperV
if not new_hostname:
    if windows:
        command = r'reg query "HKLM\SOFTWARE\Microsoft\Virtual Machine\Guest\Parameters"  /v VirtualMachineName'
        retcode, stdout, stderr = libsf.RunCommand(command)
        if retcode == 0:
            mylog.info("Detected we are a HyperV guest")
            for line in stdout.split("\n"):
                line = line.strip()
                if len(line) <= 0: continue
                if line.startswith("VirtualMachineName"):
                    pieces = re.split(r"\s+", line)
                    new_hostname = pieces[2]
                    break
            mylog.info("My VM name is " + new_hostname)
        else:
            mylog.error("Could not determine my VM name")
            sys.exit(1)
    else:
        if os.path.exists("/var/opt/hyperv/.kvp_pool_3"):
            command = r"/bin/cat /var/opt/hyperv/.kvp_pool_3 | /bin/sed 's/\x0/ /g' | /usr/bin/awk '{print $20}'"
            retcode, stdout, stderr = libsf.RunCommand(command)
            if retcode == 0:
                mylog.info("Detected we are a HyperV guest")
                new_hostname = stdout.strip()
                mylog.info("My VM name is " + new_hostname)

# Try more complex methods
if not new_hostname:
    mylog.info("Getting a list of my MAC addresses")
    mac_list = []
    if windows:
        retcode, stdout, stderr = libsf.RunCommand("getmac.exe /v /nh /fo csv")
        for line in stdout.split("\n"):
            line = line.strip()
            if len(line) <= 0: continue
            pieces = line.split(",")
            mac = pieces[2].strip('"').replace("-","").lower()
            if mac == "000000000000": continue # Occasionally we see MACs that are all 0 from badly configured NICs/bonds
            mac_list.append(mac)
    else:
        retcode, stdout, stderr = libsf.RunCommand("ifconfig | grep HWaddr | awk '{print $5}' | sed 's/://g' | sort -u")
        for mac in stdout.split("\n"):
            mac = mac.strip().lower()
            if len(mac) <= 0: continue
            if mac == "000000000000": continue # Occasionally we see MACs that are all 0 from badly configured NICs/bonds
            mac_list.append(mac)
    if len(mac_list) > 0:
        mac_list.sort()
        mac_addr = mac_list[0]
    else:
        mac_addr = "UNKNOWN"

    # If we are running on VMware, connect to the vCenter server and look for a VM with my MAC address
    if "vmware" in hypervisor or "esx" in hypervisor:
        try:
            from pysphere import VIServer
        except ImportError:
            pass
        else:
            mylog.info("Searching CFT vCenter for a VM with my MAC address")
            vcenter = VIServer()
            vcenter.connect("cft-vcenter.cft.solidfire.net", "cft", "solidfire")
            try:
                vmlist = vcenter.get_registered_vms(status='poweredOn')
                vm_name = None
                for vm in vmlist:
                    net = vm.get_property('net', from_cache=False)
                    if net:
                        for interface in net:
                            mac = interface.get('mac_address', None)
                            if mac:
                                mac = mac.replace(":", "").lower()
                            if mac in mac_list:
                                vm_name = vm.get_property('name')
                                break
                    if vm_name:
                        break
                if vm_name:
                    mylog.info("My VM name is " + vm_name)
                    new_hostname = vm_name
            finally:
                vcenter.disconnect()

    # If we are running on KVM, connect to each KVM server and look for a VM with my MAC address
    if "kvm" in hypervisor:
        try:
            import socket
            import libvirt
        except ImportError:
            pass
        else:
            mylog.info("Searching CFT KVM hosts for a VM with my MAC address")
            socket.setdefaulttimeout(10)
            hostname_prefix = "cft-kvm"
            for i in xrange(1, 16):
                vmhost = hostname_prefix + str(i)
                try:
                    vmhost_ip = socket.gethostbyname(vmhost)
                except socket.gaierror:
                    # Could not resolve name
                    break

                try:
                    conn = libvirt.openReadOnly("qemu+tcp://" + vmhost_ip + "/system")
                except libvirt.libvirtError as e:
                    mylog.error("Failed to connect to " + vmhost_ip + ": " + str(e))
                    continue

                try:
                    vm_ids = conn.listDomainsID()
                    running_vm_list = map(conn.lookupByID, vm_ids)
                    running_vm_list = sorted(running_vm_list, key=lambda vm: vm.name())
                except libvirt.libvirtError as e:
                    mylog.error("Failed to get VM list: " + str(e))
                    continue

                found = None
                for vm in running_vm_list:
                    vm_xml = ElementTree.fromstring(vm.XMLDesc(0))
                    vm_mac_list = []

                    for node in vm_xml.findall("devices/interface/mac"):
                        mac = node.get("address")
                        if mac:
                            mac = mac.replace(":", "").lower()
                            vm_mac_list.append(mac)
                    for mac in mac_list:
                        if mac in vm_mac_list:
                            found = vm
                            break
                if found:
                    break
            if found:
                mylog.info("My VM name is " + found.name())
                new_hostname = found.name()

    # If all else fails, generate a hostname from my MAC address and OS type
    if not new_hostname:
        mylog.info("Generating unique hostname from MAC address")
        if windows:
            hostname_prefix = "win-"
        else:
            if "ubuntu" in platform.linux_distribution()[0].lower():
                hostname_prefix = "ubuntu-"
            elif "el" in platform.release():
                hostname_prefix = "rhel-"
            else:
                hostname_prefix = "unix-"
        new_hostname = hostname_prefix + mac_addr


# See if we are a template VM
if "gold" in new_hostname.lower() or "template" in new_hostname.lower():
    mylog.info("Skipping first boot setup because my VM name looks like a template VM")
    sys.exit(0)


# Reset network to DHCP on Windows
if windows:
    retcode, stdout, stderr = libsf.RunCommand("netsh interface ip show interface")
    for line in stdout.split("\n"):
        line = line.strip()
        if len(line) <= 0: continue
        m = re.search(r"^\s*(\d+)\s+(\d+)\s+(\d+)\s+(\S+)\s+(.+)", line)
        if m:
            index = int(m.group(1))
            #metric = int(m.group(2))
            #mtu = int(m.group(3))
            #state = m.group(4)
            name = m.group(5)
            if "loopback" in name.lower(): continue
            mylog.debug("Setting " + name + " to DHCP")
            libsf.RunCommand("netsh interface ip set address name=" + str(index) + " source=dhcp")

# Reset networking info on unix platforms
else:
    mylog.info("Resetting /etc/hosts file")
    with open("/etc/hosts", "w") as f:
        f.write("# Created by firstboot script\n")
        f.write("127.0.0.1\t\tlocalhost\n")

    mylog.info("Clearing udev rules")
    if os.path.exists("/etc/udev/rules.d/70-persistent-net.rules"):
        os.unlink("/etc/udev/rules.d/70-persistent-net.rules")

    # List all the network interfaces
    interfaces = []
    command = '/sbin/ifconfig -a | /bin/egrep "^\S" | /bin/grep -v lo | /usr/bin/awk \'{print $1}\' | /usr/bin/sort'
    retcode, stdout, stderr = libsf.RunCommand(command)
    for iface in stdout.split("\n"):
        iface = iface.strip()
        if len(iface) <= 0:
            continue
        interfaces.append(iface)

    if "ubuntu" in platform.linux_distribution()[0].lower():
        mylog.info("Resetting networking to DHCP on Ubuntu")
        with open("/etc/network/interfaces", "w") as f:
            f.write("# Created by firstboot script\n")
            f.write("auto lo\niface lo inet loopback\n\n")
            for iface in interfaces:
                if "virbr" in iface:
                    continue
                mylog.debug("Adding " + iface + " to /etc/network/interfaces")
                f.write("auto " + iface + "\niface " + iface + " inet dhcp\n\n")
    elif "el" in platform.release():
        mylog.info("Resetting networking to DHCP on RHEL")
        for iface in interfaces:
            if "virbr" in iface:
                continue
            mylog.debug("Creating ifcfg-" + iface)
            with open("/etc/sysconfig/network-scripts/ifcfg-" + iface, "w") as f:
                f.write("# Created by firstboot script\n")
                f.write("DEVICE=" + iface + "\n")
                f.write("NM_CONTROLLED=no\n")
                f.write("BOOTPROTO=dhcp\n")
                f.write("ONBOOT=yes\n")


# Set my hostname
if new_hostname:
    mylog.info("Setting hostname to " + new_hostname)
    if windows:
        command = "wmic computersystem where name='%COMPUTERNAME%' call rename name='" + new_hostname + "'"
        retcode, stdout, stderr = libsf.RunCommand(command)
        if retcode != 0:
            mylog.error("Failed to set hostname - " + stderr)
            sys.exit(1)
    else:
        if "ubuntu" in platform.linux_distribution()[0].lower():
            with open("/etc/hostname", "w") as f:
                f.write(new_hostname)
        elif "el" in platform.release():
            with open("/etc/sysconfig/network", "r") as f:
                lines = f.readlines()
            with open("/etc/sysconfig/network", "w") as f:
                for line in lines:
                    if line.startswith("HOSTNAME="):
                        line = "HOSTNAME=" + new_hostname + "\n"
                f.write(line)


# Touch the file
with open(donefile, 'a'):
    os.utime(donefile, None)

# Reboot to make the changes take effect
if windows:
    command = "shutdown /f /r /t 1"
else:
    command = "/sbin/reboot"
mylog.info("Rebooting")
libsf.RunCommand(command)
