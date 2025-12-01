proc analyzeEMIHotspot_manpage {} {
  puts "

SYNOPSIS
        analyzeEMIHotspot.tcl is an Ansys AE TCL utility for listing out the critical instances from EMI analysis within the user-specified region and within the user specified frequency range.

USAGE
        analyzeEMIHotspot \[arguments\]
        
        Arguments: 
        -region <bbox>          Specify region co-ordinates in the format : <x1>,<y1>,<x2>,<y2>. Required.
        -freqStart                       Specify lower limit frequency.Required.
        -freqEnd	                 Specify upper limit frequency.Required.
        -reuse   			 Set to 1 if you need to re-use the computed fft data instead of re-generating the fft .Default 0
        -report_limit  			 Specify the number of instances to be reported in the outputted ranking report.Default 5 
        -o                           Output file name which contains list of critical instances to be dumped. Default file : \"inst_file\". Specify any output file name other than \"txt\"
        -\[h\]                            Usage help
        -\[m\]                            Man page
        
          "
}
proc analyzeEMIHotspot {args} {
set inputflag 0
set argv [split $args]
set state flag
set outflg 0
set ruseflg 0
set rflg 0
foreach arg $argv {
		switch -- $state {
			flag {
				switch -glob -- $arg {
					-h* { analyzeEMIHotspot_manpage ; return }
					-m { analyzeEMIHotspot_manpage ; return }
					-region { set state inputflag }
					-freqStart { set state fflag }
				 	-freqEnd { set state fflag2 }   
					-reuse {set state reuseflag }
					-report_limit {set state replimit}                                		
                               		-o  { set state outputflag }
					default { error "analyzeEMIHotspot Error: unknown flag $arg" }
				}
			}


                 




inputflag {
set bbox1 [split $arg ","]
set x1 [lindex $bbox1 0]
      set y1 [lindex $bbox1 1]
      set x2 [lindex $bbox1 2]
      set y2 [lindex $bbox1 3]
      set state flag
      set inputflg 1
}
replimit {
set repolimit $arg
set rflg 1
set state flag
}

reuseflag {
set ruseflg 1
set state flag
}

outputflag {
      set out $arg
      set state flag
      set outflg 1
}

fflag {
      set usrf1 [format %g [expr double($arg)]]
      set state flag
      set fflg 1
}
fflag2 {
      set usrf2 [format %g [expr double($arg)]]
      set state flag
      set fflg1 1
}


}
}

if {$rflg == 1} {
set rlimit $repolimit
} else {
set rlimit 5
}

if {$outflg == 1} {
set out1 $out
} else {
set out1 "inst_file"
}
if {$ruseflg == 1} {
set reuse 1
} else { 
set reuse 0
}

set er [catch {set outf [open "$out1" "w"]}]
if {$er == 1} {error "Cannot open output file inst_file"}

gsr set PLOT_REGION_NO_LIMIT 1
puts $outf "#Instance-name\t#Amplitude\t#Frequency\t#Domain"


set err [ catch {set inst_list [get inst * -glob -bbox $x1 $y1 $x2 $y2]} ]

if {$err == 1} { error "no instances found in the specified region" 
return}


set cnt 0
foreach inst $inst_list {
#puts "$inst"
set box [get inst $inst -bbox]
set xx1 [lindex $box 0]
set yy1 [lindex $box 1]
set xx2 [lindex $box 2]
set yy2 [lindex $box 3]
regsub -all {\/} $inst {_} instf
if {!(($reuse == 1) && [file exists emihotspot/$instf.txt])} { 

#if {$reuse == 0} 
set errf1 [catch {exec mkdir -p emihotspot}]
if {$errf1 == 1} { error "cannot create dir for emihotspot.Please check disk permissions"}
set err1 [catch {plot current -region $xx1 $yy1 $xx2 $yy2 -fft -nograph -o emihotspot/$instf.txt}]
if  {$err1 == 1} {
puts "no data for $inst"
incr cnt

if {[llength $inst_list] == $cnt} {
error "No instances in the specified region have fft data"
return
}
continue
}
}

if {[lindex [exec wc -l emihotspot/$instf.txt] 0] == 2} {continue}
set f [open "emihotspot/$instf.txt" "r"]
#set n [ open "testab" "w+"]
while { [gets $f line] >= 0 } {
if {[regexp {^#} $line] > 0} {continue}
if {[regexp {^$} $line] > 0} {continue}
if {[regexp -nocase {\"} $line]} {
set dom [ lindex [split $line "\""] 1]
continue
}
regsub -all {\s+} $line { } line
set a [split $line " "]
set freq [lindex $a 0]
set curr [ lindex $a 1]

set ary($inst,$freq,$dom) $curr

#set farray($freq) 1
lappend list_fr $freq
#puts  $n "$curr\t$dom"
if {($freq >=  $usrf1) && ($freq <= $usrf2)} {
	lappend list_curr_val $curr
	lappend list_dom_freq "$dom $freq $inst"
}
}
#close $n
close $f
#puts "$list_dom_freq" 
#puts "$list_curr_val"
if {(($usrf1 < [lindex $list_fr 0]) || ($usrf2 > [lindex $list_fr [expr [llength $list_fr]-1]]))} {
error "invalid freq range specified"
return
}
set search_val [lindex [lsort -real -decreasing $list_curr_val] 0]
set list_dom_freq [split [lindex $list_dom_freq [lsearch $list_curr_val $search_val]] " "]
set dom [lindex $list_dom_freq 0]
set freq [lindex $list_dom_freq 1]
set inst1 [lindex $list_dom_freq 2]
set max_curr $search_val

lappend list_max_curr $max_curr
lappend list_max_dom $dom
lappend list_max_freq $freq
lappend list_max_inst $inst1
#puts "$max_curr $dom $freq $inst1"
unset list_dom_freq 
unset list_curr_val
}
puts "Dumping out the critical instances in $out1"
set lst2 [lsort -real -decreasing $list_max_curr]
#puts "$lst2"
set i 0
set prev_max_curr 0
set flag 0
while {1} {
if {($i == [llength $list_max_curr]) || ($i == $rlimit)} {break}

set list_idx [lsearch -all $list_max_curr [lindex $lst2 $i]]
#puts [llength $list_idx]
if {[llength $list_idx] >= 1} {
foreach idx $list_idx {
#set print_list [list [lindex $list_max_inst $idx] [lindex $list_max_curr $idx] [lindex $list_max_freq $idx] [lindex $list_max_dom $idx]]
puts $outf "[lindex $list_max_inst $idx]\t[lindex $list_max_curr $idx]\t[lindex $list_max_freq $idx]\t[lindex $list_max_dom $idx]"
set i [expr $i+1]
if {($i == $rlimit)} {
set flag 1
break
}
}
}
if {$flag == 1} {break}
}

#puts $outf "Current\t\tInst name\tFreqency\tDomain"
#puts $outf "$maxm\t$ins\t$fr\t$domain"
#if {[info exists ins1]} {
#puts $outf "$maxm1\t$ins1\t$fr1\t$domain1"
#}
#if {[info exists ins2]} {
#puts $outf "$maxm2\t$ins2\t$fr2\t$domain2"
#}
#if {[info exists ins3]} {
#puts $outf "$maxm3\t$ins3\t$fr3\t$domain3"
#}
#if {[info exists ins4]} {
#puts $outf "$maxm4\t$ins4\t$fr4\t$domain4"
#}
close $outf
}
