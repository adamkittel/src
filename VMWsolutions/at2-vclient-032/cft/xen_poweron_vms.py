#!/usr/bin/python

"""
This action will power on XenServer VMs

When run as a script, the following options/env variables apply:
    --vmhost            The managment IP of the hypervisor host

    --host_user         The host username
    SFHOST_USER env var

    --host_pass         The host password
    SFHOST_PASS env var

    --vm_name           The name of a single VM to power on

    --vm_regex          Regex to match names of VMs to power on

    --vm_count          The max number of VMs to power on
"""

import sys
from optparse import OptionParser
import logging
import re
import time
import multiprocessing
import lib.libsf as libsf
from lib.libsf import mylog
import lib.XenAPI as XenAPI
import lib.libxen as libxen
import lib.sfdefaults as sfdefaults
from lib.action_base import ActionBase
from lib.datastore import SharedValues

class XenPoweronVmsAction(ActionBase):
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

    def _VmThread(self, VmHost, HostUser, HostPass, VmName, VmRef, results, debug):
        results[VmName] = False

        mylog.debug("  " + VmName + ": connecting to pool")
        try:
            session = libxen.Connect(VmHost, HostUser, HostPass)
        except libxen.XenError as e:
            mylog.error("  " + VmName + ": " + str(e))
            self.RaiseFailureEvent(message=str(e), vmName=VmName, exception=e)
            return

        mylog.info("  " + VmName + ": powering on")
        retry = 3
        while retry > 0:
            try:
                session.xenapi.VM.start(VmRef, False, False)
                results[VmName] = True
                break
            except XenAPI.Failure as e:
                if e.details[0] == "CANNOT_CONTACT_HOST":
                    time.sleep(30)
                    retry -= 1
                    continue
                if e.details[0] == "VM_BAD_POWER_STATE" and e.details[3].lower() == "running":
                    # The VM was powered on by someone else before this thread had a chance to
                    results[VmName] = True
                    break
                else:
                    mylog.error("  " + VmName + ": Failed to power on - " + str(e))
                    self.RaiseFailureEvent(message=str(e), vmName=VmName, exception=e)
                    return
        if not results[VmName]:
            mylog.error("  " + VmName + ": Failed to power on")

    def Execute(self, vm_name=None, vm_regex=None, vm_count=0, vmhost=sfdefaults.vmhost_xen,  host_user=sfdefaults.host_user, host_pass=sfdefaults.host_pass, parallel_thresh=sfdefaults.xenapi_parallel_calls_thresh, parallel_max=sfdefaults.xenapi_parallel_calls_max, debug=False):
        """
        Power on VMs
        """
        self.ValidateArgs(locals())
        if debug:
            mylog.console.setLevel(logging.DEBUG)

        # Connect to the host/pool
        mylog.info("Connecting to " + vmhost)
        session = None
        try:
            session = libxen.Connect(vmhost, host_user, host_pass)
        except libxen.XenError as e:
            mylog.error(str(e))
            self.RaiseFailureEvent(message=str(e), exception=e)
            return False

        if vm_name:
            try:
                vm_ref = session.xenapi.VM.get_by_name_label(vm_name)
            except XenAPI.Failure as e:
                mylog.error("Could not find VM " + vm_name + " - " + str(e))
                self.RaiseFailureEvent(message=str(e), exception=e)
                return False
            if not vm_ref or len(vm_ref) <= 0:
                mylog.error("Could not find source VM '" + vm_name + "'")
                self.RaiseFailureEvent(message="Could not find source VM '" + vm_name + "'")
                return False
            vm_ref = vm_ref[0]
            try:
                vm = session.xenapi.VM.get_record(vm_ref)
            except XenAPI.Failure as e:
                mylog.error("Could not get VM record - " + str(e))
                self.RaiseFailureEvent(message=str(e), exception=e)
                return False
            if vm["power_state"] == "Running":
                mylog.passed(vm_name + " is already powered on")
                return False
            mylog.info("Powering on " + vm_name)
            try:
                session.xenapi.VM.start(vm_ref, False, False)
            except XenAPI.Failure as e:
                mylog.error("Could not start " + vm_name + " - " + str(e))
                return False

        mylog.info("Searching for matching VMs")
        # Get a list of all VMs
        try:
            vm_list = libxen.GetAllVMs(session)
        except libxen.XenError as e:
            mylog.error(str(e))
            self.RaiseFailureEvent(message=str(e), exception=e)
            return False

        matched_vms = dict()
        for vname in sorted(vm_list.keys()):
            if vm_regex:
                m = re.search(vm_regex, vname)
                if m:
                    matched_vms[vname] = vm_list[vname]
            else:
                matched_vms[vname] = vm_list[vname]

            if vm_count > 0 and len(matched_vms) >= vm_count:
                break

        ## Get a list of all VMs
        #vm_list = dict()
        #try:
            #vm_ref_list = session.xenapi.VM.get_all()
        #except XenAPI.Failure as e:
            #mylog.error("Could not get VM list: " + str(e))
            #self.RaiseFailureEvent(message=str(e), exception=e)
            #return False
        #for vm_ref in vm_ref_list:
            #vm = session.xenapi.VM.get_record(vm_ref)
            #vname = vm["name_label"]
            #vm_list[vname] = dict()
            #vm_list[vname]["ref"] = vm_ref
            #vm_list[vname]["vm"] = vm

        #matched_vms = dict()
        #for vname in sorted(vm_list.keys()):
            #vm = vm_list[vname]["vm"]
            #vm_ref = vm_list[vname]["ref"]
            #if vm_regex:
                #m = re.search(vm_regex, vname)
                #if m:
                    #matched_vms[vname] = vm_list[vname]
            #else:
                #matched_vms[vname] = vm_list[vname]

            #if vm_count > 0 and len(matched_vms) >= vm_count:
                #break

        if len(matched_vms.keys()) <= 0:
            mylog.info("No VMs found")
            return True

        mylog.info(str(len(matched_vms.keys())) + " VMs will be powered on: " + ", ".join(matched_vms.keys()))

        # Run the API operations in parallel if there are enough
        if len(matched_vms.keys()) <= parallel_thresh:
            parallel_calls = 1
        else:
            parallel_calls = parallel_max

        manager = multiprocessing.Manager()
        results = manager.dict()
        self._threads = []
        for vname in sorted(matched_vms.keys()):
            vm_ref = matched_vms[vname]["ref"]
            vm = matched_vms[vname]
            if vm["power_state"] == "Running":
                mylog.passed("  " + vname + " is already powered on")
            else:
                results[vname] = False
                th = multiprocessing.Process(target=self._VmThread, args=(vmhost, host_user, host_pass, vname, vm_ref, results, debug))
                th.daemon = True
                self._threads.append(th)

        # Run all of the threads
        allgood = libsf.ThreadRunner(self._threads, results, parallel_calls)
        if allgood:
            mylog.passed("All VMs powered on successfully")
            return True
        else:
            mylog.error("Not all VMs could be powered on")
            return False


# Instantate the class and add its attributes to the module
# This allows it to be executed simply as module_name.Execute
libsf.PopulateActionModule(sys.modules[__name__])

if __name__ == '__main__':
    mylog.debug("Starting " + str(sys.argv))

    # Parse command line arguments
    parser = OptionParser(option_class=libsf.ListOption, description=libsf.GetFirstLine(sys.modules[__name__].__doc__))
    parser.add_option("--vmhost", type="string", dest="vmhost", default=sfdefaults.vmhost_xen, help="the management IP of the hypervisor [%default]")
    parser.add_option("--host_user", type="string", dest="host_user", default=sfdefaults.host_user, help="the username for the hypervisor [%default]")
    parser.add_option("--host_pass", type="string", dest="host_pass", default=sfdefaults.host_pass, help="the password for the hypervisor [%default]")
    parser.add_option("--vm_name", type="string", dest="vm_name", default=None, help="the name of the single VM to power on")
    parser.add_option("--vm_regex", type="string", dest="vm_regex", default=None, help="the regex to match names of VMs to power on")
    parser.add_option("--vm_count", type="int", dest="vm_count", default=0, help="the number of matching VMs to power on (0 to use all)")
    parser.add_option("--parallel_thresh", type="int", dest="parallel_thresh", default=sfdefaults.xenapi_parallel_calls_thresh, help="do not use multiple threads unless there are more than this many [%default]")
    parser.add_option("--parallel_max", type="int", dest="parallel_max", default=sfdefaults.xenapi_parallel_calls_max, help="the max number of threads to use [%default]")
    parser.add_option("--debug", action="store_true", dest="debug", default=False, help="display more verbose messages")
    (options, extra_args) = parser.parse_args()

    try:
        timer = libsf.ScriptTimer()
        if Execute(options.vm_name, options.vm_regex, options.vm_count, options.vmhost, options.host_user, options.host_pass, options.parallel_thresh, options.parallel_max, options.debug):
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

