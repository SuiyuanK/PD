eval '(exit $?0)' && eval 'exec perl -w -S $0 ${1+"$@"}'
    && eval 'exec perl -w -S $0 $argv:q'
    if 0;
	
##################################################################################
# Name       : pwcapxck.pl
# Description: A script to read a CPM model and instance it in a SPICE deck for AC 
#              or tranisent analysis.
# $Revision  : 1.1 $
# Author     : Jeffrey Smith
# Created    : 9/28/07
# Copyright (c) 2007 by Apache Design Solutions, Inc. All rights reserved.
# 
# Revision History
#
# Rev 1.0
#  - Initial release. 
#
##################################################################################

=head1 NAME

cpm2spice.pl - Read a CPM model and create a SPICE deck for detailed analsys

=head1 SYNOPSIS

cpm2spice.pl [options] arguments

Options: -h, -help, -man, -verbose -debug
  
Arguments: -cpm cpm_input_file, -sp spice_output_file

=head1 DESCRIPTION

cpm2spice.pl reads an input CPM file (-cpm), parses the embedded Chip Package Protocol
(CPP) section, and (using the CPP port information) creates an output spice netlist (-sp)
suitable for analysis of the CPM model. The output deck supports both AC analysis 
(for determining Rdie and Cdie) as well as a transient analysis (for checking the 
current profile of the entire die as well as each partition). Note: the output
deck has default parameters for both the AC and tranisent analysis. You should
edit the output file and set these parameters to your needs.

=head1 OPTIONS

=over 

=item -h

Prints a short synopsis.

=item -help

Prints a synopsis and a description of program options and arguments.

=item -man

Prints the entire man page.

=item -debug

Prints debug info to the log.

=item -verbose

Prints verbose debug/log info.

=head1 ARGUMENTS

=item -cpm cpm_input_file

The path to the input CPM model. 

=item -sp spice_output_file

The path to the output SPICE deck. Don't forget to edit the simulation parameters!

=back

=head1 EXAMPLES

1. Read a CPM model and create a top level SPICE deck for CPM analysis-

=over 

cpm2spice.pl -cpm ./CPM_4x4_model.sp -sp ./top.sp

=back

=head1 COPYRIGHT

COPYRIGHT (c) 2007 Apache Design Solutions. All right reserved.

=cut

use strict;
use warnings;
use diagnostics;
use Getopt::Long;
use Pod::Usage;

# define script command line options
my $opt_h		='';		# short help
my $opt_help	='';		# long help
my $opt_man		='';		# man page
my $opt_verbose	='';		# verbose output mode
my $opt_debug	='';		# debug output mode
my $opt_cpm		='';		# input cpm file 
my $opt_sp	 	='';		# output spice file

# program vars
my $cpp=0;					# fag to start scanning CPM file
my %cpp;					# a hash to hold the cpp data
my $domain;					# the power domain
my $hash;					# hash pointer
my $line_number=0;			# line number for input file
my $node;					# a node name
my %ports;					# hash to hole port info
my %domains;				# hash to hold domain names
my $port;					# a single port
my $partition;				# a single partition
my $subckt=0;				# flag
my $subckt_ports="";		# list of ports

# begin main program...

# get input options..
GetOptions(	'h'       => \$opt_h,
			'help'    => \$opt_help,
			'man'     => \$opt_man,
			'verbose' => \$opt_verbose,
			'debug'   => \$opt_debug,
			'cpm=s'   => \$opt_cpm,
			'sp=s'    => \$opt_sp ) or pod2usage(0);
							
# a little documentation for the user...				
pod2usage (-exitval => 0, -verbose => 2) if $opt_man;
pod2usage (-exitval => 0, -verbose => 1) if $opt_help;
pod2usage (-exitval => 0, -verbose => 0) if $opt_h;
		
# check for required arguments...	
if (!($opt_cpm and $opt_sp)) { pod2usage(-exitval => 1, -verbose => 0) };

# open the input file...
open (CPM, "<$opt_cpm") or die "ERROR  : Cannot open input CPM file \"$opt_cpm\": $!. Aborting!\n";

# open the input file...
open (SP, ">$opt_sp") or die "ERROR  : Cannot open output SPICE deck \"$opt_sp\": $!. Aborting!\n";

print "INFO   : Reading CPM model \"$opt_cpm\"...\n";

while (<CPM>) {

	++$line_number;

	# look for the beginning or the chip package protocol
	if (!$cpp and /^\s*\*\s*Begin\s+Chip\s+Package\s+Protocol\s+--->/i) { 
	
		# status info...
		print "INFO   : Chip Package Protocol starts at line $line_number...\n";
	
		# found start of Chip Package Protocol...
		$cpp = 1;
		
		next;
		
	} elsif ($cpp and /^\*\s*End\s+Chip\s+Package\s+Protocol\s+<---/i) {
	
		# debug info...
		print "INFO   : Chip Package Protocol ends at line $line_number...\n";
		
		# found end of Chip Package Protocol...
		$cpp = 0;
		
		next;
		
	} elsif (!$cpp and /^\s*\.subckt\s+adsPowerModel(.*)/i) {
	
		# grab the ports of the power model
		$subckt = 1;
		
		# if there are ports on this line save 'em
		if ($1) { # we got ports so add a line feed
		
			$subckt_ports = $1;
			chomp ($subckt_ports);
			$subckt_ports .= "\n";

		} else { # no ports on this line, need a line feed anyway...
		
 			$subckt_ports = "\n";
		}
		
		# debug info...
		if ($opt_debug) { print "DEBUG  : Subcircuit \"adsPowerModel\" found at line $line_number.\n" };	

	
	} elsif ($subckt) {
		
		if (/(^\+\s*.+)/) { # this is a continuation line
		
			$subckt_ports = $subckt_ports . $1 . "\n";
			
		} else {
	
			# debug output
			if ($opt_debug) { print "DEBUG  : Subckt \"adsPowerModel\" ports end at line $line_number. The extracted ports are- $subckt_ports\n"};
			
			# end of subckt ports	
			$subckt = 0;
		}
	} 
		
		
	if ($cpp) {
	
		# check for a properly formented CPP line
		if (/^\*\s*\S+\s+\:\s+\(.+\)\s+\:\s+(\S+)\s+\=\s+(\S+)_(\S+)\s*$/) {		
		
			# verbose debug info...
			if ($opt_debug and $opt_verbose) { print "DEBUG  : CPP fields at line $line_number are port = $1, partition = $2, and domain = $3.\n"};	

			# save the info...
			if (!exists $ports{$1}) { # save this port 
			
				$ports{$1} = {};
				$ports{$1}->{partition} = $2;
				$ports{$1}->{domain} = $3;
				
			} else { # port consistency checks...
			
				if ($ports{$1}->{partition} ne $2) { 
				
					print "WARNING: Partition $2 defined at line $line_number for port $1 differs from the partition defined in previous lines. Ignored!\n";
				}
				
				if ($ports{$1}->{domain} ne $3) { 
				
					print "WARNING: Domain $3 defined at line $line_number for port $1 differs from the domain defined in previous lines. Ignored!\n";
				}
			}

			if (!exists $domains{$3}) { # save this domain
			
				$domains{$3} = '';
			}
			 
		} else { # bad CPP line...
	
			print "WARNING: Difficulty parsing line number $line_number - his line not proper CPP format. Skipped!\n";
		}	
	}
}	

# status...
print "INFO   : Creating output SPICE deck \"$opt_sp\"...\n";

# write the header to the output file
print SP <<"HEADER";
*** CPM analysis deck for $opt_cpm 

*** options...
.option post

*** the CPM model...
.include $opt_cpm

*** simulation parameters (edit to your liking)...
.param Vsupply=1.0
.param Vshort=0.0
.param Freq_Step=10
.param Freq_Start=10Meg
.param Freq_Stop=50G
.param Tran_Time=10nS
.param Tran_Step='Tran_Time/1000'

* port assignments (taken from the Chip Package Protocol)
* port : partition : domain
HEADER

# write out the ports and associated partition and domain
foreach $port (sort keys %ports) {

	print SP "* $port : $ports{$port}->{partition} : $ports{$port}->{domain}\n";
	
}

print SP "\n* supplies for each partition...\n";

# write out the sense supplies
foreach $port (sort keys %ports) {
	
	print SP "V_$ports{$port}->{domain}_$ports{$port}->{partition} $port $ports{$port}->{domain} Vshort\n";
	
}

# cerate a supply for each doamin

print SP "\n*** domain power supplies\n";

foreach $domain (sort keys %domains) {

	if ($domain =~ /vdd/i or $domain =~ /vcc/i) {

		print SP "V_$domain ${domain}_sense 0 DC Vsupply AC '-0.1*Vsupply' \n";
		print SP "V_${domain}_sense ${domain}_sense $domain Vshort\n";
	}
	
	if ($domain =~ /vss/i or $domain =~ /gnd/i) {

		print SP "V_$domain ${domain}_sense 0 0\n";
		print SP "V_${domain}_sense ${domain}_sense $domain 0\n";
	}	
	
}


print SP <<"INST";

*** instance of CPM model
X_CPM${subckt_ports}+ adsPowerModel

*** do the analysis
.op
.ac dec 'Freq_Step' 'Freq_Start' 'Freq_Stop'
.tran 'Tran_Step' 'Tran_Time'

INST

print SP "*** print out magnitude and phase of all supplies\n";

foreach $domain (sort keys %domains) {

	if ($domain =~ /vdd/i or $domain =~ /vcc/i) {

		print SP ".print AC Zm_$domain='vm($domain)/im(V_$domain)'  Zp_$domain='vp($domain)-ip(V_${domain}_sense)'  Rdie_$domain='(vm($domain)/im(V_${domain}))*cos(((vp($domain)-ip(V_${domain}_sense))/360)*2*Pi)'  Cdie_$domain='-1/(((vm($domain)/im(V_$domain))*sin(((vp($domain)-ip(V_${domain}_sense))/360)*2*Pi))*2*Pi*HERTZ)'\n";
		
	}
	
}

print SP <<"END";

*** done!
.end

END

# clean up...
close CPM;
close SP;

print "INFO   : Done!\n";

# that's it!
exit;
