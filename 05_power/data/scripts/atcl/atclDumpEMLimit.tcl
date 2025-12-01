# $Revision: 2.3 $
#########################################################################
#
# atclDumpEMLimit.tcl is an Apache-AE TCL utility for dumping out wire/via EM limitations into output file.
#
# Usage:
# atclDumpEMLimit -layer <layer_name> -x <x_point> -y <y_point> [-o <dest_file>] [-h] [-m]
#
# Copyright (C) 2001-2012 Apache Design Solutions, Inc.
# All rights reserved.
#
# Revision history
#
# Rev 1.0
# - Created by Kenneth on August 15, 2011
# - Initial release
#########################################################################

proc atclDumpEMLimit_manpage {} {
  puts "
SYNOPSIS
  Apache-AE TCL utility for dumping out wire/via EM limitations into output file
USAGE
  atclDumpEMLimit \[option_arguments\]

  Options:
  \[-layer <layer_name>\] Layer name
  \[-x <x_point>\]        X coordinate
  \[-y <y_point>\]        Y coordinate
  \[-o <dest_file>\]      Destination/Output file (optional) (default=atclDumpEMLimit.output)
  \[-h\]                  Command usage
  \[-m\]                  Man page

  Example:
  atclDumpEMLimit -layer M2 -x 0 -y -0.05
  atclDumpEMLimit -layer VIA1 -x 3 -y 4.5 -o em_limit.rpt
"
}

proc atclDumpEMLimit_help {} {
  puts "Usage: atclDumpEMLimit \[-layer <layer_name>\] \[-x <x_point>\] \[-y <y_point>\] \[-o <dest_file>\] \[-h\] \[-m\]"
}

proc atclDumpEMLimit {args} {
  set argv [split $args]
  set argc [llength $argv]
  if {$argc < 6} { atclDumpEMLimit_help; return }
  for {set j 0} {$j < $argc} {} {
    if {[regexp {\-layer} [lindex $argv $j]]} {
      set layer_name [lindex $argv [expr $j + 1]]
      incr j 2
    } elseif {[regexp {\-x} [lindex $argv $j]]} {
      set xpt [lindex $argv [expr $j + 1]]
      incr j 2
    } elseif {[regexp {\-y} [lindex $argv $j]]} {
      set ypt [lindex $argv [expr $j + 1]]
      incr j 2
    } elseif {[regexp {\-o} [lindex $argv $j]]} {
      set dest [lindex $argv [expr $j + 1]]
      incr j 2
    } elseif {[regexp {\-h} [lindex $argv $j]]} {
      atclDumpEMLimit_help; return
    } elseif {[regexp {\-m} [lindex $argv $j]]} {
      atclDumpEMLimit_manpage; return
    } else {
      atclDumpEMLimit_help; return
    }
  }
  
  if {![info exists layer_name]} { atclDumpEMLimit_help; return }
  if {![info exists xpt]} { atclDumpEMLimit_help; return }
  if {![info exists ypt]} { atclDumpEMLimit_help; return }
  if {![info exists dest]} {
    set dest atclDumpEMLimit.output
  }
  
  set out_file [open $dest w]
  set wire_em_info [get em -type wire -order first -layer $layer_name]
  while {$wire_em_info != {}} {
    regsub -all -- {[[:space:]]+} $wire_em_info " " em_line
    set em_line [split $em_line]
    set width [lindex $em_line 11]
    atclGetWireSegmentAll $out_file $xpt $ypt $width
    set wire_em_info [get em -type wire -order next]
  }
  atclGetViaAll $out_file $layer_name $xpt $ypt
  close $out_file
}

proc atclGetWireSegmentAll {out_file xpt ypt width} {
  set wire_segment_em_info [get em -type wire_segment -order first]
  while {$wire_segment_em_info != {}} {
    set invalid 0
    regsub -all -- {[[:space:]]+} $wire_segment_em_info " " em_line
    set em_line [split $em_line]
    set llx [lindex $em_line 2]
    set lly [lindex $em_line 3]
    set urx [lindex $em_line 4]
    set ury [lindex $em_line 5]
    if {$llx == $urx} {
      set llx [expr $llx - ($width / 2)]
      set urx [expr $urx + ($width / 2)]
    } else {
      set lly [expr $lly - ($width / 2)]
      set ury [expr $ury + ($width / 2)]
    }
    if {($xpt < $llx) || ($xpt > $urx) || ($ypt < $lly) || ($ypt > $ury)} {
      set invalid 1
    }
    if {$invalid == 0} {
#      puts -nonewline $out_file $wire_segment_em_info
      puts "<layer> <x (um)> <y (um)> <em_limitation (A)>"
      puts "[lindex $em_line 0] $xpt $ypt [lindex $em_line 8]"
      puts $out_file "<layer> <x (um)> <y (um)> <em_limitation (A)>"
      puts $out_file "[lindex $em_line 0] $xpt $ypt [lindex $em_line 8]"
    }
    set wire_segment_em_info [get em -type wire_segment -order next]
  }
}

proc atclGetViaAll {out_file layer_name xpt ypt} {
  set via_em_info [get em -type via -order first -layer $layer_name]
  while {$via_em_info != {}} {
    set invalid 0
    regsub -all -- {[[:space:]]+} $via_em_info " " em_line
    set em_line [split $em_line]
    set center_x [lindex $em_line 4]
    set center_y [lindex $em_line 5]
    set cut_width [lindex $em_line 7]
    set cut_height [lindex $em_line 8]
    set llx [expr $center_x - ($cut_width / 2)]
    set lly [expr $center_y - ($cut_height / 2)]
    set urx [expr $center_x + ($cut_width / 2)]
    set ury [expr $center_y + ($cut_height / 2)]
    if {($xpt < $llx) || ($xpt > $urx) || ($ypt < $lly) || ($ypt > $ury)} {
      set invalid 1
    }
    if {$invalid == 0} {
#      puts -nonewline $out_file $via_em_info
      puts "<layer> <x (um)> <y (um)> <em_limitation (A)>"
      puts "[lindex $em_line 1] $xpt $ypt [lindex $em_line 12]"
      puts $out_file "<layer> <x (um)> <y (um)> <em_limitation (A)>"
      puts $out_file "[lindex $em_line 1] $xpt $ypt [lindex $em_line 12]"
    }
    set via_em_info [get em -type via -order next]
  }
}
