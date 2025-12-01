#!/pkg/qct/bin/perl

# $Revision: 1.3 $
################################################################
# (C) COPYRIGHT 2010 Apache Design Systems
# ALL RIGHTS RESERVED
#
#   $Author: pritesh $
#   $Date: 2010/11/13 00:20:39 $
#   $Revision: 1.3 $
#   $Id: showb2b.pl,v 1.3 2010/11/13 00:20:39 pritesh Exp $
#
#   Description :
#
#   Usage: 
#    perl showb2b.pl  <args>
#
#   Last Modified $Date: 2010/11/13 00:20:39 $
#
#   $Log: showb2b.pl,v $
#   Revision 1.3  2010/11/13 00:20:39  pritesh
#   Fixed duplicate bump reporting for NO_CLAMP and OUT_OF_RAD category
#
#   Revision 1.2  2010/11/12 21:49:59  pritesh
#   Initial check-in
#
#   Revision 1.1  2010/11/12 21:49:05  pritesh
#   Initial Check-in
#
#
###############################################################
use Getopt::Long;

$esddir = "adsRpt/ESD"; 

$info = 3 ; 
$warn = 2; 
$err = 1;

sub print_usage {
# 
#  bump  = PASS | FAIL | NO_CLAMP | OUT_OF_RAD | UNCONNECTED
#  bumppair = PASSING | FAILING | OUT_OF_RAD      
#
  print "\n$0 [-rule_name <rule name>] [-rule_type <rule type>] [-bump <CATEGORY>] [-domain <domain>] [-pad_file <ploc file>] [-bumppair <category>] [-esd_dir <path to esd results>] [-help]"; 
  print "\n\nWhere,";
  print "\n-rule_name : specify esd rule name used for the ESD analysis (case sensitive)"; 
  print "\n-rule_type : type can be < B2B | B2C > "; 
  print "\n-bump  : category can be < PASS | FAIL | NO_CLAMP | OUT_OF_RAD | UNCONNECTED > ";  
  print "\n-bumppair : category can be < PASS | FAIL | OUT_OF_RAD > ";  
  print "\n-domain : specify the domain (applies to -bump only) (Default: all domains)"; 
  print "\n-pad_file : specify the path to ploc file (required for -bump category UNCONNECTED)"; 
  print "\n-esd_dir : specify the path to esd results directory (Default: adsRpt/ESD/)"; 
  print "\n-help : display this message";

  print "\n\nNote that -bump cannot be combined with -bumppair\n"; 
  exit; 
}
  
sub report {
  ($a, @a) = @_; 
  print OSUM "\n[Error]: @a" if ($a==1); 
  print OSUM "\n[Warn]: @a" if ($a==2); 
  print OSUM "\n[Info]: @a" if ($a==3); 
  print "\n[Error]: @a" if ($a==1); 
  print "\n[Warn]: @a" if ($a==2); 
  print "\n[Info]: @a" if ($a==3); 
  exit if($a==1); 
}

sub showbump { 
  report ($info,"ESD Result Directory: $esddir\n");
  $tempd = ".tmpd"; 
  `rm -rf $tempd`  if (-d $tempd);
  mkdir $tempd; 

  if ($bump =~ /UNCONNECTED/) { 
    report ($err, "adsRpt/PG.ploc not found") if (! -f "adsRpt/PG.ploc"); 
    report ($info, "Input pad file : $ploc"); 
    report ($info, "Generating unconnected bump list"); 
    `grep -v ^\$ adsRpt/PG.ploc | grep -v ^\# | awk '{print \$1, \$2, \$3}' > $tempd/plc`; 
    `grep -v ^\$ $ploc | grep -v ^\# | awk '{print \$1, \$2, \$3}' > $tempd/iplc`; 
    %pdone = ();
    open F1, "$tempd/plc"; 
    while(<F1>) {
      chomp;
      split; 
      $pdone{$_[0]} = 1; 
    }
    close F1;
    open F1, "$tempd/iplc";
    open O1, "> bump_unconnected.list"; 
    open O2, "> bump_unconnected.plot"; 
    while(<F1>) { 
      chomp; 
      split; 
      if (!exists $pdone{$_[0]}) {
        print O1 "$_[0]\n";
        print O2 "marker add -position $_[1] $_[2] -color white\n";
      }
    }
    close F1; 
    close O1;
    close O2; 
    report ($info, "Refer to bump_unconnected.list for list of bumps");
    report ($info, "Source bump_unconnected.plot in RedHawk Gui to highlight these bumps\n");
    `rm -rf $tempd`;
    exit; 
  } 
  
  report ($err, "$esddir/esd_pass.rpt not found") if (! -f "$esddir/esd_pass.rpt"); 
  report ($err, "$esddir/esd_fail.rpt not found") if (! -f "$esddir/esd_fail.rpt"); 
  open F1, "$esddir/esd_pass.rpt"; 
  open O1, "> $tempd/pass"; 
  while(<F1>) { 
    if(/BEGIN_ESD_RULE/ .. /END_ESD_RULE/) { 
      $flag = 1; 
      if(($flag) && (/NAME/)) { 
        if(/$rule_name/) {
          $dflg = 1; 
        } else  {
          $dflg = 0; 
          $flag = 0; 
        } 
      }
    }

    if($dflg) { 
      print O1 $_; 
    }
  }
  close F1; 
  close O1; 
  
  open F1, "$esddir/esd_fail.rpt"; 
  open O1, "> $tempd/fail"; 
  while(<F1>) { 
    if(/BEGIN_ESD_RULE/ .. /END_ESD_RULE/) { 
      $flag = 1; 
      if(($flag) && (/NAME/)) { 
        if(/$rule_name/) {
          $dflg = 1; 
        } else  {
          $dflg = 0; 
          $flag = 0; 
        } 
      }
    }

    if($dflg) { 
      print O1 $_; 
    }
  }
  close F1; 
  close O1; 

  report ($err, "result processing failed 01") if (! -f "$tempd/pass"); 
  report ($err, "result processing failed 02") if (! -f "$tempd/fail"); 
  `grep ^BUMP $esddir/esd_pass.rpt | awk '{print \$3, \$4, \$5}' | awk -F \\( '{print \$2}' > $tempd/p `; 
  `grep ^BUMP $esddir/esd_pass.rpt | awk '{print \$9, \$10, \$11}' | awk -F \\( '{print \$2}' >> $tempd/p `; 
  `sort -u $tempd/p > $tempd/pb`; 
  `rm $tempd/p`;  
  `grep ^BUMP $esddir/esd_fail.rpt | awk '{print \$3, \$4, \$5}' | awk -F \\( '{print \$2}' > $tempd/f `; 
  `grep ^BUMP $esddir/esd_fail.rpt | awk '{print \$9, \$10, \$11}' | awk -F \\( '{print \$2}' >> $tempd/f`; 
  `sort -u $tempd/f > $tempd/f1`;  
  `rm $tempd/f`;
  `grep -v -f $tempd/pb $tempd/f1 > $tempd/fb`;
  `rm $tempd/f1`;

  if ($bump =~ /FAIL/) {
    report ($info, "Generating fail bump list"); 
    `awk '{print \$1}' $tempd/fb > bump_fail.list`;
    `awk '{print "marker add -position " \$2, \$3 " -color red"}' $tempd/fb > bump_fail.plot`;
     report ($info, "Refer to bump_fail.list for list of bumps");
     report ($info, "Source bump_fail.plot in RedHawk Gui to highlight these bumps");
  } elsif ($bump =~ /PASS/) { 
    report ($info, "Generating pass bump list"); 
    `awk '{print \$1}' $tempd/pb > bump_pass.list`;
    `awk '{print "marker add -position " \$2, \$3 " -color green"}' $tempd/pb > bump_pass.plot`;
     report ($info, "Refer to bump_pass.list for list of bumps");
     report ($info, "Source bump_pass.plot in RedHawk Gui to highlight these bumps");
  } elsif ( $bump =~ /(OUT_OF_RAD|NO_CLAMP)/) { 
    open F1, "$esddir/esd_info.rpt"; 
    open O1, "> $tempd/info"; 
    while(<F1>) { 
      if(/BEGIN_ESD_RULE/ .. /END_ESD_RULE/) { 
        $flag = 1; 
        if(($flag) && (/NAME/)) { 
          if(/$rule_name/) {
            $dflg = 1; 
          } else  {
            $dflg = 0; 
            $flag = 0; 
          } 
        }
      }

      if($dflg) { 
        print O1 $_; 
      }
    }
    close F1; 

    report ($err, "result processing failed 03") if (! -f "$tempd/info");
    if($bump =~ /NO_CLAMP/) {
       # ESD Check Bump List That's Not Connected to Clamps for Rule <B2B_r1> (BUMP2BUMP)
       $rdflg = 0; 
       open F1, "$tempd/info";
       open O1, ">$tempd/info1";
       while(<F1>) { 
         $rdflg = 1 if(/Not Connected to Clamps for Rule \<$rule_name\>/); 
         print O1 $_ if($rdflg); 
         $rdflg = 0 if(($rdflg) && (/\*/));
       }
       close F1; 
       close O1; 
       report ($info, "Generating bump having no clamp connection list"); 
      `awk '(NF==5){print \$1}' $tempd/info1 > bump_no_clamp.list`;
      `awk '(NF==5){print "marker add -position " \$2, \$3 " -color white"}' $tempd/info1 > bump_no_clamp.plot`;
       report ($info, "Refer to bump_no_clamp.list for list of bumps");
       report ($info, "Source bump_no_clamp.plot in RedHawk Gui to highlight these bumps");
    } else { 
       report ($info, "Generating list of bumps outside the radius"); 
      `grep ^PADS $tempd/info | awk '{print \$3, \$4, \$5}' > $tempd/r`; 
      `grep ^PADS $tempd/info | awk '{print \$6, \$7, \$8}' >> $tempd/r`; 
      `grep ^PADS $tempd/info | awk '{print \$3}' | awk -F \\( '{print \$1}' > $tempd/r1`; 
      `grep ^PADS $tempd/info | awk '{print \$6}' | awk -F \\( '{print \$1}' >> $tempd/r1`; 
      `awk '{print \$1}' $tempd/pb > $tempd/p1`; 
      `awk '{print \$1}' $tempd/fb > $tempd/f1`; 
      %bdone = (); 
      %bkeep = (); 
      open F1, "$tempd/p1"; 
      while (<F1>) { 
        chomp; 
        $bdone{$_} = 1; 
      }
      close F1; 
      open F1, "$tempd/f1"; 
      while (<F1>) { 
        chomp; 
        $bdone{$_} = 1; 
      }
      close F1; 
      open F1, "$tempd/r1"; 
      while (<F1>) { 
        chomp; 
        if (! exists $bdone{$_}) { 
          $bkeep{$_} = 1; 
        }
      }
      close F1; 
      #PADS 18 VSS_AR_0697(vssx_0) (9153.91 5854.15) VDD_AR_0734(vddmx_1) (9631.64 5698.6) 502.422
      %dup = (); 
      open F1, "$tempd/r"; 
      open O1, "> bump_out_of_rad.plot"; 
      open O2, "> bump_out_of_rad.list"; 
      while(<F1>){ 
        @a = split /\(/;
        @b = split /\)/, $a[2];
        if (exists $bkeep{$a[0]}) { 
          if ( ! exists $dup{$a[0]} ) { 
            $dup{$a[0]} = 1; 
            print O1 "marker add -position $b[0] -color blue\n"; 
            print O2 "$a[0]\n"; 
          }
        }
      }
      close F1; 
      close O1; 
      close O2; 
      report ($info, "Refer to bump_out_of_rad.list for list of bumps");
      report ($info, "Source bump_out_of_rad.plot in RedHawk Gui to highlight these bumps");
    }
  }
}

sub showpair {
  report ($info,"Reading esd directory: $esddir\n"); 

}

GetOptions ("rule_name=s" => \$rule_name,
            "rule_type=s" => \$rule_type,
            "bump=s" => \$bump, 
            "domain=s" => \$domain, 
            "pad_file=s"=> \$ploc, 
            "bumppair=s" => \$bpair,
            "esd_dir=s" => \$esddir,
            "help" => \$help );
            
print_usage if($help || (!$bump && !$bpair)); 

if($bump && $bpair) { 
  report ($err, "Both options -bump and -bumppair specified\nSpecify only one option\n");
  exit; 
}

$pair = 1 if($bpair); 

if($pair){
  report ($err, "Invalid option for -bumppair\n") if ($bpair !~ /(PASSING|FAILING|OUT_OF_RAD)/);
  report ($info, "Generating bumppair info\n"); 
  showpair;
  `rm -rf .tmpd`;
  print "\n";
} else { 
  report ($err, "Invalid option for -bump\n") if($bump !~ /(PASS|FAIL|NO_CLAMP|OUT_OF_RAD|UNCONNECTED)/);  
  if($bump =~ /UNCONNECTED/) { 
    report ($err, "The pad_file is not specified\n") if (!$ploc); 
  }
  report ($info, "Generating bump info\n"); 
  showbump; 
  `rm -rf .tmpd`;
  print "\n";
}


