#$Revision: 1.3 $
#/usr/bin/perl;
#use strict;
#1) Pl. adhere to the following format for your ploc file <VDD/VSS>_<HIGH/MED/LOW>_*.
#2) The script basically looks for <VDD/VSS>_[MED/HIGH/LOW] to look for medium high or low resistance pads and assigns the corresponding resistance and capacitance to those pads.
#3) It generates a modified ploc file that maps the ports of the spice subckt with ploc pads and the spice netlist file
#4) pl. add the following line in your GSR
#        PACKAGE_SPICE_SUBCKT <generated spice netlist file>

use warnings;
eval '(exit $?0)' && eval 'exec perl -S $0 ${1+"$@"}'
  && eval 'exec perl -S $0 $argv:q'
  if 0;

sub show_usage {
    print "Usage:\n perl $0 -ploc <ploc file> -Rhigh -Rmed -Rlow -Chigh -Cmed -Clow -wbpwr <Rw> <Lw> <Cw> -wbgnd <Rw> <Lw> <Cw> -pkgpwr <Rpkg> <Lpkg> <Cpkg> -pkggnd <Rpkg> <Lpkg> <Cpkg> -vdd -vss -volts\n"; 
    print " Available options \n";
    print " PLEASE ENTER THE R,L,C in Ohm,Henry,Farad respectively\n";
    print "-ploc\tploc file(REQUIRED)\n";
    print "-Rmed\tdefault ( 1e-3 ohms)\n";
    print "-Rhigh\tdefault ( 0.1 ohms)\n";
    print "-Rlow\tdefault ( 1e-5 ohms) \n";
    print "-Cmed\tdefault ( 1pF)\n";
    print "-Chigh\tdefault ( 5pF)\n";
    print "-Clow\tdefault (0.1pF)\n";
    print "-wbpwr\t <Rw> <Lw> <Cw>\n";
    print "-wbgnd\t <Rw> <Lw> <Cw>\n";
    print "-pkgpwr\t <Rpkg> <Lpkg> <Cpkg>\n";
    print "-pkggnd\t <Rpkg> <Lpkg> <Cpkg>\n";
    print "Default Rpkg=1e-3,Cpkg=10e-12,Lpkg=10e-9\n";
    print "Default Rw=1e-3, Cpkg=10e-12,Lpkg=10e-9\n"; 
    print "-vdd\tdefault VDD\n";
    print "-volts\tdefaut(VDD=1.0V)\n";
    print "-vss\tdefault VSS\n";
    exit;
}

@VarList= ("help","ploc","Rhigh","Rmed","Rlow","Chigh","Cmed","Clow","wbpwr","wbgnd","pkgpwr","pkggnd","vdd","vss","volts");
getoptions(\@ARGV,\%optHash,\@VarList);

sub getoptions {
  my(@MatchingVars,$arg,$var_name,$legal_var);

  my $ArgRef = shift(@_);
  my @Args = @{$ArgRef};

  my $VarHashRef = shift(@_);
  my $VarListRef = shift(@_);

  while (@Args) {
    $arg = shift(@Args);
    # 1. If current argument starts with "-", it's a name of the variable
    if ($arg =~ m/^-/) {
      ($var_name = $arg) =~ s/^-//;

      # Flags may be incomplete, for ex: -vdd_n -> -vdd_nets
      @MatchingVars = ();
      foreach $legal_var (@$VarListRef) {
	if ($legal_var =~ m/^$var_name/) {
	  push(@MatchingVars,$legal_var)
	}
      }

      if ($#MatchingVars < 0) {
	print "Flag $arg is illegal!\n";
      } elsif ($#MatchingVars > 0) {
	print "Flag $arg is ambiguous: matches '@MatchingVars'\n";
      }

      # If there is only one matching legal flag - OK
      $var_name = shift(@MatchingVars);
      # Reset the value of the new argument
      $VarHashRef->{$var_name} = "";
      next;
    }

    # 2. If argument doesn't start with "-" - it's a value
    # start new record in $VarHash or append if such already exists
    if ($VarHashRef->{$var_name} eq "") {
      $VarHashRef->{$var_name} = $arg;
    } else {
      $VarHashRef->{$var_name} .= " $arg";
    }
  }
}

if(!defined $optHash{"Rmed"}) { $Rmed=1e-3;}else{ $Rmed=$optHash{"Rmed"};}
if(!defined $optHash{"Rhigh"}) { $Rhigh=0.1;}else{$Rhigh=$optHash{"Rhigh"};}
if(!defined $optHash{"Rlow"}) { $Rlow=1e-5;}else{$Rlow=$optHash{"Rlow"};}
if(!defined $optHash{"Cmed"}) { $Cmed=1e-12;}else{$Cmed=$optHash{"Cmed"};}
if(!defined $optHash{"Chigh"}) { $Chigh=10e-12;}else{$Chigh=$optHash{"Chigh"};}
if(!defined $optHash{"Clow"}) { $Clow=0.1e-12;}else{$Clow=$optHash{"Clow"};}
if(!defined $optHash{"vdd"}) {$vdd="VDD";}else{$vdd=$optHash{"vdd"};}
if(!defined $optHash{"vss"}) {$vss="VSS";}else{$vss=$optHash{"vss"};}
if(!defined $optHash{"wbpwr"}) { $Rpwire=1e-3; $Cpwire=5e-12;$Lpwire=1e-9;}
else{
$temp=$optHash{"wbpwr"};
@wbp=split(/\s+/,$temp);
$Rpwire =$wbp[0];$Cpwire =$wbp[2];$Lpwire =$wbp[1];
}
if(!defined $optHash{"wbgnd"}) { $Rgwire=1e-3; $Cgwire=5e-12;$Lgwire=1e-9;}
else{
$temp=$optHash{"wbgnd"};
@wbg=split(/\s+/,$temp);
$Rgwire =$wbg[0];$Cgwire =$wbg[2];$Lgwire =$wbg[1];
}
if(!defined $optHash{"pkgpwr"}) { $Rppkg=1e-3; $Cppkg=5e-12;$Lppkg=1e-9;}
else{
$temp=$optHash{"pkgpwr"};
@pkgp=split(/\s+/,$temp);
$Rppkg =$pkgp[0];$Cppkg =$pkgp[2];$Lppkg =$pkgp[1];
}
if(!defined $optHash{"pkggnd"}) { $Rgpkg=1e-3; $Cgpkg=5e-12;$Lgpkg=1e-9;}
else{
$temp=$optHash{"pkggnd"};
@pkgg=split(/\s+/,$temp);
$Rgpkg=$pkgg[0];$Cgpkg =$pkgg[2];$Lgpkg =$pkgg[1];
}
if(!defined $optHash{"volts"}) { $volts=1.0;}else { $volts=$optHash{"volts"}};
if(!defined $optHash{"ploc"}) 
{ 
show_usage();
}
else
{
$ploc=$optHash{"ploc"};
}

open(PLOC,"$ploc")|| die "Cannot open the file $ploc $!\n";
@p=split(/\./,$ploc);
$new_ploc="$p[0]\_mod\.ploc";
$spice="$p[0]\.sp";
print "These are the generated outputs \nThe modified ploc file $new_ploc\nspice netlist $spice\n";
open(PL,">$new_ploc")|| die "Cannot open the file $!\n";
open(SP,">$spice") || die "Cannot open the file $!\n";
$head="\.subckt REDHAWK_PKG";

while(<PLOC>)
{
chomp;
@coord=split;
$a=int($coord[1]);
$b=int($coord[2]);
$head="$head"." node_$a\_$b";
}
print SP "$head\n";
close(PLOC);
print SP "VDDC VDD_SOURCE 0 $volts\n";
print SP "VSSC VSS_SOURCE 0 0.0 \n"; 

$Cwp=$Cpwire/2;
$Cwg=$Cgwire/2;
open (PLOC,"$ploc")|| die "Cannot open the file $ploc$!\n";
while(<PLOC>)
{
chomp;
@data=split;
$pad=$data[0];
$x=int($data[1]);
$y=int($data[2]);
	if( $pad =~/VDD_MED/i)
	{
	print PL "$data[0] $data[1] $data[2] $data[3] $vdd node_$x\_$y\n";
	print SP "Rnode_$x\_$y\t node_$x\_$y\t int_node$x\_$y\t $Rmed\n";
	print SP "Cnode_$x\_$y\t node_$x\_$y\t\t 0\t\t $Cmed\n";
	print SP "Cw1_$x\_$y\t int_node$x\_$y\t 0\t\t $Cwp\n";
	print SP "Lw_$x\_$y\t int_node$x\_$y \t intA$x\_$y\t $Lpwire\n";
	print SP "Rw_$x\_$y\t intA$x\_$y\t\t P_int\t $Rpwire\n";
	print SP "Cw_$x\_$y\t P_int\t\t 0\t\t $Cwp\n\n";
	}
	elsif( $pad =~/VSS_MED/i)
        {
        print PL "$data[0] $data[1] $data[2] $data[3] $vss node_$x\_$y\n";
        print SP "Rnode_$x\_$y\t node_$x\_$y\t int_node$x\_$y\t $Rmed\n";
        print SP "Cnode_$x\_$y\t node_$x\_$y\t\t 0\t\t $Cmed\n";
        print SP "Cw1_$x\_$y\t int_node$x\_$y\t 0\t\t $Cwg\n";
        print SP "Lw_$x\_$y\t int_node$x\_$y\t intA$x\_$y\t $Lgwire\n";
        print SP "Rw_$x\_$y\t intA$x\_$y\t\t G_int\t $Rgwire\n";
        print SP "Cw_$x\_$y\t G_int\t\t 0\t\t $Cwg\n\n";
        }
	if( $pad =~/VDD_HIGH/i)
        {
        print PL "$data[0] $data[1] $data[2] $data[3] $vdd node_$x\_$y\n";
        print SP "Rnode_$x\_$y\t node_$x\_$y\t int_node$x\_$y\t $Rhigh\n";
        print SP "Cnode_$x\_$y\t node_$x\_$y\t\t 0\t\t $Chigh\n";
        print SP "Cw1_$x\_$y\t int_node$x\_$y\t 0\t\t $Cwp\n";
        print SP "Lw_$x\_$y\t int_node$x\_$y\t intA$x\_$y\t $Lpwire\n";
        print SP "Rw_$x\_$y\t intA$x\_$y\t\t P_int\t $Rpwire\n";
        print SP "Cw_$x\_$y\t P_int\t\t 0\t\t $Cwp\n\n";
        }
        elsif( $pad =~/VSS_HIGH/i)
        {
        print PL "$data[0] $data[1] $data[2] $data[3] $vss node_$x\_$y\n";
        print SP "Rnode_$x\_$y\t node_$x\_$y\t int_node$x\_$y\t $Rhigh\n";
        print SP "Cnode_$x\_$y\t node_$x\_$y\t\t 0\t\t $Chigh\n";
        print SP "Cw1_$x\_$y\t int_node$x\_$y\t 0\t\t $Cwg\n";
        print SP "Lw_$x\_$y\t int_node$x\_$y\t intA$x\_$y\t $Lgwire\n";
        print SP "Rw_$x\_$y\t intA$x\_$y\t\t G_int\t $Rgwire\n";
        print SP "Cw_$x\_$y\t G_int\t\t 0\t\t $Cwg\n\n";
        }
        if( $pad =~/VDD_LOW/i)
        {
        print PL "$data[0] $data[1] $data[2] $data[3] $vdd node_$x\_$y\n";
        print SP "Rnode_$x\_$y\t node_$x\_$y\t int_node$x\_$y\t $Rlow\n";
        print SP "Cnode_$x\_$y\t node_$x\_$y\t\t 0\t\t $Clow\n";
        print SP "Cw1_$x\_$y\t int_node$x\_$y\t 0\t\t $Cwp\n";
        print SP "Lw_$x\_$y\t int_node$x\_$y\t intA$x\_$y\t $Lpwire\n";
        print SP "Rw_$x\_$y\t intA$x\_$y\t\t P_int\t $Rpwire\n";
        print SP "Cw_$x\_$y\t P_int\t\t 0\t\t $Cwp\n\n";
        }
        elsif( $pad =~/VSS_LOW/i)
        {
        print PL "$data[0] $data[1] $data[2] $data[3] $vss node_$x\_$y\n";
        print SP "Rnode_$x\_$y\t node_$x\_$y\t int_node$x\_$y\t $Rlow\n";
        print SP "Cnode_$x\_$y\t node_$x\_$y\t\t 0\t\t $Clow\n";
        print SP "Cw1_$x\_$y\t int_node$x\_$y\t 0\t\t $Cwg\n";
        print SP "Lw_$x\_$y\t int_node$x\_$y\t intA$x\_$y\t $Lgwire\n";
        print SP "Rw_$x\_$y\t intA$x\_$y\t\t G_int\t $Rgwire\n";
        print SP "Cw_$x\_$y\t G_int\t\t 0\t\t $Cwg\n\n";
	}
}
print SP "Rppkgvdd\t\t P_int\t int1\t\t $Rppkg\n";
print SP "Lppkgvdd\t\t int1\t\t VDD_SOURCE\t $Lppkg\n";
print SP "Cppkg\t\t P_int\t G_int\t\t $Cppkg\n";
print SP "Rgpkgvss\t\t G_int\t int2\t\t $Rgpkg\n";
print SP "Lgpkgvss\t\t int2\t\t VSS_SOURCE\t $Lgpkg\n";
print SP "\.ends\n";
print "PLEASE ADD THE FOLLOWING LINES IN YOUR GSR\n";
print "PACKAGE_SPICE_SUBCKT $spice\;\n";
close PLOC;
close PL;
close SP;
