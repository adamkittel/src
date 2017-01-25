"""
Logging for SolidFire automation

The logging levels are represented numerically in the following order::
    logging.DEBUG    = 0
    logging.INFO     = 1
    logging.ERROR    = 2
    logging.CRITICAL = 3
    logging.INFO     = 4

In a script; sets up logging to stdout + file at logging.INFO level::

    import lib.SFLogging as SFLogging

    if __name__ == '__main__':

        my_logfile = os.path.splitext(os.path.basename(__file__))[0]+'.log'
        log = SFLogging.get_sflogging(logging_level=1,
                                      logfile=my_logfile)
        main()

In a module that is NOT directly called by the Controller/RF (Robot Framework) -
the logging level has been set to logging.DEBUG for this module.::

    import lib.SFLogging as SFLogging

    log = SFLogging.get_sflogging(logging_level=0, module=True)

    def testing_module():
        log.debug("In my module %s" % os.getcwd())

"""

import os
import sys
import time
import shutil
import logging
from os.path import splitext, basename

# Copied from logging, so we can use without importing logging
CRITICAL = 50
FATAL = CRITICAL
ERROR = 40
WARNING = 30
WARN = WARNING
INFO = 20
DEBUG = 10
NOTSET = 0

# Since logging.getLogger is already a singleton, every time we call
# get_sflogging we need to make sure that we are not adding another handler to
# the instance.  Otherwise we get duplicate log messages.  Be careful, as
# currently implemented, if we change the logger value to "" we will end up w/
# NO log messages, the reason being is that StreamHandler is automatically added
# as a handler BEFORE the singleton is returned == no logging.
#
# If we want to use a root logger, maybe some logic around determining if the
# name of the logger is "root"??  Or subclassing a root logger??

class SFLogger:
    def get_logger(self, logging_level, logger, logfile):
        sshdebug = os.environ.get('SSHDEBUG')
        if sshdebug:
            log = logging.getLogger("")
        else:
            log = logging.getLogger(logger)

        if logger == 'sfbot-null':
            log.addHandler(NullHandler())

        if not len(log.handlers):
            sfrobot = os.environ.get('SFROBOT') == 'True'

            # We can manipulate the logging level here.
            # logging_level of 1 or 4 == logging.INFO
            if not logging_level in range(0,4):
                logging_level = 1

            llevel = (logging.DEBUG, logging.INFO, logging.CRITICAL,
                logging.ERROR, logging.INFO)[logging_level]

            # If we are running Robot Framework, we want to log to sys.__stdout__;
            # allows us to send messages to the console and the log.html file that RF
            # produces.
            if sfrobot:
                console = logging.StreamHandler(sys.__stdout__)
                log.setLevel(llevel)
                lformat = logging.Formatter("%(asctime)s %(levelname)-3s [%(module)s:%(lineno)d]" \
                                            +" %(message)s")
                console.setFormatter(lformat)
                log.addHandler(console)

            # Create a normal "root" logger.
            else:
                # log = logging.getLogger(logger)
                shandler = logging.StreamHandler()
                log.setLevel(llevel)
                lformat = logging.Formatter("%(asctime)s %(levelname)-3s [%(module)s:%(lineno)d]" \
                                        +" %(message)s")
                shandler.setFormatter(lformat)
                log.addHandler(shandler)
                #fhandler = logging.FileHandler(logfile, 'w')
                #fhandler.setFormatter(lformat)
                #log.addHandler(fhandler)

        return log

class NullHandler(logging.Handler):
    """ A null handler logger so that sfbot can log to nothing if it wants. """

    def emit(self, record):
        pass

def put_rotating_file(infile, outfile, ssh_inst=None, max_backup=10):
    """function will save infile as outfile, either locally or remotely, saving
    any existing files with extensions '.1', '.2', etc. appended to it.

    for example:
    put_rotating_file('/tmp/iscsid.conf.default', '/etc/iscsi/iscsid.conf',
                      ssh_inst=ssh_inst, max_backup=5)

    will put the local file: /tmp/iscsid.conf.default onto the client specified
    by ssh_inst. If there is already an /etc/iscsi/iscsid.conf file on the
    client, it will save it as /etc/iscsi/iscsid.conf.1, and onwards up to 5
    backups
    """
    outdir = shutil.os.path.dirname(outfile)
    infilename = infile.replace(shutil.os.path.dirname(infile)+ '/', '')
    outfilename = outfile.replace(outdir + '/', '')

    # get list of files in outdir
    if ssh_inst:
        rfiles_in = ssh_inst.rfiles
        if not rfiles_in:
            ssh_inst.rfiles = True
        files = ssh_inst.run_command_safe('ls -a ' + outdir)[-3]
        ssh_inst.rfiles = rfiles_in
    else:
        files = shutil.os.listdir(outdir)

    # extract file names that start with the outfile name
    files = [f for f in files if f.startswith(outfilename)]
    # extract files that either match the outfile name or end in a number
    files = [f for f in files if f==outfilename or f.split('.')[-2].isdigit()]
    # create another filename if the number of files is less than max backups
    if len(files) <= max_backup:
        files.append('{0}.{1}'.format(outfilename, len(files)))
    files.sort(reverse=True)
    if ssh_inst:
        cmd = ''
        for i in range(1, len(files)):
            oldfilename = shutil.os.path.normpath(outdir + '/' + files[i])
            newfilename = shutil.os.path.normpath(outdir + '/' + files[i-1])
            cmd = cmd + 'mv {0} {1}; '.format(oldfilename, newfilename)
        ssh_inst.run_command_safe(cmd)
        ssh_inst.put([infile], remote_path=outfile)
    else:
        for i in range(1, len(files)):
            oldfilename = shutil.os.path.normpath(outdir + '/' + files[i])
            newfilename = shutil.os.path.normpath(outdir + '/' + files[i-1])
            shutil.move(oldfilename, newfilename)
        shutil.copy(infile, outfile)

def get_sflogging(logging_level=1, logger="SFLOGGER", logfile=False):
    """ Our factory function to either setup the logging or get the desired
    root logger.

    :param logging_level: Specify the numerical logging level
    :param module: Boolean specifying instantiation for a module as opposed to
        a script.
    :param logger: The name of the root logger we want to log to.  Most of the
        time not necessary to modify.
    :param logfile: Specify a logfile to log to, not applicable in module
        context; defaults to the name of the calling script w/ a .log extension.
    """

    # NOTE: When called in the context of autotest/Django, __file__ is not
    #       present, so we do the following.

    if not logfile:
        try:
            logfile = splitext(basename(sys.modules['__main__'].__file__))[0]+'.log'
        except AttributeError:
            logfile = "/tmp/idontknow_whereiam.log"

    Logger = SFLogger()
    return Logger.get_logger(logging_level, logger, logfile)
