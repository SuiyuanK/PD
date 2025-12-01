proc atcl_noAPL_manpage {} {
  
 	puts "\nSYNOPSIS\n"
 	puts "Apache-AE TCL utility to list out the number of instances for cells having no APL current\n\n"
 	puts "USAGE\n"
 	puts "atcl_noAPL \[option_arguments\]\n"
	puts "\t-current_file <instance_list file> The output file containing the list of cells and their instantiation which do not have APL current profile\n"
 	puts "\t-cdev_file <instance_list file> The output file containing the list of cells and their instantiation which do not have APL cdev\n"
	puts "\t-pwcap_file <instance_list file> The output file containing the list of cells and their instantiation which do not have APL pwcap\n"
	puts "\t -type <current|cap|pwcap>,By default it finds cells with missing current ,cap and pwcap data\n";

	puts "\t-help command usage\n"
 	puts "\t-man man page\n"
 	return
} 


proc atcl_noAPL_help {} {

 	puts "Usage: atcl_noAPL -current_file <output_file for current> -cdev_file <output_file for cdev> -pwcap_file <output_file for pwcap> -type <current|cap|pwcap>\[-help \] \[-man \]\n"
 	return
} 
 

proc atcl_noAPL {args} {

 set current_flag 1
 set cap_flag 1
 set pwcap_flag 1
 
 	set argv [split $args]
	set state flag
 	foreach arg $argv {
	
	
	 switch -- $state {
                        flag {
                                switch -glob -- $arg {
				
                                        -h* { atcl_noAPL_help;  return }
                                        -m* { atcl_noAPL_manpage ; return }
                                        -type  { set state typeflag }
                                        default { error "atcl_showPratioMap Error: unknown flag $arg" }
                                                                                                                                        
                                }
                        }
                        typeflag {
			   set type $arg
                        if { $type eq "current" } { 
			set current_flag 1
			set cap_flag 0
			set pwcap_flag 0
			 }
			if { $type eq "cap" } { 
			set cap_flag 1
			set current_flag 0
			set pwcap_flag 0
			 }
			if { $type eq "pwcap" } { 
			set pwcap_flag 1
			set current_flag 0
			set cap_flag 0
			 }
			
                        set state flag
                        }
		}
		
	
	
	
	
	
  		
 	}  
	
 	array set opt [concat {-current_file "noAPL_current.rpt"  -cdev_file "noAPL_cdev.rpt"  -pwcap_file "noAPL_pwcap.rpt"  -help 0 -man 0} $args]
	if { $current_flag == 1 } {
	
 	set current_file [open $opt(-current_file) "w"]
	set current_file_name $opt(-current_file)
	set file1 [open "adsRpt/apache.refCell.noAplCurrent" r]
	
	set data [read $file1 ]
	close $file1
	set i 0
	set data1 [split $data "\n" ]
	set n1 [ llength [ split $data "\n" ] ]
	foreach line $data1 {
		incr i
		set a($i) $line
	}
	set n1 $i
	for {set i 3} {$i < $n1 } {incr i} {
		set count [llength [get instofcell $a($i)]]
		puts $current_file "$a($i) $count"
	}
	close $current_file
	puts "\n\nThe file containing the cells with no APL current and their number of instances is $current_file_name\n"
	
	}
	if {$cap_flag == 1 } {
	
	set cdev_file [open $opt(-cdev_file) "w"]
	set cdev_file_name $opt(-cdev_file)
	set file2 [open "adsRpt/apache.refCell.noAplCap" r]
	
	
	set data [read $file2 ]
	close $file2
	set i 0
	set data1 [split $data "\n" ]
	set n1 [ llength [ split $data "\n" ] ]
	foreach line $data1 {
		incr i
		set a($i) $line
	}
	set n1 $i
	for {set i 3} {$i < $n1 } {incr i} {
		set count [llength [get instofcell $a($i)]]
		puts $cdev_file "$a($i) $count"
	}
	close $cdev_file
	puts "\n\nThe file containing the cells with no APL cdev and their number of instances is $cdev_file_name\n"
	
	}
	if {$pwcap_flag == 1 } {
	
	set pwcap_file [open $opt(-pwcap_file) "w"]	
	set pwcap_file_name $opt(-pwcap_file)
	set file3 [open "adsRpt/apache.refCell.noAplPwcap" r]
	
	set data [read $file3 ]
	close $file3
	set i 0
	set data1 [split $data "\n" ]
	set n1 [ llength [ split $data "\n" ] ]
	foreach line $data1 {
		incr i
		set a($i) $line
	}
	set n1 $i
	for {set i 3} {$i < $n1 } {incr i} {
		set count [llength [get instofcell $a($i)]]
		puts $pwcap_file "$a($i) $count"
	}
	close $pwcap_file
	puts "\n\nThe file containing the cells with no APL pwcap and their number of instances is $pwcap_file_name\n"
	
	}
 	
 	
	
	
	
	
	
	
	
}
