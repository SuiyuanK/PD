$file_totcl = './totcl.txt';

$l = 0 ;
$m = 0 ;
if(-e $file_totcl)
{
open(FP7, $file_totcl);
while(<FP7>)
{
if($_ =~m/^Designbbox/)
{

@array2 = split(/\s+/,$_);
$Xpar = abs($array2[1]) + abs($array2[3]) ;
$Ypar = abs($array2[2]) + abs($array2[4]) ;

}
if ($_ =~ m/^APLMMX_path\s*(\S+)/) {
$apl_mmx_path = $1 ;
}

if($_ =~m/^Output_file\s*(\S+)/)
{
$final_output = $1 ;
}
if($_ =~m/Threshold_file\s*(\S+)/)
{
$threshold_file = $1 ;
}
if($_ =~m/^VOLTAGE\s*DOMAINS.*\s*(\S+)/)
{
$var[21] =$1 ;
}

if ($_ =~m/^EM_THRESHOLD\s+(.*)/)
{
$var[30] =  $1 ;
}
if ($_ =~m/^EM_THRESHOLD_AVG\s+(.*)/)
{
$var[30] =  $1 ;
}
if ($_ =~m/^EM_THRESHOLD_RMS\s*(.*)/)
{
$var[47] =  $1 ;
}
if ($_ =~m/^EM_THRESHOLD_PEAK\s*(.*)/)
{
$var[51] = $var[55]= $1 ;
}
if ($_ =~m/^Mode:\s*(\S+)\s+(.*)\s+(.*)/)
{
$var[35] = $1.$2 ;
$var[37]  =$3;
}




}
close(FP7);

}
if(!defined($var[47])) {
$var[47] = $var[30] ;
}
if(!defined($var[51])) {
$var[51]=$var[30];
}
if(!defined($var[55])) {
$var[55]=$var[51];
}


$var[36] = ($Xpar * $Ypar)*(10e-07) ;








$file_empro    = "".$apl_mmx_path."./adsRpt/empro.log";
if(-e $file_empro)
{
open(FP1, $file_empro);
while(<FP1>)
{
if ($_ =~m/^Info:\s+TOP_CELL:\s*(\S+)/)
{
$var[19] = $1;
}

}
close(FP1);
}
$file_gsr    = './'.$var[19].'.gsr';
$file_totlog = './adsRpt/totem.log';

$file_emavg  = './adsRpt/SignalEM/'.$var[19].'.em.worst';
$file_emrms = './adsRpt/SignalEM/'.$var[19].'.em.worst.rms';
$file_emshort ='./adsRpt/SignalEM/'.$var[19].'.em.worst.peak';
$file_emlong ='./adsRpt/SignalEM/'.$var[19].'.em.worst.peak';


$file_sigemnet = './adsRpt/apache.sigem.netinfo';
#$file_totcl = './totcl.txt';
#$file_mactype = './gdsmmx/'.$var[19].'.gds.config';
$file_mactype = './'.$var[19].'.gds.conf'; 
#$file_ipwr    = './adsRpt/Dynamic/'.$var[19].'.ipwr';
#$file_ivdd    = './adsRpt/Dynamic/'.$var[19].'.ivdd';
#$file_thresh  = './thresh.txt';
#$file_out = '>./output_totem.txt';
$file_thresh = './'.$threshold_file ;
$file_out ='>./'.$final_output;
$file_sfactor = './em.ratio';

open(FP2, $file_out) or die "Cannot open $file_out\n";



if(-e $file_empro)
{

open(FP1, $file_empro) or die "Cannot open $file_empro\n";
while(<FP1>)
{
if ($_ =~m/^\s*Info:\s+Total\s+No\.\s+of\s+Mos\s+Device:\s+(\d+)\s*$/)
{
$var[1] = $1 ;
}

if ($_ =~m/^\s*Info:\s+Total\s+No\.\s+of\s+Bjt\s+Device:\s+(\d+)\s*$/)
{
#print "Total Bjt No :" .$1. "\n";
$var[2] = $1 ;
}

if($_ =~m/^\s*Info:\s+Total\s+No\.\s+of\s+Diode\s+Device:\s+(\d+)\s*$/)
{
$var[4] = $1;
}


if($_ =~m/^\s*Info:\s+Total\s+No\.\s+of\s+Resistor\s+Device:\s+(\d+)\s*$/)
{
$var[5] = $1;
}


if($_ =~m/^\s*Info:\s+Total\s+No\.\s+of\s+Capacitor\s+Device:\s+(\d+)\s*$/)
{
$var[6] = $1;
}

if($_ =~m/^\s*Info:\s+Total\s+No\.\s+of\s+Inductor\s+Device:\s+(\d+)\s*$/)
{
$var[7] = $1;
}


if($_ =~m/^\s*Info:\s+Total\s+No\.\s+of\s+Switch:\s+(\d+)\s*$/)
{
$var[8] = $1;
}

if($_ =~m/^\s*Info:\s+Total\s+No\.\s+of\s+Intentional\s*Decaps:\s+(\d+)\s*$/)
{
$var[9] =$1;
}


if($_ =~m/^\*\s*Hostname:\s+(\S+)/)
{
$var[11] = $1 ;
}

if($_ =~m/^\*\s*Username:\s+(\S+)/)
{
$var[12] = $1 ;
}

if($_ =~m/\*\s*Start\s*Time:\s+(\S+)/)
{
$var[13] = $1 ;
}

if($_ =~m/TOTAL CPU TIME:\s+(.*)/)
{
$var[14] = $1;
}

if($_ =~m/^MEMORY USAGE:\s+(.*)/)
{
$var[15] = $1;
}

if($_ =~m/^WALLTIME:\s+(.*)/)
{
$var[16] = $1;
}

if($_ =~m/^CPU TIME \(aplmmx\):\s*(.*)/)
{
$var[17] = $1;
}

if($_ =~m/^\*\s*Aplmmx\s*(.*)\*$/)
{
$var[18] = $1;
}
########
if(m/Total Nets in DSPF:\s+(\S+)/i) {
$tot_nets=$1;
}
if(m/Total Nets dropped from signal EM analysis:\s+(\S+)/i) {
$dropped_nets=$1;
}
if(m/Total Nets kept in signal EM analysis:\s+(\S+)/i) {
$kept_nets=$1;
}
if (m/^ERROR(\S+)\s*(.*)/)
{
$ecode[$l] = $1 ;
$ereason[$l] = $2 ;
$l++ ;
}
if (m/^WARNING(\S+)\s*(.*)/)
{
$wcode[$m] = $1 ;
$wreason[$m] = $2 ;
$m++ ;
}
##########
}

close(FP1);
print "Finished Reading the APLMMX(EMPRO) log file...\n";
}

#else
#{
#print "Cannot find/open".$file_empro."\n";
#}



$count = 0 ;
if(-e $file_gsr)
{
open (FP3, $file_gsr);
while (<FP3>)
{
if (/^VDD_NETS/i) {
$found_internal_pin = 1 ;
}
if ( $found_internal_pin == 1 && !/^VDD_NETS/i && !/\}/ && $_ ne "" ) {

$domains[$count] = $_ ;
$count++ ;
}
if($found_internal_pin == 1 && /\}/) {
$found_internal_pin = 0 ;
}

if ($_ =~m/^FREQ.*\s+(\S+)/)
{
$var[23] = $1;
}

}
close(FP3);
print "Finished Reading GSR file...\n";
}
#else
#{
#print "Cannot find/open".$file_gsr."\n" ;
#}

if(-e $file_totlog)
{
open(FP4, $file_totlog);
{
while(<FP4>)
{
if($_ =~m/^MMX_cell\s*(\S+)/)
{
$var[25] = $1 ;
}


if($_=~m/^WIRE\s*(\S+)mV\s+VDD\s+(\S+)/)
{
$var[26] = $1;
}

if($_=~m/^WIRE\s*(\S+)mV\s+VSS\s+(\S+)/)
{
$var[27] = $1 ;
}

if ($_=~m/^Xtor\s+(\S+)\s+VDD\s+(\S+)/)
{
$var[28] = 1000*($2 - $1) ;
}

if ($_=~m/^Xtor\s+(\S+)\s+VSS\s+(\S+)/)
{
$var[29] = 1000*($1 -$2) ;
}

if ($_ =~m/^XtorMinWc\s+(\S+)\s+VDD\s+(\S+)/)
{
$var[45] = 1000*($2 -$1) ;
}

if($_ =~m/^XtorMinWc\s+(\S+)\s+VSS\s+(\S+)/)
{
$var[46] = 1000*($2 - $1) ;
}


if ($_ =~m/^ERROR(\S+)\s*(.*)/)
{
$ecode[$l] = $1 ;
$ereason[$l] = $2 ;
$l++ ;
}
if ($_ =~m/^WARNING(\S+)\s*(.*)/)
{
$wcode[$m] = $1 ;
$wreason[$m] = $2 ;
$m++ ;
}

if ($_ =~m/^PKG\s+(\S+)\s+VDD.*/)
{
$var[39] = $1 ;
}

if ($_ =~m/^PKG\s+(\S+)\s*.*/)
{
$var[40] = $1 ;
}

}
close(FP4);
}
##################################
open(TOTLOG,$file_totlog); 
	$tot_var[0]=`hostname`;
	$tot_var[1]=`whoami`;
	$tot_var[2]=`date`;
chomp($tot_var[0]);chomp($tot_var[1]);chomp($tot_var[2]);
while(<TOTLOG>) {
	if(m/^Totem/) {
	chomp;
	@a=split('--',$_);
	$tot_var[6]=$a[0] if(!defined($tot_var[6]));
	}
	if(m/MEMORY USAGE \(EM check\)/i) {
	chomp;
	@a=split(':',$_);
	$tot_var[4]= $a[1];
#	print "$tot_var[4]\n";
	$finished=1;
	}
	if(m/TOTAL CPU TIME/i) {
	chomp;
	@a=split(':',$_);
	$tot_var[3]=$a[1] if($finished==1);
#	print "$tot_var[3]\n";
	}
	if(m/WALLTIME/i) {
	chomp;
	@a=split(':',$_);
	$tot_var[5]=$a[1] if($finished==1);
#	print "$tot_var[5]\n";
	}

close(TOTLOG);
print "Finished Reading totem.log file...\n";
#############################################

my %hash ;
foreach my$element (@wcode)
{
$hash{$element}++ ;
}
my @wcode2 = keys %hash ;
my @wcode3 ;
my @wreason ;
my @wcount ;
my $q = 0 ;
foreach my $elem(@wcode2)
{
$wcount[$q] = $hash{"$elem"} ;

####################################
if(-e $file_empro)
{

open(FP1, $file_empro);
$elem=~s/\(|\)|\://g;
$wcode3[$q] = $elem;

while(<FP1>)
{
if (/WARNING.${elem}.:\s*(.*)/ )
{
$wreason3[$q] = $1 ;
#print $ereason3[$q];
$q++ ;
#print $q ;
last;

}

}
close(FP1);
}

#else 
#{
#print "Cannot open/find".$file_empro."\n" ;
#}
###############################################
if(-e $file_totlog)
{

open(FP4, $file_totlog);
$elem=~s/\(|\)|\://g;
$wcode3[$q] = $elem;

while(<FP4>)
{
if (/WARNING.${elem}.:\s*(.*)/ )
{
$wreason3[$q] = $1 ;
#print $ereason3[$q];
$q++ ;
#print $q ;
last;

}

}
close(FP4);
}

#else 
#{
#print "Cannot open/find".$file_totlog."\n" ;
#}
}

my %hash1 ;
foreach my$element1 (@ecode)
{
$hash1{$element1}++ ;
}
my @ecode2 = keys %hash1 ;


my @ecode3 ;
my @ereason3 ;
my @ecount ;
my $r = 0 ;
foreach my $elem1(@ecode2)
{
$ecount[$r] = $hash1{"$elem1"};
######################################
if(-e $file_empro)
{

open(FP1, $file_empro);
$elem1=~s/\(|\)|\://g;
$ecode3[$r] = $elem1;

while(<FP1>)
{
if (/ERROR.${elem1}.:\s*(.*)/ )
{
$ereason3[$r] = $1 ;
#print $ereason3[$q];
$r++ ;
#print $r ;
last;

}

}
close(FP1);
}
######################################
if(-e $file_totlog)
{

open(FP4, $file_totlog);
$elem1=~s/\(|\)|\://g;
$ecode3[$r] = $elem1;

while(<FP4>)
{
if (/ERROR.${elem1}.:\s*(.*)/ )
{
$ereason3[$r] = $1 ;
#print $ereason3[$q];
$r++ ;
#print $r ;
last;

}

}
close(FP4);
}
}


####
$count_11 = 0 ;
if(-e $file_emavg)
{
open(FP5, $file_emavg);
while(<FP5>)
{
if ($_ !~m/^#/ && $_ !~m/^$/)
{
@arrayavg = split(/\s+/ , $_);


if ($arrayavg[3] > $var[30])
{
$count_11++ ;
}

}
#if ($_ =~m/Limit\s*>\s*(\S+)/)
#{
#$var[30] = $1 ;
#}
}


close(FP5);
}

#else
#{
#print "Cannot open/find".$file_emavg."\n" ;
#}

if(-e $file_emavg)
{
open(FP5, $file_emavg) ;


while(<FP5>)
{
if($_ =~m/^via\s*(.*)/)
{
$var[33] = $1  ;
last;
}

}
close(FP5);
}


if(-e $file_emavg)
{
open(FP5, $file_emavg) ;


while(<FP5>)
{
if($_ =~m/^diffcon\s*(.*)/)  
{
$var[33] = $1 ;
last;
}

}
close(FP5);
}



if(-e $file_emavg)
{
open(FP5, $file_emavg) ;


while(<FP5>)
{
if($_ =~m/^metal\s*(.*)/)
{
$var[32] = $1 ;
last;
}

}
close(FP5);
}

$var[31] = $count_11;

######

$count_12 = 0 ;
if(-e $file_emrms)
{
open(FP5, $file_emrms);
while(<FP5>)
{
if ($_ !~m/^#/ && $_ !~m/^$/)
{
@arrayrms = split(/\s+/ ,$_);
if ($arrayrms > $var[47])
{
$count_12++ ;
}
}
#if ($_ =~m/Limit\s*>\s*(\S+)/)
#{
#$var[47] = $1 ;
#}
}


close(FP5);
}

#else
#{
#print "Cannot find/open".$file_emrms."\n";
#}

if(-e $file_emrms)
{
open(FP5, $file_emrms) ;


while(<FP5>)
{
if($_ =~m/^via\s*(.*)/)
{
$var[50] = $1 ;
last;
}

}
close(FP5);
}




if(-e $file_emrms)
{
open(FP5, $file_emrms) ;


while(<FP5>)
{
if($_ =~m/^diffcon\s*(.*)/)
{
$var[50] = $1. $2 ;
last;
}

}
close(FP5);
}





if(-e $file_emrms)
{
open(FP5, $file_emrms) ;


while(<FP5>)
{
if($_ =~m/^metal\s*(.*)/)
{
$var[49] = $1 ;
last;
}

}
close(FP5);
}

$var[48] = $count_12;

####

$count_13 = 0 ;
if(-e $file_emshort)
{
open(FP5, $file_emshort);
while(<FP5>)
{
if ($_ !~m/^#/ && $_ !~m/^$/)
{
@arrayshort = split(/\s+/ , $_);
if ($arrayshort > $var[51])
{
$count_13++ ;
}
}
#if ($_ =~m/Limit\s*>\s*(\S+)/)
#{
#$var[51] = $1 ;
#}
}


close(FP5);
}
#else
#{
#print "Cannot open/find".$file_emshort."\n";
#}

if(-e $file_emshort)
{
open(FP5, $file_emshort) ;


while(<FP5>)
{
if($_ =~m/^via\s*(.*)/)
{
$var[54] = $1 ;
last;
}

}
close(FP5);
}


if(-e $file_emshort)
{
open(FP5, $file_emshort) ;


while(<FP5>)
{
if($_ =~m/^diffcon\s*(.*)/)
{
$var[54] = $1;
last;
}

}
close(FP5);
}





if(-e $file_emshort)
{
open(FP5, $file_emshort) ;


while(<FP5>)
{
if($_ =~m/^metal\s*(.*)/)
{
$var[53] = $1 ;
last;
}

}
close(FP5);
}


$var[52] = $count_13;


######

$count_14 = 0 ;
if(-e $file_emlong)
{
open(FP5, $file_emlong);
while(<FP5>)
{
if ($_ !~m/^#/ && $_ !~m/^$/)
{
@arraylong = split(/\s+/ , $_) ;
if ($arraylong[3] > $var[55])
{
$count_14++ ;
}
}
#if ($_ =~m/Limit\s*>\s*(\S+)/)
#{
#$var[55] = $1 ;
#}
}


close(FP5);
}
#else {
#print "Cannot open/find".$file_emlong."\n" ;
#}

if(-e $file_emlong)
{
open(FP5, $file_emlong) ;


while(<FP5>)
{
if($_ =~m/^via\s*(\S+)\s*(\S+)/)
{
$var[58] = $1. $2 ;
last;
}

}
close(FP5);
}
#else {
#print "Cannot open/find".$file_emlong."\n" ;
#}


if(-e $file_emlong)
{
open(FP5, $file_emlong) ;


while(<FP5>)
{
if($_ =~m/^diffcon\s*(.*)/)
{
$var[58] = $1;
last;
}

}
close(FP5);
}

#else {
#print "Cannot open/find".$file_emlong."\n" ;
#}

if(-e $file_emlong)
{
open(FP5, $file_emlong) ;


while(<FP5>)
{
if($_ =~m/^metal\s*(.*)/)
{
$var[57] = $1 ;
last;
}

}
close(FP5);
}


$var[56] = $count_14;


###
$count_2 = 0 ;
if(-e $file_sigemnet)
{
open(FP6, $file_sigemnet);
while(<FP6>)
{
if($_ !~m/^#/)
{
@array1 = split(/\s+/,$_);
$count_2++ ;
push(@analysis_type, $array1[9]);
}
}
close(FP6);
}
#else
#{
#print "Cannot open/find".$file_sigemnet."\n" ;
#}

print "Finished Reading EM Report files...\n";
#print "@analysis_type" ;

$mix =   0 ;
$vec =   0 ;
$vless = 0 ;
$err   = 0 ;
foreach(@analysis_type)
{
if ($_ eq "SIM")
{
$vec = 1 ;
}
if($_ eq "CCR_DRV" || $_ eq "CCR_P" || S_ eq "CCR_N" || $_ eq "CCR_L" || $_ eq "NCCR_DRV" || $_ eq "NCCR_PI" || $_ eq "NCCR_PO")
{
$vless = 1 ;
}
if($_ eq "SIM_H")
{
$mix = 1 ;
}

if($_ eq "NCCR_DRV" || $_ eq "NCCR_PO" || $_ eq "UNDEFINED")
{
$err = 1;
$error_rep = $_ ;
}
}

#if ($vec == 1)
#{
#$var[37] = VECTOR_BASED  ;
#}

#if($vless == 1  & $mix == 1)
#{
#$var[37] = MIXED ;
#}
#if($vless == 1 && $mix == 0)
#{
#$var[37] = VECTOR_LESS ;
#}

$var[34] = $count_2;
#
#
if(-e $file_mactype)
{
open(FP8,$file_mactype);

while(<FP8>)
{
if ($_ =~m/^MACRO_TYPE\s+(\S+)/)
{
$var[38] = $1 ;
}
}
close(FP8);
}

##else
#{
#print "Cannot open/find".$file_mactype."\n";
#}

if(-e $threshold_file)
{
open(FP11, $file_thresh);

while(<FP11>)
{
if($_ =~m/^STATIC_IR_DROP\s+(\S+)/)
{
$var[44] = $1 ;
}

}

close(FP11) ;
}
else
{
$var[44] = "100 mV" ;
}

$count_15 = 0 ;
if(-e $file_sfactor)
{
open(FP12,$file_sfactor);
while(<FP12>)
{
if ($_ =~m/^!Report threshold =\s*(\S+)/)
{
$var[59] = $1 ;
}


if(($_ !~m/^CELL/)   && ($_ !~m/^!/) && ($_ !~m/^#/))
{
@arraysfactor = split(/\s+/ , $_) ;
push(@arraysratio, $arraysfactor[25]);
if ($arraysfactor[25] > $var[59])
{

$count_15++ ;
}
}


}
close(FP12);

}

#else
#{
#print "Cannot find/open".$file_sfactor."\n" ;
#}
@arraysratio = sort {$b <=> $a}@arraysratio ;
$maxratio = $arraysratio[$#arraysratio -1];


if (-e $file_sfactor)
{
open(FP12, $file_sfactor);
while(<FP12>)
{
if(($_ !~m/^CELL/)   && ($_ !~m/^!/) && ($_ !~m/^#/))
{
@arraysfactor2 = split(/\s+/, $_);
if($arraysfactor2[25] eq $maxratio)
{
$var[61] = $arraysfactor2[1].$arraysfactor2[2] ;
}


}
}
close(FP12);
}
print "Finished Reading S-factor Report files...\n";





$var[60] = $count_15 ;

















$var[3] = $var[2] + $var[1] ;
$var[10] = $var[3] + $var[4] + $var[5] + $var[6] + $var[7] + $var[8] + $var[9]  ;




for ($i = 1 ; $i < 100; $i++)
{
unless(defined $var[$i])
{
$var[$i] = NA;
}
}

print FP2 "DESIGN SUMMARY\n";
print FP2 "---------------------------------------------------------------------------------------\n\n" ;
print FP2 "DESIGN NAME             	\t" .$var[19]."\n";
print FP2 "DESIGN SIZE             	\t" .$Xpar."um  By ".$Ypar."um"."\n";
print FP2 "DESIGN AREA             	\t" .$var[36]."sq mm \n" ;
print FP2 "DEVICE COUNT            	\t" .$var[10]."\n";
print FP2 "NO OF VOLTAGE DOMAINS   	\t" .$var[21]."\n";
print FP2 "NO OF SIGNAL NETS       	\t" .$tot_nets."\n" ;
print FP2 "NO OF SIGNAL NETS ANALYZED   	\t" .$kept_nets."\n" ;
print FP2 "NO OF SIGNAL NETS DROPPED    	\t" .$dropped_nets."\n" ;
print FP2 "FREQUENCY               	\t" .$var[23]."  hertz\n";
print FP2 "MACRO TYPE              	\t" .$var[38]."\n" ;
print FP2 "ANALYSIS MODE           	\t" .$var[37]."\n";
print FP2 "ANALYSIS TYPE           	\t" .$var[35]."\n\n \n";



print FP2 "DEVICE COUNT DETAILS\n\n" ;
print FP2 "-----------------------------------------\n";
print FP2 "Device Type                  Count\n" ;
print FP2 "-----------------------------------------\n";
print FP2 "Total No of MOS Devices:  \t" .$var[1]."\n";
print FP2 "Total No of BJT Devices:  \t" .$var[2]."\n";
#print FP2 "Total No of Transistors:  \t" .$var[3]."\n";
print FP2 "Total No of Diode Devices:\t" .$var[4]."\n";
print FP2 "Total No of Resistors:    \t" .$var[5]."\n";
print FP2 "Total No of Capacitors:   \t" .$var[6]."\n";
print FP2 "Total No of Inductors:    \t" .$var[7]."\n";
print FP2 "Total No of Switches:     \t" .$var[8]."\n";
print FP2 "Total No of Intentional Decaps  ".$var[9]."\n";
print FP2 "---------------------------------------------------------------------------------------------\n";
print FP2 "TOTAL                     \t" .$var[10]."\n";
print FP2 "---------------------------------------------------------------------------------------------\n\n\n";

print FP2 "PERFORMANCE SUMMARY\n";
print FP2 "----------------------------------------\n";
print FP2 "CHARACTERIZATION\n";
print FP2 "################\n";
print FP2 "Host name                    ".$var[11]."\n";
print FP2 "User name                    ".$var[12]."\n";
print FP2 "Date                         ".$var[13]."\n";
#print FP2 "TOTAL CPU TIME               ".$var[14]."\n";
print FP2 "MEMORY USAGE                 ".$var[15]."\n";
print FP2 "WALL TIME                    ".$var[16]."\n";
print FP2 "TOOL Version                 ".$var[18]."\n";
print FP2 "---------------------------------------\n\n\n";
print FP2 "IR/RV ANALYSIS  \n";
print FP2 "################\n";
print FP2 "Host name                    ".$tot_var[0]."\n";
print FP2 "User name                    ".$tot_var[1]."\n";
print FP2 "Date                         ".$tot_var[2]."\n";
#print FP2 "TOTAL CPU TIME               ".$tot_var[3]."\n";
print FP2 "MEMORY USAGE                 ".$tot_var[4]."\n";
print FP2 "WALL TIME                    ".$tot_var[5]."\n";
print FP2 "TOOL Version                 ".$tot_var[6]."\n";




print FP2 "VOLTAGE DOMAIN DETAILS\n";
$d=0 ;
#print FP2 "".$domains[0]."\n" ;
#print FP2 "".$domains[1]."\n" ;
#print FP2 "".$domains[2]."\n" ;

while ($d < $length ) {
print FP2 "$domains[$d]" ;
$d++ ;
}
print FP2 "----------------------------------------------------------------------------------------------\n";
#print FP2 "VDD = ".$var[24]."V\n\n\n" ;

print FP2 "RV RESULTS SUMMARY \n";
print FP2 "----------------------------------------------------------------------------------------------\n";
if(-e $file_emavg)
{
print FP2 "AVG-EM VIOLATION THRESHOLD    ".$var[30]." % \n";
print FP2 "TOTAL AVG-EM VIOLATIONS       ".$var[31]." \n";
print FP2 "WORST METAL AVG-EM VIOLATIONS ".$var[32]."\n";
print FP2 "WORST VIA AVG-EM VIOLATIONS   ".$var[33]."\n";
print FP2 "Refer to \n";
print FP2 "$file_emavg"."\n\n" ;
}

if(-e $file_emrms)
{
print FP2 "RMS-EM VIOLATION THRESHOLD    ".$var[47]." % \n";
print FP2 "TOTAL RMS-EM VIOLATIONS       ".$var[48]." \n";
print FP2 "WORST METAL RMS-EM VIOLATIONS ".$var[49]."\n";
print FP2 "WORST VIA RMS-EM VIOLATIONS   ".$var[50]."\n";
print FP2 "Refer to \n";
print FP2 "$file_emrms"."\n\n" ;
}

if(-e $file_emshort)
{
print FP2 "SHORT_PEAK-EM VIOLATION THRESHOLD    ".$var[51]." %\n";
print FP2 "TOTAL SHORT_PEAK-EM VIOLATIONS       ".$var[52]." \n";
print FP2 "WORST METAL SHORT_PEAK-EM VIOLATIONS ".$var[53]."\n";
print FP2 "WORST VIA SHORT_PEAK-EM VIOLATIONS   ".$var[54]."\n";
print FP2 "Refer to \n";
print FP2 "$file_emshort"."\n\n" ;
}

if(-e $file_emlong)
{
print FP2 "LONG_PEAK-EM VIOLATION THRESHOLD    ".$var[55]." %\n";
print FP2 "TOTAL LONG_PEAK-EM VIOLATIONS       ".$var[56]." \n";
print FP2 "WORST METAL LONG_PEAK-EM VIOLATIONS ".$var[57]."\n";
print FP2 "WORST VIA LONG_PEAK-EM VIOLATIONS   ".$var[58]."\n";
print FP2 "Refer to \n";
print FP2 "$file_emlong"."\n\n" ;
}
if(-e $file_sfactor)
{

print FP2 "S-FACTOR SUMMARY\n" ;
print FP2 "--------------------------------------------------------------------------------------\n";
print FP2 "S-FACTOR VIOLATION THRESHOLD     ".$var[59]."\n" ;
print FP2 "S-FACTOR VIOLATIONS              ".$var[60]."\n" ;
print FP2 "WORST S-FACTOR VIOLATIONS        ".$var[61]."\n" ;
print FP2 "Please refer to all the violations in S-FACTOR violation report \n";
}



#print FP2 "Number of Nets                ".$var[34]."\n\n\n";

print FP2 "WARNINGS SUMMARY \n" ;
print FP2 "---------------------------------------------------------------------------------------------------------------------\n";
print FP2 "Warning Code\t Count  \t   Description \n" ;
print FP2 "---------------------------------------------------------------------------------------------------------------------\n";
$s = 0 ;
while($s <= $#wcode3 + 1)
{
print FP2 "$wcode3[$s]\t"."\t  $wcount[$s]\t"."\t$wreason3[$s]\n" ;
$s++ ;
}
print FP2 "ERROR SUMMARY \n";
print FP2 "---------------------------------------------------------------------------------------------------------------------\n";
print FP2 "Error Code   \tCount  \t  Description  \n" ;
print FP2 "----------------------------------------------------------------------------------------------------------------------\n";
$t = 0 ;
while($t <= $#ecode3 + 1)
{
print FP2 "$ecode3[$t]\t"."\t  $ecount[$t]\t"."$ereason3[$t]\n\n" ;
$t++ ;
}
print FP2 "---------------------------------------------------------------\n";
if($err)
{
print FP2 "ERROR SUMMARY (NET RELATED ISSUES)\n";
print FP2 "---------------------------------------------------------------------------\n";
print FP2 "$err_rep\t". "NCCR_DRV--> Cannot find driver through CCR,NCCR_PO --> PO net does not have a CCR,UNDEFINED --> no result from CCR";

}
close(FP2);
print "Signal RV summary report generated successfully !!!!\n";
}
