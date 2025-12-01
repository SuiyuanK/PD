# $Revision: 1.145 $

#########################################################################
#
# atclListCellType.tcl is an Apache-AE TCL utility for listing cells belong to a certain type stated in power_summary.rpt
#
# Usage: type the following in Redhawk command window
#	source /home/phong/scripts/atclListCellType.tcl
#	atclListCellType
# Or:
#       see 3 different procedures usage below
#
# Copyright © 2007 Apache Design Solutions, Inc.
# All  rights reserved.
#
# Revision history
#
# Rev 1.0
# - Created by Phong T. Nguyen on Jan 9 2008
# - Initial version
#
#########################################################################
proc atclListCellType {} {
	puts "##### Man page for atclGetCellByType, atclGetTypeByCell, and atclGetTypeByInst #####
SYNOPSIS
	Apache-AE TCL utility to print a list of cells recognized by redhawk as a type stated in power_summary.rpt 
USAGE
	atclGetCellByType <clocked_inst|memory|combinational|latch|flipflop|mux|clockgate|IO> \[output_file\]

	Options:
	\[output_file\]		Destination/Output file (optional) (default display on screen)

Example:
	atclGetCellByType clocked_inst clocked_inst_cell_list.out
	atclGetCellByType memory

SYNOPSIS
        Apache-AE TCL utility to print the type of a cell recognized by redhawk  given the cell name.
USAGE
        atclGetTypeByCell <cell_name> \[output_file\]
Example:
	atclGetTypeByCell rf128x32p2

SYNOPSIS
        Apache-AE TCL utility to print the cell name, the type of a cell recognized by redhawk given the instance name. 
USAGE
        atclGetTypeByCell <instance_name> \[output_file\]
Example:
        atclGetTypeByInst ram_inst1
"
}
proc atclGetCellByType {args} {
  set design_n [ query top -name  ]
  if {[llength $args] < 1} {
    puts "Usage: atclgetCellByType <clocked_inst|memory|combinational|latch|flipflop|mux|clockgate|IO> \[output_file\]"
  } else {
    exec perl .atclListCellType_[pid].pl getCellByType adsPower/$design_n.nets.adsLib.power $args
  }
}
proc atclGetTypeByCell {args} {
  set design_n [ query top -name  ]
  if {[llength $args] < 1} {
    puts "Usage: atclGetTypeByCell <cell_name> \[output_file\]"
  } else {
    exec perl .atclListCellType_[pid].pl getTypeByCell .apache/adsLib.output $args
  }
}
proc atclGetTypeByInst {args} {
  set design_n [ query top -name  ]
  if {[llength $args] < 1} {
    puts "Usage: atclGetTypeByInst <instance_name> \[output_file\]"
  } else {
    exec perl .atclListCellType_[pid].pl getTypeByInst adsPower/$design_n.nets.adsLib.power $args
  }
}

set tempFileName ".atclListCellType_[pid].pl"

# Open the output file, and
# write the program to it

set outfl [open $tempFileName w]

puts $outfl {
# Temporary perl code
# Copyright © 2007 Apache Design Solutions, Inc.
# All  rights reserved.
#
# Revision history
#
# Rev 1.0
# - Created by Phong T. on Jan 09 2008
# - Initial version
####################################################
# constant definition
@type=('combinational cell','latch','flip flop','cell with clock input pin','memory');
@subtype=('core cell','input pad','output pad','input pad','clockgate','mux');
# Help and usage
if ($#ARGV < 2) {
  print "Usage: $0 <getCellByType|getTypeByCell|getTypeByInst> <cellType|cellName|InstName> <inputFile> [outputFile]\n";
  print "      Where cellType is one of clocked_inst|memory|combinational|latch|flipflop|mux|clockgate|IO\n";
  print "Ex: $0 getCellByType clocked_inst adsPower/GENERIC.nets.adsLib.power listOfCellofTypeClock_inst.txt\n";
  print "Ex: $0 getTypeByCell rf128x32p2 .apache/adsLib.output\n";
  print "Ex: $0 getTypeByInst ram_inst1 adsPower/GENERIC.nets.adsLib.power\n";
  exit 1;
}
# redirect output to file or stdout
if (defined $ARGV[3]) {
  open $OUT,'>',$ARGV[3]  || die "ERROR: can not write to file $ARGV[3]\n";
}else {
  $OUT=STDOUT;
}
# filter and check arguments then call subroutine
for ($ARGV[0]) {
  if (/getCellByType/) {
    for ($ARGV[2]) {
      if (/clocked_inst/) {getCellByType(3,$ARGV[1])}
      elsif (/memory/) {getCellByType(4,$ARGV[1])}
      elsif (/combinational/) {getCellByType(0,$ARGV[1])}
      elsif (/latch/) {getCellByType(1,$ARGV[1])}
      elsif (/flipflop/) {getCellByType(2,$ARGV[1])}
      elsif (/mux/) {getCellBySubType(5,$ARGV[1])}
      elsif (/clockgate/) {getCellBySubType(4,$ARGV[1])}
      elsif (/IO/) {
        print $OUT "###INFO: List of input padcell\n";
        getCellBySubType(1,$ARGV[1]);
        print $OUT "###INFO: List of output padcell\n";
        getCellBySubType(2,$ARGV[1]);
        print $OUT "###INFO: List of inout padcell\n";
        getCellBySubType(3,$ARGV[1]);
      }
      else {die "ERROR: argument is not one of <clocked_inst|memory|combinational|latch|flipflop|mux|clockgate|IO>\n"}
    }
  }
  elsif (/getTypeByCell/) {getTypeByCell($ARGV[2],$ARGV[1])}
  elsif (/getTypeByInst/) {getTypeByInst($ARGV[2],$ARGV[1])}
  else { die "ERROR: argument is not one of <getCellByType|getTypeByCell|getTypeByInst>\n" }
}
# Begining subroutines
sub getTypeByInst {
  my ($InstName, $powerFile) = @_;
  open my $INFILE,'<',$powerFile  || die "ERROR: can not read file $powerFile\n";
  while (<$INFILE>) {
    if (/^$InstName /) {
      my @l=split;
      my $cellName = $l[7];
      print $OUT "Instant $InstName uses cell $cellName\n";
      if ($l[29]==0) { print $OUT "$cellName is a $type[$l[20]]\n" }else {
        print  $OUT "$cellName is type $type[$l[20]]\n";
        print  $OUT "$cellName is type $subtype[$l[29]]\n";
      }
      last;
    }
  }
  close $INFILE;
  return;
}
sub getTypeByCell {
  my ($cellName, $powerFile) = @_;
  open my $INFILE,'<',$powerFile  || die "ERROR: can not read file $powerFile\n";
  while (<$INFILE>) {
    if (/^cell $cellName /) {
      my @l=split;
      if ($l[6]==0) { print $OUT "$cellName is a $type[$l[5]]\n" }else {
        print  $OUT "$cellName is type $type[$l[5]]\n";
        print  $OUT "$cellName is type $subtype[$l[6]]\n";
      }
      last;
    }
  }
  close $INFILE;
  return;
}
sub getCellByType {
  my ($cellType, $powerFile) = @_;
  open my $INFILE,'<',$powerFile  || die "ERROR: can not read file $powerFile\n";
  while (<$INFILE>) {
    #next if $. = 0;
    #next if /^\#/;
    my @l=split;
    if ((defined $l[20]) && ($l[20] eq "$cellType")) { 
      if (defined  ${$cellType}{$l[7]})  {
        ${$cellType}{$l[7]}++;
      }else {
        ${$cellType}{$l[7]} = 1;
      }
    } 
  }
  printf $OUT "%20s","\#Cell_name\n";
  foreach my $k (sort by_keys keys %{$cellType}) {
    printf $OUT "%20s","$k\n";
  } 
  close $INFILE;
  return;
}
sub getCellBySubType {
  my ($cellType, $powerFile) = @_;
  open my $INFILE,'<',$powerFile  || die "ERROR: can not read file $powerFile\n";
  while (<$INFILE>) {
    my @l=split;
    if ((defined $l[29]) && ($l[29] eq "$cellType")) {
      if (defined  ${$cellType}{$l[7]})  {
        ${$cellType}{$l[7]}++;
      }else {
        ${$cellType}{$l[7]} = 1;
      }
    }
  }
  printf $OUT "%20s","\#Cell_name\n";
  foreach my $k (sort by_keys keys %{$cellType}) {
    printf $OUT "%20s","$k\n";
  }
  close $INFILE;
  return;
}
sub by_keys { $a cmp $b }
}

# Flush and close the file
flush $outfl
close $outfl
