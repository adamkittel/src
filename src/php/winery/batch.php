<html>
<title>Adam's winery software</title>
<form action="batch.php" method="post">
<body bgcolor=#a4b1c0>
<h1>Adam's winery software - test mode</h1>

<?php

// how many ingrediants?
function stepone() {
	print "<input type=hidden name=switcher value=stepone>";
	print "How many ingrediants are in the batch? <select name=stepone>
		<option>1</option><option>2</option><option>3</option><option>4</option>
		<option>5</option><option>6</option><option>7</option><option>8</option>
		<option>9</option><option>10</option></select>
		<input type=submit value=GO>
		";
}

// build inital batch form
function makeform() {
	print "<input type=hidden name=switcher value=makeform>";
	print "<input type=hidden name=count value={$_POST['stepone']}";
	print "	<h1>Batch Form</h1>
		<table cellpadding=2><tr bgcolor=tan><th>Batch Info</th></tr>
		<tr bgcolor=skyblue><td>Start Date:<td> mm/dd/yyyy <input type=text name=startdate size=10>
		<td>Employee Name:<td> <input type=text name=employee size=20></tr>
		<tr bgcolor=lightgrey><td>Batch ID:<td> <input type=text name=batchid size=20>
		<td>Batch Name:<td> <input type=text name=batchname size=20></tr>
		<tr bgcolor=skyblue><td>Fermenter:<td> <input type=text name=fermenter size=3>
		<td>Total Start Volume:<td> <input type=text name=startvol size=5><select name=startvoltype>
		<option value=ltr>ltr</option>
		<option value=gal>gal</option></select>
		<tr bgcolor=lightgrey><td>Initial BRIX: <input type=text name=startbrix size=3>
		<td>BRIX Temp: <input type=text name=startbrixtemp size=3>F
		<tr bgcolor=skyblue><td>Yeast pitched:<td> mm/dd/yyyy <input type=text name=yeastdate size=10>
		<td>Temp yeast pitched:<td> <input type=text name=yeasttemp size=3> F</tr></table>
		Add to bonded inventory? Yes <input type=radio name=bonded value=bondedyes> 
		No <input type=radio name=bonded value=bondedno>
		</tr></table><br>
		";

	$x=1;
	print "<br><table cellpadding=2><tr bgcolor=tan><th>Ingrediant List</th></tr>";
	while($x <= $_POST['stepone'])
	{
		print "<tr bgcolor=skyblue><td>Ingrediant:<td><input type=text name=ing$x size=20>
			<td>Amount<td><input type=text name=ingamt$x size=6><select name=ingamttype$x>
			<option value=lbs>lbs</option>
			<option value=kg>kg</option>
			<option value=gal>gal</option>
			<option value=ltr>ltr</option></select></tr>
			<tr bgcolor=lightgrey><td>Vendor:<td> <input type=text name=vendor$x size=20>
			<td>Cost per:<td><select name=ingcosttype$x>
			<option value=lbs>lbs</option>
			<option value=kg>kg</option>
			<option value=gal>gal</option>
			<option value=ltr>ltr</option></select> 
			$<input type=text name=ingcost$x size=6></tr>	
		";
		$x++;
	}

	print "</table><input type=submit value=GO>";		
}

// formatted form for printing
function printform () {
	print "<input type=hidden name=switcher value=printform>";
	if ($_POST['startvoltype'] = 'gal') {
		$vol=($_POST['startvol'] * 3.78541178);
	} else {
		$vol=$_POST['startvol'];
	}

	print "<h1>{$_POST['batchname']} Batch Record</h1>";
	print "<h2>Start volume in liters = $vol</h2>";
	
	if($_POST['bonded'] = 'bondedyes')
		{
			print "<h2>Added to bonded inventory</h2><br>";
		} else	{
			print "<h2>NOT added to bonded inventory</h2><br>";
		} 

	print "<table cellpadding=2>
		<tr bgcolor=tan><th>Batch info</th></tr>
		<tr bgcolor=skyblue><td>Start Date:<td> {$_POST['startdate']}
		<td>Employee Name:<td> {$_POST['employee']}</tr>
		<tr bgcolor=lightgrey><td>Batch ID:<td> {$_POST['batchid']}
		<td>Batch Name:<td> {$_POST['batchname']}</tr>
		<tr bgcolor=skyblue><td>Fermenter:<td> {$_POST['fermenter']}
		<td>Total Start Volume:<td> {$_POST['startvol']} {$_POST['startvoltype']}
		<tr bgcolor=lightgrey><td>Initial BRIX: {$_POST['startbrix']}
		<td>BRIX Temp: {$_POST['startbrixtemp']} F
		<tr bgcolor=skyblue><td>Yeast pitched:<td> {$_POST['yeastdate']}
		<td>Temp yeast pitched: <td> {$_POST['yeasttemp']} F</tr></table>
		"; 

	print "<br><table cellpadding=2>";
	print "<tr><th bgcolor=tan>Ingrediant</th><th>Vendor</th><th>Amount Used</th><th>Cost</th>";
	$x=1; $a=0; $b=0;$batchcost=0;
	$count = $_POST['count'];
	while($x < $count)
	{
		if($x %2)
		{
			$color = "skyblue";
		} else {
			$color = "lightgrey";
		}

		$str = sprintf("ing$x");
		$strr = $_POST[$str];
		print "<tr bgcolor=$color><td>$strr"; 

		$str = sprintf("vendor$x");
		$strr = $_POST[$str];
		print "<td>$strr"; 

		$str = sprintf("ingamt$x");
		$strr = $_POST[$str];
		print "<td>$strr";
		$a = $strr ; //set amount for later math

		$str = sprintf("ingamttype$x");
		$strr = $_POST[$str];
		print "$strr"; 

		$str = sprintf("ingcost$x");
		$strr = $_POST[$str];
		$b = $strr;
		$c = ($a * $b);
		$batchcost = ($batchcost + $c);
		print "<td>$$c</tr>";

		

		$x++;
	} 
	print "<tr bgcolor=lightgreen><td><td><td>Batch Cost<td>$$batchcost</tr>";
	print "</table>";

	// bottle needs and cost	
	$bot15=round(($vol / 1.5),0); $case15=round(($bot15 / 6),0);
	$bot750=round(($vol / .750),0); $case750=round(($bot750 / 12),0);
	$bot375=round(($vol / .375),0); $case375=round(($bot375 / 24),0);

	print "<br><table cellpadding=2>
		<tr bgcolor=tan><th>Bottle estimate</th></tr>
		<tr bgcolor=skyblue><td>$bot15 1.5 liter bottles <td> $case15 cases</tr>
		<tr bgcolor=lightgrey><td>$bot750 .750ml bottles <td> $case750 cases</tr>
		<tr bgcolor=skyblue><td>$bot375 .375ml bottles <td> $case375 cases</tr></table>";

	$file=fopen("batch.db","w+") or exit("Unable to open file!\n");
	foreach($_POST as $var => $value)
	{
		$data="$var|$value\n";
		print "$data <br>";
		fwrite($file,$data);
	}
	fclose($file);

}

switch($_POST['switcher']) {
	case 'stepone':
		makeform();
		break;
	case 'makeform':
		printform();
		break;
	default:
		stepone();
}



print "<br><br><hr>DEBUG INFO<br>";
print "<br>print ENV<br>";
foreach($_ENV as $var => $value)
{
print $var . ' : ' . $value . "<br>";
}
?>
</form>
</body>
</html>