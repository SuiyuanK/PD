#!/usr/bin/perl

#############################################################################
# Name       : convertApacheEcoToEncounterTcl.pl
# Description:  To convert Apache ECO file after FAO into Encounter tcl commands for feedback of RedHawk FAO changes to Encounter.
# $Revision  :  1.2$
# Author     : Vinayakam Subramanian , email : vinayakam@apache-da.com
#############################################################################

#############################################################################
# Revision History
# 1.2 by Vinayakam
# - Added procedure section in man page
# 1.1 by Vinayakam
# - Added scaling factor option to scale the x,y location unit from microns
# - Created perl hash "mapOrientation" for mapping Apache orientation to Encounter orientation
# 1.0 by Vinayakam
# - Initial version
#############################################################################

=head1 NAME

convertApacheEcoToEncounterTcl.pl - To convert Apache ECO file after FAO into Encounter tcl commands for feedback of RedHawk FAO changes to Encounter.

=head1 SYNOPSIS

convertApacheEcoToEncounterTcl.pl [options] arguments

Options: -h, -help, -man , -apacheEco , -o , -scalingFactor

=head1 DESCRIPTION

B<convertApacheEcoToEncounterTcl.pl> is used to convert Apache ECO file into Encounter tcl commands. This enables the user to feedback the changes done by RedHawk FAO to Encounter.

 
=head1 OPTIONS

=over

=item -h

Prints a short synopsis.

=item -help

Prints a synopsis and a description of program options.

=item -man

Prints the entire man page. 

=item -apacheEco

Specify the Apache ECO file. Required.

=item -o

Specify the output file name of the Encounter tcl. Default : apacheEco.encounter.tcl

=item -scalingFactor

Specify the scaling factor to scale the x,y location units from microns. Default : 1


=head1 EXAMPLE

convertApacheEcoToEncounterTcl.pl -apacheEco ../redhawkFao/decapfill.eco  -o decapFao.encounter.tcl

=back

=head1 REQUIREMENTS

Just the Apache ECO file and the scaling factor for scaling the units of x,y location from microns. 

=head1 PROCEDURE

Steps for using the convertApacheEcoToEncounterTcl.pl script for feedback of Redhawk FAO changes to Encounter :

1. After decap optimization in RedHawk using FAO feature, generate the eco file from redHawk in Apache format using the command "export eco <filename>.eco"
Eg: RedHawk> export eco voltageDropRepairForDesign123.eco

2. (Optional)Get the db unit from Encounter and identify the scaling factor to be multiplied with value in microns.

3. Run the convertApacheEcoToEncounterTcl.pl  script to convert the Apache ECO file into an Encounter tcl command file.
Eg:  perl convertApacheEcoToEncounterTcl.pl -apacheEco voltageDropRepairForDesign123.eco   -o  redHawkIrDropRepair.encounter.tcl   -scalingFactor  1

4. Use the output file from convertApacheEcoToEncounterTcl.pl  script in Encounter.
Eg : Encounter> source  redHawkIrDropRepair.encounter.tcl 

=head1 AUTHOR

Vinayakam Subramanian , Applications Engineer, Apache India.

email : vinayakam@apache-da.com

=head1 COPYRIGHT

COPYRIGHT (c) 2007 Apache Design Solutions. All right reserved.

=cut

# end program documentation

use Getopt::Long;
use Pod::Usage;

# begin main program...

        # define script command line options
        my $opt_h   ='';            # short help
        my $opt_help='';            # long help
        my $opt_man ='';            # man page
	my $opt_apacheEco = '';
	my $opt_o = '';
	# get input options..
        GetOptions( 'h'    => \$opt_h,
                    'help' => \$opt_help,
                    'man'  => \$opt_man,
		    'apacheEco=s' => \$opt_apacheEco,
		    'scalingFactor=f' => \$opt_scalingFactor,
		    'o=s' => \$opt_o ) || pod2usage (-verbose => 0);
                                
        # a little documentation for the user...
        pod2usage (-exitval => 0, -verbose => 2) if $opt_man;
        pod2usage (-exitval => 0, -verbose => 1) if $opt_help;
        pod2usage ( -msg => "The following is the usage .\n To learn more about the options, use --help\n", -exitval => 0 , -verbose => 0) if $opt_h;
	
	# If output file was not specified, set the default output filename
	if($opt_o) {
		# $opt_o = $opt_o :) ;
	}
	else {
		$opt_o = "./apacheEco.encounter.tcl";
	}
	
	# If output file was not specified, set the default output filename
	if($opt_scalingFactor) {
		# $opt_scalingFactor = $opt_scalingFactor :) ;
	}
	else {
		$opt_scalingFactor = 1;
	}

	# if Apache ECO file was not specified, exit.
	unless($opt_apacheEco) {
		die "\nFATAL : Apache ECO file not specified!\nPlease use -apacheEco option to specify Apache ECO file as input!\n";
	}

	# if Apache ECO file does not exist, exit.
	unless( -e $opt_apacheEco ) { 
		die "\nFATAL : The apacheEco file $opt_apacheEco does not exist.\nProgram Exit!\n";
	}

	# print inputs
	print "\nGiven Inputs:\nInput Apache ECO file - $opt_apacheEco\nScaling Factor for x,y location : $opt_scalingFactor\nOutput filename - $opt_o\n";
	print "Processing.....\n";
	
	# Mapping of Apache orientation to Encounter orientation
			# N - R180
			# S - R0
			# E - R90
			# W - R270
			# FN - MX
			# FS - MY
			# FE - MX90
			# FW - MY90
	%mapOrientation = ( 	"N", "R180",
				"S", "R0",
				"E", "R90",
				"W", "R270",
				"FN", "MX",
				"FS", "MY",
				"FE", "MX90",
				"FW", "MY90"
			);

	open ECOFP , " $opt_apacheEco" or die "\nFATAL : Cannot open Apache ECO file $opt_apacheEco for reading : $!\n";
	open OUTFP ," > $opt_o" or die "Cannot open file $opt_o for writing :$!\n";
	while(<ECOFP>) {
		# print header in output file with design name
		if(/^DESIGN/) {
			chomp;
			split;
			print OUTFP "# Apache Voltage drop Repair for design $_[1]\n";
			next;
		}

		# identify units
		if(/^UNIT/) {
			chomp;
			split;
			$unit = $_[1];
		}

        	# Convert lines like this
        	# ADD    decap   DECAP_SH0  DECAP  N  2357040 5600 143360 5600
        	# to decap addition commands 
		if(/^ADD\s+decap/) {
			chomp;
			split;
			$decapInst = $_[2];
			$decapCell = $_[3];
			$orientation = $_[4];
			$xloc = $_[5]/$unit * $opt_scalingFactor ; # get location value in microns and multiply it by scaling factor
			$yloc = $_[6]/$unit * $opt_scalingFactor ;
			# print OUTFP " <encounter commands for decap addition>";
			# eg: addInst -cell BUF1 -inst i1/i2 -loc 100 200
			
			# add decap
			print OUTFP "addInst -cell $decapCell -inst $decapInst -loc $xloc $yloc -ori $mapOrientation{$orientation}\n";
			next;
		}

        	# Convert lines like this
        	# MODIFY inst   inst123  N  5754560 1136800 8960 5600
        	# to instance movement commands 
		if(/^MODIFY\s+inst/) {
			chomp;
			split;
			$inst = $_[2];
			$orientation = $_[3];
			$xloc = $_[4]/$unit * $opt_scalingFactor ;
			$yloc = $_[5]/$unit * $opt_scalingFactor ;
			# print OUTFP " <encounter commands for changing the placement of an instance>";
			# eg: placeInstance SH22/I40 1500.3 980.3 MY
			# Specify one of the following values for orientation : R0, R90, R180, R270, MX, MX90, MY,or MY90.
						
			# move/create instance
			print OUTFP "placeInstance $inst $xloc $yloc $mapOrientation{$orientation}\n";
			next;
		}

        	# Convert lines like this
        	# DELETE inst decap123
		# to instance deletion commands
		if(/^DELETE\s+inst/) {
			chomp;
			split;
			$inst = $_[2];
			# print OUTFP " <encounter commands for deleting an instance>";
			# Eg: deleteInst i1/i2
			
			# delete instance
			print OUTFP "deleteInst $inst\n";
			next;
		}
	}


print "\nSuccessfully generated Encounter tcl command file from Apache ECO file!\nOutput filename is $opt_o!\n";

print "\nProgram Finished!\n";
