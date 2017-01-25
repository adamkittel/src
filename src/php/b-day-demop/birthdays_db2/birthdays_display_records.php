<html>
<head><title>Display Records</title>
<style type="text/css">
td {font-family: tahoma, arial, verdana; font-size: 10pt }
</style>


</head>
<body>
<?php
/* Change next two lines */
$db="nameof_mydatabase";
$link = mysql_connect('servername.com: 3306', 'username', 'password');
if (! $link)
die(mysql_error());
mysql_select_db($db , $link)
or die("Couldn't open $db: ".mysql_error());
$result = mysql_query( "SELECT * FROM birthdays" )
or die("SELECT Error: ".mysql_error());
$num_rows = mysql_num_rows($result);
print "There are $num_rows records.<P>";
print "<table width=200 border=1>\n";
while ($get_info = mysql_fetch_row($result)){ 
print "<tr>\n";
foreach ($get_info as $field) 
print "\t<td>$field</td>\n";
print "</tr>\n";
}
print "</table>\n";
mysql_close($link);
?>
<br>

<form method="POST" action="birthdays_dbase_interface.php">
<input type="submit" value="Dbase Interface">
</form>

</body>
</html> 








