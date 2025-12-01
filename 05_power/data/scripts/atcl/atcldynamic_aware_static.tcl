proc atcldynamic_aware_static { } {

set gsc_vs_ipf [gsr get GSC_OVERRIDE_IPF]
if { [ catch {gsr get GSC_FILE } ] } {
set original_gsc ".apache/.apache2.gsc"
} else {
set tmp [gsr get GSC_FILE]
regsub -all "GSC_FILE \{" $tmp "" temp2
regsub -all "\n" $temp2 "" temp3
regsub -all "\}" $temp3 "" temp4
regsub -all "#" $temp4 "" temp5
regsub -all " " $temp5 "" original_gsc
if {$original_gsc == ""} {
set original_gsc ".apache/.apache2.gsc"
} 
}

set timestep [gsr get DYNAMIC_TIME_STEP]
set simtime [gsr get DYNAMIC_SIMULATION_TIME ]
set newtimestep [lindex $simtime 1]
set presim [gsr get DYNAMIC_PRESIM_TIME ]
gsr set DYNAMIC_TIME_STEP $newtimestep
gsr set DYNAMIC_PRESIM_TIME 0
perform analysis -vectorless
gsr get DYNAMIC_SIMULATION_TIME
set fd2 [open ".apache/.apache1.gsc" "w"]
puts $fd2 "* DISABLE"
set data [ print sw ]
foreach line $data {
puts $fd2 "$line TOGGLE"
}
close $fd2
gsr set GSC_OVERRIDE_IPF 1
import gsc .apache/.apache1.gsc
perform pwrcalc
perform analysis -static
gsr set DYNAMIC_TIME_STEP $timestep 
gsr set DYNAMIC_PRESIM_TIME $presim
set fd3 [open ".apache/.apache2.gsc" "w"]
close $fd3
gsr set GSC_OVERRIDE_IPF $gsc_vs_ipf
import gsc $original_gsc
}
