#########################################################################
#
# Apache Design Solutions, Inc.
#
# Copyright 2009 Apache Design Solutions, Inc.
# All rights reserved.
#
# File Name : Predict.tcl
#
# Creation Date : Jul 31, 2009
#
# Created By : Devesh Nema (devesh@apache-da.com) 
#
# Revision history
#
# 	Last Modified : Fri 21 Aug 2009 04:12:56 PM PDT
#
#########################################################################
proc Select_File {button1 label1} {
set types {
       	{"GSR Files" {.gsr}}
        {"All Files" *}
}
set file [tk_getOpenFile -filetypes $types -parent .]
$label1 configure -text $file
return $file
}; # end of Select_File


proc ceil {args} {
	set nint [expr [lindex [split $args "."] 0] + 1]
	return $nint
} ; # end of ceil


proc dim {color factor} {
  foreach i {r g b} n [winfo rgb . $color] d [winfo rgb . white] {
     set $i [expr int(255.*$n/$d*$factor)]
  }
  format #%02x%02x%02x $r $g $b
}  ; # end of dim


proc 3drect {w args} {
   if [string is int -strict [lindex $args 1]] {
      set coords [lrange $args 0 3]
   } else {
      set coords [lindex $args 0]
   }
   foreach {x0 y0 x1 y1} $coords break
   set d [expr {($x1-$x0)/3}]
   set x2 [expr {$x0+$d+1}]
   set x3 [expr {$x1+$d}]
   set y2 [expr {$y0-$d+1}]
   set y3 [expr {$y1-$d-1}]
   set id [eval [list $w create rect] $args]
   set fill [$w itemcget $id -fill]
   set tag [$w gettags $id]
   $w create poly $x0 $y0 $x2 $y2 $x3 $y2 $x1 $y0 \
       -fill [dim $fill 0.8] -outline black
   $w create poly $x1 $y1 $x3 $y3 $x3 $y2 $x1 $y0 \
       -fill [dim $fill 0.6] -outline black -tag $tag
}; # end of 3drect 


proc yscale {w x0 y0 y1 min max} {
  set dy   [expr {$y1-$y0}]
  regexp {([1-9]+)} $max -> prefix
  set stepy [expr {1.*$dy/$prefix}]
  set step [expr {$max/$prefix}]
  set y $y0
  set label $max
  while {$label>=$min} {
     $w create text $x0 $y -text $label -anchor w
     set y [expr {$y+$stepy}]
     set label [expr {$label-$step}]
  }
  expr {$dy/double($max)}
}; # end of yscale


proc roughly {n {sgn +}} {
  regexp {(.+)e([+-])0*(.+)} [format %e $n] -> mant sign exp
  set exp [expr $sign$exp]
  if {abs($mant)<1.5} {
     set mant [expr $mant*10]
     incr exp -1
  }
  set t [expr round($mant $sgn 0.49)*pow(10,$exp)]
  expr {$exp>=0? int($t): $t}
} ; # end of roughly


proc max list {
   set res [lindex $list 0]
   foreach e [lrange $list 1 end] {
      if {$e>$res} {set res $e}
   }
   set res
}; # end of max


proc min list {
   set res [lindex $list 0]
   foreach e [lrange $list 1 end] {
      if {$e<$res} {set res $e}
   }
   set res
}; # end of min


proc swap {_a _b} {
   upvar 1 $_a a $_b b
   foreach {a b} [list $b $a] break
}; # end of swap


proc bars {w x0 y0 x1 y1 data} {
   set vals 0
   foreach bar $data {
      lappend vals [lindex $bar 1]
   }
   set top [roughly [max $vals]]
   set bot [roughly [min $vals] -]
   set f [yscale $w $x0 $y0 $y1 $bot $top]
   set x [expr $x0+30]
   set dx [expr ($x1-$x0-$x)*3/[llength $data]]
   set y3 [expr $y1-20]
   set y4 [expr $y1+10]
   #$w create poly $x0 $y4 [expr $x0 + $dx + 30] $y3 [expr $x0 + $dx] $y3 [expr $x1-20] $y4 -fill gray65
   $w create poly $x0 $y4 [expr $x0+30] $y3 [expr $x1 + 280] $y3 [expr $x1 + 260] $y4 -fill gray65
   set dxw [expr $dx*6/10]
   foreach bar $data {
	   set color [lindex $bar 2]
      foreach {txt val col} $bar break
      set y [expr {round($y1-($val*$f))}]
      set y1a $y1
      if {$y>$y1a} {swap y y1a}
      set tag [expr {$val<0? "d": ""}]
      3drect $w $x $y [expr $x+$dxw] $y1a -fill $col -tag $tag
      $w create text [expr {$x+30}] [expr {$y-25}] -text "$val\GB"  -justify center -anchor w
      $w create text [expr {$x+25}] [expr {$y1a+6}] -text $txt
      incr x $dx
   }
   $w lower d
}; # end of bars

proc rotmatrix {size angle} {
    set size [expr {double($size)}]
    set angle [expr {double($angle)*acos(0.0)/90.0}]; # In radians
    set c [expr {$size*cos($angle)}]
    set s [expr {$size*sin($angle)}]
    set s [format "\[%.f %.f %.f %.f\]" $c [expr {-$s}] $s $c]
    regsub -all -- "-" $s ~ s
    return $s
 }; # end of rotmatrix




proc Predict {widget} {
.c create rect 0 0 500 300 -fill white
global mylist
global log
global gsr_file
global dynamic_file
global statistic_file
global readmode
global dyn_sim_time
global dyn_time_step 
global presim_time
global psf1
global psf2
global less_presim_time
global node_count
global res_count
global cell_count
global decap_count
global coupledflag
set psf2 1
if {$readmode == ""} {
	$log insert end "\nPLEASE SELECT MODE1 OR MODE2\n" RED
	$log see end
	return
}
if {$readmode == "files"} {
	if {![file exists $dynamic_file]} {
		$log insert end "\n.debug.dynamic FILE $dynamic_file NOT FOUND\n" RED
		$log insert end "\nPLEASE SELECT .debug.dynamic FILE\n" RED
		$log see end
		return
	}
	if {![file exists $statistic_file]} {
		$log insert end "\n.statistic FILE $statistic_file NOT FOUND\n" RED
		$log insert end "\nPLEASE SELECT .statistic FILE\n" RED
		$log see end
		return
	}
	$log insert end "\nREADING .debug.dynamic FILE \n$dynamic_file\n"
	$log see end
	set DYN [open $dynamic_file r]
	set coupledflag 0
	while { [gets $DYN line] >=0 } {
		set line [string trim $line]
        	regsub -all -- {[[:space:]]+} $line " " line
		set line [split $line]
		set stind [lsearch -exact $line "\-st"]
		set starttime [lindex $line [expr $stind + 1]]
		set endtime [lindex $line [expr $stind + 2]]
		set dyn_sim_time [expr $endtime - $starttime]
		set timestepind [lsearch -exact $line "\-d"]
		set dyn_time_step [lindex $line [expr $timestepind + 1]]
		set coupledind [lsearch -exact $line "\-coupled"]
		if {$coupledind != "-1"} {
			set coupledflag 1
		}
		set presind [lsearch -exact $line "\-bp"]
		set presim_time [lindex $line [expr $presind + 1]]
		if {$presim_time == -1} {
		} else {
			set psfind [lsearch -exact $line "\-psf"]
			set psf1 [lindex $line [expr $psfind + 1]]
			set psf2 1
			set less_presim_time [expr $presim_time - ($presim_time * [lindex $line [expr $psfind + 2]])]
		}
		while { [gets $DYN line] >=0 } {
			if {[regexp {nodes in the circuit} $line]} {
				set node_count [expr [lindex $line 3] / double(1000000)]
			}
			if {[regexp {resistors in the circuit} $line]} {
				set res_count [expr [lindex $line 3] / double(1000000)]
			}
			if {[regexp {^Presim is determined} $line]} {
				set presim_time [lindex $line 5]
				set psf1 [lindex [split [lindex $line 8] "\)"] 0]
				set psf2 1
				set less_presim_time [lindex [split [lindex $line 7] "\("] 1]
			}
		}
	}
	close $DYN
	$log insert end "\nREADING .statistic FILE \n$statistic_file\n"
	$log see end
	
	set STAT [open $statistic_file r]
	while { [gets $STAT line] >=0 } {
		set line [string trim $line]
        	regsub -all -- {[[:space:]]+} $line " " line
		set line [split $line]
		if {[regexp {^Leaf Inst} $line]} {
			set cell_count [expr [lindex $line 3] / double(1000000)]
		}
		if {[regexp {^Decap Inst} $line]} {
			set decap_count [expr [lindex $line 3] / double(1000000)]
		}
	}
	close $STAT
	$log insert end "\n###########################\n" 
	$log insert end "INFO READ FROM .debug.dynamic and .statistic" 
	$log insert end "\n###########################\n"
	$log see end


##***##	if {![file exists $gsr_file]} {
##***##		$log insert end "\nGSR FILE $gsr_file NOT FOUND\n"
##***##		$log insert end "\nPLEASE SELECT GSR FILE\n"
##***##		return
##***##	}
##***##	$log insert end "\nREADING GSR FILE \n$gsr_file\n"
##***##	set GSR [open $gsr_file r]
##***##	while { [gets $GSR line] >=0 } {
##***##		set line [string trim $line]
##***##		regsub -all -- {[[:space:]]+} $line " " line
##***##                set line [split $line]
##***##		if {[regexp -nocase {DYNAMIC_SIMULATION_TIME} $line]} {
##***##			set dyn_sim_time [lindex $line 1]
##***##			if {[regexp {n} $dyn_sim_time]} {
##***##				string trimright $dyn_sim_time ns
##***##				set dyn_sim_time [expr $dyn_sim_time * 1e-9]
##***##			}
##***##			if {[regexp {p} $dyn_sim_time]} {
##***##				string trimright $dyn_sim_time ps
##***##				set dyn_sim_time [expr $dyn_sim_time * 1e-12]
##***##			}
##***##			set dyn_sim_time [expr $dyn_sim_time * 1e12]
##***##		}
##***##		if {[regexp -nocase {DYNAMIC_TIME_STEP} $line]} {
##***##			set dyn_time_step [lindex $line 1]
##***##			if {[regexp {n} $dyn_time_step]} {
##***##				string trimright $dyn_time_step ns
##***##				set dyn_time_step [expr $dyn_time_step * 1e-9]
##***##			}
##***##			if {[regexp {p} $dyn_time_step]} {
##***##				string trimright $dyn_time_step ps
##***##				set dyn_time_step [expr $dyn_time_step * 1e-12]
##***##			}
##***##			set dyn_time_step [expr $dyn_time_step * 1e12]
##***##		}
##***##	}
##***##	close $GSR
} elseif {$readmode == "entries"} {
if {$dyn_sim_time == ""} {
	$log insert end "\nPLEASE ENTER DYNAMIC_SIMULATION_TIME\n" RED
	$log see end
	return
} else {
	if {[regexp -nocase {[a-df-z]} $dyn_sim_time]} {
		$log insert end "\nPLEASE ENTER DYNAMIC_SIMULATION_TIME IN ps ONLY\n" RED
		$log see end
		return
	}
}

if {$dyn_time_step == ""} {
	$log insert end "\nPLEASE ENTER DYNAMIC_TIME_STEP\n" RED
	$log see end
	return
} else {
	if {[regexp -nocase {[a-df-z]} $dyn_time_step]} {
		$log insert end "\nPLEASE ENTER DYNAMIC_TIME_STEP IN ps ONLY\n" RED
		$log see end
		return
	}
}

if {$presim_time == ""} {
	$log insert end "\nPLEASE ENTER PRESIM_TIME\n" RED
	$log see end
	return
} else {
	if {[regexp -nocase {[a-df-z]} $presim_time]} {
		$log insert end "\nPLEASE ENTER PRESIM TIME IN ps ONLY\n" RED
		$log see end
		return
	}
}

if {$psf1 == ""} {
	$log insert end "\nPRE-SIMULATION SPEEDUP NOT PROVIDED\n" RED
	$log insert end "\nASSUMING PRE-SIMULATION SPEEDUP = 1\n" RED
	$log see end
	set psf1 1
} else {
	if {[regexp -nocase {[a-df-z]} $psf1]} {
		$log insert end "\nPLEASE ENTER PRE-SIMULATION SPEEDUP AS A NUMBER ONLY\n" RED
		$log see end
		return
	}
}

if {$less_presim_time == ""} {
	$log insert end "\nPRESIM TIME WITH psf=1 NOT PROVIDED\n" RED
	$log insert end "\nASSUMING PRESIM TIME WITH psf=1 = 0\n" RED
	$log see end
	set less_presim_time 0
} else {
	if {[regexp -nocase {[a-df-z]} $less_presim_time]} {
		$log insert end "\nPLEASE ENTER PRESIM TIME WITH psf=1 IN ps ONLY\n" RED
		$log see end
		return
	}
}


if {$cell_count == ""} {
	$log insert end "\nPLEASE ENTER NUMBER OF CELLS\n" RED
	$log see end
	return
} else {
	if {[regexp -nocase {[a-df-z]} $cell_count]} {
		$log insert end "\nPLEASE ENTER NUMBER OF CELLS IN MILLIONS ONLY\n" RED
		$log see end
		return
	}
}

if {$decap_count == ""} {
	$log insert end "\nPLEASE ENTER NUMBER OF DECAPS\n" RED
	$log see end
	return
} else {
	if {[regexp -nocase {[a-df-z]} $decap_count]} {
		$log insert end "\nPLEASE ENTER NUMBER OF DECAPS IN MILLIONS ONLY\n" RED
		$log see end
		return
	}
}

if {$node_count == ""} {
	$log insert end "\nPLEASE ENTER NUMBER OF NODES\n" RED
	$log see end
	return
} else {
	if {[regexp -nocase {[a-df-z]} $node_count]} {
		$log insert end "\nPLEASE ENTER NUMBER OF NODES IN MILLIONS ONLY\n" RED
		$log see end
		return
	}
}

if {$res_count == ""} {
	$log insert end "\nPLEASE ENTER NUMBER OF RESISTORS\n" RED
	$log see end
	return
} else {
	if {[regexp -nocase {[a-df-z]} $res_count]} {
		$log insert end "\nPLEASE ENTER NUMBER OF RESISTORS IN MILLIONS ONLY\n" RED
		$log see end
		return
	}
}




$log insert end "\n###########################\n"
$log insert end "INFO READ FROM USER INPUTS" 
$log insert end "\n###########################\n"
$log see end

#$log insert end "\nDYNAMIC_SIMULATION_TIME = $dyn_sim_time ps"
#$log insert end "\nDYNAMIC_TIME_STEP = $dyn_time_step ps"
#$log insert end "\nPRESIM TIME = $presim_time ps"
#$log insert end "\nPSF = $psf1"
#$log insert end "\nPRESIM TIME (with PSF=1) = $less_presim_time" 	
#$log insert end "\nNODE COUNT = $node_count million"
#$log insert end "\nRESISTOR COUNT = $res_count million"
}

$log insert end "\nDYNAMIC_SIMULATION_TIME = $dyn_sim_time ps"
$log insert end "\nDYNAMIC_TIME_STEP = $dyn_time_step ps"
$log insert end "\nPRESIM TIME = $presim_time ps"
$log insert end "\nPSF = $psf1"
$log insert end "\nPRESIM TIME (with PSF=1) = $less_presim_time" 	
$log insert end "\nNODE COUNT = $node_count million"
$log insert end "\nRESISTOR COUNT = $res_count million\n"
$log see end

set time_points [expr ($dyn_sim_time/double($dyn_time_step)) + ($presim_time - $less_presim_time)/double($psf1 * $dyn_time_step) + ($less_presim_time/double($psf2 * $dyn_time_step))]
#set time_points [ceil $time_points]
set time_points [expr int($time_points)]
$log insert end "\n###########################\n" BLUE
$log insert end "TOTAL TIME POINTS = $time_points" BLUE
$log insert end "\n###########################\n" BLUE
$log see end

set total_cell_count [expr $cell_count + $decap_count]
$log insert end "\nCELL COUNT = $cell_count million"
$log insert end "\nDECAP COUNT = $decap_count million\n"
$log insert end "\n----------------------------------\n"
$log see end

set total_mem [expr 13.994 + (0.3617 * $node_count) + (0.037 * $res_count) - (0.230 * $cell_count)]
set rh_peak_mem [expr $total_mem * 0.52]
set asim_mem_dvd  $rh_peak_mem; # assume
set asim_mem_sta  [expr 0.25 * $rh_peak_mem] ; # assume
set mm_size     [expr (1.36 * $total_mem) - $rh_peak_mem]
set total_peak_mem_dyn [expr (0.4*$rh_peak_mem) + $asim_mem_dvd]
set total_peak_mem_sta [expr (0.4*$rh_peak_mem) + $asim_mem_sta]

if {[expr $res_count / double($node_count)] <= 1.25} {
} elseif {([expr $res_count / double($node_count)] > 1.25) && ([expr $res_count / double($node_count)] <= 1.4)} {
	set asim_mem_dvd [expr $asim_mem_dvd * 150/85.0]
	set asim_mem_sta [expr $asim_mem_sta * 150/85.0]
	set total_peak_mem_dyn [expr (0.4*$rh_peak_mem) + $asim_mem_dvd]
	set total_peak_mem_sta [expr (0.4*$rh_peak_mem) + $asim_mem_sta]
} elseif {([expr $res_count / double($node_count)] > 1.4) && ([expr $res_count / double($node_count)] <= 1.5)} {
	set asim_mem_dvd [expr $asim_mem_dvd * 270/85.0]
	set asim_mem_sta [expr $asim_mem_sta * 270/85.0]
	set total_peak_mem_dyn [expr (0.4*$rh_peak_mem) + $asim_mem_dvd]
	set total_peak_mem_sta [expr (0.4*$rh_peak_mem) + $asim_mem_sta]
} elseif {([expr $res_count / double($node_count)] > 1.5) && ([expr $res_count / double($node_count)] <= 1.6)} {
	set asim_mem_dvd [expr $asim_mem_dvd * 450/85.0]
	set asim_mem_sta [expr $asim_mem_sta * 450/85.0]
	set total_peak_mem_dyn [expr (0.4*$rh_peak_mem) + $asim_mem_dvd]
	set total_peak_mem_sta [expr (0.4*$rh_peak_mem) + $asim_mem_sta]
}



if {$coupledflag == 1} {
	set asim_mem_dvd [expr $asim_mem_dvd * 2]
	set asim_mem_sta [expr $asim_mem_sta * 2]
	set total_peak_mem_dyn [expr (0.4*$rh_peak_mem) + $asim_mem_dvd]
	set total_peak_mem_sta [expr (0.4*$rh_peak_mem) + $asim_mem_sta]
}

#set mylist [list [list "STA PEAK MEM" [ceil $total_peak_mem_sta] red] [list "STA .MM" [ceil $mm_size] green] [list "DYN PEAK MEM" [ceil $total_peak_mem_dyn] blue] [list "DYN .MM" [ceil $mm_size] yellow]]
set mylist [list [list "ASIM MEM" [expr int($asim_mem_dvd)] yellow] [list "STA PEAK MEM" [expr int($total_peak_mem_sta)] red] [list "  DYN PEAK MEM" [expr int($total_peak_mem_dyn)] blue] [list ".MM SIZE" [expr int($mm_size)] green] ]

bars .c 30 30 220 250 $mylist
} ;# end of Predict

#**************************************************************************************************

set gsr_file ".apache/apache.gsr"
set statistic_file ".apache/.statistic"
set dynamic_file ".apache/.debug.dynamic"
#button .b1 -text "Change GSR File" -command "set gsr_file \[Select_File .b1 .l10\]" -fg black -bg yellow
#label .l10 -text ".apache/apache.gsr"
button .b2 -text "Change .statistic File" -command "set statistic_file \[Select_File .b2 .l11\]" -fg black -bg yellow
label .l11 -text ".apache/.statistic"
button .b3 -text "Change .debug.dynamic File" -command "set dynamic_file \[Select_File .b3 .l12\]" -fg black -bg yellow
label .l12 -text ".apache/.debug.dynamic"
button .b4 -text "Quit" -command "destroy ." -fg black -bg red -height 3
button .b5 -text "Predict" -command "Predict .b5" -fg black -bg green -height 3
label .l1 -text "Enter DYNAMIC_SIMULATION_TIME(ps)"
entry .e1 -width 20 -relief sunken -bd 2 -textvariable dyn_sim_time
focus .e1
label .l2 -text "Enter DYNAMIC_TIME_STEP(ps)"
entry .e2 -width 20 -relief sunken -bd 2 -textvariable dyn_time_step
label .l3 -text "Enter Presim Time(ps)"
entry .e3 -width 20 -relief sunken -bd 2 -textvariable presim_time
label .l4 -text "Enter Pre-simulation Speedup"
entry .e4 -width 20 -relief sunken -bd 2 -textvariable psf1
label .l5 -text "Enter Presim Time with psf=1 (ps)"
entry .e5 -width 20 -relief sunken -bd 2 -textvariable less_presim_time
label .l6 -text "Enter number of instances excluding filler and decap cells(Millions)"
entry .e6 -width 20 -relief sunken -bd 2 -textvariable cell_count 
label .l7 -text "Enter number of filler and decap cells(Millions)"
entry .e7 -width 20 -relief sunken -bd 2 -textvariable decap_count 
label .l8 -text "Enter number of nodes(Millions)"
entry .e8 -width 20 -relief sunken -bd 2 -textvariable node_count 
label .l9 -text "Enter number of resistors(Millions)"
entry .e9 -width 20 -relief sunken -bd 2 -textvariable res_count 

canvas .c -width 500 -height 300

radiobutton .cb1 -text "MODE 1: Read input from files" -variable readmode -value files  -anchor w
radiobutton .cb2 -text "MODE 2: Read input from entered values"  -variable readmode -value entries -anchor w


label .l14 -text "Coupled Solver?"
radiobutton .cb3 -text "Yes" -variable coupledflag -value 1  -anchor w
radiobutton .cb4 -text "No"  -variable coupledflag -value 0 -anchor w 


frame .t
set log [text .t.log -width 40 -height 30 -borderwidth 2 -relief sunken -setgrid true -yscrollcommand {.t.scroll set}]
scrollbar .t.scroll -command {.t.log yview}
pack .t.scroll -side right -fill y
pack .t.log -side left -fill both -expand true
pack .t -side top -fill both -expand true
.t.log tag configure RED -foreground red
.t.log tag configure BLUE -foreground blue
#set im [image create photo untiled -file "/home/devesh/apache.GIF"]
#label .l13  -image $im -bg white


grid .cb1 -row 0 -column 0 -sticky w
grid .cb2 -row 4 -column 0 -sticky w
#grid .b1 -row 1 -column 0 -sticky w
#grid .l10 -row 1 -column 1 -sticky w
grid .b2 -row 2 -column 0 -sticky w
grid .l11 -row 2 -column 1 -sticky w
grid .b3 -row 3 -column 0 -sticky w
grid .l12 -row 3 -column 1 -sticky w
grid .b4 -row 16 -column 1
grid .b5 -row 16 -column 0
grid .l1 -row 5 -column 0 -sticky w
grid .e1 -row 5 -column 1 -sticky w
grid .l2 -row 6 -column 0 -sticky w
grid .e2 -row 6 -column 1 -sticky w
grid .l3 -row 7 -column 0 -sticky w
grid .e3 -row 7 -column 1 -sticky w
grid .l4 -row 8 -column 0 -sticky w
grid .e4 -row 8 -column 1 -sticky w
grid .l5 -row 9 -column 0 -sticky w
grid .e5 -row 9 -column 1 -sticky w
grid .l6 -row 10 -column 0 -sticky w
grid .e6 -row 10 -column 1 -sticky w
grid .l7 -row 11 -column 0 -sticky w
grid .e7 -row 11 -column 1 -sticky w
grid .l8 -row 12 -column 0 -sticky w
grid .e8 -row 12 -column 1 -sticky w
grid .l9 -row 13 -column 0 -sticky w
grid .e9 -row 13 -column 1 -sticky w
grid .c -row 15 -column 0 -sticky w
grid .t -row 15 -column 1 -sticky w
grid .l14 -row 14 -column 0 -sticky w
grid .cb3 -row 14 -column 1 -sticky w
grid .cb4 -row 14 -column 1 -sticky e


#**************************************************************************************************

