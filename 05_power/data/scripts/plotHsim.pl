# $Revision: 1.1 $
eval '(exit $?0)' && eval 'exec perl -S $0 ${1+"$@"}'
    && eval 'exec perl -S $0 $argv:q'
    if 0;


# Print Warnings and Errors by default
use vars qw(%GLOBAL_PARMS);
$GLOBAL_PARMS{VerboseLevel} = "W";
use File::Basename;

# Put a directory with eda_utils.pm into search path
$script_installation_dir = dirname($0);
push(@INC,$script_installation_dir);
push(@INC,$script_installation_dir."/pm");

require "eda_utils.pm";

$usage = "
This script displays waveforms for chosen signals from HSIM/Nanosim simulation results in Apache signal viewer

Usage:
plotHsim.pl 
      -input <file_name> 
      -signal_names <signal1> <signal2> ...
      [-start_time <time_in_ns>]
      [-end_time <time_in_ns>]

Example:
plotHsim.pl -hsim_file muf4kx32.out -signal_names clk re we vdd -start_time 5
";



# Defaults 
$time_unit = "ns";
$start_time = 0;
$end_time = 1e10;

# Read command line parameters
@VarList = ("help","input","signal_names","start_time","end_time");
edaGetOptions(\@ARGV,\%OptHash,\@VarList);

if (defined $OptHash{help}) {
  print $usage;
  exit;
}

if (not defined $OptHash{input}) {
  edaError("Input file must be defined!");
}

if (defined $OptHash{start_time}) {
  $start_time = $OptHash{start_time};
}
if (defined $OptHash{end_time}) {
  $end_time = $OptHash{end_time};
}

foreach $signal_name (split(" ",$OptHash{signal_names})) {
  $ChosenSignals{$signal_name} = 1;
}


#==============================================
# loop through all lines of hsim file
#==============================================
$counter = 0;
open(IN, "$OptHash{input}");
edaMsg("Parsing $OptHash{input}...");
while(<IN>) {
  chomp;
  
  # Skip lines starting with ";:
  if ($_ =~ m/^;.*/) {
    next;
  }

  @Line = split(" ",$_);

  if ($Line[0] eq ".current_resolution") {
      $current_resolution = $Line[1];
      next;
  }
  if ($Line[0] eq ".voltage_resolution") {
      $voltage_resolution = $Line[1];
      next;
  }
  if ($Line[0] eq ".time_resolution") {
      $time_resolution = $Line[1];
      next;
  }
  if ($Line[0] eq ".bus_notation") {
    next;
  }

  # 1. If it's a declaration of a signal
  #------------------------------------------
  if ($Line[0] eq ".index") {
    $signal_name = $Line[1];
    # There may be i(...) and v(...) for the same net/pin
    ($net_name = $signal_name) =~ s/(.*\()(.*)(\))/$2/;
    
    $signal_id = $Line[2];
    $signal_type = $Line[3];


    # Skip signal is not included in user-given list
    if (not defined $ChosenSignals{$net_name}) {
      next;
    }
    # Skip signal if not marked as voltage or current
    if (($signal_type ne "v") && ($signal_type ne "i")) {
      next;
    }

    $SignalHash{$signal_id,signal_name} = $signal_name;
    $SignalHash{$signal_id,net_name} = $net_name;
    $SignalHash{$signal_id,signal_type} = $signal_type;
    push(@SignalID, $signal_id);
    #print "$signal_name->$net_name->$signal_id\n";
    next;
  }


  #2. If line contains only one number - it's a time stamp
  #--------------------------------------------------------
  if ($#Line == 0) {
    $time = $Line[0]*$time_resolution;
    next;
  }

  # Check if we're withing the time range
  if ($time < $start_time) {
    next;
  }
  if ($time > $end_time) {
    last;
  }
  
  if ($#Line > 1) {
    print "Can't parse line: '$_'!\n";
  }

  # 3. If there are 2 numbers on the line - it's a measurement
  #-----------------------------------------------------------
  $signal_id = $Line[0];
  # If it's not one of the requested indexes - skip it
  if (not defined $SignalHash{$signal_id,signal_name}) {
    next;
  }

  # If it's one of the requested indexes - record it
  push(@{$SignalHash{$signal_id,"time"}},$time); 
  if ($SignalHash{$signal_id,signal_type} eq "v") {
    $value = $Line[1]*$voltage_resolution;
  } else {
    $value = $Line[1]*$current_resolution;
  }

  push(@{$SignalHash{$signal_id,"values"}},$value);

}
close(IN);

# The absolute last time point
$latest_sim_time = $time;

#######################################################
# Create output .ta0 files
#######################################################
rmtree(".plot_hsim");
mkdir(".plot_hsim");

foreach $signal_id (@SignalID) {
  $signal_name = $SignalHash{$signal_id,signal_name};
  @Time = @{$SignalHash{$signal_id,"time"}};
  @Values = @{$SignalHash{$signal_id,"values"}};
  if ($#Time<0) {
    edaMsg("Signal $signal_name doesn't have any data points in the given timing range","W");
    next;
  }
  
  if ($Time[-1] < $latest_sim_time) {
    push (@Time,$latest_sim_time);
    push (@Values,$Values[-1]);
  }
  $num_of_points = $#Time+1;
  
  edaOpenFile(OUT, ".plot_hsim/$signal_name.ta0", "w");


  print OUT "Title: tabulated curve from $source
Date: Fri Dec 13 18:43:54 2002
Plotname: Transient Analysis
Flags: real
No. Variables: 2
No. Points: $num_of_points
Command: version 3f5
Variables:
        0       Time(ns)    time
        1       $signal_name v
Values:
";

  for ($count=0; $count<$num_of_points; $count++) {
    print OUT "$count\t$Time[$count]\n\t$Values[$count]\n";
  }

  close OUT;
}

system("sv .plot_hsim/*");
rmtree(".plot_hsim");
