proc atclQuerySigEM_help {} {
puts "atclQuerySigEM -setup <conf file name> ?-window <llx lly urx ury>? ?-nets <net names>? ?-layers <layer names>? ?-o <output file name>? ?-h? ?-m?"
}

proc atclQuerySigEM_manpage {} {
puts "
SYNOPSIS
        Apache-AE TCL utility to get EM info on wires/vias
                                                                                                                                                            
USAGE
	atclQuerySigEM -setup <conf file name> ?-window <llx lly urx ury>? ?-nets <net names>? ?-layers <layer names>? ?-o <output file name>? ?-h? ?-m?
   Options:
        -setup <conf file name> : Config file with all metal/via layer names. \n Script to be run first with this option and then with other options. \n All other options are mutually exclusive of this option. \n (Required, format explained below)
	?-window <llx lly urx ury>? : Bounding box information. Only wires/vias lying inside the window will be reported. \n For Wires/Wire-Segments/Vias lying in multiple windows the code snaps it to left and lower window. \n (Optional. Default : Full chip)
	?-nets <net names>? : Nets to be reported (Optional. Default : All nets)
	?-layers <layer names>? : Layers to be reported (Optional. Default : All layers)
	?-o <output file name>? : Output file name (Optional. Default : Returns TCL list. Format explained below) 
	-h : Help
        -m : Man page


-setup <conf file name> : Format for conf file is as follows:

*************************************************************************************
#List all the metals/vias in the design with the keywords METALS/VIAS. These keywords are required.
METALS metal1 metal2 metal3 metal4 metal5 metal6 metal7 metal8
VIAS via1 via2 via3 via4 via5 via6 via7
*************************************************************************************

NOTE: The script needs to be run in two steps viz.
#Step 1# Setup the script
   Example Command 
   	atclQuerySigEM -setup layers.conf

#Step 2# Run script using other options
   Example Commands 
   	atclQuerySigEM -o emoutput.txt
	atclQuerySigEM -window 0 0 100 100
	atclQuerySigEM -window 0 0 100 100 -nets vdd1 vdd2 vss
	atclQuerySigEM -window 0 0 100 100 -nets vdd1 vdd2 vss -layers metal1 metal2 metal3
	atclQuerySigEM -window 0 0 100 100 -nets vdd1 vdd2 vss -layers metal1 metal2 metal3 -o emoutput.txt


Output Format:
For Wires:
<id> <layer> <net> <llx lly lrx lry urx ury ulx uly> <width> <resistance> <current_dir>

For Wire-Segments:
<layer> <net> <llx lly urx ury> <dir> <current_rms> <em_limit_rms> <em_rms> <current_peak> <em_limit_peak> <em_peak> <current_avg> <em_limit_avg> <em_avg> <resistance> <segmentid>

For Vias:
<id> <layer> <vianame> <net> <cordx cordy> <cuts_#> <cut_width> <cut_height> <resistance> <dir> <current_rms> <em_limit_rms> <em_rms> <current_peak> <em_limit_peak> <em_peak> <current_avg> <em_limit_avg> <em_avg> <top_metal_id> <bot_metal_id> <top_seg_id1> <top_seg_id2> <bot_seg_id1> <bot_seg_id2> <top_metal llx lly urx ury> <via_cut llx lly urx ury> <bot_metal llx lly urx ury>

"
}


proc atclQuerySigEM { args } {
set argv [split $args]
set argc [llength $argv]

# set default #####################
set setupflag 0
set windowflag 0
set netsflag 0
set layersflag 0
set outflag 0
global viamodelarr
# END of set default #####################

for {set j 0} {$j < $argc} {incr j 1} {
	if {[regexp {\-setup} [lindex $argv $j]]} {
		set conffile [lindex $argv [expr $j + 1]]
		set setupflag 1
        } elseif  {[regexp {\-window} [lindex $argv $j]]} {
		set windowflag 1
	} elseif  {[regexp {\-nets} [lindex $argv $j]]} {
		set netsflag 1
	} elseif  {[regexp {\-layers} [lindex $argv $j]]} {
		set layersflag 1
        } elseif  {[regexp {\-o} [lindex $argv $j]]} {
                set outfile [lindex $argv [expr $j + 1]]
		set outflag 1
        } elseif  {[regexp {\-h} [lindex $argv $j]]} {
                atclQuerySigEM_help;return
        } elseif  {[regexp {\-m} [lindex $argv $j]]} {
                atclQuerySigEM_manpage;return
        }
}

if {$setupflag && ($windowflag || $netsflag || $layersflag || $outflag)} {
	puts "-setup option should not be used with other options"
	return
}

if {$setupflag} {
	atclQuerySigEM_Setup $conffile
} else {
	atclQuerySigEM_Report $args
}

}; ### End of proc atclQuerySigEM

proc atclQuerySigEM_Setup {conffile} {
config cmdlog off

if {$conffile == ""} {
	puts "\n-setup <file name> is required"
	return
}

puts "Setting up for atclQuerySigEM"
set CONF [open $conffile r]

global viamodelarr
# Parse the conf file ############################
set all_metals_list [list]
set all_vias_list [list]
puts "Reading conf fie $conffile"
while { [gets $CONF line] >=0 } {
        if {[regexp {^\s*$} $line] || [regexp {^#} $line] } {
        } else {
		set line [string trim $line]
	        regsub -all -- {[[:space:]]+} $line " " line
	        set line [split $line]
	}
	# ALL_METALS
        if {[string equal -nocase [lindex $line 0] "METALS"]} {
		set len [llength $line]
		for {set k 1} {$k < $len} {incr k 1} {		
			lappend all_metals_list [lindex $line $k]
		}
	}
	# ALL_VIAS
        if {[string equal -nocase [lindex $line 0] "VIAS"]} {
		set len [llength $line]
		for {set k 1} {$k < $len} {incr k 1} {		
			lappend all_vias_list [lindex $line $k]
		}
	}
}
close $CONF

puts "\nReading METALS... \n$all_metals_list" 
puts "\nReading VIAS... \n$all_vias_list\n" 
# END of Parse the conf file ############################

## Delete already existing DB and create a new one ###########
set file [glob -nocomplain -directory . .apache/.atclQuerySigEMDB.db]
if {[file exists $file]} {
	file delete -force $file
} 

global env
set libpath "$env(APACHEROOT)/linux64/lib/libsqlite3.6.14.1.so"
if {![file exists $libpath]} {
	set libpath "$env(APACHEROOT)/linux32e3/lib/libsqlite3.6.18.so"
}
if {![file exists $libpath]} {
	set libpath "$env(APACHEROOT)/lib/libsqlite3.6.14.1.so"
}
if {![file exists $libpath]} {
	set libpath "$env(APACHEROOT)/lib/libsqlite3.6.18.so"
}

if {[catch {load $libpath Sqlite3}]} {puts "Please Check RedHawk/Totem Version" ; return}
sqlite3 db .apache/.atclQuerySigEMDB.db
	
db eval {CREATE TABLE wiretable(w_id int, w_layer text, w_net text, w_llx float, w_lly float , w_lrx float, w_lry float, \
w_urx float, w_ury float, w_ulx float, w_uly float, w_width float, w_resistance float, w_dir text)}
	
db eval {CREATE TABLE wiresegtable(ws_layer text, ws_net text, ws_llx float, ws_lly float , ws_urx float, ws_ury float, \
ws_dir text, ws_current float, ws_emlimit ws_float, ws_em text, ws_resistance float, ws_segmentid text)}

	
db eval {CREATE TABLE viatable(v_id int, v_layer text, v_vianame text, v_net text, v_cordx float, v_cordy float , \
v_ncuts int, v_cutwidth float, v_cutheight float, v_resistance float, v_dir text, v_current float, v_emlimit float, v_em text , \
v_topmid int, v_botmid int, v_topsegid1 text, v_topsegid2 text, v_botsegid1 text, v_botsegid2 text, v_boxinfo text)}

db eval {CREATE INDEX wireind ON wiretable(w_layer, w_net, w_urx, w_ury, w_llx, w_lly)}
db eval {CREATE INDEX wiresegind ON wiresegtable(ws_segmentid, ws_urx, ws_ury, ws_llx, ws_lly, ws_dir)}
#db eval {CREATE INDEX wiresegind ON wiresegtable(ws_urx, ws_ury, ws_llx, ws_lly)}
db eval {CREATE INDEX viaind ON viatable(v_layer, v_net, v_cordx, v_cordy)}

## End of Delete already existing DB and create a new one ####

db eval {PRAGMA synchronous=OFF}
db eval {PRAGMA count_changes=OFF}
db eval {PRAGMA default_cache_size=5000}
db eval {PRAGMA journal_mode=OFF}
db eval {PRAGMA temp_store=2}
db eval {BEGIN TRANSACTION}

# Get EM info for all layers and vias #############################
foreach metal $all_metals_list {
	puts "Getting EM info for $metal"
	set em_wire_info [ get em -type wire -order first -layer $metal]
        #puts -nonewline $OUT $em_wire_info
	set em_wire_info [string trim $em_wire_info]
	set wireid [lindex $em_wire_info 0]
	#db eval {INSERT INTO t1 VALUES($em_wire_info)}
	if {$em_wire_info != {}} {
		InsertIntoWireTable $em_wire_info 
	}
        atclGetWireSegmentNextAll $wireid $em_wire_info
        while { $em_wire_info != {} } {
        	set em_wire_info [ get em -type wire -order next ]
                #puts -nonewline $OUT $em_wire_info
		if {$em_wire_info != {}} {
			set em_wire_info [string trim $em_wire_info]
			set wireid [lindex $em_wire_info 0]
			#db eval {INSERT INTO t1 VALUES($em_wire_info)}
			InsertIntoWireTable $em_wire_info
                	atclGetWireSegmentNextAll $wireid $em_wire_info 
		}
        }
}



#*******************
#foreach vname $all_vias_list {
#	if {![info exists viamodelarr($vname)]} {
#		set viamodel [get viamodel $vname -detail_bbox]
#		set viamodelarr($vname) $viamodel
#		puts "Getting via size information for $vname"
#	} else {
#		set viamodel $viamodelarr($vname)
#	}
#}
#foreach {k v}  [array get viamodelarr] {
#	puts "$k, $v"
#}
#*******************


foreach via $all_vias_list {
	puts "Getting EM info for $via"
        set em_via_info [ get em -type via -order first -layer $via -topology]
        #puts -nonewline $OUT $em_via_info
	set em_via_info [string trim $em_via_info]
	#db eval {INSERT INTO t1 VALUES($em_via_info)}
	if {$em_via_info != {} } {
		InsertIntoViaTable $em_via_info
	}
        while { $em_via_info != {} } {
                set em_via_info [ get em -type via -order next  -topology]
                #puts -nonewline $OUT $em_via_info
		if {$em_via_info != {} } {
			set em_via_info [string trim $em_via_info]
			#db eval {INSERT INTO t1 VALUES($em_via_info)}
			InsertIntoViaTable $em_via_info
		}
        }
}
# End of Get EM info for all layers and vias ########################

db eval {COMMIT}
get em -clear
config cmdlog on

#db eval {SELECT * FROM wiresegtable} {
#	puts $LOG "$layer $net $llx $lly $urx $ury $dir $current $emlimit $em $segmentid"
#}

#****************************************************************************************************************************
### ADD PROTECTION FOR THE CASE WHERE SOME OF THE TABLES ARE EMPTY ##########################################################
#****************************************************************************************************************************

#db eval {SELECT * FROM wiretable ORDER BY id} {
#	puts $LOG "$id $layer $net $llx $lly $lrx $lry $urx $ury $ulx $uly $width $resistance $dir"
#	#Rect -box $llx $lly $urx $ury
#	db eval "SELECT * FROM wiresegtable WHERE segmentid GLOB '$id\_*'" {
#		puts $LOG "$layer $net $llx $lly $urx $ury $dir $current $emlimit $em $segmentid"
#		#Rect -box $llx $lly $urx $ury -color white -width 1 
#		#marker add -position $llx $lly -size 10
#		#marker add -position $urx $ury -size 10
#	}
#}
#
#
#db eval {SELECT * FROM viatable ORDER BY id} {
#	puts $LOG "$id $layer $vianame $net $cordx $cordy $ncuts $cutwidth $cutheight\
#	$resistance $dir $current $emlimit $em $topmid $botmid $topsegid1 $topsegid2 $botsegid1 $botsegid2 $boxinfo"
#}

puts "Done with Setup"
}; ### End of proc atclQuerySigEM_Setup



proc atclGetWireSegmentNextAll {wireid em_wire_info} {
      set count 1
      set em_wire_segment_info [ get em -type wire_segment -order first ]
      #puts -nonewline $ofile $em_wire_segment_info
      set em_wire_segment_info [string trim $em_wire_segment_info]
      #db eval {INSERT INTO t1 VALUES($em_wire_segment_info)}
      if {$em_wire_segment_info != {} } {
      	InsertIntoWireSegTable $em_wire_segment_info $wireid\_$count $em_wire_info
      }
      while { $em_wire_segment_info != {} } {
                        set em_wire_segment_info [get em -type wire_segment -order next]
			incr count
                        #puts -nonewline $ofile $em_wire_segment_info
			if {$em_wire_segment_info != {} } {
      				set em_wire_segment_info [string trim $em_wire_segment_info]
      				#db eval {INSERT INTO t1 VALUES($em_wire_segment_info)}
				InsertIntoWireSegTable $em_wire_segment_info $wireid\_$count $em_wire_info
			}
      }
      #db eval {INSERT INTO t1 VALUES("###########################")}
}; ### end of proc atclGetWireSegmentNextAll




proc atclQuerySigEM_Report { args } {
regexp -all {\{(.*)\}} $args  match args
set argv [split $args]
set argc [llength $argv]

# set default #####################
set outfile "GetEM.out"
set setupflag 0
set windowflag 0
set netsflag 0
set layersflag 0
set outflag 0
global viamodelarr
# END of set default #####################

for {set j 0} {$j < $argc} {incr j 1} {
	if {[regexp {\-setup} [lindex $argv $j]]} {
		set conffile [lindex $argv [expr $j + 1]]
		set setupflag 1
        } elseif  {[regexp {\-window} [lindex $argv $j]]} {
		set windowflag 1
		set winllx [lindex $argv [expr $j + 1]]
		set winlly [lindex $argv [expr $j + 2]]
		set winurx [lindex $argv [expr $j + 3]]
		set winury [lindex $argv [expr $j + 4]]
	} elseif  {[regexp {\-nets} [lindex $argv $j]]} {
		set netsflag 1
		for {set i [expr $j + 1]} {$i < $argc} {incr i 1} {
                        if {![regexp {\-} [lindex $argv $i]] } {
                                lappend nets [lindex $argv $i]
                        } else {
                                break
                        }
                }
	} elseif  {[regexp {\-layers} [lindex $argv $j]]} {
		set layersflag 1
		for {set i [expr $j + 1]} {$i < $argc} {incr i 1} {
                        if {![regexp {\-} [lindex $argv $i]] } {
                                lappend layers [lindex $argv $i]
                        } else {
                                break
                        }
                }
        } elseif  {[regexp {\-o} [lindex $argv $j]]} {
                set outfile [lindex $argv [expr $j + 1]]
		set outflag 1
        } elseif  {[regexp {\-h} [lindex $argv $j]]} {
                atclQuerySigEM_help;return
        } elseif  {[regexp {\-m} [lindex $argv $j]]} {
                atclQuerySigEM_manpage;return
        }
}


if {$setupflag && ($windowflag || $netsflag || $layersflag || $outflag)} {
	puts "-setup option should not be used with other options"
	return
}

if {![file exists .apache/.atclQuerySigEMDB.db]} {
	puts "Please use the -setup option first"
	atclQuerySigEM_help;return
}

if {$outflag} {
	set OUT [open $outfile w]
}


#### Check for different output flags ###########
if {$windowflag == 0} {
	puts "Window = Full Chip"
	if {($netsflag == 0) && ($layersflag == 0)} {
		puts "Outputting all Layers on all Nets"
		db eval {SELECT * FROM wiretable} {
			lappend outlist "$w_id $w_layer $w_net $w_llx $w_lly $w_lrx $w_lry $w_urx $w_ury $w_ulx $w_uly $w_width $w_resistance $w_dir"
			db eval "SELECT * FROM wiresegtable WHERE ws_segmentid GLOB '$w_id\_*'" {
				lappend outlist "$ws_layer $ws_net $ws_llx $ws_lly $ws_urx $ws_ury $ws_dir $ws_current $ws_emlimit $ws_em $ws_resistance $ws_segmentid"
			}
		}
		db eval {SELECT * FROM viatable} {
			lappend outlist "$v_id $v_layer $v_vianame $v_net $v_cordx $v_cordy $v_ncuts $v_cutwidth $v_cutheight\
			$v_resistance $v_dir $v_current $v_emlimit $v_em $v_topmid $v_botmid $v_topsegid1 $v_topsegid2 $v_botsegid1 $v_botsegid2 $v_boxinfo"
		}
	}
	if {($netsflag == 0) && ($layersflag == 1)} {
		puts "Outputting Layers \"$layers\" on all Nets"
		foreach eachlayer $layers {
			db eval "SELECT * FROM wiretable WHERE w_layer = '$eachlayer'" {
				lappend outlist "$w_id $w_layer $w_net $w_llx $w_lly $w_lrx $w_lry $w_urx $w_ury $w_ulx $w_uly $w_width $w_resistance $w_dir"
				db eval "SELECT * FROM wiresegtable WHERE ws_segmentid GLOB '$w_id\_*'" {
					lappend outlist "$ws_layer $ws_net $ws_llx $ws_lly $ws_urx $ws_ury $ws_dir $ws_current $ws_emlimit $ws_em $ws_resistance $ws_segmentid"
				}
			}
		}
		foreach eachlayer $layers {
			db eval "SELECT * FROM viatable WHERE v_layer = '$eachlayer'" {
				lappend outlist "$v_id $v_layer $v_vianame $v_net $v_cordx $v_cordy $v_ncuts $v_cutwidth $v_cutheight\
				$v_resistance $v_dir $v_current $v_emlimit $v_em $v_topmid $v_botmid $v_topsegid1 $v_topsegid2 $v_botsegid1 $v_botsegid2 $v_boxinfo"
			}
		}
	}
	if {($netsflag == 1) && ($layersflag == 0)} {
		puts "Outputting Nets \"$nets\" on all Layers"
		foreach eachnet $nets {
			db eval "SELECT * FROM wiretable WHERE w_net = '$eachnet'" {
				lappend outlist "$w_id $w_layer $w_net $w_llx $w_lly $w_lrx $w_lry $w_urx $w_ury $w_ulx $w_uly $w_width $w_resistance $w_dir"
				db eval "SELECT * FROM wiresegtable WHERE ws_segmentid GLOB '$w_id\_*'" {
					lappend outlist "$ws_layer $ws_net $ws_llx $ws_lly $ws_urx $ws_ury $ws_dir $ws_current $ws_emlimit $ws_em $ws_resistance $ws_segmentid"
				}
			}
		}
		foreach eachnet $nets {
			db eval "SELECT * FROM viatable WHERE v_net = '$eachnet'" {
				lappend outlist "$v_id $v_layer $v_vianame $v_net $v_cordx $v_cordy $v_ncuts $v_cutwidth $v_cutheight\
				$v_resistance $v_dir $v_current $v_emlimit $v_em $v_topmid $v_botmid $v_topsegid1 $v_topsegid2 $v_botsegid1 $v_botsegid2 $v_boxinfo"
			}
		}
	}
	if {($netsflag == 1) && ($layersflag == 1)} {
		puts "Outputting Layers \"$layers\" on Nets \"$nets\""
		foreach eachlayer $layers {
			foreach eachnet $nets {
				db eval "SELECT * FROM wiretable WHERE w_layer = '$eachlayer' AND w_net = '$eachnet'" {
					lappend outlist "$w_id $w_layer $w_net $w_llx $w_lly $w_lrx $w_lry $w_urx $w_ury $w_ulx $w_uly $w_width $w_resistance $w_dir"
					db eval "SELECT * FROM wiresegtable WHERE ws_segmentid GLOB '$w_id\_*'" {
						lappend outlist "$ws_layer $ws_net $ws_llx $ws_lly $ws_urx $ws_ury $ws_dir $ws_current $ws_emlimit $ws_em $ws_resistance $ws_segmentid"
					}
				}
			}
		}
		foreach eachlayer $layers {
			foreach eachnet $nets {
				db eval "SELECT * FROM viatable WHERE v_layer = '$eachlayer' AND v_net = '$eachnet'" {
					lappend outlist "$v_id $v_layer $v_vianame $v_net $v_cordx $v_cordy $v_ncuts $v_cutwidth $v_cutheight\
					$v_resistance $v_dir $v_current $v_emlimit $v_em $v_topmid $v_botmid $v_topsegid1 $v_topsegid2 $v_botsegid1 $v_botsegid2 $v_boxinfo"
				}
			}
		}
	}
} elseif {$windowflag == 1} {
#	set winllx [lindex $window 0]
#	set winlly [lindex $window 1]
#	set winurx [lindex $window 2]
#	set winury [lindex $window 3]
	#Rect -box $winllx $winlly $winurx $winury -width 1 -color red
	puts "Window = $winllx $winlly $winurx $winury"
	if {$winllx > $winurx} {
		set temp $winllx
		set winllx $winurx
		set winurx $temp
	}
	if {$winlly > $winury} {
		set temp $winlly
		set winlly $winury
		set winury $temp
	}
	if {($netsflag == 0) && ($layersflag == 0)} {
		puts "Outputting all Layers on all Nets"
		set selwirecmd " w_urx > $winllx AND w_ury > $winlly AND $winurx > w_llx AND $winury > w_lly "
		db eval "SELECT * FROM wiretable WHERE $selwirecmd" {
			#Rect -box $w_llx $w_lly $w_urx $w_ury -color green
			lappend outlist "$w_id $w_layer $w_net $w_llx $w_lly $w_lrx $w_lry $w_urx $w_ury $w_ulx $w_uly $w_width $w_resistance $w_dir"
			set selwiresegcmd " ((ws_urx > $winllx AND ws_ury > $winlly AND $winurx > ws_llx AND $winury > ws_lly) OR ((ws_dir IN ('l','r') AND ws_ury = $winury AND ws_urx > $winllx AND ws_llx < $winurx ) OR (ws_dir IN ('u','d') AND ws_urx = $winurx AND ws_ury > $winlly AND ws_lly < $winury))) "
			db eval "SELECT * FROM wiresegtable WHERE ws_segmentid GLOB '$w_id\_*' AND $selwiresegcmd" {
				set seglist [findintersect $winllx $winlly $winurx $winury $ws_llx $ws_lly $ws_urx $ws_ury $ws_dir] 
				if {[llength $seglist] != 0} {
					set ws_llx [lindex $seglist 0]
					set ws_lly [lindex $seglist 1]
					set ws_urx [lindex $seglist 2]
					set ws_ury [lindex $seglist 3]
					set scalingfactor [lindex $seglist 4]
					set ws_resistance [expr $ws_resistance * $scalingfactor]
				}
				#Rect -box $ws_llx $ws_lly $ws_urx $ws_ury -width 1
				#marker add -position $ws_llx $ws_lly -size 10
				#marker add -position $ws_urx $ws_ury -size 10
				lappend outlist "$ws_layer $ws_net $ws_llx $ws_lly $ws_urx $ws_ury $ws_dir $ws_current $ws_emlimit $ws_em $ws_resistance $ws_segmentid"
			}
		}
		set selcmd " $winllx < v_cordx AND v_cordx <= $winurx AND $winlly < v_cordy AND v_cordy <= $winury "
		db eval "SELECT * FROM viatable WHERE $selcmd" {
			#marker add -position $v_cordx $v_cordy -size 5 -color blue
			lappend outlist "$v_id $v_layer $v_vianame $v_net $v_cordx $v_cordy $v_ncuts $v_cutwidth $v_cutheight\
			$v_resistance $v_dir $v_current $v_emlimit $v_em $v_topmid $v_botmid $v_topsegid1 $v_topsegid2 $v_botsegid1 $v_botsegid2 $v_boxinfo"
		}
	}
	if {($netsflag == 0) && ($layersflag == 1)} {
		puts "Outputting Layers \"$layers\" on all Nets"
		foreach eachlayer $layers {
			set selwirecmd " w_urx > $winllx AND w_ury > $winlly AND $winurx > w_llx AND $winury > w_lly "
			db eval "SELECT * FROM wiretable WHERE w_layer = '$eachlayer' AND $selwirecmd" {
				#Rect -box $w_llx $w_lly $w_urx $w_ury -color green
				lappend outlist "$w_id $w_layer $w_net $w_llx $w_lly $w_lrx $w_lry $w_urx $w_ury $w_ulx $w_uly $w_width $w_resistance $w_dir"
				set selwiresegcmd " ((ws_urx > $winllx AND ws_ury > $winlly AND $winurx > ws_llx AND $winury > ws_lly) OR ((ws_dir IN ('l','r') AND ws_ury = $winury AND ws_urx > $winllx AND ws_llx < $winurx ) OR (ws_dir IN ('u','d') AND ws_urx = $winurx AND ws_ury > $winlly AND ws_lly < $winury))) "
				db eval "SELECT * FROM wiresegtable WHERE ws_segmentid GLOB '$w_id\_*' AND $selwiresegcmd" {
					set seglist [findintersect $winllx $winlly $winurx $winury $ws_llx $ws_lly $ws_urx $ws_ury $ws_dir] 
					if {[llength $seglist] != 0} {
						set ws_llx [lindex $seglist 0]
						set ws_lly [lindex $seglist 1]
						set ws_urx [lindex $seglist 2]
						set ws_ury [lindex $seglist 3]
						set scalingfactor [lindex $seglist 4]
						set ws_resistance [expr $ws_resistance * $scalingfactor]
					}
					#Rect -box $ws_llx $ws_lly $ws_urx $ws_ury -width 1
					#marker add -position $ws_llx $ws_lly -size 10
					#marker add -position $ws_urx $ws_ury -size 10
					lappend outlist "$ws_layer $ws_net $ws_llx $ws_lly $ws_urx $ws_ury $ws_dir $ws_current $ws_emlimit $ws_em $ws_resistance $ws_segmentid"
				}
			}
		}
		foreach eachlayer $layers {
			set selcmd " $winllx < v_cordx AND v_cordx <= $winurx AND $winlly < v_cordy AND v_cordy <= $winury "
			db eval "SELECT * FROM viatable WHERE v_layer = '$eachlayer' AND $selcmd" {
				#marker add -position $v_cordx $v_cordy -size 5 -color blue
				lappend outlist "$v_id $v_layer $v_vianame $v_net $v_cordx $v_cordy $v_ncuts $v_cutwidth $v_cutheight\
				$v_resistance $v_dir $v_current $v_emlimit $v_em $v_topmid $v_botmid $v_topsegid1 $v_topsegid2 $v_botsegid1 $v_botsegid2 $v_boxinfo"
			}
		}
	}
	if {($netsflag == 1) && ($layersflag == 0)} {
		puts "Outputting Nets \"$nets\" on all Layers"
		foreach eachnet $nets {
			set selwirecmd " w_urx > $winllx AND w_ury > $winlly AND $winurx > w_llx AND $winury > w_lly "
			db eval "SELECT * FROM wiretable WHERE w_net = '$eachnet' AND $selwirecmd" {
				#Rect -box $w_llx $w_lly $w_urx $w_ury -color green
				lappend outlist "$w_id $w_layer $w_net $w_llx $w_lly $w_lrx $w_lry $w_urx $w_ury $w_ulx $w_uly $w_width $w_resistance $w_dir"
				set selwiresegcmd " ((ws_urx > $winllx AND ws_ury > $winlly AND $winurx > ws_llx AND $winury > ws_lly) OR ((ws_dir IN ('l','r') AND ws_ury = $winury AND ws_urx > $winllx AND ws_llx < $winurx ) OR (ws_dir IN ('u','d') AND ws_urx = $winurx AND ws_ury > $winlly AND ws_lly < $winury))) "
				db eval "SELECT * FROM wiresegtable WHERE ws_segmentid GLOB '$w_id\_*' AND $selwiresegcmd" {
					set seglist [findintersect $winllx $winlly $winurx $winury $ws_llx $ws_lly $ws_urx $ws_ury $ws_dir] 
					if {[llength $seglist] != 0} {
						set ws_llx [lindex $seglist 0]
						set ws_lly [lindex $seglist 1]
						set ws_urx [lindex $seglist 2]
						set ws_ury [lindex $seglist 3]
						set scalingfactor [lindex $seglist 4]
						set ws_resistance [expr $ws_resistance * $scalingfactor]
					}
					#Rect -box $ws_llx $ws_lly $ws_urx $ws_ury -width 1
					#marker add -position $ws_llx $ws_lly -size 10
					#marker add -position $ws_urx $ws_ury -size 10
					lappend outlist "$ws_layer $ws_net $ws_llx $ws_lly $ws_urx $ws_ury $ws_dir $ws_current $ws_emlimit $ws_em $ws_resistance $ws_segmentid"
				}
			}
		}
		foreach eachnet $nets {
			set selcmd " $winllx < v_cordx AND v_cordx <= $winurx AND $winlly < v_cordy AND v_cordy <= $winury "
			db eval "SELECT * FROM viatable WHERE v_net = '$eachnet' AND $selcmd" {
				#marker add -position $v_cordx $v_cordy -size 5 -color blue
				lappend outlist "$v_id $v_layer $v_vianame $v_net $v_cordx $v_cordy $v_ncuts $v_cutwidth $v_cutheight\
				$v_resistance $v_dir $v_current $v_emlimit $v_em $v_topmid $v_botmid $v_topsegid1 $v_topsegid2 $v_botsegid1 $v_botsegid2 $v_boxinfo"
			}
		}
	}
	if {($netsflag == 1) && ($layersflag == 1)} {
		puts "Outputting Layers \"$layers\" on Nets \"$nets\""
		foreach eachlayer $layers {
			foreach eachnet $nets {
				set selwirecmd " w_urx > $winllx AND w_ury > $winlly AND $winurx > w_llx AND $winury > w_lly "
				db eval "SELECT * FROM wiretable WHERE w_layer = '$eachlayer' AND w_net = '$eachnet' AND $selwirecmd" {
					#Rect -box $w_llx $w_lly $w_urx $w_ury -color green
					lappend outlist "$w_id $w_layer $w_net $w_llx $w_lly $w_lrx $w_lry $w_urx $w_ury $w_ulx $w_uly $w_width $w_resistance $w_dir"
					set selwiresegcmd " ((ws_urx > $winllx AND ws_ury > $winlly AND $winurx > ws_llx AND $winury > ws_lly) OR ((ws_dir IN ('l','r') AND ws_ury = $winury AND ws_urx > $winllx AND ws_llx < $winurx ) OR (ws_dir IN ('u','d') AND ws_urx = $winurx AND ws_ury > $winlly AND ws_lly < $winury))) "
					db eval "SELECT * FROM wiresegtable WHERE ws_segmentid GLOB '$w_id\_*' AND $selwiresegcmd" {
						set seglist [findintersect $winllx $winlly $winurx $winury $ws_llx $ws_lly $ws_urx $ws_ury $ws_dir] 
						if {[llength $seglist] != 0} {
							set ws_llx [lindex $seglist 0]
							set ws_lly [lindex $seglist 1]
							set ws_urx [lindex $seglist 2]
							set ws_ury [lindex $seglist 3]
							set scalingfactor [lindex $seglist 4]
							set ws_resistance [expr $ws_resistance * $scalingfactor]
						}
						#Rect -box $ws_llx $ws_lly $ws_urx $ws_ury -width 1
						#marker add -position $ws_llx $ws_lly -size 10
						#marker add -position $ws_urx $ws_ury -size 10
						lappend outlist "$ws_layer $ws_net $ws_llx $ws_lly $ws_urx $ws_ury $ws_dir $ws_current $ws_emlimit $ws_em $ws_resistance $ws_segmentid"
					}
				}
			}
		}
		foreach eachlayer $layers {
			foreach eachnet $nets {
				set selcmd " $winllx < v_cordx AND v_cordx <= $winurx AND $winlly < v_cordy AND v_cordy <= $winury "
				db eval "SELECT * FROM viatable WHERE v_layer = '$eachlayer' AND v_net = '$eachnet' AND $selcmd" {
					#marker add -position $v_cordx $v_cordy -size 5 -color blue
					lappend outlist "$v_id $v_layer $v_vianame $v_net $v_cordx $v_cordy $v_ncuts $v_cutwidth $v_cutheight\
					$v_resistance $v_dir $v_current $v_emlimit $v_em $v_topmid $v_botmid $v_topsegid1 $v_topsegid2 $v_botsegid1 $v_botsegid2 $v_boxinfo"
				}
			}
		}
	}
}

#### End of Check for different output flags ####


if {$outflag} {
	if {[info exists outlist]} {
		foreach outelem $outlist {
			puts $OUT "$outelem"
		}
	}
	close $OUT
	puts "EM information outputted to file $outfile"
} else {
	if {[info exists outlist]} {
		return $outlist
		unset outlist
	}
}
}; ### End of proc atclQuerySigEM_Report



proc InsertIntoWireTable {eminfo} {
set id [lindex $eminfo 0] 
set layer [lindex $eminfo 1] 
set net  [lindex $eminfo 2]
set llx [lindex $eminfo 3]
set lly [lindex $eminfo 4]
set lrx [lindex $eminfo 5]
set lry [lindex $eminfo 6]
set urx   [lindex $eminfo 7]
set ury   [lindex $eminfo 8]
set ulx  [lindex $eminfo 9]
set uly   [lindex $eminfo 10]
set width  [lindex $eminfo 11]
set resistance  [lindex $eminfo 12]
set dir  [lindex $eminfo 13]
db eval {INSERT INTO wiretable VALUES($id, $layer, $net, $llx, $lly, $lrx, $lry, $urx, $ury, $ulx, $uly, $width, $resistance, $dir)}
}



proc InsertIntoWireSegTable {eminfo segid em_wire_info} {
set layer [lindex $eminfo 0]
set net  [lindex $eminfo 1]
set llx  [lindex $eminfo 2]
set lly  [lindex $eminfo 3]
set urx  [lindex $eminfo 4]
set ury  [lindex $eminfo 5]
set dir  [lindex $eminfo 6]
##$$##set current  [lindex $eminfo 7]
##$$##set emlimit  [lindex $eminfo 8]
##$$##set em  [lindex $eminfo 9]
set current  [list [lindex $eminfo 7] [lindex $eminfo 8] [lindex $eminfo 9]]
set emlimit  [list [lindex $eminfo 10] [lindex $eminfo 11] [lindex $eminfo 12]]
set em  [list [lindex $eminfo 13] [lindex $eminfo 14] [lindex $eminfo 15]]
set segmentid $segid 
set wirellx [lindex $em_wire_info 3]
set wirelly [lindex $em_wire_info 4]
set wireurx [lindex $em_wire_info 7]
set wireury [lindex $em_wire_info 8]
set wireres [lindex $em_wire_info 12]
if {$dir == "l" || $dir == "r"} {
	set wsresistance [expr $wireres * ($urx - $llx) / double($wireurx - $wirellx)]
}
if {$dir == "u" || $dir == "d"} {
	set wsresistance [expr $wireres * ($ury - $lly) / double($wireury - $wirelly)]
}
db eval {INSERT INTO wiresegtable VALUES($layer, $net, $llx, $lly, $urx, $ury, $dir, $current, $emlimit, $em, $wsresistance, $segmentid)} 
}



proc InsertIntoViaTable {eminfo} {
set id [lindex $eminfo 0] 
set layer [lindex $eminfo 1] 
set vianame [lindex $eminfo 2] 
set net [lindex $eminfo 3] 
set cordx [lindex $eminfo 4] 
set cordy [lindex $eminfo 5] 
set ncuts [lindex $eminfo 6] 
set cutwidth [lindex $eminfo 7] 
set cutheight [lindex $eminfo 8] 
set resistance [lindex $eminfo 9] 
set dir [lindex $eminfo 10] 
##$$##set current [lindex $eminfo 11] 
##$$##set emlimit [lindex $eminfo 12] 
##$$##set em [lindex $eminfo 13] 
set current [list [lindex $eminfo 11] [lindex $eminfo 12] [lindex $eminfo 13]]
set emlimit [list [lindex $eminfo 14] [lindex $eminfo 15] [lindex $eminfo 16]]
set em [list [lindex $eminfo 17] [lindex $eminfo 18] [lindex $eminfo 19]]
##$$##set topmid [lindex $eminfo 14] 
##$$##set botmid [lindex $eminfo 15] 
set topmid [lindex $eminfo 20] 
set botmid [lindex $eminfo 21] 
# Set defaults for top seg and bot seg
set topsegid1 "-"
set topsegid2 "-" 
set botsegid1 "-"
set botsegid2 "-" 
set tc 0
set bc 0
global viamodelarr

db eval "SELECT * FROM wiresegtable WHERE ws_segmentid GLOB '$topmid\_*'" {
	#puts "top## $ws_segmentid"
	if {((($ws_llx <= $cordx) && ($ws_urx >= $cordx)) && (($ws_dir == "l") || ($ws_dir == "r"))) || ((($ws_lly <= $cordy) && ($ws_ury >= $cordy)) && (($ws_dir == "u") || ($ws_dir == "d")))} {
#	puts "TOP = $ws_segmentid"
		incr tc
		if {$tc == 1} {set topsegid1 $ws_segmentid} elseif {$tc == 2} {set topsegid2 $ws_segmentid}
	}
}

db eval "SELECT * FROM wiresegtable WHERE ws_segmentid GLOB '$botmid\_*'" {
	#puts "bot## $ws_segmentid"
	if {((($ws_llx <= $cordx) && ($ws_urx >= $cordx)) && (($ws_dir == "l") || ($ws_dir == "r"))) || ((($ws_lly <= $cordy) && ($ws_ury >= $cordy)) && (($ws_dir == "u") || ($ws_dir == "d")))} {
#	puts "BOT = $ws_segmentid"
		incr bc
		if {$bc == 1} {set botsegid1 $ws_segmentid} elseif {$bc == 2} {set botsegid2 $ws_segmentid}
	}
}


if {[info exists viamodelarr($vianame)]} {
	set vmodel $viamodelarr($vianame)
	set topboxw [lindex [lindex $vmodel 0] 2]
	set topboxh [lindex [lindex $vmodel 0] 3]
	set viaboxw [lindex [lindex $vmodel 1] 2]
	set viaboxh [lindex [lindex $vmodel 1] 3]
	set botboxw [lindex [lindex $vmodel 2] 2]
	set botboxh [lindex [lindex $vmodel 2] 3]
	set topboxllx [expr $cordx - (double($topboxw)/2)]
	set topboxlly [expr $cordy - (double($topboxh)/2)]
	set topboxurx [expr $cordx + (double($topboxw)/2)]
	set topboxury [expr $cordy + (double($topboxh)/2)]
	set viaboxllx [expr $cordx - (double($viaboxw)/2)]
	set viaboxlly [expr $cordy - (double($viaboxh)/2)]
	set viaboxurx [expr $cordx + (double($viaboxw)/2)]
	set viaboxury [expr $cordy + (double($viaboxh)/2)]
	set botboxllx [expr $cordx - (double($botboxw)/2)]
	set botboxlly [expr $cordy - (double($botboxh)/2)]
	set botboxurx [expr $cordx + (double($botboxw)/2)]
	set botboxury [expr $cordy + (double($botboxh)/2)]
	set boxinfo [list $topboxllx $topboxlly $topboxurx $topboxury $viaboxllx $viaboxlly $viaboxurx $viaboxury $botboxllx $botboxlly $botboxurx $botboxury]
} else {
	set vmodel [get viamodel $vianame -detail_bbox]
	set viamodelarr($vianame) $vmodel
	set topboxw [lindex [lindex $vmodel 0] 2]
	set topboxh [lindex [lindex $vmodel 0] 3]
	set viaboxw [lindex [lindex $vmodel 1] 2]
	set viaboxh [lindex [lindex $vmodel 1] 3]
	set botboxw [lindex [lindex $vmodel 2] 2]
	set botboxh [lindex [lindex $vmodel 2] 3]
	set topboxllx [expr $cordx - (double($topboxw)/2)]
	set topboxlly [expr $cordy - (double($topboxh)/2)]
	set topboxurx [expr $cordx + (double($topboxw)/2)]
	set topboxury [expr $cordy + (double($topboxh)/2)]
	set viaboxllx [expr $cordx - (double($viaboxw)/2)]
	set viaboxlly [expr $cordy - (double($viaboxh)/2)]
	set viaboxurx [expr $cordx + (double($viaboxw)/2)]
	set viaboxury [expr $cordy + (double($viaboxh)/2)]
	set botboxllx [expr $cordx - (double($botboxw)/2)]
	set botboxlly [expr $cordy - (double($botboxh)/2)]
	set botboxurx [expr $cordx + (double($botboxw)/2)]
	set botboxury [expr $cordy + (double($botboxh)/2)]
	set boxinfo [list $topboxllx $topboxlly $topboxurx $topboxury $viaboxllx $viaboxlly $viaboxurx $viaboxury $botboxllx $botboxlly $botboxurx $botboxury]
}

#set boxinfo [list - - - - - - - - - - - -]
db eval {INSERT INTO viatable VALUES($id, $layer, $vianame, $net, $cordx, $cordy, $ncuts, $cutwidth, $cutheight, \
$resistance, $dir, $current, $emlimit, $em, $topmid, $botmid, $topsegid1, $topsegid2, $botsegid1, $botsegid2, $boxinfo)}
}



proc Rect { args } {
set argv [split $args]
set argc [llength $argv]
set color white
set width 3
set unit 1
for {set j 0} {$j < $argc} {incr j 1} {
        if {[regexp {\-box} [lindex $argv $j]]} {
                set llx [lindex $argv [expr $j + 1]]
                set lly [lindex $argv [expr $j + 2]]
                set urx [lindex $argv [expr $j + 3]]
                set ury [lindex $argv [expr $j + 4]]
        } elseif  {[regexp {\-color} [lindex $argv $j]]} {
                set color [lindex $argv [expr $j + 1]]
        } elseif  {[regexp {\-width} [lindex $argv $j]]} {
                set width [lindex $argv [expr $j + 1]]
        } elseif  {[regexp {\-unit} [lindex $argv $j]]} {
                set unit [lindex $argv [expr $j + 1]]
        }
}
                                                                                                                                                            
set llx [expr $llx / $unit]
set lly [expr $lly / $unit]
set urx [expr $urx / $unit]
set ury [expr $ury / $unit]
                                                                                                                                                            
plot line -position $llx $lly $urx $lly -color $color -width $width
plot line -position $urx $lly $urx $ury -color $color -width $width
plot line -position $urx $ury $llx $ury -color $color -width $width
plot line -position $llx $ury $llx $lly -color $color -width $width
}; ### end of proc #Rect



proc min {a b} {
if {$a <= $b} {         return $a
} else {
        return $b
}
}
                                                                                                                                                            
proc max {a b} { if {$a >= $b} {
        return $a
} else {
        return $b
}
}


proc findintersect {winllx winlly winurx winury ws_llx ws_lly ws_urx ws_ury ws_dir} {
set intersects 0
if {$ws_dir == "l" || $ws_dir == "r"} {
	if {($ws_llx < $winllx) && ($winllx < $ws_urx)} {
		set intersects 1
		set centx $winllx
		set centy $ws_lly
		set rearx $ws_urx
		set reary $ws_ury
		set scalingfactor [expr (double($rearx) - $centx) / ($ws_urx - $ws_llx)]
		set retlist [list $centx $centy $rearx $reary $scalingfactor]
	} 
	if {($ws_llx < $winurx) && ($winurx < $ws_urx)} {
		set intersects 1
		set centx $winurx
		set centy $ws_lly
		set rearx $ws_llx
		set reary $ws_lly
		set scalingfactor [expr (double($centx) - $rearx) / ($ws_urx - $ws_llx)]
		set retlist [list $rearx $reary $centx $centy $scalingfactor]
	}
	if {($ws_llx < $winllx) && ($winurx < $ws_urx)} {
		set intersects 1
		set centx $winllx
		set centy $ws_lly
		set rearx $winurx
		set reary $ws_ury
		set scalingfactor [expr (double($rearx) - $centx) / ($ws_urx - $ws_llx)]
		set  retlist [list $centx $centy $rearx $reary $scalingfactor]
	}
} elseif {$ws_dir == "u" || $ws_dir == "d"} {
	if {($ws_lly < $winlly) && ($winlly < $ws_ury)} {
		set intersects 1
		set centx $ws_llx
		set centy $winlly
		set rearx $ws_urx
		set reary $ws_ury
		set scalingfactor [expr (double($reary) - $centy) / ($ws_ury - $ws_lly)]
		set retlist [list $centx $centy $rearx $reary $scalingfactor]
	} 
	if {($ws_lly < $winury) && ($winury < $ws_ury)} {
		set intersects 1
		set centx $ws_llx
		set centy $winury
		set rearx $ws_llx
		set reary $ws_lly
		set scalingfactor [expr (double($centy) - $reary) / ($ws_ury - $ws_lly)]
		set retlist [list $rearx $reary $centx $centy $scalingfactor]
	}
	if {($ws_lly < $winlly) && ($winury < $ws_ury)} {
		set intersects 1
		set centx $ws_llx
		set centy $winlly
		set rearx $ws_urx
		set reary $winury
		set scalingfactor [expr (double($reary) - $centy) / ($ws_ury - $ws_lly)]
	        set retlist [list $centx $centy $rearx $reary $scalingfactor]	
	}
}
if {$intersects == 1} {
	return  $retlist 
}
} ; ### End of proc findintersect



set file [glob -nocomplain -directory . .apache/.atclQuerySigEMDB.db]
if {[file exists $file]} {
	file delete -force $file
} 

