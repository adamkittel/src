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

import json
import logging
import re
import sf_exceptions
import sys
import time
import pprint

from optparse import OptionParser
from SolidFireAPI import SolidFireAPI


def process_options():
    """Pretty much boilerplate for all of our scripts.  Not much interesting
    just some monotony parsing out command line options and finally
    instantiating a cluster object.
    """
    config = {}
    usage = "usage: %prog [options]"\
            "\n\nCreates n number of clones of specified volume(s)"
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
                      ' set up in the SolidFireAPI object')

    parser.add_option('-r', '--vidrange', action='store',
                      type='string',
                      default=None,
                      dest='volid_range',
                      help='Range of IDs to perform action on.'
                      ' quoted string containing a range of IDs.'
                      ' ie: \"1-5\" to select 1,2,3,4 and 5')

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

    parser.add_option('-n', '--clonespervolume', action='store',
                      type='int',
                      default=1,
                      dest='clones_per_volume',
                      help='Number of clones to create for each volume '
                           'omit for the default of 1.')

    parser.add_option('-N', '--no-waitasync', action='store_true',
                      default=False,
                      dest='no_asyncwait',
                      help='Do not wait for async operations '
                           'to complete before exiting. ')
# jtw adds for I-Behavior
    parser.add_option('-M', '--mart-name', action='store',
                      type='string',
                      default=None,
                      dest='mart_name',
                      help='Mart name associated with clone.'
                      ' ie: \"Mart-N\"',)

    parser.add_option('-I', '--target-accountid', action='store',
                      type='int',
                      default=0,
                      dest='target_account_id',
                      help='target account id '
                           'omit to use the source account id.')

# jtw end adds for I-Behavior

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
    """Simple script to clone volumes on a SolidFire device.

    The thing about CloneVolume is that it's async, no big deal,
    BUT the important thing to know is we have limits based on
    node and slice file combinations.  These limits restrict the
    number of simultaneous clone or snapshot jobs that can take place
    simultaneously.

    These limits are subject to change from release to release.  So
    you can obtain them via the GetLimits API call.

    In this particular case we're just going to try and create our clones
    and look for an exception from the API to tell us we have to wait.

    """

    if len(sys.argv) == 1:
        sys.argv.append('-h')

    (SFC, options) = process_options()

    if options.account_id != -1:
        vol_list = SFC.get_volume_list_by_accountID(options.account_id)
    else:
        vol_list = SFC.get_volume_list()

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

    # jtw snap_params = {'volumes': volid_list,
    # jtw                'name': options.mart_name
    # jtw               }

    # jtw SFC.issue_api_request('CreateGroupSnapshot', snap_params, version='6.0')

    async_handle_list = []
    counter = 0
    for v in vol_list:
        logging.debug('Volume:%s' % v)
        if v['volumeID'] in volid_list:
            id = v['volumeID']
            account = v['accountID']
            current_attr = v['attributes']
            name = v['name']

            params = {'volumeID': int(id)}

            try:
                async_handle = SFC.issue_api_request('ListSnapshots', params, version='6.0')
                async_handle_list.append(async_handle)
            except sf_exceptions.MaxSimultaneousClonesPerVolume:
                waiting = True
                while waiting:
                    waiting = False
                    time.sleep(1)
                    try:
                        async_handle = SFC.issue_api_request('CloneVolume',
                                                             params)
                        async_handle_list.append(async_handle)
                    except sf_exceptions.MaxSimultaneousClonesPerVolume:
                        waiting = True
                    except:
                        raise
            pprint.pprint(async_handle)
            counter += 1


    if not options.no_asyncwait:
        # At this point all of our async cmds have been issued
        # One last thing, we should hang around until they actually complete :)
        # I hate dumb polling but it works...
        logging.info('waitasync was selected, wait for jobs to complete...')
        outstanding = True
        while outstanding:
            for h in async_handle_list:
                outstanding = False
                if 'asyncHandle' in h:
                    params = {'asyncHandle': h['asyncHandle']}
                    status = SFC.issue_api_request('GetAsyncResult', params)
                    if 'running' in status:
                        outstanding = True
                        time.sleep(1)
    else:
        logging.info('waitasync was NOT selected, exiting without checks...')

    if counter < len(volid_list):
        logging.warning('Only cloned %s of %s requested.'
                        % (counter, len(volid_list)))
    else:
        logging.info('Succesfully cloned %s volumes.' % counter)
