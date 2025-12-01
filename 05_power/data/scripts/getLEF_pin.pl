#!/usr/bin/perl 

$author = "Aveek Sarkar";
$location = ".";
$file = "\/.pl";
$path = "$location"."$file";

$version = "1.0";

$rev_history = "

v 1.0: date: 01.22.2006
       descp: To read through a list of LEF files and output the names and types of pins for a user provided list of cells.


\n";


#-------------------------------------------------------------------

$usage = "$path [-v: version] [-h: help] [-u: usage] -s: <list of cells> -t: <list of lef files>\n";


use Getopt::Std;

getopts("vhus:t:");

if($opt_h) { print "$rev_history\n$author\n$path\n"; exit(0);}
if($opt_v) { print "Latest version of $path = $version\n$author\n"; exit(0);}
if($opt_u) { print "\n\n$usage\n$author\n$path\n"; exit(0);}

#--------------------------------------------------------------------

if( !(($opt_h || $opt_v || $opt_u) || ($opt_s && $opt_t)) ) {
    print "ERROR :: Please refer to usage: $usage\n\n";
    exit(0);
}

$source1 = $opt_s;
$source2 = $opt_t;

if( !(-e $source1) || !(-e $source2) ) {
    print "ABORT !! Please stick to entry format: $usage\n";
    exit(0);
}

open( OUT, ">outFile.txt");
open(IN1, "$source1");
open(IN2, "$source2");

while(<IN1>) {
    chomp;
    split;
    $cellExist{"$_[0]"} = "yes";
}
close(IN1);

format STDOUT =
@<<<<<<<<<<<<<<<<<< @<<<<<<<<<<<< @<<<<<<<<<<<<<<
$pin, $use, $direction
.
    select( STDOUT );

while(<IN2>) {
    chomp;
    split;
    open(LEF, "$_[0]");
    while(<LEF>) {
	chomp;
	split;
	if( /MACRO / ) {
	    $cell = $_[1];
	    $use{"$cell"} = "";
	    $pin{"$cell"} = "";
	    $direction{"$cell"} = "";
	    $use = $direction = "";
	}
	if( / PIN / || /^PIN /) {
	    $pin = $_[1];
	    $pin{"$cell"} = "$pin{\"$cell\"}+"."$_[1]";
	    $use = $direction = "---";
	}
	if( / USE / || /^USE / ) {
	    $use = $_[1];
	}
	if( /DIRECTION / || /^DIRECTION /) {
	    $direction = $_[1];
	}
	if(/END / ) {
	    if( $cellExist{"$cell"} =~ /yes/ && $_[1] =~ /^$pin$/ ) {
		$use{"$cell"} = "$use{\"$cell\"}+"."$use";
		$direction{"$cell"} = "$direction{\"$cell\"}+"."$direction";
	    }
	    if( $cellExist{"$_[1]"} =~ /yes/ && $_[1] =~ /^$cell$/ ) {
		print STDOUT "$cell";

		@pins       = split( /\+/, "$pin{\"$cell\"}");
		@uses       = split( /\+/, "$use{\"$cell\"}");
		@directions = split( /\+/, "$direction{\"$cell\"}");

		$count = $#pins;
		chomp($count);
		$count--;
		print STDOUT " total # of pins = $count";
		for( $i = 0; $i <= $count; $i++ ) {
		    $pin = $pins[$i];
		    $use = $uses[$i];
		    $direction = $directions[$i];
		    write;
		}
		print STDOUT "\n";
	    }
	}
    }
    close( LEF );
}

close(IN2);
close(OUT);


