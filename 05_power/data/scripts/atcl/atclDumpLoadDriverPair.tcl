proc atclDumpLoadDriverPair { } {
set fd1 [open "driverload.list" "w" ]
if { [ catch {set cells [ get cell * -glob ]} ] == 0 } {
foreach cell $cells {
	if { [ catch {set insts [ get instofcell $cell ]} ] ==0 } { 
	foreach inst $insts {
		if { [ catch {set pins [getcell pins $cell -type signal -direction output ]} ] ==0 } {
		foreach pin $pins {
			if { [ catch {set nets [ getnet list * -inst $inst -pin $pin ]} ] == 0} {
			foreach net $nets {
				if { [ catch {set receivers [ getinst list * -net $net ]} ] ==0 } {
				foreach receiver $receivers {
					if { $receiver ne $inst } {
						puts $fd1 "$inst $pin $receiver"
					}
				}
				} else { continue }
			}
			} else { continue }
		}
		} else { continue }
	}
	} else { continue }
}
} else { puts "no cell found in the design" }
close $fd1
}
