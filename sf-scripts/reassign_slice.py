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
Simple demo script to illustrate setting QOS directly on a volume or
number of volumes.
"""

import json
import logging
import re
import sys

from optparse import OptionParser
from SolidFireAPI import SolidFireAPI


def process_options():
    """Pretty much boilerplate for all of our scripts.  Not much interesting
    just some monotony parsing out command line options and finally
    instantiating a cluster object.
    """
    config = {}
    usage = "usage: %prog [options]"\
            "\n\nSets or clears qos on specified volume(s)"
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

    parser.add_option('-i', '--accountid', action='store',
                      type='int',
                      default=-1,
                      dest='account_id',
                      help='Filter volumes by accountID '
                           '(omit for ALL active volumes).')

    parser.add_option('-p', '--primary', action='store',
                      type='string',
                      default='off',
                      dest='primary_id',
                      help='Primary slice id. ')

    parser.add_option('-s', '--secondary', action='store',
                      type='string',
                      default='off',
                      dest='secondary_id',
                      help='Secondary slice id. ')

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
        cluster_object = SolidFireAPI(**config)
    else:
        cluster_object = SolidFireAPI()

    return (cluster_object, options)

if __name__ == "__main__":

    if len(sys.argv) == 1:
        sys.argv.append('-h')

    (SFC, options) = process_options()

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

    if options.account_id != -1:
        vol_list = SFC.get_volume_list_by_accountID(options.account_id)
    else:
        vol_list = SFC.get_volume_list()

    counter = 0
    for v in vol_list:
        logging.debug('Volume:%s' % v)
        if v['volumeID'] in volid_list:
            params = {'sliceID': int(v['volumeID'])}
            result = SFC.issue_api_request('GetSliceInfo', params, version='7.0')
            dbVersion=result["dbVersion"]
            print "dbVersion: %s" % dbVersion
            params = {'sliceID': int(v['volumeID']),
                      'dbVersion': dbVersion,
                      'primary': options.primary_id,
                      'secondaries': [options.secondary_id],
                      'action': 'Required'
                     }

            # logging.info( 'Changing volume %d to have primary %d and secondary %d' %
                           # int(v['volumeID'],options.primary_id, options.secondary_id
                        # )
            result = SFC.issue_api_request('ReassignSlice', params, version='7.0')
            if 'error' in result:
                logging.error('Failed to change slice assignment' % result['error'])
            else:
                counter += 1

    # jtw if counter < len(vol_list):
    if counter < len(volid_list):
        logging.warning('Only modified %s of %s requested volumes?'
                        % (counter, len(volid_list)))
    else:
        logging.info('Succesfully modified %s volumes.' % counter)
