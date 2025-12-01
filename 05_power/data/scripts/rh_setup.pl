# $Revision: 2.38 $
# internal_revision 2.25
#==================================================================
# This scripts requires from user to define a minimum set
# of variables an then creates all files necessary for RedHawk run
#==================================================================

# Revision history
# Rev2.27
# Added explorer command "explore design" to the run tcl
# Rev2.26
# DYNAMIC_MOVIE keyword is obsolete, removed it. 
# Rev2.25
# - Keywords DYNAMIC_MOVIE and DYNAMIC_EM are set to '0' by default
# Rev2.24 
# - Corrected the bug where pwcap file was followed by cap attribute instead of the pwcap attribute
# Rev 2.23
# - Added keywords to GSR with default values. ad_mode, dynamic_simulation_time, dynamic_time_step, input_transition and toggle_rate.
#Rev 2.22
# - Added some checks based on the analysis and mode specified and prompt the user to edit the GSR to provide the mandatory inputs reuqired for the RH run based on mode and anlysis type
# Rev 2.21
# - Added new switches mode and analysis to specify whether gsr is for early_analysis mode or sign_off_analysis mode and anlysis type is static dynamic or lowpower 
# Rev 2.20
# - For Redhawk 5.3 - apl current and cdev files are specified in GSR
#  with APL_FILES keyword and not imported with 'import apl'
# Rev 2.19
# - Add "setup analysis_mode static/dynamic" right after setup design
# Rev 2.18 
# - Print help for required variables which were not provided
# - Use "none" or "???" as a value if you want to disable default value of 
#   a flag without setting a new value.   Ex: -sta none 
# - run_dynamic.tcl will not be generated and appropriate message is printed if
#   a. timing file is not specified
#   b. apl current file is specified but decap (usually cell.cdev) is not
# Rev 2.17
# - rh_setup.defaults must have "FREQ" keyword declared
# - changes SLEW default to a more reasonable 200ps
# - Better printing of undefined (???) variables
# - "-spf '???'" resulted in empty illegal CELL_RC FILE
# Rev 2.16
# - If user specified a pattern with -gds_dirs,script ignores
#  matched non-directories (i.e files) 
# Rev 2.15
# - Look for files under ../design_data and only then under ../../data
#   This is encoded in rh_setup.defaults
# - Looks for gzipped lef/def/lib/timing files as well
# - No hardcoded default for frequency. User has to define it
# - setup package/wirebond/pad with explicit 0
# - run_setupApl file is no longer created. Correspondent line is moved to run_static.apl
# Rev 2.14
# - Renamed apache_default.gsr to rh_setup.defaults. gsr extention was
#   making an impression, that it's a legal gsr file.
# Rev 2.13
# - Switched to more robust parseGSR function. Stored GSR keyword help is not followed
#   by a new line any more
# Rev 2.12
# - Moved parseGSR and mergeGSR functions to edaUtils.pm
# Rev 2.11
# - Search path works for command line arguments as well
# Rev 2.10 
# - If template gsr is newer than rh_setup.init - delete rh_setup.init
# Rev 2.9
# - Implemented search path in template gsr. Repeated appearances of files with the same base 
# name are rejected
# Rev 2.8
# - Corrected reporting of defaults
# - Stupid bug - eda_utils.pm was not searched in $cwd
# - Obsoleted peak_pwr command line parameter
# - Error out if there are multiple def files for the top level
# - Reports number of matched files in abbreviated lines
# Rev 2.7
# - Fixed minor bug.  -spf "???" should create empty CELL_RC record in gsr
# Rev 2.6
# - Fixed bug preventing correct extraction of design name from STA 
# Rev 2.5
# - Bug fix  -input_slew option didn't work  
# - Bug fix  -gds_dirs could find only gdsmem cells, but not gds2def
# Rev 2.4
# - Create run_setup_apl.tcl
# Rev 2.3
# - Replaced 'grepping' in LEF files (search fro TYPE keyword) with pure perl,
#   since grep didn't work on Solaris
# - Print aplcap placeholder to run_dynamic.tcl
# Rev 2.2
# - Don't save <design>.{lefs,defs,libs} in all_in_gsr mode
# - Check that voltage is not specified along with vss name
# - If by mistake the def list contains directories along with true files
#   don't look in 'directories'
# Rev 2.1
# - Bug fix. If any file pattern has no matches, corresponding GSR word 
#   will be commented
# Rev 2.0
# - Major departure from hardcoded GSR generation to a template based model
#   rh_setup now constructs GSR from 4 sources in the following precedence
#   a. From rh_setup.pl command line parameters
#   b. From parameters of previous invocation of rh_setup.pl saved in rh_setup.init
#   c. From template gsr pointed by variable $APACHEDA_TEMPLATE_GSR, if this
#      file exists
#   d. From the default gsr distributed by Apache:
#      $APACHEROOT/bin/apache_default.gsr
# - gds_dirs option
# - all_in_gsr option. If set to 'off' .defs,.lefs,.libs files are generated. Otherwise
#   list appear directly in GSR (default)
# - old <design>.gsr is copied to <design>.gsr.<date>
# - Default location of data can be defined in template GSR, for ex:
#    DEF_FILES {
#     ../../data/def/*.def
#     }
#
# Rev 1.13
# - don't specify full path to gsr file in run_static.tcl and run_dynamic.tcl 
# Rev 1.12
# - fix bug related to aplcap
# Rev 1.11
# - eda_utils.pl is renamed to eda_utils.pm. rh_setup looks fro eda_utils.pm 
#   either in $cwd or $cwd/pm
# Rev 1.10
# - More file existence checks + better formatted output
# Rev 1.9
# - -pad_files option may be followed with a special keyword def_pins
#   This will trigger ADD_PLOC_FROM_TOP_DEF 1 to apepar in GSR file
# Rev 1.8
# - Complies with Redhawk 5.2 controls - everything is in GSR!
# - Warning if lef files have no or multiple technology section
# Rev 1.7
# - Better help message
# - Automatic detection of revision
# Rev 1.6
# - VDD net names and voltages are defined with a single argument "-vdd_nets"
# - completion of arguments if unambiguous, like "-vdd_n" -> "-vdd_nets" 
# - can handle cell.current and cell.cdev independently
# Rev 1.5
# - IOSSO mode
# Rev 1.4
# - Support of avm
# - User can specify average and peak cycle power
# - Long parameter lines are truncated
# - All file paths are absolute
# Rev 1.3
# - Fixed bug related to automatic ordering of def files
# - Much more substance and comments in generated GSR file
# Rev 1.2
# - If user didn't specify any parameter and they were all extracted from 
#   rh_setup.init - just print info and don't regenerate any files
# - Support multiple spf and sta 
# - Support multiple vdd
# - Copy .gsr,.lefs,.libs,.defs to *.old if exist
# - Help and examples are added

# TO DO:
# - Automatic recognition of gdsmem cells ?


eval '(exit $?0)' && eval 'exec perl -S $0 ${1+"$@"}'
  && eval 'exec perl -S $0 $argv:q'
  if 0;


# Put a directory with eda_utils.pm into search path
# eda_utils.pm can be either in the current dir or in /pm
$script_installation_dir = dirname($0);
push(@INC,$script_installation_dir);
push(@INC,$script_installation_dir."/pm");



# Print Warnings and Errors by default
use vars qw(%GLOBAL_PARMS);
$GLOBAL_PARMS{VerboseLevel} = "W";
require "eda_utils.pm";
use File::Basename;

$revision = edaGetScriptRevision($0);
print "rh_setup.pl $revision - quick setup utility for RedHawk
Copyright (c) 2002-2007 Apache Design Solutions, Inc. All rights reserved.

";

# Here is array of required and optional variables
@VarList = (top_cell,mode,analysis,vdd_nets,vss_nets,frequency,tech_file,lef_files,def_files,lib_files,pgarc_file,pad_files,spf_files,sta_files,vcd_file,switch_model_file,gsc_file,bpa,apl_files,aplcap_files,aplpwcap_files,gds_dirs,avg_pwr,input_slew,toggle_rate,all_in_gsr,ad_mode,dyn_sim_time,dyn_presim_time,dyn_time_step,dyn_em,enable_auto_em,consistent_scenario,dynamic_report_dvd,ate_constraint_files,ate_options_file,enable_ate,cmm_cells,use_drawn_width_for_em,use_drawn_for_em_lookup,dynamic_frame_size,ignore_short,ignore_lef_def_mismatch,ignore_def_error,ignore_pgarc_error,ignore_ipf_error,ignore_apl_check,ignore_apl_process_corner,distributed_extract,use_fast_decap_alg,use_drawn_width_for_em_lookup,ignore_cells_file,decap_cells,lef_ignore_pin_layers,apache_files,push_pininst,split_sparse_via_array,dynamic_save_waveform,dynamic_report_decap,via_compress);

# Explanation default and examples of all variables
%VarProperties = ("top_cell" => {
				 "example" => "TOP",
				 "expl" => "Top module of design hierarchy for this analysis",
                                 "req_switch" => 1,
				},
		  "mode"  => {
				 "example" => "early_analysis",
				 "expl" => "Declare mode of analysis viz.  \"early_analysis\" or \"sign_off_analysis\" or \"performance\" ",
                                 "optional" => 1,
                                 "default" => "sign_off_analysis",
                                 "req_switch" => 1,
                             },
		  "analysis"  => {
				 "example" => "static",
				 "expl" => "Declare type of analysis \"static\", \"dynamic\", \"low_power\", \"signalEM\" or \"cpm\"",
                                 "optional" => 1,    
                                 "default" => "static and dynamic",
                                 "req_switch" => 1,
                             },
		  "tech_file" => {
				  "example" => "apache.tech",
				  "expl" => "Apache tech file with dielectrics, metal layers",
				  "gsr_word" => "TECH_FILE",
                                 "req_switch" => 1,
				 },

		  "lef_files" => {
				  "example" => "stdlib/*.lef macros/{A,B}.lef",
				  "expl" => "LEF files for technology,library cells, hierarchical and IP blocks",
				  "gsr_word" => "LEF_FILES",
                                 "req_switch" => 1,
				 },
		  "def_files" => {
				  "example" => "def/*def",
				  "expl" => "DEF files for top module, hierarchical and IP blocks",
				  "gsr_word" => "DEF_FILES",
                                 "req_switch" => 1,
				 },
		  "sta_files" => {
				  "example" => "timing/top.timing",
				  "expl" => "Timing files from STA",
				  "optional" => 1,
				  "gsr_word" => "STA_FILE",
                                 "req_switch" => 1,
				 },
		  "switch_model_file" => {
				  "example" => "apl/switch.model",
				  "expl" => "Required for a lowpower analysis run",
				  "optional" => 1,
				  "gsr_word" => "SWITCH_MODEL_FILE"
				 },

		  "use_drawn_width_for_em" => {
				  "example" => "apl/switch.model",
				  "expl" => "Required for perfomance mode ",
				  "optional" => 1,
				  "gsr_word" => "USE_DRAWN_WIDTH_FOR_EM"
				 },
		  "use_drawn_width_for_em_lookup" => {
				  "example" => "apl/switch.model",
				  "expl" => "Required for perfomance mode ",
				  "optional" => 1,
				  "gsr_word" => "USE_DRAWN_WIDTH_FOR_EM_LOOKUP"
				 },
		  "dynamic_frame_size" => {
				  "example" => "apl/switch.model",
				  "expl" => "Required for perfomance mode",
				  "optional" => 1,
				  "gsr_word" => "DYNAMIC_FRAME_SIZE"
				 },
		  "ignore_short" => {
				  "example" => "apl/switch.model",
				  "expl" => "Required for perfomance mode ",
				  "optional" => 1,
				  "gsr_word" => "IGNORE_SHORT"
				 },
		  "ignore_lef_def_mismatch" => {
				  "example" => "apl/switch.model",
				  "expl" => "Required for a perfomance mode ",
				  "optional" => 1,
				  "gsr_word" => "IGNORE_LEF_DEF_MISMATCH"
				 },
		  "ignore_def_error" => {
				  "example" => "apl/switch.model",
				  "expl" => "Required for perfomance mode ",
				  "optional" => 1,
				  "gsr_word" => "IGNORE_DEF_ERROR"
				 },
		# #"dynamic_report_decap" => {
		#		  "example" => "apl/switch.model",
		#		  "expl" => "Required for perfomance mode ",
		#		  "optional" => 1,
		#		  "gsr_word" => "DYNAMIC_REPORT_DECAP"
		#		 },
		#  "dynamic_save_waveform" => {
		#		  "example" => "apl/switch.model",
		#		  "expl" => "Required for perfomance mode ",
		#		  "optional" => 1,
		#		  "gsr_word" => "DYNAMIC_SAVE_WAVEFORM"
		#		 },
		#  "via_compress" => {
		#		  "example" => "apl/switch.model",
		#		  "expl" => "Required for perfomance mode ",
		#		  "optional" => 1,
		#		  "gsr_word" => "VIA_COMPRESS"
		#		 },
		#  "split_sparse_via_array" => {
		#		  "example" => "apl/switch.model",
		#		  "expl" => "Required for perfomance mode ",
		#		  "optional" => 1,
		#		  "gsr_word" => "SPLIT_SPARSE_VIA_ARRAY"
		#		 },
		#  "push_pininst" => {
		#		  "example" => "apl/switch.model",
		#		  "expl" => "Required for perfomance mode ",
		#		  "optional" => 1,
		#		  "gsr_word" => "PUSH_PININST"
		#		 },

		  "ignore_pgarc_error" => {
				  "example" => "apl/switch.model",
				  "expl" => "Required for perfomance mode",
				  "optional" => 1,
				  "gsr_word" => "IGNORE_PGARC_ERROR"
				 },
		  "ignore_ipf_error" => {
				  "example" => "apl/switch.model",
				  "expl" => "Required for perfomance mode",
				  "optional" => 1,
				  "gsr_word" => "IGNORE_IPF_ERROR"
				 },
		  "ignore_apl_check" => {
				  "example" => "apl/switch.model",
				  "expl" => "Required for perfomance mode",
				  "optional" => 1,
				  "gsr_word" => "IGNORE_APL_CHECK"
				 },
		  "ignore_apl_process_corner" => {
				  "example" => "apl/switch.model",
				  "expl" => "Required for perfomance mode",
				  "optional" => 1,
				  "gsr_word" => "IGNORE_APL_PROCESS_CORNER"
				 },
		  "distributed_extract" => {
				  "example" => "apl/switch.model",
				  "expl" => "Required for perfomance mode",
				  "optional" => 1,
				  "gsr_word" => "DISTRIBUTED_EXTRACT"
				 },
		  "use_fast_decap_alg" => {
				  "example" => "apl/switch.model",
				  "expl" => "Required for perfomance mode",
				  "optional" => 1,
				  "gsr_word" => "USE_FAST_DECAP_ALG"
				 },
		  "ignore_cells_file" => {
				  "example" => "apl/switch.model",
				  "expl" => "Required for perfomance mode",
				  "optional" => 1,
				  "gsr_word" => "IGNORE_CELLS_FILE"
				 },
		  "decap_cells" => {
				  "example" => "apl/switch.model",
				  "expl" => "Required for perfomance mode",
				  "optional" => 1,
				  "gsr_word" => "DECAP_CELLS"
				 },
		  "lef_ignore_pin_layers" => {
				  "example" => "apl/switch.model",
				  "expl" => "Required for perfomance mode",
				  "optional" => 1,
				  "gsr_word" => "LEF_IGNORE_PIN_LAYERS"
				 },
		  
		   "ate_constraint_files" => {
				  "example" => "timing/*sdc",
				  "expl" => "Required for generating the STA files during setup design phase",
				  "optional" => 1,
				  "gsr_word" => "ATE_CONSTRAINT_FILES"
				 },

                    "ate_options_file" => {
				  "example" => "timing/<file_name>.tcl",
				  "expl" => "TCL file to enable you to pass options to ATE. values in this file will be included at the top of ate.cmd file Redhawk creates",
				  "optional" => 1,
				  "gsr_word" => "USER_OPTIONS_FILE"
				 },

 		"cmm_cells" => {
				  "example" => "cmm/*",
				  "expl" => "Required for including CMM models in redhawk run",
				  "optional" => 1,
				  "gsr_word" => "CMM_CELLS"
				 },


		  "bpa" =>       {
                                  "example" => "on, off",
				  "expl" => "Required for a early analysis run, to assign power to different metal layers and vias",
				  "optional" => 1,
				  "gsr_word" => "BLOCK_POWER_ASSIGNMENT",
				 },
		  "vcd_file" => {
				  "example" => "top.vcd",
				  "expl" => "Specify the vcd file for a vector based dynamic analysis",
				  "optional" => 1,
				  "gsr_word" => "VCD_FILE",
				 },
		  "gsc_file" => {
				  "example" => "top.gsc",
				  "expl" => "Specify the gsc file for a lowpower analysis run",
				  "optional" => 1,
				  "gsr_word" => "GSC_FILE",
				 },
		  "lib_files" => {
				  "example" => "/home/libs/*lib",
				  "expl" => "Synopsys Liberty format (.lib) timing libraries",
	                  	  "gsr_word" => "LIB_FILES",
                                  "optional" => 1,
                                 "req_switch" => 1,
				 },
		  "pgarc_file" => {
				  "example" => "custom.pgarc",
				  "expl" => "Specify the custom.pgarc file to support cells with multi vdd and multi vss pins",
				  "optional" => 1,
				 },
		  "spf_files" => {
				  "example" => "top.spef block.dspf",
				  "expl" => "Hierarchical SPEF or DSPF files of post-layout parasitics",
				  "optional" => 1,
				  "gsr_word" => "CELL_RC_FILE",
                                 "req_switch" => 1,
				 },
		  "pad_files" => {
				 "example" => "top.ploc or def_pins keyword",
				 "expl" => "Apache PLOC file that gives X,Y of ideal Voltage sources\n\tFor block level analysis you can use keyword 'def_pins'. This forces Redhawk\n\t to place one pad in the center of every VDD/VSS pin described in top-level\n\tdef file.  ",
				  "gsr_word" => "PAD_FILES",
                                 "req_switch" => 1,

				},
		  "apl_files" => {
				  "example" => "apl/cell.current",
				  "expl" => "Apache cell.current file of current profiles from apl run",
				  "gsr_word" => "APL_FILES",
				  "optional" => 1,                                 
				 },
		  "aplcap_files" => {
				     "example" => "apl/cell.cdev",
				     "expl" => "Apache cell.cdev decap file from apl -c run",
				     "optional" => 1,
                                 "req_switch" => 1,
				    },
		  "aplpwcap_files" => {
				     "example" => "apl/cell.pwcap",
				     "expl" => "Apache cell.pwcap decap file from apl -w run",
				     "optional" => 1,
                                 "req_switch" => 1,
				    },
		  "gds_dirs" => {
				 "example" => "data/gdsmem data/gdsdef",
				 "expl" => "Load all lef/def/lib files created by gds2def/gdsmem in specified directories",
				 "optional" => 1,
                                 "req_switch" => 1,
				},
		  "vdd_nets" => {
				 "example" => "VDD 1.1 VDDO 2.0",
				 "expl" => "Names of power nets used in this analysis along with nominal voltages",
                                 "req_switch" => 1,
				},
		  "vss_nets" => {
				 "example" => "VSS VSSO",
				 "expl" => "Names of ground nets used in this analysis",
                                 "optional" => 1,
                                 "req_switch" => 1,
				},
		  "input_slew" => {
				   "example" => "20ps",
				   "expl" => "Default input slew of all cells",
				   "optional" => 1,
				   "gsr_word" => "INPUT_TRANSITION",
                                   "default" => "200ps"
				  },
		  "frequency" => {
				  "example" => "100e6",
				  "expl" => "Primary operating frequency of this design (Hz)",
				  "gsr_word" => "FREQ",
                                 "req_switch" => 1,
				 },
		  "toggle_rate" => {
				    "example" => "0.3",
				    "expl" => "Default uniform activity level of this design",
				    "optional" => 1,
                                    "default" => "0.3"
				   },
		  "dyn_sim_time" => {
				    "example" => "2.56e-9",
				    "expl" => "If specified, dynamic simulation uses the specified start and end times",
				    "optional" => 1,
                                    "gsr_word" => "DYNAMIC_SIMULATION_TIME",  
                                    "default" => "2.56e-9",
				   },
		  "dyn_presim_time" => {
				    "example" => "10ns 2",
				    "expl" => "Specifies the time to initialize capacitance charge and inductor current before time t=0 for starting simulation.",
				    "optional" => 1,
                                    "gsr_word" => "DYNAMIC_PRESIM_TIME",  
                                    "default" => "-1"
				   },
		  "dyn_time_step" => {
				    "example" => "25e-12",
				    "expl" => "Defines dynamic simulation time step. Default: 10ps",
				    "optional" => 1,
                                    "gsr_word" => "DYNAMIC_TIME_STEP",  
				   },
		  "dyn_em" => {
				    "example" => "0",
				    "expl" => "Turns on Dynamic Power EM",
				    "optional" => 1,
                                    "gsr_word" => "DYNAMIC_EM",  
                                    "default" => "0" 
				   },

                  "enable_auto_em" => {
				    "example" => "0",
				    "expl" => "Enables/ Disbales EM check ",
				    "optional" => 1,
                                    "gsr_word" => "ENABLE_AUTO_EM", 
				    "default" => 0,
				   },

       		  "enable_ate" => {
				    "example" => "0",
				    "expl" => "Enables/ Disbales EM check ",
				    "optional" => 1,
                                    "gsr_word" => "ENABLE_ATE",  
                                    "default" => "0" 
				   },



		  "avg_pwr" => {
				"example" => "0.8",
				"expl" => "Average chip power (watt). If defined, all instance toggle rates are\n\tscaled to bring the total chip power to a requested level",
				"optional" => 1,
			       },
		  "ad_mode" => {
			      "example" => "1, 0",
			      "expl" => "Switch on the accelrated dynamic mode or off",
		              "optional" => 1,
                              "gsr_mode" => "AD_MODE", 
			     },

                 "consistent_scenario" => {
			      "example" => "1, 0",
			      "expl" => "Insures similar designs have similar switching scenarios",
			      "optional" => 1,
                              "default" => 1,
                              "gsr_mode" => "CONSISTENT_SCENARIO", 
			     },

                  "dynamic_report_dvd" => {
			      "example" => "1, 0",
			      "expl" => "Enables reporting of TW-based effective voltage drop for all switching cycles ",
			      "optional" => 1,
                              "default" => 1,
                              "gsr_mode" => "DYNAMIC_REPORT_DVD", 
			     }, 
		  "gsr_include" => {
				    "expl" => "List all lef/def/lib files directly in GSR",
				    "default" => "off",
				   },
		  "template_gsr" => {
				     "example" => "central_cad/proj1/xyz.gsr",
				     "expl" => "Extract parameters from template GSR file",
				     "optional" => 1,
				    },
		  "all_in_gsr" => {
				   "example" => "on, off",
				   "expl" => "If 'on', all input lef/def/lib files are listed directly in GSR. If 'off'\n\t, <design>.{lefs,defs,libs} list files will be created and GSR will\n\tpoint to these files",
				   "optional" => 1,
				   "default" => "on",
				  }
		 );



#setting different default values for defaults if mode performance is selected
use Data::Dumper;

my %VarHash_copy ;
edaGetOptions(\@ARGV,\%VarHash_copy,\@VarList);
#print Dumper(\%VarHash_copy);

if ( $VarHash_copy{mode} eq "performance" ) {
  $VarProperties{toggle_rate}{"default"} = "???" ;
$VarProperties{dyn_presim_time}{"default"} = "???" ;
 $VarProperties{input_slew}{"default"} = "???" ;
 
}


# Create separate lists of required and optional variables
foreach $var (@VarList) {
  if (defined $VarProperties{$var}{"optional"}) {
    push(@ptionalVarList,$var);
  } else {
    push(@RequiredVarList,$var);
  }
}

#====================================================================
# Merge 2 GSR sources:
#  3'rd priority - central GSR file - usually provided by central CAD
#  4'th priority - hardcoded values coming from Apache-provided rh_setup.defaults
# later they will be merged with 1'st priority - GSR formed from user 
# commands 
#====================================================================
%DefaultGSR = ();%CentralGSR = ();%TempGSR = ();%CombinedGSR = ();

# Load 4'th priority rh_setup.defaults and save it in hash %DefaultGSR
# Note, that list of GSR keywords comes from the default GSR
@GSR_keywords = parseGSR("$script_installation_dir/rh_setup.defaults",\%DefaultGSR);

# If $APACHEDA_TEMPLATE_GSR is defined - load it (3'rd priority) and
# merge with previously imported rh_setup.defaults and save again
# in hash %DefaultGSR
if (defined $ENV{APACHEDA_TEMPLATE_GSR}) {
  # If template GSR exists
  # Merge default and central(template) gsr
  if (not -r $ENV{APACHEDA_TEMPLATE_GSR}) {
    print("-E- Template GSR file $ENV{APACHEDA_TEMPLATE_GSR} doesn't exist or unreadable! Create it or 'unsetenv APACHEDA_TEMPLATE_GSR'\n");
    exit(-1);
  }
  edaCheckInputFiles($ENV{APACHEDA_TEMPLATE_GSR});
  edaMsg("Parsing template GSR file $ENV{APACHEDA_TEMPLATE_GSR}...");
  parseGSR($ENV{APACHEDA_TEMPLATE_GSR},\%CentralGSR);
  mergeGSR(\%CentralGSR,\%DefaultGSR,\%TempGSR);
  %DefaultGSR = %TempGSR;

  # If template gsr is newer than rh_setup.init - delete rh_setup.init
  if (-r "rh_setup.init" and (edaAreFileTimeStampsInSequence($ENV{APACHEDA_TEMPLATE_GSR},"rh_setup.init") == 0)) {
    edaMsg("Removing rh_setup.init...","W");
    edaRemoveFiles("rh_setup.init");
  }
}


# For all file-related parameters
# a. expand wildcards
# b. check that there is at least one matching file, if not -
#    clear GSR entry
foreach $gsr_key (keys(%DefaultGSR)) {
  if (not ($gsr_key =~ m/FILE/)) {
    next;
  }
   
  $gsr_value = $DefaultGSR{$gsr_key}{text};
  $gsr_value =~ s/\{//; $gsr_value =~ s/\}//;
  $gsr_value = edaCleanLine($gsr_value);
  @ExpandedFileList = glob($gsr_value);
  
  # If default GSR record for this parameter is empty...
  if ( $#ExpandedFileList < 0) {
    $DefaultGSR{$gsr_key}{text} = "";
    next;
  } 


  # OK, it's not empty
  # Save unexpanded value for display in help
  $DefaultGSR{$gsr_key}{unexpanded_text} = $gsr_value;
  
  $DefaultGSR{$gsr_key}{text} = "{\n";
  # Remove multiple appearances of identical files
  %FileNamesHash = ();
  foreach $file (@ExpandedFileList) { 
    # Check, that it's indeed file and not some parameter...
    if (not (-r $file)) {
      next;
    }

    $base_name = basename($file);
    if (defined $FileNamesHash{$base_name}) {
      edaMsg("File $file is found more than once in search path!","I");
      next;
    }

    # First appearance of current basename - save it
    $FileNamesHash{$base_name} = 1;
    $DefaultGSR{$gsr_key}{text} .= " $file\n";
  }
  $DefaultGSR{$gsr_key}{text} .= "}";

}
# At this point DefaultGSR absorbed both rh_setup.defaults and 
# APACHEDA_TEMPLATE_GSR. File patterns are expanded to explicit lists

# Here we start a population of $VarHash - structure which contains
# all controlling variables.
# Note that full list of variables is a superset of all

# We begin with 3'rd priority - data is either hardcoded or comes from 
# default/central GSR's
foreach $var_name (@VarList) {

  # To start pre-set "???" or hardcoded default for all variables
  if (defined $VarProperties{$var_name}{"default"}) {
    $VarHash{$var_name} = $VarProperties{$var_name}{"default"};
   } else {
    $VarHash{$var_name} = "???";
    }
# Setting up default values for analysis for analysis and mode if not specified
 
  # Check if default GSR value exists and not empty
  # if yes copy its value from $DefaultGSR to $VarHash thus overriding the pre-set ???
  if (not defined $VarProperties{$var_name}{"gsr_word"}) {
   next;
  }
 
  $gsr_key = $VarProperties{$var_name}{"gsr_word"};
  $gsr_value = $DefaultGSR{$gsr_key}{text};
  if ($gsr_value eq "") {
    next;
  }

  $gsr_value =~ s/\{//; $gsr_value =~ s/\}//;
  $gsr_value = edaCleanLine($gsr_value);
  $VarHash{$var_name} = $gsr_value;
}

# Second  priority - from rh_setup.init file with previously defined 
# variables (if exists)
# Every line has following syntax:
# <var_name> : <value1> <value2> ...
if (-r "rh_setup.init") {
  edaOpenFile(IN, "rh_setup.init", "r");
  edaMsg("Reading rh_setup.init...");
  while (<IN>) {
    chomp();
    @Line = split(" ",$_);
    $var_name = shift(@Line);
    shift(@Line);
    $VarHash{$var_name} = join(" ",@Line);
  }
  close IN;
}
$num_of_args = $#ARGV + 1;


if ($ARGV[0] =~  m/^-h/ || $ARGV[0] =~  m/^-m/ || $ARGV[0] =~  m/^-man/) {
  usage();
  exit;
}

# First priority - from command-line arguments
edaGetOptions(\@ARGV,\%VarHash,\@VarList);



# Print all parameters with their values
# Check if all mandatory parameters were defined by the user
# Save all currently defined parameters in the rh_setup.init file
$all_parms_defined_flag = 1;
edaOpenFile(OUT, "rh_setup.init", "wf");
print "
--------------+---------------------------------------------------
Option        | values
--------------+---------------------------------------------------\n";
foreach $var (@VarList) {
  # If variable is empty or unknown
  if (($VarHash{$var} eq "") or ($VarHash{$var} eq "none")) {
    $VarHash{$var} = "???";
  }
  if ($VarHash{$var} eq "???" || $var eq "analysis" || $var eq "mode") {
    if (defined $VarProperties{$var}{"req_switch"}) {

    printf("%-13s | %s", -$var, $VarHash{$var});
    if ($var eq "analysis" || $var eq "mode")
     {
      print "  $VarProperties{$var}{expl}\n\t\t";
      print OUT "$var : $VarHash{$var}\n";

     }
    if (defined $VarProperties{$var}{"optional"}) {
      print " (optional)";
    } else {
      print " (REQUIRED) $VarProperties{$var}{expl}";
      $all_parms_defined_flag = 0;
    }

    # If default exists for this option - print it, otherwise print example
    if (defined $VarProperties{$var}{"default"}) {
      $var_default = $VarProperties{$var}{"default"};
      print "  Default: $var_default\n";
    } else {
      $var_example = $VarProperties{$var}{"example"};
      print "  Example: $var_example\n";
    }
    next;
  }
}


  # Remove multiple appearances of identically named files
  # Special treatment for "pad_files" flag
  if (($var =~ m/_file/) and (defined $VarProperties{$var}{"req_switch"}) and not
      (($var eq "pad_files") and ($VarHash{$var} eq "def_pins"))) {
    @Files = split(" ", $VarHash{$var});
    $VarHash{$var} = "";
    %FileNamesHash = ();

    foreach $file (@Files) { 
      # Check, that it's indeed file and not some parameter...
      if (not (-r $file)) {
	#edaMsg("File $file is not readable!","W");
	next;
      } 
	
      $base_name = basename($file);
      if (defined $FileNamesHash{$base_name}) {
	edaMsg("File $file is found more than once in search path!","I");
	next;
      }

      # First appearance of current basename - save it
      $FileNamesHash{$base_name} = 1;
      $VarHash{$var} .= "$file ";
    }
    if ($VarHash{$var} eq "" ) {
      print "\n\n";
      edaError("No readable files match pattern for $var: @Files\n    Aborting...");
    } 
  }

  # Print to rh_setup.init
  print OUT "$var : $VarHash{$var}\n";


  # If value is too long (too many files) , print only a portion
  if (length($VarHash{$var}) > 80 && (defined $VarProperties{$var}{"req_switch"})) {
    @files = split(" ", $VarHash{$var});
    $num_of_files = $#files+1;
    printf("%-13s | %s... (%s files)", -$var, substr($VarHash{$var},0,80), $num_of_files);
    print "\n"; 
  } elsif (defined $VarProperties{$var}{"req_switch"}) {
    printf("%-13s | %s", -$var, $VarHash{$var});
    print "\n"; 
  }
 
}
close OUT;
print "----------------------------------------------------------------\n";


if ($all_parms_defined_flag == 0) {
  edaError("Some of the required parameters were not defined!");
}
#============================================================================
# Some checks for the availability and correctness of the command line inputs
#============================================================================

#===========================================================================
# Setting the must required variables for the Redhawk analysis
#===========================================================================


if ($VarHash{mode} eq "early_analysis")
 {
  if ($VarHash{analysis} ne "static")
   {
     $VarHash{dyn_time_step} = "50ps";
     #$VarHash{ad_mode} = "1";
     if ($VarHash{bpa} ne "on")
      {
       $VarHash{bpa} = "on";
       edaMsg("Block power assignment is a must for an early analysis run!! \n");
       edaMsg("Please edit the BLOCK POWER ASSIGNMENT SECTION in the GSR according to your requirements!!!\n");
      }
    }
  }
elsif ($VarHash{mode} ne "early_analysis") {
	if ($VarHash{bpa} eq "on")
 	{
   	edaMsg("Block Power Assignment is not supported for modes other than early analysis\n");
  	 exit (0);
	}
}

if ($VarHash{mode} eq "sign_off_analysis")
 {
  $VarHash{dyn_time_step} = "20ps";
  if ($VarHash{sta_files} eq "???" || $VarHash{spf_files} eq "???")
   {
     edaMsg("A sign-off run  should have the timing and the parasitics information file\n");
   }
 }

if ($VarHash{analysis} eq "low_power")
 {
   if ($VarHash{gsc_file} eq "???")
    {
      $VarHash{gsc_file} = " ";
      edaMsg("GSC file is a must for a Low Power analysis run!! \n");
      edaMsg("Please edit the GSC FILE SECTION in the GSR according to your requirements!!!\n");
    }
   if ($VarHash{switch_model_file} eq "???")
    {
      $VarHash{switch_model_file}  = " ";
      edaMsg("Switch Model file is a must for a Low Power analysis run!! \n");
      edaMsg("Please edit the SWITCH_MODEL_FILE section in the GSR according to your requirements!!!\n");
    }
 }

if ($VarHash{mode} eq "performance") {


 if ($VarHash{use_drawn_width_for_em} eq "???") {
   $VarHash{use_drawn_width_for_em} = 1;
  }
if ($VarHash{use_drawn_width_for_em_lookup} eq "???") {
   $VarHash{use_drawn_width_for_em_lookup} = 1;
  }

 if ($VarHash{enable_auto_em} eq "???") 
{
  $VarHash{enable_auto_em} = 0;
 }
 if ($VarHash{dynamic_frame_size} eq "???") {
  $VarHash{dynamic_frame_size} = -1;
 }
 if ($VarHash{consistent_scenario} eq "???") {
  $VarHash{consistent_scenario} = 1;
 }
 if ($VarHash{ignore_short} eq "???") {
  $VarHash{ignore_short} = 1;
 }
 if ($VarHash{ignore_lef_def_mismatch} eq "???") {
  $VarHash{ignore_lef_def_mismatch} = 1;
 }
 if ($VarHash{ignore_def_error} eq "???") {
  $VarHash{ignore_def_error} = 1;
 }
 if ($VarHash{ignore_pgarc_error} eq "???") {
  $VarHash{ignore_pgarc_error} = 1;
 }
 if ($VarHash{ignore_ipf_error} eq "???") {
  $VarHash{ignore_ipf_error} = 1;
 }
 if ($VarHash{ignore_apl_check} eq "???") {
  $VarHash{ignore_apl_check} = 1;
 }
 if ($VarHash{ignore_apl_process_corner} eq "???") {
  $VarHash{ignore_apl_process_corner} = 1;
 }
 if ($VarHash{distributed_extract} eq "???") {
  $VarHash{distributed_extract} = 1;
 }
 if ($VarHash{use_fast_decap_alg} eq "???") {
  $VarHash{use_fast_decap_alg} = 1;
 }
 if ($VarHash{dyn_presim_time} eq "???") {
  $VarHash{dyn_presim_time} = 0;
 }
 if ($VarHash{toggle_rate} eq "???") {
 $VarHash{toggle_rate} = 0.3;
 }
 if ($VarHash{input_slew} eq "???") {
  $VarHash{input_slew} = "50ps";
 }
 if ($VarHash{dyn_time_step} eq "???") {
 $VarHash{dyn_time_step} = "30ps";
 }
 if ($VarHash{ignore_cells_file} eq "???") {
 $VarHash{ignore_cells_file} = "{ \n }";
 }

 if ($VarHash{lef_ignore_pin_layers} eq "???") {
 $VarHash{lef_ignore_pin_layers} = "{ \n }";
 }

 if ($VarHash{decap_cells} eq "???") {
 $VarHash{decap_cells} = "{ \n }";
 }



 }
# Check, that all files specified by user exist
edaCheckInputFiles($VarHash{tech_file});
edaCheckInputFiles($VarHash{lef_files});
edaCheckInputFiles($VarHash{def_files});
edaCheckInputFiles($VarHash{lib_files});
edaCheckInputFiles($VarHash{spf_files}) if ($VarHash{spf_files} ne "???");
edaCheckInputFiles($VarHash{sta_files}) if ($VarHash{sta_files} ne "???");
edaCheckInputFiles($VarHash{vcd_file}) if ($VarHash{vcd_file} ne "???");
edaCheckInputFiles($VarHash{gsc_file}) if ($VarHash{gsc_file} ne "???");
edaCheckInputFiles($VarHash{pgarc_file}) if ($VarHash{pgarc_file} ne "???");
edaCheckInputFiles($VarHash{switch_model_file}) if ($VarHash{switch_model_file} ne "???");
edaCheckInputFiles($VarHash{apl_files}) if ($VarHash{apl_files} ne "???");
edaCheckInputFiles($VarHash{aplcap_files}) if ($VarHash{aplcap_files} ne "???");
edaCheckInputFiles($VarHash{aplpwcap_files}) if ($VarHash{aplpwcap_files} ne "???");
edaCheckInputFiles($VarHash{ate_constraint_files}) if ($VarHash{ate_constraint_files} ne "???");
edaCheckInputFiles($VarHash{ate_options_file}) if ($VarHash{ate_options_file} ne "???");
edaCheckInputFiles($VarHash{cmm_cells}) if ($VarHash{cmm_cells} ne "???");
edaCheckInputFiles($VarHash{pad_files}) if ($VarHash{pad_files} ne "def_pins");


# If there were no arguments passed by the user - don't generate gsr
# and other files. Just print the table and exit
if (($num_of_args == 0) && (-r "$VarHash{top_cell}.gsr")) {
  edaMsg("Skipping regeneration of RedHawk control files. Remove $VarHash{top_cell}.gsr if you want to regenerate them... Quitting");
  exit 0;
}

#====================================================================================
# Copy old <design>.{gsr,defs,lefs,libs} do <design>.{gsr,defs,lefs,libs}.<file_time>
#====================================================================================
foreach $file ("$VarHash{top_cell}.gsr","$VarHash{top_cell}.lefs","$VarHash{top_cell}.libs","$VarHash{top_cell}.defs") {
  if (-r $file) {
    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime((stat("$file"))[10]);
    $year += 1900;
    if ($min < 10) {
      $min = "0".$min;
    }
    $date = "$year-$mon-$mday-$hour:$min";
    edaMsg("Renaming existing $file to $file.$date");
    edaMoveFile($file,"$file.$date");
  }
}

#============================================================
# Populate User GSR hash
#============================================================

# vdd nets
$UserGSR{VDD_NETS}{text} = "{\n";

@VddNets = edaConvert2List($VarHash{vdd_nets});
while (@VddNets) {
  $vdd_net = shift(@VddNets);
  $vdd_value = shift(@VddNets);
  if ($vdd_value eq "") {
    edaError("Nominal voltage is not defined for vdd net '$vdd_net'!");
  }
  $UserGSR{VDD_NETS}{text} .= " $vdd_net $vdd_value\n";
}
$UserGSR{VDD_NETS}{text} .= "}"; 

# gnd nets
if ($VarHash{vss_nets} ne "???") {
$UserGSR{GND_NETS}{text} = "{\n";
foreach $vss_net (edaConvert2List($VarHash{vss_nets})) {
  if (($vss_net =~ m/^\d*$/) or ($vss_net =~ m/^\d*\.\d*$/)) {
    print("-E- Incorrect format for ground nets: '$VarHash{vss_nets}'\n    Don't specify voltages, but only net names!\n");
    exit(-1);
  }
  $UserGSR{GND_NETS}{text} .=" $vss_net 0\n";
}
$UserGSR{GND_NETS}{text} .= "}";
}

# Dynamic EM 
if ($VarHash{dyn_em} ne "???") {
if ($VarHash{analysis} ne "static") {

  $UserGSR{DYNAMIC_EM}{text} = $VarHash{dyn_em};

}
}

# Tech file
$UserGSR{TECH_FILE}{text} = edaConvertToAbsolutePath($VarHash{tech_file});

# Slew
#$UserGSR{INPUT_TRANSITION}{text} = $VarHash{input_slew};

#--------------------------------------------------
# DEF files
$top_def = "";
$def_list = "";


foreach $def_file (split(" ",$VarHash{def_files})) {
  # Don't try to look in the file if by mistake it's a directory
  if (not -f $def_file) {
    next;
  }
  $def_file = edaConvertToAbsolutePath($def_file);
  $design_name = edaGetDefDesignName($def_file);
  if ($design_name eq $VarHash{top_cell}) {
    if ($top_def ne "") {
      edaError(" Multiple def files with top-level block found: $top_def, $def_file !");
    }
    $top_def = $def_file;
  } else {
    $def_list .= "$def_file block\n";
  }
}


# If top def is not found after parsing all def files - it's an error
if ($top_def eq "") {
  edaError("Can't find def file for the top cell '$VarHash{top_cell}'!");
}

# Top block must be last in the list
$def_list .= "$top_def top\n";

if ($VarHash{all_in_gsr} eq "on") {
  $UserGSR{DEF_FILES}{text} = "{\n$def_list}";
} else {
  edaMsg("Creating $VarHash{top_cell}.defs");
  $UserGSR{DEF_FILES}{text} = "{\n$VarHash{top_cell}.defs\n}";
  edaOpenFile(OUT, "$VarHash{top_cell}.defs", "wf");
  print OUT "$def_list";
  close OUT;
}

#--------------------------------------------------
# LEF files
$NonTechnologyLefs = "";
$technology_lefs_count = 0;
$lef_list = "";

foreach $lef_file (split(" ",$VarHash{lef_files})) {
  $lef_file = edaConvertToAbsolutePath($lef_file);
  $is_technology_lef = 0;

  # If keyword TYPE appears in the lef file - it's a technology lef
  edaOpenFile(LEF, $lef_file, "r");
  while (<LEF>) {
    $line = edaCleanLine($_);
    if ($line =~ m/TYPE\s/) {
      $is_technology_lef = 1;
      $technology_lefs_count++;
      last;
    }
  }
  close LEF;

  if ($is_technology_lef eq 1) {
    $lef_list .= "# Technology lef:\n$lef_file\n";
  } else {
    $NonTechnologyLefs .= "$lef_file\n";
  }
}

$lef_list .= "\n# Other lefs:\n$NonTechnologyLefs";
if ($VarHash{all_in_gsr} eq "on") {
  $UserGSR{LEF_FILES}{text} = "{\n$lef_list}";
} else {
  edaMsg("Creating $VarHash{top_cell}.lefs");
  $UserGSR{LEF_FILES}{text} = "{\n $VarHash{top_cell}.lefs\n}";
  edaOpenFile(OUT, "$VarHash{top_cell}.lefs", "wf");
  print OUT "$lef_list\n";
  close OUT;
}

if ($technology_lefs_count < 1) {
  edaMsg("None of the lef files has a technology section! Please check",W);
} elsif ($technology_lefs_count > 1) {
  edaMsg("Multiple lef files with technology section found! See LEF_FILES section of $gsr_file","W")
}

#--------------------------------------------------------
# LIB files
$lib_list = "";
foreach $lib_file (split(" ",$VarHash{lib_files})) {
  $lib_file = edaConvertToAbsolutePath($lib_file);
  $lib_list .= "$lib_file\n";
}
if ($VarHash{pgarc_file} ne "???")
{
  $lib_list.= "# Specify the custom.pgarc file to support cells with multi vdd and multi vss pins\n";
  foreach $pgarc_file (edaConvert2List($VarHash{pgarc_file})) {
  $pgarc_file = edaConvertToAbsolutePath($pgarc_file);
  $lib_list.= "$pgarc_file custom\n";
  }
} 
if ($VarHash{all_in_gsr} eq "on") {
  $UserGSR{LIB_FILES}{text} = "{\n$lib_list}";
} else {
  edaMsg("Creating $VarHash{top_cell}.libs");
  $UserGSR{LIB_FILES}{text} = "{\n$VarHash{top_cell}.libs\n}";
  edaOpenFile(OUT, "$VarHash{top_cell}.libs", "wf");
  print OUT "LIBS_FILE {\n$lib_list}\n";
  close OUT;
}

#--------------------------------------------------------
# APL files
$UserGSR{APL_FILES}{text} = "{\n";
if ($VarHash{apl_files} ne "???") {
  foreach $apl_file (split(" ",$VarHash{apl_files})) {
    $apl_file = edaConvertToAbsolutePath($apl_file);
    $UserGSR{APL_FILES}{text} .= " $apl_file current\n";
  } 
}
if ($VarHash{aplcap_files} ne "???") {
  foreach $aplcap_file (split(" ",$VarHash{aplcap_files})) {
    $aplcap_file = edaConvertToAbsolutePath($aplcap_file);
    $UserGSR{APL_FILES}{text} .= " $aplcap_file cdev\n";
  }
}
if ($VarHash{aplpwcap_files} ne "???") {
  foreach $aplpwcap_file (split(" ",$VarHash{aplpwcap_files})) {
    $aplpwcap_file = edaConvertToAbsolutePath($aplpwcap_file);
    $UserGSR{APL_FILES}{text} .= " $aplpwcap_file pwcap\n";
  }
}
$UserGSR{APL_FILES}{text} .= "\n}";
#--------------------------------------------------------
# GDS files
if ($VarHash{gds_dirs} ne "???") {
  $gds_list = "";
  foreach $gds_dir (edaConvert2List($VarHash{gds_dirs})) {
    if (not -d $gds_dir) {
      edaMsg("Directory $gds_dir doesn't exist or not accessible","W");
      next;
    }

    $gds_dir = edaConvertToAbsolutePath($gds_dir);
    foreach $def_file (glob("$gds_dir/*.def*")) {
      $gds_block_name = edaGetDefDesignName($def_file);
      $lef_file = $gds_dir."/".$gds_block_name."_adsgds.lef";

      # Check if _adsgds.lef exists
      if (not -r $lef_file) {
	edaMsg("Can't find _adsgds.lef for $gds_block_name - it will not be included in the GDS cells list");
      }
      $gds_list .= "$gds_block_name $gds_dir\n";
    }
  }
  
  $UserGSR{GDS_CELLS}{text} = "{\n$gds_list}";
}

#------------------------------------------------------
# PAD files
if ($VarHash{pad_files} eq "def_pins") {

  $UserGSR{ADD_PLOC_FROM_TOP_DEF}{text} = "1";
  $UserGSR{PAD_FILES}{text} = "";

} else {
  $UserGSR{PAD_FILES}{text} = "{\n";
  foreach $pad_file (split(" ",$VarHash{pad_files})) {
    $pad_file = edaConvertToAbsolutePath($pad_file);
    $UserGSR{PAD_FILES}{text} .= " $pad_file\n";
  }

  $UserGSR{PAD_FILES}{text} .= "}";
}

#------------------------------------------------------
# STA file
if ($VarHash{sta_files} ne "???") {
  $UserGSR{STA_FILE}{text} = "{\n";
  foreach $sta_file (edaConvert2List($VarHash{sta_files})) {
    $sta_file = edaConvertToAbsolutePath($sta_file);
    $design_name = edaGetStaDesignName($sta_file);
    if ($design_name eq "???") {
     edaMsg("Can't extract design name from '$sta_file'! You'll need to modify STA_FILE section of GSR FILE generated manually","W");
     $UserGSR{STA_FILE}{text} .= "<design_name> $sta_file\n";
    }
    else {
      $UserGSR{STA_FILE}{text} .= "$design_name $sta_file\n";
    }
  }
  $UserGSR{STA_FILE}{text} .= "}";
} else {
  $UserGSR{STA_FILE}{text} = "";
}

#--------------------------------------------------------------
#  VCD file
if ($VarHash{vcd_file} ne "???") {
  $UserGSR{VCD_FILE}{text} = "{\n";
  foreach $vcd_file (edaConvert2List($VarHash{vcd_file})) {
    $vcd_file = edaConvertToAbsolutePath($vcd_file);
  $UserGSR{VCD_FILE}{text} .= "$design_name $vcd_file\n";
  }
  $UserGSR{VCD_FILE}{text} .= "FILE_TYPE\n"; 
  $UserGSR{VCD_FILE}{text} .= "FRONT_PATH\n"; 
  $UserGSR{VCD_FILE}{text} .= "SUBSTITUTE_PATH\n"; 
  $UserGSR{VCD_FILE}{text} .= "FRAME_SIZE\n"; 
  $UserGSR{VCD_FILE}{text} .= "}";
   
} else {
  $UserGSR{VCD_FILE}{text} = "";
}

#--------------------------------------------------------------
# gsc file
if ($VarHash{gsc_file} ne "???") {
  $UserGSR{GSC_FILE}{text} = "{\n";
  foreach $gsc_file (edaConvert2List($VarHash{gsc_file})) {
    $gsc_file = edaConvertToAbsolutePath($gsc_file);
  $UserGSR{GSC_FILE}{text} .= " #Edit the file to our requirements \n";
  $UserGSR{GSC_FILE}{text} .= " $gsc_file\n";
  }

  $UserGSR{GSC_FILE}{text} .= "}";
} else {
  $UserGSR{GSC_FILE}{text} = "";
}


#--------------------------------------------------------------
# Switch model file
if ($VarHash{switch_model_file} ne "???") {
  $UserGSR{SWITCH_MODEL_FILE}{text} = "{\n";
  foreach $switch_model_file (edaConvert2List($VarHash{switch_model_file})) {
    $switch_model_file = edaConvertToAbsolutePath($switch_model_file);
  $UserGSR{SWITCH_MODEL_FILE}{text} .= " $switch_model_file\n";
  }

  $UserGSR{SWITCH_MODEL_FILE}{text} .= "}";
} else {
  $UserGSR{SWITCH_MODEL_FILE}{text} = "";
}

#--------------------------------------------------------------
# CMM cells
if ($VarHash{cmm_cells} ne "???") {
  my $string = "";
  $UserGSR{CMM_CELLS}{text} = "{\n";
  foreach $cmm_file (edaConvert2List($VarHash{cmm_cells})) {
    $cmm_file = edaConvertToAbsolutePath($cmm_file);
    open (FH , $cmm_file);
    while (<FH>) {
	$string .= $_;
	}
     close (FH);
        
  }
  $UserGSR{CMM_CELLS}{text} .= "$string\n";
  $UserGSR{CMM_CELLS}{text} .= "}";
} else {
  $UserGSR{CMM_CELLS}{text} = "";
}


#--------------------------------------------------------------
# ATE constraint files
if ($VarHash{ate_constraint_files} ne "???") {
  $UserGSR{ENABLE_ATE}{text} = 1;
  $UserGSR{ATE_CONSTRAINT_FILES}{text} = "{\n";
  foreach $ate_file (edaConvert2List($VarHash{ate_constraint_files})) {
    $ate_file = edaConvertToAbsolutePath($ate_file);
  $UserGSR{ATE_CONSTRAINT_FILES}{text} .= "$ate_file\n";
  }
  if ($VarHash{ate_options_file} ne "???") {
  $options_file =  $VarHash{ate_options_file} ;
  $options_file = edaConvertToAbsolutePath($options_file);
  $UserGSR{ATE_CONSTRAINT_FILES}{text} .= "USER_OPTIONS_FILE $options_file\n" ;
  }
  $UserGSR{ATE_CONSTRAINT_FILES}{text} .= "}";
} else {
  $UserGSR{ATE_CONSTRAINT_FILES}{text} = "";
}

#--------------------------------------------------------------
# SPF (parasitics) files
if (($VarHash{spf_files} ne "???") && ($VarHash{spf_files} ne "")) {
  $UserGSR{CELL_RC_FILE}{text} = "{\n";
  foreach $spf_file (edaConvert2List($VarHash{spf_files})) {
    $spf_file = edaConvertToAbsolutePath($spf_file);
    $design_name = edaGetSpfDesignName($spf_file);
    if ($design_name eq "???") {
      edaMsg("Can't extract design name from '$spf_file'! You'll need to modify CELL_RC_FILE section of $gsr_file manually","W");
    }
    $UserGSR{CELL_RC_FILE}{text} .= " $design_name $spf_file\n";
  }
  $UserGSR{CELL_RC_FILE}{text} .= "}\n";
} else {
  $UserGSR{CELL_RC_FILE}{text} = "";
}


#---------------------------------------------------------------
# BLOCK_POWER_FOR_SCALING
if ($VarHash{avg_pwr} ne "???") {
  $UserGSR{BLOCK_POWER_FOR_SCALING}{text} = "{
FULLCHIP $VarHash{top_cell} $VarHash{avg_pwr}
# CELLTYPE block_master_name power_in_watts
}
  ";
}

# BLOCK_POWER_ASSIGNMENT
if ($VarHash{bpa} ne "???") {
  $UserGSR{BLOCK_POWER_ASSIGNMENT}{text} = "{
}
  ";
}

# Toggle rate
if ($VarHash{toggle_rate} ne "???") {
  $UserGSR{TOGGLE_RATE}{text} = $VarHash{toggle_rate};
}

# Frequency
if ($VarHash{frequency} ne "???") {
  $UserGSR{FREQ}{text} = $VarHash{frequency};
}

# Dynamic_Simulation_Time
if ($VarHash{dyn_sim_time} ne "???") {
if ($VarHash{analysis} ne "static") {
  $UserGSR{DYNAMIC_SIMULATION_TIME}{text} = $VarHash{dyn_sim_time};
}
}

# Dynamic_PreSimulation_Time
if ($VarHash{dyn_presim_time} ne "???") {
  if ($VarHash{analysis} ne "static") {
  $UserGSR{DYNAMIC_PRESIM_TIME}{text} = $VarHash{dyn_presim_time};
 }
}

# Dynamic_report_dvd
if ($VarHash{dynamic_report_dvd} ne "???") {
  if ($VarHash{analysis} ne "static") {
  $UserGSR{DYNAMIC_REPORT_DVD}{text} = $VarHash{dynamic_report_dvd};
 }
}

# Dynamic_Time_step
if ($VarHash{dyn_time_step} ne "???") {
  if ($VarHash{analysis} ne "static") {
  $UserGSR{DYNAMIC_TIME_STEP}{text} = $VarHash{dyn_time_step};
  }
}

#Accelerated Dynamic mode 
#if ($VarHash{ad_mode} ne "???") {
#  $UserGSR{AD_MODE}{text} = $VarHash{ad_mode};
#}
#else
# {
#  $UserGSR{AD_MODE}{text} = "0";
# }

#Enable auto EM 
if ($VarHash{enable_auto_em} ne "???") {
  $UserGSR{ENABLE_AUTO_EM}{text} = "$VarHash{enable_auto_em}";
}

#Consistent Scenario 
if ($VarHash{consistent_scenario} ne "???") {
  $UserGSR{CONSISTENT_SCENARIO}{text} = "$VarHash{consistent_scenario}";
}

#Dynamic_Report_dvd
if ($VarHash{dynamic_report_dvd} ne "???") {
  $UserGSR{DYNAMIC_REPORT_DVD}{text} = "$VarHash{dynamic_report_dvd}";
}


#performance mode

if ($VarHash{mode} eq "performance") {
 if ($VarHash{use_drawn_width_for_em} ne "???") {
   $UserGSR{USE_DRAWN_WIDTH_FOR_EM}{text} = $VarHash{use_drawn_width_for_em};
 
  }
if ($VarHash{use_drawn_width_for_em_lookup} ne "???") {
   $UserGSR{USE_DRAWN_WIDTH_FOR_EM_LOOKUP}{text} = $VarHash{use_drawn_width_for_em_lookup};
  }

 if ($VarHash{enable_auto_em} ne "???") {
  $UserGSR{ENABLE_AUTO_EM}{text} = $VarHash{enable_auto_em};
 }
 if ($VarHash{dynamic_frame_size} ne "???") {
  $UserGSR{DYNAMIC_FRAME_SIZE}{text} = $VarHash{dynamic_frame_size};
 }
 if ($VarHash{consistent_scenario} ne "???") {
  $UserGSR{CONSISTENT_SCENARIO}{text} = $VarHash{consistent_scenario};
 }
 if ($VarHash{ignore_short} ne "???") {
  $UserGSR{IGNORE_SHORT}{text} = $VarHash{ignore_short};
 }
 if ($VarHash{ignore_lef_def_mismatch} ne "???") {
 $UserGSR{IGNORE_LEF_DEF_MISMATCH}{text} = $VarHash{ignore_lef_def_mismatch}; 
 }
 if ($VarHash{ignore_def_error} ne "???") {
 $UserGSR{IGNORE_DEF_ERROR}{text} = $VarHash{ignore_def_error};
 }
 if ($VarHash{ignore_pgarc_error} ne "???") {
 $UserGSR{IGNORE_PGARC_ERROR}{text} = $VarHash{ignore_pgarc_error}; 
 }
 if ($VarHash{ignore_ipf_error} ne "???") {
  $UserGSR{IGNORE_IPF_ERROR}{text} = $VarHash{ignore_ipf_error};
 }
 if ($VarHash{ignore_apl_check} ne "???") {
   $UserGSR{IGNORE_APL_CHECK}{text} = $VarHash{ignore_apl_check};
 }
 if ($VarHash{ignore_apl_process_corner} ne "???") {
   $UserGSR{IGNORE_APL_PROCESS_CORNER}{text} = $VarHash{ignore_apl_process_corner};
 }
 if ($VarHash{distributed_extract} ne "???") {
  $UserGSR{DISTRIBUTED_EXTRACT}{text} = $VarHash{distributed_extract};
 }
 if ($VarHash{use_fast_decap_alg} ne "???") {
  $UserGSR{USE_FAST_DECAP_ALG}{text} = $VarHash{use_fast_decap_alg};
 }
 if ($VarHash{dyn_presim_time} ne "???") {
   $UserGSR{DYNAMIC_PRESIM_TIME}{text} = $VarHash{dyn_presim_time};
 }
 if ($VarHash{toggle_rate} ne "???") {
  $UserGSR{TOGGLE_RATE}{text} = $VarHash{toggle_rate};
 }
 if ($VarHash{input_slew} ne "???") {
  $UserGSR{INPUT_TRANSITION}{text} = $VarHash{input_slew};
 }
 if ($VarHash{dyn_time_step} ne "???") {
  $UserGSR{DYNAMIC_TIME_STEP}{text} = $VarHash{dyn_time_step};
 }

$UserGSR{APL_FILES} = "{}";
#$UserGSR{REDHAWK_PACKAGE_SUBCKT} = "{}";
$UserGSR{GDS_CELLS}{text} = "{}";

$UserGSR{SPLIT_SPARSE_VIA_ARRAY}{text} = "";
#$UserGSR{PUSH_PININST}{text}= "0";
$UserGSR{DYNAMIC_REPORT_DECAP}{text} = "0";
$UserGSR{DYNAMIC_SAVE_WAVEFORM}{text} = "0";
#$UserGSR{VIA_COMPRESS}{text} = "0";


$UserGSR{CACHE_MODE}{text} = "1" ;
$UserGSR{CACHE_DIR}{text} = "/tmp";

edaMsg (" IGNORE_CELLS_FILE is required for performance mode . Edit it manually in GSR ");
$UserGSR{IGNORE_CELLS_FILE}{text} = $VarHash{ignore_cells_file};
edaMsg ("DECAP_CELLS  is required for performance mode . Edit it manually in GSR ");
$UserGSR{DECAP_CELLS}{text} = $VarHash{decap_cells};
edaMsg ("LEF_IGNORE_PIN_LAYERS is required for performance mode . Edit it manually in GSR ");
$UserGSR{LEF_IGNORE_PIN_LAYERS}{text} = $VarHash{lef_ignore_pin_layers};
 }



# Finished forming user GSR
# Merge user GSR

mergeGSR(\%UserGSR,\%DefaultGSR,\%CombinedGSR);

#==========================================================================
# Generate GSR file
#==========================================================================
my $date = edaGetDate();

$gsr_file = "$VarHash{top_cell}.gsr";
edaMsg("Creating $gsr_file");
edaOpenFile("FILE","$gsr_file","wf");
print FILE "# Created by rh_setup.pl on $date\n\n";

# If keyword is bare (i.e has no value) - comment it
foreach $keyword (@GSR_keywords) {
  print FILE "$CombinedGSR{$keyword}{help}\n";
  if (($CombinedGSR{$keyword}{text} eq "") || ($CombinedGSR{$keyword}{text} eq "{}") || ($CombinedGSR{$keyword}{text} eq "{\n}")) {
    print FILE "# $keyword\n\n";
 
  } else {
    print FILE "$keyword $CombinedGSR{$keyword}{text}\n\n";
    edaMsg
  }
}

#====================================================
# Create sceleton scripts:
#  run_static.tcl
#  run_sigEM.tcl
#  run_dynamic.tcl
# run_lowpower.tcl
#====================================================
$cwd = `pwd`;
chomp($cwd);

if ($VarHash{analysis} eq "signalEM")
 {
  edaMsg("Creating run_signalEM.tcl");
  edaMsg("Please edit the variables under EM SECTION in the GSR to your requiremnets\n");
  edaOpenFile("FILE","run_signalEM.tcl","wf");
  
  print FILE "
# Created by rh_setup.pl on $date

# Import data
setup analysis_mode signalEM
import gsr $VarHash{top_cell}.gsr 
setup design

# Calculate power
perform pwrcalc

#Signal EM analysis
perform extraction -signal
perform analysis -signalEM 
perform emcheck
";

close FILE;
}

if ($VarHash{analysis} eq "static" || $VarHash{analysis} eq "static and dynamic")
{  
edaMsg("Creating run_static.tcl");
edaOpenFile("FILE","run_static.tcl","wf");

print FILE "
# Created by rh_setup.pl on $date

# Import data
import gsr $VarHash{top_cell}.gsr
setup design
setup analysis_mode static

# If you need to run design-dependent APL - uncomment the next line
# setup apl -dir APL

# Calculate power
perform pwrcalc

# Power grid extraction
perform extraction -power -ground

# Lumped resistance (in Ohms) for package, wirebond and pads
# Default values are all 0, i.e no off-chip impact
setup package -power -r 0
setup package -ground -r 0
setup wirebond -power -r 0
setup wirebond -ground -r 0
setup pad -power -r 0
setup pad -ground -r 0

# Static IR analysis
perform analysis -static

#Performing EM analysis. Additional settings to choose between different modes and to perform analysis for a particular net are as follows. User may use them according to requirement : -mode [AVG | RMS | PEAK | all] -net <net_name>
perform emcheck 

# Run Explorer
explore design

# Export the Static db
export db $VarHash{top_cell}_static.db

";

close FILE;
}

# run_dynamic.tcl

if ($VarHash{analysis} eq "dynamic"  || $VarHash{analysis} eq "static and dynamic")
{
 if ($VarHash{vss_nets} eq "???")
  {
    edaMsg("Please specify the VSS nets for the dynamic run!!\n");  
    exit (0);
  }
 if ($VarHash{lib_files} eq "???" && $VarHash{analysis} eq "dynamic")
  {
    edaMsg("Specify the .lib files for the dynamic run analysis!!\n");
    exit (0);
  }
 if ($VarHash{mode} ne "early_analysis"  && $VarHash{analysis} eq "dynamic")
  {
    if ($VarHash{sta_files} eq "???") {
     edaMsg("Dynamic analysis is meaningless without STA(timing) file. Skipping generation of run_dynamic.tcl","W"); 
     } elsif (($VarHash{apl_files} eq "???") || ($VarHash{aplcap_files} eq "???")) {
      edaMsg("Dynamic analysis is overly pessimistic without reading APL data. Skipping generation of run_dynamic.tcl. Please specify the same to run dynamic analysis","W");
      exit (0);
    }
  } 

  edaMsg("Creating run_dynamic.tcl");
  edaOpenFile("FILE","run_dynamic.tcl","wf");
  print FILE "
# Created by rh_setup.pl on $date

# Import data
import gsr $VarHash{top_cell}.gsr
setup design
setup analysis_mode dynamic

# Calculate power
perform pwrcalc

# Power grid extraction
perform extraction -power -ground -c

# Lumped resistance, capacitance and inductance for package, wirebond and pads
# R in Ohms, C in picoFarads, and L in picoHenrys.
# Default values are all 0, i.e no off-chip impact
setup package -power -r 0 -c 0 -l 0
setup package -ground -r 0 -c 0 -l 0
setup wirebond -power -r 0 -c 0 -l 0
setup wirebond -ground -r 0 -c 0 -l 0
setup pad -power -r 0 -c 0
setup pad -ground -r 0 -c 0
";

if ($VarHash{vcd_file} ne "???") {
edaMsg("VCD mode of analysis switched \"on\", please fill in the unfilled paramters under the \"VCD_FILE\" section of the GSR manually\n");
edaMsg("Also edit the run_dynamic.tcl suitably\n");
print FILE "
# Dynamic simulation
perform cycle_select -type -percent -bp
";
}
else {
print FILE "
#Use this command if you are running a vcd based dynamic run 
#perform dynamic -vcd
perform analysis -vectorless
";
}
print FILE "
#Performing EM analysis. Additional settings to choose between different modes and to perform analysis for a particular net are as follows. User may use them according to requirement : -mode [AVG | RMS | PEAK | all] -net <net_name>
perform emcheck 

# Run Explorer
explore design

# Export the Dyanamic db
export db $VarHash{top_cell}_dynamic.db

";

close FILE;
}

if ($VarHash{analysis} eq "low_power")
{
 if ($VarHash{vss_nets} eq "???")
  {
    edaMsg("Please specify the VSS nets for the lowpower run!!\n");
    exit (0);
  }
 if ($VarHash{lib_files} eq "???")
  {
    edaMsg("Specify the .lib files for the lowpower run analysis!!\n");
    exit (0);
  }

 if ($VarHash{switch_model_file} eq "???" && $VarHash{gsc_file} eq "???")
  {
   edaMsg("Lowpower analysis is meaningless without a switch model file and the gsc file,please specify it!! Skipping generation of run_lowpower.tcl","W");
   exit (0); 
  }

if ($VarHash{mode} ne "early_analysis") {
if ($VarHash{sta_files} eq "???") {
  edaMsg("Lowpower analysis is meaningless without STA(timing) file. Skipping generation of run_lowpower.tcl","W");
  exit (0);
} elsif ((($VarHash{apl_files} ne "???") && ($VarHash{aplcap_files} eq "???" )) || ($VarHash{aplpwcap_files} eq "???" )) {
  edaMsg("Warning: Lowpower analysis is overly pessimistic without reading APL data!!");
} 
}
  edaMsg("Creating run_lowpower.tcl");
  edaOpenFile("FILE","run_lowpower.tcl","wf");
  print FILE "
# Created by rh_setup.pl on $date

# Import data
import gsr $VarHash{top_cell}.gsr
setup design
setup analysis_mode lowpower

# Calculate power
perform pwrcalc

# Power grid extraction
perform extraction -power -ground -c

# Lumped resistance, capacitance and inductance for package, wirebond and pads
# R in Ohms, C in picoFarads, and L in picoHenrys.
# Default values are all 0, i.e no off-chip impact
setup package -power -r 0 -c 0 -l 0
setup package -ground -r 0 -c 0 -l 0
setup wirebond -power -r 0 -c 0 -l 0
setup wirebond -ground -r 0 -c 0 -l 0
setup pad -power -r 0 -c 0
setup pad -ground -r 0 -c 0

# Dynamic simulation
perform analysis -lowpower 

#Performing EM analysis. Additional settings to choose between different modes and to select a particular net have been commented out. User may use them according to requirement.
perform emcheck #-mode [AVG | RMS | PEAK | all] -net <net_name>

# Run Explorer
explore design

# Export the Lowpower db
export db $VarHash{top_cell}_lowpower.db

";

close FILE;
}

# run_cpm.tcl

if ($VarHash{analysis} eq "cpm")
{
 if ($VarHash{vss_nets} eq "???")
  {
    edaMsg("Please specify the VSS nets for the cpm run!!\n");
    exit (0);
  }
 if ($VarHash{lib_files} eq "???" && $VarHash{analysis} eq "cpm")
  {
    edaMsg("Specify the .lib files for the cpm run analysis!!\n");
    exit (0);
  }
 if ($VarHash{mode} ne "early_analysis"  && $VarHash{analysis} eq "dynamic")
  {
    if ($VarHash{sta_files} eq "???") {
     edaMsg("CPM analysis is meaningless without STA(timing) file. Skipping generation of run_cpm.tcl","W");
     } elsif (($VarHash{apl_files} eq "???") || ($VarHash{aplcap_files} eq "???")) {
      edaMsg("Dynamic analysis is overly pessimistic without reading APL data. Skipping generation of run_cpm.tcl. Please specify the same to run cpm 
analysis","W");
      exit (0);
    }
  }

  edaMsg("Creating run_cpm.tcl");
  edaOpenFile("FILE","run_cpm.tcl","wf");
  print FILE "
# Created by rh_setup.pl on $date

# Import data
import gsr $VarHash{top_cell}.gsr
setup design

# Calculate power
perform pwrcalc

# Power grid extraction
perform extraction -power -ground -c

# Lumped resistance, capacitance and inductance for package, wirebond and pads
# R in Ohms, C in picoFarads, and L in picoHenrys.
# Default values are all 0, i.e no off-chip impact
setup package
setup wirebond
setup pad 
perform pwrmodel -wirebond
";

close FILE;
}


BEGIN {

#----------------------------------------------------
#   Help page
#----------------------------------------------------
sub usage {
  print "
SYNOPSIS

  Helps to setup necessary input files for static and dynamic runs of RedHawk

DESCRIPTION

  rh_setup.pl creates all the files needed to launch Redhawk simulation, either
  static or dynamic:

  <design>.gsr      - global settings
  run_static.tcl    - static run script
  run_dynamic.tcl   - dynamic run script
  run_signalEM.tcl  - signal EM run script
  run_lowpower.tcl  - rampup run script
  run_cpm.tcl       - cpm run script

  Every parameter value in generated <design>.gsr can come from 4 sources in the
  following precedence:
   a. From rh_setup.pl command line parameters
   b. From parameters of previous invocation of rh_setup.pl saved in rh_setup.init
      file
   c. From template gsr pointed by variable $APACHEDA_TEMPLATE_GSR, if this
      file exists
   d. From default value preset by Apache

  Input to the script is incremental. You can invoke the script with one or more
  command line arguments. Script will prompt you if any of the required arguments
  are missing (for ex. power net name) Re-invoke the script adding/changing the
  arguments, until all required information is complete.

  Unix wildcards are accepted for options which specify file names. For example
  '-def *def */*def */*/*def' will match all the def files up to 2 levels down
  If the file with the same name is found more than once in the search pattern,
  the first occurance will be picked.

  Then rh_setup.pl checks, that all input files exist and creates all configuration
  files listed above.

  To launch simulation run:
  'redhawk -f run_static.tcl' or 'redhawk -f run_dynamic.tcl'


i) List of inputs taken through the command line argument

top_cell
- Specify top module of design hierarchy for this analysis, a must required input.
Ex: -top_cell GENERIC

mode
- Specify the mode, either \"early_analysis\" or \"sign_off_analysis\"or \"performance\". By default it picks up 
sign_off_analysis
Ex: -mode early_analysis

analysis
- Specify analysis type, static dynamic low_power cpm or signalEM. By default tcl files for static and 
dynamic will be created
Ex: -analysis signalEM

vdd_nets
- Names of power nets used in this analysis along with nominal voltages, a must required input
Ex: -vdd_nets VDD 1.2 VDD_INT 1.5

vss_nets
-  Names of ground nets used in this analysis, an optional input for static or sigEM run but must 
for dynamic or lowpower run
Ex: -vss_nets gnd gnde

frequency
- Primary operating frequency of this design (Hz), must required input
Ex: -frequency 100e6

tech_file
- Apache tech file with dielectrics, metal layers. If not specified it tries to search in the 
default path mentioned in rh_setup.defaults. A must required input
Ex: -tech_file ../design_data/tech/GENERIC.tech

lef_files
-   LEF files for technology,library cells, hierarchical and IP blocks, must required.
Ex: -lef_files ../design_data/lef/*

def_files
-    DEF files for top module, hierarchical and IP blocks, must required.
Ex: -def_files ../design_data/def/*.def.gz

lib_files
-       Synopsys Liberty format (.lib) timing libraries, optional for an early analysis static run 
must for dynamic, lowpower and sign-off runs.
Ex: -lib_files ../design_data ../data/lib/*.lib


pad_files
-    Apache PLOC file that gives X,Y of ideal Voltage sources. For block level analysis you can use 
keyword 'def_pins'. This forces Redhawk to place one pad in the center of every VDD/VSS pin 
described in top-level def file. Either one of tem is a must
Ex: -pad_files ../design_data/ploc/GENERIC.ploc, -pad_files def_pins

spf_files
-         Hierarchical SPEF or DSPF files of post-layout parasitic, must required input for a 
sign_off analysis_run
Ex: -spf_files ../design_data/spef/GENERIC.spef

sta_files
-       Timing files from STA, must required input for a 
sign_off_analysis run.
Ex: -sta_files ../design_data/sta/GENERIC.timing

apl_files
-       Apache cell.current file of current profiles from apl run. It is must required if the mode 
is sign_off and the analysis type is dynamic or lowpower
Ex: -apl_files ../design_data/apl/stdcellcurrent/cell.current

aplcap_files
-       Apache cell.cdev decap file from apl -c run. It is must required if the mode is sign_off 
and the analysis type is dynamic or lowpower
Ex: -aplcap_files ../design_data/apl/stdcellcap/cell.cdev

aplpwcap_files
-         Apache cell.pwcap decap file from apl -w run. It is must required if the mode is sign_off 
and the analysis type is lowpower
Ex: -aplpwcap_files ../design_data/apl/stdcellpwcap/cell.pwcap

gds_dirs
-       Load all lef/def/pratio files created by gds2def/gdsmem in specified directories
Ex: -gds_dirs ../design_data/gds2def/*

ate_constraint_files
-	this keyword requires the input files to be specified so that ATE generates STA file during the setup design phase
Ex:   -ate_constraint_files ../design_data/timing/*.sdc

ate_options_file
-	This keyword specifies additional user options to be used with ATE_CONSTRAINT_FILES
Ex:	-ate_options_file ../design_data/timing/*.tcl

cmm_cells
-	file containing the <model_name> and <cmm_model_file> must be included with this keyword.
Ex:  -cmm_cells ../design_data/cmm/*.txt. File format is :<model_name> <cmm_model_file_path>


ii) List of key words which prints out a default value in the GSR. User can edit these to his 
requirements.

AD_MODE
-  \"1\" for an early_anlysis run and \"0\" for sign_off run

DYNAMIC_SIMULATION_TIME
-  2.56e9

DYNAMIC_TIME_STEP
-  \"50ps\" for an early_analysis run and \"20ps\" for sign_off

INPUT_TRANSITION
-  200ps

TOGGLE_RATE
-  0.3

iii) List of keywords which are taken into account only based on the mode or kept commented in the 
GSR file.These switches act as hidden switches wherein the user can set these variables along with 
other inputs

  -BLOCK_POWER_ASSIGNMENT
It is turned on during prototype analysis and prompts the user to edit to their requirements

-SWITCH_MODEL_FILE
It s added (commented) to the GSR section during a low power analysis run. It prompts the user to 
edit the file before a lowpower analysis run

-GSC_FILE
It is added (commented) to the GSR section during a low power analysis run. It prompts the user to 
edit the file before a lowpower analysis run

-VCD_FILE -BPFS_FILE -PGARC_FILE
Kept commented in the GSR, user can edit to his requirements.

";

    }
  }


