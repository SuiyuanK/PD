# Revision:1.1$
# This generates a ploc file of the following format for optimal package spice subckt
# <pad name> <x> <y> <metal> <domain name> <port>

#/usr/bin/perl
#use strict;
eval '(exit $?0)' && eval 'exec perl -S $0 ${1+"$@"}' && eval 'exec perl -S $0 $argv:q' if 0;
use warnings;
sub show_usage {
    print "#####################################################\n";
    print "# This Script is Suitable for Wirebond Designs only #\n";
    print "#####################################################\n";
    print "Usage:\n perl $0 -ploc <ploc file> -netlist <netlist file> -x_offset <x-offset in um> -y_offset <y-offset in um> -err <+/-max error in the offset> -domain1 <vdd_domain_name> -domain2 <vdd_domain_name> -domain3 <vss_domain_name>\n ";
    print " Available options \n";
    print "-ploc\t\tploc file(REQUIRED)\n";
    print "-netlist\tspice netlist(REQUIRED)\n";
    print "-x_offset\toffset in X-axis DEFAULT is 0\n";
    print "-y_offset\toffset in Y-axis DEFAULT is 0\n";
    print "-err\t\terror due to pad/package updates DEFAULT is 0\n";
    print "-domain1\tEnter the first VDD domain pad name a regular expression\n\t\tDefault:VDDCORE_\n";
    print "-domain2\tEnter the second VDD domain pad name\n\t\tDefault:VDDCORE_2_\n";
    print "-domain3\tEnter the  VSS  domain pad name\n\t\tDefault:VSSCORE_\n";
    print "-theta\t\tEnter the degree of rotation(0/90/-90/180 degrees) of the pad/package DEFAULT is 0\n";
    exit;
}

$opts=@ARGV;
for($i=0; $i< $opts; $i++)
{
	if($ARGV[$i]=~/^-h/i || $ARGV[$i]=~/^--help/)
	{
	show_usage();
	}
	elsif( $ARGV[$i]=~/^-ploc/i)
	{
	$ploc=$ARGV[$i+1];
	}
	elsif( $ARGV[$i]=~/^-net/i)
	{
	$netlist=$ARGV[$i+1];
	}
	elsif( $ARGV[$i]=~/^-x_off/i)
	{
	$of_x=$ARGV[$i+1];
	}
	elsif( $ARGV[$i]=~/^-y_off/i)
	{
	$of_y=$ARGV[$i+1];
	}
        elsif( $ARGV[$i]=~/^-err/i)
        {
        $error=$ARGV[$i+1];
        }
	elsif( $ARGV[$i]=~/^-domain1/i)
	{
	$d1="$ARGV[$i+1]";
	}
	elsif( $ARGV[$i]=~/^-domain2/i)
        {
        $d2="$ARGV[$i+1]";
        }
        elsif( $ARGV[$i]=~/^-domain3/i)
        {
        $d3="$ARGV[$i+1]";
        }
	elsif( $ARGV[$i]=~/^-theta/i)
	{
	$theta="$ARGV[$i+1]";
	}
}

if(!defined($ploc) || !defined($netlist))
{
show_usage();
}
else
{
	if(!defined $of_x)
	{
	$of_x=0;
	}
        if(!defined $of_y)
        {
        $of_y=0;
        }
        if(!defined $error)
        {
        $error=0;
        }
        if(!defined $d1)
        {
        $d1="VDDCORE_";
        }
        if(!defined $d2)
        {
        $d2="VDDCORE_2_";
        }
        if(!defined $d3)
        {
        $d3="VSSCORE_";
        }
	if(!defined $theta)
	{
	$theta=0;
	}
}

open(NET,"<$netlist") or die "Could not open the domain file: $!\n";
$i=0;
while(<NET>)
{
	if($_=~/\s*\* Start Power Ground Ports/)  #check for the begining of the OPTIMAL package protocol
	{
		while($_ !~/\s*\* End/)           #check for the end of the OPTIMAL package protocol
		{
		$_=<NET>;
		chomp;
		@coord= split(/\s*\s+/,$_);
			if( ($coord[2]!~/^[a-zA-Z]/) &&($coord[3]!~/^[A-Za-z]/) && ($coord[9]=~/DIE/)) 
# shift the die pads by the given offset and rotate it by 90 degrees
			{
			if($theta==90) {
			$y[$i]=int(($coord[2])*1000+$of_y);  #PLOC(Yp)=NETLIST(X)+OFFSET
			$x[$i]=int(-($coord[3])*1000+$of_x); #PLOC(Xp)=NETLIST(-Y)+OFFSET
			}
			elsif($theta==180) {
                        $y[$i]=int(-($coord[3])*1000+$of_y);  #PLOC(Yp)=NETLIST(-Y)+OFFSET
                        $x[$i]=int(-($coord[2])*1000+$of_x); #PLOC(Xp)=NETLIST(-X)+OFFSET
			}
			elsif($theta==-90) {
                        $y[$i]=int(-($coord[2])*1000+$of_y);  #PLOC(Yp)=NETLIST(-X)+OFFSET
                        $x[$i]=int(($coord[3])*1000+$of_x); #PLOC(Xp)=NETLIST(Y)+OFFSET
			}
			else					#ROTATION IS ASSUMED AS ZERO
			{
                       	$y[$i]=int(($coord[3])*1000+$of_y);  #PLOC(Yp)=NETLIST(X)+OFFSET
                        $x[$i]=int(($coord[2])*1000+$of_x); #PLOC(Xp)=NETLIST(Y)+OFFSET
			}
#			print "$x[$i]\t $y[$i]\n";
			$p[$i]=$coord[5];                    #Stores the corresponding port of the pad in the netlist
			$i++;
			}
		}
	}
}
$i--;
close(NET);

open(TEMP1,">temp.ploc");
#print TEMP1 "For offsets X=$of_x\t Y=$of_y\n";
open(NF,">nomatch.txt");
open(PLOC, "<$ploc") or die "Cannot open the file$!";
$j=0;
while(<PLOC>) {
next if(m/^#/);
next if(m/^$/);
  chomp;
  @ploc=split(/\s+/,$_);
	while($j <= $i)					    
	{
	if(($ploc[1]>=($x[$j]-$error))&& ($ploc[2]>=($y[$j]-$error))&& ($ploc[1]<=($x[$j]+$error))&& ($ploc[2]<=($y[$j]+$error)))
  		{
		if($ploc[0]=~/$d1/)
		{
		$domain=VDD;
		}
		elsif($ploc[0]=~/$d2/)
		{
		$domain=VDD_B;
		}
		elsif($ploc[0]=~/$d3/)
		{
		$domain= VSS;
		}
		else
		{
		print "UNKNOWN DOMAIN\n";
		exit;
		}
		print TEMP1 "$ploc[0] $ploc[1] $ploc[2] $ploc[3] $domain $p[$j]\n";
		$j=0;
		last; 
		}
		elsif($j==$i)
		{
		print NF "$ploc[0]  $ploc[1] and $ploc[2] are not found in netlist\n";
		$j=0;
		last;
		}
		else
		{
		$j++;
		}
	}
}
close(PLOC);
close(TEMP1);
close(NF);
