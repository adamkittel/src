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
This example module illustrates how to make various API calls to
a SolidFire Cluster.

This includes creating a new cluster as well as making various modifications.

This module is included as part of the demo-scripts package and the majority of
API calls that scripts in the package make are actually implemented as methods
here.
"""

import base64
import httplib
import json
import logging
import random
import sf_exceptions
import string
import time
import uuid


class SolidFireAPI:
    def __init__(self, **kwargs):
        """This simply creates our Cluster object, notice we have some
        hard-coded default values here.  If you're working with a single
        cluster, you can just edit these values and things are really easy.

        In the case of working with multiple SF Clusters, you can pass in
        the parameters  you want/need to modify using the variable length
        keyword arguments (**kwargs)

        """
        self.mip = '127.0.0.2'
        self.mvip = '127.0.0.4'
        self.port = '443'
        self.svip = '192.168.69.211'
        self.login = 'admin'
        self.password = 'solidfire'
        self.node_list = []
        self.rep_count = 2
        self.drv_ready_timer = 20

        # overrides
        if 'mip' in kwargs:
            logging.info('Setting MIP to:%s' % kwargs['mip'])
            self.mip = kwargs['mip']
        if 'mvip' in kwargs:
            logging.info('Setting MVIP to:%s' % kwargs['mvip'])
            self.mvip = kwargs['mvip']
        if 'port' in kwargs:
            logging.info('Setting PORT to:%s' % kwargs['port'])
            self.port = kwargs['port']
        if 'svip' in kwargs:
            logging.info('Setting SVIP to:%s' % kwargs['svip'])
            self.svip = kwargs['svip']
        if 'login' in kwargs:
            logging.info('Setting LOGIN to:%s' % kwargs['login'])
            self.login = kwargs['login']
        if 'password' in kwargs:
            logging.info('Setting PASSWORD')
            self.password = kwargs['password']
        if 'node_list' in kwargs:
            logging.info('Setting NODE_LIST to:%s' % kwargs['node_list'])
            self.node_list = kwargs['node_list']
        if 'rep_count' in kwargs:
            logging.info('Setting REP_COUNT to:%s' % kwargs['rep_count'])
            self.rep_count = kwargs['rep_count']
        if 'drv_ready_timer' in kwargs:
            logging.info('Setting DRV_READY_TIMER to:%s'
                    % kwargs['drv_ready_timer'])
            self.drv_ready_timer = kwargs['drv_ready_timer']

    def create_cluster(self):
        params = {'mvip': self.mvip,
                  'svip': self.svip,
                  'repCount': self.rep_count,
                  'username': self.login,
                  'password': self.password,
                  'nodes': self.node_list}

        self.issue_api_request('CreateCluster', params)

    # jtw
    def issue_api_request(self, method_name, params, version='1.0'):
        """ Every API call to the SolidFire Cluster goes through this method.
        The API calls are simple REST calls comprised of a "method name" and
        "parameters".

        The method name is simply the API request to issue, and the parameters
        are a python dict of the needed/required arguments

        There are a number of specific methods implemented in this class
        however they all call this at the lowest level.  You can either
        build up an object with all of your API methods, or build your
        own in scripts using this method

        Returns:
          'result' or 'error' dict entries ie:
            'result':{'account': {'username': 'jdg',... }
            'error':{'message':'', 'code': 500, 'name': 'xUnknownAccount'}
        """

        # Here we generate a random int to use as a requestID.  Each API
        # call sends an integer request ID and each response includes the
        # request ID with which it was called.  This is something you'll want
        # to check in cases where you may have a large number of API calls
        # occuring simultaneously.

        request_id = int(uuid.uuid4())
        command = {'method': method_name,
                   'id': request_id}
        if params is not None:
            command['params'] = params

        # That's about it for the API call itself
        # Now we just need to use some of the standard
        # python modules to convert our dicts to json format
        # and send them to the SF Cluster via http
        payload = json.dumps(command, ensure_ascii=False)
        payload.encode('utf-8')
        logging.debug('Payload for API call:%s' % payload)
        header = {'content-type': 'application/json-rpc; charset=utf-8'}

        auth_key = base64.encodestring('%s:%s'
                                       % (self.login, self.password))[:-1]
        header['authorization'] = 'Basic %s' % auth_key
        host = self.mvip
        if method_name is 'CreateCluster':
            logging.debug('Change host to MIP for cluster creation')
            host = self.mip
            logging.warning('Cluster creation may take a while, '
                            'please be patient...')

        # jtw
        api_endpoint = '/json-rpc/%s' % version

        connection = httplib.HTTPSConnection(host, self.port)
        logging.debug('Issuing call with payload and header: %s\n%s'
                % (payload, header))
        try:
            # jtw 
            connection.request('POST', api_endpoint, payload, header)
            response = connection.getresponse()
        except EnvironmentError as exc:
            logging.error('Error sending request to SolidFire Cluster,'
                          'is the cluster available?  Is your MVIP, login, '
                          'and or password correct?\n')
            raise
        logging.debug('API call response status:%s' % response.status)
        data = {}

        # At this point we've issued the request and should have
        # a response available
        if response.status == 200:  # indicates 'GOOD'
            data = response.read()
            data = json.loads(data)
            if 'error' in data:
                if 'MaxSnapshotsPerVolumeExceeded' in data['error']['name']:
                    raise sf_exceptions.MaxSimultaneousClonesPerVolume(
                        'max clones/snapshots per volume encountered',
                        data)
                elif 'MaxSnapshotsPerNodeExceeded' in data['error']['name']:
                    raise sf_exceptions.MaxSimultaneousClonesPerNode(
                        'max clones/snapshots per node encountered',
                        data)
                else:
                    logging.error('Error Response from API call:%s' % data)
                    raise sf_exceptions.APICommandException('Error detected in'
                        ' API response', data)

        elif response.status == 401:  # Authenication failed
            connection.close()
            raise sf_exceptions.ExceptionAuthenticationException(
                'Authentication error', data)
        else:  # some other error
            connection.close()
            logging.error('API call returned invalid response:%s'
                          % response.status)
            logging.error('\tResults were:%s' % json.loads(response.read()))
            raise Exception('API call failed')
        connection.close()

        if 'result' in data:
            return data['result']
        else:
            return data

    # Begin methods that do work using the api call method above
    def get_drive_list(self, wait_for_pending_nodes=False):
        """Querie the cluster for all drives and returns the drive
        objects in a list. The drive object like all objects for our api
        are basicly just dicts

        One thing about the ListDrives command, if you've just created
        the cluster there can be some timing issues with regard to receiving
        a complete list of drives.  Specifically if all of the nodes have not
        come online yet, you will not get a complete list.

        To deal with this we simply check that ListActiveNodes returns the
        same number of nodes that we assigned to the cluster
        (active == assigned)

        """

        drive_list = []
        max_wait_time = 30  # pending wait time in seconds
        start_time = time.time()

        while wait_for_pending_nodes:
            result = self.issue_api_request('ListActiveNodes', {})
            if 'nodes' not in result:
                raise Exception('Error from ListActiveNodes:%s' % result)
            if len(result['nodes']) == len(self.node_list):
                wait_for_pending_nodes = False
            else:
                #check our timer, exit or sleep
                curr_time = time.time()
                elapsed_time = (curr_time - start_time) * 1000.0
                if (elapsed_time > max_wait_time):
                    logging.info('Exceeded wait for time for Nodes to become'
                                 ' active (%s of %s seconds)'
                                 % (elapsed_time, max_wait_time))
                    wait_for_pending_nodes = False
                else:
                    time.sleep(3)

        #(jdg) There's one more gotcha here
        # There can be a lag between the time the nodes become ready and
        # the time before the drives themeselve are discoverable.
        # This is easy to deal with, we'll call ListDrives in a loop
        # until we have at least 'number_of_nodes * 11' drives OR a timeout
        # This covers the case of future releases where we will have more than
        # 11 drives per node, once we have more than 22 we have to change :)
        while((len(drive_list) < (len(self.node_list) * 11))
                and self.drv_ready_timer < 20):
            time.sleep(1)
            result = self.issue_api_request('ListDrives', {})
            if 'drives' not in result:
                raise Exception('Error from ListDrives:%s' % result)

            if len(result['drives']) >= len(self.node_list):
                for d in result['drives']:
                    logging.debug('Append drive object: %s' % d)
                    drive_list.append(d)
            else:
                logging.info('Waiting for drive ready detection on all nodes')
                logging.info('\tWill wait for another %s seconds'
                        % self.drv_ready_timer)
            self.drv_ready_timer -= 1

        return sorted(drive_list, key=lambda k: k['driveID'])

    def get_account_list(self):
        """Querie the cluster for all active accounts and returns
        the account objects found in a list
        """
        account_list = []
        params = {'startAccountID': '0',
                  'limit': 1000}
        result = self.issue_api_request('ListAccounts', params)
        if 'accounts' not in result:
            raise Exception('Error from ListAccounts:%s' % result)

        for a in result['accounts']:
            logging.debug('Append account object: %s' % a)
            account_list.append(a)

        return sorted(account_list, key=lambda k: k['accountID'])

    def get_account_by_name(self, name):
        """Attempt to retrieve an account object by name.
        Note, this is one of those cases where an error may
        be normal (ie account does not exist).
        """
        params = {'username': name}
        result = None
        try:
            result = self.issue_api_request('GetAccountByName', params)
        finally:
            if result is not None and 'account' in result:
                logging.debug('get_account_by_name returning: %s'
                        % result['account'])
                return result['account']
            else:
                logging.debug('get_account_by_name returning: None')
                return None

    def get_account_by_id(self, accountID):
        """Attempt to retrieve an account object by ID.
        Note, this is another case where an error may
        be normal (ie account does not exist).
        """
        params = {'accountID': accountID}
        result = self.issue_api_request('GetAccountByID', params)
        if 'account' in result:
            logging.debug('get_account_by_id returning: %s'
                    % result['account'])
            return result['account']
        else:
            logging.debug('get_account_by_id returning: %s'
                    % result['account'])
            return None

    def add_account(self, name, chap_secrets=None, attributes={}):
        """Adds a user account to the Cluster.  If chap_secrets is
        None, it will generate random CHAP passwords for the new account.
        """
        if chap_secrets is None:
            chap_secrets = self._generate_random_string(12)
        params = {'username': name,
                  'initiatorSecret': chap_secrets,
                  'targetSecret': chap_secrets,
                  'attributes': attributes}

        result = self.issue_api_request('AddAccount', params)
        if 'accountID' not in result:
            raise Exception('Failed AddAccount:%s' % result)
        return self.get_account_by_id(result['accountID'])

    def get_volume_list(self):
        """Queries the Cluster for all active Volumes, and returns a list
        of objects for all the Volumes found
        """
        volume_list = []
        params = {'startVolumeID': 0,
                  'limit': 1000}
        result = self.issue_api_request('ListActiveVolumes', params)
        if 'volumes' not in result:
            raise Exception('Failed ListActiveVolumes:%s' % result)

        for v in result['volumes']:
            logging.debug('Append volume object: %s' % v)
            volume_list.append(v)
        return sorted(volume_list, key=lambda k: k['volumeID'])

    def get_volume_list_by_accountID(self, accountID):
        """There are a number of ways to request volume info from the cluster,
        here's one that just gets those associated with an accountID
        """
        volume_list = []
        params = {'accountID': accountID}
        result = self.issue_api_request('ListVolumesForAccount', params)

        for v in result['volumes']:
            logging.debug('Append volume object: %s' % v)
            volume_list.append(v)

        # may be an empty list
        return sorted(volume_list, key=lambda k: k['volumeID'])

    def create_volume(self, **kwargs):
        """Create volume requires an accountID to be associated on
        creation.  This is where CHAP information is gathered from and
        as a result, the volume is exported and ready for use immediately
        upon creation.

        Size is specified in bytes
        """

        name = None
        accountID = None
        totalSize = None

        sliceCount = 1
        enable512e = False
        attributes = {}
        qos = {}

        if 'name' in kwargs:
            name = kwargs['name']
        if 'accountID' in kwargs:
            accountID = kwargs['accountID']
        if 'sliceCount' in kwargs:
            sliceCount = kwargs['sliceCount']
        if 'totalSize' in kwargs:
            totalSize = kwargs['totalSize']
        if 'enable512e' in kwargs:
            enable512e = kwargs['enable512e']
        if 'attributes' in kwargs:
            attributes = kwargs['attributes']
        if 'qos' in kwargs:
            qos = kwargs['qos']

        #if any[name is None, accountID is None, totalSize is None]:
        #    raise Exception('Sorry, must specify: name, accountID, sliceCount'
        #                    ' and size, in order to create a volume.')
        params = {'name': name,
                  'accountID': accountID,
                  'sliceCount': sliceCount,
                  'totalSize': totalSize,
                  'enable512e': enable512e,
                  'attributes': attributes}

        result = self.issue_api_request('CreateVolume', params)
        if 'volumeID' not in result:
            raise Exception('Failed CreateVolume:%s' % result)

        vlist = self.get_volume_list_by_accountID(accountID)
        vol = None
        for v in vlist:
            if v['volumeID'] == result['volumeID']:
                vol = v
                break

        return vol

    # Following methods are pretty simple and shouldn't need any explanation
    # For these cases we'll let the caller decide what to do on an error
    def delete_volume(self, volumeID):
        params = {'volumeID': volumeID}
        return self.issue_api_request('DeleteVolume', params)

    def purge_deleted_volume(self, volumeID):
        params = {'volumeID': volumeID}
        return self.issue_api_request('PurgeDeletedVolume', params)

    def restore_deleted_volume(self, volumeID):
        params = {'volumeID': volumeID}
        return self.issue_api_request('RestoreDeletedVolume', params)

    def _generate_random_string(self, length):
        """ Using this to get somewhat secure CHAP
        password settings unique to each SF account
        """
        char_set = string.ascii_uppercase + string.digits
        return ''.join(random.sample(char_set, length))
