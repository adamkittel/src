<html>
<head><title>Connect Server</title></head>
<body>
<?
$db="mydb";
//$link = mysql_connect("localhost",$_POST['username'],$_POST['password']) or die(mysql_error());
$link = mysql_connect("localhost") or die(mysql_error());
print "Successfully connected.\n";
mysql_select_db($db , $link)
	or die("Select DB Error: ".mysql_error());
//mysql_query("CREATE DATABASE mydatabase");
mysql_query(
	"CREATE TABLE birthdays(
		id INT NOT NULL AUTO_INCREMENT,
		PRIMARY KEY(id),
		name VARCHAR(30),
		birthday VARCHAR(7))") or die(mysql_error());
mysql_close($link);
?>
</body>
</html>
