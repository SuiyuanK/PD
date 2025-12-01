#! /usr/bin/perl

############################################################################################
#	Author: Pius Ng (piusng@apache-da.com)
#	Verison: 1.4
#	History:
#		3/13/2007 1.0	Initial Release
#		3/30/2007 1.1	Instead of using total distance to determine the rotation,
#				use number of ploc per quardant and distance to centerS
#		4/26/2007 1.2	Manual Rotation and Mirror are supported
#	 	6/28/2007 1.3	Fixed bugs
#		7/23/2007 1.4	Automatic Mirroring Detection
#				Debug Plot Feature
############################################################################################

$ver = "1.4";

if ($#ARGV < 1) {
  printf("Usage: cpp2ploc.pl -ploc <RedHawk Ploc File> [-pcpp <CPP package spice deck> | -smap <Spice Node Mapping>] [-bcpp <CPP board spice deck>] -o <Modified Ploc File> [-sp <RH package spice>] [-io <IOSSO config file>] -om <Package Pad Name Mapping File> [-rot <0/90/180/270>] [-m x|y|xy] -plot\n");
  printf("Verison: %s\n",$ver);
  exit(-1);	
}

$spice = 0;
$iosso = 0;
$pkgsp = 0;
$brdsp = 0;
$pcpp = 0;
$smap = 0;
$mrot = 0;
$mmir = 0;
$pmapa = 0;
$plot = 0;

for($i=0; $i <= $#ARGV; $i=$i+2) {
  if ($ARGV[$i] =~ /-ploc/) {
    $plocfile = $ARGV[$i+1];
    open(PLOF,$plocfile);
  } elsif ($ARGV[$i] =~ /-pcpp/) {
    $pcppfile = $ARGV[$i+1];
    open(PCPPF,$pcppfile);
    $pcpp = 1;
    $pkgsp = 1;
  } elsif ($ARGV[$i] =~ /-bcpp/) {
    printf("Info: Board CPP file is not supported yet\n");
    $bcppfile = $ARGV[$i+1];
    open(BCPPF,$bcppfile);
    $brdsp = 1;
  } elsif ($ARGV[$i] =~ /-om/) {
    $pmapfile = $ARGV[$i+1];
    open(PMAPF, " > " . $pmapfile);
    $pmapa = 1;
  } elsif ($ARGV[$i] =~ /-o/) {
    $nplocfile = $ARGV[$i+1];
    open(NPLOCF, " > " . $nplocfile);
  } elsif ($ARGV[$i] =~ /-sp/) {
    $spfile = $ARGV[$i+1];
    open(NSPF, " > " . $spfile);
    $spice = 1;
  } elsif ($ARGV[$i] =~ /-io/) {
    $iofile = $ARGV[$i+1];
    open(IOF, " > " . $iofile);
    $iosso = 1;
  } elsif ($ARGV[$i] =~ /-smap/) {
    $smapfile = $ARGV[$i+1];
    open(SMAPF,$smapfile);
    $smap = 1;
  } elsif ($ARGV[$i] =~ /-rot/) {
    $rotation = $ARGV[$i+1];
    $mrot = 1;
  } elsif ($ARGV[$i] =~ /-m/) {
    $mirror = $ARGV[$i+1];
    $mmir = 1;
  } elsif ($ARGV[$i] =~ /-plot/) {
    $plot = 1;
  } else {
    printf("FATAL: Illegal option\n");
    exit(-1);
  }
}

if ($plot == 1) {
  open(DPLOTF, " > die_pad.xgraph");
  open(PPLOTF, " > pkg_pad.xgraph");
  open(DEBUGF, " > debug.txt");
  printf(DPLOTF "TitleText: Die Pad Locations After mirroring, offsetting, and rotating\n");
  printf(DPLOTF "\"Die\"\n");
  printf(PPLOTF "TitleText: PKG Pad Locations After mirroring, offsetting, and rotating\n");
  printf(PPLOTF "\"PKG\"\n");
}

# Reading Original Ploc File
$numploc = 0;
$maxx = 0;
$minx = 1e12;
$maxy = 0;
$miny = 1e12;
while(<PLOF>) {
  if (/^\#/) {
  } elsif (/(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/) {
    $ploc[$numploc] = $1;
    $x = $2;
    $y = $3;
    $ploc_l[$numploc] = $4;
    $plocx[$numploc] = $x;
    $plocy[$numploc] = $y;
    $temp = $5;
    if ($temp =~ /POWER/i) {
      $plocpg[$numploc] = 1;
    } else {
      $plocpg[$numploc] = 0;
    }
    $numploc++;
    if ($x > $maxx) {
      $maxx = $x;
    } elsif ($x < $minx) {
      $minx = $x;
    }
    if ($y > $maxy) {
      $maxy = $y;
    } elsif ($x < $miny) {
      $miny = $y;
    }
  }
}
close(PLOF);

# Generating the 90, 180, and 270 rotation
$max90x = 0;
$min90x = 1e12;
$max90y = 0;
$min90y = 1e12;
$max180x = 0;
$min180x = 1e12;
$max180y = 0;
$min180y = 1e12;
$max270x = 0;
$min270x = 1e12;
$max270y = 0;
$min270y = 1e12;
for($j=0; $j < $numploc; $j++) {
  $x = ($plocy[$j] * -1) + $maxy;
  $y = $plocx[$j];
  if ($x > $max90x) {
    $max90x = $x;
  }
  if ($x < $min90x) {
    $min90x = $x;
  }
  if ($y > $max90y) {
    $max90y = $y;
  }
  if ($y < $min90y) {
    $min90y = $y;
  }
  $ploc90x[$j] = $x;
  $ploc90y[$j] = $y;
  #printf("DEBUG 90: %f %f\n",$ploc90x[$j],$ploc90y[$j]);
}


for($j=0; $j < $numploc; $j++) {
  $x = $plocx[$j] * -1 + $maxx;
  $y = $plocy[$j] * -1 + $maxy;
  if ($x > $max180x) {
    $max180x = $x;
  } elsif ($x < $min180x) {
    $min180x = $x;
  }
  if ($y > $max180y) {
    $max180y = $y;
  } elsif ($y < $min180y) {
    $min180y = $y;
  }
  $ploc180x[$j] = $x;
  $ploc180y[$j] = $y;
  #printf("DEBUG 180: %f %f\n",$ploc180x[$j],$ploc180y[$j]);
}


for($j=0; $j < $numploc; $j++) {
  $x = $plocy[$j] ;
  $y = $plocx[$j] * -1 + $maxx;
  if ($x > $max270x) {
    $max270x = $x;
  } elsif ($x < $min270x) {
    $min270x = $x;
  }
  if ($y > $max270y) {
    $max270y = $y;
  } elsif ($y < $min270y) {
    $min270y = $y;
  }
  $ploc270x[$j] = $x ;
  $ploc270y[$j] = $y ;
  #printf("DEBUG 270: %f %f\n",$ploc270x[$j],$ploc270y[$j]);
}

$cenx = ($maxx - $minx)/2 + $minx;
$ceny = ($maxy - $miny)/2 + $miny; 

$plocq0 = 0;
$plocq1 = 0;
$plocq2 = 0;
$plocq3 = 0;
$plocd0 = 0;
$plocd1 = 0;
$plocd2 = 0;
$plocd3 = 0;

for($i=0; $i < $numploc; $i++) {
  $dx = $plocx[$i] - $cenx;
  $dy = $plocy[$i] - $ceny;
  if (($plocx[$i] > $cenx) && ($plocy[$i] > $ceny)) {
    $plocq0++;
    $plocd0 = $plocd0 + sqrt(($dx*$dx+$dy*$dy));
  } elsif (($plocx[$i] > $cenx) && ($plocy[$i] < $ceny)) {
    $plocq1++;
    $plocd1 = $plocd1 + sqrt(($dx*$dx+$dy*$dy));
  } elsif (($plocx[$i] < $cenx) && ($plocy[$i] < $ceny)) {
    $plocq2++;
    $plocd2 = $plocd2 + sqrt(($dx*$dx+$dy*$dy));
  } elsif (($plocx[$i] < $cenx) && ($plocy[$i] > $ceny)) {
    $plocq3++;
    $plocd3 = $plocd3 + sqrt(($dx*$dx+$dy*$dy));
  }
}

#Reading the CPP spice deck
$numnode = 0;
$cpp = 0;
$pg = 0;
$sp = 0;
$cppmaxx = 0;
$cppminx = 1e12;
$cppmaxy = 0;
$cppminy = 1e12;
$mcppmaxx = 0;
$mcppminx = 1e12;
$mcppmaxy = 0;
$mcppminy = 1e12;
$nsvdd = 0;
$nsvss = 0;
if ($pcpp == 1) {
  while(<PCPPF>) {
    if (/Start\s+Chip\s+Package\s+Protocol/) {
      $cpp = 1;
    } elsif (/End\s+Chip\s+Package\s+Protocol/) {
      $cpp = 2;
    } elsif ($pg == 1) {
      if (/End\s+Power\s+Ground\s+Ports/) {
        $pg = 2;
      } elsif ((/\s*(\S+)\s+(\S+)\s+(\S+)\s+=\s+(\S+)\s+=\s+(\S+)\s+=\s+DIE/) || (/\s*(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+DIE/)) {
	$cpppname[$numnode] = $1;
	if ($mmir == 1) {
   	  if ($mirror eq "x") {
            $cppx[$numnode] = $2 * $unitv;
            $cppy[$numnode] = $3 * $unitv * -1;
   	  } elsif ($mirror eq "y") {
            $cppx[$numnode] = $2 * $unitv * -1;
            $cppy[$numnode] = $3 * $unitv;
	  } else {
	    $cppx[$numnode] = $2 * $unitv * -1;
            $cppy[$numnode] = $3 * $unitv * -1;
	  }
	} else {
          $cppx[$numnode] = $2 * $unitv;
          $cppy[$numnode] = $3 * $unitv;
 	}
        $mcppx[$numnode] = $2 * $unitv * -1;
        $mcppy[$numnode] = $3 * $unitv;
 	#printf("DEBUG M: %f %f\n",$cppx[$numnode],$cppy[$numnode]);
        $cppsnode[$numnode] = $4;
        $cppname[$numnode] = $5;
	$cppcheck[$numnode] = 0;
        if ($cppminx > $cppx[$numnode]) {
  	  $cppminx = $cppx[$numnode];
        } 
        if ($cppminy > $cppy[$numnode]) {
  	  $cppminy = $cppy[$numnode];
        }
        if ($cppmaxx < $cppx[$numnode]) {
  	  $cppmaxx = $cppx[$numnode];
        } 
        if ($cppmaxy < $cppy[$numnode]) {
  	  $cppmaxy = $cppy[$numnode];
        }
        if ($mcppminx > $mcppx[$numnode]) {
  	  $mcppminx = $mcppx[$numnode];
        } 
        if ($mcppminy > $mcppy[$numnode]) {
  	  $mcppminy = $mcppy[$numnode];
        }
        if ($mcppmaxx < $mcppx[$numnode]) {
  	  $mcppmaxx = $mcppx[$numnode];
        } 
        if ($mcppmaxy < $mcppy[$numnode]) {
  	  $mcppmaxy = $mcppy[$numnode];
        }
        $numnode++;
      } elsif ((/\s+\S+\s+\S+\s+\S+\s+=\s+(\S+)\s+=\s+(\S+)\s+=\s+OTHER/) || (/\s+\S+\s+\S+\s+\S+\s+(\S+)\s+(\S+)\s+OTHER/)) {
        $node = $1;
        $name = $2;
        if ($name =~ /\S*\[_]*VDD(\S+)\[_Group]*/) {  
          $net = "VDD" . $1; 
          $VDD[$nsvdd] = $net;
          $VDDN[$nsvdd] = $node;
    	  $nsvdd++;	
        } elsif ($name =~ /\S*\[_]*VCC(\S+)\[_Group]*/) {  
          $net = "VCC" . $1; 
          $VDD[$nsvdd] = $net;
          $VDDN[$nsvdd] = $node;
    	  $nsvdd++;	
        } elsif ($name =~ /\S*\[_]*PWR(\S+)\[_Group]*/) {  
          $net = "PWR" . $1; 
          $VDD[$nsvdd] = $net;
          $VDDN[$nsvdd] = $node;
    	  $nsvdd++;	
        } elsif ($name =~ /\S*VSS(\S+)\[_Group]*/) {
          $net = "VSS" . $1; 
          $VDD[$nsvss] = $net;
          $VDDN[$nsvss] = $node;
    	  $nsvss++;	
        } elsif ($name =~ /\S*GND(\S+)\[_Group]*/) {
          $net = "GND" . $1; 
          $VDD[$nsvss] = $net;
          $VDDN[$nsvss] = $node;
    	  $nsvss++;	
        } 
      }
    } elsif ($cpp == 1) {
      if (/Length\s+(\S+)/) {
        $unit = $1;
        if ($unit eq "mm") {
          $unitv = 1e3;
        } elsif ($unit eq "m") {
   	$unitv = 1e6;
        } elsif ($unit eq "um") {
  	$unitv = 1;
        } else {
  	printf("Unit %s has not been implemented yet.  Please inform Apache Design Solutions\n",$unit);
  	exit(-1);
        }
      } elsif (/Start\s+Power\s+Ground\s+Ports/) {
        $pg = 1; 
      }
    } elsif ($sp == 1) {
      if (/^\+/) {
        $line = $';
        @ports = split(" ",$line);
        for($m=0; $m <= $#ports; $m++) {
          if (($nport % 10) == 0) {
            $port_line = $port_line . "\n+ " . $ports[$m];
          } else { 
            $port_line = $port_line . " " . $ports[$m];
  	}
  	$nport++;
        }
      } else {
        $sp = 2;
      } 
    } elsif (/^.subckt\s+(\S+)/i) {
      $sp = 1;
      $cell = $1;
      $nport = 0;
      $line = $';
      $port_line = "";
      for($m=0; $m <= $#ports; $m++) {
        if ($nport % 10) {
          $port_line = $port_line . "\n+ " . $ports[$m];
        } else { 
        $port_line = $port_line . " " . $ports[$m];
        }
        $nport++;
      }
    }
  }
  if ($cpp != 2) {
    printf("FATAL: CPP header is either missing or incompleted in CPP header\n");
    exit(-1);
  } elsif ($pg != 2) {
    printf("FATAL: Power Ground Ports section is either missing or incompleted in CPP header\n");
    exit(-1);
  } elsif (($sp != 2) && ($sp == 1)) {
    printf("FATAL: Spice subckt section is either missing or incompleted\n");
    exit(-1);
  }
  close(PCPPF);
} elsif ($smap == 1) {
  $unitv = 1;
  while(<SMAPF>) {
    if (/(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/) {
      if ($mmir == 1) {
   	if ($mirror eq "x") {
          $cppx[$numnode] = $1 * $unitv;
          $cppy[$numnode] = $2 * $unitv * -1;
   	} elsif ($mirror eq "y") {
          $cppx[$numnode] = $1 * $unitv * -1;
          $cppy[$numnode] = $2 * $unitv;
	} else {
	  $cppx[$numnode] = $1 * $unitv * -1;
          $cppy[$numnode] = $2 * $unitv * -1;
	}
      } else {
        $cppx[$numnode] = $1 * $unitv;
        $cppy[$numnode] = $2 * $unitv;
        $mcppx[$numnode] = $2 * $unitv * -1;
        $mcppy[$numnode] = $3 * $unitv;
      }
      $cppsnode[$numnode] = $3;
      $cppname[$numnode] = $4;
      if ($cppminx > $cppx[$numnode]) {
        $cppminx = $cppx[$numnode];
      }
      if ($cppminy > $cppy[$numnode]) {
        $cppminy = $cppy[$numnode];
      }
      if ($cppmaxx < $cppx[$numnode]) {
  	$cppmaxx = $cppx[$numnode];
      } 
      if ($cppmaxy < $cppy[$numnode]) {
  	$cppmaxy = $cppy[$numnode];
      }
      if ($mcppminx > $mcppx[$numnode]) {
        $mcppminx = $mcppx[$numnode];
      } 
      if ($mcppminy > $mcppy[$numnode]) {
  	$mcppminy = $mcppy[$numnode];
      }
      if ($mcppmaxx < $mcppx[$numnode]) {
  	$mcppmaxx = $mcppx[$numnode];
      } 
      if ($mcppmaxy < $mcppy[$numnode]) {
  	$mcppmaxy = $mcppy[$numnode];
      }
      $numnode++;
    }
  }
  close(SMAPF);
}

$cppcenx = ($cppmaxx - $cppminx)/2 + $cppminx;
$cppceny = ($cppmaxy - $cppminy)/2 + $cppminy; 
$mcppcenx = ($mcppmaxx - $mcppminx)/2 + $mcppminx;
$mcppceny = ($mcppmaxy - $mcppminy)/2 + $mcppminy; 

$cppq0 = 0;
$cppq1 = 0;
$cppq2 = 0;
$cppq3 = 0;
$cppd0 = 0;
$cppd1 = 0;
$cppd2 = 0;
$cppd3 = 0;
$mcppq0 = 0;
$mcppq1 = 0;
$mcppq2 = 0;
$mcppq3 = 0;
$mcppd0 = 0;
$mcppd1 = 0;
$mcppd2 = 0;
$mcppd3 = 0;

#printf("DEBUG: cppmaxx %d cppminx %d cppmaxy %d cppminy %d cppcenx %d cppceny %d\n",$cppmaxx,$cppminx,$cppmaxy,$cppminy,$cppcenx,$cppceny);

for($i=0; $i < $numnode; $i++) {
  $dx = $cppx[$i] - $cppcenx;
  $dy = $cppy[$i] - $cppceny;
  $mdx = $mcppx[$i] - $mcppcenx;
  $mdy = $mcppy[$i] - $mcppceny;
#  printf("cppx %d cppy %d\n",$cppx[$i],$cppy[$i]);
  if (($cppx[$i] > $cppcenx) && ($cppy[$i] > $cppceny)) {
    $cppq0++;
    $cppd0 = $cppd0 + sqrt(($dx*$dx+$dy*$dy));
  } elsif (($cppx[$i] > $cppcenx) && ($cppy[$i] < $cppceny)) {
    $cppq1++;
    $cppd1 = $cppd1 + sqrt(($dx*$dx+$dy*$dy));
  } elsif (($cppx[$i] < $cppcenx) && ($cppy[$i] < $cppceny)) {
    $cppq2++;
    $cppd2 = $cppd2 + sqrt(($dx*$dx+$dy*$dy));
  } elsif (($cppx[$i] < $cppcenx) && ($cppy[$i] > $cppceny)) {
    $cppq3++;
    $cppd3 = $cppd3 + sqrt(($dx*$dx+$dy*$dy));
  }
  if (($mcppx[$i] > $mcppcenx) && ($mcppy[$i] > $mcppceny)) {
    $mcppq0++;
    $mcppd0 = $mcppd0 + sqrt(($mdx*$mdx+$mdy*$mdy));
  } elsif (($mcppx[$i] > $mcppcenx) && ($mcppy[$i] < $mcppceny)) {
    $mcppq1++;
    $mcppd1 = $mcppd1 + sqrt(($mdx*$mdx+$mdy*$mdy));
  } elsif (($mcppx[$i] < $mcppcenx) && ($mcppy[$i] < $mcppceny)) {
    $mcppq2++;
    $mcppd2 = $mcppd2 + sqrt(($mdx*$mdx+$mdy*$mdy));
  } elsif (($mcppx[$i] < $mcppcenx) && ($mcppy[$i] > $mcppceny)) {
    $mcppq3++;
    $mcppd3 = $mcppd3 + sqrt(($mdx*$mdx+$mdy*$mdy));
  }
}

# Calculating total delta from each rotation and find the min.

$qd00 = abs($plocq0 - $cppq0);
$qd01 = abs($plocq1 - $cppq1);
$qd02 = abs($plocq2 - $cppq2);
$qd03 = abs($plocq3 - $cppq3);
$qd0 = $qd00 + $qd01 + $qd02 + $qd03;
$mqd00 = abs($plocq0 - $mcppq0);
$mqd01 = abs($plocq1 - $mcppq1);
$mqd02 = abs($plocq2 - $mcppq2);
$mqd03 = abs($plocq3 - $mcppq3);
$mqd0 = $mqd00 + $mqd01 + $mqd02 + $mqd03;
#printf("DEBUG: qd00 %d qd01 %d qd02 %d qd03 %d\n",$qd00,$qd01,$qd02,$qd03);

$qd10 = abs($plocq3 - $cppq0);
$qd11 = abs($plocq0 - $cppq1);
$qd12 = abs($plocq1 - $cppq2);
$qd13 = abs($plocq2 - $cppq3);
$qd1 = $qd10 + $qd11 + $qd12 + $qd13;
$mqd10 = abs($plocq3 - $mcppq0);
$mqd11 = abs($plocq0 - $mcppq1);
$mqd12 = abs($plocq1 - $mcppq2);
$mqd13 = abs($plocq2 - $mcppq3);
$mqd1 = $mqd10 + $mqd11 + $mqd12 + $mqd13;
#printf("DEBUG: qd10 %d qd11 %d qd12 %d qd13 %d\n",$qd10,$qd11,$qd12,$qd13);

$qd20 = abs($plocq2 - $cppq0);
$qd21 = abs($plocq3 - $cppq1);
$qd22 = abs($plocq0 - $cppq2);
$qd23 = abs($plocq1 - $cppq3);
$qd2 = $qd20 + $qd21 + $qd22 + $qd23;
$mqd20 = abs($plocq2 - $mcppq0);
$mqd21 = abs($plocq3 - $mcppq1);
$mqd22 = abs($plocq0 - $mcppq2);
$mqd23 = abs($plocq1 - $mcppq3);
$mqd2 = $mqd20 + $mqd21 + $mqd22 + $mqd23;
#printf("DEBUG: qd20 %d qd21 %d qd22 %d qd23 %d\n",$qd20,$qd21,$qd22,$qd23);

$qd30 = abs($plocq1 - $cppq0);
$qd31 = abs($plocq2 - $cppq1);
$qd32 = abs($plocq3 - $cppq2);
$qd33 = abs($plocq0 - $cppq3);
$qd3 = $qd30 + $qd31 + $qd32 + $qd33;
$mqd30 = abs($plocq1 - $mcppq0);
$mqd31 = abs($plocq2 - $mcppq1);
$mqd32 = abs($plocq3 - $mcppq2);
$mqd33 = abs($plocq0 - $mcppq3);
$mqd3 = $mqd30 + $mqd31 + $mqd32 + $mqd33;
#printf("DEBUG: qd30 %d qd31 %d qd32 %d qd33 %d\n",$qd30,$qd31,$qd32,$qd33);

#printf("DEBUG: qd0 %d qd1 %d qd2 %d qd3 %d\n",$qd0,$qd1,$qd2,$qd3);
#printf("DEBUG: mqd0 %d mqd1 %d mqd2 %d mqd3 %d\n",$mqd0,$mqd1,$mqd2,$mqd3);

$dd00 = abs($plocd0 - $cppd0);
$dd01 = abs($plocd1 - $cppd1);
$dd02 = abs($plocd2 - $cppd2);
$dd03 = abs($plocd3 - $cppd3);
$dd0 = $dd00 + $dd01 + $dd02 + $dd03;
$mdd00 = abs($plocd0 - $mcppd0);
$mdd01 = abs($plocd1 - $mcppd1);
$mdd02 = abs($plocd2 - $mcppd2);
$mdd03 = abs($plocd3 - $mcppd3);
$mdd0 = $mdd00 + $mdd01 + $mdd02 + $mdd03;

$dd10 = abs($plocd3 - $cppd0);
$dd11 = abs($plocd0 - $cppd1);
$dd12 = abs($plocd1 - $cppd2);
$dd13 = abs($plocd2 - $cppd3);
$dd1 = $dd10 + $dd11 + $dd12 + $dd13;
$mdd10 = abs($plocd3 - $mcppd0);
$mdd11 = abs($plocd0 - $mcppd1);
$mdd12 = abs($plocd1 - $mcppd2);
$mdd13 = abs($plocd2 - $mcppd3);
$mdd1 = $mdd10 + $mdd11 + $mdd12 + $mdd13;

$dd20 = abs($plocd2 - $cppd0);
$dd21 = abs($plocd3 - $cppd1);
$dd22 = abs($plocd0 - $cppd2);
$dd23 = abs($plocd1 - $cppd3);
$dd2 = $dd20 + $dd21 + $dd22 + $dd23;
$mdd20 = abs($plocd2 - $mcppd0);
$mdd21 = abs($plocd3 - $mcppd1);
$mdd22 = abs($plocd0 - $mcppd2);
$mdd23 = abs($plocd1 - $mcppd3);
$mdd2 = $mdd20 + $mdd21 + $mdd22 + $mdd23;

$dd30 = abs($plocd1 - $cppd0);
$dd31 = abs($plocd2 - $cppd1);
$dd32 = abs($plocd3 - $cppd2);
$dd33 = abs($plocd0 - $cppd3);
$dd3 = $dd30 + $dd31 + $dd32 + $dd33;
$mdd30 = abs($plocd1 - $mcppd0);
$mdd31 = abs($plocd2 - $mcppd1);
$mdd32 = abs($plocd3 - $mcppd2);
$mdd33 = abs($plocd0 - $mcppd3);
$mdd3 = $mdd30 + $mdd31 + $mdd32 + $mdd33;

$qminangle = -1;
if (($qd00 == 0) && ($qd01 == 0) && ($qd02 == 0) && ($qd03 == 0)) { 
  $qminangle = 0;
} elsif (($qd10 == 0) && ($qd11 == 0) && ($qd12 == 0) && ($qd13 == 0)) {
  $qminangle = 3;
} elsif (($qd20 == 0) && ($qd21 == 0) && ($qd22 == 0) && ($qd23 == 0)) {
  $qminangle = 2;
} elsif (($qd30 == 0) && ($qd31 == 0) && ($qd32 == 0) && ($qd33 == 0)) {
  $qminangle = 1;
} elsif ($mmir == 0) {
  if (($mqd00 == 0) && ($mqd01 == 0) && ($mqd02 == 0) && ($mqd03 == 0)) { 
    $qminangle = 4;
  } elsif (($mqd10 == 0) && ($mqd11 == 0) && ($mqd12 == 0) && ($mqd13 == 0)) {
    $qminangle = 7;
  } elsif (($mqd20 == 0) && ($mqd21 == 0) && ($mqd22 == 0) && ($mqd23 == 0)) {
    $qminangle = 6;
  } elsif (($mqd30 == 0) && ($mqd31 == 0) && ($mqd32 == 0) && ($mqd33 == 0)) {
    $qminangle = 5;
  }
}

if ($qminangle == -1) { 
  printf("Info: This combination of ploc and package doesn't match the ploc per\n");
  printf("	quadrant test.  The number of plocs doesn't match or the\n");
  printf("	distribution is different.  cpp2ploc.pl will proceed with the least\n");
  printf("	error but the result may be wrong\n"); 
  if ($plot == 1) {
    printf("The following data shows the number of plocs/pads per quadrant\n");
    printf("Chip: Q0 %d Q1 %d Q2 %d Q3 %d\n",$plocq0,$plocq1,$plocq2,$plocq3);
    printf("PKG: Q0 %d Q1 %d Q2 %d Q3 %d\n",$cppq0,$cppq1,$cppq2,$cppq3);
    printf("Mirrored PKG: Q0 %d Q1 %d Q2 %d Q3 %d\n",$mcppq0,$mcppq1,$mcppq2,$mcppq3);
  }
  if (($qd0 < $qd1) && ($qd0 < $qd2) && ($qd0 < $qd3)) {
    $qminangle = 0;
    $qmin = $qd0;
  } elsif (($qd1 < $qd0) && ($qd1 < $qd2) && ($qd1 < $qd3)) {
    $qminangle = 3;
    $qmin = $qd1;
  } elsif (($qd2 < $qd0) && ($qd2 < $qd1) && ($qd2 < $qd3)) {
    $qminangle = 2;
    $qmin = $qd2;
  } elsif (($qd3 < $qd0) && ($qd3 < $qd1) && ($qd3 < $qd2)) {
    $qminangle = 1;
    $qmin = $qd3;
  }
  if ($mmir == 0) {
    if (($mqd0 < $mqd1) && ($mqd0 < $mqd2) && ($mqd0 < $mqd3)) {
      if ($mqd0 < $qmin) {
        $qminangle = 4;
      }
  } elsif (($mqd1 < $mqd0) && ($mqd1 < $mqd2) && ($mqd1 < $mqd3)) {
      if ($mqd1 < $qmin) {
        $qminangle = 7;
      }
  } elsif (($mqd2 < $mqd0) && ($mqd2 < $mqd1) && ($mqd2 < $mqd3)) {
      if ($mqd2 < $qmin) {
        $qminangle = 6;
      }
  } elsif (($mqd3 < $mqd0) && ($mqd3 < $mqd1) && ($mqd3 < $mqd2)) {
      if ($mqd3 < $qmin) {
        $qminangle = 5;
      }
    }  
  }
}
$dminangle = -1;
if (($dd00 == 0) && ($dd01 == 0) && ($dd02 == 0) && ($dd03 == 0)) { 
  $dminangle = 0;
} elsif (($dd10 == 0) && ($dd11 == 0) && ($dd12 == 0) && ($dd13 == 0)) {
  $dminangle = 3;
} elsif (($dd20 == 0) && ($dd21 == 0) && ($dd22 == 0) && ($dd23 == 0)) {
  $dminangle = 2;
} elsif (($dd30 == 0) && ($dd31 == 0) && ($dd32 == 0) && ($dd33 == 0)) {
  $dminangle = 1;
}
if ($mmir == 0) { 
  if (($mdd00 == 0) && ($mdd01 == 0) && ($mdd02 == 0) && ($mdd03 == 0)) { 
    $dminangle = 4;
  } elsif (($mdd10 == 0) && ($mdd11 == 0) && ($mdd12 == 0) && ($mdd13 == 0)) {
    $dminangle = 7;
  } elsif (($mdd20 == 0) && ($mdd21 == 0) && ($mdd22 == 0) && ($mdd23 == 0)) {
    $dminangle = 6;
  } elsif (($mdd30 == 0) && ($mdd31 == 0) && ($mdd32 == 0) && ($mdd33 == 0)) {
    $dminangle = 5;
  }
}
if ($dminangle == -1) {
  if ($plot == 1) {
    printf("Info: The number of plocs matches in each quadrant after rotation but\n");
    printf("	the distances from plocs to center are different.  This may be \n");
    printf(" 	caused by scaling in package.  cpp2ploc.pl will proceed\n");
  }
  if (($dd0 < $dd1) && ($dd0 < $dd2) && ($dd0 < $dd3)) {
    $dminangle = 0;
    $dmin = $dd0;
  } elsif (($dd1 < $dd0) && ($dd1 < $dd2) && ($dd1 < $dd3)) {
    $dminangle = 3;
    $dmin = $dd1;
  } elsif (($dd2 < $dd0) && ($dd2 < $dd1) && ($dd2 < $dd3)) {
    $dminangle = 2;
    $dmin = $dd2;
  } elsif (($dd3 < $dd0) && ($dd3 < $dd1) && ($dd3 < $dd2)) {
    $dminangle = 1;
    $dmin = $dd3;
  }
  if ($mmir == 0) {
    if (($mdd0 < $mdd1) && ($mdd0 < $mdd2) && ($mdd0 < $mdd3)) {
      if ($mdd0 < $dim) {
        $dimangle = 4;
      }
    } elsif (($mdd1 < $mdd0) && ($mdd1 < $mdd2) && ($mdd1 < $mdd3)) {
      if ($mdd1 < $dim) {
        $dimangle = 7;
      }
    } elsif (($mdd2 < $mdd0) && ($mdd2 < $mdd1) && ($mdd2 < $mdd3)) {
      if ($mdd1 < $dim) {
        $dimangle = 6;
      }
    } elsif (($mdd3 < $mdd0) && ($mdd3 < $mdd1) && ($mdd3 < $mdd2)) {
      if ($mdd1 < $dim) {
        $dimangle = 5;
      }
    }
  }  
}

#printf("DEBUG PLOC: 0 %d 1 %d 2 %d 3 %d\n",$plocq0,$plocq1,$plocq2,$plocq3);
#printf("DEBUG PLOC D: 0 %e 1 %e 2 %e 3 %e\n",$plocd0,$plocd1,$plocd2,$plocd3);
#printf("DEBUG CPP: 0 %d 1 %d 2 %d 3 %d\n",$cppq0,$cppq1,$cppq2,$cppq3);
#printf("DEBUG CPP D: 0 %e 1 %e 2 %e 3 %e\n",$cppd0,$cppd1,$cppd2,$cppd3);

if ($dminangle == $qminangle) {
  $minangle = $dminangle;
  if ($plot == 1) {
    printf("Info: The ploc per quadrant test agrees with distance per quadrant test\n");
    printf("	Even there are differences for each test, the match is likely to \n");
    printf("	correct\n");
  }
} else {
  $minangle = $qminangle;
  if ($plot == 1) {
    printf("Info:	Since ploc per quadrant test doesn't agree with distance per quadrant test\n");
    printf("	cpp2ploc will proceed with the result of ploc per quadrant test\n");
  }
}	 

if ($mrot == 1) {
  printf("Info: Manual rotation angle is used\n");
  if ($rotation == 0) {
    $minangle = 0;
  } elsif ($rotation == 90) {
    $minangle = 1;
  } elsif ($rotation == 180) {
    $minangle = 2;
  } elsif ($rotation == 270) {
    $minangle = 3;
  } else {
    printf("Illegal manual rotation angle specified\n");
    exit(-1);
  }
}

$datetime = localtime();
printf(NPLOCF "# Ploc file is created by cpp2ploc.pl to match with %s\n# %s\n",$pcppfile,$datetime);
if ($minangle == 0) {
  printf(NPLOCF "# Die match the package as is\n\n");
  $offsetx = $cppminx - $minx;
  $offsety = $cppminy - $miny;
} elsif ($minangle == 1) {
  printf(NPLOCF "# Die must rotate 90 degree counterclockwise to match the package\n\n");
  $offsetx = $cppminx - $min90x;
  $offsety = $cppminy - $min90y;
} elsif ($minangle == 2) {
  printf(NPLOCF "# Die must rotate 180 degree counterclockwise to match the package\n\n");
  $offsetx = $cppminx - $min180x;
  $offsety = $cppminy - $min180y;
} elsif ($minangle == 3) {
  printf(NPLOCF "# Die must rotate 270 degree counterclockwise to match the package\n\n");
  $offsetx = $mcppminx - $min270x;
  $offsety = $mcppminy - $min270y;
} elsif ($minangle == 4) {
  printf(NPLOCF "# Die match the mirrored package as is\n\n");
  $offsetx = $mcppminx - $minx;
  $offsety = $mcppminy - $miny;
} elsif ($minangle == 5) {
  printf(NPLOCF "# Die must rotate 90 degree counterclockwise to match the mirrored package\n\n");
  $offsetx = $mcppminx - $min90x;
  $offsety = $mcppminy - $min90y;
} elsif ($minangle == 6) {
  printf(NPLOCF "# Die must rotate 180 degree counterclockwise to match the mirrored package\n\n");
  $offsetx = $mcppminx - $min180x;
  $offsety = $mcppminy - $min180y;
} elsif ($minangle == 7) {
  printf(NPLOCF "# Die must rotate 270 degree counterclockwise to match the mirrored package\n\n");
  $offsetx = $mcppminx - $min270x;
  $offsety = $mcppminy - $min270y;
}
#printf("Debug: cppminx %f cppminy %f min90x %f min90y %f\n",$cppminx,$cppminy,$min90x,$min90y);
if ($plot == 1) {
  printf("Info: The die ploc is offset by %f %f\n",$offsetx,$offsety);
}

$ndports = 0;
$nvdd = 0;
$nvss = 0;
$tdiff = 0;
$ntdiff = 0;
$check = 0;
for($l=0; $l < $numploc; $l++) {
  $mind = 1e12;
  $mini = 0;
  $everconsider = 0;
  if (($minangle == 0) || ($minangle == 4)) {
    $x = $plocx[$l] + $offsetx;
    $y = $plocy[$l] + $offsety;
  } elsif (($minangle == 1) || ($minangle == 5)) {
    $x = $ploc90x[$l] + $offsetx;
    $y = $ploc90y[$l] + $offsety;
  } elsif (($minangle == 2) || ($minangle == 6)) {
    $x = $ploc180x[$l] + $offsetx;
    $y = $ploc180y[$l] + $offsety;
  } elsif (($minangle == 3)  || ($minangle == 7)) {
    $x = $ploc270x[$l] + $offsetx;
    $y = $ploc270y[$l] + $offsety;
  }
  $type = 0;
  for ($k=0; $k < $numnode; $k++) {
    $consider = 0;
    if ($cppcheck[$k] == 0) {
      if ($ploc[$l] =~ /VDD([a-z|0-9]*)/i) {
        $n0 = "VDD" . $1;
        if ($cppname[$k] =~  /VDD([a-z|0-9]*)/i) {
          $n1 = "VDD" . $1;
          $consider = 1;
          $net = $n1;
	  if ($n0 eq $n1) {
	    $everconsider = 1;
    	  }
        }
      } elsif ($ploc[$l] =~ /VCC([a-z|0-9]*)/i) {
        $n0 = "VCC" . $1;
        if ($cppname[$k] =~  /VCC([a-z|0-9]*)/i) {
          $n1 = "VCC" . $1;
	  $consider = 1;
	  $net = $n1;
	  if ($n0 eq $n1) {
	    $everconsider = 1;
  	  }
        }      
      } elsif ($ploc[$l] =~ /PWR([a-z|0-9]*)/i) {
        $n0 = "PWR" . $1;
        if ($cppname[$k] =~  /PWR([a-z|0-9]*)/i) {
          $n1 = "PWR" . $1;
	  $consider = 1;
	  $net = $n1;
	  if ($n0 eq $n1) {
	    $everconsider = 1;
	  }
        }        
      } elsif ($ploc[$l] =~ /VSS([a-z|0-9]*)/i) {
        $n0 = "VSS" . $1;
        if ($cppname[$k] =~  /VSS([a-z|0-9]*)/i) {
          $n1 = "VSS" . $1;
  	  $consider = 2;
	  $net = $n1;
	  if ($n0 eq $n1) {
	    $everconsider = 1;
    	  }
        }      
      } elsif ($ploc[$l] =~ /GND([a-z|0-9]*)/i) {
        $n0 = "GND" . $1;
        if ($cppname[$k] =~  /GND([a-z|0-9]*)/i) {
          $n1 = "GND" . $1;
	  $consider = 2;
	  $net = $n1;
	  if ($n0 eq $n1) {
	    $everconsider = 1;
	  }
        }      
      } elsif ($plocpg[$l] == 0) {
        if (($cppname[$k] =~  /GND([a-z|0-9]*)/i) || ($cppname[$k] =~  /VSS([a-z|0-9]*)/i)) {
	  $consider = 2;
          $everconsider = 1;
        }
      } elsif ($plocpg[$l] == 1) {
        if (($cppname[$k] =~  /VDD([a-z|0-9]*)/i) || ($cppname[$k] =~  /PWR([a-z|0-9]*)/i) || ($cppname[$k] =~  /VCC([a-z|0-9]*)/i)) {
	  $consider = 2;
          $everconsider = 1;
        }
      }
    } 
    if ($consider > 0) {
      if ($minangle > 3) {
        $cx = $mcppx[$k];
        $cy = $mcppy[$k];
      } else {
        $cx = $cppx[$k];
        $cy = $cppy[$k];
      }
      $dx = $x - $cx;
      $dy = $y - $cy;
      $d = sqrt(($dx*$dx)+($dy*$dy));
      #printf("DEBUG: ploc %s cpp %s cx %f cy %f x %f y %f dx %f dy %f d %f\n",$ploc[$l],$cppsnode[$k],$cx,$cy,$x,$y,$dx,$dy,$d);
      if ($d < $mind) {
        $mind = $d;
        $mini = $k;
	$type = $consider;
	$mnet = $net;
      }
    }
    if ($mind != 0) {
      $found = 0;
      for ($z=0; $z < $ndports; $z++) {
        if ($cppsnode[$mini] eq $cpp_ports[$z]) {
	  $found = 1; 
	}
      }
      if ($found == 0) {
        $cpp_ports[$ndports++] = $cppsnode[$mini];
      }
    }
  }
  if ($type == 1) {
    $vdds[$nvdd] = $ploc[$l];
    $vdds_mn[$nvdd] = $mnet;
    $vdds_m[$nvdd++] = $cppsnode[$mini];
    printf(NPLOCF "%s %s %s %s POWER %s\n",$ploc[$l],$plocx[$l],$plocy[$l],$ploc_l[$l],$cppsnode[$mini]);
  } elsif ($type == 2) {
    $vsss[$nvss] = $ploc[$l];
    $vsss_mn[$nvss] = $mnet;
    $vsss_m[$nvss++] = $cppsnode[$mini];
    printf(NPLOCF "%s %s %s %s GROUND %s\n",$ploc[$l],$plocx[$l],$plocy[$l],$ploc_l[$l],$cppsnode[$mini]);
  }
  if ($mind < 20) {
    $cppcheck[$mini] = 1;
    $ntdiff = $ntdiff + $mind;
    $check++;
  } else {
    printf("Warning: the best match for ploc %s is %fum away!\n",$ploc[$l],$mind);
  }
  $tdiff = $tdiff + $mind;
  if ($plot == 1) {
    if ($minangle < 4) {
      $cx = $cppx[$mini];
      $cy = $cppy[$mini];
    } else {
      $cx = $mcppx[$mini];
      $cy = $mcppy[$mini];
    }
    printf(DEBUGF "%s %f %f %s %f %f %f\n",$ploc[$l],$x,$y,$cppsnode[$mini],$cx,$cy,$mind);
    printf(DPLOTF "%f %f\n",$x,$y);
    printf(PPLOTF "%f %f\n",$cx,$cy);
  }
#  if ($everconsider == 0) {
#    printf("Warning: Ploc %s cannot match to any net\n",$ploc[$l]);
#  }  
  if ($pmapa == 1) {
    printf(PMAPF "%s %s\n",$ploc[$l],$cpppname[$mini]); 
  }
}
$atdiff = $tdiff/$numnode;
$natdiff = $ntdiff/$check;
printf("Info: The average difference among matched ploc and package pad is %fum\n",$atdiff);
printf("Info: The average difference among matched ploc and package pad is %fum excluding any match with 20um or larger in difference\n",$natdiff);
if ($atdiff > 50) {
  printf("Error: Please use the plot option to compare the die and package pads visually.\n");
}

close(NPLOCF);
if ($plot == 1) {
  close(DEBUGF);
  close(DPLOTF);
  close(PPLOTF);
}

if ($spice == 1) {
  printf(NSPF ".inc %s\n\n",$pcppfile);
  for ($i=0; $i < $ndports; $i++) {
    if (($i % 10) == 0) {
      $port_line0 = $port_line0 . "\n+ " . $cpp_ports[$i];
    } else { 
      $port_line0 = $port_line0 . " " . $cpp_ports[$i];
    }
  }
  printf(NSPF ".subckt REDHAWK_PKG %s %s\n\n",$cell,$port_line0);
  $port_line0 = $port_line;
  $port_line0 =~ s/GND0/0/; 
  printf(NSPF "X%s %s\n+ %s\n",$cell,$port_line0,$cell); 
  printf(NSPF "\n.ends\n");
  printf(NSPF "\n\n* Please bias unused PG ports and add ideal voltage source(s)\n");
  close(NSPF);
}

if ($iosso == 1) {
  printf(IOF "PIN_MAP_FILE\n{\n\tpin.map\n}\n\n");
  printf(IOF "SOURCES\n{\n}\n\n");
  printf(IOF "METHOD\n{\n\tTRAN\n}\n\n");
  printf(IOF "SPICE_SETTING\n{\n.option gshunt=1e-12\n.option tcon=3\n.option initbias=3\n.temp 125\n.tran 0.01n 20n\n}\n\n");
  printf(IOF "CONNECTION_RULE\n{\n\tIO_CELLS\tPKG\n");
  printf(IOF "\tVDD_PINS\tPKG\tVSRC\n");
  for($p=0; $p < $#vdds; $p++) {
    $out = $vdds_m[$p];
    if ($out =~ /I/) {
      $out =~ s/I/O/;
    } else {
      $out =~ s/O/I/;
    }
    printf(IOF "\t%s\t%s %s %s\tv%s\n",$vdds[$p],$cell,$vdds_m[$p],$out,lc $vdds_mn[$p]);
  }
  printf(IOF "\n\tVSS_PINS\tPKG\tVSRC\n");
  for($p=0; $p < $#vsss; $p++) {
    $out = $vsss_m[$p];
    if ($out =~ /I/) {
      $out =~ s/I/O/;
    } else {
      $out =~ s/O/I/;
    }
    printf(IOF "\t%s\t%s %s %s\tv%s\n",$vsss[$p],$cell,$vsss_m[$p],$out,lc $vsss_mn[$p]);
  }
  printf(IOF "}\n\n");
  printf(IOF "PKG_BOARD_MODEL\n{\n\t%s\n}\n\n",$pcppfile);
  printf(IOF "LIBRARY\n{\n\}\n\n");
  printf(IOF "IO_CELL_SPICE\n{\n}\n\n"); 
  close(IOF);
}

