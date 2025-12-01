# $Revision: 2.3 $
#!/usr/bin/perl -w
#20181123 leo
#use strict;
eval '(exit $?0)' && eval 'exec perl -S $0 ${1+"$@"}' && eval 'exec perl -S $0 $argv:q' if 0;
use Getopt::Std;
getopts('i:');
if ( !defined $opt_i ) {
	print "usage: perl $0 -i adsRpt/aplmmx_validation_current_comparison.rpt \n";
	exit;
};
###	get top cell name
my $cell="adsRpt/cellHierarchy";
my $topcell;
my $line_num=0;
open (CELL, $cell) or die "Can't find $cell";
while (<CELL>) {
	chomp;
	if ( $line_num == 2) {
	$topcell=$_;
#	print "$topcell\n";
	}
	$line_num++;
}
close (CELL);
###	get max OD deltaT
my $od_file=`find adsRpt/CTA/ -name "$topcell\_od.out.gz"`;
if ($od_file ne "") {
	system "gzip -d -f adsRpt/CTA/$topcell\_od.out.gz";
}
else {
	$od_file=`find adsRpt/CTA/ -name "$topcell\_od.out"` ;
	if ($od_file eq "") {
	die "Can't find adsRpt/CTA/$topcell\_od.out file";
	}
#	print "$topcell\n";
}
my $maxdeltaT=`grep -v '#' adsRpt/CTA/$topcell\_od.out | sort -g -k9 -r | head -n 1 | awk '{print \$9}'`;
chomp($maxdeltaT);
	print "max OD deltaT = $maxdeltaT\n";
###

###	get VDD name and voltage
my $power_report="adsPower/power_summary.rpt";
my $flag=0;
my %VDD;
open (POWER_SUM, $power_report) or die "Can't find $power_report";
while (<POWER_SUM>) {
	chomp;
	if ($_ =~ /^\s*$/ ) {next;}
	if ($_ =~ /^For\s+NA\s+domain/ ) {last;}
	if ($_ =~ /^Vdd_domain/) {
	#print "flag = $flag\n";
		$flag=1;next;
	}
	if ($flag == 1 ) {
	#print "flag = $flag\n";
	#print "$_\n";
		my @line=split(' ', $_);
		if ( $_ =~ /\s+\((.*)V\)/ ) {
		#print "$1\n";
		$VDD{$line[0]}=$1;
		}
			#print "$line[0]  $VDD{$line[0]}\n";
	}
	if ($flag == 0 ) {next;}
}
close (POWER_SUM);
###

###	get each VDD domain AVG current and multiply with voltage
open (CUR, "$opt_i");
my $power=0;
my $total_pwr=0;
while (<CUR>) {
	chomp;
	if ($_ =~ /^\s*$/ ) {next;}
	if ($_ =~ /^#/ ) {next;}
	if ($_ =~ /AVG/ ) {
		my @line1=split(' ', $_);
		$line1[4]=~ s/A//g;
		#print "$line1[0] current is $line1[4]\n";
		foreach my $key (keys %VDD) {
			if ($line1[0] =~ /$key/i) {
			$power=$VDD{$key} * $line1[4];
			$total_pwr=$total_pwr+$power;
			#print "power is $VDD{$key} x $line1[4] = $power W \n";
			}
		}
	}
} 
print "Total power is $total_pwr W\n";
print "Use 1/2 cell power for Rth calculation\n";
close (CUR);

#use 1/2 cell power for Rth calculation according to tsmc spec.
open (TRF, ">$topcell.trf") or die "Can't generate $topcell.trf";
print TRF "$topcell" , " " , $maxdeltaT/($total_pwr/2) , "\n";
print "Output thermal resistance file $topcell.trf\n",
close (TRF);

#my $power_report="adsPower/power_summary.rpt";
#my $flag=0;
#my $pwr=0;
#open (POWER_SUM, $power_report) or die "Can't find $power_report";
#while (<POWER_SUM>) {
#	chomp;
#	if ($_ =~ /^\s*$/ ) {next;}
#	if ($_ =~ /^For\s+NA\s+domain/ ) {last;}
#	if ($_ =~ /^Vdd_domain/) {
#	#print "flag = $flag\n";
#		$flag=1;next;
#	}
#	if ($flag == 1 ) {
#	#print "flag = $flag\n";
#		my @line=split(' ', $_);
#		if ($line[2] =~ /\d+/) {
#			$pwr=$pwr+$line[2];
#			print "total power in Watt = $pwr\n";
#		}
#	}
#	if ($flag == 0 ) {next;}
#}
#close (POWER_SUM);
#
#open (POWER,"adsRpt/GDS/$topcell\_od_self_heat_xtor.rpt") or die "Can't find adsRpt/GDS/$topcell\_od_self_heat_xtor.rpt";
#my $total_pwr=0;
#while (<POWER>) {
#	chomp;
#	if ($_ =~ /^\%XTOR/) {
#	my @line=split(/\s+/, $_);
#	$total_pwr=$total_pwr+$line[7];
##	print "$total_pwr\n";
#	}
#}
##	print "total power = $total_pwr\n";
#close (POWER);
#$total_pwr=$total_pwr/1000;
#	print "total power = $total_pwr W\n";
