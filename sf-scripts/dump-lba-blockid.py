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

########################################################################
#
# External libraries
#
########################################################################

import json
import logging
import re
import sys
import pprint
import time
import timeit
import math

from optparse import OptionParser
from SolidFireAPI import SolidFireAPI

########################################################################
#
# Global variables and aliases
#
########################################################################

pp = pprint.PrettyPrinter(indent=4)
#logging.basicConfig(level=logging.INFO)


########################################################################
#
# Function name: process_options
#
# Description: Parse command line inputs
#
########################################################################

def process_options():
    config = {}
    usage = "usage: %prog [options]"\
            "\n\nDisplay information for specified volume(s)"
    parser = OptionParser( usage, version='%prog 1.1' )

    parser.add_option( '-V', '--verbose', action='store_true',
                       default=False,
                       dest='verbose',
                       help='Enable verbose messaging.'
                      )

    parser.add_option( '-C', '--ClusterConfigFile', action='store',
                       type='string',
                       default=None,
                       dest='json_config',
                       help='JSON formatted cluster config, used'
                       ' to specify a SolidFire Cluster other than the default'
                       ' set up in the SolidFireAPI object.'
                     )

    parser.add_option( '-r', '--vidrange', action='store',
                       type='string',
                       default=None,
                       dest='volid_range',
                       help='Range of IDs to perform action on.'
                       ' quoted string containing a range of IDs.'
                       ' ie: \"1-5\" to select 1,2,3,4 and 5.'
                      )

    parser.add_option( '-l', '--vidlist', action='store',
                       type='string',
                       default=None,
                       dest='vol_ids',
                       help='Comma seperated list of IDs to perform action on.'
                       ' ie: \"1,3,4,5,9\"'
                     )

    parser.add_option( '-i', '--accountid', action='store',
                       type='int',
                       default=-1,
                       dest='account_id',
                       help='Filter volumes to display using this account ID.'
                     )

    parser.add_option( '-I', '--interval', action='store',
                       type='int',
                       default=1,
                       dest='interval',
                       help='Filter volumes to display using this account ID.'
                     )

    ( options, args ) = parser.parse_args()

    if options.verbose:
        print 'Caught it...'
        logging.basicConfig(level=logging.DEBUG)
    else:
        logging.basicConfig(level=logging.INFO)

    if options.json_config is not None:
        logging.info( 'Using provided json file for cluster info' )
        config_text = open(options.json_config, 'r').read()
        config = json.loads( config_text )

    if config:
        cluster_object = SolidFireAPI( **config )
    else:
        cluster_object = SolidFireAPI()

    return( cluster_object, options )

if __name__ == "__main__":
    if len( sys.argv ) == 1:
        sys.argv.append( '-h' )

    ( SFC, options ) = process_options()

    if ( options.account_id != -1 ):
        vol_list = SFC.get_volume_list_by_accountID( options.account_id )
    else:
        vol_list = SFC.get_volume_list()

    volid_list = []
    if ( ( options.vol_ids or options.volid_range ) is None ):
        volid_list = [v['volumeID'] for v in vol_list]

    if options.vol_ids is not None:
        ids = re.findall( r'\w+', options.vol_ids )
        for inx in ids:
            volid_list.append( int( inx ) )

    if options.volid_range is not None:
        r = re.findall( r'\w+', options.volid_range )
        assert len( r ) == 2
        volid_list.extend( range( int( r[0] ), int( r[1] ) + 1 ) )

    # remove duplicate ID's from the list
    volid_list = list( set( volid_list ) )

    if len( vol_list ) < 1:
        logging.error( 'It appears no volumes exist on your cluster?!?' )
        sys.exit( 1 )

    batch_size = 1000
    counter = 0
    for v in vol_list:
        logging.debug('Volume:%s' % v)
        if v['volumeID'] in volid_list:
            params = {'volumeID': int(v['volumeID'])}
            result = SFC.issue_api_request('GetVolumeStats', params)
            num_blocks = result["volumeStats"]["volumeSize"] / 4096 
            num_full_batches = math.trunc( num_blocks / batch_size )
            last_batch_size = num_blocks  - batch_size * num_full_batches

            inx = 0
            while inx < num_full_batches:
               params2 = { 'volumeID' : int( v['volumeID']),
                           'nBlocks' : batch_size,
                           'lba' : inx * batch_size }
               result2 = SFC.issue_api_request( 'ReadSliceLBA', params2, version='6.0' )
               pp.pprint(result2["blockIDs"])
               if 'error' in result:
                  logging.error('Failed to set QOS on volume:%s' % result['error'])
               else:
                  counter += 1
               inx += 1

            params2 = { 'volumeID' : int( v['volumeID']),
                        'nBlocks' : last_batch_size,
                        'lba' : inx * batch_size }
            result2 = SFC.issue_api_request( 'ReadSliceLBA', params2, version='6.0' )
# 
#     for v in volid_list:
#         if v['volumeID'] in volid_list:
#             params = {'volumeID': v['volumeID'] }
#             result = SFC.issue_api_request( 'GetVolumeStats', params )
#             params2 = { 'volumeID' : int( v['volumeID']),
#                         'nBlocks' : int( result['volumeSize'] / 4096 ),
#                         'lba' : 0,
#             result2 = SFC.issue_api_request( 'GetVolumeStats', params2 )
#             pp.pprint(result2)
#'nBlocks' : int( result["volumeStats"]["volumeSize"] / 4096 ),
