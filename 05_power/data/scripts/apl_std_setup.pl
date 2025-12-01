# $Revision: 1.1 $

eval '(exit $?0)' && eval 'exec perl -S $0 ${1+"$@"}'
    && eval 'exec perl -S $0 $argv:q'
    if 0;

#==================================================================
# This script performs APL current and capacitance characterization for all std. cells 
#==================================================================

# Revision history


# Put a directory with eda_utils.pm into search path
$script_installation_dir = dirname($0);
push(@INC,$script_installation_dir);
push(@INC,$script_installation_dir."/pm");


# Print Warnings and Errors by default
use vars qw(%GLOBAL_PARMS);
$GLOBAL_PARMS{VerboseLevel} = "W";
require "eda_utils.pm";
use File::Basename;

#--------------------------------------------------------------------

# Here is array of all variables
@VarList = ("vdd_value","vdd_pin","vss_pin","temperature","spice_netlist","device_model","corner","rise_slew_threshold","fall_slew_threshold","gsr_file","apl_setup_dir","cell_list");

%VarProperties = ("vdd_value,expl" => "Value of supply voltage",
		  "vdd_pin,expl" => "Name of the VDD pin in SPICE netlist",
		  "vss_pin,expl" => "Name of the VSS pin in SPICE netlist",
		  "temperature,expl" => "Analysis temperature in C",
		  "spice_netlist,expl" => "List of SPICE netlist files",
 	          "device_model,expl" => "File containing device model library",
		  "corner,expl" => "Analysis corner",
		  "corner,example" => "SS",
		  "corner,optional" => 1, 
		  "rise_slew_threshold,expl" => "Rise slew thresholds used in STA",
		  "rise_slew_threshold,example" => "0.25 0.55",
		  "fall_slew_threshold,expl" => "Rise slew thresholds used in STA",
                  "fall_slew_threshold,example" => "0.45 0.75",
		  "gsr_file,expl" => "GSR file used for analysis",
		  "gsr_file,optional" => 1,
		  "apl_setup_dir" => "RedHawk run directory with APL setup",
	          "apl_setup_dir,optional" => 1,
		  "cell_list,expl" => "List of cells to be characterized",
		  "cell_list,optional" => 1
);

# Preset values of all required variables
foreach $var_name (@VarList) {
    $VarHash{$var_name} = "???";
}
# Defaults
#$VarHash{gsr_file} = "../../../design_data/design.gsr";  
$VarHash{apl_setup_dir} = "../../../setupApl";
#$VarHash{fall_slew_threshold} = "default";

# If apl_std_setup.init file with previously defined variables exists -
# parse it first
# Every line has following syntax:
# <var_name> : <value1> <value2> ...
if (-r "apl_std_setup.init") {
  edaOpenFile(IN, "apl_std_setup.init", "r");
  while (<IN>) {
    chomp();
    @Line = split(" ",$_);
    $var_name = shift(@Line);
    shift(@Line);
    $VarHash{$var_name} = join(" ",@Line);
  }
  close IN;
}

#if (-r "$VarHash{gsr_file}") {
#  edaOpenFile(IN, "$VarHash{gsr_file}", "r");
#  $start = 0;
#  while(<IN>) {
#        if($start == 1) {
#                split;
#                $VarHash{vdd_value} = $_[1];
#                $start = 0;
#        }
#
#        if(/VDD_NETS/) {
#                $start = 1;
#        }
#  }
#  close IN;
#}

#===============================================================================
# Usage info
sub usage {
  print "
SYNOPSIS
 Performs APL and APLCAP characterization of std. cells in the design 

DESCRIPTION
 apl_std_setup.pl generates the configuration file required for APL 
 and runs APL to generate cell.current and cell.cdev

 Script accepts user options from 2 sources:
 a. from \$cwd/apl_std_setup.init file
 b. from command line arguments, which are saved as well in extract_gds.init by the script

 Input to the script is incremental. The user may invoke the script with one or more options, then re-invoke the script adding more information, until all required information is complete. The user may add optional information at any time.

OPTIONS
";

  foreach $var (@VarList) {
    $var_expl = $VarProperties{$var.",expl"};
    $var_example = $VarProperties{$var.",example"};
    if (defined $VarProperties{$var.",default"}) {
      $var_default = $VarProperties{$var.",default"};
    } else {
      $var_default = "none";
    }
    print "  -$var\n    $var_expl\n";
  }
} # End of usage routine

# Read in command line variables
# * Catch the corner case if the very first argument doesn't start with "-"
if (@ARGV && !($ARGV[0] =~ m/^-/)) {
  edaError("Flag $ARGV[0] is illegal!");
}

while(@ARGV) {
  $arg = shift(@ARGV);
  # If current argument starts with "-", it's a name of the parameter
  if ($arg =~ m/^-/) {
    if ($arg eq "-h") {
      usage();
      exit(0);
    }
    ($var_name = $arg) =~ s/^-//;
    if (edaInArray($var_name,\@VarList) < 0) {
      edaError("Flag $arg is illegal!");
    }
    $VarHash{$var_name} = "";
    next;
  }

  # If not - it's a value of the parameter - store or append it


  if ($VarHash{$var_name} eq "") {
    $VarHash{$var_name} = $arg;
  } else {
    $VarHash{$var_name} .= " $arg";
  }
}

# Print all parameters with their values
# Check if all parameters were defined by the user
# Save all currently defined parameters in the extract_gds.init file
$all_parms_defined_flag = 1;
edaOpenFile(OUT, "apl_std_setup.init", "wf");
print "----------------------------------------------------------------\n option      | values\n----------------------------------------------------------------\n";
foreach $var (@VarList) {
  print OUT "$var : $VarHash{$var}\n";

  # If value is too long (too many files) , print only a portion
  if (length($VarHash{$var}) > 120) {
      printf("%-12s | %s...", -$var, substr($VarHash{$var},0,120));
  } else {
      printf("%-12s | %s", -$var, $VarHash{$var});
  }
  if (($VarHash{$var} eq "???") || ($VarHash{$var} eq "")) {
    if (defined $VarProperties{$var.",optional"}) {
      print " (optional)";
    } else {
      print " (REQUIRED)";
      $all_parms_defined_flag = 0;
    }
    if (defined $VarProperties{$var.",example"}) {
      $var_example = $VarProperties{$var.",example"};
      print "  Ex: $var_example";
    }
  }
  print "\n";
}
close OUT;
print "----------------------------------------------------------------\n";

if ($all_parms_defined_flag == 0) {
  edaError("Some of the required parameters were not defined!");
}

edaOpenFile(OUT, "apl.conf", "wf");

print OUT "\nVDD $VarHash{vdd_value}\n";
print OUT "\nVDD_PIN_NAME $VarHash{vdd_pin}\n";
print OUT "GND_PIN_NAME $VarHash{vss_pin}\n";
print OUT "\nTEMP $VarHash{temperature}\n";
print OUT "\nSPICE_NETLIST $VarHash{spice_netlist}\n";
if ( ($VarHash{corner} eq "???") || ($VarHash{corner} eq "") ) { 
  print OUT "\nINCLUDE $VarHash{device_model}\n";
} else {
  print OUT "\nDEVICE_MODEL_LIBRARY $VarHash{device_model} $VarHash{corner}\n";
}
print OUT "\nREDHAWK_WORKING_DIRECTORY ./\n";
print OUT "\nRISE_SLEW_THRESHOLD $VarHash{rise_slew_threshold} \n";
print OUT "FALL_SLEW_THRESHOLD $VarHash{fall_slew_threshold} \n\n";

close OUT;

if ( !( -d ".apache" ) ) {
   system("mkdir .apache");
}

if ( !(-r "$VarHash{apl_setup_dir}/.apache/apache.apl") ) {
  edaError("Missing APL setup file : $VarHash{apl_setup_dir}/.apache/apache.apl\n");
}

if ( !(-r "$VarHash{apl_setup_dir}/.apache/adsLib.output") ) {
  edaError("Missing APL setup file : $VarHash{apl_setup_dir}/.apache/adsLib.output\n");
}

system("cp $VarHash{apl_setup_dir}/.apache/apache.apl .apache/");
system("cp $VarHash{apl_setup_dir}/.apache/adsLib.output .apache/");

edaOpenFile(OUT, "apl_cell.list", "wf");
edaOpenFile(IN, ".apache/apache.apl", "r");

while(<IN>) {
  if(/{/) {
    split;
    print OUT "$_[0]\n";
  }	
}
close IN;
close OUT;

print STDOUT "\nGenerated APL configuration file: apl.conf\nGenerated cell list file: apl_cell.list\n";



#if ( ($VarHash{cell_list} eq "???") || ($VarHash{cell_list} eq "") ) {
#  if ( !(-r "$VarHash{apl_setup_dir}/std.list") ) {
#    edaError("Missing APL cell list file: $VarHash{apl_setup_dir}/std.list\n");
#  }
#   if ( !(-r "apl_cell.list") ) {
#  system("cp $VarHash{apl_setup_dir}/std.list ./");
#  
#
#}




