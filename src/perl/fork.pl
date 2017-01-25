#!/usr/local/bin/perl

#$pid=fork();
#print "pid1********$pid\n";
#@PID=`ps -eaf | grep fork`;
#print @PID;
$login = getlogin;
#print "$login\n";
@passwd=getpwnam(akittel);
#print "@passwd\n";
@pwent=getpwent();
#print "@pwent\n";
@server=getservbyname(yukon,tcp);
print "@server\n";
@servent=getservent();
print "@servent\n";
