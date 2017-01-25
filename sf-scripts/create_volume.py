#!/usr/bin/python
# vim: tabstop=4 shiftwidth=4 softtabstop=4
# Copyright 2012 SolidFire Inc
########################################################################
#
# Id: $Id:$
# Header: $Header:$
# Date: $Date:$
#
########################################################################


"""
Simple demo script to show how to create volumes on a SolidFire Cluster.
"""

import json
import logging
import sys

from math import pow
from optparse import OptionParser
from SolidFireAPI import SolidFireAPI


def process_options():
    """Pretty much boilerplate for all of our scripts.  Not much interesting
    just some monotony parsing out command line options and finally
    instantiating a cluster object.
    """
    config = {}
    usage = "usage: %prog [options]\nCreate new volume(s)"
    parser = OptionParser(usage, version='%prog 1.1')

    parser.add_option('-V', '--verbose', action='store_true',
                      default=False,
                      dest='verbose',
                      help='Enable verbose messaging.')

    parser.add_option('-C', '--ClusterConfigFile', action='store',
                      type='string',
                      default=None,
                      dest='json_config',
                      help='JSON formatted cluster config, used'
                      ' to specify a SolidFire Cluster other than the default '
                      ' set up in the SolidFireAPI object',)

    parser.add_option('-n', '--basename', action='store',
                      type='string',
                      default='demoVolume',
                      dest='volume_basename',
                      help='Name to assign to newly created volume(s).'
                           '  Appended with integer for mutliple volumes.'
                           '  Default = \"demoVolume\".')

    parser.add_option('-i', '--accountid', action='store',
                      type='int',
                      default=-1,
                      dest='account_id',
                      help='Account ID to associate new volume with.')

    parser.add_option('-s', '--size', action='store',
                      type='int',
                      default=1,
                      dest='volume_size',
                      help='Size of new volume(s) in GB (n*10^9).')

    parser.add_option('-c', '--count', action='store',
                      type='int',
                      default=1,
                      dest='volume_count',
                      help='Number of volumes to create (default = 1).')

    parser.add_option('-a', '--accountname', action='store',
                      type='string',
                      default=None,
                      dest='account_name',
                      help='Account name to associate with volume.  '
                           'If account does not exist we create it '
                           '(use to create new account).')

    parser.add_option('-q', '--qoslevel', action='store',
                      type='string',
                      default='off',
                      dest='qos_attr',
                      help='QOS level to set in attributes. '
                           'Examples are: '
                           '\"slow|medium|fast|performance|off\" '
                           '(default=off). '
                           'NOTE: This does not turn on QOS, but sets '
                           'an attribute on the volume that can be used '
                           'for setting QOS on later. Sets a key/val '
                           'attribute: \"service-level\": \"fast\" .'
                           'You can set any attribute you like, but these '
                           'are examples our scripts use.')

    parser.add_option('-S', '--secrets', action='store',
                      type='string',
                      default=None,
                      dest='chap_secrets',
                      help='Initiator and Target CHAP passwords to use.  '
                           'This is ONLY applicable when creating a new '
                           'account, as CHAP settings are associated with '
                           'the account owning the volume.  If a new account '
                           'is created and no chap_secret is specified one '
                           ' will be generated randomly.')

    parser.add_option('-e', '--emulation', action='store_true',
                      default=False,
                      dest='emulation',
                      help='Enable 512 byte emulation.')

    (options, args) = parser.parse_args()

    if options.verbose:
        logging.basicConfig(level=logging.DEBUG)
    else:
        logging.basicConfig(level=logging.INFO)

    if options.json_config is not None:
        logging.info('Using provided json file for cluster info')
        config_text = open(options.json_config, 'r').read()
        config = json.loads(config_text)

    if config:
        logging.debug('Config is:%s' % config)
        cluster_object = SolidFireAPI(**config)
    else:
        cluster_object = SolidFireAPI()

    return (cluster_object, options)

if __name__ == "__main__":

    if len(sys.argv) == 1:
        sys.argv.append('-h')

    (SFC, options) = process_options()

    # start with some sanity checks
    if all([options.account_id is None, options.account_name is None]):
        logging.error('Sorry, you must specify --accountid OR --accountname')
        logging.error('try \"%prog -h\" for more info')

    accountID = options.account_id
    if accountID == -1:
        account = SFC.get_account_by_name(options.account_name)
        if account is None or 'accountID' not in account:
            logging.info('Account not found, creating one now...')
            account = SFC.add_account(options.account_name,
                                      options.chap_secrets)

        accountID = account['accountID']

    vol_attributes = {'QOS_level': options.qos_attr}
    created_volumes = []
    for volnum in xrange(0, options.volume_count):
        volname = options.volume_basename + '-' + str(volnum)
        kwargs = {'name': volname,
                  'accountID': accountID,
                  'totalSize': int(options.volume_size * pow(10, 9)),
                  'enable512e': options.emulation,
                  'attributes': vol_attributes}
        logging.info('Creating volume with name/attributes:%s/%s'
                     % (volname, vol_attributes))
        logging.debug('KWARGS for create_volume:%s' % kwargs)
        SFC.create_volume(**kwargs)
