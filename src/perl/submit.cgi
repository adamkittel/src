From - Tue May  6 19:55:41 1997
Received: from viper.tci.com (viper.tci.com [198.178.8.173]) by blackhole.dimensional.com (8.7.6/8.6.12) with SMTP id JAA13197 for <akittel@dimensional.com>; Tue, 6 May 1997 09:16:45 -0600 (MDT)
Posted-Date: Tue, 6 May 1997 09:16:45 -0600 (MDT)
Received-Date: Tue, 6 May 1997 09:16:45 -0600 (MDT)
Received: by viper.tci.com; id JAA29334; Tue, 6 May 1997 09:15:48 -0600
Received: from den-web1.tci.com(165.137.146.147) by viper.tci.com via smap (3.2)
	id xma029141; Tue, 6 May 97 09:15:25 -0600
Received: (from smmtoper@localhost)
	by den-web1.tci.com (8.8.5/8.8.5) id JAA04394
	for akittel@dimensional.com; Tue, 6 May 1997 09:16:06 -0600 (MDT)
Date: Tue, 6 May 1997 09:16:06 -0600 (MDT)
From: Smmt Oper Web Production <smmtoper@den-web1.tci.com>
Message-Id: <199705061516.JAA04394@den-web1.tci.com>
To: akittel@dimensional.com
Status: RO
X-Mozilla-Status: 0001
Content-Length: 12600

#!/usr/local/bin/perl
#submit.cgi ver1.0  crapo.ryan@tci.com
#submit.cgi ver2.0  shannon.ryan@tci.com w/ comments and everything
#this code deals with tickets/hour_logs/mail_logs/text_log/oper_tasks.
#It makes ticket/task/log files, sends mail to warn, some rudimentray error checking, and
#user control. In essence this program is the core of operations logging capacities. 
#ie. Don't break it. 
	
# This is the main area. Each sub is run in order, until 'group_switch' , which is where all
# the decision making starts. 
&print_opening;    #Prints the opening HTML stuff
&parse_input;      #Parses the input from the sending CGI
&init_vars;        #Sets up the vars using the parsed input and other sources
&group_switch;     #Sends data to the correct function accoring to what group it is.
&print_closing;    #Prints the closing HTML stuff


sub print_opening {
    #Prints the opening HTML stuff
    print "Content-type: text/html\n\n";
    print "<HTML><HEAD><TITLE>submit</TITLE></HEAD>\n";    
    print "<BODY BACKGROUND=/~smmtoper/images/backgrounds/bg.1";
    print " BGCOLOR=white TEXT=black LINK=blue>";
    print "<FONT SIZE=7 COLOR=blue>Submission!</FONT><HR>";
}

sub print_closing {
    #Prints the closing HTML stuff
    print "<BR><A HREF=/~smmtoper/docs/main>";
    print "<IMG BORDER=0 SRC=/~smmtoper/images/buttons/home.gif>Back to Main";
    print "</BODY></HTML>";
}

sub parse_input {
    #Parses the input from the sending CGI
    read (STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
    @pairs = split(/&/, $buffer);
    foreach $pair (@pairs)
    {
	($name, $value) = split(/=/, $pair);
	$value =~ tr/+/ /;
	$value =~ s/%0A//eg;
	$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
	$list{$name} = $value;
    }
}

sub init_vars {
    #Sets up the vars using the parsed input and other sources
    $time=`date "+%H:%M"`;
    chop($time);
    $addr=$ENV{'REMOTE_HOST'};
    @abcd=split(/[^0-9]/,$addr);
    $addr=pack("C4",$abcd[0],$abcd[1],$abcd[2],$abcd[3]);
    ($host, $al, $ad, $ln, @ad)=gethostbyaddr($addr,2);
    @host=split(/-/,$host);
    $logtime=`date "+%d:%H"`;
    chop($logtime);
    $logtime="$logtime:$host[0]";
    $month=`date "+%b"`;
    chop($month);
    $user=$ENV{'REMOTE_USER'};
    $fulltime=`date '+%H:%M:%S'`;
    chop($fulltime);
    $logpathvar="$fulltime:$user";
    $colorpath="/home/smmtoper/html_internal/bin/3t/email.status.color.txt";
    $logpath = "/home/smmtoper/html_internal/logs/dailylogs/cache/operlog:$logpathvar";
    $lightgif = 'light.gif';
    $leadccopath="/home/smmtoper/html_internal/bin/3t/users/lead-ccousers";
    open(LIST,$leadccopath);
    @opermgr=<LIST>;
    close LIST;
    $mgrcheck=grep(/$user/,@opermgr);
    #Converted to a happyier easier to type format early on. 
    $light=$list{'light'};
    $mail_comment=$list{'mailtext'};
    $group=$list{'group'};
    $old_item=$list{'search'};
    $ouser=$list{'ouser'};
    $who=$list{'user'};
    $path=$list{'path'};
    $date=$list{'date'};
    $stat=$list{'stat'};
    $task_mod=$list{'tmod'};
    $summary=$list{'smry'};
    $machine=$list{'mach'};
    $ticket_time=$list{'time'};
    $tool_used=$list{'tool'};
    $downtime=$list{'dwnt'};
    $customer=$list{'customer'};
    $history=$list{'hist'};
    $if_log=$list{'iflog'};
    $priotiry=$list{'priority'};
    $target_date=$list{'targetdate'};
    $approval=$list{'approval'};
    $due_date=$list{'dued'};
    $progress=$list{'prog'};
    $log_text=$list{'text'};
    $snm_stat=$list{'snm'};
    $snm_text=$list{'snmtext'};    
    $rsm_stat=$list{'rsm'};
    $rsm_text=$list{'rsmtext'};
    $cppv_stat=$list{'cppv'};
    $cppv_text=$list{'cppvtext'};    
    $tivoli_stat=$list{'tivoli'};
    $tivoli_text=$list{'tivolitext'};    
    $greeley_stat=$list{'greeley'};
    $greeley_text=$list{'greeleytext'};    
    $ping_stat=$list{'ping'};
    $ping_text=$list{'pingtext'};    
    $mail_stat=$list{'mail'};
    $mail_text=$list{'mailtext'};    
    $comment_text=$list{'comments'};
}

sub group_switch {
    #Sends data to the correct function accoring to what group it is.
    if ($group eq 'oper') {
	#Sends data the the tickets functions
	$subdir='tickets';
	&get_number;
	&integrity_check;
	&mail_check;
	&item_write;
    }
    elsif ($group eq 'log' ){
	#Sends data to the raw text log functions
	&log_write;
    }
    elsif ($group eq 'hlog' ) {
	#Sends data to the hourly log functions
	&hourlog_check;
	&hourlog_write;
    }
    elsif ($group eq 'mlog'){
	# Sends data to the mail log functions
	&maillog_write;
    }
    elsif ($group eq 'opertask') {
	#Sends data the the opertask functions
	$subdir='opertasks';
	&get_number;
	&integrity_check;
	&manager_check;
	&mail_check;
	&item_write;
    }
    else {
	#If we don't understand whats going on here.
	print "Unidentifiable Group!!\n<BR>";
    }
}

sub get_number {
    #This sub gets the next item number. It also sets up some variables used later on. 
    @item_list = `ls /home/smmtoper/html_internal/logs/3t/$subdir`;
    $last_item = pop(@item_list);
    if ($group eq 'oper'){
	@n = split(/ket/,$last_item);
	$item_number = pop(@n);
	$item='ticket';
	$searchexec='operticsearch.cgi';
    }
    elsif ($group eq 'opertask') {
	@n = split(/task/,$last_item);
	$item_number = pop(@n);
	$item='opertask';
	$searchexec='tasksearch.cgi';
    }
    else {
	print "Group Error!\n<BR>";
    }
    if ($old_item eq 'no') {
	# This area determines how many if any zeros to stick on front
	# of the new ticket number
	$ouser=$who;
	$new_item = $item_number + 1;
	if ($new_item < 10 ) {
	    $new_item = "000$new_item";
	}
	elsif ($new_item < 100 && $new_item > 9) {
	    $new_item = "00$new_item";
	}
	elsif ($new_item < 1000 && $new_item >99) {
	    $new_item = "0$new_item";
	}
	$path="/home/smmtoper/html_internal/logs/3t/$subdir/$item$new_item";
    }
    else {
	#Junk is throwaway stuff. gem is just a holding variable.
	#The point of the below is just to get the ticket number
	#from the old ticket path. Lotta work for a little number.
	($junk,$gem) = split(/$item\D/,$path);
	($junk,$new_item) = split(/$item/,$gem);
    }
}

sub integrity_check {
    #This sub removes '#'s from items because they screw with the scanner.
    $date =~ s/#/ /eg;
    $task_mod =~ s/#/ /eg;
    $machine =~ s/#/ /eg;
    $downtime =~ s/#/ /eg;
    $history =~ s/#/ /eg;
    $target_date =~ s/#/ /eg;
    $approval =~ s/#/ /eg;
    $due_date =~ s/#/ /eg;
    $progress =~ s/#/ /eg;
}

sub manager_check {
    #Checks to make sure you have manager rights before you are allowed to forward a task.
    if ($user ne $who && $mgrcheck ne '1') {
	print "<FONT COLOR=RED><H2> You are not a manager </h2></FONT>";
	print "Only Managers may forward a task to another person.<BR>";
	print "The task you were attempting to edit is unchanged<BR>";
	print "Click the back button on your browser to go back to your entry.<BR>";
	print "Remember to smile.<BR>";
	$ok = 'no';
    }
}

sub mail_check {
    #Checks to see if mail needs to be sent with the creation of a ticket or one being forwarded.
    if ($old_item eq 'no' || $who ne $ouser) {
	open (MAIL, "|/usr/lib/sendmail -t");
	print MAIL "Date:". `date`;
	if ($who eq 'unassigned'){
	    print MAIL "TO: pbilling\@elmer.tci.com, agrimes\@elmer.tci.com\n";
	    print "<FONT COLOR=RED><h2>$item was Mailed to pbilling and agrimes</H2></FONT>";
	}
	else {
	    print MAIL "TO: $who\@den-ops1.tci.com\n";
	    print "<FONT COLOR=RED><h2>$item was Mailed to $who</H2></FONT>";
	}
	print MAIL "FROM: $ouser\n";
	print MAIL "SUBJECT: New $item\n";
	print MAIL "You are now the proud owner of $item number $new_item\n";
	if ($who ne $ouser) {
	    print MAIL "The past owner, $ouser, has seen it\n";
	    print MAIL "and wishes for you to deal with it.\n";
	}
	print MAIL "http://summitrak/~smmtoper/\n";
	print MAIL "Thank you for your cooperation.\n";
	close (MAIL);
    }
}

sub hourlog_check {
    #Makes sure you've clicked all the buttons on the hourlog. No cheating please.. :)
    if ($snm_stat eq '' || $rsm_stat eq '' || $cppv_stat eq '' || $tivoli_stat eq '' || 
	$greeley_stat eq '' || $ping_stat eq '' || $mail_stat eq '') {
	print "<FONT COLOR=RED><h2>You forgot to click a small button.</H2></FONT>";
	print "Click the back button on your browser to go back to your entry.<BR>";
	print "Remember to smile.<BR>";
	$ok = 'no';
    }
}

sub maillog_write {
    #Write the mail log to file.
    open(LOG,">>$logpath");
    print LOG "<HR>$light";
    print LOG "E-MAIL LOG \@:time by $user<BR>";
    print LOG "Comments: $mail_comment<BR>";
    close LOG;
    print "<FONT COLOR=red><H2>Mail Log Entry Successful!</h2></FONT>";
    print "<BR><BR>";
}

sub log_write {
    #Write the raw text log to file.
    open(LOG,">>$logpath");
    print LOG "<HR>LOG ENTRY \@:$time by $user\n";
    print LOG "<BR>$log_text\n";
    chmod(0666,$logpath);
    close LOG;
    print "<FONT COLOR=red><H2>Log Entry Successful!</h2></FONT>";
    print "<BR><BR>";
    print "<A HREF=/cgi-bin/cgiwrap/~smmtoper/bin/3t/start/logentrystart.cgi><IMG SRC=/~smmtoper/images";
    print "/buttons/back.gif BORDER=0>Back to enter another log?</a>";
}

sub hourlog_write {
    #Write the hourlog to file printing a red header and the problem if a problem buttons was
    #clocked. 
    if ( $ok ne 'no' ) {
	open(LOG,">>$logpath");
	if ($snm_stat eq 'problem' || $rsm_stat eq 'problem' || $cppv_stat eq 'problem' ||
	    $tivoli_stat eq 'problem' || $greeley_stat eq 'problem' || $ping_stat eq 'problem' ||
	    $mail_stat eq 'red' || $mail_stat eq 'yellow') {
	    #If there was a prob, make the header red
	    print LOG "<HR><FONT COLOR=red>HOURLYLOG ENTRY \@:$time by $user</FONT>";
	}
	else {
	    #Else, just print it normally.
	    print LOG "<HR>HOURLYLOG ENTRY \@:$time by $user";
	}
	if ($snm_stat eq 'problem') {
	    print LOG "<BR>SNM - $snm_stat - $snm_text\n";
	    $problem=1;
	}
	if ($rsm_stat eq 'problem') {
	    print LOG "<BR>RSM - $rsm_stat - $rsm_text\n";
	    $problem=1;
	}
	if ($cppv_stat eq 'problem') {
	    print LOG "<BR>CPPV - $cppv_stat - $cppv_text\n";
	    $problem=1;
	}
	if ($tivoli_stat eq 'problem') {
	    print LOG "<BR>TIVOLI - $tivoli_stat - $tivoli_text\n";
	    $problem=1;
	}
	if ($greeley_stat eq 'problem') {
	    print LOG "<BR>GREELEY - $greeley_stat - $greeley_text\n";
	    $problem=1;
	}
	if ($ping_stat eq 'problem') {
	    print LOG "<BR>PING - $ping_stat - $ping_text\n";
	    $problem=1;
	}
	if ($mail_stat eq 'red' || $mail_stat eq 'yellow') {
	    print LOG "<BR>MAIL STATUS - $mail_stat - $mail_text\n";
	    $problem=1;
	}
	if ($problem eq '') {
	    print LOG "<BR>Everything is Ok!";
	}
	print LOG "<BR>Comments: $comment_text";
	chmod(0666,$logpath);
	close LOG;
	#Print the Email Status to the tag file.
	$light="<IMG SRC=/~smmtoper/images/icons/$mail_stat$lightgif>";
	open(CLOG,">$colorpath");
	print CLOG "$light";
	close CLOG;
	
	print "<FONT COLOR=red><H2>Log Entry Successful!</h2></FONT>";
	print "<BR><BR>";
    }
}

sub item_write {
    #Prints a ticket/task to file. 
    if ($ok ne 'no'){
	open(ITEM,">$path");
	print ITEM "file#$path\n";
	print ITEM "date#$date\n";
	print ITEM "user#$who\n";
	print ITEM "stat#$stat\n";
	print ITEM "lmod#$task_mod\n";
	print ITEM "smry#$summary\n";
	print ITEM "check#$user\n";
	print ITEM "mach#$machine\n";
	if ($group eq 'oper') {
	    print ITEM "time#$ticket_time\n";
	    print ITEM "tool#$tool_used\n";
	    print ITEM "dwnt#$downtime\n";
	    print ITEM "customer#$customer\n";
	    print ITEM "hist#$history\n";
	    if ($if_log ne 'no') {
		#Check here to see if we need to log this or not.
		open(LOG,">>$logpath");
		print LOG "<HR><FONT COLOR=red>TICKET SUBMIT \@:$time by $user\n</FONT>";
		print LOG "<BR>$item$new_item was created or appended. \n";
		print LOG "<BR>For a detailed description click here: ";
		print LOG "<A HREF=/cgi-bin/cgiwrap/~smmtoper/bin/3t/search/operticsearch.cgi?";
		print LOG "file=$item$new_item>$item$new_item</A>\n";
		print LOG "<BR>Status: $stat\n";
		print LOG "<BR>Summary: $summary\n";
		chmod(0666,$logpath);
		close LOG;
	    }
	}
	else {
	    #This stuff for tasks only
	    print ITEM "priority#$priority\n";
	    print ITEM "targetdate#$target_date\n";
	    print ITEM "approval#$approval\n";
	    print ITEM "dued#$due_date\n";
	    print ITEM "prog#$progress\n";
	}	
	print "<FONT COLOR=red><H2>$item was submitted as $item$new_item! </h2></FONT>";
	close ITEM;
    }
    print "<BR><A HREF=/cgi-bin/cgiwrap/~smmtoper/bin/3t/search/$searchexec?file=$item$new_item>";
    print "<IMG BORDER=0 SRC=/~smmtoper/images/buttons/back.gif>Back to $item$new_item";
}
