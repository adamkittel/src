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
Simple demo script to show how to delte volume(s) on a SolidFire Cluster.
"""

import json
import logging
import re
import sys

from operator import itemgetter
from optparse import OptionParser
from SolidFireAPI import SolidFireAPI


def process_options():
    """Pretty much boilerplate for all of our scripts.  Not much interesting
    just some monotony parsing out command line options and finally
    instantiating a cluster object.
    """
    config = {}
    usage = "usage: %prog [options] <operation>\n\
            where operation is: (delete | restore | purge) \
            Performs requested <operation> on specified volume id's \
            Id's are specified using either --vidrange, or --vidlist or both"
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
                      ' set up in the SolidFireAPI object.')

    parser.add_option('-r', '--vidrange', action='store',
                      type='string',
                      default=None,
                      dest='volid_range',
                      help='Range of IDs to perform action on.'
                      ' quoted string containing a range of IDs.'
                      ' ie: \"1-5\" to select 1,2,3,4 and 5.')

    parser.add_option('-l', '--vidlist', action='store',
                      type='string',
                      default=None,
                      dest='vol_ids',
                      help='Comma seperated list of IDs to perform action on.'
                      ' ie: \"1,3,4,5,9\"',)

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

    return (cluster_object, options, args)


def restore_volumes(sf, volid_list):
    params = {}
    results = sf.issue_api_request('ListDeletedVolumes', params)
    if 'error' in results:
        logging.error('Failed to get list of deleted volumes:%s'
                % results['error'])
        logging.error('Unable to continue!')
        sys.exit(1)

    vol_list = results['volumes']
    sorted_vols = sorted(vol_list, key=itemgetter('volumeID'))

    completed_count = 0
    for v in sorted_vols:
        if v['volumeID'] in volid_list:
            params = {'volumeID': v['volumeID']}
            logging.info('Restoring deleted volume (id: %s)'
                         % v['volumeID'])
            sf.issue_api_request('RestoreDeletedVolume', params)
            if 'error' in results:
                logging.error('Failed to restore deleted volume:%s'
                              % results['error'])
                logging.warning('Will continue to attempt restoring\
                                 remaining volumes')
            else:
                completed_count += 1

    return (len(sorted_vols), completed_count)


def purge_volumes(sf, volid_list):
    params = {}
    results = sf.issue_api_request('ListDeletedVolumes', params)
    if 'error' in results:
        logging.error('Failed to list of deleted volume:%s' % results['error'])
        logging.error('Unable to continue!')
        sys.exit(1)

    vol_list = results['volumes']
    sorted_vols = sorted(vol_list, key=itemgetter('volumeID'))

    completed_count = 0
    for v in sorted_vols:
        if v['volumeID'] in volid_list:
            params = {'volumeID': v['volumeID']}
            logging.info('Purging deleted volume (id:%s)' % v['volumeID'])
            results = sf.issue_api_request('PurgeDeletedVolume', params)

            if 'error' in results:
                logging.error('Failed to set purge volume:%s'
                              % results['error'])
                logging.warning('Will continue to attempt purging \
                                 remaining volumes')
            else:
                    completed_count += 1

    return (len(sorted_vols), completed_count)


def delete_volumes(sf, volid_list):
    params = {}
    results = sf.issue_api_request('ListActiveVolumes', params)
    if 'error' in results:
        logging.error('Failed to retrieve active volume:%s' % results['error'])
        logging.error('Unable to continue!')
        sys.exit(1)

    vol_list = results['volumes']
    sorted_vols = sorted(vol_list, key=itemgetter('volumeID'))

    completed_count = 0
    for v in sorted_vols:
        if v['volumeID'] in volid_list:
            params = {'volumeID': v['volumeID']}
            logging.info('Deleting volume (id: %s)'
                         % v['volumeID'])
            results = sf.issue_api_request('DeleteVolume', params)
            if 'error' in results:
                logging.error('Failed to set delete volume:%s'
                              % results['error'])
                logging.warning('Will continue to attempt deletion of \
                                 remaining volumes')
            else:
                completed_count += 1

    return (len(sorted_vols), completed_count)


if __name__ == "__main__":

    if len(sys.argv) == 1:
        sys.argv.append('-h')

    (SFC, options, args) = process_options()
    discovered = -1
    completed = -1

    volid_list = []
    if options.vol_ids is not None:
        ids = re.findall(r'\w+', options.vol_ids)
        for i in ids:
            volid_list.append(int(i))

    if options.volid_range is not None:
        r = re.findall(r'\w+', options.volid_range)
        assert len(r) == 2
        volid_list.extend(range(int(r[0]), int(r[1]) + 1))

    # remove duplicate ID's from the list
    volid_list = list(set(volid_list))

    if len(args) < 1:
        logging.error("It seems you forgot to specify what"
                      " operation you want performed?")
        logging.error('Try running -h for usage...')
        sys.exit(1)

    if args[0].lower() == 'restore':
        (discovered, completed) = restore_volumes(SFC, volid_list)
    elif args[0].lower() == 'purge':
        (discovered, completed) = purge_volumes(SFC, volid_list)
    elif args[0].lower() == 'delete':
        (discovered, completed) = delete_volumes(SFC, volid_list)
    else:
        logging.error('Sorry, %s is not a valid command!'
                      % args[0].lower())

        logging.error('Try running -h for usage...')
        sys.exit(1)

    logging.debug('discovered: %s, completed: %s' % (discovered, completed))
    if discovered == -1 or completed == -1:
        logging.error('Unknown error, failed to receive any count information'
                      ' from calls!!')
    else:
        logging.info('Completed %s operation on %s of %s requested volumes.'
                     % (args[0], completed, len(volid_list)))
