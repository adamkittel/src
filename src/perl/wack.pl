#!/home/akittel/bin/perl

opendir(CWD,".");
@files = readdir(CWD);
$b=@files;

for($a=0;$a<=$b;$a++)
{
    if($files[$a] =~ /~/)
    {
	print $files[$a];
	system("rm $files[$a]");
    }
}
