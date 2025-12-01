# $Revision: 2.2 $

eval '(exit $?0)' && eval 'exec perl -S $0 ${1+"$@"}'
    && eval 'exec perl -S $0 $argv:q'
    if 0;

#==================================================================
# This script performs "vanilla" gds2def extraction of multiple
# macros from multiple gds files
#==================================================================
# Revision history
# Rev 2.2
# - The script generates a top levek pass/fail report
# Rev 2.1
# - The script now supports lsf option to run the gds2def and corresponding switches are bsub_run and bsub_command_file
#  Rev 2.0
# - Consolidated gds_setup.pl and extract_gds.pl to one script. Retired old extract_gds.pl
# - killed mcf option
# - Command lines parameters can be abbreviated as in rh_setup
# - If cell names are not specified, try to extract all MACRO names whose CLASS != CORE
#   found in all lef fils
# - Support composite net name definition to support lef<->gds name mapping
# - Retired -lef_dir and -gds_dir. Use -lef_files and -gds_files with * as in rh_setup  
# Rev 1.6 (by bthudi Fri Jun 24 14:21:21 PDT 2005)
# - mem option for running 'gds2def -m'
# Rev 1.5
# - Check that gds2def utility is there
# - better help
# Rev 1.4
# - Parametrized GDS prefix
# Rev 1.3
# - Fixed bugs and made support of possible naming difference between GDS and LEF more generic 
#   and robust 
# Rev 1.2
# - Scan input lef files and check if each specified cell appears as MACRO 
# - Can handle cases when cell name has different cases in lef and gds
# - Create a modified copy of the lef file if gds cell name differs from the lef one
# - norun option


# Put a directory with eda_utils.pm into search path
$script_installation_dir = dirname($0);
push(@INC,$script_installation_dir);
push(@INC,$script_installation_dir."/pm");


# Print Warnings and Errors by default
use vars qw(%GLOBAL_PARMS);
$GLOBAL_PARMS{VerboseLevel} = "W";
require "eda_utils.pm";
use File::Basename;


# Here is array of all variables
@VarList = ("vdd_nets","vss_nets","cell_names","map_file","lef_files","gds_files","mem","start_layer","core_start_layer","options_file","bsub_command_file", "norun","bsub_run");

%VarProperties = ("map_file,expl" => "GDS layer map file",
		  "vdd_nets,expl" => "VDD net names separated with ',' Multiple GDS labels can map to a single VDD net",
		  "vdd_nets,example" => "'VDD vdda vddb, VDD_SOC' - segments labeled in GDS with 'vdda' and 'vddb' will appear as 'VDD' in generated def file. 'VDD_SOC' will bot be renamed",
	          "vss_nets,expl" => "VSS net names. Same syntax as VDD", 	

		  "start_layer,expl" => "Extraction starting layer",
		  "start_layer,example" => "m1",
		  "start_layer,optional" => 1,

	          "core_start_layer,expl" => "Core extraction starting layer", 
		  "core_start_layer,example" => "m3",
		  "core_start_layer,optional" => 1,

		  "cell_names,expl" => "List of cell names for GDS conversion or name of the file where cells are listed",
		  "cell_names,optional" => 1,

	 	  "gds_files,expl" => "GDS files to be extracted",
		  "gds_files,default" => "../gds/*.gds",

                  "lef_files,expl" => "LEF files of macros to be extracted",
		  "lef_files,default" => "../lef/*.lef",
		  "norun,expl" => "Setting to 'on' will stop the script after creation of config files ",
		  "norun,optional" => 1,
		  "norun,default" => "off",
		  "bsub_run,expl" => "Setting to 'on' will use bsub option to run gds2def ",
		  "bsub_run,optional" => 1,
		  "bsub_run,default" => "off",
		  "mem,expl" => "Run gdsmem  (on/off)",
		  "mem,optional" => 1,
		  "mem,default" => "off",
                  "options_file,optional" => 1,
                  "options_file,expl" => "File containing list of additional gds2def options to use",
                  "bsub_command_file,optional" => 1,
                  "bsub_command_file,expl" => "File containing bsub options"
);

# Preset values of all required variables
foreach $var_name (@VarList) {
  if (defined $VarProperties{$var_name.",default"}) {
    if (($var_name eq "lef_files") || ($var_name eq "gds_files")) {
      $key = $var_name.",default";
      $VarHash{$var_name} = join(" ",glob($VarProperties{$key}));
    } else {
      $VarHash{$var_name} = $VarProperties{$var_name.",default"};
    } 
  } else {
    $VarHash{$var_name} = "???";
  }
}



# If gds_setup.init file with previously defined variables exists -
# parse it first
# Every line has following syntax:
# <var_name> : <value1> <value2> ...
if (-r "gds_setup.init") {
  edaOpenFile(IN, "gds_setup.init", "r");
  while (<IN>) {
    chomp();
    @Line = split(" ",$_);
    $var_name = shift(@Line);
    shift(@Line);
    $VarHash{$var_name} = join(" ",@Line);
	
  }
  close IN;
}



if ($ARGV[0] =~ m/^-h/) {
  usage();
  exit;
}

# Read command-line arguments
edaGetOptions(\@ARGV,\%VarHash,\@VarList);

# Print all parameters with their values
# Check if all parameters were defined by the user
# Save all currently defined parameters in the gds_setup.init file
$all_parms_defined_flag = 1;
edaOpenFile(OUT, "gds_setup.init", "wf");
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



# Check that all required parameters were defined
if ($all_parms_defined_flag == 0) {
  edaError("Some of the required parameters were not defined!");
}

# Check that all files exist and readable
edaCheckInputFiles($VarHash{gds_files},$VarHash{map_file});
edaCheckInputFiles($VarHash{lef_files}) if ($VarHash{lef_files} ne "???");
edaCheckInputFiles($VarHash{gds_files}) if ($VarHash{gds_files} ne "???");

# Check, that gds2def utility is available
if (! -e "$ENV{APACHEROOT}/bin/gds2def") {
  edaError("gds2def utility can't be found! Check your RedHawk installation");
}

# If cell_names is really a file listing cells to extract
if (($VarHash{cell_names} ne "???") && (-r $VarHash{cell_names})) {
  edaOpenFile(IN,$VarHash{cell_names}, "r");
  edaMsg("Reading cell names from $VarHash{cell_names}...");
  $CellNames = "";
  while (<IN>) {
    chomp;
    $CellNames .= "$_ ";
  }
  close IN;
  if ($CellNames eq "") {
    edaError("No cell names found in file list '$VarHash{cell_names}'!");
  }
  $VarHash{cell_names} = $CellNames;
}

# Scan gds files, create cross-reference table (in which file each string is found)
foreach $gds_file (edaConvert2List($VarHash{gds_files})) {
    edaMsg("Scanning $gds_file ...");
    $ALL_STRINGS = `strings $gds_file`;
    foreach $string (split("\n",$ALL_STRINGS)) {
	$AllGdsStrings{$string} = $gds_file;

	# Provide translation table for case-insensitive search
	$string_lowcase = lc($string);
	$AllGdsStringsInLowcase{$string_lowcase} = $string;
      }
}

# Scan lef files create cross-reference table for MACROS
edaMsg("Scanning lef files...");
*LefHash = edaCreateMacroHashFromLefFiles(edaConvert2List($VarHash{lef_files}));

# Autodetection of maro names (little clumsy) if user didn't specify
if (($VarHash{cell_names} eq "???") || ($VarHash{cell_names} eq "")) {
  $VarHash{cell_names} = "";
  foreach $cell_name (keys %LefHash) {
    if (!($cell_name =~ m/file$/)) {
      if ($LefHash{$cell_name} ne "CORE") {
	$VarHash{cell_names} .= "$cell_name ";
     }
    }
  }

  edaMsg("Following macros names were detected: $VarHash{cell_names}");
  #$LefHash{$cell_name,"file"}
}
print "\n";



#===================================================================
# Create config files for all memories
#===================================================================
foreach $cell_name (edaConvert2List($VarHash{cell_names})) {

  # Check, that cell is declared as MACRO in one of the lef files
  if (defined $LefHash{$cell_name,"file"}) {
    edaMsg("Cell '$cell_name' is found in $LefHash{$cell_name,'file'} - OK");
  } else {
    edaMsg("Cell '$cell_name' is not found in specified lef files! Skipping it...\n","E");
    next;
  }

  # First check, that this cells is found in gds strings
  # The cell name in gds may not be matching exactly to the name in lef. It can: 
  #  a. it can have an "m_" prefix 
  #  b. be in a different case

  $gds_cell_name = "???";
  $locase_cell_name = lc($cell_name);
  $gds_prefix = $VarHash{gds_prefix};

  # 1. Check cell name as is
  if (defined $AllGdsStrings{$cell_name}) {
    $gds_cell_name = $cell_name;
  # 2. Check with the prefix
  } elsif (defined $AllGdsStrings{$gds_prefix.$cell_name}) {
    $gds_cell_name = $gds_prefix.$cell_name;
  # 3. Check if gds name appears in different case
  } elsif (defined $AllGdsStringsInLowcase{$locase_cell_name}) {
    $gds_cell_name = $AllGdsStringsInLowcase{$locase_cell_name};
  # 4. Check with both prefix and in different case
  } elsif (defined $AllGdsStringsInLowcase{$gds_prefix.$locase_cell_name}) {
    $gds_cell_name = $AllGdsStringsInLowcase{$gds_prefix.$locase_cell_name};
  }


  # Print a message whether cell name was found as is in the gds, found under different name 
  # or not found at all
  if ($gds_cell_name eq "???") {
    edaMsg("Cell '$cell_name' is not found in specified gds files! Skipping it...\n","E");
    next;
  } elsif ($gds_cell_name eq $cell_name) {
    edaMsg("Cell '$cell_name' is found in $AllGdsStrings{$gds_cell_name} - OK");
  } else {
    edaMsg("Cell '$cell_name' is found in $AllGdsStrings{$gds_cell_name} as '$gds_cell_name' - OK");
  }

  # Here is the gds file where $cell_name was found
  $gds_file = $AllGdsStrings{$gds_cell_name};


  # If cell name had a prefix in gds or appears in different case, 
  # we need to create a local copy of lef where the MACRO is renamed
  # to match exactly the one from GDS
  if ($gds_cell_name ne $cell_name) {
    $MACRO_TEXT = "";
    $read_flag = 0;
    edaMsg("Creating $gds_cell_name.lef.4gdsnamematch\n");

    # read in the text for macro from the original lef file
    # and dump the modified version to buffer $MACRO_TEXT
    edaOpenFile(IN, $LefHash{$cell_name,'file'}, "r");
    while(<IN>) {
      # Skip empty line
      if ($_ =~ m/^\s*$/) {
        next;
      }

      $line = $_;
      # Remove tabs, multiple, leading and trailing spaces
      $line =~ s/\t/ /g;
      $line =~ s/^\s*//;
      $line =~ s/\s*$//;
      $line =~ s/\s+/ /g;

      @Line = split(" ",$line);
      $line .= "\n";

      # Is it a beginning of the MACRO?
      if (($Line[0] eq "MACRO") && ($Line[1] eq $cell_name)) {
        $MACRO_TEXT .= "MACRO $gds_cell_name\n";
	$read_flag = 1;
	next;
      }
      # Is it the end of MACRO?
      elsif (($Line[0] eq "END") && ($Line[1] eq $cell_name)) {
        $MACRO_TEXT .= "END $gds_cell_name\n";
	last;
      }
      # If inside macro - append the line to the section
      if ($read_flag) {
	$MACRO_TEXT .= $line;
      }
    }
    close IN;

    # Write out modified lef to $gds_cell_name.lef.4gdsnamematch
    edaOpenFile(OUT, "$gds_cell_name.lef.4gdsnamematch", "wf");
    print OUT $MACRO_TEXT;
    close OUT;
  }
 
 

  # Create gds2def config file
  edaMsg("Creating '$cell_name.conf'...\n");
  edaOpenFile("FILE","$cell_name.conf","wf");
    print FILE "
# Top Level cell for extraction
TOP_CELL $gds_cell_name
#GDS Layer Map file
GDS_MAP_FILE $VarHash{map_file}
";

  # If gds name is not equal to lef name - point to the modified local lef file
  # otherwise point to the original lef file
  if ($cell_name ne $gds_cell_name) {
    print FILE "
# LEF file for the top cell
LEF_FILE {
 $gds_cell_name.lef.4gdsnamematch
}
";
  } else {
    print FILE "
# LEF file for top cell
LEF_FILE {
 $LefHash{$cell_name,'file'}
}
";
  }

  print FILE "
# GDS file for the top cell
GDS_FILE $gds_file

VDD_NETS {
";

  # Typical syntax "VDD vdda vddb, VDD_SOC vdd1 vdd2" or simply "VDD1 VDD2"
  foreach $vdd_net (split(",",$VarHash{vdd_nets})) {
    @VddNet = split(" ",$vdd_net);
    if ($#VddNet > 0) {
      $lef_vdd_name = shift(@VddNet);
      print FILE " $lef_vdd_name {\n";
      foreach $gds_vdd_name (@VddNet) {
	print FILE "  $gds_vdd_name\n";
      }
      print FILE " }\n";
    } else {
      print FILE " @VddNet\n";
    }
  }
  
  print FILE "}

GND_NETS {
";

  foreach $vss_net (split(",",$VarHash{vss_nets})) {
    @VssNet = split(" ",$vss_net);
    if ($#VssNet > 0) {
      $lef_vss_name = shift(@VssNet);
      print FILE " $lef_vss_name {\n";
      foreach $gds_vss_name (@VssNet) {
	print FILE "  $gds_vss_name\n";
      }
      print FILE " }\n";
    } else {
      print FILE " @VssNet\n";
    }
  }

  print FILE "}\n";
  
  # For gdsmem only
  if ($VarHash{mem} eq "on") {
    print FILE "
MEMORY_BIT_CELL auto_detect\n";
    if( ($VarHash{core_start_layer} ne "") && ($VarHash{core_start_layer} ne "???") ) {
      print FILE "
CORE_EXTRACTION_STARTING_LAYER $VarHash{core_start_layer}\n";
    }
  }

  if( ($VarHash{start_layer} ne "") && ($VarHash{start_layer} ne "???") ) {
    print FILE "
EXTRACTION_STARTING_LAYER $VarHash{start_layer}\n";
  }
  

  print FILE "\n";

  # Append optional file
  if( ($VarHash{options_file} ne "???") && ($VarHash{options_file} ne "") ) {
    if( -r "$VarHash{options_file}" ) {
      edaOpenFile(IN,"$VarHash{options_file}","r");
      while(<IN>) {
	print FILE $_;
      }	
      close IN;
    }
  }


  close FILE;
}

# At this point all config files are created
# Stop here if user specified "-norun"
if ($VarHash{norun} eq "on") {
  edaMsg("Stopping ...");
  exit;
}

# Read the bsub options file if present 
$bsub_command = "bsub";
  if( ($VarHash{bsub_command_file} ne "???") && ($VarHash{bsub_command_file} ne "") && ($VarHash{bsub_run} eq "on")) {
    if( -r "$VarHash{bsub_command_file}" ) {
      edaOpenFile(IN,"$VarHash{bsub_command_file}","r");
      while(<IN>) {
        if ($_ =~ /sub/)
         {
           chomp;
           $bsub_command = $_;
         }
      }
      close IN;
    }
  }
#=========================================================
# Loop over all memories and run gds2def
#==========================================================
edaOpenFile("REPORT","top_report","wf");
system "mkdir  LOG";
foreach $cell_name (edaConvert2List($VarHash{cell_names})) {

  # Run gds2def
  
  if ($VarHash{mem} eq "on") { 
  if ($VarHash{bsub_run} eq "on") {
    edaMsg("Running $bsub_command $ENV{APACHEROOT}/bin/gds2def -m for cell $cell_name...");
    edaExecute("$bsub_command $ENV{APACHEROOT}/bin/gds2def -m  -out_dir OUTPUT -log LOG/$cell_name\_log $cell_name.conf >& log");
  }
  else {	
    edaMsg("Running $ENV{APACHEROOT}/bin/gds2def -m for cell $cell_name...");
    edaExecute("$ENV{APACHEROOT}/bin/gds2def -m  -out_dir OUTPUT -log LOG/$cell_name\_log $cell_name.conf >& log" );
  }
 }
else {
    if ($VarHash{bsub_run} eq "on") {
    edaMsg("Running $ENV{APACHEROOT}/bin/gds2def for cell $cell_name...");
    edaExecute("$bsub_command $ENV{APACHEROOT}/bin/gds2def -out_dir OUTPUT -log LOG/$cell_name\_log $cell_name.conf $gds_file >& log"); 
}
  else {
    edaMsg("Running $ENV{APACHEROOT}/bin/gds2def for cell $cell_name...");
    edaExecute("$ENV{APACHEROOT}/bin/gds2def -out_dir OUTPUT -log LOG/$cell_name\_log $cell_name.conf $gds_file >& log"); 
  }
}

  
  # Check that def file file was created
  #if ($VarHash{mem} eq "on") {
  #  if ( !( (-r "$gds_cell_name\_adsgds.def") && (-r "$gds_cell_name\_adsgds.lef") && ( (-r "$gds_cell_name\_adsgds.lib") || (-r "$gds_cell_name\_adsgds.pratio") ) ) ) {
  #    #edaMsg("Extraction failed for $gds_cell_name on $date\n");
  #    next;
  #  }
  # }
  #  edaCheckInputFiles("$gds_cell_name\_adsgds.def, $gds_cell_name\_adsgds.lef, $gds_cell_name\_adsgds.lib "); 
  #elsif ( !( (-r "$gds_cell_name.def") && (-r "$gds_cell_name\_adsgds.lef") ) ) {
  #    edaMsg("Extraction failed for $gds_cell_name on $date\n");
  #    next;
  #    #edaCheckInputFiles("$gds_cell_name.def, $gds_cell_name\_adsgds.lef"); 
  #}

  #my $date = edaGetDate();
  #edaMsg("Extraction completed on $date\n");


#  # Again, if gds name was different from lef one - rename files and macros back
#  if ($cell_name ne $gds_cell_name) {
#    print "$cell_name $gds_cell_name\n";
#    edaMsg("Renaming '$gds_cell_name' back to '$cell_name'");
#    if ($VarHash{mem} eq "on") {
#      edaExecute("sed \"s/$gds_cell_name/$cell_name/g\" $gds_cell_name\_adsgds.def > $cell_name\_adsgds.def");
#      edaExecute("sed \"s/$gds_cell_name/$cell_name/g\" $gds_cell_name\_adsgds.lef > $cell_name\_adsgds.lef");
#      edaExecute("sed \"s/$gds_cell_name/$cell_name/g\" $gds_cell_name\_adsgds.lib > $cell_name\_adsgds.lib");
#     edaExecute("sed \"s/$gds_cell_name/$cell_name/g\" $gds_cell_name\_adsgds.pratio > $cell_name\_adsgds.pratio");
#     edaRemoveFiles("$gds_cell_name\_adsgds.def","$gds_cell_name\_adsgds.lef","$gds_cell_name\_adsgds.lib", "$gds_cell_name\_adsgds.pratio","$gds_cell_name.lef.4gdsnamematch");
#    } 
#    else {	
#      edaExecute("sed \"s/$gds_cell_name/$cell_name/g\" $gds_cell_name.def > $cell_name.def");
#      edaExecute("sed \"s/$gds_cell_name/$cell_name/g\" $gds_cell_name\_adsgds.lef > $cell_name\_adsgds.lef");
#      edaRemoveFiles("$gds_cell_name.def","$gds_cell_name\_adsgds.lef","$gds_cell_name.lef.4gdsnamematch");
#    }
#  }
}




$job_count = 1;
 while ($job_count == 1 && $VarHash{bsub_run} eq "on")
  {
   system("bjobs >& job_status");
   edaOpenFile("JOB","job_status","r");
   while (<JOB>)
    {
     if ($_ =~ /No unfinished job found/)
      {
       $job_count = 0;
      }
    }
   }
 chdir LOG;
 @all_dir = glob "*log*/";
foreach $dir(@all_dir){
        if (-d "$dir")
         {
          split (/\_log/,$dir);
          $cell_name = $_[0];
          chdir "$dir";
          edaOpenFile("LOG","gds.log","r");
          while (<LOG>)
          {
            $result = "Fail";
            $error = "";
            if ($_ =~ /ERROR/)
             {
              $error = $_;
              last;
             }
            if ($_ =~ /Finish generating output DEF file/)
            {
              $result = "Done";
              last;
            }
          }
printf REPORT "%20s%10s\n","$cell_name","$result";
chdir ("..");
}

}

system "\rm -rf log";
system "\rm -rf job_status";

#----------------------------------------------------
#   Help page
#----------------------------------------------------

BEGIN {
  sub usage {
    print "
SYNOPSIS

 Generates configuration files and runs gds2def extraction for multiple cells

DESCRIPTION

 Script accepts user options from 2 sources:
 a. from \$cwd/gds_setup.init file
 b. from command line arguments, which are saved as well in gds_setup.init by the script

 Input to the script is incremental. The user may invoke the script with one or more options, then re-invoke the script adding more information, until all required information is complete. The user may add optional information at any time.

 Script examines lef and gds files first to ensure that cells being extracted have both gds and lef description

 Example:

 gds_setup.pl -vdd_nets VDD vdd vddx vddy, VDD_SOC \\
              -vss_nets VSS gnd vss \\
              -map_file gds_layer.map \\
              -cell_name MEM22x64 MEM22x32 \\
              -lef_files lef_dir/*.lef \\
              -gds_files gds_dir/*.gds \\
              -mem on \\
              -norun on \\
              -bsub_run on \\
              -bsub_command_file  
OPTIONS
";

    foreach $var (@VarList) {
      $var_expl = $VarProperties{$var.",expl"};
      $var_example = $VarProperties{$var.",example"};
      if (defined $VarProperties{$var.",default"}) {
	$var_default = $VarProperties{$var.",default"};
      } else {
	
	if ($var eq "cell_names") {
	  $var_default = "all non CORE macros found in specified lef files";
	} else {
	  $var_default = "none";
	}
      }
      print "  -$var\n\t$var_expl\n\tDefault: $var_default\n";
      if ($var_example ne "") {
	print "\tExample: $var_example\n";
      }
    }
  } # End of usage routine
}


