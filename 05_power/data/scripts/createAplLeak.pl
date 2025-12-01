# $Revision: 2.2 $

#=====================================================================
# This script creates apl leakage file from power calc and equationfiles provided by user
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
Create apl leakage file cells
createAplLeak -o <output_file> -temp <analysis_T> <from_T> <to_T> -i <equation_file> ?<original_run_dir>?
";

@VarList = ("help","o","i","temp");
edaGetOptions(\@ARGV,\%OptHash,\@VarList);
if (defined $OptHash{help}) {
  print $usage;
  exit;
}

@IN_FILE = split(" ",$OptHash{"i"});
# Check number of files
if ($#IN_FILE < 0) {
  edaError("equation parameter file must be given with -i");
}

$out_file = $OptHash{"o"};
if ($out_file eq "") {
  $out_file = "cell.leak";
}

$equation_file = $IN_FILE[0];
$run_dir = "./";
if ($#IN_FILE > 0) {
  $run_dir = $IN_FILE[1];
}

@TEMP_R = split(" ",$OptHash{"temp"});
# Check number of files
if ($#TEMP_R < 2) {
  edaError("analysis temperature, start and end temperature must be given");
}

$a_temp = $TEMP_R[0];
$from_temp = $TEMP_R[1];
$to_temp = $TEMP_R[2];
$t_size = 4;
$step = ($to_temp - $from_temp)/$t_size;

#====================================
edaMsg("Generating apl leak file \"$out_file\" ...");

my %cellHash;
opendir(DIR, $run_dir);
@power_dirs = grep(/^adsPower/,readdir(DIR));
closedir(DIR);
foreach $power_d (@power_dirs) {
  opendir(DIR, "$run_dir/$power_d");
  @files = grep(/\.nets\.adsLib\.power$/i,readdir(DIR));
  closedir(DIR);

  foreach $file (@files) {
    edaOpenFile(PW_IN, "$run_dir/$power_d/$file", "r");
    $line = <PW_IN>;
    $line = <PW_IN>;
    $cell_name = "";
    $skip_inst = 1;
    while (<PW_IN>) {
      chomp();
      if ($_ =~ /^#/ or $_ =~ /^$/) {
      } elsif ($_ =~ /^\$/) {
        if ($skip_inst) {
          next;
        }
        @field = split /\s+/, $_;
        $pin_name = $field[1];
        $domain_name = $field[2];
        $leakcurrent = $field[13];
        push @{$cellHash{$cell_name}}, $pin_name;
        push @{$cellHash{$cell_name}}, $leakcurrent;
      } else {
        ($inst_name, $cell_name, $cell_type, undef) = split(" ",$_,4);
        if (exists $cellHash{$cell_name}){
          $skip_inst = 1;
        } else{
          push @{$cellHash{$cell_name}}, $cell_type;
          $skip_inst = 0;
        }
      }
    }
    close PW_IN;
  }
}


edaOpenFile(OUT, "$out_file", "wf");
print OUT "data_version TMPDIRMERGERESULT 5v3
tool_name aplleak rail_slew
version 1.0 rel 0A
Released Date: 08/31/2018
data_tag rem atclExec createAplLeak
file_signature XX $from_temp 1.8 2838199766 000000 XX slew_threshold 0.3 0.7 ACCURATE\n";
$size = keys %cellHash;
$size += 1;
print OUT "cell_temp $size 5\n";
$t_p = $from_temp;
for my $i (0 .. $t_size) {
  print OUT "$t_p ";
  $t_p += $step;
}
print OUT "\n";

edaOpenFile(EQ_IN, "$equation_file", "r");
while(<EQ_IN>) {
  chomp();
  if ($_ =~ /^#/ or $_ =~ /^$/) {
    next;
  }
  ($word, $para) = split(" ",$_,2);

  @matches = grep $word, keys %cellHash;
  for my $key (@matches) {
    $value = $cellHash{$key};
    @inhash = @$value;
    $cell_t = $inhash[0];
    my $size = @inhash;
    $size = int(($size-1)/2);
    if ($size < 1) {
      next;
    }

    print OUT "$key $cell_t $size";
    for my $i (1..$size) {
      print OUT " $inhash[$i*2-1]";
      $t_p = $from_temp;
      $leak = $inhash[$i*2];
      for my $i (0 .. $t_size) {
        $new_l = $leak * exp($para*($t_p - $a_temp)); 
        $new_l = sprintf "%.6g", $new_l ;
        print OUT " $t_p $new_l $new_l";
        $t_p += $step;
      }
    }
    print OUT "\n";
    delete $cellHash{$key};
  }
}

close EQ_IN;
close OUT;
edaMsg("Success.");

#===================================
