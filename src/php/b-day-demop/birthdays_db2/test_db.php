<?php
/* Change next  line */
$link = mysql_connect('servername.com: 3306', 'username', 'password');
if
(!$link) {
die(mysql_error());
}
echo
'Successful connection';
mysql_close($link);
?> 


