## New Enhancements done in August,2011
## (1) Input LEF directory Support w/ -ilefdir option (08/24/2011)
##	Please Note: Both ilefdir and ilef option are mutually exclusive
## (2) Option -ilayer is optional(but recommended) and utility uses BOTTOM layer as pin layer(08/22/2011)
##     Please Note: Pin creation and ESD_PIN_PAIR is maded independent of layer specified in -ilayer option
## (3) Clamp type or clamp cell specific RON specification in the setup configuration file(08/22/2011)
## (4) Anti-parallel(or)B2B diode support b/w PWR/PWR or GND/GND. No special option required. Classify the 2 diodes in B2B diode set w/ different types and reverse the RON+ and RON- values in ESD_PIN_PAIR (08/22/2011)
## (5) Global Expression support in setup configuration. To enable this, use "-glob 1" option(Hidden option at the moment) (08/25/2011)
##	Please Note: Do not use "*" option, just specify the base sub-cell name. Please make sure that the strings(for clamp cell name,2nd column) specified in CLAMP_LIST is unique
##(6) Enhanced messaging, all info are tagged with -I- for all the info, -E- for errors and -W- for warnings

eval '(exit $?0)' && eval 'exec perl -S $0 ${1+"$@"}' && eval 'exec perl -S $0 $argv:q' if 0;
use Getopt::Long;

my($help) ;
my($ilef) = "";
#my($olef) = "";
#my($oclamp) = "";
GetOptions("help|h"=>\$help,
           "setup=s"=>\$setup,
           "conf=s"=>\$conf,
           "ilef=s"=>\$ilef,
	   "ilefdir=s"=>\$ilefdir,
           "layer=s"=>\$layer,
           "olef=s"=>\$olef,
           "oclamp=s"=>\$oclamp,
	   "glob=s"=>\$glob);
print "Unprocessed by Getopt::Long\n" if $ARGV[0];

if ($help) {
printUsage();
exit;
}
sub printUsage {
print " Usage ::\n\
perl clampgen.pl 
        \ -setup <1|0 to generate a template config file>
        \ -conf <script_config_file>
        \ -ilef <design>_adsgds1.lef
	\-ilefdir <directory>
        \ -layer <lowest_layer>
        \ -olef <clamp>.lef
        \ -oclamp <clamp>.list

Options:
========
setup ? Creates a template configuration file for the script
conf  ? Configuration file w/ net and clamp cell information
ilef  ? Input LEF generated from 
         GDS translation

ilefdir ? Provide the directory that contains multiple <>_adsgds1.lef
Layer ? lowest metal layer connecting   to devices

Olef  ? output clamp LEF file with      lower level pins
        Default: <design>_clamps.lef

Oclamp ? Clamp cell Info file 
         Default: <clamp>.info\n";
}

sub processLef {
@lefs=`ls $ilefdir/\*_adsgds1.lef`;
print "-I- $lefs[0] @lefs\n";
open(OLEF,">all_adsgds1.lef") ||die "-E- Cannot open the file $lef $!\n";
foreach $lef(@lefs) {
open(ILEF,"$lef") || die "-E- Cannot open the file $lef $!\n";
($local=$lef)=~s/_adsgds1.lef//;
@local=split('/',$local);
$dsn=pop(@local);
	while(<ILEF>) {
	# Print the Design name ahead of Each LEF file
		if(m/^MACRO/i) {
		print OLEF "\# DESIGN $dsn\n";
		print OLEF "$_";
		chomp;split;
		$cell=$_[1];
		$macro=1;
		}
		elsif($macro==1) {
		print OLEF "$_";
		}
		if(m/^END $cell/i) {
		$macro=0;
		}
	}
close (ILEF);
}
close (OLEF);
}
sub openConf {
open(CONF,"$conf")||die "Cannot open the configuration file \n $!\n";
$nfile=0;$ninfo=0;$clamplist=0;$clampfile=0;$user_clamp=0;
print "-I- Parsing the ESD setup configuration file ....\n";
while(<CONF>) {
next if(m/^\s*$/);
next if(m/^\s*\#/);
        if(m/NET_INFO_FILE/) {
#       print;
                $nfile=1;
                next;
        }
        elsif(m/NET_INFO /) {
#       print;
        $ninfo=1;
        next;
        }
        elsif(m/CLAMP_LIST /) {
#       print;
        $clamplist=1;
        next;
        }
        elsif(m/CLAMP_LIST_FILE/) {
#       print;
        $clampfile=1;
        next;
        }
        elsif(m/USER_CLAMP_INFO/) {
        $user_clamp=1;
        next;
        }
        elsif(m/CLAMP_ARC_INFO/) {
        $rule=1;
        next;
        }
        elsif(m/CLAMP_ARC_FILE/) {
        $rulefile=1;
        next;
        }
        elsif(m/\}/) {
#       print;
        $nfile=0;$ninfo=0;$clamplist=0;$clampfile=0;$user_clamp=0;$rule=0;$rulefile=0;
        next;
        }
if($rule==1) {
s/\[//g;s/\] /,/g;s/\]//g;
next if(m/^\s*$/);next if(m/^\s*\#/);
if(m/^\s*RESISTOR/) {
chomp;split;
$rpin1=$_[1];
$rpin2=$_[2];
$res=$_[3];
print "-I- Resistor template defined with pin1=$rpin1 pin2=$rpin2 Resistance of $res\n";
}
else {
#        next if(m/^\s*$/); next if(m/^\s*\#/);
#        s/\[//g;s/\]/:/g;
	chomp;
	@line=split(',',$_);
	@arc1=split(' ',$line[0]);
	$clamp=shift(@arc1);
	@arc2=split(' ',$line[1]);
        $pin1{$clamp}=$arc1[0];
        $pin2{$clamp}=$arc1[1];
		if($arc[2] ne '-') {
		@r=split(':',$arc1[2]);
		$res{$clamp}="$r[0] $r[1]"; ## Can Include the IV profile or RON+ RON- here
		print "-I- $clamp $res{$clamp}\n";
		}
        $pin3{$clamp}=$arc2[0] if(defined($arc2[0]));
        $pin4{$clamp}=$arc2[1] if(defined($arc2[1]));
		if($arc1[2] ne '-') {
		@r1=split(':',$arc1[2]);
		$res1{$clamp}="$r1[0] $r1[1]";
		print "-I- $clamp $res1{$clamp}\n";
		}
###chomp;split;
###$pin1{$_[0]}=$_[1];
###$pin2{$_[0]}=$_[2];
###$res{$_[0]}=$_[3];
###$pin3{$_[0]}=$_[4] if(defined($_[3]));
###$pin4{$_[0]}=$_[5] if(defined($_[4]));
###$res1{$_[0]}=$_[6] if(defined($_[4]));
#print "-I- AAA $_[0] $pin1{$_[0]} $pin2{$_[0]} $pin3{$_[0]} $pin4{$_[0]}\n";
}
}
if($rulefile==1) {
print "-I- Checking the Clamp ARC rules ...\n";
        open(RULE,"$_")||die "Cannot open the file $_\n";
        print "-I- Parsing the Rule file $_ ...\n";
        while(<RULE>) {
        next if(m/^\s*$/); next if(m/^\s*\#/);
        s/\[//g;s/\]/,/g;
	chomp;
	@line=split(',',$_);
	@arc1=split(' ',$line[0]);
	$clamp=shift(@arc1);
	@arc2=split(' ',$line[1]);
        $pin1{$clamp}=$arc1[0];
        $pin2{$clamp}=$arc1[1];
		if($arc[2] ne '-') {
		@r=split(':',$arc1[2]);
		$res{$clamp}="$r[0] $r[1]"; ## Can Include the IV profile or RON+ RON- here
		print "-I- $clamp $res{$clamp}\n";
		}
        $pin3{$clamp}=$arc2[0] if(defined($arc2[0]));
        $pin4{$clamp}=$arc2[1] if(defined($arc2[1]));
		if($arc1[2] ne '-') {
		@r1=split(':',$arc1[2]);
		$res1{$clamp}="$r1[0] $r1[1]";
		print "-I- $clamp $res1{$clamp}\n";
		}
        }
        close RULE;
}
if($ninfo==1) {
        chomp;split;
        $attr{$_[1]}=$_[0];
        $int{$_[1]}=$_[2] if(defined($_[2]));
        print "-I- Netname $_[1]  Attribute $_[0] $_[2] \n";
}
if($clamplist==1) {
next if(m/^\#/);next if(m/^\s*$/);
        chomp;split;
        $type{$_[1]}=$_[0];
        $type_glob{$_[1]}=$_[0];
        print "-I- Clamp $_[1] Type $type{$_[1]}\n";
}
if($nfile==1) {
        open(F,"$_")||die "-E-Cannot open the file $_ \n";
        print "-I- Parsing the Net info file $_ ....\n";
        while(<F>) {
        next if(m/^\s*$/); next if(m/^\s*\#/);
        chomp;split;
        $attr{$_[1]}=$_[0];
        $int{$_[1]}=$_[2] if(defined($_[2]));
        }
        close F;
        foreach $net(keys(%attr)) {
        print "-I- $net $attr{$net}\n";
        }
}
if($user_clamp==1) {
$filename=$_;
        open(F,"$filename")||die "-E- Cannot open the file $filename $!\n";
        print "-I- Parsing User clamp info file\n";
        while(<F>) {
        next if(m/^\s*$/); next if(m/^\s*\#/);
                if(m/^\s*NAME /) {
                chomp;split;
                $clampdef{$_[1]}=$_[1];
                }
        }
        close F;
        open(F,"$filename")||die "-E- Cannot open the file $filename $!\n";
        @clampfile=<F>;
        close F;
        print "-I- The following clamps are defined in the user clamp file..\n";
        foreach $name(keys(%clampdef)) {
        print "-I- $name\n";
        }
        print "-I- It will be appended to generated clamp info file\n";
}
if($clampfile==1) {
        open(CF,"$_")||die;
        print "-I- Parsing the Clamp info file $_ ....\n";
        while(<CF>) {
        next if(m/^\s*$/); next if(m/^\s*\#/);
        chomp;split;
        $type{$_[1]}=$_[0];
        $type_glob{$_[1]}=$_[0];
        }
        close CF;
        foreach $clampcell(keys(%type)) {
        print "-I- $clampcell $type{$clampcell}\n";
        }
}
}
}

if($setup==1) {
open(SETUP,">setup.conf")||die"-E-Cannot open the file $!\n";
print SETUP "
NET_INFO_FILE {
#<file_names>
}
NET_INFO {
# pwr <net_name>
# sig <net_name>
# gnd <net_name>
}
CLAMP_LIST {
#<list of clamps w/ types>
}
CLAMP_LIST_FILE {
# <clamp_type> <clamp_cell_name>
}
USER_CLAMP_INFO {
# <clamp info file generated for library clamp cells>
} 
CLAMP_ARC_FILE {
# FILE WITH Clamp ARC file
}
CLAMP_ARC_INFO {
## Edits
#<TYPE> [ <pin1> <pin2> <RON+>:<RON->],[ <pin1> <pin2> <RON+>:<RON-> ]
}
\n";
close SETUP;
print "-I- Template Configuration file \"setup.conf\" created\n";
exit;
}
elsif(defined($conf)) {
openConf();
}
else {
print "-I- Configuration file is not provided\n";
}

if(!defined($layer)) { $layer="BOTTOM"};

if(defined($ilefdir)) {
processLef();
$ilef="all_adsgds1.lef";
}

($temp=$ilef)=~s/_adsgds1.lef//;
@temp=split('/',$temp);
$design=pop(@temp);
print "-I- Design name is $design \n";

if(!defined($oclamp)) {$oclamp="$design\_clamps.info"};
if(!defined($olef)) {$olef="$design\_clamps\.lef"};
if(!defined($oclamp)) {$oclamp="$design\_clamps.info"};
open(f1,"$ilef")||die "Cannot open the file ilef=$ilef $!\n";
if(defined($olef)) {
open(f2,">$olef")||die "Cannot open the file olef=$olef $!\n";
}
open(f3,">$oclamp")||die "Cannot open the file oclamp=$oclamp $!\n";
open(f4,">$design\.ppi")||die "Cannot open the file ppi_file=$design\.ppi $!\n";
open(SWITCH,">$design\_switch.model")||die "Cannot open the file=$design\_switch.model $!\n";
print SWITCH "*--ASW: 4.2 rel 3B Released Date: 10/02/2006   Linux 2.4.21-27.EL
*--(C) Copyright of Apache Design Solutions, Inc.\n";
#$irect{$layer}=0;
$irect=0;
print "-I- Reading the input LEF file\n";
while(<f1>) {
if(m/^\s*\# DESIGN/i) {
chomp;split;
$design=$_[2];
print "Design name is $design\n";
next;
}
if(m/^\s*\#layer name/i) {
chomp;split;
$type_def=$_[2];
#print "-I- Clamp cell type is $type_def\n";
print f2 "$_\n";
next;
}
if(m/^\s*MACRO/) {
chomp;split;
$clamp=$_[1];
undef @pin;
($clamp_name=$clamp)=~s/($design)(\_)(\S+)_(\d+)/$3/;
$clamp_glob=$clamp_name;
if($glob==1) {
	foreach $a(keys %type_glob) {
		if($clamp_glob=~/\S*$a\S*/i) {
		$clamp_name=$a;
		print "-I- Clamp name $clamp_glob matches the following clamp type $clamp_name\n";
		last;
		}
		else {
		print "-I- Clamp name $clamp_glob does not match with user defined clamp $a\n";
		}
	}
}
else {
	print "-I- Global Expression is disabled\n";
}
print "-I- Uniquified_Clamp_Name:$clamp Orignal_Clamp_Name:$clamp_name Clamp_type:$type{$clamp_name} $type_def\n";
$type{$clamp_name}=$type_def if($type_def ne "");
if(($type_def eq 'RESISTOR') ||($type{$clamp_name} eq 'RESISTOR')) {
$clampdef{$clamp}=1;
}
$type_def="";
#exit;
print f2 "$_\n" if(defined($olef));
print f3 "BEGIN_CLAMP_CELL\n" if(!defined($clampdef{$clamp}));
print f3 "NAME $clamp\n"if(!defined($clampdef{$clamp}));
if(defined($type{$clamp_name})) {
        print f3 "TYPE $type{$clamp_name}\n" if(!defined($clampdef{$clamp}));
        print f3 "# $pin1{$type{$clamp_name}} $pin2{$type{$clamp_name}}\n";
        print f3 "# $pin3{$type{$clamp_name}} $pin4{$type{$clamp_name}}\n";
#       print  "TYPE $type{$clamp_name}\n";
}
elsif(defined($type{$clamp})) {
        print f3 "TYPE $type{$clamp}\n" if(!defined($clampdef{$clamp}));
        print f3 "# $pin1{$type{$clamp}} $pin2{$type{$clamp_name}}\n";
        print f3 "# $pin3{$type{$clamp}} $pin4{$type{$clamp_name}}\n";
$clamp_name=$clamp;
}
elsif(defined($clamp_name)) {
        print f3 "TYPE $clamp_name\n" if(!defined($clampdef{$clamp}));
#       print  "TYPE $clamp_name\n";

}
else {
        print f3 "TYPE $clamp\n" if(!defined($clampdef{$clamp}));
#       print "-I- TYPE $clamp\n";
}
print f4 "$clamp ";
$end=0;$i=0;
}
elsif(m/^\s*PIN/) {
chomp;split;
print f2 "$_\n" if(defined($olef));
#$pin[$i]=$_[1];
$ipin=$_[1];
($tmp=$ipin)=~s/\[/\\\[/;
($jpin=$tmp)=~s/\]/\\\]/;
print "-I- Parsing pin name $ipin $jpin\n";
print f4 "$_[1] { $layer } ";
#print f3 "PIN $_[1] - - $layer\n";
#$i++;
$ilayer=0;
}
elsif(m/^\s*USE/) {
print f2 "$_" if(defined($olef));
chomp;split;
###print "-I- parsing pin attribute $ipin \n";
if(!defined($attr{$ipin})) {
#$attr{$ipin}=$_[1] if(!defined($attr{$ipin}));
$attr{$ipin}='sig';
print "-I- Classifying $ipin as sig by default since attribute is not defined in config file \n"; 
}
}
elsif(m/^\s*LAYER/) {
chomp;split;
        if($_[1]=~/$layer/) {
        $metal=1;
        print f2 "$_\n" if(($ilayer==0) && (defined($olef)));
        $ilayer=1;
        }
        else {
        $metal=0;
        }
}
elsif(m/^\s*RECT/) {
#        if($metal==1) {
        print f2 "$_" if(defined($olef));
        #$irect{$layer}++;
        $irect++;
#        }
}
#elsif(m/^\s*END $ipin/) {
elsif(m/^\s*END $jpin/) {
print "-I- Finished parsing pin info for $clamp $ipin\n";
print f2 "$_" if(defined($olef));
#if($ilayer==1) {
print "-W- There are no rectangles found in layer $layer for clamp $clamp..\n-W- Please verify your LEF file\n" if($irect==0);
print f3 "PIN $ipin - - $layer " if(!defined($clampdef{$clamp}));
print f3 "\# $attr{$ipin} $irect Rectangles \n" if(!defined($clampdef{$clamp}));
$pin[$i]=$ipin;
$i++;
#}
#$irect{$layer}=0;
$irect=0;
}
elsif(m/^\s*END $clamp/i) {
#if(!defined($clampdef{$clamp})){
print "-I- Finished parsing Clamp data from LEF for $clamp\n";
        if($i<2) {
        print "-W- $clamp cell has less than 2 pins, please ensure all the net names are provided in gds2def\n";
        print "-W- IF it is done intentionally, please comment out this clamp from Clamp info file\n";
        print f3 "END_CLAMP_CELL\n" if(!defined($clampdef{$clamp}));
        print f2 "END $clamp\n" if(defined($olef));
        print f4 "\n";
        }
        elsif($i>=2) {
        if((defined($pin1{$type{$clamp_name}}))&&(defined($pin2{$type{$clamp_name}}))){
                if((defined($pin3{$type{$clamp_name}}))&&(defined($pin4{$type{$clamp_name}}))){
                	for($j=0;$j<=$i;$j++) {
###			print "-I- Checking pin $pin[$j]\n";
        	        if(($attr{$pin[$j]} eq $pin1{$type{$clamp_name}}) &&($attr{$pin[$j]} ne $attr{$pin1})) {
        	        print "-I- $type{$clamp_name} $clamp_name $pin1{$type{$clamp_name}} --> $pin[$j]\n";
        	        $pin1=$pin[$j];
        	        }
        	        elsif($attr{$pin[$j]} eq $pin2{$type{$clamp_name}}) {
        	        print "-I- $type{$clamp_name} $clamp_name $pin2{$type{$clamp_name}}--> $pin[$j]\n";
        	        $pin2=$pin[$j];
        	        }
        	        if(($attr{$pin[$j]} eq $pin3{$type{$clamp_name}})&&($attr{$pin[$j]} ne $attr{$pin3})) {
                	print "-I- $type{$clamp_name} $clamp_name $pin3{$type{$clamp_name}} --> $pin[$j]\n";
                	$pin3=$pin[$j];
                	}
                	elsif($attr{$pin[$j]} eq $pin4{$type{$clamp_name}}) {
                	print "-I- $type{$clamp_name} $clamp_name $pin4{$type{$clamp_name}} --> $pin[$j]\n";
                	$pin4=$pin[$j];
                	}
                	}
			if(defined($res{$clamp_name})) { 
			$ron=$res{$clamp_name};print "-I- ON Resistance of $clamp_name is $ron\n"; 
			}
			elsif(defined($res{$type{$clamp_name}})) { 
			$ron=$res{$type{$clamp_name}}; 
			print "-I- ON Resistance of $type{$clamp_name} is $ron\n";		
			}
			else { 
			$ron= "0.1 OFF";
			print "-I- ON Resistance is not defined in setup file, using default RON of 0.1 ohms\n";
			}
			if(defined($res1{$clamp_name})) { 
			$ron1=$res1{$clamp_name}; print "-I- ON Resistance of $clamp_name is $ron1\n"; 
			}
			elsif(defined($res1{$type{$clamp_name}})) { 
			$ron1=$res1{$type{$clamp_name}}; 
			print "-I- ON Resistance of $type{$clamp_name} is $ron1\n"; 
			}
			else { 
			$ron1= "0.1 OFF"; 
			print "-I- ON Resistance is not defined in setup file, using default RON of 0.1 ohms\n";
			}
		if((defined($pin1)) && (defined($pin2))) { 
                print f3 "ESD_PIN_PAIR $pin1 $pin2 $ron\n" if(!defined($clampdef{$clamp}));
                #print "-I- AAA ESD_PIN_PAIR $pin1 $pin2 $ron\n" if(!defined($clampdef{$clamp}));
		}
		if((defined($pin3)) && (defined($pin4))) {
                print f3 "ESD_PIN_PAIR $pin3 $pin4 $ron1 \n" if(!defined($clampdef{$clamp}));
                print "-I- BBB ESD_PIN_PAIR $pin3 $pin4 $ron1 \n" if(!defined($clampdef{$clamp}));
		}
		undef $pin1;undef $pin2;undef $pin3;undef $pin4;undef $ron;undef $ron1;
                }
                else {
                	for($j=0;$j<=$i;$j++) {
                		if(($attr{$pin[$j]} eq $pin1{$type{$clamp_name}}) &&($attr{$pin[$j]} ne $attr{$pin1})) {
                		$pin1=$pin[$j];
                		}
                		elsif($attr{$pin[$j]} eq $pin2{$type{$clamp_name}}) {
                		$pin2=$pin[$j];
                		}
                	}
		if(defined($res{$clamp_name})) { 
			$ron=$res{$clamp_name}; print "-I- ON Resistance of $clamp_name is $ron\n"; 
		}
		elsif(defined($res{$type{$clamp_name}})) { 
			$ron=$res{$type{$clamp_name}}; 
			print "-I- ON Resistance of $clamp_name is $ron\n"; 
		}
		else { 
			$ron1= "0.1 OFF"; 
			print "-I- ON Resistance is not defined in setup file, using default RON of 0.1 ohms\n";
		} 
		if(defined($pin1) && defined($pin2)) { 
                print f3 "ESD_PIN_PAIR $pin1 $pin2 $ron\n" if(!defined($clampdef{$clamp}));
                #print "-I- CCC ESD_PIN_PAIR $pin1 $pin2 $ron\n" if(!defined($clampdef{$clamp}));
		}
		undef $pin1;undef $pin2;undef $pin3;undef $pin4;undef $ron;undef $ron1;
                }
        }
        elsif($type{$clamp_name} eq 'RESISTOR') {
                for($j=0;$j<=$i;$j++) {
                if(($attr{$pin[$j]} eq 'SIGNAL')||($attr{$pin[$j]} eq 'sig')) {
                        if($int{$pin[$j]} eq 'int') {
                        $rpin2=$pin[$j];
                        }
                        else {
                        $rpin1=$pin[$j];
                        }
                }
                }
                print f2 "PIN en\n DIRECTION INOUT ;\n USE SIGNAL ;\nEND en\n";
print SWITCH "
                               
SWITCH_CELL $clamp {
        SWITCH_TYPE: HEADER 
        EXT_PIN: $rpin1
        INT_PIN: $rpin2
        CTRL_PIN: en F R
        ON:
                R $res 
                I 8.218e-09
                C 7.577e-15
                IDSAT 1
        OFF: 
                C 5.245e-17
                VI 1.1 
                N_VO_I 12
                0       1.895e-07
                0.09167 1.653e-07 
                0.1833  1.44e-07
                0.275   1.249e-07 
                0.3667  1.077e-07
                0.4583  9.205e-08
                0.55    7.791e-08 
                0.6417  6.514e-08
                0.7333  5.36e-08
                0.825   4.315e-08
                0.9167  3.36e-08
                1.089   6.167e-09
        POWER_UP:
                VI 1.1
                N_VO_R 12
                0       417.6
                0.09167 394.9
                0.1833  369.1
                0.275   340.2
                0.3667  310.5
                0.4583  280.4
                0.55    250
                0.6417  220
                0.7333  191.9
                0.825   167.2
                0.9167  146.2
                1.089   114.7
        POWER_DOWN:
                VI 1.1
                N_VO_R 12
                0       5.806e+06
                0.09167 6.1e+06
                0.1833  6.364e+06
                0.275   6.603e+06
                0.3667  6.811e+06
                0.4583  6.971e+06
                0.55    7.059e+06
                0.6417  7.036e+06
                0.7333  6.841e+06
                0.825   6.373e+06
                0.9167  5.456e+06
                1.089   1.784e+06
}\n";
        }
        else {
        print "-I- Clamp $clamp has more than 1 arc.. Please verify the ESD_PIN_PAIR\n" if($i>2);
        for($j=0;$j<=$i;$j++) {
                for($k=($j+1);$k<=($i-1);$k++) {
                if(($attr{$pin[$j]} eq 'GROUND')||($attr{$pin[$j]} eq 'gnd')) {
                #print "-I- $attr{$pin[$j]} $attr{$pin[$k]}";
                        if(($attr{$pin[$k]} eq 'POWER')||($attr{$pin[$k]} eq 'pwr')) {
                        print f3 "ESD_PIN_PAIR $pin[$j] $pin[$k] 0.1 0.1\n" if(!defined($clampdef{$clamp}));
                        }
                        else {
                        print f3 "ESD_PIN_PAIR $pin[$j] $pin[$k] 0.1 OFF\n" if(!defined($clampdef{$clamp}));
                        }
                }
                elsif(($attr{$pin[$j]} eq 'SIGNAL')||($attr{$pin[$j]} eq 'sig')) {
                #print "-I- $attr{$pin[$j]} $attr{$pin[$k]}";
                        if(($attr{$pin[$k]} eq 'POWER')||($attr{$pin[$k]} eq 'pwr')) {
                        print f3 "ESD_PIN_PAIR $pin[$j] $pin[$k] 0.1 OFF\n" if(!defined($clampdef{$clamp}));
                        }
                        else {
                        print f3 "ESD_PIN_PAIR $pin[$k] $pin[$j] 0.1 OFF\n" if(!defined($clampdef{$clamp}));
                        }
                }
                else {
                        if(($attr{$pin[$k]} eq 'SIGNAL') ||($attr{$pin[$k]} eq 'sig')) {
                        print f3 "ESD_PIN_PAIR $pin[$k] $pin[$j] 0.1 OFF\n" if(!defined($clampdef{$clamp}));
                        }
                        else {
                        print f3 "ESD_PIN_PAIR $pin[$k] $pin[$j] 0.1 0.1\n" if(!defined($clampdef{$clamp}));
                        }
                }
                }
        }
        }
        print f3 "END_CLAMP_CELL\n" if(!defined($clampdef{$clamp}));
        print f2 "END $clamp\n" if(defined($olef));
        print f4 "\n";
        $end=1;
        }
}
#}
else {
print f2 "$_" if(defined($olef));
}
}
print f3 "@clampfile";
print "-I- #####Important!!! Please verify the ESD_PIN_PAIR section in the clamp cell info file and specify the correct Arcs\n";
#print "-I- Moving the input <>_adsgds1.lef to <>_adsgds1.lef.orig\n";
close(f1);
close(f2);
close (f3);
close(f4);
