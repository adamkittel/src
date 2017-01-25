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
Simple demo script to create/initialize a new Cluster
"""

import json
import logging
import sys

from optparse import OptionParser
from SolidFireAPI import SolidFireAPI

logging.basicConfig(level=logging.DEBUG)


def process_options():
    """
    Just getopt for the most part, there are quite a few options needed
    for cluster setup, so we just use -C and take in a cluster config file.
    Of course this can be easily modified to take arguments on the command
    line.

    Possible enhancements:
    1. Provide argument to specify number of slice/volume drives
    2. Provide argumnet to specify number of block drives
    """
    config = {}
    usage = "usage: %prog [options]\n"\
            "Performs initial cluster config using supplied json file"
    parser = OptionParser(usage, version='%prog 1.1')
    parser.add_option('-C', '--ClusterConfigFile', action='store',
                      type='string',
                      default=None,
                      dest='json_config',
                      help='JSON formatted cluster config, used'
                      ' to specify a SolidFire Cluster other than the default '
                      ' set up in the SolidFireAPI object',)
    (options, args) = parser.parse_args()

    if options.json_config is not None:
        logging.info('Using provided json file for cluster info')
        config_text = open(options.json_config, 'r').read()
        config = json.loads(config_text)
    else:
        parser.error("Sorry, you must specify a valid configuration file!")

    if config:
        cluster_object = SolidFireAPI(**config)
    else:
        cluster_object = SolidFireAPI()

    return (cluster_object, options)


if __name__ == "__main__":
    """
    Uses a provided configuration file (json format) to create a cluster
    from a bare install.

    This entails setting IP's and assigning drives

    Example config:

    {
        "mvip": "192.168.69.200",
        "mip": "192.168.68.240"
        "svip": "192.168.69.201"
        "sip": "192.168.68.240",
        "login": "myadminuser",
        "password": "myadminpassword",
        "node_list":["192.168.68.240"]
    }

    """

    if len(sys.argv) == 1:
        sys.argv.append('-h')

    assigned_slice = False
    (SFC, options) = process_options()
    SFC.create_cluster()
    drive_list = SFC.get_drive_list(True)
    if len(drive_list) < 1:
        raise Exception('No drives in add list?')

    drive_param_list = []
    for d in drive_list:
        if assigned_slice:
            drive_param_list.append({'driveID': d['driveID'],
                'type': 'automatic'})
        else:
            drive_param_list.append({'driveID': d['driveID'],
                'type': 'volume'})
            assigned_slice = True

    params = {'drives': drive_param_list}
    results = SFC.issue_api_request('AddDrives', params)
