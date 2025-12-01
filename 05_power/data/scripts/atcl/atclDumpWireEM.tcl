# $Revision: 1.145 $
#########################################################################
#
# atcl_wire_em_info.tcl is an Apache-AE TCL utility for copying files and directories
#
# Usage:
# atclDumpWireEM  -m <metal_string> -top <top_metal_layer_number> -bot <bot_metal_layer_number> -o <dest_file> -celllist <cell list file> \[-h\] \[-m\]
#
# Copyright © 2007 Apache Design Solutions, Inc.
# All rights reserved.
#
# Revision history
#
# Rev 1.0
# - Created by Kawo on September11, 2007
# - Initial release
# Rev 1.1
# - Modified by Devesh Nema
# - Added a celllist option to exclude the EM info for wires lying on cells specified in celllist
#########################################################################

proc atclDumpWireEM_manpage {} {
	puts "
SYNOPSIS
	Apache-AE TCL utility for dumping out wire EM's information into output file
USAGE
	atclDumpWireEM \[option_arguments\]

	Options:
	\[-bot <metal_layer_number>\]	Bottom metal layer number: 0,1,2... (optional) (default=1)
	\[-top <metal_layer_number>\]	Top metal layer number: 0,1,2,... (optional) (default=top-layer from techfile)
	\[-o <dest_file>\]		Destination/Output file (optional) (default=atclDumpWireEM.output)
	\[-celllist <cell list file>\]  List of cells to exclude (optional)
	\[-h\] 				command usage
	\[-m\] 				man page

Example:
	atclDumpWireEM -bot 3 -top 4 -o wire_em.out
	atclDumpWireEM
"
}

proc atclDumpWireEM_help {} {
	puts "Usage: atclDumpWireEM \[-top <metal_layer_number>\] \[-bot <metal_layer_number>\] \[-o <output_file>\]  \[-celllist <cell list file>\] \[-h\] \[-m\]"
}

proc atclDumpWireEM { args } {
	# Process command arguments
	set argv [split $args]
		#if {[llength $argv] == 0 } { set argv "-h" }
		set state flag
		set iscell 0
		foreach arg $argv {
			switch -- $state {
				flag {
				      switch -glob -- $arg {
					 -h* { atclDumpWireEM_help ; return }
					 --he* { atclDumpWireEM_help ; return }
					 -m* { atclDumpWireEM_manpage ; return }
					 -o { set state destf }
        				 -t* { set state topl ; }
        				 -b* { set state botl ; }
					 -celllist {set state cells;}
					 default { error "actl Error: unknow flag $arg" }
				      }
			         }
				destf {
					set dest $arg
					set state flag
				}
				botl {
					set m_bot_layer_num $arg
					set state flag
				}
				cells {
					set conffile $arg
					set iscell 1
					set state flag
				}
				topl {
					set m_top_layer_num $arg
					set top_layer [atclGetTopMetalLayer]
					regexp -nocase {([a-z]*)([0-9]*)} $top_layer match m_prefix
					set state flag
				}
			}
		}
		if {![info exists m_bot_layer_num]} {
			set m_bot_layer_num 1
		}
		if {![info exists dest]} {
			set dest atclDumpWireEM.output
		}
		if {![info exists m_top_layer_num ]} {
			set top_layer [atclGetTopMetalLayer]
			regexp -nocase {([a-z]*)([0-9]*)} $top_layer match m_prefix m_top_layer_num
		}

#-------------
# Main
#-------------
#########################################################################################################
if {$iscell == 1} {
set CONF [open $conffile r 0666]
while { [gets $CONF line] >=0 } {
        if {[regexp {^#} $line]} {
                gets $CONF line
        }
        regsub -all -- {[[:space:]]+} $line " " line
        set line [split $line]
        set name     [lindex $line 0]
        set instances [get instofcell $name]
        foreach inst $instances {
                query inst -bbox $inst -o  tempdump
                set TEMP [open tempdump r 0666]
                gets $TEMP templine
                gets $TEMP templine
                regsub -all -- {[[:space:]]+} $templine " " templine
                set templine [split $templine]
                set llx  [lindex $templine 1]
                set lly  [lindex $templine 2]
                set urx  [lindex $templine 3]
                set ury  [lindex $templine 4]
                lappend wirelist [list $llx $lly $urx $ury]
                close $TEMP
                file delete -force tempdump
        }
}
#puts "$wirelist"
close $CONF
} else {
	set wirelist [list {}]
}
#########################################################################################################

	set outfile [ open $dest w ] 
	set mlayer $m_bot_layer_num
	puts $outfile "#For wires"
        puts $outfile "# <ID> <layer> <net> <ll(x y) lr(x y) ur(x y) ul(x y) (um)> <width(um)> <resistance(ohm)> <current_dir(h|v)>"
	puts $outfile "#For wire segments"
        puts $outfile "# <layer> <net> <start(x y) end(x y) ( m)> <direction(l|r|u|d)> <current(A)> <em_limit(A)> <em(%)>\n"

	while { $mlayer <= $m_top_layer_num} {
		if [ catch { get em -type wire -order first -layer $m_prefix$mlayer } fid ] {
			#puts stderr $fid
		} else {
			set em_wire_info [ get em -type wire -order first -layer $m_prefix$mlayer ]
  		}
		puts -nonewline $outfile $em_wire_info
		atclGetWireSegmentNextAll $outfile $wirelist $iscell

		while { $em_wire_info != {} } {
			set em_wire_info [ get em -type wire -order next ]
			puts -nonewline $outfile $em_wire_info
			atclGetWireSegmentNextAll $outfile $wirelist $iscell
		}
		incr mlayer
	     }
	     close $outfile
}

proc atclGetWireSegmentNextAll { ofile wirelist iscell} {
if {$iscell == 1} {
      set invalid 0
      set em_wire_segment_info [ get em -type wire_segment -order first ]
      regsub -all -- {[[:space:]]+} $em_wire_segment_info " " emline
      set emline [split $emline]
      set x1 [lindex $emline 2]
      set y1 [lindex $emline 3]
      set x2 [lindex $emline 4]
      set y2 [lindex $emline 5]
      foreach wireelem $wirelist {
		set llx [lindex $wireelem 0]
		set lly [lindex $wireelem 1]
		set urx [lindex $wireelem 2]
		set ury [lindex $wireelem 3]
		if { (($x1 >= $llx) && ($x1 <= $urx)) && (($y1 >= $lly) && ($y1 <= $ury)) || (($x2 >= $llx) && ($x2 <= $urx)) && (($y2 >= $lly) && ($y2 <= $ury)) } {
			set invalid 1
		}
      }
      if {$invalid == 1} {
      } else {
	      puts -nonewline $ofile $em_wire_segment_info
      }
      while { $em_wire_segment_info != {} } {
                      set invalid 0
                      set em_wire_segment_info [get em -type wire_segment -order next]
		      regsub -all -- {[[:space:]]+} $em_wire_segment_info " " emline
		      set emline [split $emline]
		      set x1 [lindex $emline 2]
		      set y1 [lindex $emline 3]
		      set x2 [lindex $emline 4]
		      set y2 [lindex $emline 5]
		      foreach wireelem $wirelist {
		                set llx [lindex $wireelem 0]
		                set lly [lindex $wireelem 1]
		                set urx [lindex $wireelem 2]
		                set ury [lindex $wireelem 3]
		                if { (($x1 >= $llx) && ($x1 <= $urx)) && (($y1 >= $lly) && ($y1 <= $ury)) || (($x2 >= $llx) && ($x2 <= $urx)) && (($y2 >= $lly) && ($y2 <= $ury)) } {
		      			set invalid 1
				}
		      }
		      if {$invalid == 1} {
		      } else {
			     puts -nonewline $ofile $em_wire_segment_info
		      }
      }
} else {
      set em_wire_segment_info [ get em -type wire_segment -order first ]
      puts -nonewline $ofile $em_wire_segment_info
      while { $em_wire_segment_info != {} } {
                        set em_wire_segment_info [get em -type wire_segment -order next]
                        puts -nonewline $ofile $em_wire_segment_info
      }

}

}; ### end of proc atclGetWireSegmentNextAll

proc atclGetTopMetalLayer { } {
	set tech_summary adsRpt/tech_summary.rpt
	set techfile [ open $tech_summary r ] 
	foreach line [ split [read $techfile] \n ] {
		regsub -all {\s+} $line "" element
		if  [regexp "instance" $element] {
			return $last_element
		}
		set last_element $element
	}
	close $techfile
}
