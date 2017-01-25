#######-----------------------------------------------------------########
# 
#  AUTHOR:              ADAM KITTEL / ART LARKIN
#                       adam.kittel@sun.com / art.larkin@sun.com
#                       303 272 6561 -- x76561 / 303-464-4879 -- x50879
#
#  CREATED:             08/2004
#  LAST UPDATE:         03/2005
#
#  This script uses the built in RAS_SNAP utility in storADE
#  Diagnostic 2.4.xx.xxx	
#
#######--------------------------------------------------------------#####

###  --->  To change the default placement and playback directories
###        Edit $SLOCAL in the AutoSnap/RASSANP file
###        EXAMPLE:  $SLOCAL=/var/tmp/MYDIRECTORY

#######--------------------------------------------------------------#####

#######		     -> MAIN DIRECTORY FILE LIST <-

#
# README.txt	f-> This File
# dsqatool.ksh	F-> MAIN PROGRAM FUNCTION
# RASSNAP	f-> Ras Snap Progam Call
# Snap/		D-> Ras Snap Program Directory
# BUG		f-> Bug Program Call
# BugInfo/    	D-> Bug Program Directory	
# REV		f-> Revision Program Call
# RevInfo/	D-> Revision Program Directory
# qmessage	f-> Exit message

#######		     -> Snap DIRECTORY FILE / FUNCTION LIST <-

# Faudit	F-> Audit - rasagent -r -d2 -M -A
# Fdisco	F-> Discovery - rasagent -r -d2 -M -A
# Ffault	F-> Fault injection 
# Fplay		F-> Play ras_snap 
# Fquit		F-> Quit - clean and restore files and dirs
# Mplay		F-> Mass ras snap play by device, ver ...
# Pinfo		f-> Gather snap play information
# Sdump		f-> Dump system, storade info into ../FVT dir
# Sinfo		f-> Gather ras_snap info
# agentA	f-> Audit agent rasagent -r -d2 -M -A Audit all devices
# agentC	f-> Clean agent - rasagent -r -d2 -M until clean
# agentS	f-> Standard agent- rasagent -r -d2 -M regular run
# stopagent	f-> Stop agent from running from cron ../ras_admin agent -d
# auditQ	f-> Audit clean up processes mv ../BASE/OLD*/* ../FAIL/OLD*/ 
# clean		f-> Delete tmp files
# confBk	f-> Restore ../System/config
# confMv	f-> Backup ../System/config to config.snap and append
# cpdata	f-> Copy DATA dir to ../dsqa/DATA_DIRS
# dataBk	f-> Restore ../DATA from ../DATA-RESTORE 
# dataMv	f-> Backup ../DATA to ../DATA-RESTORE 
# discoQ	f-> Disco clean up processes mv ../BASE/OLD*/* ../FAIL/OLD*/   
# inject	f-> Inject Fault message
# input		f-> ntros
# introA	f-> Explain Audit function
# introD	f-> Explain discovery function
# introF	f-> Explain Fault Injection function
# motdBk	f-> Restore /etc/motd
# motdMv	f-> Append and backup ../motd to ../motd.snap Add RSMFVT message
# Splay		f-> Play ras_snap - rasagent -r -d2 -M -T$S_ID
# SplayStop	f-> Finish functions for Fplay
# repair	f-> Ras_snap copies files in $SLOCAL/REPAIR Directory
# root		f-> Verify user is root
# start		f-> Ras_snap copies files in $SLOCAL/BASE Directory
# stop		f-> Ras_snap copies files in $SLOCAL/FAIL Directory
# success	f-> 
# Stype		f-> Get the ras_snap type to perform


==========================================================
#
#  \$.Log.\$
#
#  Copyright 2005 Sun Microsystems, Inc.
#
# 
==========================================================

#
#  $.Log.$
#
#  Copyright 2005 Sun Microsystems, Inc.
#
