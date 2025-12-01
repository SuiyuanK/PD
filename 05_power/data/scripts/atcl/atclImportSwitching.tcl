proc import_switching_help {} {
puts "
USAGE import_switching <Switching scenario file name/path> ?-h? ?-dmpcurrent?
"
}

proc import_switching {args} {
  set argv [split $args]
  set argc [llength $argv]
  if {$argc == 0} {
	puts "File name is required"
	return
  }
  set  inputfile [lindex $argv 0]

  set currentflag 0
  for {set j 0} {$j < $argc} {incr j 1} {
        if {[regexp {\-dmpcurrent} [lindex $argv $j]]} {
                set currentflag 1
        } elseif  {[regexp {\-h} [lindex $argv $j]]} {
                import_switching_help; return
        }
  }
  if {[file exists $inputfile] == 0} {
  	put "$inputfile doesn't exist"
  	return
  }

  if {$currentflag == 0} {
  	file copy -force $inputfile .apache/apache.dvd
  } else {
#  	gsr set APL_FILES [list \
        [list $inputfile/cell.current current] \
        [list $inputfile/vmemory.current current_avm] \
  	[list $inputfile/cell.cdev cdev] \
  	[list $inputfile/vmemory.cdev cap_avm] \
        ]

#  	perform pwrcalc

  	file delete {*}[glob -nocomplain .apache.*/apache.dvd*] .apache/tmp_fill
        file delete {*}[glob -nocomplain adsPower*/apache.hier.*.gz] .apache/tmp_fill
	file delete {*}[glob -nocomplain .apache.*/apache.apl_idx*] .apache/tmp_fill

        set dmp_no [get dmp]
  	for {set i 1} {$i <= $dmp_no} {incr i 1} {
       		file copy -force -- $inputfile/apache.dvd .apache.$i/
		file copy -force -- $inputfile/apache.hier.gz adsPower.$i/apache.hier.$i.gz
		for {set j 1} {$j <= $dmp_no} {incr j 1} {
			file link -symbolic .apache.$i/apache.apl_idx.$j $inputfile/apache.apl_idx
		}
	}
        puts "Finish Importing Current profile.\n"
  }
}
