#!/usr/bin/perl
#################################################################
#Author : Sooyong Kim  2008.6
#Purpose: Script to generate runtime report to copy paste to excel 
#################################################################
#revision 1.1 : correct bugs in getting runtime from sir option, put better indentation for excel formatted output  
#revision 2.0 : expand the script to save the necessary files to ../<dirname>_<date_time>, script will propose a good practice to debug a large design debug flow 
#revision 3.0 : generate a new lightweight format for excel tables. get_runstat_short.out. This output is default.
#revision 3.1 : copy and paste some lines from .nodestatistic to the output file : get_runstat.out
#revision 3.2 : check if there is APACHE_FILES debug option in gsr 
#################################################################################################
use Getopt::Long;
use Switch;
my($help) ;
my($logfile) = "adsRpt/redhawk.log";
my($output) = "get_runstat.out";
my($save_mode) = 0;
my($count_gds_cells) =my($gds_cells_keyword_found) = my($gds_cells_keyword_found_check)=0;
#if (-f ".apache/.statistic_0") {
#my($dotstatfile) = ".apache/.statistic_0";
#}
#if (-f ".apache/.statistic" ) {
my($dotstatfile) = ".apache/.statistic"; 
#}
my($debugdynamicfile) = ".apache/.debug.dynamic";
my($dotnxfile) = ".apache/.nx.log";
#if (-e ".apache/.run.setting" ) {
#my($dotrunsettingfile) = ".apache/.run.setting";
#}
#if (-e ".run.setting" ) {
my($dotrunsettingfile) = ".run.setting";
#}
my $dotnodestatistic = ".apache/.nodestatistic";
my($gsrfile) = "";
my($email) = "";
GetOptions("help|h"=>\$help,
	   "statistic|stat|s=s"=>\$dotstatfile,
	   "nx|nxfile|n=s"=>\$dotnxfile,
	   "runsetting|run|r=s"=>\$dotrunsettingfile,
	   "email|e=s"=>\$email,
	   "gsr|g=s"=>\$gsrfile,
	   "output|outfile|out|o=s"=>\$output,
	   "save|s=s"=>\$save_mode,
	   "log|l=s"=>\$logfile);
print "Unprocessed by Getopt::Long\n" if $ARGV[0];

if ($help) {
printUsage();
exit;   
} 

sub printUsage
{
print "
This script will create a snapshot report from RH run
The information includes build used, machine, runtime, memory, disk space ussage, performance related information, license usage, high level power/IR drop, gsr options. 
Also the script can save some information from the current runs for later use.
The script will create an $output. The script can copy a few files over to <run_dir>_date_time dir for later debugging purpose.
\"$output\" file is excel friendly and can be copied to an excel spreadsheet. 

USAGE :: \n\
perl get_runtime.pl <options>
-log | -l  		<log file> default: adsRpt/redhawk.log
-statistic | stat | s   <.statistic file> default: .apache/.statistic
-nx | nxfile | n        <.nx.log file> default: .apache/.nx.log
-runsetting | run | r   <.run.setting file> default : ./.run.setting
-gsr | g 		<gsr file> default : none
-output|outfile|out|o	<output file > default get_runstat.out, also a lightweighted version of output will be dumped out : get_runstat_short.out
-save                   save necessary files 
			0 : default(no saving) 1: saving least necessary files 2: saving the detailed for node profiling/dvd comparison/static ir comparison
-help | -h		print help message

#### APACHE_FILES debug in gsr recommended to be set for more detail report for complexity check
#### set ::env(ASIM_PEAK_MEMORY) 1 in command file or setenv ASIM_PEAK_MEMORY 1 in unix terminal is needed
#### along with gsr keyword DEBUG_ENVIRONMENT 1 for asim peak memory report in log file

";
}
#-email | e		<email address> will $output to email address. default : no email
#################################################################################################
my($flag1) =0;
my($result) ="";
my($count_step) =0;
my(@walltime) ="";
my(@cputime) ="";
my(@memory) ="";
my(@step) ="";
my($found_version_flag) =0;
my($found_design_flag) =0;
my($found_techfile_flag)=0;
my($found_machine_flag)=0;
my($found_runsetup)=0;
my($found_systeminfocheck)=0;
open( LOG, "$logfile") || warn "$logfile does not exist : $!\n";
open( OUTPUT, ">$output") || die "cannot create runtime file: $!\n";
open( DOTSTAT, "$dotstatfile") || warn "$dotstatfile does not exist : $!\n";
open( DEBUGDYNAMIC, "$debugdynamicfile") || warn "$debugdynamicfile  does not exist : $!\n";
open(DEBUGSTATIC, ".apache/.debug.static" ) || warn ".apache/.debug.static  does not exist : $!\n";
open( DOTNX, "$dotnxfile") || warn "$dotnxfile dest not exist : $!\n";
open( DOTRUNSET, "$dotrunsettingfile") || warn "$dotrunsettingfile does not exist : $!\n";
#if ( $gsrfile != "" ) { open( GSRFILE, "$gsrfile" ) || warn "$gsrfile does not exist : $!\n"; }
open( GSRFILE, "$gsrfile" ) || warn "gsrfile $gsrfile does not exist  : $!\n"; 
open( DOTNODE, "$dotnodestatistic") || warn "$dotnodestatistic does not exist : $!\n";

create_hash ();

#added by Ruizhen Guo on 9/17/2013 
# global variables declaration 
my $version_lw;
my $debug_dynamic_node_lw = "N/A";
my $debug_dynamic_r_lw = "N/A";
my $rn_ratio_dotstat = "rn ratio missing";

my $total_size = 0;
my $adsrpt_size_lw;
my $adspower_size_lw;
my $dotapache_size_lw;

while (<LOG>) {
chomp($_);
$_ =~ s/MEMORY USAGE \(import ApacheDB\):/MEMORY USAGE\(importApacheDB\):/;
$_ =~ s/WALLTIME \(After post-processing\):/WALLTIME\(Afterpost-processing\)/;
$_ =~ s/MEMORY USAGE \(report dynamic simulation results/MEMORY USAGE\(reportdynamicsimulationresults/;
$_ =~ s/MEMORY USAGE \(Start dynamic simulation\):/MEMORY USAGE\(Startdynamicsimulation\):/;
$_ =~ s/MEMORY USAGE \(dynamic simulation\):/MEMORY USAGE\(dynamicsimulation\):/;
$_ =~ s/MEMORY USAGE \(export ApacheDB\):/MEMORY USAGE\(exportApacheDB\):/;
#split(/\s+/ , $_ );
if (!$found_runsetup) {print OUTPUT "###RUN SETUP\n";$found_runsetup=1;}
if (/RedHawk/ && /Power and Ground Network Analyzer/ && !$found_version_flag) {split; $version_lw = "$_[1] $_[2] $_[3] $_[4] $_[5]"; print OUTPUT "Tool Version Used\t$version_lw\n"; $found_version_flag =1; }
#if (/Reading the timing file/ && !$found_design_flag ) {$_=~ s/<//g; $_=~ s/>//g; split ;  print OUTPUT "Design name\t$_[7]\n"; $found_design_flag =1;}
#if (/^File name is / && /.tech$/ && !$found_techfile_flag ) {split; print OUTPUT "Tech File :\t$_[3]\n"; $found_techfile_flag =1;}
if (/Running on/ && !$found_machine_flag ) {split; print OUTPUT "Machine Used\t$_[3]\n"; $found_machine_flag = 1;}

if (!$found_systeminfocheck && /Running on/ ) {
$hostname = `hostname`; $uname = ` uname -a`; $release = `head -n1 /etc/issue`; $memtotal = `grep MemTotal /proc/meminfo`; $cpuinfo_c =`grep 'model name' /proc/cpuinfo | wc -l`; $cpuinfo_t = `grep 'model name' /proc/cpuinfo | head -1 `;
chomp( $cpuinfo_c ) ;
print OUTPUT "\n###SYSTEM INFORMATION\nMachine Type\t${uname}OS Release\t${release}Available Memory\t${memtotal}CPU Information\t$cpuinfo_c of $cpuinfo_t\n";

$found_systeminfocheck=1;}
###system "echo 'System Info' >> $output ; uname -a >> $output; head -n1 /etc/issue >> $output; grep MemTotal /proc/meminfo >> $output; grep 'model name' /proc/cpuinfo >> $output";
##

if (/^MEMORY USAGE/) {@current_mem = $_;} 
if (/^TOTAL CPU TIME/) {@current_cpu = $_;}
if (/^WALLTIME/) {@current_wall = $_;}

if (/MEMORY USAGE \(import LEF\): /) { @step[$count_step]= 1;@memory[$count_step]=get_data();$flag1=1;}
elsif (/MEMORY USAGE \(import library\):/)  { @step[$count_step]= 2;@memory[$count_step]=get_data();$flag1=1;} 
elsif (/MEMORY USAGE \(import DEF\):/)  { @step[$count_step]= 3;@memory[$count_step]=get_data();$flag1=1;} 
elsif (/MEMORY USAGE \(setup DB\):/)  { @step[$count_step]= 4;@memory[$count_step]=get_data();$flag1=1;} 
elsif (/MEMORY USAGE \(import APL_FILES\):/)  { @step[$count_step]= 5;@memory[$count_step]=get_data();$flag1=1;} 
elsif (/MEMORY USAGE \(calculate power\):/)  { @step[$count_step]= 6;@memory[$count_step]=get_data();$flag1=1;} 
elsif (/MEMORY USAGE \(build connectivity\):/)  { @step[$count_step]= 7;@memory[$count_step]=get_data();$flag1=1;} 
elsif (/MEMORY USAGE \(Extracting RC\):/)  { @step[$count_step]= 8;@memory[$count_step]=get_data();$flag1=1;} 
elsif (/MEMORY USAGE \(Extracting RLC\):/)  { @step[$count_step]= 9;@memory[$count_step]=get_data();$flag1=1;} 
elsif (/MEMORY USAGE \(Extracting R\):/)  { @step[$count_step]= 16;@memory[$count_step]=get_data();$flag1=1;}
elsif (/MEMORY USAGE \(Static ESD Resistance Check\):/)  { @step[$count_step]= 17;@memory[$count_step]=get_data();$flag1=1;}
elsif (/MEMORY USAGE \(static analysis\): /)  { @step[$count_step]= 10;@memory[$count_step]=get_data();$flag1=1;} 
elsif (/\*\*\*\*   Finish Setting Up Dynamic Simulation/ & !$dup_flag) {
#print STDOUT "Finish Setting Up Dynamic Simulation\n @current_cpu\n @current_wall\n @current_mem\n";
@step[$count_step]= 11; 
#print @current_mem;
@memory[$count_step]=@current_mem;
@cputime[$count_step]=@current_cpu;
@walltime[$count_step]=@current_wall;
$flag1=0;$count_step++;
$dup_flag =1 ;
}
elsif (/Redhawk application is ended/) {
@step[$count_step]= 18;
#print @current_mem;
@memory[$count_step]=@current_mem;
@cputime[$count_step]=@current_cpu;
@walltime[$count_step]=@current_wall;
$flag1=0;$count_step++;
}
elsif (/\*\*\*\*   Finish ASIM Analysis/) {
@step[$count_step]= 19;
#print @current_mem;
@memory[$count_step]=@current_mem;
@cputime[$count_step]=@current_cpu;
@walltime[$count_step]=@current_wall;
$flag1=0;$count_step++;
}
elsif (/\*\*\*\*   Finish Importing Apache DB/) {
@step[$count_step]= 20;
#print @current_mem;
@memory[$count_step]=@current_mem;
@cputime[$count_step]=@current_cpu;
@walltime[$count_step]=@current_wall;
$flag1=0;$count_step++;
}
elsif (/\*\*\*\*   Finish RedHawk Dynamic Flow/) {
@step[$count_step]= 21;
#print @current_mem;
@memory[$count_step]=@current_mem;
@cputime[$count_step]=@current_cpu;
@walltime[$count_step]=@current_wall;
$flag1=0;$count_step++;
}
elsif (/MEMORY USAGE \(dynamic simulation\):/ | /MEMORY USAGE\(dynamicsimulation\):/ ) {@step[$count_step]= 12;@memory[$count_step]=get_data();$flag1=1;}
elsif (/MEMORY USAGE \(report dynamic simulation results\):/ | /MEMORY USAGE\(reportdynamicsimulationresults/ ) {@step[$count_step]= 13;@memory[$count_step]=get_data();$flag1=1;}
elsif (/MEMORY USAGE \(import ApacheDB\):/ | /MEMORY USAGE\(importApacheDB\):/) {@step[$count_step]= 14;@memory[$count_step]=get_data();$flag1=1;}
elsif (/Redhawk releases.*for dynamic asim!/) {
@step[$count_step]= 15;
@memory[$count_step]=@current_mem;
@cputime[$count_step]=@current_cpu;
@walltime[$count_step]=@current_wall;
$flag1=0;$count_step++;
}
elsif (/^TOTAL CPU TIME/ ) {
	if ($flag1) {@cputime[$count_step]=get_data();}
}
elsif (/^WALLTIME/) {
 	if ($flag1) {@walltime[$count_step]=get_data();$flag1=0;$count_step++;}
}
}

print_data ();

sub create_hash {
%table = ( 1, "Finish Importing LEFs", 2, "Finish Importing Library", 3, "Finish Importing DEFs", 4, "Finish Setting Up Database for Design Data",5,  "Finish importing APL_FILE",6, "Finish Calculating Power",7,"Finish Building Connectivity",8, "Finish Extracting RC",9, "Finish Extracting RLC",10, "Finish Static Analysis",11, "Finish Setting Up Dynamic Simulation",12,"Finish Dynamic Analysis",13,"Finish RedHawk Dynamic Flow",14,"Finish Importing Apache DB",15, "Redhawk releases memory for dynamic asim!",16,"Finish Extracting R",17,"Finish Static ESD Resistance Check",18,"Finish Exporting Apache DB",19,"Finish ASIM Analysis",20,"Finish Importing Apache DB",21,"Finish Reporting Dynamic Simulation Results" );
}
sub get_data {
#local $_;
my($i)=0;
my($h)=0;
my($m)=0;
my($s)=0;
my($size)=0;
my($count)=0;
for (@words=split) {$count++;}
#print "$count\n";
for ($i=0;$i <= $count;$i++) {

#print "$i,@words[$i]\n";
if (@words[$i]=~ /hrs/) {$h=@words[$i-1];}
if (@words[$i]=~ /mins/) {$m=@words[$i-1];}
if (@words[$i]=~ /secs/) {$s=@words[$i-1];}
if (@words[$i]=~ /MBytes/) {$size=@words[$i-1];}
}
#print "$_\n";
if (/MEMORY USAGE/) {return $size;print "$size\n";}
elsif  (/TOTAL CPU TIME|WALLTIME/) {return "$h:$m:$s";}
else {return 0;}
}

sub print_data { 
#print STDOUT "\n\n\n\n"; 
my($i)=0; my($count)=0; my(@temp_step)=@step; 
#print $count_step;
print OUTPUT "###RUNTIME/MEMORY\tCPU Total\tWall Total\tMEM(MB)\n";
HERE: for ($i=0;$i <= $count_step ; $i++) {
#HERE: for ($i=0;$i <= 13; $i++) {
if ( ($table{@temp_step[$i]} =~ /Importing DEFs/) && ($table{@temp_step[$i+1]} =~ /Importing DEFs/) ) {
#print "herewego $table{@temp_step[$i]}\n"; 
}
elsif ( @cputime[$i] =~ /TOTAL CPU TIME:/ ) { 
@cputime_temp= split(/\s+/,@cputime[$i]);
@walltime_temp = split(/\s+/,@walltime[$i]);
@memory_temp = split(/\s+/,@memory[$i]);
print OUTPUT "$table{@temp_step[$i]}\t@cputime_temp[3]:@cputime_temp[5]:@cputime_temp[7]\t@walltime_temp[1]:@walltime_temp[3]:@walltime_temp[5]\t@memory_temp[2]\n"; 
}
else {
print OUTPUT "$table{@temp_step[$i]}\t@cputime[$i]\t@walltime[$i]\t@memory[$i]\n";
      }
}

}
close LOG; 
close OUTPUT;


open ( LOGFILE_OPEN, "$logfile" )  || die "no log file found: $!\n";
open ( OUTPUT_FILE, ">>$output" ) || die "cannot open the output file : $!\n";
print OUTPUT_FILE "###ASIM PEAK MEMORY USAGE\n";
while (<LOGFILE_OPEN>) {
chomp;
print OUTPUT_FILE "$&\t$'\n" if ( /PEAK.*:/ );
}
close OUTPUT_FILE;
close LOGFILE_OPEN;



open( OUTPUT, ">>$output") || die "cannot create runtime file: $!\n";
if (-e $gsrfile ) {
print OUTPUT "\n###RUN SETUP FROM GSR\n" ;
while (<GSRFILE>) {
chomp;
unless (/^\s*#/ | /^\s*$/) {
if (/APACHE_FILES\s+debug/i) { $debug_check_debug_file_option = 1 ; }  
if ($tech_file_in_next_line ) { split; print OUTPUT "TECH_FILE\t $_[0]\n"; $tech_file_in_next_line = 0 }
if (/CACHE_MODE/) { split ; print OUTPUT "$_[0]\t$_[1]\n"; } #else { print OUTPUT "CACHE_MODE\tdefault off in 8.1\n";}
if (/CACHE_SIZE/) { split ; print OUTPUT "$_[0]\t$_[1]\n"; } #else { print OUTPUT "CACHE_SIZE\tdefault off in 8.1\n";}
if (/NX_SIM/) { split ; print OUTPUT "$_[0]\t$_[1]\n"; }  #else { print OUTPUT "NX_SIM\tdefault off in 8.1\n";}
if (/DYNAMIC_SIMULATIOIN_TIME/) { split ; print OUTPUT "$_[0]\t$_[1]\n"; 
if ( $_[1] > 10e-9 ) {print OUTPUT "--> WARN : >10ns, the simulation time seems to be too long, double check if we need that long sim time\n";}
}  #else { print OUTPUT "DYNAMIC_SIMULATIOIN_TIME\tdefault 1 over freq\n";}
if (/DYNAMIC_TIME_STEP/) { split ; print OUTPUT "$_[0]\t$_[1]\n";
if ( $_[1] > 30e-12 ) { print OUTPUT "--> WARN : >30ps, the time step is too big for sign-off\n"; }
if ( $_[1] <= 30e-12 ) { print OUTPUT "--> WARN : <=30ps, the time step is too small \(for AE to do INTERNAL DEBUG\)\n"; }
} #else { print OUTPUT "DYNAMIC_TIME_STEP\tdefault 10ps\n";}
if (/DYNAMIC_PRESIM_TIME|DYNAMIC_BYPASS_TIME/) { split ; print OUTPUT "$_[0]\t$_[1]\t$_[2]\t$_[3]\n"; 
if ( $_[1] > 20e-9 ) {print OUTPUT "--> WARN : >20ns, the presim time seems to be too long, double check if we need that long presim\n"; }
} #else { print OUTPUT "DYNAMIC_PRESIM_TIME\tdefault -1\n";}

if (/MEMORY_SAVING_MODE/) { split ; print OUTPUT "$_[0]\t$_[1]\n"; } #else { print OUTPUT "MEMORY_SAVING_MODE\tdeaful on\n";}
if (/FREQ/) {split ; print OUTPUT "$_[0]\t$_[1]\n"; }
if ( ( /MULTI_THREADS/ | /TECH_FILE/ | /HIGH_CAPACITY/ | /NETWORK_REDUCTION_MODE/ | /HC_REDUCE_FRACTION/ | /MPR_MODE/ | /VCD_PREPARE_SCENARIO/ | /EASY_STD_RAIL_VIAS/ | /EASY_STD_CONN/ )  & !/TECH_FILE\s+\{/ ) {split ; print OUTPUT "$_[0]\t$_[1]\n"; }
if ( /TECH_FILE\s+\{/ ) { $tech_file_in_next_line = 1; } 
if (/^\s*\}/ & $gds_cells_keyword_found) { 
print OUTPUT "GDS_CELLS\t$count_gds_cells\tcells\n";
$gds_cells_keyword_found =0 ;
}
$count_gds_cells++ if ( $gds_cells_keyword_found ) ;
if (/GDS_CELLS/) { $gds_cells_keyword_found_check = 1; $gds_cells_keyword_found = 1; $length_gds_cells_line = split ; $count_gds_cells++ if ($length_gds_cells_line > 3 ); } 
}
}
print OUTPUT "GDS_CELLS\t0\tcells\n" unless ($gds_cells_keyword_found_check);
}
close OUTPUT;
close GSRFILE;


open( OUTPUT, ">>$output") || die "cannot create runtime file: $!\n";

if (-e $debugdynamicfile) {
print OUTPUT "\n###FROM .apache/.debug.dynamic file\n";
while (<DEBUGDYNAMIC>) {
chomp;
#if (/Begin DC analysis of /) { split ; print OUTPUT "Node Count\t$_[4]\n"; };
if (/nodes in the circuit/) { split ; print OUTPUT "Node Count\t$_[3]\n"; $debug_dynamic_node_lw = $_[3]/1000000; $debug_dynamic_node_lw = sprintf("%.3f", $debug_dynamic_node_lw);};
if (/resistors in the circuit/) { split ; print OUTPUT "Resistor Count\t$_[3]\n"; $debug_dynamic_r_lw = $_[3]/1000000; $debug_dynamic_r_lw = sprintf("%.3f", $debug_dynamic_r_lw);};
if (/capacitors in the circuit/) { split ; print OUTPUT "Capacitor Count\t$_[3]\n" ;};
if (/inductors in the circuit/) { split ; print OUTPUT "Inductor Count\t$_[3]\n" ;};
if (/^Cnd\s+/) { split ; $_[2] =~ s/,//; print OUTPUT "Cnd\t$_[2]\n";};
}
}
if (-e ".apache/.debug.static" ) {
close DEBUGDYNAMIC;
print OUTPUT "\n###FROM .apache/.debug.static and adsRpt/redhawk.log file\n";
while (<DEBUGSTATIC>) {
chomp; 
if (/asim/) { split ; print OUTPUT "Initial Node Count\t$_[1]\n"; };
}
}
close DEBUGSTATIC;
open ( LOGFILE_OPEN, "$logfile" )  || die "no log file found: $!\n";
while (<LOGFILE_OPEN> ) {
chomp; 
if ( /SIM-S01I/ ) {split;print OUTPUT "Final Node Count\t$_[5]\nFinal Resistror Count $_[8]\n"; } 
}
close LOGFILE_OPEN;
close OUTPUT;
my($dotstat_node) = 0 ;
open( OUTPUT, ">>$output") || die "cannot create runtime file: $!\n";
#if ( -f "$dotstatfile") {
print OUTPUT "\n###FROM $dotstatfile\n";
while (<DOTSTAT>) {
chomp;
split;
#print OUTPUT "\t$_[]\n" if (//);
$dotstat_node = $_[2] if (/Node      :/);
#print OUTPUT "Node count\t$_[2]\n" if (/Node      :/);
$dotstat_r = $_[2] if (/Resistor  :/);
#print OUTPUT "Resistor count\t$_[2]\n" if (/Resistor  :/);
$dotstat_i = $_[3] if (/Leaf Inst :/);
#print OUTPUT "Leaf inst\t$_[3]\n" if (/Leaf Inst :/);
#if (//){
#$_[3]=~ s/M/000000/;
#print OUTPUT "\t$_[3]\n";
#}
if (/Cached out memory:/){
$_[3]=~ s/M/000000/;
$dotstat_cm = $_[3] ;
#print OUTPUT "Cached out memory\t$_[3]\n"; 
}
if (/Allocated cachable memory:/){
$_[3]=~ s/M/000000/;
$dotstat_acm = $_[3] ;
#print OUTPUT "Allocated cachable memory\t$_[3]\n";
}
if (/Total Memory \(cached\+used\):/){
$_[3]=~ s/M/000000/;
$dotstat_tm = $_[3] ;
#print OUTPUT "Total Memory (cached+used)\t$_[3]\n";
}
}
print OUTPUT "Node count\t$dotstat_node\n" ;
print OUTPUT "Resistor count\t$dotstat_r\n" ;
if ( $dotstat_node != 0) {
$rn_ratio_dotstat = $dotstat_r / $dotstat_node;
$rn_ratio_dotstat = sprintf("%.3f", $rn_ratio_dotstat);
print OUTPUT "Resistor/Node ratio\t$rn_ratio_dotstat\n" ;
}
print OUTPUT "Leaf inst\t$dotstat_i\n" ;
print OUTPUT "Cached out memory\t$dotstat_cm\n";
print OUTPUT "Allocated cachable memory\t$dotstat_acm\n";
print OUTPUT "Total Memory (cached+used)\t$dotstat_tm\n";
#}
close OUTPUT;
close DOTSTAT;

#added by Ruizhen Guo on 10/22/2013 
#copy and paste some lines from .apache/.nodestatistic

open( OUTPUT, ">>$output") || die "cannot create runtime file: $!\n";
if (-e $dotnodestatistic ) {
	my $node_f = 0;
	print OUTPUT "\n###FROM $dotnodestatistic\n";
	while (my $line = <DOTNODE>) {
		if ($node_f == 0) {
			print OUTPUT $line;
		}
		else {
			last;
		}

		if ($line =~ /Avg Number of Nodes per Sqmm/) {
			$node_f = 1;
		}
	}
}
close DOTNODE;
close OUTPUT;

#end 
		

open( OUTPUT, ">>$output") || die "cannot create runtime file: $!\n";

if (-e $dotnxfile ) {
print OUTPUT "\n###DISK SPACE USAGE FROM .apache/.nx\n";
while (<DOTNX>){
chomp;
unless (/^#/) {
if (/\.apache/ && /MBytes/) {split ; $apacheDirSize = $_[1] if ($apacheDirSize <= $_[1]); }
if (/\MM_/ && /MBytes/) {split; $mmDirSize =  $_[1] if ($mmDirSize <= $_[1]); $mmDirName = $_[0] if ($mmDirSize <= $_[1]); }

}
}
$apacheDirSize = $apacheDirSize / 1024;
$mmDirSize = $mmDirSize / 1024;
$mmDirSize = sprintf("%.3f", $mmDirSize);
printf OUTPUT ".apache\t%5.0f\n",$apacheDirSize;
printf OUTPUT "$mmDirName\t%5.0f\n",$mmDirSize;
}
close DOTNX;
close OUTPUT; 
open( OUTPUT, ">>$output") || die "cannot create runtime file: $!\n";

print OUTPUT "\n###CURRENT DISK SPACE USAGE FROM du -h --max-depth=1\n";
#Modified by Ruizhen on 9/18/2013
if (-e "./adsRpt") { 
	$adsrpt_size = `\du -h --max-depth=0 adsRpt`;
	if ($adsrpt_size =~ /(\S+)G\s+adsRpt/) {
		$total_size += $1 ;
		$adsrpt_size_lw = $1;
	}
	elsif ($adsrpt_size =~ /(\S+)M\s+adsRpt/) {
		$total_size += $1/1024 ;
		 $adsrpt_size_lw = $1/1024;
	}
	else {
		$adsrpt_size_lw = 0;
	}
	$adsrpt_size_lw = sprintf("%.3f", $adsrpt_size_lw);
} 
else {
	$adsrpt_size = "adsRpt_is_missing\n";
	$adsrpt_size_lw = "adsRpt is missing";
}
if (-e "./adsPower") {
	$adspower_size = `\du -h --max-depth=0 adsPower`;
	if ($adspower_size =~ /(\S+)G\s+adsPower/) {
		$total_size += $1 ;
		$adspower_size_lw = $1;
	}
	elsif ($adspower_size =~ /(\S+)M\s+adsPower/) {
		$total_size += $1/1024 ;
		$adspower_size_lw = $1/1024;
	}
	else {
		$adspower_size_lw = 0;
	}
	$adspower_size_lw = sprintf("%.3f", $adspower_size_lw);
}
else {
	$adspower_size = "adsPower_is_missing\n";
	$adspower_size_lw = "adsPower is missing";
}
if (-e "./.apache") {
	$dotapache_size = `\du -h --max-depth=0 .apache`;
	if ($dotapache_size =~ /(\S+)G\s+\.apache/) {
		$total_size += $1 ;
		$dotapache_size_lw = $1;
	}
	elsif ($dotapache_size =~ /(\S+)M\s+\.apache/) {
		$total_size += $1/1024 ;
		$dotapache_size_lw = $1/1024;
	}
	else {
		$dotapache_size_lw = 0;
	}
	$dotapache_size_lw = sprintf("%.3f", $dotapache_size_lw);
}
else {
	$dotapache_size = ".apache_is_missing\n";
	$dotapache_size_lw = ".apache is missing";
}

open ( TEMPOUTPUT, ">ftftp857" ) || die "cannot create temp file: $!\n";
print TEMPOUTPUT "adsRpt\t$adsrpt_size";
print TEMPOUTPUT "adsPower\t$adspower_size";
print TEMPOUTPUT ".apache\t$dotapache_size";
close TEMPOUTPUT;
open ( TEMPOUTPUTR, "ftftp857" ) || die "cannot read temp file: $!\n"; 
while (<TEMPOUTPUTR> ) {
chomp;
split;
print OUTPUT "$_[0]\t$_[1]\n";
}
system('\rm ftftp857');
close OUTPUT;
#system("\du -h --max-depth=1 >> $output");
close DEBUGDYNAMIC;



open( LOG, "$logfile") || warn "$logfile does not exist : $!\n";
open( OUTPUT, ">>$output") || die "cannot create runtime file: $!\n";
#print OUTPUT "\n";
while (<LOG>) {
if ( /^Total chip power,/ ) {
print OUTPUT "
###POWER REPORT in watts
"; split ; print OUTPUT "Total chip power\t$_[3]\n";}
if ( /^Total clock network only power/ ) { split ; print OUTPUT "Total clock network only power\t$_[5]\nTotal clock power including clock network and FF/latch clock pin power\t$_[18]\n\n";}

if ( /^Worst Dynamic Voltage Drop/ ) {
print OUTPUT "
###WORST DYNAMIC VOLTAGE DROP
Type\tvalue\tnet\tideal_volt\tlocation\tname
"; $worst_dynamic_voltage_drop_is_on =1; $last_line_count_dynamic = $. + 10 ;}

if ( /^Worst Static IR Drop/ ) {
print OUTPUT "
###WORST STATIC VOLTAGE DROP
Type\tvalue\tnet\tideal_volt\tlocation\tname
"; $worst_static_voltage_drop_is_on= 1; $last_line_count_static= $. + 8 ;}
#print OUTPUT "$_" if (/PEAK/);

if ( /^Worst Static EM violation/) {
print OUTPUT "
###WORST STATIC EM VIOLATION
Type\tvalue\tnet\tEM_limit\tlocation\tname
"; $worst_static_em_is_on = 1; $last_line_count_em = $. + 5 ;}

if (/^WIRE / & ($worst_dynamic_voltage_drop_is_on == 1) & ($.<$last_line_count_dynamic)) {chomp; s=\s+=\t=g;print OUTPUT "$_\n"; }
if (/^avgTW/ & ($worst_dynamic_voltage_drop_is_on == 1) & ($.<$last_line_count_dynamic)) {chomp; s=\s+=\t=g;print OUTPUT "$_\n"; };
if (/^maxTW/ & ($worst_dynamic_voltage_drop_is_on == 1) & ($.<$last_line_count_dynamic)) {chomp; s=\s+=\t=g;print OUTPUT "$_\n"; };
if (/^minTW/ & ($worst_dynamic_voltage_drop_is_on == 1) & ($.<$last_line_count_dynamic)) {chomp; s=\s+=\t=g;print OUTPUT "$_\n"; };
if (/^minWC/ & ($worst_dynamic_voltage_drop_is_on == 1) & ($.<$last_line_count_dynamic)) {chomp; s=\s+=\t=g;print OUTPUT "$_\n"; };
if (/^WIRE / & ($worst_static_voltage_drop_is_on== 1) & ($.<$last_line_count_static)) {chomp; s=\s+=\t=g;print OUTPUT "$_\n"; }
if (/^INST / & ($worst_static_voltage_drop_is_on== 1) & ($.<$last_line_count_static)) {chomp; s=\s+=\t=g;print OUTPUT "$_\n"; }
if (/^WIRE / & ($worst_static_em_is_on== 1) & ($.<$last_line_count_em)) {chomp; s=\s+=\t=g;print OUTPUT "$_\n"; }

}

close OUTPUT;
close LOG;

open( OUTPUT, ">>$output") || die "cannot create runtime file: $!\n";
if (-e $dotrunsettingfile ) {
print OUTPUT "\n####License Check-Out/In History from .run.setting\n";
while (<DOTRUNSET>) {
chomp;
if ( /^chkin/ ) { split; $chkin{$_[1]} = "chkin"; }
if ( /^chkout/ ) { split; $chkout{$_[1]} = "chkout"; }
}
foreach $chkin_list ( keys %chkin ) { print OUTPUT "chkin $chkin_list\n"; }
foreach $chkout_list ( keys %chkout ) { print OUTPUT "chkout $chkout_list\n"; }
}
print OUTPUT "\n";
close OUTPUT;
close DOTRUNSET;

open( OUTPUT, ">>$output") || die "cannot create runtime file: $!\n";

my($cur_dir)=`pwd`;
my($now)=`date  +%Y_%m_%d_%a_%H_%M`;
chomp($cur_dir); chomp($now);
#print "$now\n";
@dir=split(/\//,$cur_dir);
$dirlength = @dir ;
#print "$dirlength\n";
#print "$dir[$dirlength-1]";

@joined_list= ("$dir[$dirlength-1]","$now");
$joined_dir= join('_',@joined_list);
#print "$joined_dir\n";
if ($save_mode) {
print OUTPUT "###files for debug saved at\n";
print OUTPUT "../$joined_dir : compact\n" if ($save_mode == 1 );
print OUTPUT "../$joined_dir : detailed \n" if ($save_mode == 2 );
}

print OUTPUT '
############################################# GUIDELINE FOR RUNNING LARGE DESIGN IN RH ##############################################

---------------------------------      -----------------------------------
|   Simplifying the Design      | ==>> | review GSR settings in parallel |  ==>> e.g. > Time-step 20-30ps 
|   Black-box memories          |      -----------------------------------            > Simulation time 3-4 cycles 
---------------------------------                                                     > pre-sim time 20~30ns(pre-sim DC!) 
           |   |                                                                      > PSF ~ 3 with 0.9 
           |   |
        ---     ---
	  \     /
	    \ /
---------------------------------   > WALL vs CPM (cache impact) 
|      Run and clean "static"   |           ~remote disk impact(CACHE_DIR)
|         Review RHE-pc         |   > Check stage by stage run-time
---------------------------------   > Should be within hrs at most                        --------------------------------
           |   |                                                                          |     Run with recommended     | 
           |   |                                                                          |     settings ( as above )    |
        ---     ---                                                                       --------------------------------
	  \     /                                                                                       /   \
	    \ /                                                                                       /       \
---------------------------------                                                                    ---|   |---  
|       Check time-steps        |   > WALL vs CPU (cache impact)                                        |   |
|  > simulation time ~ 1 cycle  |   > Profile stage by stage runtime                                    |   |
|  > timg-step ~ 100ps          |   > Review node count distribution                                    |   |
|  > zero pre-simulation        |             > Memory LEF pin                                          |   |
|    Use lumped pacage model    |             > Standard cell LEF/via                                   |   |
---------------------------------                                                                       |   |
           |   |                                                                                        |   |
           |   |                                                                                        |   |
        ---     ---                                                                                     |   |
	  \     /                                                                                       |   |
	    \ /                                                                                         |   |
-----------------------------------------------------\    > Try bigger m/c(CACHE_SIZE)                  |   |
|     Run and clean "BB DvD"    |   "Swpping"         \   > If>128MB needed, check with RD/PE           |   |
|         Review RHE-PC         |   "Out of memory"   /   > Use MPR/SIR based on RD suggestion          |   |
-----------------------------------------------------/                                                  |   |
           |   |                                                                                        |   |
           |   |                                                                                        |   |
        ---     ---                                                                                     |   |
	  \     /                                                                                       |   |
	    \ /                                                                                         |   |
---------------------------------                                                                       |   |
|                               |   > Memory block node profile : ESL/CESL(must be m3/m3 or above)      |   |
|    Introduce memory models    |   > TM CMM views used or not (use CELL_VIEW only ~ m3/m3+)            |   | 
|                               |   > Profile stage by stage run-time and peak memory (RH + asim)       |   |
---------------------------------                                                                       |   |
           |   |                                                                                        |   |
           |   |                                                                                        |   |
        ---     ---                                                                                     |   | 
	  \     /                                                                                       |   |
	    \ /                                                                                         |   |
-----------------------------------------------------\    > Try bigger m/c(CACHE_SIZE)                  |   |
|    Run and clean "WB DvD"     |   "Swapping"        \   > If>128GB needed, check with RD/PE           |   |
|        Review RHE-PC          |   "Out of memory"   /   > Use MPR/SIR based on RD suggestion          |   |
-----------------------------------------------------/                                                  |   |
           |   |                                                                                        |   |
           |   |                                                                                        |   |
           |   |----------------------------------------------------------------------------------------|   |
	   |                                                                                                | 
	   |------------------------------------------------------------------------------------------------|

############################################# GUIDELINE FOR RUNNING LARGE DESIGN IN RH ##############################################

';
close OUTPUT;

open ( OUTPUT_RT, ">runtime.log") || die "cannot create file runtime file: $!\n";
open ( OUTPUT, "$output") || warn "$output does not exist : $!\n"; 
while (<OUTPUT>) {
chomp;
if  ( /^Finish / ) {
$don_like_asim_time_flag = 1 if (/Finish ASIM Analysis/);
split;
$lll = @_;
#print "length = $lll\n";
#close OUTPUT if (/^\s*$/); 
$cur_time = $_[$lll-2];
$cur_time2 = $_[$lll-3];
@cur_sec = split(":",$cur_time);
@cur_sec2 = split(":",$cur_time2);
$cur_seconds = 3600 * $cur_sec[0] + 60* $cur_sec[1] + $cur_sec[2];
$cur_seconds2 = 3600 * $cur_sec2[0] + 60 * $cur_sec2[1] + $cur_sec2[2];
if ($don_like_asim_time_flag) { 
$cur_seconds = $cur_seconds + $pre_seconds;
$cur_seconds2 = $cur_seconds2 + $pre_seconds2;
$don_like_asim_time_flag = 0;
}
#print "@cur_sec2 $cur_seconds2 @cur_sec $cur_seconds\n";
$hhh=int($cur_seconds/3600);
$mmm=int(($cur_seconds%3600)/60);
$sss=int($cur_seconds%60);
$hhh2=int($cur_seconds2/3600);
$mmm2=int(($cur_seconds2%3600)/60);
$sss2=int($cur_seconds2%60);
#print "$hhh2:$mmm2:$sss2 $hhh:$mmm:$sss\n";
switch ($lll) {
case 4 { print OUTPUT_RT "$_[0]\t$hhh2:$mmm2:$sss2\t$hhh:$mmm:$sss\t$_[$lll-1]\n";}
case 5 { print OUTPUT_RT "$_[0] $_[1]\t$hhh2:$mmm2:$sss2\t$hhh:$mmm:$sss\t$_[$lll-1]\n";}
case 6 { print OUTPUT_RT "$_[0] $_[1] $_[2]\t$hhh2:$mmm2:$sss2\t$hhh:$mmm:$sss\t$_[$lll-1]\n";}
case 7 { print OUTPUT_RT "$_[0] $_[1] $_[2] $_[3]\t$hhh2:$mmm2:$sss2\t$hhh:$mmm:$sss\t$_[$lll-1]\n";}
case 8 { print OUTPUT_RT "$_[0] $_[1] $_[2] $_[3] $_[4]\t$hhh2:$mmm2:$sss2\t$hhh:$mmm:$sss\t$_[$lll-1]\n";}
case 9 { print OUTPUT_RT "$_[0] $_[1] $_[2] $_[3] $_[4] $_[5]\t$hhh2:$mmm2:$sss2\t$hhh:$mmm:$sss\t$_[$lll-1]\n";}
case 10 { print OUTPUT_RT "$_[0] $_[1] $_[2] $_[3] $_[4] $_[5] $_[6]\t$hhh2:$mmm2:$sss2\t$hhh:$mmm:$sss\t$_[$lll-1]\n";}
else { print OUTPUT_RT "$_[0] $_[1] $_[2] $_[3] $_[4] $_[5] $_[6]\t$hhh2:$mmm2:$sss2\t$hhh:$mmm:$sss\t$_[$lll-1]\n";}
}
$pre_seconds = $cur_seconds;
$pre_seconds2 = $cur_seconds2;
}
elsif (!/Redhawk releases memory for dynamic asim!/) {
print OUTPUT_RT "$_\n";
}
}

system('\rm get_runstat.out');
system('\mv runtime.log get_runstat.out');

#saving files 
if ($save_mode ) {
system("
mkdir ../$joined_dir 
mkdir ../$joined_dir/.apache
mkdir ../$joined_dir/adsRpt
mkdir ../$joined_dir/adsRpt/Log
mkdir ../$joined_dir/adsRpt/Cmd
mkdir ../$joined_dir/adsRpt/Error
mkdir ../$joined_dir/adsRpt/Warn
mkdir ../$joined_dir/adsRpt/Dynamic
mkdir ../$joined_dir/adsRpt/Static
cp -prf adsRpt/apache.trace ../$joined_dir/adsRpt/.
#cp -prf adsRpt/*.power.rpt ../$joined_dir/adsRpt/.
cp -prf adsRpt/apache.CMM.rpt ../$joined_dir/adsRpt/.
cp -prf adsRpt/*unconnect ../$joined_dir/adsRpt/.
cp -prf adsRpt/redhawk.* ../$joined_dir/adsRpt/.
cp -prf adsRpt/totem.* ../$joined_dir/adsRpt/.
cp -prf adsRpt/Log ../$joined_dir/adsRpt/.
cp -prf adsRpt/Error ../$joined_dir/adsRpt/.
cp -prf adsRpt/Warn ../$joined_dir/adsRpt/.
cp -prf adsRpt/Cmd ../$joined_dir/adsRpt/.
#cp -prf adsRpt/Dynamic/*.dvd ../$joined_dir/adsRpt/Dynamic/.
cp -prf adsRpt/Dynamic/*.i* ../$joined_dir/adsRpt/Dynamic/.
cp -prf adsRpt/Dynamic/i* ../$joined_dir/adsRpt/Dynamic/.
cp -prf adsRpt/Static/*.em.worst ../$joined_dir/adsRpt/Static/.
cp -prf adsRpt/Static/switch*.rpt ../$joined_dir/adsRpt/Static/.
cp -prf adsRpt/Dynamic/switch*.rpt ../$joined_dir/adsRpt/Dynamic/. 
cp -prf .apache/.debug.* ../$joined_dir/.apache/.
cp -prf .apache/.nx.log ../$joined_dir/.apache/.
cp -prf .apache/.run.setting ../$joined_dir/.apache/.
cp -prf .run.setting ../$joined_dir/.apache/.
cp -prf .apache/.*statistic* ../$joined_dir/.apache/.
cp -prf .apache/*gsr ../$joined_dir/.apache/.
#cp -prf .apache/apache.nloc  ../$joined_dir/.apache/.
cp -prf .ir* ../$joined_dir/.
cp -prf pwr* ../$joined_dir/.
cp -p *.tcl ../$joined_dir/.
cp -p *.jpg ../$joined_dir/.
cp -p *.cmd ../$joined_dir/.
cp -p  *gsr ../$joined_dir/.
cp -p *.out ../$joined_dir/.
cp -p *.pl ../$joined_dir/.
cp -prf adsRpt/CPM ../$joined_dir/adsRpt/.
cp -p *.sp ../$joined_dir/.
cp -p *.sp.inc ../$joined_dir/.
cp -prf adsRpt/CPM ../$joined_dir/adsRpt/.
cp -prf adsRHE ../$joined_dir/.
cp -p rhe* ../$joined_dir/.
cp -prf *.rpt ../$joined_dir/.
cp -prf *gridcheck* ../$joined_dir/.
cp -prf adsRpt/*gridcheck* ../$joined_dir/adsRpt/.
");
system("
mkdir ../$joined_dir/adsPower
cp -prf adsPower/*power ../$joined_dir/adsPower/.
cp -prf adsRpt/Dynamic/* ../$joined_dir/adsRpt/Dynamic/.
cp -prf adsRpt/Static/* ../$joined_dir/adsRpt/Static/.
cp -prf adsRpt/*power.rpt ../$joined_dir/adsRpt/.
cp -prf .apache/apache.nloc  ../$joined_dir/.apache/.
cp -prf  .apache/apache.mpr  ../$joined_dir/.apache/.
cp -prf .apache/.asim.* ../$joined_dir/.apache/.
cp -prf .apache/*state.out ../$joined_dir/.apache/.
cp -prf .apache/apache.scenario ../$joined_dir/.apache/.
cp -prf .apache/apache.pwr ../$joined_dir/.apache/.
cp -prf .apache/*nets ../$joined_dir/.apache/.
cp -prf .apache/apache.tr ../$joined_dir/.apache/.
cp -prf .apache/mcyc_inst.out ../$joined_dir/.apache/.
cp -prf .apache/apache.imap ../$joined_dir/.apache/.
cp -prf .apache/apache.statemap ./$joined_dir/.apache/. 
cp -prf .apache/apache.pad ./$joined_dir/.apache/.
") if ($save_mode == 2);
} #printing the information of steps to go thru for large design debugging


#added by Ruizhen Guo on 10/22/2013
my $lw = 1; 

#added by Ruizhen Guo on 9/17/2013
if ($lw == 1) {
	open OUT, '>', "get_runstat_short.out" or die;
	print OUT "##Version\tSetup\tDesign Name\tPACKAGE\tInstance Count\t.static (M)\t.debug.dynamic (M)\tR/N\tTime Steps (ps)\tPRESIM TIME (ns)\tSIM TIME (ns)\tSetup Design (mins)\tAPL Processing (mins)\tPwrCalc (mins)\tExtraction (mins)\tSimulation (ASIM) (mins)\tPost processing (mins)\tTotal time (hrs)\tFactor\tExport DB (mins)\tSetup Design (GB)\tPwrCalc (GB)\tExtraction (GB)\tSimulation (ASIM) (GB)\tPost processing (GB)\tExport DB (GB)\tadsRpt (GB)\t.MM (GB)\t.apache (GB)\tadsPower (GB)\tTotal (GB)\n";
	
	my $dotstat_node_lw = $dotstat_node/1000000;
	$dotstat_node_lw = sprintf("%.3f", $dotstat_node_lw);
	my $dotstat_r_lw = $dotstat_r/1000000;
	$dotstat_r_lw = sprintf("%.3f", $dotstat_r_lw);

	sub get_time_memory {
		if ($_[0] =~ /$_[1]\S*\s+\S+\s+(\d+):(\d+):\d+\s+(\S+)/) {
			$time = $1 * 60 + $2;
			$mem = $3/1000;
			#print "$time\n";
			return ($time, $mem, 1);
			
		} 
		else {
			return ("missing", "missing", 0);
		}
	}
		

#	open IN, '<', "get_runstat.out" or die;
	my @setup_design = ("setup design missing", "setup design missing", 0);
	#my $setup_design_m = "setup design missing";
	my @apl_import = ("APL importing missing", "APL importing missing", 0);
	#my $apl_import_m = "APL importing missing";
	my @power_calc = ("power Calc  missing", "power Calc missing", 0);
	my @extraction = ("extraction missing", "extraction missing", 0);
	my @asim = ("asim missing", "asim missing", 0);
	my @post_process = ("post process missing", "post process missing", 0);
	my @import_db = ("importing db missing", "importing db missing", 0);
	

	
	my @temp = ("missing", "missing", 0);
	my $mem_buf;
	my $walltime_buf;
	my $sim_t = "sim is missing";
	my $sim_m = "sim is missing";
	my $sim_f = 0;

	my $post_t = "post processing is missing";

	my $db_t = "N/A";
	my $db_m = "N/A";

	my $design_name_lw = "N/A";

	my $static_f = 0;
	my $dynamic_f = 0;

	open IN, '<', "get_runstat.out" or die;
	while (my $line = <IN>) {
	#	if ($line =~ /Finish Setting Up Database for Design Data\s+\S+\s+(\S+)\s+(\S+)/) {
	#		$setup_design_t = $1;
	#		$setup_design_m = $2;
	#	}
	#	elsif ($line =~ /Finish importing APL_FILE\s+\S+\s+(\S+)\s+(\S+)/) {
	#		$apl_import_t = $1;
	#		$apl_import_m = $1;
	#	}
	#	elsif
		@temp = get_time_memory($line, "Finish Setting Up Database for Design Data");
		if ($temp[2] == 1) { @setup_design = ($temp[0], $temp[1], 1); }
		
		@temp = get_time_memory($line, "Finish importing APL_FILE");
		if ($temp[2] == 1) { @apl_import = ($temp[0], $temp[1], 1); }

		@temp = get_time_memory($line, "Finish Calculating Power");
		if ($temp[2] == 1) { @power_calc = ($temp[0], $temp[1], 1); }

		@temp = get_time_memory($line, "Finish Extracting R");
		if ($temp[2] == 1) { @extraction = ($temp[0], $temp[1], 1); }

		@temp = get_time_memory($line, "Finish ASIM Analysis");
		if ($temp[2] == 1) { @asim = ($temp[0], $temp[1], 1); }
	
		@temp = get_time_memory($line, "Finish Dynamic Analysis");
		if ($temp[2] == 1) { @post_process = ($temp[0], $temp[1], 1); $dynamic_f = 1; }
		else {
			@temp = get_time_memory($line, "Finish Static Analysis");
			if ($temp[2] == 1) { @post_process = ($temp[0], $temp[1]); $static_f = 1;}
		}
		
		@temp = get_time_memory($line, "Finish Importing Apache DB");
		if ($temp[2] == 1) { @import_db = ($temp[0], $temp[1]); }
		
	
	}
	close IN;
	my $apl_t = $apl_import[0]-$setup_design[0];
	my $power_calc_t = $power_calc[0]-$apl_import[0];
#	print "&&&&$extraction[0]&&&&&&$power_calc[0]\n";
	my $extract_t = $extraction[0]-$power_calc[0];
#	$sim_t = $sim_t - $extraction[0];
#	my $post_t = $post_process[0] - $sim_t;
#	my $asim_t;
#	my $post_t; 
#	if ($asim[2] == 0) {
#		$asim_t = $asim[0];
#		$asim_m = $asim_[1];
#		$post_t = $post_process[0] - $extraction[0];
#	}
#	close IN;

	my $presim_log = "Not found in log file";

	open IN, '<', "./adsRpt/redhawk.log" or die "redhawk.log is not exist!";
	while ($line = <IN>) {
		if ($line =~ /PEAK MEMORY USAGE:\s+(\d+)\s+/) {
			$mem_buf = $1;
		}
		if ($line =~ /WALLTIME:\s+(\d+)\s+hrs\s+(\d+)\s+mins/) {
			$walltime_buf = $1*60 + $2;
		}
		if ($line =~ /Collecting post-simulation results/ && $sim_f == 0) {
			$sim_m = $mem_buf/1000;
			$sim_t = $walltime_buf;
			$sim_f = 1;
#			print "!!!!!$mem_buf!!!!!$walltime_buf\n";
		}
		if ($line =~ /Finish Exporting Apache DB/) {
			$db_t = $walltime_buf;
			$db_m = $mem_buf/1000;
		}
		if ($line =~ /Presim is determined to be\s+(\S+)\s+/ ) {
			$presim_log = $1;
		}
		if ($line =~ /Reading\s+\S+\s+for top_design <(\S+)>/) {
			$design_name_lw = $1;
		}
	}
	$post_t = $post_process[0] - $sim_t;
	$sim_t = $sim_t - $extraction[0];
#	$post_t = $post_process[0] - $sim_t;
	close IN;

	my $package_f = "NO";
	my $fg;

#	if ($dynamic_f == 1) {
	my $step_time;
	my $presim_time;
	my $sim_time;

	if ($dynamic_f == 1) {
	open IN, '<', $gsrfile or die "gsr file is not specified\n";
	my $step_f = 0;
	my $presim_f = 0;
	my $sim_f = 0;
	my $sq;
#	my $fq;
	while ($line = <IN>) {
		if ($line =~ /^DYNAMIC_TIME_STEP\s+(\S+)e-(\d+)/) {
			$sq = 12 - $2;
			$step_time = $1 * (10**$sq);
			$step_f = 1;
		}
		if ($line =~ /^DYNAMIC_PRESIM_TIME\s+(\S+)e-(\d+)/) {
			$sq = 9 - $2;
			$presim_time = $1 * (10**$sq);
			$presim_f = 1;
		}
		if ($line =~ /^DYNAMIC_SIMULATION_TIME\s+(\S+)e-(\d+)/ || $line =~ /^DYNAMIC_SIMULATION_TIME\s+\S+\s+(\S+)e-(\d+)/) {
			$sq = 9 - $2;
			$sim_time = $1 * (10**$sq);
			$sim_f = 1;
		}
		if ($line =~ /^FREQUENCY\s+(\S+)e(\d+)/ || $line =~ /^FREQ\s+(\S+)e(\d+)/) {
			if ($2 > 9) {
				$fg = $1*(10**($2 - 9));
			}
			else {
				$fg = $1/(10**(9 - $2));
			}
		}
		if ($line =~ /^FREQ\s+(\d+)/ || $line =~ /^FREQENCY\s+(\d+)/) {
			$fg = $1/1000000000;
		}
		if ($line =~ /^PACKAGE_SPICE_SUBCKT/) {
			$package_f = "YES";
		}
	}
	close IN;
#	print "SF $step_f\n";
	if ($step_f == 0) {
		$step_time = 10;
	}
	if ($presim_f == 0) {
		$presim_time = $presim_log/1000;
	}
	if ($sim_f == 0) {
		$sim_time = 1/$fg;
		$sim_time = sprintf("%.3f", $sim_time);
	}

	}# end of dynamic flag
	else {
		$step_time = "N/A";
		$presim_time = "N/A";
		$sim_time = "N/A";
	}
	
	
	$total_size += $mmDirSize;
	$total_size = sprintf("%.3f", $total_size);

	print OUT "$version_lw\tSetup_missing\t$design_name_lw\t$package_f\t$dotstat_i\t$dotstat_node_lw\t$debug_dynamic_node_lw\t$dotstat_r_lw\t$debug_dynamic_r_lw\t$rn_ratio_dotstat\t$step_time\t$presim_time\t$sim_time\t$setup_design[0]\t$apl_t\t$power_calc_t\t$extract_t\t$sim_t\t$post_t\t$post_process[0]\t$setup_design[1]\t$apl_import[1]\t$power_calc[1]\t$extraction[1]\t$sim_m\t$post_process[1]\t$db_m\t$adsrpt_size_lw\t$mmDirSize\t$dotapache_size_lw\t$adspower_size_lw\t$total_size\t";

#	print OUT "$version_lw\tSetup_missing\t$design_name_lw\t$package_f\t$dotstat_i\t$dotstat_node_lw\t$debug_dynamic_node_lw\t$dotstat_r_lw\t$debug_dynamic_r_lw\t";
#	printf OUT "%.3f\t", $rn_ratio_dotstat;
#	printf OUT "%.3f\t", "misssssssss";
#	print OUT "$step_time\t";

#	print "$step_time\t$presim_time\t$sim_time\t";
#	print "$setup_design[0]\n$apl_t\n$power_calc_t\n$extract_t\n$sim_t\n$post_t\n$post_process[0]\n";
#	print "$setup_design[1]\n$apl_import[1]\n$power_calc[1]\n$extraction[1]\n$sim_m\n$post_process[1]\n";
#	print "$adsrpt_size_lw\n$mmDirSize\n$dotapache_size_lw\n$adspower_size_lw\n$total_size\n";
	close OUT;
#	close IN;
}

print "\n#### get_runstat_short.out is created ####\n";
print "\n#### $output is created ####\n";
print "\n#### APACHE_FILES debug is not set in gsr file, the output files won't contain sufficient details without the setting\n" unless ( $debug_check_debug_file_option ) ; 
print "\n#### set ::env(ASIM_PEAK_MEMORY) 1 in command file or setenv ASIM_PEAK_MEMORY 1 in unix terminal is needed\n#### along with gsr keyword DEBUG_ENVIRONMENT 1 for asim peak memory report in log file\n"; 
print "#### run dir snapshot copied at ../$joined_dir ####\n\n" if ($save_mode);
