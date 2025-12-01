eval '(exit $?0)' && eval 'exec perl -w -S $0 ${1+"$@"}'
    && eval 'exec perl -w -S $0 $argv:q'
    if 0;
	
#############################################################################
# Name       : vds2avm.pl 
# Description: A script to convert Virage data sheets to avm config files
#
# $Revision  : 1.0 $
# Author     : Jeffrey Smith
# Created    : 5/08/06
# Copyright (c) 2006 by Apache Design Solutions, Inc. All rights reserved.
# 
# Revision History
#
# Rev 1.1
#  - Initial release. 
#
# Rev 1.2
#  - Fixed input options so that -d option is not required. 
#  - Updated the version numbers to agree with CVS
#
# Rev 1.3
#  - Enhanced to understand more data sheets
#  - Handles missing power dissapation table
#
# Rev 1.4
#  - Fixed infinite loop bug in getTableHash routine
#  - Added support for Static Idd in Typ/Worst case power tables
#  - Added estimate of Cpd_standby if clock power table is missing
# 
# Rev 1.5
#  - Fixed Idd leakage problem (no MegaAmp leakage values)
#
# Rev 1.6
#  - Added process output to be compatible with 5.3.X AVM
#  - Added -f option to specify fraction used in Cpd_standby estimation.
#
# Rev 1.7 
#  - Enhanced to better understand ROMs.
#
# Rev 1.8
#  - Enhanced to be better at extractiong the process corner from the -pvt 
#    option
#
##############################################################################

=head1 NAME

vds2avm.pl - converte a Virage datasheet to an AVM config file  

=head1 SYNOPSIS

vds2avm.pl [options] arguments

Options: -h, -help, -man, -l output_load, -tr output_rise_time, -tf output_fall_time, -s, -f
  
Arguments: -i data_sheet, -d working_dir, -pvt pvt_corner, -o config_file, -t memory_type, -typ|-wst

=head1 DESCRIPTION

vds2avm.pl reads a Virage data sheet and creates an AVM config file. Users 
specify the input data sheet (-i), the RedHawk working directory (-d), 
the desired Process-Voltage-Temperature corner (-pvt), the output AVM config file
name (-o), the memory type (-t), and typical (-typ) or worst case (-wst) memory power cycle 
(see the Virage datasheet for the conditions of a typical vs worst case power cycle).
If an instance of the RAM cannot be found in the RedHawk database the user must
also specify the output load (-l) and the output rise time (-tr) and fall time (-tf). 
Finally, a summary (-s) of datasheet information can be printed.

=head1 OPTIONS

=over 

=item -h

Prints a short synopsis.

=item -help

Prints a synopsis and a description of program options and arguments.

=item -man

Prints the entire man page.

=item -s

Prints a summary of the infomation found in the datasheet allowing the user 
to verify that the script is properly parsing the data sheet (highly recommended).
Also, lists the PVT corners used in the datasheet which is a required input for
generating an AVM config file.

=item -l

Used to specify an optional output load capacitance (in femto-farads) for the memory.
Necessary only if the memory is not found in the RedHawk database.

=item -tr, -tf

Used to specify the output rise (-tr) and fall (-tf) time (in nano-seconds) for the memory.
Necessary only if the memory is not found in the RedHawk database.

=item -f

Used to specify the standby power in the event it can't be determined from the data sheet.
This option specifies the fraction of the average of the READ and WRITE power that will
be assigned as the standby power. In other words, the option "-f 0.3" specifies that the
STANDBY power will be computed as 30% of the average of the READ and WRITE power.
Necessary only if the STANDBY power is not found in the memory data sheet.

=back 

=head1 ARGUMENTS

=over 

=item -i data_sheet 

The path to the Virage data sheet file. This file is the standard ascii data sheet typically
distributed with Virage memories (i.e., a ".ds" or "cds" file).

=item -d apache_dir

The path to the RedHawk working directory (the directory where the design is being 
analyzed with RedHawk).

=item -pvt corner

The PVT corner to use to generate the AVM config file. This parameter is case sensitive and should
be entered exactly as shown with the -s option.

=item -t memory_type

The type of memory that is being modeled. Valid types are SRAM, DRAM, CAM, ROM, RegFile, MSRAM, 
and IP.

=item -typ|-wst

Virage specifies both a worst case power cycle (all inputs/outputs switching) and a typical power
cycle (some inputs/outputs switching). The user specifies which type power cycle (-typ or -wst) 
should be used to compute Cpd. See the Virage data sheet for the definition of a worst case vs. 
a typical case power cycle.

=item -o config_file

The path to the output AVM config file. This file is an input to the Apache Virtual Memory
tool and is used to create current profiles for memories based on data sheet specifications.

=back

=head1 EXAMPLES

1. Print a summary of the infomation found in the datasheet for verification by the user-

=over

vds2avm.pl -i my_ram.ds -s

=back

2. Create an AVM config file for an SRAM type memory based on the "my_ram.ds" data sheet using 
the local directory as the RedHawk working directory and using the "BEST" PVT corner assuming 
a worst case memory power cycle-

=over

vds2avm.pl -i my_ram.ds -o my_ram.cfg -d . -pvt BEST -t SRAM -wst

=back

3. Same as 2 above but the user specifies output load and rise/fall times-

=over

vds2avm.pl -i my_ram.ds -o my_ram.cfg -d . -pvt BEST -t SRAM -wst -l 500 -tf 0.05 -tr 0.05

=back

4. Same as 2 above but the user specifies that the standby power is estimated as 30%
of the average of the READ and WRITE power.

=over

vds2avm.pl -i my_ram.ds -o my_ram.cfg -d . -pvt BEST -t SRAM -wst -f 0.3

=back

=head1 COPYRIGHT

COPYRIGHT (c) 2006 Apache Design Solutions. All right reserved.

=cut
	
# packages...
use Getopt::Long;
use Pod::Usage;
# use strict;
# use warnings;
# use diagnostics;


# define script command line options
my $opt_h	  = '';			# short help
my $opt_help  = '';			# long help
my $opt_man	  = '';			# man page
my $opt_l	  = '';			# output load
my $opt_tr	  = '';			# output rise time
my $opt_tf	  = '';			# output fall time
my $opt_s	  = '';			# summary 
my $opt_i	  = '';			# input data sheet
my $opt_o	  = '';			# output config file
my $opt_pvt	  = '';			# pvt corner to be used
my $opt_d	  = '';			# RedHawk working directory
my $opt_t	  = '';			# Memory type
my $opt_f	  = '';			# fraction for computing STANDBY power
my $opt_typ	  = '';			# typ power table
my $opt_wst	  = '';			# worst case power table
my $opt_debug = '';			# debug option

# variables...
my $adr;					# name for address inputs
my $C1; 					# load caps
my $C2;
my $Cload;
my $clk;					# default name for the clock
my %clock_power;			# hash that hold clock power
my $ck2q_delay;				# ck to q delay value
my $ck2q_key;				# key for ck to q delay time
my $Cpd_read;				# Cpd read
my $Cpd_write;				# Cpd write
my $Cpd_standby;			# Cpd standby
my %corners;				# holds the position of typ, best, and worst corners
my $field;					# holds a field from a line
my @fields;					# holds the fields from a line
my $found_memory=0;			# flag indicating that the memory was found in apache DB
my $gate_count;				# equivelent gate count
my $Idd_key;				# leakage key
my $i;						# index
my $key;					# hash key
my $key0;					# hash key
my $key1;					# hash key
my $key2;					# hash key
my $label;					# holds a single lable
my @labels;					# lables for table columns
my $leakage_i;				# leakage current
my @lines;					# contains the lines from a table
my %memory;					# holds memory data
my $memory_power;			# pointer to the desired memory power hash
my $pwr_diss_key;			# power dissapation key
my $process;				# the process corner
my $q;						# default name for the output pins
my %static_power;			# holds the power diss table
my %pvt;					# pvt corner hash
my $read_key;				# read key 
my $rom_flag=0;				# indicates that the memory may be a ROM
my @rows;					# holds table rows
my @samples;				# holds the samples for a memory
my $sample;					# a single sample line
my $scale;					# scales for the dynamic power
my $section="INTRO";		# tells us which section of the data sheet we are in
my $setup_key;				# setup time key
my $standby_key;			# key used to put memory in standby mode
my $Trise; 					# rise and fall slews
my $Tfall;
my $T_setup;				# setup time
my @table;					# holds a table
my %timing;					# holds timing info
my %timing_sym;				# holds timing info with symbol keys
my %typ_power;				# holds typical power info
my $Vdd;					# Vdd value for this memory
my $Vdd_key;				# Vdd key for pvt hash
my $write_key;				# hold the write key
my %worst_power;			# holds worst power info


{	# subroutines

	# convert numbers into engineering units (like old HP calculators)
	sub eng_units($) {
		my ($str) = @_;		# the input string (number)
		my $man;			# the mantissa
		my $exp;			# the exponent
		
		# get the number in scientific notation
		$man = sprintf '%.3e', $str;
		$exp = $man;
		
		# seperate mantissa and exponent
		$man =~ s/(.*?)e(.*)/$1/;
		$exp =~ s/(.*?)e(.*)/$2/;
			
		# get an "engineering" multiplier
		while ($exp%3) {
			$man *= 10;
			--$exp 
		}
		
		# pad positive mantissias with a space for pretty columns
		if (!($man =~ /-/)) { 		# number is positive 
			$man = " " . "$man";	# pad it...
		}
			
		# return the engineering units
		return ("$man" . "E" . sprintf '%+03d',$exp);
		
	}
	
	# a test for blank strings
	sub matchKey ($ @) {
		my ($target, @keys) = @_;
		my $key;					# a single key
					
		# scan the keys for the target phrase
		foreach $key ( @keys ) {
						
			# look for the target phrase/word
			if ($key =~ /$target/i) { return $key }
		}
		
		return "";
	} 
	

	# get the next table from the input file
	sub getTable($ *) {	
		my ($input_string, $input_file) = @_;
		my @table;								# contains the lines of the table
	
		# get lines until the table is found
		until ($input_string =~ /^#/) {	
			
			# get another line
			$input_string = <$input_file>;
			
			# make sure this line is not another heading
			if ($input_string =~ /^\w+/) { # table is missing!
								
				# return current line and an empty table
				return ($input_string, ());
			}
		}
		
		# grab lines until end of the table	is found
		until (!($input_string =~ /^#/)) {
			push @table, $input_string;
			$input_string = <$input_file>;
		}
		
		# return next line and table
		return  ($input_string, @table);
		
	} # end subroutine getTable
	
	
	# get the samples from a apache.apl file
	sub getSamples($ *) {	
		my ($input_string, $input_file) = @_;
		my @samples;						# contains the lsamples
	
		# get lines until the table is found
		until ($input_string =~ /^sampling/) {	
			$input_string = <$input_file>;
		}
		
		# grab lines until end of the table	is found
		until (!($input_string =~ /^sampling/)) {
			push @samples, $input_string;
			$input_string = <$input_file>;
		}
		
		# return next line and table
		return  ($input_string, @samples);
		
	} # end subroutine getSamples
	
		
	# get the "rows" from a table
	sub getTableRows(@) {	
		my (@table) = @_;
	
		my $line;				# holds a single line from the table
		my $current_line = 0;	# index of table lines
		my $last_line = -100;	# index of last line saved
		my @rows;				# rows of the input table
		
		# scan the table pulling out "rows" that contain data
		foreach $line (@table) {
		
			# check for a line that contains "data"
			if (($line =~ /\d/) or ($line =~ /\w/)) { # this is a non-graphics line (it contains data!)
			
				if ($current_line == $last_line + 1) { # this line is a "continuation" of the last line
				
					# add the current line to the array
					push @{$rows[scalar(@rows)-1]}, $line;
					
					# save the index of the last line
					$last_line = $current_line;
				
				} else { # save this line as a row of the table
				
					# save this line as a "row"
					push @rows, [ $line ];
					
					# save index of last line
					$last_line = $current_line;
				
				}
			} 

			# bump the line count
			++$current_line;
		}
		
		# return the rows 
		return @rows;
		
	} # end subroutine getTableRows
	
	
	# get the fields from a table
	sub getRowFields($) {	
		my ($row_ptr) = @_;	# pointer to an array containing a table row
		my @fields;			# holds the fields from the row
		my $line;			# a line from an array
		my @new_fields;		# holds "extra" fileds
		my $i;				# index
		my $j;				# index
				
		# get the (first) line
		$line = $row_ptr->[0];
				
		# remove any # delimiters
		$line =~ s/[\#]//g;
			
		# remove any leading space
		$line =~ s/^\s+//;
			
		# remove any trailing space
		$line =~ s/\s+$//;
			
		# get the fields
		@fields = split /\s*\|\s*/, $line;
		
		# is this a single line row?
		if (scalar(@$row_ptr) > 1) { # this row contains multiple lines			
						
			for ($i=1; scalar(@$row_ptr) > $i; ++$i) {
						
				# get the rest of the lines
				$line = $row_ptr->[$i];
		
				# remove any # delimiters
				$line =~ s/[\#]//g;
			
				# remove any leading space
				$line =~ s/^\s+//;
			
				# remove any trailing space
				$line =~ s/\s+$//;
			
				# get the fields
				@new_fields = split /\s*\|\s*/, $line;
				
				# add the new fields to the existing fields
				for ($j=0; scalar(@new_fields) > $j; ++$j) {
				
					# add the new field if not empty
					if ($new_fields[$j]) { 
				
						$fields[$j] = $fields[$j] . " " . $new_fields[$j];
					}
					
				}
			}
		}

		# return the result
		return (@fields);
		
	} # end subroutine getRowFields 
	

	# generat a hash from a table (using description as keys)
	sub getDescTableHash(@) {	
		my (@table) = @_;
		
		my @labels;				# holds the labels of a table
		my $row;				# holds a row line (pointer)
		my @rows;				# holds the rows of a table
		my %hash;				# holds result
		my $hash_ptr;			# a hash pointer
		
		# empty tables return empty hashes
		if (!@table) { return %hash };
		
		# get the rows from the table
		@rows = getTableRows(@table);	
			
		# first row contains table labels 
		@labels = getRowFields($rows[0]);	
			
		# remove the first row (rest are field values)
		shift @rows;		
			
		# build the hash containing the table values
		foreach $row (@rows) {
						
			# get the fields from this row
			@fields = getRowFields($row);
								
			# get a hash for this line
			$hash_ptr = {};
				
			# save the fields for this line
			for ($i=1; $i < scalar(@labels); ++$i) {
				
				$hash_ptr->{"$labels[$i]"} = "$fields[$i]";	
				
			}
				
			# save this line on the hash
			$hash{"$fields[0]"} = $hash_ptr;
		}
			
		# return the hash
		return (%hash);
			
	} # end subroutine getDescTableHash 


	# generat a hash from a table (using Symbols as keys)
	sub getSymTableHash(@) {	
		my (@table) = @_;
		
		my @labels;				# holds the labels of a table
		my $row;				# holds a row line (pointer)
		my @rows;				# holds the rows of a table
		my %hash;				# holds result
		my $hash_ptr;			# a hash pointer
		
		# empty tables return empty hashes
		if (!@table) { return %hash };		
		
		# get the rows from the table
		@rows = getTableRows(@table);	
			
		# first row contains table labels 
		@labels = getRowFields($rows[0]);	
			
		# remove the first row (rest are field values)
		shift @rows;		
			
		# build the hash containing the table values
		foreach $row (@rows) {
						
			# get the fields from this row
			@fields = getRowFields($row);
								
			# get a hash for this line
			$hash_ptr = {};
				
			# save the fields for this line
			for ($i=1; $i < scalar(@labels); ++$i) {
				
				$hash_ptr->{"$labels[$i]"} = "$fields[$i]";	
				
			}
				
			# save this line on the hash
			$hash{"$fields[1]"} = $hash_ptr;
		}
			
		# return the hash
		return (%hash);
			
	} # end subroutine getSymTableHash 


	# generat a hash from a power table
	sub getPowerTableHash(@) {	
		my (@table) = @_;
		
		my @pvts;				# holds the pvt points
		my @modes;				# holds the memory modes (RD/WR)
		my $row;				# holds a row line (pointer)
		my @rows;				# holds the rows of a table
		my %hash;				# holds result
		my $hash_ptr;			# a hash pointer

		# empty tables return empty hashes
		if (!@table) { return %hash };
		
		# get the rows from the table
		@rows = getTableRows(@table);	
			
		# first row contains table pvt corners 
		@pvts = getRowFields($rows[0]);
		
		# just keep pvt columns	
		shift @pvts;
				
		# remove first row (pvt labels)
		shift @rows;	
		
		# next row contains table memory mode (RD/WR) 
		@modes = getRowFields($rows[0]);	
		
		# just keep mode columns	
		shift @modes;
					
		# remove next row (mode labels)
		shift @rows;					
					
		# build the hash containing the table values
		foreach $row (@rows) {
																		
			# get the fields from this row
			@fields = getRowFields($row);
														
			# get a hash for this line
			$hash_ptr = {};
				
			# save the fields for this line
			for ($i=0; $i < scalar(@pvts); ++$i) {
						
				if ($fields[0]=~/static\s+idd/i) { # this row contains static Idd numbers!
									
					# what format is static Idd in? 
					if ((scalar(@fields)-1) == scalar(@modes)) { # there is a static Idd for each mode
										
						$hash_ptr->{"$pvts[$i]"} = {
													"$modes[(2*$i)]"   => "$fields[(2*$i)+1]",
													"$modes[(2*$i)+1]" => "$fields[(2*$i)+2]"
													};						
					} else { # assume there is a static Idd for each PVT
										
						$hash_ptr->{"$pvts[$i]"} = $fields[$i+1];	
						
					}												
			
				} else { # this is a non static Idd row so one value per mode
				
					# things like ROMS only have one mode (RD) per PVT point
					if (scalar(@pvts) == scalar(@modes)) { 
										
						$hash_ptr->{"$pvts[$i]"} = {
													"$modes[($i)]"   => "$fields[($i)+1]"
												   };						
					
					} else { # assume there are two modes per PVT point
									
					$hash_ptr->{"$pvts[$i]"} = {
												"$modes[(2*$i)]"   => "$fields[(2*$i)+1]",
												"$modes[(2*$i)+1]" => "$fields[(2*$i)+2]"
												};	
					}	
				}
			
			}
			
			
			# save this line on the hash
			$hash{"$fields[0]"} = $hash_ptr;
		}
			
		# return the hash
		return (%hash);
			
	} # end subroutine getPowerTableHash 


	# generat a hash from a power table
	sub getPowerTable2Hash(@) {	
		my (@table) = @_;
		
		my @pvts;				# holds the pvt points
		my $mode;				# holds the memory mode (read/write/disable)
		my $row;				# holds a row line (pointer)
		my @rows;				# holds the rows of a table
		my %hash;				# holds result
		my $hash_ptr='';		# a hash pointer
		my $hash_ptr1='';		# another hash pointer

		# empty tables return empty hashes
		if (!@table) { return %hash };		
		
		# get the rows from the table
		@rows = getTableRows(@table);	
			
		# first row contains table pvt corners 
		@pvts = getRowFields($rows[0]);
		
		# just keep pvt columns	
		shift @pvts;
			
		# remove first row (pvt labels)
		shift @rows;	
		
		# scan the rest of the table
		foreach $row (@rows) {
			
			# get the fields from this row
			@fields = getRowFields($row);						
				
			# description line or real data?
			if ( $fields[0] =~ /desc/i )  {
			
				# if the hash is defined save it 
				if ( $hash_ptr ) { $hash{"$mode"} = $hash_ptr; }
			
				# grab the mode from this line
				$mode = $fields[1];	
				
				# get a hash for this line
				$hash_ptr = {};					
									
				next;
				
			} else {
				
				
				# get a hash for the line
				$hash_ptr1 = {};
				
				# save the fields for this line
				for ($i=0; $i < scalar(@pvts); ++$i) {
				
					$hash_ptr1->{"$pvts[$i]"} = "$fields[$i+1]";
				}
				
				# save this line
				$hash_ptr->{"$fields[0]"} = $hash_ptr1;
				
			}
		}
		# if the hash is defined save it before the exit
		if ( $hash_ptr ) { $hash{"$mode"} = $hash_ptr; }
		
		# return the hash
		return (%hash);
			
	} # end subroutine getPowerTable2Hash 


	# dump the various hashes
	sub dumpHashes() {	

		# user status
		print "DEBUG  : Memory hash-\n";
		foreach $key ( keys %memory ) {
			print "            {$key} = $memory{$key}\n";
		}
	
		print "\nDEBUG  : PVT hash-\n";
		foreach $key0 ( keys %pvt ) {
	
			foreach $key1 ( keys %{$pvt{$key0}} ) {
				print "            {$key0}{$key1} = $pvt{$key0}->{$key1}\n";
		
			}
		}
	
		print "\nDEBUG  : Timing hash-\n";
		foreach $key0 ( keys %timing ) {
	
			foreach $key1 ( keys %{$timing{$key0}} ) {
				print "            {$key0}{$key1} = $timing{$key0}->{$key1}\n";
		
			}
		}
		
		print "\nDEBUG  : Timing hash (using symbols)-\n";
		foreach $key0 ( keys %timing_sym ) {
	
			foreach $key1 ( keys %{$timing_sym{$key0}} ) {
				print "            {$key0}{$key1} = $timing_sym{$key0}->{$key1}\n";
		
			}
		}
		
		print "\nDEBUG  : Static power hash-\n";
		foreach $key0 ( keys %static_power ) {
	
			foreach $key1 ( keys %{$static_power{$key0}} ) {
				print "            {$key0}{$key1} = $static_power{$key0}->{$key1}\n";
		
			}
		}	
		print "\nDEBUG  : Typical case power hash-\n";
		foreach $key0 ( keys %typ_power ) {
	
			foreach $key1 ( keys %{$typ_power{$key0}} ) {
		
				foreach $key2 ( keys %{$typ_power{$key0}->{$key1}} ) {
					print "            {$key0}{$key1}{$key2} = $typ_power{$key0}->{$key1}{$key2}\n";
				
				}
			}
		}	
	
		print "\nDEBUG  : Worst case power hash-\n";
		foreach $key0 ( keys %worst_power ) {
	
			foreach $key1 ( keys %{$worst_power{$key0}} ) {
		
				foreach $key2 ( keys %{$worst_power{$key0}->{$key1}} ) {
					print "            {$key0}{$key1}{$key2} = $worst_power{$key0}->{$key1}{$key2}\n";
				
				}
			}
		}
		
		
		print "\nDEBUG  : Clock power hash-\n";
		foreach $key0 ( keys %clock_power ) {
	
			foreach $key1 ( keys %{$clock_power{$key0}} ) {
		
				foreach $key2 ( keys %{$clock_power{$key0}->{$key1}} ) {
					print "            {$key0}{$key1}{$key2} = $clock_power{$key0}->{$key1}{$key2}\n";
				
				}
			}
		}
		
	} # end subroutine dumpHashes
	
	
	# get the fields from a line
	sub  getFields(@) {	
		my ($string) = @_;	# input string

			# remove any leading space
			$string =~ s/^\s+//g;
			
			# remove any trailing space
			$string =~ s/\s+$//g;

			# get the fields
			my @fields = split /\s+/, $string;

			# return the result
			return (@fields);
		
	} # end subroutine getFields 
	
	
	# get the fields from a spec line
	sub getSpecFields(@) {	
		my ($string) = @_;	# input string

			# remove any leading space
			$string =~ s/^\s+//g;
			
			# remove any trailing space
			$string =~ s/\s+$//g;

			# get the fields
			my @fields = split /\s*\:\s*/, $string;

			# return the result
			return (@fields);
		
	} # end subroutine getSpecFields 


	# get the fields from a table
	sub  getTableFields($) {	
		my ($string) = @_;	# input string

			# remove any # delimiters
			$string =~ s/[\#]//g;
			
			# remove any leading space
			$string =~ s/^\s+//;
			
			# remove any trailing space
			$string =~ s/\s+$//;
			
			# get the fields
			my @fields = split /\s*\|\s*/, $string;

			# return the result
			return (@fields);
		
	} # end subroutine getTableFields 
	
	
	# get the rise/fall times from a sample
	sub  getSlews($) {	
		my ($string) = @_;	# input string
		my @fields;			# fields of the incoming sample

			# get the fields
			@fields = split /\s+/, $string;

			return ($fields[1],$fields[2]);
		
	} # end subroutine getSlews 
		
	
	# get the rise/fall times from a sample
	sub  getLoads($) {	
		my ($string) = @_;	# input string
		my @fields;			# fields of the incoming sample

			# get the fields
			@fields = split /\s+/, $string;

			return ($fields[3],$fields[5]);
		
	} # end subroutine getLoads 
	
	# determine the scale for dynamic power to convert to watts/Hz
	sub scale($) {
		my ($key) = @_;		# the hash key with embedde units
		my $units;			# units extracted from the key
		my $numerator;		# units numerator
		my $denominator;	# units denominator
		
		# grab the units
		$units = $key;
		
		# remove everting before/after the parenthesis
		$units =~ s/^.*?\(//;
		$units =~ s/\).*?$//;
		
		# no leading space
		$units =~ s/^\s+//;
		
		# no trailing space
		$units =~ s/\s+$//;
		
		# is this a ratio?
		if ($units=~/\//) { # contains a slash so assume it's a ratio
		
			# get the numerator/denominator	
			$numerator   = $denominator = $units;
			$numerator   =~ s/\/.*$//;
			$denominator =~ s/^.*\///;
		
		} else {
		
			# get the numerator and default denominator	
			$numerator   = $units;
			$denominator = " ";		
			
		} 
		
		# compute/return the scale
		return (getMultiplier($numerator)/getMultiplier ($denominator));
		
	}
		
	# scans a string for standard "multipliers" and returns the multiplier value
	sub getMultiplier ($) {
		my ($string) = @_;		
		
		
		if    ($string =~ /^T/)    { return (1e+12) }
		elsif ($string =~ /^G/)    { return (1e+09) }
		elsif ($string =~ /^M/)    { return (1e+06) }
		elsif ($string =~ /^K/i)   { return (1e+03) }
		elsif ($string =~ /^m/)    { return (1e-03) }
		elsif ($string =~ /^u/)    { return (1e-06) }
		elsif ($string =~ /^n/)    { return (1e-09) }
		elsif ($string =~ /^p/)    { return (1e-12) }
		elsif ($string =~ /^f/)    { return (1e-15) }
		else                       { return (1)     }

	} # end subroutine getMultiplier


} # end subroutines

# begin main program...
{

	# get user input options..
    GetOptions(	'h'       => \$opt_h,
				'help'    => \$opt_help,
				'man'     => \$opt_man,
				'l=s'     => \$opt_l,
				'tr=s'    => \$opt_tr,
				'tf=s'    => \$opt_tf,
				's'       => \$opt_s,	
				'i=s'     => \$opt_i,
				'o=s'     => \$opt_o,
				'pvt=s'   => \$opt_pvt,
				'd=s'     => \$opt_d,
				't=s'     => \$opt_t,
				'f=s'     => \$opt_f,
				'typ'     => \$opt_typ,
				'wst'     => \$opt_wst,
				'debug'   => \$opt_debug ) or pod2usage(0);
								
	# a little documentation for the user...				
	pod2usage (-exitval => 0, -verbose => 2) if $opt_man;
	pod2usage (-exitval => 0, -verbose => 1) if $opt_help;
	pod2usage (-exitval => 0, -verbose => 0) if $opt_h;
			
	# check for required input options
	if (!((($opt_i and ($opt_d  or ($opt_l and $opt_tr and $opt_tf)) and $opt_pvt and $opt_o and ($opt_typ or $opt_wst)) or ($opt_i and $opt_s)))) { pod2usage(-exitval => 1, -verbose => 0) }
	if (!$opt_t) { 
		$opt_t = "SRAM";
		print "WARNING: No memory type specified. Assuming \"SRAM\" as default.\n";
	}
	if (!(($opt_t =~/SRAM/i) or ($opt_t =~/DRAM/i) or ($opt_t =~/CAM/i) or 
	      ($opt_t =~/ROM/i)  or ($opt_t =~/RegFile/i) or ($opt_t =~/MSRAM/i)or ($opt_t =~/IP/i))) {
		
		print "ERROR  : Illegal value for -t option: \"$opt_t\". Aborting!\n";
		pod2usage (-exitval => 0, -verbose => 0);
		exit;
	}
	
	# save the memory type
	$memory{TYPE} = uc($opt_t);
	
	# open the input file
	open (DATA_SHEET, "<$opt_i") or die "ERROR  : Cannot open input data sheet file \"$opt_i\": $!. Aborting!\n";
	
	# open the output file if specified
	if ($opt_o) {
		open (CONFIG_FILE, ">$opt_o") or die "ERROR  : Cannot open output config file \"$opt_o\": $!. Aborting!\n";
	}
	
	# get the first line
	$_ = <DATA_SHEET>;
	
	# some status
	print "INFO   : Reading the datasheet...\n";
	
	# read the data sheet
	while (defined ($_)){
					
		# note the various sections as they go by...
		if    (/^Description\s*:/i) { 
			if ($opt_debug) { print "DEBUG  : Found \"Descriptions\" section...\n"; }
			$section = "DESCRIPTION"
		}
		elsif (/^.*?Features\s*:/i) { 
			if ($opt_debug) { print "DEBUG  : Found \"Features\" section...\n"; }
			$section = "FEATURES"
		}
		elsif (/^Output Ports\s*:/i) { 
			if ($opt_debug) { print "DEBUG  : Found \"Output Ports\" section...\n"; }
			$section = "OUTPUT PORTS"
		}
		elsif (/^Input Ports\s*:/i) { 
			if ($opt_debug) { print "DEBUG  : Found \"Input Ports\" section...\n"; }
			$section = "INPUT PORTS"
		}
		elsif (/^Operating\s+Conditions\s*$/i) { 
			if ($opt_debug) { print "DEBUG  : Found \"Operating Conditions\" section...\n"; }
			$section = "OPERATING CONDITIONS"
		}
		elsif ((/^Read.*?Write\s+Cycle\s+Timing[s]*\s*$/i) or (/^timing\s*\(\)$/i) or (/^Read\s+Cycle\s+Timing[s]*\s*$/i)) { 
			if ($opt_debug) { print "DEBUG  : Found \"Read/Write Cycle Timing\" section...\n"; }
			$section = "TIMING"
		}
		elsif (/^power\s+dissipation/i) { 
			if ($opt_debug) { print "DEBUG  : Found \"Power Dissapation\" section...\n"; }
			$section = "STATIC POWER"
		}
		elsif (/^typical\s+power\s+cycle/i) { 
			if ($opt_debug) { print "DEBUG  : Found \"Typical Power Cycle\" section...\n"; }
			$section = "TYP POWER CYCLE"
		}
		elsif (/^worst\s+power\s+cycle/i) { 
			if ($opt_debug) { print "DEBUG  : Found \"Worst Power Cycle\" section...\n"; }
			$section = "WORST POWER CYCLE"
		}
		elsif ((/^clock\s+read.+?write.+?disable/i) or 
              (/^clock\s+write.+?disable/i) or 
			  (/^clock\s+read.+?disable/i)) { 
			if ($opt_debug) { print "DEBUG  : Found \"Clock, Read, Write, Disable\" section...\n"; }
			$section = "CLOCK PWR"
		}
	
		# look for specific data in each section
		if ($section eq "INTRO") { # grap various data from the intro section
		
			if (/^Memory Name\s*:/) {	# get the memory name
				@fields = getSpecFields($_);
				$memory{"NAME"} = $fields[1];
				
				# check the name to see if this look like a ROM
				if ($memory{"NAME"} =~ /ROM/i) { $rom_flag = 1 };

			}
			
			if (/^Memory Size\s*:/) {	# get the memory size
				@fields = getSpecFields($_);
				$memory{"SIZE"} = $fields[1];
				
				# extract the words and bits from the size
				$memory{"WORDS"} = $fields[1];
				$memory{"BITS"}  = $fields[1];
				
				# get the number of words
				$memory{"WORDS"} =~ s/x*\s*\d+\s*bits\s*x*//i;
				$memory{"WORDS"} =~ s/\s*words\s*//i;
				$memory{"WORDS"} =~ s/^\s*//;
				$memory{"WORDS"} =~ s/\s*$//;
				
				# get the number of bits
				$memory{"BITS"} =~ s/x*\s*\d+\s*words\s*x*//i;
				$memory{"BITS"} =~ s/\s*bits\s*//i;
				$memory{"BITS"} =~ s/^\s*//;
				$memory{"BITS"} =~ s/\s*$//;
			}
			
			if (/^Frequency\s*:/) {	# get the max frequency of the memory
				@fields = getSpecFields($_);
				$memory{"FREQUENCY"} = $fields[1];
			}
			
			# get the next line
			$_ = <DATA_SHEET>;	
			
			# next loop...
			next;		
		}
		
		if ($section eq "DESCRIPTION") { # grab data from the description section
		
			# watch for a string that looks like the address ports
			if ((/\s+1[\s-]*p\s+/i) or (/\s+1[\s-]*port\s+/i)) {		# it's *probably* a 1 port memory
				$memory{"PORTS"} = 1;
			} elsif ((/\s+2[\s-]*p\s+/i) or (/\s+2[\s-]*port\s+/i)) { 	# it's *probably* a 2 port memory
				$memory{"PORTS"} = 2;
			}
			
			# check to see if this might be a ROM
			if ((/\s+read\s+only\s+memory\s+/i) or (/\s+ROM\s+/i)) {
										
				$rom_flag = 1;
			}
			
			# get the next line
			$_ = <DATA_SHEET>;	
			
			# next loop...
			next;
		}
		
		if ($section eq "FEATURES") { # grab data from the features section
		
			# watch for a string that looks like the number of ports
			if ((/\s+1[\s-]*p\s+/i) or (/\s+1[\s-]*port\s+/i)) {		# it's *probably* a 1 port RAM
				$memory{"PORTS"} = 1;
			} elsif ((/\s+2[\s-]*p\s+/i) or (/\s+2[\s-]*port\s+/i)) { 	# it's *probably* a 2 port RAM
				$memory{"PORTS"} = 2;
			}
			
			# get the next line
			$_ = <DATA_SHEET>;	
			
			# do next loop
			next;		
		}			
		
		if ($section eq "OUTPUT PORTS") { # grab data from the output ports section
					
			# get the first output pin name
			if ((/data output/i) and (!$q)) {		# this line defines pin names for output pins 
				@fields = getFields($_);
				$q = $fields[0];	
			}
			
			# get the next line
			$_ = <DATA_SHEET>;	
			
			# next loop...
			next;
		}
		
		if ($section eq "INPUT PORTS") { # grab data from the input ports section
				
			# get the first pin name for address and clock pins
			if ((/address input/i) and (!$adr)) {		# this line defines pin names for address 
				@fields = getFields($_);
				$adr = $fields[0];
			} elsif ((/clock input/i) and (!$clk)) { 	# this line defines pin names for the clock
				@fields = getFields($_);
				$clk = $fields[0];				
			}
			
			# get the next line
			$_ = <DATA_SHEET>;	
			
			# next loop...
			next;
		}
				
		if ($section eq "OPERATING CONDITIONS") { # grab data from the operating conditions table
		
			# grab the table 
			($_, @table) = getTable($_, *DATA_SHEET	);
			
			# get a hash to hold the table data
			%pvt = getDescTableHash(@table);
						
			# once the table is read don't read anything else until the next section of interest
			$section = "NONE";
			
			# do next loop
			next;		
		}	
		
		
		if ($section eq "TIMING") { # grab data from the timing table
					
			# grab the table 
			($_, @table) = getTable($_, *DATA_SHEET	);
			
			# get a hash to hold the table data
			%timing = getDescTableHash(@table);

			# get a hash to hold the table data (using symbols as keys)
			%timing_sym = getSymTableHash(@table);
						
			# once the table is read don't read anything else until the next section of interest
			$section = "NONE";
			
			# do next loop
			next;			}	
	
		
		if ($section eq "STATIC POWER") { # grab data from the power dissapation table
		
			# grab the table 
			($_, @table) = getTable($_, *DATA_SHEET	);
			
			# get a hash to hold the table data
			%static_power = getDescTableHash(@table);
						
			# once the table is read don't read anything else until the next section of interest
			$section = "NONE";
			
			# do next loop
			next;			}	
			
		if ($section eq "TYP POWER CYCLE") { # grab data from the typical power cycle table

			# grab the table 
			($_, @table) = getTable($_, *DATA_SHEET	);
						
			# get a hash to hold the table data
			%typ_power = getPowerTableHash(@table);
						
			# once the table is read don't read anything else until the next section of interest
			$section = "NONE";
			
			# do next loop
			next;		
		}	
			
		if ($section eq "WORST POWER CYCLE") { # grab data from the worst power cycle table
					
			# grab the table 
			($_, @table) = getTable($_, *DATA_SHEET	);
			
			# get a hash to hold the table data
			%worst_power = getPowerTableHash(@table);
						
			# once the table is read don't read anything else until the next section of interest
			$section = "NONE";
			
			# do next loop
			next;		
		}	
		
		if ($section eq "CLOCK PWR") { # grab data from the clock power rable
						
			# grab the table 
			($_, @table) = getTable($_, *DATA_SHEET	);
			
			# get a hash to hold the table data
			%clock_power = getPowerTable2Hash(@table);
						
			# once the table is read don't read anything else until the next section of interest
			$section = "NONE";
			
			# do next loop
			next;		
		}	
		
		# if no hits, next line...
		$_ = <DATA_SHEET>;	
		
	}
				

	# a little QC, check to make sure required data was found...
	if (!exists $memory{NAME}) {
		print "ERROR  : Can't find memory name in data sheet. Aborting!\n";
		exit;
	}

	if (!exists $memory{PORTS}) {
		print "ERROR  : Can't determine number of ports from data sheet. Aborting!\n";
		exit;
	}
	
	if (!exists $memory{BITS}) {
		print "ERROR  : Can't determine number of bits from data sheet. Aborting!\n";
		exit;
	}

	if (!exists $memory{WORDS}) {
		print "ERROR  : Can't determine number of words from data sheet. Aborting!\n";
		exit;
	}
	
	if (scalar(keys %pvt) == 0) {
		print "ERROR  : Can't extract PVT corners from data sheet. Aborting!\n";
		exit;
	}
	
	if (scalar(keys %timing) == 0) {
		print "ERROR  : Can't extract timing data from data sheet. Aborting!\n";
		exit;
	}	
	
	if (scalar(keys %typ_power) == 0) {
		print "ERROR  : Can't extract typical case power data from data sheet. Aborting!\n";
		exit;
	}
	
	if (scalar(keys %worst_power) == 0) {
		print "ERROR  : Can't extract worst case power data from data sheet. Aborting!\n";
		exit;
	}
	
	if (scalar(keys %clock_power) == 0) {
		print "WARNING: Can't extract clock only power data from data sheet (\"Clock Read, Write and Disable Power\" table is missing!)\n       : Cpd_standby will be estimated!\n";
	}
	
	
	if ($rom_flag and ($memory{TYPE} ne "ROM")) {
	
		print "WARNING: This looks like a ROM but the memory type (-t option) is \"$memory{TYPE}\"!\n       : Did you specify the correct memory type?\n"; 
	}

	
	# looks like we may have found all the data (got past all the checks...)
	
	# print a summary if ask to...
	if ($opt_s) {	

		print "INFO   : The following information was parsed from the datasheet-\n";
		print "         NAME        = $memory{NAME}\n";
		print "         TYPE        = $memory{TYPE}\n";
		print "         FREQUENCY   = $memory{FREQUENCY}\n";
		print "         PORTS       = $memory{PORTS}\n";
		print "         SIZE        = $memory{SIZE}\n";
		print "         WORDS       = $memory{WORDS}\n";
		print "         BITS        = $memory{BITS}\n";
		print "         PVT corners = ";
		for $key ( keys %pvt ) {
			chomp ($key);
			print "$key  ";
		}
		print "\n";	
	}

	# extract the output load and slew rate from apache database
	if ($opt_d) {
		
		# open the apache.apl file and find the memory
		if (open (APL_FILE, "<$opt_d/.apache/apache.apl")) {
		
			# some status
			print "INFO   : Looking for memory \"$memory{NAME}\" in the Apache DB...\n";		
		
			while (<APL_FILE>) {
		
				if (/^$memory{NAME}\s*\{/i) {	
				
					# get the samples for this memory from the file
					($_, @samples) = getSamples($_, *APL_FILE );	
							
					# get the last (biggest load) sample
					$sample = pop @samples;
				
					# get slews and loads
					($Trise, $Tfall) = getSlews($sample);
					($C1, $C2)       = getLoads($sample);
				
					# done!
					$found_memory = 1;
					last;			
				}
			}	
			
			# close the apache.apl file
			close APL_FILE;		
		
		} else {
		
			# can't open the apl file!
			print "WARNING: Cannot open DB file \"$opt_d/.apache/apache.apl\": $!.\n";		
		}
		
		# did we find the RAM?
		if (!$found_memory ) {
		
			# if not error off
			print "WARNING: Cannot find memory device \"$memory{NAME}\" in Apache DB.\n";
			
			if (!$opt_l or !$opt_tr or !$opt_tf) { 
				die "ERROR  : You must specify the output load (-l) and the output rise/fall times (-tr/-tf). Aborting!\n";
			}
		} else {
		
			# some status
			print "INFO   : Found memory \"$memory{NAME}\" in the Apache DB...\n";			
		}
	}
	
	# user overrides?
	if ($opt_l) {
		print "INFO   : Using user specified value $opt_l fF for memory output load.\n";
		$C1 = $opt_l;
		$C2 = 0;
	}
	
	if ($opt_tr) {
		print "INFO   : Using user specified value $opt_tr nS for memory output rise time.\n";
		$Trise = $opt_tr;
	}	
		
	if ($opt_tf) {
		print "INFO   : Using user specified value $opt_tf nS for memory output fall time.\n";
		$Tfall = $opt_tf;
	}
		
	if ($opt_o) {
	
		# make sure the specified PVT corner exists
		if (!exists $pvt{"$opt_pvt"}) {
			print "ERROR  : PVT corner \"$opt_pvt\" not found. Use -s option to determine PVT corners in datasheet. Aborting!\n";
			exit;	
		}	
		
		# get the VDD key from the pvt hash
		$Vdd_key = matchKey ("volt", keys %{$pvt{$opt_pvt}});		
		if (!$Vdd_key) {
			print "ERROR  : Can't find Vdd value for PVT corner \"$opt_pvt\". Aborting!\n";
			exit;			
		}	
		
		# get Vdd
		$Vdd = $pvt{$opt_pvt}->{$Vdd_key};
		
		# what power cycle to use for Cpd?
		if ($opt_typ) {	# use typical power cycle
			
			print "INFO   : Using typical case power cycle to compute Cpd...\n";
			$memory_power = \%typ_power
		
		} elsif ($opt_wst) { # use worst power cycle
		
			print "INFO   : Using worst case power cycle to compute Cpd...\n";
			$memory_power = \%worst_power
	
		} else { # someone forgot to specify the desired power cycle
		
			print "INFO   : No memory power cycle specified - assuming worst case...\n";
			$memory_power = \%worst_power
		}	
		
		# set default values for clock, address and output pins if needed
		if (!$clk) { $clk = "CK"};
		if (!$adr) { $adr = "ADR"};
		if (!$q)   { $q   = "Q"};

		# get keys needed to read the hashes
		$pwr_diss_key = matchKey("power", keys %{$memory_power});
		$standby_key  = matchKey("dis", keys %clock_power); 		
		$setup_key    = matchKey("$adr setup", keys %timing);
		$ck2q_key     = matchKey("$clk to $q delay", keys %timing);
		$Idd_key      = matchKey("idd", keys %static_power);
		
		# find the hash with Idd info
		if (!$Idd_key) { # static Idd might be in typ/wst power table
		
			# assume static Idd is in the typ table?
			$Idd_key = matchKey("idd", keys %typ_power);
		}	
		if (!$Idd_key) {
			
			# assume Idd is in the worst table...
			$Idd_key = matchKey("idd", keys %worst_power);
		}
		if (!$Idd_key) {
			
			# assume default Idd key
			$Idd_key = "Static Idd (uA)";
		}
				
		$read_key     = matchKey("rd", keys %{$memory_power->{$pwr_diss_key}->{$opt_pvt}});
		$write_key    = matchKey("wr", keys %{$memory_power->{$pwr_diss_key}->{$opt_pvt}});
		
		# warn user if we can't find the write mode for this memory
		if (!$write_key) { 
		
			print "WARNING: No WRITE mode found for this memory! Cpd_write will be set equal to Cpd_read.\n";
			
		}
		
		# compute quantities needed for config
		# get gate count
		$gate_count = int( 1.1*$memory{BITS}*$memory{WORDS});
		
		# get the setup time
		if (exists $timing{$setup_key}->{$opt_pvt}) { # description matches pins
					
			$T_setup = $timing{$setup_key}->{$opt_pvt};
			
		} else { # try to get setup time using the typical symbol
					
			$T_setup = $timing_sym{"Tac"}->{$opt_pvt};
		}
				
		# get ck to q time
		if (exists $timing{$ck2q_key}->{$opt_pvt}) { # description matches pins
		
			$ck2q_delay = $timing{$ck2q_key}->{$opt_pvt};
			
		} else { # try to get setup time using the typical symbol
		
			$ck2q_delay = $timing_sym{Tcq}->{$opt_pvt};
			
		}
		
		# compute Cpd's
		$Cpd_read    = eng_units((($memory_power->{$pwr_diss_key}->{$opt_pvt}->{$read_key})/($Vdd * $Vdd)) * scale($pwr_diss_key));

		# only compute Cpd_write if this memory has a write mode!
		if ($write_key) {
		 
			$Cpd_write   = eng_units((($memory_power->{$pwr_diss_key}->{$opt_pvt}->{$write_key})/($Vdd * $Vdd)) * scale($pwr_diss_key));

		} else {
			
			$Cpd_write = $Cpd_read;
		}

		$pwr_diss_key = matchKey("power", keys %{$clock_power{$standby_key}});
		
		if (!exists $clock_power{$standby_key}->{$pwr_diss_key}->{$opt_pvt}) { # clock power table is probably missing!
		
			if (!$opt_f ) {
		
				# estimate Cpd_standby as 10% of average of read/write power
				$Cpd_standby = eng_units((($Cpd_read + $Cpd_write)/2)*0.1);
			
				# warn the user
				print "WARNING: Unable to determine standby power! Cpd_standby is estimated as 10% of the average of the read/write power.\n       : You can set the fraction used for Cpd_standby estimation with the -f option.\n       : See the man page for more details.\n";
			
			} else {
			
				# estimate Cpd_standby as 10% of average of read/write power
				$Cpd_standby = eng_units((($Cpd_read + $Cpd_write)/2)*$opt_f);

				# warn the user
				print "WARNING: Unable to determine standby power! Cpd_standby is estimated as " . $opt_f*100 . "% of the average of the read/write power.\n";
			}		
								
		} else { # compute Cpd_standby	
		
			$Cpd_standby  = eng_units((($clock_power{$standby_key}->{$pwr_diss_key}->{$opt_pvt})/($Vdd * $Vdd)) * scale($pwr_diss_key)); 
		}

		# make it pretty
		$T_setup    = eng_units($T_setup * 1e-9);
		$Cload      = eng_units(($C1+$C2)*1e-15);
		$ck2q_delay = eng_units(($ck2q_delay * 1e-9));
		$Trise      = eng_units(($Trise * 1e-9));
		$Tfall      = eng_units(($Tfall * 1e-9));
				
		# get the Idd current (if it exists)...
		
		# do any of the power tables contain an Idd row?
		if    (exists $typ_power{$Idd_key})    { $key = $typ_power{$Idd_key} }
		elsif (exists $worst_power{$Idd_key})  { $key = $worst_power{$Idd_key} }
		elsif (exists $static_power{$Idd_key}) { $key = $static_power{$Idd_key} }
		else                                   { $key = "" }
		
		# found the Idd key, now to find the Idd value...
		if ($key) {
		
			# search the hash for the Idd leakage value
			if (exists($key->{$opt_pvt})) {  # we have a Idd value but where is it?
			
				if (exists($key->{$opt_pvt}->{$read_key})) { 
					
					$leakage_i  = eng_units($key->{$opt_pvt}->{$read_key} * scale($Idd_key))
								
				} elsif (exists($key->{$opt_pvt}->{$write_key})) {
		
					$leakage_i  = eng_units($key->{$opt_pvt}->{$write_key} * scale($Idd_key))
					
				} else {
				
					$leakage_i  = eng_units($key->{$opt_pvt} * scale($Idd_key))
		
				}
				
			} 
				
		} else {
		
			# no leakage found
			$leakage_i = "";
			
		}
				
		# get the process from the pvt corner
		if (($opt_pvt =~ /best/i) or ($opt_pvt =~ /fast/i) or ($opt_pvt =~ /ff/i)) {
			$process = "FF";
		} elsif (($opt_pvt =~ /typ/i) or ($opt_pvt =~ /nom/i) or ($opt_pvt =~ /tt/i)) {
			$process = "TT";
		} elsif (($opt_pvt =~ /worst/i) or ($opt_pvt =~ /slow/i) or ($opt_pvt =~ /ss/i)) {
			$process = "SS";
		} elsif (exists $pvt{$opt_pvt}{Process}) {
			if ($pvt{$opt_pvt}{Process} =~ /^W/i) {
				$process = "SS";
			} elsif ($pvt{$opt_pvt}{Process} =~ /^T/i) { 
				$process = "TT";
			} elsif ($pvt{$opt_pvt}{Process} =~ /^B/i) { 
				$process = "FF";					
			} else {
				$process = "";
			}	
				
		} elsif (exists $pvt{$opt_pvt}{PROCESS}) {
			if ($pvt{$opt_pvt}{PROCESS} =~ /^W/i) {
				$process = "SS";
			} elsif ($pvt{$opt_pvt}{PROCESS} =~ /^T/i) { 
				$process = "TT";
			} elsif ($pvt{$opt_pvt}{PROCESS} =~ /^B/i) { 
				$process = "FF";					
			} else {
				$process = "";
			}
		
		} else { # can't find a process anywhere
			$process = "";	
		}
		
		if (! $process ) {
			print "WARNING: Unable to determin process from datasheet! You must manually specify the process corner in the avm config file.\n";
		}
			
		# write out config file
		print CONFIG_FILE "$memory{NAME}\n";
		print CONFIG_FILE "{\n";  
		print CONFIG_FILE "    EQUIV_GATE_COUNT $gate_count\n";
		print CONFIG_FILE "    MEMORY_TYPE $memory{TYPE}\n";
		print CONFIG_FILE "    PROCESS $process\n";
		print CONFIG_FILE "    VDD $Vdd\n";
		print CONFIG_FILE "    Cpd_read $Cpd_read\n";   
		print CONFIG_FILE "    Cpd_write $Cpd_write\n";   
		print CONFIG_FILE "    Cpd_standby $Cpd_standby\n";   
		print CONFIG_FILE "    tsu $T_setup\n";   
		print CONFIG_FILE "    ck2q_delay $ck2q_delay\n";   
		print CONFIG_FILE "    tr_q $Trise\n";   
		print CONFIG_FILE "    tf_q $Tfall\n";   
		print CONFIG_FILE "    Cload $Cload\n";   
		if ($leakage_i) { print CONFIG_FILE "    leakage_i $leakage_i\n" };
		print CONFIG_FILE " }\n";
		   
	}

	# dump the hashes if debugging
	if ($opt_debug) {
		
		print "DEBUG  : A dump of program hashes follows...\n";
		dumpHashes() ;

	}
	
	# little house keeping
	close DATA_SHEET;
	close CONFIG_FILE;

	# that's it...
	print "INFO   : Done!\n";
}
