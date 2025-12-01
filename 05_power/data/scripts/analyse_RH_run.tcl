#!/usr/local/bin/tclsh

proc generate_analysis_report {args} {

#############################################################################
# Name       : analyse_RH_run.tcl
# Description:  To generate maps,movie,reports of the Redhawk static/dynamic/rampup run results.
# $Revision  :  5.6.6$
# Author     : Vinayakam Subramanian , email : vinayakam@apache-da.com
#############################################################################

    
    array set opt [concat {-static 0 -esdStatic 0 -view 0 -thresholdListFile "thresholds.list" -o reports -dynamic 0 -help 0 -nogui 0 -rampup 0 -genRptScriptPath "defaultPath" -relativePath 0 -pathFromReportDirToRhDir "../../" -bundle 0 -lineLimit 10 -imagesInline 1} $args]
    set thresholdListFile $opt(-thresholdListFile)
    set opt_static $opt(-static)
    set opt_esdStatic $opt(-esdStatic)
    set opt_dynamic $opt(-dynamic)
    set help $opt(-help)
    set outDir $opt(-o)
    set view $opt(-view)
    set nogui $opt(-nogui)
    set opt_rampup $opt(-rampup)
    set opt_genRptScriptPath $opt(-genRptScriptPath)
    set opt_relativePath $opt(-relativePath)
    set opt_pathFromReportDirToRhDir $opt(-pathFromReportDirToRhDir)
    set bundleDir $opt(-bundle)
    if { $bundleDir != 0 } { 
	    set opt_bundle 1
    } else {
	    set opt_bundle 0
    }
    set opt_lineLimit $opt(-lineLimit)
    set imagesInline $opt(-imagesInline)
    global  anaScriptPath
    global report_dir
    
    if { $opt_static == 1 && $opt_dynamic == 1 } {
    	puts "Error : Both static and dynamic cannot be enabled simultaneously."
	puts "Use -static 1 after 'perform static' or -dynamic 1 after 'perform dynamic'"
	puts "Exit!"
	return
    } elseif { $opt_static == 1 && $opt_rampup == 1 } {
    	puts "Error : Both static and rampup cannot be enabled simultaneously."
	puts "Use -static 1 after 'perform static' or -rampup 1 after 'perform lowpower'"
	puts "Exit!"
	return
    } elseif { $opt_rampup == 1 && $opt_dynamic == 1 } {
    	puts "Error : Both rampup and dynamic cannot be enabled simultaneously."
	puts "Use -rampup 1 after 'perform lowpower' or -dynamic 1 after 'perform dynamic'"
	puts "Exit!"
	return
    }
 
    
    # help
     if {$help !=0} {
        puts "\nThis function is for generating reports from current RedHawk static/dynamic run"
        puts "\nFollowing options are supported:"
        puts "-thresholdListFile <file containing list of thresholds for the DVD/IR maps, thresholds must be in % ; default value is thresholds.list>"
        puts "-static <0 or 1, default is 0> ### To generate reports for static"
        puts "-esdStatic <0 or 1, default is 0> ### To generate reports for static ESD"
        puts "-dynamic <0 or 1, default is 0> ### To generate reports for dynamic"
	puts "-rampup <0 or 1, default is 0> ### To generate reports for rampup"
        puts "-o <output directory name, default is reports>"
	puts "It is recommended to turn off the pads in the GUI."
	puts "For generating animated gif of DvD movie, the path should point to 'gifsicle' and 'convert' and should have mkmv.pl in the <mkmv> path." 
	puts "-nogui <0 or 1, default is 0> ### To be enabled when redhawk is run in batch mode. Note : This will not generate the maps or movie!"
	puts "-bundle <bundle-directory-name> ### To create a bundle <bundle-directory-name>.tar.gz containing all the reports and RH output files."
	return
    }
    
    # if static/dynamic/rampup were not specified, exit.
    if { $opt_static == 0 && $opt_dynamic == 0 && $opt_rampup == 0 && $opt_esdStatic == 0 } {
    	puts "Error : Analysis type Static/Dynamic/Rampup/EsdStatic was not specified."
	puts "Use -static 1 after 'perform static' or -dynamic 1 after 'perform dynamic' or -rampup 1 after 'perform lowpower' or -esdStatic 1 after 'perform esdcheck'"
	puts "Exit!"
	return
    }
    
    # DO Not # remove pre-existing output directory
    #if {[file exists $outDir]} {
    #    puts "Deleting existing contents of output directory $outDir...\n"
    #    file delete -force $outDir
    #}
    
    # if output dir does not exist , create it.
    if  { [ file exists $outDir ] && [file isdirectory $outDir ] } {
    } else {
    	puts "Creating output directory $outDir..";
    	file mkdir $outDir
    }
    
    if { $opt_static == 1 } {
    	set report_dir "$outDir/static_reports"
    } elseif { $opt_dynamic == 1 } {
    	set report_dir "$outDir/dynamic_reports"
    } elseif { $opt_rampup == 1 } {
    	set report_dir "$outDir/rampup_reports"
    } elseif { $opt_esdStatic == 1 } {
    	set report_dir "$outDir/esdStatic_reports"
    }
    # if report dir does not exist , create it.
    if  { [ file exists $report_dir ] && [ file isdirectory $report_dir ] } {
    } else {
    	file mkdir $report_dir
    }
    # view only option: open mozilla and return
    puts "Analysis report file : $report_dir/analysis_summary.html"
    if {$view == 1} {
    	if { [ catch { exec which mozilla } err_variable ] == 0} {
    		puts "Opening analysis summary html file in Mozilla..."
    		set pw [ pwd ] 
    		exec mozilla "file://$pw/$report_dir/analysis_summary.html" &
   	 } else {
    		puts "Mozilla not found! Please open $report_dir/analysis_summary.html manually in your browser.";
    	}
	return
    }
    
  if { $nogui == 0} {
    #create maps directory
    set mapDir "$report_dir/maps"
    # if map dir does not exist , create it.
    if  { [ file exists $mapDir ] && [ file isdirectory $mapDir ]} {
    } else {
    	file mkdir $mapDir
    }
    file mkdir $mapDir
   
    
    puts "Thresholds list is in: $thresholdListFile\nEnable Static : $opt_static \nEnable Dynamic : $opt_dynamic\nEnable Rampup : $opt_rampup\nEnable ESD Static : $opt_esdStatic \nOutput directory : $outDir"
    
    # check whether thresholdListFile input was given
    if { [ file exists $thresholdListFile  ] == 0 } {
    	if { $thresholdListFile ne "thresholds.list" } {
		puts "Error: Default Threshold list file $thresholdListFile does not exist."
	} else {
		puts "Error: Threshold list file $thresholdListFile does not exist."
	}
	puts "No user-defined thresholds used!"
    }
  }
    
    # store variables to be passed to perl in $cwd/variables.list
    set outfp [ open $outDir/.variables.txt w ]
    
    #design name
    set design [ query top -name ]
    puts $outfp "DESIGN_NAME $design\n"
    # hostname
    if { [ catch { exec  uname -n }  err_variable ] } {			
    	puts stderr $err_variable
	puts "uname -n not supported.Hostname string not obtained."
    } else {
	  set hostname [exec uname -n]
	  puts $outfp "HOSTNAME $hostname\n"
    }    
    # platform
    if { [ catch { exec  uname -i }  err_variable ] } {			
    	puts stderr $err_variable
	puts "uname -i not supported.Platform string not obtained."
    } else {
	  set platform [exec uname -i]
	  puts $outfp "PLATFORM $platform\n"
    }
    # os and version
    if { [ catch { exec  uname -s -r }  err_variable ] } {			
    	puts stderr $err_variable
	puts "uname -s -r not supported.OS version string not obtained."
    } else {
	  set os_version [ exec uname -s -r]
	  puts $outfp "OS_AND_VERSION $os_version\n"
    }
    # temperature
    set temperature [ gsr get TEMPERATURE]
	if { $temperature > 2e5 } {
		puts $outfp "TEMPERATURE Undefined\n"
	} else {
		puts $outfp "TEMPERATURE $temperature\n"
	}
    # tool name
    if { [ catch { get build -name }  err_variable ] } {			
    	puts stderr $err_variable
	puts "get build -name not supported.Tool name string not obtained."
    } else {
	  set tool_name [ get build -name]
	  puts $outfp "TOOL_NAME $tool_name\n"
    }
    # tool version
    if { [ catch { get build -version }  err_variable ] } {			
    	puts stderr $err_variable
	puts "get build -version not supported.Tool name string not obtained."
    } else {
	  set tool_version [ get build -version]
	  puts $outfp "TOOL_VERSION $tool_version\n"
    }
    
  # don't do gridcheck for rampup
  if { $opt_rampup == 0 && $opt_esdStatic == 0 } {        
    # gridcheck
    perform gridcheck -o $report_dir/gridcheck.rpt
  }
    
  if { $nogui == 0} {
    	# dump common maps
    	puts "Dumping gif of design layout view ..."
    	dump gif -map SA -o $mapDir/${design}_Layout.gif 
	
	if { $opt_esdStatic == 0} {
    		#Power maps
    		puts "Dumping gifs for power maps ..."
		dump gif -map PD -o $mapDir/${design}_PowerDensity.gif
		dump gif -map IPM -o $mapDir/${design}_InstPower.gif
		dump gif -map CPM -o $mapDir/${design}_ClockPower.gif
		#dump gif -map ILM -o $mapDir/${design}_InstLeakage.gif
		dump gif -map IFM -o $mapDir/${design}_InstFreq.gif
	}
	
    	if {$opt_esdStatic == 0} {
		#Resistance maps
    		puts "Dumping gifs for resistance maps ..."
		dump gif -map PRM -o $mapDir/${design}_VddRes.gif
		dump gif -map TRM -o $mapDir/${design}_TotalRes.gif
		dump gif -map GRM -o $mapDir/${design}_VssRes.gif
	}
	

	
    if { $opt_static } {
    	puts $outfp "STATIC_ENABLE 1\n"
	
	###(a) Instance IR drop map: <design_instIR>.gif
	###(b) Wire IR drop map: <design_VDD>.gif, <design_VSS>.gif

	# wire IR map
	config viewlayer -name all -style invisible
    	config viewlayer -name metalonly -style fill
	dump gif -map IR -o $mapDir/${design}_wireIR.gif
	
	#instance IR map
	config viewlayer -name all -style invisible
	config viewlayer -name instance -style fill
	dump gif -map IR -o $mapDir/${design}_instanceIR.gif
	
	# disable instances for following maps
	config viewlayer -name all -style fill
    	config viewlayer -name instance -style invisible
	
	# EM and current maps
	#dump gif -map EM -o $mapDir/${design}_EM.gif
	# dump EM and current maps for dynamic and rampup
		if { [ catch { dump gif -map EM -o $mapDir/${design}_EM.gif }  err_variable ] } {
			#puts stderr $err_variable
			puts "Errors occured during dump EM gif : $err_variable"
		} else {
			puts "EM map dumped."
		}
	dump gif -map CUR -o $mapDir/${design}_Current.gif
	
	
	# dump IR maps for different thresholds , if thresholdListFile exists
	if { [ file exists $thresholdListFile  ] } {
		puts "Dumping gifs of IR maps for given thresholds ..."
		set thresfp [ open $thresholdListFile r ]
		while {[gets $thresfp max] >= 0} {
			# set threshold to user defined value
			config colormap -percent -min 0 -max $max -wire
			dump gif -map IR -o $mapDir/${design}_IR_$max%.gif
		}
	}
    }
    
  }	
    
    
    
    if { $opt_dynamic || $opt_rampup } {
    	puts "Getting values of GSR dynamic keywords...."
    	set dyn_sim_time [ gsr get DYNAMIC_SIMULATION_TIME ]
	set dyn_presim_time [ gsr get DYNAMIC_PRESIM_TIME ]
	set dyn_time_step [ gsr get DYNAMIC_TIME_STEP ]
	puts $outfp "DYNAMIC_ENABLE 1\n"
	puts $outfp "DYNAMIC_SIMULATION_TIME $dyn_sim_time \n"
	puts $outfp "DYNAMIC_PRESIM_TIME $dyn_presim_time\n"
	puts $outfp "DYNAMIC_TIME_STEP $dyn_time_step\n"
	
      if { $nogui == 0} {
	# dump dynamic maps
	puts "Dumping gifs for decap maps ..."
	#Decap maps
	dump gif -map DD -o $mapDir/${design}_DecapDensity.gif
	dump gif -map DEV -o $mapDir/${design}_DeviceDecap.gif
	dump gif -map LC -o $mapDir/${design}_LoadCap.gif
	dump gif -map IDD -o $mapDir/${design}_IntentionalDecapDensity.gif
	dump gif -map PG -o $mapDir/${design}_PowerGridParasiticDecap.gif

	#instance DvD maps
	puts "Dumping gifs for instance DvD maps ..."
	dump gif -map minTW -o $mapDir/${design}_minTW.gif
	dump gif -map minCyc -o $mapDir/${design}_minCyc.gif
	dump gif -map avgTW -o $mapDir/${design}_avgTW.gif
	dump gif -map maxTW -o $mapDir/${design}_maxTW.gif
	
	#wire DvD map
	config viewlayer -name all -style invisible
    	config viewlayer -name metalonly -style fill
	dump gif -map IR -o $mapDir/${design}_wireDvD.gif
	
	# dump EM and current maps for dynamic and rampup
		if { [ catch { dump gif -map EM -o $mapDir/${design}_PeakEM.gif }  err_variable ] } {
			#puts stderr $err_variable
			puts "Errors occured during dump EM gif : $err_variable"
		} else {
			puts "EM map dumped."
		}
	if { [ catch { dump gif -map CUR -o $mapDir/${design}_Current.gif }  err_variable ] } {
			#puts stderr $err_variable
			puts "Errors occured during dump CUR gif : $err_variable"
		} else {
			puts "Current map dumped."
		}
	

	# dump DVD maps for different thresholds , if thresholdListFile exists
	if { [ file exists $thresholdListFile  ] } {
		puts "Dumping gifs of DvD maps for given thresholds ..."
		set thresfp [ open $thresholdListFile r ]
		while {[gets $thresfp max] >= 0} {
			# set threshold to user defined value
			config colormap -percent -min 0 -max $max -inst
			dump gif -map minCyc -o $mapDir/${design}_minCyc_$max%.gif
		}
	}
	
	# movie
	puts "Creating DvD movie..."
	#create movie directory under $outDir
	set movieDir  "$report_dir/movie"
	# if movie dir does not exist , create it.
    	if  { [ file exists $movieDir ] &&  [ file isdirectory $movieDir ] } {
    	} else {
    		file mkdir $movieDir
    	}
	file mkdir $movieDir
	if { [ catch { movie make } err_variable ] } {
		puts "Error occured while creating movie!"
		puts stderr $err_variable
		puts " Movie is not created."
        }  else {
    		puts "Movie created!"
		if { [ catch { exec which mkmv.pl } err_variable ] } {
			#puts stderr $err_variable
			#puts "mkmv.pl not found in PATH."
			if {  [ file exists $anaScriptPath/mkmv.pl ] } {
				puts "mkmv.pl script found in tcl script path itself ($anaScriptPath)!Converting movie to animated gif....";
				if { [ catch { exec $anaScriptPath/mkmv.pl -l 0 -i .apache/.movie -o $movieDir/${design}_movie.gif }  err_variable ] } {
					puts stderr $err_variable
					puts "Errors occured during Movie conversion.Please check whether convert and gifsicle are installed in your system."
				} else {
					puts "Movie created successfully! The movie gif file is $movieDir/${design}_movie.gif"
				}				
    			} else {
				puts "mkmv.pl not found in PATH or in tcl script path. Movie gif not created."
			}				  
		} else {
    			puts "mkmv.pl found in PATH.Converting movie to animated gif...."
			if { [ catch { exec mkmv.pl -l 0 -i .apache/.movie -o $movieDir/${design}_movie.gif }  err_variable ] } {
			puts stderr $err_variable
				puts "Errors occured during Movie conversion.Please check whether convert and gifsicle are installed in your system."
			} else {
				puts "Movie created successfully! The movie gif file is $movieDir/${design}_movie.gif"
			}
		
		} 
	}
		
	
#	if { [file exists $mkpath/mkmv.pl ] } {
#		puts "Converting movie to animated gif...."
#		if { [ catch { exec $mkpath/mkmv.pl -l 0 -i .apache/.movie -o $movieDir/${design}_movie.gif }  err_variable ] } {
#			puts stderr $err_variable
#			puts "Errors occured during Movie creation.Please check whether convert and gifsicle are installed in your system."
#		} else {
#			puts "Movie created successfully! The movie gif file is $movieDir/${design}_movie.gif"
#		}
#	} else {
#		puts "mkmv.pl not found in $mkpath. Movie gif not created."
#	}
	puts ""
      }	
    }
    
    
   

    # generate missing via report
    puts "Generating missing via report..."
    if { [ catch { mesh vias -report_missing }  err_variable ] } {
			puts stderr $err_variable
			puts "Errors occured during Missing via report generation."
    }  else {
    		puts "Finished generating missing via report."
	}
    
    if { $opt_dynamic } {
    	# generate decap statistics report
    	puts "Generating decap statistics report..."
    	print decap -o $report_dir/decap_statistics.rpt
    	puts "Finished generating decap statistics report."
	# generate "print type" report
	puts "Generating switching stats by cell type report..."
	if { [ catch { print type -o $report_dir/switchingStatsByCellType.rpt }  err_variable ] } {
		puts stderr $err_variable
		puts "Errors occured during print type output generation."
    	}  else {
		puts "Finished generating switching stats by cell type report."
	}
	# generate "plot switching" report
	puts "Generating switching histogram..."
	if { [ catch { plot switching -o $report_dir/switchingHistogram.txt -nograph }  err_variable ] } {
		puts stderr $err_variable
		puts "Errors occured during plot switching output generation."
    	}  else {
		puts "Finished generating switching histogram."
	}
	# generate demand current waveform if get version returns 6.2 or 7.1
	if { [ catch { get version }  err_variable ] } {
			puts stderr $err_variable
			puts "get version command is not supported."
    	}  else {
    		set version [ get version]
		set version2digit [string range $version 0 2 ]
		if { $version2digit == "6.2" } {
			puts "Version is 6.2.Generating demand current waveform..."
			if { [ catch { plot current -net -power -o $report_dir/demand_current.txt -nograph}  err_variable ] } {
				puts stderr $err_variable
				puts "Errors occured while plotting demand current waveform."
    			}  else {
				puts "Finished generating demand current waveform."
			}
		} elseif { $version2digit == "7.1" } {
			puts "Version is 7.1.Generating demand current waveform..."
			if { [ catch { plot current -net -power -o $report_dir/demand_current.txt -nograph}  err_variable ] } {
				puts stderr $err_variable
				puts "Errors occured while plotting demand current waveform."
    			}  else {
				puts "Finished generating demand current waveform."
			}
		} elseif { $version2digit == "7.2" } {
			puts "Version is 7.2.Generating demand current waveform..."
			if { [ catch { plot current -net -power -o $report_dir/demand_current.txt -nograph}  err_variable ] } {
				puts stderr $err_variable
				puts "Errors occured while plotting demand current waveform."
    			}  else {
				puts "Finished generating demand current waveform."
			}
#		} elseif { $version2digit == "8.1" ||  $version2digit == "8.2" ||  $version2digit == "9.1" ||  $version2digit == "9.2" ||  $version2digit == "rd"} {
		} else {
			puts "Version is post 8.X.Generating demand current waveform..."
			if { [ catch { plot current -net -power -o $report_dir/demand_current.txt -nograph}  err_variable ] } {
				puts stderr $err_variable
				puts "Errors occured while plotting demand current waveform."
    			}  else {
				puts "Finished generating demand current waveform."
			}
		}
		
	}
    }	
    
    
    if { $opt_rampup } {
    	# find last switch turning on
    	puts "Finding last switch turning on..."
	set  lastTurnOnSwitch [  get_last_turning_on_switch ]
	if {  $lastTurnOnSwitch != "-1"} {
		if { $lastTurnOnSwitch ne "-2" } { 
			puts "Last switch turning on is : $lastTurnOnSwitch ";
			plot voltage -name $lastTurnOnSwitch -nograph -o $report_dir/last_switch
			puts $outfp "LAST_TURN_ON_SWITCH $lastTurnOnSwitch";
		} else {
			puts "Unable to find last switch.";
		}
	}
	
    }	
    
     if { $opt_dynamic || $opt_rampup } {
    	# generate battery current waveform if get version returns 6.2 or 7.1
	if { [ catch { get version }  err_variable ] } {
			puts stderr $err_variable
			puts "get version command is not supported."
    	}  else {
    		set version [ get version]
		set version2digit [string range $version 0 2 ]
		if { $version2digit == "6.2" } {
			puts "Version is 6.2.Generating battery current waveform..."
			if { [ catch { plot current -net -power -pad -o $report_dir/battery_current.txt -nograph}  err_variable ] } {
				puts stderr $err_variable
				puts "Errors occured while plotting battery current waveform."
    			}  else {
				puts "Finished generating battery current waveform."
			}
		} elseif { $version2digit == "7.1" } {
			puts "Version is 7.1.Generating battery current waveform..."
			if { [ catch { plot current -net -power -pad -o $report_dir/battery_current.txt -nograph}  err_variable ] } {
				puts stderr $err_variable
				puts "Errors occured while plotting battery current waveform."
    			}  else {
				puts "Finished generating battery current waveform."
			}
		} elseif { $version2digit == "7.2" } {
			puts "Version is 7.2.Generating battery current waveform..."
			if { [ catch { plot current -net -power -pad -o $report_dir/battery_current.txt -nograph}  err_variable ] } {
				puts stderr $err_variable
				puts "Errors occured while plotting battery current waveform."
    			}  else {
				puts "Finished generating battery current waveform."
			}
#		} elseif { $version2digit == "8.1"  ||  $version2digit == "8.2" ||  $version2digit == "9.1" ||  $version2digit == "9.2" ||  $version2digit == "rd"} {
		} else	{
			puts "Version is post 8.X.Generating battery current waveform..."
			if { [ catch { plot current -net -power -pad -o $report_dir/battery_current.txt -nograph}  err_variable ] } {
				puts stderr $err_variable
				puts "Errors occured while plotting battery current waveform."
    			}  else {
				puts "Finished generating battery current waveform."
			}
		}
		
	}
    }
	
    close $outfp
    
    # execute perl script
    puts "Generating analysis summary reports..."
    # find path of generate_report.pl and set the variable genRptScript
    #if genRptScriptPath is specified as ~vinayakam/scripts , it will not work. User needs to specify genRptScriptPath as /home/vinayakam
    	if { [ file exists $opt_genRptScriptPath/generate_report.pl ] } {
		puts "generate_report.pl script found in the user-specified path - $opt_genRptScriptPath!";
		set genRptScript [ concat $opt_genRptScriptPath/generate_report.pl ]
	} elseif { [ catch { exec which generate_report.pl } err_variable ] == 0} {
		puts "generate_report.pl script found as $err_variable!";
		set genRptScript $err_variable
	} elseif {  [ file exists $anaScriptPath/generate_report.pl ] } {
		puts "generate_report.pl script found in tcl script path itself ($anaScriptPath)!";
		set genRptScript [ concat $anaScriptPath/generate_report.pl ]
	} else {
		puts "generate_report.pl not found in genRptScriptPath,PATH and in the directory containing analyse_RH_run.tcl . Summary report not created. Exit"
		return
	}
    if { $opt_relativePath } {
    	if { $opt_static && $opt_dynamic } {
    		if { [ catch { exec perl $genRptScript  -dynamic  -static  -o $outDir -relativePath -pathFromReportDirToRhDir $opt_pathFromReportDirToRhDir -imagesInline $imagesInline } err_variable ] } {
			puts stderr $err_variable
			puts "Errors occured while generating analysis summary reports."
    		}  else {
			puts "Finished generating analysis summary reports."
		}

		# if you execute generate_report.pl in background, then tcl will proceed to the next commands which however require the output of the perl script to be read in. So don't run generate_report.pl in background.
    	} elseif { $opt_dynamic } {
    		if { [ catch { exec perl $genRptScript -dynamic  -o $outDir -relativePath -pathFromReportDirToRhDir $opt_pathFromReportDirToRhDir -imagesInline $imagesInline } err_variable ] } {
			puts stderr $err_variable
			puts "Errors occured while generating analysis summary reports."
    		}  else {
			puts "Finished generating analysis summary reports."
		}

    	} elseif { $opt_static } {
    		if { [ catch { exec perl $genRptScript  -static  -o $outDir -relativePath -pathFromReportDirToRhDir $opt_pathFromReportDirToRhDir -imagesInline $imagesInline } err_variable ] } {
			puts stderr $err_variable
			puts "Errors occured while generating analysis summary reports."
    		}  else {
			puts "Finished generating analysis summary reports."
		}

    	} elseif { $opt_rampup } {
    	 	if { [ catch { exec perl $genRptScript  -rampup  -o $outDir -relativePath -pathFromReportDirToRhDir $opt_pathFromReportDirToRhDir -imagesInline $imagesInline } err_variable ] } {
			puts stderr $err_variable
			puts "Errors occured while generating analysis summary reports."
    		}  else {
			puts "Finished generating analysis summary reports."
		}

    	} elseif { $opt_esdStatic } {
    	 	if { [ catch { exec perl $genRptScript  -esdStatic  -o $outDir -relativePath -pathFromReportDirToRhDir $opt_pathFromReportDirToRhDir -imagesInline $imagesInline } err_variable ] } {
			puts stderr $err_variable
			puts "Errors occured while generating analysis summary reports."
    		}  else {
			puts "Finished generating analysis summary reports."
		}

    	} else {
    		if { [ catch { exec perl $genRptScript  -o $outDir -relativePath -pathFromReportDirToRhDir $opt_pathFromReportDirToRhDir -imagesInline $imagesInline } err_variable ] } {
			puts stderr $err_variable
			puts "Errors occured while generating analysis summary reports."
    		}  else {
			puts "Finished generating analysis summary reports."
		}

    	}
    } elseif { $opt_bundle } {
    	if { $opt_static && $opt_dynamic } {
    		if { [ catch { exec perl $genRptScript  -dynamic  -static  -o $outDir -bundle $bundleDir -lineLimit $opt_lineLimit -imagesInline $imagesInline } err_variable ] } {
			puts stderr $err_variable
			puts "Errors occured while generating analysis summary reports."
    		}  else {
			puts "Finished generating analysis summary reports."
		}

		# if you execute generate_report.pl in background, then tcl will proceed to the next commands which however require the output of the perl script to be read in. So don't run generate_report.pl in background.
    	} elseif { $opt_dynamic } {
    		if { [ catch { exec perl $genRptScript -dynamic  -o $outDir -bundle $bundleDir -lineLimit $opt_lineLimit -imagesInline $imagesInline } err_variable ] } {
			puts stderr $err_variable
			puts "Errors occured while generating analysis summary reports."
    		}  else {
			puts "Finished generating analysis summary reports."
		}

    	} elseif { $opt_static } {
    		if { [ catch { exec perl $genRptScript  -static  -o $outDir -bundle $bundleDir -lineLimit $opt_lineLimit -imagesInline $imagesInline } err_variable ] } {
			puts stderr $err_variable
			puts "Errors occured while generating analysis summary reports."
    		}  else {
			puts "Finished generating analysis summary reports."
		}
    	} elseif { $opt_rampup } {
    		if { [ catch { exec perl $genRptScript  -rampup  -o $outDir -bundle $bundleDir -lineLimit $opt_lineLimit -imagesInline $imagesInline } err_variable ] } {
			puts stderr $err_variable
			puts "Errors occured while generating analysis summary reports."
    		}  else {
			puts "Finished generating analysis summary reports."
		}

    	} elseif { $opt_esdStatic } {
    		if { [ catch { exec perl $genRptScript  -esdStatic  -o $outDir -bundle $bundleDir -lineLimit $opt_lineLimit -imagesInline $imagesInline } err_variable ] } {
			puts stderr $err_variable
			puts "Errors occured while generating analysis summary reports."
    		}  else {
			puts "Finished generating analysis summary reports."
		}

    	} else {
    		if { [ catch { exec perl $genRptScript  -o $outDir -bundle $bundleDir -lineLimit $opt_lineLimit -imagesInline $imagesInline } err_variable ] } {
			puts stderr $err_variable
			puts "Errors occured while generating analysis summary reports."
    		}  else {
			puts "Finished generating analysis summary reports."
		}

    	}
    } else {
    	if { $opt_static && $opt_dynamic } {
    		if { [ catch { exec perl $genRptScript  -dynamic  -static  -o $outDir  -imagesInline $imagesInline } err_variable ] } {
			puts stderr $err_variable
			puts "Errors occured while generating analysis summary reports."
    		}  else {
			puts "Finished generating analysis summary reports."
		}

		# if you execute generate_report.pl in background, then tcl will proceed to the next commands which however require the output of the perl script to be read in. So don't run generate_report.pl in background.
    	} elseif { $opt_dynamic } {
    		if { [ catch { exec perl $genRptScript -dynamic  -o $outDir  -imagesInline $imagesInline } err_variable ] } {
			puts stderr $err_variable
			puts "Errors occured while generating analysis summary reports."
    		}  else {
			puts "Finished generating analysis summary reports."
		}

   	 } elseif { $opt_static } {
    		if { [ catch { exec perl $genRptScript  -static  -o $outDir  -imagesInline $imagesInline } err_variable ] } {
			puts stderr $err_variable
			puts "Errors occured while generating analysis summary reports."
    		}  else {
			puts "Finished generating analysis summary reports."
		}

    	} elseif { $opt_rampup } {
    		if { [ catch { exec perl $genRptScript  -rampup  -o $outDir  -imagesInline $imagesInline } err_variable ] } {
			puts stderr $err_variable
			puts "Errors occured while generating analysis summary reports."
    		}  else {
			puts "Finished generating analysis summary reports."
		}

   	 }  elseif { $opt_esdStatic } {
    		if { [ catch { exec perl $genRptScript  -esdStatic  -o $outDir  -imagesInline $imagesInline } err_variable ] } {
			puts stderr $err_variable
			puts "Errors occured while generating analysis summary reports."
    		}  else {
			puts "Finished generating analysis summary reports."
		}

    	} else {
    		if { [ catch { exec perl $genRptScript  -o $outDir  -imagesInline $imagesInline } err_variable ] } {
			puts stderr $err_variable
			puts "Errors occured while generating analysis summary reports."
    		}  else {
			puts "Finished generating analysis summary reports."
		}

    	}	
    }
    puts "Finished generating analysis summary report!"
    
    # disable version file need since it is now 10.1 and the commands are always supported
    # for RH6.1 and above 
#    set verfp [ open "$outDir/.version.txt" r ]
#    while {[gets $verfp line] >= 0} {
#    	if { $line == 6 || $line == 7 || $line == 8} {
	   if { $nogui == 0} {
		if { [ catch { config viewpad -type all -mode off }  err_variable ] } {
			#puts stderr $err_variable
			puts "Errors occured during 'config viewpad' : $err_variable"
		} else {
			puts "Pads turned off."
		}
		if {$opt_esdStatic == 0} {
			# dumping Toggle rate maps
   			dump gif -map ITR -o $mapDir/${design}_InstanceToggleRate.gif
			dump gif -map TRD -o $mapDir/${design}_ToggleRateDensity.gif
			dump gif -map LPM -o $mapDir/${design}_LeakagePower.gif
		}
		# dump pad current maps
		if { [ catch { config viewpad -type all -mode on }  err_variable ] } {
			#puts stderr $err_variable
			puts "Errors occured during 'config viewpad' : $err_variable"
		} else {
			puts "Pads turned on."
		}
		if { $opt_static } {
			dump gif -map PADC -o $mapDir/${design}_PadCurrent.gif
		}
		if { $opt_dynamic || $opt_rampup } {
			dump gif -map PADC -o $mapDir/${design}_PeakPadCurrent.gif
		}
	   }
#	}
#    }
#    close $verfp
if { $opt_rampup } {
    set p2tfp [ open "$outDir/.values_from_perl_to_tcl.txt" r ]
    while { [ gets $p2tfp line ] >= 0 } {
    	if { [ regexp SWITCH_INSTANCE_WITH_MAX_CURRENT $line ] } {
		set max_cur_switch [ lindex [split $line ] 2 ]
		set max_cur_switch_filename [ lindex [ split $line ] 3 ]
		if { $nogui == 0 } {	
			plot voltage -name $max_cur_switch -o $report_dir/$max_cur_switch_filename
		} else {
			plot voltage -name $max_cur_switch -o $report_dir/$max_cur_switch_filename -nograph
		}
	}
    }
    close $p2tfp
}    
		
    puts "Output Directory : $outDir"
    if { $nogui == 0} {
    	puts "Maps directory : $mapDir"
    }
    puts "Analysis report file : $report_dir/analysis_summary.html"
    if {$nogui == 0} {
    	if { [ catch { exec which mozilla } err_variable ] == 0} {
    		puts "Opening analysis summary html file in Mozilla..."
    		set pw [ pwd ] 
    		exec mozilla "file://$pw/$report_dir/analysis_summary.html" &
   	 } else {
    		puts "Mozilla not found! Please open $report_dir/analysis_summary.html manuaaly in your browser.";
    	}
    }
    if { $opt_bundle } {
	    puts "Bundle is $bundleDir.tar.gz!"
    }	    
    puts "Finished!"

} 


proc get_last_turning_on_switch {} {

#############################################################################
# Name  of proc  : get_last_turning_on_switch
# Description:  To get the switch instance name that is turning on last
# $Revision  :  1.1$
# Author     : Vinayakam Subramanian , email : vinayakam@apache-da.com
#############################################################################

#############################################################################
# Inputs : .apache/apache.dsw , .apache/apache.imap
# Output : Name of switch instance that is turning on last
# Usage : set  lastTurnOnSwitch [  get_last_turning_on_switch ]
#############################################################################

# fifth column of apache.dsw is second control pin TW (if only one control pin is present for switch, then fifth nand fourth column are same)
# first column of apache.dsw is instance ID
global report_dir
 if { [ catch { exec  sort +4 -n -r .apache/apache.dsw > $report_dir/.dsw }  err_variable ] } {                 
     if { [ catch { exec  sort -k5,5 -n -r .apache/apache.dsw > $report_dir/.dsw }  err_variable ] } {                    
	puts stderr $err_variable
        puts "Could not sort apache.dsw file."
	return -1;
     } else {
	if { [ catch { exec  head -1 $report_dir/.dsw | awk "{ print \$1; }" }  err_variable ] } {                 
        	puts stderr $err_variable
        	puts "Could not find instance id of last switch turning on."
		return -1;
    	} else { 
    		set last_switch_inst_id [exec  head -1 $report_dir/.dsw | awk "{ print \$1; }"]
	 	puts "Instance id of last switch  turning on obtained."
	}
      }
    } else {
           if { [ catch { exec  head -1 $report_dir/.dsw | awk "{ print \$1; }" }  err_variable ] } {                 
        	puts stderr $err_variable
        	puts "Could not find instance id of last switch turning on."
		return -1;
    	} else { 
    		set last_switch_inst_id [exec  head -1 $report_dir/.dsw | awk "{ print \$1; }"]
	 	puts "Instance id of last switch  turning on obtained."
	}
    }  
# first column of apache.imap is instance ID
# second column of apache.imap is instance name
 if { [ catch { exec  awk " { if(\$1==$last_switch_inst_id) {print \$2;} }" .apache/apache.imap }  err_variable ] } {                 
        puts stderr $err_variable
        puts "Could not find instance name of last switch turning on."
	return -2;
    } else {
          set last_switch_instance_name [ exec awk " { if(\$1==$last_switch_inst_id) {print \$2;} }" .apache/apache.imap ]
	  puts "Instance name of last switch turning on obtained."
    }      
     
return $last_switch_instance_name;

}

set report_dir 0
set anaScriptPath [ file dirname [info script] ] 
      
