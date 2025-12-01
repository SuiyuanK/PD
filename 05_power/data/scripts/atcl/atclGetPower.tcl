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


proc atclGetPower_help {} {
puts "
USAGE
atclGetPower [-cellList <filename> | -instList <filename] ?-o <output file name>? ?-h? ?-m?
"
}
                                                                                                                                                            
proc atclGetPower_manpage {} {
puts "
AE-TCL utility to get power information for design hierarchy
                                                                                                                                                            
USAGE
atclGetPower [-cellList <filename> | -instList <filename] ?-o <output file name>? ?-h? ?-m?
                                                                                                                                                            
Options:
 [-cellList <filename> | -instList <filename]: cellList of instList file (Required)
 ?-o <output file name>? : Output file name (Optional. Default output on RedHawk GUI)
 ?-h? : Help
 ?-m? : Manpage
"
}



proc atclGetPower { args } {
set argv [split $args]
set argc [llength $argv]
set cellflag 0
set instflag 0
set outflag 0
for {set j 0} {$j < $argc} {incr j 1} {
	if {[regexp {\-cellList} [lindex $argv $j]]} {
        	set cellfile [lindex $argv [expr $j + 1]]
		set cellflag 1
        } elseif  {[regexp {\-instList} [lindex $argv $j]]} {
        	set instfile [lindex $argv [expr $j + 1]]
		set instflag 1
        } elseif  {[regexp {\-o} [lindex $argv $j]]} {
        	set outfile [lindex $argv [expr $j + 1]]
		set outflag 1
        } elseif  {[regexp {\-h} [lindex $argv $j]]} {
                atclGetPower_help;return
        } elseif  {[regexp {\-m} [lindex $argv $j]]} {
                atclGetPower_manpage;return
        }
}

if {$outflag == 1} {
set OUT [open $outfile w 0666]
}

if {$cellflag == 1} {
	set CELL [open $cellfile r 0666]
	while { [gets $CELL cellline] >=0 } {
		 if {[regexp {^#} $cellline]} {
        	        gets $CELL cellline
	         }
       		 regsub -all -- {[[:space:]]+} $cellline " " cellline
                 set cellline [split $cellline]
                 set cellname [lindex $cellline 0]
                 set instances [get instofcell $cellname]
		 if {[llength $instances] == 0} {
			if {$outflag == 1} {
				puts $OUT "\n\n<INFO> : Cell $cellname doesn't have any instance"
			} else {
				puts "\n\n<INFO> : Cell $cellname doesn't have any instance"
			}
		 }
		 if {[llength $instances] > 1} {
			foreach tempinst $instances {
				lappend instlist $tempinst
			}
		 } else {
		 lappend instlist $instances
		 }
	#	 puts "$instlist"
	}
} elseif {$instflag == 1} {
        set INST [open $instfile r 0666]
        while { [gets $INST instline] >=0 } {
                 if {[regexp {^#} $instline]} {
                        gets $INST instline
                 }
                 regsub -all -- {[[:space:]]+} $instline " " instline
                 set instline [split $instline]
                 set instname [lindex $instline 0]
                 lappend instlist $instname
         #        puts "$instlist"
	}
}

#foreach tempinst $instlist {
#	puts "tempinst = $tempinst"
#}


foreach inst $instlist {
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
        close $TEMP
        file delete -force tempdump
	
	if {$outflag == 1} {
		if {$inst != ""} {
			if {$cellflag == 1} {
				set inst_cellname [get master $inst]
				puts $OUT "\n##################################################################"
				puts $OUT "### Cell = $inst_cellname"
				puts $OUT "### Instance = $inst "
				puts $OUT "##################################################################"
			} else {
				puts $OUT "\n##################################################################"
				puts $OUT "### Instance = $inst "
				puts $OUT "##################################################################"
			}
			dump mmx_pin_info -box  $llx $lly $urx $ury -o ATCLGETPOWER.OUT
			set ATCL [open ATCLGETPOWER.OUT r 0666]
			while {[gets $ATCL atclline] >= 0} {
				if {[regexp {^#<InstName:PinName>} $atclline]} {
					break
				} else {
					puts $OUT $atclline
				}
			}
			close $ATCL
			file delete -force ATCLGETPOWER.OUT
		}
	} else { 
		if {$inst != ""} {
			if {$cellflag == 1} {
				set inst_cellname [get master $inst]
				puts  "\n##################################################################"
				puts  "### Cell = $inst_cellname"
				puts  "### Instance = $inst "
				puts  "##################################################################"
			} else {
				puts  "\n##################################################################"
				puts  "### Instance = $inst "
				puts  "##################################################################"
			}
			dump mmx_pin_info -box  $llx $lly $urx $ury 
		}
	}
}

if {$outflag == 1} {
	close $OUT
}



}; ## end of proc atclGetPower
