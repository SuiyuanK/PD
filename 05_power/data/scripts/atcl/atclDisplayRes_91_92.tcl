#########################################################################
#
# Apache Design Solutions, Inc.
#
# Copyright 2009 Apache Design Solutions, Inc.
# All rights reserved.
#
# File Name : atclDisplayRes_91_92.tcl
#
# Creation Date : Oct 12, 2009
#
# Created By : Devesh Nema (devesh@apache-da.com) 
#
# Revision history
#
# 	Last Modified : Mon 29 Apr 2013 01:11:24 PM PDT
#
#########################################################################
proc atclDisplayRes { args } {
regsub -all -- {[[:space:]]+} $args " " args
set argv [split $args]
set argc [llength $argv]
set version "9.2"

for {set j 0} {$j < $argc} {incr j 1} {
	if {[regexp {\-ver} [lindex $argv $j]]} {
		set version [lindex $argv [expr $j + 1]]
	}
}

if {$version == "9.2"} {
	for {set j 0} {$j < $argc} {incr j 1} {
		if  {[regexp {\-h} [lindex $argv $j]]} {
			atclDisplayResNX_help;return
		} elseif  {[regexp {\-m} [lindex $argv $j]]} {
			atclDisplayResNX_manpage;return
		}
	}
	atclDisplayResNX $args
} else {
	for {set j 0} {$j < $argc} {incr j 1} {
		if  {[regexp {\-h} [lindex $argv $j]]} {
			atclDisplayRes91_help;return
		} elseif  {[regexp {\-m} [lindex $argv $j]]} {
			atclDisplayRes91_manpage;return
		}
	}
	atclDisplayRes91 $args
}
}; ### End of proc atclDisplayRes


#$$$$$ NX $$$$##
proc atclDisplayResNX_manpage {} {
puts "
************************************************************************
SYNOPSIS
        Apache-AE TCL utility to display ESD check results
                                                                                                                                                            
USAGE

STEP 1: Setup the script

	atclDisplayRes -setup ?-esd_dir <esd dir path>?
	
	Where:
	-esd_dir <esd dir path> : Path to ESD results directory (Optional. Default: adsRpt/ESD)

STEP 2: Use other display options

#####################
OPTIONS FOR BUMP2BUMP
#####################

atclDisplayRes -type <BUMP2BUMP|B2B|bump2bump|b2b> -rule_name <esd rule name> -bump_pair <bump1_name bump2_name> ?-clamp <clamp_name>? ?-restype <loop|parallel>? ?-all_fail? ?-all_pass? ?-domain_pair <domain1_name domain2_name>? ?-relresmap \{minR maxR\}? ?-overlay? ?-h? ?-m?
                                                                                                                                                            
OPTIONS:
        -type <BUMP2BUMP|B2B|bump2bump|b2b> : Type of ESD check (Required) 
	-rule_name <esd rule name> : ESD rule name (Required)
        -bump_pair <bump1_name bump2_name> : Name of bump pair for which fly-lines have to be displayed (Required. Optional when -all_fail/-all_pass options are used. Order of bump pair names must match with ones in esd reports)
	-clamp <clamp_name> : Name of clamp instance associated with the bump pair, for which fly-lines have to be displayed (Optional. Default: Displays all bump-clamp-bump loop resistances for the bump pair chosen.)
	-restype <loop|parallel> : Displays loop or parallel resistance (Optional. Default: parallel)
        -all_fail : Displays ALL failing bump-bump parallel resistances (Optional. Precedes all other options)
        -all_pass : Displays ALL passing bump-bump parallel resistances (Optional. Precedes all other options)
	-domain_pair <domain1_name domain2_name> : Display ALL pass/fail parallel resistances between bumps belonging to the domain pair (Optional. Default: All Domains. Either -all_pass or -all_fail option MUST be specified)
	-relresmap \{minR maxR\} : Display color coded resistances (minR, maxR is Optional.)
	-overlay : To overlay current fly lines display with the previous display (Optional. Default: No overlay = Clears display in each new run)
        -h : Help
        -m : Man page

COLOR CODING FOR FLY LINES
	GREEN :  Resistance is below threshold
	RED   :  Resistance is above threshold
	WHITE :  Connecter line between Power and Ground pin locations on the clamp cell
	Power/Ground pin locations on clamp cell marked by white marker

EXAMPLES
	atclDisplayRes -type BUMP2BUMP -rule_name rule1 -bump_pair vdd1 vdd2
	atclDisplayRes -type BUMP2BUMP -rule_name rule1 -bump_pair vdd1 vdd2 -restype loop
	atclDisplayRes -type BUMP2BUMP -rule_name rule1 -bump_pair vdd1 vdd2 -restype loop -relresmap
	atclDisplayRes -type BUMP2BUMP -rule_name rule1 -bump_pair vdd1 vdd2 -clamp inst1
	atclDisplayRes -type BUMP2BUMP -rule_name rule1 -all_pass
	atclDisplayRes -type BUMP2BUMP -rule_name rule1 -all_fail
	atclDisplayRes -type BUMP2BUMP -rule_name rule1 -all_fail -domain_pair VDD VSS
	atclDisplayRes -type BUMP2BUMP -rule_name rule1 -all_fail -domain_pair VDD VSS -relresmap
	atclDisplayRes -type BUMP2BUMP -rule_name rule1 -all_fail -relresmap {0 0.8}


######################
OPTIONS FOR BUMP2CLAMP
######################

atclDisplayRes -type <BUMP2CLAMP|B2C|bump2clamp|b2c>  -rule_name <esd rule name> -bump <bump_name> ?-fail? ?-all_fail? ?-domain <domain_name>? ?-relresmap \{minR maxR\}? ?-overlay? ?-h? ?-m?

OPTIONS:
	-type <BUMP2CLAMP|B2C|bump2clamp|b2c> :  Type of ESD check (Required) 
	-rule_name <esd rule name> : ESD rule name (Required)
	-bump <bump_name> : Name of the bump for which the bump-to-clamp connections will be shown (Required. Optional when -all_fail is used)
	-fail : Displays all the failed resistance checks for the one bump specified (Optional. -bump is also required along with it)
	-all_fail : Displays ALL the failed resistance checks for all the bumps (Optional. Precedes all other options)
	-domain <domain_name> : Displays ALL fail resistances for all the bumps belonging to specified domain (Optional. Default: All domains. -all_fail option MUST be specified)
	-relresmap \{minR maxR\} : Display color coded resistances (minR, maxR is Optional. Doesn't work with -all_fail)
	-overlay : To overlay current fly lines display with the previous display (Optional. Default: No overlay = Clears display in each new run)
        -h : Help
        -m : Man page

COLOR CODING FOR FLY LINES
        GREEN :  Resistance is below threshold
        RED   :  Resistance is above threshold
	Power/Ground pin locations on clamp cell marked by white marker

EXAMPLES
	atclDisplayRes -type BUMP2CLAMP -rule_name rule1 -bump vdd1
	atclDisplayRes -type BUMP2CLAMP -rule_name rule1 -bump vdd1 -relresmap
	atclDisplayRes -type BUMP2CLAMP -rule_name rule1 -bump vdd1 -fail
	atclDisplayRes -type BUMP2CLAMP -rule_name rule1 -bump vdd1 -fail -relresmap
	atclDisplayRes -type BUMP2CLAMP -rule_name rule1 -bump vdd1 -fail -relresmap {0 0.8}
	atclDisplayRes -type BUMP2CLAMP -rule_name rule1 -all_fail
	atclDisplayRes -type BUMP2CLAMP -rule_name rule1 -all_fail -domain VDD


######################
OPTIONS FOR CLAMP2CLAMP
######################


atclDisplayRes -type <CLAMP2CLAMP|C2C|clamp2clamp|c2c> -rule_name <esd rule name> -clamp <clamp_name> ?-fail? ?-all_fail? ?-domain <domain_name>? ?-relresmap \{minR maxR\}? ?-overlay? ?-h? ?-m?

OPTIONS:
	-type <CLAMP2CLAMP|C2C|clamp2clamp|c2c> :  Type of ESD check (Required) 
	-rule_name <esd rule name> : ESD rule name (Required)
	-clamp <clamp_name> : Name of the clamp for which the clamp-to-clamp connections will be shown (Required. Optional when -all_fail is used)
	-fail : Displays all the failed resistance checks for the one clamp specified (Optional. -clamp is also required along with it)
	-all_fail : Displays ALL the failed resistance checks for all the clamps (Optional. Precedes all other options)
	-domain <domain_name> : Displays ALL fail resistances for all the clamps belonging to specified domain (Optional. Default: All domains. -all_fail option MUST be specified)
	-relresmap \{minR maxR\} : Display color coded resistances (minR, maxR is Optional. Doesn't work with -all_fail)
	-overlay : To overlay current fly lines display with the previous display (Optional. Default: No overlay = Clears display in each new run)
        -h : Help
        -m : Man page

COLOR CODING FOR FLY LINES
        GREEN :  Resistance is below threshold
        RED   :  Resistance is above threshold
	Power/Ground pin locations on clamp cell marked by white marker

EXAMPLES
	atclDisplayRes -type CLAMP2CLAMP -rule_name rule1 -clamp inst1
	atclDisplayRes -type CLAMP2CLAMP -rule_name rule1 -clamp inst1 -relresmap
	atclDisplayRes -type CLAMP2CLAMP -rule_name rule1 -clamp inst1 -fail
	atclDisplayRes -type CLAMP2CLAMP -rule_name rule1 -clamp inst1 -fail -relresmap  
	atclDisplayRes -type CLAMP2CLAMP -rule_name rule1 -clamp inst1 -fail -relresmap {0 0.8}
	atclDisplayRes -type CLAMP2CLAMP -rule_name rule1 -all_fail
	atclDisplayRes -type CLAMP2CLAMP -rule_name rule1 -all_fail -domain VDD


#####################
OPTIONS FOR BUMP2BUMP_MULTISTAGE
#####################

atclDisplayRes -type <BUMP2BUMP_MULTISTAGE|B2BM|bump2bump_multistage|b2bm> -rule_name <esd rule name> -bump_pair <bump1_name bump2_name> ?-clamp_pair <clamp1_name clamp2_name>? ?-restype <loop|parallel>? ?-all_fail? ?-all_pass? ?-domain_pair <domain1_name domain2_name>? ?-relresmap> \{minR maxR\}? ?-overlay? ?-h? ?-m?
                                                                                                                                                            
OPTIONS:
        -type <BUMP2BUMP_MULTISTAGE|B2BM|bump2bump_multistage|b2bm> : Type of ESD check (Required) 
	-rule_name <esd rule name> : ESD rule name (Required)
        -bump_pair <bump1_name bump2_name> : Name of bump pair for which fly-lines have to be displayed (Required. Optional when -all_fail/-all_pass options are used. Order of bump pair names must match with ones in esd reports)
	-clamp_pair <clamp1_name clamp2_name> : Name of clamp instances associated with the bump pair, for which fly-lines have to be displayed (Optional. Default: Displays all bump-clamp-clamp-bump loop resistances for the bump pair chosen. Order of clamp pair names must match with ones in esd reports. For single stage, the second clamp name is still required and must be same as the first clamp name)
	-restype <loop|parallel> : Displays loop or parallel resistance (Optional. Default: parallel)
        -all_fail : Displays ALL failing bump-bump parallel resistances (Optional. Precedes all other options)
        -all_pass : Displays ALL passing bump-bump parallel resistances (Optional. Precedes all other options)
	-domain_pair <domain1_name domain2_name> : Display ALL pass/fail parallel resistances between bumps belonging to the domain pair (Optional. Default: All Domains. Either -all_pass or -all_fail option MUST be specified)
	-relresmap \{minR maxR\} : Display color coded resistances (minR, maxR is Optional.)
	-overlay : To overlay current fly lines display with the previous display (Optional. Default: No overlay = Clears display in each new run)
        -h : Help
        -m : Man page

COLOR CODING FOR FLY LINES
	GREEN :  Resistance is below threshold
	RED   :  Resistance is above threshold
	WHITE :  Connecter line between Power and Ground pin locations on the clamp cell
	WHITE  :  Connecter line between the two clamps associated with the bump pair
	Power/Ground pin locations on clamp cell marked by white marker

EXAMPLES
	atclDisplayRes -type BUMP2BUMP_MULTISTAGE -rule_name rule1 -bump_pair vdd1 vdd2
	atclDisplayRes -type BUMP2BUMP_MULTISTAGE -rule_name rule1 -bump_pair vdd1 vdd2 -restype loop
	atclDisplayRes -type BUMP2BUMP_MULTISTAGE -rule_name rule1 -bump_pair vdd1 vdd2 -restype loop -relresmap
	atclDisplayRes -type BUMP2BUMP_MULTISTAGE -rule_name rule1 -bump_pair vdd1 vdd2 -clamp_pair inst1 inst2
	atclDisplayRes -type BUMP2BUMP_MULTISTAGE -rule_name rule1 -all_pass
	atclDisplayRes -type BUMP2BUMP_MULTISTAGE -rule_name rule1 -all_fail
	atclDisplayRes -type BUMP2BUMP_MULTISTAGE -rule_name rule1 -all_pass -domain_pair VDD VSS
	atclDisplayRes -type BUMP2BUMP_MULTISTAGE -rule_name rule1 -all_pass -domain_pair VDD VSS -relresmap
	atclDisplayRes -type BUMP2BUMP_MULTISTAGE -rule_name rule1 -all_fail -relresmap {0 0.8}

************************************************************************
NOTE: To use RedHawk/Totem 9.1 versions or below, please also use the option '-ver 9.1'
"
}

proc atclDisplayResNX_help {} {
puts "
STEP 1: Setup the script

atclDisplayRes -setup ?-esd_dir <esd dir path>?

STEP 2: Use other display options

OPTIONS FOR BUMP2BUMP
atclDisplayRes -type <BUMP2BUMP|B2B|bump2bump|b2b> -rule_name <esd rule name> -bump_pair <bump1_name bump2_name> ?-clamp <clamp_name>? ?-restype <loop|parallel>? ?-all_fail? ?-all_pass? ?-domain_pair <domain1_name domain2_name>? ?-relresmap \{minR maxR\}? ?-overlay? ?-h? ?-m?

OPTIONS FOR BUMP2CLAMP
atclDisplayRes -type <BUMP2CLAMP|B2C|bump2clamp|b2c>  -rule_name <esd rule name> -bump <bump_name> ?-fail? ?-all_fail? ?-domain <domain_name>? ?-relresmap \{minR maxR\}? ?-overlay? ?-h? ?-m?

OPTIONS FOR CLAMP2CLAMP
atclDisplayRes -type <CLAMP2CLAMP|C2C|clamp2clamp|c2c> -rule_name <esd rule name> -clamp <clamp_name> ?-fail? ?-all_fail? ?-domain <domain_name>? ?-relresmap \{minR maxR\}? ?-overlay? ?-h? ?-m?

OPTIONS FOR BUMP2BUMP_MULTISTAGE
atclDisplayRes -type <BUMP2BUMP_MULTISTAGE|B2BM|bump2bump_multistage|b2bm> -rule_name <esd rule name> -bump_pair <bump1_name bump2_name> ?-clamp_pair <clamp1_name clamp2_name>? ?-restype <loop|parallel>? ?-all_fail? ?-all_pass? ?-domain_pair <domain1_name domain2_name>? ?-relresmap> \{minR maxR\}? ?-overlay? ?-h? ?-m?

NOTE: To use RedHawk/Totem 9.1 versions or below, please also use the option '-ver 9.1'
"
}




proc atclDisplayResNX { args } {
regexp -all {\{(.*)\}} $args  match args
set argv [split $args]
set argc [llength $argv]
set setupflag 0
if {$argc == 0} {
	puts "Please refer to the usage"
	atclDisplayResNX_help; return
}


if {$argc == 1} {
	if {[regexp {\-h} [lindex $argv 0]]} {
                atclDisplayResNX_help;return
        } elseif  {[regexp {\-m} [lindex $argv 0]]} {
                atclDisplayResNX_manpage;return
	}
}

set rtype "NA"

for {set j 0} {$j < $argc} {incr j 1} {
	if {[regexp {\-type} [lindex $argv $j]]} {
		set rtype [lindex $argv [expr $j + 1]]
	} elseif {[regexp {\-rule_name} [lindex $argv $j]]} {
		set rule_name [lindex $argv [expr $j + 1]]
	} elseif {[regexp {\-setup} [lindex $argv $j]]} {
		set setupflag 1
	} elseif  {[regexp {\-h} [lindex $argv $j]]} {
		atclDisplayResNX_help;return
	} elseif  {[regexp {\-m} [lindex $argv $j]]} {
		atclDisplayResNX_manpage;return
	}
}

if {$setupflag == 1} {
	atclDisplayResNX_SETUP $args ; return
} else {

	if {![info exists rtype] || ![info exists rule_name]} {
		puts "Rule type and rule name needs to be specified"
		return
	}


	if {($rtype == "BUMP2BUMP") || ($rtype == "B2B") || ($rtype == "bump2bump") || ($rtype == "b2b")} {
		set rtype "BUMP2BUMP"
	}
	if {($rtype == "BUMP2CLAMP") || ($rtype == "B2C") || ($rtype == "bump2clamp") || ($rtype == "b2c")} {
		set rtype "BUMP2CLAMP"
	}
	if {($rtype == "CLAMP2CLAMP") || ($rtype == "C2C") || ($rtype == "clamp2clamp") || ($rtype == "c2c")} {
		set rtype "CLAMP2CLAMP"
	}
	if {($rtype == "BUMP2BUMP_MULTISTAGE") || ($rtype == "B2BM") || ($rtype == "bump2bump_multistage") || ($rtype == "b2bm")} {
		set rtype "BUMP2BUMP_MULTISTAGE"
	}


	if {$rtype == "NA"} {
		puts "Rule type not recognized. Please check the -type option"
		return
	} elseif {$rtype == "BUMP2BUMP"} {
		atclDisplayResNX_B2B $args; return
	} elseif {$rtype == "CLAMP2CLAMP"} {
		atclDisplayResNX_C2C $args; return
	} elseif {$rtype == "BUMP2CLAMP"} {
		atclDisplayResNX_B2C $args; return
	} elseif {$rtype == "BUMP2BUMP_MULTISTAGE"} {
		atclDisplayResNX_B2BM $args; return
	} 

}
}; ### End of wrapper atclDisplayResNX


proc atclDisplayResNX_SETUP { args } {
regexp -all {\{(.*)\}} $args  match args
set argv [split $args]
set argc [llength $argv]

set esd_dir "adsRpt/ESD"

for {set j 0} {$j < $argc} {incr j 1} {
	if {[regexp {\-esd_dir} [lindex $argv $j]]} {
		set esd_dir [lindex $argv [expr $j + 1]]
	} elseif  {[regexp {\-h} [lindex $argv $j]]} {
		atclDisplayResNX_help;return
	} elseif  {[regexp {\-m} [lindex $argv $j]]} {
		atclDisplayResNX_manpage;return
	}
}


set esd_pass_rpt "$esd_dir/esd_pass.rpt"
set esd_fail_rpt "$esd_dir/esd_fail.rpt"
set clampinforpt "$esd_dir/ClampInfo.rpt"

if {![file exists $esd_pass_rpt] || ![file exists $esd_fail_rpt] || ![file exists $clampinforpt]} {
	puts "Please check if the ESD result files were redirected to some other directory using -outdir option. If so, then -esd_dir option needs to be used"
	return
}


### Read Clamp Info file #############
if {![file exists $clampinforpt]} {
	puts "ClampInfo.rpt file $clampinforpt doesn't exist. Please check for file existense"
	return
}
global clampinstlocarr
set CLMPINFO [open $clampinforpt r]
while {[gets $CLMPINFO line] >= 0} {
if {[regexp {^#RULE} $line]} {
	regsub -all -- {[[:space:]]+} $line " " line
	set line [split $line]
	regexp -nocase {[a-z0-9_]+} [lindex $line 2] clampinforuletype
	set clampinforulename [lindex $line 1]
	while {![regexp {^#END } $line]} {
		gets $CLMPINFO line
		if {[regexp {^#PIN:} $line]} {
			gets $CLMPINFO line
			while {![regexp {\}} $line]} {
				if {[regexp {^INST} $line]} {
					regsub -all -- {[[:space:]]+} $line " " line
					set line [split $line]
					set clamp_name [lindex $line 1]
					set clamp_llx [lindex $line 2]
					set clamp_lly [lindex $line 3]
					set clamp_urx [lindex $line 4]
					set clamp_ury [lindex $line 5]
					#Rect -box $clamp_llx $clamp_lly $clamp_urx $clamp_ury
					set clampinstboxarr($clampinforuletype,$clampinforulename,$clamp_name) [list $clamp_llx $clamp_lly $clamp_urx $clamp_ury]
					gets $CLMPINFO line
					while {[regexp {^PIN} $line]} {
						regsub -all -- {[[:space:]]+} $line " " line
						set line [split $line]
						set locx [lindex $line 1]	
						set locy [lindex $line 2]	
						set locid [lindex $line 6]
						set clampinstlocarr($clampinforuletype,$clampinforulename,$clamp_name,$locid) [list $locx $locy]
						gets $CLMPINFO line
					}
					if {[regexp {^ESD_PIN_PAIR} $line]} {
						gets $CLMPINFO line
					}
				}
			}
		}
	}
}
}
close $CLMPINFO
### End of Read Clamp Info file ######



# Delete already existing DB and create a new one ##################
set file [glob -nocomplain -directory . .apache/.atclDisplayResNXDB.db]
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
sqlite3 db .apache/.atclDisplayResNXDB.db
## End of Delete already existing DB and create a new one ###########
	

db eval {CREATE TABLE B2BPASSTABLE(rulename text, bump1name text, bumpx1 float, bumpy1 float, bump1net text, bump2name text, bumpx2 float, bumpy2 float, bump2net text, passfail text, clampname text, clampx1 float, clampy1 float, clampx2 float, clampy2 float, loopr float)}
db eval {CREATE TABLE B2CPASSTABLE(rulename text, bump1name text, bumpx1 float, bumpy1 float, bump1net text, clampname text, clampx1 float, clampy1 float, res float)}
db eval {CREATE TABLE C2CPASSTABLE(rulename text, clamp1name text, clampx1 float, clampy1 float, clamp1net text, clamp2name text, clampx2 float, clampy2 float, res float)}
db eval {CREATE TABLE B2BMPASSTABLE(rulename text, bump1name text, bumpx1 float, bumpy1 float, bump1net text, bump2name text, bumpx2 float, bumpy2 float, bump2net text, passfail text, clamp1name text, clamp1x1 float, clamp1y1 float, clamp1x2 float, clamp1y2 float, clamp2name text, clamp2x1 float, clamp2y1 float, clamp2x2 float, clamp2y2 float, loopr float)}
db eval {CREATE TABLE B2BPARPASSTABLE(rulename text, bumpx1 float, bumpy1 float, bump1net text, bumpx2 float, bumpy2 float, bump2net text, parallelr float, bump1name text, bump2name text)}
db eval {CREATE TABLE B2BMAXPARPASSTABLE(rulename text, maxr float)}
db eval {CREATE TABLE B2BMPARPASSTABLE(rulename text, bumpx1 float, bumpy1 float, bump1net text, bumpx2 float, bumpy2 float, bump2net text, parallelr float,bump1name text, bump2name text)}
db eval {CREATE TABLE B2BMMAXPARPASSTABLE(rulename text, maxr float)}


db eval {CREATE TABLE B2BFAILTABLE(rulename text, bump1name text, bumpx1 float, bumpy1 float, bump1net text, bump2name text, bumpx2 float, bumpy2 float, bump2net text, passfail text, clampname text, clampx1 float, clampy1 float, clampx2 float, clampy2 float, loopr float)}
db eval {CREATE TABLE B2CFAILTABLE(rulename text, bump1name text, bumpx1 float, bumpy1 float, bump1net text, clampname text, clampx1 float, clampy1 float, res float)}
db eval {CREATE TABLE C2CFAILTABLE(rulename text, clamp1name text, clampx1 float, clampy1 float, clamp1net text, clamp2name text, clampx2 float, clampy2 float, res float)}
db eval {CREATE TABLE B2BMFAILTABLE(rulename text, bump1name text, bumpx1 float, bumpy1 float, bump1net text, bump2name text, bumpx2 float, bumpy2 float, bump2net text, passfail text, clamp1name text, clamp1x1 float, clamp1y1 float, clamp1x2 float, clamp1y2 float, clamp2name text, clamp2x1 float, clamp2y1 float, clamp2x2 float, clamp2y2 float, loopr float)}
db eval {CREATE TABLE B2BPARFAILTABLE(rulename text, bumpx1 float, bumpy1 float, bump1net text, bumpx2 float, bumpy2 float, bump2net text, parallelr float, bump1name text, bump2name text)}
db eval {CREATE TABLE B2BMAXPARFAILTABLE(rulename text, maxr float)}
db eval {CREATE TABLE B2BMPARFAILTABLE(rulename text, bumpx1 float, bumpy1 float, bump1net text, bumpx2 float, bumpy2 float, bump2net text, parallelr float,bump1name text, bump2name text)}
db eval {CREATE TABLE B2BMMAXPARFAILTABLE(rulename text, maxr float)}


db eval {CREATE INDEX B2BPind ON B2BPASSTABLE(rulename, bump1name, bump1net, bump2name, bump2net, passfail, clampname)}
db eval {CREATE INDEX B2CPind ON B2CPASSTABLE(rulename, bump1name, bump1net, clampname)}
db eval {CREATE INDEX C2CPind ON C2CPASSTABLE(rulename, clamp1name, clamp1net, clamp2name)}
db eval {CREATE INDEX B2BMPind ON B2BMPASSTABLE(rulename, bump1name, bump1net, bump2name, bump2net, passfail, clamp1name, clamp2name)}
db eval {CREATE INDEX B2BPARPind ON B2BPARPASSTABLE(rulename, bump1net, bump2net, bump1name, bump2name)}
db eval {CREATE INDEX B2BMPARPind ON B2BPARPASSTABLE(rulename, bump1net, bump2net, bump1name, bump2name)}
db eval {CREATE INDEX B2BFind ON B2BFAILTABLE(rulename, bump1name, bump1net, bump2name, bump2net, passfail, clampname)}
db eval {CREATE INDEX B2CFind ON B2CFAILTABLE(rulename, bump1name, bump1net, clampname)}
db eval {CREATE INDEX C2CFind ON C2CFAILTABLE(rulename, clamp1name, clamp1net, clamp2name)}
db eval {CREATE INDEX B2BMFind ON B2BMFAILTABLE(rulename, bump1name, bump1net, bump2name, bump2net, passfail, clamp1name, clamp2name)}
db eval {CREATE INDEX B2BPARFind ON B2BPARFAILTABLE(rulename, bump1net, bump2net, bump1name, bump2name)}
db eval {CREATE INDEX B2BMPARFind ON B2BPARFAILTABLE(rulename, bump1net, bump2net, bump1name, bump2name)}

db eval {PRAGMA synchronous=OFF}
db eval {PRAGMA count_changes=OFF}
db eval {PRAGMA default_cache_size=5000}
db eval {PRAGMA journal_mode=OFF}
db eval {PRAGMA temp_store=2}
db eval {BEGIN TRANSACTION}

atclDisplayResNX_CREATETABLE $esd_pass_rpt "PASS" 
atclDisplayResNX_CREATETABLE $esd_fail_rpt "FAIL" 

db eval {COMMIT}
puts "Done with Setup"
}; ### End of proc atclDisplayResNX_SETUP



proc atclDisplayResNX_CREATETABLE { esd_rpt PFflag } {
global clampinstlocarr
set ESDRPT [open $esd_rpt r]
while {[gets $ESDRPT line] >= 0} {
	if {[regexp {^# ESD Check} $line]} {
		set rulename [lindex $line 6]
		regsub -all -- {<} $rulename "" rulename
		regsub -all -- {>} $rulename "" rulename
		set rtype [lindex $line 7]
		regsub -all -- {\(} $rtype "" rtype
		regsub -all -- {\)} $rtype "" rtype
		if {$rtype == "BUMP2BUMP"} {
			set parcnt 0
			while {![regexp {^Summary} $line]} {
				gets $ESDRPT line
				if {[regexp {^BUMP PAIR:} $line]} {
					incr parcnt
					regsub -all -- {[[:space:]]+} $line " " line
					set line [split $line]
		                        set bump1name   [lindex [split [lindex $line 2] "("] 1]
		                        set bump2name   [lindex [split [lindex $line 8] "("] 1]
					set bumpx1 [lindex $line 3]
					set bumpy1 [lindex $line 4]
					set bumpx2 [lindex $line 9]
					set bumpy2 [lindex $line 10]
					set bump1net   [lindex [split [lindex $line 6] ")"] 0]
		                        set bump2net   [lindex [split [lindex $line 12] ")"] 0]
					gets $ESDRPT line
					while {![regexp {^PARALLEL} $line]} {
						if {[regexp {^(PASS|FAIL)} $line]} {
							regsub -all -- {[[:space:]]+} $line " " line
							regsub -all -- {\[} $line "" line
							regsub -all -- {\]} $line "" line
							set line [split $line]
							set passfail [lindex $line 0]
							if {$passfail == "PASS:"} {
								set  passfail "PASS"
							} else {
								set  passfail "FAIL"
							}
							set loopr [lindex $line 1]
							set clampname [lindex $line 4]
							set locid1 [lindex $line 5]
							set locid2 [lindex $line 6]
							set clampx1 [lindex $clampinstlocarr($rtype,$rulename,$clampname,$locid1) 0]
							set clampy1 [lindex $clampinstlocarr($rtype,$rulename,$clampname,$locid1) 1]
							set clampx2 [lindex $clampinstlocarr($rtype,$rulename,$clampname,$locid2) 0]
							set clampy2 [lindex $clampinstlocarr($rtype,$rulename,$clampname,$locid2) 1]
							if {$PFflag == "PASS"} {
								db eval {INSERT INTO B2BPASSTABLE VALUES($rulename, $bump1name, $bumpx1, $bumpy1, $bump1net, $bump2name, $bumpx2, $bumpy2, $bump2net, $passfail, $clampname, $clampx1, $clampy1, $clampx2, $clampy2, $loopr)} 
							} else {
								db eval {INSERT INTO B2BFAILTABLE VALUES($rulename, $bump1name, $bumpx1, $bumpy1, $bump1net, $bump2name, $bumpx2, $bumpy2, $bump2net, $passfail, $clampname, $clampx1, $clampy1, $clampx2, $clampy2, $loopr)} 
							}
							gets $ESDRPT line
						}
					}
					set parallelr [lindex $line 2]
					if {$parcnt == 1} {
						set maxparr $parallelr
						if {$PFflag == "PASS"} {
							db eval {INSERT INTO B2BMAXPARPASSTABLE VALUES($rulename, $maxparr)}
						} else {
							db eval {INSERT INTO B2BMAXPARFAILTABLE VALUES($rulename, $maxparr)}
						}
					}
					if {$PFflag == "PASS"} {
						db eval {INSERT INTO B2BPARPASSTABLE VALUES($rulename, $bumpx1, $bumpy1, $bump1net, $bumpx2, $bumpy2, $bump2net, $parallelr, $bump1name, $bump2name)}
					} else {
						db eval {INSERT INTO B2BPARFAILTABLE VALUES($rulename, $bumpx1, $bumpy1, $bump1net, $bumpx2, $bumpy2, $bump2net, $parallelr, $bump1name, $bump2name)}
					}
				}
			}
		}
		if {$rtype == "BUMP2CLAMP"} {
			while {![regexp {^Summary} $line]} {
				gets $ESDRPT line
				if {[regexp {^BUMP:} $line]} {
					regsub -all -- {[[:space:]]+} $line " " line
					set line [split $line]
		                        set bump1name   [lindex $line 5]
					set bumpx1 [lindex $line 1]
					set bumpy1 [lindex $line 2]
					set bump1net   [lindex $line 4]
					gets $ESDRPT line
					while {![regexp {^\s*$} $line]} {
						regsub -all -- {[[:space:]]+} $line " " line
						set line [split $line]
						set res [lindex $line 0]
						set clampname [lindex $line 6]
						set locid1 [lindex $line 5]
						set clampx1 [lindex $clampinstlocarr($rtype,$rulename,$clampname,$locid1) 0]
						set clampy1 [lindex $clampinstlocarr($rtype,$rulename,$clampname,$locid1) 1]
						if {$PFflag == "PASS"} {
								db eval {INSERT INTO B2CPASSTABLE VALUES($rulename, $bump1name, $bumpx1, $bumpy1, $bump1net, $clampname, $clampx1, $clampy1, $res)}
						} else {
								db eval {INSERT INTO B2CFAILTABLE VALUES($rulename, $bump1name, $bumpx1, $bumpy1, $bump1net, $clampname, $clampx1, $clampy1, $res)}
						}
						gets $ESDRPT line
					}
				}
			}
		}
		if {$rtype == "CLAMP2CLAMP"} {
			while {![regexp {^Summary} $line]} {
				gets $ESDRPT line
				if {[regexp {^CLAMP POINT:} $line]} {
					regsub -all -- {[[:space:]]+} $line " " line
					set line [split $line]
		                        set clamp1name   [lindex $line 7]
					set clampx1 [lindex $line 2]
					set clampy1 [lindex $line 3]
					set clamp1net   [lindex $line 5]
					gets $ESDRPT line
					while {![regexp {^\s*$} $line]} {
						regsub -all -- {[[:space:]]+} $line " " line
						set line [split $line]
						set res [lindex $line 0]
						set clamp2name [lindex $line 6]
						set locid2 [lindex $line 5]
						set clampx2 [lindex $clampinstlocarr($rtype,$rulename,$clamp2name,$locid2) 0]
						set clampy2 [lindex $clampinstlocarr($rtype,$rulename,$clamp2name,$locid2) 1]
						if {$PFflag == "PASS"} {
								db eval {INSERT INTO C2CPASSTABLE VALUES($rulename, $clamp1name, $clampx1, $clampy1, $clamp1net, $clamp2name, $clampx2, $clampy2, $res)}
						} else {
								db eval {INSERT INTO C2CFAILTABLE VALUES($rulename, $clamp1name, $clampx1, $clampy1, $clamp1net, $clamp2name, $clampx2, $clampy2, $res)}
						}
						gets $ESDRPT line
					}
				}
			}
		}
		if {$rtype == "BUMP2BUMP_MULTISTAGE"} {
			set parcnt 0
			while {![regexp {^Summary} $line]} {
				gets $ESDRPT line
				if {[regexp {^BUMP PAIR:} $line]} {
					incr parcnt
					regsub -all -- {[[:space:]]+} $line " " line
					set line [split $line]
		                        set bump1name   [lindex [split [lindex $line 2] "("] 1]
		                        set bump2name   [lindex [split [lindex $line 8] "("] 1]
					set bumpx1 [lindex $line 3]
					set bumpy1 [lindex $line 4]
					set bumpx2 [lindex $line 9]
					set bumpy2 [lindex $line 10]
					set bump1net   [lindex [split [lindex $line 6] ")"] 0]
		                        set bump2net   [lindex [split [lindex $line 12] ")"] 0]
					gets $ESDRPT line
					while {![regexp {^PARALLEL} $line]} {
						if {[regexp {^(PASS|FAIL)} $line]} {
							regsub -all -- {[[:space:]]+} $line " " line
							set line [split $line]
							set passfail [lindex $line 0]
							if {$passfail == "PASS:"} {
								set  passfail "PASS"
							} else {
								set  passfail "FAIL"
							}
							set loopr [lindex $line 1]
							set clamp1name [lindex $line 4]
							set locid11 [lindex $line 5]
							set locid12 [lindex $line 6]
							set clamp1x1 [lindex $clampinstlocarr($rtype,$rulename,$clamp1name,$locid11) 0]
							set clamp1y1 [lindex $clampinstlocarr($rtype,$rulename,$clamp1name,$locid11) 1]
							set clamp1x2 [lindex $clampinstlocarr($rtype,$rulename,$clamp1name,$locid12) 0]
							set clamp1y2 [lindex $clampinstlocarr($rtype,$rulename,$clamp1name,$locid12) 1]
							if {[llength $line] == 11} {
								set clamp2name [lindex $line 8]
								set locid21 [lindex $line 9]
								set locid22 [lindex $line 10]
							} else {
								set clamp2name $clamp1name 
								set locid21 $locid11
								set locid22 $locid12
							}
							set clamp2x1 [lindex $clampinstlocarr($rtype,$rulename,$clamp2name,$locid21) 0]
							set clamp2y1 [lindex $clampinstlocarr($rtype,$rulename,$clamp2name,$locid21) 1]
							set clamp2x2 [lindex $clampinstlocarr($rtype,$rulename,$clamp2name,$locid22) 0]
							set clamp2y2 [lindex $clampinstlocarr($rtype,$rulename,$clamp2name,$locid22) 1]
							if {$PFflag == "PASS"} {
								db eval {INSERT INTO B2BMPASSTABLE VALUES($rulename, $bump1name, $bumpx1, $bumpy1, $bump1net, $bump2name, $bumpx2, $bumpy2, $bump2net, $passfail, $clamp1name, $clamp1x1, $clamp1y1, $clamp1x2, $clamp1y2, $clamp2name, $clamp2x1, $clamp2y1, $clamp2x2, $clamp2y2, $loopr)}
							} else {
								db eval {INSERT INTO B2BMFAILTABLE VALUES($rulename, $bump1name, $bumpx1, $bumpy1, $bump1net, $bump2name, $bumpx2, $bumpy2, $bump2net, $passfail, $clamp1name, $clamp1x1, $clamp1y1, $clamp1x2, $clamp1y2, $clamp2name, $clamp2x1, $clamp2y1, $clamp2x2, $clamp2y2, $loopr)}
							}
							gets $ESDRPT line
						}
					}
					set parallelr [lindex $line 2]
					if {$parcnt == 1} {
						set maxparr $parallelr
						if {$PFflag == "PASS"} {
							db eval {INSERT INTO B2BMMAXPARPASSTABLE VALUES($rulename, $maxparr)}
						} else {
							db eval {INSERT INTO B2BMMAXPARFAILTABLE VALUES($rulename, $maxparr)}
						}
					}
					if {$PFflag == "PASS"} {
						db eval {INSERT INTO B2BMPARPASSTABLE VALUES($rulename, $bumpx1, $bumpy1, $bump1net, $bumpx2, $bumpy2, $bump2net, $parallelr, $bump1name, $bump2name)}
					} else {
						db eval {INSERT INTO B2BMPARFAILTABLE VALUES($rulename, $bumpx1, $bumpy1, $bump1net, $bumpx2, $bumpy2, $bump2net, $parallelr, $bump1name, $bump2name)}
					}
				}
			}
		}
	}
}
close $ESDRPT
}; ### End of proc atclDisplayResNX_CREATETABLE



proc atclDisplayResNX_B2B { args } {
puts "*******************************************"
regexp -all {\{(.*)\}} $args  match args
set argv [split $args]
set argc [llength $argv]
config cmdlog off

if {![file exists .apache/.atclDisplayResNXDB.db]} {
	puts "Please use the -setup option first"
	return
}

#### Set the default parameters #########################
set overlay 0
set relresmap 0
set domainpairflag 0
set bumppairflag 0
set clampflag 0
set restype "parallel"
set passfailflag -1
set dispallflag -1
set minmaxexistflag 0
set bluecount 0
set greencount 0
set yellowcount 0
set orangecount 0
set redcount 0
set parfailcount 0
set parpasscount 0
#### Finish Set the default parameters ##################
#### Parse the arguments ##############################################
for {set j 0} {$j < $argc} {incr j 1} {
        if {[regexp {\-rule_name} [lindex $argv $j]]} {
                set rule_name [lindex $argv [expr $j + 1]]
        } elseif  {[regexp {\-bump_pair} [lindex $argv $j]]} {
                set bump1_name [lindex $argv [expr $j + 1]]
                set bump2_name [lindex $argv [expr $j + 2]]
		set bumppairflag 1
		set dispallflag 0
	} elseif  {[regexp {\-domain_pair} [lindex $argv $j]]} {
                set domain1_name [lindex $argv [expr $j + 1]]
                set domain2_name [lindex $argv [expr $j + 2]]
		set domainpairflag 1
        } elseif  {[regexp {\-clamp} [lindex $argv $j]]} {
                set clamp_name [lindex $argv [expr $j + 1]]
		set restype "loop"
		set clampflag 1
		set dispallflag 0
        } elseif  {[regexp {\-restype} [lindex $argv $j]]} {
                set restype [lindex $argv [expr $j + 1]]
		set dispallflag 0
        } elseif  {[regexp {\-overlay} [lindex $argv $j]]} {
		set overlay 1
        } elseif  {[regexp {\-relresmap} [lindex $argv $j]]} {
		set relresmap 1
		if {[regexp {\{} $argv]} {
			incr j 1
			regexp -all {\\{(.*)\\}} $argv  match r
			set minr [lindex $r 0]
                	set maxr [lindex $r 1]
			set minmaxexistflag 1
		}
        } elseif  {[regexp {\-all_fail} [lindex $argv $j]]} {
		set passfailflag 0
		set dispallflag 1
	} elseif  {[regexp {\-all_pass} [lindex $argv $j]]} {
		set passfailflag 1
		set dispallflag 1
	}
}

#### Finish Parse the arguments ########################################

if {$overlay == 0} {
	plot line -clearall
	marker delete -all
	select clearall
}

if {$dispallflag == -1} {
	puts "Either -bump_pair or -all_pass/-all_fail option is missing"
	return
}

if {$dispallflag == 1} {
	if {$passfailflag == 0} {
		puts "Displaying all fail b2b parallel resistances"
		set seltable "B2BPARFAILTABLE"
		if {$minmaxexistflag == 0} {
			set minr 0
			set maxr [lindex [db eval "SELECT * FROM B2BMAXPARFAILTABLE WHERE rulename = '$rule_name'"] 1]
		}
	} elseif {$passfailflag == 1} {
		set seltable "B2BPARPASSTABLE"
		puts "Displaying all pass b2b parallel resistances"
		if {$minmaxexistflag == 0} {
			set minr 0
			set maxr [lindex [db eval "SELECT * FROM B2BMAXPARPASSTABLE WHERE rulename = '$rule_name'"] 1]
		}
	}

	if {$domainpairflag == 1} {
		puts "Selecting domains $domain1_name and $domain2_name"
		set selcmd "WHERE (rulename = '$rule_name') AND ((bump1net = '$domain1_name' AND bump2net = '$domain2_name') OR (bump1net = '$domain2_name' AND bump2net = '$domain1_name'))"
	} else {
		set selcmd "WHERE rulename = '$rule_name'"
	}
	db eval "SELECT * FROM $seltable $selcmd" {
		if {($relresmap == 0) && ($passfailflag == 0)} {
			incr parfailcount
			set color "red"
			plot line -position $bumpx1 $bumpy1 $bumpx2 $bumpy2 -width 3 -color $color
		} elseif {($relresmap == 0) && ($passfailflag == 1)} {
			incr parpasscount
			set color "green"
			plot line -position $bumpx1 $bumpy1 $bumpx2 $bumpy2 -width 3 -color $color
		}
		if {($relresmap == 1) && ($parallelr >= $minr) && ($parallelr <= $maxr)} {
			set color [getcolor $parallelr $minr $maxr]
			switch $color {
				"blue" {incr bluecount}
				"green" {incr greencount}
				"yellow" {incr yellowcount}
				"orange" {incr orangecount}
				"red" {incr redcount}
			}
			plot line -position $bumpx1 $bumpy1 $bumpx2 $bumpy2 -width 3 -color $color
		}
	}
	if {($relresmap == 0) && ($passfailflag == 0)} {puts "Total b2b failed parallel resistance pairs = $parfailcount"}
	if {($relresmap == 0) && ($passfailflag == 1)} {puts "Total b2b passed parallel resistance pairs = $parpasscount"}
	if {$relresmap == 1} {
		set step [expr ($maxr - $minr) / 5.0]
		puts "Relative Resistance Color Map"
		puts "#\[Rmin Rmax\) : Rcount :: color"
		puts "\[$minr   [expr $minr + $step]\)  : $bluecount :: BLUE"
		puts "\[[expr $minr + $step]   [expr $minr + (2*$step)]\)  : $greencount :: GREEN"
		puts "\[[expr $minr + (2*$step)]   [expr $minr + (3*$step)]\)  : $yellowcount :: YELLOW"
		puts "\[[expr $minr + (3*$step)]   [expr $minr + (4*$step)]\)  : $orangecount :: ORANGE"
		puts "\[[expr $minr + (4*$step)]   $maxr\]  : $redcount :: RED"
		puts "Total number of resistances = [expr $bluecount +  $greencount + $yellowcount + $orangecount + $redcount]"
	}
} else {
	if {$bumppairflag == 0} {
		puts "-bump_pair option is required"
		return
	}
	if {$clampflag == 1} {
		puts "Selecting bump-clamp-bump loop resistance for $bump1_name\-$clamp_name\-$bump2_name" 
		puts "#<bump1> <clamp> <bump2> <loopR>"
		set seltablelist [list "B2BPASSTABLE" "B2BFAILTABLE"]
		set selcmd "WHERE (rulename = '$rule_name') AND (bump1name = '$bump1_name') AND (bump2name = '$bump2_name') AND (clampname = '$clamp_name')"
	} elseif {$clampflag == 0} {
		if {$restype == "loop"} {
			puts "Displaying bump-clamp-bump loop resistances for $bump1_name\-$bump2_name"
			puts "#<bump1> <clamp> <bump2> <loopR>"
			set seltablelist [list "B2BPASSTABLE" "B2BFAILTABLE"]
			set selcmd "WHERE (rulename = '$rule_name') AND (bump1name = '$bump1_name') AND (bump2name = '$bump2_name') ORDER BY loopr DESC"
		} elseif {$restype == "parallel"} {
			puts "Displaying bump-bump parallel resistances for $bump1_name\-$bump2_name"
			puts "#<bump1> <bump2> <parellelR>"
			set seltablelist [list "B2BPARPASSTABLE" "B2BPARFAILTABLE"]
			set selcmd "WHERE (rulename = '$rule_name') AND (bump1name = '$bump1_name') AND (bump2name = '$bump2_name')"
		}
	}
	if {$minmaxexistflag == 0} {
		set count 0
		db eval "SELECT * FROM B2BFAILTABLE $selcmd" {
			incr count
			if {$count == 1} { set maxr $loopr }
		}
		if {![info exists maxr]} {
			set count 0
			db eval "SELECT * FROM B2BPASSTABLE $selcmd" {
				incr count
				if {$count == 1} { set maxr $loopr }
			}
		}
		set minr 0
	}
	foreach seltable $seltablelist {	
		db eval "SELECT * FROM $seltable $selcmd" {
			if {$restype == "loop"} {
				if {$relresmap == 0} {
					if {$passfail == "PASS"} {set color "green"} else {set color "red"}
					puts "$bump1name $clampname $bump2name $loopr"
					plot line -position $bumpx1 $bumpy1 $clampx1 $clampy1 -width 3 -color $color
					plot line -position $bumpx2 $bumpy2 $clampx2 $clampy2 -width 3 -color $color
					plot line -position $clampx1 $clampy1 $clampx2 $clampy2 -width 3 -color white
					marker add -position $clampx1 $clampy1 -size 5 -color white
					marker add -position $clampx2 $clampy2 -size 5 -color white
				}
				if {($relresmap == 1) && ($loopr >= $minr) && ($loopr <= $maxr)} {
					puts "$bump1name $clampname $bump2name $loopr"
					set color [getcolor $loopr $minr $maxr]
					plot line -position $bumpx1 $bumpy1 $clampx1 $clampy1 -width 3 -color $color
					plot line -position $bumpx2 $bumpy2 $clampx2 $clampy2 -width 3 -color $color
					plot line -position $clampx1 $clampy1 $clampx2 $clampy2 -width 3 -color white
					marker add -position $clampx1 $clampy1 -size 5 -color white
					marker add -position $clampx2 $clampy2 -size 5 -color white
					switch $color {
						"blue" {incr bluecount}
						"green" {incr greencount}
						"yellow" {incr yellowcount}
						"orange" {incr orangecount}
						"red" {incr redcount}
					}
				}
			} else {
				if {$seltable == "B2BPARPASSTABLE"} {set color "green"} else {set color "red"}
				puts "$bump1name $bump2name $parallelr"
				plot line -position $bumpx1 $bumpy1 $bumpx2 $bumpy2 -width 3 -color $color
			}
		}
	}
	if {$relresmap == 1} {
		set step [expr ($maxr - $minr) / 5.0]
		puts "Relative Resistance Color Map"
		puts "#\[Rmin Rmax\) : Rcount :: color"
		puts "\[$minr   [expr $minr + $step]\)  : $bluecount :: BLUE"
		puts "\[[expr $minr + $step]   [expr $minr + (2*$step)]\)  : $greencount :: GREEN"
		puts "\[[expr $minr + (2*$step)]   [expr $minr + (3*$step)]\)  : $yellowcount :: YELLOW"
		puts "\[[expr $minr + (3*$step)]   [expr $minr + (4*$step)]\)  : $orangecount :: ORANGE"
		puts "\[[expr $minr + (4*$step)]   $maxr\]  : $redcount :: RED"
		puts "Total number of resistances = [expr $bluecount +  $greencount + $yellowcount + $orangecount + $redcount]"
	}
}
}; ### End of proc atclDisplayResNX_B2B


proc atclDisplayResNX_B2C { args } {
puts "*******************************************"
regexp -all {\{(.*)\}} $args  match args
set argv [split $args]
set argc [llength $argv]
config cmdlog off

if {![file exists .apache/.atclDisplayResNXDB.db]} {
	puts "Please use the -setup option first"
	return
}

#### Set the default parameters #########################
set overlay 0
set domainflag 0
set bumpflag 0
set b2cfailflag 0
set passfailflag 0
set dispallflag -1
set minmaxexistflag 0
set relresmap 0
set bluecount 0
set greencount 0
set yellowcount 0
set orangecount 0
set redcount 0
#### Finish Set the default parameters ##################


#### Parse the arguments ##############################################
for {set j 0} {$j < $argc} {incr j 1} {
        if {[regexp {\-rule_name} [lindex $argv $j]]} {
                set rule_name [lindex $argv [expr $j + 1]]
        } elseif  {[regexp {\-bump} [lindex $argv $j]]} {
                set bump1_name [lindex $argv [expr $j + 1]]
		set bumpflag 1
		set dispallflag 0
	} elseif  {[regexp {\-domain} [lindex $argv $j]]} {
                set domain1_name [lindex $argv [expr $j + 1]]
		set domainflag 1
		set dispallflag 1
        } elseif  {[regexp {\-fail} [lindex $argv $j]]} {
		set b2cfailflag 1
		set dispallflag 0
        } elseif  {[regexp {\-overlay} [lindex $argv $j]]} {
		set overlay 1
        } elseif  {[regexp {\-all_fail} [lindex $argv $j]]} {
		set passfailflag 1
		set dispallflag 1
	} elseif  {[regexp {\-relresmap} [lindex $argv $j]]} {
		set relresmap 1
		if {[regexp {\{} $argv]} {
			incr j 1
			regexp -all {\\{(.*)\\}} $argv  match r
			set minr [lindex $r 0]
                	set maxr [lindex $r 1]
			set minmaxexistflag 1
		}
	}
}
#### Finish Parse the arguments ########################################

if {$overlay == 0} {
	plot line -clearall
	marker delete -all
	select clearall
}

if {$dispallflag == -1} {
	puts "Either -bump or -all_fail option is missing"
	return
}

if {$dispallflag == 1} {
	puts "Displaying all fail b2c resistances"
	set seltable "B2CFAILTABLE"
	if {$domainflag == 1} {
		set selcmd "WHERE (rulename = '$rule_name') AND (bump1net = '$domain1_name')"
		puts "Selecting bumps on domain $domain1_name"
	} else {
		set selcmd "WHERE rulename = '$rule_name'"
	}

	db eval "SELECT * FROM $seltable $selcmd" {
		set color "red"
		plot line -position $bumpx1 $bumpy1 $clampx1 $clampy1 -width 3 -color $color
		marker add -position $clampx1 $clampy1 -size 5 -color white
	}
} else {
	if {$bumpflag == 0} {
		puts "-bump option is required"
		return
	}
	set selcmd "WHERE (rulename = '$rule_name') AND (bump1name = '$bump1_name') ORDER BY res DESC"
	puts "Displaying b2c resistances for bump $bump1_name"
	if {$b2cfailflag == 1} {
		set seltablelist "B2CFAILTABLE"
		puts "Displaying only fail resistances"
		puts "#<bump> <clamp> <res>"
	} elseif {$b2cfailflag == 0} {
		puts "Displaying both pass and fail resistances"
		puts "#<bump> <clamp> <res>"
		set seltablelist [list "B2CFAILTABLE" "B2CPASSTABLE"]
	}
	if {$minmaxexistflag == 0} {
		set count 0
		db eval "SELECT * FROM B2CFAILTABLE $selcmd" {
			incr count
			if {$count == 1} { set maxr $res }
		}
		if {![info exists maxr]} {
			set count 0
			db eval "SELECT * FROM B2CPASSTABLE $selcmd" {
				incr count
				if {$count == 1} { set maxr $res }
			}
		}
		set minr 0
	}
	foreach seltable $seltablelist {	
		db eval "SELECT * FROM $seltable $selcmd"  {
			if {($relresmap == 1) && ($res >= $minr) && ($res <= $maxr)} {
				puts "$bump1name $clampname $res"
				set color [getcolor $res $minr $maxr]
				switch $color {
					"blue" {incr bluecount}
					"green" {incr greencount}
					"yellow" {incr yellowcount}
					"orange" {incr orangecount}
					"red" {incr redcount}
				}
				plot line -position $bumpx1 $bumpy1 $clampx1 $clampy1 -width 3 -color $color
				marker add -position $clampx1 $clampy1 -size 5 -color white
			}
			if {$relresmap == 0} {
				puts "$bump1name $clampname $res"
				if {$seltable == "B2CFAILTABLE"} {set color "red"} else {set color "green"}
				plot line -position $bumpx1 $bumpy1 $clampx1 $clampy1 -width 3 -color $color
				marker add -position $clampx1 $clampy1 -size 5 -color white
			}
		}
	}
	if {$relresmap == 1} {
		set step [expr ($maxr - $minr) / 5.0]
		puts "Relative Resistance Color Map"
		puts "#\[Rmin Rmax\) : Rcount :: color"
		puts "\[$minr   [expr $minr + $step]\)  : $bluecount :: BLUE"
		puts "\[[expr $minr + $step]   [expr $minr + (2*$step)]\)  : $greencount :: GREEN"
		puts "\[[expr $minr + (2*$step)]   [expr $minr + (3*$step)]\)  : $yellowcount :: YELLOW"
		puts "\[[expr $minr + (3*$step)]   [expr $minr + (4*$step)]\)  : $orangecount :: ORANGE"
		puts "\[[expr $minr + (4*$step)]   $maxr\]  : $redcount :: RED"
		puts "Total number of resistances = [expr $bluecount +  $greencount + $yellowcount + $orangecount + $redcount]"
	}
}
}; ### End of proc atclDisplayResNX_B2C



proc atclDisplayResNX_C2C { args } {
puts "*******************************************"
regexp -all {\{(.*)\}} $args  match args
set argv [split $args]
set argc [llength $argv]
config cmdlog off

if {![file exists .apache/.atclDisplayResNXDB.db]} {
	puts "Please use the -setup option first"
	return
}

#### Set the default parameters #########################
set overlay 0
set domainflag 0
set clampflag 0
set c2cfailflag 0
set passfailflag 0
set dispallflag -1
set minmaxexistflag 0
set relresmap 0
set bluecount 0
set greencount 0
set yellowcount 0
set orangecount 0
set redcount 0
#### Finish Set the default parameters ##################


#### Parse the arguments ##############################################
for {set j 0} {$j < $argc} {incr j 1} {
        if {[regexp {\-rule_name} [lindex $argv $j]]} {
                set rule_name [lindex $argv [expr $j + 1]]
        } elseif  {[regexp {\-clamp} [lindex $argv $j]]} {
                set clamp1_name [lindex $argv [expr $j + 1]]
		set clampflag 1
		set dispallflag 0
	} elseif  {[regexp {\-domain} [lindex $argv $j]]} {
                set domain1_name [lindex $argv [expr $j + 1]]
		set domainflag 1
		set dispallflag 1
        } elseif  {[regexp {\-fail} [lindex $argv $j]]} {
		set c2cfailflag 1
		set dispallflag 0
        } elseif  {[regexp {\-overlay} [lindex $argv $j]]} {
		set overlay 1
        } elseif  {[regexp {\-all_fail} [lindex $argv $j]]} {
		set passfailflag 1
		set dispallflag 1
	} elseif  {[regexp {\-relresmap} [lindex $argv $j]]} {
		set relresmap 1
		if {[regexp {\{} $argv]} {
			incr j 1
			regexp -all {\\{(.*)\\}} $argv  match r
			set minr [lindex $r 0]
                	set maxr [lindex $r 1]
			set minmaxexistflag 1
		}
	}
}
#### Finish Parse the arguments ########################################

if {$overlay == 0} {
	plot line -clearall
	marker delete -all
	select clearall
}

if {$dispallflag == -1} {
	puts "Either -clamp or -all_fail option is missing"
	return
}

if {$dispallflag == 1} {
	puts "Displaying all fail c2c resistances"
	set seltable "C2CFAILTABLE"
	if {$domainflag == 1} {
		puts "Selecting clamps on domain $domain1_name"
		set selcmd "WHERE (rulename = '$rule_name') AND (clamp1net = '$domain1_name')"
	} else {
		puts "Selecting all domains on clamp $clamp1_name"
		set selcmd "WHERE rulename = '$rule_name'"
	}

	db eval "SELECT * FROM $seltable $selcmd" {
		set color "red"
		plot line -position $clampx1 $clampy1 $clampx2 $clampy2 -width 3 -color $color
		marker add -position $clampx2 $clampy2 -size 5 -color white
	}
} else {
	if {$clampflag == 0} {
		puts "-clamp option is required"
		return
	}
	set selcmd "WHERE (rulename = '$rule_name') AND (clamp1name = '$clamp1_name') ORDER BY res DESC"
	puts "Displaying c2c resistances for clamp $clamp1_name"
	if {$c2cfailflag == 1} {
		puts "Displaying only fail resistances"
		puts "#<clamp1> <domain1> <clamp2> <res>"
		set seltablelist "C2CFAILTABLE"
	} elseif {$c2cfailflag == 0} {
		puts "Displaying both pass and fail resistances"
		puts "#<clamp1> <domain1> <clamp2> <res>"
		set seltablelist [list "C2CFAILTABLE" "C2CPASSTABLE"]
	}
	if {$minmaxexistflag == 0} {
		set count 0
		db eval "SELECT * FROM C2CFAILTABLE $selcmd" {
			incr count
			if {$count == 1} { set maxr $res }
		}
		if {![info exists maxr]} {
			set count 0
			db eval "SELECT * FROM C2CPASSTABLE $selcmd" {
				incr count
				if {$count == 1} { set maxr $res }
			}
		}
		set minr 0
	}
	foreach seltable $seltablelist {	
		db eval "SELECT * FROM $seltable $selcmd" {
			if {($relresmap == 1) && ($res >= $minr) && ($res <= $maxr)} {
				puts "$clamp1name $clamp1net $clamp2name $res"
				set color [getcolor $res $minr $maxr]
				switch $color {
					"blue" {incr bluecount}
					"green" {incr greencount}
					"yellow" {incr yellowcount}
					"orange" {incr orangecount}
					"red" {incr redcount}
				}
				plot line -position $clampx1 $clampy1 $clampx2 $clampy2 -width 3 -color $color
				marker add -position $clampx2 $clampy2 -size 5 -color white
			}
			if {$relresmap == 0} {
				if {$seltable == "C2CFAILTABLE"} {set color "red"} else {set color "green"}
				puts "$clamp1name $clamp1net $clamp2name $res"
				plot line -position $clampx1 $clampy1 $clampx2 $clampy2 -width 3 -color $color
				marker add -position $clampx2 $clampy2 -size 5 -color white
			}
		}
	}
	if {$relresmap == 1} {
		set step [expr ($maxr - $minr) / 5.0]
		puts "Relative Resistance Color Map"
		puts "#\[Rmin Rmax\) : Rcount :: color"
		puts "\[$minr   [expr $minr + $step]\)  : $bluecount :: BLUE"
		puts "\[[expr $minr + $step]   [expr $minr + (2*$step)]\)  : $greencount :: GREEN"
		puts "\[[expr $minr + (2*$step)]   [expr $minr + (3*$step)]\)  : $yellowcount :: YELLOW"
		puts "\[[expr $minr + (3*$step)]   [expr $minr + (4*$step)]\)  : $orangecount :: ORANGE"
		puts "\[[expr $minr + (4*$step)]   $maxr\]  : $redcount :: RED"
		puts "Total number of resistances = [expr $bluecount +  $greencount + $yellowcount + $orangecount + $redcount]"
	}
}
}; ### End of proc atclDisplayResNX_C2C



proc atclDisplayResNX_B2BM { args } {
puts "*******************************************"
regexp -all {\{(.*)\}} $args  match args
set argv [split $args]
set argc [llength $argv]
config cmdlog off

if {![file exists .apache/.atclDisplayResNXDB.db]} {
	puts "Please use the -setup option first"
	return
}

#### Set the default parameters #########################
set overlay 0
set relresmap 0
set domainpairflag 0
set bumppairflag 0
set clampflag 0
set restype "parallel"
set passfailflag -1
set dispallflag -1
set minmaxexistflag 0
set bluecount 0
set greencount 0
set yellowcount 0
set orangecount 0
set redcount 0
set parfailcount 0
set parpasscount 0
#### Finish Set the default parameters ##################


#### Parse the arguments ##############################################
for {set j 0} {$j < $argc} {incr j 1} {
        if {[regexp {\-rule_name} [lindex $argv $j]]} {
                set rule_name [lindex $argv [expr $j + 1]]
        } elseif  {[regexp {\-bump_pair} [lindex $argv $j]]} {
                set bump1_name [lindex $argv [expr $j + 1]]
                set bump2_name [lindex $argv [expr $j + 2]]
		set bumppairflag 1
		set dispallflag 0
	} elseif  {[regexp {\-domain_pair} [lindex $argv $j]]} {
                set domain1_name [lindex $argv [expr $j + 1]]
                set domain2_name [lindex $argv [expr $j + 2]]
		set domainpairflag 1
        } elseif  {[regexp {\-clamp_pair} [lindex $argv $j]]} {
                set clamp1_name [lindex $argv [expr $j + 1]]
                set clamp2_name [lindex $argv [expr $j + 2]]
		set restype "loop"
		set clampflag 1
		set dispallflag 0
        } elseif  {[regexp {\-restype} [lindex $argv $j]]} {
                set restype [lindex $argv [expr $j + 1]]
		set dispallflag 0
        } elseif  {[regexp {\-overlay} [lindex $argv $j]]} {
		set overlay 1
        } elseif  {[regexp {\-relresmap} [lindex $argv $j]]} {
		set relresmap 1
		if {[regexp {\{} $argv]} {
			incr j 1
			regexp -all {\\{(.*)\\}} $argv  match r
			set minr [lindex $r 0]
                	set maxr [lindex $r 1]
			set minmaxexistflag 1
		}
        } elseif  {[regexp {\-all_fail} [lindex $argv $j]]} {
		set passfailflag 0
		set dispallflag 1
	} elseif  {[regexp {\-all_pass} [lindex $argv $j]]} {
		set passfailflag 1
		set dispallflag 1
	}

}
#### Finish Parse the arguments ########################################

if {$overlay == 0} {
	plot line -clearall
	marker delete -all
	select clearall
}

if {$dispallflag == -1} {
	puts "Either -bump_pair or -all_pass/-all_fail option is missing"
	return
}




if {$dispallflag == 1} {
	if {$passfailflag == 0} {
		puts "Displaying all fail b2b parallel resistances"
		set seltable "B2BMPARFAILTABLE"
		if {$minmaxexistflag == 0} {
			set minr 0
			set maxr [lindex [db eval "SELECT * FROM B2BMMAXPARFAILTABLE WHERE rulename = '$rule_name'"] 1]
		}
	} elseif {$passfailflag == 1} {
		puts "Displaying all pass b2b parallel resistances"
		set seltable "B2BMPARPASSTABLE"
		if {$minmaxexistflag == 0} {
			set minr 0
			set maxr [lindex [db eval "SELECT * FROM B2BMMAXPARPASSTABLE WHERE rulename = '$rule_name'"] 1]
		}
	}

	if {$domainpairflag == 1} {
		puts "Selecting domains $domain1_name and $domain2_name"
		set selcmd "WHERE (rulename = '$rule_name') AND ((bump1net = '$domain1_name' AND bump2net = '$domain2_name') OR (bump1net = '$domain2_name' AND bump2net = '$domain1_name'))"
	} else {
		set selcmd "WHERE rulename = '$rule_name'"
	}

	db eval "SELECT * FROM $seltable $selcmd" {
		if {($relresmap == 0) && ($passfailflag == 0)} {
			incr parfailcount
			set color "red"
			plot line -position $bumpx1 $bumpy1 $bumpx2 $bumpy2 -width 3 -color $color
		} elseif {($relresmap == 0) && ($passfailflag == 1)} {
			incr parpasscount
			set color "green"
			plot line -position $bumpx1 $bumpy1 $bumpx2 $bumpy2 -width 3 -color $color
		}
		if {($relresmap == 1) && ($parallelr >= $minr) && ($parallelr <= $maxr)} {
			set color [getcolor $parallelr $minr $maxr]
			switch $color {
				"blue" {incr bluecount}
				"green" {incr greencount}
				"yellow" {incr yellowcount}
				"orange" {incr orangecount}
				"red" {incr redcount}
			}
			plot line -position $bumpx1 $bumpy1 $bumpx2 $bumpy2 -width 3 -color $color
		}
	}
	if {($relresmap == 0) && ($passfailflag == 0)} {puts "Total b2b failed parallel resistance pairs = $parfailcount"}
	if {($relresmap == 0) && ($passfailflag == 1)} {puts "Total b2b passed parallel resistance pairs = $parpasscount"}
	if {$relresmap == 1} {
		set step [expr ($maxr - $minr) / 5.0]
		puts "#\[Rmin Rmax\) : Rcount :: color"
		puts "\[$minr   [expr $minr + $step]\)  : $bluecount :: BLUE"
		puts "\[[expr $minr + $step]   [expr $minr + (2*$step)]\)  : $greencount :: GREEN"
		puts "\[[expr $minr + (2*$step)]   [expr $minr + (3*$step)]\)  : $yellowcount :: YELLOW"
		puts "\[[expr $minr + (3*$step)]   [expr $minr + (4*$step)]\)  : $orangecount :: ORANGE"
		puts "\[[expr $minr + (4*$step)]   $maxr\]  : $redcount :: RED"
		puts "Total number of resistances = [expr $bluecount +  $greencount + $yellowcount + $orangecount + $redcount]"
	}
} else {
	if {$bumppairflag == 0} {
		puts "-bump_pair option is required"
		return
	}
	if {$clampflag == 1} {
		puts "Selecting bump-clamp-clamp-bump loop resistance for $bump1_name\-$clamp1_name\-$clamp2_name\-$bump2_name" 
		puts "#<bump1> <clamp1> <clamp2> <bump2> <loopR>"
		set seltablelist [list "B2BMPASSTABLE" "B2BMFAILTABLE"]
		set selcmd "WHERE (rulename = '$rule_name') AND (bump1name = '$bump1_name') AND (bump2name = '$bump2_name') AND (clamp1name = '$clamp1_name') AND (clamp2name = '$clamp2_name')"
	} elseif {$clampflag == 0} {
		if {$restype == "loop"} {
			puts "Displaying bump-clamp-clamp-bump loop resistances for $bump1_name\-$bump2_name"
			puts "#<bump1> <clamp1> <clamp2> <bump2> <loopR>"
			set seltablelist [list "B2BMPASSTABLE" "B2BMFAILTABLE"]
			set selcmd "WHERE (rulename = '$rule_name') AND (bump1name = '$bump1_name') AND (bump2name = '$bump2_name') ORDER BY loopr DESC"
		} elseif {$restype == "parallel"} {
			puts "Displaying bump-bump parallel resistances for $bump1_name\-$bump2_name"
			puts "#<bump1> <bump2> <parellelR>"
			set seltablelist [list "B2BMPARPASSTABLE" "B2BMPARFAILTABLE"]
			set selcmd "WHERE (rulename = '$rule_name') AND (bump1name = '$bump1_name') AND (bump2name = '$bump2_name')"
		}
	}
	if {$minmaxexistflag == 0} {
		set count 0
		db eval "SELECT * FROM B2BMFAILTABLE $selcmd" {
			incr count
			if {$count == 1} { set maxr $loopr }
		}
		if {![info exists maxr]} {
			set count 0
			db eval "SELECT * FROM B2BMPASSTABLE $selcmd" {
				incr count
				if {$count == 1} { set maxr $loopr }
			}
		}
		set minr 0
	}
	foreach seltable $seltablelist {	
		db eval "SELECT * FROM $seltable $selcmd" {
			if {$restype == "loop"} {
				if {$relresmap == 0} {
					if {$passfail == "PASS"} {set color "green"} else {set color "red"}
					puts "$bump1name $clamp1name $clamp2name $bump2name $loopr"
					plot line -position $bumpx1 $bumpy1 $clamp1x1 $clamp1y1 -width 3 -color $color
					plot line -position $bumpx2 $bumpy2 $clamp2x2 $clamp2y2 -width 3 -color $color
					plot line -position $clamp1x1 $clamp1y1 $clamp1x2 $clamp1y2 -width 3 -color white
					plot line -position $clamp2x1 $clamp2y1 $clamp2x2 $clamp2y2 -width 3 -color white
					plot line -position $clamp1x2 $clamp1y2 $clamp2x1 $clamp2y1 -width 3 -color white
					marker add -position $clamp1x1 $clamp1y1 -size 5 -color white
					marker add -position $clamp1x2 $clamp1y2 -size 5 -color white
					marker add -position $clamp2x1 $clamp2y1 -size 5 -color white
					marker add -position $clamp2x2 $clamp2y2 -size 5 -color white
				}
				if {($relresmap == 1) && ($loopr >= $minr) && ($loopr <= $maxr)} {
					puts "$bump1name $clamp1name $clamp2name $bump2name $loopr"
					set color [getcolor $loopr $minr $maxr]
					plot line -position $bumpx1 $bumpy1 $clamp1x1 $clamp1y1 -width 3 -color $color
					plot line -position $bumpx2 $bumpy2 $clamp2x2 $clamp2y2 -width 3 -color $color
					plot line -position $clamp1x1 $clamp1y1 $clamp1x2 $clamp1y2 -width 3 -color white
					plot line -position $clamp2x1 $clamp2y1 $clamp2x2 $clamp2y2 -width 3 -color white
					plot line -position $clamp1x2 $clamp1y2 $clamp2x1 $clamp2y1 -width 3 -color white
					marker add -position $clamp1x1 $clamp1y1 -size 5 -color white
					marker add -position $clamp1x2 $clamp1y2 -size 5 -color white
					marker add -position $clamp2x1 $clamp2y1 -size 5 -color white
					marker add -position $clamp2x2 $clamp2y2 -size 5 -color white
					switch $color {
						"blue" {incr bluecount}
						"green" {incr greencount}
						"yellow" {incr yellowcount}
						"orange" {incr orangecount}
						"red" {incr redcount}
					}
				}
			} else {
				if {$seltable == "B2BMPARPASSTABLE"} {set color "green"} else {set color "red"}
				puts "$bump1name $bump2name $parallelr"
				plot line -position $bumpx1 $bumpy1 $bumpx2 $bumpy2 -width 3 -color $color
			}
		}
	}
	if {$relresmap == 1} {
		set step [expr ($maxr - $minr) / 5.0]
		puts "Relative Resistance Color Map"
		puts "#\[Rmin Rmax\) : Rcount :: color"
		puts "\[$minr   [expr $minr + $step]\)  : $bluecount :: BLUE"
		puts "\[[expr $minr + $step]   [expr $minr + (2*$step)]\)  : $greencount :: GREEN"
		puts "\[[expr $minr + (2*$step)]   [expr $minr + (3*$step)]\)  : $yellowcount :: YELLOW"
		puts "\[[expr $minr + (3*$step)]   [expr $minr + (4*$step)]\)  : $orangecount :: ORANGE"
		puts "\[[expr $minr + (4*$step)]   $maxr\]  : $redcount :: RED"
		puts "Total number of resistances = [expr $bluecount +  $greencount + $yellowcount + $orangecount + $redcount]"
	}
}
}; ### End of proc atclDisplayResNX_B2BM

proc getcolor_old {perc} {
if {($perc >= 0) && ($perc < 20)} {
	set color blue
} elseif {($perc >= 20) && ($perc < 40)} {
        set color green
} elseif {($perc >= 40) && ($perc < 60)} {
        set color yellow
} elseif {($perc >= 60) && ($perc < 80)} {
        set color orange
} elseif {($perc >= 80) && ($perc <= 100)} {
        set color red
}
return $color
}


proc getcolor {r minr maxr} {
set step [expr ($maxr - $minr) / 5.0]
if {($r >= $minr) && ($r < [expr $minr + $step])} {
	set color blue
} elseif {($r >= [expr $minr + $step]) && ($r < [expr $minr + (2*$step)])} {
        set color green
} elseif {($r >= [expr $minr + (2*$step)]) && ($r < [expr $minr + (3*$step)])} {
        set color yellow
} elseif {($r >= [expr $minr + (3*$step)]) && ($r < [expr $minr + (4*$step)])} {
        set color orange
} elseif {($r >= [expr $minr + (4*$step)]) && ($r <= $maxr)} {
        set color red
}
return $color
}
#$$$$$ END OF NX $$$$##



#$$$$$ 91 $$$$#########
proc atclDisplayRes91 { args } {
regexp -all {\{(.*)\}} $args  match args
set argv [split $args]
set argc [llength $argv]
#### Set the default parameters ###############################################################
set whattype "parallel"
set noofpads 0
set flagrule 0
set flagpassfail 0
set flaginternalnet 0
set flagequcell 0
set noofloops 0
set loopflag 0
#### Finish Set the default parameters ########################################################

#### Parse the arguments ######################################################################
if {$argc == 0} {
	puts "Please refer to the usage"
	atclDisplayRes91_help; return
}


if {$argc == 1} {
	if {[regexp {\-h} [lindex $argv 0]]} {
                atclDisplayRes91_help;return
        } elseif  {[regexp {\-m} [lindex $argv 0]]} {
                atclDisplayRes91_manpage;return
	}
}


for {set k 0} {$k < $argc} {incr k 1} { 
	if {[regexp {\-type} [lindex $argv $k]]} {
		set flagrule 1
	}
}


if {$flagrule == 0} {
	puts "Please specify a rule name"
	return
}
	
for {set k 0} {$k < $argc} {incr k 1} {
        if {[regexp {\-loop_id} [lindex $argv $k]]} {
                set loopflag 1
        }
}






if {$loopflag == 0} {
	for {set j 0} {$j < $argc} {incr j 1} {
	        if {[regexp {\-type} [lindex $argv $j]]} {
	                set rulefile [lindex $argv [expr $j + 1]]
	        } elseif  {[regexp {\-restype} [lindex $argv $j]]} {
	                set whattype [lindex $argv [expr $j + 1]]
	        } elseif  {[regexp {\-rule_file} [lindex $argv $j]]} {
	                set rfile [lindex $argv [expr $j + 1]]
	        } elseif  {[regexp {\-h} [lindex $argv $j]]} {
	                atclDisplayRes91_help;return
	        } elseif  {[regexp {\-m} [lindex $argv $j]]} {
	                atclDisplayRes91_manpage;return
	        } elseif  {[regexp {\-fail} [lindex $argv $j]]} {
	                set flagpassfail 1
	        } elseif  {[regexp {\-internal_net} [lindex $argv $j]]} {
	                set flaginternalnet 1
	        } elseif  {[regexp {\-equcell} [lindex $argv $j]]} {
	                set flagequcell 1
	        } elseif  {[regexp {\-bump_pair} [lindex $argv $j]]} {
	                set noofpads [expr [expr $argc - 1] - $j]
	                for {set i [expr $j + 1]} {$i < $argc} {incr i 1} {
	                        lappend padlist [lindex $argv $i]
	                }
	        }
	}
} else {
	for {set j 0} {$j < $argc} {incr j 1} {
               if {[regexp {\-type} [lindex $argv $j]]} {
	               set rulefile [lindex $argv [expr $j + 1]]
               } elseif  {[regexp {\-restype} [lindex $argv $j]]} {
                       set whattype [lindex $argv [expr $j + 1]]
	       } elseif  {[regexp {\-rule_file} [lindex $argv $j]]} {
                       set rfile [lindex $argv [expr $j + 1]]
               } elseif  {[regexp {\-h} [lindex $argv $j]]} {
                       atclDisplayRes91_help;return
               } elseif  {[regexp {\-m} [lindex $argv $j]]} {
                       atclDisplayRes91_manpage;return
               } elseif  {[regexp {\-fail} [lindex $argv $j]]} {
                       set flagpassfail 1
	       } elseif  {[regexp {\-internal_net} [lindex $argv $j]]} {
	                set flaginternalnet 1
	       } elseif  {[regexp {\-equcell} [lindex $argv $j]]} {
	                set flagequcell 1
               } elseif  {[regexp {\-bump_pair} [lindex $argv $j]]} {
                       set noofpads 1
                       lappend padlist [lindex $argv [expr $j + 1]]
               } elseif  {[regexp {\-loop_id} [lindex $argv $j]]} {
                       set noofloops [expr [expr $argc - 1] - $j]
                       for {set i [expr $j + 1]} {$i < $argc} {incr i 1} {
                               lappend looplist [lindex $argv $i]
                       }
               }
        }
}


if {$rulefile == "BUMP2BUMP"} {
	if {$flaginternalnet == 0 && $flagequcell == 0} {
		puts "BUMP2BUMP rule, assuming -internal_net and -equcell options were not used in your ESD check"
		atclDisplayRes91_case1 $args; return
	} elseif {$flaginternalnet == 1 && $flagequcell == 0} {
		puts "BUMP2BUMP rule, assuming -equcell option was not used in your ESD check"
                atclDisplayRes91_case2 $args; return
        } elseif {$flaginternalnet == 0 && $flagequcell == 1} {
		puts "BUMP2BUMP rule, assuming -internal_net option was not used in your ESD check"
                atclDisplayRes91_case3 $args; return
        } elseif {$flaginternalnet == 1 && $flagequcell == 1} {
                atclDisplayRes91_case4 $args; return
        } 
} elseif {$rulefile == "CLAMP2CLAMP"} {
	atclDisplayRes91_CLAMP2CLAMP $args; return
} elseif {$rulefile == "BUMP2CLAMP"} {
	atclDisplayRes91_BUMP2CLAMP $args; return
} 





	
#### Finish Parse the arguments ###############################################################
};### end of proc wrapper


proc atclDisplayRes91_manpage {} {
puts "
************************************************************************
SYNOPSIS
        Apache-AE TCL utility to display ESD check results
                                                                                                                                                            
USAGE
#####################
Options for BUMP2BUMP
#####################

atclDisplayRes -type <BUMP2BUMP> ?-rule_file <rule file name>? ?-internal_net? ?-equcell? ?-restype <loop | parallel>? ?-bump_pair <bump_pair_ID1 bump_pair_ID2 bump_pair_ID3 .........>? ?-loop_id <loop_ID1 loop_ID2 .........>? ?-fail? ?-h? ?-m?
                                                                                                                                                            
Options:
        -type <BUMP2BUMP> : Name of the ESD rule (BUMP2BUMP. Required) 
	-rule_file <rule file name>: ESD rule file name (Optional)
	-internal_net : Specifies if the option -internal_net was used in perform esdcheck (Required if it was used in perform esdcheck)
	-equcell : Specifies if the option -equcell was used in perform esdcheck (Required if it was used in perform esdcheck)
        -restype <loop|parallel> : Displays loop or parallel resistance (Optional, Default: parallel)
        -bump_pair <bump_pair_ID1 bump_pair_ID2 bump_pair_ID3 .........> :  ID of bump pair(s) to display (Required if -restype is loop. Takes only one bump ID if -loop_id is specified)
        -loop_id <loop_ID_1 loop_ID_2 ........> : ID of bump-clamp-bump loop for a bump_pair specified (Specify only one bump pair in -bump_pair, -loop_id should be the last argument)
        -fail : Displays ALL those bump-bump parallel resistances which are above the threshold (Optional, neglects -bump_pair and -loop_id)
        -h : Help
        -m : Man page

COLOR CODING
	GREEN :  Resistance is below threshold
	RED   :  Resistance is above threshold
	YELLOW:  Clamp-to-equivalent clamp connection
	BLUE  :  Clamp-to-clamp bus connection
	Clamps shown by grey crosshair markers                                        


EXAMPLES
	atclDisplayRes -type BUMP2BUMP 
	atclDisplayRes -type BUMP2BUMP -internal_net 
        atclDisplayRes -type BUMP2BUMP -equcell
        atclDisplayRes -type BUMP2BUMP -internal_net -bump_pair 1
        atclDisplayRes -type BUMP2BUMP -internal_net -restype loop -bump_pair 1 -loop_id 2
	atclDisplayRes -type BUMP2BUMP -equcell -restype loop -bump_pair 1
	atclDisplayRes -type BUMP2BUMP -internal_net -equcell -fail
	atclDisplayRes -type BUMP2BUMP -rule_file rule.txt -internal_net -equcell -restype loop -bump_pair 1 -loop_id 2
	atclDisplayRes -type BUMP2BUMP -rule_file rule.txt -fail 


######################
Options for BUMP2CLAMP
######################

atclDisplayRes -type <BUMP2CLAMP> ?-rule_file <rule file name>?  -pad_id <number> ?-fail? ?-all_fail?	

Options:
	-type <BUMP2CLAMP> : Name of the ESD rule (BUMP2CLAMP. Required) 
	-rule_file <rule file name>: ESD rule file name (Optional)
	-pad_id <number> : ID of the pad for which the bump-to-clamp connections will be shown (Required, except if -all_fail is used, in which case it is neglected)
	?-fail? : Displays all the failed resistance checks for the one pad_id specified (Optional, -pad_id is also required along with it)
	?-all_fail? : Displayes all the failed resistance checks for all the pads (Optional. Neglects -pad_id if provided)

COLOR CODING
        GREEN :  Resistance is below threshold
        RED   :  Resistance is above threshold
	Clamps shown by grey crosshair markers                                        

EXAMPLES
	atclDisplayRes -type BUMP2CLAMP -pad_id 1
	atclDisplayRes -type BUMP2CLAMP -pad_id 1 -fail
	atclDisplayRes -type BUMP2CLAMP -all_fail
	atclDisplayRes -type BUMP2CLAMP  -rule_file rule.txt -pad_id 1


######################
Options for CLAMP2CLAMP
######################
                                                                                                                                                            
atclDisplayRes -type <CLAMP2CLAMP> ?-rule_file <rule file name>? -clamp_id <number> ?-fail? ?-all_fail?
                                                                                                                                                            
Options:
        -type <CLAMP2CLAMP> : Name of the ESD rule (CLAMP2CLAMP. Required) 
	-rule_file <rule file name>: ESD rule file name (Optional)
        -clamp_id <number> : ID of the clamp for which the clamp-to-clamp connections will be shown (Required, except if -all_fail is used, in which case it is neglected)
        ?-fail? : Displays all the failed resistance checks for the one clamp_id specified (Optional, -clamp_id is also required along with it)
        ?-all_fail? : Displayes all the failed resistance checks for all the clamps (Optional. Neglects -clamp_id if provided)
                                                                                                                                                            
COLOR CODING
        GREEN :  Resistance is below threshold
        RED   :  Resistance is above threshold
	Clamps shown by grey crosshair markers                                        
                                                                                                                                                            
EXAMPLES
        atclDisplayRes -type CLAMP2CLAMP -clamp_id 1
        atclDisplayRes -type CLAMP2CLAMP -clamp_id 1 -fail
        atclDisplayRes -type CLAMP2CLAMP -all_fail
        atclDisplayRes -type CLAMP2CLAMP -rule_file rule.txt -clamp_id 1

	
************************************************************************

"
}

proc atclDisplayRes91_help {} {
puts "\nOptions for BUMP2BUMP"
puts "atclDisplayRes -type <BUMP2BUMP> ?-rule_file <rule file name>? ?-internal_net? ?-equcell? ?-restype <loop | parallel>? ?-bump_pair <bump_pair_ID1 bump_pair_ID2 bump_pair_ID3 .........>? ?-loop_id <loop_ID1 loop_ID2 .........>? ?-fail? ?-h? ?-m?"
puts "\nOptions for BUMP2CLAMP"
puts "atclDisplayRes -type <BUMP2CLAMP> ?-rule_file <rule file name>?  -pad_id <number> ?-fail? ?-all_fail?"
puts "\nOptions for CLAMP2CLAMP"
puts "atclDisplayRes -type <CLAMP2CLAMP> ?-rule_file <rule file name>? -clamp_id <number> ?-fail? ?-all_fail?"
}




proc atclDisplayRes91_case1 { args } {
regexp -all {\{(.*)\}} $args  match args; ### debug
set argv [split $args]
set argc [llength $argv]

#### Set the default parameters ###############################################################
set whattype "parallel"
set noofpads 0
set flagrule 0
set flagpassfail 0
set noofloops 0
set loopflag 0
#### Finish Set the default parameters ########################################################

#### Parse the arguments ######################################################################


for {set k 0} {$k < $argc} {incr k 1} { 
	if {[regexp {\-type} [lindex $argv $k]]} {
		set flagrule 1
	}
}


if {$flagrule == 0} {
	puts "Please specify a rule name"
	return
}
	
for {set k 0} {$k < $argc} {incr k 1} {
        if {[regexp {\-loop_id} [lindex $argv $k]]} {
                set loopflag 1
        }
}






if {$loopflag == 0} {
	for {set j 0} {$j < $argc} {incr j 1} {
	        if {[regexp {\-type} [lindex $argv $j]]} {
	                set rulefile [lindex $argv [expr $j + 1]]
	        } elseif  {[regexp {\-rule_file} [lindex $argv $j]]} {
	                set rfile [lindex $argv [expr $j + 1]]
	        } elseif  {[regexp {\-restype} [lindex $argv $j]]} {
	                set whattype [lindex $argv [expr $j + 1]]
	        } elseif  {[regexp {\-fail} [lindex $argv $j]]} {
	                set flagpassfail 1
	        } elseif  {[regexp {\-bump_pair} [lindex $argv $j]]} {
	                set noofpads [expr [expr $argc - 1] - $j]
	                for {set i [expr $j + 1]} {$i < $argc} {incr i 1} {
	                        lappend padlist [lindex $argv $i]
	                }
	        }
	}
} else {
	for {set j 0} {$j < $argc} {incr j 1} {
               if {[regexp {\-type} [lindex $argv $j]]} {
	               set rulefile [lindex $argv [expr $j + 1]]
	       } elseif  {[regexp {\-rule_file} [lindex $argv $j]]} {
                        set rfile [lindex $argv [expr $j + 1]]
               } elseif  {[regexp {\-restype} [lindex $argv $j]]} {
                       set whattype [lindex $argv [expr $j + 1]]
               } elseif  {[regexp {\-fail} [lindex $argv $j]]} {
                       set flagpassfail 1
               } elseif  {[regexp {\-bump_pair} [lindex $argv $j]]} {
                       set noofpads 1
                       lappend padlist [lindex $argv [expr $j + 1]]
               } elseif  {[regexp {\-loop_id} [lindex $argv $j]]} {
                       set noofloops [expr [expr $argc - 1] - $j]
                       for {set i [expr $j + 1]} {$i < $argc} {incr i 1} {
                               lappend looplist [lindex $argv $i]
                       }
               }
        }
}






















	
#set oldrulefile $rulefile
#set mynewrulefile $rulefile.rpt
#set rulefile $mynewrulefile

if {![info exists rfile]} {
        set rulefile "esd_B2B.rpt"
        set oldrulefile "B2B"
} else {
        set RULE [open $rfile r 0666]
	while { [gets $RULE line] >=0 } {
                if {[regexp {NAME} $line]} {
                        regsub -all -- {[[:space:]]+} $line " " line
                        regsub -all -- {^[[:space:]]+} $line "" line
                        set line [split $line]
                        set rulename [lindex $line 1]
		}
	}

	set rulefile [concat esd_$rulename.rpt]
	set oldrulefile $rulename
}
#### Finish Parse the arguments ###############################################################



#### If -bump_pair option is not specified ####################################################
if {$noofpads == 0} {	
	plot line -clearall
	marker delete -all
	#### Open <rulename>.rpt file
	set RLRPT [open adsRpt/ESD/$rulefile r 0666]
	while { [gets $RLRPT line] >=0 } {
		if {[regexp {^PADS} $line]} { 
			regsub -all -- {[[:space:]]+} $line " " line
			set line [split $line]
			set pads      [lindex $line 0]
			set pad_id    [lindex $line 1]
			set pad1_name [lindex $line 2]
			set pad2_name [lindex $line 3]
			set pad1_x    [lindex [split [lindex $line 4] "("] 1]
			set pad1_y    [lindex [split [lindex $line 5] ")"] 0]
			set pad2_x    [lindex [split [lindex $line 6] "("] 1]
			set pad2_y    [lindex [split [lindex $line 7] ")"] 0]
			gets $RLRPT esd  ;    # Reads "EDS Loops"
			gets $RLRPT clamp ;   # Reads the first line for clamp
			while {[regexp {:} $clamp] } {
				regsub -all -- {[[:space:]]+} $clamp " " clamp
				set clamp [split $clamp]
				set this_is_space   [lindex $clamp 0]
				set loop_id   	    [lindex [split [lindex $clamp 1] ":"] 0]
				set passfail        [lindex [split [lindex $clamp 1] ":"] 1]
				set loop_r          [lindex $clamp 2]
				set pad1_tocr       [lindex $clamp 3]
				set pad2_tocr       [lindex $clamp 4]
				set clampcell       [lindex $clamp 5]

				#### If -restype is loop ####################################################
                		#### Open esd_<rulename>.res file to locate the clamps ##################
				if {[regexp {loop} $whattype]} {
                                        puts "Please provide bump IDs using the option, -bump_pair <bump_1 bump_2 ...>"
					return
#					set correctfilename [concat .apache/esd_$oldrulefile.res]
#			                set ESDF [open $correctfilename r 0666]
#			                while {[gets $ESDF esdline] >=0 } {
#			                        if {[regexp $clampcell $esdline]} {
#			                                regsub -all -- {[[:space:]]+} $esdline " " esdline
#			                                set esdline [split $esdline]
#			                                set clamp_x [lindex $esdline 1]
#			                                set clamp_y [lindex $esdline 2]
#							marker add -position $clamp_x $clamp_y -color grey -size 10
#		 					if {[regexp {pass} $passfail]} {
#								plot line -position $pad1_x $pad1_y $clamp_x $clamp_y -color green -width 2
#								plot line -position $pad2_x $pad2_y $clamp_x $clamp_y -color green -width 2
#							} else {
#								plot line -position $pad1_x $pad1_y $clamp_x $clamp_y -color red -width 2
#								plot line -position $pad2_x $pad2_y $clamp_x $clamp_y -color red -width 2
#							}
#								
#		                                break
#			                        }  ;#### End of if {[regexp $clampcell $esdline]} 
#			                } ;#### End of while
#			                close $ESDF
				} ;#### End of if {[regexp {loop} $whattype]} 
		                #### end of  Open esd_<rulename>.res file to locate the clamps ##########
				gets $RLRPT clamp
			} ;#### End of while {[regexp {:} $clamp] } 

	
			#### Else if -restype is parallel ###########################################
			#### get the parallel R information from <rulename>.rpt ######################
			if {[regexp {parallel} $whattype]} {
				set parallel $clamp
				regsub -all -- {[[:space:]]+} $parallel " " parallel
				set parallel [split $parallel]
				set this_is_parallel [lindex $parallel 0]	
				set this_is_R        [lindex $parallel 1]	
				set parR             [lindex $parallel 2]
				set par_passfail     [lindex $parallel 3]
				
				if {$flagpassfail == 1} {
					if {[regexp {pass} $par_passfail]} {
					} else {
						plot  line -position $pad1_x $pad1_y $pad2_x $pad2_y  -color red -width 2
					}
				} else {
					if {[regexp {pass} $par_passfail]} {
						plot  line -position $pad1_x $pad1_y $pad2_x $pad2_y  -color green -width 2
					} else {
						plot  line -position $pad1_x $pad1_y $pad2_x $pad2_y  -color red -width 2
					}
				}
					
		
			
			} ;#### End of if {[regexp {parallel} $whattype]} 
			#### end of Else if -restype is parallel ####################################
		} ;#### End of 	if {[regexp {^PADS} $line]}  
	} ;#### End of while { [gets $RLRPT line] >=0 } 
	close $RLRPT

} else  { ;#### Else if -bump_pair is specified
	plot line -clearll
	marker delete -all
	foreach padinlist "$padlist"  {		
		set RLRPT [open adsRpt/ESD/$rulefile r 0666]
		
		while { [gets $RLRPT line] >=0 } {
			if {[regexp {^PADS} $line]} { 
				regsub -all -- {[[:space:]]+} $line " " line
				set line [split $line]
				set pads      [lindex $line 0]
				set pad_id    [lindex $line 1]
				set pad1_name [lindex $line 2]
				set pad2_name [lindex $line 3]
				set pad1_x    [lindex [split [lindex $line 4] "("] 1]
				set pad1_y    [lindex [split [lindex $line 5] ")"] 0]
				set pad2_x    [lindex [split [lindex $line 6] "("] 1]
				set pad2_y    [lindex [split [lindex $line 7] ")"] 0]
				if {$padinlist == $pad_id} {	
					gets $RLRPT esd  ;    # Reads "EDS Loops"
					gets $RLRPT clamp ;   # Reads the first line for clamp
					while {[regexp {:} $clamp] } {
						regsub -all -- {[[:space:]]+} $clamp " " clamp
						set clamp [split $clamp]
						set this_is_space   [lindex $clamp 0]
						set loop_id   	    [lindex [split [lindex $clamp 1] ":"] 0]
						set passfail        [lindex [split [lindex $clamp 1] ":"] 1]
						set loop_r          [lindex $clamp 2]
						set pad1_tocr       [lindex $clamp 3]
						set pad2_tocr       [lindex $clamp 4]
						set clampcell       [lindex $clamp 5]
			                        

						if { $loopflag == 1} {
							foreach loopinlist "$looplist" {
								if {$loopinlist == $loop_id} {
									if {[regexp {loop} $whattype]} {
			                                                        set correctfilename [concat .apache/esd_$oldrulefile.res] 
										if {![file exists $correctfilename]} {
											set correctfilename [concat .apache/ESD/esd_$oldrulefile.res]
										}
			                                                        set ESDF [open $correctfilename r 0666]
			                                                        while {[gets $ESDF esdline] >=0 } {
			                                                                if {[regexp $clampcell $esdline]} {
			                                                                        regsub -all -- {[[:space:]]+} $esdline " " esdline
			                                                                        set esdline [split $esdline]
			                                                                        set clamp_x [lindex $esdline 1]
			                                                                        set clamp_y [lindex $esdline 2]
                        			                                                marker add  -position $clamp_x $clamp_y -color grey -size 10
                                                			                        if {[regexp {pass} $passfail]} {
                                                                        			        plot line -position $pad1_x $pad1_y $clamp_x $clamp_y -color green -width 2
                                			                                                plot line -position $pad2_x $pad2_y $clamp_x $clamp_y -color green -width 2
                                			                                        } else {
                                                        			                        plot line -position $pad1_x $pad1_y $clamp_x $clamp_y -color red -width 2
                                			                                                plot line -position $pad2_x $pad2_y $clamp_x $clamp_y -color red -width 2
                                			                                        }
			
                        			                                                break
                                                			                }
			                                                        }
                        			                                close $ESDF
			                                                } ;#### End of if {[regexp {loop} $whattype]}
								};#### End of if {$loopinlist == loop_id}
							};#### End of foreach loopinlist "$looplist"
						} else { 

 
							#### If -restype is loop ####################################################
				                	#### Open esd_<rulename>.res file to locate the clamps ##################
							if {[regexp {loop} $whattype]} {
								set correctfilename [concat .apache/esd_$oldrulefile.res]
								if {![file exists $correctfilename]} {
										set correctfilename [concat .apache/ESD/esd_$oldrulefile.res]
								}
						                set ESDF [open $correctfilename r 0666]
						                while {[gets $ESDF esdline] >=0 } {
						                        if {[regexp $clampcell $esdline]} {
						                                regsub -all -- {[[:space:]]+} $esdline " " esdline
						                                set esdline [split $esdline]
						                                set clamp_x [lindex $esdline 1]
						                                set clamp_y [lindex $esdline 2]
										marker add  -position $clamp_x $clamp_y -color grey -size 10
					 					if {[regexp {pass} $passfail]} {
											plot line -position $pad1_x $pad1_y $clamp_x $clamp_y -color green -width 2
											plot line -position $pad2_x $pad2_y $clamp_x $clamp_y -color green -width 2
										} else {
											plot line -position $pad1_x $pad1_y $clamp_x $clamp_y -color red -width 2
											plot line -position $pad2_x $pad2_y $clamp_x $clamp_y -color red -width 2
										}
											
						                                break
						                        }
						                }
						                close $ESDF
							} ;#### End of if {[regexp {loop} $whattype]} 
					                #### end of  Open esd_<rulename>.res file to locate the clamps ##########
						}; #### End of else

						gets $RLRPT clamp
					} ;#### End of 	while {[regexp {:} $clamp] } 
		
				
					#### Else if -restype is parallel ###########################################
					#### get the parallel R information from <rulename>.rpt ######################
					if {[regexp {parallel} $whattype]} {
						set parallel $clamp
						regsub -all -- {[[:space:]]+} $parallel " " parallel
						set parallel [split $parallel]
						set this_is_parallel [lindex $parallel 0]	
						set this_is_R        [lindex $parallel 1]	
						set parR             [lindex $parallel 2]
						set par_passfail     [lindex $parallel 3]
						if {[regexp {pass} $par_passfail]} {
							plot line -position $pad1_x $pad1_y $pad2_x $pad2_y  -color green -width 2
						} else {
							plot line -position $pad1_x $pad1_y $pad2_x $pad2_y  -color red -width 2
						}
					
					} ;#### End of 	if {[regexp {parallel} $whattype]} 
					#### end of Else if -restype is parallel ####################################
				} ;#### End of if {$padinlist == $pad_id} 	
			} ;#### End of 	if {[regexp {^PADS} $line]}  
		} ;#### End of while { [gets $RLRPT line] >=0 } 
		close $RLRPT
	
	} ;#### End of foreach padinlist "$padlist"  		
	} ;#### End of else   ;#### Else if -bump_pair is specified
	
	
} ;#### End of proc atclDisplayRes91






proc atclDisplayRes91_case2 { args } {
regexp -all {\{(.*)\}} $args  match args; ### debug
set argv [split $args]
set argc [llength $argv]

#### Set the default parameters ###############################################################
set whattype "parallel"
set noofpads 0
set flagrule 0
set flagpassfail 0
set noofloops 0
set loopflag 0
#### Finish Set the default parameters ########################################################

#### Parse the arguments ######################################################################



for {set k 0} {$k < $argc} {incr k 1} { 
	if {[regexp {\-type} [lindex $argv $k]]} {
		set flagrule 1
	}
}


if {$flagrule == 0} {
	puts "Please specify a rule name"
	return
}
	
for {set k 0} {$k < $argc} {incr k 1} {
        if {[regexp {\-loop_id} [lindex $argv $k]]} {
                set loopflag 1
        }
}






if {$loopflag == 0} {
	for {set j 0} {$j < $argc} {incr j 1} {
	        if {[regexp {\-type} [lindex $argv $j]]} {
	                set rulefile [lindex $argv [expr $j + 1]]
	        } elseif  {[regexp {\-rule_file} [lindex $argv $j]]} {
	                set rfile [lindex $argv [expr $j + 1]]
	        } elseif  {[regexp {\-restype} [lindex $argv $j]]} {
	                set whattype [lindex $argv [expr $j + 1]]
	        } elseif  {[regexp {\-fail} [lindex $argv $j]]} {
	                set flagpassfail 1
	        } elseif  {[regexp {\-bump_pair} [lindex $argv $j]]} {
	                set noofpads [expr [expr $argc - 1] - $j]
	                for {set i [expr $j + 1]} {$i < $argc} {incr i 1} {
	                        lappend padlist [lindex $argv $i]
	                }
	        }
	}
} else {
	for {set j 0} {$j < $argc} {incr j 1} {
               if {[regexp {\-type} [lindex $argv $j]]} {
	               set rulefile [lindex $argv [expr $j + 1]]
	       } elseif  {[regexp {\-rule_file} [lindex $argv $j]]} {
                       set rfile [lindex $argv [expr $j + 1]]
               } elseif  {[regexp {\-restype} [lindex $argv $j]]} {
                       set whattype [lindex $argv [expr $j + 1]]
               } elseif  {[regexp {\-fail} [lindex $argv $j]]} {
                       set flagpassfail 1
               } elseif  {[regexp {\-bump_pair} [lindex $argv $j]]} {
                       set noofpads 1
                       lappend padlist [lindex $argv [expr $j + 1]]
               } elseif  {[regexp {\-loop_id} [lindex $argv $j]]} {
                       set noofloops [expr [expr $argc - 1] - $j]
                       for {set i [expr $j + 1]} {$i < $argc} {incr i 1} {
                               lappend looplist [lindex $argv $i]
                       }
               }
        }
}






















	
#set oldrulefile $rulefile
#set mynewrulefile $rulefile.rpt
#set rulefile $mynewrulefile

if {![info exists rfile]} {
        set rulefile "esd_B2B.rpt"
        set oldrulefile "B2B"
} else {
        set RULE [open $rfile r 0666]
	while { [gets $RULE line] >=0 } {
                if {[regexp {NAME} $line]} {
                        regsub -all -- {[[:space:]]+} $line " " line
                        regsub -all -- {^[[:space:]]+} $line "" line
                        set line [split $line]
                        set rulename [lindex $line 1]
		}
	}

	set rulefile [concat esd_$rulename.rpt]
	set oldrulefile $rulename
}
#puts "\n $rulefile \n $oldrulefile"
#### Finish Parse the arguments ###############################################################



#### If -bump_pair option is not specified ####################################################
if {$noofpads == 0} {	
	plot line -clearall
	marker delete -all
	#### Open <rulename>.rpt file
	set RLRPT [open adsRpt/ESD/$rulefile r 0666]
	while { [gets $RLRPT line] >=0 } {
		if {[regexp {^PADS} $line]} { 
			regsub -all -- {[[:space:]]+} $line " " line
			set line [split $line]
			set pads      [lindex $line 0]
			set pad_id    [lindex $line 1]
			set pad1_name [lindex $line 2]
			set pad2_name [lindex $line 3]
			set pad1_x    [lindex [split [lindex $line 4] "("] 1]
			set pad1_y    [lindex [split [lindex $line 5] ")"] 0]
			set pad2_x    [lindex [split [lindex $line 6] "("] 1]
			set pad2_y    [lindex [split [lindex $line 7] ")"] 0]
			gets $RLRPT esd  ;    # Reads "EDS Loops"
			gets $RLRPT clamp ;   # Reads the first line for clamp
			while {[regexp {:} $clamp] } {
				regsub -all -- {[[:space:]]+} $clamp " " clamp
				set clamp [split $clamp]
				set this_is_space   [lindex $clamp 0]
				set loop_id   	    [lindex [split [lindex $clamp 1] ":"] 0]
				set passfail        [lindex [split [lindex $clamp 1] ":"] 1]
				set loop_r          [lindex $clamp 2]
				set pad1_tocr       [lindex $clamp 3]
				set pad2_tocr       [lindex $clamp 4]
				set clampcell       [lindex $clamp 5]

				#### If -restype is loop ####################################################
                		#### Open esd_<rulename>.res file to locate the clamps ##################
				if {[regexp {loop} $whattype]} {
                                        puts "Please provide bump IDs using the option, -bump_pair <bump_1 bump_2 ...>"
					return
#					set correctfilename [concat .apache/esd_$oldrulefile.res]
#			                set ESDF [open $correctfilename r 0666]
#			                while {[gets $ESDF esdline] >=0 } {
#			                        if {[regexp $clampcell $esdline]} {
#			                                regsub -all -- {[[:space:]]+} $esdline " " esdline
#			                                set esdline [split $esdline]
#			                                set clamp_x [lindex $esdline 1]
#			                                set clamp_y [lindex $esdline 2]
#							marker add -position $clamp_x $clamp_y -color grey -size 10
#		 					if {[regexp {pass} $passfail]} {
#								plot line -position $pad1_x $pad1_y $clamp_x $clamp_y -color green -width 2
#								plot line -position $pad2_x $pad2_y $clamp_x $clamp_y -color green -width 2
#							} else {
#								plot line -position $pad1_x $pad1_y $clamp_x $clamp_y -color red -width 2
#								plot line -position $pad2_x $pad2_y $clamp_x $clamp_y -color red -width 2
#							}
#								
#		                                break
#			                        }  ;#### End of if {[regexp $clampcell $esdline]} 
#			                } ;#### End of while
#			                close $ESDF
				} ;#### End of if {[regexp {loop} $whattype]} 
		                #### end of  Open esd_<rulename>.res file to locate the clamps ##########
				gets $RLRPT clamp
			} ;#### End of while {[regexp {:} $clamp] } 

	
			#### Else if -restype is parallel ###########################################
			#### get the parallel R information from <rulename>.rpt ######################
			if {[regexp {parallel} $whattype]} {
				set parallel $clamp
				regsub -all -- {[[:space:]]+} $parallel " " parallel
				set parallel [split $parallel]
				set this_is_parallel [lindex $parallel 0]	
				set this_is_R        [lindex $parallel 1]	
				set parR             [lindex $parallel 2]
				set par_passfail     [lindex $parallel 3]
				
				if {$flagpassfail == 1} {
					if {[regexp {pass} $par_passfail]} {
					} else {
						plot  line -position $pad1_x $pad1_y $pad2_x $pad2_y  -color red -width 2
					}
				} else {
					if {[regexp {pass} $par_passfail]} {
						plot  line -position $pad1_x $pad1_y $pad2_x $pad2_y  -color green -width 2
					} else {
						plot  line -position $pad1_x $pad1_y $pad2_x $pad2_y  -color red -width 2
					}
				}
					
		
			
			} ;#### End of if {[regexp {parallel} $whattype]} 
			#### end of Else if -restype is parallel ####################################
		} ;#### End of 	if {[regexp {^PADS} $line]}  
	} ;#### End of while { [gets $RLRPT line] >=0 } 
	close $RLRPT

} else  { ;#### Else if -bump_pair is specified
	plot line -clearll
	marker delete -all
	foreach padinlist "$padlist"  {		
		set RLRPT [open adsRpt/ESD/$rulefile r 0666]
		
		while { [gets $RLRPT line] >=0 } {
			if {[regexp {^PADS} $line]} { 
				regsub -all -- {[[:space:]]+} $line " " line
				set line [split $line]
				set pads      [lindex $line 0]
				set pad_id    [lindex $line 1]
				set pad1_name [lindex $line 2]
				set pad2_name [lindex $line 3]
				set pad1_x    [lindex [split [lindex $line 4] "("] 1]
				set pad1_y    [lindex [split [lindex $line 5] ")"] 0]
				set pad2_x    [lindex [split [lindex $line 6] "("] 1]
				set pad2_y    [lindex [split [lindex $line 7] ")"] 0]
				if {$padinlist == $pad_id} {	
					gets $RLRPT esd  ;    # Reads "EDS Loops"
					gets $RLRPT clamp ;   # Reads the first line for clamp
					while {[regexp {:} $clamp] } {
						regsub -all -- {[[:space:]]+} $clamp " " clamp
						set clamp [split $clamp]
						set this_is_space   [lindex $clamp 0]
						set loop_id   	    [lindex [split [lindex $clamp 1] ":"] 0]
						set passfail        [lindex [split [lindex $clamp 1] ":"] 1]
						set loop_r          [lindex $clamp 2]
						set pad1_tocr       [lindex $clamp 3]
						set pad2_tocr       [lindex $clamp 4]
						set clampcell1      [lindex $clamp 6]
						set vddbus          [lindex $clamp 7]
						set clampcell2      [lindex $clamp 8]
			                        
						# For clampcell1
						if { $loopflag == 1} {
							foreach loopinlist "$looplist" {
								if {$loopinlist == $loop_id} {
									if {[regexp {loop} $whattype]} {
			                                                        set correctfilename [concat .apache/esd_$oldrulefile.res]
										if {![file exists $correctfilename]} {
											set correctfilename [concat .apache/ESD/esd_$oldrulefile.res]
										}
			                                                        set ESDF [open $correctfilename r 0666]
			                                                        while {[gets $ESDF esdline] >=0 } {
			                                                                if {[regexp $clampcell1 $esdline]} {
			                                                                        regsub -all -- {[[:space:]]+} $esdline " " esdline
			                                                                        set esdline [split $esdline]
			                                                                        set clamp1_x [lindex $esdline 1]
			                                                                        set clamp1_y [lindex $esdline 2]
                        			                                                marker add  -position $clamp1_x $clamp1_y -color grey -size 10
                                                			                        if {[regexp {pass} $passfail]} {
                                                                        			        plot line -position $pad1_x $pad1_y $clamp1_x $clamp1_y -color green -width 2
                                			                                                #plot line -position $pad2_x $pad2_y $clamp_x $clamp_y -color green -width 2
                                			                                        } else {
                                                        			                        plot line -position $pad1_x $pad1_y $clamp1_x $clamp1_y -color red -width 2
                                			                                                #plot line -position $pad2_x $pad2_y $clamp_x $clamp_y -color red -width 2
                                			                                        }
			
                        			                                                break
                                                			                }
			                                                        }
                        			                                close $ESDF
			                                                } ;#### End of if {[regexp {loop} $whattype]}
								};#### End of if {$loopinlist == loop_id}
							};#### End of foreach loopinlist "$looplist"
						} else { 

 
							#### If -restype is loop ####################################################
				                	#### Open esd_<rulename>.res file to locate the clamps ##################
							if {[regexp {loop} $whattype]} {
								set correctfilename [concat .apache/esd_$oldrulefile.res]
								if {![file exists $correctfilename]} {
										set correctfilename [concat .apache/ESD/esd_$oldrulefile.res]
								}
						                set ESDF [open $correctfilename r 0666]
						                while {[gets $ESDF esdline] >=0 } {
						                        if {[regexp $clampcell1 $esdline]} {
						                                regsub -all -- {[[:space:]]+} $esdline " " esdline
						                                set esdline [split $esdline]
						                                set clamp1_x [lindex $esdline 1]
						                                set clamp1_y [lindex $esdline 2]
										marker add  -position $clamp1_x $clamp1_y -color grey -size 10
					 					if {[regexp {pass} $passfail]} {
											plot line -position $pad1_x $pad1_y $clamp1_x $clamp1_y -color green -width 2
											#plot line -position $pad2_x $pad2_y $clamp_x $clamp_y -color green -width 2
										} else {
											plot line -position $pad1_x $pad1_y $clamp1_x $clamp1_y -color red -width 2
											#plot line -position $pad2_x $pad2_y $clamp_x $clamp_y -color red -width 2
										}
											
						                                break
						                        }
						                }
						                close $ESDF
							} ;#### End of if {[regexp {loop} $whattype]} 
					                #### end of  Open esd_<rulename>.res file to locate the clamps ##########
						}; #### End of else



						# For clampcell2
						if { $loopflag == 1} {
							foreach loopinlist "$looplist" {
								if {$loopinlist == $loop_id} {
									if {[regexp {loop} $whattype]} {
			                                                        set correctfilename [concat .apache/esd_$oldrulefile.res]
										if {![file exists $correctfilename]} {
											set correctfilename [concat .apache/ESD/esd_$oldrulefile.res]
										}
			                                                        set ESDF [open $correctfilename r 0666]
			                                                        while {[gets $ESDF esdline] >=0 } {
			                                                                if {[regexp $clampcell2 $esdline]} {
			                                                                        regsub -all -- {[[:space:]]+} $esdline " " esdline
			                                                                        set esdline [split $esdline]
			                                                                        set clamp2_x [lindex $esdline 1]
			                                                                        set clamp2_y [lindex $esdline 2]
                        			                                                marker add  -position $clamp2_x $clamp2_y -color grey -size 10
                                                			                        if {[regexp {pass} $passfail]} {
                                                                        			        #plot line -position $pad1_x $pad1_y $clamp_x $clamp_y -color green -width 2
                                			                                                plot line -position $pad2_x $pad2_y $clamp2_x $clamp2_y -color green -width 2
                                			                                        } else {
                                                        			                        #plot line -position $pad1_x $pad1_y $clamp_x $clamp_y -color red -width 2
                                			                                                plot line -position $pad2_x $pad2_y $clamp2_x $clamp2_y -color red -width 2
                                			                                        }
												plot line -position $clamp1_x $clamp1_y $clamp2_x $clamp2_y -color blue -width 2			
                        			                                                break
                                                			                }
			                                                        }
                        			                                close $ESDF
			                                                } ;#### End of if {[regexp {loop} $whattype]}
								};#### End of if {$loopinlist == loop_id}
							};#### End of foreach loopinlist "$looplist"
						} else { 

 
							#### If -restype is loop ####################################################
				                	#### Open esd_<rulename>.res file to locate the clamps ##################
							if {[regexp {loop} $whattype]} {
								set correctfilename [concat .apache/esd_$oldrulefile.res]
								if {![file exists $correctfilename]} {
										set correctfilename [concat .apache/ESD/esd_$oldrulefile.res]
								}
						                set ESDF [open $correctfilename r 0666]
						                while {[gets $ESDF esdline] >=0 } {
						                        if {[regexp $clampcell2 $esdline]} {
						                                regsub -all -- {[[:space:]]+} $esdline " " esdline
						                                set esdline [split $esdline]
						                                set clamp2_x [lindex $esdline 1]
						                                set clamp2_y [lindex $esdline 2]
										marker add  -position $clamp2_x $clamp2_y -color grey -size 10
					 					if {[regexp {pass} $passfail]} {
											#plot line -position $pad1_x $pad1_y $clamp_x $clamp_y -color green -width 2
											plot line -position $pad2_x $pad2_y $clamp2_x $clamp2_y -color green -width 2
										} else {
											#plot line -position $pad1_x $pad1_y $clamp_x $clamp_y -color red -width 2
											plot line -position $pad2_x $pad2_y $clamp2_x $clamp2_y -color red -width 2
										}
									        plot line -position $clamp1_x $clamp1_y $clamp2_x $clamp2_y -color blue -width 2
						                                break
						                        }
						                }
						                close $ESDF
							} ;#### End of if {[regexp {loop} $whattype]} 
					                #### end of  Open esd_<rulename>.res file to locate the clamps ##########
						}; #### End of else




						gets $RLRPT clamp
					} ;#### End of 	while {[regexp {:} $clamp] } 
		
				
					#### Else if -restype is parallel ###########################################
					#### get the parallel R information from <rulename>.rpt ######################
					if {[regexp {parallel} $whattype]} {
						set parallel $clamp
						regsub -all -- {[[:space:]]+} $parallel " " parallel
						set parallel [split $parallel]
						set this_is_parallel [lindex $parallel 0]	
						set this_is_R        [lindex $parallel 1]	
						set parR             [lindex $parallel 2]
						set par_passfail     [lindex $parallel 3]
						if {[regexp {pass} $par_passfail]} {
							plot line -position $pad1_x $pad1_y $pad2_x $pad2_y  -color green -width 2
						} else {
							plot line -position $pad1_x $pad1_y $pad2_x $pad2_y  -color red -width 2
						}
					
					} ;#### End of 	if {[regexp {parallel} $whattype]} 
					#### end of Else if -restype is parallel ####################################
				} ;#### End of if {$padinlist == $pad_id} 	
			} ;#### End of 	if {[regexp {^PADS} $line]}  
		} ;#### End of while { [gets $RLRPT line] >=0 } 
		close $RLRPT
	
	} ;#### End of foreach padinlist "$padlist"  		
	} ;#### End of else   ;#### Else if -bump_pair is specified
	
	
} ;#### End of proc atclDisplayRes91




proc atclDisplayRes91_case3 { args } {
regexp -all {\{(.*)\}} $args  match args; ### debug
set argv [split $args]
set argc [llength $argv]

#### Set the default parameters ###############################################################
set whattype "parallel"
set noofpads 0
set flagrule 0
set flagpassfail 0
set noofloops 0
set loopflag 0
#### Finish Set the default parameters ########################################################

#### Parse the arguments ######################################################################


for {set k 0} {$k < $argc} {incr k 1} { 
	if {[regexp {\-type} [lindex $argv $k]]} {
		set flagrule 1
	}
}


if {$flagrule == 0} {
	puts "Please specify a rule name"
	return
}
	
for {set k 0} {$k < $argc} {incr k 1} {
        if {[regexp {\-loop_id} [lindex $argv $k]]} {
                set loopflag 1
        }
}






if {$loopflag == 0} {
	for {set j 0} {$j < $argc} {incr j 1} {
	        if {[regexp {\-type} [lindex $argv $j]]} {
	                set rulefile [lindex $argv [expr $j + 1]]
	        } elseif  {[regexp {\-rule_file} [lindex $argv $j]]} {
	                set rfile [lindex $argv [expr $j + 1]]
	        } elseif  {[regexp {\-restype} [lindex $argv $j]]} {
	                set whattype [lindex $argv [expr $j + 1]]
	        } elseif  {[regexp {\-fail} [lindex $argv $j]]} {
	                set flagpassfail 1
	        } elseif  {[regexp {\-bump_pair} [lindex $argv $j]]} {
	                set noofpads [expr [expr $argc - 1] - $j]
	                for {set i [expr $j + 1]} {$i < $argc} {incr i 1} {
	                        lappend padlist [lindex $argv $i]
	                }
	        }
	}
} else {
	for {set j 0} {$j < $argc} {incr j 1} {
               if {[regexp {\-type} [lindex $argv $j]]} {
	               set rulefile [lindex $argv [expr $j + 1]]
	       } elseif  {[regexp {\-rule_file} [lindex $argv $j]]} {
                        set rfile [lindex $argv [expr $j + 1]]
               } elseif  {[regexp {\-restype} [lindex $argv $j]]} {
                       set whattype [lindex $argv [expr $j + 1]]
               } elseif  {[regexp {\-fail} [lindex $argv $j]]} {
                       set flagpassfail 1
               } elseif  {[regexp {\-bump_pair} [lindex $argv $j]]} {
                       set noofpads 1
                       lappend padlist [lindex $argv [expr $j + 1]]
               } elseif  {[regexp {\-loop_id} [lindex $argv $j]]} {
                       set noofloops [expr [expr $argc - 1] - $j]
                       for {set i [expr $j + 1]} {$i < $argc} {incr i 1} {
                               lappend looplist [lindex $argv $i]
                       }
               }
        }
}






















	
#set oldrulefile $rulefile
#set mynewrulefile $rulefile.rpt
#set rulefile $mynewrulefile

set C2Cfile "esd_C2C.res"
if {![file exists .apache/esd_C2C.res]} {
	set C2Cfile "ESD/esd_C2C.res"
}
if {![info exists rfile]} {
        set rulefile "esd_B2B.rpt"
        set oldrulefile "B2B"
} else {
        set RULE [open $rfile r 0666]
	while { [gets $RULE line] >=0 } {
                if {[regexp {NAME} $line]} {
                        regsub -all -- {[[:space:]]+} $line " " line
                        regsub -all -- {^[[:space:]]+} $line "" line
                        set line [split $line]
                        set rulename [lindex $line 1]
		}
	}

	set rulefile [concat esd_$rulename.rpt]
	set oldrulefile $rulename
}
#puts "\n $rulefile \n $oldrulefile"
#### Finish Parse the arguments ###############################################################



#### If -bump_pair option is not specified ####################################################
if {$noofpads == 0} {	
	plot line -clearall
	marker delete -all
	#### Open <rulename>.rpt file
	set RLRPT [open adsRpt/ESD/$rulefile r 0666]
	while { [gets $RLRPT line] >=0 } {
		if {[regexp {^PADS} $line]} { 
			regsub -all -- {[[:space:]]+} $line " " line
			set line [split $line]
			set pads      [lindex $line 0]
			set pad_id    [lindex $line 1]
			set pad1_name [lindex $line 2]
			set pad2_name [lindex $line 3]
			set pad1_x    [lindex [split [lindex $line 4] "("] 1]
			set pad1_y    [lindex [split [lindex $line 5] ")"] 0]
			set pad2_x    [lindex [split [lindex $line 6] "("] 1]
			set pad2_y    [lindex [split [lindex $line 7] ")"] 0]
			gets $RLRPT esd  ;    # Reads "EDS Loops"
			gets $RLRPT clamp ;   # Reads the first line for clamp
			while {[regexp {:} $clamp] } {
				regsub -all -- {[[:space:]]+} $clamp " " clamp
				set clamp [split $clamp]
				set this_is_space   [lindex $clamp 0]
				set loop_id   	    [lindex [split [lindex $clamp 1] ":"] 0]
				set passfail        [lindex [split [lindex $clamp 1] ":"] 1]
				set loop_r          [lindex $clamp 2]
				set pad1_tocr       [lindex $clamp 3]
				set pad2_tocr       [lindex $clamp 4]
				set clampcell       [lindex $clamp 5]

				#### If -restype is loop ####################################################
                		#### Open esd_<rulename>.res file to locate the clamps ##################
				if {[regexp {loop} $whattype]} {
                                        puts "Please provide bump IDs using the option, -bump_pair <bump_1 bump_2 ...>"
					return
#					set correctfilename [concat .apache/esd_$oldrulefile.res]
#			                set ESDF [open $correctfilename r 0666]
#			                while {[gets $ESDF esdline] >=0 } {
#			                        if {[regexp $clampcell $esdline]} {
#			                                regsub -all -- {[[:space:]]+} $esdline " " esdline
#			                                set esdline [split $esdline]
#			                                set clamp_x [lindex $esdline 1]
#			                                set clamp_y [lindex $esdline 2]
#							marker add -position $clamp_x $clamp_y -color grey -size 10
#		 					if {[regexp {pass} $passfail]} {
#								plot line -position $pad1_x $pad1_y $clamp_x $clamp_y -color green -width 2
#								plot line -position $pad2_x $pad2_y $clamp_x $clamp_y -color green -width 2
#							} else {
#								plot line -position $pad1_x $pad1_y $clamp_x $clamp_y -color red -width 2
#								plot line -position $pad2_x $pad2_y $clamp_x $clamp_y -color red -width 2
#							}
#								
#		                                break
#			                        }  ;#### End of if {[regexp $clampcell $esdline]} 
#			                } ;#### End of while
#			                close $ESDF
				} ;#### End of if {[regexp {loop} $whattype]} 
		                #### end of  Open esd_<rulename>.res file to locate the clamps ##########
				gets $RLRPT clamp
			} ;#### End of while {[regexp {:} $clamp] } 

	
			#### Else if -restype is parallel ###########################################
			#### get the parallel R information from <rulename>.rpt ######################
			if {[regexp {parallel} $whattype]} {
				set parallel $clamp
				regsub -all -- {[[:space:]]+} $parallel " " parallel
				set parallel [split $parallel]
				set this_is_parallel [lindex $parallel 0]	
				set this_is_R        [lindex $parallel 1]	
				set parR             [lindex $parallel 2]
				set par_passfail     [lindex $parallel 3]
				
				if {$flagpassfail == 1} {
					if {[regexp {pass} $par_passfail]} {
					} else {
						plot  line -position $pad1_x $pad1_y $pad2_x $pad2_y  -color red -width 2
					}
				} else {
					if {[regexp {pass} $par_passfail]} {
						plot  line -position $pad1_x $pad1_y $pad2_x $pad2_y  -color green -width 2
					} else {
						plot  line -position $pad1_x $pad1_y $pad2_x $pad2_y  -color red -width 2
					}
				}
					
		
			
			} ;#### End of if {[regexp {parallel} $whattype]} 
			#### end of Else if -restype is parallel ####################################
		} ;#### End of 	if {[regexp {^PADS} $line]}  
	} ;#### End of while { [gets $RLRPT line] >=0 } 
	close $RLRPT

} else  { ;#### Else if -bump_pair is specified
	plot line -clearll
	marker delete -all
	foreach padinlist "$padlist"  {		
		set RLRPT [open adsRpt/ESD/$rulefile r 0666]
		
		while { [gets $RLRPT line] >=0 } {
			if {[regexp {^PADS} $line]} { 
				regsub -all -- {[[:space:]]+} $line " " line
				set line [split $line]
				set pads      [lindex $line 0]
				set pad_id    [lindex $line 1]
				set pad1_name [lindex $line 2]
				set pad2_name [lindex $line 3]
				set pad1_x    [lindex [split [lindex $line 4] "("] 1]
				set pad1_y    [lindex [split [lindex $line 5] ")"] 0]
				set pad2_x    [lindex [split [lindex $line 6] "("] 1]
				set pad2_y    [lindex [split [lindex $line 7] ")"] 0]
				if {$padinlist == $pad_id} {	
					gets $RLRPT esd  ;    # Reads "EDS Loops"
					gets $RLRPT clamp ;   # Reads the first line for clamp
					while {[regexp {:} $clamp] } {
						regsub -all -- {[[:space:]]+} $clamp " " clamp
						set clamp [split $clamp]
						set this_is_space   [lindex $clamp 0]
						set loop_id   	    [lindex [split [lindex $clamp 1] ":"] 0]
						set passfail        [lindex [split [lindex $clamp 1] ":"] 1]
						set loop_r          [lindex $clamp 2]
						set pad1_tocr       [lindex $clamp 3]
						set pad2_tocr       [lindex $clamp 4]
						set clampcell1      [lindex [split [lindex $clamp 5] "("] 0]
						set eqclampcell1    [lindex [split [lindex [split [lindex $clamp 5] "("] 1] ")"] 0]
					#	set vddbus          [lindex $clamp 7]
					#	set clampcell2      [lindex [split [lindex $clamp 8] "("] 0]
					#	set eqclampcell2    [lindex [split [lindex [split [lindex $clamp 8] "("] 1] ")"] 0]


			                        
										set C2C [open .apache/$C2Cfile r 0666]
                                                                                while {[gets $C2C c2cline] >=0 } {
                                                                                        if {[regexp $eqclampcell1 $c2cline]} {
                                                                                                regsub -all -- {[[:space:]]+} $c2cline " " c2cline
                                                                                                set c2cline [split $c2cline]
                                                                                                set eqclamp1_x [lindex $c2cline 1]
                                                                                                set eqclamp1_y [lindex $c2cline 2]
                                                                                            }
										} 



						# For clampcell1
						if { $loopflag == 1} {
							foreach loopinlist "$looplist" {
								if {$loopinlist == $loop_id} {
									if {[regexp {loop} $whattype]} {
			                                                        set correctfilename [concat .apache/esd_$oldrulefile.res]
										if {![file exists $correctfilename]} {
											set correctfilename [concat .apache/ESD/esd_$oldrulefile.res]
										}
			                                                        set ESDF [open $correctfilename r 0666]
			                                                        while {[gets $ESDF esdline] >=0 } {
			                                                                if {[regexp $clampcell1 $esdline]} {
			                                                                        regsub -all -- {[[:space:]]+} $esdline " " esdline
			                                                                        set esdline [split $esdline]
			                                                                        set clamp1_x [lindex $esdline 1]
			                                                                        set clamp1_y [lindex $esdline 2]
                        			                                                marker add  -position $clamp1_x $clamp1_y -color grey -size 10
                                                			                        if {[regexp {pass} $passfail]} {
                                                                        			        plot line -position $pad1_x $pad1_y $clamp1_x $clamp1_y -color green -width 2
                                			                                                plot line -position $pad2_x $pad2_y $eqclamp1_x $eqclamp1_y -color green -width 2
                                			                                        } else {
                                                        			                        plot line -position $pad1_x $pad1_y $clamp1_x $clamp1_y -color red -width 2
                                			                                                plot line -position $pad2_x $pad2_y $eqclamp1_x $eqclamp1_y -color red -width 2
                                			                                        }
                                                                                                plot line -position $clamp1_x $clamp1_y $eqclamp1_x $eqclamp1_y -color yellow -width 2
                                                                                                marker add  -position $eqclamp1_x $eqclamp1_y -color grey -size 10
			
                        			                                                break
                                                			                }
			                                                        }
                        			                                close $ESDF
			                                                } ;#### End of if {[regexp {loop} $whattype]}
								};#### End of if {$loopinlist == loop_id}
							};#### End of foreach loopinlist "$looplist"
						} else { 

 
							#### If -restype is loop ####################################################
				                	#### Open esd_<rulename>.res file to locate the clamps ##################
							if {[regexp {loop} $whattype]} {
								set correctfilename [concat .apache/esd_$oldrulefile.res]
								if {![file exists $correctfilename]} {
										set correctfilename [concat .apache/ESD/esd_$oldrulefile.res]
								}
						                set ESDF [open $correctfilename r 0666]
						                while {[gets $ESDF esdline] >=0 } {
						                        if {[regexp $clampcell1 $esdline]} {
						                                regsub -all -- {[[:space:]]+} $esdline " " esdline
						                                set esdline [split $esdline]
						                                set clamp1_x [lindex $esdline 1]
						                                set clamp1_y [lindex $esdline 2]
										marker add  -position $clamp1_x $clamp1_y -color grey -size 10
					 					if {[regexp {pass} $passfail]} {
											plot line -position $pad1_x $pad1_y $clamp1_x $clamp1_y -color green -width 2
											plot line -position $pad2_x $pad2_y $eqclamp1_x $eqclamp1_y -color green -width 2
										} else {
											plot line -position $pad1_x $pad1_y $clamp1_x $clamp1_y -color red -width 2
											plot line -position $pad2_x $pad2_y $eqclamp1_x $eqclamp1_y -color red -width 2
										}
                                                                                plot line -position $clamp1_x $clamp1_y $eqclamp1_x $eqclamp1_y -color yellow -width 2
                                                                                marker add  -position $eqclamp1_x $eqclamp1_y -color grey -size 10
			
											
						                                break
						                        }
						                }
						                close $ESDF
							} ;#### End of if {[regexp {loop} $whattype]} 
					                #### end of  Open esd_<rulename>.res file to locate the clamps ##########
						}; #### End of else








									#	set C2C [open .apache/$C2Cfile r 0666]
                                                                        #        while {[gets $C2C c2cline] >=0 } {
                                                                        #                if {[regexp $eqclampcell2 $c2cline]} {
                                                                        #                        regsub -all -- {[[:space:]]+} $c2cline " " c2cline
                                                                        #                        set c2cline [split $c2cline]
                                                                        #                        set eqclamp2_x [lindex $c2cline 1]
                                                                        #                        set eqclamp2_y [lindex $c2cline 2]
                                                                        #                        #marker add  -position $eqclamp2_x $eqclamp2_y -color grey -size 10
                                                                        #                        #plot line -position $clamp2_x $clamp2_y $eqclamp2_x $eqclamp2_y -color yellow -width 2
                                                                        #                    }
								#		}






						#clampcell 2 is not required	
						if {0} {
						# For clampcell2
						if { $loopflag == 1} {
							foreach loopinlist "$looplist" {
								if {$loopinlist == $loop_id} {
									if {[regexp {loop} $whattype]} {
			                                                        set correctfilename [concat .apache/esd_$oldrulefile.res]
										if {![file exists $correctfilename]} {
											set correctfilename [concat .apache/ESD/esd_$oldrulefile.res]
										}
			                                                        set ESDF [open $correctfilename r 0666]
			                                                        while {[gets $ESDF esdline] >=0 } {
			                                                                if {[regexp $clampcell2 $esdline]} {
			                                                                        regsub -all -- {[[:space:]]+} $esdline " " esdline
			                                                                        set esdline [split $esdline]
			                                                                        set clamp2_x [lindex $esdline 1]
			                                                                        set clamp2_y [lindex $esdline 2]
                        			                                                marker add  -position $clamp2_x $clamp2_y -color grey -size 10
                                                			                        if {[regexp {pass} $passfail]} {
                                                                        			        #plot line -position $pad1_x $pad1_y $clamp_x $clamp_y -color green -width 2
                                			                                                plot line -position $pad2_x $pad2_y $clamp2_x $clamp2_y -color green -width 2
                                			                                        } else {
                                                        			                        #plot line -position $pad1_x $pad1_y $clamp_x $clamp_y -color red -width 2
                                			                                                plot line -position $pad2_x $pad2_y $clamp2_x $clamp2_y -color red -width 2
                                			                                        }
												#plot line -position $clamp1_x $clamp1_y $clamp2_x $clamp2_y -color blue -width 2			
                                                                                                plot line -position $clamp1_x $clamp1_y $eqclamp1_x $eqclamp1_y -color yellow -width 2
                                                                                                plot line -position $clamp2_x $clamp2_y $eqclamp2_x $eqclamp2_y -color yellow -width 2
												plot line -position $eqclamp1_x $eqclamp1_y $eqclamp2_x $eqclamp2_y -color blue -width 2
                                                                                                marker add  -position $eqclamp1_x $eqclamp1_y -color grey -size 10
                                                                                                marker add  -position $eqclamp2_x $eqclamp2_y -color grey -size 10
                        			                                                break
                                                			                }
			                                                        }
                        			                                close $ESDF
			                                                } ;#### End of if {[regexp {loop} $whattype]}
								};#### End of if {$loopinlist == loop_id}
							};#### End of foreach loopinlist "$looplist"
						} else { 

 
							#### If -restype is loop ####################################################
				                	#### Open esd_<rulename>.res file to locate the clamps ##################
							if {[regexp {loop} $whattype]} {
								set correctfilename [concat .apache/esd_$oldrulefile.res]
								if {![file exists $correctfilename]} {
									set correctfilename [concat .apache/ESD/esd_$oldrulefile.res]
								}
						                set ESDF [open $correctfilename r 0666]
						                while {[gets $ESDF esdline] >=0 } {
						                        if {[regexp $clampcell2 $esdline]} {
						                                regsub -all -- {[[:space:]]+} $esdline " " esdline
						                                set esdline [split $esdline]
						                                set clamp2_x [lindex $esdline 1]
						                                set clamp2_y [lindex $esdline 2]
										marker add  -position $clamp2_x $clamp2_y -color grey -size 10
					 					if {[regexp {pass} $passfail]} {
											#plot line -position $pad1_x $pad1_y $clamp_x $clamp_y -color green -width 2
											plot line -position $pad2_x $pad2_y $clamp2_x $clamp2_y -color green -width 2
										} else {
											#plot line -position $pad1_x $pad1_y $clamp_x $clamp_y -color red -width 2
											plot line -position $pad2_x $pad2_y $clamp2_x $clamp2_y -color red -width 2
										}
									        #plot line -position $clamp1_x $clamp1_y $clamp2_x $clamp2_y -color blue -width 2
                                                                                                plot line -position $clamp1_x $clamp1_y $eqclamp1_x $eqclamp1_y -color yellow -width 2
                                                                                                plot line -position $clamp2_x $clamp2_y $eqclamp2_x $eqclamp2_y -color yellow -width 2
												plot line -position $eqclamp1_x $eqclamp1_y $eqclamp2_x $eqclamp2_y -color blue -width 2
                                                                                                marker add  -position $eqclamp1_x $eqclamp1_y -color grey -size 10
                                                                                                marker add  -position $eqclamp2_x $eqclamp2_y -color grey -size 10
						                                break
						                        }
						                }
						                close $ESDF
							} ;#### End of if {[regexp {loop} $whattype]} 
					                #### end of  Open esd_<rulename>.res file to locate the clamps ##########
						}; #### End of else
						} ; #### end of if 0








 
						gets $RLRPT clamp
					} ;#### End of 	while {[regexp {:} $clamp] } 
		
				
					#### Else if -restype is parallel ###########################################
					#### get the parallel R information from <rulename>.rpt ######################
					if {[regexp {parallel} $whattype]} {
						set parallel $clamp
						regsub -all -- {[[:space:]]+} $parallel " " parallel
						set parallel [split $parallel]
						set this_is_parallel [lindex $parallel 0]	
						set this_is_R        [lindex $parallel 1]	
						set parR             [lindex $parallel 2]
						set par_passfail     [lindex $parallel 3]
						if {[regexp {pass} $par_passfail]} {
							plot line -position $pad1_x $pad1_y $pad2_x $pad2_y  -color green -width 2
						} else {
							plot line -position $pad1_x $pad1_y $pad2_x $pad2_y  -color red -width 2
						}
					
					} ;#### End of 	if {[regexp {parallel} $whattype]} 
					#### end of Else if -restype is parallel ####################################
				} ;#### End of if {$padinlist == $pad_id} 	
			} ;#### End of 	if {[regexp {^PADS} $line]}  
		} ;#### End of while { [gets $RLRPT line] >=0 } 
		close $RLRPT
	
	} ;#### End of foreach padinlist "$padlist"  		
	} ;#### End of else   ;#### Else if -bump_pair is specified
	
	
} ;#### End of proc atclDisplayRes91




	



proc atclDisplayRes91_case4 { args } {
regexp -all {\{(.*)\}} $args  match args; ### debug
set argv [split $args]
set argc [llength $argv]

#### Set the default parameters ###############################################################
set whattype "parallel"
set noofpads 0
set flagrule 0
set flagpassfail 0
set noofloops 0
set loopflag 0
#### Finish Set the default parameters ########################################################

#### Parse the arguments ######################################################################


for {set k 0} {$k < $argc} {incr k 1} { 
	if {[regexp {\-type} [lindex $argv $k]]} {
		set flagrule 1
	}
}


if {$flagrule == 0} {
	puts "Please specify a rule name"
	return
}
	
for {set k 0} {$k < $argc} {incr k 1} {
        if {[regexp {\-loop_id} [lindex $argv $k]]} {
                set loopflag 1
        }
}






if {$loopflag == 0} {
	for {set j 0} {$j < $argc} {incr j 1} {
	        if {[regexp {\-type} [lindex $argv $j]]} {
	                set rulefile [lindex $argv [expr $j + 1]]
	        } elseif  {[regexp {\-rule_file} [lindex $argv $j]]} {
	                set rfile [lindex $argv [expr $j + 1]]
	        } elseif  {[regexp {\-restype} [lindex $argv $j]]} {
	                set whattype [lindex $argv [expr $j + 1]]
	        } elseif  {[regexp {\-fail} [lindex $argv $j]]} {
	                set flagpassfail 1
	        } elseif  {[regexp {\-bump_pair} [lindex $argv $j]]} {
	                set noofpads [expr [expr $argc - 1] - $j]
	                for {set i [expr $j + 1]} {$i < $argc} {incr i 1} {
	                        lappend padlist [lindex $argv $i]
	                }
	        }
	}
} else {
	for {set j 0} {$j < $argc} {incr j 1} {
               if {[regexp {\-type} [lindex $argv $j]]} {
	               set rulefile [lindex $argv [expr $j + 1]]
               } elseif  {[regexp {\-rule_file} [lindex $argv $j]]} {
                        set rfile [lindex $argv [expr $j + 1]]
               } elseif  {[regexp {\-restype} [lindex $argv $j]]} {
                       set whattype [lindex $argv [expr $j + 1]]
               } elseif  {[regexp {\-fail} [lindex $argv $j]]} {
                       set flagpassfail 1
               } elseif  {[regexp {\-bump_pair} [lindex $argv $j]]} {
                       set noofpads 1
                       lappend padlist [lindex $argv [expr $j + 1]]
               } elseif  {[regexp {\-loop_id} [lindex $argv $j]]} {
                       set noofloops [expr [expr $argc - 1] - $j]
                       for {set i [expr $j + 1]} {$i < $argc} {incr i 1} {
                               lappend looplist [lindex $argv $i]
                       }
               }
        }
}






















	
#set oldrulefile $rulefile
#set mynewrulefile $rulefile.rpt
#set rulefile $mynewrulefile

set C2Cfile "esd_C2C.res"
if {![file exists .apache/esd_C2C.res]} {
	set C2Cfile "ESD/esd_C2C.res"
}
if {![info exists rfile]} {
        set rulefile "esd_B2B.rpt"
        set oldrulefile "B2B"
} else {
        set RULE [open $rfile r 0666]
	while { [gets $RULE line] >=0 } {
                if {[regexp {NAME} $line]} {
                        regsub -all -- {[[:space:]]+} $line " " line
                        regsub -all -- {^[[:space:]]+} $line "" line
                        set line [split $line]
                        set rulename [lindex $line 1]
		}
	}

	set rulefile [concat esd_$rulename.rpt]
	set oldrulefile $rulename
}
#puts "\n $rulefile \n $oldrulefile"
#### Finish Parse the arguments ###############################################################



#### If -bump_pair option is not specified ####################################################
if {$noofpads == 0} {	
	plot line -clearall
	marker delete -all
	#### Open <rulename>.rpt file
	set RLRPT [open adsRpt/ESD/$rulefile r 0666]
	while { [gets $RLRPT line] >=0 } {
		if {[regexp {^PADS} $line]} { 
			regsub -all -- {[[:space:]]+} $line " " line
			set line [split $line]
			set pads      [lindex $line 0]
			set pad_id    [lindex $line 1]
			set pad1_name [lindex $line 2]
			set pad2_name [lindex $line 3]
			set pad1_x    [lindex [split [lindex $line 4] "("] 1]
			set pad1_y    [lindex [split [lindex $line 5] ")"] 0]
			set pad2_x    [lindex [split [lindex $line 6] "("] 1]
			set pad2_y    [lindex [split [lindex $line 7] ")"] 0]
			gets $RLRPT esd  ;    # Reads "EDS Loops"
			gets $RLRPT clamp ;   # Reads the first line for clamp
			while {[regexp {:} $clamp] } {
				regsub -all -- {[[:space:]]+} $clamp " " clamp
				set clamp [split $clamp]
				set this_is_space   [lindex $clamp 0]
				set loop_id   	    [lindex [split [lindex $clamp 1] ":"] 0]
				set passfail        [lindex [split [lindex $clamp 1] ":"] 1]
				set loop_r          [lindex $clamp 2]
				set pad1_tocr       [lindex $clamp 3]
				set pad2_tocr       [lindex $clamp 4]
				set clampcell       [lindex $clamp 5]

				#### If -restype is loop ####################################################
                		#### Open esd_<rulename>.res file to locate the clamps ##################
				if {[regexp {loop} $whattype]} {
                                        puts "Please provide bump IDs using the option, -bump_pair <bump_1 bump_2 ...>"
					return
#					set correctfilename [concat .apache/esd_$oldrulefile.res]
#			                set ESDF [open $correctfilename r 0666]
#			                while {[gets $ESDF esdline] >=0 } {
#			                        if {[regexp $clampcell $esdline]} {
#			                                regsub -all -- {[[:space:]]+} $esdline " " esdline
#			                                set esdline [split $esdline]
#			                                set clamp_x [lindex $esdline 1]
#			                                set clamp_y [lindex $esdline 2]
#							marker add -position $clamp_x $clamp_y -color grey -size 10
#		 					if {[regexp {pass} $passfail]} {
#								plot line -position $pad1_x $pad1_y $clamp_x $clamp_y -color green -width 2
#								plot line -position $pad2_x $pad2_y $clamp_x $clamp_y -color green -width 2
#							} else {
#								plot line -position $pad1_x $pad1_y $clamp_x $clamp_y -color red -width 2
#								plot line -position $pad2_x $pad2_y $clamp_x $clamp_y -color red -width 2
#							}
#								
#		                                break
#			                        }  ;#### End of if {[regexp $clampcell $esdline]} 
#			                } ;#### End of while
#			                close $ESDF
				} ;#### End of if {[regexp {loop} $whattype]} 
		                #### end of  Open esd_<rulename>.res file to locate the clamps ##########
				gets $RLRPT clamp
			} ;#### End of while {[regexp {:} $clamp] } 

	
			#### Else if -restype is parallel ###########################################
			#### get the parallel R information from <rulename>.rpt ######################
			if {[regexp {parallel} $whattype]} {
				set parallel $clamp
				regsub -all -- {[[:space:]]+} $parallel " " parallel
				set parallel [split $parallel]
				set this_is_parallel [lindex $parallel 0]	
				set this_is_R        [lindex $parallel 1]	
				set parR             [lindex $parallel 2]
				set par_passfail     [lindex $parallel 3]
				
				if {$flagpassfail == 1} {
					if {[regexp {pass} $par_passfail]} {
					} else {
						plot  line -position $pad1_x $pad1_y $pad2_x $pad2_y  -color red -width 2
					}
				} else {
					if {[regexp {pass} $par_passfail]} {
						plot  line -position $pad1_x $pad1_y $pad2_x $pad2_y  -color green -width 2
					} else {
						plot  line -position $pad1_x $pad1_y $pad2_x $pad2_y  -color red -width 2
					}
				}
					
		
			
			} ;#### End of if {[regexp {parallel} $whattype]} 
			#### end of Else if -restype is parallel ####################################
		} ;#### End of 	if {[regexp {^PADS} $line]}  
	} ;#### End of while { [gets $RLRPT line] >=0 } 
	close $RLRPT

} else  { ;#### Else if -bump_pair is specified
	plot line -clearll
	marker delete -all
	foreach padinlist "$padlist"  {		
		set RLRPT [open adsRpt/ESD/$rulefile r 0666]
		
		while { [gets $RLRPT line] >=0 } {
			if {[regexp {^PADS} $line]} { 
				regsub -all -- {[[:space:]]+} $line " " line
				set line [split $line]
				set pads      [lindex $line 0]
				set pad_id    [lindex $line 1]
				set pad1_name [lindex $line 2]
				set pad2_name [lindex $line 3]
				set pad1_x    [lindex [split [lindex $line 4] "("] 1]
				set pad1_y    [lindex [split [lindex $line 5] ")"] 0]
				set pad2_x    [lindex [split [lindex $line 6] "("] 1]
				set pad2_y    [lindex [split [lindex $line 7] ")"] 0]
				if {$padinlist == $pad_id} {	
					gets $RLRPT esd  ;    # Reads "EDS Loops"
					gets $RLRPT clamp ;   # Reads the first line for clamp
					while {[regexp {:} $clamp] } {
						regsub -all -- {[[:space:]]+} $clamp " " clamp
						set clamp [split $clamp]
						set this_is_space   [lindex $clamp 0]
						set loop_id   	    [lindex [split [lindex $clamp 1] ":"] 0]
						set passfail        [lindex [split [lindex $clamp 1] ":"] 1]
						set loop_r          [lindex $clamp 2]
						set pad1_tocr       [lindex $clamp 3]
						set pad2_tocr       [lindex $clamp 4]
						set clampcell1      [lindex [split [lindex $clamp 6] "("] 0]
						set eqclampcell1    [lindex [split [lindex [split [lindex $clamp 6] "("] 1] ")"] 0]
						set vddbus          [lindex $clamp 7]
						set clampcell2      [lindex [split [lindex $clamp 8] "("] 0]
						set eqclampcell2    [lindex [split [lindex [split [lindex $clamp 8] "("] 1] ")"] 0]
			                        
						# For clampcell1
						if { $loopflag == 1} {
							foreach loopinlist "$looplist" {
								if {$loopinlist == $loop_id} {
									if {[regexp {loop} $whattype]} {
			                                                        set correctfilename [concat .apache/esd_$oldrulefile.res]
										if {![file exists $correctfilename]} {
											set correctfilename [concat .apache/ESD/esd_$oldrulefile.res]
										}
			                                                        set ESDF [open $correctfilename r 0666]
			                                                        while {[gets $ESDF esdline] >=0 } {
			                                                                if {[regexp $clampcell1 $esdline]} {
			                                                                        regsub -all -- {[[:space:]]+} $esdline " " esdline
			                                                                        set esdline [split $esdline]
			                                                                        set clamp1_x [lindex $esdline 1]
			                                                                        set clamp1_y [lindex $esdline 2]
                        			                                                marker add  -position $clamp1_x $clamp1_y -color grey -size 10
                                                			                        if {[regexp {pass} $passfail]} {
                                                                        			        plot line -position $pad1_x $pad1_y $clamp1_x $clamp1_y -color green -width 2
                                			                                                #plot line -position $pad2_x $pad2_y $clamp_x $clamp_y -color green -width 2
                                			                                        } else {
                                                        			                        plot line -position $pad1_x $pad1_y $clamp1_x $clamp1_y -color red -width 2
                                			                                                #plot line -position $pad2_x $pad2_y $clamp_x $clamp_y -color red -width 2
                                			                                        }
			
                        			                                                break
                                                			                }
			                                                        }
                        			                                close $ESDF
			                                                } ;#### End of if {[regexp {loop} $whattype]}
								};#### End of if {$loopinlist == loop_id}
							};#### End of foreach loopinlist "$looplist"
						} else { 

 
							#### If -restype is loop ####################################################
				                	#### Open esd_<rulename>.res file to locate the clamps ##################
							if {[regexp {loop} $whattype]} {
								set correctfilename [concat .apache/esd_$oldrulefile.res]
								if {![file exists $correctfilename]} {
										set correctfilename [concat .apache/ESD/esd_$oldrulefile.res]
								}
						                set ESDF [open $correctfilename r 0666]
						                while {[gets $ESDF esdline] >=0 } {
						                        if {[regexp $clampcell1 $esdline]} {
						                                regsub -all -- {[[:space:]]+} $esdline " " esdline
						                                set esdline [split $esdline]
						                                set clamp1_x [lindex $esdline 1]
						                                set clamp1_y [lindex $esdline 2]
										marker add  -position $clamp1_x $clamp1_y -color grey -size 10
					 					if {[regexp {pass} $passfail]} {
											plot line -position $pad1_x $pad1_y $clamp1_x $clamp1_y -color green -width 2
											#plot line -position $pad2_x $pad2_y $clamp_x $clamp_y -color green -width 2
										} else {
											plot line -position $pad1_x $pad1_y $clamp1_x $clamp1_y -color red -width 2
											#plot line -position $pad2_x $pad2_y $clamp_x $clamp_y -color red -width 2
										}
											
						                                break
						                        }
						                }
						                close $ESDF
							} ;#### End of if {[regexp {loop} $whattype]} 
					                #### end of  Open esd_<rulename>.res file to locate the clamps ##########
						}; #### End of else






										set C2C [open .apache/$C2Cfile r 0666]
                                                                                while {[gets $C2C c2cline] >=0 } {
                                                                                        if {[regexp $eqclampcell1 $c2cline]} {
                                                                                                regsub -all -- {[[:space:]]+} $c2cline " " c2cline
                                                                                                set c2cline [split $c2cline]
                                                                                                set eqclamp1_x [lindex $c2cline 1]
                                                                                                set eqclamp1_y [lindex $c2cline 2]
                                                                                                #marker add  -position $eqclamp1_x $eqclamp1_y -color grey -size 10
                                                                                                #plot line -position $clamp1_x $clamp1_y $eqclamp1_x $eqclamp1_y -color yellow -width 2
                                                                                            }
										} 


										set C2C [open .apache/$C2Cfile r 0666]
                                                                                while {[gets $C2C c2cline] >=0 } {
                                                                                        if {[regexp $eqclampcell2 $c2cline]} {
                                                                                                regsub -all -- {[[:space:]]+} $c2cline " " c2cline
                                                                                                set c2cline [split $c2cline]
                                                                                                set eqclamp2_x [lindex $c2cline 1]
                                                                                                set eqclamp2_y [lindex $c2cline 2]
                                                                                                #marker add  -position $eqclamp2_x $eqclamp2_y -color grey -size 10
                                                                                                #plot line -position $clamp2_x $clamp2_y $eqclamp2_x $eqclamp2_y -color yellow -width 2
                                                                                            }
										}








						# For clampcell2
						if { $loopflag == 1} {
							foreach loopinlist "$looplist" {
								if {$loopinlist == $loop_id} {
									if {[regexp {loop} $whattype]} {
			                                                        set correctfilename [concat .apache/esd_$oldrulefile.res]
										if {![file exists $correctfilename]} {
											set correctfilename [concat .apache/ESD/esd_$oldrulefile.res]
										}
			                                                        set ESDF [open $correctfilename r 0666]
			                                                        while {[gets $ESDF esdline] >=0 } {
			                                                                if {[regexp $clampcell2 $esdline]} {
			                                                                        regsub -all -- {[[:space:]]+} $esdline " " esdline
			                                                                        set esdline [split $esdline]
			                                                                        set clamp2_x [lindex $esdline 1]
			                                                                        set clamp2_y [lindex $esdline 2]
                        			                                                marker add  -position $clamp2_x $clamp2_y -color grey -size 10
                                                			                        if {[regexp {pass} $passfail]} {
                                                                        			        #plot line -position $pad1_x $pad1_y $clamp_x $clamp_y -color green -width 2
                                			                                                plot line -position $pad2_x $pad2_y $clamp2_x $clamp2_y -color green -width 2
                                			                                        } else {
                                                        			                        #plot line -position $pad1_x $pad1_y $clamp_x $clamp_y -color red -width 2
                                			                                                plot line -position $pad2_x $pad2_y $clamp2_x $clamp2_y -color red -width 2
                                			                                        }
												#plot line -position $clamp1_x $clamp1_y $clamp2_x $clamp2_y -color blue -width 2			
                                                                                                plot line -position $clamp1_x $clamp1_y $eqclamp1_x $eqclamp1_y -color yellow -width 2
                                                                                                plot line -position $clamp2_x $clamp2_y $eqclamp2_x $eqclamp2_y -color yellow -width 2
												plot line -position $eqclamp1_x $eqclamp1_y $eqclamp2_x $eqclamp2_y -color blue -width 2
                                                                                                marker add  -position $eqclamp1_x $eqclamp1_y -color grey -size 10
                                                                                                marker add  -position $eqclamp2_x $eqclamp2_y -color grey -size 10
                        			                                                break
                                                			                }
			                                                        }
                        			                                close $ESDF
			                                                } ;#### End of if {[regexp {loop} $whattype]}
								};#### End of if {$loopinlist == loop_id}
							};#### End of foreach loopinlist "$looplist"
						} else { 

 
							#### If -restype is loop ####################################################
				                	#### Open esd_<rulename>.res file to locate the clamps ##################
							if {[regexp {loop} $whattype]} {
								set correctfilename [concat .apache/esd_$oldrulefile.res]
								if {![file exists $correctfilename]} {
										set correctfilename [concat .apache/ESD/esd_$oldrulefile.res]
								}
						                set ESDF [open $correctfilename r 0666]
						                while {[gets $ESDF esdline] >=0 } {
						                        if {[regexp $clampcell2 $esdline]} {
						                                regsub -all -- {[[:space:]]+} $esdline " " esdline
						                                set esdline [split $esdline]
						                                set clamp2_x [lindex $esdline 1]
						                                set clamp2_y [lindex $esdline 2]
										marker add  -position $clamp2_x $clamp2_y -color grey -size 10
					 					if {[regexp {pass} $passfail]} {
											#plot line -position $pad1_x $pad1_y $clamp_x $clamp_y -color green -width 2
											plot line -position $pad2_x $pad2_y $clamp2_x $clamp2_y -color green -width 2
										} else {
											#plot line -position $pad1_x $pad1_y $clamp_x $clamp_y -color red -width 2
											plot line -position $pad2_x $pad2_y $clamp2_x $clamp2_y -color red -width 2
										}
									        #plot line -position $clamp1_x $clamp1_y $clamp2_x $clamp2_y -color blue -width 2
                                                                                                plot line -position $clamp1_x $clamp1_y $eqclamp1_x $eqclamp1_y -color yellow -width 2
                                                                                                plot line -position $clamp2_x $clamp2_y $eqclamp2_x $eqclamp2_y -color yellow -width 2
												plot line -position $eqclamp1_x $eqclamp1_y $eqclamp2_x $eqclamp2_y -color blue -width 2
                                                                                                marker add  -position $eqclamp1_x $eqclamp1_y -color grey -size 10
                                                                                                marker add  -position $eqclamp2_x $eqclamp2_y -color grey -size 10
						                                break
						                        }
						                }
						                close $ESDF
							} ;#### End of if {[regexp {loop} $whattype]} 
					                #### end of  Open esd_<rulename>.res file to locate the clamps ##########
						}; #### End of else









 
						gets $RLRPT clamp
					} ;#### End of 	while {[regexp {:} $clamp] } 
		
				
					#### Else if -restype is parallel ###########################################
					#### get the parallel R information from <rulename>.rpt ######################
					if {[regexp {parallel} $whattype]} {
						set parallel $clamp
						regsub -all -- {[[:space:]]+} $parallel " " parallel
						set parallel [split $parallel]
						set this_is_parallel [lindex $parallel 0]	
						set this_is_R        [lindex $parallel 1]	
						set parR             [lindex $parallel 2]
						set par_passfail     [lindex $parallel 3]
						if {[regexp {pass} $par_passfail]} {
							plot line -position $pad1_x $pad1_y $pad2_x $pad2_y  -color green -width 2
						} else {
							plot line -position $pad1_x $pad1_y $pad2_x $pad2_y  -color red -width 2
						}
					
					} ;#### End of 	if {[regexp {parallel} $whattype]} 
					#### end of Else if -restype is parallel ####################################
				} ;#### End of if {$padinlist == $pad_id} 	
			} ;#### End of 	if {[regexp {^PADS} $line]}  
		} ;#### End of while { [gets $RLRPT line] >=0 } 
		close $RLRPT
	
	} ;#### End of foreach padinlist "$padlist"  		
	} ;#### End of else   ;#### Else if -bump_pair is specified
	
	
} ;#### End of proc atclDisplayRes91




proc atclDisplayRes91_BUMP2CLAMP {args} {
regexp -all {\{(.*)\}} $args  match args; 
set argv [split $args]
set argc [llength $argv]
                                                                                                                                                            
#### Set the default parameters ###############################################################
set flagfail 0
set flagallfail 0
#### Finish Set the default parameters ########################################################
                                                                                                                                                            
#### Parse the arguments ######################################################################
                                                                                                                                                            
                                                                                                                                                            
for {set j 0} {$j < $argc} {incr j 1} {
	if {[regexp {\-type} [lindex $argv $j]]} {
        	set rulefile [lindex $argv [expr $j + 1]]
       	} elseif  {[regexp {\-rule_file} [lindex $argv $j]]} {
        	set rfile [lindex $argv [expr $j + 1]]
       	} elseif  {[regexp {\-pad_id} [lindex $argv $j]]} {
                set pad_id [lindex $argv [expr $j + 1]]
        } elseif  {[regexp {\-fail} [lindex $argv $j]]} {
                set flagfail 1
        } elseif  {[regexp {\-all_fail} [lindex $argv $j]]} {
                set flagallfail 1
	}
}

if {![info exists rulefile]} {
	puts "\n-type option is required"
	return
}

	


if {![info exists rfile]} {
        set rulefile "esd_B2C.rpt"
} else {
        set RULE [open $rfile r 0666]
        while { [gets $RULE line] >=0 } {
                if {[regexp {NAME} $line]} {
                        regsub -all -- {[[:space:]]+} $line " " line
                        regsub -all -- {^[[:space:]]+} $line "" line
                        set line [split $line]
                        set rulename [lindex $line 1]
                }
        }
                                                                                                                                                            
        set rulefile [concat esd_$rulename.rpt]
}


if {$flagallfail == 0 && ![info exists pad_id]} {
	puts "-pad_id is required"
	return
}

plot line -clearall
marker delete -all

if {$flagallfail == 1} {
	set RLRPT [open adsRpt/ESD/$rulefile r 0666]
        while {[gets $RLRPT line] >= 0} {
                if {[regexp {Pad} $line]} {
                        regsub -all -- {[[:space:]]+} $line " " line
                        set line [split $line]
                        set pad_x      [lindex [split [lindex $line 2] "("] 1]
                        set pad_y    [lindex $line 3]
                        gets $RLRPT line
                        gets $RLRPT line
                        while {![regexp {^#\s*$} $line]} {
                        	if {[regexp {^=====*} $line]} {
                                	break
                                }
                                regsub -all -- {[[:space:]]+} $line " " line
                                set line [split $line]
                                set clamp_x    [lindex $line 1]
                                set clamp_y    [lindex $line 2]
                                if {[regexp -nocase {VIOLATED} [lindex $line 6]]} {
                                	plot line -position $pad_x $pad_y $clamp_x $clamp_y -color red -width 2
                                        marker add  -position $clamp_x $clamp_y -color grey -size 10
                                }
                                gets $RLRPT line
                        }
                }
        }
                                                                                                                                                            
        close $RLRPT

} else {
	set RLRPT [open adsRpt/ESD/$rulefile r 0666]
	while {[gets $RLRPT line] >= 0} {
	        if {[regexp {Pad} $line]} {
	                regsub -all -- {[[:space:]]+} $line " " line
	                set line [split $line]
			if {[lindex $line 6] == $pad_id} {
		                set pad_x      [lindex [split [lindex $line 2] "("] 1]
		                set pad_y    [lindex $line 3]
		                gets $RLRPT line
		                gets $RLRPT line
		                while {![regexp {^#\s*$} $line]} {
		                        if {[regexp {^=====*} $line]} {
		                                break
		                        }
		                        regsub -all -- {[[:space:]]+} $line " " line
		                        set line [split $line]
		                        set clamp_x    [lindex $line 1]
		                        set clamp_y    [lindex $line 2]
					if {$flagfail == 1} {
						if {[regexp -nocase {VIOLATED} [lindex $line 6]]} {
	                                                plot line -position $pad_x $pad_y $clamp_x $clamp_y -color red -width 2
                                        	        marker add  -position $clamp_x $clamp_y -color grey -size 10
	                                        } 
					} else {
						if {[regexp -nocase {VIOLATED} [lindex $line 6]]} {
				                        plot line -position $pad_x $pad_y $clamp_x $clamp_y -color red -width 2
                                        	        marker add  -position $clamp_x $clamp_y -color grey -size 10
						} else {
				                        plot line -position $pad_x $pad_y $clamp_x $clamp_y -color green -width 2
                                        		marker add  -position $clamp_x $clamp_y -color grey -size 10
						}
					}
		                        gets $RLRPT line
        		        }
			}
	        }
	}
	                                                                                                                                                            
	close $RLRPT
}

}; ###end of proc atclDisplayRes91_BUMP2CLAMP





proc atclDisplayRes91_CLAMP2CLAMP {args} {
regexp -all {\{(.*)\}} $args  match args; 
set argv [split $args]
set argc [llength $argv]
                                                                                                                                                            
#### Set the default parameters ###############################################################
set flagfail 0
set flagallfail 0
#### Finish Set the default parameters ########################################################
                                                                                                                                                            
#### Parse the arguments ######################################################################
                                                                                                                                                            
                                                                                                                                                            
for {set j 0} {$j < $argc} {incr j 1} {
	if {[regexp {\-type} [lindex $argv $j]]} {
        	set rulefile [lindex $argv [expr $j + 1]]
       	} elseif  {[regexp {\-rule_file} [lindex $argv $j]]} {
        	set rfile [lindex $argv [expr $j + 1]]
       	} elseif  {[regexp {\-clamp_id} [lindex $argv $j]]} {
                set clamp_id [lindex $argv [expr $j + 1]]
        } elseif  {[regexp {\-fail} [lindex $argv $j]]} {
                set flagfail 1
        } elseif  {[regexp {\-all_fail} [lindex $argv $j]]} {
                set flagallfail 1
	}
}

if {![info exists rulefile]} {
	puts "\n-type option is required"
	return
}

	


if {![info exists rfile]} {
        set rulefile "esd_C2C.rpt"
} else {
        set RULE [open $rfile r 0666]
        while { [gets $RULE line] >=0 } {
                if {[regexp {NAME} $line]} {
                        regsub -all -- {[[:space:]]+} $line " " line
                        regsub -all -- {^[[:space:]]+} $line "" line
                        set line [split $line]
                        set rulename [lindex $line 1]
                }
        }
                                                                                                                                                            
        set rulefile [concat esd_$rulename.rpt]
}

if {$flagallfail == 0 && ![info exists clamp_id]} {
	puts "-clamp_id is required"
	return
}

plot line -clearall
marker delete -all

if {$flagallfail == 1} {
	set RLRPT [open adsRpt/ESD/$rulefile r 0666]
        while {[gets $RLRPT line] >= 0} {
                if {[regexp {Starting} $line]} {
                        regsub -all -- {[[:space:]]+} $line " " line
                        set line [split $line]
			set c1_x      [lindex [split [lindex $line 3] "("] 1]
	                set c1_y    [lindex $line 4]
                        marker add  -position $c1_x $c1_y -color grey -size 10
                        gets $RLRPT line
                        gets $RLRPT line
                        while {![regexp {^#\s*$} $line]} {
                        	if {[regexp {^=====*} $line]} {
                                	break
                                }
                                regsub -all -- {[[:space:]]+} $line " " line
                                set line [split $line]
                                set c2_x    [lindex $line 1]
                                set c2_y    [lindex $line 2]
                                if {[regexp -nocase {VIOLATED} [lindex $line 6]]} {
                                	plot line -position $c1_x $c1_y $c2_x $c2_y -color red -width 2
                                        marker add  -position $c2_x $c2_y -color grey -size 10
                                }
                                gets $RLRPT line
                        }
                }
        }
                                                                                                                                                            
        close $RLRPT

} else {
	set RLRPT [open adsRpt/ESD/$rulefile r 0666]
	while {[gets $RLRPT line] >= 0} {
	        if {[regexp {Starting} $line]} {
	                regsub -all -- {[[:space:]]+} $line " " line
	                set line [split $line]
			if {[lindex $line 8] == $clamp_id} {
				set c1_x      [lindex [split [lindex $line 3] "("] 1]
		                set c1_y    [lindex $line 4]
                        	marker add  -position $c1_x $c1_y -color grey -size 10
		                gets $RLRPT line
		                gets $RLRPT line
		                while {![regexp {^#\s*$} $line]} {
		                        if {[regexp {^=====*} $line]} {
		                                break
		                        }
		                        regsub -all -- {[[:space:]]+} $line " " line
		                        set line [split $line]
		                        set c2_x    [lindex $line 1]
		                        set c2_y    [lindex $line 2]
					if {$flagfail == 1} {
						if {[regexp -nocase {VIOLATED} [lindex $line 6]]} {
	                                                plot line -position $c1_x $c1_y $c2_x $c2_y -color red -width 2
                                        		marker add  -position $c2_x $c2_y -color grey -size 10
	                                        } 
					} else {
						if {[regexp -nocase {VIOLATED} [lindex $line 6]]} {
				                        plot line -position $c1_x $c1_y $c2_x $c2_y -color red -width 2
                                        		marker add  -position $c2_x $c2_y -color grey -size 10
						} else {
				                        plot line -position $c1_x $c1_y $c2_x $c2_y -color green -width 2
                                        		marker add  -position $c2_x $c2_y -color grey -size 10
						}
					}
		                        gets $RLRPT line
        		        }
			}
	        }
	}
	                                                                                                                                                            
	close $RLRPT
}

}; ###end of proc atclDisplayRes91_CLAMP2CLAMP
#$$$$$ END OF 91 $$$$##
