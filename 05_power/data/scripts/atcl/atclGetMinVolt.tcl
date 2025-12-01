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

proc atclGetMinVolt_help {} {
puts "
USAGE
	atclGetMinVolt -met <Metal layer name> -vddvalue <vdd voltage> ?-bbox <llx lly urx ury> ?-o <output file name> ?-h ?-m
"
}

proc atclGetMinVolt_manpage {} {
puts "
SYNOPSIS
	Apache-DA AE TCL script to report minimum voltage on a Metal layer and the time of occurrence
USAGE
	atclGetMinVolt -met <Metal layer name> -vddvalue <vdd voltage> ?-bbox <llx lly urx ury> ?-o <output file name> ?-h ?-m
OPTIONS
	-met <Metal layer name> (Required)
	-vddvalue <vdd voltage> (Required)
	-o <output file name> (Optional, Default print in RedHawk Log Display Area)
	-bbox <llx lly urx ury> (Optional, find minimum voltage in bounding box region only, give lower left and upper right cordinates)
	-h : Help (Optional)
	-m : Manpage (Optional)
"
}


proc atclGetMinVolt { args } {
set starttime [clock seconds]
set argv [split $args]
set argc [llength $argv]
                                                                                                                                                            
#### Set the default parameters ###############################################################
set outflag 0 
#### Finish Set the default parameters ########################################################
                                                                                                                                                            
#### Parse the arguments ######################################################################
if {$argc == 0} {
        puts "Please refer to the usage"
        atclGetMinVolt_help; return
}
                                                                                                                                                            
                                                                                                                                                            
if {$argc == 1} {
        if {[regexp {\-h} [lindex $argv 0]]} {
                atclGetMinVolt_help;return
        } elseif  {[regexp {\-m} [lindex $argv 0]]} {
                atclGetMinVolt_manpage;return
        }
}
                                                                                                                                                            
                                                                                                                                                            
for {set k 0} {$k < $argc} {incr k 1} {
        if {[regexp {\-met} [lindex $argv $k]]} {
                set flagrule 1
        }
}
                                                                                                                                                            
                                                                                                                                                            
if {$flagrule == 0} {
        puts "Please specify a metal name"
        return
}

set corflag 0


for {set j 0} {$j < $argc} {incr j 1} {
                if {[regexp {\-met} [lindex $argv $j]]} {
                        set metal [lindex $argv [expr $j + 1]]
                } elseif  {[regexp {\-h} [lindex $argv $j]]} {
                        atclGetMinVolt_help;return
                } elseif  {[regexp {\-m} [lindex $argv $j]]} {
                        atclGetMinVolt_manpage;return
                } elseif  {[regexp {\-o} [lindex $argv $j]]} {
                        set outfile [lindex $argv [expr $j + 1]]
			set outflag 1
                } elseif  {[regexp {\-vddvalue} [lindex $argv $j]]} {
                        set vddvalue [lindex $argv [expr $j + 1]]
                } elseif {[regexp {\-bbox} [lindex $argv $j]]} {
                        set llx [lindex $argv [expr $j + 1]]
                        set lly [lindex $argv [expr $j + 2]]
                        set urx [lindex $argv [expr $j + 3]]
                        set ury [lindex $argv [expr $j + 4]]
			set corflag 1
                }
}

### Finish parsing arguments #######################################################################
set maxnodes 1024 
set count 0
set subcount 0
set lastbin 0
set notthere 0
set returnflag 0
#set plotcount 0 ;############################################3
set NLOC [open .apache/apache.nloc r 0666]
      while { [gets $NLOC line] >=0 } {
                if {[regexp $metal $line]} {
                        regsub -all -- {[[:space:]]+} $line " " line
                        set line [split $line]
                        set node_id      [lindex $line 0]
                        set xloc         [lindex $line 1]
                        set yloc         [lindex $line 2]
                        set metal_name   [lindex $line 3]
			if {$corflag == 1} {
				if {$xloc >= $llx && $xloc <= $urx && $yloc >= $lly && $yloc <= $ury} { 
					lappend nodelist $node_id 
					set count [expr $count + 1]
				}
			} else { 
				lappend nodelist $node_id 
				set count [expr $count + 1]
			}
		} ; ## end of if
	}; ### end of while

set timevoltlist [list]
for  {set j 0} {$j < $count} {incr j} {
	if {$subcount < $maxnodes } {
		lappend smalllist [lindex $nodelist $j]
		set subcount [expr $subcount + 1]
	} else {
		lappend smalllist [lindex $nodelist $j]
		plot voltage -node $smalllist -nograph
#		set plotcount [expr $plotcount + 1];###############################################
#		puts "Plotcount = $plotcount" ;####################################################
                set timevoltlist [concat $timevoltlist [findmin $vddvalue]]
		unset smalllist
		set subcount 0
	}
}
	set remainder [expr $count % [expr $maxnodes + 1]]
	if {$remainder != 0} {
		 plot voltage -node $smalllist -nograph
#		set plotcount [expr $plotcount + 1] ;#############################################
#		puts "Plotcount = $plotcount" ;####################################################
                 set timevoltlist [concat $timevoltlist [findmin $vddvalue]]
	}





set vddtimevoltlist [lsort  -real -increasing -index 1 $timevoltlist]
set vsstimevoltlist [lsort  -real -decreasing -index 3 $timevoltlist]


set outputlist  [open "atclGetMinVolt_$metal.log" w 0666]
puts $outputlist "\n#METAL :\t  $metal"
if {$corflag == 1 && $count == 0} {
	puts $outputlist "\n<ERROR> No $metal found in bounding box $llx $lly $urx $ury"
} else {
	puts $outputlist "\n#Nodes :\t  $count"
	if {[lindex [lindex $vddtimevoltlist 0] 1] == 1000} {
		puts $outputlist "\n<ERROR> No VDD net found in $metal"
	} else {
#			puts $outputlist "\n VDD"
		puts $outputlist "\n#VDD minimum voltage (V)  :\t  [lindex [lindex $vddtimevoltlist 0] 1]"
		puts $outputlist "\n#Time at minimum voltage (ps) :\t  [lindex [lindex $vddtimevoltlist 0] 0]"
	}
	if {[lindex [lindex $vsstimevoltlist 0] 3] == -1000} {
		puts $outputlist "\n<ERROR> No VSS net found in $metal"
	} else {
#			puts $outputlist "\n VSS"
		puts $outputlist "\n#VSS maximum voltage (V)  :\t  [lindex [lindex $vsstimevoltlist 0] 3]"
		puts $outputlist "\n#Time at maximum voltage (ps) :\t  [lindex [lindex $vsstimevoltlist 0] 2]"
	}
}
close $outputlist

if {$outflag == 1} {
	set OUTFILE [open $outfile w 0666]
}
set out  [open "atclGetMinVolt_$metal.log" r 0666]
while { [gets $out outputline] >=0 } {
        regsub -all -- {[[:space:]]+} $outputline " " outputline
	if {[regexp {:} $outputline]} {
	         set outputline [split  $outputline ":"]
		if {$outflag == 1} {
	        	puts -nonewline $OUTFILE "[lindex $outputline 0] \t"
		} else {
			puts -nonewline  "[lindex $outputline 0] \t"
		}
	}
}
close $out

if {$outflag == 1} {
	puts $OUTFILE "\n"
} else {
	puts "\n"
}

set out  [open "atclGetMinVolt_$metal.log" r 0666]
while { [gets $out outputline] >=0 } {
        regsub -all -- {[[:space:]]+} $outputline " " outputline
	if {[regexp {:} $outputline]} {
	         set outputline [split  $outputline ":"]
		if {$outflag == 1} {
		        puts -nonewline $OUTFILE "[lindex $outputline 1] \t"
		} else {
			puts -nonewline  "[lindex $outputline 1] \t"
		}
	}
}
close $out

if {$outflag == 1} {
        puts $OUTFILE "\n"
} else {
        puts "\n"
}
if {$outflag == 1} {
close $OUTFILE
}


close $NLOC
set endtime [clock seconds]
puts "Check ./atclGetMinVolt_$metal.log for any errors"
puts "Total run time [expr $endtime - $starttime] seconds"
}; ### End of proc atclGetMinVolt






proc findmin {vddvalue } {
set dirs [glob .apache/wave/*]
set len [llength $dirs]
for  {set i 0} {$i < $len} {incr i} {
	set f [lindex $dirs $i]
	 set WAV [open $f r 0666];
         gets $WAV wavline
         while { [regexp {#.*} $wavline] } {
	         gets $WAV wavline
         }
         regsub -all -- {[[:space:]]+} $wavline " " wavline
         set wavline [split $wavline]
         set mintime [lindex $wavline 0]
         set minvolt [lindex $wavline 1] 
	 if {$minvolt >= [expr $vddvalue * 0.5]} {
		while { [gets $WAV wavline] >=0 } {
                    regsub -all -- {[[:space:]]+} $wavline " " wavline
                    set wavline [split $wavline]
                    set time [lindex $wavline 0]
                    set volt [lindex $wavline 1]
                    if {$volt < $minvolt} {
                              set minvolt $volt
                              set mintime $time
                    }
         	}
		set templist [list $mintime $minvolt -1000 -1000]
	} else {
		while { [gets $WAV wavline] >=0 } {
                    regsub -all -- {[[:space:]]+} $wavline " " wavline
                    set wavline [split $wavline]
                    set time [lindex $wavline 0]
                    set volt [lindex $wavline 1]
                    if {$volt > $minvolt} {
                              set minvolt $volt
                              set mintime $time
                    }
                }
		set templist [list 1000 1000 $mintime $minvolt]
	}
        close $WAV
lappend timevoltlist $templist
};## end of for

foreach file [glob .apache/wave/*] {
	file delete -force $file
}
return $timevoltlist

};##end of proc findmin[]
