eval '(exit $?0)' && eval 'exec perl -w -S $0 ${1+"$@"}'
    && eval 'exec perl -w -S $0 $argv:q'
    if 0;
	
#############################################################################
# Name       : saif2toggle.pl 
# Description: A script to convert saif files to Apache toggle files.
#
# $Revision  : 1.0 $
# Author     : Jeffrey Smith
# Created    : 3/2/06
# Copyright (c) 2006 by Apache Design Solutions, Inc. All rights reserved.
# 
# Revision History
#
# Rev 1.0
#  - Initial release. 
#
# Rev 1.1
#  - Fixed constant delaration to be perl 5.6 compatible
# 
# Rev 1.2 
#  - Added support of SAIF files with IOPATH and COND statements
#  - Added support for outputting toggle rates of ports (in addition to nets)
#
# Rev 1.3
#  - Added check for trailing slash in -r option
#
# Rev 1.4
#  - Fixed bug that missed nets/ports containing the strings "net" or "port"
#
# Rev 1.5
#  - Changed code to omit leading slash in net paths
#  - Added -l option to add leading slash back to net paths
#
# Rev 1.6
#  - Fixed initialization bug when no -r option is given
#
##############################################################################

=head1 NAME

saif2toggle.pl - convert a SAIF file to an Apache toggle file.  

=head1 SYNOPSIS

saif2toggle.pl [options] arguments

Options: -h, -help, -man, -r root_instance, -v, -l, -debug
  
Arguments: -i saif_file, -o toggle_file | -p design_hierarchy_file

=head1 DESCRIPTION

saif2toggle.pl creates an Apache toggle file from an input SAIF file. Additional 
capabilities include writting the SAIF file hierarchy to an output file which 
is useful in finding the instance of the design that is being analyzed in RedHawk. 
Once indentified, the desired instance can be specified as the root of the output 
toggle file removing extraneous nets from the output file. Also, users can specify 
the value that is to be extracted from the SAIF file. Toggle counts for both nets 
and ports are extracted.

saif2toggle can read SAIF files that include IOPATH and COND statements. In this 
case the toggle counts of all conditions/iopaths are summed by net. In other words,
when toggle counts are specified as a function of conditions and/or iopaths all 
counts for the current net/port are summed to generate the totals for that net/port.

=head1 OPTIONS

=over 

=item -h

Prints a short synopsis.

=item -help

Prints a synopsis and a description of program options and arguments.

=item -man

Prints the entire man page.

=item -r root_instance

Specifies the root instance that will be output to the SAIF file. The -r 
option allows the user to ignore extraineous parts of the SAIF file and 
only output the part of the file that applies to the design under analysis.
Paths specified for the -r option should NOT end in a "/" (i.e., /u1/u2/u3 
is OK but /u1/u2/u3/ is illegal). If a trailing slash is specified it will 
be truncated and a warning issued.

=item -l

Typically, the toggle file is output without a leading slash in each net path for greater
compatibility with the RedHawk toggle file format. If desired, the leading slash can be included
by specifing the -l option.

=item -v value

Specifies the value to be written to the output file. Possible values are toggle count ("TC"), 
logic 1 time ("T1"), logic 0 time ("T0"), and logic X time ("TX"). The default
is to print the toggle count.

=item -debug

Turns on debug output.

=head1 ARGUMENTS

=item -i saif_file 

The path to the input SAIF file. This file should contain toggle information for the
design under analysis. SAIF files containing path or state dependent toggle infomation 
are supported.

=item -o toggle_file

The path to the output Apache toggle file. This file is an input to the RedHawk analysis.

=item -p design_hierarchy

Prints the hierarchy of the SAIF file to the specified output file. SAIF files are 
often generated from simulations that may include additional system level 
instances. The -p option allows the entire heirarchy of the file to be printed 
so that the desired instance can be identified.

=back

=head1 EXAMPLES

1. Print the hierarchy of SAIF file design.saif to a file called design.hierarchy.

=over

saif2toggle.pl -i design.saif -p design.hierarchy

=back

2. Generate toggle file apache.toggle from SAIF file design.saif. The root of the output 
toggle file is the root of the SAIF file. In other words, all instances in the SAIF file 
are written to the toggle file.

=over 

saif2toggle.pl -i design.saif -p design.hierarchy

=back

3. Generate toggle file apache.toggle from SAIF file design.saif as above but write the
T1 values to the file instead of the toggle counts.

=over 

saif2toggle.pl -i design.saif -o apache.toggle -v T1
 
=back

4. Generate toggle file apache.toggle from SAIF file design.saif. The root of the output 
toggle file is /tb/design_top. In other words, only the instance /tb/design_top is written 
to the toggle file.

=over

saif2toggle.pl -i design.saif -o apache.toggle -r /tb/design_top

=back

5. Generate toggle file apache.toggle from SAIF file design.saif. Also write the hierarchy of
the SAIF file to an output file called "design.hierarchy".

=over

saif2toggle.pl -i design.saif -o apache.toggle -p design.hierarchy

=back

=head1 LIMITATIONS

This script builds a data structure of hashes to hold the data represented in the SAIF file. 
This can be a bit memory intensive so watch your memory usage as the script runs (example: 
a file of 223M Bytes/5.4M lines/1.35M nets took 9 minutes and consumed about 1.1G Bytes RAM).

=cut
	
=head1 COPYRIGHT

COPYRIGHT (c) 2006, 2007 Apache Design Solutions. All rights reserved.

=cut
	
# packages...
use Getopt::Long;
use Pod::Usage;
# use strict;
# use warnings;
# use diagnostics;

# constants...
use constant no_nets => -100;	# indiacates that no nets are open

# define script command line options
my $opt_h	  = '';			# short help
my $opt_help  = '';			# long help
my $opt_man	  = '';			# man page
my $opt_i	  = '';			# input saif file
my $opt_o	  = '';			# output toggle file
my $opt_p	  = '';			# print the saif file hierarchy
my $opt_v     = '';			# value to read from the saif file
my $opt_r	  = '';			# root of the design
my $opt_l	  = '';			# include leading slashes in net paths
my $opt_debug = '';			

# variables...
my $ascending = 0;			# ascending from the file
my $descending = 0;			# descending into the file
my $stable = 0;				# stable in the file
my $left_parens  = 0;		# number of left parentheses
my $right_parens = 0;		# number of right parentheses
my $line_number  = 0;		# line number of the current line
my $paren_level  = 0;		# parenthesis level
my $valid_file   = 0;		# marks a valid file
my @fields;					# fields of an input line
my $net;					# a net
my $nets = {};				# pointer to a hash of net info
my $field = '';				# the field part of a field/value pair
my $value = '';				# the value part of a field/value pair
my $previous_field = '';	# previous field
my $previous_value = '';	# previous value
my $saif_statement;			# saif statement extracted from the input file
my $previous_paren_level;	# previous value of the paren_level
my $current_hash;			# pointer to the current hash
my $next_hash;				# pointer to the next hash
my $previous_instance;		# the last instance encountered
my $previous_net;			# the last net encountered
my $nets_level = no_nets;	# paren level at which a net was encountered
my $cond_level = no_nets;	# condition statement level
my @instances;				# contains the instances in a particular path
my %instances;				# a hash that contains all the instances
my @hashes;					# contains the hashes in a particular path
my $previous_hash;			# the previous hash
my $found_nets = 0;			# indicates that a net was found
my $hash_ptr;				# holds a pointer to a hash
my $hier_level = 0;			# holds the depth we are in the design
my $instance;				# holds a single instance
my $inst_path;				# holds the path to an instance
my %inst_paths;				# holds the paths of all instances
my $iopath_level = no_nets;	# level for a iopath specification
my @junk;	
my @instance;				# an array containing one instance
my @paths;
my $string;
my %net_paths;				# hash to hold net paths and values
my %header;					# holds file header infomation
my $statement_count = 0;	# count of statements processed
my $path;					# an individual path in the design
my $rel_path;				# realitive (short) path
my $time_units;				# units of time for output file
my $duration;				# duration of output file
my $multiplier;				# multiplier to convert duration to ps

{	# subroutines

	# static vars for subroutines
	my $input_buffer = "";	# input buffer holds part of the file	
	my @net_path;			# path to a net

	# convert timescale to picoseconds
	sub timescale2ps (@) {	
		my ($string) = @_;	# input string
		my $time;			# time in ps
		my $units;			# units of input time

		# get the numerical value and units of the input time
		($time, $units) = split /[\s]/, $string;
		
		if ($units =~ /ns/i) { 		# convert ns to ps
			$time *= 1000;
			$units = "ps";
		} elsif ($units =~ /us/i) {	# convert us to ps
			$time *= 1000000;	
			$units = "ps";
		} elsif ($units =~ /ms/i) {	# convert ms to ps
			$time *= 1000000000;
			$units = "ps";
		} elsif ($units =~ /^s/i) {	# convert s to ps
			$time *= 1000000000000;
			$units = "ps";
		} elsif ($units =~ /fs/i) {	# convert fs to ps
			$time /= 1000;
			$units = "ps";
		}
		
		# return the time and units
		return ($time, $units);
		
	} # end subroutine time2ps
		

	# given a list of keys return only valid instances
	sub ValidKeys (@) {	
		my (@all_keys) = @_;	# all the keys from a hash
		my @valid_keys;			# a list of valid keys
		my $key;				# a key from the hash
		
		foreach $key (@all_keys) {
			
			if ($key !~ /_parent_hash_/     and 
				$key !~ /_parent_instance_/ and 
				$key !~ /_parent_net_/      and
				$key !~ /_paren_level_/         ) {	# this is a valid key
			
				# put the instance in the list
				push @valid_keys, $key;
			}		
		}
		
		# return valid key list
		return \@valid_keys;
		
	} # end subroutine ValidKeys


	# get the desired fields from the tree hash given
	# the pointer to the hash and the instances to search
	sub getNetData ($ $ $) {
		my ($hash_ptr, $instances, $field) = @_;	# hash pointer, instances, desired field
		my $instance;								# a single instance at the current level of the hierarchy
		my $net_path;								# a path to a net
		
		# some debug status
		if ($opt_debug) {print "DEBUG: getNetData called with hash_ptr = $hash_ptr, instances = @{$instances}, and field = $field\n";};
		
		# look for end of list condition
		if (exists $hash_ptr->{_parent_net_}) { # we are at the values hash 

			# if the desired field exists and is not empty
			if ((exists $hash_ptr->{$field}) and ($hash_ptr->{$field} ne "")) {
				
				# build a path to this net
				$net_path = "";
				foreach $instance (@net_path) {
						$net_path .= "/$instance";
				}
				
				# save value of this net in the hash
				$net_paths{$net_path} = $hash_ptr->{$field};
				
				# pop off the net name
				$net = pop @net_path;
													
				# build a path to this instance
				$inst_path = "";
				foreach $instance (@net_path) {
						$inst_path .= "/$instance";
				}	
							
				# save this instance in the hash (duplicates don't count)
				if (!exists $inst_paths{$inst_path}) {
					$inst_paths{$inst_path} = '';
				}
				
				# put the stack back
				push @net_path, $net;				
			} 

		} else { # not at lists end, keep looking for nets
		
			foreach $instance (@{$instances}) {
		
				# if the instance has a child hash
				if (ref $hash_ptr->{$instance} eq "HASH") {  
								
					# save the path to this net
					push @net_path, $instance;
								
					# push down one more level into the hash tree
					&getNetData (($hash_ptr->{$instance}), (ValidKeys keys %{$hash_ptr->{$instance}}), $field);
					
					pop @net_path;
					
				} 			
			}
		}
		
		# done
		return;	
		
	} # end subroutine getNetData						
	
	
	# get the next line from the input file
	sub getNextLine (*) {	
		my ($input_file) = @_;
	
		# bump the line count
		++$line_number;
				
		# get the next line
		return (<$input_file>);
		
	} # end sub getNextLine
	
	
	# get the next saif statement from the input file
	sub getSaifStatement (*) {	
		my ($input_file) = @_;
		
		# subroutine vars
		my $starting_line;				# first non-blank line at entry
		my $statement;					# the extracted saif statement
		my $left_paren_count;			# number of left parens in the input buffer
		my $right_paren_count;			# number of right parens in the input buffer
		my $next_line;					# buffer to read in the next line from the file	
		my $left_paren_index;			# index position of the left parenthesis
		my $right_paren_index;			# index position of the right parenthesis
		my $second_left_paren_index;	# index position of a 2nd left hand parenthesis	
		
		# skip blank lines
		while (!($input_buffer =~ /\S/)) {
		
			# exit if end of the file is found
			($input_buffer = getNextLine($input_file)) or return 0;
			
		}	
	
		# save the current line number
		$starting_line = $line_number;		
			
		# leading white space, so useless
		$input_buffer=~ s/^\s+//g;	
			
		# is this a commnet?
		if ($input_buffer =~ /^\/\*/) { # input buffer is a comment
			
			# grab the statement
			$statement = $input_buffer;
			
			# remove the comment from the input buffer
			$input_buffer = "";

			# return the comment
			chomp($statement);
			return($statement);
		}
			
		# get the number of left/right parens in the input buffer...
		$left_paren_count  = ($input_buffer =~ tr/\(/\(/);
		$right_paren_count = ($input_buffer =~ tr/\)/\)/);
			
		# read until we have enough lines to extract a saif statement or find the end of the file
		while (($left_paren_count < 2) and ($right_paren_count < 1)) {
		
			# get the next line 
			($next_line = getNextLine($input_file)) or last;
			
			# add the next line to the input buffer
			$input_buffer =~ s/\n/ /g;
			$input_buffer .= $next_line;
		
			# update paren counts
			$left_paren_count  = ($input_buffer =~ tr/\(/\(/);
			$right_paren_count = ($input_buffer =~ tr/\)/\)/);		
		}

		# check for abnormal end of file...
		if (!defined ($next_line) and ($left_paren_count < 2) and ($right_paren_count < 1)) {
			print ("ERROR: Open parenthesis found at line $starting_line but no matching closing parenthesis found!\n");
			exit;
		}
				
		# get the position of the left and right parenthesis (if they exists)
		$left_paren_index  = index ($input_buffer, "(");
		$right_paren_index = index ($input_buffer, ")");
		
		# check for the special case where there is text outside of the parens (like a COND or IOPATH)
		# look for stuff to the *left* of the left paren
		if ( $left_paren_index > 0 ) {	
		
			# grab stuff left of left paren
			$statement = substr($input_buffer, 0, $left_paren_index) ; 
		
			# is the stuff non-blank?
			if ( $statement =~ /\S+/ ) {
				
				# remove non blank stuff from statement 
				$input_buffer = substr($input_buffer, $left_paren_index);
		
				# return the statement
				chomp($statement);
				
				return $statement;	
			}	
		
		}
				
		# extract the "normal" statement...
		# lets do the simple case first
		if (($left_paren_count == 1) and ($right_paren_count == 1)) { # extract the statement bound by (...)
		
			# grab text between the parens (but not the right paren)
			$statement = substr($input_buffer, $left_paren_index, $right_paren_index-$left_paren_index);
			
			# take the statement out of the input buffer
			$input_buffer = substr($input_buffer, 0, $left_paren_index) . substr($input_buffer, $right_paren_index) 	
			
		} elsif (($left_paren_count > 1) and ($right_paren_count == 0)) { # statement is bound by two left parens
		
			# find the second occurance of a left parenthesis...
			$right_paren_index = index ($input_buffer, "(", $left_paren_index+1);
				
			# grab text between the parens (don't get the right most left paren)...
			$statement = substr($input_buffer, $left_paren_index, $right_paren_index-$left_paren_index);
			
			# take the statement out of the input buffer
			$input_buffer = substr($input_buffer, 0, $left_paren_index) . substr($input_buffer, $right_paren_index) 	
			
		} elsif (($left_paren_count == 0) and ($right_paren_count > 0)) { # end of statement marked by right parens
		
			# grab text from the beginning of the line to the first right paren
			$statement = substr($input_buffer, 0, $right_paren_index+1);		
			
			# take the statement out of the input buffer
			$input_buffer = substr($input_buffer, $right_paren_index+1) 	
				
			
		} else { # extract more complex statements containing both left and righ parens...
				
			# find the second occurance of a left parenthesis (if it exists)
			$second_left_paren_index = index ($input_buffer, "(", $left_paren_index+1);
		
			if (($second_left_paren_index != -1) and ($second_left_paren_index < $right_paren_index)) { # statement is bound by two left parens
					
				# grab text between the two left parens
				$statement = substr($input_buffer, $left_paren_index, $second_left_paren_index-$left_paren_index);	
				
				# take the statement out of the input buffer
				$input_buffer = substr($input_buffer, 0, $left_paren_index) . substr($input_buffer, $second_left_paren_index) 
				
			} elsif ($right_paren_index < $left_paren_index) { # statement is terminated by a right paren

				# grab text between the two left parens
				$statement = substr($input_buffer, 0, $right_paren_index+1);
				
				# take the statement out of the input buffer
				$input_buffer = substr($input_buffer, $right_paren_index+1);								

			} else {  # statement is bound by left/right parens
												
				# grab text between the left/right parens
				$statement = substr($input_buffer, $left_paren_index, $right_paren_index-$left_paren_index);	
				
				# take the statement out of the input buffer
				$input_buffer = substr($input_buffer, 0, $left_paren_index) . substr($input_buffer, $right_paren_index);
			} 
		}
				
		# return the statement
		chomp($statement);
				
		return $statement;

	} # end sub getSaifStatement		
	
	
} # end subroutine block


# begin main program...
{

	# get user input options..
    GetOptions(	'h'       => \$opt_h,
				'help'    => \$opt_help,
				'man'     => \$opt_man,
				'i=s'     => \$opt_i,
				'o=s'     => \$opt_o,
				'p=s'     => \$opt_p,
				'debug'   => \$opt_debug,
				'v=s'     => \$opt_v,
				'l'       => \$opt_l,
				'r=s'     => \$opt_r ) or pod2usage(0);
								
	# a little documentation for the user...				
	pod2usage (-exitval => 0, -verbose => 2) if $opt_man;
	pod2usage (-exitval => 0, -verbose => 1) if $opt_help;
	pod2usage (-exitval => 0, -verbose => 0) if $opt_h;
			
	# check for required input options
	if (!(($opt_i and $opt_p) or ($opt_i and $opt_o))) { pod2usage(-exitval => 1, -verbose => 0) }
	
	# set -v default
	if (!$opt_v) { $opt_v = "TC" } 
	
	# check -v option for valid input
	if (!(($opt_v eq "TC") or ($opt_v eq "T1") or ($opt_v eq "T0") or ($opt_v eq "TX"))) {
	
		die "ERROR: unknown value for option -v : \"$opt_v\".  Aborting!\n";
		
	}
	
	# any trailing slahses in -r option?
	if ( $opt_r=~/.*\/$/ ) {
	
		# trailing slashes break my algorithm so get rid of it
		chop ($opt_r) ;
		
		# a littl status...
		print "WARNING: removed trailing slash (\"/\") from -r option - the new path is \"$opt_r\"...\n";
	
	}
	
	if ( $opt_l ) {	
	
		# a littl status...
		print "INFO   : -l option invoked so leading slashes will be included in net paths...\n";		
	}
	
	# open the input file
	open (SAIF_FILE, "<$opt_i") or die "ERROR: Cannot open SAIF file \"$opt_i\": $!. Aborting!\n";

	# if requested, open toggle output file
	if ($opt_o) {  
		open (TOGGLE_FILE, ">$opt_o") or die "ERROR: Cannot open toggle file \"$opt_o\": $!. Aborting!\n";
	}
	
	# if requested, open hierarchy output file 
	if ($opt_p) {  
		open (HIERARCHY_FILE, ">$opt_p") or die "ERROR: Cannot open hierarchy file \"$opt_p\": $!. Aborting!\n";
	}

	# initialization 
	$hash_ptr = $nets;
	
	# status
	print "STATUS: Reading saif file \"$opt_i\"...\n";
	
	# read the saif file
	while ( $saif_statement = getSaifStatement (*SAIF_FILE) ){
	
		# count  statements procdessed
		++$statement_count;
		
		# something to let the user know we are doing something
		if ((!$opt_debug) and (!($statement_count%10000))) { print "    read $line_number lines...\n"}

		# debug output
		if ($opt_debug) { print "\nDEBUG: saif_statement = >$saif_statement<, ending line number = $line_number\n" }
		
		# skip comments...
		if ($saif_statement =~ /\/\*/) { next };
		
		# keep up with the number of open parens encountered in the file
		$left_parens  += ($saif_statement =~ tr/\(/\(/);
		$right_parens += ($saif_statement =~ tr/\)/\)/);
		$previous_paren_level = $paren_level;
		$paren_level = $left_parens - $right_parens;
		
		# debug output
		if ($opt_debug) {print "DEBUG: left_parens = $left_parens, right_parens  = $right_parens, previous_paren_level = $previous_paren_level, paren_level = $paren_level\n"; }

		# set some status flags
		if ($paren_level > $previous_paren_level) {
			$descending = 1;
			$ascending = 0;
			$stable = 0;
		} elsif ($paren_level < $previous_paren_level) {
			$descending = 0;
			$ascending = 1;
			$stable = 0;
		} else {
			$descending = 0;
			$ascending = 0;
			$stable = 1;			
		}	
			
		# debug output
		if ($opt_debug) {print "DEBUG: descending = $descending, ascending = $ascending, stable = $stable\n"; }

		# get new field/value...
		$field = $saif_statement;
		# remove the parens...
		$field =~ s/[\(\)]//g;
		# remove any leading/trailing white space...
		$field =~ s/^\s+//g;
		$field =~ s/\s+$//g;
		
		# grap field/value...
		$value = $field;
		$field =~ s/(\S+)\s*(.*)/$1/;
		$value =~ s/(\S+)\s*(.*)/$2/;
		
		# debug output
		if ($opt_debug) { print "DEBUG: field = >$field<, value = >$value<\n"; }
				
		# error check
		if ($descending and ($paren_level == 1) and ($field !~ /SAIFILE/i)) { # check opening statement to make sure this is a saif file
		
			# error off			
			die "ERROR: This does not look like a SAIF file! Aborting...\n";
		
		}
				
		# grab the instances
		if ($descending and ($field eq "INSTANCE") and $value) { # found an instance

			# create a hash to hold the children of this instance		
			$hash_ptr->{$value} = {};
			
			# remember the paren level this instance lives at
			$hash_ptr->{_paren_level_} = $paren_level;
			
			# link back to the parent 
			$hash_ptr->{$value}->{_parent_hash_}     = $hash_ptr;
			$hash_ptr->{$value}->{_parent_instance_} = $value;
			
			# advance the pointer to the next hash
			$hash_ptr = $hash_ptr->{$value};
			
			# debug output
			if ($opt_debug) { print "DEBUG: found instance \"$hash_ptr->{_parent_instance_}\"\n" }

			# next statement
			next;
				
		}	
			
		# watch for nets/ports section
		if ($descending and (($field eq "NET") or ($field eq "PORT"))) { # found the nets or ports section
		
			# everything below this level is a net/port
			$nets_level = $paren_level;

			# debug output
			if ($opt_debug) { print "DEBUG: detected nets/ports under instance $hash_ptr->{_parent_instance_}\n"; }

			# next statement
			next;
				
		}	
		
		# watch for a net/port
		if ($descending and ($paren_level == ($nets_level+1)) and $field)  { # found a net/port!
		
			# create a hash to hold the net info		
			$hash_ptr->{$field} = {};

			# link back to the parent 
			$hash_ptr->{$field}->{_parent_hash_} = $hash_ptr;
			$hash_ptr->{$field}->{_parent_net_}  = $field;
			
			# advance the pointer to info hash
			$hash_ptr = $hash_ptr->{$field};
			
			# debug output
			if ($opt_debug) { print "DEBUG: added net \"$hash_ptr->{_parent_net_}\" to instance $hash_ptr->{_parent_hash_}->{_parent_instance_}\n"; }

			# next statement
			next;
		
		}


		# watch for COND section
		if ($descending and ($nets_level != no_nets) and ($paren_level > ($nets_level+1)) and (($field eq "COND") or ($field eq "COND_DEFAULT"))) { # found a CONDITION statement
		
			# everything at this level is a CONDITION
			$cond_level = $paren_level;

			# debug output
			if ($opt_debug) { print "DEBUG: detected CONDITION under net $hash_ptr->{_parent_net_}\n"; }

			# next statement
			next;
		
		}	
		

		# watch for IOPATH section
		if ($descending and ($nets_level != no_nets) and ($paren_level > ($nets_level+1)) and ($field eq "IOPATH")) { # found a IOPATH statement
		
			# everything at this level is a IOPATH statement
			$iopath_level = $paren_level;

			# debug output
			if ($opt_debug) { print "DEBUG: detected IOPATH under net $hash_ptr->{_parent_net_}\n"; }

			# next statement
			next;
				
		}


		# watch for simple net info
		if ($descending and ($paren_level == ($nets_level+2)) and $field)  { # found a value for a net
		
			# save the net info...
			$hash_ptr->{$field} = $value;
		
			# debug output
			if ($opt_debug) { print "DEBUG: added $field = $value to net $hash_ptr->{_parent_net_}\n"; }

			# next statement
			next;
		
		}


		# watch for IOPATH info
		if ($descending and ($paren_level == ($iopath_level+1)) and $field)  { # found IOPATH data
		
			if ( exists $hash_ptr->{$field} ) {		# if an entry already exists then incrementally sum...
				$hash_ptr->{$field} += $value; 
			} else { 								# if no entry yet, create one...
				$hash_ptr->{$field} = $value;
			}
			
			# debug output
			if ($opt_debug) { print "DEBUG: added incremental (IOPATH) $field = $value to net $hash_ptr->{_parent_net_}\n"; }

			# next statement
			next;
		
		}
		
		# watch for IOPATH closing 
		if ($ascending and ($paren_level == ($iopath_level-1)) and !$field)  { # closing IOPATHS for this net
		
			# debug output
			if ($opt_debug) { print "DEBUG: closing IOPATHS for net $hash_ptr->{_parent_net_}\n"; }
			
			# close this section of nets
			$iopath_level = no_nets;

			# next statement
			next;
		
		}
		
		# watch for COND closing 
		if ($ascending and ($paren_level == ($cond_level-1)) and !$field)  { # closing COND for this net
		
			# debug output
			if ($opt_debug) { print "DEBUG: closing COND for net $hash_ptr->{_parent_net_}\n"; }
			
			# close this section of nets
			$cond_level = no_nets;

			# next statement
			next;
		
		}

		# watch for a net closing
		if ($ascending and ($paren_level == $nets_level) and !$field)  { # closing a net for this instance
				
			# debug output
			if ($opt_debug) { print "DEBUG: closing net $hash_ptr->{_parent_net_}\n"; }
			
			# back up one level in the tree	(to the nets hash)	
			$hash_ptr = $hash_ptr->{_parent_hash_};
				
			# next statement
			next;
		
		}		


		# watch for all nets closing
		if ($ascending and ($paren_level == ($nets_level-1)) and !$field)  { # closing all nets for this instance
		
			# debug output
			if ($opt_debug) { print "DEBUG: closing all nets for instance $hash_ptr->{_parent_instance_}\n"; }
			
			# close this section of nets
			$nets_level = no_nets;

			# next statement
			next;
		
		}

		# watch for closing an instance
		if ($ascending and ($nets_level == no_nets) and (exists ($hash_ptr->{_parent_hash_})) and ($hash_ptr->{_parent_hash_}->{_paren_level_} == ($paren_level+1))) { # just closed an instance
		
			# debug output
			if ($opt_debug) { print "DEBUG: closing instance $hash_ptr->{_parent_instance_}\n"; }
			
			# back up one level in the tree	(to the nets hash)	
			$hash_ptr = $hash_ptr->{_parent_hash_};
				
			# next statement
			next;
				
		}
				
		# watch for header values
		if ($descending and $field and ($paren_level == 2)) { # must be a header value
		
			# add the kwy/value to the header hash
			$header{$field} = $value;
		
			# debug output
			if ($opt_debug) { print "DEBUG: adding $field = $value to header hash\n"; }
				
			# next statement
			next;
				
		}
		
		# if we get here we did nothing....
		if ($opt_debug) { print "DEBUG: nothing to do for this statement\n" };
	
	}
	
	# file is read in so process user request(s)
		
	# user status
	print "STATUS: Generating output data...\n";
	
	# get data for the entire file 
	getNetData($nets, (ValidKeys keys %{$nets}), "$opt_v");
		
	# compute duration in picoseconds
	($multiplier, $time_units) = timescale2ps($header{TIMESCALE});
	$duration = $header{DURATION} * $multiplier;

	# output hierarchy file?
	if ($opt_p) {
	
		# user status
		print "STATUS: Generating hierarchy file \"$opt_p\"...\n";	
	
		# initialization
		$statement_count = 1;
			
		# first line is the duration of the simulation
		print HIERARCHY_FILE "# a list of sorted design instances\n";
			
		# write instances to the hierarchy file
		foreach $path (sort keys %inst_paths) {
		
			# write the result to the output file
			print HIERARCHY_FILE "$path\n";
		
			# bump the line count
			++$statement_count;
		
			# something to let the user know we are doing something
			if ((!$opt_debug) and (!($statement_count%10000))) { print "    wrote $statement_count lines...\n"}
		
		}	
	}


	# output file?
	if ($opt_o) {

		# user status
		print "STATUS: Generating output toggle file \"$opt_o\"...\n";		

		# first line is the duration of the simulation
		print TOGGLE_FILE "time $duration $time_units\n";
		
		# initialization
		$statement_count = 1;
		
		# user specified a root instance?
		if ($opt_r) {
		
			# write desired toggle counts to the output file
			foreach $path ( keys %net_paths) {
			
				$rel_path = $path;
			
				if ($rel_path =~ s/^$opt_r\//\//) {
				
					if ( !$opt_l ) {	# remove leading slash
						
						$rel_path =~ s/^\/// ;
					}	
				
					# write the result to the output file
					print TOGGLE_FILE "$rel_path $net_paths{$path}\n";
		
					# bump the line count
					++$statement_count;
		
					# something to let the user know we are doing something
					if ((!$opt_debug) and (!($statement_count%10000))) { print "    wrote $statement_count lines...\n"}		
		
				}
				
			}	
		
		} else {	# just write out all the insances 
		
			# write all toggle counts to the output file
			foreach $path ( keys %net_paths) {
				
				$rel_path = $path;
				
				if ( !$opt_l ) {	# remove leading slash
						
					$rel_path =~ s/^\/// ;
				}					
				
				# write the result to the output file
				print TOGGLE_FILE "$rel_path $net_paths{$path}\n";
		
				# bump the line count
				++$statement_count;
		
				# something to let the user know we are doing something
				if ((!$opt_debug) and (!($statement_count%10000))) { print "    wrote $statement_count lines...\n"}
			}
		}

	}
	
	# check for a bad -r path
	if ($opt_r and ($statement_count == 1)) {
	
		print "WARNING: No instances found for root path =\"$opt_r\"!\n         Please check the path specified for the -r option.\n";
	}
	
	# user status
	print "STATUS: Done!\n";
}
