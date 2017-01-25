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
Simple demo script to show how to create accounts on a SolidFire Cluster.
"""

import json
import logging
import sys

from optparse import OptionParser
from SolidFireAPI import SolidFireAPI


def process_options():
    """Pretty much boilerplate for all of our scripts.  Not much interesting
    just some monotony parsing out command line options and finally
    instantiating a cluster object.
    """
    config = {}
    usage = "usage: %prog [options]\nCreate new account on SF cluster"
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

    parser.add_option('-a', '--accountname', action='store',
                      type='string',
                      default=None,
                      dest='account_name',
                      help='Name to use in new account creation.')

    parser.add_option('-S', '--secrets', action='store',
                      type='string',
                      default=None,
                      dest='chap_secrets',
                      help='Initiator and Target CHAP passwords to use.  '
                           ' If no chap secret is specified, then one '
                           ' will be generated randomly.')

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

    account = SFC.get_account_by_name(options.account_name)
    if account is None or 'accountID' not in account:
        logging.info('Account not found, creating one now...')
        account = SFC.add_account(options.account_name,
                                  options.chap_secrets)

        accountID = account['accountID']
        logging.info('Created new account with name: %s and ID: %s' % (options.account_name, accountID))
    else:
        logging.error('An account with the specified name %s already exists!' % options.account_name)

