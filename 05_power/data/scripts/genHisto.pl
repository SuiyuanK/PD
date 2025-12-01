# $Revision: 1.7 $
################################################################
# (C) COPYRIGHT 2010 Apache Design Systems
# ALL RIGHTS RESERVED
#
#
#   $Date: 2010/12/08 21:55:42 $
#   $Revision: 1.7 $
#   $Id: genHisto.pl,v 1.7 2010/12/08 21:55:42 skim Exp $
#
#   Last Modified $Date: 2010/12/08 21:55:42 $
# 
#   $Log: genHisto.pl,v $
#   Revision 1.7  2010/12/08 21:55:42  skim
#   BugID:
#
#   Revision 1.6  2010/10/29 20:58:05  pritesh
#   updated header and temp file deletion
#
#
###############################################################
# Old header
# $Revision: 1.7 $

# Revision history
# Rev 1.5
# - Don't blindly assume, that first line is the header
# Rev 1.4
# - Bug fix. Some voltage bins were showing 0 instead of real
#   positive number of samples - due to Perl rounding error
# Rev 1.3
# - User can specify column by index
# - Bins with 0 samples are not skipped
# - All *.hist files are created in current dir ("/" is replaced with "_")
# Rev 1.2
# - Can process multiple dvd reports and show on the same plot
#   (file names can contain wildcards)
# - Automatically determines min and max voltages if not specified
#   by user
# - Clearer user options
# - Significantly faster
eval '(exit $?0)' && eval 'exec perl -S $0 ${1+"$@"}'
  && eval 'exec perl -S $0 $argv:q'
  if 0;

sub numerically {$a <=> $b;}

$usage = "
SYNOPSIS 
  Creates histogram of instance based voltage drop or any other tabulated file

DESCRIPTION
  genHisto.pl 
      -report_files <dvd_results_report>
      -min_voltage <lowest_voltage_bound>
      -max_voltage <highest_voltage_bound>
      -bin_size <volts> (default: 0.1)
      -field [name|index]
        a. index explicitly specifies the column number, count starts with 0
        b. following predefined names can be used for anaylis of 
           <design_name>.dvd (default: min_pg_sim):
           eff_Vdd, max_pg_tw, min_pg_tw, min_pg_sim, min_vdd, max_vss

 * You can type incomplete flags as long as they're inambiguous
 ** Wildcards are accepted for specification of report file names 

Example: 
 genHisto.pl -bin_size 0.02 -min_volt 1.2 -rep lcore_vctrls_*/adsRpt/Dynamic/*dvd

";
$script_installation_dir = dirname($0);
push(@INC,$script_installation_dir."/pm");

# Print Info Warnings and Errors by default
use vars qw(%GLOBAL_PARMS);
$GLOBAL_PARMS{VerboseLevel} = "W";
require "eda_utils.pm";
use File::Basename;


%Defaults = (	  
	     "min_voltage" => "automatic",
	     "max_voltage" => "automatic",
	     "bin_size" => 0.1,
	     "field" => "min_pg_sim");
@VarList = ("help","report_files","min_voltage","max_voltage","field","bin_size");

# Read in command line parameters
edaGetOptions(\@ARGV,\%OptHash,\@VarList);

if (defined $OptHash{help}) {
  print $usage;
  exit;
}

# If some of parameters are not defined - take default
foreach $var_name (@VarList) {
  if ((not defined $OptHash{$var_name}) and (defined $Defaults{$var_name})) {
    $OptHash{$var_name} = $Defaults{$var_name};
  }
}

# Print the value of all parameters
print "\n";
foreach $var_name (@VarList) {
  if ($var_name eq "help") {
    next;
  }
  $$var_name = $OptHash{$var_name};
  printf("%-30s  %10s\n", $var_name, $$var_name);
}

# Make sure, that at least one dvd report was specified
if (not defined $OptHash{report_files}) {
  edaError("No dynamic voltage drop report was defined!");
}

# Determine the column to pick from dvd report
%FieldName2Col = (
		  "eff_Vdd" => 2,
		  "max_pg_tw" => 3,
		  "min_pg_tw" => 4, 
		  "min_pg_sim" => 5, 
		  "min_vdd" => 6,
		  "max_vss" =>7);

# User explicitly set a coulmn to extract from
if ($field =~ m/^\d*$/) {
  $col = $field;
  edaMsg("Extracting data from column '$col'");
} else {  
  # Column number will be set by name 
  if (not defined $FieldName2Col{$field}) {
    edaError("There is no '$field' field in dvd report!");
  }
  $col = $FieldName2Col{$field};
  edaMsg("Extracting data from column '$col' - '$field'");
}


# Loop over all specified dvd reports files
$report_count = 0;
foreach $dvd_report (split(" ",$OptHash{report_files})) {
  $report_count++;
  edaOpenFile(DVD, "$dvd_report", "r");
  edaMsg("\nParsing $dvd_report...");
  
  # Retrieve data from one column of dvd report file
  %RoundedVoltagesCount = ();
  $line_count = 0;

  # Loop over all lines of the report file
  while (<DVD>) {
    # Skip empty and comment lines
    if (($_ =~ m/^\s*$/) or ($_ =~ m/^#/)) {
      next;
    }

    # Increment count if useful lines
    $line_count++;
 
    @temp=split;
    $voltage = $temp[$col];
    
    # skip if it's not a number
    if (!($voltage =~ m/^\d+/)) {
      next;
    }


    # floor voltage to assign to a bin
    # i.e all voltages in interval 1.4-1.4999.. will be converted to 1.4
    $rounded_voltage = (int($voltage/$bin_size))*$bin_size;
    $RoundedVoltagesCount{$rounded_voltage}++;
    
  }
  close DVD;

  # Determine start and stop voltages if they're automatic
  @Voltages = sort numerically (keys(%RoundedVoltagesCount));
  if ($min_voltage eq "automatic") {
    $min_voltage = $Voltages[0];
    print "min value: $min_voltage\n";
  }
  if ($max_voltage eq "automatic") {
    $max_voltage = $Voltages[-1];
    print "max value: $max_voltage\n";
  }

  print "\n*** Histogram ***\n";
  ($hist_file = $dvd_report) =~ s/\//_/g;
  $hist_file .= ".hist";
  edaOpenFile (OUT,$hist_file,"wf");

  # Something wrong with rounding in perl ... this is needed to print the last interval
  $max_voltage += 0.0001;

  for ($voltage = $min_voltage; $voltage < $max_voltage; $voltage += $bin_size) {
    # There was a very subtle problem related to perl numerical error
    # Need to round each voltage even though each step 
    # equal exactly one bin size
    $rounded_voltage = (int($voltage/$bin_size))*$bin_size;
    $next_voltage = $rounded_voltage + $bin_size;
    if (defined $RoundedVoltagesCount{$rounded_voltage}) {
      $count = $RoundedVoltagesCount{$rounded_voltage};
    } else {
      $count = 0;
    }

    print "$rounded_voltage - $next_voltage $count\n";

    print OUT "$rounded_voltage\t$count\n";
    print OUT "$next_voltage\t$count\n";
  }
  close OUT;
  print "*****************\nTotal number of lines $line_count\n";
  push(@HistFiles,$hist_file);

  
}

print "Showing histogram with:\nxgraph -tk -bg black -fg yellow -lw 3 @HistFiles\n";
system ("xgraph -tk -bg black -fg yellow -lw 3 @HistFiles");
system ("rm @HistFiles");
