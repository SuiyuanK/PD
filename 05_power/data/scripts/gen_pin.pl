#!/usr/bin/perl
#################################################################
#Author : Sooyong Kim  2008.6
#Purpose: Script to generate pins for CMM model creation 
#################################################################

#################################################################################################
use Getopt::Long;


my($memlistfile) = "memlist";

GetOptions("help|h"=>\$help,
	   "top_metal_layer=s"=>\$top_metal_layer,
	    "memlist|mem|m=s"=> \$memlistfile,
	     "out_dir=s"=> \$cmmOutDir,
	     "-debug=s" => \$debug);


if ($help) {
printUsage();
exit;   
} 

sub printUsage
{
print "USAGE :: \n\
perl gen_pin.pl <options>
 
-memlist | mem | m 	<memory list file>
			gets memory list file that has the following format
			cell_name gds2def_view_location_for_cell
-top_metal_layer 	specify the top_layer on which pins for all nets will be created
-out_dir 		specify the output directory
-help | -h		print help message


";
}
#################################################################################################

if($top_metal_layer eq "") {
print "ERROR:Enter the top metal layer \n";
printUsage();
exit;
}

$cmmOutDir = "cmmOutDir" if(!defined($cmmOutDir));
system("mkdir -p $cmmOutDir");
#system("mkdir -p cmmOutDir");
open( MEM_LIST, "$memlistfile") || die "$memlistfile does not exist. create one for the list of cellsl for CMM creation : $!";

while (<MEM_LIST>) {

if (/^\#/) {
}

else {
chomp($_);

($mem_name, $gds2def_dir) = split (/\s+/ , $_ ); 

print "Running makepin.pl for MACRO $mem_name\n"; 

system("mkdir -p $cmmOutDir/$mem_name") ;


@def_files = <$gds2def_dir/$mem_name*.def>;
chdir "$gds2def_dir";
@temp1 = <$mem_name*.def>;
$name_def_file = $temp1[0];
chdir "$ENV{PWD}";



$def_file = $def_files[0]; print "Input DEF file : $def_file\n";

open DEF1,"$def_file" or die "Unable to open the def file $def_file for the MACRO $mem_name\n";
$found_spl_nets_section = 0;$found_end_spl_nets_section = 0;
while(<DEF1>) {

if(/SPECIALNETS/ ) {

$found_spl_nets_section = 1;
$found_spl_net = 0;
}

if(/END\s+SPECIALNETS/ ) {

$found_end_spl_nets_section = 1;

}

if($found_spl_nets_section == 1 && $found_end_spl_nets_section == 0 && /^\s*\-/) {
chomp;split;$spl_net_name = $_[1] ;$found_spl_net = 1;
}

if($found_spl_net == 1 && /ROUTED/ && !(/^\s*\-/)) {chomp;split;$layers{$spl_net_name}{$_[2]} = 1;}
if($found_spl_net == 1 && /NEW/ && !(/^\s*\-/)) {chomp;split;$layers{$spl_net_name}{$_[1]} = 1;}



}

@a = keys %layers ;

for ($i =0;$i<@a;$i++) {

@b = sort keys %{$layers{$a[$i]}} ;
$last = @b -1 ;
$top_layer{$a[$i]} = $b[$last];

}


close DEF1 ;


open DEF , "$def_file" or die "Unable to open the def file $def_file for the MACRO $mem_name\n";
$started_pins_section = 0;$finished_pins_section = 0;
while(<DEF>) {

######################################## Finding top most metal layer #######################################


######################################## Finding top most metal layer #######################################


if(/PINS/) { $started_pins_section = 1;$finished_pins_section = 0; }
if(/END PINS/) { $finished_pins_section = 1; }

if($started_pins_section == 1 && !(/.extra/) && /^\s*\-/ && /NET/ && $finished_pins_section == 0) { $found_one_pin = 1; chomp;$line_saved = $_;}

if(/USE\s+POWER/ && $started_pins_section == 1 && $found_one_pin == 1 && $finished_pins_section == 0) {
@words = split(" ",$line_saved) ;$pin_net{$words[1]} = $words[4];$net_supply{$words[4]} = "POWER";$found_one_pin = 0;
if(defined($debug)) {
print "@words,saved_line=$line_saved,POWERPIN=$pin_net{$words[1]},POWERNET=$net_supply{$words[4]}\n";
}
} 
if(/USE\s+GROUND/ && $started_pins_section == 1 && $found_one_pin == 1 && $finished_pins_section == 0) {
@words = split(" ",$line_saved) ;$pin_net{$words[1]} = $words[4];$net_supply{$words[4]} = "GROUND";$found_one_pin = 0;
if(defined($debug)) {
print "@words,saved_line=$line_saved,GNDPIN=$pin_net{$words[1]},GNDNET=$net_supply{$words[4]}\n";
}
} 
}
$pin_domain_connectivity = "" ;
foreach $pin ( keys %pin_net ) {
if(defined($debug)) {
print "PIN DOMAIN CONNECTIVITY = $pin_domain_connectivity.$pin:$pin_net{$pin}:$net_supply{$pin}:$top_layer{$pin_net{$pin}} \n";
}
$pin_domain_connectivity = $pin_domain_connectivity.$pin.":".$pin_net{$pin}.":".$net_supply{$pin}.":".$top_layer{$pin_net{$pin}}."," ;
if(defined($debug)) {
print "pindomain conectivity $pin_domain_connectivity\n";
}
}
#chop($pin_domain_connectivity);
#print " $pin_domain_connectivity\n";
@temp = sort keys %layers ;
$last = @temp - 1 ;
#$top_layer = $temp[$last]; 

#print "perl makepin.pl -pinCount 1 -outputFilePrefix new -onlyTopMetalPins -topMetal $top_metal_layer -defFile $def_file -pinDomainConnectivity $pin_domain_connectivity\n";
#system("perl makepin.pl -pinCount 1 -outputFilePrefix new -onlyTopMetalPins -topMetal $top_metal_layer -defFile $def_file -pinDomainConnectivity $pin_domain_connectivity");
$pincount=0;
$outputFilePrefix="new";
$onlyTopMetalPins=1;
print "makepin\($pincount,$outputFilePrefix,$onlyTopMetalPins,$top_metal_layer,$def_file,$pin_domain_connectivity\)\;\n";
makepin($pincount,$outputFilePrefix,$onlyTopMetalPins,$top_metal_layer,$def_file,$pin_domain_connectivity);
#print "system\(\"mv new\.pin\.def $cmmOutDir\/$mem_name/\"\)\;\n";
system("mkdir -p $cmmOutDir/$mem_name");

@lef_files = <$gds2def_dir/$mem_name*lef> ;
@pratio_files = <$gds2def_dir/$mem_name*pratio> ;
for($i = 0;$i < @lef_files ;$i++ ) {
system("cp $lef_files[$i] $cmmOutDir/$mem_name/");
}
system("cp $pratio_files[0] $cmmOutDir/$mem_name/");

$new_data = `cat  new.pin.def`;


open INPUT, "$def_file";

@contents =  <INPUT> ;

close INPUT;
if($def_file =~ /_adsgds/) {
open OUTPUT , ">$cmmOutDir/$mem_name/$mem_name\_adsgds.def" ;
} else {
open OUTPUT , ">$cmmOutDir/$mem_name/$mem_name.def" ;
}
for ($i = 0;$i<@contents ;$i++) {

if($contents[$i] =~ /END\s+PINS/) { print OUTPUT "$new_data\nEND PINS\n";} else {print OUTPUT "$contents[$i]" ;}

}

close OUTPUT;

if(defined($debug)) {
system("mv new.pin.def $cmmOutDir/$mem_name/");
system("mv new.ploc $cmmOutDir/$mem_name/");
system("mv new.mark $cmmOutDir/$mem_name/");
}
else {
system ("rm -rf new.pin.def");
system ("rm -rf new.ploc");
system ("rm -rf new.mark");
}
}

}

close(MEM_LIST);

sub makepin {
our ($pinCount,$outFile,$onlyPinsOnTopMetalLayer,$topMetal,$defFile,$pinDomString)=@_;
#use strict;
#use Getopt::Long;

#my $result;
#my $defFile;
#my $pinDomString;
our $pinCount = 0 if(!defined($pinCount));
our $onlyBdyPins = 0;
#our $onlyPinsOnTopMetalLayer = 0 if(!defined($onlyPinsOnTopMetalLayer));
#print "$onlyPinsOnTopMetalLayer\n";
#our $topMetal=0 if(!defined($topMetal));
our $pinX1 = 0;
our $pinY1 = 0;
our $pinX2 = 0;
our $pinY2 = 0;
our $lineDir = 0;


#$result = GetOptions (
#    "defFile=s" => \$defFile,
#    "outputFilePrefix=s" => \$outFile,
#    "topMetal=s" => \$topMetal,	
#    "onlyBoundaryPins" => \$onlyBdyPins,
#    "onlyTopMetalPins" => \$onlyPinsOnTopMetalLayer,
#    "pinDomainConnectivity=s" => \$pinDomString, 	
#    "pinX1=s" => \$pinX1, 	
#    "pinY1=s" => \$pinY1, 	
#    "pinX2=s" => \$pinX2, 	
#    "pinY2=s" => \$pinY2, 	
#    "pinCount=s" => \$pinCount, 	
#    "help" => \$help,
#    "h" => \$help
#);
    

if ($help) {
    #user has requested for usage information
    printUsage();
    exit;
} elsif (! defined $defFile) {
    print "\nIncorrect usage\n";
    printUsage();
    exit;	
}

#################################################################

our $defUnit = 1000;

$pinX1 = $pinX1 * $defUnit;
$pinY1 = $pinY1 * $defUnit;
$pinX2 = $pinX2 * $defUnit;
$pinY2 = $pinY2 * $defUnit;

if ($pinX1 != 0 || $pinY1 != 0 || $pinX2 != 0 || $pinY2 != 0) {
    if ($pinX1 > $pinX2 || $pinY1 > $pinY2) {
	print "Illegal pin region coordinates.\n";
	printUsage();
	exit;
    } elsif ($pinX1 == $pinX2) {
	$lineDir = 2;	# for vertical
    } elsif ($pinY1 == $pinY2) {
	$lineDir = 1;	# for horizontal
    } elsif ($pinX2 - $pinX1 < $pinY2 - $pinY1) {
	$pinX1 = ($pinX1 + $pinX2) / 2;
	$pinX2 = $pinX1;
	$lineDir = 2;	# for vertical
    } else {
	$pinY1 = ($pinY1 + $pinY2) / 2;
	$pinY2 = $pinY1;
	$lineDir = 1;	# for horizontal
    }
}

#print "dir=$lineDir pinX1=$pinX1 pinY1=$pinY1 pinX2=$pinX2 pinY2=$pinY2\n\n";

if ($defFile =~ /\.gz/) {
    print "\n\nDef file is in gzip format. Unzipping onto tempFile\n\n";
    system ("gunzip -c $defFile >! tempFile");
    $defFile = "tempFile";
}


our $metalSuffix = "METAL"; 

if ($topMetal =~ /^(\S+)(\d+)$/) {

    $metalSuffix = $1;
    $topMetal = $2;
}

print "Start processing the def file $defFile\n\n";

our $x1;
our $y1;
our $x2;
our $y2; 

our %pinLocs;
our %domainPinMap;
our $pinName;
our $domainName;
our $domainFound = 0;
our $metalLayer;
our $metalLine;
our $startStr;
our $parseLine;
our $signalType = "";
our $pinsFromLayer = 0;
our %vias = ();
our $via;
our $metalInVia;
our $viaDef;
our @viaLines;
our $i;
our %domainSupplyMap ;

our @words_new ;
#defines the die size
our $dieX1 = 0;
our $dieY1 = 0;
our $dieX2 = 1000000000000;
our $dieY2 = 1000000000000;
our %domainTopLayerMap;
our @words = split (",", $pinDomString);

our $index = 0;
our $line_details ;
our @temp_split;
our $metalLayer_full;
for($i = 0;$i<@words;$i++) {
@words_new = split(/:/,$words[$i]); 
    $domainPinMap{$words_new[0]}  = $words_new[1];
    $domainSupplyMap{$words_new[0]}  = $words_new[2];	
    $domainTopLayerMap{$words_new[0]}  = $words_new[3];
}


if ($onlyPinsOnTopMetalLayer == 1) {
    $pinsFromLayer = $topMetal;
}

print "topMetal=$topMetal onlyBdyPins=$onlyBdyPins ";
print "pinsFromLayer=$pinsFromLayer\n\n";

open (DEF, "<$defFile");
open (OUT, ">$outFile.pin.def");
open (PLOC, ">$outFile.ploc");
open (MARK, ">$outFile.mark");

while (<DEF>)
{

    chomp;
    s/^\s*//;
    s/\s*$//;

    if (/UNITS\s*DISTANCE\s*MICRONS\s*(\d+)\s*;\s*$/) {
	if ($lineDir != 0) {
	    $pinX1 = $pinX1 / $defUnit;
	    $pinY1 = $pinY1 / $defUnit;
	    $pinX2 = $pinX2 / $defUnit;
	    $pinY2 = $pinY2 / $defUnit;
	}
	$defUnit = $1;
	print "$defUnit\n";
	if ($lineDir != 0) {
	    $pinX1 = $pinX1 * $defUnit;
	    $pinY1 = $pinY1 * $defUnit;
	    $pinX2 = $pinX2 * $defUnit;
	    $pinY2 = $pinY2 * $defUnit;
	}
	next;
    } elsif (/DIEAREA\s*\(\s*([^ ]*)\s*([^ ]*)\s*\)\s*\(\s*([^ ]*)\s*([^ ]*)\s*\)\s*;\s*$/) {
	$dieX1 = $1;
	$dieY1 = $2;
	$dieX2 = $3;
	$dieY2 = $4;
	print "DIEAREA ( $dieX1 $dieY1 $dieX2 $dieY2 )\n\n";
	next;
    } elsif (/^\s*VIAS\s*\d+\s*;\s*$/) {
	#vias section	
	while ( <DEF> ) {
	    chomp;
	    s/^\s*//;
	    s/\s*$//;
	    last if (/^\s*END\s+VIAS\s*$/);	

	    if (/^\s*-\s+([^ ]+)/) {
		#start of a via definition
		$via = $1;
		#get the complete via drfinition and then do processing
		$viaDef = $_;
		while ( <DEF> ) {
		    chomp;
		    s/^\s*//;
		    s/\s*$//;
			
		    next if (/^#/ || /^\s*$/);
		    $viaDef = $viaDef." "."$_";	
		    last if (/\s*;\s*/);
		}

		@viaLines = split(/\+/, $viaDef); 
		foreach my $line (@viaLines) {	
		    if ($line =~ /$metalSuffix(\d+)\s+\(\s+([^ ]+)\s+([^ ]+)\s+\)\s+\(\s+([^ ]+)\s+([^ ]+)\s+\)\s*;*\s*$/) {
			$metalInVia = $1;
			next if ( $metalInVia != $topMetal );
			$vias{$via}{X1} = $2; 
			$vias{$via}{Y1} = $3;
			$vias{$via}{X2} = $4;
			$vias{$via}{Y2} = $5;
			$vias{$via}{XWIDTH} = $4-$2;
			$vias{$via}{YWIDTH} = $5-$3;
			$vias{$via}{METAL} = $topMetal;
		    }
		}
		next;
	    }
 	    if (/$metalSuffix(\d+)\s+\(\s+([^ ]+)\s+([^ ]+)\s+\)\s+\(\s+([^ ]+)\s+([^ ]+)\s+\)\s*;*\s*$/) {
		$metalInVia = $1;
		next if ( $metalInVia != $topMetal );
		$vias{$via}{X1} = $2;
		$vias{$via}{Y1} = $3;
		$vias{$via}{X2} = $4;
		$vias{$via}{Y2} = $5;	
		$vias{$via}{XWIDTH} = $4-$2;
		$vias{$via}{YWIDTH} = $5-$3;
		$vias{$via}{METAL} = $metalInVia;
	    }
	}
	next;	
    } elsif (/^\s*(\S*NETS)\s*\d*\s*;\s*$/) {
	$startStr = $1;
	print "Parsing the $startStr section in Def\n";
	#have entered the NETS/Special nets section
	$domainFound = 0;
	while (<DEF>) {
	    last if (/END\s*$startStr/);
	    if (/^\s*\-/) {  
	    $line_details = $_;
		@temp_split = split(" ",$line_details);
		$domainName = $temp_split[1]; 
		if(defined($debug)) {print "DOMAIN NAME --> $domainName\n";}
		if (exists $domainPinMap{$domainName}) {
		    $pinName = $domainPinMap{$domainName};
		    $signalType = $domainSupplyMap{$domainName};
		    if(defined($debug)) {
		    print "PIN NAME --> $pinName,SIGNAL TYPE --> $signalType\n";  
		    }
		    $domainFound = 1;
		}
		next ;
		}
	     
	    next if ($domainFound == 0);
	    $metalLine = 0;
	    if (/\s*$metalSuffix(\d*)\s*(.*)\s*$/) {
		$metalLayer = $1; $metalLayer_full = $metalSuffix.$1 ; 
		$parseLine = $2;
		$metalLine = 1;	
		print "METAL_LINE --> $metalLine\nPARSE_LINE --> $parseLine\n" if(defined($debug));
	    }
	    if (/;\s*$/) {
		$domainFound = 0;
	    }			
	    next if ($metalLine == 0);
	    
	    	    next if ($pinsFromLayer > 0 && $metalLayer != $pinsFromLayer);
	    #print OUT "\n\n\n$_\n\n"; 
	   
	    if ($onlyBdyPins == 1) {

		addPinsOnBoundary($parseLine, $pinName, $domainName,
		    $metalLayer, $signalType,
		    $dieX1, $dieY1, $dieX2, $dieY2);
	    } elsif ($topMetal <= 0 || $metalLayer == $topMetal) {
#print "$parseLine $metalLayer\n";
		if(defined($debug)) {
		print "assignTopMetalAsPins($parseLine, $pinName, $domainName,$metalLayer, $signalType, $topMetal, %vias)\n";
		}
		assignTopMetalAsPins($parseLine, $pinName, $domainName,
		    $metalLayer, $signalType, $topMetal, \%vias);
		#will not come here if onlyBoundaryPins is set
		#addPins($parseLine, $pinName, $domainName, $metalLayer,
		    #$signalType, $topMetal, \%vias);
	    }
	
    }
}
}
print "$pinCount pin(s) created.\n";

close (DEF);
close (OUT);
close (PLOC);
close (MARK);
}
#############################################################
#The function handles top level metals
#It models the entire pin as a metal
#and creates a def
#############################################################

sub assignTopMetalAsPins
{

#print "AAAAAAAAAAAA\n";
    my ($parseLine, $pin, $net, $metLayer, $signalType,
    	$topMetal, $viasHashRef,) = @_;
    print "line_received_by_assignTopMetalAsPins --> @_\n" if(defined($debug));
    my $width;
    my $x1;
    my $y1;
    my $x2;
    my $y2;
    my $xwidth;
    my $ywidth;
    my $centreX;
    my $centreY;

#1200 + SHAPE STRIPE ( -858260 -1010520 ) ( -797780 * )

    if ($parseLine =~ /\s*(\d+)\s*.*\s+\(\s*([-\d]\d*)\s+([-\d]\d*)\s*\)\s+\(\s*([^ ]+)\s+([^ ]+)\s*\)\s*;*\s*$/) {
#	print "$parseLine\n";
	#simple plain retangular metal

	$width = $1;
	$x1 = $2;
	$y1 = $3;
	$x2 = $4;
	$y2 = $5;

	if ($y2 =~ /^\s*\*\s*$/) {
	    $y1 = $y1 - ($width/2);
	    $y2 = $y1 + $width;	
	} elsif ($x2 =~  /^\s*\*\s*$/) {
	    $x1 = $x1 - ($width/2);
	    $x2 = $x1 + $width;
	}		

#print "$x1 $y1 $x2 $y2\n";

	$xwidth = $x2 - $x1;
	$ywidth = $y2 - $y1;

	$pinCount++;
	print OUT "- $pin.extra$pinCount + NET $net + SPECIAL + DIRECTION INOUT + USE $signalType\n";
	print OUT "\t+ LAYER $metalSuffix$metLayer ( 0 0 ) ( $xwidth $ywidth )\n";
	print OUT "\t+ PLACED ( $x1 $y1 ) N ;\n";		
	$centreX = $x1 + ($width/2);
	$centreY = $y1 + ($width/2);
#	print "$centreX,$centreY,$width,$defUnit\n";
	$centreX = $centreX/$defUnit;
	$centreY = $centreY/$defUnit;
	print PLOC "V\_$pinCount $centreX $centreY $metalSuffix$metalLayer $signalType\n";
	print MARK "marker add -position $centreX $centreY -color white -size 5\n";

    } elsif ($parseLine =~ /^\s*(\d+)\s*.*\s+\(\s*(\d+)\s+(\d+)\s*\)\s+([^ ]+)\s*;*$/ ) {

	#vias in the VDD NET section
	#return;
	$via = $4;
	$centreX = $2;
	$centreY = $3;
	if (exists $vias{$via} &&
	    $viasHashRef->{$via}{METAL} == $topMetal) {
	    $xwidth = $viasHashRef->{$via}{XWIDTH};
	    $ywidth = $viasHashRef->{$via}{YWIDTH};
	    $x1 = $centreX + $viasHashRef->{$via}{"X1"};
	    $y1 = $centreY + $viasHashRef->{$via}{"Y1"};
	    $pinCount++;
	    print OUT "- $pin.extra$pinCount + NET $net + SPECIAL + DIRECTION INOUT + USE $signalType\n";
	    print OUT "\t+ LAYER $metalSuffix$metLayer ( 0 0 ) ( $xwidth $ywidth )\n";
	    print OUT "\t+ PLACED ( $x1 $y1 ) N ;\n";
	    $centreX = $x1 + ($xwidth/2);
	    $centreY = $y1 + ($ywidth/2);
	    $centreX = $centreX/$defUnit;
	    $centreY = $centreY/$defUnit;
	    print PLOC "V\_$pinCount $centreX $centreY $metalSuffix$metalLayer $signalType\n";
	    print MARK "marker add -position $centreX $centreY -color white -size 5\n";
	}
    }
}

#################################################################

#Pins would be added along the longest axis only for a length of 2u
#The smaller axis would be 

sub addPins
{
    my ($parseLine, $pin, $net, $metLayer, $signalType,
    	$topMetal, $viasHashRef) = @_;

    my $width; #routed meatl width
    my $x1;
    my $x2;
    my $y1;
    my $y2;
    my $deltaX;
    my $deltaY;	
    my $pinWidth; # width of pin to be routed
    my $xwidth;
    my $ywidth;
    my $x;
    my $y;
    my $step = 20*$defUnit;	
    my $centreX;
    my $centreY;	
    my $via;	

    if ($parseLine =~ /\s*(\d+)\s*.*\s+\(\s*([-\d]\d*)\s+([-\d]\d*)\s*\)\s+\(\s*([^ ]+)\s+([^ ]+)\s*\)\s*;*\s*$/) {

	#simple plain retangular metal 
	$width = $1;
	$x1 = $2;
	$y1 = $3;
	$x2 = $4;
	$y2 = $5;

	if ($y2 =~ /^\s*\*\s*$/) {
	    $y1 = $y1 - ($width/2);
	    $y2 = $y1 + $width;	
	} elsif ($x2 =~  /^\s*\*\s*$/) {
	    $x1 = $x1 - ($width/2);
	    $x2 = $x1 + $width;
	}
	$deltaX = $x2 - $x1;
	$deltaY = $y2 - $y1;

	if ($deltaX > $deltaY) {
	    $x = 0;
	    $y = 0;
	    #along x axis - horizontal
	    while ($x < $deltaX) {
		$xwidth = $defUnit;
		$ywidth = $deltaY; 
		if (($x1+$xwidth) > $x2) {
		    #pin exceeds the metal location.
		    $xwidth = $x2-$x1;
		}
		#x axis is longer
		$pinCount++;
		print OUT "- $pin.extra$pinCount + NET $net + SPECIAL + DIRECTION INOUT + USE $signalType\n";
		print OUT "\t+ LAYER $metalSuffix$metalLayer ( 0 0 ) ( $xwidth $ywidth )\n";
		print OUT "\t+ PLACED ( $x1 $y1 ) N ;\n";
		$centreX = $x1 + ($width/2);
		$centreY = $y1 + ($width/2);
		$centreX = $centreX/$defUnit;
		$centreY = $centreY/$defUnit;
		print PLOC "V\_$pinCount $centreX $centreY $metalSuffix$metalLayer $signalType\n";
		print MARK "marker add -position $centreX $centreY -color white -size 5\n";
		$x = $x + $step;
		$x1 = $x1+ $step;
	    }
	    $x1 = $x2 - $defUnit;
	    $y1 = $y2 - $ywidth;

	    $pinCount++;
	    print OUT "- $pin.extra$pinCount + NET $net + SPECIAL + DIRECTION INOUT + USE $signalType\n";
	    print OUT "\t+ LAYER $metalSuffix$metalLayer ( 0 0 ) ( $xwidth $ywidth )\n";
	    print OUT "\t+ PLACED ( $x1 $y1 ) N ;\n"; 
	    $centreX = $x1 + ($width/2);
	    $centreY = $y1 + ($width/2);
	    $centreX = $centreX/$defUnit;
	    $centreY = $centreY/$defUnit;
	    print PLOC "V\_$pinCount $centreX $centreY $metalSuffix$metalLayer $signalType\n";
	    print MARK "marker add -position $centreX $centreY -color white -size 5\n";
	} else {
	    $x = 0;
	    $y = 0;
	    #along y axis - vertical 
  
	    while ($y < $deltaY) {
		$xwidth = $deltaX;
		$ywidth = $defUnit; 
		if (($y1+$ywidth) > $y2) {
		    #pin exceeds the metal location.
		    $ywidth = $y2-$y1;
		}
		#x axis is longer
		$pinCount++;
		print OUT "- $pin.extra$pinCount + NET $net + SPECIAL + DIRECTION INOUT + USE $signalType\n";
		print OUT "\t+ LAYER $metalSuffix$metalLayer ( 0 0 ) ( $xwidth $ywidth )\n";
		print OUT "\t+ PLACED ( $x1 $y1 ) N ;\n";
		$centreX = $x1 + ($width/2);
		$centreY = $y1 + ($width/2);
		$centreX = $centreX/$defUnit;
		$centreY = $centreY/$defUnit;
		print PLOC "V\_$pinCount $centreX $centreY $metalSuffix$metalLayer $signalType\n";
		print MARK "marker add -position $centreX $centreY -color white -size 5\n";
		$y = $y + $step;
		$y1 = $y1+$step;
	    }
	    $x1 = $x2 - $xwidth;
	    $y1 = $y2 - $defUnit;#defUnit is the length of pin
	    $pinCount++;
	    print OUT "- $pin.extra$pinCount + NET $net + SPECIAL + DIRECTION INOUT + USE $signalType\n";
	    print OUT "\t+ LAYER $metalSuffix$metLayer ( 0 0 ) ( $xwidth $ywidth )\n";
	    print OUT "\t+ PLACED ( $x1 $y1 ) N ;\n";
	    $centreX = $x1 + ($width/2);
	    $centreY = $y1 + ($width/2);
	    $centreX = $centreX/$defUnit;
	    $centreY = $centreY/$defUnit;
	    print PLOC "V\_$pinCount $centreX $centreY $metalSuffix$metalLayer $signalType\n";
	    print MARK "marker add -position $centreX $centreY -color white -size 5\n";
	}
    } elsif ($parseLine =~ /^\s*(\d+)\s*.*\s+\(\s*(\d+)\s+(\d+)\s*\)\s+([^ ]+)\s*;*$/ ) {

	#vias in the VDD NET section		
	$via = $4;
	$centreX  = $2;
	$centreY  = $3;	
	if (exists $vias{$via} &&
	    $viasHashRef->{$via}{METAL} == $topMetal) {
	    $xwidth = $viasHashRef->{$via}{XWIDTH};
	    $ywidth = $viasHashRef->{$via}{YWIDTH};

	    $x1 = $centreX + $viasHashRef->{$via}{"X1"};
	    $y1 = $centreY + $viasHashRef->{$via}{"Y1"};
	    $pinCount++;
	    print OUT "- $pin.extra$pinCount + NET $net + SPECIAL + DIRECTION INOUT + USE $signalType\n";
	    print OUT "\t+ LAYER $metalSuffix$metLayer ( 0 0 ) ( $xwidth $ywidth )\n";
	    print OUT "\t+ PLACED ( $x1 $y1 ) N ;\n";	
	    $centreX = $centreX/$defUnit;
	    $centreY = $centreY/$defUnit;
	    print PLOC "V\_$pinCount $centreX $centreY $metalSuffix$metalLayer $signalType\n";
	    print MARK "marker add -position $centreX $centreY -color white -size 5\n";
	}
    }	
}


sub addPinsOnBoundary
{
    my ($parseLine,  $pin, $net, $metLayer, $signalType,
    	$dieX1, $dieY1, $dieX2, $dieY2) = @_;

    my $width;
    my $x1;
    my $x2;
    my $y1;
    my $y2;
    my $deltaX;
    my $deltaY;
    my $pinX;
    my $pinY;
    my $centreX;
    my $centreY;

    my $step = 20*$defUnit;

#280 + SHAPE STRIPE ( 369040 -481500 ) ( * -480990 )

    if ($parseLine =~ /\s*(\d+)\s*.*\s+\(\s*([-\d]\d*)\s+([-\d]\d*)\s*\)\s+\(\s*([^ ]+)\s+([^ ]+)\s*\)\s*;*\s*$/) {

	$width = $1;
	$x1 = $2;
	$y1 = $3;
	$x2 = $4;
	$y2 = $5;

	if ($y2 =~ /^\s*\*\s*$/) {
	    $y1 = $y1 - ($width/2);
	    $y2 = $y1 + $width;	
	} elsif ($x2 =~ /^\s*\*\s*$/) {
	    $x1 = $x1 - ($width/2);
	    $x2 = $x1 + $width;
	}
	$deltaX = $x2 - $x1;
	$deltaY = $y2 - $y1; 

#print "w$width $x1 $y1 $x2 $y2\n";
#print "OK\n" if ($width == $deltaX || $width == $deltaY);

	if ($lineDir == 1) {
	    if ($x1 <= $pinX2 && $x2 >= $pinX1 &&
	    	$y1 <= $pinY1 && $y2 >= $pinY1) {
		$pinX = $x1;
		$pinY = $pinY1 - 500 / 2;
		$pinCount++;
		print OUT "- $pin.extra$pinCount + NET $net + SPECIAL + DIRECTION INOUT + USE $signalType\n";
		print OUT "\t+ LAYER $metalSuffix$metLayer ( 0 0 ) ( $deltaX 500 )\n";
		print OUT "\t+ PLACED ( $pinX $pinY ) N ;\n";	
		$centreX = ($x1 + $x2) / 2;
		$centreY = $pinY1;
		$centreX = $centreX/$defUnit;
		$centreY = $centreY/$defUnit;
		print PLOC "V\_$pinCount $centreX $centreY $metalSuffix$metalLayer $signalType\n";
		print MARK "marker add -position $centreX $centreY -color white -size 5\n";
	    }
	    return;
	} elsif ($lineDir == 2) {
	    if ($y1 <= $pinY2 && $y2 >= $pinY1 &&
	    	$x1 <= $pinX1 && $x2 >= $pinX1) {
		$pinX = $pinX1 - 500 / 2;
		$pinY = $y1;
		$pinCount++;
		print OUT "- $pin.extra$pinCount + NET $net + SPECIAL + DIRECTION INOUT + USE $signalType\n";
		print OUT "\t+ LAYER $metalSuffix$metLayer ( 0 0 ) ( 500 $deltaY )\n";
		print OUT "\t+ PLACED ( $pinX $pinY ) N ;\n";	
		$centreX = $pinX1;
		$centreY = ($y1 + $y2) / 2;
		$centreX = $centreX/$defUnit;
		$centreY = $centreY/$defUnit;
		print PLOC "V\_$pinCount $centreX $centreY $metalSuffix$metalLayer $signalType\n";
		print MARK "marker add -position $centreX $centreY -color white -size 5\n";
	    }
	    return;
	} elsif ($x1 > $dieX1 && $x2 < $dieX2 &&
	    $y1 > $dieY1 && $y2 < $dieY2) {
#print "an internal route\n";
	    return;
	} 		
 	#if a metal tocuhes both x and y boundary of the subchip
	elsif(($x1 <= $dieX1 && $y1 <= $dieY1) ||
	    ($x1 <= $dieX1 && $y2 >= $dieY2) ||
	    ($x2 >= $dieX2 && $y1 <= $dieY1) ||
	    ($x2 >= $dieX2 && $y2 >= $dieY2)) {
	    #touches any two sides (x, y pair) of the chip
	    #call the addPins function;
#print "at corner, call addPins\n";
	    addPins($parseLine, $pin, $net, $metLayer, $signalType);
	    return;
	}
	#cases of pins touching one side of the subchip only

	if ($x1 <= $dieX1 && $x2 < $dieX2 &&
	    $deltaY > $step && $deltaY >= $deltaX ) {
#print "left, call addPins\n";
	    addPins($parseLine, $pin, $net, $metLayer, $signalType);
	    return;
	}
	if ($x2 >= $dieX2 && $x1 > $dieX1 &&
	    $deltaY > $step && $deltaY >= $deltaX ) {
#print "right, call addPins\n";
	    addPins($parseLine, $pin, $net, $metLayer, $signalType);
	    return;
	}
	if ($y1 <= $dieY1 && $y2 < $dieY2 &&
	    $deltaX > $step && $deltaX >= $deltaY) {
#print "bottom, call addPins\n";
	    addPins($parseLine, $pin, $net, $metLayer, $signalType);
	    return;		
	}
	if ($y2 >= $dieY2 && $y1 > $dieY1 &&
	    $deltaX > $step && $deltaX >= $deltaY) {
#print "top, call addPins\n";
	    addPins($parseLine, $pin, $net, $metLayer, $signalType);
	    return;		
	}

#print "attach pins at the boundary\n";
	if ($x1 <= $dieX1) {
	    $pinX = $dieX1;
	    $pinY = $y1;
	    $pinCount++;
	    print OUT "- $pin.extra$pinCount + NET $net + SPECIAL + DIRECTION INOUT + USE $signalType\n";
	    print OUT "\t+ LAYER $metalSuffix$metLayer ( 0 0 ) ( 500 $deltaY )\n";
	    print OUT "\t+ PLACED ( $pinX $pinY ) N ;\n";	
	    $centreX = $dieX1 + 500 / 2;
	    $centreY = ($y1 + $y2) / 2;
	    $centreX = $centreX/$defUnit;
	    $centreY = $centreY/$defUnit;
	    print PLOC "V\_$pinCount $centreX $centreY $metalSuffix$metalLayer $signalType\n";
	    print MARK "marker add -position $centreX $centreY -color white -size 5\n";
	} 
			
	if ($y1 <= $dieY1) {

	    $pinX = $x1;
	    $pinY = $dieY1;
	    $pinCount++;
	    print OUT "- $pin.extra$pinCount + NET $net + SPECIAL + DIRECTION INOUT + USE $signalType\n";
	    print OUT "\t+ LAYER $metalSuffix$metLayer ( 0 0 ) ( $deltaX 500 )\n";
	    print OUT "\t+ PLACED ( $pinX $pinY ) N ;\n";	
	    $centreX = ($x1 + $x2) / 2;
	    $centreY = $dieY1 + 500 / 2;
	    $centreX = $centreX/$defUnit;
	    $centreY = $centreY/$defUnit;
	    print PLOC "V\_$pinCount $centreX $centreY $metalSuffix$metalLayer $signalType\n";
	    print MARK "marker add -position $centreX $centreY -color white -size 5\n";
	    #dont do anything
	} 

	if ($x2 >= $dieX2) {
	    $pinX = $dieX2 - 500;
	    $pinY = $y1;
	    $pinCount++;
	    print OUT "- $pin.extra$pinCount + NET $net + SPECIAL + DIRECTION INOUT + USE $signalType\n";
	    print OUT "\t+ LAYER $metalSuffix$metLayer ( 0 0 ) ( 500 $deltaY )\n";
	    print OUT "\t+ PLACED ( $pinX $pinY ) N ;\n";	
	    $centreX = $dieX2 - 500 / 2;
	    $centreY = ($y1 + $y2) / 2;
	    $centreX = $centreX/$defUnit;
	    $centreY = $centreY/$defUnit;
	    print PLOC "V\_$pinCount $centreX $centreY $metalSuffix$metalLayer $signalType\n";
	    print MARK "marker add -position $centreX $centreY -color white -size 5\n";
	} 
	if ($y2 >= $dieY2) {
	    $pinX = $x1;
	    $pinY = $dieY2 - 500 ;
	    $pinCount++;
	    print OUT "- $pin.extra$pinCount + NET $net + SPECIAL + DIRECTION INOUT + USE $signalType\n";
	    print OUT "\t+ LAYER $metalSuffix$metLayer ( 0 0 ) ( $deltaX 500 )\n";
	    print OUT "\t+ PLACED ( $pinX $pinY ) N ;\n";	
	    $centreX = ($x1 + $x2) / 2;
	    $centreY = $dieY2 - 500 / 2;
	    $centreX = $centreX/$defUnit;
	    $centreY = $centreY/$defUnit;
	    print PLOC "V\_$pinCount $centreX $centreY $metalSuffix$metalLayer $signalType\n";
	    print MARK "marker add -position $centreX $centreY -color white -size 5\n";
	}
    }
    return;	
}

#sub printUsage
#{
#	print "USAGE :: \n\
#perl makePin.pl <switches>
#-defFile  		<design/subchip def file>
#
#-outputFilePrefix 	<Prefix for output file name
#			outputFilePrefix.ploc    -> pins in ploc format
#			outputFilePrefix.pin.def-> pins in def format>
#
#-pinDomainConnectivity  <Net1:Pin1:Net2:Pin2>
#
#-onlyBoundaryPins       <option used if pins need to be added 
#			to boundary only and not on the top 
#			level metal route. Please dont use 
#			this option if hook up could be from top>
#
#-onlyTopMetalPins 	<option for directing the script to
#			generate Pins only on top metal Layer>
#
#-topMetal		<top metal in design>
#
#-pinX1			<min X of the pin region>
#-pinY1			<min Y of the pin region>
#-pinX2			<max X of the pin region>
#-pinY2			<max Y of the pin region>
#-pinCount		<starting pin index>
#
#-help 			<option for listing the switches :-)>
#
#";
#}
