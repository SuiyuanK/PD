#############################################################
# This procedure "plotSwitchVoltageWaveforms" is intended to be used for plotting switch voltage waveforms for a RedHawk Rampup analysis run. The procedure takes as input a file specifying the switch cell masters and plots the external and internal node voltage waveforms for all the instances of those masters.
# Author : Vinayakam Subramanian  ( email : vinayakam@apache-da.com )
# Version : 1.5
#############################################################

puts "Procedure \"plotSwitchVoltageWaveforms\" loaded!";
proc plotSwitchVoltageWaveforms {args} {
    
    	array set opt [concat {-switchCellListFile "switchCellList" -o switchVoltageWaveformsForRampup -nograph 1 -sv 1 -internalNetOnly 0 -help 0} $args]
    	set switchCellListFile $opt(-switchCellListFile)
    	set opt_nograph $opt(-nograph)
   	set opt_sv $opt(-sv)
	set opt_internalNetOnly $opt(-internalNetOnly)
    	set help $opt(-help)
    	set outDir $opt(-o)
   	
	puts "Running plotSwitchVoltageWavefroms version 1.5 ...";
    	# help
     	if {$help !=0} {
        	puts "\nThis function is for plotting switch voltage waveforms from current RedHawk Rampup analysis run"
        	puts "\nFollowing options are supported:"
        	puts "-switchCellListFile <file containing list of switch cell masters,each switch cell should be on a separate line>"
        	puts "-nograph <0 or 1, default is 0> ### To show / not show the graphs"
        	puts "-sv <0 or 1, default is 1> ### To generate waveforms in ta0 format which can be viewed with sv. If disabled, waveforms will be dumped in text format."
        	puts "-o <output directory name, default is switchVoltageWaveformsForRampup>"
		puts "-internalNetOnly <0 or 1,default is 0> ### Plot waveform of internal net only.";
        	return
    	}
  
    
    	# check whether switchCellListFile exists
    	if {  [ file exists $switchCellListFile ]  == 0 } {
    		puts "Given switchCellListFile $switchCellListFile does not exist! Program End!"
return;
    	}
    
    	# remove pre-existing output directory
    	if { [file exists $outDir] && [ file isdirectory $outDir ]} {
        	puts "Deleting existing output directory $outDir..."
		file delete -force $outDir
    	}
    	file mkdir $outDir
	set logfp [ open "$outDir/plotSwitchVoltageWaveforms.log" w ]
	puts $logfp "# Log file for plotSwitchVoltageWaveformsforRampup.tcl";
	# display parameters
	puts "Input switch cell list file : $switchCellListFile";
	puts "Output waveforms directory : $outDir";
	puts "Enable ta0 format : $opt_sv";
	puts $logfp "Input switch cell list file : $switchCellListFile";
	puts $logfp "Output waveforms directory : $outDir";
	puts $logfp "Enable ta0 format : $opt_sv";
	set showGraph  [ expr {  !$opt_nograph } ];
	puts "Show graph : $showGraph";
	puts $logfp "Show graph : $showGraph";
	puts $logfp "Internal Net only : $opt_internalNetOnly";


	# get list of instances for each master and plot voltage for that switch instance
	set switchinfp [ open $switchCellListFile r ]
	set switchInstanceList [list]
	set emptystring "";
	while { [ gets $switchinfp line ] >= 0 } {
		if { [ string equal $line $emptystring ] } {
			# if line is empty , skip this line
			continue;
		}
		puts "Processing switch cell $line ....";
		puts $logfp "Processing switch cell $line ....";
		set switchInstanceList [list]
		set switchInstanceList [ get instofcell $line ]
		set len 0 
		set len [ llength $switchInstanceList ]
		if { $len == 0 } {
			puts "There are no instances in the design for switch cell $line !"
		} else {
			puts "Number of instances for this switch cell : $len"
			puts $logfp "Number of instances for this switch cell : $len"
		}
		foreach inst $switchInstanceList {
			puts $logfp "Plotting voltage waveforms for instance $inst ...."; 
			if { $opt_internalNetOnly == 1 } {
				if { $opt_nograph == 0 && $opt_sv == 0 } {
					if { [ catch { plot voltage -name $inst -o $outDir/$inst -int }  err_variable ] } {
					        puts "Error occured - $err_variable"
						puts $logfp "Error occured - $err_variable" 
					} 
				} elseif { $opt_nograph == 0 && $opt_sv != 0 } {
					if { [ catch { plot voltage -name $inst -o $outDir/$inst -sv -int}  err_variable ] } {
					        puts "Error occured - $err_variable"
						puts $logfp "Error occured - $err_variable"
					} 
				} elseif { $opt_nograph != 0 && $opt_sv == 0 } {
					if { [ catch { plot voltage -name $inst -o $outDir/$inst -nograph -int	}  err_variable ] } {
					        puts "Error occured - $err_variable"
						puts $logfp "Error occured - $err_variable"
					} 
				} elseif { $opt_nograph != 0 && $opt_sv != 0 } {
					if { [ catch { plot voltage -name $inst -o $outDir/$inst -sv -nograph -int }  err_variable ] } {
					        puts "Error occured - $err_variable" 
						puts $logfp "Error occured - $err_variable"
					} 
				}
			} else {
				if { $opt_nograph == 0 && $opt_sv == 0 } {
					if { [ catch { plot voltage -name $inst -o $outDir/$inst }  err_variable ] } {
					        puts "Error occured - $err_variable"
						puts $logfp "Error occured - $err_variable"
					} 
				} elseif { $opt_nograph == 0 && $opt_sv != 0 } {
					if { [ catch { plot voltage -name $inst -o $outDir/$inst -sv }  err_variable ] } {
					        puts "Error occured - $err_variable"
						puts $logfp "Error occured - $err_variable"
					} 
				} elseif { $opt_nograph != 0 && $opt_sv == 0 } {
					if { [ catch { plot voltage -name $inst -o $outDir/$inst -nograph }  err_variable ] } {
					        puts "Error occured - $err_variable" 
						puts $logfp "Error occured - $err_variable"
					} 
				} elseif { $opt_nograph != 0 && $opt_sv != 0 } {
					if { [ catch { plot voltage -name $inst -o $outDir/$inst -sv -nograph }  err_variable ] } {
					        puts "Error occured - $err_variable" 
						puts $logfp "Error occured - $err_variable"
					} 
				}
			}

		}
		puts "Finished processing switch cell $line !";
		puts $logfp "Finished processing switch cell $line !";

	}
	
	puts "Plotted Switch Instance Voltage waveforms! Output waveforms are in directory $outDir !";
	puts $logfp "Plotted Switch Instance Voltage waveforms! Output waveforms are in directory $outDir !";
	close $logfp;

}





    
