<html><head><title>Birthdays Delete Record</title></head>
<body>
<?
$id=$_POST['id'];
/* Change next two lines */
$db="nameof_mydatabase";
$link = mysql_connect('servername.com: 3306', 'username', 'password');
if (! $link)
die(mysql_error());
mysql_select_db($db , $link)
or die("Couldn't open $db: ".mysql_error());
mysql_query("DELETE FROM  birthdays where id=$id")or die("Delete Error: ".mysql_error());
mysql_close($link);
print "Record Removed.\n";
?>
<br><br>
<form method="POST" action="birthdays_delete_form.php">
<input type="submit" value="Delete Another">
</form><br>
<form method="POST" action="birthdays_dbase_interface.php">
<input type="submit" value="DBase Interface">
</form>
</body>
</html>




