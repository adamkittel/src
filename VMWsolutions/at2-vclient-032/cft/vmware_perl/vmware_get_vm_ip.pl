#!/usr/bin/perl
use strict;
use VMware::VIRuntime;
use libsf;

# Set default username/password to use
# These can be overridden via --username and --password command line options
Opts::set_option("username", "sqd");
Opts::set_option("password", "solidfire");

# Set default vCenter Server
# This can be overridden with --mgmt_server
Opts::set_option("server", "vcenter.etc.hosts");

my %opts = (
    mgmt_server => {
        type => "=s",
        help => "The hostname/IP of the vCenter Server (replaces --server)",
        required => 0,
        default => Opts::get_option("server"),
    },
    vm_name => {
        type => "=s",
        help => "The name of the virtual machine to get the IP address",
        required => 1,
    },
    csv => {
        type => "",
        help => "Display a minimal output that is formatted as a comma separated list",
        required => 0,
    },
    bash => {
        type => "",
        help => "Display a minimal output that is formatted as a space separated list",
        required => 0,
    },
    result_address => {
        type => "=s",
        help => "Address of a ZMQ server listening for results (when run as a child process)",
        required => 0,
    },
    debug => {
        type => "",
        help => "Display more verbose messages",
        required => 0,
    },
);

Opts::add_options(%opts);
if (scalar(@ARGV) < 1)
{
   print "Get the IP address of a virtual machine.";
   Opts::usage();
   exit 1;
}
Opts::parse();
my $vsphere_server = Opts::get_option("mgmt_server");
Opts::set_option("server", $vsphere_server);
my $vm_name = Opts::get_option('vm_name');
my $enable_debug = Opts::get_option('debug');
my $csv = Opts::get_option('csv');
my $bash = Opts::get_option('bash');
my $result_address = Opts::get_option('result_address');
Opts::validate();

$mylog::DisplayDebug = 1 if $enable_debug;
$mylog::Silent = 1 if ($bash || $csv);

# Turn off cert validation so we can get away with self signed certs
mylog::debug("Disabling SSL cert verification");
$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 0;

# Connect to vSphere
mylog::info("Connecting to vSphere at $vsphere_server...");
eval
{
   Util::connect();
};
if ($@)
{
   mylog::error("Could not connect to $vsphere_server: $@");
   exit 1;
}


eval
{
    # Find the source VM
    mylog::info("Searching for VM");
    my $vm = Vim::find_entity_view(view_type => 'VirtualMachine', filter => {'name' => qr/^$vm_name$/i});
    if (!$vm)
    {
        mylog::error("Could not find VM '$vm_name'");
        exit 1;
    }

    # Skip if it's not powered on
    if ($vm->runtime->powerState->val !~ /poweredOn/)
    {
        mylog::error("$vm_name is not powered on");
        exit 1;
    }

    # Quit if VMware tools are not installed and running
    if ($vm->guest->toolsStatus->val eq "toolsNotInstalled")
    {
        mylog::error("VMware Tools are not installed in this VM; cannot detect VM IP address");
        exit 1;
    }
    if ($vm->guest->toolsStatus->val eq "toolsNotRunning")
    {
        mylog::error("VMware Tools are not running in this VM; cannot detect VM IP address");
        exit 1;
    }

    # Try to find an IP address
    mylog::info("Looking for IP address");
    my $vm_ip;
    if (defined $vm->guest && defined $vm->guest->net)
    {
        foreach my $net (@{$vm->guest->net})
        {
            if (defined $net->ipAddress)
            {
                foreach my $ip (@{$net->ipAddress})
                {
                    if ($ip =~ /^192/)
                    {
                        $vm_ip = $ip;
                        last;
                    }
                }
                foreach my $ip (@{$net->ipAddress})
                {
                    if ($ip =~ /^172/)
                    {
                        $vm_ip = $ip;
                        last;
                    }
                }
                foreach my $ip (@{$net->ipAddress})
                {
                    if ($ip =~ /^10/)
                    {
                        $vm_ip = $ip;
                        last;
                    }
                }
            }
            else
            {
                mylog::debug("ipAddress is undefined on " . $net->network);
            }
            last if $vm_ip;
        }
        # Quit if we couldn't find an IP - either the VM doesn't have one, it's not fully booted, VMware Tools not running, etc.
        if (!$vm_ip)
        {
            mylog::error("Cannot read the IP address of " . $vm->name);
            exit 1;
        }

        if ($csv || $bash)
        {
            print "$vm_ip\n";
        }
        else
        {
            mylog::info("$vm_name IP address is $vm_ip");
        }
        # Send the info back to parent script if requested
        if (defined $result_address)
        {
            libsf::SendResultToParent(result_address => $result_address, result => $vm_ip);
        }

    }
    else
    {
        mylog::error("$vm_name does not have a defined guest/net object");
        exit 1;
    }
};
if ($@)
{
    my $fault = $@;
    if (ref($fault) ne 'SoapFault')
    {
        mylog::error($fault);
        exit 1;
    }
    mylog::error(ref($fault->name) . ": " . $fault->fault_string);
    exit 1;
}

exit 0;
