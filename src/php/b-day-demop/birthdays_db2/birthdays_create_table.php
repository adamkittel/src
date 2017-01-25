<html><head><title>Birthdays Create Table</title></head>
<body>
<?
/* Change next two lines */
$db="nameof_mydatabase";
$link = mysql_connect('servername.com: 3306', 'username', 'password');
if (! $link)
die(mysql_error());
mysql_select_db($db , $link)
or die(mysql_error());
/* create table */
mysql_query("CREATE TABLE birthdays(
 id INT NOT NULL AUTO_INCREMENT,
 PRIMARY KEY(id),
 name VARCHAR(30),
 birthday VARCHAR(7))")
or die(mysql_error()); 
mysql_close($link);

?>
</body>
</html>







