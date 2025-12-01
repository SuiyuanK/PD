# $Revision: 1.5 $

eval '(exit $?0)' && eval 'exec perl -w -S $0 ${1+"$@"}' 
  && eval 'exec perl -w -S $0 $argv:q' if 0;

# Author: Chris Ortiz, chris@apache-da.com
# Apache Design Solutions. All rights reserved.

use Math::Complex;
use Getopt::Long;


$result = GetOptions (
  "help|h|usage" => \$help ,
  "net1=s" => \$netname1 ,
  "diegroup1=s" => \$diegroup1 ,
  "net2:s" => \$netname2 ,
  "diegroup2=s" => \$diegroup2 ,
  "model|m=s" => \$filein ,
  "smodel=s" => \$sparamfile ,
  "fmin=f" => \$fmin ,
  "fmax=f" => \$fmax ,
  "fit!" => \$fit,
  "sim!" => \$sim,
  "hspice" => \$hspice,
  "genS|genSparam" => \$genSparam,
  "stepstyle|s" => \$stepstyle,
  "fit_model=s" => \$fit_model ,
  "lumpedports=s" => \$lumpedports ,
  "shortedports=s" => \$shortedports ,
  "fixreff=f" => \$fixreff ,
  "fixleff=f" => \$fixleff ,
  "fixceff=f" => \$fixceff ,

);

if( ($help) || (! $result)){
print STDERR <<EOF;
usage spice:  measure_andor_fit_rlc.pl -model spice_subckt.txt -net1 netname1 [-net2 netname2] \
[-fmin minFreq] [-fmax maxFreq] [-nofit] [-nosim] [-stepstyle <dec|lin>] [-hspice] [-genSparam] \
[-fixreff float] [-fixleff float] [fixceff float]

usage sparam:  measure_andor_fit_rlc.pl -smodel sparam.s#p -lumpedported [] -shortedports [] \
[-fmin minFreq] [-fmax maxFreq] [-nofit] [-nosim] [-stepstyle <dec|lin>] [-hspice] \
[-fixreff float] [-fixleff float] [fixceff float]

-model  file name of the spice subckt for package or CPM.
-smodel  file name of the s-parameter file.
-net1 name of net in -model file wished to be modeled as RLC.
-diegroup1 (optonal) subset of die groups to use in simulation for net1.
     (ex: -diegroup1 [1,3-5,7] would consider the groups 1,3,4,5,7 of net1 one terminal).
-net2 (optional) name of second net to be used as a return path for loop RLC.
-diegroup2 (optonal) subset of die groups to use in simulation for net2.
-fmin minimum frequency to be used in fitting to RLC model, default 1e6Hz.
-fmax maximum frequency to be used in fitting to RLC model, default 1e10Hz.
-stepstyle [dec|lin] log or linear frequency steps.  Default is log (dec=log).
-nofit No RLC values will be fit, only the spice simulation will be run.
-nosim No spice simulation will be run.
-fit_model specifies the model that should be used to fit the impedance.
          T;  a T model is used. R-L-C-R-L (where C is to ground) Z(DC)=2R.
	  cdie; a cdie model is used R-L-C (where C is part of the direct path) Z(DC)=infinity. 
-hspice Use hspice as the simulator instead of the default, nspice.
-genSparam Using hspice a s-parameter file is generated from the model.
-lumpedports (required with sparam) subset of s-param ports to lump and stimulate in simulation. 
     (ex: -lumpedports [1,3-5,7] would consider the ports 1,3,4,5,7 to be lumped as one port).
-shortedports Subset of s-param ports to short together.
     (ex: -shortedports [1,3-5,7] would consider the ports 1,3,4,5,7 to be shorted.)
-fixreff Don't fit the Reff value but use specified value instead.
-fixleff Don't fit the Leff value but use specified value instead.
-fixceff Don't fit the Ceff value but use specified value instead.
EOF
exit;
}

if (! defined $fit) {
  $fit = 0;
}
if (! defined $sim) {
  $sim = 1;
}
if (! defined $hspice) {
  $simulator = "nspice";
}else{
  $simulator = "hspice";
}
if( defined $genSparam){
  if(! defined $hspice){
   die "\nERROR: you must use hspice when generating an s-paramter file.\n";
  }
}
if (! defined $fmin) {
  $fmin = 1e6;
}
if (! defined $fmax) {
  $fmax = 1e10;
}
if ((! defined $netname1 )&&(! defined $sparamfile)){
 die "\nERROR: you must specify a net name with the -net1 option.\n";
}
if (! defined $stepstyle) {
  $stepstyle = "dec";
  $steps_per_dec = 50;
}elsif($stepstyle eq "dec"){
$steps_per_dec = 50;
}elsif($stepstyle ne "lin"){
$steps_per_dec = 100;
}else{
 die "\nERROR: stepstyle must be either dec or lin\n";
}
if(defined $diegroup1){
  $diegroup1 =~ s/[][(){}]//g;
  @ainputs = split(/,/,$diegroup1);
  $i=0;
  %hash_diegroup1 = ();
  until (! defined $ainputs[$i] ){
    if($ainputs[$i] =~ m/[-]/){
      @startstop = split(/[-]/,$ainputs[$i]);
      for($j = $startstop[0]; $j<=$startstop[1]; ++$j){
        $hash_diegroup1{$j} = 1;
      }
    }else{  
      $hash_diegroup1{$ainputs[$i]} = 1;
    }
    ++$i;
  }
}

if(defined $diegroup2){
  $diegroup2 =~ s/[][(){}]//g;
  @ainputs = split(/,/,$diegroup2);
  $i=0;
  %hash_diegroup2 = ();
  until (! defined $ainputs[$i] ){
    if($ainputs[$i] =~ m/[-]/){
      @startstop = split(/[-]/,$ainputs[$i]);
      for($j = $startstop[0]; $j<=$startstop[1]; ++$j){
        $hash_diegroup2{$j} = 1;
      }
    }else{  
      $hash_diegroup2{$ainputs[$i]} = 1;
    }
    ++$i;
  }
}

if(defined $lumpedports){
  $lumpedports =~ s/[][(){}]//g;
  @ainputs = split(/,/,$lumpedports);
  $i=0;
  %hash_lumpedports = ();
  until (! defined $ainputs[$i] ){
    if($ainputs[$i] =~ m/[-]/){
      @startstop = split(/[-]/,$ainputs[$i]);
      for($j = $startstop[0]; $j<=$startstop[1]; ++$j){
        $hash_lumpedports{$j} = 1;
      }
    }else{  
      $hash_lumpedports{$ainputs[$i]} = 1;
    }
    ++$i;
  }
}

if(defined $shortedports){
  $shortedports =~ s/[][(){}]//g;
  @ainputs = split(/,/,$shortedports);
  $i=0;
  %hash_shortedports = ();
  until (! defined $ainputs[$i] ){
    if($ainputs[$i] =~ m/[-]/){
      @startstop = split(/[-]/,$ainputs[$i]);
      for($j = $startstop[0]; $j<=$startstop[1]; ++$j){
        $hash_shortedports{$j} = 1;
      }
    }else{  
      $hash_shortedports{$ainputs[$i]} = 1;
    }
    ++$i;
  }
}

$fixvariables = 0;
if(defined $fixreff){
 $fixvariables += 1;
}
if(defined $fixleff){
 $fixvariables += 2;
}
if(defined $fixceff){
 $fixvariables += 4;
}

$freq4 = $fmin + 0.9*($fmax-$fmin);
$freq3 = $fmin + 1.0e-2*($fmax-$fmin);
$freq2 = $fmin + 1.0e-4*($fmax-$fmin);
$freq1 = $fmin + 1.0e-6*($fmax-$fmin) ;
$rfloat = 1e12;
$rshort = 1e-7;

%source_port = ();
%sink_port = ();
%float_port = ();
%float_noncpp_port = ();
%short_port1 = ();
%short_port2 = ();
@subckt_port = ();

if (! defined $fit_model ){
 if( defined $sparamfile ){
   die "\nERROR: you must explicitly specify -fit_model as either \"T\" or \"cdie\" when using s-parameter files\n";
 }
 $fit_model = "T";
}
if ( defined $netname2 ){
  $file_test_bench = "test_bench_${filein}_${netname1}_${netname2}" ;
}elsif( defined $netname1 ){
  $file_test_bench = "test_bench_${filein}_${netname1}" ;
}elsif( defined $sparamfile ){
  $file_test_bench = "test_bench_${sparamfile}" ;
}
if ($fit_model eq "T" ){
 if( defined $sparamfile ){
   simulate_sparam_model ();
 }else{
   parse_cpp_spice_model ();
 }
}elsif($fit_model eq "cdie"){
 if( defined $sparamfile ){
   simulate_sparam_model ();
 }else{
   parse_cpm_inc_model ();
 }
}else{
 die "\nERROR: you must specify -fit_model as either \"T\" or \"cdie\"\n";
}

sub parse_cpp_spice_model {

my $measure_cap_flag = 1;
my $source_flag = 0;
my $sink_flag = 0;
open(FILEIN,"<$filein" ) or die "\nCan't open input file $filein\n\n";
open(FILESPICE,">${file_test_bench}.sp" ) or die "\nCan't create file ${file_test_bench}.sp\n\n";


print FILESPICE <<EOF;
.option measdgt = 7
.option RESMIN=1e-8
.option probe post
.temp 25

.include '$filein'

EOF

while (<FILEIN>){
  chop($line = $_);
  if($line =~ m/Start Signal Ports/i){
    until($line =~ m/End Signal Ports/i){
      chop($line = <FILEIN> );
      $line =~ s/[:=()]/ /g;
      @temp = split(/\s+/,$line);
      if($line =~ m/(DIE|PCB|OTHER)/){
      if($temp[4] =~ m/MP/){
        $pname = "${temp[5]}-${temp[4]}";
      }else{
	$io = $temp[4];
        $io =~ s/[0-9]//g;
        $pname = "${temp[5]}-${temp[1]}-${io}";
      }
      }
      if(defined $netname2){
        if($line =~ m/\s+DIE/){
          if($line =~ m/ $netname1 /i){
	    $source_port{$pname} = 1;
	    $source_port{$temp[4]} = 1;
          }elsif($line =~ m/ $netname2 /i){
	    $sink_port{$pname} = 1;
	    $sink_port{$temp[4]} = 1;
	  }else{
	    $float_port{$pname} = 1;
	    $float_port{$temp[4]} = 1;
  	  }
        }elsif($line =~ m/\s+(PCB|OTHER)/){
          if($line =~ m/ $netname1 /i){
	    $short_port1{$pname} = 1;
	    $short_port1{$temp[4]} = 1;
	  }elsif($line =~ m/ $netname2 /i){
	    $short_port2{$pname} = 1;
	    $short_port2{$temp[4]} = 1;
	  }else{
	    $float_port{$pname} = 1;
	    $float_port{$temp[4]} = 1;
	  }
        }
      }else{
        if($line =~ m/\s+DIE/){
          if($line =~ m/ $netname1 /i){
	    $source_port{$pname} = 1;
	    $source_port{$temp[4]} = 1;
	  }else{
	    $float_port{$pname} = 1;
	    $float_port{$temp[4]} = 1;
  	  }
        }elsif($line =~ m/\s+(PCB|OTHER)/){
          if($line =~ m/ $netname1 /i){
	    $sink_port{$pname} = 1;
	    $sink_port{$temp[4]} = 1;
	  }else{
	    $float_port{$pname} = 1;
	    $float_port{$temp[4]} = 1;
	  }
        }
      }
    }
  }
  if($line =~ m/Start Power Ground Ports/i){
    until($line =~ m/End Power Ground Ports/i){
      chop($line = <FILEIN> );
      $line =~ s/[:=()]/ /g;
      @temp = split(/\s+/,$line);
      if($line =~ m/(DIE|PCB|OTHER)/){
        if($temp[4] =~ m/MP/){
          $pname = "${temp[5]}-${temp[4]}";
        }else{
  	  $io = $temp[4];
          $io =~ s/[0-9]//g;
          $pname = "${temp[5]}-${temp[1]}-${io}";
        }
      }
      if(defined $netname2){
        if($line =~ m/\s+DIE/){
          if($line =~ m/ ${netname1}_Group_[0-9]* /i){
            if( defined $diegroup1 ){
	      $ntemp = $line;
	      $ntemp =~ s/.* ${netname1}_Group_([0-9]*)\s.*/$1/;
	      if(exists $hash_diegroup1{$ntemp}){
	        $source_port{$pname} = 1;
	        $source_port{$temp[4]} = 1;
	      }else{
	        $float_port{$pname} = 1;
	        $float_port{$temp[4]} = 1;
	      }
            }else{
	      $source_port{$pname} = 1;
	      $source_port{$temp[4]} = 1;
            }
          }elsif($line =~ m/ ${netname2}_Group_[0-9]* /i){
            if( defined $diegroup2 ){
	      $ntemp = $line;
	      $ntemp =~ s/.* ${netname2}_Group_([0-9]*)\s.*/$1/;
	      if(exists $hash_diegroup2{$ntemp}){
	        $sink_port{$pname} = 1;
	        $sink_port{$temp[4]} = 1;
	      }else{
	        $float_port{$pname} = 1;
	        $float_port{$temp[4]} = 1;
	      }
            }else{
	      $sink_port{$pname} = 1;
	      $sink_port{$temp[4]} = 1;
            }
          }elsif($line =~ m/\s${netname1}\s/i){
	      $source_port{$pname} = 1;
	      $source_port{$temp[4]} = 1;
          }elsif($line =~ m/\s${netname2}\s/i){
	      $sink_port{$pname} = 1;
	      $sink_port{$temp[4]} = 1;
	  }else{
	    $float_port{$pname} = 1;
	    $float_port{$temp[4]} = 1;
	  }
        }elsif($line =~ m/\s+(PCB|OTHER)/){
          if($line =~ m/ ${netname1}_Group_[0-9]* /i){
	    $short_port1{$pname} = 1;
	    $short_port1{$temp[4]} = 1;
	  }elsif($line =~ m/ ${netname2}_Group_[0-9]* /i){
	    $short_port2{$pname} = 1;
	    $short_port2{$temp[4]} = 1;
          }elsif($line =~ m/\s${netname1}\s/i){
	      $short_port1{$pname} = 1;
	      $short_port1{$temp[4]} = 1;
          }elsif($line =~ m/\s${netname2}\s/i){
	      $short_port2{$pname} = 1;
	      $short_port2{$temp[4]} = 1;
	  }else{
	    $float_port{$pname} = 1;
	    $float_port{$temp[4]} = 1;
	  }
        }
      }else{
        if($line =~ m/\s+DIE/){
          if($line =~ m/ ${netname1}_Group_[0-9]* /i){
            if( defined $diegroup1 ){
	      $ntemp = $line;
	      $ntemp =~ s/.* ${netname1}_Group_([0-9]*)\s.*/$1/;
	      if(exists $hash_diegroup1{$ntemp}){
	        $source_port{$pname} = 1;
	        $source_port{$temp[4]} = 1;
	      }else{
	        $float_port{$pname} = 1;
	        $float_port{$temp[4]} = 1;
	      }
            }else{
	      $source_port{$pname} = 1;
	      $source_port{$temp[4]} = 1;
            }
          }elsif($line =~ m/\s${netname1}\s/i){
	      $source_port{$pname} = 1;
	      $source_port{$temp[4]} = 1;
	  }else{
	    $float_port{$pname} = 1;
	    $float_port{$temp[4]} = 1;
	  }
        }elsif($line =~ m/\s+(PCB|OTHER)/){
          if($line =~ m/ ${netname1}_Group_[0-9]* /i){
	    $sink_port{$pname} = 1;
	    $sink_port{$temp[4]} = 1;
          }elsif($line =~ m/\s${netname1}\s/i){
	      $sink_port{$pname} = 1;
	      $sink_port{$temp[4]} = 1;
	  }else{
	    $float_port{$pname} = 1;
	    $float_port{$temp[4]} = 1;
	  }
        }
      }
    }
  }
  if($line =~ m/^.subckt /i){
    @temp = split(/\s+/,$line);
    $subckt_name = $temp[1];
    $line =~ s/^.subckt [^ 	]+[ 	]*/+/i;
    $nport = 0;
    $i = 0;
    until( ! ($line =~ m/^[	 ]*[+]/)) {
      $line =~ s/[ 	]*[+][ 	]*//;
      @temp = split(/\s+/,$line);
      until( ! exists $temp[$i]){
        $subckt_port[$nport] = $temp[$i];
	$nport++;
	$i++;
      }
      $i = 0;
      chop($line = <FILEIN> );
    }
    print FILESPICE "X1 ";
    for($j=0;$j<$nport;$j++){
      if(($j%5)==0){
        print FILESPICE "\n+";
      }
      if(defined $source_port{$subckt_port[$j]}){
        print FILESPICE " nin";
	$source_flag = 1;
      }elsif(defined $sink_port{$subckt_port[$j]}){
        print FILESPICE " nout";
	$sink_flag = 1;
      }elsif(defined $short_port1{$subckt_port[$j]}){
        print FILESPICE " nshort1";
      }elsif(defined $short_port2{$subckt_port[$j]}){
        print FILESPICE " nshort2";
      }elsif(defined $float_port{$subckt_port[$j]}){
        print FILESPICE " n$subckt_port[$j]";
      }else{
        print FILESPICE " n$subckt_port[$j]";
        print STDERR "ERROR: PORT $subckt_port[$j] not source/sink/float. Not referenced in CPP.\n";
	$float_noncpp_port{$subckt_port[$j]} = 1;
      }
    }
    print FILESPICE "\n+ $subckt_name\n";
    if(defined $netname2){
      if( ((scalar (keys %short_port1)) == 0) && ((scalar (keys %short_port2)) == 0 ) ) {
        $measure_cap_flag = 0;
      }
    }else{
      if($sink_flag == 0){
        $measure_cap_flag = 0;
      }
    }
    if($measure_cap_flag == 1){
      print FILESPICE "XC ";
      for($j=0;$j<$nport;$j++){
        if(($j%5)==0){
          print FILESPICE "\n+";
        }
        if(defined $source_port{$subckt_port[$j]}){
          print FILESPICE " ninc";
        }elsif(defined $sink_port{$subckt_port[$j]}){
          print FILESPICE " noutc";
        }elsif(defined $short_port1{$subckt_port[$j]}){
          print FILESPICE " nshort1c";
        }elsif(defined $short_port2{$subckt_port[$j]}){
          print FILESPICE " nshort2c";
        }elsif(defined $float_port{$subckt_port[$j]}){
          print FILESPICE " nc$subckt_port[$j]";
        }else{
          print FILESPICE " nc$subckt_port[$j]";
          print STDERR "ERROR: PORT $subckt_port[$j] not source/sink/float.  Not referenced in CPP.\n";
  	$float_noncpp_port{$subckt_port[$j]} = 1;
        }
      }
      print FILESPICE "\n+ $subckt_name\n";
    }
    if(defined $genSparam){
      print FILESPICE "XS ";
      for($j=0;$j<$nport;$j++){
        if(($j%5)==0){
          print FILESPICE "\n+";
        }
        if(defined $source_port{$subckt_port[$j]}){
          print FILESPICE " nins";
        }elsif(defined $sink_port{$subckt_port[$j]}){
          print FILESPICE " nouts";
        }elsif(defined $short_port1{$subckt_port[$j]}){
          print FILESPICE " nshort1s";
        }elsif(defined $short_port2{$subckt_port[$j]}){
          print FILESPICE " nshort2s";
        }elsif(defined $float_port{$subckt_port[$j]}){
          print FILESPICE " ns$subckt_port[$j]";
        }else{
          print FILESPICE " ns$subckt_port[$j]";
          print STDERR "ERROR: PORT $subckt_port[$j] not source/sink/float.  Not referenced in CPP.\n";
	  $float_noncpp_port{$subckt_port[$j]} = 1;
        }
  
      }
      print FILESPICE "\n+ $subckt_name\n";
    }
  }
}
close(FILEIN);

for($j=0;$j<$nport;$j++){
  if((defined $float_port{$subckt_port[$j]})||(defined $float_noncpp_port{$subckt_port[$j]})){
    print FILESPICE "R$subckt_port[$j] n$subckt_port[$j] 0 $rfloat\n";
    if($measure_cap_flag == 1){
      print FILESPICE "Rc$subckt_port[$j] nc$subckt_port[$j] 0 $rfloat\n";
    }
    if(defined $genSparam){
      print FILESPICE "Rs$subckt_port[$j] ns$subckt_port[$j] 0 $rfloat\n";
    }
  }
}

if(defined $netname2){
  if( ((scalar (keys %short_port1)) > 0) || ((scalar (keys %short_port2)) > 0 ) ) {
    if( ((scalar (keys %short_port1)) > 0) && ((scalar (keys %short_port2)) > 0 ) ) {
      print FILESPICE "Rnshort1c nshort1c 0 $rfloat\n" ;
      print FILESPICE "Rnshort2c nshort2c 0 $rfloat\n" ;
      print FILESPICE "Vshort nshort1 nshort2 0\n" ;
    }else{
      if( (scalar (keys %short_port1)) == 0){
        die "ERROR: The PCB side of net1 is not represented by a port but net2 is.\n";
      }else{
        die "ERROR: The PCB side of net2 is not represented by a port but net1 is.\n";
      }
    }
  }else{
     print STDOUT "WARNING: The PCB side of net1 and net2 is not represented by a port.\n";
     print STDOUT "WARNING: Capacitance won't be measured.\n";
  }
}

if($measure_cap_flag == 1){
if(defined $netname2){
print FILESPICE <<EOF;
V1 nin nout ac 1.0
Rv1 nout 0 $rfloat
V1c ninc noutc ac 1.0
Rv1c noutc 0 $rfloat
EOF
}else{
print FILESPICE <<EOF;
V1 nin nout ac 1.0
Rv1 nout 0 $rfloat
V1c ninc 0 ac 1.0
Rv1c noutc 0 $rfloat
EOF
}
}else{
if(defined $netname2){
print FILESPICE <<EOF;
V1 nin nout ac 1.0
Rv1 nout 0 $rfloat
EOF
}else{
print FILESPICE <<EOF;
V1 nin nout ac 1.0
Rv1 nout 0 $rshort
EOF
}
}

if(defined $genSparam){
print FILESPICE <<EOF;
Rsnins nins 0 $rfloat
Rsnouts nouts 0 $rfloat
p1 nins     nouts    port=1 z0=50
.LIN sparcalc=1 format=touchstone dataformat=RI
EOF
if($measure_cap_flag == 1){
print FILESPICE <<EOF;
p2 nshort1s nshort2s port=2 z0=50
Rsnshort1s nshort1s 0 $rfloat
Rsnshort2s nshort2s 0 $rfloat
EOF
}
}

if($measure_cap_flag == 1){
print FILESPICE <<EOF;
.probe ac im(v1) ip(v1)
.print ac im(v1) ip(v1)
.ac $stepstyle $steps_per_dec $fmin $fmax
.param pi=3.141592654
.meas ac freq1 find par('hertz') at=$freq1
.meas ac Reff1 find par('-(ir(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1)))') at=freq1
.meas ac Leff1 find par('(ii(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1))/(2*pi*hertz))') at=freq1
.meas ac Ceff1 find par('(-(ir(v1c)*ir(v1c)+ii(v1c)*ii(v1c))/(ii(v1c)*2*pi*hertz))') at=freq1
*
.meas ac freq2 find par('hertz') at=$freq2
.meas ac Reff2 find par('-(ir(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1)))') at=freq2
.meas ac Leff2 find par('(ii(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1))/(2*pi*hertz))') at=freq2
.meas ac Ceff2 find par('(-(ir(v1c)*ir(v1c)+ii(v1c)*ii(v1c))/(ii(v1c)*2*pi*hertz))') at=freq2
*
.meas ac freq3 find par('hertz') at=$freq3
.meas ac Reff3 find par('-(ir(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1)))') at=freq3
.meas ac Leff3 find par('(ii(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1))/(2*pi*hertz))') at=freq3
.meas ac Ceff3 find par('(-(ir(v1c)*ir(v1c)+ii(v1c)*ii(v1c))/(ii(v1c)*2*pi*hertz))') at=freq3
*
.meas ac freq4 find par('hertz') at=$freq4
.meas ac Reff4 find par('-(ir(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1)))') at=freq4
.meas ac Leff4 find par('(ii(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1))/(2*pi*hertz))') at=freq4
.meas ac Ceff4 find par('(-(ir(v1c)*ir(v1c)+ii(v1c)*ii(v1c))/(ii(v1c)*2*pi*hertz))') at=freq4

.end
EOF
}else{
print FILESPICE <<EOF;
.probe ac im(v1) ip(v1)
.print ac im(v1) ip(v1)
.ac $stepstyle $steps_per_dec $fmin $fmax
.param pi=3.141592654
.meas ac freq1 find par('hertz') at=$freq1
.meas ac Reff1 find par('-(ir(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1)))') at=freq1
.meas ac Leff1 find par('(ii(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1))/(2*pi*hertz))') at=freq1
*
.meas ac freq2 find par('hertz') at=$freq2
.meas ac Reff2 find par('-(ir(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1)))') at=freq2
.meas ac Leff2 find par('(ii(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1))/(2*pi*hertz))') at=freq2
*
.meas ac freq3 find par('hertz') at=$freq3
.meas ac Reff3 find par('-(ir(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1)))') at=freq3
.meas ac Leff3 find par('(ii(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1))/(2*pi*hertz))') at=freq3
*
.meas ac freq4 find par('hertz') at=$freq4
.meas ac Reff4 find par('-(ir(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1)))') at=freq4
.meas ac Leff4 find par('(ii(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1))/(2*pi*hertz))') at=freq4

.end
EOF
}

close(FILESPICE);
if(($source_flag == 0)&&($sink_flag == 0)){
  die "ERROR: no source ports found.  Check net names.\nWARNING: no sink ports found.  Check net names.\n"
}
if($source_flag == 0){
  die "ERROR: no source ports found.  Check net names.\n"
}
if($sink_flag == 0){
  print STDOUT "WARNING: no sink ports found.  Capacitance won't be measured.  Check net names.\n"
}
}


sub parse_cpm_inc_model {

if(! defined $netname2){
  die "ERROR: Two net names are needed for cpm.inc RLC estimation.\n";
}

open(FILEIN,"<$filein" ) or die "\nCan't open input file $filein\n\n";
open(FILESPICE,">${file_test_bench}.sp" ) or die "\nCan't create file ${file_test_bench}.sp\n\n";

print FILESPICE <<EOF;
.option measdgt = 7
.option RESMIN=1e-8
.option probe post
.temp 25

.include '$filein'

V1 nin nout ac 1.0
Rv1 nout 0 $rfloat
EOF

while (<FILEIN>){
  chop($line = $_);
  if($line =~ m/^.subckt /i){
    @temp = split(/\s+/,$line);
    $subckt_name = $temp[1];
    $line =~ s/^.subckt [^ 	]+[ 	]*/+/i;
    $nport = 0;
    $i = 0;
    until( ! ($line =~ m/^[	 ]*[+]/)) {
      $line =~ s/[ 	]*[+][ 	]*//;
      @temp = split(/\s+/,$line);
      until( ! exists $temp[$i]){
        $subckt_port[$nport] = $temp[$i];
	$nport++;
	$i++;
      }
      $i = 0;
      chop($line = <FILEIN> );
    }
  }elsif($line =~ m/Pad name : port name : port id/){
    chop($line = <FILEIN> );
    @temp = split(/\s+/,$line);
    while(($line =~ m/^[*]/)&&(exists $temp[3])){
      if($line =~ m/ ${netname1}_/i){
        $source_port{$temp[3]} = 1;
      }elsif($line =~ m/ ${netname2}_/i){
        $sink_port{$temp[3]} = 1;
      }else{
        $float_port{$temp[3]} = 1;
      }
      chop($line = <FILEIN> );
      @temp = split(/\s+/,$line);
    }
  }elsif($line =~ m/Pad name : port name : net : port id/){
    chop($line = <FILEIN> );
    @temp = split(/\s+/,$line);
    while(($line =~ m/^[*]/)&&(exists $temp[4])){
      if($line =~ m/ ${netname1} /i){
        $source_port{$temp[4]} = 1;
      }elsif($line =~ m/ ${netname2} /i){
        $sink_port{$temp[4]} = 1;
      }else{
        $float_port{$temp[4]} = 1;
      }
      chop($line = <FILEIN> );
      @temp = split(/\s+/,$line);
    }
  }elsif($line =~ m/Pad name : Subckt terminal : net/){
    chop($line = <FILEIN> );
    @temp = split(/\s+/,$line);
    while(($line =~ m/^[*]/)&&(exists $temp[3])){
      if($line =~ m/ ${netname1}\b/i){
        $source_port{$temp[2]} = 1;
      }elsif($line =~ m/ ${netname2}\b/i){
        $sink_port{$temp[2]} = 1;
      }else{
        $float_port{$temp[2]} = 1;
      }
      chop($line = <FILEIN> );
      @temp = split(/\s+/,$line);
    }
  }
}
close(FILEIN);

print FILESPICE "X1 ";
#print STDOUT "nport = $nport\n";
for($j=0;$j<$nport;$j++){
  if(($j%5)==0){
    print FILESPICE "\n+";
  }
  if(defined $source_port{$subckt_port[$j]}){
    print FILESPICE " nin";
  }elsif(defined $sink_port{$subckt_port[$j]}){
    print FILESPICE " nout";
  }elsif(defined $float_port{$subckt_port[$j]}){
    print FILESPICE " n$subckt_port[$j]";
  }else{
    print FILESPICE " n$subckt_port[$j]";
    print STDERR "ERROR: PORT $subckt_port[$j] not source/sink/float.\n";
    $float_noncpp_port{$subckt_port[$j]} = 1;
  }
}
print FILESPICE "\n+ $subckt_name\n";

if(defined $genSparam){
  print FILESPICE "XS ";
  for($j=0;$j<$nport;$j++){
    if(($j%5)==0){
      print FILESPICE "\n+";
    }
    if(defined $source_port{$subckt_port[$j]}){
      print FILESPICE " nins";
    }elsif(defined $sink_port{$subckt_port[$j]}){
      print FILESPICE " nouts";
    }elsif(defined $short_port1{$subckt_port[$j]}){
      print FILESPICE " nshort1s";
    }elsif(defined $short_port2{$subckt_port[$j]}){
      print FILESPICE " nshort2s";
    }elsif(defined $float_port{$subckt_port[$j]}){
      print FILESPICE " ns$subckt_port[$j]";
    }else{
      print FILESPICE " ns$subckt_port[$j]";
      print STDERR "ERROR: PORT $subckt_port[$j] not source/sink/float.\n";
      $float_noncpp_port{$subckt_port[$j]} = 1;
    }

  }
  print FILESPICE "\n+ $subckt_name\n";
}

for($j=0;$j<$nport;$j++){
  if((defined $float_port{$subckt_port[$j]})||(defined $float_noncpp_port{$subckt_port[$j]})){
    print FILESPICE "R$subckt_port[$j] n$subckt_port[$j] 0 $rfloat\n";
    if(defined $genSparam){
      print FILESPICE "Rs$subckt_port[$j] ns$subckt_port[$j] 0 $rfloat\n";
    }
  }
}

if(defined $genSparam){
print FILESPICE <<EOF;
Rsnins nins 0 $rfloat
Rsnouts nouts 0 $rfloat
p1 nins     nouts    port=1 z0=0.01
.LIN sparcalc=1 format=touchstone dataformat=RI
EOF
}

print FILESPICE <<EOF;
.probe ac im(v1) ip(v1)
.print ac im(v1) ip(v1)
.ac dec $steps_per_dec $fmin $fmax
.param pi=3.141592654
.meas ac freq1 find par('hertz') at=$freq1
.meas ac dir_imag_i1 derivative par('ii(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1))') at=freq1
.meas ac imag_i1 find par('(ii(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1)))') at=freq1
.meas ac Reff1 find par('-(ir(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1)))') at=freq1
.meas ac Leff1 param='((freq1*dir_imag_i1 + imag_i1)/(4*freq1*pi))'
.meas ac Ceff1 param='(1./(freq1*pi*(freq1*dir_imag_i1 - imag_i1)))'
*
.meas ac freq2 find par('hertz') at=$freq2
.meas ac dir_imag_i2 derivative par('ii(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1))') at=freq2
.meas ac imag_i2 find par('(ii(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1)))') at=freq2
.meas ac Reff2 find par('-(ir(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1)))') at=freq2
.meas ac Leff2 param='((freq2*dir_imag_i2 + imag_i2)/(4*freq2*pi))'
.meas ac Ceff2 param='(1./(freq2*pi*(freq2*dir_imag_i2 - imag_i2)))'
*
.meas ac freq3 find par('hertz') at=$freq3
.meas ac dir_imag_i3 derivative par('ii(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1))') at=freq3
.meas ac imag_i3 find par('(ii(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1)))') at=freq3
.meas ac Reff3 find par('-(ir(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1)))') at=freq3
.meas ac Leff3 param='((freq3*dir_imag_i3 + imag_i3)/(4*freq3*pi))'
.meas ac Ceff3 param='(1./(freq3*pi*(freq3*dir_imag_i3 - imag_i3)))'
*
.meas ac freq4 find par('hertz') at=$freq4
.meas ac dir_imag_i4 derivative par('ii(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1))') at=freq4
.meas ac imag_i4 find par('(ii(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1)))') at=freq4
.meas ac Reff4 find par('-(ir(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1)))') at=freq4
.meas ac Leff4 param='((freq4*dir_imag_i4 + imag_i4)/(4*freq4*pi))'
.meas ac Ceff4 param='(1./(freq4*pi*(freq4*dir_imag_i4 - imag_i4)))'
*
.probe ac Cplot='(-(ir(v1)*ir(v1)+ii(v1)*ii(v1))/(ii(v1)*2*pi*hertz))'
*
.end
EOF
close(FILESPICE);

}

sub simulate_sparam_model {

$numberports = $sparamfile;
$numberports =~ s/^.*[.]s([0-9]+)p/$1/i;

open(FILESPICE,">${file_test_bench}.sp" ) or die "\nCan't create file ${file_test_bench}.sp\n\n";

print FILESPICE <<EOF;
.option measdgt = 7
.option RESMIN=1e-8
.option probe post
.temp 25

EOF

if($simulator eq "hspice"){
print FILESPICE <<EOF;
.model SMODEL S N=$numberports TSTONEFILE="$sparamfile"
Smodel 
EOF
}else{
print FILESPICE <<EOF;
.model SMODEL NPORT file="$sparamfile" np=$numberports dc=0
Nsmodel S(${numberports})
EOF
}
for($i=1; $i<=$numberports; $i++){
  if(defined $hash_lumpedports{$i}){
    print FILESPICE "+ nin nout\n";
  }elsif(defined $hash_shortedports{$i}){
    print FILESPICE "+ nshorta${i} nshortb${i}\n";
  }else{
    print FILESPICE "+ n$i 0\n";
  }
}
if($simulator eq "hspice"){
print FILESPICE <<EOF;
+ MNAME=SMODEL
EOF
}else{
print FILESPICE <<EOF;
+ SMODEL
EOF
}

if ($fit_model eq "T" ){
if($simulator eq "hspice"){
print FILESPICE <<EOF;
Smodelc 
EOF
}else{
print FILESPICE <<EOF;
Nsmodelc S(${numberports})
EOF
}
for($i=1; $i<=$numberports; $i++){
  if(defined $hash_lumpedports{$i}){
    print FILESPICE "+ ninc noutc\n";
  }elsif(defined $hash_shortedports{$i}){
    print FILESPICE "+ nshortca${i} 0\n";
  }else{
    print FILESPICE "+ nc$i 0\n";
  }
}
if($simulator eq "hspice"){
print FILESPICE <<EOF;
+ MNAME=SMODEL
EOF
}else{
print FILESPICE <<EOF;
+ SMODEL
EOF
}
}


print FILESPICE <<EOF;
V1 nin nout ac 1.0
Rv1 nout 0 $rfloat
EOF
for($i=1; $i<=$numberports; $i++){
  if(defined $hash_shortedports{$i}){
    print FILESPICE "Vshort${i} nshorta${i} nshortb${i} 0\n";
    print FILESPICE "Rshort${i} nshortb${i} 0 $rfloat\n";
  }
}
if ($fit_model eq "T" ){
print FILESPICE <<EOF;
V1c ninc noutc ac 1.0
Rv1c noutc 0 $rfloat
EOF
  for($i=1; $i<=$numberports; $i++){
    if(defined $hash_shortedports{$i}){
      print FILESPICE "Rshortca${i} nshortca${i} 0 $rfloat\n";
    }
  }
}

for($i=1; $i<=$numberports; $i++){
  if((! defined $hash_lumpedports{$i})&&(! defined $hash_shortedports{$i})){
    print FILESPICE "Rn$i n$i 0 $rfloat\n";
    if ($fit_model eq "T" ){
      print FILESPICE "Rnc$i nc$i 0 $rfloat\n";
    }
  }
}


if ($fit_model eq "T" ){
print FILESPICE <<EOF;
.probe ac im(v1) ip(v1)
.print ac im(v1) ip(v1)
.ac $stepstyle $steps_per_dec $fmin $fmax
.param pi=3.141592654
.meas ac freq1 find par('hertz') at=$freq1
.meas ac Reff1 find par('-(ir(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1)))') at=freq1
.meas ac Leff1 find par('(ii(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1))/(2*pi*hertz))') at=freq1
.meas ac Ceff1 find par('(-(ir(v1c)*ir(v1c)+ii(v1c)*ii(v1c))/(ii(v1c)*2*pi*hertz))') at=freq1
*
.meas ac freq2 find par('hertz') at=$freq2
.meas ac Reff2 find par('-(ir(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1)))') at=freq2
.meas ac Leff2 find par('(ii(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1))/(2*pi*hertz))') at=freq2
.meas ac Ceff2 find par('(-(ir(v1c)*ir(v1c)+ii(v1c)*ii(v1c))/(ii(v1c)*2*pi*hertz))') at=freq2
*
.meas ac freq3 find par('hertz') at=$freq3
.meas ac Reff3 find par('-(ir(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1)))') at=freq3
.meas ac Leff3 find par('(ii(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1))/(2*pi*hertz))') at=freq3
.meas ac Ceff3 find par('(-(ir(v1c)*ir(v1c)+ii(v1c)*ii(v1c))/(ii(v1c)*2*pi*hertz))') at=freq3
*
.meas ac freq4 find par('hertz') at=$freq4
.meas ac Reff4 find par('-(ir(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1)))') at=freq4
.meas ac Leff4 find par('(ii(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1))/(2*pi*hertz))') at=freq4
.meas ac Ceff4 find par('(-(ir(v1c)*ir(v1c)+ii(v1c)*ii(v1c))/(ii(v1c)*2*pi*hertz))') at=freq4

.end

EOF
}else{
print FILESPICE <<EOF;
.probe ac im(v1) ip(v1)
.print ac im(v1) ip(v1)
.ac dec $steps_per_dec $fmin $fmax
.param pi=3.141592654
.meas ac freq1 find par('hertz') at=$freq1
.meas ac dir_imag_i1 derivative par('ii(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1))') at=freq1
.meas ac imag_i1 find par('(ii(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1)))') at=freq1
.meas ac Reff1 find par('-(ir(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1)))') at=freq1
.meas ac Leff1 param='((freq1*dir_imag_i1 + imag_i1)/(4*freq1*pi))'
.meas ac Ceff1 param='(1./(freq1*pi*(freq1*dir_imag_i1 - imag_i1)))'
*
.meas ac freq2 find par('hertz') at=$freq2
.meas ac dir_imag_i2 derivative par('ii(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1))') at=freq2
.meas ac imag_i2 find par('(ii(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1)))') at=freq2
.meas ac Reff2 find par('-(ir(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1)))') at=freq2
.meas ac Leff2 param='((freq2*dir_imag_i2 + imag_i2)/(4*freq2*pi))'
.meas ac Ceff2 param='(1./(freq2*pi*(freq2*dir_imag_i2 - imag_i2)))'
*
.meas ac freq3 find par('hertz') at=$freq3
.meas ac dir_imag_i3 derivative par('ii(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1))') at=freq3
.meas ac imag_i3 find par('(ii(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1)))') at=freq3
.meas ac Reff3 find par('-(ir(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1)))') at=freq3
.meas ac Leff3 param='((freq3*dir_imag_i3 + imag_i3)/(4*freq3*pi))'
.meas ac Ceff3 param='(1./(freq3*pi*(freq3*dir_imag_i3 - imag_i3)))'
*
.meas ac freq4 find par('hertz') at=$freq4
.meas ac dir_imag_i4 derivative par('ii(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1))') at=freq4
.meas ac imag_i4 find par('(ii(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1)))') at=freq4
.meas ac Reff4 find par('-(ir(v1)/(ii(v1)*ii(v1)+ir(v1)*ir(v1)))') at=freq4
.meas ac Leff4 param='((freq4*dir_imag_i4 + imag_i4)/(4*freq4*pi))'
.meas ac Ceff4 param='(1./(freq4*pi*(freq4*dir_imag_i4 - imag_i4)))'
*
.probe ac Cplot='(-(ir(v1)*ir(v1)+ii(v1)*ii(v1))/(ii(v1)*2*pi*hertz))'
*
.end
EOF
}
close(FILESPICE);

}


sub neldermead_rlc {

#nelder mead simplex minimumization method

my $ur = -1.0;
my $ue = 2.0;
my $uoc = 0.5;
#my $uic = -0.5;
my $npoints = 0;
 $pi = 4.*atan(1.0);

 @freq = ();
 @current = ();
 @phase = ();
my @vec = ();
my @vsum = ();
my @vhash = ();
my @vmin = ();
my @vmincurrent = ();
my @vminphase = ();
my @svhash = ();
my %fhash = ();
my %sfhash = ();
my $N = 3;
if($fixvariables == 0){
  $N = 3;
}elsif(($fixvariables == 1)||($fixvariables == 2)||($fixvariables == 4)){
  $N = 2;
}elsif(($fixvariables == 3)||($fixvariables == 5)||($fixvariables == 6)){
  $N = 1;
}elsif($fixvariables == 7){
  $N = 0;
}
open (FILELOG, "< ${file_test_bench}.log") or die "\n ERROR: can't open ${file_test_bench}.log\n";
open (FILEMEASURE, "< simulated_rlc_values.txt") or die "\n ERROR: can't open simulated_rlc_values.txt\n";

if($simulator eq "hspice"){
  while (<FILELOG>){
    chop($line = $_);
    if($line =~ m/^\s*freq.*mag.*phase/){
      chop($line = <FILELOG>);
      chop($line = <FILELOG>);
      until ( ($line =~ m/^y$/) ){
        $line =~ s/^\s+//;
        $line =~ s/g/e9/g;
        $line =~ s/x/e6/g;
        $line =~ s/k/e3/g;
        $line =~ s/m/e-3/g;
        $line =~ s/u/e-6/g;
        $line =~ s/n/e-9/g;
        $line =~ s/p/e-12/g;
        $line =~ s/f/e-15/g;
        @temp = split(/\s+/,$line);
        if(($temp[0] > 1.0)&&($temp[0]<2.e12)){
          $freq[$npoints] = $temp[0] ;
          $current[$npoints] = $temp[1] ;
          $phase[$npoints] = $temp[2] ;
          $npoints++; 
        }
        chop($line = <FILELOG>);
      }
    }
  }
}else{
  while (<FILELOG>){
    chop($line = $_);
    if($line =~ m/^freq/){
      chop($line = <FILELOG>);
      until ( ($line =~ m/^$/) ){
        @temp = split(/\s+/,$line);
        if(($temp[0] > 1.0)&&($temp[0]<2.e12)){
          $freq[$npoints] = $temp[0] ;
          $current[$npoints] = $temp[1] ;
          $phase[$npoints] = $temp[2] ;
          $npoints++; 
        }
        chop($line = <FILELOG>);
      }
    }
  }
}
close(FILELOG);

$randc0 = .5;
for($q=0;$q<3;$q++){
  if($q == 0){
      chop($line = <FILEMEASURE>);
      for($i=0;$i<=$N;$i++) {
        chop($line = <FILEMEASURE>);
	$line =~ s/NA/10e-12/i;
        @temp = split(/\s+/,$line);
	for($i1=1;$i1<=3;$i1++){
	  if($temp[$i1] <= 0){
	    $temp[$i1] = 1e-15;
	  }
	}
        if($fixvariables == 0){
          $vhash[0]{$i} = $temp[1]*(1. + $randc0*(rand)); 
          $vec[0] = $vhash[0]{$i};
          $vmin[0] = $vhash[0]{$i};
          $vhash[1]{$i} = $temp[2]*(1. + $randc0*(rand)); 
          $vec[1] = $vhash[1]{$i};
          $vmin[1] = $vhash[1]{$i};
          $vhash[2]{$i} = $temp[3]*(1. + $randc0*(rand)); 
          $vec[2] = $vhash[2]{$i};
          $vmin[2] = $vhash[2]{$i};
        }elsif($fixvariables == 1){
          $vhash[0]{$i} = $temp[2]*(1. + $randc0*(rand)); 
          $vec[0] = $vhash[0]{$i};
          $vmin[0] = $vhash[0]{$i};
          $vhash[1]{$i} = $temp[3]*(1. + $randc0*(rand)); 
          $vec[1] = $vhash[1]{$i};
          $vmin[1] = $vhash[1]{$i};
	}elsif($fixvariables == 2){
          $vhash[0]{$i} = $temp[1]*(1. + $randc0*(rand)); 
          $vec[0] = $vhash[0]{$i};
          $vmin[0] = $vhash[0]{$i};
          $vhash[1]{$i} = $temp[3]*(1. + $randc0*(rand)); 
          $vec[1] = $vhash[1]{$i};
          $vmin[1] = $vhash[1]{$i};
	}elsif($fixvariables == 4){
          $vhash[0]{$i} = $temp[1]*(1. + $randc0*(rand)); 
          $vec[0] = $vhash[0]{$i};
          $vmin[0] = $vhash[0]{$i};
          $vhash[1]{$i} = $temp[2]*(1. + $randc0*(rand)); 
          $vec[1] = $vhash[1]{$i};
          $vmin[1] = $vhash[1]{$i};
        }elsif($fixvariables == 3){
          $vhash[0]{$i} = $temp[3]*(1. + $randc0*(rand)); 
          $vec[0] = $vhash[0]{$i};
          $vmin[0] = $vhash[0]{$i};
	}elsif($fixvariables == 5){
          $vhash[0]{$i} = $temp[2]*(1. + $randc0*(rand)); 
          $vec[0] = $vhash[0]{$i};
          $vmin[0] = $vhash[0]{$i};
	}elsif($fixvariables == 6){
          $vhash[0]{$i} = $temp[1]*(1. + $randc0*(rand)); 
          $vec[0] = $vhash[0]{$i};
          $vmin[0] = $vhash[0]{$i};
        }
        $fhash{$i} = func0 (\@vec,$npoints,$q);
        $fmin = $fhash{$i};
      }
    close(FILEMEASURE);
  }elsif($N != 0){
    for($i=0;$i<=$N;$i++){
      for($l=0;$l<$N;$l++){
        if(($i==0)&&(($q==1)||($q==2))){
          $vhash[$l]{$i} = $vmincurrent[$l]; 
          $vec[$l] = $vhash[$l]{$i};
	}elsif(($i==1)&&($q==2)){
          $vhash[$l]{$i} = $vminphase[$l]; 
          $vec[$l] = $vhash[$l]{$i};
	}else{
          $vhash[$l]{$i} = $vhash[$l]{$i}*(1. + 0.5*(1.-2.*(rand))); 
          $vec[$l] = $vhash[$l]{$i};
	}
      }
      $fhash{$i} = func0 (\@vec,$npoints,$q);
    }
  }
 if($N != 0){
  for($m=0;$m<=5000;$m++){
    $ii=0;
    foreach $k (sort {$fhash{$a} <=> $fhash{$b}} keys %fhash){
      for($l=0;$l<$N;$l++){
        $svhash[$l]{$ii} =  $vhash[$l]{$k};
      }
      $sfhash{$ii} =  $fhash{$k};
      $ii++;
    }
    for($i=0;$i<=$N;$i++){
      for($l=0;$l<$N;$l++){
        $vhash[$l]{$i} = $svhash[$l]{$i};
      }
      $fhash{$i} = $sfhash{$i};
    }
    for($l=0;$l<$N;$l++){
      $vsum[$l] = 0.0;
    }
    for($l=0;$l<$N;$l++){
      for($i=0;$i<=$N;$i++){
        $vsum[$l] += $vhash[$l]{$i};
      }
    }
    for($l=0;$l<$N;$l++){
      $vr[$l] = (1.0-$ur)*$vsum[$l]/$N - ((1.0-$ur)/$N - $ur)*$vhash[$l]{$N};
      $vr[$l] = abs($vr[$l]);
    }
    $fr = func0 (\@vr,$npoints,$q);
    if( $fhash{$N}>$fr ){
      $fhash{$N} = $fr;
      for($l=0;$l<$N;$l++){
        $vsum[$l] += ($vr[$l] - $vhash[$l]{$N});
        $vhash[$l]{$N} = $vr[$l];
      }
    }
    if($fr < $fhash{0}){
      for($l=0;$l<$N;$l++){
        $ve[$l] = (1.0-$ue)*$vsum[$l]/$N - ((1.0-$ue)/$N - $ue)*$vhash[$l]{$N};
        $ve[$l] = abs($ve[$l]);
      }
      $fe = func0 (\@ve,$npoints,$q);
      if( $fhash{$N}>$fe ){
        $fhash{$N} = $fe;
        for($l=0;$l<$N;$l++){
          $vsum[$l] += ($ve[$l] - $vhash[$l]{$N});
          $vhash[$l]{$N} = $ve[$l];
        }
      }
    }elsif( $fr>=$fhash{($N-1)} ){
      $fsave = $fhash{$N};
      for($l=0;$l<$N;$l++){
        $vc[$l] = (1.0-$uoc)*$vsum[$l]/$N - ((1.0-$uoc)/$N - $uoc)*$vhash[$l]{$N};
        $vc[$l] = abs($vc[$l]);
      }
      $fc = func0 (\@vc,$npoints,$q);
      if( $fhash{$N}>$fc ){
        $fhash{$N} = $fc;
        for($l=0;$l<$N;$l++){
          $vsum[$l] += ($vc[$l] - $vhash[$l]{$N});
          $vhash[$l]{$N} = $vc[$l];
        }
      }
      if($fc > $fsave){
        for($p=1;$p<=$N;$p++){
          for($l=0;$l<$N;$l++){
            $vsum[$l] = ($vhash[$l]{$p}+$vhash[$l]{0})/2.0;
            $vhash[$l]{$p} = $vsum[$l];
  	    $vec[$l] = $vhash[$l]{$p};
  	  }
          $fhash{$p} = func0 (\@vec,$npoints,$q);
        }
      }
    }
    if( (0.5*abs($fhash{$N}-$fhash{0})/(abs($fhash{$N}) + abs($fhash{0}))) < 1e-7 ){
      $m=5000;
    }
  }
  if($q == 0){
    for($l=0;$l<$N;$l++){
      $vmincurrent[$l] = $vhash[$l]{0};
    }
  }
  if($q == 1){
    for($l=0;$l<$N;$l++){
      $vminphase[$l] = $vhash[$l]{0};
    }
  }
  $fmin = $fhash{0};
  for($l=0;$l<$N;$l++){
    $vmin[$l] = $vhash[$l]{0};
  }
 }

  if($q == 0){
    print STDOUT "Fitting the current.\n";
    print STDOUT "reff\t\t\tleff\t\t\tceff\t\tsum(abs(fitcurrent-simcurrent))\n";
  }elsif($q == 1){
    print STDOUT "Fitting the phase.\n";
    print STDOUT "reff\t\t\tleff\t\t\tceff\t\tsum(abs(fitphase-simphase))\n";
  }else{
    print STDOUT "Fitting the product of current times phase.\n";
    print STDOUT "reff\t\t\tleff\t\t\tceff\t\tsum(abs(fitcurrent*fitphase-simcurrent*simphase))\n";
  }
  
  foreach $k (sort {$fhash{$a} > $fhash{$b}} keys %fhash){
    if($fixvariables == 0){
      print STDOUT "$vhash[0]{$k} $vhash[1]{$k} $vhash[2]{$k} $fhash{$k}\n";
    }elsif($fixvariables == 1){
      print STDOUT "$fixreff $vhash[0]{$k} $vhash[1]{$k} $fhash{$k}\n";
    }elsif($fixvariables == 2){
      print STDOUT "$vhash[0]{$k} $fixleff $vhash[1]{$k} $fhash{$k}\n";
    }elsif($fixvariables == 4){
      print STDOUT "$vhash[0]{$k} $vhash[1]{$k} $fixceff $fhash{$k}\n";
    }elsif($fixvariables == 3){
      print STDOUT "$fixreff $fixleff $vhash[0]{$k} $fhash{$k}\n";
    }elsif($fixvariables == 5){
      print STDOUT "$fixreff $vhash[0]{$k} $fixceff $fhash{$k}\n";
    }elsif($fixvariables == 6){
      print STDOUT "$vhash[0]{$k} $fixleff $fixceff $fhash{$k}\n";
    }elsif($fixvariables == 7){
      print STDOUT "$fixreff $fixleff $fixceff $fhash{$k}\n";
    }
  }

  if($q == 0){
    open (FILEVOLTAGE, "> raw_current.dat") or die "\n ERROR: can't open raw_current.dat\n";
    open (FILEFVOLTAGE, "> fitcurrent_current.dat") or die "\n ERROR: can't open fitcurrent_current.dat\n";
    open (FILEPHASE, "> raw_phase.dat") or die "\n ERROR: can't open raw_phase.dat\n";
    open (FILEFPHASE, "> fitcurrent_phase.dat") or die "\n ERROR: can't open fitcurrent_phase.dat\n";
  }elsif($q == 1){
    open (FILEFVOLTAGE, "> fitphase_current.dat") or die "\n ERROR: can't open fitphase_current.dat\n";
    open (FILEFPHASE, "> fitphase_phase.dat") or die "\n ERROR: can't open fitphase_phase.dat\n";
  }else{
    open (FILEFVOLTAGE, "> fitcurrentphase_current.dat") or die "\n ERROR: can't open fitcurrentphase_current.dat\n";
    open (FILEFPHASE, "> fitcurrentphase_phase.dat") or die "\n ERROR: can't open fitcurrentphase_phase.dat\n";
  }
  for($i=0;$i<$npoints;$i++){
    $omega = 2.*$pi*$freq[$i];
    if($fixvariables == 0){
      if($fit_model eq "T"){
        $tmp = -1./($vmin[0]/2. + i*$omega*$vmin[1]/2. + 1./(i*$omega*$vmin[2] + 1./($vmin[0]/2. + i*$omega*$vmin[1]/2.)));
      }else{
        $tmp = -1.0/($vmin[0] + i*( $omega*$vmin[1] - 1.0/($omega*$vmin[2])));
      }
    }elsif($fixvariables == 1){
      if($fit_model eq "T"){
        $tmp = -1./($fixreff/2. + i*$omega*$vmin[0]/2. + 1./(i*$omega*$vmin[1] + 1./($fixreff/2. + i*$omega*$vmin[0]/2.)));
      }else{
        $tmp = -1.0/($fixreff + i*( $omega*$vmin[0] - 1.0/($omega*$vmin[1])));
      }
    }elsif($fixvariables == 2){
      if($fit_model eq "T"){
        $tmp = -1./($vmin[0]/2. + i*$omega*$fixleff/2. + 1./(i*$omega*$vmin[1] + 1./($vmin[0]/2. + i*$omega*$fixleff/2.)));
      }else{
        $tmp = -1.0/($vmin[0] + i*( $omega*$fixleff - 1.0/($omega*$vmin[1])));
      }
    }elsif($fixvariables == 4){
      if($fit_model eq "T"){
        $tmp = -1./($vmin[0]/2. + i*$omega*$vmin[1]/2. + 1./(i*$omega*$fixceff + 1./($vmin[0]/2. + i*$omega*$vmin[1]/2.)));
      }else{
        $tmp = -1.0/($vmin[0] + i*( $omega*$vmin[1] - 1.0/($omega*$fixceff)));
      }
    }elsif($fixvariables == 3){
      if($fit_model eq "T"){
        $tmp = -1./($fixreff/2. + i*$omega*$fixleff/2. + 1./(i*$omega*$vmin[0] + 1./($fixreff/2. + i*$omega*$fixleff/2.)));
      }else{
        $tmp = -1.0/($fixreff + i*( $omega*$fixleff - 1.0/($omega*$vmin[0])));
      }
    }elsif($fixvariables == 5){
      if($fit_model eq "T"){
        $tmp = -1./($fixreff/2. + i*$omega*$vmin[0]/2. + 1./(i*$omega*$fixceff + 1./($fixreff/2. + i*$omega*$vmin[0]/2.)));
      }else{
        $tmp = -1.0/($fixreff + i*( $omega*$vmin[0] - 1.0/($omega*$fixceff)));
      }
    }elsif($fixvariables == 6){
      if($fit_model eq "T"){
        $tmp = -1./($vmin[0]/2. + i*$omega*$fixleff/2. + 1./(i*$omega*$fixceff + 1./($vmin[0]/2. + i*$omega*$fixleff/2.)));
      }else{
        $tmp = -1.0/($vmin[0] + i*( $omega*$fixleff - 1.0/($omega*$fixceff)));
      }
    }elsif($fixvariables == 7){
      if($fit_model eq "T"){
        $tmp = -1./($fixreff/2. + i*$omega*$fixleff/2. + 1./(i*$omega*$fixceff + 1./($fixreff/2. + i*$omega*$fixleff/2.)));
      }else{
        $tmp = -1.0/($fixreff + i*( $omega*$fixleff - 1.0/($omega*$fixceff)));
      }
    }
    if($q == 0){
      print FILEPHASE "$freq[$i] $phase[$i]\n";
      print FILEVOLTAGE "$freq[$i] $current[$i]\n";
      $ptmp =  180./$pi*theta($tmp);
      print FILEFPHASE "$freq[$i] $ptmp\n";;
      $atmp =  abs($tmp);
      print FILEFVOLTAGE "$freq[$i] $atmp\n";
    }elsif($q == 1){
      $ptmp =  180./$pi*theta($tmp);
      print FILEFPHASE "$freq[$i] $ptmp\n";;
      $atmp =  abs($tmp);
      print FILEFVOLTAGE "$freq[$i] $atmp\n";
    }else{
      $ptmp =  180./$pi*theta($tmp);
      print FILEFPHASE "$freq[$i] $ptmp\n";;
      $atmp =  abs($tmp);
      print FILEFVOLTAGE "$freq[$i] $atmp\n";
    }
  }
  if($q == 0){
    close (FILEVOLTAGE);
    close (FILEFVOLTAGE);
    close (FILEPHASE);
    close (FILEFPHASE);
  }elsif($q == 1){
    close (FILEFVOLTAGE);
    close (FILEFPHASE);
  }else{
    close (FILEFVOLTAGE);
    close (FILEFPHASE);
  }
}
}

sub func0 {
  my @v = @{$_[0]};
  my $np = $_[1];
  my $loop = $_[2];
  my $f = 0.0;
  my $tmp = 0.0;
  my $dphase = 0.0;
  my $dcurrent = 0.0;
  for($j=0;$j<$np;$j++){
    $omega = 2.*$pi*$freq[$j];
    if($fixvariables == 0){
      if($fit_model eq "T"){
        $tmp = -1./($v[0]/2. + i*$omega*$v[1]/2. + 1./(i*$omega*$v[2] + 1./($v[0]/2. + i*$omega*$v[1]/2.)));
      }else{
        $tmp = -1.0/($v[0] + i*( $omega*$v[1] - 1.0/($omega*$v[2])));
      }
    }elsif($fixvariables == 1){
      if($fit_model eq "T"){
        $tmp = -1./($fixreff/2. + i*$omega*$v[0]/2. + 1./(i*$omega*$v[1] + 1./($fixreff/2. + i*$omega*$v[0]/2.)));
      }else{
        $tmp = -1.0/($fixreff + i*( $omega*$v[0] - 1.0/($omega*$v[1])));
      }
    }elsif($fixvariables == 2){
      if($fit_model eq "T"){
        $tmp = -1./($v[0]/2. + i*$omega*$fixleff/2. + 1./(i*$omega*$v[1] + 1./($v[0]/2. + i*$omega*$fixleff/2.)));
      }else{
        $tmp = -1.0/($v[0] + i*( $omega*$fixleff - 1.0/($omega*$v[1])));
      }
    }elsif($fixvariables == 4){
      if($fit_model eq "T"){
        $tmp = -1./($v[0]/2. + i*$omega*$v[1]/2. + 1./(i*$omega*$fixceff + 1./($v[0]/2. + i*$omega*$v[1]/2.)));
      }else{
        $tmp = -1.0/($v[0] + i*( $omega*$v[1] - 1.0/($omega*$fixceff)));
      }
    }elsif($fixvariables == 3){
      if($fit_model eq "T"){
        $tmp = -1./($fixreff/2. + i*$omega*$fixleff/2. + 1./(i*$omega*$v[0] + 1./($fixreff/2. + i*$omega*$fixleff/2.)));
      }else{
        $tmp = -1.0/($fixreff + i*( $omega*$fixleff - 1.0/($omega*$v[0])));
      }
    }elsif($fixvariables == 5){
      if($fit_model eq "T"){
        $tmp = -1./($fixreff/2. + i*$omega*$v[0]/2. + 1./(i*$omega*$fixceff + 1./($fixreff/2. + i*$omega*$v[0]/2.)));
      }else{
        $tmp = -1.0/($fixreff + i*( $omega*$v[0] - 1.0/($omega*$fixceff)));
      }
    }elsif($fixvariables == 6){
      if($fit_model eq "T"){
        $tmp = -1./($v[0]/2. + i*$omega*$fixleff/2. + 1./(i*$omega*$fixceff + 1./($v[0]/2. + i*$omega*$fixleff/2.)));
      }else{
        $tmp = -1.0/($v[0] + i*( $omega*$fixleff - 1.0/($omega*$fixceff)));
      }
    }elsif($fixvariables == 7){
      if($fit_model eq "T"){
        $tmp = -1./($fixreff/2. + i*$omega*$fixleff/2. + 1./(i*$omega*$fixceff + 1./($fixreff/2. + i*$omega*$fixleff/2.)));
      }else{
        $tmp = -1.0/($fixreff + i*( $omega*$fixleff - 1.0/($omega*$fixceff)));
      }
    }
    $dcurrent = abs(abs($tmp) - $current[$j]);
    $dphase = abs((180./$pi*theta($tmp)) - $phase[$j]);
    $dphasecurrent = abs(abs($tmp)*(180./$pi*theta($tmp)) - $current[$j]*$phase[$j]);
    if($loop == 0){
      $f += $dcurrent;
    }elsif($loop == 1){
      $f += $dphase;
    }else{
      $f += $dphasecurrent;
    }
  }
  return $f;
}


if( $sim == 1 ){
  if($simulator eq "nspice"){
    $tfile = `which nspice`;
    chomp($tfile);
    if( -e $tfile){
      system ("$ENV{APACHEROOT}/bin/${simulator} ${file_test_bench}.sp -o ${file_test_bench}.log");
    }else{
      print STDERR "ERROR: can't find nspice, are you setup to use nspice?\n";
    }
  }elsif($simulator eq "hspice"){
    $tfile = `which hspice64`;
    chomp($tfile);
    if( -e $tfile){
      system ("${simulator}64 ${file_test_bench}.sp |tee ${file_test_bench}.log");
    }else{
      print STDERR "ERROR: can't find hspice, are you setup to use hspice?\n";
    }
  }else{
    die "\nERROR: Simulator \"$simulator\" not supported\n";
  }
  
  $flag = system ("/bin/grep -i error ${file_test_bench}.log >/dev/null");
  if ($flag == 0 ){
    die "\nERROR: problems during spice simulation.  Look at ${file_test_bench}.log\n";
  }
  
  if($simulator eq "nspice"){
    open (FILEMA, "< ${file_test_bench}.am0") or die "\n ERROR: can't open ${file_test_bench}.am0\n";
  }elsif($simulator eq "hspice"){
    open (FILEMA, "< ${file_test_bench}.ma0") or die "\n ERROR: can't open ${file_test_bench}.ma0\n";
  }
  open (SIMVALUES, "> simulated_rlc_values.txt") or die "\n ERROR: can't open simulated_rlc_values.txt\n";
  
  
  %hash_value = ();
  @vec_value = ();
  
  $read = 0;
  $index = 0;
  $noffset = 0;
  while(<FILEMA>){
   chomp($line=$_);
   $line =~ s/^\s*//;
   $idummy = 0;
   @vec_line = split(/\s+/,$line);
   if($read == 1){
     until(! defined $vec_line[$idummy]){
       $vec_value[$index] = $vec_line[$idummy];
       $hash_value{$vec_line[$idummy]} = $index;
       if($vec_line[$idummy] =~ /(temper|alter)/m){
         $noffset  = $index+1;
       }
       ++$index;
       ++$idummy;
     }
   }
   if($line =~ m/^.TITLE/i){
     $read = 1;
   }
  }
  close(FILEMA);
  print SIMVALUES "freq\t\treff\t\tleff\t\tceff\n";
  for($i=1;$i<=4;$i++){
    $fname = "freq" . "$i";
    $rname = "reff" . "$i";
    $lname = "leff" . "$i";
    $cname = "ceff" . "$i";
    print SIMVALUES "$vec_value[($hash_value{$fname} + $noffset)]\t";
    print SIMVALUES "$vec_value[($hash_value{$rname} + $noffset)]\t";
    print SIMVALUES "$vec_value[($hash_value{$lname} + $noffset)]\t";
    if(defined $hash_value{$cname}){
      print SIMVALUES "$vec_value[($hash_value{$cname} + $noffset)]\n";
    }else{
      print SIMVALUES "NA\n";
    }
  }
  close(SIMVALUES);
}

if( $fit == 1 ){
 neldermead_rlc ();
}
