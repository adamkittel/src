#!/bin/ksh
#
#   Usage:/opt/sa/bin/downtime.ksh
#
#   Author: Greg Anderson
#   Purpose:Log Date and uptime on Production Systems.
#   Last Mod: Tue Nov 28 07:48:22 MST 1995
#

TODAY=`date +%y%m%d`
date > /opt/sa/downtime/${TODAY}
/opt/sa/bin/rup_den1.ksh >> /opt/sa/downtime/${TODAY}
date >> /opt/sa/downtime/${TODAY}
/opt/sa/bin/rup_dal.ksh >> /opt/sa/downtime/${TODAY}

