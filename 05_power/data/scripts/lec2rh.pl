# $Revision: 1.3 $
# Added formality support(may not be complete)
# Fixed issues related to U$ _reg replacements
# Added -blk option for users to specify
# $Revision: 1.3 $

# Fixed a bug on pin name extraction from LEF
# Modified the behavior on using q_pin for DFF, Default script looks for LEF and uses the OUTPUT pin definition as q pin for DFF, if LEF is not available, user can use -q_pin option to provide output pin name for DFF
# Modified behavior of handling nets and instances in DLAT and DFF, if_reg is present pin name is not added at RTL, if not pin name is added
# $Revision: 1.3 $

# Modified for handling the black boxes as well as special fields inserted by DFT
# $Revision: 1.3 $
eval '(exit $?0)' && eval 'exec perl -S $0 ${1+"$@"}'

&& eval 'exec perl -S $0 $argv:q' if 0;

#This perl script reads in mapped.rpt file created by verplex and outputs a format which is compatible
#with the redhawk tool flow.  This is necessary for RTL VCD dynamic voltage drop simulation
# command line : <perl_pgm_name> -in mapped.rpt -def top level def -ver_dir verilog files path [options]


######################################################################################################################
# Name       : lec2rh.pl
# Description: read in conformal or formality LEC mapping file and output a RedHawk compatible mapping file
# $Revision  :  1.4$
# Author     : Karthik Srinivasan(karthiks@apache-da.com)
######################################################################################################################

=head1 NAME

lec2rh.pl

=head1 SYNOPSIS

lec2rh.pl -in ARGUMENT -def TOP LEVEL DEF -div <hierarchy_separator> -lef_dir LEF_DIR -q_pin <output_pin of the flop> [OPTIONS]

ARGUMENT: LEC(Logic Equivalency Check) Mapping file from Conformal

TOP LEVEL DEF: design top level def file

LEF_DIR: Directory with all the LEF files for macros and memories

-q_pin: Specify the output pin of the flop(whether q or qn default=q)

-div : Specify the hierarchy separator(default: obtained from Top level DEF)

OPTIONS: -h, -help, -man, -o

outputs --> "o' (default is lec2rh.rpt)

=head1 DESCRIPTION

B<lec2rh.pl> reads in the mapped.rpt file.  It also collects design info from DEF/LEF. 
It produces a report which has RTL nets and associated Gate Level Output pins.

=head1 OPTIONS

=over

=item -h

Prints a short synopsis.

=item -help

Prints a short synopsis and description of program options

=item -man

Prints the entire man page

=item -in.

Specify the input filename LEC Mapping filename.  This is a requirment.

=item -o <filename>

Specify the output filename. Optional. Default is "lec2rh.rpt".

=item -def

Specify the top level def file

=item -lef 

Specify the directory with all the macro LEF files

=head1 EXAMPLE

lec2rh.pl -in mapped.rpt -def toplevel.def -lef_dir lef_files/ -div _ -qpin q [options]

=back

=head1 REQUIREMENTS

The user has to specify the mapped.rpt filename,top level def file and LEF file as arguments. Execute the script from the redhawk run directory.  The lef files need to be placed in a single directory and its directory path should be passed as an argument.

=head1 AUTHOR(s)

Karthik Srinivasan, Applications Engineer, Apache Design Solutions

email : karthiks@apache-da.com

=head1 COPYRIGHT

COPYRIGHT (c) 2006 Apache Design Solutions. All rights reserved.

=cut

# end program documentation


use Getopt::Long;
use Pod::Usage;

# begin main program...

        # define script command line options
        my $h   ='';            # short help
        my $help='';            # long help
        my $man ='';            # man page
	# get input options..
        GetOptions( 'h'        => \$h,
                    'help'     => \$help,
                    'man'      => \$man, 
                    'in=s'     => \$input,
		    'def=s'    => \$top_def,
		    'div=s'      => \$divider_char,
		    'lef_dir=s'=> \$lef_path,
		    'q_pin=s'    => \$qpin,
		    'blk=s' => \$blk,
		    'str=s' =>\$substr,
		    'gate=s'=>\$gate,
		    'o=s'      => \$output ) || pod2usage (-verbose => 0);
		               
        # a little documentation for the user...
        pod2usage (-exitval => 0, -verbose => 2) if $man;
        pod2usage (-exitval => 0, -verbose => 1) if $help;
        pod2usage (-msg => "\nThe following is the usage .\n To learn more about the options, use -help or -man to display the manual\n", -exitval => 0 , -verbose => 0) if $h;
	
# if no argument is specified, show usage and exit
	unless($input ) {
		pod2usage (-msg => "\nNo arguments specified.\nThe following is the usage.\nTo learn more about the options, use -help or -man to display the man page.\n", -exitval => 0 , -verbose => 0) ;
	}

# Set the output file name
if($output) {
        $output_file = $output;
}
else {
        $output_file = "lec2rh.rpt";
}

# OPENS FILE "design".power.rpt FOR READING
open (in, $input) or die "can't open file $input\n";
#open (pwr, <adsRpt/*.power.rpt>) or die "can't open pwr rpt file";
open (top_def, $top_def) or die"can't open file $top_def\n";

open (out, "> $output_file") or die "can't open output file $output_file\n";
open( out1,">missing_map_points") or die "Cannot open the output file missing_map_points\n";
open( out2,">missing_lefs") or die "Cannot open the output file to dump out macros missing LEF\n";

############################################################################

if(defined($gate)) {
$gate=1;
}
else {
$gate=0;
}
print "*********GATE $gate*********\n";
# Read top level def
print "\nReading file $top_def\n";
while (<top_def>) {
	#print;
	if (/BUSBITCHARS/){
		@field = split /\"/;
		@bus_delim = split / */, $field[1];
		$bus_delim_left = $bus_delim[0];
		$bus_delim_right = $bus_delim[1];
	}
	if(/DIVIDERCHAR/){
	chomp;
	split;
	($d=$_[1])=~s/\"//g;
		if(!defined($divider_char)) {
		$divider_char=$d;
		print "DIVIDERCHAR=$divider_char, if this is not the divider character separating the hierarchy, please use -div option to specify the hierarchy separator\n";
		}
	}
        if(/\s*COMPONENTS/) {
                $start = 1;
        }
        if(/^\s*END COMPONENTS/) {
                $start = 0;
		last;
        }
        if( $start == 1 ) {
                if(m/^\s*\-\s*/) {
		s/\\//g;
		chomp;
		split; 
			$instance=$_[1];
			if($instance =~ /_reg/g) { $underscore_reg=1;}
		#	print "$instance\n";
			if(m/_MEM\d+\s+/) {
			s/_MEM\d+\s+.*//g;
			($t=$_)=~s/^\s*\-\s+//g;
			$mem_def{$t}=$instance;
			$mem_type{$instance}=$_[2];
#			print "$instance $mem_type{$instance} $mem_def{$t} $t\n";
			}
			elsif(m/_MEM\d+_\S+/) {
			s/^\s*\-\s+(.*)_MEM\d+_(.*)\s+(.*)/$1_$2/g;
			($t=$_)=~s/\s.*//g;
		#	$t=$_;
			$mem_def{$t}=$instance;
			$mem_type{$instance}=$_[2];
		#	print "$t \n";
			}
#			else {
                        $cell_type{"$_[1]"}= $_[2];
#			}
                }
        }
}

print;

# Read <design>.pwr.rpt
#print "\nReading file </adsRpt/*.power.rpt>\n";
#$line_pwr = <pwr>;
#while ($line_pwr) {
#	chomp($line_pwr);
#	if ($line_pwr =~ /^#/){
#		$line_pwr = <pwr>;
#	}else{
#		@field = split /\s+/, $line_pwr;
#		
#		$instance = $field[0];
#				
#		$celltype{$instance} = $field[1];
#		
#		$line_pwr = <pwr>;
#	}
#		
#}

# Read mapped.rpt input file
print "\nReading $input\n";
$line_mapfile = <in>;
$conformal=0;$formality=0;
open(TMP,"$input") || die "cannot open the input mapping file $input:$!\n";
while(<TMP>) {
next if(m/^\s*$/g);
if(m/mapped point/i) {
$conformal=1;
}
elsif(m/Ref\s*DFF\s*Name/i) {
$formality=1;
}
}

#if(($conformal==0)&&($formality==0)) {
#print "The script currently supports only conformal and formality outputs\n";
#print "The input mapping file neither looks like conformal or formality LEC mapping file\n";
#exit;
#}
$i = $j = $k = $n = $o = $p =0;
if($conformal==1) {
print "The LEC mapping file is from CONFORMAL\n";
while ($line_mapfile) {
	chomp($line_mapfile);

	if ($line_mapfile =~ /G.*PI\s+\/(.+)/){
		$_ = $1;
		s/\[/$bus_delim_left/;
		s/\]/$bus_delim_right/;
		$net_name_PI_G[$i] = $_;
		#print "$net_name_PI_G[$i]\n";
		$i++;
	}
	if ($line_mapfile =~ /R.*PI\s+\/(.+)/){
		$_ = $1;
		s/\[/$bus_delim_left/;
		s/\]/$bus_delim_right/;
		$pin_PI_R[$j] = $_;
#		print out "$net_name_PI_G[$j] $blk/$pin_PI_R[$j]\n";
		print out "$net_name_PI_G[$j] ";if(defined($blk)) {print out "$blk/";} 
		print out "$pin_PI_R[$j]\n";
		$j++;
	}	

#########################For handling the blackboxes#############################	
        if ($line_mapfile =~ /G.*BBOX\s+\/(.+)/){
                $_ = $1;
                s/\[/$bus_delim_left/;
                s/\]/$bus_delim_right/;
                $mem_rtl[$o] = $_;
                $o++;
        }
        if ($line_mapfile =~ /R.*BBOX\s+\/(.+)/){
                $_ = $1;
                s/\[/$bus_delim_left/;
                s/\]/$bus_delim_right/;
		s/^\///g;
		($inst=$_)=~s/\//$divider_char/g;
		if(defined($mem_def{$inst})) {
                $mem_gate[$p] = $mem_def{$inst};
	#	print "$mem_gate[$p]\n";
		}
		else {
		$mem_gate[$p]=$inst;
	#	print "$mem_gate[$p]\n";
		}
                $p++;
        }
####################################################################################

	if ($line_mapfile =~ /G.*DFF\s+.*/){
                @t=split(' ',$line_mapfile);
		$_ = $t[4];
                s/^\///g;
                if(((m/_reg\[/ )||(m/_reg$/))&&($gate==0)) {
                s/_reg\[/\[/g;
                s/_reg$//g;
                $reg_dff=1
                }
		else {$reg_dff=0};
		s/\/U\$\d\s*//g;
                $net_DFF_G[$k]=$_;
		$reg_dff{$net_DFF_G[$k]}=$reg_dff;
		#print "$net_DFF_G[$k] $reg_dff\n";
		$k++;
	}
	
	if ($line_mapfile =~ /R.*DFF\s+.*/){
		@t=split(' ',$line_mapfile);
		$_ = $t[4];
		s/^\///g;
		$net_DFF_R[$n]=$_;
		#exit;
#		print "$t[4],$net_DFF_R[$n]\n";exit;
#		$instance_DFF_R[$n] = $2;
#               print "$net_DFF_R[$n]\t$1\t$2\n"; exit;
		$_ = $net_DFF_R[$n];
		s/\/U\$\d//g;
		s/\//$divider_char/g;
#		print "$_\n";
		$net_DFF_R[$n] = $_;
#		print out "$net_name_DFF_G[$n] $net_DFF_R[$n]\/$qpin\n";
		$n++;
	}

####################Handling DLAT#######################################
        if ($line_mapfile =~ /G.*DLAT\s+.*/){
                @t=split(' ',$line_mapfile);
                $_ = $t[4];
		s/^\///g;
		if(((m/_reg\[/ )||(m/_reg$/))&&($gate==0)) {
		s/_reg\[/\[/g;
		s/_reg$//g;
		$reg=1
		}
		else { $reg=0; }
                s/\/U\$\d\s*//g;
                $net_DLAT_G[$q]=$_;
		$reg{$net_DLAT_G[$q]}=$reg;
		$reg=0;
                $q++;
        }
        
        if ($line_mapfile =~ /R.*DLAT\s+.*/){
                @t=split(' ',$line_mapfile);
                $_ = $t[4];
                s/^\///g;
                $net_DLAT_R[$r]=$_;
                $_ = $net_DLAT_R[$r];
                s/\/U\$\d\s*//g;
                s/\//$divider_char/g;
                $net_DLAT_R[$r] = $_;
             #   print out "$net_name_DFF_G[$n] $net_DFF_R[$n]\/$qpin\n";
                $r++;
        }

###########################################################################

	$line_mapfile = <in>;
}
$count_pi = $i-1;
$count_dlat=$r-1;
$count_mem = $p-1;
$count_dff = $n-1;
}
elsif($formality==1) {
print "The LEC mapping file is from FORMALITY\n";
while ($line_mapfile) {
	chomp($line_mapfile);

	if ($line_mapfile =~ /Ref.*Port\s+Name.*\s*r:(.+)/){
		$_ = $1;
		#print;
		s/$substr//g;
		#print "  $_\n";
		s/\[/$bus_delim_left/;
		s/\]/$bus_delim_right/;
		$net_name_PI_G[$i] = $_;
		#print "$net_name_PI_G[$i]\n";
		$i++;
	}
	if ($line_mapfile =~ /Impl.*Port\s+Name.*\s*i:(.+)/){
		$_ = $1;
		s/$substr//g;
		s/\[/$bus_delim_left/;
		s/\]/$bus_delim_right/;
		$pin_PI_R[$j] = $_;
		#print out "$net_name_PI_G[$j] $pin_PI_R[$j]\n";
		print out "$net_name_PI_G[$j] ";if(defined($blk)) {print out "$blk/";} 
		print out "$pin_PI_R[$j]\n";
		$j++;
	}	

#########################For handling the blackboxes#############################	
        if ($line_mapfile =~ /Ref.*BBox\s+Name.*\s*r:(.+)/){
                $_ = $1;
		s/$substr//g;
                s/\[/$bus_delim_left/;
                s/\]/$bus_delim_right/;
                $mem_rtl[$o] = $_;
                $o++;
        }
        if ($line_mapfile =~ /Impl.*BBox\s+Name.*\s*i:(.+)/){
                $_ = $1;
		s/$substr//g;
                s/\[/$bus_delim_left/;
                s/\]/$bus_delim_right/;
		s/^\///g;
		($inst=$_)=~s/\//$divider_char/g;
		if(defined($mem_def{$inst})) {
                $mem_gate[$p] = $mem_def{$inst};
	#	print "$mem_gate[$p]\n";
		}
		else {
		$mem_gate[$p]=$inst;
	#	print "$mem_gate[$p]\n";

		}
                $p++;
        }
####################################################################################

	if ($line_mapfile =~ /Ref\s*DFF.*\s+Name.*\s*r:(.+)/){
                #@t=split(':',$line_mapfile);
		$_ = $1;
		s/$substr//g;
		#print "$_\n";
                s/^\///g;
                if((m/_reg\[/ )||(m/_reg$/)) {
                s/_reg\[/\[/g;
                s/_reg$//g;
                $reg_dff=1
                }
                $net_DFF_G[$k]=$_;
		$reg_dff{$net_DFF_G[$k]}=$reg_dff;
		$k++;
	}
	
	if ($line_mapfile =~ /Impl\s*DFF.*\s+Name.*\s*i:(.+)/){
		#@t=split(':',$line_mapfile);
		$_ = $1;
		s/$substr//g;
		#print "$_\n";
		s/^\///g;
		$net_DFF_R[$n]=$_;
		#exit;
#		print "$t[4],$net_DFF_R[$n]\n";exit;
#		$instance_DFF_R[$n] = $2;
#               print "$net_DFF_R[$n]\t$1\t$2\n"; exit;
		$_ = $net_DFF_R[$n];
		s/\/U\$\d//g;
		s/\//$divider_char/g;
		$net_DFF_R[$n] = $_;
#		print out "$net_name_DFF_G[$n] $net_DFF_R[$n]\/$qpin\n";
		$n++;
	}

####################Handling DLAT#######################################
        if ($line_mapfile =~ /Ref.*LAT.*\s+Name.*\s*r:(.+)/){
           #     @t=split(':',$line_mapfile);
                $_ = $1;
		s/$substr//g;
		#print "$_\n";
		s/^\///g;
		if((m/_reg\[/ )||(m/_reg$/)) {
		s/_reg\[/\[/g;
		s/_reg$//g;
		$reg=1
		}
		else { $reg=0; }
                s/\/U\$\d\s*//g;
                $net_DLAT_G[$q]=$_;
		$reg{$net_DLAT_G[$q]}=$reg;
                $q++;
        }
        
        if ($line_mapfile =~ /Impl.*LAT\s+Name.*\s*i:(.+)/){
               # @t=split(':',$line_mapfile);
                $_ = $1;
		s/$substr//g;
		#print "$_\n";
                s/^\///g;
                $net_DLAT_R[$r]=$_;
                $_ = $net_DLAT_R[$r];
                s/\/U\$\d\s*//;
                s/\//$divider_char/g;
                $net_DLAT_R[$r] = $_;
             #   print out "$net_name_DFF_G[$n] $net_DFF_R[$n]\/$qpin\n";
                $r++;
        }

###########################################################################

	$line_mapfile = <in>;
}
$count_pi = $i-1;
$count_dlat=$r-1;
$count_mem = $p-1;
$count_dff = $n-1;
}
else {
print "The script currently supports only conformal and formality outputs\n";
print "The input mapping file neither looks like conformal or formality LEC mapping file\n";
exit;
}


#exit;
# Read lef files
@files = <$lef_path/*>;
foreach $file (@files){
	print "\n Reading Lef File $file\n";
	open (lef_file, $file) or die "can't open $file\n";
	$line_file = <lef_file>;
	while ($line_file){
		chomp($line_file);
		($_=$line_file)=~s/\s*$//g;
		 $line_file=$_;
		if ($line_file =~ /^\s*MACRO/){
#			$macro = $1;
			chomp($line_file);@field=split(' ',$line_file);
			$macro=$field[1];
#			print "$macro\n";
		}
		if ($line_file =~ /^\s*PIN/){
#			$pin = $1;
			chomp($line_file);@field=split(' ',$line_file);
			$pin=$field[1];
#			print "$pin\n";

		}
		if ($line_file =~ /DIRECTION OUTPUT/){
			$out_pin{$macro}{$pin} = $pin;
			$opin{$macro}=1;
#			print "$macro $out_pin{$macro}{$pin} \$opin{$macro} --> $opin{$macro} \n";
		}
		
		$line_file = <lef_file>;
	}
}

#Processing RTL net names
#Print RTL net names Gate Output pins
print "\nWriting Report\n";
#print out ("# RTL net Gate Output Pin\n");
#
#for ($i=0;$i<=$count_pi;$i++){
#	print out ("$net_name_PI_G[$i] $pin_PI_R[$i]\n");
#}
#
print out1 "#Instances with missing master cell or missing instantiation in DEF are listed here\n";
print out1 "#Please check the consistency between the generated mapping file and DEF\n";
print out2 "#Master cell missing LEF views are listed below\n#Please read the LEF for these Macros\n";
print "\nProcessing RTL net names\n";				

if($formality==1) {
$substr="";
#print "$formality $substr\n";
}	
################################################
for ($i=0;$i<=$count_dff;$i++){
	if(defined($cell_type{$net_DFF_R[$i]})) {
	$cell=$cell_type{$net_DFF_R[$i]};
	}
	else {
	print out1 "$net_DFF_R[$i]\n"; 
	next if(!defined($qpin));# *********Modified on 7/21/2008
	}
#	print "$cell $net_DLAT_R[$i] \n";
#	print "$cell $opin{$cell}\n";
	if(!defined($opin{$cell})) {
	print out2 "$cell\n";
	}
	if(defined($qpin) ) {
#		print out "AAAA\n";
		if($gate==0) {
		print out ("$net_DFF_G[$i] ");
		print out "$blk/" if(defined($blk));
		print out "$net_DFF_R[$i]/$qpin\n";
		}
		else {
		print out ("$net_DFF_G[$i]/$qpin ");
		print out "$blk/" if(defined($blk));
		print out ("$net_DFF_R[$i]/$qpin\n");
		}
	}
	else {
		foreach $pin (keys %{$out_pin{$cell}}){
                if($reg_dff{$net_DFF_G[$i]}==1 && $gate==0) {
#                print out ("$net_DFF_G[$i] $blk/$net_DFF_R[$i]/$out_pin{$cell}->{$pin}\n");
                print out "$net_DFF_G[$i] ";
		if(defined($blk)) {print out "$blk/";}
		print out "$net_DFF_R[$i]/$out_pin{$cell}->{$pin}\n";
                }
                else {
#                print out ("$net_DFF_G[$i]/$out_pin{$cell}->{$pin} $blk/$net_DFF_R[$i]/$out_pin{$cell}->{$pin}\n");
                print out "$net_DFF_G[$i]/$out_pin{$cell}->{$pin} ";
		if(defined($blk)) {print out "$blk/";}
		print out "$net_DFF_R[$i]/$out_pin{$cell}->{$pin}\n";
                }
#		print out ("$net_DFF_G[$i] $net_DFF_R[$i]/$out_pin{$cell}->{$pin}\n");
		}
	}
}	
################################################

for ($i=0;$i<=$count_mem;$i++){
	if(defined($mem_type{$mem_gate[$i]})) {
	$cell = $mem_type{$mem_gate[$i]};
	}
	else {
	$cell=$cell_type{$mem_gate[$i]};
	}
#	print "$cell $mem_gate[$i] \n";
	if((!defined($mem_type{$mem_gate[$i]})) &&(!defined($cell_type{$mem_gate[$i]}))) {
		print out1 "$mem_gate[$i] \n";next;
	}
	if(!defined($opin{$cell})) {
	print out2 "$cell\n";
	}
	foreach $pin (keys %{$out_pin{$cell}}){
	#	print out ("$mem_rtl[$i]/$out_pin{$cell}->{$pin} $blk/$mem_gate[$i]/$out_pin{$cell}->{$pin}\n");
		print out "$mem_rtl[$i]/$out_pin{$cell}->{$pin} ";
		if(defined($blk)) {print out "$blk/";}
		print out "$mem_gate[$i]/$out_pin{$cell}->{$pin}\n";
	}
}

###############################################	
for ($i=0;$i<=$count_dlat;$i++){
	if(defined($cell_type{$net_DLAT_R[$i]})) {
	$cell=$cell_type{$net_DLAT_R[$i]};
	}
	else {
	print out1 "$net_DLAT_R[$i]\n"; next if(!defined($qpin)); #***********Modified on 7/21/2008
	}
#	print "$cell $net_DLAT_R[$i] \n";
#	print "$cell $opin{$cell}\n";
	if(!defined($opin{$cell})) {
	print out2 "$cell\n";
	}

#************ lines modified on 7/21/2008#############
        if(defined($qpin) ) {
#               print out "AAAA\n";
		if($gate==0) {
                print out ("$net_DFF_G[$i] ");
                if(defined($blk)) {print out "$blk/";}
		print out ("$net_DFF_R[$i]/$qpin\n");
		}
		else {
                print out ("$net_DFF_G[$i]/$qpin ");
                if(defined($blk)) {print out "$blk/";}
		print out ("$net_DFF_R[$i]/$qpin\n");
		}
        }
#******************************************************
        else {
	foreach $pin (keys %{$out_pin{$cell}}){
		if($reg{$net_DLAT_G[$i]}==1 && $gate ==0) {
	#	print out ("$net_DLAT_G[$i]	$blk/$net_DLAT_R[$i]/$out_pin{$cell}->{$pin}\n");
		print out "$net_DLAT_G[$i] ";
                if(defined($blk)) {print out "$blk/";}
		print out "$net_DLAT_R[$i]/$out_pin{$cell}->{$pin}\n";
		}
		else {
#		print out ("$net_DLAT_G[$i]/$out_pin{$cell}->{$pin} $blk/$net_DLAT_R[$i]/$out_pin{$cell}->{$pin}\n");
		print out "$net_DLAT_G[$i]/$out_pin{$cell}->{$pin} ";
               if(defined($blk)) {print out "$blk/";}
	       print out "$net_DLAT_R[$i]/$out_pin{$cell}->{$pin}\n";
		}
	}
	}
}	
###################################################

print "\nMapping file $output_file is generated successfully\n\n";

print " Please check missing_lefs and missing_map_points file for coverage of the generated mapping file\n";
#end;
