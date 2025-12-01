#!/usr/bin/perl
#################################################################
#Author : Sooyong Kim  2008.6
#Purpose: Script to generate CMM detail view 
#################################################################
#revision 1.5 : user now can set lib/lef dir and suffix, lef header file name to speed up make_cmm runs. 
#             
#revision 1.4 : LEF_SCAILING/DEF_SCALING will be inherited
#revision 1.3 : FREQ will be parsed as well as FREQENCY
#               Note change added for usage
#revision 1.2 : include option for additional keyword in gsr file -inc_gsr
#               changed -no_l to -l 
#               get rid of the comment lines from gsr
#revision 1.1 : changed output gsr file to contatin the options copied from original gsr file. 
#               include the -no_l option to include inductance extraction default is inductance extraction on  
#################################################################################################
use Getopt::Long;

my($help) ;
my($gsrfile_ini) = "chip.gsr";
my($gsrfile) = ".intermidiate.gsr";
my($memlistfile) = "memlist";
#my($no_l) = 0;
my($lib_dir) = "";
my($lef_dir) = "";
my($lef_header ) = "";
my($lef_suffix) = ".lef";
my($lib_suffix) = ".lib";
GetOptions("help|h"=>\$help,
	   "gsr|g=s"=>\$gsrfile_ini,
	   "l"=>\$yes_l,
	   "inc_gsr|inc|i:s"=>\$inc_gsr,
	   "memlist|mem|m=s"=>\$memlistfile,
           "lib_dir|lib=s"=>\$lib_dir,
           "lef_dir|lef=s"=>\$lef_dir,
           "lef_header=s"=>\$lef_header,
           "lef_suffix=s"=>\$lef_suffix,
           "lib_suffix=s"=>\$lib_suffix);
print "Unprocessed by Getopt::Long\n" if $ARGV[0];

if ($help) {
printUsage();
exit;   
} 

sub printUsage
{
print "USAGE :: \n\
perl make_cmm.pl <options>
-gsr | -g 		<gsr file> required
			gets chip.gsr if not defined. 
-memlist | mem | m 	<memory list file> required
			gets memory list file that has the following format
			cell_name gds2def_view_location_for_cell
			comment line in the memlist will be ignored 
-l                      inductance extraction ( default : l NOT extracted ) (optional)
-inc_gsr | i | inc      add extra keywords to the gsrs under cmmOutDir (optional) 
-lib_dir		directory that contains .lib file (optional) 
-lef_dir		directory that contains .lef/.plef file ( default : .lef ) (optional)
-lib_suffix		suffix used for .lib file ( defaul : .lib ) (optional)
-lef_suffix		suffix used for .lef file ( defaul : .lef ) (optional)
-lef_header		lef_header file name ( default : \"\" ) (optional)
-help | -h		print help message

will produce make_cmm.node file which can be copied to the top level run and can be used as the input file for stat.pl

NOTE : start using this script with an empty memlist, it will only create \"template_gsr\" file, which is the base gsr file for redhawk run except for the GDS_CELLS definition. If you found any missing gsr keywords use -inc_gsr option to add those missing keyword into template_gsr.   
";
}
#################################################################################################
my($tech_file) = "";
my($flag_lib)= 0;
my($flag_lef)= 0;
my($pre)="";
my($count_open)=0;
my($count_close)=0;
my($cmmOutDir) = "cmmOutDir";
#clean up comment line 
open( GSR_INI, "$gsrfile_ini")  || die "$gsrfile_ini  does not exist. : $!";
open( GSR_CLEAN, ">$gsrfile" ) || die "fail to create $gsrfile. : $!";
while (<GSR_INI>) {
chomp;
print GSR_CLEAN "$_\n" unless (/^\s*#/) ;
}
close (GSR_INIT);
close ( GSR_CLEAN ) ;

open( MAKE_CMM, ">make_cmm.node") || die "fail to create log file : $!";
open( MEM_LIST, "$memlistfile") || warn "$memlistfile does not exist. create one for the list of cellsl for CMM creation : $!";

open( GSR, "$gsrfile") || die "$gsrfile does not exist. create one for synlib, original lef, vdd nets and vss nets : $!";

open( EXTRACT, ">template_gsr" ) || die "faile to create extracted file : $!";

while (<GSR>) {
chomp($_);
$input_transition = $_ if (/^\s*INPUT_TRANSITION\s+/);
$temperature = $_ if (/^\s*TEMPERATURE\s+/);
$toggle_rate = $_ if (/^\s*TOGGLE_RATE\s+/) ;
$frequency = $_ if (/^\s*FREQUENCY\s+/ || /^\s*FREQ\s+/ ) ;
$interconnect_gate_cap_ratio = $_ if (/^\s*INTERCONNECT_GATE_CAP_RATIO\s+/) ;
$steiner_tree_cap = $_ if (/^\s*STEINER_TREE_CAP\s+/) ;
$lowest_metal = $_ if (/^\s*LOWEST_METAL\s+/);
$lextraction_mode = $_ if (/^\s*LEXTRACTION_MODE\s+/);
$lextraction_freq = $_ if (/^\s*LEXTRACTION_FREQ\s+/);

split(/\s+/ , $_ );
if (/TECH_FILE/) { print EXTRACT "$_\n";}
if ( $flag_tech_file == 1 ) { 
	if (/}/) { print EXTRACT "$_\n"; $flag_tech_file=0; }
	else { print EXTRACT "$_\n";}
}
if (/TECH_FILE\s*{/) { $flag_tech_file =1 ;}
}
close(GSR);

############Added switch model file support and some special keywords #############
open(GSR,"$gsrfile")||die "$gsrfile does not exist. create one for synlib original lef,vdd nets and vss nets:$!\n";
while(<GSR>) {
chomp;
$split_sparse=$_ if(/^\s*SPLIT_SPARSE_VIA_ARRAY\s+/);
$internal_net=$_ if(/^\s*EXTRACT_INTERNAL_NET\s+/);
if(/\s*SWITCH_MODEL_FILE/) { print EXTRACT "$_\n"; }
	if($flag_switch_file == 1 ) {
	        if(/}/) { print EXTRACT "$_\n"; $flag_switch_file=0; }
	        else { print EXTRACT "$_\n"; }
	}
	if (m/^\s*SWITCH_MODEL_FILE\s*{/) { $flag_switch_file=1; }
}
close(GSR);
###########Added APL_FILES support#################################
open(GSR,"$gsrfile")||die "$gsrfile does not exist. create one for synlib original lef,vdd nets and vss nets:$!\n";
while(<GSR>) {
chomp;
if(/\s*APL_FILES/) { $flag_apl_file=1;}
	if($flag_apl_file== 1 ) {
		if(/}/) { print EXTRACT "$_\n CMM_INCLUDE_APL 1\n"; $flag_apl_file=0; }
		else { print EXTRACT "$_\n"; }
	}
}                                                                                                 close(GSR);

open( GSR, "$gsrfile") || die "$gsrfile does not exist. create one for synlib, original lef,vdd nets and vss nets : $!";
while (<GSR>) {
chomp($_);
#split(/\s+/ , $_ );
if (/LEF_SCALING_FACTOR/) { print EXTRACT "$_\n";}
if ( $flag_lef_scaling_factor == 1 ) {
        if (/}/) { print EXTRACT "$_\n"; $flag_lef_scaling_factor=0; }
        else { print EXTRACT "$_\n";}
}
if (/LEF_SCALING_FACTOR\s*{/) { $flag_lef_scaling_factor =1 ;}
}
close(GSR);

open( GSR, "$gsrfile") || die "$gsrfile does not exist. create one for synlib, original lef,vdd nets and vss nets : $!";
while (<GSR>) {
chomp($_);
#split(/\s+/ , $_ );
if (/DEF_SCALING_FACTOR/) { print EXTRACT "$_\n";}
if ( $flag_def_scaling_factor == 1 ) {
        if (/}/) { print EXTRACT "$_\n"; $flag_def_scaling_factor=0; }
        else { print EXTRACT "$_\n";}
}
if (/DEF_SCALING_FACTOR\s*{/) { $flag_def_scaling_factor =1 ;}
}
close(GSR);


open( GSR, "$gsrfile") || die "$gsrfile does not exist. create one for synlib, original lef,vdd nets and vss nets : $!";
print "what is lib_dir specified? $lib_dir \n";
unless ($lib_dir) {
while (<GSR>) {
chomp($_);
if (/LIB_FILES/) {
$flag_lib = 1;
$flag_lib_l =1;
}
if (/^}/) {$flag_lib = 0;}
#if ($flag_lib ) {push (@syn_lib_list ,$_) ; }
if ($flag_lib ) {print EXTRACT "$_\n"}
}
print EXTRACT "}\n" if ($flag_lib_l);
} #if ($lib_dir)
close(GSR);
#print STDOUT "@syn_lib_list\n";

open( GSR, "$gsrfile") || die "$gsrfile does not exist. create one for synlib, original lef,vdd nets and vss nets : $!";
unless ($lef_dir) {
while (<GSR>) {
chomp($_);

split(/\s+/ , $_ );

if(/LEF_FILES/) {
$flag_lef = 1;
$flag_lef_l=1;
}
if (/^}/) {$flag_lef = 0;}
#if ($flag_lef) {push (@lef_list ,$_); } 
if ($flag_lef) {print EXTRACT "$_\n";}
}
print EXTRACT "}\n" if ($flag_lef_l);
} #if ($lef_dir)
close(GSR);

open( GSR, "$gsrfile") || die "$gsrfile does not exist. create one for synlib, original lef,vdd nets and vss nets : $!"; 

while (<GSR>) {
chomp($_);
split(/\s+/ , $_ ); 

if (/VDD_NETS/) {
$flag_vdd = 1;
$flag_vdd_l =1;
}

if ( /{/ && $flag_vdd ) {$count_open +=1;}
if ( /}/ && $flag_vdd ) {$count_close +=1;}

if ($count_open == $count_close) {$flag_vdd = 0;}
if ($flag_vdd) {print EXTRACT "$_\n";}
}
print EXTRACT "}\n" if ($flag_vdd_l);
close(GSR);

my($flag_gnd)=0;
$count_open=0;
$count_close=0;

open( GSR, "$gsrfile") || die "$gsrfile does not exist.  $!"; 

while (<GSR>) {
chomp($_);
split(/\s+/ , $_ ); 

if (/GND_NETS/) {
$flag_gnd = 1;
$flag_gnd_l =1;
}

if ( /{/ && $flag_gnd ) {$count_open +=1;}
if ( /}/ && $flag_gnd ) {$count_close +=1;}

if ($count_open == $count_close) {$flag_gnd = 0;}
if ($flag_gnd) {print EXTRACT "$_\n";}
}
print EXTRACT "}\n" if ($flag_gnd_l);
close(GSR);

print EXTRACT "$lowest_metal\n$lextraction_mode\n$lextraction_freq\n$input_transition\n$temperature\n$toggle_rate\n$frequency\n$interconnect_gate_cap_ratio\n$steiner_tree_cap\n$internal_net\n$split_sparse\n"; 
	open( GSRINC, "$inc_gsr") || warn "$inc_gsr does not exist.  $!";
	while (<GSRINC>) {
	chomp;
	print EXTRACT "$_\n";
	}
	close(GSRINC);
close(EXTRACT);

while (<MEM_LIST>) {
chomp($_);
$_ =~ s/^\s+//;
if (/^#/ || /^\s*$/ ) {
}

else {

($mem_name, $gds2def_dir) = split (/\s+/ , $_ ); 
#print MAKE_CMM "$mem_name, $gds2def_dir\n";
mkdir ("$cmmOutDir",0755) || warn "cannot mkdir $cmmOutDir : $!";
chdir ("$cmmOutDir") || die "cannot cd to $cmmOutDir : $!";
mkdir ("$mem_name",0755) || warn "cannot mkdir $mem_name : $!";
chdir ("..") || die "cannot cd to .. : $!";

#mkdir ($cmmOutDir/$mem_name,0755) || warn "cannot mkdir $cmmOutDir/$mem_name : $!";

open( CMD, ">$cmmOutDir/$mem_name/$mem_name.cmd" );
print CMD "import gsr $cmmOutDir/$mem_name/$mem_name.gsr\n";
print CMD "setup design\n";
print CMD "perform extraction -power -ground -c\n" if ($yes_l == 0);
print CMD "perform extraction -power -ground -c -l\n" if ($yes_l == 1);
print CMD "save design -o $cmmOutDir/$mem_name/$mem_name.detail.db\n";
print CMD "exit\n";
close(CMD);

open(GSROUT, ">$cmmOutDir/$mem_name/$mem_name.gsr" );
print GSROUT "ADD_PLOC_FROM_TOP_DEF 1\n";
print GSROUT "CMM_MODEL_CREATION 1\n";
print GSROUT "CMM_EXPAND_PINS_AT_TOP 1\n";
#print GSROUT "CMM_INCLUDE_APL 1\n";
#print GSROUT "LIB_FILES {\n$syn_lib\n}\n";
open(EXT, "template_gsr");
while (<EXT>) {
chomp($_);
split (/\s+/ , $_ );
print GSROUT "$_\n";
}
close(EXT);
print GSROUT "GDS_CELLS {\n$mem_name $gds2def_dir\n}\n";
print GSROUT "LIB_FILES {\n$lib_dir/$mem_name$lib_suffix\n}\n" if ($lib_dir);
print GSROUT "LEF_FILES {\n$lef_dir/$mem_name$lef_suffix\n$lef_header\n}\n" if ($lef_dir);
#print GSROUT "TECH_FILE $tech_file\n";
#print GSROUT "VDD_NETS {\n$vdd_net $vdd_vol\n}\n";
#print GSROUT "GND_NETS {\n$vss_net 0\n}\n";
;
close(GSROUT);
}

}
close(MEM_LIST);
my ($cmm_cells_1st_line)=1;
open( MEM_LIST, "$memlistfile") || die "$memlistfile does not exist. create one for the list of cellsl for CMM creation : $!"; 
while (<MEM_LIST>) {
chomp($_);
$_ =~ s=^\s+==;
($mem_name, $gds2def_dir) = split (/\s+/ , $_ ); 
if (/^#/ || /^\s*$/) {
}
else {
#system("cd $mem_name");
#chdir("$mem_name") || die "cannot cd to $mem_name : $!";
system("redhawk_tcl  $cmmOutDir/$mem_name/$mem_name.cmd -lmwait");
print STDOUT "redhawk_tcl  $cmmOutDir/$mem_name/$mem_name.cmd -lmwait\n";
system("mv -f .apache/.statistic  $cmmOutDir/$mem_name/statistic");
system("cp -f adsRpt/redhawk.log  $cmmOutDir/$mem_name/redhawk.log");
system("rm -rf adsRpt adsPower .apache .MM* *detail.db");
#system("cd ..");
#chdir("..") || die "cannot cd to .. : $!";
open (STAT,"$cmmOutDir/$mem_name/statistic");
if ( $cmm_cells_1st_line == 1 ) {  print MAKE_CMM "CMM_CELLS {\n"; $cmm_cells_1st_line=0;}
while (<STAT>) {
chomp($_);
split (/\s+/ , $_ ); 
if (/^Node/) {
print MAKE_CMM "$mem_name $cmmOutDir/$mem_name/$mem_name.detail.db \n";
print MAKE_CMM "#$mem_name  Node : $_[2]  ";}
if (/^Resistor/) {print MAKE_CMM "Resistor : $_[2]\n";}
}
#print MAKE_CMM "$mem_name, $gds2def_dir\n";
}
}
print MAKE_CMM "}";
close(MEM_LIST);
close(MAKE_CMM);

### create new gsr for the chip level CMM run

system ("\rm .intermidiate.gsr") if (-e ".intermidiate.gsr" );
