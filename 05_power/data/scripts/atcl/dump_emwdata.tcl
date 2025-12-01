# Some Procedures
proc filecopy {src dest} {
    if {[catch {file copy -force $src $dest} sError]} {
        puts "File copy Failed: From: $src To: $dest Error: $sError"
    }
}

proc dump_emwdata {tsmc_process tsmc_process_code {design_name ""}} {
    set em_config {
        # Config for power EM reporting
        EM_WORST_POWER
        WIRESEGMENT $LAYER $STARTX $STARTY $ENDX $ENDY $WIDTH $EM_WIDTH $NET_NAME $CURRENT $EM_LIMIT $EM_RATIO $BLECH_LENGTH $CURRENT_DIR $RESISTANCE $EM_MODE $PULSE_WIDTH $EM_DUTY_RATIO $WIRESEG_ID $TEMPERATURE
        VIA $LAYER $CX $CY $CUT_WIDTH $CUT_HEIGHT $CUT_AREA $CUT_NUM $WIDTH_ABOVE $WIDTH_BELOW $NET_NAME $CURRENT $EM_LIMIT $EM_RATIO $BLECH_LENGTH $CURRENT_DIR $RESISTANCE $VIA_NAME $EM_MODE $PULSE_WIDTH $EM_DUTY_RATIO $VIA_ID $TEMPERATURE

        # Config for signal EM reporting
        EM_WORST_SIGNAL
        WIRESEGMENT $LAYER $STARTX $STARTY $ENDX $ENDY $WIDTH $EM_WIDTH $NET_NAME $CURRENT $EM_LIMIT $EM_RATIO $BLECH_LENGTH $CURRENT_DIR $RESISTANCE $EM_MODE $PULSE_WIDTH $EM_DUTY_RATIO $WIRESEG_ID
        VIA $LAYER $CX $CY $CUT_WIDTH $CUT_HEIGHT $CUT_AREA $CUT_NUM $WIDTH_ABOVE $WIDTH_BELOW $NET_NAME $CURRENT $EM_LIMIT $EM_RATIO $BLECH_LENGTH $CURRENT_DIR $RESISTANCE $VIA_NAME $EM_MODE $PULSE_WIDTH $EM_DUTY_RATIO $VIA_ID

    }

    set fo [open "emw.config" "w"]
    puts $fo $em_config
    close $fo


    # EM Reporting Parameters
    gsr set EM_REPORT_PERCENTAGE 0
    gsr set EM_REPORT_LINE_NUMBER -1
    gsr set CONFIGURABLE_REPORT_FILE ./emw.config

    # Is a Mode set in the GSR ?
    set gsrdump [gsr dump]
    if { [lsearch -exact $gsrdump EM_MODE] == -1 } {
        perform emcheck
    } else {
        # Report Peak EM
        gsr set EM_MODE peak
        perform emcheck

        # Report Avg. EM
        gsr set EM_MODE avg
        perform emcheck

        # Report RMS EM
        gsr set EM_MODE rms
        perform emcheck
    }

    file delete emw.config

    # Copy and Create the required files for EMWaiver Python Code
    file delete -force emwfiles
    file mkdir emwfiles


    set design [get design]
    if {[file exists "adsRpt/Static"]} {
        set filename "$design.em.worst.avg" 
        filecopy "adsRpt/Static/$filename" "emwfiles/$filename"
    } else {
        set filename "$design.em.worst.avg" 
        filecopy "adsRpt/Dynamic/$filename" "emwfiles/$filename"
        set filename "$design.em.worst.rms" 
        filecopy "adsRpt/Dynamic/$filename" "emwfiles/$filename"
        set filename "$design.em.worst.peak" 
        filecopy "adsRpt/Dynamic/$filename" "emwfiles/$filename"    
    }
    filecopy ".layerStack.txt" "emwfiles/layerStack.txt"

    set fo [open "emwfiles/misc" "w"]
    puts $fo $tsmc_process
    puts $fo $tsmc_process_code
    if {[llength $design_name] == 0} {
        set design_name [get design]
    }
    puts $design_name
    puts $fo $design_name
    close $fo

}
