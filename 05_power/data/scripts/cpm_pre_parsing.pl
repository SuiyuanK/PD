# Rev 13.7

# Rev 13.7 by Prateek Agrawal
# Support for time units for CPM_SPLIT
# Rev 13.6 by Prateek Agrawal
# Support for inc file generation if split CPM is selected for USE_INC_FILE
# Rev 13.5 by Prateek Agrawal
# Check for Average Power section presence 
# Rev 13.4 by Prateek Agrawal
# Changing the split CPM header section to include CPM ports and average current sectioncp#
# Rev 13.3 by Prateek Agrawal
# Adding power coulmn to output
# Rev 13.2 by Prateek
# Minor fix for cpm's without groups for correct output generation
# Rev 13.1 by Prateek
# Mode transition enhancement.

#!/usr/bin/perl
################################################################################################################
# Name       : cpm_pre_parsing.pl
# Description: Adding one CPM after another,Adding one CPM on top of another
# $Revision  : 1.0$
# Author     : Ramesh , email : ramesh.agarwal@ansys.com
# Date 		 : 24-06-2013
################################################################################################################

# (1) quit unless we have the correct number of command-line args
$num_args = $#ARGV + 1;
#if (($num_args != 2) && ($num_args != 1)) {
#  print "\nIncorrect number of command-line args: Please see the usage below or see the manual: ";
#  print "\nUsage	: perl cpm_pre_parsing.pl -Input <>";
 # print "\nExaple	: perl cpm_pre_parsing.pl -Input multiple_activity.Input \n\n";
 # exit;
#}

## Start of program documentaion

=head1 NAME

cpm_pre_parsing.pl -Stiches multiple RedHawk-CPA files into one 

=head1 SYNOPSIS

cpm_pre_parsing.pl [options] arguments

Options :  -Input, -output, -help, -man

=head1 DESCRIPTION

<cpm_pre_parsing.pl> stiches multiple RedHawk-CPA files into one.

  The output file is once complete cpm file : cpm_pre_parsing.rpt

=head1 OPTIONS

=over 

=item -help

prints a synopsis and a description of program options.

=item -Input <Input_file_name>

Specify the file which has all the Inputurations settings.

=item -output <output_file_name>

Specify the output file , Default : "cpm_pre_parsinged.sp"

=item -man

Prints the entire man page

=back

=head1 EXAMPLE

cpm_pre_parsing.pl -Input <Input_file> -output all_cpm.sp

The output file is one complete cpm

=head1 AUTHOR

Ramesh Agarwal , Ansys Apache India

email : ramesh.agarwal@ansys.com

=head1 COPYRIGHT

COPYRIGHT (c) 2013 Apache Design Solutions. All right reserved.

=cut

## end program documentation

use Getopt::Long;
use Pod::Usage;

GetOptions ('help'=>				\$help,
            'input=s'=>			\$Input_file,
			'man'=>					\$man,
			'output=s'=>				\$output,
			'u'=>					\$help,
			'h'=>					\$help);

pod2usage (-exitval => 0, -verbose => 1) if $help;
pod2usage (-exitval => 0, -verbose => 2) if $man;

if($Input_file eq '' )	{
 	printf "%0s\t%10s","Error !! :","Specify Input File\n\n";
 	$help=1;
 	pod2usage (-exitval => 0, -verbose => 1) if $help;
}
if ($output eq '') {
	$output="cpm_pre_parsing.rpt";
} else {
	$output="$output";
}

$x=`date`;
@_=split(" ",$_); ('\s+',$x);
$month="$_[1]";$date=$_[2];$time=$_[3];$year=$_[5];
@_=split(" ",$_); ('\:',$time);
$hr=$_[0];$minute=$_[1];
$log="cpm_pre_parsing".$date.$month.$year."_".$hr."_".$minute.".log";
if (! -d "Log") { system("mkdir Log");}
open LOG_FILE , ">$ENV{PWD}/Log/$log" or die "Cannot write into the file $ENV{PWD}/Log/$log :$!\n\n";
if(-e "$ENV{PWD}/cpm_pre_parsing.log")	{	system("rm -rf $ENV{PWD}/cpm_pre_parsing.log");	}
system("ln -s $ENV{PWD}/Log/$log $ENV{PWD}/cpm_pre_parsing.log");	

#Start Reading the Input Files and generating required database
open ip_file, "$Input_file" or die "\nERROR : Failed to open file $Input_file : $!" ;
print LOG_FILE "###Parsing Input File : $Input_file";
#print LOG_FILE "\n#Input CPM files : " ;
$cnt=0;
while (<ip_file>)	{
	if(($_ !~ /^#/) && ($_ !~ /^$/))	{
	   chomp;@_=split(" ",$_);
	   $cpm{$_[0]}=$_[1];
	   print LOG_FILE "\n#Input CPM file :";
	   print LOG_FILE "\n$_[0] : $_[1]";
	   $cpm_name= $_[0];
	   $cpm_file= $cpm{$_[0]};
	   $cpm_hash;
	   print LOG_FILE "\n###Start Parsing input CPM file $cpm_name ";
	   cpm_info($cpm_name,$cpm{$cpm_name},\%cpm_hash,LOG_FILE);
	   print LOG_FILE "###End Parsing input CPM file $cpm_name \n";
#use Data::Dumper;
#print Dumper (\%cpm_hash);

       if($_[2] =~ /SPLIT_TIME/){
			$create_input_text=1;
			$time_snip=$_[3];
			$time_snip2=$_[4];
			if(!$time_snip2){$time_snip2 = '0ps';}
			cpm_altered_hash($cpm_name,$cpm_file,$time_snip,$time_snip2);
			print_hash_split_cpm_file($cpm_name,$cpm_file,$time_snip,$time_snip2,$unit1,$unit2);#The processing of $time_step is done in cpm_altered_hash sub func. and therafter $time_snip becomes a numerical value
			create_input_text($cpm_name,$time_snip,$time_snip2,$unit1,$unit2);
			$input_files_created[$cnt]= ".input_split_cpm_for_"."$cpm_name".".txt";
			$cnt++;
	    }
	}  
	      
	   
}
#create_input_text() ;#function for creating output input.txt by splitting the specified CPM 
#if ($create_input	
print LOG_FILE "\n###End Parsing Input File \n";

#use Data::Dumper;
#print Dumper (\%cpm_hash);
#use Data::Dumper;
#print Dumper (\%ihash);
# Generating Output report of pre-parsing mode
calculate_average_power(\%ihash,\%cpm_hash,\@input_files_created);
out($output,@input_files_created);
#use Data::Dumper;
#print Dumper (\%ihash);
#use Data::Dumper;
#print Dumper (\%cpm_hash);

# Finish Generating Output report of pre-parsing mode
print  "CPM Details Output file $output Created";
print LOG_FILE  "CPM Details Output file $output Created";
#use Data::Dumper;
#print Dumper (\%cpm_hash);
#Start Doing Sanity Checks in the input CPM   
print LOG_FILE "\n###Start Doing Sanity checks on input CPM files ";
# The following metrics for all the CPM Must be same  :  
# "Time Step" , "Unit" , "No of Current Sources" , "No of Nodes" , "Name of Nodes" , "User Group" -> If present . 
# NOTE: "Start Time" and "End Time"  can vary
@metrics = ("Unit","No of Ports","Name of Ports","Average Power");
foreach $metric (@metrics)	{
	if ($metric =~ /Average Power/){
		foreach$testcase(keys %cpm_hash) {
			$AveragePower=$$cpm_hash{$testcase}{$metric};
			if (!$AveragePower){
				print "\nERROR :$metric is not present for $testcase\n";
				print LOG_FILE "\nERROR :$metric is not present for $testcase\n";
			}
		}
    	}else{
	$flag=0;
	foreach $testcase (keys %cpm_hash) {
		if ($flag ==0) { $old=$cpm_hash{$testcase}{$metric};$flag=1;}	
		else {
			$val=$cpm_hash{$testcase}{$metric};
			if ($old ne $val) { print "\nERROR : $metric $val is not matching for $testcase with $old on other CPM files\n\n" ;
			 print LOG_FILE "\nERROR : $metric $val is not matching for $testcase with $old on other CPM files\n\n" ;
			 exit;
			}
		}
	}
	}
}

print LOG_FILE "\nSanity checks PASSED on all input CPM files";
print LOG_FILE "\n###End Doing Sanity checks on input CPM files \n";


print  "\nSanity checks succesfully PASSED on all input CPM files\n";





#use Data::Dumper;
#print Dumper (\%cpm);
#print Dumper (\%cpm_hash);




# Function to save the cpm information in a hash and all the current signatures of the CPM
# Function to save the cpm information in a hash and all the current signatures of the CPM
sub cpm_info
{		
	($cpm_name,$cpm_file,$cpm_hash,$log) = @_;
	my $read_time;my $t0;my $t1;my $time_step;my $end_time;my $end_time;my $unit;my $no_of_nodes;my @nodes; my $no_of_current_source;my $line_no=0;my $power;my $power_units;
	my $read_usr_group=0;my @user_group;my $group;my $current_sig;my $current_samples=1;
	if (open(cpm_file,$cpm_file)){
		while(<cpm_file>)	{
				#print "$_\n";
			if ($read_time)	{
				chomp;@_=split(" ",$_);;$time=$_[1];$current=$_[2];
				if ($time=~m/(\d+\.\d+)(\S+)/) { $t=$1;$unit=$2;} elsif ($time=~m/(\d+)(\S+)/) {$t=$1;$unit=$2;}
				if ($group) {$$cpm_hash{$cpm_name}{$group}{$current_sig}{$t}=$_[2]} 
				else {$$cpm_hash{$cpm_name}{$current_sig_name}{$t}=$_[2];}
				if ($line_no==0 ) { $t0=$t}
				if ($line_no==1 ) { $t1=$t} 
				if ($line_no==2 ) { 
					$t2=$t ;
					if (!$time_step)	{$time_step=$t2-$t1;}
					$read_time=0; $step=1;
				}
				$line_no++;
			}
			if ($step)	{
				if (($_ !~ /^\+ R/)&&($_ !~ /^\+\)/)) 	{
					chomp;@_=split(" ",$_);$time=$_[1];if ($time=~m/(\d+\.\d+)(\S+)/) { $t=$1;$unit=$2;} elsif ($time=~m/(\d+)(\S+)/) {$t=$1;$unit=$2;}
					if ($group) {$$cpm_hash{$cpm_name}{$group}{$current_sig}{$t}=$_[2]} 
					else {$$cpm_hash{$cpm_name}{$current_sig_name}{$t}=$_[2];} 
					$prev_line=$_; next;	
				}
					#print $prev_line;
					chomp $prev_line;@_=split(" ",$prev_line);$time=$_[1] ;
					if ($time=~m/(\d+\.\d+)(\S+)/) { $end_time=$1;$unit=$2;} elsif ($time=~m/(\d+)(\S+)/) {$end_time=$1;$unit=$2;}
					$step=0;
					#print "\n End Time Detected :$end_time" ;
			}
			if ($read_node)	{
				if($_ =~ /^\+/)	{	chomp;@_=split(" ",$_);shift(@_); $no_of_nodes+=scalar @_;	@nodes=(@nodes,@_);	}
				if ($_ !~ /^\+/)	{$read_node=0};
			}

			if ((/^I/)&&(! $t0))	{  $read_time=1; chomp;@_=split(" ",$_);$port_name = $_[1];
				$current_sig_name= $_[0];
				$ihash{$cpm_name}{$current_sig_name}= $port_name;#$_=$_[0];
				if ($current_sig_name =~ /I_(\w+)_(cursig\d+)/i) { 
					$group="$1"; $user{$group}=1; #print "\n $group $2" ;
					$current_sig="I$2";
				
				}
				else {
					$current_sig_name=$_[0];
				}
			}
			if (/^I/){
			chomp;
				@_=split(" ",$_);
				$port_name = $_[1];$current_sig_name= $_[0];
				$ihash{$cpm_name}{$current_sig_name}= $port_name;
			}

			if (/^I/) {	
				$no_of_current_source++; 
				$step=1; 
				chomp;
				@_=split(" ",$_);
				$_= $_[0];
				#if ($_[0]=~m/I_(\S+)_(a-z\d+)/) { print "\n Group= $1"; }
				#if (/I(cursig\d+)/i) { print "\n Current= $1\n"; }
				if (/I_(\w+)_(cursig\d+)/i) { 
					$group=$1; $user{$group}=1; #print "\n $group $2" ;
					$current_sig="I$2";
#					$$cpm_hash{$cpm_name}{$group}{$current_sig}{'Port Name'} = $port_name;
				
				}
				else {
					$current_sig_name=$_[0];
					
				}

 			}

			if (/^.subckt adsPowerModel/)	{ $read_node=1; }
			if (/^\* Average power/){
				chomp;@_=split(" ",$_);
				$power=$_[4];
				$power_units=$_[5];
			}
			if (/^\* CPM Port Name/){
				$read_port_names=1;next;#print "$cpm_name $_\n";next;
			}
			if($read_port_names){
				if (/^\* Average power/){$read_port_names =0;next;
				}else{
				chomp; @_=split(" ",$_);
				$port= $_[1];$voltage= $_[4];
				if ($voltage){
					$cpm_hash{$cpm_name}{$port}= $_[4];
				}
#print "$_\n";			}	
#use Data::Dumper;
#				print Dumper (\%cpm_hash);
				}
			}
		}
		foreach $group (keys %user) {
			@user_group=(@user_group,$group);
		}
					
		if ($log)
		{
		print $log "\nCPM file : $cpm_file" ;
		print $log "\nSim Start Time : $t0 $unit, Sim End Time : $end_time $unit , Simulation Time Step : $time_step $unit" ;
		print $log "\nNo of Current Source  : $no_of_current_source" ;
		print $log "\nNo of Ports  : $no_of_nodes" ;
		print $log "\nName of Ports  : @nodes " ;
		if (@user_group)
		{
		print $log "\nUser Configured Groups  : @user_group \n" ;
		} else {print $log "\n";}
		}
		$$cpm_hash{$cpm_name}{"Start Time"}=$t0;
		$$cpm_hash{$cpm_name}{"End Time"}=$end_time;
		$$cpm_hash{$cpm_name}{"Time Step"}=$time_step;
		$$cpm_hash{$cpm_name}{"Unit"}=$unit;
		$$cpm_hash{$cpm_name}{"No of Current Sources"}=$no_of_current_source;
		$$cpm_hash{$cpm_name}{"No of Ports"}=$no_of_nodes;
		$$cpm_hash{$cpm_name}{"Name of Ports"}="@nodes";
		$$cpm_hash{$cpm_name}{"Average Power"}="$power";
		$$cpm_hash{$cpm_name}{"Power Units"}="$power_units";
		if (@user_group)
		{
		$$cpm_hash{$cpm_name}{"User Group"}="@user_group";
		}
		
		
		
		
	}
	else {
		if ($log){
		print $log "\nERROR : Failed to open cpm file $cpm_file : $!"  ;}
		print "\nERROR : Failed to open cpm file $cpm_file : $!\n\n" ;
		exit ;
	}
	return;
}

# Function to Dump output file as per Vinayakam Specifications
#<cpm-name> <filename> <duration> <groupnames-for-user-config-cpm>
#ind_bpfs_cpm /nfs/sjo2ae384-2.data1/araykar/mini_qa/validate_cpm/testcases/int_generic_vless_bpfs_ind/version1/bpfs_cpm.sp 23.5ns 
#regular_bpfs /nfs/sjo2ae384-2.data1/araykar/mini_qa/validate_cpm/testcases/int_generic_vless_bpfs/version1/bpfs_cpm.sp 23.5ns
# Sub-routine call out($output);
sub out
{		
	($output,@input_files_created) = @_;
	$output=shift(@_);
	#@input_files_created=split(" ",$_[0]);
	#print "\n Inputs : $output " ;
	open $output_file , ">$output"  or die "ERROR!! Cannot Open $output_file to write" ;
	print $output_file  "#<cpm-name> <filename> <duration> <power> <groupnames-for-user-config-cpm>";
	# Get all the cpm file names and location from $cpm_file hash
#	foreach $named_input_files (@input_files_created){  
#	open input_text , "<$ENV{PWD}/$named_input_files";
#		while (<input_text>)	{
#	if(($_ !~ /^#/) && ($_ !~ /^$/))	{
#	   chomp;@_=split(" ",$_);
#	   $cpm{$_[0]}=$_[1];
#	   print LOG_FILE "\n#Input CPM file :";
#	   print LOG_FILE "\n$_[0] : $_[1]";
#	   $cpm_name= $_[0];
#	   $cpm_file= $cpm{$_[0]};
#	   $cpm_hash;
##	   print LOG_FILE "\n###Start Parsing input CPM file $cpm_name ";
#	   cpm_info($cpm_name,$cpm{$cpm_name},\%cpm_hash,LOG_FILE);
##	   print LOG_FILE "###End Parsing input CPM file $cpm_name \n";
#}
#}
#}
#close input_text;
#use Data::Dumper;
#				print Dumper (\%cpm_hash);
		foreach $cpm (keys %cpm)	{
		# Get all the details of this cpm from $cpm_hash hash
		$user_group=0;
		$file_loc=$cpm{$cpm};
		#print "\n $file_loc";
		$duration=$cpm_hash{$cpm}{"End Time"}-$cpm_hash{$cpm}{"Start Time"};
		$duration="$duration$cpm_hash{$cpm}{\"Unit\"}";
		$power_number=$cpm_hash{$cpm}{"Average Power"};
		$power_units=$cpm_hash{$cpm}{"Power Units"};
		if ($cpm_hash{$cpm}{"User Group"})	{
			$user_group=$cpm_hash{$cpm}{"User Group"};
			print $output_file "\n$cpm $file_loc $duration $power_number$power_units {$user_group} " ;
		}
		else {
			print $output_file "\n$cpm $file_loc $duration $power_number$power_units" ;
		}
	}
	close $output_file;
}
sub cpm_altered_hash
{
	($cpm_name,$cpm_file,$time_snip,$time_snip2)=@_;
	if ($time_snip=~m/(\d+\.\d+)(\S+)/) { $time_snip=$1;$unit1=$2;} elsif ($time_snip=~m/(\d+)(\S+)/) {$time_snip=$1;$unit1=$2;}
	if ($time_snip2=~m/(\d+\.\d+)(\S+)/) { $time_snip2=$1;$unit2=$2;} elsif ($time_snip2=~m/(\d+)(\S+)/) {$time_snip2=$1;$unit2=$2;}
	if (!($unit1 eq "s" || $unit1 eq "ms" || $unit1 eq "us" || $unit1 eq "ns" || $unit1 eq "ps" || $unit1 eq "fs" || $unit1 =~ /e+/ || $unit1 =~ /e-/))
    {
        print $log "ERROR ! Dead Time unit : $unit is not matching with allowed units : s,ms,us,ns,ps,fs or scientific notation  e-0,e+0,e-3,e-6,e-9,e-12,e-15\n";
        print "ERROR ! Dead Time unit : $unit is not matching with allowed units : s,ms,us,ns,ps,fs or scientific notation  e-0,e+0,e-3,e-6,e-9,e-12,e-15\n";
        exit;
    }
	if (!($unit2 eq "s" || $unit2 eq "ms" || $unit2 eq "us" || $unit2 eq "ns" || $unit2 eq "ps" || $unit2 eq "fs" || $unit2 =~ /e+/ || $unit2 =~ /e-/))
    {
        print $log "ERROR ! Dead Time unit : $unit is not matching with allowed units : s,ms,us,ns,ps,fs or scientific notation  e-0,e+0,e-3,e-6,e-9,e-12,e-15\n";
        print "ERROR ! Dead Time unit : $unit is not matching with allowed units : s,ms,us,ns,ps,fs or scientific notation  e-0,e+0,e-3,e-6,e-9,e-12,e-15\n";
        exit;
    }
	$cpm_unit= $cpm_hash{$cpm_name}{"Unit"};
	if ($unit1 ne $cpm_unit){
	 $factor=unit_multiplier($cpm_unit,$unit1,$log);
        $time_snip=$time_snip*$factor;
        #$time_to_add=$t;    
        #print "\n $t $unit_resultant to be inserted ";    
    }
	if ($unit2 ne $cpm_unit){
	 $factor=unit_multiplier($cpm_unit,$unit1,$log);
        $time_snip2=$time_snip2*$factor;
        #$time_to_add=$t;    
        #print "\n $t $unit_resultant to be inserted ";    
    }
	$start_time= $cpm_hash{$cpm_name}{"Start Time"};
	if($time_snip){
		$end_time_initial_part_without_decimal= $start_time+$time_snip;
		$end_time_initial_part=sprintf("%.6f",$end_time_initial_part_without_decimal);
	}
	
	if($time_snip2){
		$start_time_end_part_without_decimal= $start_time+$time_snip2;
		$start_time_end_part=sprintf("%.6f",$start_time_end_part_without_decimal);
	}
	
	if ($time_snip){
	if($cpm_hash{$cpm_name}{"User Group"}){
	  $user_groups = $cpm_hash{$cpm_name}{"User Group"};
	  chomp;@user_groups= split(" ",$user_groups);
	  foreach $group (@user_groups){ 
	     foreach $current_sig (keys %{$cpm_hash{$cpm_name}{$group}}) {
	          foreach $time_instant (sort {$a <=> $b} keys % {$cpm_hash{$cpm_name}{$group}{$current_sig}}){
		  #print "$time_instant\n";
	   	          if ($end_time_initial_part> $time_instant){
		             $prev_time_instant=$time_instant;
		             next;
		          }elsif ($time_instant > $end_time_initial_part) {
		              $value1=$cpm_hash{$cpm_name}{$group}{$current_sig}{$time_instant};#print "$value1\n";
		              $value2=$cpm_hash{$cpm_name}{$group}{$current_sig}{$prev_time_instant};#print "$value2\n";
		              $cpm_hash{$cpm_name}{$group}{$current_sig}{$end_time_initial_part}=((($value1-$value2)/($time_instant-$prev_time_instant))*$end_time_initial_part)+((($value1*$prev_time_instant)-($value2*$time_instant))/($prev_time_instant-$time_instant));
		              goto NEXT;
		          }elsif ($time_instant = $end_time_initial_part) {
		              goto NEXT;
	              }  
                }
	            NEXT :
                #next;
	        } 
	    }      
	}else{
	  foreach $current_sig_name (keys %{$cpm_hash{$cpm_name}}) {
	      foreach $time_instant (sort {$a <=> $b} keys % {$cpm_hash{$cpm_name}{$current_sig_name}}){
	           if ($end_time_initial_part> $time_instant){
		           $prev_time_instant=$time_instant;
		           next;
		      }elsif ($time_instant > $end_time_initial_part) {
		           $value1=$cpm_hash{$cpm_name}{$current_sig_name}{$time_instant};#print "$value1\n";
		           $value2=$cpm_hash{$cpm_name}{$current_sig_name}{$prev_time_instant};
		           $cpm_hash{$cpm_name}{$current_sig_name}{$end_time_initial_part}=((($value1-$value2)/($time_instant-$prev_time_instant))*$end_time_initial_part)+((($value1*$prev_time_instant)-($value2*$time_instant))/($prev_time_instant-$time_instant));
		           goto NEXT;
		      }elsif ($time_instant = $end_time_initial_part) {
                   #$cpm_hash{$cpm}{$group}{$metric}{$end_time_initial_part}=$cpm_hash{$cpm}{$group}{$metric}{$time_instant};
		           goto NEXT;
	              }  
               
	        }
			NEXT :
            #next;	
	    }      
	}
	}
	if($time_snip2){
	  if($cpm_hash{$cpm_name}{"User Group"}){
	  $user_groups = $cpm_hash{$cpm_name}{"User Group"};
	  chomp;@user_groups= split(" ",$user_groups);
	  foreach $group (@user_groups){ 
	     foreach $current_sig (keys %{$cpm_hash{$cpm_name}{$group}}) {
	          foreach $time_instant (sort {$a <=> $b} keys % {$cpm_hash{$cpm_name}{$group}{$current_sig}}){
		  #print "$time_instant\n";
	   	          if ($start_time_end_part> $time_instant){
		             $prev_time_instant=$time_instant;
		             next;
		          }elsif ($time_instant > $start_time_end_part) {
		              $value1=$cpm_hash{$cpm_name}{$group}{$current_sig}{$time_instant};#print "$value1\n";
		              $value2=$cpm_hash{$cpm_name}{$group}{$current_sig}{$prev_time_instant};#print "$value2\n";
		              $cpm_hash{$cpm_name}{$group}{$current_sig}{$start_time_end_part}=((($value1-$value2)/($time_instant-$prev_time_instant))*$start_time_end_part)+((($value1*$prev_time_instant)-($value2*$time_instant))/($prev_time_instant-$time_instant));
			      $cpm_hash_value = $cpm_hash{$cpm_name}{$group}{$current_sig}{$start_time_end_part};
		              goto NEXT;
		          }elsif ($time_instant = $start_time_end_part) {
		              goto NEXT;
	              }  
                }
	            NEXT :
	        } 
	    }      
	}else{
	  foreach $current_sig_name (keys %{$cpm_hash{$cpm_name}}) {
	      foreach $time_instant (sort {$a <=> $b} keys % {$cpm_hash{$cpm_name}{$current_sig_name}}){
	           if ($start_time_end_part> $time_instant){
		           $prev_time_instant=$time_instant;
		           next;
		      }elsif ($time_instant > $start_time_end_part) {
		           $value1=$cpm_hash{$cpm_name}{$current_sig_name}{$time_instant};#print "$value1\n";
		           $value2=$cpm_hash{$cpm_name}{$current_sig_name}{$prev_time_instant};
		           $cpm_hash{$cpm_name}{$current_sig_name}{$start_time_end_part}=((($value1-$value2)/($time_instant-$prev_time_instant))*$start_time_end_part)+((($value1*$prev_time_instant)-($value2*$time_instant))/($prev_time_instant-$time_instant));
		           goto NEXT;
		      }elsif ($time_instant = $start_time_end_part) {
		           goto NEXT;
	              }  
               
	        }
			NEXT :
	    }      
	}
	}
	
}

sub print_hash_split_cpm_file
{
	($cpm_name,$cpm_file,$time_snip,$time_snip2,$unit1,$unit2)= @_;
	$cpm_name=$_[0];
	$cpm_file=$_[1];
	$time_snip=$_[2];
	$time_snip2=$_[3];
	$unit1=$_[4];
	$unit2=$_[5];
	$cpm_initial_part=$cpm_name."_1.sp";
	$cpm_rest_of_the_part=$cpm_name."_2.sp";
	if($time_snip2){$cpm_end_part=$cpm_name."_3.sp";}
	$start_time= $cpm_hash{$cpm_name}{"Start Time"};
	$unit=$cpm_hash{$cpm_name}{"Unit"};
	$end_time_initial_part_without_decimal= $start_time+$time_snip;
	$end_time_initial_part=sprintf("%.6f",$end_time_initial_part_without_decimal);
	$path = "$cpm_file.inc";
	if($time_snip2){
		$start_time_end_part_without_decimal= $start_time+$time_snip2;
		$start_time_end_part=sprintf("%.6f",$start_time_end_part_without_decimal);
		
	if ( -e $path ) {system ("cp $path cpm_split/$cpm_end_part.inc");
	}else{
		print $log "\n WARNING ! Inc file not present in given path : $path \nCPM Editor will proceed without inc file\nPlease modify the output CPM file to include the correct inc file before you use it in simulation!";
	} 
	if ( -e $path ) {system ("cp $path cpm_split/$cpm_rest_of_the_part.inc");
	}else{
		print $log "\n WARNING ! Inc file not present in given path : $path \nCPM Editor will proceed without inc file\nPlease modify the output CPM file to include the correct inc file before you use it in simulation!";
	} 
	if ( -e $path ) {system ("cp $path cpm_split/$cpm_initial_part.inc");
	}else {
		print $log "\n WARNING ! Inc file not present in given path : $path \nCPM Editor will proceed without inc file\nPlease modify the output CPM file to include the correct inc file before you use it in simulation!";
	} 
	}else{$start_time_end_part=$cpm_hash{$cpm_name}{"End Time"}};
	if($time_snip){
		if (! -d "cpm_split") {system("mkdir cpm_split");}
		if ( -e $path ) {system ("cp $path cpm_split/$cpm_initial_part.inc");
		}else {
			print $log "\n WARNING ! Inc file not present in given path : $path \nCPM Editor will proceed without inc file\nPlease modify the output CPM file to include the correct inc file before you use it in simulation!";
		} 
		if ( -e $path ) {system ("cp $path cpm_split/$cpm_rest_of_the_part.inc");
		}else {
			print $log "\n WARNING ! Inc file not present in given path : $path \nCPM Editor will proceed without inc file\nPlease modify the output CPM file to include the correct inc file before you use it in simulation!";
		}	 
	}
	if ($start_time_end_part){open cpm_end , ">$ENV{PWD}/cpm_split/$cpm_end_part";}
	if ($time_snip){
		open cpm_initial , ">$ENV{PWD}/cpm_split/$cpm_initial_part";
		open cpm_rest , ">$ENV{PWD}/cpm_split/$cpm_rest_of_the_part";
		open cpm_file,$cpm_file;
	}
	#$path = "$cpm_file.inc";
	#if ( -e $path ) {system ("cp $path cpm_split/$cpm_name.inc");} 
	#else {
	#print $log "\n WARNING ! Inc file not present in given path : $path \nCPM Editor will proceed without inc file\nPlease modify the output CPM file to include the correct inc file before you use it in simulation!";
	#}
	while ($line1=<cpm_file>){
		if ($line1 =~ /^I/) {    
			print cpm_initial "\n$line1";  $start=1;
			print cpm_rest "\n$line1";
			print cpm_end "\n$line1";
			$I_metric=$line1;
			next;
		}
		if ($start==0) {
			if ($line1 =~ /\*.Apache.RedHawk/) {
				print cpm_end "*************************************************************\n";
				print cpm_initial "*************************************************************\n";
				print cpm_rest "*************************************************************\n";
				print cpm_rest "$line1";
				print cpm_initial "$line1";
				print cpm_end "$line1";
				$x=`date`;
				@_=split('\s+',$x);
				$month="$_[1]";$date=$_[2];$time=$_[3];$year=$_[5];
				@_=split('\:',$time);
				$hr=$_[0];$minute=$_[1];
				print cpm_rest "* File created by CPM Editor on $date-$month-$year| $hr:$minute\n";
				print cpm_initial "* File created by CPM Editor on $date-$month-$year| $hr:$minute\n";
				print cpm_end"* File created by CPM Editor on $date-$month-$year| $hr:$minute\n";
				print cpm_rest "*************************************************************\n";
				print cpm_initial "*************************************************************\n";
				print cpm_end "*************************************************************\n";
			}
			if ($line1 =~ /INCLUDE/ ) { 

				print cpm_end "\n.INCLUDE \"$cpm_end_part.inc\" \n\n";
				print cpm_initial "\n.INCLUDE \"$cpm_initial_part.inc\" \n\n";
				print cpm_rest "\n.INCLUDE \"$cpm_rest_of_the_part.inc\" \n\n";
			}
	
			if ($line1 =~ /\*.Begin.Chip.Package/){
				$flag2=1;
			}
			if ($line1 =~ /\*.Average.power/){
				$flag2=0;
			}
			if ($flag2){
				print cpm_rest "$line1";
				print cpm_initial "$line1";
				print cpm_end "$line1";
			}
			if ($line1 =~ /\*.Average.power/){
				print cpm_rest "\n$line1";
				print cpm_initial"\n$line1";
				print cpm_end"\n$line1";
			}
			if ($line1 =~ /\.ends/){print cpm_rest "\n.ends";print cpm_initial "\n.ends";print cpm_end "\n.ends";}  
		}else{
			@_=split(" ",$I_metric);
			$I_metric=$_[0];
			if ($I_metric =~ /I_(\w+)_(cursig\d+)/i) { 
				$group="$1";
				$current_sig="I$2";my $flag=1;
		   		foreach $time_instant(sort {$a <=> $b}  keys %{$cpm_hash{$cpm_name}{$group}{$current_sig}}){
						if ($time_instant <= $end_time_initial_part){
							print cpm_initial "+ $time_instant$unit $cpm_hash{$cpm_name}{$group}{$current_sig}{$time_instant}\n";$prev_current=$cpm_hash{$cpm_name}{$group}{$current_sig}{$time_instant};
						}
						elsif ($time_instant>$end_time_initial_part && $time_instant<=$start_time_end_part) {
							$subtracted_time_instant_without_decimal=$time_instant-$end_time_initial_part;
							$subtracted_time_instant=sprintf("%.6f",$subtracted_time_instant_without_decimal);
							if($flag){	print cpm_rest "+ 0.000000$unit $prev_current \n";}
							print cpm_rest "+ $subtracted_time_instant$unit $cpm_hash{$cpm_name}{$group}{$current_sig}{$time_instant} \n";$flag=0;$flag_2=1;
							$prev_current2=$cpm_hash{$cpm_name}{$group}{$current_sig}{$time_instant};
						}elsif($time_instant>$start_time_end_part){
							$subtracted_time_instant_without_decimal=$time_instant-$start_time_end_part;
							$subtracted_time_instant=sprintf("%.6f",$subtracted_time_instant_without_decimal);
							if($flag_2){	print cpm_end "+ 0.000000$unit $prev_current2 \n";}
							print cpm_end "+ $subtracted_time_instant$unit $cpm_hash{$cpm_name}{$group}{$current_sig}{$time_instant} \n";$flag_2=0;
						}
				}
					$start=0;
				$end_currentsig=1;
			}
			else {
				$current_sig_name=$_[0];my $flag=1;
				foreach $time_instant(sort {$a <=> $b}  keys %{$cpm_hash{$cpm_name}{$current_sig_name}}){
					if ($time_instant <= $end_time_initial_part){
						print cpm_initial "+ $time_instant$unit $cpm_hash{$cpm_name}{$current_sig_name}{$time_instant}\n";$prev_current=$cpm_hash{$cpm_name}{$current_sig_name}{$time_instant};
					}
					elsif($time_instant>$end_time_initial_part && $time_instant<=$start_time_end_part) {
						$subtracted_time_instant_without_decimal=$time_instant-$end_time_initial_part;
						$subtracted_time_instant=sprintf("%.6f",$subtracted_time_instant_without_decimal);
						if($flag){	print cpm_rest "+ 0.000000$unit $prev_current \n";}
						print cpm_rest "+ $subtracted_time_instant$unit $cpm_hash{$cpm_name}{$current_sig_name}{$time_instant}\n";$flag=0;$flag_2=1;
						$prev_current2=$cpm_hash{$cpm_name}{$current_sig_name}{$time_instant};
					}elsif($time_instant>$start_time_end_part){
						$subtracted_time_instant_without_decimal=$time_instant-$start_time_end_part;
						$subtracted_time_instant=sprintf("%.6f",$subtracted_time_instant_without_decimal);
						if($flag_2){	print cpm_end "+ 0.000000$unit $prev_current2 \n";}
						print cpm_end "+ $subtracted_time_instant$unit $cpm_hash{$cpm_name}{$current_sig_name}{$time_instant} \n";$flag_2=0;
					}
				}
				$start=0;
				$end_currentsig=1;
			}
		}
		if ($end_currentsig==1) {
            		if (($line1 !~ /^\+ R/)&&($line1 !~ /^\+\)/)) { next; }
            		else {print cpm_rest "+)" ;print cpm_initial "+)" ;print cpm_end "+)" ;$start=0; $end_currentsig=0; next;}
        	}    			
		
	}	
	close cpm_initial;
	close cpm_rest;
	close cpm_end;
	close cpm_file;		
#	open cpm_initial , ">$ENV{PWD}/cpm_split/$cpm_initial_part" or die "Cannot write into the file $ENV{PWD}/cpm_split/$cpm_initial_part:$!\n\n";
}

sub create_input_text{
	($cpm_name,$time_snip,$time_snip2,$unit1,$unit2)=@_;
#	open ip_file,$Input_file;
	
	if ($time_snip){open input_text , ">$ENV{PWD}/.input_split_cpm_for_"."$cpm_name".".txt";}
#	while ($line=<ip_file>){
#		#print input_text "$line";
#		chomp;@_=split(" ",$line);#print input_text "@_\n";
#		print input_text "$_[0] $_[1]\n";#print $_line
#	}
	$cpm_initial_part=$cpm_name."_1";
	$cpm_rest_of_the_part=$cpm_name."_2";
	$cpm_end_part=$cpm_name."_3";
	print input_text "$cpm_initial_part $ENV{PWD}/cpm_split/$cpm_initial_part.sp\n";
	print input_text "$cpm_rest_of_the_part $ENV{PWD}/cpm_split/$cpm_rest_of_the_part.sp\n";
	if ($time_snip2){
		print input_text "$cpm_end_part $ENV{PWD}/cpm_split/$cpm_end_part.sp\n";
	}
	close input_text;
}	

sub calculate_average_power{
	($ihash,$cpm_hash,$input_files_created)=@_;
	#$ihash1=shift(@_);
	#$cpm_hash1=shift(@_);
	
	foreach $named_input_files (@$input_files_created){
		open input_text , "<$ENV{PWD}/$named_input_files";
		while (<input_text>)	{
		if(($_ !~ /^#/) && ($_ !~ /^$/))	{
		chomp;@_=split(" ",$_);
		$cpm{$_[0]}=$_[1];
		$cpm_name= $_[0];
		$cpm_file= $cpm{$_[0]};
		#$cpm_hash;
	   	cpm_info($cpm_name,$cpm{$cpm_name},\%cpm_hash,LOG_FILE);
		}
		$cnt2=1;
		$cnt3=0;$total_average_power=0; $ihash{$cpm_name}{$current_sig_name}{'Average Cursig Power'}=0;$total_area=0;
		foreach $current_sig_name (keys %{$cpm_hash{$cpm_name}}) {
			if ($current_sig_name =~ /^I/){
			$port_name=$ihash{$cpm_name}{$current_sig_name};
			$portvoltage=$cpm_hash{$cpm_name}{$port_name};
			if ($portvoltage){
			$total_area=0;
			$flg=1;
			$cnt=0;
			foreach $time_instant (sort {$a <=> $b} keys % {$cpm_hash{$cpm_name}{$current_sig_name}}){
				if ($flg){$flg =0;$first_prev_time_instant= $time_instant;$first_prev_current=$cpm_hash{$cpm_name}{$current_sig_name}{$time_instant};$cnt++;next;}
				if ($cnt){
				$second_current_value= $cpm_hash{$cpm_name}{$current_sig_name}{$time_instant};
				$first_time_difference=$time_instant - $first_prev_time_instant;
				$first_current_difference= $second_current_value - $first_prev_current;
				$total_area += $first_time_difference*($first_prev_current + ($first_current_difference)/2);
				$prev_time_instant=$time_instant;
				$prev_current_value=$second_current_value;
				$cnt=0;
				}else{
				$current_value= $cpm_hash{$cpm_name}{$current_sig_name}{$time_instant};
				$time_difference= $time_instant - $prev_time_instant;
				$current_difference= $current_value - $prev_current_value;
				$total_area += $time_difference*($prev_current_value + ($current_difference)/2);
				$prev_current_value= $current_value;
				$prev_time_instant= $time_instant;
				}
			}	
			$total_time= -($cpm_hash{$cpm_name}{"Start Time"} - $cpm_hash{$cpm_name}{"End Time"});
			$average_current= $total_area/$total_time;
			$ihash{$cpm_name}{$current_sig_name}{'Average Cursig Power'} = $average_current*$portvoltage;
			$total_average_power += $ihash{$cpm_name}{$current_sig_name}{'Average Cursig Power'};
			$cpm_hash{$cpm_name}{"Average Power"} = $total_average_power;
			$cnt2++;
			$cnt3++;
		
			}
		}
		}
		}
	}
}
sub unit_multiplier    {
    ($unit1,$unit2,$log)=@_;
    if ($unit1 eq $unit2)    { return 1 }
    elsif ($unit1 eq "s")    {
        if ($unit2 eq "ms" || $unit2 eq "e-3")    { return 1e-3 }
        elsif ($unit2 eq "us" || $unit2 eq "e-6") { return 1e-6 }
        elsif ($unit2 eq "ns" || $unit2 eq "e-9") { return 1e-9 }
        elsif ($unit2 eq "ps" || $unit2 eq "e-12") { return 1e-12 }
        elsif ($unit2 eq "fs" || $unit2 eq "e-15") { return 1e-15 }
        elsif ($unit2 eq "e+0" || $unit2 eq "e-0") { return 1 }
        else {    
            print $log "ERROR ! Dead Time unit : $unit is not matching with allowed units : s,ms,us,ns,ps,fs or scientific notation e-0,e+0,e-3,e-6,e-9,e-12,e-15\n";
            print "ERROR ! Dead Time unit : $unit is not matching with allowed units : s,ms,us,ns,ps,fs or scientific notation e-0,e+0,e-3,e-6,e-9,e-12,e-15\n";
            exit;
        }
    }
    elsif ($unit1 eq "ms")    {
        if ($unit2 eq "s" || $unit2 eq "e-0"  || $unit2 eq "e+0")    { return e+3 }
        elsif ($unit2 eq "us" || $unit2 eq "e-6") { return 1e-3 }
        elsif ($unit2 eq "ns" || $unit2 eq "e-9") { return 1e-6 }
        elsif ($unit2 eq "ps" || $unit2 eq "e-12") { return 1e-9 }
        elsif ($unit2 eq "fs" || $unit2 eq "e-15") { return 1e-12 }
        elsif ($unit2 eq "e-3") { return 1 }
        else {    
            print $log "ERROR ! Dead Time unit : $unit is not matching with allowed units : s,ms,us,ns,ps,fs or scientific notation e-0,e+0,e-3,e-6,e-9,e-12,e-15\n";
            print "ERROR ! Dead Time unit : $unit is not matching with allowed units : s,ms,us,ns,ps,fs or scientific notation e-0,e+0,e-3,e-6,e-9,e-12,e-15\n";
            exit;
        }
    }
    elsif ($unit1 eq "us")    {
        if ($unit2 eq "s" || $unit2 eq "e-0" || $unit2 eq "e+0")    { return e+6 }
        elsif ($unit2 eq "ms" || $unit2 eq "e-3") { return 1e+3 }
        elsif ($unit2 eq "ns" || $unit2 eq "e-9") { return 1e-3 }
        elsif ($unit2 eq "ps" || $unit2 eq "e-12") { return 1e-6 }
        elsif ($unit2 eq "fs" || $unit2 eq "e-15") { return 1e-9 }
        elsif ($unit2 eq "e-6") { return 1 }
        else {    
            print $log "ERROR ! Dead Time unit : $unit is not matching with allowed units : s,ms,us,ns,ps,fs or scientific notation e-0,e+0,e-3,e-6,e-9,e-12,e-15\n";
            print "ERROR ! Dead Time unit : $unit is not matching with allowed units : s,ms,us,ns,ps,fs or scientific notation e-0,e+0,e-3,e-6,e-9,e-12,e-15\n";
            exit;
        }
    }
    elsif ($unit1 eq "ns")    {
        if ($unit2 eq "s"  || $unit2 eq "e-0" || $unit2 eq "e+0")    { return e+9 }
        elsif ($unit2 eq "ms" || $unit2 eq "e-3") { return 1e+6 }
        elsif ($unit2 eq "us" || $unit2 eq "e-6") { return 1e+3 }
        elsif ($unit2 eq "ps" || $unit2 eq "e-12") { return 1e-3 }
        elsif ($unit2 eq "fs" || $unit2 eq "e-15") { return 1e-6 }
        elsif ($unit2 eq "e-9") { return 1 }
        else {    
            print $log "ERROR ! Dead Time unit : $unit is not matching with allowed units : s,ms,us,ns,ps,fs or scientific notation e-0,e+0,e-3,e-6,e-9,e-12,e-15\n";
            print "ERROR ! Dead Time unit : $unit is not matching with allowed units : s,ms,us,ns,ps,fs or scientific notation e-0,e+0,e-3,e-6,e-9,e-12,e-15\n";
            exit;
        }
    }
    elsif ($unit1 eq "ps")    {
        if ($unit2 eq "s" || $unit2 eq "e-0" || $unit2 eq "e+0")    { return e+12 }
        elsif ($unit2 eq "ms" || $unit2 eq "e-3") { return 1e+9 }
        elsif ($unit2 eq "us" || $unit2 eq "e-6") { return 1e+6 }
        elsif ($unit2 eq "ns" || $unit2 eq "e-9") { return 1e+3 }
        elsif ($unit2 eq "fs" || $unit2 eq "e-15") { return 1e-3 }
        elsif ($unit2 eq "e-12") { return 1 }
        else {    
            print $log "ERROR ! Dead Time unit : $unit is not matching with allowed units : s,ms,us,ns,ps,fs or scientific notation e-0,e+0,e-3,e-6,e-9,e-12,e-15\n";
            print "ERROR ! Dead Time unit : $unit is not matching with allowed units : s,ms,us,ns,ps,fs or scientific notation e-0,e+0,e-3,e-6,e-9,e-12,e-15\n";
            exit;
        }
    }
    elsif ($unit1 eq "fs")    {
        if ($unit2 eq "s" || $unit2 eq "e-0" || $unit2 eq "e+0")    { return e+15 }
        elsif ($unit2 eq "ms" || $unit2 eq "e-3") { return 1e+12 }
        elsif ($unit2 eq "us" || $unit2 eq "e-6") { return 1e+9 }
        elsif ($unit2 eq "ns" || $unit2 eq "e-9") { return 1e+6 }
        elsif ($unit2 eq "ps" || $unit2 eq "e-12") { return 1e+3 }
        elsif ($unit2 eq "e-15") { return 1 }
        else {    
            print $log "ERROR ! Dead Time unit : $unit is not matching with allowed units : s,ms,us,ns,ps,fs or scientific notation e-0,e+0,e-3,e-6,e-9,e-12,e-15\n";
            print "ERROR ! Dead Time unit : $unit is not matching with allowed units : s,ms,us,ns,ps,fs or scientific notation e-0,e+0,e-3,e-6,e-9,e-12,e-15\n";
            exit;
        }
    }
}
	

