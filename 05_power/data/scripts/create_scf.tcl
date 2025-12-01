# $Revision: 1.3 $



proc create_scf_manpage {} {
	puts "
SYNOPSIS
        Apache-AE TCL utility for for creating the Switch chain file required for STA file flattening in heirarchical rampup analysis. 

USAGE
        create_scf \[option_arguments\]

        Options:
        -switch_id_file <input_file>   Input file containing the start point pin of switch daisy chains in top level (required)
        -block_list_file <input_file>  Input file containing the master names of blocks in the design (required)
	-xref_file <output_file> Output file containing the instance name cross-reference for blocks
	\[-out_dir <output_file>\] Output directory where the scf files will be dumped(optional; default: ./scfs)
	\[-h\] 		  command usage
	\[-m\]		  man page
"
}

proc create_scf_help {} {
	puts "Usage: create_scf -switch_id_file <input_file> -block_list_file <block-list> -out_dir <output_dir> -xref_file <output_xref_file> \[-h\] \[-m\]"
}

proc create_scf { args } {
	
	# Process command arguments
	# Possible flags are:-switch_id_file, -out_dir, -h* and -m*
	set x [exec date]
        puts "INFO	: Started create_scf process on $x"
	set argv [split $args]
	if {[llength $argv] == 0 } { set argv "-h" }
	set state flag
	set inputf ""
	set outputf ""
	foreach arg $argv {
		switch -- $state {
			flag {
				switch -glob -- $arg {
					-h* { create_scf_help ; return }
					-m* { create_scf_manpage ; return }
					-switch_id_file  { set state inputflag }
					-block_list_file  { set state blockflag }
					-out_dir  { set state outputflag }
					-xref_file { set state xrefflag }
					default { error "atcl Error: unknown flag $arg" }
				}
			}
			inputflag {
				set inputf $arg
				set state flag
			}
			outputflag {
				set outputf $arg
				set state flag
			}
			blockflag {
				set blockf $arg
				set state flag
			}
                        xrefflag {
				set xref_file $arg
				set state flag
			}
		}
	}

	# Check required options
	if {![info exists inputf] } {
		puts "Missing required option/value for switch_id_file"
		create_scf_help
		return
	}
	if {![info exists blockf] } {
		puts "Missing required option/value for block_list_file"
		create_scf_help
		return
	}
	# Check optional switches
	if {![info exists outputf]} {
		puts "Missing value for out_dir. Use default value './scfs'/"
		set outputf "./scfs"
		
	}
	if {![info exists xref_file]} {
		puts "INFO    : Missing value for xref_file. Use default value './block.inst'"
		set xref_file "block.inst"
		
	}        
suppress_message [list CMD-041]

set OUT [open $xref_file w]

#Newly added by Jai for run time optimization
set block_list_file $blockf
set cnt_inst 0 
set cnt_block 0
set file0 $block_list_file
if {![file exists $file0]} {
 puts "ERROR	: File $file0 does not exist. Exiting"
 exit
}  else {
  puts "INFO	: Reading Block List File : $file0"
}
set fid [open $file0 r]

while {[gets $fid line] >= 0} {
 if {[regexp -nocase {^\s*$} $line]} { 
   #ignoring empty lines
   continue 
 } elseif {[regexp -nocase {^\s*\#} $line]} { 
   #ignoring comments
   continue 
 } elseif { [llength [get_cells * -quiet -filter "ref_name == $line" ]] < 1  } { 
   puts "WARNING	: No instances found for block $line. Check your inputs. Ignoring this block ..."
   continue
 }
 set insts [get_cells * -quiet -filter "ref_name == $line" ]
 foreach_in_collection inst $insts  {
   set inst_name [get_attribute $inst full_name]
   puts "INFO	: Found instance $inst_name for block $line"
   incr cnt_inst
   puts $OUT "$line $inst_name"
 }
 incr cnt_block
}
puts "INFO	: Total $cnt_block valid blocks found in block list file"
close $fid
if ($cnt_inst<1)  {
  puts "ERROR	: No instances found for the specified blocks. Check the block list file"
  return
}
puts "INFO	: Total $cnt_inst instances found for the specified blocks"
##Finished the newly added section

set file $inputf
set out_dir $outputf

if {![file exists $file]} {
 puts "ERROR	: File $file does not exist. Exiting"
 exit
}  else {
  puts "\nINFO	: Reading Switch ID file : $file"
}


set fid0 [open $file r]
set cnt 0
exec rm -rf $out_dir
exec mkdir -p $out_dir

while {[gets $fid0 line] >= 0} {
 set pin_found [expr [llength [get_pins $line -quiet ]] + [llength [get_ports $line -quiet ]] ]
 #puts "Jai: $pin_found"
 if {[regexp -nocase {^\s*$} $line]} { 
   #ignoring empty lines
   continue 
 } elseif {[regexp -nocase {^\s*\#} $line]} { 
   #ignoring comments
   continue 
 } elseif { $pin_found < 1  } { 
   puts "WARNING	: Pin $line not found. Check your inputs. Ignoring this pin ..."
   continue
 }
 set file "$out_dir/chain_$cnt"
 set start $line
 set timing_report_unconstrained_paths 1
 puts "\nINFO	: Generating the SCF for pin: $start"
 foreach_in_collection inst $insts  {
   puts "INFO	: Querying the timing path from $start through $inst_name"

   set inst_name [get_attribute $inst full_name]   
   redirect  -append $file { report_timing -through $inst_name  -max_paths 1000 -rise_from $start -in -nosplit } 
   set n [sizeof_collection  [get_timing_paths  -max_paths 1000 -from $start -through  $inst_name]]
   if ($n>0)  {
     puts "INFO	: Found total $n paths passing through the block"
   } else  {
     puts "INFO	: No paths found. This chain does not pass through the block"
   }
 }
 incr cnt
}

close $fid0

set scf_cnt [llength  [ls $out_dir/*]]
puts "\nINFO	: Generated total $scf_cnt SCF files in $out_dir directory."
if { $scf_cnt < 1 } {
  puts "ERROR	: No SCF files generated. Check your inputs."
}
set x [exec date]
puts "INFO	: Finished create_scf process on $x"
close $OUT
}
