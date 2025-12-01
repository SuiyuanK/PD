package Util;
require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(date makeDir isHashDefined isArrayDefined minMax
	     isEven isOdd dumpFstack
	     existFile printTitle printChar printBloatString
	     compareHash
	     $debug @fstack
	    );
@EXPORT_OK = qw();
%EXPORT_TAGS = ();

use Carp;
#------------------------------------------------------------------------#
#                     D A T A     S T R U C T U R E S                    #
#------------------------------------------------------------------------#

$debug = 0;   # debug flag
@fstack = (); # function stack

#------------------------------------------------------------------------#
# Synopsys : returns today's date in mm/dd/yy format                     #
# Args     :                                                             #
# Ret      : string                                                      #
#------------------------------------------------------------------------#
sub date {
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

  $mon++;  # originally 0 .. 11
  $date = $mon . '/' . $mday . '/' . $year;
  return $date;
}

#------------------------------------------------------------------------#
# Synopsys : makes a dir. if exists, noop.                               #
# Args     : $dir = name of the director                                 #
# Ret      : 1                                                           #
#------------------------------------------------------------------------#
sub makeDir {
  my($dir) =@_;
  my $func = "Util::makeDir";
  my $abort = "";

  if($debug){
    push @fstack, join '~',$func,$dir;
  }

  if(!(-e $dir && -d $dir)){
    if(!mkdir($dir,0777)){
      $abort = "can't make $dir";
    }
  }

 FINAL:
  if($abort ne ""){
    print "\nERROR[$func] : $abort\n";
    &dumpFstack();
    die;
  }
  if($debug){
    pop @fstack;
  }
  return 1;
}
   
#------------------------------------------------------------------------#
# Synopsys : checks to see if a hash is defined                          #
# Args     : $hashref = reference to hash                                #
#            $key = key of the hash                                      #
# Ret      : 1 | 0                                                       #
#------------------------------------------------------------------------#
sub isHashDefined {
  my ($hashref,$key) = @_;
  my $error = "ERROR[Util::isHashDefined]";
  my $func = "Util::isHashDefined";
  my $abort = "";
  my $rval = 1;

  if($debug){
    push @fstack, join '~',$func,$hashref,$key,$cc;
  }

  if(!defined $hashref->{$key}){
    $rval = 0;
    goto FINAL;
  }

 FINAL:
  if($abort ne ""){
    print "\n$abort\n";
    &dumpFstack();
    die;
  }
  if($debug){
    pop @fstack;
  }
  return $rval;

}

#------------------------------------------------------------------------#
# Synopsys : checks to see if array is defined                           #
# Args     : $arryref = reference to an array                            #
#            $index = index to the array                                 #
# Ret      : 1                                                           #
#------------------------------------------------------------------------#
sub isArrayDefined {
  my ($arryref,$index,$cc) = @_;
  my $error = "ERROR[Util::isArrayDefined($cc)]";
  my $func = "Util::isArrayDefined";
  my $abort = "";

  if($debug){
    push @fstack, join '~',$func,$arryref,$index,$cc;
  }

  if(!defined $arryref->[$index]){
    $abort = "$error : $index is not defined";
    goto FINAL;
  }

 FINAL:
  if($abort ne ""){
    print "\n$abort\n";
    &dumpFstack();
    die;
  }
  if($debug){
    pop @fstack;
  }
}

#------------------------------------------------------------------------#
# Synopsys : returns min & max value in an array                         #
# Args     :                                                             #
# Ret      : $maxval = max value of the array                            #
#            $minval = min value of the array                            #
#------------------------------------------------------------------------#
sub minMax {
  my $func = "Util::minMax";
  my $abort = "";

  if($debug){
    push @fstack, join '~',$func,"";
  }

  if(@_ == 0){
    $abort = "array empty";
    goto FINAL;
  }

  my $minval = $_[0];
  my $maxval = $_[0];
  foreach $v (@_){
    if($v < $minval){
      $minval = $v;
    }
    if($v > $maxval){
      $maxval = $v;
    }
  }

 FINAL:
  if($abort ne ""){
    print "\nERROR[$func] : $abort\n";
    &dumpFstack();
    die;
  }
  if($debug){
    pop @fstack;
  }
  return ($minval,$maxval);
}

#------------------------------------------------------------------------#
# Synopsys : check to see if the number is an even number                #
# Args     : $num = the number to check                                  #
# Ret      : 1 | 0                                                       #
#------------------------------------------------------------------------#
sub isEven {
  my ($num) = @_;
  my $result;
  my $func = "Util::isEven";
  my $abort = "";
  my $rval = 1;

  if($debug){
    push @fstack, join '~',$func,$num;
  }

  if($num < 0){
    $abort = "\"$num\" is a negative number.";
  }
  elsif($num == 0){
    $rval = 1;
  }
  else{
    $result = $num % 2;
    if($result == 0){
      $rval = 1;
    }
    else{
      $rval = 0;
    }
  }

 FINAL:
  if($abort ne ""){
    print "\nERROR[$func] : $abort\n";
    &dumpFstack();
    die;
  }
  if($debug){
    pop @fstack;
  }
  return $rval;
}
  
#------------------------------------------------------------------------#
# Synopsys : check to see if the number is an odd number                #
# Args     : $num = the number to check                                  #
# Ret      : 1 | 0                                                       #
#------------------------------------------------------------------------#
sub isOdd {
  my ($num) = @_;
  my $result;
  my $func = "Util::isOdd";
  my $abort = "";
  my $rval = 1;

  if($debug){
    push @fstack, join '~',$func,$num;
  }

  if($num < 0){
    $abort = "\"$num\" is a negative number.";
  }
  elsif($num == 0){
    $rval = 0;
  }
  else{
    $result = $num % 2;
    if($result == 0){
      $rval = 0;
    }
    else{
      $rval = 1;
    }
  }

 FINAL:
  if($abort ne ""){
    print "\nERROR[$func] : $abort\n";
    &dumpFstack();
    die;
  }
  if($debug){
    pop @fstack;
  }
  return $rval;

}

#------------------------------------------------------------------------#
# Synopsys : check to see if the file exists                             #
# Args     : $file = name of the file                                    #
# Ret      :                                                             #
#------------------------------------------------------------------------#
sub existFile {
  my ($file) = @_;
  my $func = "Util::existFile";
  my $abort = "";

  if($debug){
    push @fstack, join '~',$func,$file;
  }

  if(!(-e $file) || (-d $file)){
    $abort = "file \"$file\" doens't exist.";
  }

 FINAL:
  if($abort ne ""){
    print "\nERROR[$func] : $abort\n";
    &dumpFstack();
    die;
  }
  if($debug){
    pop @fstack;
  }
  return 1;
}

#------------------------------------------------------------------------#
# Synopsys : prints the title section                                    #
# Args     : $title = title to print                                     #
#            $justify = how to align the title                           #
# Ret      :                                                             #
#------------------------------------------------------------------------#
sub printTitle {
  my ($title,$justify,$gap,$width,$cmt_style) = @_;
  my (@alist,$len,$bg_char,$mid_char,$end_char,$blank,$lblank,$rblank);

  $cmt_style = "hash" if !defined $cmt_style;
  $width = 70 if !defined $width;  # width of a row
  $gap = 1 if !defined $gap;       # gap for printBloatString()

  if($cmt_style =~ /hash/i){  # '#' style
    $bg_char = $mid_char = $end_char = '#';
  }
  else{                       # '/* */' style
    $bg_char = '/*';
    $mid_char = '*';
    $end_char = '*/';
  }

  @alist = split //,$title;
  $len = @alist;
  $len = ($gap+1) * $len;
    
  ## title is too long.  can't fit!
  if($len > ($width-2)){
    confess "ERROR :\"$title\" is too long.\n";
  }

  $blank = $width - $len;
  if(&isOdd($blank)){
    $lblank = int($blank/2);
    $rblank = int($blank/2) + 1;
  }
  else{
    $lblank = $blank/2;
    $rblank = $blank/2;
  }
  ## print the title
  print "$bg_char"; printChar('-',$width); print "$mid_char\n";
  print "$mid_char";
  if($justify =~ 'left'){
    &printChar(' ',1);
    &printBloatString($title,$gap);
    &printChar(' ',$blank - 1);
  }
  elsif($justify =~ 'right'){
    &printChar(' ',$blank - 1);
    &printBloatString($title,$gap);
    &printChar(' ',1);
  }
  elsif($justify =~ 'center'){
    &printChar(' ',$lblank);
    &printBloatString($title,$gap);
    &printChar(' ',$rblank);
  }
  print "$mid_char\n";
  print "$mid_char"; printChar('-',$width); print "$end_char\n";

  return 1;
}

#------------------------------------------------------------------------#
# Synopsys : prints a char 'n' times                                     #
# Args     : $char = the character to print                              #
#            $num = number of times to print                             #
# Ret      :                                                             #
#------------------------------------------------------------------------#
sub printChar {
  my ($char, $num) = @_;
  my $i;

  for($i=0;$i<$num;$i++){
    print "$char";
  }

  return 1;
}

#------------------------------------------------------------------------#
# Synopsys : prints a string with a number of blank chars in between char#
# Args     : $str = string to print                                      #
#            $num = number of blank char to put in                       #
# Ret      :                                                             #
#------------------------------------------------------------------------#
sub printBloatString {
  my ($str,$num) = @_;
  my (@alist,$i);

  @alist = split //,$str;
  for($i=0;$i<@alist;$i++){
    print "$alist[$i]";
    &printChar(' ',$num);
  }

  return 1;
}

#------------------------------------------------------------------------#
# Synopsys : dumps out @fstack before a subroutine dies                  #
# Args     :                                                             #
# Ret      :                                                             #
#------------------------------------------------------------------------#
sub dumpFstack {
  my $func = "dumpFstack";
  my $i;

  print "\n------ S T A C K   T R A C E   B E G I N S -------\n";
  for($i=0;$i<@fstack;$i++){
    print "[$i] $fstack[$i]\n";
  }
  print "--------- S T A C K   T R A C E   E N D S ----------\n\n";
}

#------------------------------------------------------------------------#
# Synopsys : compares two hashes                                         #
# Args     : $ref1 = reference to first hash                             #
#            $ref2 = reference to second hash                            #
# Ret      :                                                             #
#------------------------------------------------------------------------#
sub compareHash {
  my ($ref1,$ref2) = @_;
  my $func = "Util::compareHash";
  my ($k,%all);

  if($debug){
    push @fstack, join '~',$func,$ref1,$ref2;
  }

  foreach $k (keys %$ref1){
    $all{$k} = 'first';
  }
  foreach $k (keys %$ref2){
    if(defined $all{$k}){
      if($all{$k} eq 'first'){
	$all{$k} = 'both';
      }
      else{
	die "key \"$k\" defined but not as \'first\'\n";
      }
    }
    else{
      $all{$k} = 'second';
    }
  }

  while(($k,$v) = each %all){
    print "$v : $k\n";
  }

 FINAL:
  if($debug){
    pop @fstack;
  }
  return 1;
}

1;
