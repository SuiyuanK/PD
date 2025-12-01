# $Revision: 1.44 $

# Revision history
#Rev 1.44 by Ramachandra
#Fixed bug while reading gsr which is commented in command file
#Rev 1.43 by Ramachandra
#Added support for "dump res_network" and "EM_NET_INFO"
#Rev 1.42 by Ramachandra 
#Added support for inject_noise pwl files
#Rev 1.41 by Vineeth
#Added protection for blank lines in CMM_CELLS section
#Fixed bug in uniquification of *gz files
#Use diff instead of size comparison for uniquification
#Rev 1.38 by Vineeth
#Added support for copying config files of POWER_TRANSIENT keyword.
#Modified handling of .libs/.lefs/.defs file to add support for CUSTOM_LIBS_FILE section in .libs file
#Fixed a bug in uniquification of files
#Rev 1.37 by Vineeth
#Added support for CPA_MODEL
#Added support for cmm_type (raw/original/optimize/compact)
#Rev 1.36 by Vineeth
#Fixed a bug in handling whitespace in .defs/.lefs/.libs
# Rev 1.35 by Vineeth
# Added support for CMM_CELLS and ERV_CELLS 
# Rev 1.34 by Vineeth
# New options -zip, -tar, -ftp.
# -notar option removed. Default behaviour is that of -notar
# Auto -ftp disabled. -zip or -tar has to be used along with -ftp.
# -tcl option required to input RH command file. 
# GetOpt function is used to read options and arguments.
# Rev 1.33 by Vineeth
# -added support for files with same names in different directories
# Rev 1.32 by Vineeth
# - added support for RDL_CELL
# Rev 1.31 by Vinayakam
# - do not link db if gsr is given in cmd file
# Rev 1.30 by Vinayakam
# - added support for constraint file specified in report result command
# Rev 1.29 by Vinayakam
# - added support for import eco,gsc,vpcontrol,sta,db
# Rev 1.28 by Vinayakam
# - added support for GATED_CONTROL_FILE under STATE_PROPAGATION
# Rev 1.28 by Vinayakam
# - added support for GATED_CONTROL_FILE under STATE_PROPAGATION
# Rev 1.27 by Vinayakam
# - added support for VP_CONTROL file
# Rev 1.26 by Vinayakam
# - added better messages for broken links
# Rev 1.25 by Vinayakam
# - added support for PACKAGE_SPICE_SUBCKT and .inc lines in the package wrapper file for RH
# Rev 1.24 by Vinayakam
# - do not process IGNORE_FILE_PREPARSE keyword - leave as is
# Rev 1.23 by Vinayakam
# - added support for EM_TECH_RMS/AVG/PEAK keywords and respective files
# Rev 1.22 by Vinayakam
# - fixed bug in prefixing cmd_dirname to FILE_TYPE line in VCD_FILE when cmd_dirname/VCD exists
# Rev 1.21 by Vinayakam
# - added support for temporal in GDS_CELLS
# Rev 1.20  by Vinayakam
# - added support for vcd file specified in "setup vcd" command
# Rev 1.19  by Vinayakam
# - added support for absolute path gsr file referred to in cmd file
# Rev 1.18  by Vinayakam
# - fixed bug in -copy option where it looked for copy2dirafter chdir to send2apache
# Rev 1.17  by Vinayakam
# - print as is for _FILE keywords APACHE_FILES,GENERATE_APL_FILE.
# - mapped CELL_RC_FILE to spef dir name under design_data
# Rev 1.16  by Vinayakam
# - added support for file.defs,file.lefs,file.libs
# Rev 1.15  by Vinayakam
# - added support for gzipped def files in gds2def directory
# Rev 1.14  by Vinayakam
# - added absolute path support for "import apl" files.
# Rev  1.13  by Vinayakam
# - added support for files specified with absolute path in the gsr
# - fixed typo in cd sendapache message
# Rev  1.12  by Vinayakam
# - get gsr file from "setup design" line in cmd file also
# Rev 1.11
# - Works with non-writeable directories. $cwd has to be writeable
# Rev 1.10
# - Fixed wrong dir name for APL files  
# Rev 1.8 
# - Names under design_data: apl  def  gds2def  lef  lib  ploc  tech
# - New function "-copy <target_dir>"
# Rev 1.7
# - Fixed handling of GDS_CELLS - covers gds2def and gdsmem 5.2 and 5.3
# Rev 1.6
# - Supports "import avm"
#   Apl and avm files are linked under data/APL_FILES
# Rev 1.5
# - Fix bug related to linked files
# - Supports both 5.2. and 5.3 gdsmem
# Rev 1.4
# - Tar is named as: <design>.<username>.<domain>.<day><month><year>
# - notar option for debugging
# Rev 1.3
# - Removed an "exit" before tarring - stupid bug
# Rev 1.2
# - Fix problem with GDS_DIR. No directory link any more _adsgds files are linked directly
# - Delete all temporary files upon completion

eval '(exit $?0)' && eval 'exec perl -S $0 ${1+"$@"}'
  && eval 'exec perl -S $0 $argv:q'
  if 0;

# Put a directory with eda_utils.pm into search path
$script_installation_dir = dirname($0);
push(@INC,$script_installation_dir);
push(@INC,$script_installation_dir."/pm");

# Print Warnings and Errors by default
use vars qw(%GLOBAL_PARMS);
$GLOBAL_PARMS{VerboseLevel} = "W";
require "eda_utils.pm";
use File::Basename;

%Gdskey2dirname = (
		   "TECH_FILE" => "tech",
		   "DEF_FILES" => "def",
		   "LEF_FILES" => "lef",
		   "APL_FILES" => "apl",
		   "LIB_FILES" => "lib",
		   "PAD_FILES" => "ploc",
		   "STA_FILE" => "timing",
		   "GDS_CELLS" => "gds2def",
		   "CELL_RC_FILE" => "spef",
		   "GDSII_FILE" => "gds",
		   "CPA_MODEL" => "rh_cpa",
		  ); 
		   
=head1 NAME

 
=head1 SYNOPSIS

perl send2apache.pl [options] arguments

Options: -h, -help, -man , -tcl , -copy , -u, -ftp, -tar, -zip

=head1 DESCRIPTION

This script performs automatic data collection - it's handy if customer data has no common root and files are scattered across the network. By default both compression ( tar/zip) and ftp (sending to apache ftp network) are disabled. To enable them use options -zip / -tar and -ftp.


=head1 PROCEDURE

 1. All files referenced in Redhawk command script and GSR are detected and linked under
    send2apache/design_data/<file_type> directories thus creating a complete local data set
 2. Modified command file and GSR are created under send2apache/run - they contain 
    only relative pointers to ../design_data/...
 3. Give -tar / -ftp option.Tar ball / zip file is created with the name: send2apache/<design>.<username>.<domain>.<day><month><year>.[tgz/zip]
    * Please check disk space before using send2apache.pl - tarball can be very large!.
 4. Give -copy '$copy2dir' to copy the testcase to desired directory.
 4. File is uploaded to Apache ftp if -ftp option is provided.
 5. send2apache is deleted

 
=head1 OPTIONS

=over

=item -h

Prints a short synopsis.

=item -u

Prints a short synopsis.

=item -help

Prints a synopsis and a description of program options.

=item -man

Prints the entire man page. 

=item -tcl

Specify the .tcl/.cmd file

=item -copy

Specify the directory into which the data has to be copied into.

=item -ftp

Specify whether the tar ball has to be send to apache ftp network. To ftp the data, this option has to be used in conjunction with -zip / -tar.

=item -zip

Specify whether the data has to be compressed using zip

=item -tar

Specify whether the data has to be tarred.

=head1 EXAMPLE

perl send2apache.pl -tcl ../lab_10/brcm_jtag_wrapper/run/run.tcl  -tar -ftp

=back

=head1 REQUIREMENTS

Just the .tcl/.cmd file.

=head1 AUTHOR

Vinayakam Subramanian , Applications Engineer, Apache India.

email : vinayakam@apache-da.com

=head1 COPYRIGHT

COPYRIGHT (c) 2007 Apache Design Solutions. All right reserved.

=cut

# end program documentation


$usage = "
SYNOPSYS

 Automatically transfers complete customer testcases to Apache

DESCRIPTION

 This script performs automatic data collection - it's handy if customer
 data has no common root and files are scattered across the network.


 1. All files referenced in Redhawk command script and GSR are detected and linked under
    send2apache/design_data/<file_type> directories thus creating a complete local data set
 2. Modified command file and GSR are created under send2apache/run - they contain 
    only relative pointers to ../design_data/...
 3. All the data is tarred in file send2apache/<design>.<username>.<domain>.<day><month><year>.tgz
    * Please check disk space before using send2apache.pl - tarball can be very large!
 4. Tar file is automatically uploaded to Apache ftp (incoming)
 5. send2apache is deleted

USAGE

Please ask customer 
 1. cd to directory where the testcase had run
 2. run \"send2apache.pl <cmd_file>\"
 3. mail file name and size reported by \"send2apache.pl\"

To reproduce testcase at Apache:
 1. download the file from ftp
 2. tar xvfz <filename>.tgz
 3. cd run
 4. redhawk -f <cmd_file>

OPTIONS
 -copy <target_directory>
   Instead of putting the tarball on ftp - open it under <target_directory>
 -notar
   Only create temporary directory with all the link and the GSR file. Good for debug.
";
use Getopt::Long;
use Pod::Usage;
	my $opt_h   ='';            # short help
        my $opt_u   ='';	    # short help	
	my $opt_help='';            # long help
        my $opt_man ='';            # man page
        my $cmd_file = '';
 	my $copy2dir = '';
	my $notar = 1;
        # get input options..
        GetOptions( 'h'    => \$opt_h,
		    'u'	   => \$opt_u,
                    'help' => \$opt_help,
                    'man'  => \$opt_man,
                    'tcl=s' => \$cmd_file,
                    'ftp' => \$ftp,
                    'zip' => \$zip,
		    'tar' => \$tar,
		    'd'   => \$debugMode,
                    'copy=s' => \$copy2dir);
	pod2usage (-exitval => 0, -verbose => 2) if $opt_man;
	pod2usage (-exitval => 0, -verbose => 1) if $opt_help;
        pod2usage ( -msg => "The following is the usage .\n To learn more about the options, use --help\n", -exitval => 0 , -verbose => 0) if ($opt_h || $opt_u);
# if Apache ECO file was not specified, exit.
unless($cmd_file) {
	die "\nFATAL : .tcl/.cmd  file not specified!\nPlease use -tcl option to specify the redhawk command file (.tcl/.cmd) as input!\n";
}

# if $cmd_file does not exist, exit.i
unless( -e $cmd_file ){ 
	die "\nFATAL : The .tcl/.cmd file $cmd_file does not exist.\nProgram Exit!\n";
}
if($ftp) {
unless($zip || $tar){
print "\nIn order to FTP, Please provide -zip or -tar option along with -ftp\n";
}
}
if ($copy2dir ne ""){
$ftp=0;
$zip=0;
$tar=0;
$notar=0;
}
elsif ($zip){
$tar=0;
$notar=0;
}
elsif ($tar){
$notar=0;
}
if ($notar){
$ftp=0;
}
# Create special area for ftp'ing
edaExecute("\\rm -rf send2apache");
edaCreateDirs("send2apache/design_data");
edaCreateDirs("send2apache/run");
edaCreateDirs("send2apache/design_data/apl");

# Parse command script
# a. determine name of GSR file
# b. determine names of imported apl files, create links
# c. write out modified cmd file
$gsr_file = "???";

$cmd_basename = basename($cmd_file);
$cmd_dirname = dirname($cmd_file);

edaOpenFile(IN_CMD, "$cmd_file", "r");
edaMsg("Creating send2apache/run/$cmd_basename");
edaOpenFile(OUT_CMD, "send2apache/run/$cmd_basename", "wf");
while (<IN_CMD>) {
if($_ !~ m/^#/ ) {
  chomp();
  $_ =~ s/\s+/ /;
  if ($_ =~ m/import gsr/ ) {
    ($gsr_file = $_) =~ s/^.*import gsr\s+//;
    $gsr_file =~ s/\s+//;
    $gsr_basename = basename($gsr_file);
    $total_byte_count += (stat("$gsr_file"))[7];
    print OUT_CMD "import gsr $gsr_basename\n";
  } elsif ($_ =~ m/setup design\s+.*gsr/) {
    ($gsr_file = $_) =~ s/^.*setup design\s+//;
    $gsr_file =~ s/\s+//;
    $gsr_basename = basename($gsr_file);
    $total_byte_count += (stat("$gsr_file"))[7];
    print OUT_CMD "setup design $gsr_basename\n";
  } elsif (($_ =~ m/import apl/) or ($_ =~ m/import avm/)) {
    @Line = split(" ",$_);
    # File name is the last word in command line
    $apl_file = @Line[-1];
    if( -e $apl_file ) {   # link apl file if it exists
    	$file = edaConvertToAbsolutePath("$apl_file");
	$basename = basename($file);
    	edaExecute("\\ln -s $file send2apache/design_data/apl");
   	 $total_byte_count += (stat("$file"))[7];
    	@Line[-1] = "../design_data/apl/$basename";
    	print OUT_CMD "@Line\n";
    } elsif( -e "$cmd_dirname/$apl_file") { # apl file could be in cmd dir
    	$file = edaConvertToAbsolutePath("$cmd_dirname/$apl_file");
    	$basename = basename($file);
    	edaExecute("\\ln -s $file send2apache/design_data/apl");
   	 $total_byte_count += (stat("$file"))[7];
    	@Line[-1] = "../design_data/apl/$basename";
    	print OUT_CMD "@Line\n";
    }
 } elsif ($_ =~ m/perform\s+analysis\s+-inject/) {
   @Line = split('\s+',$_);
   	for($i = 0; $i < (@Line-1); $i = $i+1) {
   	    if (@Line[$i] eq '-wave') {
   	       $i_w = $i;
   	    }
   	}
    edaCreateDirs("send2apache/design_data/inject_noise");
    ## File name is the next word to -wave
    $noise_file = @Line[$i_w+1];
    if( -e $noise_file ) {   # link noise file if it exists
    	$file = edaConvertToAbsolutePath("$noise_file");
	$basename = basename($file);
    	edaExecute("\\ln -s $file send2apache/design_data/inject_noise");
   	 $total_byte_count += (stat("$file"))[7];
    	@Line[$i_w+1] = "../design_data/inject_noise/$basename";
    	print OUT_CMD "@Line\n";
    } elsif( -e "$cmd_dirname/$noise_file") { # noise file could be in cmd dir
    	$file = edaConvertToAbsolutePath("$cmd_dirname/$noise_file");
    	$basename = basename($file);
    	edaExecute("\\ln -s $file send2apache/design_data/inject_noise");
   	 $total_byte_count += (stat("$file"))[7];
    	@Line[$i_w+1] = "../design_data/inject_noise/$basename";
    	print OUT_CMD "@Line\n";
    }
  } elsif (($_ =~ m/report\s+result/)) {
    @Line = split(" ",$_);
    # File name is the last word in command line
    $apl_file = @Line[-1];
    if( -e $apl_file ) {   # link apl file if it exists
    	$file = edaConvertToAbsolutePath("$apl_file");
	$basename = basename($file);
    	edaExecute("\\ln -s $file send2apache/design_data/constraint");
   	 $total_byte_count += (stat("$file"))[7];
    	@Line[-1] = "../design_data/constraint/$basename";
    	print OUT_CMD "@Line\n";
    } elsif( -e "$cmd_dirname/$apl_file") { # apl file could be in cmd dir
    	$file = edaConvertToAbsolutePath("$cmd_dirname/$apl_file");
    	$basename = basename($file);
    	edaExecute("\\ln -s $file send2apache/design_data/constraint");
   	 $total_byte_count += (stat("$file"))[7];
    	@Line[-1] = "../design_data/constraint/$basename";
    	print OUT_CMD "@Line\n";
    }
  }  elsif (($_ =~ m/^\s*setup\s+vcd\s+(\S+).*/)) {
    $line = $_;
    edaCreateDirs("send2apache/design_data/vcd");
    #@Line = split(" ",$_);
    # File name is the last word in command line
    $vcd_file = $1;
    if( -e $vcd_file ) {   # link vcd file if it exists
    	$file = edaConvertToAbsolutePath("$vcd_file");
	$basename = basename($file);
    	edaExecute("\\ln -s $file send2apache/design_data/vcd");
   	 $total_byte_count += (stat("$file"))[7];
    	#$line = $_;
	$line =~ s,$vcd_file,../design_data/vcd/$basename,g;
    	print OUT_CMD "$line\n";
    } elsif( -e "$cmd_dirname/$vcd_file") { # vcd file could be in cmd dir
    	$file = edaConvertToAbsolutePath("$cmd_dirname/$vcd_file");
    	$basename = basename($file);
    	edaExecute("\\ln -s $file send2apache/design_data/vcd");
   	 $total_byte_count += (stat("$file"))[7];
    	#$line = $_;
	$line =~ s,$vcd_file,../design_data/vcd/$basename,g;
    	print OUT_CMD "$line\n";
    }
  } elsif (($_ =~ m/^\s*import\s+(\S+)\s+(\S+)\s*$/)) { # to get import gsc,sta,vpcontrol,eco files
    if ($gsr_file ne "???"  && $1 eq "db") {
    	# case: gsr file is defined and cmd file has import db
	# do: do not link db, comment out line in output cmd file
	print OUT_CMD "# send2apache commented the below import db line since gsr is being read in\n#$_\n";
    } else {
    	$line = $_;
   	#@Line = split(" ",$_);
    	# type of file is eco or gsc or sta or vpcontrol
   	$type_of_file = $1;
   	# File name is the last word in command line
    	$eco_file = $2;
    	edaCreateDirs("send2apache/design_data/$type_of_file");
    	if( -e $eco_file ) {   # link vcd file if it exists
    		$file = edaConvertToAbsolutePath("$eco_file");
		$basename = basename($file);
    		edaExecute("\\ln -s $file send2apache/design_data/$type_of_file");
   	 	$total_byte_count += (stat("$file"))[7];
    		#$line = $_;
		$line =~ s,$eco_file,../design_data/$type_of_file/$basename,g;
    		print OUT_CMD "$line\n";
    	} elsif( -e "$cmd_dirname/$eco_file") { # vcd file could be in cmd dir
    		$file = edaConvertToAbsolutePath("$cmd_dirname/$eco_file");
    		$basename = basename($file);
    		edaExecute("\\ln -s $file send2apache/design_data/$type_of_file");
   	 	$total_byte_count += (stat("$file"))[7];
    		#$line = $_;
		$line =~ s,$eco_file,../design_data/$type_of_file/$basename,g;
    		print OUT_CMD "$line\n";
    	}
    }
  } elsif ($_ =~ m/^\s*dump res_network\s+-o\s+(.*)\s+-conf\s+(.*)\s*$/) { 
    $rptr = $1 ;
    $conff = $2 ;
    $rptr1 = basename($rptr);
    $conf1 = basename($conff);
    edaExecute("\\cp -f $conff send2apache/design_data/$conf1");
    print OUT_CMD "dump res_network -o $rptr1 -conf send2apache/design_data/$conf1\n";
   } else {
    print OUT_CMD "$_\n";
  }
}
}
close IN_CMD;
close OUT_CMD;

if ($gsr_file eq "???") {
  edaError("There is no reference to GSR file in $cmd_file!");
}



# a. Parse GSR
# b. Loop over all GSR keywords. Create all the links for subsequent ftp'ing as
#  well as modified GSR and command file
if( -r "$cmd_dirname/$gsr_file" ) {
	@GSR_keywords = parseGSR("$cmd_dirname/$gsr_file",\%MyGSR);
}
else {  # gsr can be with absolute path
	@GSR_keywords = parseGSR("$gsr_file",\%MyGSR);
}

edaMsg("Creating send2apache/run/$gsr_basename");
edaOpenFile(OUT_GSR, "send2apache/run/$gsr_basename", "wf");
print OUT_GSR "# Created by send2apache.pl\n";

foreach $gsr_key (@GSR_keywords) {
  if (defined $MyGSR{$gsr_key}{help}) {
    print OUT_GSR "\n$MyGSR{$gsr_key}{help}\n";
  } else {
    print OUT_GSR "\n";
  }
  print OUT_GSR "$gsr_key ";

 
  # Does this GSR entry specify some file/s?
  if (($gsr_key =~ m/_FILE/) || ($gsr_key =~ m/GDS_CELLS/) || ($gsr_key =~ m/EM_TECH_/) || ($gsr_key =~ m/PACKAGE_SPICE_SUBCKT/)  || ($gsr_key =~ m/VP_CONTROL/) || ($gsr_key =~ m/STATE_PROPAGATION/) || ($gsr_key =~ m/RDL_CELL/) || ($gsr_key =~ m/ERV_CELLS/) || ($gsr_key =~ m/CMM_CELLS/) || ($gsr_key =~ m/POWER_TRANSIENT/) || ($gsr_key =~ /CPA_MODEL/) || ($gsr_key =~ m/EM_NET_INFO/)) {
    
    # Determine target directory to link the data 
    if (defined $Gdskey2dirname{$gsr_key}) {
      $target_dir = $Gdskey2dirname{$gsr_key};
    } else {
      $target_dir = $gsr_key;
    }


    # if keyword is *_FILE* but does not specify any files (eg: APACHE_FILEs), print as is and go to next keyword
    if($gsr_key =~ m/APACHE_FILE/ || $gsr_key =~ m/GENERATE_APL_FILE/ || $gsr_key =~ m/IGNORE_FILE_PREPARSE/) {
    	print OUT_GSR "$MyGSR{$gsr_key}{text}\n";
	next;
    }
    edaCreateDirs("send2apache/design_data/$target_dir");
    foreach $line (split("\n",$MyGSR{$gsr_key}{text})) {
      # if it's a comment line - print as is
      if (($line =~ m/^#.*/) || ($line =~ m/^\s*$/)) {
	print OUT_GSR "$line\n";
	next;
      }
      # if it is VCD_FILE and FILE_TYPE keyword, write it as it is and continue with next line
      if($gsr_key =~ m/VCD_FILE/ && $line =~ /FILE_TYPE/) {
      	print OUT_GSR "$line\n";
	next;
      }
      
      # Handling CMM and ERV cells
      if (($gsr_key =~ m/ERV_CELLS/) || ($gsr_key =~ m/CMM_CELLS/)) {
	@line = split(" ",$line);
        $db = pop(@line);
	if (($db eq "raw") || ($db eq "optimize") || ($db eq "compact") || ($db eq "original")) {
	$cmm_type = $db;
	$db = pop(@line);
	} else {
	$cmm_type = '';
	}
        if (-r "$cmd_dirname/$db"){          
          $file = edaConvertToAbsolutePath("$cmd_dirname/$db");
	}
	elsif (-r "$db"){
	  $file = edaConvertToAbsolutePath("$db");
	} else {
	print OUT_GSR "$line\n"; next;
  	}
	$basename = basename($file);
	# if link already exists - skip
	if (-l "send2apache/design_data/$target_dir/$basename") {
	  $basename = resolveSameBaseName("send2apache/design_data/$target_dir/$basename", "$file");
	}
	edaExecute("\\ln -s $file send2apache/design_data/$target_dir/$basename");
	$total_byte_count += (stat($file))[7];
	print OUT_GSR "@line ../design_data/$target_dir/$basename $cmm_type\n";
	next;		
      }
      
      foreach $word (split(" ",$line)) {
	# Check, that this is a readable file
	if ((-r "$cmd_dirname/$word") || (-r "$word"))  {
	  if (-r "$cmd_dirname/$word") {
	  # Just in case it was a manual GSR - convert to absolute path if $word is already not absolute path,ie, $word does not start with /
	  $file = edaConvertToAbsolutePath("$cmd_dirname/$word");
	  } else {
	  $file =  edaConvertToAbsolutePath("$word");
	  }
	  $basename = basename($file);
	  # if link already exists - skip
	  if (-e "send2apache/design_data/$target_dir/$basename")  { 
	  $basename = resolveSameBaseName("send2apache/design_data/$target_dir/$basename", "$file");
          }
	if($word =~ /\.defs$/ || $word =~ /\.lefs$/ || $word =~ /\.libs$/ ) {
	    if (-r "$cmd_dirname/$word"){          
	    $file = edaConvertToAbsolutePath("$cmd_dirname/$word");
	    }
	    elsif (-r "$word"){
	    $file = edaConvertToAbsolutePath("$word");
	    }
	    $basename = basename($file);
            edaOpenFile(IN_LIBS, "$file", "r");
	    edaMsg("Creating send2apache/design_data/$target_dir/$basename");
	    edaOpenFile(OUT_LIBS, "send2apache/design_data/$target_dir/$basename", "wf");
	    print OUT_GSR "../design_data/$target_dir/$basename ";
	    while(<IN_LIBS>) {    
            @LIBS_keywords = parseGSR("$file",\%MyLIBS);
	    }
	    foreach $libs_key (@LIBS_keywords) {
	      if (defined $MyLIBS{$libs_key}{help}) {
	        print OUT_LIBS "\n$MyLIBS{$libs_key}{help}\n";
	      } else {
	        print OUT_LIBS "\n";
	      }
		$is_file = 0;
		if (-r "$cmd_dirname/$libs_key" ) {
	      	  $file_libs = edaConvertToAbsolutePath("$cmd_dirname/$libs_key");
	      	  $basename = basename($file_libs);
		  $is_file = 1;
	      	} elsif (-r "$libs_key") { 
	      	  $file_libs =  edaConvertToAbsolutePath("$libs_key");
	      	  $basename = basename($file_libs);
		  $is_file = 1;
	      	}	      
		if ($is_file == 1) {
	 		if (-l "send2apache/design_data/$target_dir/$basename") {
	      	  	$basename = resolveSameBaseName("send2apache/design_data/$target_dir/$basename", "$file_libs");
	                }
	      	    
	      	      # All file related keywords
	      	      edaExecute("\\ln -s $file_libs send2apache/design_data/$target_dir/$basename");
	      	      $total_byte_count += (stat($file_libs))[7];
	      	      print OUT_LIBS "../design_data/$target_dir/$basename ";		
		}else {
	      	  # This word is not a file - print as is
	      	  print OUT_LIBS "$libs_key " ;
	      	}
	       
	     
	      foreach $line_libs (split("\n",$MyLIBS{$libs_key}{text})) {
	            # if it's a comment line - print as is
	            if ($line_libs =~ m/^#.*/) {
	      	print OUT_LIBS "$line_libs\n";
	      	next;
	            }
	      foreach $word_libs (split(" ",$line_libs)) {
		$is_file = 0;
	      # Check, that this is a readable file
	      	if (-r "$cmd_dirname/$word_libs" ) {
	      	  # Just in case file pointers are relative, - convert to absolute path if $word_libs is already not absolute path,ie, $word_libs does not start with /
		  $is_file = 1;
	      	  $file_libs = edaConvertToAbsolutePath("$cmd_dirname/$word_libs");
	      	  $basename = basename($file_libs);
	      	} elsif (-r "$word_libs") { # can be absolute path to the file
	      	  # Just in case file pointers are relative, convert to absolute path if $word_libs is already not absolute path,ie, $word_libs does not start with /
		  $is_file = 1;
	      	  $file_libs =  edaConvertToAbsolutePath("$word_libs");
	      	  $basename = basename($file_libs);
	      	} elsif (-l $word_libs) {
	      	  # unreadable link...
	      	  edaError("Link '$word_libs' is broken!");
	        } elsif (-l "$cmd_dirname/$word_libs") {
	      	  # unreadable link...
	      	  edaError("Link '$word_libs' is broken!");
	        }
		if ($is_file == 1) {
	 		if (-l "send2apache/design_data/$target_dir/$basename") {
	      	  	$basename = resolveSameBaseName("send2apache/design_data/$target_dir/$basename", "$file_libs");
	                }
	      	    
	      	      # All file related keywords
	      	      edaExecute("\\ln -s $file_libs send2apache/design_data/$target_dir/$basename");
	      	      $total_byte_count += (stat($file_libs))[7];
	      	      print OUT_LIBS "../design_data/$target_dir/$basename ";		
		}else {
	      	  # This word is not a file - print as is
	      	  print OUT_LIBS "$word_libs" ;
	      	}
	            }
	            print OUT_LIBS " \n";
	            }
	    print OUT_LIBS " \n";
	    }
	    close OUT_LIBS;
       }
  	      # Special treatment for GDS_CELLS to avoid recursive links
	    elsif ($gsr_key =~ m/GDS_CELLS/) {
	      # $file points to directory with gds cells
	      # $prev_word contains the name of the memory 
	      # This covers both 5.2 and 5.3 gdsmem
	      foreach $gds_file (glob("$file/$prev_word*{lef,def,lib,pratio,def\.gz}")) {
		edaExecute("\\ln -s $gds_file send2apache/design_data/$target_dir");
		$total_byte_count += (stat("$gds_file"))[7];		
	      }
	      print OUT_GSR "../design_data/$target_dir ";
	    }
            elsif (($gsr_key =~ m/GDSII_FILE/) || ($gsr_key =~ m/POWER_TRANSIENT/)) {
	    edaOpenFile(IN_GDS, "$file", "r");
	    edaMsg("Creating send2apache/design_data/$target_dir/$basename");
	    edaOpenFile(OUT_GDS, "send2apache/design_data/$target_dir/$basename", "wf");
	    print OUT_GSR "../design_data/$target_dir/$basename ";
	    while(<IN_GDS>) {    
            @GDS_keywords = parseGSR("$file",\%MyGDS);
	    }
	    foreach $gds_key (@GDS_keywords) {
	      if (defined $MyGDS{$gds_key}{help}) {
	        print OUT_GDS "\n$MyGDS{$gds_key}{help}\n";
	      } else {
	        print OUT_GDS "\n";
	      }
	      print OUT_GDS "$gds_key ";
	       
	     
	      # Does this GDS entry specify some file/s?
	      if (($gds_key =~ m/_FILE/) ) {
	      foreach $line_gds (split("\n",$MyGDS{$gds_key}{text})) {
	            # if it's a comment line - print as is
	            if ($line_gds =~ m/^#.*/) {
	      	print OUT_GDS "$line_gds\n";
	      	next;
	            }
	      foreach $word_gds (split(" ",$line_gds)) {
	      	if($debugMode) {
	      		print "DEBUG:word=$word_gds \n";
	      	}
	      # Check, that this is a readable file
	      	if (-r "$cmd_dirname/$word_gds" ) {
	      	  # Just in case file pointers are relative, - convert to absolute path if $word_gds is already not absolute path,ie, $word_gds does not start with /
	      	  if($debug_mode) {
	      	    print "DEBUG: $cmd_dirname/$word_gds is readable\n";
	      	  }
	      	  $file_gds = edaConvertToAbsolutePath("$cmd_dirname/$word_gds");
	      	  $basename = basename($file_gds);
	      	  # if link already exists - skip
	      	  if (-l "send2apache/design_data/$target_dir/$basename") {
	      	  $basename = resolveSameBaseName("send2apache/design_data/$target_dir/$basename", "$file_gds");
	                }
	      	    
	      	      # All file related keywords
	      	      edaExecute("\\ln -s $file_gds send2apache/design_data/$target_dir/$basename");
	      	      $total_byte_count += (stat($file_gds))[7];
	      	      print OUT_GDS "../design_data/$target_dir/$basename ";
	      	  
	      	} elsif (-r "$word_gds") { # can be absolute path to the file
	      	  # Just in case file pointers are relative, convert to absolute path if $word_gds is already not absolute path,ie, $word_gds does not start with /
	      	  $file_gds =  edaConvertToAbsolutePath("$word_gds");
	      	  $basename = basename($file_gds);
	      	  # if link already exists - skip
	      	  if (-l "send2apache/design_data/$target_dir/$basename") {
	      	   $basename = resolveSameBaseName("send2apache/design_data/$target_dir/$basename", "$file_gds");
	      	  }
	      	      # All file related keywords
	      	      edaExecute("\\ln -s $file_gds send2apache/design_data/$target_dir/$basename");
	      	      $total_byte_count += (stat($file_gds))[7];
	      	      print OUT_GDS "../design_data/$target_dir/$basename ";
	      	  
	      	} elsif (-l $word_gds) {
	      	  # unreadable link...
	                if($debugMode) {
	      		print "DEBUG:word=$word_gds is an unreadable link!\nPlease check file permission with ls -l -L <file>\n";
	      	  }
	      	  edaError("Link '$word_gds' is broken!");
	              } elsif (-l "$cmd_dirname/$word_gds") {
	      	  # unreadable link...
	                if($debugMode) {
	      		print "DEBUG:$cmd_dirname/$word_gds is an unreadable link!\nPlease check file permission with ls -l -L <file>\n";
	      	  }
	      	  edaError("Link '$word_gds' is broken!");
	              } else {
	      	  # Even though this word appears inside *_FILE section, it's not a file - print as is
	      	  print OUT_GDS "$word_gds" ;
	      	}
	            }
	            print OUT_GDS "\n";
	            }
	          }  else {
              # print non-file GDS structures as is
              print OUT_GDS "$MyGDS{$gds_key}{text}";
              }  
	    }
	    close OUT_GDS;
	    }
	    elsif ($gsr_key =~ m/PACKAGE_SPICE_SUBCKT/) {
	      	# $file points to package wrapper
	      	# copy/process package wrapper - modify lines starting with .inc
	      	edaOpenFile(IN_PKG, "$file", "r");
		edaMsg("Creating send2apache/design_data/$target_dir/$basename");
		edaOpenFile(OUT_PKG, "send2apache/design_data/$target_dir/$basename", "wf");
		while(<IN_PKG>) {
			# ignore comments
			if(/^\s*\*/) { print OUT_PKG $_;next;}
			if(/^.inc.*/) {
				chomp;
				split;
				$inc_file = $_[1];
				if (-r "$cmd_dirname/$inc_file") {
					$inc_file_abs = edaConvertToAbsolutePath("$cmd_dirname/$inc_file");
	  			} elsif (-r "$inc_file") {
					$inc_file_abs = edaConvertToAbsolutePath("$inc_file");
	  			} 
				$inc_basename = basename($inc_file_abs);
	  			edaExecute("\\ln -s $inc_file_abs send2apache/design_data/$target_dir");
				$total_byte_count += (stat("$inc_file_abs"))[7];
				print OUT_PKG "$_[0] ../design_data/$target_dir/$inc_basename \n";
				next;
			}
			print OUT_PKG $_;		
	      	}
		close OUT_PKG;
	      	print OUT_GSR "../design_data/$target_dir/$basename ";
	    } else {
	      # All non-gds, but file related keywords
	      edaExecute("\\ln -s $file send2apache/design_data/$target_dir/$basename");
	      $total_byte_count += (stat($file))[7];
	      print OUT_GSR "../design_data/$target_dir/$basename ";
	    }
	  
	} elsif (-l $word) {
	  # unreadable link...
          if($debugMode) {
		print "DEBUG:word=$word is an unreadable link!\nPlease check file permission with ls -l -L <file>\n";
	  }
	  edaError("Link '$word' is broken!");
        } elsif (-l "$cmd_dirname/$word") {
	  # unreadable link...
          if($debugMode) {
		print "DEBUG:$cmd_dirname/$word is an unreadable link!\nPlease check file permission with ls -l -L <file>\n";
	  }
	  edaError("Link '$word' is broken!");
        } else {
	  # Even though this word appears inside *_FILE section, it's not a file - print as is
          if($gsr_key =~ m/EM_NET_INFO/) {
                if($debugMode) {
		print "DEBUG:$cmd_dirname/$word is an unreadable file!\nPlease check for the existence of file\n";
                } else {print "Please run with debug mode using \"-d\" option for detailed error message\n";}
	  edaError("File '$word' is not present!");
          }
	  print OUT_GSR "$word ";
	}

	$prev_word = $word;
      }
      print OUT_GSR "\n";
    }
  } else {
    # print non-file GDS structures as is
    print OUT_GSR "$MyGSR{$gsr_key}{text}";
  }
}
close OUT_GSR;

# Form the name of the tar file: <design>.<username>.<domain>.<day><month><year>
# Determine the name of the top block from DEF_FILES section
foreach $line (split("\n",$MyGSR{DEF_FILES}{text})) {
  $line =~ s/\{//; $line =~ s/\}//;
  @Line = split(" ",$line);
  if ($#Line eq 1) {
    if ($Line[1] eq "top") {
      if($Line[0] !~ /^\s*\//) {
      	$design_name = edaGetDefDesignName("$cmd_dirname/$Line[0]");
      }
      else {
      	$design_name = edaGetDefDesignName("$Line[0]");
      }
    }
  }
}


$domain = `hostname -y`;
chomp($domain);
$domain =~ s/\.com//;
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$year +=1900;
$mon =("jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec")[($mon)];
my $tar_name = $design_name.".".$ENV{USER}.".".$domain.".".$mday.$mon.$year;

$total_kbyte_count = $total_byte_count/1024;
print "\nTotal size of data to be bundled - $total_byte_count bytes\n";

# Do actual tarring, then remove temporary directory

$date = getDate();
#$copy2dir = edaConvertToAbsolutePath($copy2dir);


# Local copying
# If user specified "-copy <directory>"
if ($copy2dir ne "") {
  
$copy2dir = edaConvertToAbsolutePath($copy2dir);
  edaMsg("Copying to local directory - $copy2dir");
  chdir("send2apache");
  edaExecute("tar cfhz - run design_data |(cd $copy2dir; tar xfzBp -)");
  
  # Remove temporary directory
  edaExecute("\\rm -rf send2apache");
  chdir("..");
  
  exit;
}

chdir("send2apache");
# Main usage mode - tarring and ftp'ing
my $compressed_file = "";
if($tar){
edaMsg("\nStarted tarring of $tar_name on $date");
edaExecute("tar cvfhz $tar_name.tgz run design_data"); 
$compressed_file = "$tar_name.tgz";
}

if($zip){
edaMsg("\nStarted zipping $tar_name on $date");
edaExecute("zip -r $tar_name.zip run design_data");
$compressed_file = "$tar_name.zip";
}

# Put tar file on Apache ftp
if($ftp){
$date = getDate();
edaMsg("\nStarted uploading of $compressed_file to Apache ftp on $date");
edaExecute("ftp -n ftp.apache-da.com << EOF
quote user anonymous
quote pass a\@b.com
passive
cd incoming
bin
hash
put $compressed_file
bye
EOF");

# Report file informaition
$date = getDate();
@FileStat = stat("$compressed_file");
$size = @FileStat[7];
print "
############################################################################
Finished uploading data to Apache ftp on $date
File name - $compressed_file
File size - $size bytes
please email this message to Apache AE!
############################################################################
";
chdir("..");

# Remove temporary directory
edaExecute("\\rm -rf send2apache");
exit;
}
if ($notar == 1) {
  print "\nStopped before actual tarring and ftp'ing.
 To manually tar the data do:
  cd send2apache
  tar cvfhz $tar_name.tgz run design_data  
 To manually zip the data do:
  cd send2apache
  zip -r $tar_name.zip run design_data
";

exit;
}
BEGIN {

  sub getDate {
    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    $mon =("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")[($mon)];
    $year += 1900;
    if ($hour < 10) {$hour = "0$hour";}
    if ($min < 10) {$min = "0$min";}
    if ($sec < 10) {$sec = "0$sec";}

    return("$hour:$min:$sec $mday $mon $year");
  }

  # Given a text file - return all words which are files themselves
  sub getFileNamesInTheFile {
    my $file = shift(@_);
    my %FileList = ();
    if($debugMode) {
		print "DEBUG:Reading file $file for getting wrods which are filenames!\n";
    }
    edaOpenFile(CMD, "$file", "r");
    while (<CMD>) {
      chomp($_);
      # Skip comment and empty lines
      if (($_ =~ m/^\s*\#.*/) or ($_ =~ m/^\s*$/)) {
	next;
      }

      # Remove leading,trailing,multiple spaces
      $line = edaCleanLine($_);

      # Check which words are files, detect broken links
      foreach $word (split(" ",$line)) {
	# If file is readable - add it to a list
	if($debugMode) {
		print "DEBUG:word=$word!\n";
	}
	if (-r $word) {
	  $FileList{$word} = 1;
	} elsif (-l $word) {
	  if($debugMode) {
		print "DEBUG:word=$word : gves an unreadable link!\nPlease check file permission with ls -l -L <file> command.\n";
	}
	  edaError("Link '$word' is broken!");
	}
      }
    }
    close CMD;  
    return(keys(%FileList));
  }
sub resolveSameBaseName {					
$file_new = $_[1];
$file_old = $_[0];

(my $basenameold = $file_old) =~ s!^.*/!!;

my $count = 0;
#$basename = "${basenameold}_${count}";

while (-e "send2apache/design_data/$target_dir/$basename") {
if ( comparefilesize("send2apache/design_data/$target_dir/$basename", "$file_new") == 0) {
$count++;
 if ($basenameold =~ m/(.*)\.gz/) {
  $basename = "$1_${count}.gz";
 } else {
 $basename = "${basenameold}_${count}";
 }
} else {
last;
}
}
return($basename);
}
sub comparefilesize {

$file_new = $_[1];
$file_old = $_[0];
if ( -l "$file_old") {
($file_old = `ls -lrt $file_old`) =~ s!.* (.*)\n!\1! ;
}
#($size_old = `wc -l $file_old`) =~ s!(\d*).*!\1!;
if ( -l "$file_new") {
($file_new = `ls -lrt $file_new`) =~ s!.* (.*)\n!\1! ;
}
#($size_new = `wc -l $file_new`) =~ s!(\d*).*!\1!;
$diff_out = `diff $file_new $file_old`;
if ( $diff_out) {
return(0);
} else {
return(1);
}
}
}



