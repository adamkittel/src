"""
A module containing generic SSH functions.

This is a fork of the module from lab

"""
import os
import re
import socket
import time
import urllib2
import threading
from binascii import hexlify
from contextlib import contextmanager
import platform

try:
    import paramiko
    from paramiko.agent import Agent
    from paramiko.client import RejectPolicy
    from paramiko.hostkeys import HostKeys
    from paramiko.dsskey import DSSKey
    from paramiko.rsakey import RSAKey
except ImportError, i_error:
    print "Unable to import paramiko (pip install paramiko): %s" % i_error
    raise

import SFLogging
import scp_client

DEFAULT_USERNAME = 'root'
DEFAULT_PASSWD = 'sf.9012182'  # ApiZooKeeper.py uses this

IPMI_PASSWD      = 'calvin'
CLIENT_PASSWD    = 'solidfire'
OLD_CLIENT_PASSWD    = 'SolidF1r3'
BE_NODE_PASSWD   = 'sf.9012182'
BO_NODE_PASSWD   = 'Boronthe5thElement'
BE_OTPW_FILE     = 'be-otpw-words.txt'
BO_OTPW_FILE     = 'b-otpw-words.txt'

# BE here refers to the password change and not the build name.
BE_MAX_MAJOR_VERSION = 5
BE_MAX_MINOR_VERSION = 572

SF_VERSION_UNCERTAIN = -1

UNKNOWN_SRV      = 0
NODE_SRV         = 1
IPMI_SRV         = 2
CLIENT_SRV       = 3

log = SFLogging.get_sflogging()
#log = SFLogging.get_sflogging(1, "")

class GenericSSHError(RuntimeError):
    """ Standard GenericSSH exception """
    def __init__(self, value):
        self.value = value

def _argdecorator(fun):
    """ A decorator to check the remote_paths argument to get(). """
    def wrap(*args, **kwargs):
        """ Wrap it """
        log.debug("args: %s" % args[1])
        if isinstance(args[1], list) or isinstance(args[1], tuple):
            pass
        else:
            raise GenericSSHError, "the remote_paths argument to get() " \
                    +"needs to be a list!"
        return fun(*args, **kwargs)
    return wrap

class SSH(object):
    """ Create an ssh connection, keep it open for following operations """
    def __init__(self, host, username=DEFAULT_USERNAME, passwd=None,
                 rfiles=False, retry=True, port=22, reset_otpw=True,
                 force_otpw=False, wrong_otpw=False, abort=False, timeout=15):
        self.host = host
        self.port = port
        self.username = username
        self.passwd = passwd

        log.debug("SSH => host=%s, username=%s, password=%s" % \
                  (self.host, self.username, self.passwd))

        if passwd == BE_NODE_PASSWD:
            log.info("CLUE: GenericSSH was passed the old node password!")

        self.srvtype = UNKNOWN_SRV

        # Guess password and server type
        passwd_guess = None
        if host.startswith('192.168.134') or host.startswith('172.25.105'):
            self.srvtype = IPMI_SRV
            passwd_guess = IPMI_PASSWD
        elif host.startswith('192.168.133') or host.startswith('172.25.104'):
            self.srvtype = NODE_SRV
            passwd_guess = BO_NODE_PASSWD
        else:
            # Assume it's a client otherwise...
            self.srvtype = CLIENT_SRV
            passwd_guess = CLIENT_PASSWD

        # If password wasn't passed in, use the guess.
        if self.passwd == None:
            self.passwd = passwd_guess
            log.info("GenericSSH using guessed passwd '%s'"%self.passwd)
        elif passwd_guess != None and self.passwd != passwd_guess:
            log.info("GenericSSH guessed passwd '%s', but is using the one you "
                    "passed instead, '%s'."%(passwd_guess,self.passwd))

        self.rfiles = rfiles
        self.retry = retry
        self.reset_otpw = reset_otpw
        self.force_otpw = force_otpw
        self.wrong_otpw = wrong_otpw
        self.abort = abort
        self.timeout = timeout

        self.auth_method = None
        self.client = None
        self._init_client()

    @property
    def node(self):
        import inspect
        st = inspect.stack()[1]
        filename = os.path.basename(st[1])
        line_no = st[2]
        log.warn("SSH.node is deprecated. Use SSH.host instead. Called from %s:%s" % (filename, line_no))
        return self.host

    def _init_client(self):
        """ Connect to the client. """
        self.client = SFSSHClient(force_otpw=self.force_otpw,
                                  wrong_otpw=self.wrong_otpw,
                                  abort=self.abort)
        self.client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

        retries = 2
        attempts = 0
        while True:
            try:
                self.client.connect(self.host,
                                    username=self.username,
                                    password=self.passwd,
                                    port=self.port,
                                    timeout=self.timeout)

            except socket.error, serror:
                if not self.retry:
                    raise GenericSSHError, "Client connection error, " \
                        +" %s \'%s\' - not retrying" % (self.host, str(serror))

                log.error("Client connection error - %s \'%s\' retrying ..." % \
                          (self.host, str(serror)))

                attempts += 1
                if attempts >= retries:
                    raise GenericSSHError, "Unable to connect to host " \
                          +" %s after %d retries" % (self.host, retries)
                time.sleep(15)

            except paramiko.SSHException, really_bad:
                log.critical("really_bad: {0}".format(really_bad)) # Cause Robot isn't showing this.
                raise GenericSSHError("Something went bad with SSH itself [%s]" %
                    really_bad)

            else:
                log.info("Successfully connected to host %s using method %s."%
                         (self.host, self.client.auth_method))
                self.auth_method = self.client.auth_method
                if self.reset_otpw:
                    self.reset_otpw_list()
                break

    def reset_otpw_list(self):
        """ Recreate the original otpw list if we're running out """
        cmd = ("if [ -e .otpw ]; then "
               + "if [ `grep -v ^--------------- .otpw|wc -l` -lt 100 ] ; "
               + "then apt-get install -y --only-upgrade "
               + '--reinstall "solidfire-otp-*"; fi; fi')
        self.run_command(cmd)

    def run_command(self, cmd, func_=None):
        """ Run the passed command, return stdin,stdout,stderr if specified at
        instantiation.
        """
        log.debug("Running cmd: \n%s" % cmd)

        bufsize = -1
        exit_status = -12
        try:
            chan = self.client._transport.open_session()
            chan.exec_command(cmd)

        except paramiko.SSHException, ssh_error:
            raise GenericSSHError, "%s" % str(ssh_error)

        if self.rfiles:
            stdin = chan.makefile('wb', bufsize)
            stdout = chan.makefile('rb', bufsize)
            stderr = chan.makefile_stderr('rb', bufsize)
            return (stdin, stdout, stderr, chan)

        if func_:
            stdin = chan.makefile('wb', bufsize)
            stdout = chan.makefile('rb', bufsize)
            stderr = chan.makefile_stderr('rb', bufsize)
            return func_(stdin, stdout, stderr, chan)

        exit_status = chan.recv_exit_status()
        chan.close()

        return exit_status

    def run_command_safe(self, cmd, timeout=600, combine_stderr=False):
        """ Run a Command, Safely

        Given a command, open a channel to run that command, read STDOUT and
        STDERR, close the channel. Return the out, err and rc.

        Timeout: 10 min.

        :param str cmd: the command to run
        :rtype: tuple
            :Returns:
                out, err, rc::
                    [ ['.','..'], [], 0 ]
        """

        log.debug("Running cmd: \n%s" % cmd)

        bufsize = 65536

        start_time = time.time()

        out = ''
        err = ''
        rc = -99

        try:
            chan = self.client._transport.open_session()
            if combine_stderr:
                chan.set_combine_stderr(True)
            chan.exec_command(cmd)

        except paramiko.SSHException, ssh_error:
            raise GenericSSHError, "%s" % str(ssh_error)

        while time.time() - start_time < timeout:
            if chan.recv_ready():
                out += chan.recv(bufsize)
            if chan.recv_stderr_ready():
                err += chan.recv_stderr(bufsize)
            if chan.exit_status_ready():
                rc = chan.recv_exit_status()
                break

        while time.time() - start_time < timeout:
            chunk = chan.recv(bufsize)
            if chunk:
                out += chunk
            else:
                break

        while time.time() - start_time < timeout:
            chunk = chan.recv_stderr(bufsize)
            if chunk:
                err += chunk
            else:
                break

        chan.close()

        outlist = out.splitlines()
        errlist = err.splitlines()

        return outlist, errlist, rc

    def run_command_thread(self, command, keep_output=True, daemon=False, stdin=False):
        return SSHCommandHandler(command, self, keep_output, daemon, stdin)

    def run_command_daemon(self, command):
        return SSHCommandHandler(command, self, daemon=True)

    def run_command_get_pid(self, command):
        resp = SSHCommandHandler(command, self, daemon=True)
        return resp.get_pid()

    def run_command_get_output(self, command, timeout=600, keep_output=True):
        resp = SSHCommandHandler(command, self, keep_output=keep_output)
        resp.close(timeout=timeout, fail=True, force=True)
        return (resp.stdout, resp.stderr, resp.ret_code)

    def run_command_no_ret(self, cmd):
        """ Run the passed command. Does not query for return code or
        stdin,stdout,stderr.
        """
        log.debug("Running cmd: \n%s" % cmd)

        try:
            chan = self.client._transport.open_session()
            chan.exec_command(cmd)
            chan.close()

        except paramiko.SSHException, ssh_error:
            raise GenericSSHError, "%s" % str(ssh_error)

    @_argdecorator
    def get(self, remote_paths, local_path='', recursive=False,
                preserve_times=False):
        """ Use scp (scp_client) to retrieve remote file(s). """
        log.info("Getting files from remote machine ...%s"% self.host)

        try:
            scp = scp_client.SCPClient(self.client.get_transport())

            for rpath in remote_paths:
                scp.get(rpath, local_path, recursive, preserve_times)

        except scp_client.SCPException, scp_err:
            raise GenericSSHError, "%s" % str(scp_err)

    def put(self, files, remote_path='.', recursive=False,
            preserve_times=False):
        """ Use scp (scp_client) to copy file(s) to remote location.
        files is a list.
        """
        log.info("Putting files on remote machine '%s'..." % self.host)

        try:
            scp = scp_client.SCPClient(self.client.get_transport())
            scp.put(files, remote_path, recursive, preserve_times)

        except scp_client.SCPException, scp_err:
            raise GenericSSHError, "%s" % str(scp_err)


    def close(self):
        """ Close down the SSH connection. """
        self.client.close()

def ssh_run_command(host, cmd, username=DEFAULT_USERNAME,
                    passwd=None, port=22):
    """ Login and run a command.


    RETURNS:
        list<str> stdout,
        list<str> stderr,
        int exit_status
    """
    log.debug("Running command [%s]" % cmd)

    ssh_inst = SSH(host, username, passwd, port=port)
    resp = ssh_inst.run_command_safe(cmd)
    ssh_inst.close()
    return resp[-3:]

def ssh_run_command_safe(host, cmd, username=DEFAULT_USERNAME,
                         passwd=None, port=22):
    """ Deprecated for ssh_run_command.
    """
    log.debug("ssh_run_command_safe has been deprecated. Please use ssh_run_command.")
    return ssh_run_command(host, cmd, username, passwd, port)


def run_command_thread(command, ssh_inst,
                       keep_output=True, daemon=False, stdin=False):
    """Run command via ssh_inst and return an SSHCommandHandler object

    :param str command: the command to be run
    :param lib.GenericSSH.SSH ssh_inst: a connection to the host
    :param keep_output: if ``True`` (default), keep stdout/stderr as arrays
    :param daemon: if ``True``, use ``screen`` utility to daemonize

    To ensure the command is finished, run SSHCommandHandler.close(timeout)
    Get stdout with SSHCommandHandler.stdout
    Get stderr with SSHCommandHandler.stderr
    Get ret_code with SSHCommandHandler.ret_code
    Get pid of process with SSHCommandHandler.get_pid(). This requires running
    with ``daemon=True``. The pid returned will be the pid of the ``SCREEN``
    process, which is the parent of the process running ``command``.
    """
    return SSHCommandHandler(command, ssh_inst, keep_output, daemon, stdin)

def run_command_daemon(command, ssh_inst):
    """Run command via ssh_inst and return an SSHCommandHandler object

    See ``run_command_thread()`` for details.
    """
    return SSHCommandHandler(command, ssh_inst, daemon=True)

def run_command_simple(command, ssh_inst, timeout=300):
    """Run ``command`` using ``ssh_inst`` and Return filehandles and retcode

    :param str command: the command to be run
    :param lib.GenericSSH.SSH ssh_inst: a connection to the host
    :param int timeout: max time command can run before closing channel (sec)

    :returns tuple<None, array<str>, array<str>, int>: (stdin, stdout, stderr, ret_code)

    If ``timeout`` is exceeded, an exception will be raised.
    """
    handler = run_command_thread(command, ssh_inst)
    handler.close(timeout)
    return (handler.stdin, handler.stdout, handler.stderr, handler.ret_code)


class SSHCommandHandler(list):
    def __init__(self, command, ssh_inst,
                 keep_output=True, daemon=False, stdin=False):
        """Run command via ssh_inst and Create an SSHCommandHandler object

        :param str command: the command to be run
        :param lib.GenericSSH.SSH ssh_inst: a connection to the host
        :param keep_output: if ``True`` (default), keep stdout/stderr as arrays
        :param daemon: if ``True``, use ``screeen`` utility to daemonize

        To ensure command is finished, run SSHCommandHandler.close(timeout)
        Get stdout with SSHCommandHandler.stdout
        Get stderr with SSHCommandHandler.stderr
        Get ret_code with SSHCommandHandler.ret_code
        Get pid of process with SSHCommandHandler.get_pid(). This requires
        running with ``daemon=True``. The pid returned will be the pid of the
        ``SCREEN`` process, which is the parent of the process running
        ``command``.
        """
        list.__init__(self, ([], [], None))
        # public attributes - filehandles.
        # TODO: deal with stdin, in case anyone ever cares.
        self.stdin = None
        if keep_output:
            self.stdout = self[0]
            self.stderr = self[1]
        else:
            self.stdout = None
            self.stderr = None
        self.ret_code = None
        # private attributes
        self._run_failure = False
        self._chan = None
        self._threads = [None] * 7
        self._daemon = False
        # initiate running the command
        if daemon:
            rc = ssh_inst.run_command_safe('which screen')[-1]
            if rc != 0:
                #rc = ssh_inst.run_command_safe('apt-get -y install screen')[-1]
                if rc != 0:
                    raise GenericSSHError("screen is not installed on host")
                #else:
                #    log.debug("screen installed")
            self._daemon = True
            command = re.sub('"', r'\"', command)
            command = 'screen -d -m bash -c "' + command + '" & echo $!'
        self._run(ssh_inst, command, keep_output, stdin)

    def append(self, item):
        """Act as though this is a tuple"""
        raise AttributeError("AttributeError: 'tuple' object has no attribute 'append'")

    def get_rc(self, timeout=300, fail=True):
        """Get the return code.

        :param int timeout: max seconds to wait for completion
        :param bool fail: if True and command doesn't exit, throw exception.
        :returns int ret_code: the return code of the command
        """
        self._join_thread(5, timeout=timeout, fail=fail)
        return self.ret_code

    def _join_thread(self, index, timeout=60, fail=True):
        """Thread to join a thread saved in self._threads array.

        Used by self.get_rc().
        """
        if timeout > 600:
            timeout = 600
            fail = True
        if timeout <= 0:
            timeout = 300
            fail = False
        self._threads[index].join(timeout)
        if self._threads[index].is_alive():
            if fail:
                raise GenericSSHError, \
                    'command failed to complete within %i seconds' % timeout
            return False
        return True

    def get_pid(self, fail=True):
        """Get the pid. Only meaningful when running in daemon mode.
        :param bool fail: if True, throw an exception if command doesn't exit.
        :returns int pid: the pid of the SCREEN process handling the command.
        """
        if not self._daemon:
            raise GenericSSHError("Can't get pid of non-daemon command.")
        self.close(timeout=5, fail=fail)
        # the value printed by echo is the pid of the original process.
        # screen forks another process which is the parent process we want
        return int(self.stdout[0].strip()) + 1

    def close(self, timeout=300, fail=True, force=False):
        """Close the channel after waiting for command completion.
        :param int timeout: max time to wait for command to complete
        :param bool fail: if ``True``, raise an exception on failure or timeout
        :param bool force: if ``True``, attempt to close channel after timeout.
        """
        try:
            self._join_thread(6, timeout=timeout, fail=fail)
        except GenericSSHError:
            if not force:
                raise

        if force and self._threads[6].is_alive():
            log.warn('timed out wating for command to complete via ssh')
            close_thread = threading.Thread(target=self._chan.close, args=())
            close_thread.daemon=True
            close_thread.start()
            close_thread.join(10)
            if fail and close_thread.is_alive():
                raise GenericSSHError('could not close ssh channel.')

    def _run(self, ssh_inst, command, keep_output, stdin):
        """Main control flow of running command - kick off daemon threads."""
        # open a channel
        self._kick_open_thread(ssh_inst)

        # run the command
        log.info('Running the command [%s]' % command)
        self._kick_run_thread(command)

        # set up the file handles
        if stdin:
            self.stdin = self._chan.makefile('wb', -1)
        if keep_output:
            stdout = self._chan.makefile('rb', -1)
            stderr = self._chan.makefile_stderr('rb', -1)
        else:
            stderr = None
            stdout = None

        # kick of the output handler threads.
        # input is not currently handled.
        self._kick_in_thread()
        self._kick_out_thread(stdout)
        self._kick_err_thread(stderr)
        self._kick_rc_thread()

        # one more thread to clean up the others and close the channel
        self._kick_close_thread()

    def _kick_thread(self, index, target=None, args=()):
        """Kick off a daemon thread and store it in self._threads array"""
        thread = threading.Thread(target=target, args=args)
        self._threads[index] = thread
        thread.daemon = True
        thread.start()

    def _kick_open_thread(self, ssh_inst):
        """Kick off daemon thread to open ssh channel. Should complete fast."""
        self._kick_thread(0, target=self._open_channel, args=(ssh_inst.client,))
        self._threads[0].join(10)
        if self._chan is None:
            raise GenericSSHError('could not open channel for running command.')

    def _kick_run_thread(self, command):
        """Kick off daemon to start running command. Should complete fast."""
        self._kick_thread(1, target=self._run_command, args=(command,))
        self._threads[1].join(10)
        if self._threads[1].is_alive() or self._run_failure:
            raise GenericSSHError('could not start running command %s' % command)

    def _kick_in_thread(self):
        """Kick off a daemon thread to handle stdin; not yet implemented."""
        self._kick_thread(2, target=time.sleep, args=(0.1,))

    def _kick_out_thread(self, stdout):
        """Kick off a daemon thread to handle stdout."""
        self._kick_thread(3, target=self._read_output, args=(stdout, self.stdout))

    def _kick_err_thread(self, stderr):
        """Kick off a daemon thread to handle stderr."""
        self._kick_thread(4, target=self._read_output, args=(stderr, self.stderr))

    def _kick_rc_thread(self):
        """Kick off a daemon thread to wait for the return code."""
        self._kick_thread(5, target=self._get_ret_code)

    def _kick_close_thread(self):
        """Kick off a daemon thread to join all the other threads."""
        self._kick_thread(6, target=self._wait_for_threads, args=())

    def _open_channel(self, ssh_client):
        """Thread to open the ssh channel. Should complete quickly."""
        try:
            self._chan = ssh_client._transport.open_session()
        except paramiko.SSHException, ssh_error:
            raise GenericSSHError, "%s" % str(ssh_error)

    def _run_command(self, command):
        """Start running the command. Method should complete quickly."""
        try:
            self._chan.exec_command(command)
        except paramiko.SSHException, ssh_error:
            self._run_failure = True
            raise GenericSSHError, "%s" % str(ssh_error)

    def _get_ret_code(self):
        """Save the exit status in self._ret_code"""
        self.ret_code = self._chan.recv_exit_status()
        self[2] = self.ret_code

    def _read_output(self, out_handle, out_array):
        """Handle output produced by a paramiko ChannelFile object."""
        if out_handle is None:
            return
        while True:
            next_line = out_handle.readline()
            if not next_line:
                return
            if out_array is not None:
                out_array.append(next_line)

    def _wait_for_threads(self):
        """Wait for all threads (except this one - the last thread) to
        complete, and close the channel."""
        for thread in self._threads[:-1]:
            thread.join()
        self._chan.close()


class SFSSHClient(paramiko.SSHClient):
    """ Just to override the authentication """

    def __init__(self, force_otpw=False, wrong_otpw=False, abort=False):
        """Create a new SSHClient"""
        # From paramiko.SSHClient:
        self._system_host_keys = HostKeys()
        self._host_keys = HostKeys()
        self._host_keys_filename = None
        self._log_channel = None
        self._policy = RejectPolicy()
        self._transport = None
        self._agent = None
        # Our extra stuff:
        self.force_otpw = force_otpw
        self.wrong_otpw = wrong_otpw
        self.abort = abort

    # Parent's _auth dies after failing auth_password, so that has to be last.
    # Otpw auth has to be after auth_pubkeys, or we never use pubkeys and burn
    # up all our one-time passwords quickly. The net result is that we can't
    # use the super's _auth method and just stick otpw before or after. I
    # have just pasted the super _auth here and added my otpw stuff to it.
    def _auth(self, username, password, pkey, key_filenames, allow_agent,
                 look_for_keys):
        """ Override _auth to try pubkeys, then, otpw, then password """

        self.auth_method = None
        self.auth_interactive_method = None
        self.otpw_prompt = None
        self.otpw_file = ""

        allow_otpw = True
        allow_interactive = True
        allow_publickey = True
        allow_password = True
        if self.abort:
            log.info("SSH using abort flag: aborting now")
            # Drop the connection before authenticating
            self.close()
            raise GenericSSHError("SF SSH: Forced connection abort")
        if self.wrong_otpw:
            log.info("SSH using wrong_otpw: enter wrong otpw passwords")
            allow_publickey = False
            allow_password = False
        if self.force_otpw:
            log.info("SSH using force_otpw: only using otpw for auth")
            allow_publickey = False
            allow_password = False

        def open_otpw_file():
            """ Open the otpw translation file """
            if "win" in platform.system().lower():
                def_dir = os.path.expanduser('~/sftest')
            else:
                def_dir = os.path.expanduser('~/.sftest')

            fname = self.otpw_file

            otpw_files = []
            otpw_file_default = os.path.join(def_dir, fname)
            otpw_file_tmp = os.path.join('/tmp', fname)
            otpw_files.append(otpw_file_default)
            otpw_files.append(otpw_file_tmp)
            found_otpw_file = False
            for otpw_fpath in otpw_files:
                if os.path.exists(otpw_fpath):
                    found_otpw_file = True
                    break
            if not found_otpw_file:
                otpw_fpath = otpw_file_default
                if not os.path.exists(def_dir):
                    try:
                        os.mkdir(def_dir)
                    except OSError, e:
                        otpw_fpath = otpw_file_tmp
                log.debug("SF SSH OTPW: Downloading otpw file to %s"
                        % otpw_fpath)
                host_ip = self._transport.sock.getpeername()[0]
                if host_ip.startswith('192.168'):
                    url = 'https://192.168.100.7/tools/otpw/' + fname
                else:
                    url = 'https://172.25.106.31/tools/otpw/' + fname

                try:
                    resp = urllib2.urlopen(url)
                    otpw_content = resp.read()
                    download_success = True
                    log.debug("Downloaded otpw file %s"%url)
                except (urllib2.URLError) as e:
                    log.error("SF SSH OTPW: Exception: %s" % e)
                    log.error("SF SSH OTPW: Failed to download otpw file %s"%url)
                    raise GenericSSHError(
                            "SF SSH OTPW: Failed to download otpw file %s"%url)

                try:
                    otpw_fh = open(otpw_fpath, 'w')
                    otpw_fh.write(otpw_content)
                    otpw_fh.close()
                except (IOError) as e:
                    log.error("SF SSH OTPW: Exception: %s" % e)
                    log.error("SF SSH OTPW: Failed to write downloaded otpw file %s."%otpw_fpath)
                    raise GenericSSHError(
                            "SF SSH OTPW: Failed to write downloaded otpw file.%s."%otpw_fpath)
            try:
                f = open(otpw_fpath)
            except:
                log.error("SF SSH OTPW: failed to open %s" % otpw_fpath)
                raise GenericSSHError("SF SSH OTPW: failed to open %s"
                        % otpw_fpath)
            return f

        def otpw_handler(title, instructions, prompt_list):
            """ Auth handler for interactive one-time-password prompts. """
            # Define this within _auth so we have access to all its vars.
            #
            # e.g. handler('title', 'instructions', [('Password:', False)])
            # a "prompt" is a tuple of prompt & whether to echo the user text
            # Expected OTPW prompt: "Password 730:", "Password 163/391/770:"
            answer_list = []
            log.debug("SF SSH OTPW called")
            log.debug("SF SSH OTPW: Title: %s" % title)
            log.debug("SF SSH OTPW: Instructions: %s" % instructions)
            log.debug("SF SSH OTPW: prompt_list: %s" % str(prompt_list))
            for (question, show) in prompt_list:
                log.debug("SF SSH OTPW: prompt: %s" % question)
                m = re.match("Password ([0-9/]+):", question)
                if m:
                    # It's an OTPW prompt
                    # Note that all the numbers here are str, not int.
                    self.auth_interactive_method = "otpw"
                    self.otpw_prompt = question
                    if self.wrong_otpw:
                        answer_list.append("wrong")
                        continue
                    num_list = m.group(1).split('/')
                    f = open_otpw_file()
                    num_pass_dict = {}
                    for line in f:
                        mline = re.match('([0-9]+) +([a-z ]+)$', line)
                        line_num = mline.group(1)
                        num_pass = mline.group(2)
                        if line_num in num_list:
                            num_pass_dict[line_num] = num_pass
                        if len(num_pass_dict) == len(num_list):
                            break
                    otpw_pass = ''
                    for num in num_list:
                        if not otpw_pass:
                            otpw_pass = 'SF' + num_pass_dict[num]
                        else:
                            otpw_pass += num_pass_dict[num]
                    answer_list.append(otpw_pass)
                elif re.match('Password:', question):
                    # Standard password prompt, but with keyboard-interactive
                    # This only works if this handler is defined under _auth()
                    if allow_password:
                        answer_list.append(password)
                    else:
                        answer_list.append("")
                        # still set method to password, expecting it to fail
                    self.auth_interactive_method = "password"
                else:
                    # We don't recognize the prompt
                    answer_list.append('')
                    self.auth_interactive_method = None
                log.debug("SF SSH OTPW: answer: %s" % answer_list[-1])
            log.debug("SF SSH OTPW: answer_list: %s" % answer_list)
            return(answer_list)
            # END otpw_handler

        # Just keep trying different types till we succeed or run out
        saved_exception = None

        # auth_none - fail, but get the list of auth methods
        # Not actually helpful. If otpw enabled, we still don't kno

        # auth_publickey
        if allow_publickey:
            self.auth_method = "auth_publickey"
            if pkey is not None:
                try:
                    log.debug('Trying SSH key %s' % hexlify(pkey.get_fingerprint()))
                    self._transport.auth_publickey(username, pkey)
                    return
                except paramiko.SSHException, e:
                    saved_exception = e

            for key_filename in key_filenames:
                for pkey_class in (RSAKey, DSSKey):
                    try:
                        key = pkey_class.from_private_key_file(
                                key_filename, password)
                        log.debug('Trying key %s from %s'
                                % (hexlify(key.get_fingerprint()), key_filename))
                        self._transport.auth_publickey(username, key)
                        return
                    except paramiko.SSHException, e:
                        saved_exception = e

            if allow_agent:
                if self._agent == None:
                    self._agent = Agent()

                for key in self._agent.get_keys():
                    try:
                        log.debug('Trying SSH agent key %s'
                                % hexlify(key.get_fingerprint()))
                        self._transport.auth_publickey(username, key)
                        return
                    except paramiko.SSHException, e:
                        saved_exception = e

            keyfiles = []
            rsa_key = os.path.expanduser('~/.ssh/id_rsa')
            dsa_key = os.path.expanduser('~/.ssh/id_dsa')
            if os.path.isfile(rsa_key):
                keyfiles.append((RSAKey, rsa_key))
            if os.path.isfile(dsa_key):
                keyfiles.append((DSSKey, dsa_key))
            # look in ~/ssh/ for windows users:
            rsa_key = os.path.expanduser('~/ssh/id_rsa')
            dsa_key = os.path.expanduser('~/ssh/id_dsa')
            if os.path.isfile(rsa_key):
                keyfiles.append((RSAKey, rsa_key))
            if os.path.isfile(dsa_key):
                keyfiles.append((DSSKey, dsa_key))

            if not look_for_keys:
                keyfiles = []

            for pkey_class, filename in keyfiles:
                try:
                    key = pkey_class.from_private_key_file(filename, password)
                    log.debug('Trying discovered key %s in %s'
                            % (hexlify(key.get_fingerprint()), filename))
                    self._transport.auth_publickey(username, key)
                    return
                except paramiko.SSHException, e:
                    saved_exception = e
                except IOError, e:
                    saved_exception = e

        # OTP
        if allow_interactive:
            self.auth_method = "auth_interactive"
            try:
                self.otpw_file = BO_OTPW_FILE
                log.debug("Trying otpw")
                ret = self._transport.auth_interactive(username, otpw_handler)
                log.debug("otpw succeeded: %s" % ret)
                return
            except paramiko.SSHException as e:
                log.debug("otpw failed: %s" % e)

                try:
                    self.otpw_file = BE_OTPW_FILE
                    log.debug("Re-trying otpw with old file")
                    ret = self._transport.auth_interactive(username, otpw_handler)
                    log.debug("otpw succeeded: %s" % ret)
                    return
                except paramiko.SSHException as e:
                    log.debug("forced otpw failed: %s" % e)

        # auth_password
        if allow_password:
            self.auth_method = "auth_password"
            try:
                log.debug("Trying auth_password: %s, %s"%(username, password))
                self._transport.auth_password(username, password, fallback=False)
                return
            except paramiko.SSHException, e:
                saved_exception = e
                if (password == BE_NODE_PASSWD or
                    password == BO_NODE_PASSWD or
                    password == CLIENT_PASSWD):

                    # Last ditch effort:
                    #
                    # SSH failed password authentication with the old password.
                    # What happens if we just try again with the new password?
                    #
                    try:
                        if password == BE_NODE_PASSWD:
                            password = BO_NODE_PASSWD
                        elif password == BO_NODE_PASSWD:
                            password = BE_NODE_PASSWD
                        elif password == CLIENT_PASSWD:
                            password = OLD_CLIENT_PASSWD

                        self._transport.auth_password(username, password, fallback=False)
                        saved_exception = None
                        return
                    except paramiko.SSHException, e:
                        saved_exception = e

        # If we haven't returned yet, we've failed
        raise GenericSSHError, "All auth methods failed."

#-----------------------------------
# Run a simple command return output --SridharVana
#-----------------------------------
@contextmanager
def run_ssh_context(host, cmd, username=DEFAULT_USERNAME,
                    passwd=None, port=22):
    """Run SSH command and yield output.
    Close
    """
    log.debug("Running command [%s]" % cmd)
    ssh_inst = SSH(host, username, passwd, rfiles=True, port=port)
    stdout, stderr, exit_status = ssh_inst.run_command_safe(cmd)
    yield stdout

    #Close the connection once it reaches here.
    #If it didnt reach it mean there is an error with the Connection.

    if exit_status:
        raise GenericSSHError("Command %s Failed due to %s"%(
        cmd, stderr))

    ssh_inst.close()

#----------------------------
#Run Interactive Nested Shell
#----------------------------

class NestedSSH(SSH):
    def run_command(self, cmd, func_=None):
        """ Run the passed command, return stdin,stdout,stderr if specified at
        instantiation.
        """
        log.debug("Running cmd: \n%s" % cmd)

        bufsize = -1
        try:
            chan = self.client._transport.open_session()
            chan.exec_command(cmd)
            stdin = chan.makefile('wb', bufsize)
            stdout = chan.makefile('rb', bufsize)
            stderr = chan.makefile_stderr('rb', bufsize)

        except paramiko.SSHException, ssh_error:
            raise GenericSSHError, "%s" % str(ssh_error)

        return stdin, stdout, stderr, None
