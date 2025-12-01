############################################################################################################
## Rev 1.3 - Karthik Srinivasan
# March 13th, 2019
# ENHANCEMENTS
# ############
#  (1) Support for skipping devices without pins from pin-pair creation
#  (2) Changed the process for thermal analysis to perform_pmic_thermal_analysis
## Rev 1.2 - Karthik Srinivasan
# January 29th, 2019
# ENHANCEMENTS
# ############
# (1) Support for TRACE_POINTS to get the X,Y locations
# 	Usage:
# 	#####
# 	SUPPLY_NETS { <net_name>:TRACE <net_name>:TRACE }
# 	TRACE_POINTS { <net_name> @ <layer> <x> <y> ; <net_name> @ <layer> <x> <y> }
# (2) Fixed a bug with POWER_FET_INFO setting when DEVICE_LAYER option is not used
## Rev 1.1 - Karthik Srinivasan
# December 27th, 2018
# ENHANCEMENTS
# ###################
# (1) Support for per-device ron with POWER_FET_INFO construct
# (2) Support for the LOCAL_NETS feature to enable series device RDSON analysis.. Sensitivity analysis with series device needs to be tested out
#  NOTE: LOCAL_NET should be texted in GDS and PLOC should be provided with tag "GROUND" instead of "POWER"
# (3) Dumped out all the error/warning/info messages from flow in adsRpt/pmic_flow.log file for easier debug
# (4) Procedures added for thermal analysis using ANSYS-M(Requires CTA and ANSYS-Mechanical license)
# (5) All old subroutines like show_IDS_map moved to the end
# (6) Support INFO_LAYERS to control the slicing of wire-geometries automatically
# (7) Added options UNIQUIFY 1, MERGE_INTERNAL_NETS options in BOX_CELLS_PROPERTIES section of gds config
# (8) Added the option ESD_CLAMP_PIN_NODE_DISTANCE and PIN_SLICE_LIMIT to improve deterministic node-creation for pin-Pair hook-up
# (9) Support for specifying more than 2 nets in SUPPLY_NETS section to perform RDSON analysis on High-side and low-side devices simultaneously
# NOTE: When more than 2 nets are specified in SUPPLY_NETS "perform_rdson_calc" should have -net option to specify net-pairs for RDSON analysis on respective pair of nets, Multiple net pairs can be specified as "net1:net2,net2:net3:.."
# (10) Support for loading merged current maps and current density violations from the combined analysis of high/low-side devices
# BUG FIXES
# #########
# (1) Protection added to ensure files are opened and closed properly for RDSON and sensitivity
# (2) Removed the config view options so the final layout view is shown at the end of the session
#
## Rev 1.0 - Karthik Srinivasan
#Procedures embedded for PMIC RDSON ANALYSIS FLOW
#
#USAGE:
#Import the design and setup the testbench for RDSON calculation
#setup_pmic -c <pmic_config_file>
##Setup any parallel processing configuration
#setup_design [-dmp <dmp_config_file> ]
## Perform RDSON and Sensitivity analysis
#perform_rdson_calc [ -nets net1,net2 -j <job_count> -sens 1 -skipem 1]
## Report RDSON and Sensitivity analysis 
#report_rdson
## Please refer to adsRpt/RDSON.rpt for RDSON results
## Please refer to adsRpt/Sensitivity.rpt for Sensitivity analysis results
## NOTE: Sensitivity analysis is only performed if -sens option is set to 1
## Always recommended to use dmp.cfg and -j(jobcount) when sensitivity analysis is performed
# Copyright 2018 ANSYS, Inc.
# All rights reserved.
#
# Revision history
#
# Rev 1.0 
# - Created by Karthik Srinivasan, September 23rd,2018 
# - Initial version
#
#####################################################################################################################################################
namespace eval __GUI {
	variable fontVec

	set __GUI::fontVec(0) [list "0 1 0 5" "0 5 1 6" "1 6 3 6" "3 6 4 5" "4 5 4 1" "4 1 3 0" "3 0 1 0" "1 0 0 1" \
		"0 1 4 5"]
	set __GUI::fontVec(1) [list "2 0 2 6" "2 6 1 5"]
	set __GUI::fontVec(2) [list "0 5 1 6" "1 6 3 6" "3 6 4 5" "4 5 4 4" "4 4 0 0" "0 0 4 0"]
	set __GUI::fontVec(3) [list "0 5 1 6" "1 6 3 6" "3 6 4 5" "4 5 4 4" "4 4 3 3" "3 3 2 3" "3 3 4 2" "4 2 4 1" \
		"4 1 3 0" "3 0 1 0" "1 0 0 1"]
	set __GUI::fontVec(4) [list "3 6 3 0" "3 6 0 2" "0 2 4 2"]
	set __GUI::fontVec(5) [list "0 6 4 6" "0 6 0 4" "0 4 3 4" "3 4 4 3" "4 3 4 1" "4 1 3 0" "3 0 1 0" "1 0 0 1"]
	set __GUI::fontVec(6) [list "0 1 0 5" "0 5 1 6" "1 6 3 6" "3 6 4 5" "0 3 3 3" "3 3 4 2" "4 2 4 1" "4 1 3 0" \
		"3 0 1 0" "1 0 0 1"]
	set __GUI::fontVec(7) [list "0 6 4 6" "4 6 1 0"]
	set __GUI::fontVec(8) [list "0 5 1 6" "1 6 3 6" "3 6 4 5" "4 5 4 4" "4 4 3 3" "3 3 1 3" "1 3 0 4" "0 4 0 5" \
		"3 3 4 2" "4 2 4 1" "4 1 3 0" "3 0 1 0" "1 0 0 1" "0 1 0 2" "0 2 1 3"]
	set __GUI::fontVec(9) [list "0 5 1 6" "1 6 3 6" "3 6 4 5" "4 5 4 1" "4 1 3 0" "3 0 1 0" "1 0 0 1" "0 5 0 4" \
		"0 4 1 3" "1 3 4 3"]
	set __GUI::fontVec(.) [list "1 0 1 1" "1 1 2 1" "2 1 2 0" "2 0 1 0"]
	set __GUI::fontVec(,) [list "1 0 1 1" "1 1 2 1" "2 1 2 0" "2 0 1 0" "2 0 1 -1"]
	set __GUI::fontVec(-) [list "0 3 4 3"]
	set __GUI::fontVec(_) [list "-1 0 5 0"]
	set __GUI::fontVec(+) [list "0 3 4 3" "2 1 2 5"]
	set __GUI::fontVec(/) [list "0 0 4 6"]
	set __GUI::fontVec(\) [list "0 6 4 0"]
	set __GUI::fontVec(() [list "2 1 2 5" "2 1 3 0" "2 5 3 6"]
	set __GUI::fontVec()) [list "2 1 2 5" "2 1 1 0" "2 5 1 6"]
	set __GUI::fontVec(<) [list "1 3 4 6" "1 3 4 0"]
	set __GUI::fontVec(>) [list "1 6 4 3" "1 0 4 3"]
	set __GUI::fontVec(\[) [list "2 0 2 6" "2 0 3 0" "2 6 3 6"]
	set __GUI::fontVec(\]) [list "2 0 2 6" "2 0 1 0" "2 6 1 6"]
	set __GUI::fontVec(?) [list "0 5 1 6" "1 6 3 6" "3 6 4 5" "4 5 4 4" "4 4 2 2" "2 1 2 0"]
	set __GUI::fontVec(:) [list "1 0 1 1" "1 1 2 1" "2 1 2 0" "2 0 1 0" "1 3 1 4" "1 4 2 4" "2 4 2 3" "2 3 1 3"]
	set __GUI::fontVec(\;) [list "1 0 1 1" "1 1 2 1" "2 1 2 0" "2 0 1 0" "2 0 1 -1" "1 3 1 4" "1 4 2 4" "2 4 2 3" \
		"2 3 1 3"]
	set __GUI::fontVec(a) [list "1 0 4 0" "4 0 4 3" "4 3 3 4" "3 4 1 4" "1 0 0 1" "0 1 1 2" "1 2 4 2"]
	set __GUI::fontVec(b) [list "0 1 1 0" "0 0 0 6" "1 0 3 0" "3 0 4 1" "4 1 4 3" "4 3 3 4" "3 4 1 4" "1 4 0 3"]
	set __GUI::fontVec(c) [list "1 0 3 0" "3 0 4 1" "1 0 0 1" "0 1 0 3" "0 3 1 4" "1 4 3 4" "3 4 4 3"]
	set __GUI::fontVec(d) [list "4 6 4 0" "4 1 3 0" "3 0 1 0" "1 0 0 1" "0 1 0 3" "0 3 1 4" "1 4 3 4" "3 4 4 3"]
	set __GUI::fontVec(e) [list "1 0 3 0" "3 0 4 1" "1 0 0 1" "0 1 0 3" "0 3 1 4" "1 4 3 4" "3 4 4 3" "4 3 3 2" \
		"3 2 0 2"]
	set __GUI::fontVec(f) [list "1 0 1 5" "1 5 2 6" "2 6 3 6" "3 6 4 5" "0 3 3 3"]
	set __GUI::fontVec(g) [list "4 3 4 -1" "4 -1 3 -2" "3 -2 1 -2" "1 -2 0 -1" "4 1 3 0" "3 0 1 0" "1 0 0 1" \
		"0 1 0 3" "0 3 1 4" "1 4 3 4" "3 4 4 3"]
	set __GUI::fontVec(h) [list "0 0 0 6" "4 0 4 3" "4 3 3 4" "3 4 1 4" "1 4 0 3"]
	set __GUI::fontVec(i) [list "2 0 2 4" "2 5 2 6"]
	set __GUI::fontVec(j) [list "3 0 3 4" "3 0 2 -1" "2 -1 1 -1" "1 -1 0 0" "3 5 3 6"]
	set __GUI::fontVec(k) [list "0 0 0 6" "1 2 4 0" "1 2 4 4" "0 2 1 2"]
	set __GUI::fontVec(l) [list "2 0 2 6"]
	set __GUI::fontVec(m) [list "0 0 0 4" "4 0 4 3" "1 4 2 3" "2 3 2 0" "2 3 3 4" "3 4 4 3" "1 4 0 3"]
	set __GUI::fontVec(n) [list "0 0 0 4" "0 3 1 4" "4 0 4 3" "4 3 3 4" "3 4 1 4" "1 4 0 3"]
	set __GUI::fontVec(o) [list "1 0 3 0" "3 0 4 1" "1 0 0 1" "0 1 0 3" "0 3 1 4" "1 4 3 4" "3 4 4 3" "4 3 4 1"]
	set __GUI::fontVec(p) [list "0 1 1 0" "0 -1 0 4" "1 0 3 0" "3 0 4 1" "4 1 4 3" "4 3 3 4" "3 4 1 4" "1 4 0 3"]
	set __GUI::fontVec(q) [list "1 0 3 0" "3 0 4 1" "1 0 0 1" "0 1 0 3" "0 3 1 4" "1 4 3 4" "3 4 4 3" "4 4 4 -1"]
	set __GUI::fontVec(r) [list "0 0 0 4" "0 3 1 4" "1 4 3 4" "3 4 4 3"]
	set __GUI::fontVec(s) [list "0 1 1 0" "1 0 3 0" "3 0 4 1" "4 1 0 3" "0 3 1 4" "1 4 3 4" \
		"3 4 4 3"]
	set __GUI::fontVec(t) [list "2 6 2 1" "2 1 3 0" "3 0 4 0" "1 4 4 4"]
	set __GUI::fontVec(u) [list "1 0 3 0" "3 0 4 1" "1 0 0 1" "0 1 0 4" "4 4 4 0"]
	set __GUI::fontVec(v) [list "0 4 2 0" "2 0 4 4"]
	set __GUI::fontVec(w) [list "0 1 0 4" "0 1 1 0" "1 0 2 1" "2 1 2 2" "2 1 3 0" "3 0 4 1" "4 1 4 4"]
	set __GUI::fontVec(x) [list "0 4 4 0" "0 0 4 4"]
	set __GUI::fontVec(y) [list "4 4 4 -1" "4 -1 3 -2" "3 -2 1 -2" "1 -2 0 -1" "4 1 3 0" "3 0 1 0" "1 0 0 1" \
		"0 1 0 4"]
	set __GUI::fontVec(z) [list "0 4 4 4" "0 0 4 0" "0 0 4 4"]
	set __GUI::fontVec(A) [list "0 0 0 5" "0 5 1 6" "1 6 3 6" "3 6 4 5" "4 5 4 0" "0 3 4 3"]
	set __GUI::fontVec(B) [list "0 0 0 6" "0 6 3 6" "3 6 4 5" "4 5 4 4" "4 4 3 3" "3 3 0 3" "0 0 3 0" "3 0 4 1" \
		"4 1 4 2" "4 2 3 3"]
	set __GUI::fontVec(C) [list "0 1 0 5" "0 5 1 6" "1 6 3 6" "3 6 4 5" "0 1 1 0" "1 0 3 0" "3 0 4 1"]
	set __GUI::fontVec(D) [list "0 0 0 6" "0 6 3 6" "3 6 4 5" "4 5 4 1" "4 1 3 0" "3 0 0 0"]
	set __GUI::fontVec(E) [list "0 0 0 6" "0 6 4 6" "0 3 3 3" "0 0 4 0"]
	set __GUI::fontVec(F) [list "0 0 0 6" "0 6 4 6" "0 3 3 3"]
	set __GUI::fontVec(G) [list "0 1 0 5" "0 5 1 6" "1 6 3 6" "3 6 4 5" "0 1 1 0" "1 0 3 0" "3 0 4 1" "4 1 4 3" \
		"4 3 2 3"]
	set __GUI::fontVec(H) [list "0 0 0 6" "4 0 4 6" "0 3 4 3"]
	set __GUI::fontVec(I) [list "2 0 2 6"]
	set __GUI::fontVec(J) [list "0 2 0 1" "0 1 1 0" "1 0 3 0" "3 0 4 1" "4 1 4 6"]
	set __GUI::fontVec(K) [list "0 0 0 6" "1 3 4 6" "1 3 4 0" "0 3 1 3"]
	set __GUI::fontVec(L) [list "0 0 0 6" "0 0 4 0"]
	set __GUI::fontVec(M) [list "0 0 0 6" "4 0 4 6" "0 6 2 3" "2 3 4 6"]
	set __GUI::fontVec(N) [list "0 0 0 6" "4 0 4 6" "0 6 4 0"]
	set __GUI::fontVec(O) [list "0 1 0 5" "0 5 1 6" "1 6 3 6" "3 6 4 5" "0 1 1 0" "1 0 3 0" "3 0 4 1" "4 1 4 5"]
	set __GUI::fontVec(P) [list "0 0 0 6" "0 6 3 6" "3 6 4 5" "4 5 4 4" "4 4 3 3" "3 3 0 3"]
	set __GUI::fontVec(Q) [list "0 1 0 5" "0 5 1 6" "1 6 3 6" "3 6 4 5" "0 1 1 0" "1 0 3 0" "3 0 4 1" "4 1 4 5" \
		"2 2 4 0"]
	set __GUI::fontVec(R) [list "0 0 0 6" "0 6 3 6" "3 6 4 5" "4 5 4 4" "4 4 3 3" "3 3 0 3" "3 3 4 2" "4 2 4 0"]
	set __GUI::fontVec(S) [list "0 1 1 0" "1 0 3 0" "3 0 4 1" "4 1 4 2" "4 2 3 3" "3 3 1 3" "1 3 0 4" "0 4 0 5" \
		"0 5 1 6" "1 6 3 6" "3 6 4 5"]
	set __GUI::fontVec(T) [list "2 0 2 6" "0 6 4 6"]
	set __GUI::fontVec(U) [list "0 1 0 6" "0 1 1 0" "1 0 3 0" "3 0 4 1" "4 1 4 6"]
	set __GUI::fontVec(V) [list "0 6 0 2" "0 2 2 0" "2 0 4 2" "4 2 4 6"]
	set __GUI::fontVec(W) [list "0 0 0 6" "4 0 4 6" "0 0 2 3" "2 3 4 0"]
	set __GUI::fontVec(X) [list "0 6 4 0" "4 6 0 0"]
	set __GUI::fontVec(Y) [list "0 6 2 3" "4 6 2 3" "2 3 2 0"]
	set __GUI::fontVec(Z) [list "0 6 4 6" "0 0 4 0" "4 6 0 0"]
proc    putMsg  { arg x y {xh 6} {yh 7} {c white} {w 1}}        {
                set len [string length $arg]
                for     {set i 0} { $i < $len } {incr i}        {
                        set char [string index $arg $i]
                        if      { $char == " " }        {
                                set x [expr $x+$xh]
                                continue
                        }
                        set fV [expr {[info exists __GUI::fontVec($char)] ? \
                                $__GUI::fontVec([string index $arg $i]) : $__GUI::fontVec(-)}]
                        foreach ld $fV  {
                                set x1 [expr [lindex $ld 0]*$xh/6.0 + $x]
                                set y1 [expr [lindex $ld 1]*$yh/7.0 + $y]
                                set x2 [expr [lindex $ld 2]*$xh/6.0 + $x]
                                set y2 [expr [lindex $ld 3]*$yh/7.0 + $y]
                                plot line -position $x1 $y1 $x2 $y2 -color $c -width $w
                        }
                        set x [expr $x+$xh]
                }
        }
}

proc setup_pmic_man {} {
	puts "
	SYNOPSIS
	Apache-AE TCL utility for PMIC flow 
	USAGE
	setup_pmic \[option_arguments\]
	Options:
	-c <pmic_gsr_file>
	\[-h\] command usage
	\[-m\] man page
	"
set fptemplate [ open "pmic_template.gsr" w ]
puts "-I- Writing Template GSR file as pmic_template.gsr with all madatory and optional keywords"
puts $fptemplate "
###########################################################################################
## 		SECTION1: TECHNOLOGY RELATED FILES AND OPTIONS				 ##
###########################################################################################
##############################
## 	Mandatory keywords  ##
##############################
## Technology Parameters
## RC Technology file(Contact ANSYS AE for template)
## Contains Sheet Resistance/Resistivity, Thickness, Height of metal/via and dielectric layers
TECH_FILE <TECHNOLOGY_FILE_PATH>

## Path for GDS layermap file(Contact ANSYS AE for Template)
## Contains metal/via gds layer name to number mapping  and booleans
GDS_MAP <GDS_LAYER_MAP_FILE> 

##############################
## 	Optional keywords  ##
##############################

## EM limit Technology file(Contact ANSYS AE for template)
## Contains EM limit in mA/um for each metal layer and mA current for each via cut layer
EM_TECH_FILE <EM_TECH_FILE>

## Optional, Is required if EM_TECH_FILE contains multiple set of EM rules
EM_RULE_SET <RULE_SET_NAME>

###########################################################################################
## 		SECTION2: DESIGN SPECIFIC FILES AND OPTIONS				 ##
###########################################################################################

##############################
## 	Mandatory keywords  ##
##############################

## Top cell name in the GDS
TOP_CELL <TOP_CELL_NAME_IN_GDS> 

## In and out nets of the FET
## The names are case-sensitive and it should match the name in the GDS
## Atleast 2 net-names should be specified
## Net-names should be separated by space
SUPPLY_NETS { <net_names> } 

## local nets in case of series devices
LOCAL_NETS { <net_names> }

## Path for GDS file(GDS should be short-free)
GDS_FILE <GDS_FILE_PATH> 

## Power FET device name(wildcards supported)
## Device name is also case-sensitive and should match the GDS name
PMIC_DEVICE { <FET_device_name_in_GDS> }

## Power FET device Resistance Ohms per um
DEVICE_RON <FET_resistance(Ohms/um)> 

## Power FET lowest layer to hook-up FET resistance
DEVICE_LAYER { <layer> }

## Power FET Cell Orientation (finX|finY)
DEVICE_ORIENTATION \[finX|finY\] 

## New syntax
POWER_FET_INFO \{
DEVICE <device_name> <Resistance_per_micron> <layer> <orientation>
\}

## Junction temperature
TEMPERATURE <Temperature_in_degree_Celcius>

## Pad Location file (Note: For Automatic pad creation, please refer to AUTO_PAD in Section#3)
## Format of PAD_LOCATION_FILE
## <pad_name> <x> <y> <layer> <net_name>
PAD_FILES <PAD_LOCATION_FILE>

## Equal_potential_region for defining surface as equipotential regions
## Format of EQUAL_POTENTIAL_REGION_FILE 
## For defining circular pads 
## <x> <y> <radius>  <net_name>
## For defining rectangular or square pads
## <lx> <ly> <urx> <uy>   <net_name>
EQUAL_POTENTIAL_REGION_FILE <PATH_FOR_EQUAL_POTENTIAL_REGIONS_FILE> 

###########################################################################################
## 		SECTION3: OTHER RELEVANT FILES AND OPTIONS				 ##
###########################################################################################
##############################
## 	Optional keywords  ##
##############################

## RC EXTRACTION OPTIONS FOR METAL/VIA GEOMETRY MESHING ##
## Metal meshing options
WIRE_SLICE {
#<layer> <min_width_to_mesh> <mesh_resolution>
# Example: M4, Mesh all geometry > 2um width to resolution of 1um
# M2 1 1
}
## Via meshing options(all vias are meshed to 1um resolution when specified in the list below
SLOT_VIAS { <via_layer> }

## To SKIP R Extraction for certain layers, specify them here
SKIP_LAYERS { <layer> }

## Power FET Load current(default:1Amp)
ZAP_CURRENT <CURRENT_LOAD_IN_AMPS> 

## Use top level text in GDS
USE_TOP_LEVEL_TEXT_ONLY \[1|0\]

## If GDS does not contain any layers below M1(a.k.a base layers) specify DISABLE_MINILVS 1 in the config file (default:0)
DISABLE_MINILVS \[1|0\]

## Automatically generate PAD locations from GDS using the following option
## specify multiple layers separated by space
## Specify the string TEXT(in upper case) if Text labels should be used for PAD
AUTO_PAD { <layer> }

## Other optional parameters
## For importing only portion of large GDS, use the IMPORT_REGIONS option below
IMPORT_REGIONS { <llx> <lly> <urx> <ury> }

## For skipping import of certain cells from GDS use BLACK_Box_CELLS
## Wildcard is supported for cell-names
BLACK_BOX_CELLS { <cell_names separated by space> }

## Skip the GDS conversion and import the Physical data(if already generated from Totem as lef/def format) 
LEF_DEF_DIR <directory_path_for_lef_def_database>\n"

close $fptemplate

puts "-I- Writing Template TCL file as run_template.tcl with all commands and options"
set fptemplatetcl [ open "run_template.tcl" w ]
puts $fptemplatetcl "
#Import the design and setup the testbench for RDSON calculation
setup_pmic -c pmic_template.config 
##Setup any parallel processing configuration
setup_design 
#	\\ \[-dmp <dmp_config_file> \]
## Perform RDSON and Sensitivity analysis
perform_rdson_calc 
#	\\ \[ -nets net1,net2 -j <job_count> -sens 1 \]
## Report RDSON and Sensitivity analysis 
report_rdson
## Please refer to adsRpt/RDSON.rpt for RDSON results
## Please refer to adsRpt/Sensitivity.rpt for Sensitivity analysis results
## NOTE: Sensitivity analysis is only performed if -sens option is set to 1
## Always recommended to use dmp.cfg and -j(jobcount) when sensitivity analysis is performed "

close $fptemplatetcl
}

proc setup_pmic_help {} {
	puts "Usage: setup_pmic -c <pmic_gsr_file> \[-h\] \[-m\]"
	puts "-I- Please use -man otpion to dump out a tempate configuration and command file"
}
proc setup_pmic { args } {
	# Process command arguments
	set argv [split $args]
		if {[llength $argv] == 0 } { set argv "-h" }
		set state flag
		foreach arg $argv {
			switch -- $state {
			flag {
				switch -glob -- $arg {
				-h* { setup_pmic_help; return }
				--he* { setup_pmic_help ; return }
				-c* { set state pmic_gsr;}
				-ma* { setup_pmic_man ; return }
				default { error "actl Error: unknow flag $arg" }
			}
			}
			pmic_gsr {
			set gsr_file $arg
				if {[info exists gsr_file]} {
				puts "INFO: GSR File $gsr_file"
	 			atclProcessGSR $gsr_file
				}
			set state flag
			}
			}
		}
#setup_design
}
proc setup_design { args } {
puts "-I- INFO"
set stdout [ open "adsRpt/pmic_flow.log" a ]
set argv [split $args]
                if {[llength $argv] == 0 } { 
                setup analysis_mode esd 
   		} else {
 		puts $stdout "-I- user is launching a DMP run"
		set dmpcfg [lindex $argv 1]
		set dmpcfgfile [ file normalize dmpcfg ]
		if {[info exists dmpcfgfile]} {
                puts $stdout "-I- Settings from file $dmpcfgfile will be used for DMP"
 		setup analysis_mode esd $args
		} else {
                puts $stdout "-E- DMP configuration file is not found"
		}		
		}
#setup analysis_mode esd
setup design .pmic_setup/pmic.gsr
#	if { [ catch { perform extraction -power -ground } ] == 0 } {
#	puts $stdout "-I- Extraction Successful.."
#	} else {
#	puts $stdout "-E- Extraction failed.."
#	return
#	}
close $stdout
puts "-I- INFO"
}
proc perform_rdson_calc { args } {
set stdout [ open "adsRpt/pmic_flow.log" a ]
set jobs 1
	set argv [split $args]
	if {[llength $argv] == 0 } { 
		puts $stdout "-I- Since no jobcount is specified JobCount is 1 \n -I- Skipping Sensitivity analysis"
	}
		set state flag
		foreach arg $argv {
			switch -- $state {
			flag {
				switch -glob -- $arg {
				-j* { set state jobCount }
				-sen* { set state sens }
				-skipem* { set noem 1 }
				-net* { set state nets }
				}
			}
			sens {
				set sensitivity $arg
				set state flag
			}	
			jobCount {
				set jobs $arg
				set state flag
			}
			nets {
				set netpair [split $arg ","]
				puts $stdout "-I- NETPAIR is $netpair"
				set state flag
			}
			}
	 	}	
variable layer
variable r_on
variable orient
variable current
set fets ""
if {![info exists noem ]} {
	set noem 0
}
set fpg_tmp [ open ".pmic_setup/pmic.gsr" r ]
while { [ gets $fpg_tmp line ] >=0 } {
        if { $line ne ""} {
                if {[ regexp -all -nocase {^\s*\#DEVICE_LAYER\s*\{\s+(.*)\s+\}} $line tmp layer ]} {
		puts $stdout "$layer"
		} elseif {[ regexp -nocase {^\s*\#DEVICE_ORIENTATION\s+(\S+)} $line tmp orient ]} {
		puts $stdout "-I- orientation of clamp is $orient"
		} elseif {[ regexp -nocase {^\s*\#DEVICE_RON\s+(\S+)} $line tmp r_on ]} {
		puts $stdout "-I- device RON per micron is $r_on"
		## Added on November 4th,2018
		################## edit kartik 2/4 it is possible that multiple layers are provided for pin creation
		################# edit kartik 2/4 these layers should be provided with a ":" separating them 
		################ edit kartik 2/4 for eg: pod:nod 
		} elseif {[ regexp -nocase {^\s*\#PWRDEVICE\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)} $line tmp device r_on layer_temp orient ]} {
		# strip wild-card character * from the string $device
		 if {[ regexp -nocase {^\s*(\S+)\*} $device dev ]} {
		set is_dev($dev) 1
		lappend fets "$dev"
		} else {
		set dev $device
		set is_dev($dev) 1
		lappend fets "$dev"
		}
		set d_on_r($dev) $r_on
		# strip the semicolon and add space
		set layer [ regsub ":" $layer_temp " " ]
		set d_lyr($dev) $layer
		set d_orient($dev) $orient
		puts $stdout "-I- device RON per micron is DEVICE $dev \nDEVICE RON is $d_on_r($dev)\nDEVICE LAYER IS $d_lyr($dev)\nDEVICE ORIENTATION $d_orient($dev)"
		## End update November 4th,2018
		} elseif {[ regexp -nocase {^\s*\#ZAP_CURRENT\s+(\S+)} $line tmp current]} {
		puts $stdout "-I- Zap current is $current "
		}
	}
}
puts $stdout "$layer"
if { [ info exists current] } {
puts $stdout "$r_on $orient $layer $current"
} else {
puts $stdout "$r_on $orient $layer 1"
}

close $fpg_tmp
set top [ get design ]
set pgnets [ get net * -glob -type power]
set pgnetcnt [ llength $pgnets ]
puts $stdout "-I- Net count is $pgnetcnt Nets are $pgnets"
set fgrule [ open ".pmic_setup/esd.rule" w ]
if { $pgnetcnt > 2 } {
	if { [ info exists netpair ] } {
	puts $stdout "-I- Net count is $pgnetcnt Nets are $pgnets $netpair "
	set pgnets $netpair
	} else {
	puts $stdout "-E-Since there are more than 2 nets.. Please provide the Zap net pair using -netpair option in perform_rdson_calc command\n"
	return
	}
} else {
		if { $current ne "" } {
		puts $fgrule "BEGIN_ESD_RULE\nNAME RDSON\nTYPE CD\nNET_PAIR $pgnets\nZAP_CURRENT $current\nSHORT_BUMP_IN_NET_GROUP POWER\n"
		} else {
		puts $fgrule "BEGIN_ESD_RULE\nNAME RDSON\nTYPE CD\nNET_PAIR $pgnets\nZAP_CURRENT 0.1\nSHORT_BUMP_IN_NET_GROUP POWER\n"
		}
		if { $noem == 0 } {
#### Changed kartik 2/2 SAVE_EM is changed from 0 to 1 to ensure import esdcd does not take time
		puts $fgrule "SAVE_EM 1\nCACHE_EM 0\nEM_MODE avg\nPROCESS_EM_ONLY 0\nEND_ESD_RULE\n"
		} else {
#### Changed kartik 2/2 SAVE_EM is changed from 0 to 1 to ensure import esdcd does not take time
                puts $stdout "-I- EM checking is skipped as skipem option was used\n"
		puts $fgrule "COMPUTE_EM 0\nREPORT_INSTANCE 3\nEND_ESD_RULE\n"
		}
close $fgrule
if { [info exists sensitivity ]} {
puts $stdout "Sensitivity $sensitivity"
set fsrule [ open ".pmic_setup/sensitivity.rule" w ]
	if { $sensitivity == 2 } {
	foreach inet $pgnets {
	puts $fsrule "BEGIN_ESD_RULE\nNAME Sensitivity\_$inet\nTYPE R\nNET_PAIR $pgnets\nLAYER_SENSITIVITY 3\nDOMAIN $inet\nSHORT_BUMP_IN_NET_GROUP POWER\nCOMPUTE_EM 0\nEND_ESD_RULE\n"
	}
	} else {
	puts $fsrule "BEGIN_ESD_RULE\nNAME Sensitivity\nTYPE R\nNET_PAIR $pgnets\nLAYER_SENSITIVITY 3\nSHORT_BUMP_IN_NET_GROUP POWER\nCOMPUTE_EM 0\nEND_ESD_RULE\n"
	}
close $fsrule
}
}

if { $pgnetcnt > 2 } {
	foreach jnet $pgnets {
		set tempnets [split $jnet ":"]
		if { $current ne "" } {
		puts $fgrule "BEGIN_ESD_RULE\nNAME RDSON_$jnet\nTYPE CD\nNET_PAIR $tempnets\nZAP_CURRENT $current\nSHORT_BUMP_IN_NET_GROUP POWER\n"
		} else {
		puts $fgrule "BEGIN_ESD_RULE\nNAME RDSON_$jnet\nTYPE CD\nNET_PAIR $tempnets\nZAP_CURRENT 1\nSHORT_BUMP_IN_NET_GROUP POWER\n"
		}
		if { $noem == 0 } {
		puts $fgrule "SAVE_EM 0\nCACHE_EM 0\nEM_MODE avg\nPROCESS_EM_ONLY 0\nEND_ESD_RULE\n"
		} else {
		puts $fgrule "COMPUTE_EM 0\nREPORT_INSTANCE 3\nEND_ESD_RULE\n"
		}
	}
close $fgrule
if { [info exists sensitivity ]} {
puts $stdout "Sensitivity $sensitivity"
set fsrule [ open ".pmic_setup/sensitivity.rule" w ]
	foreach inet $pgnets {
		set tempnets [split $inet ":"]
	#puts $fsrule "BEGIN_ESD_RULE\nNAME Sensitivity\_$inet\nTYPE R\nNET_PAIR $pgnets\nLAYER_SENSITIVITY 3\nDOMAIN $inet\nSHORT_BUMP_IN_NET_GROUP POWER\nCOMPUTE_EM 0\nEND_ESD_RULE\n"
	if { $sensitivity == 2 } {
	foreach knet $pgnets {
	puts $fsrule "BEGIN_ESD_RULE\nNAME Sensitivity\_$knet\nTYPE R\nNET_PAIR $tempnets\nLAYER_SENSITIVITY 3\nDOMAIN $knet\nSHORT_BUMP_IN_NET_GROUP POWER\nCOMPUTE_EM 0\nEND_ESD_RULE\n"
	}
	} else {
	puts $fsrule "BEGIN_ESD_RULE\nNAME Sensitivity\nTYPE R\nNET_PAIR $tempnets\nLAYER_SENSITIVITY 3\nSHORT_BUMP_IN_NET_GROUP POWER\nCOMPUTE_EM 0\nEND_ESD_RULE\n"
	}
	}
close $fsrule
}
}
set subcells [ get cell * -glob ]
	foreach cell $subcells {
	puts $stdout "-I- $cell"
	set inst_cnt [ llength [ get instofcell $cell ] ]
	puts $stdout "-I- instance count of cell $cell is $inst_cnt"
        if {![ regexp -all "$top\_APACHECELL" $cell] && ![ regexp -lineanchor "$top$" $cell] && $inst_cnt != 0 } {
	puts $stdout "-I- $cell"
        #### edit 3/8 to catch exception in cell names, user can provide wildcard and some cell will not have pins
	if { [ catch { get cell $cell -pins } ] == 0 } {
	puts $stdout "-I- Cell $cell has pins "
	set cellpins [ get cell $cell -pins ]
        #### edit 3/8 to catch exception in cell names, user can provide wildcard and some cell will not have pins
	## Added on November 4th,2018##
	if {[info exists fets]} {
	puts $stdout "-I- Assigning per FET RON from POWER_FET_INFO section"
	foreach fet $fets {
        	if {[ regexp -nocase "$fet" $cell temp]} {
			set r_on $d_on_r($fet)
			set layer $d_lyr($fet)
			set orient $d_orient($fet)
			puts $stdout "-I cell is $cell same as FET $fet"
			puts $stdout "-I RON is $r_on $d_on_r($fet)"
			puts $stdout "-I layer is $layer $d_lyr($fet)"
			puts $stdout "-I orient is $orient $d_orient($fet)"
		} else {
			puts $stdout "-I cell is $cell and FET is $fet"
		}
	}
		## Necessary to add different RON for different FET device
		if { [ info exists orient ] } {
		puts $stdout "-I- BBB $cellpins $orient $r_on $layer"
		pfs add clamp_pin -inst $cell\_0 -pin $cellpins -layer $layer  -$orient -dist 1 -perfwdR $r_on -perbwdR $r_on 
		} else {
		pfs add clamp_pin -inst $cell\_0 -pin $cellpins  -layer $layer -finX -dist 1 -perfwdR $r_on -perbwdR $r_on 
		}
#		set r_on ""
#		set layer ""
#		set orient ""
	################################# 
	} else {
	puts $stdout "-I- Assigning Global RON from DEVICE_RON section"
	if { [ info exists orient] } {
	puts $stdout "-I- AAA $cellpins $orient $r_on $layer"
	pfs add clamp_pin -inst $cell\_0 -pin $cellpins -layer $layer  -$orient -dist 1 -perfwdR $r_on -perbwdR $r_on 
	} else {
	pfs add clamp_pin -inst $cell\_0 -pin $cellpins  -layer $layer -finX -dist 1 -perfwdR $r_on -perbwdR $r_on 
	}
	}
	}  else {
	puts $stdout "-W- Cell $cell has no pins.. Will not be considered as a Power FET"
	}
	}
	}
	if { [ catch { perform extraction -power -ground } ] == 0 } {
	puts $stdout "-I- Extraction Successful.."
	} else {
	puts $stdout "-E- Extraction failed.."
	return
	}
	if { [ catch { pfs export clamp_pin .pmic_setup/clamp_finger.file -esdCell } ] == 0 } {
	puts $stdout "-I- Executing Device setup successful.."
	} else {
	puts $stdout "-E- Device Setup failed.."
	return
	}
	if { [ catch { perform esdcheck -clamp .pmic_setup/clamp_finger.file -setupClamp } ] == 0 } { 
	puts $stdout "-I- Setting up the PowerFET device successful.."
	} else {
	puts $stdout "-E- Power FET device setup  Failed.. Please check adsRpt/totem.log file for detailed error message"
	}
	if { [ catch {perform esdcheck -rule .pmic_setup/esd.rule -ignoreError -mcore 16 -thread 8 } ] == 0 } { 
	puts $stdout "-I- Checking RDS-ON successful.."
	} else {
	puts $stdout "-E- RDS-ON calculation Failed.. Please check adsRpt/totem.log file for detailed error message"
	}
	if {[info exists sensitivity] } {
	puts $stdout "Sensitivity $sensitivity"
	if { [ catch {perform esdcheck -rule .pmic_setup/sensitivity.rule -ignoreError -mcore 16 -thread 8 -jobCount $jobs  -append -collate} ] == 0 } { 
	puts $stdout "-I- Successful in performing Sensitivity analysis.."
	} else {
	puts $stdout "-E- Sensitivity Analysis Failed.. Please check adsRpt/totem.log file for detailed error message"
	}
	}
close $stdout
}
proc report_rdson {} {
set stdout [ open "adsRpt/pmic_flow.log" a ]
variable fromnet
variable tonet
variable rdson
if {[ file exists adsRpt/RDSON.rpt]} {
puts $stdout "-I- Creating a backup of old RDSON.rpt file "
exec mv adsRpt/RDSON.rpt adsRpt/RDSON.rpt.bak
}
puts $stdout "-I- Creating RDSON.rpt file "
set rpt [ open "./adsRpt/RDSON.rpt" w ] 
	set esdrpt [ open "./adsRpt/ESD/esd_summary.rpt" r ]
	set egsr_tmp [ open "./.pmic_setup/pmic.gsr" r ]
set top [ get design ]
puts $rpt "######################"
puts $rpt "### RDSON Report file"
puts $rpt "######################\n"
puts $rpt "Design name : $top\n"
set devwidth 0
set maxcur 0
set maxv 0
set mincur 1e6
set minv 100
set sensrpt 0
set imaxdrnxy "NONE"
set imaxsrcxy "NONE"
set imindrnxy "NONE"
set iminsrcxy "NONE"
set vmaxdrnxy "NONE"
set vmaxsrcxy "NONE"
set vmindrnxy "NONE"
set vminsrcxy "NONE"
set firstrule 1
set ruleprev "NONE"
set rule "NONE"

while { [ gets $egsr_tmp line ] >=0 } {
		if {[ regexp -nocase {^\s*\#DEVICE_RON\s+(\S+)} $line tmp devron ]} {
		puts $stdout "-I- device RON per micron is $devron"
		}
}
close $egsr_tmp
while { [ gets $esdrpt line ] >=0 } {
	if {[ regexp -nocase {Layer\s+Sensitivity\s+Analysis\s+Report} $line ]} {
		puts $stdout "$tmp"
		set sensrpt 1
	} elseif { $sensrpt == 1 } {
		if { [ regexp -nocase {<LAYER> <R_SEN(%)> <R_EFF>} $line tmp ] } {
		puts $srpt "\# $tmp"
		} elseif { [ regexp -nocase -lineanchor {Net Analyzed: (.*)$} $line tmp netname ]} {
		puts $srpt "\n#################################\n"
		puts $srpt "\# $tmp"
		puts $srpt "#################################\n"
		} elseif { [ regexp -nocase {^\s*(\S+)\s+(\S+)\s+(\S+)\s+Sensitivity_} $line tmp senslyr sens ron_change] } {
		puts $srpt "$senslyr\t$sens\t$ron_change"
		} elseif { $line eq "" } {
		set sensrpt 0
		close $srpt
		}
	}  elseif { ![ regexp -all "\#" $line ] && $line ne ""} {
		if { [ regexp -nocase {\s*BEGIN_ESD_RULE} $line tmp ] } { 
		set beginrule 1
		set ruleprev $rule
		} elseif { [ regexp -nocase {Equivalent resistance\:\s+(\S+)\s+Ohms} $line tmp rdson_temp ] } { 
#			puts $stdout "-I- rdson_temp variable is $rdson_temp RDSONRULE is $rdsonrule"
			if { $rdsonrule ==1 } {
			set rdson $rdson_temp
			puts $stdout "-I- Creating adsRpt/Sensitivity.rpt"
			set srpt [ open "./adsRpt/Sensitivity.rpt" w ] 
			puts $stdout "-I- Equivalent RDS-ON is $rdson"
			puts $srpt "#######################################"
			puts $srpt "##	LAYER SENSITIVITY REPORT	##"
			puts $srpt "#######################################\n"
			puts $srpt "Effective RDS-ON is:$rdson Ohms\n"
			}
		} elseif { [ regexp -nocase {^\s*NAME\s+(\S+)} $line tmp rule ] } {
			if { $firstrule == 0 } {
				if { $rdsonrule == 1 } {
#				set total_dev_ron [ format %5f [expr double($devron)/$devwidth ]]
#				set layer_rdson [ format %.5f  [ expr $rdson - $total_dev_ron ]]
				puts $rpt "RDS-ON from the NET $fromnet to NET $tonet is:$rdson Ohms\n"
#				puts $rpt "Total effective device width of POWER FET device is: $devwidth um\n"
#				puts $rpt "Total effective device RDSON is : $total_dev_ron Ohms\n"
#				puts $rpt "Total effective interconnect RDSON is : $layer_rdson Ohms\n"
				puts $rpt "Maximum Current(IDS) on Device is: $maxcur mA at the location $imaxdrnxy\t$imaxsrcxy\n"
				puts $rpt "Minimum Current(IDS) on Device is: $mincur  mA at the location $imindrnxy\t$iminsrcxy\n"
				puts $rpt "Maximum Voltage difference(VDS) on Device is: $maxv Volts at the location $vmaxdrnxy\t$vmaxsrcxy\n"
				puts $rpt "Minimum Voltage Difference(VDS)on Device is: $minv Volts at the location $vmindrnxy\t$vminsrcxy\n"
				puts $stdout "-I- RDS-ON from the NET $fromnet to NET $tonet is:$rdson Ohms"
#				puts $stdout "-I- Total effective device width of POWER FET is: $devwidth um "
				puts $stdout "-I- Maximum Current(IDS) on Device is: $maxcur mA at the location $imaxdrnxy $imaxsrcxy"
				puts $stdout "-I- Minimum Current(IDS) on Device is: $mincur mA at the location $imindrnxy $iminsrcxy"
				puts $stdout "-I- Maximum Voltage difference(VDS) on Device is: $maxv Volts at the location $vmaxdrnxy $vmaxsrcxy"
				puts $stdout "-I- Minimum Voltage Difference(VDS)on Device is: $minv Volts at the location $vmindrnxy $vminsrcxy"
				close $rpt
				puts $stdout "-I- Closing the RDSON.rpt file "
				rdson_rpt $ruleprev
				puts $stdout "-I- Appending the RDSON.rpt file "
				set rpt [ open "./adsRpt/RDSON.rpt" a ] 
				set devwidth 0
				set maxcur 0
				set maxv 0
				set mincur 1e6
				set minv 100
				set sensrpt 0
				set imaxdrnxy "NONE"
				set imaxsrcxy "NONE"
				set imindrnxy "NONE"
				set iminsrcxy "NONE"
				set vmaxdrnxy "NONE"
				set vmaxsrcxy "NONE"
				set vmindrnxy "NONE"
				set vminsrcxy "NONE"
				set fromnet ""
				set tonet ""
				puts $stdout " Rule is $rule"
				}
		}
			if { [ regexp -nocase {RDSON(\S*)} $rule tmp ]} {
				set rdsonrule 1 
			} else {
				set rdsonrule 0 
			}
		} elseif { [ regexp -nocase {Zap\s+from\:\s+Bump\(\S+\)\s+\(\S+\s+\S+\s+\S+\s+(\S+)\s*\)} $line tmp fromnet_temp ] } {
			if { $rdsonrule == 1 } {
			set fromnet $fromnet_temp
			puts $stdout "-I- from net is $fromnet "
			}
		} elseif { [ regexp -nocase {Zap to:\s+Bump\(\S+\)\s+\(\S+\s+\S+\s+\S+\s+(\S+)\)} $line tmp tonet_temp ] } {
			if { $rdsonrule == 1 } {
			set tonet $tonet_temp
			puts $stdout "-I- to net is $tonet "
			}
		} elseif {[regexp {^\s*(\S+)\s+(\S+)\s+\S+\s+(\(\S+.*\))\s+(\(\S+.*\))\s+\S+\s+\S+\s+\S+} $line all icur vds drn src  ]} {
			set firstrule 0
			if { $rdsonrule ==1 } {
				incr devwidth
				if { $icur >= $maxcur } {
				set maxcur $icur
				set imaxdrnxy $drn
				set imaxsrcxy $src
				} elseif { $icur <= $mincur } { 
				set mincur $icur
				set imindrnxy $drn
				set iminsrcxy $src
				}
				if { $vds >= $maxv } {
				set maxv $vds
				set vmaxdrnxy $drn
				set vmaxsrcxy $src
				} elseif { $vds <= $minv } { 
				set minv $vds
				set vmindrnxy $drn
				set vminsrcxy $src
				}
			}
		} 
	}
}
if { $rdsonrule ==1 } {
#puts $stdout "RDSON is $rdson Ohms"
#set total_dev_ron [ format %5f [expr double($devron)/$devwidth ]]
#set layer_rdson [ format %.5f  [ expr $rdson - $total_dev_ron ]]
puts $rpt "RDS-ON from the NET $fromnet to NET $tonet is:$rdson Ohms\n"
#puts $rpt "Total effective device width of POWER FET device is: $devwidth um\n"
#puts $rpt "Total effective device RDSON is : $total_dev_ron Ohms\n"
#puts $rpt "Total effective interconnect RDSON is : $layer_rdson Ohms\n"
puts $rpt "Maximum Current(IDS) on Device is: $maxcur mA at the location $imaxdrnxy\t$imaxsrcxy\n"
puts $rpt "Minimum Current(IDS) on Device is: $mincur  mA at the location $imindrnxy\t$iminsrcxy\n"
puts $rpt "Maximum Voltage difference(VDS) on Device is: $maxv Volts at the location $vmaxdrnxy\t$vmaxsrcxy\n"
puts $rpt "Minimum Voltage Difference(VDS)on Device is: $minv Volts at the location $vmindrnxy\t$vminsrcxy\n"

puts $stdout "-I- RDS-ON from the NET $fromnet to NET $tonet is:$rdson Ohms"
#puts $stdout "-I- Total effective device width of POWER FET is: $devwidth um "
puts $stdout "-I- Maximum Current(IDS) on Device is: $maxcur mA at the location $imaxdrnxy $imaxsrcxy"
puts $stdout "-I- Minimum Current(IDS) on Device is: $mincur mA at the location $imindrnxy $iminsrcxy"
puts $stdout "-I- Maximum Voltage difference(VDS) on Device is: $maxv Volts at the location $vmaxdrnxy $vmaxsrcxy"
puts $stdout "-I- Minimum Voltage Difference(VDS)on Device is: $minv Volts at the location $vmindrnxy $vminsrcxy"
##puts $stdout "-I- BBB"
close $rpt
close $esdrpt
select clearall
rdson_rpt $rule
}
		if {[info exists srpt]} {
		close $srpt
		}
## changed 2/1/2019 no need for import esdcd
#import esdcd RDSON* -glob -cacheEM 3 -EMScale 1
#	show CURD
#	select clearall
#	config viewpad -type all -mode off
#	config colormap -map CURD -min 1e-6 -max 10e-3 
#	dump gif -map CUR  -o CUR.gif
#	config viewlayer -name all -style invisible
#	config viewlayer -name instance -style outline
############ change Edit kartik 2/1 to ensure sensitivity.rpt file is copied over from ESD
set sensitivity_temp "./adsRpt/ESD/sensitivity.rpt"
set sensitivity [ file normalize $sensitivity_temp ]
#puts " -IIIIII file is $sensitivity "
if { [ file exists $sensitivity ] } {
############################################################ edit
exec cat adsRpt/ESD/sensitivity.rpt >> adsRpt/Sensitivity.rpt
puts "-I- RDSON and Sensitivity Analysis Completed Successfully.. Please check adsRpt/RDSON.rpt and adsRpt/Sensitivity.rpt files"
} else {
puts "-I- RDSON Analysis Completed Successfully.. Please check adsRpt/RDSON.rpt "
}
puts "-I- Please check adsRpt/pmic_flow.log for flow related errors and warnings and adsRpt/totem.log for Totem related errors and warnings"
close $stdout
}

######### open the config (pmic.cfg) file and dump gsr, gds.config and rule files
proc atclProcessGSR { args } {
set stdout [ open "adsRpt/pmic_flow.log" w ]
set igsr_tmp [ lindex $args 0 ]
set igsr [ file normalize $igsr_tmp ]
puts $stdout "-I- $igsr"
puts "-I- GSR file is  $igsr"
set tmpdir ".pmic_setup"
set skip_file_name "skip_layer_file"
file mkdir $tmpdir 
set fpr [ open "$igsr" r ]
### fpg is the gsr file 
set fpg [ open "$tmpdir/pmic.gsr" w ]
## fpc is the gds.config file
set fpc [ open "$tmpdir/pmic.gds.config" w ]
set fpskip [ open "$tmpdir/skip_layer_file" w ]
### flags for wire slice detection 
set wslice 0
set device_info 0
set lyr ""
set pwr_net ""
set gnd_net ""
set tracept 0
while { [ gets $fpr line ] >=0 } {
        if { ![ regexp -all "\#" $line ] && $line ne ""} {
		if { $wslice ==1 } {
		 if {[ regexp -all -nocase  {^\s*\}} $line ]} {
		  set wslice 0
                  puts $fpg "\}"
		 } else {
		 puts $fpg $line
		 }
		## update on November 4th
		} elseif { $device_info == 1 } {
		 	if {[ regexp -all -nocase  {^\s*\}} $line ]} {
		 	 set device_info 0
                 	 puts $fpc "\}"
                 	 puts $fpg "#\}"
		 	} else {
################# edit kartik 2/4 it is possible that multiple layers are provided for pin creation
################ edit kartik 2/4 these layers should be provided with a ":" separating them 
############### edit kartik 2/4 for eg: pod:nod 
				if { [ regexp -nocase {^\s*DEVICE\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)} $line tmp dev ron devlyr_temp d_orient ] } {
					puts $stdout "-I- Device info\t$dev $ron $devlyr_temp $d_orient"
					### adding the construct as is (with semicolon) in the gsr file, gsr file will parse and remove semicolon 
					### look for $layer_temp and $layer in #PWRDEVICE parsing
                	  		puts $fpg "#PWRDEVICE $dev $ron $devlyr_temp $d_orient"
					puts $fpc "$dev"
					## added on January 29th, 2019 to fix corner case with POWER_FET_INFO w/o DEVICE_LAYER keyword
					set devlyr [ regsub ":" $devlyr_temp " " ]
					append lyr " $devlyr"
				}
			}
		## End update November 4th,2018
################# edit kartik 2/4
		} else {
		if {[ regexp -nocase {^\s*TECH_FILE\s+(\S+)} $line tmp tech ] } {
		set techfile [ file normalize $tech ]
		puts $stdout "-I- TECH_FILE $techfile"
		if {![info exists techfile]} { 
		puts $stdout "-E- Tech file $techfile does not exist"
		return 
		}
		puts $fpg "TECH_FILE $techfile"
		} elseif {[ regexp -nocase {^\s*EM_TECH_FILE\s+(\S+)} $line tmp emtech ] } {
		set emtechfile [ file normalize $emtech ]
		puts $stdout "-I- EM_TECH_FILE $emtechfile"
		if {![info exists emtechfile]} { 
		puts $stdout "-E- Tech file $emtechfile does not exist"
		return 
		}
		puts $fpg "EM_TECH_FILE $emtechfile"
		} elseif {[ regexp -nocase {^\s*EM_RULE_SET\s+(\S+)\s+(\S+)} $line tmp mode ruleset] } {
		puts $stdout "-I- EM_RULE_SET $mode $ruleset"
		puts $fpg "EM_RULE_SET $mode $ruleset"
		} elseif {[ regexp -nocase {^\s*ZAP_CURRENT\s+(\S+)} $line tmp current] } {
		puts $fpg "#ZAP_CURRENT $current"
		} elseif {[ regexp -nocase {^\s*CONTACT_SANITY_CHECKS\s+(\S+)} $line tmp sanity] } {
		puts $fpc "CONTACT_SANITY_CHECKS $sanity"
		} elseif {[ regexp -nocase {^\s*APACHE_FILES\s+(\S+)} $line tmp opt_dbg ] } {
		puts $stdout "-I- APACHE_FILES is set as $opt_dbg"
		puts $fpg "APACHE_FILES $opt_dbg"
		} elseif {[ regexp -nocase {^\s*TOP_CELL\s+(\S+)} $line tmp topc ] } {
		puts $stdout "-I- TOP design name is $topc"
                } elseif {[ regexp -nocase {^\s*USE_TOP_LEVEL_TEXT_ONLY\s+(\S+)} $line tmp text1 ] } {
                puts $fpc "USE_TOP_LEVEL_TEXT_ONLY $text1"
		} elseif {[ regexp -nocase {^\s*DISABLE_MINILVS\s+(\d+)} $line tmp minilvs ] } {
		puts $stdout "-I- DISABLE_MINILVS $minilvs"
		} elseif {[ regexp -all -nocase {WIRE_SLICE \{} $line]} {
		puts $stdout "-I- Metal layer Meshing options"
                set wslice 1
                puts $fpg "WIRE_SLICE \{"
		} elseif {[ regexp -all -nocase {INFO_LAYERS \{} $line]} {
		puts $stdout "-I- Metal layer Meshing options"
                puts $fpg "INFO_LAYERS \{"
                set wslice 1
		} elseif {[ regexp -nocase {^\s*LEF_DEF_DIR\s+(\S+)} $line tmp lefdef ] } {
		set lefdefdir [ file normalize $lefdef ]
		puts $stdout "-I- Physical data is provided as LEF/DEF format so skipping GDS processing  and reusing the LEF/DEF data base present in $lefdefdir "
		} elseif {[ regexp -nocase {^\s*GDS_FILE\s+(\S+)} $line tmp gds ] } {
		set gdsfile [ file normalize $gds ]
		puts $stdout "-I- GDS_FILE $gdsfile"
		puts $fpc "GDS_FILE $gdsfile"
		} elseif {[ regexp -nocase {^\s*GDS_MAP\s+(\S+)} $line tmp gdsmap ] } {
		set gdsmapfile [ file normalize $gdsmap ]
		puts $stdout "-I- GDS_MAP $gdsmapfile"
		puts $fpc "GDS_MAP_FILE $gdsmapfile"
		} elseif {[ regexp -all -nocase {SUPPLY_NETS \{\s+([a-zA-Z0-9_].*)\s+\}} $line tmp nets ]} {
			puts $stdout "-I- SUPPLY_NETS \{ $nets \}"
			puts $fpg "VDD_NETS \{"
			if { [ regexp -all -nocase {(\S+)\:TRACE} $line tmp ] } {
			set tracept 1
			puts "-I- Found trace point"
			} else {
			puts $fpc "VDD_NETS \{"
			}
			foreach a $nets {
			if { [ regexp -all -nocase {(\S+)\:TRACE} $a tmp name] } {
			puts $fpg "$name 1"
			## Intentionally not adding net name gds config nets as this will be set later by the tool(January 29th, 2019)
			#puts $fpc "$name"
			append pwr_net " $name"	
			} else {
			puts $fpg "$a 1"
			puts $fpc "$a"
			}
			}
			puts $fpg "\}"
			if { $tracept == 0 } { 
			puts $fpc "\}"
			}
		## Added on December 27th,2018
		} elseif {[ regexp -all -nocase {LOCAL_NETS \{\s+([a-zA-Z0-9_].*)\s+\}} $line tmp lnets ]} {
			puts $stdout "-I- LOCAL_NETS \{ $tmp \}"
			## considering all local nets as GND nets
			puts $fpg "GND_NETS \{"
			if { [ regexp -all -nocase {TRACE} $line tmp ] } {
			set tracept 1
			puts "-I- Found trace point"
			} else {
			puts $fpc "GND_NETS \{"
			}
			foreach a $lnets {
			if {[ regexp -all -nocase {(\S+)\:TRACE} $a tmp name]} {
			puts $fpg "$name 1"
			append gnd_net "$name"	
			## Intentionally not adding net name gds config nets as this will be set later by the tool(January 29th, 2019)
			#puts $fpc "$name"
			} else {
			puts $fpg "$a 0"
			puts $fpc "$a"
			}
			}
			puts $fpg "\}"
			puts $fpg "ESD_EXTRACT_CLAMP_NET 2"
			if { $tracept == 0 } { 
			puts $fpc "\}"
			}
		} elseif {[ regexp -all -nocase {SIGNAL_NETS \{\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+\}} $line tmp net x y layer pinlayer_tmp ]} {
			puts $stdout "-I- SIGNAL_NETS { $tmp }"
			puts $stdout  "-I- $pinlayer_tmp"
			set pinlayer $pinlayer_tmp	
			puts $fpg "ESD_SIGNAL_NETS {"
			puts $fpc "SIGNAL_NETS {"
			puts $fpg "$net 0"
			puts $fpc "$net {\n - \@ $layer $x $y \n}\n"
			puts $fpg "}"
			puts $fpc "}"
		} elseif {[ regexp -nocase {AUTO_PAD\s+(\S+)} $line tmp padlyr ] } {
			if {[ regexp  -nocase {TEXT} $padlyr tmp]} {
			puts $stdout "-I- AUTO_PAD $padlyr"
			puts $fpg "ADD_PLOC_FROM_TOP_DEF 1"
			puts $fpc "GENERATE_PLOC USE_TEXT_LABEL"
			} else {	
			puts $stdout "-I- AUTO_PAD $padlyr"
			puts $fpg "ADD_PLOC_FROM_TOP_DEF 1"
			puts $fpc "GENERATE_PLOC USE_PIN_LAYERS"
			puts $fpc "GENERATE_PLOC_FILTER {\n$padlyr ALL\n}"
			}
		} elseif {[ regexp -nocase {PAD_FILES\s+(\S+)} $line tmp pad ] } {
			set padfile [ file normalize $pad ]
			puts $stdout "-I- PAD_FILES {\n $pad\n}"
			puts $fpg "PAD_FILES {\n $padfile\n}"
		} elseif {[ regexp -nocase {EQUAL_POTENTIAL_REGION_FILE\s+(\S+)} $line tmp eqpad ] } {
			set eqpadfile [ file normalize $eqpad ]
			puts $stdout "-I- EQUAL_POTENTIAL_REGION_FILE {\n $eqpadfile\n}"
			puts $fpg "EQUAL_POTENTIAL_REGION_FILE  $eqpadfile"
		} elseif {[ regexp -nocase {BLOCK_POWER_ASSIGNMENT_FILE\s+(\S+)} $line tmp bpa ] } {
			set bpafile [ file normalize $bpa]
			puts $stdout "-I- BLOCK_POWER_ASSIGNMENT_FILE {\n $bpafile\n}"
			puts $fpg "BLOCK_POWER_ASSIGNMENT_FILE  $bpafile"
		} elseif {[ regexp -all -nocase -lineanchor {BLACK_BOX_CELLS\s*\{\s+([a-zA-Z0-9_].*)\s+\}} $line tmp blackboxcell ]} {
			puts $stdout "-I-BLACK_BOX_CELLS { $blackboxcell }"
			puts $fpc "BLACK_BOX_CELLS {"
			foreach b $blackboxcell {
			puts $fpc "$b"
			}
			puts $fpc "}"
		} elseif {[ regexp -all -nocase -lineanchor {PMIC_DEVICE\s*\{\s+([a-zA-Z0-9_].*)\s+\}} $line tmp boxcell ]} {
			puts $stdout "-I- WHITE_BOX_CELLS { $boxcell }"
			puts $fpc "WHITE_BOX_CELLS {"
			foreach a $boxcell {
			puts $fpc "$a"
			}
			puts $fpc "}"
		} elseif {[ regexp -nocase {^\s*DEVICE_LAYER\s*\{\s+([a-zA-Z0-9_].*)\s+\}} $line tmp lyr ] } {
			puts $stdout "-I- Device layer is $lyr"
			puts $fpg "#DEVICE_LAYER { $lyr }"
                } elseif {[ regexp -all -nocase {SKIP_LAYERS \{\s+([a-zA-Z0-9_].*)\s+\}} $line tmp skip_lyr ]} {
                        puts $stdout "-I- Extraction skipped for listed layers  $skip_lyr"
                        puts $fpskip "##skipping extraction for below layers"
                        foreach b $skip_lyr {
                        puts $fpskip "$b"
                        }
			set skipfile [ file normalize $tmpdir/skip_layer_file ]
                        puts $fpg "SKIP_LAYERS_FILE $skipfile"
		} elseif {[ regexp -nocase {SLOT_VIAS\s+\{\s+([a-zA-Z0-9_].*)\s+\}} $line tmp via_layers ]} { 
			puts $stdout "-I- slot via layers are is $via_layers"
			puts $fpc "SLOT_VIA_LAYERS {"
			foreach b $via_layers {
			puts $fpc "$b 1"
			}
			puts $fpc "}"
		## Added on November 4th,2018
		} elseif {[ regexp -nocase {POWER_FET_INFO\s+\{} $line tmp]} { 
			puts $stdout "-I- New Device info syntax is specified"
			puts $fpg "\#$tmp"
			puts $fpc "WHITE_BOX_CELLS \{"
			set device_info 1
		## End update November 4th,2018
		} elseif {[ regexp -nocase {^\s*TEMPERATURE\s+(\S+)} $line tmp temp ]} {
			puts $fpg "$tmp"
			puts $fpg "TEMPERATURE_EM $temp"
		} elseif {[ regexp -nocase {THERMAL_ANALYSIS} $line tmp ]} {
			puts $fpg "$line"
		} elseif {[ regexp -all {^\s*IMPORT_REGIONS \{\s+([a-zA-Z0-9_].*)\s+\}} $line tmp boxx ]} {
			puts $stdout "-I- REGION is $boxx\n"
			puts $fpc "IMPORT_REGIONS \{\n $boxx \n\}"
			puts $fpc "NEW_IMPORT_REGION 1"
		} elseif {[ regexp -all {^\s*EM_REPORT_} $line tmp ]} {
			puts $fpg "$line"
		} elseif {[ regexp -all {^\s*TRACE_POINTS\s+\{\s+([a-zA-Z0-9_].*)\s+\}} $line tmp tpt ]} {
			puts "-I- TRACE points are found $tmp\n"
			set trace_pts [split $tpt ";"]
		} else {
			puts $fpg "#$line"
		}
		}
	}
}
if { $tracept == 1 } {
puts $fpc "VDD_NETS \{\n"
foreach pnet $pwr_net {
	set tracecnt 0
	puts $fpc " $pnet \{\n"
		foreach pt $trace_pts {
		if {[string equal "$pnet" [lindex $pt 0]]} {
			puts $fpc "\- \@ [lindex $pt 2] [lindex $pt 3] [ lindex $pt 4]"
		incr tracecnt
		}
		}
	if { $tracecnt == 0 } {
		puts $stdout "-I- Net $pnet does not have any tracing point"
		puts $fpc "$pnet\n \}\n"
	} else {
		puts $fpc "\}\n"
	}
}
puts $fpc "\}\n"
puts $fpc "GND_NETS \{\n"
foreach gnet $gnd_net {
	set tracecnt 0
	puts $fpc " $gnet \{\n"
		foreach pt $trace_pts {
		if {[string equal $gnet [lindex $pt 0]]} {
			puts $fpc "- @ [lindex $pt 2 ] [lindex $pt 3 ] [ lindex $pt 4 ]"
		incr tracecnt	
		}
		}
	if { $tracecnt == 0 } {
		puts $stdout "-I- Net $gnet does not have any tracing point"
		puts $fpc "$gnet\n \}\n"
	} else {
		puts $fpc "\}\n"
	}
}
puts $fpc "\}\n"
}
	
if {![info exists topc ]} { 
puts $stdout "-E- TOP_CELL is not specified "
return 
}
if {![info exists lyr ]} { 
puts $stdout "-E- Device pin layer is not specified.. Please specify the same in DEVICE_LAYER keyword"
return 
}

puts $fpc "TOP_CELL $topc"
if { [ info exists minilvs ] } {
	if { $minilvs == 0 } {
	puts $fpc "DISABLE_MINILVS $minilvs"
	puts $fpc "CONTACT_RESISTANCE 1"
	puts $fpc "NO_CURRENT_PIN_IN_BOX_INSTS 1"
	} else {
	puts $fpc "DISABLE_MINILVS 1"
	}
} else {
	puts $fpc "DISABLE_MINILVS 0"
        puts $fpc "CONTACT_RESISTANCE 1"
        puts $fpc "NO_CURRENT_PIN_IN_BOX_INSTS 1"
}
puts $fpc "GENERATE_LEF_DEF ./lefdef"
## edit kartik 2/28 added 2 KW's
puts $fpc "TAP_CELL_DETECTION 0"
puts $fpc "CONTACT_SANITY_CHECKS 0"
puts $fpc "BOX_CELLS_PROPERTIES \{"
## edit kartk 2/4 removed next line character 
puts $fpc "MERGE_INTERNAL_NETS 1\nUNIQUIFY 1\n"
if {[info exists pinlayer ]} {
puts $fpc "PIN_CREATION_LAYERS $pinlayer $lyr"
} else {
puts $fpc "PIN_CREATION_LAYERS $lyr"
}
puts $fpc "\}"
puts $fpg "SCANLINE_MERGE_LAYERS {\nALL\n}"
puts $fpg "SPLIT_SPARSE_VIA_ARRAY 0.1"
#puts $fpg "ESD_CLAMP_PIN_NODE_DISTANCE 1"
puts $fpg "PIN_SLICE_LIMIT 1 0.5"
if {![info exists lefdefdir ]} {
puts $fpg "GDSII_FILE {\n$topc $tmpdir\/pmic.gds.config reduced\n}"
} else {
puts $fpg "GDS_CELLS {\n $topc $lefdefdir\n}\n"
}
#puts $fpg "GND_NETS {\n}"
close $fpc
close $fpg
close $fpr
close $fpskip
puts $stdout "-I- GSR created successfully"
close $stdout
}
##proc
proc rdson_rpt { args } {
set rulename [ lindex $args 0 ]
puts "-I- Rule is $rulename"
	set file [glob "adsRpt/ESD/esd_summary.rpt"]
	#set file [glob "test.rpt"]
	set file1 [open $file r]
	set fprpt [open "adsRpt/RDSON.rpt" a]
	puts $fprpt "\n\n###DEVICE LEVEL CURRENT SUMMARY###"
	set k1 0
	set rdsonrule 0
	while {[gets $file1 line] >= 0} {
		if {[ regexp -nocase {^\s*\*\*} $line ]} {
		set rdsonrule 0
		} elseif { [ regexp -nocase {^\s*NAME\s+(\S+)} $line tmp rule ] } { 
			if { $rule eq $rulename } {
#				puts "Rule $rule is same as $rulename"
				set rdsonrule 1 
			} else {
#				puts "Rule $rule is not the same as $rulename"
				set rdsonrule 0
			}
		} elseif {[regexp {# <I> <V> <Ron>\s+.*} $line all]} {
			if { $rdsonrule ==1 } {
			puts $fprpt "$all"
			}
		} elseif {[regexp {^\s*\S+.*\(\S+.*\)\s+\(\S+.*\)\s+\S+\s+\S+\s+\S+} $line all]} {
			if { $rdsonrule ==1 } {
			puts $fprpt "$all"
			}
		}
		set lines2($k1) $line
		incr k1
		}
		puts $fprpt "####################################################\n\n"
	close $file1
	close $fprpt
}
#########################################################################
#THERMAL ANALYSIS FLOW
#########################################################################
proc perform_pmic_thermal_analysis { args } {
	set argv [split $args]
		if {[llength $argv] == 0 } { set argv "" }
		set state flag
		foreach arg $argv {
			switch -- $state {
			flag {
				switch -glob -- $arg {
				-help { set state help;}
				-mshlyr { set state layerinfo;}
				-hsf { set state hsf;}
				-ver { set state ansysversion;}
				-dis { set state distributed; }
				-bpf { set state bpfinfo; }
				default { puts "actl Error: unknow flag $arg" }
				}
			}
			help {
			puts "Usage: perform_pmic_thermal_analysis -meshlyr <start_lyr>,<end_lyr> -hsf <user_hsf_file> -ver <ANSYS/M version> -dis <number of cores>"
			puts "All the above options are optional, without the above options default settings will be used"
			return
			}
			ansysversion {
			set version $arg
			set state flag
			}
			distributed {
			set cores $arg
			set state flag
			}
			layerinfo {
			set mshlyrs $arg
			set state flag
			}
			hsf {
			if {[info exists arg ]} {
			set hsf_file [ file normalize $arg ]
			puts "INFO: GSR File $hsf_file"
			}
			set state flag
			}
			bpfinfo {
			if {[info exists arg ]} {
			set userbpf [ file normalize $arg ]
			puts "INFO: BPF File $userbpf"
			}
			set state flag
			}
			}
			}
if {![info exists mshlyrs]} {
set mshlyrs "DEFAULT"
}
if {![info exists version]} {
puts "Ansys version is not provided, Version ansys180 will be used for FEM simulations"
set version 180 
}
set is_avail [ exec which ansys$version ]
if {![info exists is_avail]} {
puts "ANSYS mechanical version $version is not found, please double check the ANSYS/M version setup"
}
if {![info exists hsf_file]} {
puts "User ANSYS/M submodel configuration file is not provided, default material properties and meshing options are used"
set hsf_file "NONE"
}
set mdldir ".submodel"
file mkdir $mdldir
	if { [ catch { dump hot_interconnect -flow 1 -o $mdldir\/hot_interconnect_file_PG } ] == 0 } {
	puts "-I- Finished Dumping Hot interconnect file .."
	} else {
	puts "-E- Dumping Hot interconnect Failed.."
	return
	}
	if { [ catch { perform pwrcalc } ] == 0 } {
	puts "-I- performing power calculation"
	} else {
	puts "-E- Cannot perform power calculation"
	return
	}
	if { [ catch { perform thermalmodel -layer -ctmfilecheck} ] == 0 } {
	puts "-I- Generating CTM"
	} else {
	puts "-E- Cannot generate CTM"
	return
	}
	atclmakebpf $userbpf 
#	if { [ catch { exec perl ./scripts/make_bpf.pl adsRpt/RDSON.rpt } ] == 0 } {
#	puts "-I- Creating block power file"
#	} else {
#	puts "-E- Cannot create block power file"
#	return
#	}
	atclProcesshsf -mshlyr $mshlyrs -userhsf $hsf_file
exec mv bpf.rpt $mdldir/bpf.rpt
exec mv adsThermal.tar.gz $mdldir/adsThermal.tar.gz
exec mv adsThermal $mdldir/adsThermal
cd $mdldir
	if { [ catch { exec fasttherm -subm hsf.cfg} ] == 0 } {
	puts "-I- Creating Submodel for ANSYS/M"
	} else {
	puts "-E- Cannot generate Submodel for ANSYS/M.. please check .submodel/hsf.log"
	return
	}
	set dsn [ get design ]
	if {[info exists cores]} {
	puts "-I- Executing the comamnd  ansys$version -b -dis -np $cores -dir ./ -j $dsn -i ./run_ansys_apdl.txt > /dev/null"
	if { [ catch { exec ansys$version -b -dis -np $cores  -dir "./" -j "$dsn" -i "./run_ansys_apdl.txt" > /dev/null } ] == 0 } {
	puts "-I- Running Ansys/M for Thermal analysis"
	} else {
	puts "-E- Failed Running ANSYS/M for thermal analysis"
	return
	}
	} else {
	puts "-I- Executing the comamnd  ansys$version -b -dis -np 4 -dir ./ -j $dsn -i ./run_ansys_apdl.txt > /dev/null"
	if { [ catch { exec ansys"$version" -b -dis -np 4 -dir "./" -j "$dsn" -i "./run_ansys_apdl.txt" > /dev/null } ] == 0 } {
	puts "-I- Running Ansys/M for Thermal analysis"
	} else {
	puts "-E- Failed Running ANSYS/M for thermal analysis"
	return
	}
	}
	if { [ catch { exec fasttherm -getT getAnsTemp.in} ] == 0 } {
	puts "-I- Getting the results from ANSYS/M"
	} else {
	puts "-E- Failed to get results from ANSYS/M"
	return
	}
cd ../
import sh_temp .submodel/hot_interconnect_file_PG.out
perform emcheck
config viewlayer -name all -style outline 
show wt
}
proc atclmakebpf { args } {
set userbpf [ lindex $args 0 ]
puts "-I- User BPF file is $userbpf"
set frdson [ open "adsRpt/RDSON.rpt" r ]
set fbpf [ open "bpf.rpt" w ]
set i 0
set iv 0
puts $fbpf "# OD_geo_id Xlo Ylo Xhi Yhi Power(mW)\n"
while { [ gets $frdson line ] >=0 } {
        if { $line ne ""} {
		if {[ regexp -nocase {^\s*\#\s+<I> <V>} $line tmp ]} {
			set iv 1 
		}
		if {$iv==1} {
			if {[ regexp -nocase {^(\S+)\s+(\S+)\s+\S+\s+\(\S+\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\)\s+\(\S+\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\)} $line tmp volt cur lx1 ly1 lyr1 nt1 lx2 ly2 lyr2 nt2 ]} {
			set pwr [ expr ($volt*$cur)]
#######
## Assigning one OD region representing the DRAIN/SOURCE terminal of the FET
			if {$lx1 <= $lx2} { 
			set llx_1 $lx1 
			set urx_1 $lx2 
			} else {
			set llx_1 $lx2
			set urx_1 $lx1
			}
			if {$ly1 <= $ly2} { 
			set lly_1 $ly1 
			set ury_1 $ly2 
			} else {
			set lly_1 $ly2
			set ury_1 $ly1
			}
				set lx_1 [ expr $llx_1-0.5 ]
				set ly_1 [ expr $lly_1-0.5 ]
				set ux_1 [ expr $urx_1+0.5 ]
				set uy_1 [ expr $ury_1+0.5 ]
				puts $fbpf "OD$i $lx_1 $ly_1 $ux_1 $uy_1 $pwr"
			incr i			
			}
		}
	}
}
if {[info exists userbpf]} {
puts "-I- Reading User BPF file $userbpf"
set ubpf [ open "$userbpf" r ]
while { [ gets $ubpf line ] >=0 } {
        if { $line ne ""} {
		if {[ regexp -nocase {^\s*OD\s+(\S+\s+\S+\s+\S+\s+\S+\s+\S+)} $line tmp userod ]} {
			puts "-I- OD$i $userod"
			puts $fbpf "OD$i $userod"
		}
	}
}
close $ubpf
}
close $fbpf
close $frdson
}
proc atclProcesshsf { args } {
	set argv [split $args]
		if {[llength $argv] == 0 } { set argv "" }
		set state flag
		foreach arg $argv {
			switch -- $state {
			flag {
				switch -glob -- $arg {
				-mshlyr { set state layerinfo;}
				-userhsf { set state hsf;}
				default { puts "actl Error: unknow flag $arg" }
				}
			}
			layerinfo {
			set mshlyrs $arg
			if { $mshlyrs ne "DEFAULT" } {
			set mshlayers [split $mshlyrs ","]
			}	 
			set state flag
			}
			hsf {
			set userhsf $arg
			if {[info exists hsf_file]} {
			puts "INFO: GSR File $hsf_file"
			}
			set state flag
			}
			}
			}

#set mshlyr [ lindex $args 0 ]
#set userhsf [ lindex $args 1 ]
#	if { $args ne "DEFAULT" } {
#	set mshlayers [split $args ","]
#	} 
set tmpdir ".submodel"
#file mkdir $tmpdir 
puts "-I- opening CTM header\n"
set fpctm [ open "adsThermal/CTM_header.txt" r ]
set metals 0
set idx 0
while { [ gets $fpctm line ] >=0 } {
        if { ![ regexp -all "\#" $line ] && $line ne ""} {
		if {$metals==1} {
		if {[ regexp {^\s*(\S+)\s+(\S+)\s+(\S+)} $line tmp lyr thk ht ] } {
		#	puts "$lyr $ht $thk"
			#set height [expr $ht+$thk ]
			set height $ht
			if {[ regexp -nocase {^\s*m\S*(\d+)} $lyr tmp idx ]} {
				if {$idx==1}  {
				set layer $lyr
			#	puts $layer
				}
			} 
			}
		}	
		}
		if {[ regexp {^\s*METAL_LAYERS\s+(\S+)} $line tmp ] } {
			set metals 1
		}
		if {[ regexp {^\s*\}} $line tmp ]} {
			puts "End of metals section"
			set metals 0
		}
	}
set fphsf [ open "$tmpdir/hsf.cfg" w ]
if {[info exists userhsf]} {
set lmatsection 0
set lyridx "" 
set matprop 0
set fpuhsf [ open "$userhsf" r ]
while { [ gets $fpuhsf line ] >=0 } {
        if { ![ regexp -all "\#" $line ] && $line ne ""} {
#		puts "CC"
		if { $lmatsection == 1 } {
			if {[ regexp {^\s*\}} $line tmp ]} {
			set lmatsection 0
			} elseif {[ regexp -nocase {^\s*(\S+)\s+(\S+)} $line tmp lyr idx]} {
			## store all layers that needs to be back-annotated
				if {![ regexp -nocase {sub} $lyr tmp]} {
				lappend lyridx $idx
				}
			}
		} else {
		if {[ regexp -nocase {^\s*CutBoundary\s+(\S+\s+\S+\s+\S+\s+\S+)} $line tmp box ]} {
			puts "-I- User defined BBOX is $box"
			set matprop 0
		} elseif {[ regexp -nocase {^\s*StartEndLayer\s+(\S+)\s+(\S+)} $line tmp slayer elayer]} {
			puts "-I- User defined  Start End layer is $slayer $elayer"	
			set matprop 0
		} elseif {[ regexp -nocase {^\s*Top_temperature\s+(\S+)} $line tmp top_t]} {
			puts "-I- Top temperature is $top_t"
			set matprop 0
		} elseif {[ regexp -nocase {^\s*Btm_temperature\s+(\S+)} $line tmp btm_t]} {
			puts "-I- Top temperature is $btm_t"
			set matprop 0
		} elseif {[ regexp -nocase {^\s*Silicon_substrate\s+(\S+)} $line tmp subt]} {
			puts "-I- Substrate thickness is $subt"
			set matprop 0
		} elseif {[ regexp -nocase {^\s*Material\s+(\S+)} $line tmp ]} {
		   	set user_hsf 1
			set matprop 1
			puts "-I- Material properties defined for all layers skipping Materials section and Layer to material mapping section"
		} elseif {[ regexp -nocase {^\s*Default_Material\s+(\S+)\s+(\S+)} $line tmp idx]} {
			set dfltidx $idx
			puts "-I- Default Material that will be back-annotated is mlyr"
		} elseif {[ regexp -nocase {^\s*Layer_material} $line tmp]} {
			set lmatsection 1
		}
		}
		if {$user_hsf==1} {
			if {$matprop==1} {
			puts $fphsf "$line"
			}
		} 
		}
}
}
## 1 mil = 25.64um 
if {[info exists subt] == 0} {
puts "-I- Using default substrate thickness of 700um, ~27mil"
set subt 700 
} 
set sub_thk [ expr {($subt/$height)} ]
puts "$layer $height $sub_thk"
set fpgett [ open "$tmpdir/getAnsTemp.in" w ]
if { [info exists box ] } {
puts "-I- User specified BBOX ($box) is set as CutBoundary for FEM simulations "
} else {
set box [ get design -bbox ]
}
set cutb $box
set temp [ gsr get TEMPERATURE_EM ]
	if { $temp eq "" } {
	set temp [ gsr get TEMPERATURE ]
	} else {
	set temp 25
	puts "-I- Since temperature is not set in the GSR, setting temperature as 25"
	}
puts $fphsf "Network_pg hot_interconnect_file_PG"
puts $fphsf "OD_loc_file bpf.rpt"
puts $fphsf "CTM_folder adsThermal/"
puts $fphsf "CutBoundary $cutb"
puts "CutBoundary $cutb"
if {[info exists mshlayers]} {
puts $fphsf "StartEndLayer $mshlayers"
} elseif {[info exists slayer]} {
puts $fphsf "StartEndLayer $slayer $elayer" 
} else {
puts $fphsf "StartEndLayer $slayer $elayer" 
}
puts $fphsf "Silicon_substrate $sub_thk"
puts "Silicon_substrate $sub_thk"
puts $fphsf "OD_thickness 0.05"
puts $fphsf "ModelLocation ./" 
## Removed top temperature
if {[info exists top_t]} {
puts $fphsf "Top_Temperature $top_t" 
}
if {[info exists btm_t]} {
puts $fphsf "Btm_Temperature $btm_t" 
} else {
puts $fphsf "Btm_Temperature $temp" 
}
puts $fphsf "# -------------- Mesh control -------------
# Geometry merging tolerance 
Mesh_t     0.1
# Maximum edge length in mesh (um)
#Mesh_l     1000
Mesh_l     30
# Triangle quality control for edges larger than 
Mesh_qt   40
# Minimum triangle angle
Mesh_qa  10"
if {$user_hsf ==0} {
puts "# -------------- Layer Material -------------
# Material properties: Material, ID, Name, Num_properties, 
Material   1  Copper  {
   	EX         120.0 
   	NUXY     0.33     
   	ALPX      1.7e-5
   	KXX        0.391e-3     
   	REFT       20
}
Material   2  Dielectric {
 	EX          3.0 
 	NUXY     0.3     
 	ALPX     1.7e-5
 	KXX       1.38e-6     
 	REFT      20
}
Material   3  Silicon {
	 EX          161.0 
	 NUXY     0.20675     
	 ALPX     2.6e-6
	 KXX       146e-6     
	 REFT      20
}
Material   4  OD {
	 EX          161.0 
	 NUXY     0.20675     
	 ALPX     2.6e-6
	 KXX       146e-6     
	 REFT      20
}
# -------------- Default metal/dielectric material IDs --- 
Default_material  1   2
# Layer Metal/Dielectric material ID
Layer_material {
	Sub  3
	OD  4
}"
}
puts $fpgett "T_ref $temp
Hot_PG_file ./hot_interconnect_file_PG
AnsysM_RUN 1 {
PG_nodes wsnode.pg
Ansys_results ./T_wires.txt
}"
set fpansm [ open "$tmpdir/run_ansys_apdl.txt" w ]
puts $fpansm "
!run batch: (examples)
/batch
/config,noeldb,1     ! force off writing results to database
/INPUT,'chipmodel','ans','',1,0 
/config,norstgm,1   
/SOLU   
!
!create component
!"
if {[info exists dfltidx]} {
puts $fpansm "ESEL,S,MAT,,$dfltidx "
} else {
puts "-I- default index is used"
puts $fpansm "ESEL,S,MAT,,1"
}
if {[info exists lyridx]} {
foreach a $lyridx {
puts $fpansm "ESEL,A,MAT,,$a"
}
}
puts $fpansm "
ALLSEL,BELOW,ELEM   
CM,n_wires,NODE 
CM,e_wires,ELEM 
ALLSEL,ALL
! 
! do not write any solver result to the results file
outres,all,none 
! write nodal solution to the results file
outres,nsol,all,n_wires
/STATUS,SOLU
EQSLV,PCG,1E-6,0
SOLVE   
FINISH  
/POST1
/page,1000000,,1000000"
if {[info exists dfltidx]} {
puts $fpansm "ESEL,S,MAT,,$dfltidx "
} else {
puts "-I- default index is used"
puts $fpansm "ESEL,S,MAT,,1"
}
if {[info exists lyridx]} {
foreach a $lyridx {
puts $fpansm "ESEL,A,MAT,,$a"
}
}
puts $fpansm "
ALLSEL,BELOW,ELEM   
/output,'./T_wires.txt'
PRNSOL,TEMP
!/output
save,ansysm,db
fini
/exit,nosav"
close $fpctm
close $fpansm
close $fphsf
close $fpgett
}





### All old and deprecated routines are here##
proc show_IDS_map {} {
	select clearall
	config viewlayer -name all -style invisible
 	config viewlayer -name instance -style outline
	##collecting the data
	set file [glob "adsRpt/ESD/esd_summary.rpt"]
	set file1 [open $file r]
	set k1 0
	set rdsonchk 0
	while { [gets $file1 line] >= 0 } {
		if { [ regexp -nocase {^\s*NAME\s+(\S+)} $line tmp rule ] } { 
			if { [ regexp -nocase {RDSON(\S*)} $rule tmp ]} {
				set rdsonchk 1 
			} else {
				set rdsonchk 0 
			}
		}
		if { $rdsonchk == 1 } {
		set lines2($k1) $line
		incr k1
		}
	}
	close $file1
	set count 0
	set flag 0
	for {set j 0} {$j<$k1} {incr j} {
		if {$flag==0} {
			if {[regexp {^\# <I> <V> <Ron>\s+.*} $lines2($j) all]} {
			set flag 1
			continue 
			} 
		} else {
			set line [split $lines2($j)]
			set IDS [lindex $line 0]
			set voltage $IDS
			set cords_x1 [lindex $line 4]
			set cords_y1 [lindex $line 5]
			set cords_x2 [lindex $line 9]
			set cords_y2 [lindex $line 10]
			set inst_1 [lindex $line 13]
			set inst [lindex [split $inst_1 "("] 0]
			if {$inst==""} {
			continue
			}
			set cord_x1($count) $cords_x1 
			set cord_y1($count) $cords_y1 
			set cord_x2($count) $cords_x2 
			set cord_y2($count) $cords_y2 
			set voltages($count) $voltage
			set insts($count) $inst
			incr count;
		}
	}

 	set v_value ""
	foreach cn [array names voltages] {
        set v_value [concat $v_value $voltages($cn)]
        }
       
	set crnt [lsort -real -increasing $v_value]
	set min [lindex $crnt 0]
	set length [llength $crnt]
	set last [expr $length - 1 ]
	set max [lindex $crnt $last]
	set bucketsize [format %.4f [expr ($max-$min)/14]]
	#puts "$min $max $bucketsize $length"	
	foreach cnt  [array names voltages] {
		set m $voltages($cnt)
		if { $m < [expr $min +  $bucketsize] } {
			#puts "$m < [expr $min +  $bucketsize] "
			plot line -position $cord_x1($cnt) $cord_y1($cnt) $cord_x2($cnt) $cord_y2($cnt) -color blue -width 8
		}
		if { $m >= [expr $min +  $bucketsize] && $m < [expr $min +  2*$bucketsize] } {
			plot line -position $cord_x1($cnt) $cord_y1($cnt) $cord_x2($cnt) $cord_y2($cnt) -color blueviolet -width 8
		}


		if { $m >= [expr $min +  2*$bucketsize] && $m < [expr $min +  5*$bucketsize] } {
			plot line -position $cord_x1($cnt) $cord_y1($cnt) $cord_x2($cnt) $cord_y2($cnt) -color greenyellow -width 8
			}

		if { $m >= [expr $min +  5*$bucketsize] && $m < [expr $min +  8*$bucketsize] } {
			plot line -position $cord_x1($cnt) $cord_y1($cnt) $cord_x2($cnt) $cord_y2($cnt) -color yellow -width 8
		}

		if { $m >= [expr $min +  8*$bucketsize] && $m < [expr $min +  11*$bucketsize] } {
			plot line -position $cord_x1($cnt) $cord_y1($cnt) $cord_x2($cnt) $cord_y2($cnt) -color orange -width 8
		}

		if { $m >= [expr $min +  (11*$bucketsize)] } {
			plot line -position $cord_x1($cnt) $cord_y1($cnt) $cord_x2($cnt) $cord_y2($cnt) -color red -width 8
		}



	}

set bbox [ get design -bbox ]
set llx [ lindex $bbox 0 ]
set lly [ lindex $bbox 1 ]
set urx [ lindex $bbox 2 ]
set ury [ lindex $bbox 3 ]
set xpos [expr $urx+20]
#set ypos [expr $lly+(($lly+$ury)/5) ]
set ypos [expr $lly+2 ]
set min1 [ format {%0.3f} $min ]
set max1 [format {%0.3f} [ expr $min+ $bucketsize] ]
set size 20 
#puts " COLOR MAP:"
      	__GUI:::putMsg  "$min A - $max1 A" $xpos $ypos $size $size blue 
	set min1 [format {%0.4f} $max1 ]
	set max1 [format {%0.4f} [ expr $min + 2*$bucketsize ]]
#	puts " Between $min1 A and $max1 A COLOR BLUE "
	set ypos [ expr $lly + 40 ]
      	__GUI:::putMsg  "$min1 A - $max1 A" $xpos $ypos $size $size blueviolet 
#	puts " Between $min1 A and $max1 A COLOR CYAN"
	set min1 [format {%0.4f} $max1]
	set max1 [format {%0.4f} [ expr $min + 5*$bucketsize ]]
	set ypos [expr  $lly + 80 ]
      	__GUI:::putMsg  "$min1 A - $max1 A" $xpos $ypos $size $size greenyellow 
#	puts " Between $min1 A and $max1 A COLOR GREEN"
	set min1 [format {%0.4f} $max1]
	set max1 [format {%0.4f} [ expr $min + 8*$bucketsize ]]
	set ypos [ expr $lly + 120 ]
      	__GUI:::putMsg  "$min1 A - $max1 A" $xpos $ypos $size $size yellow 
#	puts " Between $min1 A and $max1 A COLOR YELLOW"
	set min1 [format {%0.4f} $max1 ]
	set max1 [format {%0.4f} [ expr $min + 11*$bucketsize ] ]
	set ypos [ expr $lly + 160 ]
      	__GUI:::putMsg  "$min1 A - $max1 A" $xpos $ypos $size $size orange
#	puts " Between $min1 A and $max1 A COLOR ORANGE"
	set min1 [format {%0.4f} $max1 ]
	set max1 [format {%0.4f} [ expr $min + 14*$bucketsize ]]
	set ypos [ expr $lly + 200 ]
      	__GUI:::putMsg  "$min1 A - $max1 A" $xpos $ypos $size $size red
#	puts " Between $min1 A and $max1 A COLOR RED"
}
###
