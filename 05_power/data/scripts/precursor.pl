# $Revision: 2.2 $

#=====================================================================
# This script creates precursor summary from internal and output files provided by user
#=====================================================================
eval '(exit $?0)' && eval 'exec perl -S $0 ${1+"$@"}'
  && eval 'exec perl -S $0 $argv:q'
  if 0;

# Put a directory with eda_utils.pm into search path
# eda_utils.pm ca be either in the current dir or in /pm
$script_installation_dir = dirname($0);
push(@INC,$script_installation_dir);
push(@INC,$script_installation_dir."/pm");

# Print Info Warnings and Errors by default
use vars qw(%GLOBAL_PARMS);
$GLOBAL_PARMS{VerboseLevel} = "W";
require "eda_utils.pm";
use File::Basename;
$revision = edaGetScriptRevision($0);

$usage = "
Create precursor summary of cell instance
precursor -o <output_file> -i <Reff_file> <switchFile> ?<original_run_dir>?
";

@VarList = ("help","o","i");
edaGetOptions(\@ARGV,\%OptHash,\@VarList);
if (defined $OptHash{help}) {
  print $usage;
  exit;
}

@IN_FILE = split(" ",$OptHash{"i"});
# Check number of files
if ($#IN_FILE < 1) {
  edaError("At least 2 files <Reff_file> <switchFile> must be given with -i");
}

$out_file = $OptHash{"o"};
if ($out_file eq "") {
  $out_file = "precursor.txt";
}

$reff_file = $IN_FILE[0];
$switch_file = $IN_FILE[1];
$run_dir = "./";
if ($#IN_FILE > 1) {
  $run_dir = $IN_FILE[2];
}

#====================================
edaMsg("Generating precursor file \"$out_file\" ...");

my %instHash;

edaMsg("Reading res_calc result...\n");
edaOpenFile(REFF_IN, $reff_file, "r");
$r_idx = 0;
$inst_idx = 5;
$pin_idx = 6;
while (<REFF_IN>) {
  chomp();
  if ($_ =~ /^#/ or $_ =~ /^$/) {
    if ($. == 5) {
      @Line = split("\t",$_);
      $offset = 0;
      for my $i (0 .. $#Line) {
        if ($Line[$i] =~ /Ohm$/) {
          $r_idx = $i + $offset;
        } elsif ($Line[$i] eq "Instance") {
          $inst_idx = $i + $offset;
        } elsif ($Line[$i] eq "Pin") {
          $pin_idx = $i + $offset;
        } elsif ($Line[$i] =~ /^Location/) {
          $offset += 1;
        }
      }
    }
  } else {
    @Line = split("\t",$_);
    $inst_name = $Line[$inst_idx];
    $pin_name = $Line[$pin_idx];
    $r_value = $Line[$r_idx];
    $instHash{$inst_name} = [ ($r_value, $pin_name, 0, -1, -1, -1) ];
  }
}
close REFF_IN;

edaMsg("Reading switching file...\n");
edaOpenFile(SW_IN, $switch_file, "r");
while (<SW_IN>) {
  chomp();
  if ($_ =~ /^#/ or $_ =~ /^$/) {
  } else {
    $inst_name = $_;
    if (exists $instHash{$inst_name}) {
      $instHash{$inst_name}[2] = 1;
    }
  }
}
close SW_IN;

edaMsg("Reading inst power report...\n");
opendir(DIR, $run_dir);
@power_dirs = grep(/^adsPower/,readdir(DIR));
closedir(DIR);
foreach $power_d (@power_dirs) {
  opendir(DIR, "$run_dir/$power_d");
  @files = grep(/\.nets\.adsLib\.power$/i,readdir(DIR));
  closedir(DIR);

  foreach $file (@files) {
    edaOpenFile(PW_IN, "$run_dir/$power_d/$file", "r");
    while (<PW_IN>) {
      chomp();
      if ($_ =~ /^#/ or $_ =~ /^\$/) {
      } else {
        ($inst_name, $cell_name, undef, undef, $f_value, undef) = split(" ",$_,6);
        if (exists $instHash{$inst_name}) {
          $instHash{$inst_name}[3] = $cell_name;
          $instHash{$inst_name}[4] = $f_value;
        }
      }
    }
    close PW_IN
  }
}

edaMsg("Reading current profile...\n");
$tmpDir = "$run_dir/.apache";
if (-e "$run_dir/.apache.1") {
  $tmpDir = "$run_dir/.apache.1";
}
opendir(DIR, $tmpDir);
@hier_files = grep(/^apache\.hier\..*gz$/i,readdir(DIR));
closedir(DIR);
foreach $h_file (@hier_files) {
  @word_list = split(/[.]/, $h_file);
  $index = "";
  if ($#word_list > 2) {
    $index = "\.$word_list[2]";
  }
  $h_file = "$tmpDir/$h_file";
  $idx_file = "$tmpDir/apache.apl_idx$index";

  @id2instArray = ();
  %id2instHash = ();
  push @id2instArray, "dummy";
  edaOpenFile(H_IN, "$h_file", "r");
  $read_hier = 1;
  while (<H_IN>) {
    chomp();
    if ($_ =~ /^#/ or $_ =~ /^$/) {
      if ($_ =~ /^#END HIERARCHY/) {
        $read_hier = "";
      }
    } else {
      ($word1, $word2) = split(" ",$_);
      if ($read_hier) {
        push @id2instArray, $word2;
      } else {
        $inst_id = $word1;
        $inst_name = $word2;
        if ($inst_name =~ /^\$/) {
          $inst_name =~ s/^.//s ;
          @nameList = split('/', $inst_name);
          $inst_name = "$id2instArray[$nameList[0]]\/$nameList[1]";
        }

        if (exists $instHash{$inst_name}) {
          $id2instHash{$inst_id} = $inst_name;
        }
      }
    }
  }
  close H_IN;

  edaOpenFile(IDX_IN, "$idx_file", "r");
  while (<IDX_IN>) {
    chomp();
    if ($_ =~ /^#/ or $_ =~ /^$/) {
    } else {
      ($inst_id, $idx) = split(" ",$_);
      if (exists $id2instHash{$inst_id}) {
        $inst_name = $id2instHash{$inst_id};
        $instHash{$inst_name}[5] = $idx;
      }
    }
  }
  close IDX_IN;
}

opendir(DIR, $run_dir);
@a_dirs = grep(/^\.apache/,readdir(DIR));
closedir(DIR);
%peakHash = ();
foreach $apache_d (@a_dirs) {
  $peak_dir = "$run_dir/$apache_d/APLdump_index";
  if (-e $peak_dir and -d $peak_dir) {
  } else {
    next;
  } 
  opendir(DIR, "$peak_dir");
  @files = readdir(DIR);
  closedir(DIR);
  foreach $file (@files) {
    edaOpenFile(PEAK_IN, "$peak_dir/$file", "r");
    $line = <PEAK_IN>;
    $cell_name = "";
    while($line) {
      chomp($line);
      $cell_name = $line;
      $peakHash{$cell_name} = {};

      while($line = <PEAK_IN>) {
        chomp($line);
        @Line = split(" ",$line);
        if ($#Line < 1) {
          last;
        } elsif ($#Line > 1) {
          $pin_name = $Line[1];
          $pin_name =~ s/.*=//;
          $i_value  = $Line[2];
          $i_value  =~ s/.*=//;
          if (exists $peakHash{$cell_name}{$pin_name}) {
          } else {
            @{$peakHash{$cell_name}{$pin_name}} = (0);
          }
          push @{$peakHash{$cell_name}{$pin_name}}, abs($i_value*1e-6); 
        }
      }
    }
    close PEAK_IN
  }
}

my @reslist = ();
edaMsg("Prepare final report...\n");
edaOpenFile(OUT, "$out_file", "wf");
print OUT "#Inst_name Switching Frequency Ipeak Reff Ipeak*Reff\n";
while(($key, $value) = each(%instHash)) {
  $cell_name = @{$value}[3];
  $pin_name = @{$value}[1];
  $idx = @{$value}[5];
  $i_peak = -1;
  if (exists $peakHash{$cell_name}{$pin_name}) {
    $i_peak = $peakHash{$cell_name}{$pin_name}[$idx];
  }
  my $swi = "";
  if (@{$value}[2]) {
    $swi = "True";
  } else {
    $swi = "False";
  }

  $freq = @{$value}[4];
  $Reff = @{$value}[0];
  $multi = $Reff * $i_peak;
  push @reslist, "$key $swi $freq $i_peak $Reff $multi";
}
my @sorted = sort { (split(' ', $b))[5] <=> (split(' ', $a))[5] } @reslist;
foreach (@sorted) {
  print OUT "$_\n";
}
close OUT;

edaMsg("Success.");

#===================================
