#
# Usage: 
#	atcl_atclResDebug -vddb <powerbump_instance_name> -vssb <groundbump_instance_name> -c <clamp_instance_name> -d <dir_name_with the path> \[-h\] \[-m\]
#
# Copyright 2008 Apache Design Solutions, Inc.
# All rights reserved.
#
# Revision history
#
# Rev 1.0 
# - Created by Roshan & Gireesh 01/02/08
# - Initial version
#
#########################################################################



proc atcl_atclResDebug_manpage {} {
	puts "
SYNOPSIS
        Apache-AE TCL utility for creating a run directory in which the required gsr file,tcl command file and other required files are generated which can be used to run a redhawk GUI which shows the IR map between the user specified clamp cell and bump pairs.
	

USAGE
        atclResDebug \[option_arguments\]

        Options:
        -vddb <powerbump_instance_name> Name of the powerbump instance to which the clamp is connected  
	-vssb <groundbump_instance_name>Name of the groundbump instance to which is clamp is connected 
	-c <clamp_instance_name>        Name of the clamp instance name
	-i<instance name>       	Name of the instance 
	-vdd <vdd domain name>		Name of the vdd doamin
	-vss <vss domain name> 		Name of the vss domain 
	-type < spesify type>		Specify the type (B2C ,C2I ,C2I_MACRO)
	-d <dir_name_with the path>     Name of the directory to be created in which the redhawk has to be run.Also include the path of the directory
	-esd_dir <input dir name> 	Name of the input directory 
	-rule_name <rule name > 	Name of the esd rule for type C2I an C2I macro 	
	\[-h\] 		  command usage
	\[-m\]		  man page

SAMPLE USAGE	
                  atclResDebug  -type B2C -vddb powerbump2 -vssb groundbump2 -c coreESDInst1 -d ../opdir
		  atclResDebug  -type C2I -i inst12 -c coreESDInst1 -vdd VDD -vss VSS -d ../opdir -rule_name rule1
"
}

proc atcl_atclResDebug_help {} {

	puts "atclResDebug  -type <B2C,C2I,C2I_MACRO> - i <instance_name> -vdd <vdddomain> -vss <vssdomain> -vddb <powerbump_instance_name> -vssb <groundbump_instance_name> -c <clamp_instance_name> -d <dir_name_with the path> -esd_dir <esd_dir_name> -rule_name <rulename> \[-h\] \[-m\]"
	puts "INFO : If type is B2C please give vddbump ,vssbump ,outdir and clampname"
	puts "INFO : If type is C2I or C2I_MACRO  please give vdddomain ,vssdomain ,instancename,clampname,rulename and outdir"
	puts "INFO : Option esd_dir is optional .Default adsRpt/ESD will be taken"
	puts " SAMPLE USAGE
	
			 atclResDebug  -type B2C -vddb powerbump2 -vssb groundbump2 -c coreESDInst1 -d ../opdir
			 atclResDebug  -type C2I -i inst12 -c coreESDInst1 -vdd VDD -vss VSS -d ../opdir -rule_name rule1 "

}


proc atclResDebug { args } {

set argv [split $args]
set state flag_s

foreach arg $argv {

		
			switch -- $state {
				flag_s {
					switch -glob -- $arg {

						-h* { atcl_atclResDebug_help ; return }
						-m* { atcl_atclResDebug_manpage ; return }
						-vddb { set state vddbump_s }	
						-vssb { set state vssbump_s }
						-c { set state clamp_s }
						-d { set state dir_s }
						-i { set state inst_s }
						-vdd { set state vdd_s }
						-vss { set state vss_s }
						-type { set state type_s }
						-esd_dir { set state esd_dir_s }
						-rule_name { set state rule_name_s }

					}
				}
				vddbump_s { 


					set vddbump_name $arg
					set state flag_s
				}
				vssbump_s {
					set vssbump_name $arg
					set state flag_s
				}
				clamp_s {
					set clamp_name $arg
					set state flag_s
				}
				dir_s {
					set dir_name $arg
					set state flag_s
				}
				inst_s {
					set inst_name $arg
					set state flag_s
				}
				vdd_s {
					set vdd_name $arg
					set state flag_s
				}
				vss_s {
					set vss_name $arg
					set state flag_s
				}
				type_s {
					set type $arg
					set state flag_s
				}
				esd_dir_s {
					set esd_dir $arg
					set state flag_s
				}
				rule_name_s {
					set rule_name $arg
					set state flag_s
				}
				
				
						 

			}
			
		}

		
	
#checking for inputs 
if {![info exists type]}  {
puts  "ERROR: Please mention the type"
return;

}


if {![info exists esd_dir]}  {
puts  "INFO: ESD dir not mentioned .Default adsRpt/ESD will be taken "
set esd_dir "adsRpt/ESD"


}
if { $type eq "C2I" || $type eq "C2I_MACRO"} { 

if {![info exists vdd_name] || ![info exists vss_name] || ![info exists inst_name] || ![info exists clamp_name] ||![info exists dir_name] || ![info exists rule_name]} {
puts "ERROR: Inputs missing for $type .Please give vdd domain ,vss domain ,instance name ,clamp name,rule name  and output dir_name "
return ;

}





}	
if { $type eq "B2C" } { 

if {![info exists clamp_name] || ![info exists vssbump_name] || ![info exists vddbump_name] || ![info exists dir_name]} {
puts "ERROR: Inputs missing for $type .Please give vddbump ,vssbump ,clamp name and output dir_name "
return ;
}

}		

#creating the directory(please include what to do if dir is existing)

if { [catch {exec mkdir -p $dir_name } ] == 0} {
}

#creating gsc file 
set gsc_f [open "$dir_name/file.gsc" w]
puts $gsc_f "* OFF"
close $gsc_f


#getting the information of the bumps inorder to create new pg.ploc
if { $type eq "C2I"} {


set files "$esd_dir/esd_pass.rpt $esd_dir/esd_fail.rpt"
set C2I_files [split $files " "]

set f_vss 0
set f_vdd 0	
set inst_flag 0
set rule_flag 0


	foreach file $C2I_files { 
	
	set esd_C2I_f [open "$file" r]
		while { [gets $esd_C2I_f rpt_line]>=0} {
		set rpt_C2I_ar [split $rpt_line]
		set values [lindex $rpt_C2I_ar 3]
		
		
		if { [regexp "NAME $rule_name" $rpt_C2I_ar] } {
		puts "matched line $rpt_C2I_ar"
       	          set rule_flag 1

        	}
		if { $rule_flag == 1 } {
	
			if { ([lindex $rpt_C2I_ar 13] eq $inst_name) && $f_vss == 0 } {
			set inst_flag 1
			if { [lindex $rpt_C2I_ar 5] eq $vdd_name } {
			
			set f_vdd 1
			if { [lindex $rpt_C2I_ar 11] eq $vss_name } {
		
			set pad_vdd_layer [lindex $rpt_C2I_ar 4] 
			set vdd_domain [lindex $rpt_C2I_ar 5]
			set pad_vdd_x [lindex $rpt_C2I_ar 2]
			set pad_vdd_y [lindex $rpt_C2I_ar 3]
		
			set pad_vss_layer [lindex $rpt_C2I_ar 10]
			set vss_domain [lindex $rpt_C2I_ar 11]
			set pad_vss_x [lindex $rpt_C2I_ar 8]
			set pad_vss_y [lindex $rpt_C2I_ar 9]
			set vddbump_name "vddbump"
			set vssbump_name "vssbump"
			set f_vss 1
		
			}
			}

			}
		}
		}

	}
		
			if { $rule_flag == 0} {
			puts "ERROR:Specfied rule name $rule_name is incorrect  "
			return ;
				
			}
			if { $inst_flag == 0} {
			puts "ERROR:Cant find instance with name $inst_name "
			return ;
				
			}
			
			if { $f_vdd == 0} {
			puts "ERROR:Given instance $inst_name not connected to $vdd_name  "
			return ;
				
			}
			
			if { $f_vss == 0} {
			puts "ERROR:Given instance $inst_name not connected to $vss_name  "
			return ;
				
			}




close $esd_C2I_f

} elseif { $type eq "C2I_MACRO"} {
set files "$esd_dir/esd_pass.rpt $esd_dir/esd_fail.rpt"
set C2I_files [split $files " "]
set f11 0
	foreach file $C2I_files { 
	set esd_C2I_f [open "$file" r]
	set clamp_flag 0
	set inst_flag 0
	set flagC2C 0
	set fvdd 0
	set fvss 0
	set rule_flag 0
		while { [gets $esd_C2I_f rpt_line]>=0} {
		set rpt_C2C_ar [split $rpt_line]
		
		if { [regexp "NAME $rule_name" $rpt_C2C_ar] } {
       	          set rule_flag 1

        	}
		if { $rule_flag == 1 } {
			if { [lindex $rpt_C2C_ar 1 ] eq $inst_name } {
       			set inst_flag 1
          		set flagC2C 1

        		}

        		if { [regexp "^INST" $rpt_C2C_ar] &&  [lindex $rpt_C2C_ar 1 ] ne $inst_name } {
        
          		set flagC2C 0

       			 }

			if { $flagC2C == 1 && $rpt_C2C_ar ne "" } {
	
	
				if {  [lindex $rpt_C2C_ar 6 ] eq $clamp_name } {
				set clamp_flag 1
				if { [lindex $rpt_C2C_ar 4] eq $vdd_name && $fvdd == 0   } {
				set vddbump_name "vddbump"
				set vdd_domain [lindex $rpt_C2C_ar 4]
				set pad_vdd_x [lindex $rpt_C2C_ar 1]
				set pad_vdd_y [lindex $rpt_C2C_ar 2]
				set pad_vdd_layer [lindex $rpt_C2C_ar 3]
				set fvdd 1
			
				}
				if { [lindex $rpt_C2C_ar 4] eq $vss_name && $fvss == 0   } {
				set vssbump_name "vssbump"
				set vss_domain [lindex $rpt_C2C_ar 4]
				set pad_vss_x [lindex $rpt_C2C_ar 1]
				set pad_vss_y [lindex $rpt_C2C_ar 2]
				set pad_vss_layer [lindex $rpt_C2C_ar 3]
				set fvss 1
			
				}
	
				}
	
	
			}
			}
			}
			
			if { $fvdd == 1 && $fvss ==1 } {
			break ;
			}


		}







	
				if { $rule_flag == 0} {
				puts "ERROR:Specfied rule name $rule_name is incorrect  "
				return ;
				
				}

				if { $inst_flag == 0} {
				puts "ERROR:Cant find instance with name $inst_name "
				return ;
				
				}
				
				if { $clamp_flag == 0} {
				puts "ERROR:Cant find clamp with name $clamp_name "
				return ;
				
				}
				if { $fvdd == 0} {
				puts "ERROR:Instance $inst_name not conected to $vdd_name "
				return ;
				
				}
				if { $fvss == 0} {
				puts "ERROR:Instance $inst_name not conected to $vss_name "
				return ;
				
				}
				
				
				
				

close $esd_C2I_f
} elseif { $type == "B2C" }   {
set vdd_domain     [lindex [get pad $vddbump_name -info] 8]
set pad_vdd_layer  [lindex [get pad $vddbump_name -info] 6]
set pad_vdd_y      [lindex [get pad $vddbump_name -info] 4]
set pad_vdd_x      [lindex [get pad $vddbump_name -info] 3]
set vdd_name $vdd_domain
set vss_domain     [lindex [get pad $vssbump_name -info] 8]
set pad_vss_layer  [lindex [get pad $vssbump_name -info] 6]
set pad_vss_y      [lindex [get pad $vssbump_name -info] 4]
set pad_vss_x      [lindex [get pad $vssbump_name -info] 3]
set vss_name $vss_domain

} else {
puts "ERROR : Type must be either B2C or C2I or C2I_MACRO"
return ;

}

# creating the new ploc file

set ploc_f [open "$dir_name/pg.ploc" w]
puts  $ploc_f "$vddbump_name $pad_vdd_x $pad_vdd_y $pad_vdd_layer $vdd_domain"
puts  $ploc_f "$vssbump_name $pad_vss_x $pad_vss_y $pad_vss_layer $vss_domain"
close $ploc_f

#finding the res file in which metal layer info of the clamp cell is present

if {$type eq "C2I" || $type eq "C2I_MACRO" || $type eq "B2C" } {

set esd_rpt_name "$esd_dir/ClampInfo.rpt"
set flagvss 0
set flagf 0
set flagvdd 0
set clamp_inst_flag 0
	if {[file exists $esd_rpt_name]}  {
	
	set esd_rpt_f [open "$esd_rpt_name" r]
	
		while { [gets $esd_rpt_f rpt_line]>=0} {
		regsub -all {\t}  $rpt_line " " line1
		regsub -all -- {[[:space:]]+} $line1 " " rpt_line
		set rpt_line_ar [split $rpt_line]
		
		if { [lindex $rpt_line_ar 1 ] eq $clamp_name } {
       			set clamp_inst_flag 1
          		set flagf 1
		

        		}

			

        		if { [regexp {^\\\}} $rpt_line_ar] || ([regexp {^INST} $rpt_line_ar]   && [lindex $rpt_line_ar 1 ] ne $clamp_name )} {
        			
          		set flagf 0

        		}
 
 			if { $flagf == 1 && $rpt_line_ar ne "" } {
			
 				if { [lindex $rpt_line_ar 4] eq $vdd_name } {
				
 				set flagvdd 1
				set vdd_met [lindex $rpt_line_ar 3] 
				set vdd_x [lindex $rpt_line_ar 1]
				set vdd_y [lindex $rpt_line_ar 2]

				}
				if { [lindex $rpt_line_ar 4] eq $vss_name} {

				set flagvss 1
				set vss_met [lindex $rpt_line_ar 3] 
				set vss_x [lindex $rpt_line_ar 1]
				set vss_y [lindex $rpt_line_ar 2]

				}

			}
			if { $flagvdd == 1 && $flagvss == 1 } {
			break ;
			}




		}
		
		
				if { $clamp_inst_flag == 0} {
				puts "ERROR:Cant find clamp with name $clamp_name "
				return ;
				
				}
				if { $flagvdd == 0} {
				puts "ERROR: Clamp Instance $clamp_name not conected to $vdd_name "
				return ;
				
				}
				if { $flagvss == 0} {
				puts "ERROR:Clamp Instance $clamp_name not conected to $vss_name "
				return ;
				
				}


} else {

puts "ERROR:file $esd_rpt_name not present"
return ;
}

} else {

puts "ERROR:Type must be either B2C or C2I or C2I_MACRO" 
return ;
}

#closing the esd_rpt file
close $esd_rpt_f

#getting the voltage for the net domain and the ground amperes

set volt [get net $vdd_domain -ideal_voltage]

set curr [expr 0.01/$volt]

if { [catch {set vdd_up_x [expr $vdd_x+1]} ] == 0} {
set vdd_down_x [expr $vdd_x-1]
set vdd_up_y   [expr $vdd_y+1]
set vdd_down_y [expr $vdd_y-1]
 
if { [catch {set vss_up_x [expr $vss_x+1]} ] == 0} {
set vss_down_x [expr $vss_x-1]
set vss_up_y   [expr $vss_y+1]
set vss_down_y [expr $vss_y-1]


#opening the new gsr file 
set newg [open "$dir_name/new.gsr" w]

#writing BLOCK_POWER_ASSIGNMENT
puts $newg " BLOCK_POWER_ASSIGNMENT  {
FULLCHIP FULLCHIP $vss_met $vss_domain $curr
FULLCHIP FULLCHIP $vdd_met $vdd_domain .01
worst_pin_region1 REGION $vss_met $vss_domain $curr $vss_down_x $vss_down_y $vss_up_x $vss_up_y 
worst_pin_region2 REGION $vdd_met $vdd_domain .01 $vdd_down_x $vdd_down_y $vdd_up_x $vdd_up_y 
} 
GSC_FILE file.gsc
GSC_OVERRIDE_IPF 1
"



# this takes every line except PAD_FILES {........ }
#first catch  copyinggsre using sed
if { [catch {set gsr_content [ exec  sed {/PAD_FILES/,/\}/d ; /STATE_PROPAGATION/,/\}/d} ./.apache/apache.gsr ]}] == 0 } {
puts $newg "$gsr_content"


# here it writes the new gsr except the pad block


#inclding the newly created ploc file path in the new gsr
puts $newg "PAD_FILES { 
pg.ploc
}"

#gsr is closed
close $newg


#opening command file
set cmd_f [open "$dir_name/run_ResDebug.tcl" w]
puts $cmd_f "#import data
import gsr new.gsr
setup design
# performing extraction
perform extraction -power -ground
#performing  power claculation
perform pwrcalc
#performing static analysis
perform analysis -static
select add  $clamp_name
plot line -position $pad_vdd_x $pad_vdd_y $vdd_x $vdd_y -width 2 -color black
plot line -position $pad_vss_x $pad_vss_y $vss_x $vss_y -width 2 -color black
#dumping out IR map
dump gif -map IR -o irmap_gif

#printing the summary
puts \"#Bump_name \\t Current \\t Voltage_drop \\t Ideal_voltage \\t Resistance\\n \"

set line \[ exec grep \"worst_pin_region1\" new.gsr \]
set line_d \[split \$line\]
set vss_x_down \[lindex \$line_d 5\]
set vss_x_up \[lindex \$line_d 7\]
set vss_y_down \[lindex \$line_d 6\]
set vss_y_up \[lindex \$line_d 8\]
set vss_dom \[lindex \$line_d 3\]
set vss_met \[lindex \$line_d 2\]
set c \[lindex \$line_d 4\]

set line \[ exec grep \"worst_pin_region2\" new.gsr \]
set line_d \[split \$line\]
set vdd_x_down \[lindex \$line_d 5\]
set vdd_x_up \[lindex \$line_d 7\]
set vdd_y_down \[lindex \$line_d 6\]
set vdd_y_up \[lindex \$line_d 8\]
set vdd_dom \[lindex \$line_d 3\]
set vdd_met \[lindex \$line_d 2\]


set ir_file \[open \[glob ./adsRpt/Static/*.ir.worst\] r\]
set flag_vdd 0
set flag_vss 0
while \{ \[gets \$ir_file ir_line\]>=0\} \{
set line_dom \[lindex \$ir_line 2\]
set line_x \[lindex \$ir_line 4\]
set line_y \[lindex \$ir_line 5\]
set line_met \[lindex \$ir_line 6\]
	
	if \{ (\$line_dom == \$vss_dom) && (\$line_met == \$vss_met)\} \{
		
	
		if \{(\$line_x < \$vss_x_up) && (\$line_x > \$vss_x_down) && (\$line_y < \$vss_y_up) && (\$line_y > \$vss_y_down) && (\$flag_vss == 0) \} \{
			
			set vss_pin_drop \[lindex \$ir_line 0\]
			set vss_res \[expr \$vss_pin_drop/\$c\]
			set flag_vss 1
			puts \" groundbump \\t \$c \\t \$vss_pin_drop \\t 0 \\t \$vss_res \\n \"
		\}
	\}
	if \{ (\$line_dom == \$vdd_dom) && (\$line_met == \$vdd_met)\} \{
		
	
		if \{(\$line_x < \$vdd_x_up) && (\$line_x > \$vdd_x_down) && (\$line_y < \$vdd_y_up) && (\$line_y > \$vdd_y_down) && (\$flag_vdd ==0) \} \{
			
			set vdd_pin \[lindex \$ir_line 0\]
			set ideal_volt \[lindex \$ir_line 1\]
			set vdd_pin_drop \[expr \$ideal_volt-\$vdd_pin\]
			set vdd_res \[expr \$vdd_pin_drop/\$c\]
			set flag_vdd 1
			puts \" powerbump \\t \$c \\t \$vdd_pin_drop \\t \$ideal_volt \\t \$vdd_res \\n \"
		\}
	\}



\}
close \$ir_file

"
close $cmd_f

puts " Output Directory Created sucessfully. \nRun redhawk from $dir_name using run_ResDebug.tcl inorder to view the irmap of the specified ESD loop"

} else  {
puts "copying gsr contents failed"

} 
#first catch  copyinggsre using sed

} else {
puts "The VDD Bump $vddbump_name and clamp instance $clamp_name doesnt have connectivity.Check the connectivity or Check the names of bump pairs or clamp instance "
}
} else {
puts "The VSS Bump $vssbump_name and clamp instance $clamp_name doesnt have connectivity.Check the connectivity or Check the names of bump pairs or clamp instance "
}

}

