set lib_files [glob *.lib]

foreach lib_file $lib_files {
  set fid  	  	[open $lib_file r]
  regsub -all "\.lib" $lib_file "" lib_name
  set ofile_name   	${lib_file}.mod
  set ofid   		[open $ofile_name w]
  while {[gets $fid line] >= 0} {
    if {![regsub -all {library\(USERLIB_.*} $line "library\($lib_name\) \{" new_line]} {
      set new_line $line
    }
    puts $ofid $new_line
  }
  
  close $ofid
  close $fid
}

