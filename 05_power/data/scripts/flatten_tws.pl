#!/usr/bin/perl
################################################################################################################
# Name       : flatten_tws.pl
# Description: To convert Hierachical timing files to a Flat timing file
# $Revision  :  1.0$
# Author     : Jai Pollayil , email : jaip@apache-da.com
################################################################################################################
=head1 NAME

flatten_tws.pl -To convert Hierachical timing file to a flat timing file 

=head1 SYNOPSIS

flatten_tws.pl [options] arguments

Options : -scf_dir, -tw_list, -xref_file, -internal_chain_file, -out, -man

=head1 DESCRIPTION

<flatten_tws.pl> Takes Switch chain file (scf file) , Top Hierachical timing window file and block timimg window file as inputs and create a full chip flat timing window file.

=head1 OPTIONS

=item -help

prints a synopsis and a description of program options.

=item -scf_dir <scf-directory>

Specify the directory which contain all switch chain files(scf).


=item -tw_list

Specify a file that lists Hierachical timing window files 

=item -xref_file

Specify the instance cross reference file generated from Primetime 

=item -internal_chain_file

Specify the internal switch chain starting points. Opitional. 
#Format: <block_instance_name> <start_point_pin>  <start_delay_in secs>

=item -out <Output Flat-timing file>

Specify the output flat timimg window file .

=item -man

Prints the entire man page



=head1 AUTHOR

Jai Pollayil, Apache India

email : jaip@apache-da.com

=head1 COPYRIGHT

COPYRIGHT (c) 2007 Apache Design Solutions. All right reserved.

=cut

## end program documentation
#$internal_chain_file = "internal_switch_chain.txt";

use Getopt::Long;
use Pod::Usage;
GetOptions ('help'=>\$help,
            'scf_dir=s'=>\$scf_dir,
            'tw_list=s'=>\$in,
	    'xref_file=s'=>\$xref_file,
	    'internal_chain_file=s'=>\$internal_chain_file,
	    'out=s'=>\$out,
	    'man'=>\$man);
pod2usage (-exitval => 0, -verbose => 1) if $help;
pod2usage (-exitval => 0, -verbose => 2) if $man;

unless (defined($out))  {
  print "ERROR  : Outfile not specified. Exit\n";
  exit;
}

#print "Xref = $xref_file";

#$in="tw.list";
#$out="tw.flat";

print "\nInfo	      : Opened TW list file $in for reading\n";

open IN1,"$in" or die "Cannot open the file $in : $!\n\n";
open OUT1,">$out.tmp"or die "Cannot create the file $out.tmp : $!\n\n";

while (<IN1>)  {
  if (/^\#/)  {next}
  #if (/^\s*$/) {next}
  chomp;split;
  $block=$_[0];
  $tw_file{$block}=$_[1];
  $is_block{$block}=1;
  push @blocks,$block;
  #print "$block $is_block{$block}\n";
 
}

$file=$tw_file{top};
system "egrep \" TW \" $file | egrep -v \"\#\" > .tw_top";
system "egrep \"^CLOCK\" $file > .clock";

#Find the final clock index
open FIN,".clock";
while (<FIN>)  {
  chomp;split;
  $clk_final_index=$_[$#_];
}

$new_index=$clk_final_index;

print "Info	      : Opened Top Hierarchical TW file $file for reading\n";

#Reading the top hier TW file. I am interested only in TW section
open IN1,".tw_top" or die "Cannot open the file .tw_top : $!\n\n";

while (<IN1>)  {
  
  chomp;split;
  $inst_pin = $_[0];
  
  $tw1{$inst_pin}=$_[3];
  $tw2{$inst_pin}=$_[4];
  $tw3{$inst_pin}=$_[5];
  $tw4{$inst_pin}=$_[6];
  $index{$inst_pin} = $_[7];
  #print "$inst_pin $tw1{$inst_pin}\n";
}                                           
  

@scfs=<$scf_dir/chain_*>;
$scf_index=-1;
#open OUTX,">.clock" or die "Cannot create the file .clock : $!\n\n";

print "Info	      : Found SCF directory $scf_dir\n";

foreach $scf (@scfs)  {
  $cnt_block{$scf}=0;
  $scf_index++;
  $clock=$scf;
  $clock=~s/.*\///g;

  #print OUTX "CLOCK    0.000e-12 5.000e-12 10.000e-12 $clock $scf_index\n";
  open IN1,"$scf" or die "Cannot open the file $scf : $!\n\n";
  print "\nInfo	      : Opening SCF $scf for reading\n";

  while (<IN1>)  {
    if (/clock source latency/)  {
      while (<IN1>)  {
        s/\(/ /g;s/\)/ /g;
        chomp;split;
        s/\&//g;
        chomp;split;
        $inst_pin=$_[0];
	if($inst_pin=~/(.*)\//)  {$inst=$1}
	if($inst_pin=~/.*\/(.*)/)  {$pin=$1;}
        $master{$inst}=$_[1];
	if (/data arrival time/)  {last}
	$m=$master{$inst};
	$t1= $tw1{$inst_pin};
	$t2= $tw2{$inst_pin};
	$t3= $tw3{$inst_pin};
	$t4= $tw4{$inst_pin};
	$clk_index = $index{$inst_pin} ;
	
	#if ($is_block{$m} != 1 )  {
	  #if (defined($tw1{$inst_pin}) && $printed{$inst_pin}!=1) {
	    #print OUT1 "$inst_pin TW 1 $tw1{$inst_pin} $tw2{$inst_pin} $tw3{$inst_pin} $tw4{$inst_pin} $scf_index\n";
	    #$printed{$inst_pin}=1;
	  #}
        #}
	if ($is_block{$m} == 1 )  {
	 #print "$inst,$pin,$m,$t1,$t2,$t3,$t4\n";
           while (<IN1>) {last}
	   if($adjusted{$inst}{$pin}!=1)  {
	     
	     $cnt_block{$scf}++;
	     print "Info	      : Found hierarchical instance $inst in the SCF. Adjusting the timing windows.\n";
	     adjust_block_tw ($inst,$pin,$m,$t1,$t2,$t3,$t4,$clk_index);
	     $adjusted{$inst}{$pin}=1;
	     
	     open YIN1, ".tw_adj" or die "Cannot open the file .tw_adj : $!\n\n";
	     while (<YIN1>)  {
	       chomp;split;
	       $inst_pin=$_[0];
	       if ($printed{$inst_pin} != 1)  {
	         print OUT1 "$_\n";;
	         $printed{$inst_pin}=1;
	       }
	     }
	   }
	 
	}
	
      }
    }
  }
print "Info	      : Found $cnt_block{$scf} hierarchical blocks in this SCF.\n";
}


#Reading the top hier TW file again !!!. We need the TWs for switch chains not passing through any blocks !!!
open OUT1,">.tw_top_extra";
open IN1,".tw_top" or die "Cannot open the file .tw_top : $!\n\n";

while (<IN1>)  {
  
  chomp;split;
  $inst_pin = $_[0];
  if ($printed{$inst_pin} !=1)  {
    print OUT1 "$_\n";
    $printed{$inst_pin} = 1;
  }
  
  #print "$inst_pin $tw1{$inst_pin}\n";
}                                           

#Adding switch chains starting internally
if (!defined ($xref_file) | !defined ($internal_chain_file))  {
    print "\nInfo	      : No internal switch chain info provided. Assuming no chains are starting inside the blocks.  \n";

}

if (defined ($xref_file))  {
open IN1, "$xref_file";
#print "Here. $xref_file\n";

while (<IN1>)  {
  if(/^\s*$/)  {next}
  if(/^\s*\#/)  {next}
  chomp;split;
  $master=$_[0];
  $inst=$_[1];
  
  if (defined($internal_chain_file))  {
    open IN2,"$internal_chain_file";
    print "\nInfo	      : Opened internal_chain_file $internal_chain_file for reading\n";
    while (<IN2>)  {
      if(/^\s*$/)  {next}
      if(/^\s*\#/)  {next}
      chomp;split;
      if ($#_!=2)  {
        print "Error	      : Incorrect internal_chain_file format..Exiting..!!!\n";
        exit
      }
      if ($_[0] eq $inst)  {
         $inst = $_[0];
         $start=$_[1];
         $delay=$_[2];
         if($internal_chain_added{$master}{$inst}{$start}!=1)  {
           print "Info	      : Adding the internal switch chain : ${inst}/${start}\n";

           $f=$tw_file{$master};
	   #print "File = $f \n";
	   $new_index++;
	   $string="CLOCK     0.000e-12    5.000e-12   10.000e-12 INT_CLK_${new_index} $new_index";
	   system "echo $string >> .clock";
	   dump_internal_chain($master,$inst,$start,$delay,$f,$new_index);
           $internal_chain_added{$master}{$inst}{$start}=1;
	   open YIN1, ".tw_adj1" or die "Cannot open the file .tw_adj : $!\n\n";
	   while (<YIN1>)  {
	     chomp;split;
	     $inst_pin=$_[0];
	     if ($printed{$inst_pin} != 1)  {
	       print OUT1 "$_\n";;
	       $printed{$inst_pin}=1;
	     }
	   }    
         }   
      }
    }  	
  }        
}    
}
  


close OUT1;  

system "cat .clock $out.tmp .tw_top_extra > $out";

system "rm -rf $out.tmp";
system "rm -rf .tw_top_extra";
system "rm -rf .clock";
system "rm -rf .tw_adj";
system "rm -rf .tw*";


print "\nInfo	      : Succesfully flattened the timing windows. Output is $out\n";

sub adjust_block_tw {
  my($block,$pin,$master,$t1,$t2,$t3,$t4,$scf_index) = @_ ;
  #print "$inst,$pin,$master,$tw1,$tw2,$tw3,$tw4\n";
  $file=$tw_file{$master};
  $string = `egrep \"^$pin IDEL \" $file`; 
  #print "$string\n";
  @tmp=split (/\s+/,$string);
  $index=$tmp[$#tmp];
  $d1=$t1-$tmp[3];
  $d2=$t2-$tmp[4];
  $d3=$t3-$tmp[5];
  $d4=$t4-$tmp[6];
  #print "$index\n";
  system "egrep \" TW \" $file | egrep -v \"\#\" > .tw_$master";
  $file=".tw_$master";
  $out_file=".tw_${block}_${pin}_adj";
  $out_file=~s/\//_/g;
  open XOUT1,">$out_file" or die "Cannot create the file $out_file : $!\n\n";
  open XIN1,"$file"or die "Cannot open the file $file : $!\n\n";
  while (<XIN1>)  {
    unless (/ ${index}$/)  {next}
    chomp;split;
    $inst_pin=$_[0];
    $xt1=$d1+$_[3];
    $xt2=$d2+$_[4];
    $xt3=$d3+$_[5];
    $xt4=$d4+$_[6];
    print XOUT1 "${block}/${inst_pin} TW 1 $xt1 $xt2 $xt3 $xt4 $scf_index\n";
  }  
  close XOUT1;
  system "cp $out_file .tw_adj";
    
  
}
  


        
sub dump_internal_chain {
  my($master,$inst,$start,$delay,$file,$new_index) = @_ ;
  #$file=$tw_file{$master};
  unless (-e $file)  { 
    print "Error         : TW file for $master does not exist.. Exiting!\n";
    exit;
  }
  $string = `egrep \"^$start TW \" $file`; 
  @tmp=split (/\s+/,$string);
  $index=$tmp[$#tmp];
  #print "Index=$index\n";
  #print "Inst=$inst\n";
  open SIN1, "$file";
  open SOUT1, ">.tw_adj1";
  
  while (<SIN1>)  {
    unless (/ TW/ )  {next}
    chomp;split;
    if ($_[$#_] eq $index)  {
      $pin=$_[0];
      $t1=$_[3]+$delay;
      $t2=$_[4]+$delay;
      $t3=$_[5]+$delay;
      $t4=$_[6]+$delay;
      print SOUT1 "${inst}/${pin} TW 1 $t1 $t2 $t3 $t4 $new_index\n";
    }
  
  }
  close SOUT1;
}
