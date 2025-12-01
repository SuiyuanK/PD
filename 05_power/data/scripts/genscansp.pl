#! /usr/bin/perl
#############################################################################
# This software is confidential and proprietary information which may only be
# used with an authorized licensing agreement from Apache Design Systems
# In the event of publication, the follow notice is applicable:
# (C) COPYRIGHT 2002-2006 Apache Design Systems
# ALL RIGHTS RESERVED
#
# This entire notice must be reproduced in all copies.
#
#  Abstract: To generate a constraint file for state propagation to exercise
#		vectorless scan algorithm. 
#
#  Verison: 1.4
#  Author: Pius Ng (piusng@apache-da.com)
#
#  History: 	1.0 Initial Release
#		1.1 Added optional explicit instance to cell mapping input
#		1.2 Added mutual exclusive check for option -m and -d
#		    Pattern can be provided as pattern or file
#		    All or One (No Partial) scan pattern can be specified 
#		    using file
#		    First line of the file should be the number of patterns
#		1.3 Speedup instance matching phrase
#		1.4 Added Synopsys and Stil scan order format support
#############################################################################

if ($#ARGV < 1) {
  printf("Usage: genscansp.pl [-mgc <fastscanfile>|-mag <scan order file>|-generic <scan order file>|-syn <scan compiler order file>|-stil <stil scan order file>] [-e <Register Output EEQ> [-d <design_name> | -m <mapping file>]] [-i <primary inputs file>] -p <pattern> -o <sp constraint file>\n");
  printf("Verison: 1.4\n");
  exit(0);
}

$mgc = 0;
$mag = 0;
$generic = 0;
$syn = 0;
$stil = 0;
$eeq = 0;
$pat = 0;
$out = 0;
$pif = 0;
$pwrrpt = 0;
$mapping = 0;

for ($i=0; $i < $#ARGV; $i = $i + 2) {
  if ($ARGV[$i] eq "-mgc") {
    $mgc = 1;
    $fastscanfile = $ARGV[$i + 1];
  } elsif ($ARGV[$i] eq "-mag") {
    $mag = 1;
    $fastscanfile = $ARGV[$i + 1];
  } elsif ($ARGV[$i] eq "-generic") {
    $generic = 1;
    $fastscanfile = $ARGV[$i + 1];
  } elsif ($ARGV[$i] eq "-syn") {
    $syn = 1;
    $fastscanfile = $ARGV[$i + 1];
  } elsif ($ARGV[$i] eq "-stil") {
    $stil = 1;
    $fastscanfile = $ARGV[$i + 1];
  } elsif ($ARGV[$i] eq "-e") {
    $eeq = 1;
    $eeqfile = $ARGV[$i + 1];
    open(EEQFILE,$eeqfile);
  } elsif ($ARGV[$i] eq "-p") {
    $pattern = $ARGV[$i + 1];
    if ($pattern =~ /[A-Z|a-z]/) {
      $patf = 1;
    } else {
      $pat = 1;
    }
  } elsif ($ARGV[$i] eq "-o") {
    $out = 1;
    $spfile = $ARGV[$i + 1];
  } elsif ($ARGV[$i] eq "-d") {
    $design = $ARGV[$i + 1];
    $pwrrpt = 1;
    if ($mapping == 1) {
      printf("FATAL: -d and -m options are mutual exclusive\n");
      exit(-1); 
    }
  } elsif ($ARGV[$i] eq "-m") {
    $design = $ARGV[$i + 1];
    $mapping = 1;
    if ($pwrrpt == 1) {
      printf("FATAL: -d and -m options are mutual exclusive\n");
      exit(-1); 
    }
  } elsif ($ARGV[$i] eq "-i") {
    $pif = 1;
    $pifile = $ARGV[$i + 1];
  } else { 
    printf("FATAL: Illegal option %s\n",$ARGV[$i]);
    exit(-1);
  }
}

if (($mgc == 0) && ($mag == 0) && ($syn == 0) && ($stil == 0) && ($generic == 0)) {
  printf("FATAL: Please specify a scan chain order file\n");
  exit(-1);
} else {
  open(SCANFILE,$fastscanfile);
}

if (($pat == 0) && ($patf == 0)) {
  printf("FATAL: Please specify a pattern\n");
  exit(-1);
}

if ($out == 0) {
  printf("FATAL: Please specify a output file\n");
  exit(-1);
}

$i = 0;
$chain = 0;
$group = 0;
$memory_t = 0;
$invp = 0;
$gate = 0;
$shift_clock = 0;
$inv = 0;
$inst = 0;
$epin = 0;

if ($mgc == 1) {
  printf("Processing Mentor Graphics DFT Advisor Scan Chain Order File.....\n");
  while (<SCANFILE>) {
    if ((/^cell\#/) || (/^\-/)) 
    {} elsif (/(\d+)\s+chain(\d+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+\/(\S+)\s+(\S+)\s+\((\S+),(\S+)\)/) { 
      $cellid = $1;
      $chainid = $2;
      $groupid = $3;
      $memory_type = $4;
      $invp = $5;
      $gaten = $6;
      $clock = $7;
      $inv = $8;
      $inst = $9;
      $ipin = $11;
      $opin = $12;
      $ff[$i] = $inst;
      $ffxmap{$inst} = $i;
      $ffc[$i] = $chainid;
      $ffp[$i] = $opin;
      $ffm[$i] = 0;
      $ffi[$i++] = $inv;
    } elsif (/TLA\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+\((\S+),(\S+)\)/) {
      $invp = $1;
      $gaten = $2;
      $clock = $3;
      $inv = $4;
      $inst = $5;
      $ipin = $7;
      $opin = $8; 
    } elsif (/SHADOW\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+\((\S+),(\S+)\)/) {
      $invp = $1;
      $gaten = $2;
      $clock = $3;
      $inv = $4;
      $inst = $5;
      $ipin = $7;
      $opin = $8;
    } elsif (/^\s*$/) { 
    } else {
      printf("FATAL: Unsupported syntax! Please contact piusng@apache-da.com\n");
      exit(-1); 
    }
  } 
} elsif ($mag == 1) {
  printf("Processing Magma Scan Chain Order File.....\n");
  while (<SCANFILE>) {
    if ((/ChainId scanPin/) || (/ScanOutputPin/)) {
    } elsif (/(\d+)\s+(\S+)\s+(\S+)\s+(\d+)/) {
      $chainid = $1;
      $inst = $3;
      $lasti = rindex($inst,"/");
      $opin = substr($inst,$lasti+1,length($inst) - $lasti);
      $inst = substr($inst,0,$lasti);
      #print "$inst is the instance\n";
      $ff[$i] = $inst;
      $ffxmap{$inst} = $i;
      $ffc[$i] = $chainid;
      $ffp[$i] = $opin;
      $ffm[$i] = 0;
      $ffi[$i++] = 0;
    }  
  }
} elsif ($generic == 1) {
  printf("Processing the GENERIC Scan Chain Order File.....\n");
  while (<SCANFILE>) {
    if (/(\d+)\s+(\S+)/) {
      $chainid = $1;
      $inst = $2;
      $lasti = rindex($inst,"/");
      $opin = substr($inst,$lasti+1,length($inst) - $lasti);
      $inst = substr($inst,0,$lasti);
      print "$inst is the instance\n";
      $ff[$i] = $inst;
      $ffxmap{$inst} = $i;
      $ffc[$i] = $chainid;
      $ffp[$i] = $opin;
      $ffm[$i] = 0;
      $ffi[$i++] = 0;
    }  
  }
} elsif ($syn == 1) {
  printf("Processing Synopsys Scan Chain Order File.....\n");
  $chainid = -1;
  while (<SCANFILE>) {
    if (/------------------------------------/) {
    } elsif (/instance_name/) {
    } elsif (/(\S+)\s+(\d+)\s+MASTER\s+\S+\s+\d+\s+(\S+)\s+\((\S+)\)/) {
      $ncell = $2;
      $inst = $3;
      $cell = $4;
      if ($ncell == 0) {
	$chainid++;
      }
    } elsif (/output\s+(\S+)\s+\d+\s+(\S+)/) {
      $temp1 = $1;
      $temp2 = $2; 
      $t0 = rindex($temp2,"\/");
      $t1 = length($temp2);
      $opin = substr($temp2,$t0+1,$t1-$t0); 
      $ff[$i] = $inst;
      $ffxmap{$inst} = $i;
      $ffc[$i] = $chainid;
      $ffp[$i] = $opin;
      if (exists($eeq_pins{$cell})) {
	for ($pn=0; $pn <= $eeq_pn{$cell}; $pn++) {
          $ffp[$idx][$pn] = $eeq_pins{$cell}[$pn];
        }
        $ffm[$idx] = $eeq_pn{$cell};
      }
      if ($temp1 eq 'Y') {
        $ffi[$i++] = 1;
      } else {
        $ffi[$i++] = 0;
      }
    }  
  }
} elsif ($stil == 1) {
  printf("Processing STIL Scan Chain Order File.....\n");
  $scanstruct = 0;
  $scanchaindef = 0;
  $chainid = -1; 
  while (<SCANFILE>) {
    if ($scanstruct == 1) {
      if (/}/) {
	if ($scanchaindef == 1) {
	  $scanchaindef = 0;
	} else {   
	  $scanstruct = 0;
	  last; 
	}
      } elsif (/ScanLength\s+(\d+)/) {
	$ncells = $1;
      } elsif (/ScanChain \"\S+\"/) {
	$chainid++;
	$scanchaindef = 1;
      } elsif (/ScanInversion\s+(\d+)/) {
      } elsif (/ScanCells\s+(\S+)/) {
	$temp = $1;
	$temp =~ s/"//g;
	if ($temp =~ /\//) {
	} else {
	  $temp =~ s/\./\//g;
 	}
	$t0 = rindex($temp,"\/");
	$t1 = length($temp);
	$opin = substr($temp,$t0+1,$t1-$t0); 
	$inst = substr($temp,0,$t0);
        $ff[$i] = $inst;
        $ffxmap{$inst} = $i;
        $ffc[$i] = $chainid;
        #$ffp[$i] = $opin;
        $ffm[$i] = 0;
        $ffi[$i++] = 0;
	exit(0);
        for($i=0; $i < $ncells-1; $i++) {
	  $_ = <SCANFILE>;
	  $_ =~ /(\S+)/;
	  $temp = $1;
	  $temp =~ s/"//g;
	  if ($temp =~ /\//) {
	  } else {
	    $temp =~ s/\./\//g;
 	  }
	  $t0 = rindex($temp,"\/");
	  $t1 = length($temp);
	  $opin = substr($temp,$t0+1,$t1-$t0); 
	  $inst = substr($temp,0,$t0);
          $ff[$i] = $inst;
          $ffxmap{$inst} = $i;
          $ffc[$i] = $chainid;
          #$ffp[$i] = $opin;
          $ffm[$i] = 0;
          $ffi[$i++] = 0;
	}
      } 
    } elsif (/ScanStructures {/) {
      $scanstruct = 1;
    }
  }
}

$max = $i ;
close(SCANFILE);

if ($eeq == 1) {
  printf("Processing Register Pin EEQ File....\n");
  while(<EEQFILE>) {
    @eeq_array = split(" ",$_);
    $cellname = $eeq_array[0];
    $pn = 0;
    for($pnn=1; $pnn <= $#eeq_array; $pnn++) {
      $pin = $eeq_array[$pnn];
      $eeq_pins{$cellname}[$pn++] = $pin;
      #print "$pin is the pin\n";
    }
    $eeq_pn{$cellname} = $pn - 1;
    
  }
  close(EEQFILE);
  if ($pwrrpt == 1) {
    open(ADSPWR,"adsRpt/" . $design . ".power.rpt");
    printf("Matching instance to cell...\n");
    while (<ADSPWR>) {
      if (/\#/) {
      } elsif (/(\S+)\s+(\S+)/) {
        $inst = $1;
        $cell = $2;
	$idx = $ffxmap{$inst};
        if (exists($eeq_pins{$cell})) {
	  for ($pn=0; $pn <= $eeq_pn{$cell}; $pn++) {
            $ffp[$idx][$pn] = $eeq_pins{$cell}[$pn];
	    print "$ffp[$idx][$pn] is the pin\n";
          }
          $ffm[$idx] = $eeq_pn{$cell};
        }
      } 
    }
    close(ADSPWR);
  } elsif ($mapping == 1) {
    open(MAPF,$design);
    printf("Matching instance to cell...\n");
    while (<MAPF>) {
      if (/(\S+)\s+(\S+)/) {
        $inst = $1;
        $cell = $2;
	$idx = $ffxmap{$inst};
        if (exists($eeq_pins{$cell})) {
	  for ($pn=0; $pn <= $eeq_pn{$cell}; $pn++) {
            $ffp[$idx][$pn] = $eeq_pins{$cell}[$pn];
          }
          $ffm[$idx] = $eeq_pn{$cell};
        }
      } 
    }
    close(MAPF);
  } elsif ($syn != 1) {
    printf("Warning: No instance-to-cell mapping file is provided\n");
  }
}

printf("Processing the pattern\n");
if ($patf == 1) {
  open(PATF,$pattern);
  $_ = <PATF>;
  $_ =~ /(\d+)/;
  $npat = $1;
  if ($npat == 1) {
    $_ = <PATF>;
    $_ =~ /(\S+)/;
    $patternff = $1;
    $lpattern = length($patternff);
    for ($i=0; $i < $lpatternff; $i++) {
      $p_array[$i] = substr($patternff,$i,1);
    }  
  } else {
    $j = 0;
    while (<PATF>) {
      $_ =~ /(\S+)/;
      $patternff = $1;
      $lpattern = length($patternff);
      for ($i=0; $i < $lpatternff; $i++) {
        $p_array[$j][$i] = substr($patternff,$i,1);
      }
      $j++;  
    }    
  }
} else {
  $npat = 1;
  $lpattern = length($pattern);
  for ($i=0; $i < $lpattern; $i++) {
    $p_array[$i] = substr($pattern,$i,1);
  }  
}

for ($p=0; $p < $lpattern; $p++) {
  $k = $p;
  if ($k == 0) {
    $lastk = $lpattern - 1;
  } else {
    $lastk = $p - 1;
  }
  $curr_chain = 0;
  $inv_st = 0;
  open(SPFILE," > ".$spfile.$p);
  if ($pif == 1) {
#print "$pifile\n";
    open(PIFFILE,$pifile);
    while (<PIFFILE>) {
      if (/(\S+)\s+0/) {
        $pin = $1;
        printf(SPFILE "%s 0.0 0.0 0.0\n",$pin); 
      } elsif  (/(\S+)\s+1/) {
        $pin = $1;
        printf(SPFILE "%s 0.0 0.0 1.0\n",$pin);
      } else {
	printf("Illegal syntax in primary input file\n");
	exit(-1);
      }
    }
    close(PIFFILE);
  }
  for ($j=0; $j < $max; $j++) {
    $temp = ($k % $lpattern);  
    if ($k == ($lpattern - 1)) {
      $lastk = $k;
      $k = 0;
    } elsif ($ffc[$j] == $curr_chain) {
      $lastk = $k ;
      $k++;
    } else {
      $lastk = $k ;
      $k = $p + 1;
      $temp = $p;
      $curr_chain = $ffc[$j];
    }
    if ($npat == 1) {
      if (($p_array[$k] == 0) && ($p_array[$lastk] == 0)) {
        $ffv[$j] = "c00";
      } elsif (($p_array[$k] == 0) && ($p_array[$lastk] == 1)) {
        $ffv[$j] = "c01";
      } elsif (($p_array[$k] == 1) && ($p_array[$lastk] == 1)) {
        $ffv[$j] = "c11";
      } elsif (($p_array[$k] == 1) && ($p_array[$lastk] == 0)) {
        $ffv[$j] = "c10";
      }
    } else {
      if ($curr_chain > $npat) {
	printf("FATAL: Number of patterns provided is less than the number of scan chains\n");
	exit(-1);
      }
      if (($p_array[$curr_chain][$k] == 0) && ($p_array[$curr_chain][$lastk] == 0)) {
        $ffv[$j] = "c00";
      } elsif (($p_array[$curr_chain][$k] == 0) && ($p_array[$curr_chain][$lastk] == 1)) {
        $ffv[$j] = "c01";
      } elsif (($p_array[$curr_chain][$k] == 1) && ($p_array[$curr_chain][$lastk] == 1)) {
        $ffv[$j] = "c11";
      } elsif (($p_array[$curr_chain][$k] == 1) && ($p_array[$curr_chain][$lastk] == 0)) {
        $ffv[$j] = "c10";
      }
    }
    if ($inv_st == 1) {
      if ($ffv[$j] eq "c00") {
 	$ffv[$j] = "c11";
      } elsif ($ffv[$j] eq "c01") {
	$ffv[$j] = "c10";
      } elsif ($ffv[$j] eq "c11") {
	$ffv[$j] = "c00";
      } elsif ($ffv[$j] eq "c10") {
	$ffv[$j] = "c01";
      }
    }
    if ($ffi[$j] == 1) {
      if ($inv_st == 0) {
	$inv_st = 1;
      } else {
   	$inv_st = 0;
      }
    }
    if ($ffm[$j] > 0) {
      for($pn=0; $pn <= $ffm[$j]; $pn++) {
	$pin = $ffp[$j][$pn];
	if ($pin =~ /\!/) {
	  $pin =~ s/\!//;
          printf(SPFILE "%s\/%s ",$ff[$j],$pin);
          if ($ffv[$j] eq "c00") {
            printf(SPFILE "%s 0 0 1\n");
          } elsif ($ffv[$j] eq "c01") {
            printf(SPFILE "%s 0 0.5 0\n");
          } elsif ($ffv[$j] eq "c10") {
            printf(SPFILE "%s 0.5 0 0.5\n");
          } elsif ($ffv[$j] eq "c11") {
            printf(SPFILE "%s 0 0 0\n");
          } else {
            printf("FATAL: Illegal Switching Scenario\n");
            exit(-1);
          }
	} else {
          printf(SPFILE "%s\/%s ",$ff[$j],$pin);
          if ($ffv[$j] eq "c00") {
            printf(SPFILE "%s 0 0 0\n");
          } elsif ($ffv[$j] eq "c01") {
            printf(SPFILE "%s 0.5 0 0.5\n");
          } elsif ($ffv[$j] eq "c10") {
            printf(SPFILE "%s 0 0.5 0\n");
          } elsif ($ffv[$j] eq "c11") {
            printf(SPFILE "%s 0 0 1\n");
          } else {
            printf("FATAL: Illegal Switching Scenario\n");
            exit(-1);
          }
        }
      }
    } else {
      printf(SPFILE "%s\/%s ",$ff[$j],$ffp[$j]);
      if ($ffv[$j] eq "c00") {
        printf(SPFILE "%s 0 0 0\n");
      } elsif ($ffv[$j] eq "c01") {
        printf(SPFILE "%s 0.5 0 0.5\n");
      } elsif ($ffv[$j] eq "c10") {
        printf(SPFILE "%s 0 0.5 0\n");
      } elsif ($ffv[$j] eq "c11") {
        printf(SPFILE "%s 0 0 0\n");
      } else {
        printf("FATAL: Illegal Switching Scenario\n");
        exit(-1);
      }
    }
  }
  close(SPFILE);
}

