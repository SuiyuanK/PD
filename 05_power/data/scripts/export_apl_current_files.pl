#!/usr/bin/perl
eval '(exit $?0)' && eval 'exec perl -S $0 ${1+"$@"}'
&& eval 'exec perl -S $0 $argv:q' if 0;

use IO::Zlib;
use warnings;

my $output_dir = $ARGV[0];
my $dmpJobs = $ARGV[1];

open (my $idx, '>', "$output_dir/apache.apl_idx");
open (my $hiergz, '>', "$output_dir/apache.hier.tmp");
open (my $apdvd, '>', "$output_dir/apache.dvd");

my $inst_count = 0;
my %hash;
for (my $i=1; $i <= $dmpJobs; $i++) {
	$folder = ".apache.$i";

	my %inst_hash;
	$imapfile = "$folder/apache.imap.$i";
	open ("imap", '<', $imapfile) or die "connot open file $imapfile\n";
	while ($line_imap = <imap>) {
		chomp($line_imap);
		if ($line_imap =~ /^#/ or $line_imap =~ /^$/) {
		} else {
			@field = split /\s+/, $line_imap;
			if ($hash{$field[0]}) {
			} else {
				$inst_count ++;
				print $hiergz "$inst_count $field[1]\n";
				$hash{$field[0]} = $inst_count;
			}
			$inst_hash{$field[1]} = $field[0];
		}
	}

	$smp_idx_f = "$folder/smp_idx.out";
	open ("smp", '<', $smp_idx_f) or die "Cannot open file $smp_idx_f\n";
	while ($line_smp = <smp>) {
		chomp($line_smp);
		if ($line_smp =~ /^#/ or $line_smp =~ /^$/) {
		} else {
			@arr_smp = split /\s+/, $line_smp;
			if ($arr_smp[1]==-1) {
			} else {
				$old_idx = $arr_smp[0];
				$sample = ($arr_smp[1] + 1);
				print $idx "$hash{$old_idx} $sample\n";
			}
		}
	}

	$dvdfile = "$folder/apache.dvd.$i";
	open ("dvd", '<', $dvdfile) or die "Cannot open file $dvdfile\n";
	while ($line_dvd = <dvd>){
		print $apdvd $line_dvd;
		chomp($line_dvd);
                if ($line_dvd =~ /^#/ or $line_dvd =~ /^$/) {
                } else {
			my ( $inst, $state) = split /\s+/, $line_dvd, 2;
			if (exists $inst_hash{$inst}) {
				delete $inst_hash{$inst};
			}
		}
	}

	my %hash2 = reverse %inst_hash;
	open ("state", '<', "$folder/state.out") or die "Cannot open state file\n";
	while (my $line_state = <state>) {
		last if ! $line_state;
		my ( $in_dx, $state1, $state2, $rem) = split /\t/, $line_state, 4;
		if (exists $hash2{$in_dx}) {
			print $apdvd "$hash2{$in_dx} $state1 $state2\n";
		}
	}

}
close $hiergz;
close $apdvd;
close $idx;

open (my $in, '<', "$output_dir/apache.hier.tmp");
my $hier = IO::Zlib->new("$output_dir/apache.hier.gz", "wb9");
print $hier "#VERSION 1\n";
print $hier "#HIERARCHY NAMEMAP 0\n";
print $hier "#END HIERARCHY NAMEMAP\n\n";
print $hier "#INSTANCE NAMEMAP $inst_count\n";
{
	local $/ = \65536;
	while ( my $chunk = <$in> ) { print $hier $chunk; }
}
print $hier "#END INSTANCE NAMEMAP\n";
close $hier;
close $in;
unlink ("$output_dir/apache.hier.tmp");

print "Success.\n";
