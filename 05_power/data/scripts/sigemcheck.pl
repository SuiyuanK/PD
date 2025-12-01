#!/pkg/qct/bin/perl

# $Revision: 1.8 $
################################################################
# (C) COPYRIGHT 2010 Apache Design Systems
# ALL RIGHTS RESERVED
#
#   $Author: pritesh $
#   $Date: 2011/11/15 04:40:11 $
#   $Revision: 1.8 $
#   $Id: sigemcheck.pl,v 1.8 2011/11/15 04:40:11 pritesh Exp $
#
#   Description :
#    SignalEM results post-processing 
#    1. Filters out EM violations for net whose data is not from standard 
#       input sources (STA, SPEF etc.), if -filter set to 1.
#    2. Generates sigem results summary, if -filter set to 1. 
#    3. Compiles net based EM results for valid nets
#    4. suppresses via rms and peak em reporting (Option to control this), if -filter set to 1.
#
#   Usage: 
#    perl sigemcheck.pl  <args>
#    Run perl sigemcheck.pl  -h for args details. 
#
#   Last Modified $Date: 2011/11/15 04:40:11 $
#
#   $Log: sigemcheck.pl,v $
#   Revision 1.8  2011/11/15 04:40:11  pritesh
#   - Added support for new 11.1 signalEM flow.  Set -ver 0 (default 0) for new signalEM flow
#
#   Revision 1.7  2011/07/01 01:34:01  pritesh
#   -filter 0|1 option added to control the sigem results filtering.
#    This option should be set to 0, if SEM_IGNORE_NETS_MISSING_DATA is set in GSR.
#
#   Revision 1.6  2010/10/28 16:42:20  pritesh
#   -g option for unix sort changed to -n (for compatibility reasons)
#
#   Revision 1.5  2010/10/26 19:51:18  pritesh
#   sorted (em viol) output generation for adsRpt/SignalEM_Filtered/*
#
#   Revision 1.4  2010/10/25 20:36:16  pritesh
#   Filtered results generated in adsRpt/SignalEM_Filtered dir also.
#
#   Revision 1.3  2010/10/25 19:41:19  pritesh
#   Reason for unanalyzed nets in summary file updated.
#
#   Revision 1.2  2010/10/21 18:17:00  pritesh
#   Initial Check-in  (updated headers)
#
#
###############################################################
use Getopt::Long;

#pointers
$dapache = ".apache"; 
$dadsrpt = "adsRpt";
$dsigem = "$dadsrpt/SignalEM"; 
$gsr = "$dapache/apache.gsr";
$eminfo = "$dadsrpt/apache.sigem.info";
$dout = "./sigem_results";
$rcmismatch = "$dadsrpt/apache.rcMismatch";
$rcnodriver = "$dadsrpt/apache.rcNoDriver";
$rc0net = "$dadsrpt/apache.rc0Net"; 
$tw0 = "$dadsrpt/apache.tw0";
$twclk0 = "$dadsrpt/apache.twclk0";
$twclklate = "$dadsrpt/apache.twclkLate"; 

#net status
$valid =1;
$netrcmismatch = 2;
$netrcnodriver = 3; 
$netrc0net = 4; 
$nettw0 = 5; 
$nettwclk0 = 6; 
$nettwclklate = 7;
$droppednet = 8; 

$emdebug = 0; 
$emrptonly = 0; 
$emananet = "ALL"; 
$emmode = "rms"; 
$rms = 1;
$peak = 2; 
$avg = 3;

#message
$err = 1;
$warn = 2;
$info = 3;

#init
%nets = (); 
%em = (); 
%tw0inst = ();
%twclk0inst = ();
%twclklateinst = (); 
$avgmax = 0; 
$rmsmax = 0; 
$peakmax = 0; 
$avg_max_net = "-";
$avg_max_emr = "-";
$rms_max_net = "-";
$rms_max_emr = "-";
$peak_max_net = "-";
$peak_max_emr = "-";
$cnt_avg_nets = 0; 
$cnt_rms_nets = 0; 
$cnt_peak_nets = 0; 
$cnt_avg_nets_vio = 0; 
$cnt_rms_nets_vio = 0; 
$cnt_peak_nets_vio = 0; 
$viarms = 0; 
$viapeak = 0; 
$filter = 0; 
$design = 0;  
$ver = 0;

sub print_usage {
  print "\n$0 [-o <output_dir>] [-filter 0|1] [-viarms 0|1] [-viapeak 0|1] [-help]"; 
  print "\n\nWhere,";
  print "\n-o <output_dir> : Output dir  (Optional) (Default: ./sigem_results)";
  print "\n-viarms 0|1 : display via rms em violation (0: no reporting) (Optinal) (Default: 0)";
  print "\n-viapeak 0|1 : display via peak em violation (0: no reporting) (Optinal) (Default: 0)";
  print "\n-filter 0|1 : if 1, filters the sigem results, else not. This option should be set to 0, if SEM_IGNORE_NETS_MISSING_DATA is set in GSR (Optional) (Default: 0)"; 
  print "\n-ver 0|1 : set to 0, if running with new 11.1 signalEM  flow. (Optional) (Default: 0)"; 
  print "\n-help : display this message\n\n";
  exit; 
}
  
sub report {
  ($a, @a) = @_; 
  if($filter) { 
    print OSUM "\n[Error]: @a" if ($a==1); 
    print OSUM "\n[Warn]: @a" if ($a==2); 
    print OSUM "\n[Info]: @a" if ($a==3); 
  }
  print "\n[Error]: @a" if ($a==1); 
  print "\n[Warn]: @a" if ($a==2); 
  print "\n[Info]: @a" if ($a==3); 
  exit if($a==1); 
}

sub analyze_em { 
  ($b, $file) = @_; 
  report ($info, "Opening file $file"); 
  $a = $b;
  open F1, $file; 
# For wires: #layer #end-to-end_coordinates #EM_Ratio #net #width #current #current_limit #direction
# For vias: #via_name #x-y_coordinates #EM_Ratio #net #current #current_limit #direction
  $id = 0;  
  while(<F1>) { 
    next if /^#/;
    next if /^$/;
    next if ((/^via/) && ($a == $rms) && ($viarms == 0)); 
    next if ((/^via/) && ($a == $peak) && ($viapeak == 0)); 

    if(/^via/) { 
      split; 
      $m = $id++.":".$_[1];
      $em{$a}{$_[4]}{$m}{cds} = $_[2];
      $em{$a}{$_[4]}{$m}{emr} = $_[3];
      $em{$a}{$_[4]}{$m}{width} = "--";
      $em{$a}{$_[4]}{$m}{cur} = $_[5];
      $em{$a}{$_[4]}{$m}{curl} = $_[6];
      #print "\n$a via $m $em{$a}{$_[4]}{$m}{emr}"; 
      if(! exists $nets{$_[4]} ) { 
       #$nets{$_[4]} = 1 
        $nets{$_[4]}{state} = $valid;
      }
    } else { 
      split; 
      $m = $id++.":".$_[0];
      $em{$a}{$_[4]}{$m}{cds} = $_[1]." ".$_[2];
      $em{$a}{$_[4]}{$m}{emr} = $_[3];
      $em{$a}{$_[4]}{$m}{width} = $_[5];
      $em{$a}{$_[4]}{$m}{cur} = $_[6];
      $em{$a}{$_[4]}{$m}{curl} = $_[7];
      if(! exists $nets{$_[4]} ) { 
       #$nets{$_[4]} = 1 
        $nets{$_[4]}{state} = $valid;
      }
    }
  }
  close F1;
}


sub print_net {
  
    $net = $_[0];
    if(exists $em{$avg}{$net}) {
      print O1 "\nNet: $net ($nets{$net}{freq1}) ($nets{$net}{type1})"; 
      print O1 "\nDriver : $nets{$net}{dr}"; 
      $cnt_avg_nets++;
      foreach $k ( keys %{$em{$avg}{$net}} ) { 
        $a = $em{$avg}{$net}{$k}{emr}; 
        $b = substr($a, 0, length($a)-1); 
        $b = sprintf ("%f", $b);
        #print "\n$net  $k $b $avgmax :"; 
        $cnt_avg_nets_vio++;
        if($avgmax < $b) { 
          $avgmax = $b; 
          $avg_max_net = $net; 
          $avg_max_emr = $em{$avg}{$net}{$k}{emr}; 
        }
        split /:/, $k; 
        #print O1 "\n$_[1]\t\t$em{$avg}{$net}{$k}{emr}";
        #print O1 "\t$em{$avg}{$net}{$k}{width}\t$em{$avg}{$net}{$k}{cur}"; 
        #print O1 "\t$em{$avg}{$net}{$k}{curl}\t$em{$avg}{$net}{$k}{cds}"; 
        printf O1 "\n%-15s %-15s %-8s %-15s %-15s %-30s", $_[1], $em{$avg}{$net}{$k}{emr}, $em{$avg}{$net}{$k}{width}, $em{$avg}{$net}{$k}{cur},  $em{$avg}{$net}{$k}{curl}, $em{$avg}{$net}{$k}{cds}; 
        if($filter) {
          if ($em{$avg}{$net}{$k}{width} == "--") { 
            print O5 "\nvia $_[1] $em{$avg}{$net}{$k}{cds} $em{$avg}{$net}{$k}{emr} $net $em{$avg}{$net}{$k}{cur} $em{$avg}{$net}{$k}{curl} Bidir"; 
          } else { 
            print O5 "\n$_[1] $em{$avg}{$net}{$k}{cds} $em{$avg}{$net}{$k}{emr} $net $em{$avg}{$net}{$k}{width} $em{$avg}{$net}{$k}{cur} $em{$avg}{$net}{$k}{curl} Bidir"; 
          }
        }
      }
      print O1  "\n"; 
    }  
    
    if(exists $em{$rms}{$net}) {
      print O2 "\nNet: $net ($nets{$net}{freq1}) ($nets{$net}{type1})"; 
      print O2  "\nDriver : $nets{$net}{dr}"; 
      $cnt_rms_nets++;
      foreach $k ( keys %{$em{$rms}{$net}} ) { 
        $a = $em{$rms}{$net}{$k}{emr}; 
        $b = substr($a, 0, length($a)-2); 
        $cnt_rms_nets_vio++;
        if($rmsmax < $b) { 
          $rmsmax = $b; 
          $rms_max_net = $net; 
          $rms_max_emr = $em{$rms}{$net}{$k}{emr}; 
        }
        split /:/, $k; 
        #print O2 "\n$_[1]\t\t$em{$rms}{$net}{$k}{emr}";
        #print O2 "\t$em{$rms}{$net}{$k}{width}\t$em{$rms}{$net}{$k}{cur}"; 
        #print O2 "\t$em{$rms}{$net}{$k}{curl}\t$em{$rms}{$net}{$k}{cds}"; 
        printf O2 "\n%-15s %-15s %-8s %-15s %-15s %-30s", $_[1], $em{$rms}{$net}{$k}{emr}, $em{$rms}{$net}{$k}{width}, $em{$rms}{$net}{$k}{cur},  $em{$rms}{$net}{$k}{curl}, $em{$rms}{$net}{$k}{cds}; 
        if($filter) { 
          if ($em{$rms}{$net}{$k}{width} == "--") { 
            print O6 "\nvia $_[1] $em{$rms}{$net}{$k}{cds} $em{$rms}{$net}{$k}{emr} $net $em{$rms}{$net}{$k}{cur} $em{$rms}{$net}{$k}{curl} Bidir"; 
          } else { 
            print O6 "\n$_[1] $em{$rms}{$net}{$k}{cds} $em{$rms}{$net}{$k}{emr} $net $em{$rms}{$net}{$k}{width} $em{$rms}{$net}{$k}{cur} $em{$rms}{$net}{$k}{curl} Bidir"; 
          }
        }
      }
      print O2 "\n"; 
    }
    
    if(exists $em{$peak}{$net}) {
      print O3 "\nNet: $net ($nets{$net}{freq1}) ($nets{$net}{type1})"; 
      print O3 "\nDriver : $nets{$net}{dr}"; 
      $cnt_peak_nets++;
      foreach $k ( keys %{$em{$peak}{$net}} ) { 
        $a = $em{$peak}{$net}{$k}{emr}; 
        $b = substr($a, 0, length($a)-2); 
        $cnt_peak_nets_vio++;
        if($peakmax < $b) { 
          $peakmax = $b; 
          $peak_max_net = $net; 
          $peak_max_emr = $em{$peak}{$net}{$k}{emr}; 
        }       
        split /:/, $k; 
        #print O3 "\n$_[1]\t\t$em{$peak}{$net}{$k}{emr}";
        #print O3 "\t$em{$peak}{$net}{$k}{width}\t$em{$peak}{$net}{$k}{cur}"; 
        #print O3 "\t$em{$peak}{$net}{$k}{curl}\t$em{$peak}{$net}{$k}{cds}";
        printf O3 "\n%-15s %-15s %-8s %-15s %-15s %-30s", $_[1], $em{$peak}{$net}{$k}{emr}, $em{$peak}{$net}{$k}{width}, $em{$peak}{$net}{$k}{cur},  $em{$peak}{$net}{$k}{curl}, $em{$peak}{$net}{$k}{cds}; 
        if($filter) {
          if ($em{$peak}{$net}{$k}{width} == "--") { 
            print O7 "\nvia $_[1] $em{$peak}{$net}{$k}{cds} $em{$peak}{$net}{$k}{emr} $net $em{$peak}{$net}{$k}{cur} $em{$peak}{$net}{$k}{curl} Bidir"; 
          } else { 
            print O7 "\n$_[1] $em{$peak}{$net}{$k}{cds} $em{$peak}{$net}{$k}{emr} $net $em{$peak}{$net}{$k}{width} $em{$peak}{$net}{$k}{cur} $em{$peak}{$net}{$k}{curl} Bidir"; 
          }
        }
      }
      print  O3 "\n"; 
    }
}
             

GetOptions ("viarms=i" => \$viarms,
            "viapeak=i" => \$viapeak,
            "ver=i" => \$ver,
            "filter=i" => \$filter,
            "o=s" => \$dout, 
            "help" => \$help );

#$dout = $ARGV[0] if($#ARGV != -1);
print_usage if($help); 
 
`rm -rf $dout`;
`mkdir $dout`;
open OSUM, "> $dout/sigem.summary.rpt" if($filter); 
report ($info, "Output will be generated in $dout directory");

report ($err, "Cannot find $gsr") if(! -f $gsr); 
report ($err, "Cannot find $dadsrpt") if(! -d $dadsrpt); 
report ($err, "Cannot find $dsigem") if(! -d $dsigem); 
report ($err, "Cannot find $eminfo") if(! -f $eminfo); 


$m = `grep EM_DEBUG $gsr`; 
$emdebug = $1 if($m =~ /EM_DEBUG\s+(\d)/);

$m = `grep EM_REPORT_MODE_ONLY $gsr`; 
$emrptonly = $1 if($m =~ /EM_REPORT_MODE_ONLY\s+(\d)/);

$m = `grep EM_ANALYZE_NET_ONLY $gsr`; 
$emananet = $1 if($m =~ /EM_ANALYZE_NET_ONLY\s+(.*)/);
report ($info, "Nets analyzed: $emananet"); 

$m = `grep EM_MODE $gsr`; 
$emmode = lc($1) if($m =~ /EM_MODE\s+(.*)/);
report ($info, "EM_MODE : $emmode"); 
  
if($emrptonly == 1) {
  report ($info, "EM_REPORT_MODE_ONLY set to 1");
  report ($info, "Analyzing sigem results for $emmode em violations only"); 
}else{ 
  
  $avgf = `ls $dsigem/*avg_em.worst` if($ver==1); 
  $avgf = `ls $dsigem/*.em.worst.avg` if($ver==0); 
  
  chomp $avgf;
  if ($avgf =~ /$dsigem\/(.*?).avg_em.worst/) { 
     $design = $1; 
  } elsif ($avgf =~ /$dsigem\/(.*?).em.worst.avg/) { 
     $design = $1; 
  }
  
  if($avgf ne "") { 
    report ($info, "Analyzing sigem results for avg em violations"); 
    analyze_em($avg,$avgf); 
  } else {
    report ($warn, "Cannot find $avgf file");  
    report ($warn, "avg em violations cannot be analyzed"); 
  } 
  $rmsf = `ls $dsigem/*rms_em.worst` if($ver==1); 
  $rmsf = `ls $dsigem/*.em.worst.rms` if($ver==0); 
  chomp $rmsf;
  if ($rmsf =~ /$dsigem\/(.*?).rms_em.worst/) { 
     $design = $1; 
  } elsif ($rmsf =~ /$dsigem\/(.*?).em.worst.rms/) { 
     $design = $1; 
  }  
  
  if($rmsf ne "") { 
    report ($info, "Analyzing sigem results for rms em violations"); 
    analyze_em($rms,$rmsf); 
  } else {
    report ($warn, "Cannot find $rmsf file");  
    report ($warn, "rms em violations cannot be analyzed"); 
  } 
  
  $peakf = `ls $dsigem/*peak_em.worst` if($ver==1); 
  $peakf = `ls $dsigem/*.em.worst.peak` if($ver==0); 
  chomp $peakf; 
  if ($peakf =~ /$dsigem\/(.*?).peak_em.worst/) { 
     $design = $1; 
  } elsif ($peakf =~ /$dsigem\/(.*?).em.worst.peak/) { 
     $design = $1; 
  }

  if($peakf ne "") { 
    report ($info, "Analyzing sigem results for peak em violations"); 
    analyze_em($peak,$peakf); 
  } else {
    report ($warn, "Cannot find $peakf file");  
    report ($warn, "peak em violations cannot be analyzed"); 
  } 
  
}

#foreach $k ( keys %nets ) { 
#  print_net $k; 
#  if($cnt++ == 5) { 
#    exit; 
#  }
#}
#exit; 
#foreach $k ( keys %nets) { 
#  print "\n$k $nets{$k}{state}";
#  if( $nets{$k}{state} == $valid ) { 
#    print "\n\t$k";
#  }
#}


$k = keys %nets;
report ($info, "Nets read from em reports: $k");
$cnt=0; 
open F1, $eminfo; 
while(<F1>) { 
  next if /^#/; 
  next if /^$/; 
  split; 
  if(exists $nets{$_[0]}) { 
    $nets{$_[0]}{voltage} =  $_[1];
    $nets{$_[0]}{freq} =  $_[2];
    $nets{$_[0]}{toggle} =  $_[3];
    $nets{$_[0]}{slew} =  $_[4];
    if(@_ == 12) { 
      $nets{$_[0]}{tcap} =  $_[7];
      $nets{$_[0]}{pcap} =  $_[8];
      $nets{$_[0]}{dr} =  $_[9];
      $nets{$_[0]}{drcell} =  $_[10];
      $nets{$_[0]}{pin} =  $_[11];
    } else { 
      $nets{$_[0]}{tcap} =  $_[5];
      $nets{$_[0]}{pcap} =  -1;
      $nets{$_[0]}{dr} =  $_[6];
      $nets{$_[0]}{drcell} =  $_[7];
      $nets{$_[0]}{pin} =  $_[8];
    }
    $cnt++; 
  }
}
report ($info, "Nets updated from $eminfo: $cnt");


$drp = `ls $dsigem/*droppedSignalNets`;
chomp($drp); 
$n2 = 0; 
if($drp ne "") { 
  open F1, $drp; 
  while(<F1>) { 
    next if /^$/; 
    next if /^#/; 
    split /\(/; 
    $nets{$_[0]}{state} = $droppednet; 
    $a = $_[0];
    $b = substr($_[1], 0, length($_[1])-2);
    split " ", $b; 
    $c = join '_', @_;
    $nets{$a}{info} = $c;
    $n2++;
  }
  close F1; 
  report ($info,  "Nets read from $drp: $n2");
} else {
  report ($info, "$dsigem/*droppedSignalNets not found"); 
}                                            

$nettp = `ls $dapache/apache.freq.gz`; 
$n2 = 0; 
$n1 = 0; 
if($nettp ne "") {
  chomp($nettp); 
  `rm .apache.freq.gz`  if(-f ".apache.freq.gz"); 
  `rm .apache.freq`  if(-f ".apache.freq"); 
  `cp  $nettp .apache.freq.gz`;
  `gzip -d .apache.freq.gz`; 
  if(-f ".apache.freq") {
    open F1, ".apache.freq";
    while(<F1>) {
      next if/^#/; 
      next if/^$/; 
      split;
      $n2++;
      if(exists $nets{$_[0]}) {
        $nets{$_[0]}{freq1} = $_[1];
        $nets{$_[0]}{type1} = $_[2];
        $n1++; 
      }
    }
    close F1; 
    #report ($info,  "Total $n1/$n2 nets updated from .apache.freq");
    report ($info,  "Nets updated with type and clock info: $n1");
  } else { 
    report ($warn,  "Net type info generation unsuccessful");
  }
} else {
  report ($info, "Net type info not found"); 
} 

if($filter) { 
  $n1 = 0;
  $n2 = 0; 
  if(-f $rcmismatch) { 
    open F1, $rcmismatch; 
    while(<F1>) { 
      next if /^#/; 
      split /</;
      $a = $_[2]; 
      split />/, $a; 
      $n2++;
      if(exists $nets{$_[0]}) { 
      #  print "\nRCMM $_[0]";
        $nets{$_[0]}{state} = $netrcmismatch; 
        $n1++; 
      }
    }
    report ($info, "Nets updated from $rcmismatch: $n1"); 
    close F1; 
  } else { 
    report ($warn, "Cannot find $rcmismatch file"); 
  }


  $n1 = 0; 
  $n2 = 0; 
  if(-f $rc0net) { 
    open F1, $rc0net; 
    while(<F1>) { 
      next if /^#/; 
      split;
      $a = $_[0]; 
      split /:/, $a; 
      $n2++;
      if(exists $nets{$_[1]}) { 
      # print "\nRCZN $_[1]";
        $nets{$_[1]}{state} = $netrc0net; 
        $n1++; 
      }
    }
    report ($info, "Nets  updated from $rc0net: $n1"); 
    close F1; 
  } else { 
    report ($warn, "Cannot find $rc0net file"); 
  }

  $n1 = 0; 
  $n2 = 0; 
  if(-f $rcnodriver) { 
    open F1, $rcnodriver; 
    while(<F1>) { 
      next if /^#/; 
      split;
      $a = $_[0]; 
      split /:/, $a; 
      $n2++;
      if(exists $nets{$_[1]}) { 
      # print "\nRCND $_[1]";
        $nets{$_[1]}{state} = $netrcnodriver; 
        $n1++; 
      }
    }
    report ($info, "Nets updated from $rcnodriver: $n1"); 
    close F1; 
  } else { 
    report ($warn, "Cannot find $rcnodriver file"); 
  }


  $n2 = 0; 
  if(-f $tw0) { 
    open F1, $tw0; 
    while(<F1>) {
      next if /^#/; 
      split;
      $n2++;
      $tw0inst{$_[1]} = 1 if(! exists $tw0inst{$_[1]}); 
    }
    report ($info, "Instances read from $tw0: $n2"); 
    close F1; 
  } else { 
    report ($warn, "Cannot find $tw0 file"); 
  }

  $n2 = 0; 
  if(-f $twclk0) { 
    open F1, $twclk0; 
    while(<F1>) {
      next if /^#/; 
      split;
      $n2++;
      $twclk0inst{$_[1]} = 1 if(!exists $twclk0inst{$_[1]});  
    }
    report ($info, "Instances read from $twclk0: $n2"); 
    close F1; 
  } else { 
    report ($warn, "Cannot find $twclk0 file"); 
  }

  $n2 = 0; 
  if(-f $twclklate) { 
    open F1, $twclklate; 
    while(<F1>) {
      next if /^#/; 
      split /</; 
      $a = $_[1];
      split />/, $a; 
      $n2++;
      $twclklateinst{$_[0]} = 1 if(!exists $twclklateinst{$_[0]});
    }
    report ($info, "Instances read from $twclklate: $n2"); 
    close F1; 
  } else { 
    report ($warn, "Cannot find $twclklate file"); 
  }
}

report ($info, "Generating reports..."); 
$cnt_rcmismatch = 0; 
$cnt_rcnodriver = 0; 
$cnt_rc0net = 0; 
$cnt_tw0 = 0; 
$cnt_twclk0 = 0; 
$cnt_twclklate = 0; 
$cnt_dropped = 0; 
open O1, "> $dout/avg.sigem.rpt"; 
open O2, "> $dout/rms.sigem.rpt"; 
open O3, "> $dout/peak.sigem.rpt"; 
$header = "# Report Format:  
#  Net: <name_name>
#  Driver: <net_driver_instance>
#  Net violation summary
#  Layer  EM_Ratio  Width  Current  Current_Limit  XY-Coordinates";
$dat = `date`;
print O1 "#Signal Nets AVG EM Violation Report"; 
print O1 "\n#$dat";
print O1 "$header\n"; 
print O2 "#Signal Nets RMS EM Violation Report"; 
print O2 "\n#$dat";
print O2 "$header\n"; 
print O3 "#Signal Nets PEAK EM Violation Report"; 
print O3 "\n#$dat";
print O3 "$header\n"; 

if($filter) { 
  open O4, "> $dout/filteredout.sigem.rpt"; 
  print O4  "#net driver issue";
  $dout_filtered = "adsRpt/SignalEM_Filtered"; 
  `rm -rf $dout_filtered` if (-d $dout_filtered) ;
  `mkdir $dout_filtered`;
  print "\nCreated $dout_filtered"; 
  open O5, "> $dout_filtered/avg_em.worst"; 
  open O6, "> $dout_filtered/rms_em.worst"; 
  open O7, "> $dout_filtered/peak_em.worst"; 
}

foreach $k ( keys %nets) { 
  #print "\n$k $nets{$k}{state}";
  $nets{$k}{state} = $nettw0  if(exists $tw0inst{$nets{$k}{dr}});
  $nets{$k}{state} = $nettwclk0  if(exists $twclk0inst{$nets{$k}{dr}});
  $nets{$k}{state} = $nettwclklate  if(exists $twclklateinst{$nets{$k}{dr}});
  if( $nets{$k}{state} == $valid ) { 
    print_net $k; 
    $cnt_valid++; 
  } elsif( $nets{$k}{state} == $netrcmismatch ) { 
    printf O4 "\n%-30s%-30s\tINCONSISTENT_DRIVER", $k, $nets{$k}{dr}; 
    $cnt_rcmismatch++; 
  } elsif( $nets{$k}{state} == $netrcnodriver ) { 
    printf O4 "\n%-30s%-30s\tNO_DRIVER_FROM_SPEF", $k, $nets{$k}{dr}; 
    $cnt_rcnodriver++; 
  } elsif( $nets{$k}{state} == $netrc0net ) { 
    printf O4 "\n%-30s%-30s\tNO_SPEF_DATA", $k, $nets{$k}{dr}; 
    $cnt_rc0net++; 
  } elsif( $nets{$k}{state} == $nettw0 ) { 
    printf O4 "\n%-30s%-30s\tDRIVER_NO_TW", $k, $nets{$k}{dr}; 
    $cnt_tw0++; 
  } elsif( $nets{$k}{state} == $nettwclk0 ) { 
    printf O4 "\n%-30s%-30s\tDRIVER_NO_CLKTW", $k, $nets{$k}{dr}; 
    $cnt_twclk0++; 
  } elsif( $nets{$k}{state} == $nettwclklate ) { 
    printf O4 "\n%-30s%-30s\tDRIVER_INVALID_TW", $k, $nets{$k}{dr}; 
    $cnt_twclklate++; 
  } elsif( $nets{$k}{state} == $droppednet ) { 
    printf O4 "\n%-30s%-30s\t%-50s", $k, "-", $nets{$k}{info}; 
    $cnt_dropped++; 
  } 
}
close O1; 
close O2; 
close O3; 
close O4; 
close O5; 
close O6; 
close O7; 

if($filter) { 
  `sort -n -k 4 -r $dout_filtered/avg_em.worst > $dout_filtered/$design.avg_em.worst`; 
  `sort -n -k 4 -r $dout_filtered/rms_em.worst > $dout_filtered/$design.rms_em.worst`; 
  `sort -n -k 4 -r $dout_filtered/peak_em.worst > $dout_filtered/$design.peak_em.worst`; 
  `rm $dout_filtered/avg_em.worst`;
  `rm $dout_filtered/rms_em.worst`;
  `rm $dout_filtered/peak_em.worst`;

  print OSUM "\n\n-----------------------------------------------";
  print OSUM "\nFiltered Out Nets Summary:"; 
  print OSUM "\n-----------------------------------------------";
  printf OSUM "\n%-50s%-15d", "Inconsitent driver from def and spef", $cnt_rcmismatch; 
  printf OSUM "\n%-50s%-15d", "No driver from spef", $cnt_rcnodriver; 
  printf OSUM "\n%-50s%-15d", "No spef data", $cnt_rc0net; 
  printf OSUM "\n%-50s%-15d", "Net driver having no timing window", $cnt_tw0; 
  printf OSUM "\n%-50s%-15d", "Net driver having no clk pin timing window", $cnt_twclk0; 
  printf OSUM "\n%-50s%-15d", "Net driner having o/p switching earlier than clk", $cnt_twclklate; 
  printf OSUM "\n%-50s%-15d", "OTHERS", $cnt_dropped; 
  print OSUM "\n-----------------------------------------------";
  $a = $cnt_rcmismatch + $cnt_rcnodriver + $cnt_rc0net + $cnt_tw0 + $cnt_twclk0 + $cnt_twclklate + $cnt_dropped;
  printf OSUM "\n%-30s%-15d", "TOTAL", $a; 
  print OSUM "\n-----------------------------------------------";

  print OSUM "\n\n-----------------------------------------------";
  print OSUM "\nWorst SignalEM Net Summary:";
  print OSUM "\n-----------------------------------------------";
  printf OSUM "\n%-8s%-15s%-30s", "MODE","EM_RATIO","NET";
  printf OSUM "\n%-8s%-15s%-30s", "AVG",$avg_max_emr,$avg_max_net;
  printf OSUM "\n%-8s%-15s%-30s", "RMS",$rms_max_emr,$rms_max_net;
  printf OSUM "\n%-8s%-15s%-30s", "PEAK",$peak_max_emr,$peak_max_net;
  print OSUM "\n-----------------------------------------------";
  print OSUM "\n\nTotal nets with AVG EM values : $cnt_avg_nets";
  #print OSUM "\nTotal AVG EM violations       : $cnt_avg_nets_vio";
  print OSUM "\nTotal nets with RMS EM values : $cnt_rms_nets";
  #print OSUM "\nTotal RMS EM violations       : $cnt_rms_nets_vio";
  print OSUM "\nTotal nets with PEAK EM values : $cnt_peak_nets";
  #print OSUM "\nTotal PEAK EM violations       : $cnt_peak_nets_vio";

  close OSUM; 
}
report ($info, "Finished Post Processing EM Results");
report ($info, "Exiting.\n");


