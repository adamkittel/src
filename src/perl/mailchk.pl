#!/usr/local/bin/perl

$a=0;
$TMP=0;
while($a != 100)
{
    open(MAIL,"/var/mail/akittel");
    @MAIL2=<MAIL>;
    $MAIL3=@MAIL2;
    close(MAIL);

    if($TMP < $MAIL3)
    {
	system("/home/akittel/wav /home/akittel/opt/snd/fudd02.wav");
    }
    $TMP=$MAIL3;
    sleep 300;
    $a++;
}
