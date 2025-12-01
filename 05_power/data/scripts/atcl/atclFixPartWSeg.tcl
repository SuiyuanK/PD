#########################################################################
#
# Apache Design Solutions, Inc.
#
# Copyright 2008 Apache Design Solutions, Inc.
# All rights reserved.
#
# Revision history
#
# - Created by Devesh Nema
#
#########################################################################

proc atclFixPartWSeg_help {} {
puts "USAGE
atclFixPartWSeg -i <input file name> ?-o <output file name>? ?-h? ?-m?
"
}

proc atclFixPartWSeg_manpage {} {
puts "SYNOPSIS
Apache-AE TCL utility to fix a missing wire-segment when a wire doesn't overlap a via completely
USAGE
atclFixPartWSeg -i <input file name> ?-o <output file name>?
OPTIONS
	-i <input file name> : Output of Get-EM script (Required)
	?-o <output file name>? : The output of Get-EM script is modified to report the missing partial segments and written into the <output file name>. (Optional. Default : atclFixPartWSeg.out
	?-h? : Help
	?-m? : Manpage
"
}

proc atclFixPartWSeg { args } {
set argv [split $args]
set argc [llength $argv]

if {$argc == 0} {
	atclFixPartWSeg_help;return
}	                                                                                                                                                            
# set default #####################
set outfile "atclFixPartWSeg.out"
# END of set default #####################
                                                                                                                                                            
for {set j 0} {$j < $argc} {incr j 1} {
        if {[regexp {\-i} [lindex $argv $j]]} {
                set infile [lindex $argv [expr $j + 1]]
        } elseif  {[regexp {\-o} [lindex $argv $j]]} {
                set outfile [lindex $argv [expr $j + 1]]
        } elseif  {[regexp {\-h} [lindex $argv $j]]} {
                atclFixPartWSeg_help;return
        } elseif  {[regexp {\-m} [lindex $argv $j]]} {
                atclFixPartWSeg_manpage;return
        }
}

set OUT [open $outfile w]

set IN [open $infile r]
while {[gets $IN line] >=0} {
	regsub -all -- {[[:space:]]+} $line " " line
	set line [split $line]
	if {![regexp {^#} $line] && ![regexp {^s*$} $line]} {
		lappend inlist $line
	}
}
close $IN

##puts "$inlist"

set len [llength $inlist]

for {set k 0} {$k < $len} {incr k 1} {
	set line [lindex $inlist $k]	
	if {[llength $line] == 14} {
		#puts "WIRE"
		set wirearr([lindex $line 0]) [list $line]
	} elseif {[llength $line] == 22} {
	        #puts "VIA"
	        set viaarr([lindex $line 0]) $line
        } elseif {[llength $line] == 17} {
                #puts "WIRE-SEGMENT"
		set wireID [lindex [lindex $inlist [expr $k - 1]] 0]
		lappend wireseglist [lindex $wirearr($wireID) 0]
		#puts "WIREID = $wireID"
		while {[llength $line] == 17} {
			#lappend wireseglist [lindex $wirearr($wireID) 0] $line
			lappend wireseglist $line
			set k [expr $k + 1]
			set line [lindex $inlist $k]
		}
		set wirearr($wireID) $wireseglist
		unset wireseglist
		set k [expr $k - 1]
	}
}
									
#foreach {wid wirelist} [array get wirearr] {
#	puts "## $wid, $wirelist"
#}

foreach {wid wirelist} [array get wirearr] {
	# Check only those wires which have atleast one segment
	if {[llength $wirelist] > 1} {
	# The first element in each list is the wire and rest all elements are wire-segments
	set wdetail [lindex $wirelist 0]
	set wlayer [lindex $wdetail 1]
        set wnet   [lindex $wdetail 2]
        set wllx   [lindex $wdetail 3]
        set wlly   [lindex $wdetail 4]
        set wurx   [lindex $wdetail 7]
        set wury   [lindex $wdetail 8]
        set wdir   [lindex $wdetail 13]
	# Now check all vias
	foreach {vid vialist} [array get viaarr] {
		set vlayer  [lindex $vialist 1]
		set vname   [lindex $vialist 2]
		set vnet    [lindex $vialist 3]
		set vcx     [lindex $vialist 4] 
		set vcy     [lindex $vialist 5] 
		set vdir    [lindex $vialist 10]
		set viamodel [get viamodel $vname -detail_bbox]
		set layermatch 0
		foreach elem $viamodel {
			if {[lindex $elem 1] == $wlayer} {
				set layermatch 1
				set w [lindex $elem 2]
				set h [lindex $elem 3]
				set vllx [expr $vcx - [expr $w / 2]] 
				set vlly [expr $vcy - [expr $h / 2]] 
				set vurx [expr $vcx + [expr $w / 2]] 
				set vury [expr $vcy + [expr $h / 2]] 
			}
				
		}
		# wire-via overlap has to be considered only if both layer and net matches
		if {$layermatch == 1} {
			if {$wnet == $vnet} {
				# Now see if there is a geometrical overlap
				#*************************************************************************
				set allx [max $wllx $vllx]
                                set aurx [min $wurx $vurx]
                                set ally [max $wlly $vlly]
                                set aury [min $wury $vury]
                                if {($allx >= $aurx) || ($ally >= $aury)} {
                                } else {
					#puts "$wid, $vid"
					#Rect -box $wllx $wlly $wurx $wury -color white -unit 1
					#Rect -box $vllx $vlly $vurx $vury -color red -unit 1
					# Case 1. Wire direction is horizontal ########
					if {$wdir == "h"} {
						# if wire doesnt overlap via fully 
						if {[expr $aurx - $allx] <= [expr $vurx - $vllx]} {
							if {$allx == $vllx} {
								# case 1a. wire overlapping via from right
								#puts "# case 1a. wire overlapping via from right"
								set segment [lindex $wirelist [expr [llength $wirelist] - 1]]
								set tempseg $segment
								set surx [lindex $segment 4]
								set sury [lindex $segment 5]
								set tempseg [lreplace $tempseg 2 2 $surx]
								set tempseg [lreplace $tempseg 3 3 $sury]
								set tempseg [lreplace $tempseg 4 4 $vcx]
								set tempseg [lreplace $tempseg 5 5 $vcy]
								set tempseg [lreplace $tempseg 6 6 0]
								#Rect -box $surx $sury $vcx $vcy -unit 1 -color yellow
								lappend wirelist $tempseg
								set wirearr($wid) $wirelist
							} elseif {$aurx == $vurx} {
								# case 1b. wire overlapping via from left
								#puts "# case 1b. wire overlapping via from left"
								set segment [lindex $wirelist 1]
								set tempseg $segment
								set sllx [lindex $segment 2]
                                                                set slly [lindex $segment 3]
                                                                set tempseg [lreplace $tempseg 4 4 $sllx]
                                                                set tempseg [lreplace $tempseg 5 5 $slly]
                                                                set tempseg [lreplace $tempseg 2 2 $vcx]
                                                                set tempseg [lreplace $tempseg 3 3 $vcy]
								set tempseg [lreplace $tempseg 6 6 0]
                                                                #Rect -box $sllx $slly $vcx $vcy -unit 1 -color yellow
                                                                #lappend wirelist $tempseg
								set wirelist [linsert $wirelist 1 $tempseg]
                                                                set wirearr($wid) $wirelist
							}
						}
					}
					# End Case 1. Wire direction is horizontal ####
					# Case 2. Wire direction is vertical ########
					if {$wdir == "v"} {
						# if wire doesnt overlap via fully 
						if {[expr $aury - $ally] <= [expr $vury - $vlly]} {
							if {$ally == $vlly} {
								# case 2a. wire overlapping via from bottom
								#puts "# case 2a. wire overlapping via from bottom"
								set segment [lindex $wirelist [expr [llength $wirelist] - 1]]
								set tempseg $segment
								set surx [lindex $segment 4]
								set sury [lindex $segment 5]
								set tempseg [lreplace $tempseg 2 2 $surx]
								set tempseg [lreplace $tempseg 3 3 $sury]
								set tempseg [lreplace $tempseg 4 4 $vcx]
								set tempseg [lreplace $tempseg 5 5 $vcy]
								set tempseg [lreplace $tempseg 6 6 0]
								#Rect -box $surx $sury $vcx $vcy -unit 1 -color yellow
								lappend wirelist $tempseg
								set wirearr($wid) $wirelist
							} elseif {$aury == $vury} {
								# case 2b. wire overlapping via from top
								#puts "# case 2b. wire overlapping via from top"
								set segment [lindex $wirelist 1]
								set tempseg $segment
								set sllx [lindex $segment 2]
                                                                set slly [lindex $segment 3]
                                                                set tempseg [lreplace $tempseg 4 4 $sllx]
                                                                set tempseg [lreplace $tempseg 5 5 $slly]
                                                                set tempseg [lreplace $tempseg 2 2 $vcx]
                                                                set tempseg [lreplace $tempseg 3 3 $vcy]
								set tempseg [lreplace $tempseg 6 6 0]
                                                                #Rect -box $sllx $slly $vcx $vcy -unit 1 -color yellow
                                                                #lappend wirelist $tempseg
								set wirelist [linsert $wirelist 1 $tempseg]
                                                                set wirearr($wid) $wirelist
							}
						}
					}
					# End Case 2. Wire direction is vertical ####

				}
				#*************************************************************************
			}
		}
	}
	}
}


foreach {wid wirelist} [array get wirearr] {
	foreach elem $wirelist {
		puts $OUT "$elem"
	}
}

foreach {vid vialist} [array get viaarr] {
	puts $OUT "$vialist"
}

close $OUT
puts "**********************************"
puts "Output file created : $outfile"
puts "**********************************"
}; # end of proc atclFixPartWSeg


#proc get_viamodel {viamodel} {
#set via1list [list {METAL metal1 0.21 0.21} {VIA v1 0.19 0.19} {METAL metal2 0.2 0.2}]
#set via2list [list {METAL metal2 0.2 0.14} {VIA v2 0.14 0.14} {METAL metal3 0.14 0.2}]
#if {$viamodel == "via1"} {
#	return $via1list
#} else {
#	return $via2list
#}
#}; # End of proc get_viamodel

#proc get_viamodel {viamodel} {
#	set vialist(via1) [list {METAL metal1 0.21 0.21} {VIA v1 0.19 0.19} {METAL metal2 0.2 0.2}]
#	set vialist(via2) [list {METAL metal2 0.2 0.14} {VIA v2 0.14 0.14} {METAL metal3 0.14 0.2}]
#	return $vialist($viamodel)
#}

proc min {a b} {
if {$a <= $b} {
        return $a
} else {
        return $b
}
}                                                                                                                                                             
proc max {a b} {
if {$a >= $b} {
        return $a
} else {         return $b
}
}
 
proc Rect { args } {
set argv [split $args]
set argc [llength $argv]
set color green
set width 3
set unit 2000
for {set j 0} {$j < $argc} {incr j 1} {
        if {[regexp {\-box} [lindex $argv $j]]} {
                set llx [lindex $argv [expr $j + 1]]
                set lly [lindex $argv [expr $j + 2]]
                set urx [lindex $argv [expr $j + 3]]
                set ury [lindex $argv [expr $j + 4]]
        } elseif  {[regexp {\-color} [lindex $argv $j]]} {
                set color [lindex $argv [expr $j + 1]]
        } elseif  {[regexp {\-width} [lindex $argv $j]]} {
                set width [lindex $argv [expr $j + 1]]
        } elseif  {[regexp {\-unit} [lindex $argv $j]]} {
                set unit [lindex $argv [expr $j + 1]]
        }
}
                                                                                                                                                            
set llx [expr $llx / $unit]
set lly [expr $lly / $unit]
set urx [expr $urx / $unit]
set ury [expr $ury / $unit]
                                                                                                                                                            
plot line -position $llx $lly $urx $lly -color $color -width $width
plot line -position $urx $lly $urx $ury -color $color -width $width
plot line -position $urx $ury $llx $ury -color $color -width $width
plot line -position $llx $ury $llx $lly -color $color -width $width
}; ### end of proc Rect

