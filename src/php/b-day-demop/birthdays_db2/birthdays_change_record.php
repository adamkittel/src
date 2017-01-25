<html><head><title>Change Record</title></head>
<body>
<?
$ud_id=$_POST['ud_id'];
$ud_name=$_POST['ud_name'];
$ud_birthday=$_POST['ud_birthday'];
/* Change next two lines */
$db="nameof_mydatabase";
$link = mysql_connect('servername.com: 3306', 'username', 'password');
if (! $link)
die("Couldn't connect to MySQL");
mysql_select_db($db , $link)
or die("Couldn't open $db: ".mysql_error());
mysql_query(" UPDATE birthdays  SET name='$ud_name' ,birthday='$ud_birthday' WHERE id='$ud_id'");
echo "Record Updated";
mysql_close($link);
?>
<form method="POST" action="birthdays_update_form.php">
<input type="submit" value="Change Another">
</form><br>

<form method="POST" action="birthdays_dbase_interface.php">
<input type="submit" value="Dbase Interface">
</form>

</body>
</html>






