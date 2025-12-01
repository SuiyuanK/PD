# $Revision: 2.1 $
################################################################
# This software is confidential and proprietary information which may only be
# used with an authorized licensing agreement from Apache Design Systems
# In the event of publication, the follow notice is applicable:
# (C) COPYRIGHT 2005 Apache Design Systems
# ALL RIGHTS RESERVED
#
# This entire notice must be reproduced in all copies.
#
#  $RCSfile: hilitepad_dyn.pl
#   $Author: Jerome Toublanc
#     $Date: 26/01/2006
# $Revision: 1.0: Initial version
#
# Abstract: create a tcl file that puts on top of the PG sources Markers which color is depending
#            of the Peak of current going through the sources during the simulations.
#
# Default scale: In Red : Peak > 85% of Max Peak 
#		 Orange : 80%  > Peak > 85%
#		 Yellow : 60%  > Peak > 80%
#		 Green  : 20%  > Peak > 60%
#		 Cyan   : 10%  > Peak > 20%
#		 White  : Peak < 10% Max Peak
#
# Usage in Redhawk:
#  exec hilitepad_dyn.pl
#
# Features:
#
#   Log file: hilitepad_dyn.log
#   Revision 1.1  2006/01/26 Jerome
#   initial check-in
#
#
###############################################################

eval '(exit $?0)' && eval 'exec perl -S $0 ${1+"$@"}'
&& eval 'exec perl -S $0 $argv:q' if 0;
 
$output_tclfile = "hilitepad_dyn.tcl" ;
$output_logfile = "hilitepad_dyn.log" ;
$input_file  	= "./adsRpt/Dynamic/pad.current" ;

$maxPos		= 0;
$maxNeg		= 0;
$maxPosPeak	= 0;
$maxNegPeak	= 0;
$minPosPeak	= 10000;
$minNegPeak	=-10000;
$maxPosPad	= 0;
$maxNegPad	= 0;
$minPosPad	= 0;
$minNegPad	= 0;
$scale		= 0;
$currentPad	= 0;
$i		= 0;

### Read Peak Current Value for each pad
open (file_in,  "<$input_file")  or die "Not able to read the input file: $input_file\nPlease run Dynamic Analysis first!\n";
chop ($_ = <file_in>);

while(<file_in>) {

	chop($_); @Line = split(/\s+/, $_); 
	
	if (@Line ==1) {
		($tmp, $currentPad )= split(/\"/, @Line[0] ) ;
		$maxPos	= 0; $maxNeg	= 0;	$i++;
		push (@listPad, $currentPad) ; 
		}
	if (@Line ==0) {
		if ( $maxPos > $maxPosPeak )			{$maxPosPeak = $maxPos; $maxPosPad= $currentPad;}
		if (($maxPos > 0) && ($maxPos < $minPosPeak))	{$minPosPeak = $maxPos; $minPosPad= $currentPad;}
		if ( $maxNeg < $maxNegPeak )			{$maxNegPeak = $maxNeg; $maxNegPad= $currentPad;}
		if (($maxNeg < 0 ) && ($maxNeg> $minNegPeak))	{$minNegPeak = $maxNeg; $minNegPad= $currentPad;}
		if ( $maxNeg < 0) 				{push (@listValue, $maxNeg);} 
		if ( $maxPos > 0) 				{push (@listValue, $maxPos);}
	}
	do {	chop($_); @Line = split(/\s+/, $_);
		if (($Line[1] < 0) && ($Line[1] < $maxNeg)) 	{ $maxNeg = $Line[1] ; }
		if (($Line[1] > 0) && ($Line[1] > $maxPos)) 	{ $maxPos = $Line[1] ; }
	   } until (@Line == 0 );
	
}
close (file_in);


### Get coordinates of sources from ploc file

$lenght 	= $i; 
$maxValue   	= 0;
$currentPad 	= 0;
$i		= 0;
$color		= 0;
@results 	=();
$scale 		= -$maxNegPeak;  if ($scale <= $maxPosPeak) {$scale = $maxPosPeak;}

open (file_in, 	'./adsRpt/PG.ploc') ;
open (file_out, ">$output_tclfile") or die "Not able to write the output file: $!\n";

print file_out "marker delete -all\n"; 

for($i=0;$i<=4;$i++) { <file_in>; }
while(<file_in>) {
	chop($_); @Line = split(/\s+/, $_);
	for($i=0;$i<=$lenght;$i++) {if ($listPad[$i] eq $Line[0]) {$ind=$i;}}
	
	if  ( abs($listValue[$ind]) > (0.85*$scale))						 {  $color= red 	; }
	if  ((abs($listValue[$ind]) > (0.8*$scale))  && (abs($listValue[$ind]) < (0.85*$scale))) {  $color= orange	; }
	if  ((abs($listValue[$ind]) > (0.6*$scale))  && (abs($listValue[$ind]) < (0.8*$scale)))  {  $color= yellow	; }
	if  ((abs($listValue[$ind]) > (0.2*$scale))  && (abs($listValue[$ind]) < (0.6*$scale)))  {  $color= green	; }
	if  ((abs($listValue[$ind]) > (0.1*$scale))  && (abs($listValue[$ind]) < (0.2*$scale)))	 {  $color= cyan	; }
	if  ( abs($listValue[$ind]) < (0.1*$scale)) 						 {  $color= white	; }
	
	### Get coordinates of max/min positiv peak, and max/min negativ peak for report only					
	if  ( $listValue[$ind] == $minPosPeak ) {$minPosX=$Line[1]; $minPosY=$Line[2];}
	if  ( $listValue[$ind] == $maxPosPeak ) {$maxPosX=$Line[1]; $maxPosY=$Line[2];}
	if  ( $listValue[$ind] == $minNegPeak ) {$minNegX=$Line[1]; $minNegY=$Line[2];}
	if  ( $listValue[$ind] == $maxNegPeak ) {$maxNegX=$Line[1]; $maxNegY=$Line[2];}
	
	### Creation of TCL script to load in RH
	print file_out "\nmarker add  -position $Line[1] $Line[2] -color $color -size 10"; 
	
	### Store all values and coordinates
	if ( $listValue[$ind] >0) { push (@results, "Power   $listValue[$ind] $listPad[$ind] ($Line[1],$Line[2])\n"); }
	else 			  { push (@results, "Ground $listValue[$ind] $listPad[$ind] ($Line[1],$Line[2])\n"); }
	
	}
close (file_in); close (file_out);

### Sort the stored values in log file
open (fileout, ">$output_logfile");
@results =  sort(@results);
foreach $line (@results) { print fileout $line ;}
close (file_out);

### Print main info
print "\nINFO:\n";
print "     - Max Power Peak:  $maxPosPeak  ($maxPosPad @ $maxPosX,$maxPosY) \n";
print "     - Min Power Peak:  $minPosPeak  ($minPosPad @ $minPosX,$minPosY) \n";
print "     - Max Ground Peak: $maxNegPeak  ($maxNegPad @ $maxNegX,$maxNegY)\n";
print "     - Min Ground Peak: $minNegPeak  ($minNegPad @ $minNegX,$minNegY)\n";
print "     - Max for Scaling :  $scale for $lenght PG sources\n";

print "\n-> To colorize the PG sources, just do in RH: \"source $output_tclfile\"";
print "\n-> To remove the markers, just do in RH: \"marker delete -all\"";
print "\n-> The sorted list of PG sources is in '$output_logfile'\n";
