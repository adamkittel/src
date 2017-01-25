<html><head><title>Change Record form</title>
<style type="text/css">
td {font-family: tahoma, arial, verdana; font-size: 10pt }
</style>


</head>
<body>
<?
$id=$_POST['id'];
$db="nameof_mydatabase";
$link = mysql_connect('servername.com: 3306', 'username', 'password');
if (! $link)
die("Couldn't connect to MySQL");

mysql_select_db($db , $link)
or die("Couldn't open $db: ".mysql_error());

$query=" SELECT * FROM birthdays WHERE id='$id'";
$result=mysql_query($query);
$num=mysql_num_rows($result);

$i=0;
while ($i < $num) {
$name=mysql_result($result,$i,"name");
$birthday=mysql_result($result,$i,"birthday");
?>
<table width="300" cellpadding="10" cellspacing="0" border="2">
<tr align="center" valign="top">
<td align="center" colspan="1" rowspan="1" bgcolor="#64b1ff">
<h3>Edit and Submit</h3>
<form action="birthdays_change_record.php" method="post">
<input type="hidden" name="ud_id" value="<? echo "$id" ?>">
Name:    <input type="text" name="ud_name" value="<? echo "$name"?>"><br>
Birthday:    <input type="text" name="ud_birthday" value="<? echo "$birthday"?>"><br>
<input type="Submit" value="Update">
</form>
</td></tr></table>

<?
++$i;
}
?>
</body>
</html>






