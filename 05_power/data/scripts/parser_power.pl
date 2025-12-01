# $Revision: 2.1 $
eval '(exit $?0)' && eval 'exec perl -S $0 ${1+"$@"}'

&& eval 'exec perl -S $0 $argv:q' if 0;

#This perl script parses all the attributes for instances listed in "design".power.rpt file
#and creates a summary report based on user specifications
# command line : <perl_pgm_name> -in <design>.pwr.rpt  


######################################################################################################################
# Name       : parser_power.pl
# Description: search power report file by instance / cell / domain / freq / location / library and print summmary
# $Revision  :  1.0$
# Author     : Amey Kulkarni , email : amey@apache-da.com
######################################################################################################################

=head1 NAME

parser_power.pl

=head1 SYNOPSIS

parser_power.pl -in ARGUMENT [OPTIONS]

ARGUMENT: design power.rpt filename

OPTIONS: -h, -help, -man, -inst_exp, -inst, -cell_exp, -cell, -cell_type <combinational/latch/flip flop/clocked/memory>, -domain, -freq, -bbox "x_bottom_left y_bottom_left x_top_right y_top_right", -lib, -o

=head1 DESCRIPTION

B<parser_power.pl> collects design power report results and produces a report showing the following information.  This program 
allows the user to customize the power report summary with the help of the search options above.

=head4 instance name, cell name, cell type

=head4 frequency, toggle_rate

=head4 leakage power, switching power, internal + clock pin power, total power

=head4 x in um, y in um

=head4 VDD domain

=head4 source for leakage and internal power

=head4 domain type : 1 -> non-multi-rail power domain, 2 -> multi-rail VDD domain, 0 -> multi-rail VSS domain

=head4 leakage current, total current

=head4 library.
 
=head1 OPTIONS

=over

=item -h

Prints a short synopsis.

=item -help

Prints a short synopsis and description of program options

=item -man

Prints the entire man page

=item -in

Pass file name of the power report file as input

=item -inst_exp <instance expression>

Prints summary for instances with stated regular expression

=item -inst <instance>

Prints summary for known instance

=item -cell_exp <cell expression>

Prints summary for cells with stated regular expression

=item -cell <master cell>

Prints summary for known cell

=item -cell_type <combinational/latch/flip flop/clocked/memory>

Prints summary for the above cell types

=item -domain <VDD domain>

Prints summary of all instances belonging to the required power domain

=item -freq <frequency>

Prints summary for particular frequency

=item -bbox "x_bottom_left y_bottom_left x_top_right y_top_right"

Prints summary for all instances contained in the bounding box covered by x_bottom_left y_bottom_left x_top_right y_top_right

=item -lib <library>

Prints summary for library name

=item -o <filename>

Specify the output filename. Optional. Default is "parser_power.rpt".

=head1 EXAMPLE

parser_power.pl design.power.rpt [options]

=head4 The more the search options are provided, more specific the output report will get.

=head4 For eg, to obtain information on instances having names containing a specific string pattern like BW1_, 
execute the following command.

=head3 parser_power.pl -in <design.power.rpt> -inst_exp BW1_

=back

=head1 REQUIREMENTS

The user has to specify the power report filename as an argument. Script needs to be run in the RedHawk run directory.  When specifying x and y coordinates of instances, 
be sure to give the upper and bottom bounds.  If you know the precise location (xcoord and/or ycoord), assign that 
same coordinate value to both upper and bottom bounds.

=head1 AUTHOR

Amey Kulkarni , Aplications Engineer, Apache Bangalore,India.

email : amey@apache-da.com

=head1 COPYRIGHT

COPYRIGHT (c) 2006 Apache Design Solutions. All rights reserved.

=cut

# end program documentation


#Initialize expression types
$inst_exp = $inst = $cell_exp = $cell = $cell_type = $domain = $freq = $lib = ".*";

use Getopt::Long;
use Pod::Usage;

# begin main program...

        # define script command line options
        my $h   ='';            # short help
        my $help='';            # long help
        my $man ='';            # man page
	# get input options..
        GetOptions( 'h'        		=> \$h,
                    'help'     		=> \$help,
                    'man'      		=> \$man, 
                    'in=s'     		=> \$input,
		    'inst_exp:s'	=> \$inst_exp,
		    'inst:s'		=> \$inst,
		    'cell_exp:s'	=> \$cell_exp,
		    'cell:s'		=> \$cell,
		    'cell_type:s'	=> \$cell_type,
		    'domain:s' 		=> \$domain,
		    'freq:s'   		=> \$freq,
		    'lib:s'    		=> \$lib,
		    'bbox:s'		=> \$bbox,
		    'o=s'      		=> \$output ) || pod2usage (-verbose => 0);
		               
        # a little documentation for the user...
        pod2usage (-exitval => 0, -verbose => 2) if $man;
        pod2usage (-exitval => 0, -verbose => 1) if $help;
        pod2usage (-msg => "\nThe following is the usage .\n To learn more about the options, use -help or -man to display the manual\n", -exitval => 0 , -verbose => 0) if $h;
	
# if no argument is specified, show usage and exit
	unless($input) {
		pod2usage (-msg => "\nNo arguments specified.\nThe following is the usage.\nTo learn more about the options, use -help or -man to display the man page.\n", -exitval => 0 , -verbose => 0) ;
	}
	
@black_box = split /\s+/,$bbox;
$xcoord_low = $black_box[0];
$ycoord_low = $black_box[1];
$xcoord_high = $black_box[2];
$ycoord_high = $black_box[3];

# if only bottom or upper bound of the coordinates is specified, show usage and exit
if ( ($xcoord_high xor $xcoord_low) or ($ycoord_high xor $ycoord_low) ){
	pod2usage (-msg => "\nTo search by location, enter both bottom and top bounds for the x coord and/or y coord\n", -exitval => 0 , -verbose => 0);
}

# Set the output file name
        if($output) {
                $output_file = $output;
        }
        else {
                $output_file = "parser_power.rpt";
	}

# OPENS FILE "design".power.rpt FOR READING
open (in, $input) or die "can't open file $input\n";
$line_in = <in>;
open (adsLib, ".apache/adsLib.output") or die "can't open file adsLib.output\n";
$line_ads = <adsLib>;
open (apache_clock, ".apache/apache.clock");
$line_clk = <apache_clock>;

open (out, "> $output_file") or die "can't open output file $output_file\n";

print "\nReading File .apache/adsLib.out\n";
while ($line_ads) {
	chomp($line_ads);
	if ($line_ads =~ /^cell\s+/){
		@field = split /\s+/, $line_ads;

		if ($field[5] == 0) {
			$celltype{$field[1]} = "combinational";
		} elsif ($field[5] == 1) {
			$celltype{$field[1]} = "latch";
		} elsif ($field[5] == 2) {
			$celltype{$field[1]} = "flip flop";
		} elsif ($field[5] == 3) {
			$celltype{$field[1]} = "clocked";
		} elsif ($field[5] == 4) {
			$celltype{$field[1]} = "memory";		
		}
	}
	$line_ads = <adsLib>;
}

if ($line_clk) {
	print "\nReading File .apache/apache.clock\n";
}
while ($line_clk) {
	chomp($line_clk);
	if ($line_clk =~ /^Dumping Clock Insts/){
		print "\n$line_clk\n";
	} else {
		@field = split /\s+/, $line_clk;
		$celltype{$field[1]} = "clocked";
	}
	$line_clk = <apache_clock>;
}	
   
print "\nReading file $input\n";
while ($line_in) {
	chomp($line_in);
	if ($line_in =~ /^#/){
		$comment_line = $line_in;
		}else{
		@field = split /\s+/, $line_in;
		
		$instance = $field[0];
		$domain = $field[10];
		
		$hash{$instance}{$domain}{'line'} = $line_in;
		$hash{$instance}{$domain}{'cell'} = $field[1];
		$hash{$instance}{$domain}{'celltype'} = $celltype{$field[1]};
		$hash{$instance}{$domain}{'freq'} = $field[2];
		$hash{$instance}{$domain}{'toggle_rate'} = $field[3];
		$hash{$instance}{$domain}{'lkg_pwr'} = $field[4];
		$hash{$instance}{$domain}{'sw_pwr'} = $field[5];
		$hash{$instance}{$domain}{'int_pwr'} = $field[6];
		$hash{$instance}{$domain}{'total_pwr'} = $field[7];
		$hash{$instance}{$domain}{'xcoord'} = $field[8];
		$hash{$instance}{$domain}{'ycoord'} = $field[9];
		$hash{$instance}{$domain}{'source_lkg_int'} = $field[11];
		$hash{$instance}{$domain}{'domain_type'} = $field[12];
		$hash{$instance}{$domain}{'lkg_current'} = $field[13];
		$hash{$instance}{$domain}{'total_current'} = $field[14];
		$hash{$instance}{$domain}{'library'} = $field[15];
		}
		
	$line_in = <in>;
}

$count = 0;
sub printrpt {

	print out ("$hash{$instance}->{$domain}->{'line'}\n");
	$count++;
		
}

sub add_power_current {

	$sum_lkg_pwr += $hash{$instance}->{$domain}->{'lkg_pwr'};
	$sum_sw_pwr += $hash{$instance}->{$domain}->{'sw_pwr'};
	$sum_int_pwr += $hash{$instance}->{$domain}->{'int_pwr'};
	$sum_total_pwr += $hash{$instance}->{$domain}->{'total_pwr'};
	
	$sum_lkg_current += $hash{$instance}->{$domain}->{'lkg_current'};
	$sum_total_current += $hash{$instance}->{$domain}->{'total_current'};
		
}
	
print "\nWriting summary to file $output_file\n\n";
print out ("$comment_line\n\n");
foreach $instance (keys %hash){
	foreach $domain (keys % { $hash{$instance} }){
		if( ($instance =~ /$inst_exp/) and ($instance =~ /\b$inst\b/) and ($domain =~ /$domain/) and ($hash{$instance}->{$domain}->{'cell'} =~ /$cell_exp/) and ($hash{$instance}->{$domain}->{'cell'} =~ /\b$cell\b/) and ($hash{$instance}->{$domain}->{'freq'} =~ /\b$freq\b/) and ($hash{$instance}->{$domain}->{'library'} =~ /$lib/) and ($hash{$instance}->{$domain}->{'celltype'} =~ /$cell_type/) )
		{
			if( (($xcoord_high eq "") or ($xcoord_low eq "")) and (($ycoord_high eq "") or ($ycoord_low eq "")) ){
				&printrpt;
				&add_power_current;
			}else{
				$x = $hash{$instance}->{$domain}->{'xcoord'};
				$y = $hash{$instance}->{$domain}->{'ycoord'};
				if ( ($x >= $xcoord_low) and ($x <= $xcoord_high) and ($y >= $ycoord_low) and ($y <= $ycoord_high) ){
					&printrpt;
					&add_power_current;
				}
			}
		}
		
	}
}

$count = $count - 1;
if ($count>0){
$avg_lkg_pwr = $sum_lkg_pwr/$count;
$avg_sw_pwr = $sum_sw_pwr/$count;
$avg_int_pwr = $sum_int_pwr/$count;
$avg_total_pwr = $sum_total_pwr/$count;

$avg_lkg_current = $sum_lkg_current/$count;
$avg_total_current = $sum_total_current/$count;


print out ("\n\nADDING ALL THE POWERS");
print out ("\n\n#<leakage_power>	<switching_power>	<internal_power + clk_pin_power>	<total_power>\n");
print out ("$sum_lkg_pwr		$sum_sw_pwr		$sum_int_pwr				$sum_total_pwr\n");
print out ("\n\nAVERAGING ALL THE POWERS");
print out ("\n\n#<leakage_power>	<switching_power>	<internal_power + clk_pin_power>	<total_power>\n");
print out ("$avg_lkg_pwr		$avg_sw_pwr		$avg_int_pwr				$avg_total_pwr\n");
print out ("\n\nADDING ALL THE CURRENTS");
print out ("\n\n#<leakage current>	<total current>\n");
print out ("$sum_lkg_current		$sum_total_current");
print out ("\n\nAVERAGING ALL THE CURRENTS");
print out ("\n\n#<leakage current>	<total current>\n");
print out ("$avg_lkg_current		$avg_total_current");
}else{
print out ("\n\nNO DATA WAS FOUND FOR THE SPECIFIED SEARCH CRITERIA");
}
end;
