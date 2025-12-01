#$Revision: 1.1 $ 15/1/08 Fixed a  bug in plot generation using xgraph that was occuring due to unnecessary duplication
#$Revision: 1.1 $ 20/12/07 . Fixed a bug in Memory switching plotting

##################################
# $Revision: 1.1 $
# - Created by Kiran Joseph  on 08/08/07
# - Initial version
#################################

eval '(exit $?0)' && eval 'exec perl -S $0 ${1+"$@"}'
&& eval 'exec perl -S $0 $argv:q' if 0;

#!/usr/local/bin/perl
################################################################################################################
# Name       : plot_switching.pl
# Description: Plots switching waveforms for different types / nets / locations  / variable time span / resolution
# Author     : Kiran Joseph , email : kiran@apache-da.com
################################################################################################################

=head1 NAME


plot_switching.pl -Plots switching waveforms for different types / nets / locations  / variable time span / resolution etc ..

=head1 SYNOPSIS


plot_switching.pl [Options] arguments

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


=item -type 


Specify the type of block you want for switching plot for
< 
| MEM.ie.memory 
| FF.ie. flip flop 
| COMB.ie. combinational circuit 
| LATCH.ie latch 
| CELL_WITH_CLK  ie.(cells with clock pins excluding flops, memory,clock buffer,latches ) 
| CLK_BUF.ie.clock_buffer| etc....
> 




=item -d

Specify the  <Redhawk run directory>  
( compulsory )




=item -outdir 

Specify the  <Output plot directory> 
( Default value is ./outdir)



=item  -design

Specify the   <design name>   
 ( compulsory )




=item -resolution 

Specify the   <resolution in ns> 

( Default value is 100ns )



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


=item -net

Specify the vdd-domain as <net>.


=item -block

Specify the block/instance name(top level).


=head1 EXAMPLE

perl plot_switching.pl -type COMB -d RH_run -outdir OUT  -resolution 0.1 -start 2 -end 20 -h -bbox " 200 100 300 600" -net vdd

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
            'type=s'=>\$type,
            'd=s'=>\$Redhawkdir,
	    'outdir=s'=>\$Outputdir,
	    'resolution=s'=>\$resolution,
	    'start=s'=>\$start,
	    'end=s'=>\$end,
	    'bbox=s'=>\$bbox,
	    'design=s'=>\$design_name,
	    'net=s'=>\$net ,
	    'man' => \$man ,
	     'block=s' => \$block);
	    
	    

	    
#pod2usage (-exitval => 0, -verbose => 1) if $help;
#pod2usage (-exitval => 0, -verbose => 2) if $man;



if ($help) {
 print <<EOT


plot_switching => Plots switching waveforms as per the  user specified criteria .


Description:
    
<plot_switching.pl> plots switching waveforms as per user's requirements  namely :

	celltype <memory | flop | combo | etc....> 


	d <Redhawk run directory>
 

	outDir <Output plot directory> 


	resolution <resolution in ns) 


	start <start_time in ns> 


	end <end time in ns> 


	bbox <x1 y1 x2 y2>  ( the co-ordinates of rectangular region )

	net <net name>  

	block <instance name>
	
	design <design name>

Usage:
    ./plot_switching [options] arguments
    
    arguments : RH path & design name

    Options : -type, -d, -outdir, -resolution, -start, -end, -help, -block , -bbox, -design,-net 

Options & arguments elaborated:
    -help
    prints a synopsis and a description of program options/arguments.

    -type
    Specify the type of block you want for switching plot for <MEM.ie.memory
    |FF.ie. flip flop |COMB.ie. combinational circuit |LATCH.ie latch |
    CELL_WITH_CLK ie .(cells with clock pins excluding flops, memory,clock
    buffer,latches ) | CLK_BUF.ie.clock_buffer| etc....>

    -d
    Specify the <Redhawk run directory> ( compulsory )

    -outdir
    Specify the <Output plot directory> ( Default value is ./outdir)
    The output directory will contain *.out files which can be plotted
    using xgraph utility.
    It will also contain *.rpt files that contains the instances and their
    switching times.

    -design
    Specify the <design name> ( hint : same name as the .gsr file ) (
    compulsory )

    -resolution
    Specify the <resolution in ns>

    ( Default value is 100ns )

    -start
    Specify the <start time in ns>

    -end
    Specify the <end time in ns>

    ( Default values of start & end are first & last switching times )
    
    -bbox

    Specify the   "<x1 y1 x2  y2>"  co-ordinates of the rectangular region you want to look for.
    <x1 y1 > are co-ordinates of the lower left corner of the box & <x2  y2>  co-ordinates of 
    the upper right corner.
    Note : Please give all co-ordinates with in double quotes.


     -net

     Specify the vdd-domain as <net>.

     -block 
     specify  the  block/instance name <instance name>
    
 
 
EXAMPLE

./plot_switching -type COMB -d RH_run -outdir OUT  -resolution 0.1 -start 2 -end 20 -h -bbox " 200 100 300 600" -net vdd

The output directory is outdir if not specified 

AUTHOR

Kiran Joseph, Apache India

email : kiran@ apache-da.com 
 
 
EOT
}

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
   
 $_=$resolution;
     if (/^\-/)
   {printf   "%40s","\n\n\t ERROR : No value Specified for resolution.\n Please Enter resolution again\n";exit;}
  $_=$type;
     if (/^\-/)
   {printf   "%40s","\n\n\t ERROR :No value Specified for type.\n Please Enter type again\n";exit;}
  $_=$Outputdir;
     if (/^\-/)
   {printf   "%40s","\n\n\t ERROR :No value Specified for Output directory.\n Please Enter Output directory again\n";exit;}
 $_=$start;
     if (/^\-/)
   {printf   "%40s","\n\n\t ERROR :No value Specified for start.\n Please Enter start again\n";exit;}
  $_=$end;
     if (/^\-/)
   {printf   "%40s","\n\n ERROR :No value Specified for end.\n Please Enter end again\n";exit;}
  $_=$net;
     if (/^\-/)
   {printf   "%40s","\n\n\t ERROR :No value Specified for net.\n Please Enter net again\n";exit;}
    $_=$bbox;
     if (/^\-/)
   {printf   "%40s","\n\n\t ERROR :No value Specified for bbox.\n Please Enter bbox again\n";exit;}
    $_=$block;
     if (/^\-/)
   {printf   "%40s","\n\n\t ERROR :No value Specified for block.\n Please Enter block again\n";exit;}
    
   

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
        

if($Outputdir ne '')
{
 printf "%50s\t%0s","The Output dir is","$Outputdir\n";
}
if($type ne '')
{
 printf "%50s\t%0s","The plot is requested for","$type\n";$type_flag=1;
}
if($design_name ne '')
{
 printf "%50s\t%0s","The plot is requested for","Design => $design_name\n";
}

if($start ne '')
{
 printf "%50s\t%0s","The Switching plot starts from","$start ns\n";
 $start = $start * 1000;
 }
if($block ne '')
{
 printf "%50s\t%0s","The plot is requested for","$block \n";$block_flag=1;
}


if($end ne '')
{
 printf "%50s\t%0s","The Switching plot stops at","$end ns\n";
 $end = $end * 1000;
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

if($net ne '')
{
$net_flag=1;
}
if($net eq '')
{

$net_flag=0;
}

if($type eq '')
{
$type_flag=0;
}
if($block eq '')
{
$block_flag=0;
}
if($bbox eq '')
{
$box_flag=0;
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


if($Outputdir eq '')
{

$Outputdir= "outdir"; 
}

system ( " mkdir  -p $Outputdir");
open OUT1, "> switching.txt"or die "cannot write into switch txt $!\n";
open OUT2, "> comb.txt"or die "cannot write into comb txt $!\n";
open clk, "> apache.clock";

$apache_clock_gz=$Redhawkdir."/.apache/apache.clock.gz";
system ( " gunzip -c $apache_clock_gz > apache.clock");
close clk;
open ptr4, "apache.clock" or die "cannot open apache.clock $!\n";
$apache_scenario=$Redhawkdir."/.apache/apache.scenario";
open ptr2, "$apache_scenario" or die "cannot open /.apache/apache.scenerio $!\n";

$adsLibout=$Redhawkdir."/.apache/adsLib.output";
open ptr1, "$adsLibout" or die "cannot open /.apache/adsLib.output $!\n";

$power_rpt=$Redhawkdir."/adsRpt/".$design_name.".power.rpt";
open ptr3, "$power_rpt " or die "cannot open adsPower/$design_name.nets.adsLib.power $!\n";
open rpt, "> ./$Outputdir/all.rpt " or die "cannot open $Outputdir/all.rpt $!\n";
open rpt1, "> ./$Outputdir/COMB.rpt " or die "cannot open file.rpt $!\n";
open rpt2, "> ./$Outputdir/LATCH.rpt " or die "cannot open file.rpt $!\n";
open rpt3, "> ./$Outputdir/MEM.rpt " or die "cannot open file.rpt $!\n";
open rpt4, "> ./$Outputdir/FF.rpt " or die "cannot open file.rpt $!\n";
open rpt5, "> ./$Outputdir/CLK_BUF.rpt " or die "cannot open file.rpt $!\n";
open rpt6, "> ./$Outputdir/CELL_WITH_CLK.rpt " or die "cannot open file.rpt $!\n";

if ( $block_flag ==  1)
{
while (<ptr3>)
{ if (/^\#/)  {next}
if(/^$block/)
{
chomp;split;
$block_f{$_[0]} = 1;
$count_b++;
}
}}
if ( ($count_b == 0 ) && ( $block_flag == 1 ) )
{
printf "%50s", "ERROR : Block  is not present in the design\n ";exit;
}
close ptr3;
open ptr3, "$power_rpt " or die "\nERROR :cannot open adsRpt/$design_name.power.rpt $!\n";

while (<ptr1>)
{
if(/cell/){
chomp;
split;
if($_[5] eq '0' ){

$typec{$_[1]} ='COMB';
}
elsif($_[5] eq	'1' ){
$typec{$_[1]} ='LATCH';
}
elsif($_[5] eq '2' ){
$typec{$_[1]} ='FF';
}
elsif($_[5] eq '3' ){
$typec{$_[1]} ='CELL_WITH_CLK';
}
elsif($_[5] eq '4' ){
$typec{$_[1]} ='MEM';
}


}
}

while (<ptr3>)
{
   if (/^\#/)  {next}
  chomp;split;

if ( $block_flag == 0 )
{
if ( ($box_flag == 0 ) && ($net_flag == 0 ) )
{
$inst_type{$_[0]} = $typec{$_[1]};$print{$_[0]} = 1;
}

elsif (( $box_flag == 0 ) && ( $net_flag == 1  ))
{
if ( $_[10] eq $net )
{
$inst_type{$_[0]} = $typec{$_[1]};
$print{$_[0]} = 1;
}
}

elsif (($box_flag == 1 ) && ($net_flag == 0 ))
{

if ((( $_[8] >= $x1 ) && ( $_[8] < $x2 )) && (( $_[9] >= $y1 ) && ( $_[9] < $y2 ) ))
{
$inst_type{$_[0]} = $typec{$_[1]};
$print{$_[0]} = 1;
}
}


elsif (( $box_flag == 1 ) && ( $net_flag == 1  ))
{

if ( $_[10] eq $net )
{

if ((( $_[8] >= $x1 ) && ( $_[8] < $x2 )) && (( $_[9] >= $y1 ) && ( $_[9] < $y2 ) ))
{

$inst_type{$_[0]} = $typec{$_[1]};
$print{$_[0]} = 1;
}
}
}

}

elsif ( ($block_f{$_[0]} == 1) &&  ($block_flag == 1 ) )
{
if ( ($box_flag == 0 ) && ($net_flag == 0 ) )
{
$inst_type{$_[0]} = $typec{$_[1]};

$print{$_[0]} = 1;
}

elsif (( $box_flag == 0 ) && ( $net_flag == 1  ))
{
if ( $_[10] eq $net )
{
$inst_type{$_[0]} = $typec{$_[1]};
$print{$_[0]} = 1;
}
}

elsif (($box_flag == 1 ) && ($net_flag == 0 ))
{

if ((( $_[8] >= $x1 ) && ( $_[8] < $x2 )) && (( $_[9] >= $y1 ) && ( $_[9] < $y2 ) ))
{
$inst_type{$_[0]} = $typec{$_[1]};
$print{$_[0]} = 1;
}
}


elsif (( $box_flag == 1 ) && ( $net_flag == 1  ))
{

if ( $_[10] eq $net )
{

if ((( $_[8] >= $x1 ) && ( $_[8] < $x2 )) && (( $_[9] >= $y1 ) && ( $_[9] < $y2 ) ))
{

$inst_type{$_[0]} = $typec{$_[1]};
$print{$_[0]} = 1;
}
}
}

}



}

close ptr3;
open ptr3, "$power_rpt " or die "cannot open adsRpt/$design_name.power.rpt $!\n";


while (<ptr4>)
{
   if (/^\#/)  {next}
  chomp;split;
  $inst_type{$_[0]} = 'CLK_BUF';
  }
  
  while (<ptr3>){ 
  if (/^\#/)  {next}  
   chomp;split; 
   if (  $print{$_[0]} == 1 )
  {
  $countt++;
 #$tester{$_[0]}++;
  if ( $inst_type{$_[0]} eq 'FF') 
  {$FF_counter++;} 
    elsif ( $inst_type{$_[0]} eq 'LATCH' )
  {$LATCH_counter++;} 
    elsif ( $inst_type{$_[0]} eq 'MEM' )
  {$MEM_counter++;} 
    elsif ( $inst_type{$_[0]} eq 'CELL_WITH_CLK' )
  {$CELL_W_CLK_counter++;} 
    elsif ( $inst_type{$_[0]} eq 'CLK_BUF' )
  {$CLK_BUF_counter++;} 
    elsif ( $inst_type{$_[0]} eq 'COMB' )
  {$COMB_counter++;} 
   
   }
   }
   $TOT_counter=$COMB_counter+$CLK_BUF_counter+$CELL_W_CLK_counter+$MEM_counter+$LATCH_counter+$FF_counter;

  printf  rpt "%40s"," INSTANCE NAME \t  TIME\n";
  
  printf  rpt1 "%40s"," INSTANCE NAME \t  TIME\n";
  printf  rpt2 "%40s"," INSTANCE NAME \t  TIME\n";
  printf  rpt3 "%40s"," INSTANCE NAME \t  TIME\n";
  printf  rpt4 "%40s"," INSTANCE NAME \t  TIME\n";
  printf  rpt5 "%40s"," INSTANCE NAME \t  TIME\n";
  printf  rpt6 "%40s"," INSTANCE NAME \t  TIME\n";
  

while (<ptr2>)
 {
   if (/^\#/)  {next}
  chomp;split;
  $inst = $_[0];
  $time = $_[2];
  $state = $_[1];

  if (  $print{$_[0]} == 1 )  {
 

  
  
  if (( $state eq  'c01') or ( $state eq 'c10') )
  { $count_switch{$time}{inst} ++;
    $total_counter{$_[0]}++;
  printf  rpt "%40s"," $_[0] \t  $_[2] \n";

  if( $inst_type{$_[0]} eq 'COMB')
  {$count1{$time} ++;
   printf  rpt1 "%40s"," $_[0] \t  $_[2] \n";
  }
  if( $inst_type{$_[0]} eq 'LATCH')
  {$count2{$time} ++;
   printf  rpt2 "%40s"," $_[0] \t  $_[2] \n";
  }
  if( $inst_type{$_[0]} eq 'MEM')
  {$count3{$time} ++;
   printf  rpt3 "%40s"," $_[0] \t  $_[2] \n";
  }
    if( $inst_type{$_[0]} eq 'FF')
  {$count4{$time} ++;
   printf  rpt4 "%40s"," $_[0] \t  $_[2] \n";
  }
     if( $inst_type{$_[0]} eq 'CLK_BUF')
  {$count5{$time} ++;
    printf  rpt5 "%40s"," $_[0] \t  $_[2] \n";
  }
      if( $inst_type{$_[0]} eq 'CELL_WITH_CLK')
  {$count6{$time} ++;
     printf  rpt6 "%40s"," $_[0] \t  $_[2] \n";
  }

  }

  $last_t = $_[2];
 }}

if($end eq '')
{
$end =$last_t;
}


foreach $key(sort keys %count_switch){
print  OUT1 " $key $count_switch{$key}{inst}  \n";
}
close OUT1;

if( $type eq 'COMB'){
foreach $key(sort keys %count1){
print  OUT2 " $key $count1{$key}  \n";
}
}

elsif( $type eq 'LATCH'){
foreach $key(sort keys %count2){
print  OUT2 " $key $count2{$key}  \n";
}
}

elsif( $type eq 'MEM'){
foreach $key(sort keys %count3){
print  OUT2 " $key $count3{$key}  \n";
}
}

elsif( $type eq 'FF'){
foreach $key(sort keys %count4){
print  OUT2 " $key $count4{$key}  \n";
}
}

elsif( $type eq 'CLK_BUF'){
foreach $key(sort keys %count5){
print  OUT2 " $key $count5{$key}  \n";
}
}

elsif( $type eq 'CELL_WITH_CLK'){
foreach $key(sort keys %count6){
print  OUT2 " $key $count6{$key}  \n";
}
}


close OUT2;


open OUT2," comb.txt" or die "cannot open the file comb.txt $!\n";
open OUT1," switching.txt" or die "cannot open the file swt.txt $!\n";
open ptr5,"> resoln.txt" or die "cannot write into the out put file resoln $!\n";
open ptr6,"> resoln2.txt"or die "cannot open the file resoln2.txt $!\n";

if ((-z "switching.txt") && ($type_flag == 0))
{
 print "\tERROR:  No  switching as per the user specified criteria \n";exit;}


if ( $type_flag == 0 ){


$ycount=$start;
while($ycount <= $end )
{
$ytest=$ycount/$resolution;
 $ytest=sprintf "%d",$ytest;
  $bucket{$ytest}=0;
  $ycount=$ycount+$resolution; 
}



while(<OUT1>){
chomp;
split;
$count_out1++;
if( ($_[0] >= $start) && ($_[0] <= $end ) )
{
$pc=$_[0];
$bin=$pc/$resolution;
$bin=sprintf "%d",$bin;
$bucket{$bin}=$bucket{$bin}+$_[1];
}}
foreach $key1(sort keys %bucket){
$temp=$key1*$resolution;
$tempx=($key1-1)*$resolution;
if ( $tempx == 0 )
{
print ptr5 "$tempx $bucket{$key1}\n";
}

print ptr5 "$temp $bucket{$key1}\n";
}
system  ("sort -n resoln.txt > ./$Outputdir/overall.out  ");

	}
	
else{


if ((-z "comb.txt")&&($type_flag==1))
{
 printf "\tERROR:   No  switching of the type $type as per the user specified criteria \n";exit;}

$xcount=$start;
while($xcount <= $end )
{
$xtest=$xcount/$resolution;
$xtest=sprintf "%d",$xtest;
  $bucket2{$xtest}=0;
  $xcount=$xcount+$resolution;
}


while(<OUT2>){
chomp;
split;
$count_out2++;
if( ($_[0] >= $start) && ($_[0] <= $end ) )
{
$pc=$_[0];
$bin=$pc/$resolution;
$bin=sprintf "%d",$bin;
$bucket2{$bin}=$bucket2{$bin}+$_[1];
}}
foreach $key(sort keys %bucket2){
$temp=$key*$resolution;
$tempx=($key-1)*$resolution;
if($tempx == 0 )
{
print ptr6 "$tempx $bucket2{$key}\n";
}
print ptr6 "$temp $bucket2{$key}\n";

}
close ptr6;

system  ("sort -n resoln2.txt > ./$Outputdir/type.out  ");

}


printf"\n \n \n";

print " \n\nNOTE: \t Check  $Outputdir for output files. \n\t Use  xgraph to plot *.out files.\n\t type.out contains user-specified celltype (like COMB/MEM etc..) switching.\n\t overall.out contains overall switching if user havent specified any celltype   \n\t \n\n";
close ptr1;
close ptr2;
close ptr3;
close ptr4;
close ptr5;
close ptr6;

close rpt;
close rpt1;
close rpt2;
close rpt3;
close rpt4;
close rpt5;
close rpt6;
close OUT1;
close OUT2;

system  ("rm -rf resoln2.txt   ");
system  ("rm -rf resoln.txt   ");
system  ("rm -rf comb.txt   ");
system  ("rm -rf switching.txt   ");
system  ("rm -rf apache.clock  ");
