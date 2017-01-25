#!/bin/ksh
#######-----------------------------------------------------------########
# 
#  AUTHOR:              ADAM KITTEL / ART LARKIN
#                       adam.kittel@sun.com / art.larkin@sun.com
#                       303 272 6561 -- x76561 / 303-464-4879 -- x50879
#
#  CREATED:             08/2004
#  LAST UPDATE:         12/2004
#
##-------------------------------------------------------------------------


#set -x
HDIR=$PWD
LOG=/tmp/RAS_`date '+%m-%d-%y-%H:%M:%S'`.log
EMAILEXT="@sun.com"

#----------------------  autoload module location  -----------------------
##
FPATH=$PWD
autoload \
	fvt_menu RASSNAP REV BUG

fvt_menu()	##   Menu for selecting $WHAT_FUNCT
{
#set -x	
clear

print "\n\n	---->    Main Menu    <----\n \n \n" ;

    PS3="	
	 What Function do You want to perform? : " 

    select WHAT_FUNCT in "Ras Snap" "Revision Information" "Quit"
do
   case $WHAT_FUNCT in

      "Ras Snap")
	clear ; RASSNAP ;;

      "Revision Information")
       	clear ; REV ;;

	"Bug Info")
	clear ; BUG ;;

      "Quit")
     	 clear ; qmessage ; exit ;; #clear

      *)  
	print " !! You Didn't enter a correct choice.  Please retry" ;;
   esac
done
}
##-------------------------  FVTTOOL  ---------------------------

qmessage()
{
#set -x

##-----  Message to when leaving FVTtool

print   "\n\n            GOOD BYE, if You Have Any Suggestions for improvements
                     or enhancements please let us now.

		  :  Bugster Product = rsmfvt-tools  :

		        :  adam.kittel@sun.com :
                        :  art.larkin@sun.com  :\n
                            ------------------\n\n\n\n\n";
} #----------------------------  QMESSAGE  -----------------------------

fvt_menu

#
#  $.Log.$
#
#  Copyright 2005 Sun Microsystems, Inc.
#

