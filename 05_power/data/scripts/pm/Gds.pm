package Gds;
require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(%gds %gdsmap
	     readGds printGds readGdsMap
	     processData printRecordHeader
	     printGdsSref packEndianInt
	     @recordtype
	     );
@EXPORT_OK = qw();
%EXPORT_TAGS = ();

use Util;
use Carp;
#------------------------------------------------------------------------#
#                     D A T A     S T R U C T U R E S                    #
#------------------------------------------------------------------------#
#
#$gds = (
#    'header' => {
#        'version' => float,
#        'date'    => "yr mon day hr min sec yr mon day hr min sec",
#        'libname' => string,
#        'units'   => "user_unit metric",
#    },
#    'structure' => {
#      $str_name => {
#        'boundary' => [
#            'layer'   => integer,
#            'datatype'=> integer,
#            'xy'      => "int int int ...",
#        ],
#        'path'     => [
#            'layer'   => integer,
#            'datatype'=> integer,
#            'xy'      => "int int int ...",
#        ],
#        'sref'     => [
#            'sname'   => string,
#            'xy'      => "int int int ...",
#        ],
#        'aref'     => [
#            'sname'   => string,
#            'colrow'  => "int int",
#            'xy'      => "int int int ...",
#        ],
#        'text'     => [
#            'layer'   => integer,
#            'texttype'=> integer,
#            'string'  => string,
#            'xy'      => "int int int ...",
#        ],
#        'node'     => [
#            'layer'   => integer,
#            'nodetype'=> integer,
#            'xy'      => "int int int ...",
#        ],
#        'box'      => [
#            'layer'   => integer,
#            'boxtype' => integer,
#            'xy'      => "int int int ...",
#        ],
#        'property' => [
#            'propattr'  => integer,
#            'propvalue' => string,
#        ],
#      }
#    }
#);
#


#------------------------------------------------------------------------#
#                     G L O B A L   V A R I A B L E S                    #
#------------------------------------------------------------------------#
%gds = ();
%gdsmap = ();
%record = (
           'HEADER' => [0,2],
           'BGNLIB' => [1,2],
          'LIBNAME' => [2,6],
            'UNITS' => [3,5],
           'ENDLIB' => [4,0],
           'BGNSTR' => [5,2],
          'STRNAME' => [6,6],
           'ENDSTR' => [7,0],
         'BOUNDARY' => [8,0],
             'PATH' => [9,0],
             'SREF' => [10,0],
             'AREF' => [11,0],
             'TEXT' => [12,0],
            'LAYER' => [13,2],
         'DATATYPE' => [14,2],
            'WIDTH' => [15,3],
               'XY' => [16,3],
            'ENDEL' => [17,0],
            'SNAME' => [18,6],
           'COLROW' => [19,2],
         'TEXTNODE' => [20,0],
             'NODE' => [21,0],
         'TEXTTYPE' => [22,2],
     'PRESENTATION' => [23,1],
          'SPACING' => [24,0],
           'STRING' => [25,6],
           'STRANS' => [26,1],
              'MAG' => [27,5],
            'ANGLE' => [28,5],
         'UINTEGER' => [29,0],
          'USTRING' => [30,0],
          'REFLIBS' => [31,6],
            'FONTS' => [32,6],
         'PATHTYPE' => [33,2],
      'GENERATIONS' => [34,2],
        'ATTRTABLE' => [35,6],
        'STYPTABLE' => [36,6],
          'STRTYPE' => [37,2],
          'ELFLAGS' => [38,1],
            'ELKEY' => [39,3],
         'LINKTYPE' => [40,0],
         'LINKKEYS' => [41,0],
         'NODETYPE' => [42,2],
         'PROPATTR' => [43,2],
        'PROPVALUE' => [44,6],
              'BOX' => [45,0],
          'BOXTYPE' => [46,2],
             'PLEX' => [47,3],
          'BGNEXTN' => [48,3],
          'ENDEXTN' => [49,3],
          'TAPENUM' => [50,2],
         'TAPECODE' => [51,2],
         'STRCLASS' => [52,1],
         'RESERVED' => [53,3],
           'FORMAT' => [54,2],
             'MASK' => [55,6],
         'ENDMASKS' => [56,0],
       'LIBDIRSIZE' => [57,2],
          'SRFNAME' => [58,6],
         'LIBSECUR' => [59,2],
           'BORDER' => [60,0],
        'SOFTFENCE' => [61,0],
        'HARDFENCE' => [62,0],
         'SOFTWIRE' => [63,0],
         'HARDWIRE' => [64,0],
         'PATHPORT' => [65,0],
         'NODEPORT' => [66,0],
   'USERCONSTRAINT' => [67,0],
     'SPACER_ERROR' => [68,0],
          'CONTACT' => [69,0]
	    );

@recordtype = (
           'HEADER', # 0
           'BGNLIB', # 1
          'LIBNAME', # 2
            'UNITS', # 3
           'ENDLIB', # 4
           'BGNSTR', # 5
          'STRNAME', # 6
           'ENDSTR', # 7
         'BOUNDARY', # 8
             'PATH', # 9
             'SREF', # 10
             'AREF', # 11
             'TEXT', # 12
            'LAYER', # 13
         'DATATYPE', # 14
            'WIDTH', # 15
               'XY', # 16
            'ENDEL', # 17
            'SNAME', # 18
           'COLROW', # 19
         'TEXTNODE', # 20
             'NODE', # 21
         'TEXTTYPE', # 22
     'PRESENTATION', # 23
          'SPACING', # 24
           'STRING', # 25
           'STRANS', # 26
              'MAG', # 27
            'ANGLE', # 28
         'UINTEGER', # 29
          'USTRING', # 30
          'REFLIBS', # 31
            'FONTS', # 32
         'PATHTYPE', # 33
      'GENERATIONS', # 34
        'ATTRTABLE', # 35
        'STYPTABLE', # 36
          'STRTYPE', # 37
          'ELFLAGS', # 38
            'ELKEY', # 39
         'LINKTYPE', # 40
         'LINKKEYS', # 41
         'NODETYPE', # 42
         'PROPATTR', # 43
        'PROPVALUE', # 44
              'BOX', # 45
          'BOXTYPE', # 46
             'PLEX', # 47
          'BGNEXTN', # 48
          'ENDEXTN', # 49
          'TAPENUM', # 50
         'TAPECODE', # 51
         'STRCLASS', # 52
         'RESERVED', # 53
           'FORMAT', # 54
             'MASK', # 55
         'ENDMASKS', # 56
       'LIBDIRSIZE', # 57
          'SRFNAME', # 58
         'LIBSECUR', # 59
           'BORDER', # 60
        'SOFTFENCE', # 61
        'HARDFENCE', # 62
         'SOFTWIRE', # 63
         'HARDWIRE', # 64
         'PATHPORT', # 65
         'NODEPORT', # 66
   'USERCONSTRAINT', # 67
     'SPACER_ERROR', # 68
          'CONTACT'  # 69
);

#------------------------------------------------------------------------#
# Synopsys : parses gds  file                                            #
# Args     : $file = lef  file name                                      #
# Ret      : 1                                                           #
#------------------------------------------------------------------------#
sub readGds {
  my ($file,$verbose) = @_;
  my $func = "Gds::readGds";
  my $abort = "";
  my ($buf,@head,$dlen,$rtype,$dtype,@value);
  my ($strname,$elmname,$type);
  my %attr = ();
  my $elecount = 0; # element count

  if($Util::debug){
    push @Util::fstack, join '~',$func,$file,$verbose;
  }

  print "parsing gds ...\n" if $verbose;

  unless(open GDS, "$file"){
    $abort = "can't open \"$file\"";
    goto FINAL;
  }

  while(read GDS, $buf, 4){
    @head = unpack "nCC", $buf;   # S:unsigned short, C:unsigned char
    $dlen =  $head[0] - 4;
    $rtype = $recordtype[$head[1]];
    $dtype = $head[2];

    # process data
    @value = ();
    if($dlen > 0){
      #### read binary data from file
      if((read GDS, $data, $dlen) != $dlen){  # read bytes are shorter
	$abort = "didn't get all data, looking for $dlen";
	goto FINAL;
      }
      @value = &processData($dtype,$dlen,$data);
    }

    $_ = $rtype;
    if(/HEADER/){
      $gds{header}{version} = $value[0];
    }
    elsif(/^BGNLIB$/){
      ## Y2K fix:
      $value[0]  = 2000 if ($value[0] == 0);
      $value[6]  = 2000 if ($value[6] == 0);
      $value[0] += 1900 if ($value[0] < 1900);
      $value[6] += 1900 if ($value[6] < 1900);
      $gds{header}{'date'}  = "@value";
    }
    elsif(/^LIBNAME$/){
      $gds{header}{libname} = $value[0];
    }
    elsif(/^UNITS$/){
      $gds{header}{units}  = "@value";
    }
    elsif(/^STRNAME$/){
      $strname = $value[0];
    }
    elsif(/^(BOUNDARY|PATH|SREF|AREF|TEXT|NODE|BOX|PROPERTY)$/){
      $elmname = lc $1;
    }
    elsif(/^(LAYER|SNAME|DATATYPE|NODETYPE|BOXTYPE|STRING|TEXTTYPE|PATHTYPE)$/){
      $type = lc $1;
      $attr{$type} = $value[0];
    }
    elsif(/^(XY|COLROW|ELFLAGS|PLEX|WIDTH|BGNEXTN|ENDEXTN|PRESENTATION|MAG|ANGLE)$/){
      $type = lc $1;
      $attr{$type} = "@value";
    }
    elsif(/^ENDEL$/){
      push @{ $gds{structure}{$strname}{$elmname} },{%attr};
      %attr = ();
      $elecount++;
      if ($verbose && ($elecount%100000) == 0){
	print "  processed $elecount elements\n" if $verbose;
      }
    }
    elsif(/ENDLIB/){
      print "  processed $elecount elements\n" if $verbose;
      print "done gds.\n" if $verbose;
      goto FINAL;
    }
  }

 FINAL:
  if($abort ne ""){
    print "\nERROR[$func] : $abort\n";
    &Util::dumpFstack();
    die;
  }
  if($Util::debug){
    pop @Util::fstack;
  }
  return 1;
}

#------------------------------------------------------------------------#
# Synopsys : processes the data portion of a record                      #
# Args     : $dtype = data type                                          #
#            $dlen = data length                                         #
#            $data = data in binary                                      #
# Ret      : 1                                                           #
#------------------------------------------------------------------------#
sub processData {
  my ($dtype,$dlen,$data) = @_;
  my $func = "Gds::processData";
  my $abort = "";
  my ($num,@d,@b,$i,$j,$f,$limit,@junk);
  my @value = ();

  if($Util::debug){
    push @Util::fstack, join '~',$func,$dtype,$data;
  }

  #### format binary data
  if($dtype == 1){                 # bit array
    $num = $dlen*8;
    @value = unpack "B$num",$data; # s:signed short
  }
  elsif($dtype == 2){              # two-byte signed integer
    $num = int($dlen*8/16);
    @value = unpack "n$num",$data; # s:signed short
  }
  elsif($dtype == 3){              # four-byte signed integer
    $num = int($dlen*8/32);
#    @value = unpack "i$num",$data; # i:signed integer
## WARNING! Serious hack ahead to fix little-endian numbers:
    @junk = unpack "N$num",$data; # i:signed integer
    for ($i = 0; $i <= $#junk; $i++) {
      if ($junk[$i] < 2147483648) {
        push(@value,$junk[$i]);
      }
      else {
        push(@value,$junk[$i]-4294967296);
      }
    }
  }
  elsif($dtype == 4){              # four-byte real (not used)
    die "unused data type : four-byte real\n";
  }
  elsif($dtype == 5){              # eight-byte real
    $num = int($dlen*8);
    @d = split //,unpack("B$num",$data); # B:bit string(high to low)
    $limit = $num/64;
    for($i=0;$i<$limit;$i++){
      @b = ();
      for($j=0;$j<64;$j++){
	$b[$j] = $d[$i*64+$j];
      }
      $f = &gds2float(@b);
      push @value, $f;
    }
  }
  elsif($dtype == 6){                 # ascii
    $num = int($dlen);
    $value[0] = unpack "A$num",$data; # A:ascii(space padded)
  }
  else{
    die "Unsupported data type : $dtype\n";
  }

 FINAL:
  if($abort ne ""){
    print "\nERROR[$func] : $abort\n";
    &Util::dumpFstack();
    die;
  }
  if($Util::debug){
    pop @Util::fstack;
  }
  return @value;
}

sub gds2float{
  my ($sign,$i,$exp,$mult,$f);
  
  #### get sign bit
  $sign = $_[0];

  #### get exponent
  for($i=1,$exp=0,$mult=64;$i<8;$i++,$mult=$mult/2){
    $exp += $_[$i] * $mult;
  }
  $exp -= 64;
  $exp = 16**$exp;

  #### get mantissa
  for($i=8,$mantissa=0,$mult=0.5;$i<64;$i++,$mult=$mult/2){
    $mantissa += $_[$i] * $mult;
  }
  $f = $exp * $mantissa;

  return($f);
}

#------------------------------------------------------------------------#
# Synopsys : parses gds map file                                         #
# Args     : $file = map file name                                       #
# Ret      : 1                                                           #
#------------------------------------------------------------------------#
sub readGdsMap {
  my ($file,$verbose) = @_;
  my @alist;

  unless(open MAP, "$file"){
    confess "ERROR: can't open \"$file\"";
  }

  while(<MAP>){
    if(/^\s*$/ || /^\#/){  ## skip blanks and comments
      next;
    }
    else{
      @alist = split /\s+/;
      $alist[0] =~ s/:\S// if $alist[0] =~ /:/;
      $gdsmap{$alist[1]} = $alist[0];
    }
  }
  close MAP;

  return 1;
}

#------------------------------------------------------------------------#
# Synopsys : prints the header for the record                            #
# Args     : $rtype = record type                                        #
#            $dlen = data length                                         #
# Ret      : 1                                                           #
#------------------------------------------------------------------------#
sub printRecordHeader {
  my ($rtype,$dlen) = @_;
  my $header;

  $header = pack "nCC",$dlen,$record{$rtype}[0],$record{$rtype}[1];
  return $header;
}

#------------------------------------------------------------------------#
# Synopsys : packs data for records in a consistent way                  #
# Args     : $spec = data type (use only for type "i")                   #
#            @rest = data                                                #
# Ret      : packed data                                                 #
#------------------------------------------------------------------------#
sub packEndianInt {
  my ($spec,@rest) = @_;
  my $abort = "";
  my $func = "Gds::packEndianInt";
  my $data = ""; 
  my $i = 0;

  if ($spec !~ /^i/) {
    $abort = "illegal argument: $spec";
    goto FINAL;
  }

  $spec =~ s/^\D+//;
  ## This is the ugly part. Convert negative INTs to longs in network order:
  for ($i = 0;$i < $spec;$i++) {
    $rest[$i] += 4294967296 if ($rest[$i] < 0);
  }
  $data = pack "N$spec",@rest;
  
 FINAL:
  if($abort ne ""){
    print "\nERROR[$func] : $abort\n";
    &Util::dumpFstack();
    die;
  }
  if($Util::debug){
    pop @Util::fstack;
  }
  return $data;
}
#------------------------------------------------------------------------#
# Synopsys : prints the sref                                             #
# Args     : $sname = name of the structure                              #
#            $x = x coord.                                               #
#            $y = y coord.                                               #
#            $mag = magnification factor                                 #
#            $angle = angle                                              #
# Ret      : 1                                                           #
#------------------------------------------------------------------------#
sub printGdsSref {
  my ($sname,$x,$y,$mag,$angle) = @_;
  my ($header,$data);
  my @alist = split //,$sname;
  my $num = @alist;

  ## SREF
  $header = &printRecordHeader('SREF',4);
  print $header;
  ## SNAME
  $header = &printRecordHeader('SNAME',($num+4));
  $data = pack "a$num",$sname;
  print $header;
  print $data;
  ## XY
  $header = &printRecordHeader('XY',12);
  $data = &packEndianInt("i2",$x,$y);
  print $header;
  print $data;
  $header = &printRecordHeader('ENDEL',4);
  print $header;
}

#------------------------------------------------------------------------#
# Synopsys : prints gds                                                  #
# Args     :                                                             #
# Ret      : 1                                                           #
#------------------------------------------------------------------------#
sub printGds {
  my ($a,$s,$e,$g,$E);

  ## print header
  print "header :\n";
  print "  version : $gds{header}{version}\n";
  print "  date    : $gds{header}{'date'}\n";
  print "  libname : $gds{header}{libname}\n";
  print "  units   : $gds{header}{'units'}\n";
  print "\n";

  ## print str's
#  print "structures :\n";
  foreach $s (keys %{ $gds{structure} }){
    print "BGNSTR STRNAME $s\n";
    foreach $e (keys %{ $gds{structure}{$s} }){
      if(defined $gds{structure}{$s}{$e}){
	$E = uc $e;
	for($i=0;$i<@{$gds{structure}{$s}{$e}};$i++){
	  print "  $E ";
	  foreach $a (keys %{ $gds{structure}{$s}{$e}[$i] }){
	    print "$a $gds{structure}{$s}{$e}[$i]{$a} ";
	  }
	  print "ENDEL\n";
	}
      }
    }
    print "ENDSTR\n";
  }
}
