#!/var/station/bin/perl

require 5.001;
use Tk;
use Getopt::Long;

$version = "1.00";

$0 = "ptkb";
$ptkbrc = "$ENV{'HOME'}/.ptkbrc";
@mw = ();

$numberfont = "9x16";
$namefont = "6x13";
$delay = 2;    # in seconds
$delay *= 1000;  # now miliseconds
$foreground = "Black";
$background = "White";

sub switches {
  $autoabbrev = 0;
  $r = GetOptions("h","v","geometry=s","s","S");

  if (!$r) { $opt_h = 1; }

  if ($opt_h) {
    print <<HELP;

ptkb - an xbiff++ like program written in perl5 and pTk.  Can watch
       any number of mailboxes for incoming mail.  See the default config
       file for how the options work.  Usually started from your
       ~/.X11Startup file

Usage:
  ptkb [-geometry geometry] [-h] [-i] [-s] [-S] [-v]

Options:
-geometry heightxwidth+x+y 
          = standard X geometry string
-h        = this help message.
-i        = ignore .ptkbrc file
-s        = setup the ~/.ptkbrc configuration file with default file.
-S        = overwrite current ~/.ptkbrc file with default file.
-v        = print the version.

HELP

  exit;
    
  }
  if ($opt_v) {
    print STDERR
      "ptkb - version: $version - author: John Stoffel (john\@wpi.edu)\n";
  }
  if ($opt_s || $opt_S) {
    print STDERR "setting up default ~/.ptkbrc file.\n";
    if (-e $ptkbrc && $opt_s) {
      die "Error: ~/.ptkbrc already exists!  Use -S to overwrite.\n";
    }
    else {
      open(RC,">$ptkbrc") || die "Error: can't create $ptkbrc: $!\n";
      print RC <<PTKBRC;

# default ~/.ptkbrc file as setup by ptkb.  Lines can be commented out
# with a leading '#' as usual.

numfont = 9x16
namefont = 6x13
delay = 2
      
foreground = Black
background = White

#
# Example:
#
# spool = /usr/spool/mail/USER
# title = My-Mail

PTKBRC
		    
  close(RC);
      exit
      }
  }
}

# for now, options are global.  Eventually, they will be per-mailbox
# when there is a proper constructor for each entry and the values it
# will contain.  
#
# if you don't set a mail spool to watch, it defaults to
# /usr/spool/mail/USER 

sub parserc { 
  
  local($i) = -1;
  local($t);

  @ms = ();
  @mn = ();
  @msc = ();

  if (-e $ptkbrc && !$opt_i) {
    open(O,"<$ptkbrc") || die "Error: Can't open $ptkbrc: $!\n";
    while (<O>) {
      chop;
      if (/^#.*$|^$/)                { next; }
      if (/numfont\s*=\s*(\w+)/i)    { $numberfont = $1; }
      if (/namefont\s*=\s*(\w+)/i)   { $namefont = $1; }
      if (/delay\s*=\s*(\w+)/i)      { $delay = $1 * 1000; }
      if (/foreground\s*=\s*(\w+)/i) { $foreground = $1; }
      if (/background\s*=\s*(\w+)/i) { $background = $1; }

      if (/spool\s*=\s*(\S+)/i) {
	$i++;
	$t = $1;
	$t =~ s/~/$ENV{'HOME'}/;
	push(@ms,$t);
	push(@mn,"");
	push(@msc,0);
      }

      if (/title\s*=\s*(.+)/i) {
	if ($i >= 0) {
	  $mn[$i] = $1;
	}
      }
    }
    close(O);
  }
  
  if ($i == -1) {
    @ms = ( "/usr/spool/mail/$ENV{'USER'}" );
    @mn  = ( "Mailbox" ) ;
    @msc = ( 0 );
  }    
}

sub setup {
  $width = 0;
  @mw = ();

  for (@mn) { 
    $l = length; 
    if ($l > $width) { 
      $width = $l;
    } 
    $width += 6;
  }
  
  if ($opt_geometry) {
    $top->wm('geometry',"$opt_geometry");
  }
  
  for ($i = 0; $i <= $#ms; $i++) {
    $name = $mn[$i];
    $name =~ tr/A-Z/a-z/;
    $mailstr[$i] = sprintf("$mn[$i]: .%3d",0);
    $mw[$i] = $top->Label("-width" => $width,
			  "-textvariable" => \$mailstr[$i],
			  "-font" => "$namefont",
			  "-bd" => 1,
			  "-relief" => "raised",
			  "-background" => $background,
			  "-foreground" => $foreground,
			  );
    $mw[$i]->pack("-side" => "top",
		  "-fill" => "x",
		  "-expand" => "yes",
		  "-pady" => 1,
		  "-padx" => 2,
		  );
  }
}

sub sighup {
  my ( $l );
  for $l (@mw) {
    $l->destroy;
  }
  $top->wm('geometry','');
#  $top->wm('withdraw');
  parserc;
  setup;
}

sub invert {
  local($i) = shift(@_);       # index
  local($s) = shift(@_);       # state

  if ($s) {
    $mw[$i]->configure("-foreground" => $background,
		       "-background" => $foreground,
		       );
  } 
  else {
    $mw[$i]->configure("-foreground" => $foreground,
		       "-background" => $background, 
		       );
  }    
}

sub looper {
  ($i,$F,$num,$size);
  for ($i=0;$i<=$#ms;$i++) {
    $size = (stat($ms[$i]))[7];
    if ( $msc[$i] != $size ) {
      open(F,$ms[$i]);
      $num = 0;
      while (<F>) { $num++ if /^From / }
      close(F);
      $mailstr[$i] = sprintf("$mn[$i]: %.3d",$num);
      &invert($i,1);
    } 
    if ($size == 0) {
      $mailstr[$i] = sprintf("$mn[$i]: %.3d",0);
      &invert($i,0);
    }
    $msc[$i] = $size;
  }
  after($delay,\&looper);
}

$top = MainWindow->new;

$SIG{'HUP'} = 'sighup';

switches;
parserc;
setup;
#$top->wm('deiconify');
looper;

MainLoop;



