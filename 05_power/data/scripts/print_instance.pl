eval '(exit $?0)' && eval 'exec perl -S $0 ${1+"$@"}'
&& eval 'exec perl -S $0 $argv:q' if 0;

#!/usr/local/bin/perl
## $Revision: 1.1 $
# - Created by Kiran Joseph 3/1/08
# - Initial version
################################################################################################################
# Name       : print_instance.pl
# Description: Prints the switching / Non-Switching instances etc ..
# Author     : Kiran Joseph , email : kiran@apache-da.com
################################################################################################################

=head1 NAME


print_instance.pl - Prints the switching / Non-Switching instances etc ..

=head1 SYNOPSIS

print_instance.pl [Options] arguments

arguments : RH path design name

Options :   -type, -d, -outdir, -resolution, -start, -end,  -h ,-man , -bbox, -block,-net,-help

=head1 DESCRIPTION

<plot_switching.pl> plots switching waveforms as per user's requirements  namely :


=head4 celltype <memory | flop | combo | etc....> 


=head4 d <Redhawk run directory>
 

=head4 outdir <Output plot directory> 


=head4 resolution <resolution in ns) 


=head4 start <start_time in ns> 


=head4 end <end time in ns> 


=head4 bbox <x1 y1 x2 y2>  ( the co-ordinates of rectangular region )

=head4 net <net name>  

=head4 block <instance name>  

  

=head1 OPTIONS

=over

=item -h


Prints a synopsis and a description of program options.

=item -man

Prints the entire man page




=item -d

Specify the  <Redhawk run directory>  
( compulsory )




=item -outfile 

Specify the  <Output plot file> 
( Default value is ./outfile)



=item  -design

Specify the   <design name>   
 ( compulsory )






=item -start

Specify the   <start time in ns> 



=item -end

Specify the   <end time in ns>

( Default values of start & end are first & last switching times )


=item -bbox

Specify the   "<x1 y1 x2  y2>"  co-ordinates of the rectangular region you want to look for.
<x1 y1 > are co-ordinates of the lower left corner of the box & <x2  y2>  co-ordinates of 
the upper right corner.
Note : Please give all co-ordinates with in double quotes.




=head1 EXAMPLE

perl print_instance.pl  -d RH_run -outdir OUT  -start 2 -end 20  -bbox " 200 100 300 600" 

The output directory is outdir if not specified 


=back

=head1 AUTHOR

Kiran Joseph, Apache India

email : kiran@apache-da.com

=head1 COPYRIGHT

COPYRIGHT (c) 2007 Apache Design Solutions. All right reserved.

=cut

## end program documentation


use Getopt::Long;
use Pod::Usage;
GetOptions ('help'=>\$help,
            'd=s'=>\$Redhawkdir,
	    'outfile=s'=>\$Outputfile,
	    'start=s'=>\$start,
	    'end=s'=>\$end,
	    'bbox=s'=>\$bbox,
	    'design=s'=>\$design_name,
	    'man' => \$man  );
	    
	    

	    
pod2usage (-exitval => 0, -verbose => 1) if $help;
pod2usage (-exitval => 0, -verbose => 2) if $man;




printf "\n\n";
if ($help) {
exit;
}

if($Redhawkdir eq '')
{
 

if (-e ".apache/adsLib.output")
{$Redhawkdir = "./";
 }
 else
 {printf "\n\tERROR:  Current Directory isn't the RH run directory   \n";exit;}


 #printf "%50s\t%20s","\tERROR :Please Specify the RH directory  & run the script","\n";
#exit;
}

  $_=$design_name;
     if (/^\-/)
   {printf   "%40s","\n\n\t ERROR : No value Specified for design name.\n Please Enter Design name again\n";exit;}
  $_=$Redhawkdir;
     if (/^\-/)
   {printf   "%40s","\n\n\t ERROR :No value Specified for Redhawk directory.\n Please Enter Redhawk directory again\n";exit;}
   
 $_=$Outputfile;
     if (/^\-/)
   {printf   "%40s","\n\n\t ERROR :No value Specified for Output directory.\n Please Enter Output directory again\n";exit;}
 $_=$start;
     if (/^\-/)
   {printf   "%40s","\n\n\t ERROR :No value Specified for start.\n Please Enter start again\n";exit;}
  $_=$end;
     if (/^\-/)
   {printf   "%40s","\n\n ERROR :No value Specified for end.\n Please Enter end again\n";exit;}
    $_=$bbox;
#if (/^\-/)
#  {printf   "%40s","\n\n\t ERROR :No value Specified for bbox.\n Please Enter bbox again\n";exit;}
   
   

if($design_name eq '')
{

 printf "%50s\t%20s","\tERROR :Please Specify the design name & run the script","\n";
exit;
}
if($Redhawkdir eq '')
{
 

open ptt, ".apache/adsLib.output" or die "Current Directory isn't the RH run directory $!\n";
$Redhawkdir = "./";
 printf "%50s\t%20s","\tERROR :Please Specify the RH directory  & run the script","\n";
exit;
}

     

printf "%7s\t%10s","\tINFO :","The options given by the user are:\n\n";
if($Redhawkdir ne '')
{
 printf "%50s\t%0s","The RH directory is","$Redhawkdir\n";
 
}
if($resolution ne '')
{
 printf "%50s\t%0s","The resolution is","$resolution ns \n";
 $resolution = $resolution * 1000;
}
        

if($Outputfile ne '')
{
 printf "%50s\t%0s","The Output file is","$Outputfile\n";
}
if($design_name ne '')
{
 printf "%50s\t%0s","The plot is requested for","Design => $design_name\n";
}

if($start ne '')
{
 printf "%50s\t%0s","The Switching  starts from","$start ps\n";
 $start = $start ;
 }


if($end ne '')
{
 printf "%50s\t%0s","The Switching  stops at","$end ps\n";
 $time_flag=1;
}

if($bbox ne '')
{
$_= $bbox;
split;
$x1=$_[0];
$y1=$_[1];
$x2=$_[2];
$y2=$_[3];
$box_flag=1;
if ( ($x2 <= $x1 ) || ($y2 <= $y1 ) )
{
printf "%7s\t%20s","ERROR : x2 (or y2 ) should be greater than x1 (or y1) \n";exit;
}

}

if($bbox eq '')
{
$box_flag=0;
}
if($end eq '')
{
$time_flag=0;
}

if($end < $start )
{
printf "%7s\t%20s","ERROR :End time < Start Time ... Run again \n\n"; exit;
}

if($resolution eq '')
{
 $resolution=100;
}
if($start eq '')
{
$start =0;
}


if($Outputfile  eq '')
{
$Outputfile= "print_instance.out"; 
}
system ( " rm -rf print_instance.out ");

$apache_scenario=$Redhawkdir."/.apache/apache.scenario";
open ptr2, "$apache_scenario" or die "cannot open /.apache/apache.scenerio $!\n";


$power_rpt=$Redhawkdir."/adsRpt/".$design_name.".power.rpt";
open ptr3, "$power_rpt " or die "cannot open adsRpt/$design_name.power.rpt $!\n";
open rpt, "> $Outputfile " or die "cannot open $Outputfile  $!\n";



while (<ptr3>)
{
   if (/^\#/)  {next}
  chomp;split;

$print2{$_[0]} = 0;

if ($box_flag == 1 ) 
{

if ((( $_[8] >= $x1 ) && ( $_[8] < $x2 )) && (( $_[9] >= $y1 ) && ( $_[9] < $y2 ) ))
{
$cell_type{$_[0]} = $_[1];
$print{$_[0]} = 1;
}
}


else
{
$cell_type{$_[0]} = $_[1];
$print{$_[0]} = 1;
}



}

if ( $time_flag == 0 )
{
open ptr2, "$apache_scenario" or die "cannot open /.apache/apache.scenerio $!\n";
while (<ptr2>)
{
 if (/^\#/)  {next}
chomp;split; 
  $time = $_[2];
}
$end=$time;
close ptr2;
}

close ptr3;
open ptr3, "$power_rpt " or die "cannot open adsRpt/$design_name.power.rpt $!\n";

open ptr2, "$apache_scenario" or die "cannot open /.apache/apache.scenerio $!\n";

while (<ptr2>)
{
   if (/^\#/)  {next}
  chomp;split;
  $state=$_[1];
if ( $print{$_[0]} == 1 )
{
if ( ($_[2] >= $start ) && ( $_[2] <= $end ) )
  {
     if (( $state eq  'c01') or ( $state eq 'c10') )
     {
       
       
 $print2{$_[0]} = 1;
  }
  }
  
  }
  }
print " $time_flag , $box_flag ";
 close ptr2; 
 open ptr2, "$apache_scenario" or die "cannot open /.apache/apache.scenerio $!\n";
printf  rpt "%40s"," Switching ( 1/0) \t Instance Name \t Cell Name \n";
  while (<ptr3>){ 
  if (/^\#/)  {next}  
   chomp;split; 
   if (  $counter{$_[0]} != 1 ) 
   {
   printf  rpt "\t $print2{$_[0]} \t  $_[0] \t  $_[1]\n";
   }
$counter{$_[0]}=1;

   }
close ptr3;

