# ======================================================================
# Add instances of hierarchical memory model into the timing file
# ======================================================================
#
# - Open timing file specified using '-i' option, default get timing 
#   file from gsr
# - Write timing file including instances of hierarchical memory model.
#   Specify file name using '-o', default file name is the input timing
#   file name with '.mem' extension written into the working directory.
#   o The instance name of the memory with hierarchical memory model will
#     be extended by '/adsU1'. With this extension the timing information
#     will be applied to the memory core instead of the memory wrapper.
#   o Apply pre-defined slew values to the memory output stage pins.
#
# Usage:
#  atcl_import_mem_sta [-h | -i <timing_file> | -o <mem_timig_file> | -e]
#      -h: puts the usage
#      -i: input timing file name (default "gsr get STA_FILE")
#      -o: output timing file name (default "./<input timing file>.mem")
#      -e: execute import sta of new timing file with instances of the
#          hierarchical memory model (default "1")
#
# This procedure can be used any time after 'setup design'
#
# ======================================================================
proc atcl_import_mem_sta_help {} {
   puts {Usage: atcl_import_mem_sta [-h | -i <timing_file> | -o <mem_timig_file> | -e]}
   puts {                         -h: print help message}
   puts {                         -i: input timing file name (default "gsr get STA_FILE")}  
   puts {                         -o: output timing file name (default "./<input timing file>.mem")}
   puts {                         -e: execute import sta of new timing file with instances of the hierarchical memory model (default "1")}
}
# main proc
proc atcl_import_mem_sta {args} {
    puts "***********************************************************"
    puts "**** Update timing file to account for additional instances"
    puts "**** introduced by hierarchical memory models."
    puts "***********************************************************"
    # get arguments
    set argv [split $args]
    set argc [llength $argv]
    if {$argc >0 && [lindex $argv 0] eq "-h"} {
        atcl_import_mem_sta_help; return
    }

    set temp ""
    if {$argc >0} {    
        for {set i 0} {$i < $argc} {incr i} {
        set A($i) [lindex $argv $i]
        append temp "$A($i) "  
    }
    }
    # input timing file
    if {[lsearch -exact $temp -i] != -1} {
        set a [lsearch -exact $temp -i]
        set input_timing_file [lindex $temp [expr $a+1]]
    } else {
        set input_timing_file [lindex [lindex [gsr get STA_FILE] 1] 1]
    }
    # output timing file
    if {[lsearch -exact $temp -o] != -1} {
        set a [lsearch -exact $temp -o]
        set output_timing_file [lindex $temp [expr $a+1]]
    } else {
        set itf [split $input_timing_file  "/"]
        set output_timing_file [lindex $itf [expr [llength $itf] -1]].mem
    }
    # execute import sta (default 1)
    if {[lsearch -exact $temp -e] != -1} {
        set a [lsearch -exact $temp -e]
        set import_sta [lindex $temp [expr $a+1]]
    } else {
        set import_sta 1
    }
    # get memory instances of hierarchical memory model type
    set hier_memory_instances  [list ]
    set output_stage_instances [list ]
    set all_memory_instances [get inst * -glob -type memory]
    foreach memory $all_memory_instances {
        if {[regexp {/adsU1/adsU1$} $memory] == 1} {
            set mem [split $memory "/"]
            set lmem [expr [llength $mem] -2]
            set mem_inst ""
            for {set i 0} {$i < $lmem} {incr i} {
                set mem_inst [concat $mem_inst [lindex $mem $i]]
            }
            join $mem_inst /
            set inst $mem_inst
            set memory_instances [get inst $mem_inst/* -glob]
            if {[llength $memory_instances] >1} {
                lappend hier_memory_instances $mem_inst
                puts "INFO    : Found instance of hierarchical memory model '$mem_inst'."
                foreach inst $memory_instances {
                    if {[regexp {/adsU1$} $inst] != 1} {
                        lappend output_stage_instances $inst
                    }
                }
           }
        }
    }
    # Proceed only if memories with hierarchical memory model have been
    # found in the design.
    if {[llength $hier_memory_instances] == 0} {
                puts "INFO    : Could not find any memory using a hierarchical memory model. Return"

        return
    }
    # open timing files
    if {![file exists $input_timing_file]} {
        puts "ERROR   : File $input_timing_file does not exists. Return"
        return
    }  else {
        puts "INFO    : Reading timing file : '$input_timing_file'"
    }
    set IN [open $input_timing_file r]
    puts "INFO    : Writing timing file with corrected memory instance names: '$output_timing_file'"
    set OUT [open $output_timing_file w]    
    # process timing file
    # - adding /adsU1 hierarchy for all memory instances using the
    #   hierarchical memory model
    # - apply 5ps slew for all signal pins of the output stages
    set namemap 0
    while {[gets $IN line] >= 0} {
        if {[regexp {^\#NAMEMAP } $line]} { 
            set namemap 1
        }
        if {[regexp {^\#END NAMEMAP$} $line]} { 
            set namemap 0
        }
        if {$namemap == 1} {
            foreach hier_memory_instance $hier_memory_instances {
                if {[regexp $hier_memory_instance $line]} { 
                    set line $line/adsU1
                }
            }
        }
        if {[regexp {^\#END INSTANCE$} $line]} { 
            foreach output_stage_instance $output_stage_instances {
                puts $OUT "I $output_stage_instance"
                set output_stage_master_cell [get inst $output_stage_instance -master]
                set output_stage_master_cell_pins [get cell $output_stage_master_cell -pins -type signal]
                foreach output_stage_master_cell_pin $output_stage_master_cell_pins {
                    puts $OUT "S $output_stage_master_cell_pin 0.005 0.005 0.005 0.005"
                }
            }
        }
        puts $OUT "$line"
    }
    close $IN
    close $OUT
    if {$import_sta == 1} {
        puts "INFO    : Import sta file '$output_timing_file' including memory instances of hierarchical memory model"
        import sta $output_timing_file
        puts "***********************************************************"
        puts "**** Import timing accounting for hierarchical memory model finished."
        puts "***********************************************************"
    } else {
        puts "INFO    : Import sta file not done. Run 'import sta $output_timing_file' to load timing file with hierarchical memory model instances explicitly."
        puts "***********************************************************"
        puts "**** Preparation of timing file including instances of hierarchical memory model finished."
        puts "***********************************************************"
    }
}
