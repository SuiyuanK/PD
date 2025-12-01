# $Revision: 1.39
# 
# Rev 1.38 by Prateek
# Removal of Error message check for Average Power 
# Rev 1.37 by Prateek
# Ending of current sig with '+)' or '+ )'
# Rev 1.36 by Prateek
# DC current option for Dead_time
# Rev 1.35 by Prateek
# Mode Transition Enhancement
# Dead Time starting current enhancement

# Rev 1.34 by Prateek
# Addition of a check if the output state sequence CPM names do not match with the ones given in the input.txt.
# Addition of .ends and removal ofthe space in the last line of any Icursig after + sign. "+ )"->"+)"

# Rev 1.33 by Prateek
# Changes in the Header section of output stitched CPM.Only the chip package protocol and the subckt section is taken from t-  he first cpm by default 
# Rev 1.32 by Prateek
# Removal of Pre Parsing Comments from Output Generation Log File 

#!/usr/bin/perl
################################################################################################################
# Name       : cpm_stitch.pl
# Description: Adding one CPM after another,Adding one CPM on top of another
# Author     : Ramesh , email : ramesh.agarwal@ansys.com
# Date          : 24-06-2013
################################################################################################################

# (1) quit unless we have the correct number of command-line args
$num_args = $#ARGV + 1;
#if (($num_args != 2) && ($num_args != 1)) {
#  print "\nIncorrect number of command-line args: Please see the usage below or see the manual: ";
#  print "\nUsage    : perl cpm_stitch.pl -config <>";
 # print "\nExaple    : perl cpm_stitch.pl -config multiple_activity.config \n\n";
 # exit;
#}

## Start of program documentaion

=head1 NAME

cpm_stitch.pl -Stiches multiple RedHawk-CPA files into one 

=head1 SYNOPSIS

cpm_stitch.pl [options] arguments

Options :  -config, -output, -help, -man

=head1 DESCRIPTION

<cpm_stitch.pl> stiches multiple RedHawk-CPA files into one.

  The output file is once complete cpm file : cpm_stitched.sp

=head1 OPTIONS

=over 

=item -help

prints a synopsis and a description of program options.

=item -config <config_file_name>

Specify the file which has all the configurations settings.

=item -output <output_file_name>

Specify the output file , Default : "cpm_stitched.sp"

=item -man

Prints the entire man page

=back

=head1 EXAMPLE

cpm_stitch.pl -config <config_file> -output all_cpm.sp

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

GetOptions ('help'=>                \$help,
            'config=s'=>            \$config_file,
            'man'=>                    \$man,
            'output=s'=>                \$output,
            'u'=>                    \$help,
            'h'=>                    \$help);

pod2usage (-exitval => 0, -verbose => 1) if $help;
pod2usage (-exitval => 0, -verbose => 2) if $man;

if($config_file eq '' )    {
     printf "%0s\t%10s","Error !! :","Specify Config File\n\n";
     $help=1;
     pod2usage (-exitval => 0, -verbose => 1) if $help;
}
if ($output eq '') {
    $output="cpm_stitched.sp";
} else {
    $output="$output";
}

$x=`date`;
@_=split('\s+',$x);
$month="$_[1]";$date=$_[2];$time=$_[3];$year=$_[5];
@_=split('\:',$time);
$hr=$_[0];$minute=$_[1];
$log="cpm_stitch".$date.$month.$year."_".$hr."_".$minute.".log";
if (! -d "Log") { system("mkdir Log");}
open LOG_FILE , ">$ENV{PWD}/Log/$log" or die "Cannot write into the file $ENV{PWD}/Log/$log :$!\n\n";
if(-e "$ENV{PWD}/cpm_stitch.log")    {    system("rm -rf $ENV{PWD}/cpm_stitch.log");    }
system("ln -s $ENV{PWD}/Log/$log $ENV{PWD}/cpm_stitch.log");    

#Start Reading the Config Files and generating required database
open cfg_file, "$config_file" or die "\nERROR : Failed to open file $config_file : $!" ;
#print LOG_FILE "###Parsing Config File : $config_file";

$cpm_files=0;
$output_sequence=0;
$count=$count1=$abc=0;
$initial=0;
while (<cfg_file>)    {
    if(($_ !~ /^#/) && ($_ !~ /^$/))    {
        if ($cpm_files == 1)    {
            chomp;@_=split(" ",$_);
            if ($_ =~ /}/)    {$cpm_files=2;if(scalar @_ < 3) {goto STOP_READ ;} }
            $cpm{$_[0]}=$_[1];
	    $cpm_names{$count1}=$_[0];
	    $count1++;
            if ($initial==0) {$inc=$_[1];$initial++;}
            if ($_[2] eq "USE_INC_FILE" ) { $inc=$_[1]; }
            print LOG_FILE "\n$_[0] : $_[1]";
        }
        if ($output_sequence == 1)    {
            chomp;@_=split(" ",$_);
            if ($_ =~ /}/)    {$output_sequence=2;if(scalar @_ < 2) {goto STOP_READ ;} }
	    @output_sequence_list=@_;
	    
	    foreach $output_state_value(@output_sequence_list){
	       # print "$output_state_value\n";
		#@_=split("",$output_state_value)
		if ($output_state_value =~ /DEAD_TIME/){next;}
                if ($output_state_value =~ /^\d+/){next;}
                if ($output_state_value =~ m/(.*)\(/) {
		   $name=$1;
		 if ($name =~ m/(.*)::/){
		    $name=$1;
		 }
		}
		$count2=0; 
		$cpm_name_from_output_sequence= $name;
		
		#print "$name \n"; 
		foreach $cpm_name (keys % cpm_names){
		     #print "$cpm_name\n";
		  if ($cpm_names{$cpm_name} eq $cpm_name_from_output_sequence){
		     #print "$cpm_names{$cpm_name} = $cpm_name_from_output_sequence\n";
		     $count2++;
		     #print "count after $count2\n";
		  } else {
		      #print "$cpm_names{$cpm_name} != $cpm_name_from_output_sequence\n";
		      #print "I am here\n";
		      #print "$count2\n";
		  }
	        }
		if (!$count2){  
		       print LOG_FILE "\nERROR : CPM Name $name not defined in the input text file. CPM Name $name does not have a file path associated with it.\n" ;
              	       print "\nERROR : CPM name $name not defined in the input text file. CPM Name $name does not have a file path associated with it.\n" ;
                       exit;
		}
	    }
	       
	          
            @_=split("}",$_);
            $output_seq{$count} =$_[0];
            $count++;
            print LOG_FILE "\n$_[0]";
            #print "\n$_";
        }
        
        STOP_READ:
        if (/CPM_FILES/)    {
            if ($cpm_files > 1 )    {
                #print LOG_FILE "\nERROR : KEYWORD \"CPM_FILES\" defined multiple times at line : $. in $config_file" ;
                #print "\nERROR : KEYWORD \"CPM_FILES\" defined multiple times at line : $. in $config_file\n\n" ;
                exit;
            }    else    {
                $cpm_files =1;
                print LOG_FILE "\n#Input CPM files : " ;
            }
        }
        if (/OUTPUT_STATE_SEQUENCE/) {
            if ($output_sequence > 1 )    {
                #print LOG_FILE "\nERROR : KEYWORD \"OUTPUT_STATE_SEQUENCE\" defined multiple times at line : $. in $config_file " ;
                #print "\nERROR : KEYWORD \"OUTPUT_STATE_SEQUENCE\" defined multiple times at line : $. in $config_file \n\n" ;
                exit;
            }    else    {
                $output_sequence =1;
                print LOG_FILE "\n\n#User provided output sequence : " ;
            }
        }
	if (/ADVANCED_TIME_STEP_HANDLING/) {
	   chomp;@_=split(" ",$_); 
	   $include_all_time_points=$_[1];#print "$include_all_time_points\n";
	}
	
        if (/OVERLAP_HANDLING/) {
            if ($overlap_handling >= 1 )    {
                print LOG_FILE "\nERROR : KEYWORD \"OVERLAP_HANDLING\" defined multiple times at line : $. in $config_file " ;
                print "\nERROR : KEYWORD \"OVERLAP_HANDLING\" defined multiple times at line : $. in $config_file \n\n" ;
                exit;
            }    else    {
                chomp;@_=split(" ",$_);
                if ($_ =~ /FIRST/i || /SECOND/i|| /SUM/i || /AVERAGE/i || /AVG/i || /MIN/i || /MAX/i)    {
                    if (scalar @_ ==2) {
                        $overlap=$_[1];
                        $overlap_handling=1; 
			} 
                    else { 
                        print LOG_FILE "\nERROR : KEYWORD \"OVERLAP_HANDLING\" defined incorrectly , Correct Syntax : OVERLAP_HANDLING <type> , Where Valid tpe are \"FIRST " ;
                        print "\nERROR : KEYWORD \"OVERLAP_HANDLING\" defined incorrectly , Correct Syntax : OVERLAP_HANDLING <type> , Where Valid tpe are \"FIRST " ;
                        
                    	}
                	}
                else {
                    print LOG_FILE "\nERROR : KEYWORD \"OVERLAP_HANDLING\" defined incorrectly , Correct Syntax : OVERLAP_HANDLING <type> , Where Valid tpe are \"FIRST " ;
                    print "\nERROR : KEYWORD \"OVERLAP_HANDLING\" defined incorrectly , Correct Syntax : OVERLAP_HANDLING <type> , Where Valid tpe are \"FIRST " ;
                        
                }
                print LOG_FILE "\n#User provided overlap handling parameter : $overlap\n" ;
            }    
        }
    }
}    
#print LOG_FILE "\n###End Parsing Config File \n";

#Start Parsing given CPM files 
#print LOG_FILE "\n###Start Parsing input CPM files ";
$cpm_details;
foreach $cpm_name (keys % cpm)    {
    cpm_info($cpm_name,$cpm{$cpm_name},\%cpm_details,LOG_FILE);
}
#print LOG_FILE "###End Parsing input CPM files \n";
#use Data::Dumper;
#print Dumper (\%cpm_details);
##Start Doing Sanity Checks in the input CPM   
#print LOG_FILE "\n###Start Doing Sanity checks on input CPM files ";
# The following metrics for all the CPM Must be same  :  
# "Time Step" , "Unit" , "No of Current Sources" , "No of Nodes" , "Name of Nodes" , "User Group" -> If present . 
# NOTE: "Start Time" and "End Time"  can vary
@metrics = ("Unit","No of Nodes","Name of Nodes","Average Power");
if (!$include_all_time_points) {
foreach $metric (@metrics)    {
    if ($metric =~ /Average Power/){
	foreach$testcase(keys %cpm_details) {
		$AveragePower=$cpm_details{$testcase}{$metric};
		if (!$AveragePower){
#			print "\nERROR :$metric is not present for $testcase\n";
			print LOG_FILE "\nERROR :$metric is not present for $testcase\n";
		}
	}
    }else {
    $flag=0;
    foreach $testcase (keys %cpm_details) {
        if ($flag ==0) { $old=$cpm_details{$testcase}{$metric};$flag=1;}    
        else {
           $val=$cpm_details{$testcase}{$metric};
            if ($old ne $val) { print "\nERROR : $metric $val is not matching for $testcase with $old on other CPM files\n\n" ;
             print LOG_FILE "\nERROR : $metric $val is not matching for $testcase with $old on other CPM files\n\n" ;
             exit;
            }
        }
    }
    }	
}
}else{
@metrics = ("Unit","No of Nodes","Name of Nodes","Average Power");
foreach $metric (@metrics)    {
    if ($metric =~ /Average Power/){
	foreach$testcase(keys %cpm_details) {
		$AveragePower=$$cpm_details{$testcase}{$metric};
		if (!$AveragePower){
#			print "\nERROR :$metric is not present for $testcase\n";
			print LOG_FILE "\nERROR :$metric is not present for $testcase\n";
		}
	}
    }else {	
    $flag=0;
    foreach $testcase (keys %cpm_details) {
        if ($flag ==0) { $old=$cpm_details{$testcase}{$metric};$flag=1;}    
        else {
           $val=$cpm_details{$testcase}{$metric};
            if ($old ne $val) { print "\nERROR : $metric $val is not matching for $testcase with $old on other CPM files\n\n" ;
             print LOG_FILE "\nERROR : $metric $val is not matching for $testcase with $old on other CPM files\n\n" ;
             exit;
            }
        }
    }
    }
}
}
#print LOG_FILE "\nSanity checks PASSED on all input CPM files";
#print LOG_FILE "\n###End Doing Sanity checks on input CPM files \n";

#Start Stiching input CPM together   
print LOG_FILE "\n###Start Stitching input CPM together ";
$initial=1;
$count=0;
foreach $seq_no (sort{ $a <=> $b } keys %output_seq )    {
   %cpm_info = () ;
    foreach $cpm_name (keys % cpm)    {
    	cpm_info($cpm_name,$cpm{$cpm_name},\%cpm_details);
    }
    chomp $seq_no;
    @cpm_scale=();
    if(@output_seq{$seq_no} !~ /DEAD_TIME/) {
    #print "\nSequence No : $seq_no , Sequence : @output_seq{$seq_no}";
    @_=split(" ",@output_seq{$seq_no});
    #$insert_dead_time=0;
    #print "\nLength of Sequence : $l , @_"  ;
    @cpm_list_for_a_sequence= @_;
    #$number_of_cpm_in_sequence= scalar @_;
    #print "\n$number_of_cpm_in_sequence";
    #print "hi\n";
    #print join(",",@cpm_list_for_a_sequence);
    	foreach (@cpm_list_for_a_sequence) {
    		if (/scale/) {
		$scale=$_;
		@scale_split=split('=', $scale);
		$scaling_factor=$scale_split[1];
		chop($scaling_factor);
		@cpm_scale[$count]=$scaling_factor;
		#print "\n the scale is $scale";
		}else { 
		@cpm_scale[$count]=1;
		}
		$count++;
    	}
	$count=0;
    	#$cpm_scale_number= scalar @cpm_scale;
	#print "\n $cpm_scale_number";
	#print ",";print join(",",@cpm_scale); 
    }else { @_=split(" ",@output_seq{$seq_no});}
    	
    if ($insert_dead_time_at_start==1)    {
        if($include_all_time_points) {
	    stack_with_all_time_stamps(LOG_FILE,@cpm_list_for_a_sequence,@cpm_scale);
	    insert_dead_time_at_begining ($log,$dead_time,$resultant_cpm);
	    $insert_dead_time_at_start=0;
	    next;
	}else{   
            stack(LOG_FILE,@cpm_list_for_a_sequence,@cpm_scale);#this is being done to obtain resultant cpm irrespective wether there is a single cpm in the output sequence.
#	    use Data::Dumper;
#	    print "\n $resultant_cpm ";
            insert_dead_time_at_begining ($log,$dead_time,$resultant_cpm);    
            $insert_dead_time_at_start=0;
            next;
	}
    }
    
    if (@output_seq{$seq_no} =~ /DEAD_TIME/) { 
        if ($resultant_cpm)    {  
	  @cpm_name_specified_in_dead_time=split('=',$_[2]);
	  insert_dead_time(LOG_FILE,$resultant_cpm,$_[1],$cpm_name_specified_in_dead_time[1],$cpm_name_specified_in_dead_time[0]);	  
	  next;}
        else {
#            print "\n I am new ";
            $dead_time=$_[1];
            $insert_dead_time_at_start=1;
	    #$insert_dead_time=1;
            next;
        }
    }
    if (scalar @cpm_list_for_a_sequence >=1)    {
        if($include_all_time_points){
	   stack_with_all_time_stamps(LOG_FILE,@cpm_list_for_a_sequence,@cpm_scale);
	   next;
	}else{
           #print ",";#print join(",",@cpm_scale);
	   #print "I am here\n";
	   stack(LOG_FILE,@cpm_list_for_a_sequence,@cpm_scale);
	   next;
	}   
    }
    else {  $cpm2=$_[0];stitch(LOG_FILE,$resultant_cpm,$cpm2); next;}
        
}


#Finish Stiching input CPM together   
print LOG_FILE "\n###End Stitching input CPM together\n ";
#use Data::Dumper;
#print Dumper (\%cpm);
#print Dumper (\%output_seq);
#print Dumper (\%cpm_details);
print LOG_FILE "\n###Start Dumping final CPM to output file";
@cpm_name =keys %cpm;
dump_resultant_hash_to_file(LOG_FILE,$output,$resultant_cpm,$cpm{$cpm_name[0]});
print LOG_FILE "\n###Finish Dumping final CPM to output file";




# Function to save the cpm information in a hash and all the current signatures of the CPM
sub cpm_info
{        
    ($cpm_name,$cpm_file,$cpm_hash,$log) = @_;
    my $read_time;my $t0;my $t1;my $time_step;my $end_time;my $end_time;my $unit;my $no_of_nodes;my @nodes; my $no_of_current_source;my $line_no=0;
    my $read_usr_group=0;my @user_group;my $group;my $current_sig;
    if (open(cpm_file,$cpm_file)){
        while(<cpm_file>)    {
            if ($read_time)    {
                chomp;@_=split(" ",$_);$time=$_[1] ;$value_current=$_[2];#print "$time $value_current\n";
                if ($time=~m/(\d+\.\d+)(\S+)/) { $t=$1;$unit=$2;} elsif ($time=~m/(\d+)(\S+)/) {$t=$1;$unit=$2;}
                if ($group) {$cpm_hash{$cpm_name}{$group}{$current_sig}{$t}=$value_current} 
                else {$cpm_hash{$cpm_name}{$current_sig_name}{$t}=$value_current} 
                if ($line_no==0 ) { $t0=$t}
                if ($line_no==1 ) { $t1=$t} 
                if ($line_no==2 ) {
                    $t2=$t ;
                    if (!$time_step)    {$time_step=$t2-$t1;}
                    $read_time=0; $step=1;
                }
                $line_no++;
            } 
            if ($step)    {              if (($_ !~ /^\+ R/)&&($_ !~ /^\+\s*\)/))     {
                    chomp;@_=split(" ",$_);;$time=$_[1];if ($time=~m/(\d+\.\d+)(\S+)/) { $t=$1;$unit=$2;} elsif ($time=~m/(\d+)(\S+)/) {$t=$1;$unit=$2;}
                    if ($group) {$$cpm_hash{$cpm_name}{$group}{$current_sig}{$t}=$_[2]} 
                    else {$$cpm_hash{$cpm_name}{$current_sig_name}{$t}=$_[2]} 
                    $prev_line=$_; next;    
                }    
                    #print $prev_line;
                    chomp $prev_line;@_=split(" ",$prev_line);$time=$_[1] ;
                    if ($time=~m/(\d+\.\d+)(\S+)/) { $end_time=$1;$unit=$2;} elsif ($time=~m/(\d+)(\S+)/) {$end_time=$1;$unit=$2;}
                    $step=0;
                    #print "\n End Time Detected :$end_time" ;
            }        
            if ($read_node)    {
                if($_ =~ /^\+/)    {    chomp;@_=split(" ",$_);shift(@_); $no_of_nodes+=scalar @_;    @nodes=(@nodes,@_);    }
                if ($_ !~ /^\+/)    {$read_node=0};
            }

            if ((/^I/)&&(! $t0))    {  $read_time=1; chomp;@_=split(" ",$_);
                $_=$_[0];
                
                if (/I_(\w+)_(cursig\d+)/i) { 
                    $group="$1"; $user{$group}=1; #print "\n $group $2" ;
                    $current_sig="I$2";
                
                }
                else {
                    $current_sig_name=$_[0];
                }
            }

            if (/^I/) {    
                $no_of_current_source++; 
                $step=1; 
                chomp;
                @_=split(" ",$_);
                $_=$_[0];
                
                #if ($_[0]=~m/I_(\S+)_(a-z\d+)/) { print "\n Group= $1"; }
                #if (/I(cursig\d+)/i) { print "\n Current= $1\n"; }
                if (/I_(\w+)_(cursig\d+)/i) { 
                    $group=$1; $user{$group}=1; #print "\n $group $2" ;
                    $current_sig="I$2";
                
                }
                else {
                    $current_sig_name=$_[0];
                }
            }
	    if (/^\* Average power/){
		chomp;@_=split(" ",$_);
		$power=$_[4];
		$power_units=$_[5];
	    }	
            if (/^.subckt adsPowerModel/)    { $read_node=1; }
        }
        foreach $group (keys %user) {
            @user_group=(@user_group,$group);
        }
        if ($log)
        {
        #print $log "\nCPM file : $cpm_file" ;
        #print $log "\nSim Start Time : $t0 $unit, Sim End Time : $end_time $unit , Simulation Time Step : $time_step $unit" ;
        #print $log "\nNo of Current Source  : $no_of_current_source" ;
        #print $log "\nNo of Ports  : $no_of_nodes" ;
        #print $log "\nName of Ports  : @nodes " ;
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
	$$cpm_hash{$cpm_name}{"Average Power"}=$power;
	$$cpm_hash{$cpm_name}{"Power Units"}=$power_units;
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

#cpm_info("dir1/vcd_cpm.sp",\%cpm_details);
#use Data::Dumper;
#print Dumper (\%cpm_details);

# Algorithm : add all the cpm hash current together ,resultant is the first cpm  
# Sub-routine call : stack(LOG_FILE,@cpm);
#temp cpm1 being used to differentiate between wether dead time is added or not and hence know wether to do the stitch operation when inserting dead time.
sub stack
{   #@_=@cpm_list_for_a_sequence; The passed values to stack are the log file, an array of cpm names being stacked,and an array of scale values
    $log=shift (@_);
    @cpm_to_be_stack_with_scale=();
    $cnt=0;
#   print "\n $log";
    #print join(",",@_);
    if ($resultant_cpm)  {$cpm_details{"temp_cpm1"}=();$resultant_cpm="temp_cpm1";    }
    else {$resultant_cpm="temp_cpm";    }
    #print join(",",@_);
    foreach (@_){
    	if($_ !~ m/\^d+/) {
    		$cpm_to_be_stack_with_scale[$cnt] = shift(@_);#array for names of cpm's being stacked.The cpm names have the scale values attacehd to it.
    		$cnt++;
    	}else {goto STOP;}
	
    }
    STOP:	
    $cnt=0;
    @cpm_scale= @_;#array for scale values 
    #print "\n The Resultant CPM : $resultant_cpm , CPM's which are needed to be added to resultant CPM : @cpm_to_be_stack_with_scale; cpm scale array :@cpm_scale\n" ;
    foreach (@cpm_to_be_stack_with_scale){
    chomp;@_=split(m/\(/,$_);
    $cpm_to_be_stack[$cnt] =$_[0];
    $cnt++;
    }
    $cnt=0;
    #print "\n The Resultant CPM : $resultant_cpm , CPM's which are needed to be added to resultant CPM : @cpm_to_be_stack cpm:scale @cpm_scale" ;
    #The following metrics for all these CPM Must be same to be able to stacked on top of each other   :  
    #"Start Time" and "End Time" ;
    @metrics = ("Start Time","End Time");
    foreach $metric (@metrics)    {
        $flag=0;
    #    print "\n Metric Checking : $metric ";
        foreach $testcase (@cpm_to_be_stack) {
        #    print "\n Testcase : $testcase  ";    
            if ($testcase =~ m/(\w+\d*)::(\w+\d*)/i) {
            
                if ($flag ==0) {  $old=$cpm_details{$1}{$metric};$flag=1;}    
                else {
                    $val=$cpm_details{$1}{$metric};
                #  print "\n Old Value :$old New Value :$val" ;
                    if ($old ne $val) { print "\nERROR : $metric $val is not matching for $1 with $old on other CPM files , Cannot Stack the CPM\n\n" ;
                        print LOG_FILE "\nERROR : $metric $val is not matching for $1 with $old on other CPM files , Cannot Stack the CPM\n\n" ;
                        exit;
                    }
                }
            } else {
                #print "\n Testcase : $testcase ";
                if ($flag ==0) { $old=$cpm_details{$testcase}{$metric};$flag=1;}     
                else {
                    $val=$cpm_details{$testcase}{$metric};                      #  print "\n Old Value :$old New Value :$val" ;

                    if ($old ne $val) { print "\nERROR : $metric $val is not matching for $testcase with $old on other CPM files , Cannot Stack the CPM\n\n" ;
                        print LOG_FILE "\nERROR : $metric $val is not matching for $testcase with $old on other CPM files , Cannot Stack the CPM\n\n" ;
                        exit;
                    }
                }
            }
        }
    }    
    
    # Now Add up all the currents 
    if (@cpm_to_be_stack[0] =~ m/(\w+\d*)::(\w+\d*)/i) 
    { 
        $cpm=$1;$group=$2; 
        foreach $metric (keys %{$cpm_details{$cpm}{$group}})    {
            #print "\n$metric";
            if ($metric =~ /cursig/)    {
                #    print "\n\n\n Summing up for Cursig : $metric ";
                foreach $time_instant (keys %{$cpm_details{$cpm}{$group}{$metric}})    {
                #    print "\n\n Time Instant :$time_instant" ;
                    $summ_of_cpm_to_be_stack=0;
		    $cnt=0;
                        foreach $testcase (@cpm_to_be_stack) {
                #            print "\n Testcase : $testcase";
                            #print "\n Metric : $metric";
                            if ($testcase =~ m/(\w+\d*)::(\w+\d*)/i) {
                                $cpm=$1;$group=$2 ;
                #                print "\n CPM : $cpm , Group : $group , Cursig : $metric , Time Instant : $time_instant , Value = $cpm_details{$cpm}{$group}{$metric}{$time_instant} ";
                                $summ_of_cpm_to_be_stack+=$cpm_details{$cpm}{$group}{$metric}{$time_instant}*$cpm_scale[$cnt];
                            }
                            else { 
#                                print "\n CPM : $testcase , Cursig : $metric , Time Instant : $time_instant , Value = $cpm_details{$testcase}{$metric}{$time_instant} ";
                                $summ_of_cpm_to_be_stack+=$cpm_details{$testcase}{$metric}{$time_instant}*$cpm_scale[$cnt];
                            }
			    $cnt++;
                        }
                    #print "\n $time_instant , $cpm_details{$resultant_cpm}{$metric}{$time_instant} , $summ_of_cpm_to_be_stack ";
#                    print "\n Total Sum : $summ_of_cpm_to_be_stack" ;
                    $cpm_details{$resultant_cpm}{$metric}{$time_instant}+=$summ_of_cpm_to_be_stack;
                }
            }
        }
        $cpm_details{$resultant_cpm}{"Time Step"}=$cpm_details{$cpm}{"Time Step"};
        $cpm_details{$resultant_cpm}{"End Time"}=$cpm_details{$cpm}{"End Time"};
        $cpm_details{$resultant_cpm}{"Unit"}=$cpm_details{$cpm}{"Unit"};
        $cpm_details{$resultant_cpm}{"Start Time"}=$cpm_details{$cpm}{"Start Time"};    
        print $log "\n@cpm_to_be_stack stacked successfully ,resultant cpm : $resultant_cpm " ;
        if ($resultant_cpm eq "temp_cpm1")    { stitch (LOG_FILE,"temp_cpm",$resultant_cpm);}
    }else {
        $cpm_0=@cpm_to_be_stack[0];
	#print "\n$cpm_0,$cpm_1\n";
        foreach $metric (keys %{$cpm_details{$cpm_0}})    {
            #print "\n$metric";
            if ($metric =~ /cursig/)    {#choosing the cursig metric from no.of ports start time end time,no.of sources etc..
                #print "\n\n\n Summing up for Cursig : $metric ";
                foreach $time_instant (keys %{$cpm_details{$cpm_0}{$metric}})    {#Once cursig is found checking for each time stamp
                    #print "\n\n Time Instant :$time_instant" ;
                    $summ_of_cpm_to_be_stack=0;
		    $cnt=0;
                        foreach $testcase (@cpm_to_be_stack) {#for each of the cpm that are being stacked eg. cpm1 cpm1 cpm1.Here we take cpm1 thrice one by one.
                #            print "\n Testcase : $testcase";
                            #print "\n Metric : $metric";
                            if ($testcase =~ m/(\w+\d*)::(\w+\d*)/i) {
                                $cpm=$1;$group=$2 ;
                #                print "\n CPM : $cpm , Group : $group , Cursig : $metric , Time Instant : $time_instant , Value = $cpm_details{$cpm}{$group}{$metric}{$time_instant} ";
                                $summ_of_cpm_to_be_stack+=$cpm_details{$cpm}{$group}{$metric}{$time_instant}*$cpm_scale[$cnt];
                            }
                            else { 
                #                print "\n CPM : $testcase , Cursig : $metric , Time Instant : $time_instant , Value = $cpm_details{$testcase}{$metric}{$time_instant} ";
                                $summ_of_cpm_to_be_stack+=$cpm_details{$testcase}{$metric}{$time_instant}*$cpm_scale[$cnt];
                            }
			    $cnt++;
                        }
                    #print "\n $time_instant , $cpm_details{$resultant_cpm}{$metric}{$time_instant} , $summ_of_cpm_to_be_stack ";
                #    print "\n Total Sum : $summ_of_cpm_to_be_stack" ;
                    $cpm_details{$resultant_cpm}{$metric}{$time_instant}+=$summ_of_cpm_to_be_stack;
                }
            }
        }
        $cpm_details{$resultant_cpm}{"Time Step"}=$cpm_details{$cpm_to_be_stack[0]}{"Time Step"};
        $cpm_details{$resultant_cpm}{"End Time"}=$cpm_details{$cpm_to_be_stack[0]}{"End Time"};
        $cpm_details{$resultant_cpm}{"Unit"}=$cpm_details{$cpm_to_be_stack[0]}{"Unit"};
        $cpm_details{$resultant_cpm}{"Start Time"}=$cpm_details{$cpm_to_be_stack[0]}{"Start Time"};    
        print $log "\n@cpm_to_be_stack stacked successfully ,resultant cpm : $resultant_cpm " ;
        if ($resultant_cpm eq "temp_cpm1")    { stitch (LOG_FILE,"temp_cpm",$resultant_cpm);}
    }
       
} 
# Algorithm : add cpm2 at the end of cpm1,i.e simulation times is added up  
# Sub-routine call : stitch(cpm1,cpm2,out_file,LOG_FILE);
sub stitch
{    
    ($log,$resultant_cpm,$cpm2)=(@_);    
    $end_time_cpm1=$cpm_details{$resultant_cpm}{"End Time"};
    if (!$resultant_cpm) {
        $resultant_cpm="temp_cpm";
        #print "\n inital run ,i.e create a temp_cpm with properties of cpm2 " ; 
        if ($cpm2 =~ m/(\w+\d*)::(\w+\d*)/i) 
        {     
            $cpm=$1;$group=$2; 
            foreach $metric (keys %{$cpm_details{$cpm}{$group}})    {
                if ($metric =~ /^I/)    {
                    #print "\n Metric :$metric" ;
                    foreach $time_instant (sort{ $a <=> $b }  keys %{$cpm_details{$cpm}{$group}{$metric}}) {
                        $cpm_details{$resultant_cpm}{$metric}{$time_instant}=$cpm_details{$cpm}{$group}{$metric}{$time_instant};
                    }
                }
            }
            $cpm_details{$resultant_cpm}{"Time Step"}=$cpm_details{$cpm}{"Time Step"};
            $cpm_details{$resultant_cpm}{"End Time"}=$cpm_details{$cpm}{"End Time"};
            $cpm_details{$resultant_cpm}{"Unit"}=$cpm_details{$cpm}{"Unit"};
            $cpm_details{$resultant_cpm}{"Start Time"}=$cpm_details{$cpm}{"Start Time"};
            $cpm_details{$resultant_cpm}{"Added Dead Time Recently"}=0;
            print $log "\n$resultant_cpm and $cpm :: $group stiched successfully ,resultant cpm : $resultant_cpm" ;
        }    else    {
            foreach $metric (keys %{$cpm_details{$cpm2}})    {
                if ($metric =~ /^I/)    {
                #print "\n Metric :$metric" ;
                    foreach $time_instant (sort{ $a <=> $b }  keys %{$cpm_details{$cpm2}{$metric}}) {
                        $cpm_details{$resultant_cpm}{$metric}{$time_instant}=$cpm_details{$cpm2}{$metric}{$time_instant};
                    }
                }
            }
            $cpm_details{$resultant_cpm}{"Time Step"}=$cpm_details{$cpm2}{"Time Step"};
            $cpm_details{$resultant_cpm}{"End Time"}=$cpm_details{$cpm2}{"End Time"};
            $cpm_details{$resultant_cpm}{"Unit"}=$cpm_details{$cpm2}{"Unit"};
            $cpm_details{$resultant_cpm}{"Start Time"}=$cpm_details{$cpm2}{"Start Time"};
            $cpm_details{$resultant_cpm}{"Added Dead Time Recently"}=0;
            print $log "\n$resultant_cpm and $cpm2 stiched successfully ,resultant cpm : $resultant_cpm" ;
        }
        
    } else {
    
    if ($cpm2 =~ m/(\w+\d*)::(\w+\d*)/i) 
        {     
        $cpm=$1;$group=$2; 
        #print "\n CPM1 :$resultant_cpm CPM2 :$cpm2 End Time of CPM1 :$end_time_cpm1" ;
        foreach $metric (keys %{$cpm_details{$cpm}{$group}})    {
                if ($metric =~ /^I/)    {
                #print "\n Metric :$metric" ;

                foreach $time_instant (sort{ $a <=> $b }  keys %{$cpm_details{$cpm}{$group}{$metric}})    {
                #    print "\n $time_instant $cpm_details{$cpm2}{$metric}{$time_instant} " ;
                    $new_time=sprintf("%.6f",$end_time_cpm1 + $time_instant);
                    if ($new_time==$end_time_cpm1)    {
                        #Point of Discontinuity , Check $overlap_handling and do the required only if recently dead time is not added 
                        if ( $cpm_details{$resultant_cpm}{"Added Dead Time Recently"} == 0 ) {
			print "the overlap handling defined as ";
			    if(!defined $overlap){ $overlap = "SUM";}
                            print "\n Doing Overlap Handing now as :$overlap" ;
                            if ($overlap =~ /SUM/i) {
                                $cpm_details{$resultant_cpm}{$metric}{$new_time}=($cpm_details{$resultant_cpm}{$metric}{$end_time_cpm1}+$cpm_details{$cpm}{$group}{$metric}{$time_instant});
                            }elsif ($overlap =~ /AVERAGE/i || $overlap =~ /AVG/i) {
			    print "overlapping done as average $overlap";
                                $cpm_details{$resultant_cpm}{$metric}{$new_time}=($cpm_details{$resultant_cpm}{$metric}{$end_time_cpm1}+$cpm_details{$cpm}{$group}{$metric}{$time_instant})/2;
                            }elsif ($overlap =~ /FIRST/i ) {
                                $cpm_details{$resultant_cpm}{$metric}{$new_time}=$cpm_details{$resultant_cpm}{$metric}{$end_time_cpm1};
                            }elsif ($overlap =~ /SECOND/i ) {
                                $cpm_details{$resultant_cpm}{$metric}{$new_time}=$cpm_details{$cpm}{$group}{$metric}{$time_instant};
                            }elsif ($overlap =~ /MAX/i ) {
                                if ($cpm_details{$resultant_cpm}{$metric}{$end_time_cpm1}>=$cpm_details{$cpm}{$group}{$metric}{$time_instant})    {
                                    $cpm_details{$resultant_cpm}{$metric}{$new_time}=$cpm_details{$resultant_cpm}{$metric}{$end_time_cpm1};
                                }
                                else {
                                    $cpm_details{$resultant_cpm}{$metric}{$new_time}=$cpm_details{$cpm}{$group}{$metric}{$time_instant};
                                }
                            }elsif ($overlap =~ /MIN/i ) {
			    	if ($cpm_details{$resultant_cpm}{$metric}{$end_time_cpm1}<=$cpm_details{$cpm}{$group}{$metric}{$time_instant})    {
                                    $cpm_details{$resultant_cpm}{$metric}{$new_time}=$cpm_details{$resultant_cpm}{$metric}{$end_time_cpm1};
                                }
                                else {
                                    $cpm_details{$resultant_cpm}{$metricl}{$new_time}=$cpm_details{$cpm}{$group}{$metric}{$time_instant};
                                }
			    }			    	
			} 
			else {
                            $cpm_details{$resultant_cpm}{$metric}{$new_time}=($cpm_details{$resultant_cpm}{$metric}{$end_time_cpm1}+$cpm_details{$cpm}{$group}{$metric}{$time_instant});
                        	}
                    }
                    else {
                        $cpm_details{$resultant_cpm}{$metric}{$new_time}= $cpm_details{$cpm}{$group}{$metric}{$time_instant};
                    }
                }
            }
        }
        $cpm_details{$resultant_cpm}{"End Time"}=$new_time;
        $cpm_details{$resultant_cpm}{"Added Dead Time Recently"}=0;
        print $log "\n$resultant_cpm and $cpm :: $group stiched successfully ,resultant cpm : $resultant_cpm" ;
    } else     {
            #print "\n CPM1 :$resultant_cpm CPM2 :$cpm2 End Time of CPM1 :$end_time_cpm1" ;
            foreach $metric (keys %{$cpm_details{$cpm2}})    {
                if ($metric =~ /^I/)    {
                #print "\n Metric :$metric" ;

                foreach $time_instant (sort{ $a <=> $b }  keys %{$cpm_details{$cpm2}{$metric}})    {
                #    print "\n $time_instant $cpm_details{$cpm2}{$metric}{$time_instant} " ;
                    $new_time=sprintf("%.6f",$end_time_cpm1 + $time_instant);
                    if ($new_time==$end_time_cpm1)    {
                        #Point of Discontinuity , Check $overlap_handling and do the required only if recently dead time is not added 
                        if ( $cpm_details{$resultant_cpm}{"Added Dead Time Recently"} == 0 )     {
			    if (!defined $overlap){ $overlap = "SUM";}
                            #print "\n Doing Overlap Handling now as :$overlap" ;
                            if ($overlap =~ /SUM/i) {
                                $cpm_details{$resultant_cpm}{$metric}{$new_time}=($cpm_details{$resultant_cpm}{$metric}{$end_time_cpm1}+$cpm_details{$cpm2}{$metric}{$time_instant});#print "values :$cpm_details{$cpm2}{$metric}{$time_instant}\n";
                            }elsif ($overlap =~ /AVERAGE/i || $overlap =~ /AVG/i) {
                                $cpm_details{$resultant_cpm}{$metric}{$new_time}=($cpm_details{$resultant_cpm}{$metric}{$end_time_cpm1}+$cpm_details{$cpm2}{$metric}{$time_instant})/2;
                            }elsif ($overlap =~ /FIRST/i ) {
			    	#:print "\n I am here " ;
                                $cpm_details{$resultant_cpm}{$metric}{$new_time}=$cpm_details{$resultant_cpm}{$metric}{$end_time_cpm1};
                            }elsif ($overlap =~ /SECOND/i ) {
                                $cpm_details{$resultant_cpm}{$metric}{$new_time}=$cpm_details{$cpm2}{$metric}{$time_instant};
                            }elsif ($overlap =~ /MAX/i ) {
                                if ($cpm_details{$resultant_cpm}{$metric}{$end_time_cpm1}>=$cpm_details{$cpm2}{$metric}{$time_instant})    {
                                    $cpm_details{$resultant_cpm}{$metric}{$new_time}=$cpm_details{$resultant_cpm}{$metric}{$end_time_cpm1};
                                }
                                else {
                                    $cpm_details{$resultant_cpm}{$metric}{$new_time}=$cpm_details{$cpm2}{$metric}{$time_instant};
                                }
                            }elsif ($overlap =~ /MIN/i ) {
			    	if ($cpm_details{$resultant_cpm}{$metric}{$end_time_cpm1} <= $cpm_details{$cpm2}{$metric}{$time_instant})    {
                                	$cpm_details{$resultant_cpm}{$metric}{$new_time}=$cpm_details{$resultant_cpm}{$metric}{$end_time_cpm1};
				}
                                else {
                                	$cpm_details{$resultant_cpm}{$metric}{$new_time}=$cpm_details{$cpm2}{$metric}{$time_instant};
                                }
			    }			    
                        } 
			else {
                            $cpm_details{$resultant_cpm}{$metric}{$new_time}=($cpm_details{$resultant_cpm}{$metric}{$end_time_cpm1}+$cpm_details{$cpm2}{$metric}{$time_instant});
                        	} 
                    }
                    else {
                        $cpm_details{$resultant_cpm}{$metric}{$new_time}= $cpm_details{$cpm2}{$metric}{$time_instant};
                    }
                }
                }
            }
            $cpm_details{$resultant_cpm}{"End Time"}=$new_time;
            $cpm_details{$resultant_cpm}{"Added Dead Time Recently"}=0;
            print $log "\n$resultant_cpm and $cpm2 stiched successfully ,resultant cpm : $resultant_cpm" ;
        }
    }
}

sub dump_resultant_hash_to_file
{    
    ($log,$op_file,$resultant_cpm,$cpm1)=(@_);
    # Find the inc file copy
    open fp , "$inc";
#    while (<fp>)    {
#        if ($_ =~ /INCLUDE/ )    { chomp;@_=split(" ",$_);@i=split("\"",$_[1]);@inc=split("/",$inc); print "\Inc now is @inc";$path="@inc/$i[1]";last ;};    
#    } 
    $path="$inc.inc" ;
    if (-e $path ) {system ("cp $path $output.inc");}
    else { 
        print $log "\n WARNING ! Inc file not present in given path : $path \nCPM Editor will proceed without inc file\nPlease modify the output CPM file to include the correct inc file before you use it in simulation!";
    }
    
    #print "\n$op_file,$resultant_cpm,$}cpm1 ";
    $unit=$cpm_details{$resultant_cpm}{"Unit"};
    #print "\n Unit : $unit";
    open xgraph_file, ">$output.xgraph" ;
    if (open(out,">$op_file") && open (cpm_file1,$cpm1))    {
        $start=$start2=0;$flag1=$flag2=0;$flag_1=1;
        while($line1=<cpm_file1> )    
        {
            if ($end_currentsig==1) {
                if (($line1 !~ /^\+ R/)&&($line1 !~ /^\+\s*\)/)) { next; }
                else {print out "+)" ;$start=0; $end_currentsig=0; next;}
            }    
            if ($line1 =~ /^I/) { $start=1; }      
            if ($start==0) {
	    	if ($line1 =~ /\*.Apache.RedHawk/) {
		   print out "*************************************************************\n";
		   print out "$line1";
		   $x=`date`;
		   @_=split('\s+',$x);
		   $month="$_[1]";$date=$_[2];$time=$_[3];$year=$_[5];
		   @_=split('\:',$time);
		   $hr=$_[0];$minute=$_[1];
		   print out "* File created by CPM Editor on $date-$month-$year| $hr:$minute\n";
		   print out "*************************************************************\n";
		}
		if ($line1 =~ /INCLUDE/ ) { 
		   print out "\n.INCLUDE \"$output.inc\" \n\n";
		}
		if ($line1 =~ /\*.Begin.Chip.Package/){
		   $flag2=1;
		}
		if (($line1 =~ /\*.CPM.Port.Name/)||($line1 =~ /\*.Average.power/)){
		      $flag2=0;
		}
		if ($flag2){
		   print out "$line1";
		}
		if ($line1 =~ /\.ends/){print out "\n.ends";}     
	    } 	
            else {
                # Copy the current sig from $resultant_cpm and put to out till we find end of this current sig .
                #print "\n Now Copy :$line1" ;
                chomp $line1;@line1=split(" ",$line1); $cursig=$line1[0];$Isig=shift(@line1);	
                if ($cursig =~ /I_(\w+)_(cursig\d+)/i) { 
			$cursig="I$2";
			if($flag_1)	{
				$group_number=$1;
				$flag_1=0;
			}
			if($1 ne $group_number) {
				print out "\n.ends";	
				last;
			} 
		}
		#use Data::Dumper;
		#print Dumper (\%cpm_details);
		print out "\n$cursig @line1\n";
                #print "\n Current Signature : $cursig ";
                print xgraph_file "\n\"$cursig\n";                                
                foreach $time_instant (sort{ $a <=> $b }  keys %{$cpm_details{$resultant_cpm}{$cursig}})    {
                        print out "+ $time_instant$unit $cpm_details{$resultant_cpm}{$cursig}{$time_instant}\n";
                        print xgraph_file "$time_instant$unit $cpm_details{$resultant_cpm}{$cursig}{$time_instant}\n" ;
                }
                $start=0;
                $end_currentsig=1;
            }
        }
    }
    close $out ;
    print $log "\nOutput CPM $op_file created successfully" ;
    print "\nOutput CPM $op_file and Xgraph file $output.xgraph created successfully\n" ;
}


# Algorithm : Add Dead time at the end of cpm1 in steps
# Sub-routine call : insert_dead_time(LOG_FILE,$resultant_cpm,$dead_time)
sub insert_dead_time
{    
    ($log,$cpm1,$dead_time,$cpm_name,$dc_or_leakage)=(@_);
    $cpm_name=$_[3];$cpm_name_copy=$cpm_name;#print "$cpm1,$dead_time";
    $dc_or_leakage= $_[4];
    $resultant_cpm=$cpm1;
    $steps=0;
    $end_time_resultant=$cpm_details{$resultant_cpm}{"End Time"};
    $step_resultant=$cpm_details{$resultant_cpm}{"Time Step"};
    #print "\n $step_resultant";
    $unit_resultant=$cpm_details{$resultant_cpm}{"Unit"};
    if ($dead_time=~m/(\d+\.\d+)(\S+)/) { $t=$1;$unit=$2;} elsif ($dead_time=~m/(\d+)(\S+)/) {$t=$1;$unit=$2;}
    $time_to_add=$t;
    if ($dead_time=~m/(\d+\.\d+)(\S+)/) { $t=$1;$unit=$2;} elsif ($dead_time=~m/(\d+)(\S+)/) {$t=$1;$unit=$2;}
    if (!($unit eq "s" || $unit eq "ms" || $unit eq "us" || $unit eq "ns" || $unit eq "ps" || $unit eq "fs" || $unit =~ /e+/ || $unit =~ /e-/))
    {
        print $log "ERROR ! Dead Time unit : $unit is not matching with allowed units : s,ms,us,ns,ps,fs or scientific notation  e-0,e+0,e-3,e-6,e-9,e-12,e-15\n";
        print "ERROR ! Dead Time unit : $unit is not matching with allowed units : s,ms,us,ns,ps,fs or scientific notation  e-0,e+0,e-3,e-6,e-9,e-12,e-15\n";
        exit;
    }
    # Convert DEAD_TIME to same unit as of resultant_time
    if ($unit ne $unit_resultant)    {
        $factor=unit_multiplier($unit_resultant,$unit,$log);
        $t=$t*$factor;
        $time_to_add=$t;    
        #print "\n $t $unit_resultant to be insterted ";    
    }
    if ($time_to_add >=2*$step_resultant)    
    {
        $first_time_step_for_dead_time=sprintf("%.6f",$end_time_resultant+$step_resultant);
        $second_last_time_step_for_dead_time=sprintf("%.6f",$end_time_resultant+$time_to_add-$step_resultant);
        $last_time_step_for_dead_time=sprintf("%.6f",$end_time_resultant+$time_to_add);
        foreach $metric (keys %{$cpm_details{$resultant_cpm}})    {
            if ($metric =~ /^I/ && $first==0)    {$cpm_name=$cpm_name_copy;
		if ($dc_or_leakage =~ /DC/){
		$cpm_details{$resultant_cpm}{$metric}{$first_time_step_for_dead_time}=$cpm_name;
                $cpm_details{$resultant_cpm}{$metric}{$second_last_time_step_for_dead_time}=$cpm_name;
                $cpm_details{$resultant_cpm}{$metric}{$last_time_step_for_dead_time}=$cpm_name;

		}elsif($dc_or_leakage =~ /^LEAKAGE_CPM/){$t="0.000000";$t=sprintf("%.6f",$t);
			if($cpm_name =~ m/(\w+\d*)::(\w+\d*)/i ){
                $group=$2;$cpm_name=$1;
		$cpm_details{$resultant_cpm}{$metric}{$first_time_step_for_dead_time}=$cpm_details{$cpm_name}{$group}{$metric}{$t};
                $cpm_details{$resultant_cpm}{$metric}{$second_last_time_step_for_dead_time}=$cpm_details{$cpm_name}{$group}{$metric}{$t};
                $cpm_details{$resultant_cpm}{$metric}{$last_time_step_for_dead_time}=$cpm_details{$cpm_name}{$group}{$metric}{$t};
			}else{
		$cpm_details{$resultant_cpm}{$metric}{$first_time_step_for_dead_time}=$cpm_details{$cpm_name}{$metric}{$t};
                $cpm_details{$resultant_cpm}{$metric}{$second_last_time_step_for_dead_time}=$cpm_details{$cpm_name}{$metric}{$t};
                $cpm_details{$resultant_cpm}{$metric}{$last_time_step_for_dead_time}=$cpm_details{$cpm_name}{$metric}{$t};

			}
		}else{
		$cpm_details{$resultant_cpm}{$metric}{$first_time_step_for_dead_time}=0;
                $cpm_details{$resultant_cpm}{$metric}{$second_last_time_step_for_dead_time}=0;
                $cpm_details{$resultant_cpm}{$metric}{$last_time_step_for_dead_time}=0;

		}
            }
        }
        $cpm_details{$resultant_cpm}{"End Time"}=$last_time_step_for_dead_time;
        $cpm_details{$resultant_cpm}{"Added Dead Time Recently"}=1;
        print $log "\nSuccesfully insterted a Dead Time of $dead_time to $resultant_cpm ";
    }    
    else     
    {    
        $min_dead_time=2*$step_resultant;
        print $log "ERROR ! Dead Time too small,must be >= 2*time_step of cpm file, which in this case is $min_dead_time $unit_resultant\n";
        print "ERROR ! Dead Time too small,must be >= 2*time_step of cpm file, which in this case is $min_dead_time $unit_resultant\n";
        exit;
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


sub insert_dead_time_at_begining {
    ($log,$dead_time,$resultant_cpm)=(@_);    
    #print "\n Dead time : $dead_time to be added to $cpm1 \n";
    $step=$cpm_details{$resultant_cpm}{"Time Step"};
    $unit_resultant=$cpm_details{$resultant_cpm}{"Unit"};    
    if ($dead_time=~m/(\d+\.\d+)(\S+)/) { $t=$1;$unit=$2;} elsif ($dead_time=~m/(\d+)(\S+)/) {$t=$1;$unit=$2;}
    if ($dead_time=~m/(\d+\.\d+)(\S+)/) { $t=$1;$unit=$2;} elsif ($dead_time=~m/(\d+)(\S+)/) {$t=$1;$unit=$2;}
    $time_to_add=$t;
    if (!($unit eq "s" || $unit eq "ms" || $unit eq "us" || $unit eq "ns" || $unit eq "ps" || $unit eq "fs" || $unit =~ /e+/ || $unit =~ /e-/))
    {
        print $log "ERROR ! Dead Time unit : $unit is not matching with allowed units : s,ms,us,ns,ps,fs or scientific notation  e-0,e+0,e-3,e-6,e-9,e-12,e-15\n";
        print "ERROR ! Dead Time unit : $unit is not matching with allowed units : s,ms,us,ns,ps,fs or scientific notation  e-0,e+0,e-3,e-6,e-9,e-12,e-15\n";
        exit;
    }
    # Convert DEAD_TIME to same unit as of resultant_time
    if ($unit ne $unit_resultant)    {
        $factor=unit_multiplier($unit_resultant,$unit,$log);
        $t=$t*$factor;
        $time_to_add=$t;    
        #print "\n $t $unit_resultant to be inserted ";    
    }
    $resultant_cpm="temp_cpm";    
    #print "\n Time to add:$time_to_add ";
    foreach $metric (keys %{$cpm_details{$resultant_cpm}})    {
        if ($metric =~ /^I/)    {
        #print "\n Metric :$metric" ;
            foreach $time_instant (sort{ $a <=> $b }  keys %{$cpm_details{$resultant_cpm}{$metric}}) {
                $new_time_instant=$time_instant+$time_to_add;
                $new_time_instant=sprintf("%.6f",$new_time_instant);
                $new_cpm_details{$resultant_cpm}{$metric}{$new_time_instant}=$cpm_details{$resultant_cpm}{$metric}{$time_instant};
                delete($cpm_details{$resultant_cpm}{$metric}{$time_instant});
            }
	    foreach $new_time_instant(sort {$a <=> $b } keys %{$new_cpm_details{$resultant_cpm}{$metric}}) {
	    	$cpm_details{$resultant_cpm}{$metric}{$new_time_instant}=$new_cpm_details{$resultant_cpm}{$metric}{$new_time_instant};
	    }
	    #@cpm_details{$resultant_cpm}{$metric} = @new_cpm_details{$resultant_cpm}{$metric};
            $zero=0;
            $time_instant=sprintf("%.6f",$zero);
            $cpm_details{$resultant_cpm}{$metric}{$time_instant}=0;
            $second_last=$time_to_add-$step;
            $time_instant=sprintf("%.6f",$second_last);
            $cpm_details{$resultant_cpm}{$metric}{$time_instant}=0;
        }
    }
    $cpm_details{$resultant_cpm}{"End Time"}=sprintf("%.6f",$cpm_details{$resultant_cpm}{"End Time"}+$time_to_add);
    print $log "\nDead time :$dead_time added to $resultant_cpm successfully at the begining ,resultant cpm : $resultant_cpm" ;
}

sub stack_with_all_time_stamps
{   #@_=@cpm_list_for_a_sequence; The passed values to stack are the log file, an array of cpm names being stacked,and an array of scale values
    $log=shift (@_);
    @cpm_to_be_stack_with_scale=();
    $cnt=0;
#   print "\n $log";
    #print join(",",@_);
    if ($resultant_cpm)  {$cpm_details{"temp_cpm1"}=();$resultant_cpm="temp_cpm1";}    
    else {$resultant_cpm="temp_cpm";    }
    #use Data::Dumper;print Dumper (\%cpm_details);
    foreach (@_){
    	if($_ !~ m/\^d+/) {
    		$cpm_to_be_stack_with_scale[$cnt] = shift(@_);#array for names of cpm's being stacked.The cpm names have the scale values attacehd to it.
    		$cnt++;
    	}else {goto STOP;}
	
    }
    STOP:	
    $cnt=0;
    @cpm_scale= @_;#array for scale values 
    #print "\n The Resultant CPM : $resultant_cpm , CPM's which are needed to be added to resultant CPM : @cpm_to_be_stack_with_scale; cpm scale array :@cpm_scale\n" ;
    foreach (@cpm_to_be_stack_with_scale){
    chomp;@_=split(m/\(/,$_);
    $cpm_to_be_stack[$cnt] =$_[0];
    $cnt++;
    }
    $cnt=0;
    #print "@cpm_to_be_stack\n";
	undef @time_stamp;
    foreach $testcase (@cpm_to_be_stack){
    	if ($testcase =~ m/(\w+\d*)::(\w+\d*)/i) {
	   $cpm=$1;$group=$2;
	   foreach $metric (keys %{$cpm_details{$cpm}{$group}})    {
	   	if ($metric =~ /cursig/)    {
                   foreach $time_instant (sort {$a <=> $b} keys %{$cpm_details{$cpm}{$group}{$metric}})    {
			$time_instant_dummy=$time_instant;
			$time_stamp[$cnt]=$time_instant_dummy;
			$cnt++;
		   }
		}
	   }
	}else{
	   foreach $metric (keys %{$cpm_details{$testcase}})    {
	        #print "$metric\n";
		if ($metric =~ /cursig/)    {
		   #print "I am here\n";
                   foreach $time_instant (sort {$a <=> $b} keys %{$cpm_details{$testcase}{$metric}})    {
			#print "Value1 = $cpm_details{$testcase}{$metric}{$time_instant}\n";#print "$time_instant";
			$time_instant_dummy=$time_instant;
			$time_stamp[$cnt]=$time_instant_dummy;
			$cnt++;
			#print "\n$metric";
		   }
		}
	   }
	}  
    }
    #print "@time_stamp\n";
    $seen=();
    uniqe_array(\%seen,@time_stamp);
    #@time_stamp=@r;
    #print "@time_stamp\n";
    #use Data::Dumper;
    #print Dumper(\%cpm_details);
    @time_stamp = sort{$a <=> $b} @time_stamp;
    #print "@time_stamp\n";    
    #Calculatin Values for all cpm's to be stacked for all time points   
    foreach $testcase(@cpm_to_be_stack) {
        if ($testcase =~ m/(\w+\d*)::(\w+\d*)/i) {
	   $cpm=$1;$group=$2;
	   foreach $metric (keys %{$cpm_details{$cpm}{$group}})    {
	        if ($metric =~ /cursig/)    {
    	           foreach $time_instant_all(@time_stamp){
	                foreach $time_instant (sort {$a <=> $b} keys %{$cpm_details{$cpm}{$group}{$metric}}){
	                     if ($time_instant < $time_instant_all) {
		                $prev_time_instant=$time_instant;
		      	        next;
		             }elsif ($time_instant > $time_instant_all) {
		                $value1=$cpm_details{$cpm}{$group}{$metric}{$time_instant};#print "$value1\n";
		                $value2=$cpm_details{$cpm}{$group}{$metric}{$prev_time_instant};
		                $cpm_details{$cpm}{$group}{$metric}{$time_instant_all}=((($value1-$value2)/($time_instant-$prev_time_instant))*$time_instant_all)+((($value1*$prev_time_instant)-($value2*$time_instant))/($prev_time_instant-$time_instant));
		                goto NEXT;
		             }elsif ($time_instant = $time_instant_all) {
		                $cpm_details{$cpm}{$group}{$metric}{$time_instant_all}=$cpm_details{$cpm}{$group}{$metric}{$time_instant};
		                goto NEXT;
	                     }  
	               }
	               NEXT :
	               next;
	           }  
	        }
	   }  	  
	}else{
	   foreach $metric (keys %{$cpm_details{$testcase}})    {
	        if ($metric =~ /cursig/)    {
	           foreach $time_instant_all(@time_stamp){
	                foreach $time_instant (sort {$a <=> $b} keys %{$cpm_details{$testcase}{$metric}}){
		             #print "$time_instant :$testcase\n";#print "$time_instant_all : $time_instant :Value1 = $cpm_details{$testcase}{$metric}{$time_instant}\n";#print "Value1 = $cpm_details{$testcase}{$metric}{$time_instant}\n";	
	                     if ($time_instant < $time_instant_all) {
		                $prev_time_instant=$time_instant;#print "$time_instant_all:$time_instant:$testcase\n";#print "$time_instant:$prev_time_instant:$testcase:$cpm_details{$testcase}{$metric}{$time_instant}\n";
		                next;
		             }elsif ($time_instant > $time_instant_all) {
		                $value1=$cpm_details{$testcase}{$metric}{$time_instant};
		                $value2=$cpm_details{$testcase}{$metric}{$prev_time_instant};#print "Time_stamp:$time_instant_all Value2:$value2 Time:$time_instant_prev Testcase:$testcase\n";
		                $cpm_details{$testcase}{$metric}{$time_instant_all}=((($value1-$value2)/($time_instant-$prev_time_instant))*$time_instant_all)+((($value1*$prev_time_instant)-($value2*$time_instant))/($prev_time_instant-$time_instant));
				goto NEXT;
		             }elsif ($time_instant = $time_instant_all) {
		                $cpm_details{$testcase}{$metric}{$time_instant_all}=$cpm_details{$testcase}{$metric}{$time_instant};
		                goto NEXT;
	                     }
	                }
	                NEXT :
	                next;
	           }
	        }                  	        	      	
	   }
	}
    }
    #use Data::Dumper;
    #print Dumper(\%cpm_details);
        		       	      
    $cnt=0;   
    #print "\n The Resultant CPM : $resultant_cpm , CPM's which are needed to be added to resultant CPM : @cpm_to_be_stack cpm:scale @cpm_scale" ;
        
    # Now Add up all the currents 
    if (@cpm_to_be_stack[0] =~ m/(\w+\d*)::(\w+\d*)/i) 
    { 
        $cpm=$1;$group=$2; 
        foreach $metric (keys %{$cpm_details{$cpm}{$group}})    {
            #print "\n$metric";
            if ($metric =~ /cursig/)    {
                #    print "\n\n\n Summing up for Cursig : $metric ";
                foreach $time_instant (@time_stamp)    {
                #    print "\n\n Time Instant :$time_instant" ;
                    $summ_of_cpm_to_be_stack=0;
		    $cnt=0;
                        foreach $testcase (@cpm_to_be_stack) {
                #            print "\n Testcase : $testcase";
                            #print "\n Metric : $metric";
                            if ($testcase =~ m/(\w+\d*)::(\w+\d*)/i) {
                                $cpm=$1;$group=$2 ;
                #                print "\n CPM : $cpm , Group : $group , Cursig : $metric , Time Instant : $time_instant , Value = $cpm_details{$cpm}{$group}{$metric}{$time_instant} ";
                                $summ_of_cpm_to_be_stack+=$cpm_details{$cpm}{$group}{$metric}{$time_instant}*$cpm_scale[$cnt];
                            }
                            else { 
#                                print "\n CPM : $testcase , Cursig : $metric , Time Instant : $time_instant , Value = $cpm_details{$testcase}{$metric}{$time_instant} ";
                                $summ_of_cpm_to_be_stack+=$cpm_details{$testcase}{$metric}{$time_instant}*$cpm_scale[$cnt];
                            }
			    $cnt++;
                        }
                    #print "\n $time_instant , $cpm_details{$resultant_cpm}{$metric}{$time_instant} , $summ_of_cpm_to_be_stack ";
#                    print "\n Total Sum : $summ_of_cpm_to_be_stack" ;
                    $cpm_details{$resultant_cpm}{$metric}{$time_instant}+=$summ_of_cpm_to_be_stack;
                }
            }
        }
        $cpm_details{$resultant_cpm}{"Time Step"}=$cpm_details{$cpm}{"Time Step"};
        $cpm_details{$resultant_cpm}{"End Time"}=$cpm_details{$cpm}{"End Time"};
        $cpm_details{$resultant_cpm}{"Unit"}=$cpm_details{$cpm}{"Unit"};
        $cpm_details{$resultant_cpm}{"Start Time"}=$cpm_details{$cpm}{"Start Time"};    
        print $log "\n@cpm_to_be_stack stacked successfully ,resultant cpm : $resultant_cpm " ;#use Data::Dumper;print Dumper (\%cpm_details);
        if ($resultant_cpm eq "temp_cpm1")    { stitch (LOG_FILE,"temp_cpm",$resultant_cpm);}
    }else {
        $cpm_0=@cpm_to_be_stack[0];
	#$cpm_1=@cpm_to_be_stack[1];
	#print "\n$cpm_0,$cpm_1\n";
        foreach $metric (keys %{$cpm_details{$cpm_0}})    {
#            print "\n$metric";
            if ($metric =~ /cursig/)    {#choosing the cursig metric from no.of ports start time end time,no.of sources etc..
                #print "\n\n\n Summing up for Cursig : $metric ";
                foreach $time_instant (@time_stamp)    {#Once cursig is found checking for each time stamp
                #    print "\n\n Time Instant :$time_instant" ;
                    $summ_of_cpm_to_be_stack=0;
		    $cnt=0;
                        foreach $testcase (@cpm_to_be_stack) {#for each of the cpm that are being stacked eg. cpm1 cpm1 cpm1.Here we take cpm1 thrice one by one.
                #            print "\n Testcase : $testcase";
                            #print "\n Metric : $metric";
                            if ($testcase =~ m/(\w+\d*)::(\w+\d*)/i) {
                                $cpm=$1;$group=$2 ;
                #                print "\n CPM : $cpm , Group : $group , Cursig : $metric , Time Instant : $time_instant , Value = $cpm_details{$cpm}{$group}{$metric}{$time_instant} ";
                                $summ_of_cpm_to_be_stack+=$cpm_details{$cpm}{$group}{$metric}{$time_instant}*$cpm_scale[$cnt];#
                            }
                            else { 
                #                print "\n CPM : $testcase , Cursig : $metric , Time Instant : $time_instant , Value = $cpm_details{$testcase}{$metric}{$time_instant} ";
                                $summ_of_cpm_to_be_stack+=$cpm_details{$testcase}{$metric}{$time_instant}*$cpm_scale[$cnt];
                            }
			    $cnt++;
                        }
                    #print "\n $time_instant , $cpm_details{$resultant_cpm}{$metric}{$time_instant} , $summ_of_cpm_to_be_stack ";
                #    print "\n Total Sum : $summ_of_cpm_to_be_stack" ;
                    $cpm_details{$resultant_cpm}{$metric}{$time_instant}+=$summ_of_cpm_to_be_stack;
                }
            }
        }
        $cpm_details{$resultant_cpm}{"Time Step"}=$cpm_details{$cpm_to_be_stack[0]}{"Time Step"};
        $cpm_details{$resultant_cpm}{"End Time"}=$cpm_details{$cpm_to_be_stack[0]}{"End Time"};
        $cpm_details{$resultant_cpm}{"Unit"}=$cpm_details{$cpm_to_be_stack[0]}{"Unit"};
        $cpm_details{$resultant_cpm}{"Start Time"}=$cpm_details{$cpm_to_be_stack[0]}{"Start Time"};    
        print $log "\n@cpm_to_be_stack stacked successfully ,resultant cpm : $resultant_cpm " ;#use Data::Dumper;print Dumper (\%resultant_cpm);
        if ($resultant_cpm eq "temp_cpm1")    { stitch (LOG_FILE,"temp_cpm",$resultant_cpm);}
    }
       
}
sub uniqe_array {
    ($seen,@time_stamp)=(@_); 
    foreach $a(@time_stamp){
	$seen{$a}=1;
    }
    @time_stamp=keys(%seen);
    %{$seen}=();
#	$seen=shift(@_);
#    #print"\n@_\n";
#    @time_stamp=@_;
#    foreach $a (@time_stamp) {
#        unless ($seen{$a}) {
#            push @r, $a;
#            $seen{$a} = 1;
#        }
#    }
#    @time_stamp=@r;
#    undef @r;
#    #$time_stamp_first_value=$time_stamp[0];
#    #print "@time_stamp";
#    #return @r;
}
