#!/usr/bin/python

"""
This action will return a list of random Xen VM names, matching a regex.

When run as a script, the following options/env variables apply:
    --vmhost            The IP address of the hypervisor host

    --host_user         The username for the hypervisor

    --host_pass         The password for the hypervisor

    --vm_regex          the regex to match VMs - show all if not specified
    
    --vm_state          the power state of the VMs to list - show all if not specified
    
    --vm_count          number of VMs to return 

    --csv               Display minimal output that is suitable for piping into other programs

    --bash              Display minimal output that is formatted for a bash array/for loop
"""

import sys
from optparse import OptionParser
import re
import lib.libsf as libsf
from lib.libsf import mylog
import lib.XenAPI as XenAPI
import lib.libxen as libxen
import lib.sfdefaults as sfdefaults
from lib.action_base import ActionBase
from lib.datastore import SharedValues
import random

class XenListRandomVmNamesAction(ActionBase):
    class Events:
        """
        Events that this action defines
        """
        FAILURE = "FAILURE"

    def __init__(self):
        super(self.__class__, self).__init__(self.__class__.Events)

    def ValidateArgs(self, args):
        libsf.ValidateArgs({"vmhost" : libsf.IsValidIpv4Address,
                            "host_user" : None,
                            "host_pass" : None},
            args)

    def Get(self, vm_regex=None, vm_powerstate=None, vmhost=sfdefaults.vmhost_xen, csv=False, bash=False, host_user=sfdefaults.host_user, host_pass=sfdefaults.host_pass, debug=False, vm_count=None):
        """
        List VMs
        """
        self.ValidateArgs(locals())
        if debug:
            mylog.showDebug()
        else:
            mylog.hideDebug()

        # Connect to the host/pool
        mylog.info("Connecting to " + vmhost)
        session = None
        try:
            session = libxen.Connect(vmhost, host_user, host_pass)
        except libxen.XenError as e:
            mylog.error(str(e))
            self.RaiseFailureEvent(message=str(e), exception=e)
            return False

        mylog.info("Searching for matching VMs")
        try:
            vm_list = libxen.GetAllVMs(session)
        except libxen.XenError as e:
            mylog.error(str(e))
            self.RaiseFailureEvent(message=str(e), exception=e)
            return False

        matching_vms = []
        for vname in vm_list.keys():
            if vm_powerstate and vm_list[vname]['power_state'].lower() != vm_powerstate.lower():
                continue
            if vm_regex:
                m = re.search(vm_regex, vname)
                if not m:
                    continue

            matching_vms.append(vname)

        random_vms = []
        if (vm_count == 0 or vm_count < 0):
            mylog.error("Please enter a positive value, > 0 for vm_count")
            return False
            
        elif len(matching_vms) <= 0:
            mylog.error("There are no VMs that match the given regex")
            return False
            
        elif vm_count >= len(matching_vms):
            return sorted (matching_vms)
        else:
            list = []
            list = random.sample(range(0,len(matching_vms)-1), vm_count)
            for i in list:
                random_vms.append(matching_vms[i])
        return sorted(random_vms)

    def Execute(self, vm_regex=None, vm_powerstate=None, vmhost=sfdefaults.vmhost_xen, csv=False, bash=False, host_user=sfdefaults.host_user, host_pass=sfdefaults.host_pass, debug=False, vm_count=None):
        """
        List VMs
        """
        self.ValidateArgs(locals())
        if debug:
            mylog.showDebug()
        else:
            mylog.hideDebug()
        if bash or csv:
            mylog.silence = True

        del self
        matching_vms = Get(**locals())
        if matching_vms == False:
            mylog.error("There was an error getting the list of VMs")
            return False

        if csv or bash:
            separator = ","
            if bash:
                separator = " "
            sys.stdout.write(separator.join(matching_vms) + "\n")
            sys.stdout.flush()
        else:
            for name in matching_vms:
                mylog.info("  " + name)

        return True


# Instantate the class and add its attributes to the module
# This allows it to be executed simply as module_name.Execute
libsf.PopulateActionModule(sys.modules[__name__])

if __name__ == '__main__':
    mylog.debug("Starting " + str(sys.argv))

    parser = OptionParser(option_class=libsf.ListOption, description=libsf.GetFirstLine(sys.modules[__name__].__doc__))
    parser.add_option("--vm_regex", type="string", dest="vm_regex", default=None, help="the regex to match VMs - show all if not specified")
    parser.add_option("--vm_state", type="choice", dest="vm_state", default=None, choices=["running", "halted"], help="the power state of the VMs to list - show all if not specified")
    parser.add_option("-v", "--vmhost", type="string", dest="vmhost", default=sfdefaults.vmhost_xen, help="the management IP of the Xen hypervisor [%default]")
    parser.add_option("--vm_count", type="int", dest="vm_count", default ="5", help="number of VMs to return")
    parser.add_option("--host_user", type="string", dest="host_user", default=sfdefaults.host_user, help="the username for the hypervisor [%default]")
    parser.add_option("--host_pass", type="string", dest="host_pass", default=sfdefaults.host_pass, help="the password for the hypervisor [%default]")
    parser.add_option("--csv", action="store_true", dest="csv", default=False, help="display a minimal output that is formatted as a comma separated list")
    parser.add_option("--bash", action="store_true", dest="bash", default=False, help="display a minimal output that is formatted as a space separated list")
    parser.add_option("--debug", action="store_true", dest="debug", default=False, help="display more verbose messages")
    (options, extra_args) = parser.parse_args()

    try:
        timer = libsf.ScriptTimer()
        if Execute(vm_regex=options.vm_regex, vm_powerstate=options.vm_state, vmhost=options.vmhost, csv=options.csv, bash=options.bash, host_user=options.host_user, host_pass=options.host_pass, debug=options.debug, vm_count=options.vm_count):
            sys.exit(0)
        else:
            sys.exit(1)
    except libsf.SfArgumentError as e:
        mylog.error("Invalid arguments - \n" + str(e))
        sys.exit(1)
    except SystemExit:
        raise
    except KeyboardInterrupt:
        mylog.warning("Aborted by user")
        Abort()
        sys.exit(1)
    except:
        mylog.exception("Unhandled exception")
        sys.exit(1)

