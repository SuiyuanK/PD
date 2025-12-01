# $Revision: 1.2 $

#=====================================================================
# This simple script creates APL file from a waveform provided by user
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
Create APL file from PWL current profile
pwl2apl -cell_name <cell_name> -pwl <time1(sec)> <curr1(sec)> <time2(sec)> <curr2(sec)>
";

@VarList = ("help","cell_name","pwl");
edaGetOptions(\@ARGV,\%OptHash,\@VarList);
if (defined $OptHash{help}) {
  print $usage;
  exit;
}


@PWL = split(" ",$OptHash{"pwl"});
# Check legality of PWL
if (($#PWL % 2) == 0) {
  edaError("PWL must have even number of elements!");
}
if ($#PWL < 3) {
  edaError("PWL must have at least 2 timing points");
}

$cell_name = $OptHash{"cell_name"};

edaMsg("Generating apl file $cell_name.current");
edaOpenFile(APL, "$cell_name.current", "wf");

print APL "data_version cell.current 4v3
tool_name apl
version 4.3 rel 0B
Released Date: 01/11/2005
data_tag asc 1105497317 Tue Jan 11 18:35:17 2005
file_signature FF_g -40 1.1 -2144258590 00000000
50
";
$aplTxt = edaGenerateApl($cell_name,@PWL);
print APL "$aplTxt\n";
close APL;

edaMsg("
To verify created waveform: 
$script_installation_dir/plotApl.pl -apl_file $cell_name.current");


