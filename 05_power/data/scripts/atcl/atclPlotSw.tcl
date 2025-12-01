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

#!/usr/local/bin/tclsh
# $Revision: 1.145 $

proc atclPlotSw { args } {
set argv [split $args]
set argc [llength $argv]
set num [lindex $argv 1]

if {$argc == 4} {
	set OUT [open [lindex $argv 3] w 0666]
}
#puts "$OUT"
#puts "[lindex $argv 3]"

#set num 7 
set logfile [open logfile.txt w 0666]
set logfile2 [open logfile2.txt w 0666]
set DSW [open .apache/apache.dsw r 0666]; ## Change the path to .apache
        while { [gets $DSW line] >=0 } {
        	regsub -all -- {[[:space:]]+} $line " " line
                set line [split $line]
		set elm_0    [lindex $line 0]; ## instance id
		set elm_1    [lindex $line 1]; ## 
		set elm_2    [lindex $line 2]; ##
		set elm_3    [lindex $line 3]; ## start time
		set elm_4    [lindex $line 4]; ## end time
		set elm_5    [lindex $line 5]; ##
		set elm_6    [lindex $line 6]; ##
		set elm_7    [lindex $line 7]; ##
		set elm_8    [lindex $line 8]; ##
		
		set tw [expr $elm_3 + $elm_4]
		set tw [expr $tw/2]
		lappend mylist "$elm_0 $elm_1 $elm_2 $tw $elm_5 $elm_6 $elm_7 $elm_8" 
	}; ## End of while { [gets $DSW line] >=0 }
	set sortedlist [lsort -integer -index 3 $mylist]
	puts $logfile "$sortedlist"
	close $logfile
	set logfile [open logfile.txt r 0666]
	foreach newline [split [read $logfile] "{}"] {	
		if {[lindex $newline 3] == -9 } {
			continue	
		}
		puts $logfile2 "$newline"
		#	for {set i 1} {$i <= $num} {incr i 1} {}
	} ;## End of foreacih newline [split [read $logfile] "{}"] 
	close $logfile2
	if {$argc == 4} {
		puts $OUT "#### Instance ##################### Min voltage ################"
	} else {
		puts  "#### Instance ##################### Min voltage ################"
	}
		
	
	set logfile2 [open logfile2.txt r 0666]
	set i 1
	foreach data [split [read $logfile2] "\n"] {
		if {[regexp {\d} [lindex $data 3]] && $i <= $num} {
			set i [expr $i + 1]
			#puts "[lindex $data 0]" 
			set IMAP [open .apache/apache.imap r 0666]
			while { [gets $IMAP imapline] >= 0 } {
				regsub -all -- {[[:space:]]+} $imapline " " imapline
                                set imapline [split $imapline]
				if {[lindex $imapline 0] == [lindex $data 0]} {
					set inst_name [lindex $imapline 1]
					#puts "$inst_name"
				}
			}
			close $IMAP
			plot voltage -name $inst_name -ext -nograph -o $inst_name
			set file $inst_name.header.ext
			set WAV [open $file r 0666];
			gets $WAV wavline
			if { [regexp {#.*} $wavline] } {
			        gets $WAV wavline
			}
			regsub -all -- {[[:space:]]+} $wavline " " wavline
			set wavline [split $wavline]
			set mintime [lindex $wavline 1]
			close $WAV
			                                                                                                                                                            
			set WAV [open $file r 0666];
			gets $WAV wavline
			while { [gets $WAV wavline] >=0 } {
			        regsub -all -- {[[:space:]]+} $wavline " " wavline
			        set wavline [split $wavline]
			        set time [lindex $wavline 1]
			        if {$time <= $mintime} {
			                set mintime $time
			        }
			}
			if {$argc == 4} {
			puts $OUT "\n$inst_name   :   $mintime\n"
			} else {
			puts  "\n$inst_name   :   $mintime\n"
			}
	
		}
	}
	
	
if {$argc == 4} {
	puts $OUT "#############################################################"
} else {
        puts  "#############################################################"
}

close $logfile
if {$argc == 4} {
close $OUT
}
file delete [glob -dir ./ logfile.txt]
file delete [glob -dir ./ logfile2.txt]
foreach file [glob -nocomplain -directory ./ *.ext] {
	file delete $file
}
foreach file [glob -nocomplain -directory ./ *.int] {
	file delete $file
}

#le delete [glob -dir ./ *.ext]
#ile delete [glob -dir ./ *.int]
}
#findmin $inst_name







#foreach file [glob -nocomplain -directory . *.int]	{}
#set file $inst_name.header.int
#set WAV [open $file r 0666]; 
#gets $WAV wavline 
#regsub -all -- {[[:space:]]+} $wavline " " wavline
#set wavline [split $wavline]
#set mintime [lindex $wavline 1]
#close $WAV
#
#set WAV [open $file r 0666];
#gets $WAV wavline
#while { [gets $WAV wavline] >=0 } {
#	regsub -all -- {[[:space:]]+} $wavline " " wavline
#	set wavline [split $wavline]
##	set time [lindex $wavline 1]
#	if {$time <= $mintime} {		
#		set mintime $time
#	}
#}
#puts "\n$inst_name (int)  :   $mintime\n"
