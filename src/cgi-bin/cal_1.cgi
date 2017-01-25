#!/usr/local/bin/perl

# Name: Selena Sol's Groupware Calendar
#
# Version: 4.0
#
# Last Modified: 08-14-96
#
# Copyright Info:This application was written by Selena Sol
# (selena@eff.org, http://www.eff.org/~erict) having been inspired by
# countless other Perl authors.  Feel free to copy, cite, reference,
# sample, borrow, resell or plagiarize the contents.  However, if you
# don't mind, please let me know where it goes so that I can at least
# watch and take part in the development of the memes. Information wants
# to be free, support public domain freware.  Donations are appreciated
# and will be spent on further upgrades and other public domain scripts.
#
# Finally, PLEASE SEND WORKING URL's to selena@eff.org.  I maintain a list
# of implementations around the world.

#######################################################################
#                       Print http Header.                            #
#######################################################################

# First tell Perl to bypass the buffer.  Then, print out the HTTP
# header. We'll output this quickly so that we
# will be able to do some of our debugging from the web and so that in
# the case of a bogged down server, we won't get timed-out. 

  $! = 1;
  print "Content-type: text/html\n\n";

#######################################################################
#                       Require Libraries.                            #
#######################################################################

# Now require the necessary files with the subroutine at the end of this
# script marked by "sub CgiRequire".  We use this subroutine so that if
# there is a problem with the require, we will get a meaningful error
# message. 

# ($lib is the location of the Library directory where these files
# are to be stored.  Set $lib = "." if you do not have a Library
# directory.  This variable must be set in this file AS WELL AS in
# calendar.setup!!!)

  $lib = "./Library";

  &CgiRequire("$lib/cgi-lib.pl", "$lib/cgi-lib.sol",
           "$lib/auth-lib.pl", "$lib/date.pl");

#######################################################################
#                        Gather Form Data.                            #
#######################################################################

# Now use cgi-lib.pl to parse the incomming form data.  We'll pass
# cgi-lib.pl (*form_data) so that our variable will come out as
# $form_data{'key'} instead of $in{'$key'}.  I like to use form_data
# because it is easier for me to remember what the variable is.
# In the end, we will be able to refernce all of the incoming form data as
# $form_data{'variablename'}

  &ReadParse(*form_data);

#######################################################################
#             Determine Which Calendar Database to Use.               #
#######################################################################

# Now we will need to determine which calendar databse to use.  If the
# admin has set up more than one calendar, each calendar database will be
# in a subdirectory.  In order to reference these separate databases, the
# link to this script must have added ?calenar=Somesubdirectory at the end
# of the URL.  If we are asking for the main calendar, this variable will
# not be equal to anything.

##  if ($form_data{'calendar'} ne "")
##    {
    $calendar_type = "./$form_data{'calendar'}";
##    }
##  else
##    {
##    $calendar_type = "./";
##    }

#######################################################################
#                            Define Variables                         #
#######################################################################

# Now we will define all of our variables by using the define file that
# you should have customized for your own site.

    &CgiRequire("calendar.setup");

# Now we are going to want to make sure that we "remember" the
# session_file so that we can continually check for authentication and
# keep track of who the current client is.  However, if the client has
# already logged on, then we will not be going back through the
# authentication rouitines but will be getting the $session_file as form
# data (the same hidden field we are about to define).  So, we need to
# rename $form_data{'session_file'} to $session_file so that in both cases
# (first time to this point or continuing client) we'll have the
# session_id in the same variable name form.

  if ($form_data{'session_file'} ne "")
      {
      $session_file = $form_data{'session_file'};
      }

# Now rename some other variables with the same idea...

  if ($form_data{'year'} ne "")
    {
    $current_year = "$form_data{'year'}";
    }
  else
    {
    $current_year = "$the_current_year";
    }

  if ($form_data{'month'} eq "")
    {
    @mymonth = &make_month_array(&today);
    $current_month_name = &monthname($currentmonth);
    }
  else
    {
    @mymonth = &make_month_array(&jday($form_data{'month'},1,$current_year));
    $current_month_name = &monthname($form_data{'month'});
    }

#######################################################################
#                       Print out Generic Header HTML.                #
#######################################################################

# Okay, so if we got to this line, it means that the client has
# successsfully made it past security.  So let's print out the basic
# header information.  You may modify everything between the 
# "print qq! and the !; but be careful of
# illegal characters like @ which must be preceeded by a backslash 
# (ie: selena\@eff.org)
#
# Also create the hidden form tags that will pass along the session_file
# info and the name of the calendar that we are dealing with.  It is
# crucial that we make sure to pass this info along through every page so
# that this script can keep track of the clients as they wander about.

#######################################################################
#                       Print out Calendar                            #
#######################################################################

# Now let's actually print out the dynamically generated calendar. We'll
# need to do this in two cases.  Firstly, if we have just logged on and
# the client is asking for the very first page ($form_data{'session_file'}
# ne "") and secondly, if the client has already been moving through
# various pages and has asked to view the calendar again
# ($form_data{'change_month_year'} ne "").  The || means "or".  Thus, if
# either case is true, we will procede.

  if ($form_data{'change_month_year'} ne "" ||
      $ENV{'REQUEST_METHOD'} eq "GET" && $form_data{'day'} eq "")
    {

# Now print out the HTML calendar

    &header ("Selena Sol's Groupware Calendar Demo: $current_month_name - 
	      $current_year");
    print qq!
    <CENTER>
    <H2>$current_month_name - $current_year</H2>
    </CENTER>
    <TABLE BORDER = "2" CELLPADDING = "4" CELLSPACING = "4">
    <TR>!;

# Print up the table header (Weekdays).  For every day (foreach $day) in
# our list of days (@day_names), print out the day as a table header.
# Then plop in the table row delimiters...

    foreach $day (@day_names)
      {
      print "<TH>$day</TH>\n";
      }
    print "</TR>\n<TR>\n";

# Create the variable $count_till_last_day which we will use to make sure
# that we do not add on too many <TR>s.  Also clear out a new variable
# called $weekday which we will use to keep track of the two dimensional
# aspect of the calendar...that is, we need to break the calendar rows
# after every seventh cell representing as week. (We'll taslk more about
# this in just a bit).

    $count_till_last_day = "0";
    $weekday = 0;

# For every day in the mymonth array we are going to need to create a
# cell for the calendar.  @mymonth, if you recall, is an array we got from 
# &make_month_array

#######################################################################
#                   Create a Table Cell for Each Day                  #
#######################################################################

    foreach $day_number (@mymonth)
      {

# Begin incrementing our two counter variables.

      $count_till_last_day++;
      $weekday++;

# Make sure that we add a break for every week to make the calendar 2 
# dimensional.  Thus, when we have gone through sets of seven days in this
# foreach loop, we will reset $weekday to zero.  Below, we'll use these
# values to determine where we drop the </TR><TR>, making a new calendar
# room.  When weekday is greater than 6, we'll know that we need a
# </TR><TR> so by setting the $weekday flag to zero, we will notify the
# script just a few lines down from here to insert the row break.

      $weekday = 0 if ($weekday > 6);

# Print a table cell for each day.  However, since we want to make each
# of the numbers in each of the cells clickable so that someone can click
# on the number to see a day view, we are going to need to manmage alot of
# information here.  Firstly, we will build a variable called
# $variable_list which will be used to create a long URL appendix which
# will be used to transfer indformation using URL encoding.  As we will
# learn more specifically later, the routine which generates the day views
# needs to have the day, year, and month values if it is to bring up a day
# view.  It must also have the session_file value (as all the routines in
# this script must) and the special tag view_day=on.  So we'll gather all
# of that information and appending it to the $variable_list variable.

      $variable_list = "";
      $variable_list = "day=$day_number&year=$currentyear";
      $variable_list .= "&month=$currentmonth";
      $variable_list .= "&session_file=$session_file";
      $variable_list .= "&calendar=$form_data{'calendar'}";
      $variable_list .= "&view_day=on";

# Now create the actual cell.  Notice, the number in each cell is made
# clickable by using URL encoding to tag the URl with all of the variables
# we want passed.

      print qq!<TD VALIGN = "top" WIDTH = "150">\n!;
      print qq!<A HREF = "$this_script_url?$variable_list">$day_number</A>\n!;

# Grab the subject listings for all the entries on that day.  Make sure
# also that if we are unable to open the database file, that we send a
# useful message back to us for debugging.  We'll do this using the
# open_error subroutine in cgi-lib.sol passing the routine the location of
# the database file.    

      open (DATABASE, "$database_file") || &CgiDie ("I am sorry, but I
	was unable to open the calendar data file in the Create a Table
	Cell for Each Day routine.  The value I have is $database_file.
	Would you please check the path ansd the permissions.");

      while (<DATABASE>)
        {
        ($day, $month, $year, $username, $first_name, $last_name, $email,
         $subject, $time, $body, $database_id_number) = split (/\|/,$_);

# We are going to need to run through all of the database items and look
# for database rows whose subject belong on the day cell we are building.
# Thus, for every row, we must determine if the day, month, and year of
# the item on that row equal the day, month and year of the cell we are
# buiulding.

        if ($day eq "$day_number" && $month eq "$currentmonth" && 
            $year eq "$currentyear")
          {

# If we were able to answer true to all of those conditions, then we have
# found a match and we should print out the subject in that cell.

          print qq!<BR><FONT SIZE = "1">$subject</FONT>\n!;  

          } # End of if ($day eq "$day_number" && $month eq ...
        } # End of while (<DATABASE>)

# Once we have checked all the way through the database, we should close
# that cell and move on to the next.

      print "</TD>\n";

# If, however, we have reached the end of a week row, we are going to need
# to begin a new table row for the next week.  If $weekday is equal to
# zero, then we know that it is time.  If not, continue with the row.
# (BTW, here we use == instead of just = because if we used =, perl would
# interpret the part inside the if () to be assigning the value of zero to
# $weekday...which it would do...and evaluate the whole process as true.
# That of course would undercut the whole point of counting with
# $weekday.)

      if ($weekday == 0)
	{
	print "</TR>\n";

# But before we just blindly print up another table row, we better be sure
# that we haven't actually reached the end of the month...Thus, if
# $count_till_last_day equals @mymonth we know that there are no more days
# left and we should not begin a new row.  (Notice that when we refernce
# @mymonth without quotes we receive the numerical value of the number of
# elements in the array).

        unless ($count_till_last_day == @mymonth)
          {
          print "<TR>";
          } # End of unless ($count_till_last_day == @mymonth)

        } # End of if ($weekday == 0)
      } # End of foreach $day_number (@mymonth)

# Finally, once we are done making all of the cells for the calendar, 
# print up the HTML footer

    print qq!
    </TABLE>
    </CENTER>
    <BLOCKQUOTE>
    For day-at-a-glance-calendar, click on the day number on the
    calendar above.
    <BR>
    Or, to see another 1996 month, choose one!;


