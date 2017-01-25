
MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $MYDIR/efuncs.sh

fail()
{
    message=$1
    if [ "$message" == "" ]; then message="Test script failed"; fi
    consoletitle "$message"
    python send_email.py --email_to=$SFEMAIL_NOTIFY --email_subject "$message"

    die $message
}

logdebug()
{
    scriptname=`basename "${BASH_SOURCE[${#BASH_SOURCE[@]}-1]}"`
    ifs_save
    ifs_nl
    for line in $@; do
        logger -p user.info -t "sftest-sh" "$scriptname DEBUG  ${line}"
    done
    ifs_restore
}

loginfo()
{
    scriptname=`basename "${BASH_SOURCE[${#BASH_SOURCE[@]}-1]}"`
    ifs_save
    ifs_nl
    for line in $@; do
        echo -e "${WHITE}${line}${COLOR_OFF}"
        logger -p user.info -t "sftest-sh" "$scriptname INFO  ${line}"
    done
    ifs_restore
}

logerror()
{
    scriptname=`basename "${BASH_SOURCE[${#BASH_SOURCE[@]}-1]}"`
    ifs_save
    ifs_nl
    for line in $@; do
        echo -e "${RED}${line}${COLOR_OFF}"
        logger -p user.error -t "sftest-sh" "$scriptname ERROR ${line}"
    done
    ifs_restore
}

loggreen()
{
    scriptname=`basename "${BASH_SOURCE[${#BASH_SOURCE[@]}-1]}"`
    ifs_save
    ifs_nl
    for line in $@; do
        echo -e "${GREEN}${line}${COLOR_OFF}"
        logger -p user.info -t "sftest-sh" "$scriptname INFO ${line}"
    done
    ifs_restore
}

logbanner()
{
    scriptname=`basename "${BASH_SOURCE[${#BASH_SOURCE[@]}-1]}"`
    echo ""
    echo -e "${MAGENTA}"
    echo -e "+----------------------------------------------------------------------------+"

    ifs_save
    ifs_nl
    for line in $@; do
        echo "$line" |  sed -e :a -e 's/^.\{1,76\}$/ & /;ta'
        logger -p user.info -t "sftest-sh" "$scriptname INFO  ${line}"
    done
    ifs_restore

    echo -e "+----------------------------------------------------------------------------+${COLOR_OFF}"
    echo ""
}

consoletitle()
{
    echo -en "\033]0;$1\007"
}
