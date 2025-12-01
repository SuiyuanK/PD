# $Revision: 2.1 $
#########################################################################
#
# atcl_pmic.tcl is an Apache-AE TCL utility for PMIC flow
#
# Usage:
# setup_pmic -c <pmic_gsr> \[-h\] \[-m\]
#
# Copyright © 2016 ANSYS, Inc.
# All rights reserved.
#
# Revision history
#
# Rev 1.0
# - Created by Karthik Srinivasan on September,21st 2016 
# - Initial version
#
#########################################################################

proc perform_thermal_man {} {
	puts "
	SYNOPSIS
	Apache-AE TCL utility for Thermal analysis using ANSYS/M-FEM solution
	USAGE
	perform_thermal_analysis \[option_arguments\]
	Options:
	-hsf <sub-model_generation_config_file>
	-trench <thickness,depth,downset,conductivity>
	-version <ansys_m version,default:ansys190, PLEASE MAKE SURE THAT YOUR ENVIRONMENT HAS ansys190 setup>
	-core <number_of_cores_for_FEA_analysis>
	\[-h\] command usage
	\[-m\] man page
	"
}

proc perform_thermal_help {} {
	puts "Usage: perform_thermal_analysis -hsf <submodel_config> -trench <thickness,depth,downset,conductivity>"
}


proc perform_thermal_analysis { args } {
set argv [ split $args ]
		if {[llength $argv] == 0 } { set notrench 1 }
		set state flag
		foreach arg $argv {
			switch -- $state {
			flag {
				switch -glob -- $arg {
				--he* { perform_thermal_help ; return }
				-hsf { set state hsf;}
				-v* { set state version;}
				-c* { set state core;}
				-trench { set state trench;}
				-dbg { set state debug;}
				-ma* { perform_thermal_man ; return }
				default { error "actl Error: unknow flag $arg" }
				}
			}
			trench {
			set trench_params [ split $arg , ]
			set thk [ lindex $trench_params 0 ]
			set depth [ lindex $trench_params 1 ]
			set downset [ lindex $trench_params 2 ]
			set cond [ lindex $trench_params 3 ]
			set state flag
			}
			hsf {	
			set hsf_file [file normalize $arg ]
			if {[info exists hsf_file]} {
			puts "INFO: GSR File $hsf_file"
			}
			set state flag
			}
			version {
			set ansysm $arg
			set state flag
			}
			core {
			set threads $arg
			set state flag
			}
			dbg {
			set debug_mode 1
			set state flag
			}
			}
		}
if {[info exists thk ]} { 
set notrench 0 
} else {
set notrench 1
}
if { [info exists debug_mode]} { 
set debug_mode 0 
} else {
set debug_mode 1
}
if {[info exists ansysm ]} {
	puts "-I- ANSYSM version ansyslauncher is defined as $ansysm"
} else {
	puts "-W- ANSYSM version ansyslauncher is defined as ansys190"
}
if {[info exists threads]} { 
	puts "-I- ANSYSM $ansysm will use $threads threads"
} else {
set threads 16
	puts "-I- ANSYSM $ansysm will use $threads threads"
}
set date1 [exec date ]
set timestamp [ join $date1 "_" ]
set mdldir ".submodel_$timestamp"
file mkdir $mdldir
	if { [ catch { dump hot_interconnect -flow 1 -o hot_interconnect_file_PG } ] == 0 } {
	puts "-I- Finished Dumping Hot interconnect file .."
	## A temporary routine added to remove K2 field from hot interconnect file
	#prune_hot_int
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
	if { $debug_mode ==1 } {
	if { [ catch { perform thermalmodel -layer -ctmfilecheck } ] == 0 } {
	puts "-I- Generating CTM"
	} else {
	puts "-E- Cannot generate CTM"
	return
	}
	} else {
	if { [ catch { perform thermalmodel -layer } ] == 0 } {
	puts "-I- Generating CTM"
	} else {
	puts "-E- Cannot generate CTM"
	return
	}
	}
	set topdesign [ get design ]
	puts "$topdesign"
	#set bpffile "adsRpt/GDS/$topdesign\_bpf.rpt"
	set bpffile "adsRpt/GDS/$topdesign\_od_self_heat_xtor.rpt"
	puts "NO TRENCH is $notrench"
	if {[info exists bpffile ]} {
		if {$notrench==0} {
		puts "going to proc atclmakebpf $notrench"
		atclmakebpf $thk $depth $downset $cond $mdldir
		} else {
#		puts "going to proc atclmakebpf $notrench"
#		atclmakebpf
		}
	} else {
	puts "going to proc atclmakebpf_pmic $notrench"
	atclmakebpf_pmic $mdldir
#	puts "BBB"
	}
	atclProcesshsf $hsf_file $mdldir $ansysm
#exec cp bpf.rpt $mdldir/bpf.rpt
exec cp -rf adsThermal.tar.gz $mdldir/adsThermal.tar.gz
exec cp -rf adsThermal $mdldir/adsThermal
cd $mdldir
	if { [ catch { exec fasttherm -subm hsf.cfg } ] == 0 } {
	puts "-I- Fasttherm successful in creating submodel"
	} else {
	puts "-E- Fasttherm failed, please refer $mdldir/hsf.cfg"
	return
	}
	set dsn [ get design ]
#	if { [ catch { exec $ansysm -b -dis  -np $threads -dir "./" -j "$dsn" -i "./run_ansys_apdl.txt" > /dev/null } ] == 0 } {
#	puts "-I- Running Ansys/M for Thermal analysis"
#	} else {
#	puts "-E- Failed Running ANSYS/M for thermal analysis"
#	return
#	}
#	if { [ catch { exec fasttherm -getT getAnsTemp.in } ] == 0 } {
#	puts "-I- Getting the results from ANSYS/M"
#	} else {
#	puts "-E- Failed to get results from ANSYS/M"
#	return
#	}
#	if { [info exists ./hot_interconnect_file_PG.sig.out ] } {
	exec cat hot_interconnect_file_PG.sig.out > hot_interconnect_file_all.out
	exec grep -v "^#" ./hot_interconnect_file_PG.pg.out >> hot_interconnect_file_all.out
#	} elseif { [info exists hot_interconnect_file_PG.out ] } {
#	exec ln -s ./hot_interconnect_file_PG.out ./hot_interconnect_file_all.out
#	}
	exec mv hot_interconnect_file_all.out ../
cd ../
	if { [ catch { import sh_temp hot_interconnect_file_all.out } ] == 0 } {
	puts "-I- Post thermal EM analysis "
	} else {
	puts "-E- Failed Post thermal EM analysis "
	return
	}
	if { [ catch { perform emcheck } ] == 0 } {
	puts "-I- Post thermal EM analysis "
	} else {
	puts "-E- Failed Post thermal EM analysis "
	return
	}
	if { [ catch { show wt } ] == 0 } {
	puts "-I- showing Wire Temperature Map"
	} else {
	puts "-E- Failed Post thermal EM analysis "
	return
	}
}
proc prune_hot_int {} {
set fhi_p [ open "hot_interconnect_file_PG.pg" r ]
set fhi_po [ open "hot_interconnect_file_PG.pg.mod" w ]
set fhi_s [ open "hot_interconnect_file_PG.sig" r ]
set fhi_so [ open "hot_interconnect_file_PG.sig.mod" w ]
set temp_em [ gsr get TEMPERATURE_EM ]
	if { [info exists temp_em] } {
	set temp_em [ gsr get TEMPERATURE_EM ]
	} else {
	puts "-I- Since temperature is not set in the GSR, results will be bogus, quitting"
	return
	}
while { [ gets $fhi_p line ] >=0 } {
        if { $line ne ""} {
#puts $line
		if { [ regexp -nocase {^\s*WS\s+(\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+)\s+(\S+)\s+(\S+\s+\S+\s+\S+)} $line tmp wsline k2 wblech ] } {
		puts $fhi_po "WS $wsline $wblech"
		} else {
		puts $fhi_po "$line"
		}
	}
} 
while { [ gets $fhi_s line ] >=0 } {
        if { $line ne ""} {
#puts $line
		if { [ regexp -nocase {^\s*WS\s+(\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+)\s+(\S+)\s+(\S+\s+\S+\s+\S+)} $line tmp wsline k2 wblech ] } {
		puts $fhi_so "WS $wsline $wblech"
		} else {
		puts $fhi_so "$line"
		}
	}
} 
close $fhi_p
close $fhi_s
close $fhi_po
close $fhi_so
exec mv hot_interconnect_file_PG.pg.mod hot_interconnect_file_PG.pg
exec mv hot_interconnect_file_PG.sig.mod hot_interconnect_file_PG.sig
}
proc atclmakebpf { args } {
set argv [ split $args ]
#puts "AAA"
		if { [llength $argv] == 0 } {
			puts "-W- All necessary arguments for trench are not passed, if TRENCH is present in the bpf, flow will error out" 
			set noargs 1
		} else {
			set noargs 0
			set thickness [ lindex $args 0 ]
			set depth [ lindex $args 1 ]
			set downset [ lindex $args 2 ]
			set conductivity [ lindex $args 0 ]
			set mdl_dir [ lindex $args 3 ]
		}
#puts "AAA"
set topcell [ get design ]
set fbpf [ open "adsRpt/GDS/$topcell\_bpf.rpt" r ]
set fbpfout [ open "$mdl_dir\/$topcell\_bpf.rpt" w ]
#puts "AAA"
while { [ gets $fbpf line ] >=0 } {
#puts "AAA"
        if { $line ne ""} {
		if { [ regexp -nocase {^\s*%TRENCH\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)} $line tmp llx lly urx ury ] } {
			if {$noargs==1} {
			puts "-E- TRENCH is present in the layout, but trench parameters are not provided.. Please provide trench parameters for continuing further"
			return
			} else {
				if {$thickness==0} {
				puts "-E- trench parameters are zero and could lead to incorrect results "
				return
				} elseif {$depth==0} {
				puts "-E- trench parameters are zero and could lead to incorrect results "
				return
				} else {
				puts $fbpfout "%TRENCH $thickness $depth $downset $conductivity $llx $lly $urx $ury"
				}
			}
		} else {
#				puts "AA"
				puts $fbpfout $line
		}
		}
}
close $fbpf
close $fbpfout
}
proc atclProcesshsf { args } {
set argv [ split $args ]
		if {[llength $argv] == 0 } { 
			puts "-I- Creating Sub Model configuration file using default settings"
		} else {
			set userhsf [ lindex $args 0 ]
			set tmpdir [ lindex $args 1 ]
			set ansysm [ lindex $args 2 ]
		}
#set tmpdir ".submodel"
puts "Model directory is $tmpdir"
set fpctm [ open "adsThermal/CTM_header.txt" r ]
set fpctm_mod [ open "adsThermal/CTM_header_mod.txt" w ]
set metals 0
set idx 0
while { [ gets $fpctm line ] >=0 } {
        if { ![ regexp -all "\#" $line ] && $line ne ""} {
		if {$metals==1} {
		if {[ regexp {^\s*(\S+)\s+(\S+)\s+(\S+)} $line tmp lyr thk ht ] } {
		#	puts "$lyr $ht $thk"
			set thk_mod [ expr $thk+0.1 ]	
			set ht_mod [ expr $ht+0.1 ]	
			puts $fpctm_mod "$lyr $thk_mod $ht_mod"
			set height [expr $ht+$thk ]
			if {[ regexp -nocase {^\s*m\S*(\d+)} $lyr tmp idx ]} {
				if {$idx==1}  {
				set layer $lyr
			#	puts $layer
				}
			} 
			}
		} else {
		puts $fpctm_mod "$line"
		}
		} else {
		puts $fpctm_mod "$line"
		}
		if {[ regexp {^\s*METAL_LAYERS\s+(\S+)} $line tmp ] } {
			set metals 1
		}
		if {[ regexp {^\s*\}} $line tmp ]} {
			puts $fpctm_mod "$tmp"
#			puts "End of metals section"
			set metals 0
		}
	}
## Assuming substrate thickness is 6mil~150um
#puts "$layer $height $sub_thk"
close $fpctm
close $fpctm_mod
#exec mv adsThermal/CTM_header_mod.txt adsThermal/CTM_header.txt
set box [ get design -bbox ]
set user_hsf 0
set fphsf [ open "$tmpdir/hsf.cfg" w ]
set fpuhsf [ open "$userhsf" r ]
while { [ gets $fpuhsf line ] >=0 } {
        if { ![ regexp -all "\#" $line ] && $line ne ""} {
#		puts "CC"
		if {[ regexp -nocase {^\s*CutBoundary\s+(\S+\s+\S+\s+\S+\s+\S+)} $line tmp box ]} {
			puts "-I- User defined BBOX is $box"
		} elseif {[ regexp -nocase {^\s*StartEndLayer\s+(\S+)\s+(\S+)} $line tmp slayer elayer]} {
			puts "-I- User defined  Start End layer is $slayer $elayer"	
		} elseif {[ regexp -nocase {^\s*Top_temperature\s+(\S+)} $line tmp top_t]} {
			puts "-I- Top temperature is $top_t"
		} elseif {[ regexp -nocase {^\s*Btm_temperature\s+(\S+)} $line tmp btm_t]} {
			puts "-I- Top temperature is $btm_t"
		} elseif {[ regexp -nocase {^\s*Silicon_substrate\s+(\S+)} $line tmp subt]} {
			puts "-I- Substrate thickness is subt"
		} elseif {[ regexp -nocase {^\s*Material\s+(\S+)} $line tmp ]} {
		   	set user_hsf 1
			puts "-I- Material properties defined for all layers skipping Materials section and Layer to material mapping section"
		}
		if {$user_hsf==1} {
			puts $fphsf "$line"
		} 
		}
}
#puts "DD"
if {[info exists subt] == 0} {
puts "-I- Using default substrate thickness of 150um, ~6mil"
set subt 150
} 
set sub_thk [ expr {int($subt/$height)} ]
set fpgett [ open "$tmpdir/getAnsTemp.in" w ]
set temp [ gsr get TEMPERATURE_EM ]
	if { [info exists temp] } {
	set temp [ gsr get TEMPERATURE_EM ]
	} else {
	set temp 25
	puts "-I- Since temperature is not set in the GSR, setting temperature as 25"
	}
puts "AAA"
#set hifile "hot_interconnect_file_PG"
#if { [info exists hifile ]} {
#puts $fphsf "Network_pg ../hot_interconnect_file_PG"
#puts $fpgett "Hot_PG_file ../hot_interconnect_file_PG"
#} else {
puts $fphsf "Network_pg ../hot_interconnect_file_PG.pg"
puts $fpgett "Hot_PG_file ../hot_interconnect_file_PG.pg"
puts $fphsf "Network_Signal ../hot_interconnect_file_PG.sig"
puts $fpgett "Hot_SIG_file ../hot_interconnect_file_PG.sig"
#}
set topcell [get design]
#puts $fphsf "OD_loc_file $topcell\_bpf.rpt"
puts $fphsf "OD_loc_file ../adsRpt/GDS/$topcell\_od_self_heat_xtor.rpt"
puts $fphsf "CTM_folder adsThermal/"
puts $fphsf "chip_thermal_profile ./"
puts $fphsf "CutBoundary $box"
if { [info exists slayer] } {
puts $fphsf "StartEndLayer $slayer $elayer" 
} else {
puts $fphsf "StartEndLayer $layer $layer" 
}
#puts $fphsf "Silicon_substrate $sub_thk"
#puts $fphsf "OD_thickness 0.05"
puts $fphsf "ModelLocation ./" 
if {[info exists top_t]} {
puts $fphsf "Top_Temperature $top_t" 
} else {
puts $fphsf "Top_Temperature $temp" 
}
if {[info exists btm_t]} {
puts $fphsf "Btm_Temperature $btm_t" 
} else {
puts $fphsf "Btm_Temperature $temp" 
}
puts $fphsf "T_ref $temp
TBackMethod 1"
puts $fphsf "# -------------- Mesh control -------------
# Geometry merging tolerance 
Mesh_t     0.1
# Maximum edge length in mesh (um)
#Mesh_l     1000
Mesh_l     20
# Triangle quality control for edges larger than 
Mesh_qt   20
# Minimum triangle angle
Mesh_qa  10
Flow_Type 2
AnsysMVer $ansysm"
if {$user_hsf ==0} {
puts $fphsf  "-------------- Layer Material -------------
# Material properties: Material, ID, Name, Num_properties, 
Material   1  Copper  \{
   	EX         120.0 
   	NUXY     0.33     
   	ALPX      1.7e-5
   	KXX        0.391e-3     
   	REFT       20
\}
Material   2  Dielectric \{
 	EX          3.0 
 	NUXY     0.3     
 	ALPX     1.7e-5
 	KXX       1.38e-6     
 	REFT      20
\}
Material   3  Silicon \{
	 EX          161.0 
	 NUXY     0.20675     
	 ALPX     2.6e-6
	 KXX       146e-6     
	 REFT      20
\}
Material   4  OD \{
	 EX          161.0 
	 NUXY     0.20675     
	 ALPX     2.6e-6
	 KXX       146e-6     
	 REFT      20
\}
# -------------- Default metal/dielectric material IDs --- 
Default_material  1   2
# Layer Metal/Dielectric material ID
# To be compliant with RD build
OD_Layer 4 0.05 1
Bottom_layers {
	Substrate 3 18 3
}\n";
###############
#Layer_material \{
#	Sub  3
#	OD  4
#\}"
} else {
puts $fphsf $fpuhsf
}
puts $fpgett "T_ref $temp
AnsysM_RUN 1 \{"
set signode "wsnode.sig"
if { [info exists signode ] } {
puts $fpgett "signal_nodes wsnode.sig"
}
puts $fpgett "PG_nodes wsnode.pg
Ansys_results ./T_wires.txt
\}"
set fpansm [ open "$tmpdir/run_ansys_apdl.txt" w ]
puts $fpansm "
!run batch: (examples)
/batch
/config,noeldb,1     ! force off writing results to database
/INPUT,'chipmodel','ans','',1,0 
!Note: The /CONFIG,NORSTGM command below is not valid in Distributed ANSYS solution.
/config,norstgm,1   
/SOLU   
!
!create component
!
ESEL,S,MAT,,1   
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
/page,1000000,,1000000
ESEL,S,MAT,,1   
ALLSEL,BELOW,ELEM   
/output,'./T_wires.txt'
PRNSOL,TEMP
!/output
fini
/exit,nosav"
close $fpuhsf
close $fpansm
close $fphsf
close $fpgett
}
proc atclmakebpf_pmic {} {
set top [get design]
set frdson [ open "adsRpt/RDSON.rpt" r ]
set fbpf [ open ".submodel/$top\_bpf.rpt" w ]
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
			set pwr_t [ expr ($volt*$cur)*1000 ]
			set pwr [ expr ($pwr_t/2) ]
			set lx_1 [ expr $lx1-0.25 ]
			set ux_1 [ expr $lx1+0.25 ]
			set ly_1 [ expr $ly1-0.25 ]
			set uy_1 [ expr $ly1+0.25 ]
			set lx_2 [ expr $lx2-0.25 ]
			set ux_2 [ expr $lx2+0.25 ]
			set ly_2 [ expr $ly2-0.25 ]
			set uy_2 [ expr $ly2+0.25 ]
			puts $fbpf "OD$i $lx_1 $ly_1 $ux_1 $uy_1 $pwr"
			incr i			
			puts $fbpf "OD$i $lx_2 $ly_2 $ux_2 $uy_2 $pwr"
			}
		}
	}
}
close $fbpf
close $frdson
}
