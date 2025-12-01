proc export_switching_help {} {
puts "
USAGE export_switching ?<output name>? ?-h? ?-dmpcurrent?
"
}

proc export_switching  {args} {
  global env

  set argv [split $args]
  set argc [llength $argv]
  set currentflag 0
  set outputfile "switching.scenario"
  for {set j 0} {$j < $argc} {incr j 1} {
        if {[regexp {\-dmpcurrent} [lindex $argv $j]]} {
                set currentflag 1
        } elseif  {[regexp {\-h} [lindex $argv $j]]} {
                export_switching_help; return
        } else {
  		set outputfile [lindex $argv $j]
  	}
  }

  if {$currentflag == 0} {
  	get design -dvd_switching -o $outputfile 
  	puts "Output file created : $outputfile"
  } else {
  	if {[file exists $outputfile]} {
  		exec rm -rf $outputfile
  	}
  	exec mkdir $outputfile
  	puts "Output dirtory created : $outputfile"
  	puts [exec perl "$env(APACHEROOT)/scripts/export_apl_current_files.pl" $outputfile [get dmp]]
  }
}
