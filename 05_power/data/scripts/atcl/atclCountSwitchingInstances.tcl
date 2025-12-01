proc atclTemplate_manpage {} {
	puts "
SYNOPSIS
        Apache-AE TCL utility for getting switching instance count corresponding to each cell
	The output will be dumped to inst_switching.rpt

USAGE : atclCountSwitchingInstances
        
"
}
proc atclCountSwitchingInstances { args } {
set argv [split $args]
	if {[llength $argv] == 0 } { set argv "-run" }
	set state flag
	set runf ""
	set run 1
	foreach arg $argv {
		switch -- $state {
			flag {
				switch -glob -- $arg {
					-h* { atclTemplate_manpage ; return }
					-m* { atclTemplate_manpage ; return }
					-run { set state runf }
				}
			
			
			}
			runf {
			set run 1
			}			
}
}
if {$run ==1} {					
set data [ print sw ]
foreach inst $data {
  set master [get master $inst]
  if {![info exists count($master)]}  {
    set count($master) 0
  }
  incr count($master)
}
set fd1 [open "inst_switching.rpt" "w"]
foreach master [array names count] {
  puts $fd1 "$master $count($master)"
}
close $fd1
}
}
