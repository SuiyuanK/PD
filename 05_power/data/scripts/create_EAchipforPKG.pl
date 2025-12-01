eval '(exit $?0)' && eval 'exec perl -w -S $0 ${1+"$@"}' 
  && eval 'exec perl -w -S $0 $argv:q' if 0;

# Author: Chris Ortiz, chris@apache-da.com
# Apache Design Solutions. All rights reserved.

#Script to run RedHawk EA using user provided pkg model with CPP header or ploc file.


use Math::Complex;
use Getopt::Long;

#Using the bounding box defined by the CPP header
#active regions are only placed within the factional area
#described below. (x1,y1) lower left.  (x2,y2) upper right.


$result = GetOptions (
  "help|h|usage" => \$help ,
  "model|m=s" => \$filein ,
  "ploc=s" => \$plocfile ,
  "tech=s" => \$techfile ,
  "techlef=s" => \$techleffile ,
  "cpa_dir=s" => \$cpa_dir ,
  "voltage|v=f" => \$voltage ,
  "period|p=f" => \$period ,
  "rx_region=f" => \$rx_region ,
  "ry_region=f" => \$ry_region ,
  "rx_decap=f" => \$rx_decap ,
  "ry_decap=f" => \$ry_decap ,
  "pitchx_decap=f" => \$pitchx_decap ,
  "pitchy_decap=f" => \$pitchy_decap ,
  "capden_region=f" => \$capden_region ,
  "reff_region=f" => \$reff_region ,
  "capden_decap=f" => \$capden_decap ,
  "reff_decap=f" => \$reff_decap ,
  "high_pd=f" => \$high_pd , 
  "normal_pd=f" => \$normal_pd , 
  "low_pd=f" => \$low_pd ,
  "sim_time=f" => \$sim_time ,
  "gsr=s" => \$gsrfile ,
  "extendchip=f" => \$extendchip ,
  "presim_time=f" => \$presim_time 
);

if( ($help) || (! $result)){
print STDERR <<EOF;
usage:  create_flipchipTCforPKG.pl -model spice_pkg_subckt.txt  -tech apache_tech_file.tech -techlef technology_file.lef [ -voltage 1.0 ]
>]

-model    file name of the spice subckt for package with CPP header. 1 Power 1 Ground net.
-cpa_dir  rhcpa directory.  Full path to adsCPA directory.
-ploc     Annotated ploc file.  Use ploc file to override or in place of CPP header.
-tech     Apache's technology file.
-techlef  The lef file containing the via and conductor definitions for for your technology.
-voltage  Ideal voltage value in pkg model. (Default 1.0V)
-period  Specify the period of the activity in seconds.  (Default 2e-9 sec)
-capden_region  Specify the intrinsic capacitance density in fF/um^2 for regions.  (Default 2 fF/um^2)
-reff_region Specify the intrinsic resistance for each non-decap region (Default 1 ohm).
-capden_decap  Specify the intrinsic capacitance density in fF/um^2 for regions.  (Default 4 fF/um^2)
-reff_decap Specify the intrinsic resistance for each decap region (Default 1 ohm).
-rx_region  Specify the x length of the region in um.  (Default 100um)
-ry_region  Specify the y length of the region in um.  (Default 100um)
-rx_decap  Specify the x length of the decap in um.  (Default 100um)
-ry_decap  Specify the y length of the decap in um.  (Default 100um)
-pitchx_decap  Specify the x pitch of the decap columns in um.  (Default 500um)
-pitchy_decap  Specify the y pitch of the decap rows in um.  (Default 500um)
-high_pd  Specify the power density for the high power regions in uW/um^2.  (Default 10 uW/um^2)
-normal_pd  Specify the power density for the normal power regions in uW/um^2.  (Default 1 uW/um^2)
-low_pd  Specify the power density for the low power regions in uW/um^2.  (Default 0.1 uW/um^2)
-gsrfile     Grab the PG voltage values from a gsr file.
-sim_time  Specify the simulaton time in seconds.  (Default 20e-9)
-presim_time  Specify the pre-simulaton time in seconds.  (Default 20e-9)
-extendchip  Extend the active area of the chip by this many microns outside the bump boundary.  
EOF
exit;
}
if ( (! defined $filein ) && ( ! defined $cpa_dir)){
 die "\nERROR you must specify a package model name with the -model option.\n";
}
if ( ( defined $plocfile ) && (  defined $cpa_dir)){
 die "\nERROR Do not specify a ploc file is you are specifying an adsCPA directory.\n";
}
if (! defined $techfile ){
 die "\nERROR you must specify an apache tech file with the -tech option.\n";
}
if (! defined $techleffile ){
 die "\nERROR you must specify an tech lef file with the -techlef option.\n";
}elsif (! ( -e $techleffile ) ){
 die "\nERROR $techleffile does not exists.\n";
}
if (! defined $voltage ){
 $voltage = 1.0;
}
if (! defined $period ){
 $period = 2.0e-9;
}
if (! defined $capden_region ){
 $capden_region = 2.0;
}
if (! defined $reff_region ){
 $reff_region = 1.0;
}
if (! defined $capden_decap ){
 $capden_decap = 4.0;
}
if (! defined $reff_decap ){
 $reff_decap = 1.0;
}
if (! defined $rx_region ){
 $rx_region = 100.0;
}
if (! defined $ry_region ){
 $ry_region = 100.0;
}
if (! defined $rx_decap ){
 $rx_decap = 100.0;
}
if (! defined $ry_decap ){
 $ry_decap = 100.0;
}
if (! defined $pitchx_decap ){
 $pitchx_decap = 500.0;
}
if (! defined $pitchy_decap ){
 $pitchy_decap = 500.0;
}
if (! defined $high_pd ){
 $high_pd = 10.0;
}
if (! defined $normal_pd ){
 $normal_pd = 1.0;
}
if (! defined $low_pd ){
 $low_pd = 0.1;
}
if (! defined $sim_time ){
 $sim_time = 20e-9;
}
if (! defined $presim_time ){
 $presim_time = 20e-9;
}

$apldir = "myapldir";
if( ! ( -e $apldir ) ){
  system("mkdir $apldir");
}
$pwldir = "mypwldir";
if( ! ( -e $pwldir ) ){
  system("mkdir $pwldir");
}

if(defined $extendchip) {
  $active_frac_x1 = 0.00;
  $active_frac_x2 = 1.00;
  $active_frac_y1 = 0.00;
  $active_frac_y2 = 1.00;
}else{
  $active_frac_x1 = 0.05;
  $active_frac_x2 = 0.95;
  $active_frac_y1 = 0.05;
  $active_frac_y2 = 0.95;
}

$m = 0;
$n = 0;
$read_metal = 1;
@mstack = ();
@vstack = ();
open(FILETECH,"<$techfile" ) or die "\nCan't open input file $techfile\n";
while (<FILETECH>){
  chop($line = $_);
  if($line =~ m/^metal/){
    @temp = split(/\s+/,$line);
    if($read_metal == 1){
      if ( ! (( $temp[1] =~ m/metal0/i) || ($temp[1] =~ m/^c/i))){
        $mstack[$m] = $temp[1];
        $lmi = $m;
        $m++
      }
    }
    if( ($temp[1] =~ m/(^m[a-zA-Z_]*[1][^0-9]|metal0)/i) ){
      $read_metal = 0;
    }
  }
  if($line =~ m/^via/){
    @temp = split(/\s+/,$line);
    $vstack[$n] = $temp[1];
    $lvi = $n;
    $n++ ;
    until( $line =~ m/^[}]/ ){
      if($line =~ m/upperlayer/i){
        $via_upper_layer = $temp[1];
      }
      if($line =~ m/lowerlayer/i){
        $via_lower_layer = $temp[1];
      }
      chop($line = <FILETECH>);
      if( $line =~ m/(upperlayer|lowerlayer)/i){
        $line =~ s/^[ 	]*// ;
      }
      @temp = split(/\s+/,$line);
    }
    $dummy_str = "${via_upper_layer}___${via_lower_layer}";
    $via_ul_ll_number{$dummy_str} = ($n-1);
  }
}
close(FILETECH);

%cpp_ports = ();
%ploc_ports = ();
%subckt_ports = ();
%net_xy_ports = ();
%net_xy = ();
%nets = ();
$npins = 0;
$nnets = 0;
%gsr_pnets = ();
%gsr_gnets = ();
%pkg_pnets = ();
%pkg_gnets = ();
$subcktname = "";
%used_pg_pairs = ();

if ( defined $cpa_dir ){
  if( (-e $cpa_dir)){
    $xfl_file = `/bin/ls  ${cpa_dir}/dB/*.xfl`;
    (chop $xfl_file);
    open(FILE_XFL,"$xfl_file" ) or die "\nCan't open input file $xfl_file\n\n";
    while(<FILE_XFL>){
      chop($line = $_);
      if($line =~ m/^.PDNChannel_DIE/){
        until($line =~ m/^.endPDNChannel_DIE/){
          $line =~ s/["]//g;
          @tarray = split(/\s+/,$line);
  	if($line =~ m/^PLOC_FILE/){
  	  $plocfile = "${cpa_dir}/dB/$tarray[2]";
            if( ! (-e $plocfile)){
              die "ERROR the ploc file $plocfile does not exists.\n";
            }
          }
          chop($line = <FILE_XFL> );
        }
      }
    }
    close(FILE_XFL);
  }else{
    die "ERROR the adsCPA directory $cpa_dir does not exists.\n";
  }
}

if ( defined $plocfile ){
  open(PLOCFILE,"<$plocfile" ) or die "\nCan't open input file $plocfile\n";
  while (<PLOCFILE>){
    chop($line = $_);
    @temp = split(/\s+/,$line);
    if( ( ! $line =~ m/^[ 	]*[#]/ ) || ( ! $line =~ m/^[        ]*$/  ) ) {
      if( (! exists $temp[5]) && (! defined $cpa_dir ) ) {
        die "\nERROR ploc file needs to be annotated with pkg ports.  No 6th column found.\n";
      }
      $npins++;
      $x = $temp[1];
      $y = $temp[2];
      $net = $temp[4];
      $xy = "${x}___${y}";
      $net_xy{$xy} = $net;
      if( defined $temp[5]  ) {
        $net_xy_ports{$xy} = $temp[5];
        $ploc_ports{$temp[5]} = 1;
      }
      if(! defined $nets{$net}){
         $nets{$net} = 1;
         $nnets++;
       }
       if(! defined $xmin){
         $xmin = $x;
       }elsif($x<$xmin){
         $xmin = $x;
       }
       if(! defined $xmax){
         $xmax = $x;
       }elsif($x>$xmax){
         $xmax = $x;
       }
       if(! defined $ymin){
         $ymin = $y;
       }elsif($y<$ymin){
          $ymin = $y;
       }
       if(! defined $ymax){
         $ymax = $y;
       }elsif($y>$ymax){
         $ymax = $y;
       }
    }
  }
  close(PLOCFILE);
}else{
  open(FILEIN,"<$filein" ) or die "\nCan't open input file $filein\n";
  while (<FILEIN>){
    chop($line = $_);
    if($line =~ m/(Start|Begin) Chip Package Protocol/){
      until($line =~ m/Length/i){
        if($line =~ m/End Chip Package Protocol/){
          die "\nERROR Could not find Length unit definition in CPP header.\n";
        }
        chop($line = <FILEIN> );
      }
      if($line =~ m/um/i){
        $cppscale = 1;
      }elsif($line =~ m/mm/i){
        $cppscale = 1000;
      }elsif($line =~ m/mil/i){
        $cppscale = 24.5;
      }else{
        die "\nERROR Length unit in CPP header is not um, mm or mil\n";
      }
      until($line =~ m/End Chip Package Protocol/){
        chop($line = <FILEIN> );
        $line =~ s/[:=()]/ /g;
        if($line =~ m/^.subckt/i){
          die "\nERROR Trouble reading CPP header, found \".subckt\" before \"End Chip Package Protocol\".\n";
        }
        @temp = split(/\s+/,$line);
        if($line =~ m/DIE/){
  	$npins++;
          $x = $temp[2];
  	$x =~ s/^[+]//;
  	$x = $x*$cppscale;
          $y = $temp[3];
  	$y =~ s/^[+]//;
  	$y = $y*$cppscale;
          $net = $temp[5];
  	$xy = "${x}___${y}";
  	$net_xy{$xy} = $net;
  	$net_xy_ports{$xy} = $temp[4];
          if(! defined $nets{$net}){
  	  $nets{$net} = 1;
  	  $nnets++;
  	}
  	if(! defined $xmin){
  	  $xmin = $x;
  	}elsif($x<$xmin){
  	  $xmin = $x;
  	}
  	if(! defined $xmax){
  	  $xmax = $x;
  	}elsif($x>$xmax){
  	  $xmax = $x;
  	}
  	if(! defined $ymin){
  	  $ymin = $y;
  	}elsif($y<$ymin){
  	  $ymin = $y;
  	}
  	if(! defined $ymax){
  	  $ymax = $y;
  	}elsif($y>$ymax){
  	  $ymax = $y;
  	}
  	$cpp_ports{$temp[4]} = 1;
        }
      }
    }
  }
  close(FILEIN);
}


if(! defined $cpa_dir){
open(FILEIN,"<$filein" ) or die "\nCan't open input file $filein\n";
while (<FILEIN>){
  chop($line = $_);
  @temp = split(/\s+/,$line);
  if(($line =~ m/^.subckt/i) && (($subcktname =~ m/^$/)||($temp[1] =~ m/^redhawk_pkg$/i)) ){
    $subcktname = $temp[1];
    $i = 2;
    %subckt_ports = ();
    until(! exists $temp[$i]){
      $subckt_ports{$temp[$i]} = 1;
      $i++;
    }
    chop($line = <FILEIN> );
    until(! ($line =~ m/^\s*[+]/)){
      $line =~ s/^\s*[+]\s*//;
      @temp = split(/\s+/,$line);
      $i = 0;
      until(! exists $temp[$i]){
        $subckt_ports{$temp[$i]} = 1;
	$i++;
      }
      chop($line = <FILEIN> );
    }
  }
}
close(FILEIN);
}

if((! defined $xmin)||(! defined $xmax)||(! defined $ymin)||(! defined $ymax)){
  die "ERROR couldn't get [xmin,xmax,ymin,ymax] bounds from CPP header or ploc file.\n";
}
if( defined $extendchip ){
  $xmin -= $extendchip ;
  $xmax += $extendchip ;
  $ymin -= $extendchip ;
  $ymax += $extendchip ;
}

if(! defined $cpa_dir){
$ncommon = 0;
if ( defined $plocfile ){
 foreach $k ( keys %subckt_ports ){
   if( defined $ploc_ports{$k} ) {
     $ncommon++;
   }
 }
}else{
 foreach $k ( keys %subckt_ports ){
   if( defined $cpp_ports{$k} ) {
     $ncommon++;
   }
 }
}

if($ncommon == 0){
  if ( defined $plocfile ){
    die "ERROR No subckt ports in $subcktname are referenced by name in the ploc file.\n"
  }else{
    die "ERROR No subckt ports in $subcktname are referenced by name in the CPP header.\n"
  }
}
}

if ( defined $gsrfile ){
  open(USERGSR,"<$gsrfile" ) or die "\nCan't open input file $gsrfile\n";
  while (<USERGSR>){
    chop($line = $_);
    $line =~ s/^[ 	]*// ;
    if ( $line =~ m/^[^#]*VDD_NETS/ ) {
      $tline = $line;
      $tline =~ s/[^{]//g ;
      $ncb = length($tline) ;
      chop($line = <USERGSR>);
      $line =~ s/^[ 	]*// ;
      $tline = $line;
      $tline =~ s/[^{]//g ;
      $ncb += length($tline) ;
      until($ncb <= 0){
        next if m/^[    ]*[#]/;
        next if m/^$/;
	if( $line =~ m/[a-zA-Z0-9]\s+[0-9]/ ) {
          @temp = split(/\s+/,$line);
	  if( $temp[1] > 0 ) {
	    $gsr_pnets{$temp[0]} = $temp[1];
	  }else{
            print STDOUT "WARNING GSR power net, $temp[0], Has a voltage $temp[1], Default voltage , $voltage, will be used instead.\n";
            $gsr_pnets{$temp[0]} = $voltage;
	  }
	}
        chop($line = <USERGSR>);
        $line =~ s/^[ 	]*// ;
        $tline = $line;
        $tline =~ s/[^{]//g ;
        $ncb += length($tline) ;
        $tline = $line;
        $tline =~ s/[^}]//g ;
        $ncb -= length($tline) ;
      }
    }
    if ( $line =~ m/^[^#]*GND_NETS/ ) {
      $tline = $line;
      $tline =~ s/[^{]//g ;
      $ncb = length($tline) ;
      chop($line = <USERGSR>);
      $line =~ s/^[ 	]*// ;
      $tline = $line;
      $tline =~ s/[^{]//g ;
      $ncb += length($tline) ;
      until($ncb <= 0){
        next if m/^[    ]*[#]/;
        next if m/^$/;
	if( $line =~ m/[a-zA-Z0-9]\s+[0-9]/ ) {
          @temp = split(/\s+/,$line);
	  $gsr_gnets{$temp[0]} = $temp[1];
	}
        chop($line = <USERGSR>);
        $line =~ s/^[ 	]*// ;
        $tline = $line;
        $tline =~ s/[^{]//g ;
        $ncb += length($tline) ;
        $tline = $line;
        $tline =~ s/[^}]//g ;
        $ncb -= length($tline) ;
      }
    }
  }
  close(USERGSR);
}

if ( defined $gsrfile ){
 foreach $k ( keys %gsr_pnets ){
   if ( ! defined $nets{$k} ) {
     if ( defined $plocfile ){
       print STDOUT "WARNING Input GSR net $k has no definition in ploc. This net will not be analyzed.\n";
     }else{
       print STDOUT "WARNING Input GSR net $k has no definition in cpp. This net will not be analyzed.\n";
     }
   }
 }
 foreach $k ( keys %gsr_gnets ){
   if ( ! defined $nets{$k} ) {
     if ( defined $plocfile ){
       print STDOUT "WARNING Input GSR net $k has no definition in ploc. This net will not be analyzed.\n";
     }else{
       print STDOUT "WARNING Input GSR net $k has no definition in cpp. This net will not be analyzed.\n";
     }
   }
 }
}

foreach $k (keys %net_xy){
  $net = $net_xy{$k};
  if($net =~ m/(dd|cc)/i){
    if( defined $gsrfile ){
      if ( defined $gsr_pnets{$net} ) {
        $pkg_pnets{$net} = $gsr_pnets{$net};
      }elsif( defined $gsr_gnets{$net} ){
        $pkg_gnets{$net} = $gsr_gnets{$net};
      }else{
         print STDOUT "WARNING pkg net $net has no definition in gsr file. Default voltage , $voltage, will be used.\n";
         $pkg_pnets{$net} = $voltage;
      }
    }else{
      $pkg_pnets{$net} = $voltage;
    }
  }else{
    if( defined $gsrfile ){
      if ( defined $gsr_pnets{$net} ) {
        $pkg_pnets{$net} = $gsr_pnets{$net} ;
      }elsif( defined $gsr_gnets{$net} ){
        $pkg_gnets{$net} = $gsr_gnets{$net} ;
      }else{
        print STDOUT "WARNING pkg net $net has no definition in gsr file. Default voltage , 0, will be used.\n";
        $pkg_gnets{$net} = 0;
      }
    }else{
      $pkg_gnets{$net} = 0;
    }
  }
}


#Half the pad length in um.
$halfpadlength = 40;

$xmin -= $halfpadlength ;
$xmax += $halfpadlength ;
$ymin -= $halfpadlength ;
$ymax += $halfpadlength ;
$lx = ($xmax - $xmin);
$ly = ($ymax-$ymin);
$scale = 1000;
#$slx = $lx*$scale;
#$sly = $ly*$scale;
$sllx = $xmin*$scale;
$slly = $ymin*$scale;
$surx = $xmax*$scale;
$sury = $ymax*$scale;
$divisions = 100;
$frequency = 1./$period;
#tau1 is a short RC time constant. ex: average RC of a std cell.
$tau1 = 50e-12;  #tau1 can not equal tau2
#tau2 the time constant for an exponential probability density of switching. (limited to 100umx100um region)
$tau2 = 200e-12;
$taux = ($tau1*$tau2)/($tau2-$tau1);
#amount of charge under R100 current waveform for either 0->1 or 1->0 transition.
$Q =  ($normal_pd*1e-6*$rx_region*$ry_region)/($frequency*$voltage);
$QH =  ($high_pd*1e-6*$rx_region*$ry_region)/($frequency*$voltage);
$QL =  ($low_pd*1e-6*$rx_region*$ry_region)/($frequency*$voltage);
#Intrinsic capacitance of region (This number varies with technology)
$Reg_Ceff = $capden_region*1e-15*$rx_region*$ry_region ;
$Cap_Ceff = $capden_decap*1e-15*$rx_decap*$ry_decap ;
#Intrinsic resistance of region
$Reg_Reff = $reff_region;
$Cap_Reff = $reff_decap;

@nearest_gnd_net = ();
@nearest_pwr_net = ();

#$nx1 = (int $active_frac_x1*$lx/$rx_region) ;
#$nx2 = (int $active_frac_x2*$lx/$rx_region) ;
#$ny1 = (int $active_frac_y1*$ly/$ry_region) ;
#$ny2 = (int $active_frac_y2*$ly/$ry_region) ;
$nx1 = 0;
$nx2 = (int ($lx/$rx_region + 10)) ;
$ny1 = 0;
$ny2 = (int ($ly/$ry_region + 10)) ;
for($i=$nx1;$i<=$nx2;$i++){
  $tx = $xmin +$i*$rx_region + 0.5*$rx_region ;
  for($j=$ny1;$j<=$ny2;$j++){
    $ty = $ymin + $j*$ry_region + 0.5*$ry_region ;
    $nearest_gnd_dist = 1e10;
    $nearest_pwr_dist = 1e10;
    foreach $k (keys %net_xy){
      @coor = split(/___/,$k);
      $net = $net_xy{$k};
      $dist = ( abs($coor[0]-$tx) + abs($coor[1]-$ty) );
      if ( defined $pkg_pnets{$net} ) {
	if ( $dist < $nearest_pwr_dist){
          $nearest_pwr_dist = $dist;
          $nearest_pwr_net[$i][$j] = $net;
	}
      }elsif( defined $pkg_gnets{$net} ) {
	if ( $dist < $nearest_gnd_dist){
          $nearest_gnd_dist = $dist;
          $nearest_gnd_net[$i][$j] = $net;
	}
      }
    }
  }
}


if(! defined $cpa_dir){
%dnrports = ();
if( $subcktname =~ m/^redhawk_pkg$/i ){
  open(PKG_FILE,">/dev/null" ) or die "\nCan't open dump area /dev/null\n\n";
  $rh_pkg_file = $filein;
}else{
  open(PKG_FILE,">top.pkg" ) or die "\nCan't open input file top.pkg\n\n";
  $rh_pkg_file = "top.pkg";
}
print PKG_FILE ".SUBCKT REDHAWK_PKG\n+";
$autoplocfile = "top.ploc";
#$npf = 0;
#$autoplocfile = "top${npf}.ploc";
#if ( defined $plocfile ){
#  until( ! ( -e $autoplocfile )){
#    $npf++; 
#    $autoplocfile = "top${npf}.ploc";
#  }
#}
open(PLOC_FILE,">$autoplocfile" ) or die "\nCan't open input file $autoplocfile\n\n";
open(DEF_FILE,">top.def" ) or die "\nCan't open input file top.def\n\n";
print DEF_FILE <<EOF;
VERSION 5.6 ; 
NAMESCASESENSITIVE ON ; 
DIVIDERCHAR "/" ; 
BUSBITCHARS  "[]" ; 
DESIGN TOP ; 
UNITS DISTANCE MICRONS $scale ; 
DIEAREA ( $sllx $slly ) ( $surx $sury )  ; 
EOF

print DEF_FILE "PINS $npins ;\n";
$nports = 0;
foreach $k (keys %net_xy){
  @coor = split(/___/,$k);
  $sx = ($coor[0]-$halfpadlength)*$scale;
  $sy = ($coor[1]-$halfpadlength)*$scale;
  $spadlength = 2*$halfpadlength*$scale;
  $net = $net_xy{$k};
  if ( defined $pkg_pnets{$net} ) {
    $use = "POWER";
  }else{
    $use = "GROUND";
  }
  if((! defined $dnrports{$net_xy_ports{$k}})&&(defined $subckt_ports{$net_xy_ports{$k}})){
    $nports++;
    if($nports%10 == 0){
      print PKG_FILE "\n+";
    }
  }

  if(! defined $countpins{$net}){
    print DEF_FILE "- $net + NET $net + SPECIAL + USE $use + LAYER $mstack[0] ( 0 0 ) ( $spadlength $spadlength ) + PLACED ( $sx $sy ) N ;\n";
    if(defined $subckt_ports{$net_xy_ports{$k}}){
      print PLOC_FILE "my$net $coor[0] $coor[1] $mstack[0] $net $net_xy_ports{$k}\n";
      if(! defined $dnrports{$net_xy_ports{$k}}){
        print PKG_FILE " $net_xy_ports{$k}";
	$dnrports{$net_xy_ports{$k}} = 1;
      }
    }else{
      print STDOUT "WARNING port $net_xy_ports{$k} not referened in subckt. PLOC dropped.\n";
    }
    $countpins{$net}=1;
  }else{
    print DEF_FILE "- ${net}.$countpins{$net} + NET $net + SPECIAL + USE $use + LAYER $mstack[0] ( 0 0 ) ( $spadlength $spadlength ) + PLACED ( $sx $sy ) N ;\n";
    if(defined $subckt_ports{$net_xy_ports{$k}}){
      print PLOC_FILE "my$net.$countpins{$net} $coor[0] $coor[1] $mstack[0] $net $net_xy_ports{$k}\n";
      if(! defined $dnrports{$net_xy_ports{$k}}){
        print PKG_FILE " $net_xy_ports{$k}";
	$dnrports{$net_xy_ports{$k}} = 1;
      }
    }else{
      print STDOUT "WARNING port $net_xy_ports{$k} not referened in subckt. PLOC dropped.\n";
    }
    $countpins{$net}++;
  }
}

print PKG_FILE "\n";
print DEF_FILE "END PINS\n\n";
print DEF_FILE "SPECIALNETS $nnets ;\n";
foreach $k (keys %nets){
  if ( defined $pkg_pnets{$k} ) {
    $use = "POWER";
  }else{
    $use = "GROUND";
  }
  print DEF_FILE "- $k ( * $k ) + USE $use ;\n";
}
print DEF_FILE "END SPECIALNETS\n\n";
print DEF_FILE "END DESIGN\n";
close(DEF_FILE);
close(PLOC_FILE);
}else{
open(DEF_FILE,">top.def" ) or die "\nCan't open input file top.def\n\n";
print DEF_FILE <<EOF;
VERSION 5.6 ; 
NAMESCASESENSITIVE ON ; 
DIVIDERCHAR "/" ; 
BUSBITCHARS  "[]" ; 
DESIGN TOP ; 
UNITS DISTANCE MICRONS $scale ; 
DIEAREA ( $sllx $slly ) ( $surx $sury )  ; 
EOF

print DEF_FILE "PINS $npins ;\n";
$nports = 0;
foreach $k (keys %net_xy){
  @coor = split(/___/,$k);
  $sx = ($coor[0]-$halfpadlength)*$scale;
  $sy = ($coor[1]-$halfpadlength)*$scale;
  $spadlength = 2*$halfpadlength*$scale;
  $net = $net_xy{$k};
  if ( defined $pkg_pnets{$net} ) {
    $use = "POWER";
  }else{
    $use = "GROUND";
  }

  if(! defined $countpins{$net}){
    print DEF_FILE "- $net + NET $net + SPECIAL + USE $use + LAYER $mstack[0] ( 0 0 ) ( $spadlength $spadlength ) + PLACED ( $sx $sy ) N ;\n";
    $countpins{$net}=1;
  }else{
    print DEF_FILE "- ${net}.$countpins{$net} + NET $net + SPECIAL + USE $use + LAYER $mstack[0] ( 0 0 ) ( $spadlength $spadlength ) + PLACED ( $sx $sy ) N ;\n";
    $countpins{$net}++;
  }
}

print DEF_FILE "END PINS\n\n";
print DEF_FILE "SPECIALNETS $nnets ;\n";
foreach $k (keys %nets){
  if ( defined $pkg_pnets{$k} ) {
    $use = "POWER";
  }else{
    $use = "GROUND";
  }
  print DEF_FILE "- $k ( * $k ) + USE $use ;\n";
}
print DEF_FILE "END SPECIALNETS\n\n";
print DEF_FILE "END DESIGN\n";
close(DEF_FILE);
}

if(! defined $cpa_dir){
if( ! ( $subcktname =~ m/^redhawk_pkg$/i ) ){
  print PKG_FILE "\n.include $filein\n";
  open(FILEIN,"<$filein" ) or die "\nCan't open input file $filein\n";
  while (<FILEIN>){
    chop($line = $_);
    if($line =~ m/^.subckt\s+${subcktname}\b/i){
      @temp = split(/\s+/,$line);
      $line =~ s/^$temp[0]\s+$temp[1]//;
      $line = "X$subcktname $line";
      print PKG_FILE "$line\n";
      chop($line = <FILEIN> );
      until(! ($line =~ m/^\s*[+]/)){
        print PKG_FILE "$line\n";
        chop($line = <FILEIN> );
      }
      print PKG_FILE "+ $subcktname\n";
    }
  }
  if ( defined $plocfile ){
    foreach $k ( keys %subckt_ports ){
      if( ! defined $ploc_ports{$k} ) {
        print STDOUT "WARNING subckt port \"$k\" not defined as DIE in CPP header. A 1e9 resistor will tie off the port.\n";
        print PKG_FILE "Rtie$k $k 0 1e9\n";
      }
    }
  }else{
    foreach $k ( keys %subckt_ports ){
      if( ! defined $cpp_ports{$k} ) {
        print STDOUT "WARNING subckt port \"$k\" not defined as DIE in CPP header. A 1e9 resistor will tie off the port.\n";
        print PKG_FILE "Rtie$k $k 0 1e9\n";
      }
    }
  }
}

close(FILEIN);
print PKG_FILE ".ENDS REDHAWK_PKG\n";
close(PKG_FILE);
}

#$aax1 = $xmin + $active_frac_x1*$lx - $rx_region ;
#$aax2 = $xmin + $active_frac_x2*$lx + $rx_region ;
#$aay1 = $ymin + $active_frac_y1*$ly - $ry_region ;
#$aay2 = $ymin + $active_frac_y2*$ly + $ry_region ;


open(TCL_FILE,">top.tcl" ) or die "\nCan't open input file top.tcl\n\n";
print TCL_FILE <<EOF;
setup design top.gsr
import eco top.eco
mesh vias -bottomlayer $mstack[$lmi] -toplayer $mstack[2]
mesh vias -bottomlayer $mstack[2] -toplayer $mstack[1]
mesh vias -bottomlayer $mstack[1] -toplayer $mstack[0]
setup analysis_mode dynamic
perform pwrcalc
perform extraction -power -ground -c  -l
setup package -ignore
setup pad -ignore
setup wirebond  -ignore
perform analysis -vectorless
#explore design
EOF
close (TCL_FILE);

open( GSC_FILE,">top.gsc" ) or die "\nCan't open input file top.gsc\n\n";
print GSC_FILE <<EOF;
* toggle
EOF
close (GSC_FILE);


open( GSR_FILE,">top.gsr" ) or die "\nCan't open input file top.gsr\n\n";
$flag = system ("/bin/grep  metal0 $techfile >/dev/null");
if ($flag == 0 ){
  print GSR_FILE "\nTECHNOLOGY 20\n";
}
$nx1 = 0;
$nx2 = (int ($lx/$rx_region+10)) ;
$ny1 = 0;
$ny2 = (int ($ly/$ry_region+10)) ;
for($i=$nx1;$i<=$nx2;$i++){
  for($j=$ny1;$j<=$ny2;$j++){
    $pgpair = "${nearest_pwr_net[$i][$j]}__${nearest_gnd_net[$i][$j]}";
    $used_pg_pairs{$pgpair} = 1;
  }
}

print GSR_FILE <<EOF;

TEMPERATURE 25
TECH_FILE $techfile
LEF_FILES {
    $techleffile
}
DEF_FILES {
 top.def  top
}
VDD_NETS {
EOF
foreach $k ( keys %pkg_pnets ){
  print GSR_FILE "  $k $pkg_pnets{$k}\n";
}
print GSR_FILE <<EOF;
}
GND_NETS {
EOF
foreach $k ( keys %pkg_gnets ){
 print GSR_FILE "  $k $pkg_gnets{$k}\n";
}
print GSR_FILE <<EOF;
}
FREQ $frequency
INPUT_TRANSITION 50ps

BLOCK_POWER_ASSIGNMENT_FILE top.bpa 
ADD_PLOC_FROM_TOP_DEF 0
EOF
if( defined $cpa_dir ){
print GSR_FILE <<EOF;
CPA_MODEL $cpa_dir
APL_FILES {
EOF
}else{
print GSR_FILE <<EOF;
PAD_FILES {
 $autoplocfile
}
PACKAGE_SPICE_SUBCKT $rh_pkg_file
APL_FILES {
EOF
}
foreach $kp2 ( keys %pkg_pnets ){
  foreach $kg2 ( keys %pkg_gnets ){
    $pgpair2 = "${kp2}__${kg2}";
    if( defined $used_pg_pairs{$pgpair2} ) {
      print GSR_FILE "${apldir}/R100__${kp2}__${kg2}.cdev cap\n";
      print GSR_FILE "${apldir}/R100__${kp2}__${kg2}.spiprof current\n";
      print GSR_FILE "${apldir}/RH100__${kp2}__${kg2}.cdev cap\n";
      print GSR_FILE "${apldir}/RH100__${kp2}__${kg2}.spiprof current\n";
      print GSR_FILE "${apldir}/RL100__${kp2}__${kg2}.cdev cap\n";
      print GSR_FILE "${apldir}/RL100__${kp2}__${kg2}.spiprof current\n";
      print GSR_FILE "${apldir}/DECAP__${kp2}__${kg2}.cdev cap\n";
      print GSR_FILE "${apldir}/DECAP__${kp2}__${kg2}.spiprof current\n"
    }
  }
}
print GSR_FILE <<EOF;
}
USER_STA_FILE top.timing
DYNAMIC_PRESIM_TIME  $presim_time 5 .9
DYNAMIC_SIMULATION_TIME $sim_time
DYNAMIC_TIME_STEP 20e-12
GSC_FILE top.gsc
EOF
close(GSR_FILE);

open(BPA_FILE,">top.bpa" ) or die "\nCan't open input file top.bpa\n\n";
print BPA_FILE <<EOF;
BLOCK_POWER_MASTER_CELL {
EOF
foreach $kp1 ( keys %pkg_pnets ){
  foreach $kg1 ( keys %pkg_gnets ){
    $pgpair1 = "${kp1}__${kg1}";
    if( defined $used_pg_pairs{$pgpair1} ) {
      print BPA_FILE "R100__${kp1}__${kg1} 0 0 $rx_region $ry_region\n";
      print BPA_FILE "RH100__${kp1}__${kg1} 0 0 $rx_region $ry_region\n";
      print BPA_FILE "RL100__${kp1}__${kg1} 0 0 $rx_region $ry_region\n";
      print BPA_FILE "DECAP__${kp1}__${kg1} 0 0 $rx_decap $ry_decap\n";
    }
  }
}
print BPA_FILE <<EOF;
}
BLOCK_POWER_ASSIGNMENT {
EOF
open(TIMING_FILE,">top.timing" ) or die "\nCan't open input file top.timing\n\n";
$lmi_minus1 =  $lmi -1;
$dummy_str = "${mstack[$lmi_minus1]}___${mstack[$lmi]}";
if( defined $via_ul_ll_number{$dummy_str} ){
  $lv0 = $via_ul_ll_number{$dummy_str} ;
}else{
  $lv0 = $lvi;
}
$nx1 = (int $active_frac_x1*$lx/$rx_region) ;
$nx2 = (int $active_frac_x2*$lx/$rx_region) ;
$ny1 = (int $active_frac_y1*$ly/$ry_region) ;
$ny2 = (int $active_frac_y2*$ly/$ry_region) ;
for($i=$nx1;$i<=$nx2;$i++){
  $tx = $xmin +$i*$rx_region ;
  for($j=$ny1;$j<=$ny2;$j++){
    $ty = $ymin + $j*$ry_region ;
    if(($i>0.6*$nx2) && ($j>0.6*$ny2) && ($i<0.85*$nx2) && ($j<0.85*$ny2)){
      if( (rand) > 0.5 ){
        print BPA_FILE "REGION_${i}_${j} R100__${nearest_pwr_net[$i][$j]}__${nearest_gnd_net[$i][$j]} $vstack[$lv0] $nearest_pwr_net[$i][$j] -1 $tx $ty N\n";
        print BPA_FILE "REGION_${i}_${j} R100__${nearest_pwr_net[$i][$j]}__${nearest_gnd_net[$i][$j]} $vstack[$lv0] $nearest_gnd_net[$i][$j] -1 $tx $ty N\n";
        print BPA_FILE "REGION_${i}_${j} REGION OVERLAP_OK\n";
      }else{
        print BPA_FILE "REGION_${i}_${j} RH100__${nearest_pwr_net[$i][$j]}__${nearest_gnd_net[$i][$j]} $vstack[$lv0] $nearest_pwr_net[$i][$j] -1 $tx $ty N\n";
        print BPA_FILE "REGION_${i}_${j} RH100__${nearest_pwr_net[$i][$j]}__${nearest_gnd_net[$i][$j]} $vstack[$lv0] $nearest_gnd_net[$i][$j] -1 $tx $ty N\n";
        print BPA_FILE "REGION_${i}_${j} REGION OVERLAP_OK\n";
      }
    }else{
      if( (rand) > 0.2 ){
        print BPA_FILE "REGION_${i}_${j} R100__${nearest_pwr_net[$i][$j]}__${nearest_gnd_net[$i][$j]} $vstack[$lv0] $nearest_pwr_net[$i][$j] -1 $tx $ty N\n";
        print BPA_FILE "REGION_${i}_${j} R100__${nearest_pwr_net[$i][$j]}__${nearest_gnd_net[$i][$j]} $vstack[$lv0] $nearest_gnd_net[$i][$j] -1 $tx $ty N\n";
        print BPA_FILE "REGION_${i}_${j} REGION OVERLAP_OK\n";
      }else{
        print BPA_FILE "REGION_${i}_${j} RL100__${nearest_pwr_net[$i][$j]}__${nearest_gnd_net[$i][$j]} $vstack[$lv0] $nearest_pwr_net[$i][$j] -1 $tx $ty N\n";
        print BPA_FILE "REGION_${i}_${j} RL100__${nearest_pwr_net[$i][$j]}__${nearest_gnd_net[$i][$j]} $vstack[$lv0] $nearest_gnd_net[$i][$j] -1 $tx $ty N\n";
        print BPA_FILE "REGION_${i}_${j} REGION OVERLAP_OK\n";
      }
    }
    $n=0;
    for($z=1;$z<=10;$z++){
      if( (rand) > 0.5 ){
        $n++;
      }
    }
    if($n == 5){
      $tw = 0.07*2e-9;
    }elsif( ($n==4)||($n==6) ){
      $tw = 0.14*2e-9;
    }elsif( ($n==3)||($n==7) ){
      $tw = 0.21*2e-9;
    }elsif( ($n==2)||($n==8) ){
      $tw = 0.28*2e-9;
    }elsif( ($n==1)||($n==9) ){
      $tw = 0.35*2e-9;
    }else{
      $tw = 0.42*2e-9;
    }
    print TIMING_FILE "REGION_${i}_${j} TW $tw  $tw $frequency\n";
    print TIMING_FILE "REGION_${i}_${j} SL 50e-12 50e-12 \n";
  }
}
$nx1 = (int $active_frac_x1*$lx/$pitchx_decap) ;
if ($nx1 == 0) {
  $nx1 = 1;
}
$nx2 = (int $active_frac_x2*$lx/$pitchx_decap) ;
$ny1 = (int $active_frac_y1*$ly/$pitchy_decap) ;
if ($ny1 == 0) {
  $ny1 = 1;
}
$ny2 = (int $active_frac_y2*$ly/$pitchy_decap) ;
for($i=$nx1;$i<=$nx2;$i++){
  $tx = $xmin +$i*$pitchx_decap ;
  $ni = (int ($i*$pitchx_decap/$rx_region));
  for($j=$ny1;$j<=$ny2;$j++){
    $ty = $ymin + $j*$pitchy_decap ;
    $nj = (int ($j*$pitchy_decap/$ry_region));
    print BPA_FILE "REGIONCAP_${i}_${j} DECAP__${nearest_pwr_net[$ni][$nj]}__${nearest_gnd_net[$ni][$nj]} $vstack[$lv0] $nearest_pwr_net[$ni][$nj] -1 $tx $ty N\n";
    print BPA_FILE "REGIONCAP_${i}_${j} DECAP__${nearest_pwr_net[$ni][$nj]}__${nearest_gnd_net[$ni][$nj]} $vstack[$lv0] $nearest_gnd_net[$ni][$nj] -1 $tx $ty N\n";
    print BPA_FILE "REGIONCAP_${i}_${j} REGION OVERLAP_OK\n";
  }
}
print BPA_FILE "}\n";
close(BPA_FILE);
close(TIMING_FILE);


open(ECO_FILE,">top.eco" ) or die "\nCan't open input file top.eco\n\n";
$tmwidth = 5.75;
$tmspace = 6.0;
$nex1 = (int $active_frac_x1*$lx/$rx_region) ;
$nex2 = (int $active_frac_x2*$lx/$rx_region) ;
$ney1 = (int $active_frac_y1*$ly/($tmwidth + $tmspace)) ;
$ney2 = (int $active_frac_y2*$ly/($tmwidth + $tmspace)) ;
print ECO_FILE "#Redhawk_Eco_20\n";
print ECO_FILE "DESIGN TOP\n";
print ECO_FILE "UNIT $scale\n";
$neco = 1;

# bottom horizontal layer

for($je=$ney1;$je<=$ney2;$je++){
  $tye = $ymin + $je*($tmwidth + $tmspace) ;
  $nje = ( int  ($je*($tmwidth + $tmspace)/$ry_region)) ;
  for($ie=$nex1;$ie<=$nex2;$ie++){
    $txe = $xmin +$ie*$rx_region ;
    $nllx = (int $txe*$scale);
    $nlly = (int $tye*$scale);
    $nurx = (int (($txe+$rx_region-$tmwidth/2)*$scale));
    $nury = (int (($tye+$tmwidth)*$scale));
    if($je%2 == 0){
      $neco_net = ${nearest_gnd_net[$ie][$nje]};
      until ( ($neco_net ne ${nearest_gnd_net[$ie][$nje]}) || ($ie>$nex2)  ){
        $ie++;
      }
      $txe = $xmin +$ie*$rx_region ;
      $nurx = (int (($txe+$rx_region-$tmwidth/2)*$scale));
      print ECO_FILE "ADD wire eco_wire${neco}  $neco_net  $mstack[$lmi]  $nllx $nlly $nurx $nury horizontal\n";
      $neco++;
    }else{
      $neco_net = ${nearest_pwr_net[$ie][$nje]};
      until ( ($neco_net ne ${nearest_pwr_net[$ie][$nje]}) || ($ie>$nex2)  ){
        $ie++;
      }
      $txe = $xmin +$ie*$rx_region ;
      $nurx = (int (($txe+$rx_region-$tmwidth/2)*$scale));
      print ECO_FILE "ADD wire eco_wire${neco}  $neco_net  $mstack[$lmi]  $nllx $nlly $nurx $nury horizontal\n";
      $neco++;
    }
  }
}


# top vertical layer

$tmwidth = 10;
$tmspace = 12.0;
#$nex1 = (int $active_frac_x1*$lx/($tmwidth + $tmspace)) ;
#$nex2 = (int $active_frac_x2*$lx/($tmwidth + $tmspace)) ;
#$ney1 = (int $active_frac_y1*$ly/$ry_region) ;
#$ney2 = (int $active_frac_y2*$ly/$ry_region) ;
$nex1 = 0;
$nex2 = (int $lx/($tmwidth + $tmspace)) ;
$ney1 = 0;
$ney2 = (int $ly/$ry_region) ;

for($ie=$nex1;$ie<=$nex2;$ie++){
  $txe = $xmin + $ie*($tmwidth + $tmspace) ;
  $nie = ( int  ($ie*($tmwidth + $tmspace)/$rx_region)) ;
  for($je=$ney1;$je<=$ney2;$je++){
    $tye = $ymin +$je*$ry_region ;
    $nllx = (int $txe*$scale);
    $nlly = (int $tye*$scale);
    $nury = (int (($tye+$ry_region-$tmwidth/2)*$scale));
    $nurx = (int (($txe+$tmwidth)*$scale));
    if($ie%2 == 0){
      $neco_net = ${nearest_gnd_net[$nie][$je]};
      until ( ($neco_net ne ${nearest_gnd_net[$nie][$je]}) || ($je>$ney2)  ){
        $je++;
      }
      $tye = $ymin +$je*$ry_region ;
      $nury = (int (($tye+$ry_region-$tmwidth/2)*$scale));
      print ECO_FILE "ADD wire eco_wire${neco}  $neco_net  $mstack[2] $nllx $nlly $nurx $nury vertical\n";
      $neco++;
    }else{
      $neco_net = ${nearest_pwr_net[$nie][$je]};
      until ( ($neco_net ne ${nearest_pwr_net[$nie][$je]}) || ($je>$ney2)  ){
        $je++;
      }
      $tye = $ymin +$je*$ry_region ;
      $nury = (int (($tye+$ry_region-$tmwidth/2)*$scale));
      print ECO_FILE "ADD wire eco_wire${neco}  $neco_net  $mstack[2]  $nllx $nlly $nurx $nury vertical\n";
      $neco++;
    }
  }
}


$tmwidth = 10;
$tmspace = 12.0;
#$nex1 = (int $active_frac_x1*$lx/$rx_region) ;
#$nex2 = (int $active_frac_x2*$lx/$rx_region) ;
#$ney1 = (int $active_frac_y1*$ly/($tmwidth + $tmspace)) ;
#$ney2 = (int $active_frac_y2*$ly/($tmwidth + $tmspace)) ;
$nex1 = 0;
$nex2 = (int $lx/$rx_region) ;
$ney1 = 0;
$ney2 = (int $ly/($tmwidth + $tmspace)) ;

# top horizontal layer

for($je=$ney1;$je<=$ney2;$je++){
  $tye = $ymin + $je*($tmwidth + $tmspace) ;
  $nje = ( int  ($je*($tmwidth + $tmspace)/$ry_region)) ;
  for($ie=$nex1;$ie<=$nex2;$ie++){
    $txe = $xmin +$ie*$rx_region ;
    $nllx = (int $txe*$scale);
    $nlly = (int $tye*$scale);
    $nurx = (int (($txe+$rx_region-$tmwidth/2)*$scale));
    $nury = (int (($tye+$tmwidth)*$scale));
    if($je%2 == 0){
      $neco_net = ${nearest_gnd_net[$ie][$nje]};
      until ( ($neco_net ne ${nearest_gnd_net[$ie][$nje]}) || ($ie>$nex2)  ){
        $ie++;
      }
      $txe = $xmin +$ie*$rx_region ;
      $nurx = (int (($txe+$rx_region-$tmwidth/2)*$scale));
      print ECO_FILE "ADD wire eco_wire${neco}  $neco_net  $mstack[1] $nllx $nlly $nurx $nury horizontal\n";
      $neco++;
    }else{
      $neco_net = ${nearest_pwr_net[$ie][$nje]};
      until ( ($neco_net ne ${nearest_pwr_net[$ie][$nje]}) || ($ie>$nex2)  ){
        $ie++;
      }
      $txe = $xmin +$ie*$rx_region ;
      $nurx = (int (($txe+$rx_region-$tmwidth/2)*$scale));
      print ECO_FILE "ADD wire eco_wire${neco}  $neco_net $mstack[1]  $nllx $nlly $nurx $nury horizontal\n";
      $neco++;
    }
  }
}


close(ECO_FILE);




$step = $period/$divisions;



foreach $kp ( keys %pkg_pnets ){
  foreach $kg ( keys %pkg_gnets ){
    $pgpair3 = "${kp}__${kg}";
    if( defined $used_pg_pairs{$pgpair3} ) {
      gen_pwl ($pwldir, $kp, $kg);
    }
  }
}


foreach $kp ( keys %pkg_pnets ){
  foreach $kg ( keys %pkg_gnets ){
    $pgpair4 = "${kp}__${kg}";
    if( defined $used_pg_pairs{$pgpair4} ) {
      gen_apl ($pwldir, $apldir, $kp, $pkg_pnets{$kp}, $kg);
    }
  }
}

sub gen_pwl {
# supply the pwl direcotry and PG net name
  my $pwldir = $_[0];
  my $pwlpnet = $_[1];
  my $pwlgnet = $_[2];

  open(R100,">${pwldir}/R100__${pwlpnet}__${pwlgnet}.pwl" ) or die "\nCan't open input file ${pwldir}/R100__${pwlpnet}__${pwlgnet}.pwl\n\n";
    print R100 "I$pwlpnet $pwlpnet 0 pwl (\n";
    for ($i=0;$i<=$divisions;$i++){
      $time = $step*$i;
      $curr = ($Q/($taux*($tau1*$tau2-$tau1**2)));
      $curr = $curr*(($taux**2)*(exp(-$time/$tau2)-exp(-$time/$tau1))-$taux*$time*exp(-$time/$tau1));
      print R100 "+ $time $curr\n";
    }
    print R100 "+ )\n";
    print R100 "I$pwlgnet $pwlgnet 0 pwl (\n";
    for ($i=0;$i<=$divisions;$i++){
      $time = $step*$i;
      $curr = ($Q/($taux*($tau1*$tau2-$tau1**2)));
      $curr = $curr*(($taux**2)*(exp(-$time/$tau2)-exp(-$time/$tau1))-$taux*$time*exp(-$time/$tau1));
      print R100 "+ $time $curr\n";
    }
    print R100 "+ )\n";
  close(R100);
  open(RH100,">${pwldir}/RH100__${pwlpnet}__${pwlgnet}.pwl" ) or die "\nCan't open input file ${pwldir}/RH100__${pwlpnet}__${pwlgnet}.pwl\n\n";
    print RH100 "I$pwlpnet $pwlpnet 0 pwl (\n";
    for ($i=0;$i<=$divisions;$i++){
      $time = $step*$i;
      $curr = ($QH/($taux*($tau1*$tau2-$tau1**2)));
      $curr = $curr*(($taux**2)*(exp(-$time/$tau2)-exp(-$time/$tau1))-$taux*$time*exp(-$time/$tau1));
      print RH100 "+ $time $curr\n";
    }
    print RH100 "+ )\n";
    print RH100 "I$pwlgnet $pwlgnet 0 pwl (\n";
    for ($i=0;$i<=$divisions;$i++){
      $time = $step*$i;
      $curr = ($QH/($taux*($tau1*$tau2-$tau1**2)));
      $curr = $curr*(($taux**2)*(exp(-$time/$tau2)-exp(-$time/$tau1))-$taux*$time*exp(-$time/$tau1));
      print RH100 "+ $time $curr\n";
    }
    print RH100 "+ )\n";
  close(RH100);
  open(RL100,">${pwldir}/RL100__${pwlpnet}__${pwlgnet}.pwl" ) or die "\nCan't open input file ${pwldir}/RL100__${pwlpnet}__${pwlgnet}.pwl\n\n";
    print RL100 "I$pwlpnet $pwlpnet 0 pwl (\n";
    for ($i=0;$i<=$divisions;$i++){
      $time = $step*$i;
      $curr = ($QL/($taux*($tau1*$tau2-$tau1**2)));
      $curr = $curr*(($taux**2)*(exp(-$time/$tau2)-exp(-$time/$tau1))-$taux*$time*exp(-$time/$tau1));
      print RL100 "+ $time $curr\n";
    }
    print RL100 "+ )\n";
    print RL100 "I$pwlgnet $pwlgnet 0 pwl (\n";
    for ($i=0;$i<=$divisions;$i++){
      $time = $step*$i;
      $curr = ($QL/($taux*($tau1*$tau2-$tau1**2)));
      $curr = $curr*(($taux**2)*(exp(-$time/$tau2)-exp(-$time/$tau1))-$taux*$time*exp(-$time/$tau1));
      print RL100 "+ $time $curr\n";
    }
    print RL100 "+ )\n";
  close(RL100);
  open(DECAP,">${pwldir}/DECAP__${pwlpnet}__${pwlgnet}.pwl" ) or die "\nCan't open input file ${pwldir}/DECAP__${pwlpnet}__${pwlgnet}.pwl\n\n";
    print DECAP "I$pwlpnet $pwlpnet 0 pwl (\n";
    for ($i=0;$i<=$divisions;$i++){
      $time = $step*$i;
      $curr = 1e-8;
      print DECAP "+ $time $curr\n";
    }
    print DECAP "+ )\n";
    print DECAP "I$pwlgnet $pwlgnet 0 pwl (\n";
    for ($i=0;$i<=$divisions;$i++){
      $time = $step*$i;
      $curr = 1e-8;
      print DECAP "+ $time $curr\n";
    }
    print DECAP "+ )\n";
  close(DECAP);
}

sub gen_apl {
# create the apl files.
  my $pwldir = $_[0];
  my $apldir = $_[1];
  my $aplpnet = $_[2];
  my $myvoltage = $_[3];
  my $aplgnet = $_[4];

  open(SIM2IPROF_FILE,">${apldir}/R100__${aplpnet}__${aplgnet}.config" ) or die "\nCan't open input file ${apldir}/R100__${aplpnet}__${aplgnet}.config\n\n";
  print SIM2IPROF_FILE <<EOF;
  CELL R100__${aplpnet}__${aplgnet} {
    FILENAME {
      ${pwldir}/R100__${aplpnet}__${aplgnet}.pwl ${aplpnet}=$myvoltage
    }
    CDEV {
      $aplpnet $aplgnet {
        C0 = $Reg_Ceff
        C1 = $Reg_Ceff
        R0 = $Reg_Reff
        R1 = $Reg_Reff
        LEAK0 = 0
        LEAK1 = 0
      }
    }
  }
  SIM_TIME {
  READ 0e-12
  WRITE 0e-12
  }
  VDD_PIN $aplpnet
  VSS_PIN $aplgnet
EOF
  close(SIM2IPROF_FILE);
  
  
  open(SIM2IPROF_FILE,">${apldir}/RH100__${aplpnet}__${aplgnet}.config" ) or die "\nCan't open input file ${apldir}/RH100__${aplpnet}__${aplgnet}.config\n\n";
  print SIM2IPROF_FILE <<EOF;
  CELL RH100__${aplpnet}__${aplgnet} {
    FILENAME {
      ${pwldir}/RH100__${aplpnet}__${aplgnet}.pwl $aplpnet=$myvoltage
    }
    CDEV {
      $aplpnet $aplgnet {
        C0 = $Reg_Ceff
        C1 = $Reg_Ceff
        R0 = $Reg_Reff
        R1 = $Reg_Reff
        LEAK0 = 0
        LEAK1 = 0
      }
    }
  }
  SIM_TIME {
  READ 0e-12
  WRITE 0e-12
  }
  VDD_PIN $aplpnet
  VSS_PIN $aplgnet
EOF
  close(SIM2IPROF_FILE);
  
  
  open(SIM2IPROF_FILE,">${apldir}/RL100__${aplpnet}__${aplgnet}.config" ) or die "\nCan't open input file ${apldir}/RL100__${aplpnet}__${aplgnet}.config\n\n";
  print SIM2IPROF_FILE <<EOF;
  CELL RL100__${aplpnet}__${aplgnet} {
    FILENAME {
      ${pwldir}/RL100__${aplpnet}__${aplgnet}.pwl $aplpnet=$myvoltage
    }
    CDEV {
      $aplpnet $aplgnet {
        C0 = $Reg_Ceff
        C1 = $Reg_Ceff
        R0 = $Reg_Reff
        R1 = $Reg_Reff
        LEAK0 = 0
        LEAK1 = 0
      }
    }
  }
  SIM_TIME {
    READ 0e-12
    WRITE 0e-12
  }
  VDD_PIN $aplpnet
  VSS_PIN $aplgnet
EOF
  close(SIM2IPROF_FILE);
  
  
  open(SIM2IPROF_FILE,">${apldir}/DECAP__${aplpnet}__${aplgnet}.config" ) or die "\nCan't open input file ${apldir}/DECAP__${aplpnet}__${aplgnet}.config\n\n";
  print SIM2IPROF_FILE <<EOF;
  CELL DECAP__${aplpnet}__${aplgnet} {
    FILENAME {
      ${pwldir}/DECAP__${aplpnet}__${aplgnet}.pwl $aplpnet=$myvoltage
    }
    CDEV {
      $aplpnet $aplgnet {
        C0 = $Cap_Ceff
        C1 = $Cap_Ceff
        R0 = $Cap_Reff
        R1 = $Cap_Reff
        LEAK0 = 0
        LEAK1 = 0
      }
    }
  }
  SIM_TIME {
    READ 0e-12
    WRITE 0e-12
  }
  VDD_PIN $aplpnet
  VSS_PIN $aplgnet
EOF
  close(SIM2IPROF_FILE);
  
  
  $tfile = `which sim2iprof`;
  chomp($tfile);
  if( -e $tfile){
    system("sim2iprof ${apldir}/R100__${aplpnet}__${aplgnet}.config > ${apldir}/R100__${aplpnet}__${aplgnet}.log");
    if( -e "R100__${aplpnet}__${aplgnet}.cdev" ){
      system("mv R100__${aplpnet}__${aplgnet}.cdev  ${apldir}");
      system("mv R100__${aplpnet}__${aplgnet}.spiprof  ${apldir}");
    }
    system("sim2iprof ${apldir}/RH100__${aplpnet}__${aplgnet}.config > ${apldir}/RH100__${aplpnet}__${aplgnet}.log");
    if( -e "RH100__${aplpnet}__${aplgnet}.cdev" ){
      system("mv RH100__${aplpnet}__${aplgnet}.cdev  ${apldir}");
      system("mv RH100__${aplpnet}__${aplgnet}.spiprof  ${apldir}");
    }
    system("sim2iprof ${apldir}/RL100__${aplpnet}__${aplgnet}.config > ${apldir}/RL100__${aplpnet}__${aplgnet}.log");
    if( -e "RL100__${aplpnet}__${aplgnet}.cdev" ){
      system("mv RL100__${aplpnet}__${aplgnet}.cdev  ${apldir}");
      system("mv RL100__${aplpnet}__${aplgnet}.spiprof  ${apldir}");
    }
    system("sim2iprof ${apldir}/DECAP__${aplpnet}__${aplgnet}.config > ${apldir}/DECAP__${aplpnet}__${aplgnet}.log");
    if( -e "DECAP__${aplpnet}__${aplgnet}.cdev" ){
      system("mv DECAP__${aplpnet}__${aplgnet}.cdev  ${apldir}");
      system("mv DECAP__${aplpnet}__${aplgnet}.spiprof  ${apldir}");
    }
  }else{
    print STDERR "ERROR can't find sim2iprof, are you setup to use redhawk?\n";
  }
}


