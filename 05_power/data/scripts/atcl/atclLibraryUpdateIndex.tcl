# $Revision: 1.145 $

#For Product team to create tclIndex file
#Usage: atclLibraryUpdateIndex atcl/

proc atclLibraryUpdateIndex { libdir } {

	set index [ file join $libdir tclIndex]
	if {![file exists $index]} {
		set doit 1
	} else {
		set age [file mtime $index]
		set doit 0
		# Changes to directory may mean files were deleted
		if {[file mtime $libdir] > $age} {
			set doit 1
		} else {
			# Check each file for modification
			foreach file [glob [file join $libdir *.tcl]] {
				if {[file mtime $file] > $age} {
					set doit 1
					break
				}
			}
		}
	}
	if { $doit } {
		auto_mkindex $libdir *.tcl
	}
}
