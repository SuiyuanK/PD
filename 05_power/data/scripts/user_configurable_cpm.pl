#!/usr/bin/perl
##########################
#$Revision  :1.2$
#Modified by Uday on 19-04-12 
#Two changes , taken care of ignoring bracket and $last_time = 0ps pushed out of the loop so that time does not get initialized to zero after each user specified  group.
#############################################################################
# Name       : user_configurable_cpm.pl
# Description: Creates a CPM based on the sequence that is input by the user
# $Revision  :  1.0$
# Author     : Mithun K S Rao , email : mithun@apache-da.com
#############################################################################

=head1 NAME

user_configurable_cpm.pl - Creates a CPM based on the sequence that is input by the user

=head1 SYNOPSIS

user_configurable_cpm.pl [options] arguments

Options:  -help, -cpm, -user_file, -o

=head1 DESCRIPTION

B<user_configurable_cpm.pl> Creates a CPM based on the sequence that is input by the user.

=head1 OPTIONS

=item -help

Prints a synopsis and description of program options.

=item -o

Provide the output filename

=item -cpm <pointer to baseline CPM file>

Pointer to the baseline CPM file

=item -user_file  <filename>

Specify the file path which contains the sequence for the output CPM

Output report is stored in the user defined output file or default is: user_configurable_CPM.sp.inc

=head1 EXAMPLE

user_configurable_cpm.pl -CPM PowerModel.sp.inc -user_file sequence.txt

=back

=head1 AUTHOR

Mithun K S Rao , Apache India.

email : mithun@apache-da.com

=head1 COPYRIGHT

COPYRIGHT (c) 2010 Apache Design Solutions. All right reserved.

=cut

## end program documentation

use Getopt::Long;
use Pod::Usage;

my $opt_help='';
my $opt_cpm_file='';
my $opt_output_file= "user_configurable_CPM.sp.inc";
my $opt_sequence_file='';
my %currentval;
# get input options..
GetOptions ('help' =>\$opt_help,
            'cpm=s'=>\$opt_cpm_file,
            'o=s'=>\$opt_output_file,
            'user_file=s'=>\$opt_sequence_file);
            pod2usage (-exitval => 0, -verbose => 1) if $opt_help;

if ($opt_cpm_file)
 {
  $cpmfile= $opt_cpm_file;
 }
else
 {
   print "Baseline CPM file is not available\n";
   exit;
 }
if ($opt_sequence_file)
 {
  $sequencefile= $opt_sequence_file;
 }
else
 {
   print "User driven input file is not available\n";
   exit;
 }


open CPM, "$cpmfile" or die "Cannot open the baseline CPM file $!\n";
open FILE, "$sequencefile" or die "Cannot open the user driven input file $!\n";
open OUTPUT, ">$opt_output_file";

while (<CPM>)
 {
   chomp($_);
   if (/^\#/)
    {
     next
    }

   if ($_ =~ /^\s*$/) 
    {
          next
    }
   if ($_ =~ /^\+\)/ || $_ =~ /.ends/) 
    {
     next
    }
   if ($_ =~ /^I_/) {
      split (/\s+/,$_);
      $groupname = $_[0];
      $groupname =~ s/I_//g;
      $groupname =~ s/_cursig[^\/]*$//g; 
      push @groups, $groupname ;
      $port1 = $_[1];
      $port2 = $_[2];
    } elsif ($_ =~ /^\+/ && $_ !~ /\).*$/) {
      split (/\s+/,$_);
      $time = $_[1];
      $current = $_[2];    
      if ($time =~ /ps/) {
      $currentval{$groupname}{$port1}{$port2}{$time} = $current;
    } else {
      push @lines, $_;
    }
    } else {
      push @lines, $_;
    }
 }

foreach $line (@lines)  {
  print OUTPUT "$line\n";
}

print OUTPUT "\n";

foreach $check_group (@groups) {
$flag{$check_group} = 1;
}
while (<FILE>)
 {
   chomp($_);
   if (/^\#/)
    {
     next
    }
   @array = split (/,/,$_);
 }
  
   foreach $sequence (@array) {
   $sequence =~ s/^\s+//;
   $sequence =~ s/\s+$//;

   if ($sequence =~ /\+/) {
    print "Adding up the current signature for user group $sequence\n";
    @sequence_1 = split (/\+/,$sequence);
    foreach $seq_list (@sequence_1) {
    if ($flag{$seq_list} == 1) {
      foreach $port1 (sort {$a <=> $b} keys %{$currentval{$seq_list}})
       {
        foreach $port2 (sort {$a <=> $b} keys %{$currentval{$seq_list}{$port1}})
         {
           foreach $time (sort {$a <=> $b} keys %{$currentval{$seq_list}{$port1}{$port2}})
           {
             foreach $seq_list (@sequence_1) { 
              $currentval{$sequence}{$port1}{$port2}{$time} += $currentval{$seq_list}{$port1}{$port2}{$time};
             }     
           }
         }
       }
      goto here;  
     } else {
       print "Groupname $seq_list not matching with any of the groups in the input baseline CPM\n";
        exit;
    }
    }
    } elsif ($flag{$sequence} ne 1) {
       print "Groupname $sequence not matching with any of the groups in the input baseline CPM\n";
        exit;
    }
here:  }

$i =0;

print "Writing out current waveform to output file $opt_output_file\n";
foreach $sequence (@array) {
$sequence =~ s/^\s+//;
$sequence =~ s/\s+$//;
  foreach $port1 (sort {$currentval{$sequence}{$a} <=> $currentval{$sequence}{$b}} keys %{$currentval{$sequence}})
       {
           $last_time = "0.000";
        foreach $port2 (sort {$currentval{$sequence}{$port1}{$a} <=> $currentval{$sequence}{$port1}{$b}} keys %{$currentval{$sequence}{$port1}})
         {
           $i = $i+1; 
           print OUTPUT "I_output_cursig$i $port1 $port2 pwl(\n";
           foreach $sequence (@array) {
           $sequence =~ s/^\s+//;
           $sequence =~ s/\s+$//;         
           foreach $time (sort {$a <=> $b} keys %{$currentval{$sequence}{$port1}{$port2}})
            {
              $current_Value = $currentval{$sequence}{$port1}{$port2}{$time};
              	unless ($time==0 && $last_time>$time) 
              	{
	   	$time = $last_time+$time;  
            	$time1 = sprintf("%.3f", $time);  
              	$timeps = $time1."ps";
              	print OUTPUT "+ $timeps  $current_Value\n";}
                }
           $last_time = $last_time+$time;
           }          
           print OUTPUT "+)\n\n";
           }
          }
        goto end;
       }

end: print OUTPUT ".ends\n";
     print "Script Completed\n";

