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


"""Starter exception class for SolidFire API calls."""


class APICommandException(Exception):
    def __init__(self, message, api_response):
        self.message = message
        self.results = api_response


class APIAuthenticationException(Exception):
    def __init__(self, message, api_response):
        self.message = message
        self.results = api_response


class MaxSimultaneousClonesPerVolume(Exception):
    def __init__(self, message, api_response):
        self.message = message
        self.results = api_response


class MaxSimultaneousClonesPerNode(Exception):
    def __init__(self, message, api_response):
        self.message = message
        self.results = api_response
