# $Revision: 2.4 $

#########################################################################
#
# Ansys
#
# Copyright 2002-2016 Ansys, Inc.
# All rights reserved.
#
# Revision history
#
# - Created by Jeonghoon Kook 04/21/16 (last modified: 06/30/16)
# - Initial version 0.1. create ports on output pins
#           version 0.2. generate per-cell dspf
#           version 0.3. read ttemcheck.conf
#           version 0.4. debug info per cell, merge rectangles
#           version 0.4.1 bug fixed
#           version 0.5  dpsf_only
#           version 0.5.1 bug fixed
#
#########################################################################

proc	atclMakePort_manpage {}	{
	puts	"
SYNOPSIS
	atclMakrPort.tcl finds port location with specified pitch on output signal pins in lef,
	and print the port x/y positions as *|P syntax in dspf file for ttemcheck.

USAGE
	atclMakePort	\[arguments\]

	arguments:
	-lef	<lef_files>
	-layer	<layer_names>	(optional)
	    lef pin layer name
	    default: *
	    (ex) -layer M1 M2
	-pitch	<pitch_in_um>	(optional)
	    distance between ports to be created
	    default: 0.5
	    (ex) -pitch 0.1
	-list	<cell_list_file>	(optional)
	    default: all cells in lef
	-dspf	<dspf_files>	(optional)
	    default: if not specified, port x/y positions are printed in <output_dir>/<cell>.dspf
	    if specified, modified dspf files are generated as <output_dir>/<cell>.dspf, where port x/y locations are appended
	-o	<output_dir>	(optional)
	    output directory name, where modified dspf files to be generated
	    default: ./DSPF
	-help
	    usage help

	-config <ttemcheck.config>
	    # valid keywords in ttemcheck.config
		DSPF_NETLIST	{ }				# required
		LEF_FILES	{ }				# required
		STD_CELL_PRE_PROCESSING	{
			OUTPUT_PORT_LAYER	<layer_names>	# optional, default: *
			OUTPUT_PORT_PITCH	<pitch_in_um>	# optional, default: 0.5
			DSPF_OUTPUT_DIRECTORY	<output_dir>	# optional, default: ./DSPF
		}
"
}
proc	atclMakePort_help {}	{
	puts	"usage1: atclMakePort
	-config <ttemcheck.config>
	?-list <cell_list_file>?\n
usage2: atclMakePort
	-lef <lef_files>
	?-layer <layer_names>?
	?-pitch <pitch_in_um>?
	?-list <cell_list_file>?
	?-dspf <dspf_files>?
	?-o <output_dir>?
"
}
proc	atclMakePort { args }	{
	set argv [split $args]	
	if	{ [llength $argv] == 0 }	{ atclMakePort_help; return }
	set useList 0; set useDspf 0; set useOutDir 0; set useDebug 0; set useConfig 0; set useDspfOnly 0
	set cState option; set pState na
	foreach arg $argv	{
		switch	$cState	{
			option	{
				switch -- $arg	{
					-lef		{ set cState flag_lef }
					-config		{ set cState flag_config; set useConfig 1 }
					-layer		{ set cState flag_layer }
					-pitch 		{ set cState flag_pitch }
					-list		{ set cState flag_list; set useList 1 }
					-dspf		{ set cState flag_dspf; set useDspf 1 }
					-dspf_only	{ set pState na; set useDspfOnly 1 }
					-o		{ set cState flag_outdir; set useOutDir 1 }
					-debug		{ set pState na; set useDebug 1 }
					-h		{ atclMakePort_manpage; return }
					-help		{ atclMakePort_manpage; return }
					default	{
						if	{ [regexp {^-} $arg] }	{ error "+ERROR+ unknown option: $arg" }
						if	{ ![string compare $pState flag_layer] }	{
							set layerM($arg) 1
						}	else	{ error	"+ERROR+ unknown option: $arg" }
					}
				}
			}
			flag_lef	{ set lefFileM([atclMakePort_getabspath $arg]) 1; set pState na; set cState option }
			flag_config	{ set configFile $arg; set pState na; set cState option }
			flag_layer	{ set layerM($arg) 1; set pState $cState; set cState option }
			flag_pitch	{ set pitch $arg; set pState $cState; set cState option }
			flag_list	{ set listFile $arg; set pState $cState; set cState option }
			flag_dspf	{ set dspfFileM([atclMakePort_getabspath $arg]) 1; set pState $cState; set cState option }
			flag_outdir	{ set outDir $arg; set pState $cState; set cState option }
			default		{ error "+ERROR+ internal error: $cState" }
		}
	}
	if	{ [regexp {^flag} $cState] }	{ error "+ERROR+ missing required option(s) or value(s)" }
	if	{ $useConfig }	{
		set rstL [atclMakePort_readConfig $configFile $useDspfOnly]
		set lefFileL [lindex $rstL 0]; set dspfFileL [lindex $rstL 1]
		set layerL [lindex $rstL 2]; set pitch [lindex $rstL 3]; set outDir [lindex $rstL 4]
		set useDebug [lindex $rstL 5]
		foreach layer $layerL	{ set layerM($layer) 1 }
		set useDspf 1
	}	else	{
		if	{ ![info exists lefFile] } { error "+ERROR+ missing option: -lef <lef_file>" }
		if	{ ![info exists layerM] } { error "+ERROR+ missing option: -layer <layer_names>" }
		if	{ ![info exists pitch] } { error "+ERROR+ missing option: -pitch <pitch_in_um>" }
		set lefFileL [lsort [array names lefFileM]]
		set dspfFileL [lsort [array names dspfFileM]]
		if	{ !$useOutDir }	{ set outDir {DSPF} }
	}
	set pitch [format %f $pitch]
	set outDir [atclMakePort_getabspath $outDir]
	file mkdir $outDir

# read LIST
	if	{ $useList }	{
		if	{ [catch { open $listFile r } IN] }	{ error "+ERROR+ can't open a file: $listFile" }
		puts	"info: reading $listFile"; puts -nonewline ""
		while	{[gets $IN line] >= 0}	{
			regexp {(.*?)#} $line match line
			if	{ ![regexp {\S} $line] }	{ continue }
			regsub {^\s+} $line {} line; regsub {\s+$} $line {} line
			set lstM($line) 1
		}
		close	$IN
		set t [llength [array names lstM]]
		puts	[format "info: %d cell(s) found" $t]
	}
# read LEF
	foreach lefFile $lefFileL	{
		if	{ [catch { open $lefFile r } IN] }	{ error "+ERROR+ can't open a file: $lefFile" }
		puts	"info: reading $lefFile"; puts -nonewline ""
		set inFlag 0
		while	{[gets $IN line] >= 0}	{
			if	{ $inFlag == 0 }	{
				if	{ [regexp {^\s*END\s+LIBRARY} $line] }	{ break }
				if	{ [regexp {^\s*MACRO\s+(\S+)} $line match cellS] }	{
					if	{ $useList && ![info exists lstM($cellS)] }	{ continue }
					set inFlag 1
				}	elseif	{ [regexp {^\s*PROPERTYDEFINITIONS} $line] }	{
					set inFlag -1
				}
			}	elseif	{ $inFlag == 1 }	{
				if	{ [regexp {^\s*END\s+(\S+)} $line match cellE] }	{
					if	{ $cellS ne $cellE }	{
						error "+ERROR+ internal error while reading LEF ($cellS != $cellE)?"
					}
					set inFlag 0
				}	elseif	{ [regexp {^\s*PIN\s+(\S+)} $line match pinS] }	{
					set inFlag 2; set layer {__NA__}; set use {NOUSE}; set dir {NODIR}
				}
			}	elseif	{ $inFlag == 2 }	{
				if	{ [regexp {^\s*END\s+(\S+)} $line match pinE] }	{
					if	{ $pinS ne $pinE }	{
						error "+ERROR+ internal error while reading LEF ($pinS != $pinE)?"
					}
					set inFlag 1
				}	elseif	{ [regexp {^\s*USE\s+(\S+)} $line match use] }	{
					set use [string toupper $use]				
				}	elseif	{ [regexp {^\s*DIRECTION\s+(\S+)} $line match dir] }	{
					set dir [string toupper $dir]				
				}	elseif	{ [regexp {^\s*LAYER\s+(\S+)} $line match layer] }	{
					set layer [string toupper $layer]				
				}	elseif	{ [regexp {^\s*RECT} $line] }	{
					set fLine $line
					if	{ ![regexp {;} $fLine] }	{
						while	{[gets $IN line] >= 0}	{
							append fLine $line
							if	{ [regexp {;} $fLine] }	{ break }
						}
					}
					if	{ $dir ne {OUTPUT} } { continue }
					if	{ $use ne {SIGNAL} } { continue }
					if	{ ![info exists layerM(*)] && ![info exists layerM($layer)] } { continue }
					puts	"info: found \[$cellS/$pinS ($layer)\] (signal/output/rect)"
					regsub {^\s*RECT\s+(MASK\s+\S+)?} $fLine {} line
					regsub -all {(\s+|;)} $line { } line
					set line [string trim $line]
					set xyL [split $line]
					if	{ [llength $xyL] != 4 }	{
						error "+ERROR+ syntax error in LEF\n->$fLine";
					}
					set cellM($cellS) 0
					lappend lefRectM($cellS,$pinS) $xyL
				}	elseif	{ [regexp {^\s*POLYGON} $line] }	{
					set fLine $line
					if	{ ![regexp {;} $fLine] }	{
						while	{[gets $IN line] >= 0}	{
							append fLine $line
							if	{ [regexp {;} $fLine] }	{ break }
						}
					}
					if	{ $dir ne {OUTPUT} } { continue }
					if	{ $use ne {SIGNAL} } { continue }
					if	{ ![info exists layerM(*)] && ![info exists layerM($layer)] } { continue }
					puts	"info: found \[$cellS/$pinS ($layer)\] (signal/output/polygon)"
					regsub {^\s*POLYGON\s+(MASK\s+\S+)?} $fLine {} line
					regsub -all {(\s+|;)} $line { } line
					set line [string trim $line]
					set xyL [split $line]
					if	{ [llength $xyL] < 6 || [expr [llength $xyL] % 2] }	{
						error "+ERROR+ syntax error in LEF\n->$fLine";
					}
					set cellM($cellS) 0
					lappend lefPolyM($cellS,$pinS) $xyL
				}
			}	elseif	{ $inFlag == -1 }	{
				if	{ [regexp {^\s*END\s+PROPERTYDEFINITIONS} $line] }	{ set inFlag 0 }
			}
		}
		close	$IN
	}

	if	{ !$useDspfOnly && ![info exists cellM] }	{ error "+ERROR+ no data found" }

	foreach cell [array names cellM]	{
		puts	"info: processing \[$cell\]"
		set cellLog "$outDir/$cell.log"
		file delete -force $cellLog
		file delete -force "$outDir/$cell.poly_in.tcl"
		file delete -force "$outDir/$cell.poly_out.tcl"
		file delete -force "$outDir/$cell.poly_rect.tcl"
		file delete -force "$outDir/$cell.rect.tcl"
		file delete -force "$outDir/$cell.port.tcl"
		if	{ [catch { open $cellLog a } CELLLOG] }	{ error "+ERROR+ can't create a file: $cellLog" }
		puts	$CELLLOG	"# CELL: $cell"
		close	$CELLLOG
# partition polygons
		foreach pin [array names lefPolyM $cell,*]	{
			regexp {\S+,(\S+)} $pin match pin
			puts	"info: partitioning polygon \[$pin\]"
			if	{ [catch { open $cellLog a } CELLLOG] }	{ error "+ERROR+ can't create a file: $cellLog" }
			puts	$CELLLOG	"\n  POLY PIN: $pin"
			close	$CELLLOG
			foreach polyL $lefPolyM($cell,$pin)	{
				set polyDir [atclMakePort_getorientation $cellLog $polyL]
				set tLL [atclMakePort_makevertices $cellLog $polyL]
				set vL [lindex $tLL 0]; set polyNL [lindex $tLL 1]
				set rectLL [atclMakePort_makerects $cellLog $polyDir $vL $polyNL]
				foreach rectL $rectLL	{
					lappend lefRectM($cell,$pin) $rectL
				}
			}
		}
		foreach pin [array names lefRectM $cell,*]	{
			regexp {\S+,(\S+)} $pin match pin
			puts	"info: merging rects \[$pin\]"
			set rectLL [atclMakePort_mergerects $cellLog $lefRectM($cell,$pin)]
			puts	"info: creating ports \[$pin\]"
			if	{ [catch { open $cellLog a } CELLLOG] }	{ error "+ERROR+ can't create a file: $cellLog" }
			puts	$CELLLOG	"\n  PIN: $pin"
			close	$CELLLOG
			set portCML($cell,$pin) [atclMakePort_makeports $cellLog $pitch $rectLL]
			set nP [llength $portCML($cell,$pin)]
			puts	[format "info: %d port(s) created" $nP]
		}
	}

	if	{ $useDspf }	{
		if	{ $useDspfOnly }	{
			foreach dspfFile $dspfFileL	{
				if	{ [catch { open $dspfFile r } INFILE] }	{ error "+ERROR+ can't open a file: $dspfFile" }
				set dspfHeaderL {}
				while	{[gets $INFILE line] >= 0}	{
					if	{ [regexp -nocase {^\s*\.subckt\s+\S+} $line] }	{ break }
					lappend dspfHeaderL $line
				}
				close	$INFILE
		
				if	{ [catch { open $dspfFile r } INFILE] }	{ error "+ERROR+ can't open a file: $dspfFile" }
				while	{[gets $INFILE line] >= 0}	{
					if	{ ![regexp -nocase {^\s*\.subckt\s+(\S+)} $line match cell] }	{ continue }
					if	{ $useList && [info exists lstM([string tolower $cell])] }	{
						set cell [string tolower $cell]
					}	elseif	{ $useList && [info exists lstM([string toupper $cell])] }	{
						set cell [string toupper $cell]
					}	elseif	{ $useList }	{ continue }
					set outFile "$outDir/$cell.dspf"
					if	{ [catch { open $outFile w } OUTFILE] }	{ error "+ERROR+ can't create a file: $outFile" }
					puts	"info: generating $outFile"
					foreach hLine $dspfHeaderL	{
						puts	$OUTFILE	$hLine
					}
					puts	$OUTFILE	$line
					while	{[gets $INFILE line] >= 0}	{
						puts	$OUTFILE	$line
						if	{ [regexp -nocase {^\s*\.ends} $line] }	{ break }
					}
					close	$OUTFILE
				}
				close	$INFILE
			}
		}	else	{
			foreach dspfFile $dspfFileL	{
				if	{ [catch { open $dspfFile r } INFILE] }	{ error "+ERROR+ can't open a file: $dspfFile" }
				set dspfHeaderL {}
				while	{[gets $INFILE line] >= 0}	{
					if	{ [regexp -nocase {^\s*\.subckt\s+\S+} $line] }	{ break }
					lappend dspfHeaderL $line
				}
				close	$INFILE
		
				if	{ [catch { open $dspfFile r } INFILE] }	{ error "+ERROR+ can't open a file: $dspfFile" }
				while	{[gets $INFILE line] >= 0}	{
					if	{ ![regexp -nocase {^\s*\.subckt\s+(\S+)} $line match cell] }	{ continue }
					if	{ [info exists cellM([string tolower $cell])] }	{
						set cell [string tolower $cell]
					}	elseif	{ [info exists cellM([string toupper $cell])] }	{
						set cell [string toupper $cell]
					}	else	{ continue }
# inside subckt
					set outFile "$outDir/$cell.dspf"
					if	{ [catch { open $outFile w } OUTFILE] }	{ error "+ERROR+ can't create a file: $outFile" }
					puts	"info: generating $outFile"
					foreach hLine $dspfHeaderL	{
						puts	$OUTFILE	$hLine
					}
					puts	$OUTFILE	$line
					set pin {__NA__}
					while	{[gets $INFILE line] >= 0}	{
						if	{ [regexp -nocase {^\s*\.ends} $line] }	{
							puts	$OUTFILE	$line
							break
						}
						if	{ [regexp -nocase {^\s*\*\|NET\s+(\S+)} $line match pin] }	{
							puts	$OUTFILE	$line
							if	{ [info exists portCML([string tolower "$cell,$pin"])] }	{
								set pin [string tolower $pin]
							}	elseif	{ [info exists portCML([string toupper "$cell,$pin"])] }	{
								set pin [string toupper $pin]
							}	else	{ continue }
							set id 0
							foreach portL $portCML($cell,$pin)	{
								set x [lindex $portL 0]; set y [lindex $portL 1]
								puts	$OUTFILE	[format "*|P (%s_ads_p%d O 0 %.4f %.4f)" $pin $id $x $y]
								incr id
							}
							continue
						}
						if	{ [regexp -nocase {^\s*\*\|P\s+} $line] && [info exists portCML($cell,$pin)] }	{ continue }
						puts	$OUTFILE	$line
					}
					close	$OUTFILE
					set cellM($cell) 1
				}
				close	$INFILE
			}
		}
	}
	foreach cell [array names cellM]	{
		if	{ $cellM($cell) }	{ continue }
		set outFile "$outDir/$cell.dspf"
		if	{ [catch { open $outFile w } OUTFILE] }	{ error "+ERROR+ can't create a file: $outFile" }
		puts	"info: generating $outFile"
		puts	$OUTFILE	".SUBCKT $cell"
		foreach pin [array names portCML $cell,*]	{
			regexp {\S+,(\S+)} $pin match pin
			puts	$OUTFILE	"\n*|NET $pin 0"
			set id 0
			foreach portL $portCML($cell,$pin)	{
				set x [lindex $portL 0]; set y [lindex $portL 1]
				puts	$OUTFILE	[format "*|P (%s_ads_p%d O 0 %.4f %.4f)" $pin $id $x $y]
				incr id
			}
		}
		puts	$OUTFILE	"\n.ENDS $cell"
		close	$OUTFILE
	}
	puts	"done.\n"
}
proc	atclMakePort_readConfig { configFile useDspfOnly }	{
	set pitch 0.5; set layerL {*}
	set outDir {DSPF}; set debug 0
	if	{ [catch { open $configFile r } IN] }	{ error "+ERROR+ can't open a file: $configFile" }
	puts	"info: reading $configFile"; puts -nonewline ""
	while	{[gets $IN line] >= 0}	{
		regexp {(.*?)#} $line match line
		if	{ ![regexp {\S} $line] }	{ continue }
		regsub {^\s+} $line {} line; regsub {\s+$} $line {} line
		if	{ [regexp {^LEF_FILES} $line] }	{
			set lineBuf "$line\n"
			if	{ ![regexp {\}} $lineBuf] }	{
				while	{[gets $IN line] >= 0}	{
					regexp {(.*?)#} $line match line
					if	{ ![regexp {\S} $line] }	{ continue }
					regsub {^\s+} $line {} line; regsub {\s+$} $line {} line
					append lineBuf "$line\n"
					if	{ [regexp {\}} $line] }	{ break }
				}
			}
			if	{ ![regexp {LEF_FILES\s*\{\s*(.*)\s*\}} $lineBuf match lineBuf] }	{
				error	"+ERROR+ syntax error in LEF_FILES"
			}
			set tL [regexp -all -inline {\S+} $lineBuf]
			foreach t $tL	{ set lefFileM([atclMakePort_getabspath $t]) 1 }
			set lefFileL [lsort [array names lefFileM]]
			puts	[format "info: %d LEF file(s) found" [llength $lefFileL]]
		}	elseif	{ [regexp {^DSPF_NETLIST$} $line] || [regexp {^DSPF_NETLIST\s*\{} $line] }	{
			set lineBuf "$line\n"
			if	{ ![regexp {\}} $lineBuf] }	{
				while	{[gets $IN line] >= 0}	{
					regexp {(.*?)#} $line match line
					if	{ ![regexp {\S} $line] }	{ continue }
					regsub {^\s+} $line {} line; regsub {\s+$} $line {} line
					append lineBuf "$line\n"
					if	{ [regexp {\}} $line] }	{ break }
				}
			}
			if	{ ![regexp {DSPF_NETLIST\s*\{\s*(.*)\s*\}} $lineBuf match lineBuf] }	{
				error	"+ERROR+ syntax error in DSPF_NETLIST"
			}
			set tempFileL [regexp -all -inline {\S+} $lineBuf]
			foreach dspfFile $tempFileL	{
				if	{ [regexp {\*} $dspfFile] }	{
					set tL [glob -nocomplain $dspfFile]
					foreach t $tL	{ set dspfFileM([atclMakePort_getabspath $t]) 1 }
				}	else	{ set dspfFileM([atclMakePort_getabspath $dspfFile]) 1 }
			}
			set dspfFileL [lsort [array names dspfFileM]]
			puts	[format "info: %d DSPF file(s) found" [llength $dspfFileL]]
		}	elseif	{ [regexp {^DSPF_NETLIST\s+(\S+)$} $line match dspfFile] }	{
			if	{ [regexp {\*} $dspfFile] }	{
				set tL [glob -nocomplain $dspfFile]
				foreach t $tL	{ set dspfFileM([atclMakePort_getabspath $t]) 1 }
			}	else	{ set dspfFileM([atclMakePort_getabspath $dspfFile]) 1 }
			set dspfFileL [lsort [array names dspfFileM]]
			puts	[format "info: %d DSPF file(s) found" [llength $dspfFileL]]
		}	elseif	{ [regexp {^STD_CELL_PRE_PROCESSING} $line] }	{
			set lineBuf "$line\n"
			if	{ ![regexp {\}} $lineBuf] }	{
				while	{[gets $IN line] >= 0}	{
					regexp {(.*?)#} $line match line
					if	{ ![regexp {\S} $line] }	{ continue }
					regsub {^\s+} $line {} line; regsub {\s+$} $line {} line
					append lineBuf "$line\n"
					if	{ [regexp {\}} $line] }	{ break }
				}
			}
			if	{ ![regexp {STD_CELL_PRE_PROCESSING\s*\{\s*(.*)\s*\}} $lineBuf match lineBuf] }	{
				error	"+ERROR+ syntax error in STD_CELL_PRE_PROCESSING"
			}
			foreach line [split $lineBuf "\n"]	{
				if	{ ![regexp {\S} $line] }	{ continue }
				if	{ [regexp {OUTPUT_PORT_PITCH\s+(\S+)$} $line match pitch] }	{
					puts	"info: OUTPUT_PORT_PITCH $pitch"
				}	elseif	{ [regexp {OUTPUT_PORT_LAYER\s+(.*)} $line match layer] }	{
					puts	"info: OUTPUT_PORT_LAYER $layer"
					set layerL [regexp -all -inline {\S+} $layer]
				}	elseif	{ [regexp {DSPF_OUTPUT_DIRECTORY\s+(\S+)$} $line match outDir] }	{
					puts	"info: DSPF_OUTPUT_DIRECTORY $outDir"
				}	elseif	{ [regexp {^DEBUG\s+(\S+)$} $line match debug] }	{
					if	{ $debug ne {0} }	{ set debug 1 }
				}	elseif	{ [regexp {^DSPF_ONLY\s+(.*)$} $line match v] }	{
					puts	"info: DSPF_ONLY $v"
					if	{ $v eq {1} }	{ set useDspfOnly 1 }
				}	else	{ error "+ERROR+ syntax error: $line" }
			}
		}
	}
	close	$IN
	if	{ $useDspfOnly }	{
		set lefFileL {}
	}	else	{
		if	{ ![info exists lefFileL] }	{ error "+ERROR+ LEF_FILES not found in $configFile" }
	}
	if	{ ![info exists dspfFileL] }	{ error "+ERROR+ DSPF_NETLIST not found in $configFile" }
	return	[list $lefFileL $dspfFileL $layerL $pitch $outDir $debug]
}
proc	atclMakePort_mergerects	{ logFile rectLL }	{
	set minX 1e99; set minY 1e99; set maxX -1e99; set maxY -1e99
	foreach rectL $rectLL	{
		set x1 [lindex $rectL 0]; set y1 [lindex $rectL 1]
		set x2 [lindex $rectL 2]; set y2 [lindex $rectL 3]
		if	{ $minX > $x1 }	{ set minX $x1 }
		if	{ $minY > $y1 }	{ set minY $y1 }
		if	{ $maxX < $x2 }	{ set maxX $x2 }
		if	{ $maxY < $y2 }	{ set maxY $y2 }
	}
	set dx [expr $maxX-$minY]; set dy [expr $maxY-$minY]
	if	{ $dx < $dy }	{	# vertical
		while	(1)	{
			set tLL [atclMakePort_mergerects_sub {H} $rectLL]
			set nC [lindex $tLL 0]; set rectLL [lindex $tLL 1]
			if	{ $nC == 0 }	{ break }
		}
		while	(1)	{
			set tLL [atclMakePort_mergerects_sub {V} $rectLL]
			set nC [lindex $tLL 0]; set rectLL [lindex $tLL 1]
			if	{ $nC == 0 }	{ break }
		}
	}	else	{		# horizontal
		while	(1)	{
			set tLL [atclMakePort_mergerects_sub {V} $rectLL]
			set nC [lindex $tLL 0]; set rectLL [lindex $tLL 1]
			if	{ $nC == 0 }	{ break }
		}
		while	(1)	{
			set tLL [atclMakePort_mergerects_sub {H} $rectLL]
			set nC [lindex $tLL 0]; set rectLL [lindex $tLL 1]
			if	{ $nC == 0 }	{ break }
		}
	}

	set debugFile "[file rootname $logFile].rect.tcl"
	if	{ [catch { open $debugFile a } DEBUG] }	{ error "+ERROR+ can't create a file: $debugFile" }
	puts	$DEBUG	""
	foreach rectL $rectLL	{
		set x1 [lindex $rectL 0]; set y1 [lindex $rectL 1]
		set x2 [lindex $rectL 2]; set y2 [lindex $rectL 3]
		puts	$DEBUG	"plot line -position $x1 $y1 $x2 $y1 -color white"
		puts	$DEBUG	"plot line -position $x1 $y2 $x2 $y2 -color white"
		puts	$DEBUG	"plot line -position $x1 $y1 $x1 $y2 -color white"
		puts	$DEBUG	"plot line -position $x2 $y1 $x2 $y2 -color white"
		puts	$DEBUG	"plot line -position $x1 $y1 $x2 $y2 -color white"
		puts	$DEBUG	"plot line -position $x1 $y2 $x2 $y1 -color white"
	}
	close	$DEBUG
	return	$rectLL
}
proc	atclMakePort_mergerects_sub	{ gD rectLL }	{
	set nC 0
	set l [llength $rectLL]
	for { set i 0 } { $i < $l } { incr i }	{
		if	{ [info exists invM($i)] }	{ continue }
		set rectiL [lindex $rectLL $i]
		set ix1 [lindex $rectiL 0]; set iy1 [lindex $rectiL 1]
		set ix2 [lindex $rectiL 2]; set iy2 [lindex $rectiL 3]
		set fFlag 0
		for { set j [expr $i+1] } { $j < $l } { incr j }	{
			if	{ [info exists invM($j)] }	{ continue }
			set rectjL [lindex $rectLL $j]
			set jx1 [lindex $rectjL 0]; set jy1 [lindex $rectjL 1]
			set jx2 [lindex $rectjL 2]; set jy2 [lindex $rectjL 3]
			if	{ $gD eq {V} }	{	# merge vertically
				if	{ $ix1 ne $jx1 || $ix2 ne $jx2 }	{ continue }
				if	{ $iy1 eq $jy2 || ($iy1 < $jy2 && $iy1 > $jy1) }	{
					set fFlag 1; set invM($j) 1
					set newRectL [list $jx1 $jy1 $ix2 $iy2]
					break
				}	elseif	{ $iy2 eq $jy1 || ($iy2 > $jy1 && $iy2 < $jy2) }	{
					set fFlag 1; set invM($j) 1
					set newRectL [list $ix1 $iy1 $jx2 $jy2]
					break
				}
			}	else	{		# merge horizontally
				if	{ $iy1 ne $jy1 || $iy2 ne $jy2 }	{ continue }
				if	{ $ix1 eq $jx2 || ($ix1 < $jx2 && $ix1 > $jx1) }	{
					set fFlag 1; set invM($j) 1
					set newRectL [list $jx1 $jy1 $ix2 $iy2]
					break
				}	elseif	{ $ix2 eq $jx1 || ($ix2 > $jx1 && $ix2 < $jx2) }	{
					set fFlag 1; set invM($j) 1
					set newRectL [list $ix1 $iy1 $jx2 $jy2]
					break
				}
			}
		}
		if	{ $fFlag }	{
			lappend newRectLL $newRectL
			incr nC
		}	else	{
			lappend newRectLL $rectiL
		}
	}
	return	[list $nC $newRectLL]
}
proc	atclMakePort_makeports	{ logFile pitch rectLL }	{
	foreach rectL $rectLL	{
		set x1 [lindex $rectL 0]; set y1 [lindex $rectL 1]
		set x2 [lindex $rectL 2]; set y2 [lindex $rectL 3]
		set dx [expr $x2-$x1]; set dy [expr $y2-$y1]
		set cx [format %.4f [expr 0.5*($x1+$x2)]]; set cy [format %.4f [expr 0.5*($y1+$y2)]]
		if	{ $dx < $dy }	{	# vertical
			set hW [expr 0.5*$dx]
			if	{ $dy < [expr $pitch + $dx] }	{
				lappend portLL [list $cx $cy]
			}	else	{
				set sy [format %.4f [expr $hW+$y1]]
				set ey [format %.4f [expr $y2-$hW]]
				set ny [expr int(($ey-$sy)/$pitch)]; incr ny
				set pdy [format %.4f [expr ($ey-$sy)/$ny]]
				lappend portLL [list $cx $sy]
				for	{ set i 1 } { $i < $ny } { incr i }	{
					set y [format %.4f [expr $sy+$i*$pdy]]
					lappend portLL [list $cx $y]
				}
				lappend portLL [list $cx $ey]
			}
		}	else	{		# horizontal
			set hW [expr 0.5*$dy]
			if	{ $dx < [expr $pitch + $dy] }	{
				lappend portLL [list $cx $cy]
			}	else	{
				set sx [format %.4f [expr $hW+$x1]]
				set ex [format %.4f [expr $x2-$hW]]
				set nx [expr int(($ex-$sx)/$pitch)]; incr nx
				set pdx [format %.4f [expr ($ex-$sx)/$nx]]
				lappend portLL [list $sx $cy]
				for	{ set i 1 } { $i < $nx } { incr i }	{
					set x [format %.4f [expr $sx+$i*$pdx]]
					lappend portLL [list $x $cy]
				}
				lappend portLL [list $ex $cy]
			}
		}
	}
	if	{ [catch { open $logFile a } LOG] }	{ error "+ERROR+ can't create a file: $logFile" }
	puts	$LOG	"    Rect:"
	foreach rectL $rectLL	{
		puts	$LOG	"\t$rectL"
	}
	puts	$LOG	"    Pitch: $pitch"
	puts	$LOG	"    Port:"
	foreach portL $portLL	{
		set x [lindex $portL 0]; set y [lindex $portL 1]
		puts	$LOG	"\t$portL"
	}
	close	$LOG

	set debugFile "[file rootname $logFile].port.tcl"
	if	{ [catch { open $debugFile a } DEBUG] }	{ error "+ERROR+ can't create a file: $debugFile" }
	puts	$DEBUG	""
	if	{ [info exists portLL] }	{
		foreach portL $portLL	{
			set x [lindex $portL 0]; set y [lindex $portL 1]
			puts	$DEBUG	"marker add -position $x $y -color white"
		}
	}
	if	{ [info exists rectLL] }	{
		foreach rectL $rectLL	{
			set x1 [lindex $rectL 0]; set y1 [lindex $rectL 1]
			set x2 [lindex $rectL 2]; set y2 [lindex $rectL 3]
			puts	$DEBUG	"plot line -position $x1 $y1 $x2 $y1 -color white"
			puts	$DEBUG	"plot line -position $x1 $y2 $x2 $y2 -color white"
			puts	$DEBUG	"plot line -position $x1 $y1 $x1 $y2 -color white"
			puts	$DEBUG	"plot line -position $x2 $y1 $x2 $y2 -color white"
		}
	}
	close	$DEBUG

	if	{ [info exists portLL] }	{
		return	$portLL
	}	else	{ return }
}
proc	atclMakePort_makerects { logFile d vL polyL }	{
	set l [llength $polyL]
	for	{ set i 0 } { $i < $l } { set i [expr $i+2] }	{
		set x [lindex $polyL $i]; set y [lindex $polyL [expr $i+1]]
		lappend xyLL [list $x $y]
	}
	set l [llength $xyLL]
	lappend xyLL [lindex $xyLL 0]
	for	{ set i 0 } { $i < $l } { incr i }	{
		set xy1L [lindex $xyLL $i]; set xy2L [lindex $xyLL [expr $i+1]]
		set x1 [lindex $xy1L 0]; set y1 [lindex $xy1L 1]
		set x2 [lindex $xy2L 0]; set y2 [lindex $xy2L 1]
		if	{ $y1 eq $y2 }	{
			if	{ [info exists lineDM($x2,$y1,$x1,$y2)] }	{
				puts	"info: line duplication found ($x2,$y1,$x1,$y2), ignored"
				unset lineDM($x2,$y1,$x1,$y2)
			}	else	{
				if	{ $x1 < $x2 }	{	# RIGHT
					set lineDM($x1,$y1,$x2,$y2) {R}
				}	else	{		# LEFT
					set lineDM($x1,$y1,$x2,$y2) {L}
				}
			}
		}	elseif	{ $x1 eq $x2 }	{
			if	{ [info exists lineDM($x1,$y2,$x2,$y1)] }	{
				puts	"info: line duplication found ($x1,$y2,$x2,$y1), ignored"
				unset lineDM($x1,$y2,$x2,$y1)
			}	else	{
				if	{ $y1 < $y2 }	{	# UP
					set lineDM($x1,$y1,$x2,$y2) {U}
				}	else	{		# DOWN
					set lineDM($x1,$y1,$x2,$y2) {D}
				}
			}
		}	else	{ error "+ERROR+ internal error in makeRects" }
	}
	foreach xy $vL	{
		regexp {(\S+),(\S+)} $xy match x y
		lappend xL $x; lappend yL $y; lappend vxyLL [list $x $y]
		lappend xMyL($x) $y; lappend yMxL($y) $x
	}
	foreach x $xL	{
		set xMyLU($x) [lsort -real -unique $xMyL($x)]
		set xMyLD($x) [lsort -real -unique -decreasing $xMyL($x)]
	}
	foreach y $yL	{
		set yMxLR($y) [lsort -real -unique $yMxL($y)]
		set yMxLL($y) [lsort -real -unique -decreasing $yMxL($y)]
	}
	if	{ $d eq {CCW} }	{
		foreach xyL $vxyLL	{
			set ox [lindex $xyL 0]; set oy [lindex $xyL 1]
			set x1 $ox; set y1 $oy
			# find x2,y1 point
			set fFlag 0
			foreach x $yMxLR($y1)	{
				if	{ $x > $x1 }	{
					set x2 $x; set fFlag 1; break
				}
			}
			if	{ $fFlag == 0 }	{ continue }
			# find x2,y2 point
			set fFlag 0
			foreach y $xMyLU($x2)	{
				if	{ $y > $y1 }	{ set y2 $y; set fFlag 1; break }
			}
			if	{ $fFlag == 0 }	{ continue }
			# find x1,y2 point
			set fFlag 0
			foreach x $yMxLL($y2)	{
				if	{ $x < $x2 }	{ set x1 $x; set fFlag 1; break }
			}
			if	{ $fFlag == 0 }	{ continue }
			# find x1,y1 point
			set fFlag 0
			foreach y $xMyLD($x1)	{
				if	{ $y < $y2 }	{ set y1 $y; set fFlag 1; break }
			}
			if	{ $fFlag == 0 }	{ continue }
			if	{ $x1 != $ox || $y1 != $oy }	{ continue }
			# checking if rect inside polygon
			set fFlag 0
			if	{ [info exists lineDM($x1,$y1,$x2,$y1)] }	{
				if	{ $lineDM($x1,$y1,$x2,$y1) ne {R} }	{ continue }
			}	elseif	{ [info exists lineDM($x2,$y1,$x1,$y1)] }	{
				if	{ $lineDM($x2,$y1,$x1,$y1) ne {R} }	{ continue }
			}	else	{ incr fFlag }
			if	{ [info exists lineDM($x2,$y1,$x2,$y2)] }	{
				if	{ $lineDM($x2,$y1,$x2,$y2) ne {U} }	{ continue }
			}	elseif	{ [info exists lineDM($x2,$y2,$x2,$y1)] }	{
				if	{ $lineDM($x2,$y2,$x2,$y1) ne {U} }	{ continue }
			}	else	{ incr fFlag }
			if	{ [info exists lineDM($x2,$y2,$x1,$y2)] }	{
				if	{ $lineDM($x2,$y2,$x1,$y2) ne {L} }	{ continue }
			}	elseif	{ [info exists lineDM($x1,$y2,$x2,$y2)] }	{
				if	{ $lineDM($x1,$y2,$x2,$y2) ne {L} }	{ continue }
			}	else	{ incr fFlag }
			if	{ [info exists lineDM($x1,$y2,$x1,$y1)] }	{
				if	{ $lineDM($x1,$y2,$x1,$y1) ne {D} }	{ continue }
			}	elseif	{ [info exists lineDM($x1,$y1,$x1,$y2)] }	{
				if	{ $lineDM($x1,$y1,$x1,$y2) ne {D} }	{ continue }
			}	else	{ incr fFlag }
			if	{ $fFlag == 4 }	{
				lappend cnRectLL [list $x1 $y1 $x2 $y2]
				continue
			}
			lappend rectLL [list $x1 $y1 $x2 $y2]
		}
	}	elseif	{ $d eq {CW} }	{
		foreach xyL $vxyLL	{
			set ox [lindex $xyL 0]; set oy [lindex $xyL 1]
			set x1 $ox; set y1 $oy
			# find x1,y2 point
			set fFlag 0
			foreach y $xMyLU($x1)	{
				if	{ $y > $y1 }	{ set y2 $y; set fFlag 1; break }
			}
			if	{ $fFlag == 0 }	{ continue }
			# find x2,y2 point
			set fFlag 0
			foreach x $yMxLR($y2)	{
				if	{ $x > $x1 }	{ set x2 $x; set fFlag 1; break }
			}
			if	{ $fFlag == 0 }	{ continue }
			# find x2,y1 point
			set fFlag 0
			foreach y $xMyLD($x2)	{
				if	{ $y < $y2 }	{ set y1 $y; set fFlag 1; break }
			}
			if	{ $fFlag == 0 }	{ continue }
			# find x1,y1 point
			set fFlag 0
			foreach x $yMxLL($y1)	{
				if	{ $x < $x2 }	{ set x1 $x; set fFlag 1; break }
			}
			if	{ $fFlag == 0 }	{ continue }
			if	{ $x1 != $ox || $y1 != $oy }	{ continue }
			# checking if rect inside polygon
			set fFlag 0
			if	{ [info exists lineDM($x1,$y1,$x2,$y1)] }	{
				if	{ $lineDM($x1,$y1,$x2,$y1) ne {L} }	{ continue }
			}	elseif	{ [info exists lineDM($x2,$y1,$x1,$y1)] }	{
				if	{ $lineDM($x2,$y1,$x1,$y1) ne {L} }	{ continue }
			}	else	{ incr fFlag }
			if	{ [info exists lineDM($x2,$y1,$x2,$y2)] }	{
				if	{ $lineDM($x2,$y1,$x2,$y2) ne {D} }	{ continue }
			}	elseif	{ [info exists lineDM($x2,$y2,$x2,$y1)] }	{
				if	{ $lineDM($x2,$y2,$x2,$y1) ne {D} }	{ continue }
			}	else	{ incr fFlag }
			if	{ [info exists lineDM($x2,$y2,$x1,$y2)] }	{
				if	{ $lineDM($x2,$y2,$x1,$y2) ne {R} }	{ continue }
			}	elseif	{ [info exists lineDM($x1,$y2,$x2,$y2)] }	{
				if	{ $lineDM($x1,$y2,$x2,$y2) ne {R} }	{ continue }
			}	else	{ incr fFlag }
			if	{ [info exists lineDM($x1,$y2,$x1,$y1)] }	{
				if	{ $lineDM($x1,$y2,$x1,$y1) ne {U} }	{ continue }
			}	elseif	{ [info exists lineDM($x1,$y1,$x1,$y2)] }	{
				if	{ $lineDM($x1,$y1,$x1,$y2) ne {U} }	{ continue }
			}	else	{ incr fFlag }
			if	{ $fFlag == 4 }	{
				lappend cnRectLL [list $x1 $y1 $x2 $y2]
				continue
			}
			lappend rectLL [list $x1 $y1 $x2 $y2]
		}
	}	else	{ error "+ERROR+ internal error in makeRects" }
	# find rects not touching poly but enclosed by valid rects
	if	{ [info exists cnRectLL] }	{
		foreach rectcL $cnRectLL	{
			set cx1 [lindex $rectcL 0]; set cy1 [lindex $rectcL 1]
			set cx2 [lindex $rectcL 2]; set cy2 [lindex $rectcL 3]
			foreach rectL $rectLL	{
				set x1 [lindex $rectL 0]; set y1 [lindex $rectL 1]
				set x2 [lindex $rectL 2]; set y2 [lindex $rectL 3]
				if	{ ($cx1 eq $x1 && $cx2 eq $x2) && ($cy1 eq $y2 || $cy2 eq $y1) }	{
					lappend rectLL $rectcL
					break
				}	elseif	{ ($cy1 eq $y1 && $cy2 eq $y2) && ($cx1 eq $x2 || $cx2 eq $x1) }	{
					lappend rectLL $rectcL
					break
				}
			}
		}
	}
	set debugFile "[file rootname $logFile].poly_rect.tcl"
	if	{ [catch { open $debugFile a } DEBUG] }	{ error "+ERROR+ can't create a file: $debugFile" }
	puts	$DEBUG	""
	foreach rectL $rectLL	{
		set x1 [lindex $rectL 0]; set y1 [lindex $rectL 1]
		set x2 [lindex $rectL 2]; set y2 [lindex $rectL 3]
		puts	$DEBUG	"plot line -position $x1 $y1 $x2 $y2 -color grey\nplot line -position $x1 $y2 $x2 $y1 -color grey"
		puts	$DEBUG	"plot line -position $x1 $y1 $x2 $y1 -color white\nplot line -position $x1 $y2 $x2 $y2 -color white"
		puts	$DEBUG	"plot line -position $x1 $y1 $x1 $y2 -color white\nplot line -position $x2 $y1 $x2 $y2 -color white"
	}
	close	$DEBUG
	return	$rectLL
}
proc	atclMakePort_makevertices { logFile polyL }	{
	set l [llength $polyL]
	for	{ set i 0 } { $i < $l } { set i [expr $i+2] }	{
		set x [format %.4f [lindex $polyL $i]]; set y [format %.4f [lindex $polyL [expr $i+1]]]
		lappend xL $x; lappend yL $y; lappend xyLL [list $x $y]
	}
# make XY combination
	foreach x $xL	{
		foreach y $yL	{
			lappend xMyL($x) $y; lappend yMxL($y) $x; set vM($x,$y) 1
		}
	}
	foreach x $xL	{
		set xMyLU($x) [lsort -real -unique $xMyL($x)]
		set xMyLD($x) [lsort -real -unique -decreasing $xMyL($x)]
	}
	foreach y $yL	{
		set yMxLR($y) [lsort -real -unique $yMxL($y)]
		set yMxLL($y) [lsort -real -unique -decreasing $yMxL($y)]
	}
	set l [llength $xyLL]
	lappend xyLL [lindex $xyLL 0]

	set debugFile "[file rootname $logFile].poly_in.tcl"
	if	{ [catch { open $debugFile a } DEBUG] }	{ error "+ERROR+ can't create a file: $debugFile" }
	puts	$DEBUG	""
	for	{ set i 0 } { $i < $l } { incr i }	{
		set xy1L [lindex $xyLL $i]; set xy2L [lindex $xyLL [expr $i+1]]
		set x1 [lindex $xy1L 0]; set y1 [lindex $xy1L 1]
		set x2 [lindex $xy2L 0]; set y2 [lindex $xy2L 1]
		puts	$DEBUG	"marker add -position $x1 $y1 -color yellow"
		puts	$DEBUG	"plot arrow -position $x1 $y1 $x2 $y2 -type middle -color grey"
	}
	close	$DEBUG

	for	{ set i 0 } { $i < $l } { incr i }	{
		set xy1L [lindex $xyLL $i]; set xy2L [lindex $xyLL [expr $i+1]]
		set x1 [lindex $xy1L 0]; set y1 [lindex $xy1L 1]
		set x2 [lindex $xy2L 0]; set y2 [lindex $xy2L 1]
		if	{ $y1 eq $y2 }	{
			lappend xyNLL [list $x1 $y1]
			if	{ $x1 < $x2 }	{	# RIGHT
				foreach x $yMxLR($y1)	{
					if	{ $x > $x1 && $x < $x2 }	{ lappend xyNLL [list $x $y1] }
				}
			}	else	{		# LEFT
				foreach x $yMxLL($y1)	{
					if	{ $x < $x1 && $x > $x2 }	{ lappend xyNLL [list $x $y1] }
				}
			}
		}	elseif	{ $x1 eq $x2 }	{
			lappend xyNLL [list $x1 $y1]
			if	{ $y1 < $y2 }	{	# UP
				foreach y $xMyLU($x1)	{
					if	{ $y > $y1 && $y < $y2 }	{ lappend xyNLL [list $x1 $y] }
				}
			}	else	{		# DOWN
				foreach y $xMyLD($x1)	{
					if	{ $y < $y1 && $y > $y2 }	{ lappend xyNLL [list $x1 $y] }
				}
			}
		}	else	{ error "+ERROR+ polygon not rectilinear\n->$x1 $y1 $x2 $y2" }
	}
	if	{ $y1 eq $y2 }	{
		lappend xyNLL [list $x2 $y1]
	}	elseif	{ $x1 eq $x2 }	{
		lappend xyNLL [list $x1 $y2]
	}	else	{ error "+ERROR+ polygon not rectilinear\n->$x1 $y1 $x2 $y2" }
	set l [expr [llength $xyNLL] - 1]
	for	{ set i 0 } { $i < $l } { incr i }	{
		set xy1L [lindex $xyNLL $i]
		set xy2L [lindex $xyNLL [expr $i+1]]
		set x1 [lindex $xy1L 0]; set y1 [lindex $xy1L 1]
		set x2 [lindex $xy2L 0]; set y2 [lindex $xy2L 1]
		lappend polyNL $x1; lappend polyNL $y1
	}
	set debugFile "[file rootname $logFile].poly_out.tcl"
	if	{ [catch { open $debugFile a } DEBUG] }	{ error "+ERROR+ can't create a file: $debugFile" }
	puts	$DEBUG	""
	for	{ set i 0 } { $i < $l } { incr i }	{
		set xy1L [lindex $xyNLL $i]
		set xy2L [lindex $xyNLL [expr $i+1]]
		set x1 [lindex $xy1L 0]; set y1 [lindex $xy1L 1]
		set x2 [lindex $xy2L 0]; set y2 [lindex $xy2L 1]
		puts	$DEBUG	"marker add -position $x1 $y1 -color yellow"
		puts	$DEBUG	"plot arrow -position $x1 $y1 $x2 $y2 -type middle -color grey"
	}
	close	$DEBUG
	return	[list [array names vM] $polyNL]
}
proc atclMakePort_getorientation { logFile polyL }	{
# find lower left
	set l [llength $polyL]
	set minX 1e99; set minY 1e99; set b 0
	for	{ set i 0 } { $i < $l } { set i [expr $i+2] }	{
		set x [lindex $polyL $i]; set y [lindex $polyL [expr $i+1]]
		if	{ $minX < $x }	{ continue }
		if	{ $y < $minY }	{ set minX $x; set minY $y; set b $i }
	}
	set a [expr $b-2]; set c [expr $b+2]
	if	{ $a < 0 }	{ set a [expr $a+$l] }
	if	{ $c >= $l }	{ set c [expr $c-$l] }
	set xa [lindex $polyL $a]; set ya [lindex $polyL [expr $a+1]]
	set xb [lindex $polyL $b]; set yb [lindex $polyL [expr $b+1]]
	set xc [lindex $polyL $c]; set yc [lindex $polyL [expr $c+1]]
	set d [expr ($xb*$yc+$xa*$yb+$ya*$xc)-($ya*$xb+$yb*$xc+$xa*$yc)]
	if	{ $d < 0 }	{
		set dir {CW}
	}	elseif	{ $d > 0 }	{
		set dir {CCW}
	}	else	{ error "+ERROR+ failed to determine orientation\n->$xa $ya, $xb $yb, $xc $yc" }
	if	{ [catch { open $logFile a } LOG] }	{ error "+ERROR+ can't create a file: $logFile" }
	puts	$LOG	"    Polygon: $polyL"
	puts	$LOG	[format "    LL Corner: (%.4f %.4f) (%.4f %.4f) (%.4f %.4f)" $xa $ya $xb $yb $xc $yc]
	puts	$LOG	[format "    Direction: %f" $d]
	puts	$LOG	"    Orientation: $dir"
	close	$LOG
	return	$dir
}
proc	atclMakePort_drawrect { rectLL }	{
	foreach rectL $rectLL	{
		set x1 [lindex $rectL 0]; set y1 [lindex $rectL 1]
		set x2 [lindex $rectL 2]; set y2 [lindex $rectL 3]
		plot line -position $x1 $y1 $x2 $y1 -color white
		plot line -position $x1 $y2 $x2 $y2 -color white
		plot line -position $x1 $y1 $x1 $y2 -color white
		plot line -position $x2 $y1 $x2 $y2 -color white
		plot line -position $x1 $y1 $x2 $y2 -color white
		plot line -position $x1 $y2 $x2 $y1 -color white
	}
}
proc	atclMakePort_getabspath	{ path }	{
	regsub {\/$} $path {} path
	if	{ ![regexp {^\/} $path] }	{
		set cPath [pwd]
		set lpath [file split $cPath]
		set lpath [lreplace $lpath 0 0]
		while	{ [regexp {\.\.\/} $path] }	{
			regsub {\.\.\/} $path {} path
			set lpath [lreplace $lpath end end]
		}
		set path "/[join $lpath /]/$path"
		while	{ [regexp {\/\.\/} $path] }	{
			regsub {\/\.\/} $path / path
		}
	}
	return	$path
}
