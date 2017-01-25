<html>
<title>Adam's Winery Software</title>
<form action="money.php" method="post">
<body bgcolor=#a4b1c0>
<h1>Adam's winery software - test mode</h1>

<?php

function stepone() {
	print "<input type=hidden name=switcher value=steponedone>
		<h1>Expense Entry</h1>
		How many expenses do you want to enter? 
		<select name=stepone>
		<option>1<option>2<option>3<option>4
                <option>5<option>6<option>7<option>8
		<option>9<option>10<option>11<option>12
		<option>13<option>14<option>15
		</select>
		<input type=submit value=GO>";
}


function expense_entry() {
	$x=1;
	print "<input type=hidden name=switcher value=expense_entry>";
	print "<h1>Expense Entry</h1>
		<table cellpadding=2>
		<tr bgcolor=tan><th>Invoice #<th>Invoice Amount<th>Description<th>Catagory
		<th>Due Date<th>Paid<th>Check #</tr>";
	while($x <= $_POST['stepone']){
		if($x %2) {
			$color = "skyblue";
		} else {
		        $color = "lightgrey";
		}
		print "<tr bgcolor=$color>
			<input type=hidden name=beginentry$x>
			<td><input type=text name=inv$x size=15>
			<td>$<input type=text name=invamt$x size=8>
			<td><input type=text name=invdesc$x size=40>
			<td><select name=invcat$x>
			<option>Select one
			<option>Advertising<option>Vehical<option>Commision/Fee
			<option>Contract Labor<option>Depletion<option>Depreciation
			<option>Employee Benifits<option>Insurance<option>Mortgage Intrest
			<option>Other Intrest<option>Lawyer/Professional
			<option>Office<option>Pension/Profit Share<option>Rent/Lease
			<option>Repair/Maint<option>Supplies(not COGS)
			<option>Taxes/License<option>Travel<option>Utilities
			<option>Wages<option>COGS<option>Other</select>
			<td><input type=text name=invdate$x size=10>
			<td>Yes<input type=radio name=invpaid$x value=yes>
			No<input type=radio name=invpaid$x value=no>
			<td><input type=text name=invcheck$x size=6></tr>";
			$x++;
	}
	print "</table> <br><input type=submit value=GO>";
}


function expense_report() {
	write_data();
	print "<input type=hidden name=switcher value=expense_report>
		<h1>Expense Report</h1><table cellpadding=2><tr bgcolor=tan>
		<th>Invoice #<th>Amount<th>Description<th>Catagory<th>Due Date<th>Paid<th>Check #
		<tr bgcolor=skyblue>";

	$spent = 0;
	$file = @fopen("expense.db", 'r');
	if($file) {
		while(!feof($file)) {
			$line = fgets($file, 4096);
			list($name,$value) = split('\|',$line);
			if(preg_match('/^beginentry/',$name)) { print "</tr><tr bgcolor=skyblue>"; }
			if(preg_match('/^inv/',$name)) {
				print "<td>$value";
				if(preg_match('/^invamt/',$name)) {
					$spent = ($spent + $value);
				}
			}
		}
		fclose($file);
	}
	print "<tr bgcolor=lightgreen><td>Total<td>$spent</tr></table>";
}

function write_data() {
	$file = fopen("expense.db", "a+") or exit("CRAP! can't open file!");
	foreach($_POST as $var => $value) {
		$data="$var|$value\n";
		fwrite($file,$data);
	}
	        fclose($file);
}

switch($_POST['switcher']) {
case 'steponedone':
	expense_entry();
	break;
case 'expense_entry':
	expense_report();
	break;
default:
	stepone();
}

print "<br><br><hr>DEBUG INFO<br>";
print "<br>POST<br>";
foreach($_POST as $var => $value)
{
	print $var . ' : ' . $value . "<br>";
}

print "<br>ENV<br>";
foreach($_ENV as $var => $value)
{
print $var . ' : ' . $value . "<br>";
}
?>
</form>
</body>
</html>

