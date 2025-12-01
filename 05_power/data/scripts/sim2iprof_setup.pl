# $Revision: 1.1 $

eval '(exit $?0)' && eval 'exec perl -S $0 ${1+"$@"}'
    && eval 'exec perl -S $0 $argv:q'
    if 0;

#==================================================================
# This script generates configuration file required for AVM characterization of memories
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
@VarList = ("vdd_pin","vss_pin","sim_dir","mcf_file","norun");

%VarProperties = ("vdd_pin,expl" => "VDD pin name probed in .OUT sim file",
                  "vss_pin,expl" => "VSS pin name probed in .OUT sim file",
		  "sim_dir,expl" => "Directory containing all memory cells' simulation OUT files ",
		  "sim_dir,example" => "sim_dir where sim_dir contains cell1/*.out, cell2/*.out",
	          "mcf_file,expl" => ".apache/apache.mcf file from Redhawk run directory. Default is ../../../setupAPL/.apache/apache.apl",
	 	  "mcf_file,optional" => 1,
		  "norun,expl" => "Run sim2iprof (on/off). Default off", 
                  "norun,optional" => 1

);

# Preset values of all required variables
foreach $var_name (@VarList) {
    $VarHash{$var_name} = "???";
}
# Defaults
$VarHash{mcf_file} = "../../../setupAPL/.apache/apache.mcf";
$VarHash{norun} = "off";

# If sim2iprof_setup.init file with previously defined variables exists -
# parse it first
# Every line has following syntax:
# <var_name> : <value1> <value2> ...
if (-r "sim2iprof_setup.init") {
  edaOpenFile(IN, "sim2iprof_setup.init", "r");
  while (<IN>) {
    chomp();
    @Line = split(" ",$_);
    $var_name = shift(@Line);
    shift(@Line);
    $VarHash{$var_name} = join(" ",@Line);
  }
  close IN;
}

#===============================================================================
# Usage info
sub usage {
  print "
SYNOPSIS
 Generates configuration file for running sim2iprof for conversion of memory .OUT files to Apache cell.current format 

DESCRIPTION
 sim2iprof_setup.pl generates the configuration file and runs sim2iprof

 Script accepts user options from 2 sources:
 a. from \$cwd/sim2iprof_setup.init file
 b. from command line arguments, which are saved as well in avm_setup.init by the script

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
edaOpenFile(OUT, "sim2iprof_setup.init", "wf");
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

edaOpenFile(OUT, "sim2iprof.conf", "wf");
@ls = `ls $VarHash{sim_dir}`;

$date = `date`;

print OUT "# sim2iprof configuration file generated by sim2iprof_setup.pl on $date\n\n";

print OUT "\nMCF_FILE $VarHash{mcf_file}\n\n";
print OUT "\nVDD_PIN $VarHash{vdd_pin}\n\n";
print OUT "VSS_PIN $VarHash{vss_pin}\n";
print OUT "\nSIM_FILE { \n";

$out_files_found = 0;
foreach $dir (@ls) {
        chomp($dir);
	$full_path = "$VarHash{sim_dir}"."/"."$dir";
        if ( -d $full_path ) {
		$cell_name = $dir;
                @files = <$dir/*.out>;
		$flag = 0;
                foreach $file (@files) {
			print OUT "$cell_name  $file\n";
			$flag = 1;
			$out_files_found = 1;
                }
		if($flag eq "0") {
		   print "ERROR:: Simulation files (*.out) not present in directory: $full_path\n";
		   system("\rm -f sim2iprof.conf");	
    		   next;
		   #exit(0);
		}
        }
}

print OUT "}\n\n";

if (($VarHash{norun} eq "off") && ($out_files_found == 1) ) {
  system("sim2iprof sim2iprof.conf");
}










