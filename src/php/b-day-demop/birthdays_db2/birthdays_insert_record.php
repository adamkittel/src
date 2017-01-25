<html><head><title>Birthdays Insert Record</title></head>
<body>
<?
/* Change next two lines */
$db="nameof_mydatabase";
$link = mysql_connect('servername.com: 3306', 'username', 'password');
if (! $link)
die(mysql_error());
mysql_select_db($db , $link) or die("Select Error: ".mysql_error());
$result=mysql_query("INSERT INTO birthdays (name, birthday) VALUES ('$name','$birthday')")or die("Insert Error: ".mysql_error());
mysql_close($link);
print "Record added\n";
?>
<form method="POST" action="birthdays_insert_form.php">
<input type="submit" value="Insert Another Record">
</form>
<br>

<form method="POST" action="birthdays_dbase_interface.php">
<input type="submit" value="Dbase Interface">
</form>



</body>
</html>





