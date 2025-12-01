#!/usr/bin/tclsh

proc generate_pwl_for_GPS { args } {

set state "flag";
set argv [split $args];

foreach arg $argv {

 switch -- $state {
   flag {
    	 switch -glob -- $arg {
       				-i { 
					set state "input_state"; 
				   }
			        -out_dir { 
					set state "output_state";
					 }
       				default { 
					error "missing arguments";
					 }
                              } 
        } 
    input_state {
                  if { [regexp {^-} $arg]} {
    	             error "Wrong argument"
		     return;
				            }
 		  set input_file "$arg";
		  set state "flag";
		}
    output_state {
	           if { [regexp {^-} $arg]} {
		      error "Wrong argument"
		      return;
	                                     }

	     	   set output_directory "$arg";
		   set state "flag";
                 }

    }                      
}

global env     
global net_pin_pair_list         
exec mkdir -p $output_directory

if {[catch {set del_files [ glob $output_directory\/*raw* ]}] == 0 } {
foreach raw_pwl_files $del_files {
if { [catch {file delete -force $raw_pwl_files}] == 0} {
}
}
}
set fp_input_open [open "$input_file" r];
set fp_output_open [open "$output_directory/block_raw_list" w];

while { [gets $fp_input_open line] >= 0 } {
 
  if { $line ne "" && ![regexp "#" $line]} {

      set line_length [llength $line]
      
      for { set word_count 0 } { $word_count < $line_length} {incr word_count} {
           if { $word_count == 0 } {
		set inst_name [lindex $line $word_count];
		} elseif { $word_count != 0  && $word_count%2 == 0} {
                set pin_name [lindex $line $word_count]
		set net_pin_pair_list($inst_name,$net_name) $pin_name
		} elseif { $word_count != 0 && $word_count%2 == 1} {
		set net_name [lindex $line $word_count]
		} else { }
	}

				
      set coordinates [get inst $inst_name -bbox]
     
	if { [catch { #puts "plot current -region $coordinates -nograph -o $output_directory/$inst_name\_raw_pwl"}] == 0 } {
	}

   if { [catch { plot current -region [lindex $coordinates 0] [lindex $coordinates 1] [lindex $coordinates 2] [lindex $coordinates 3] -o $output_directory/$inst_name\_raw_pwl -nograph} ] == 0} {
	}
    		     }


 puts $fp_output_open "$inst_name";
}

close $fp_input_open;                   
close $fp_output_open;                                           

generate_pwl -i $output_directory/block_raw_list -out_dir $output_directory

if { [info exists net_pin_pair_list] } {
unset net_pin_pair_list
}
}

##################################

proc generate_pwl { args } {

set state "flag";
set argv [split $args];

foreach arg $argv {

switch -- $state {

	  flag {

		switch -glob -- $arg {

					-i {
					    	set state "input_state";
					   }

					-out_dir {
				   	   	 set state "output_state";
					   }
					default {
					  	 error "missing arguments";
						}
				      }
	        }

	  input_state {
			if { [regexp {^-} $arg]} {
			    	error "wrong usage of command:input";
			    	return;
			   }
			set input $arg;
			set state "flag";
		      }

	  output_state {
			 if { [regexp {^-} $arg] } {
			   	  error "wrong usage of command:output";
	                       	  return;
			    }
			 set output_dir $arg;
			 set state "flag";
		       }

		}
	}

global env
global net_pin_pair_list
set count 0
set flag_count 0

set inst_count 1

set fp_input_file [open "$input" r];
set GPS_extra_gsr [open "$output_dir/GPS_PWL_files.txt" w];

if {[catch {set del_files1 [glob $output_dir/*.pwl]}] == 0 } {
foreach pwl_file $del_files1 {
if { [catch {file delete -force $pwl_file}] == 0} {
}
} 
}



while { [gets $fp_input_file line_blocks] >= 0} {

if { $line_blocks ne "" } {
set block_name "$line_blocks\_raw_pwl";
set block_name1 "$line_blocks"


set fp_open [open "$output_dir/$block_name" r];
set write_pwl [open "$output_dir/$inst_count\.pwl" w];

set count 0;
while { [gets $fp_open line] >= 0 } {
	
if { $line ne "" && ![regexp "#" $line] } {
		if { [regexp {[a-df-zA-Z]} $line] || [regexp "\"" $line] } {

			if { $count > 0 } {
				puts $write_pwl "\+\)";
			   }

			set count [expr $count+1];
			set pin_temp [split $line "\""];
			set pin [lindex $pin_temp 1];
			if { [catch { set pin_name $net_pin_pair_list($line_blocks,$pin) }] == 0 } {
			} else {
				puts "\nError Info: Block nets of $line_blocks is not Matching with Block nets defined in the input file\n";
				}
				

			puts $write_pwl "\n";
			if {[catch {puts $write_pwl "\I$pin_name PWL \("; }] == 0}  {
			}

		   } else {
				if { $flag_count == 0 } {
					set line_split [split $line " "];
					set carry_negative [lindex $line_split 0];
					set carry_positive [expr abs($carry_negative)];
					set carry_ps [expr $carry_positive*1e-12];
				   }
				set flag_count [expr $flag_count+1];
				set split_line [split $line " "];
				set time [lindex $split_line 0];
				set current [lindex $split_line 1];
				set time_ps [expr $time*1e-12];
				if { $time_ps >= 0 } {
					puts $write_pwl "\+ $time_ps $current";
				   }
			  }

           }

      }

if { [gets $fp_open line] < 0} {
set block_freq [expr 1/$time_ps];
set block_freq_mhz [expr $block_freq/1000000];
puts $write_pwl "\+\)";
puts $GPS_extra_gsr "$block_name1 $output_dir/$inst_count.pwl"
}
}

set inst_count [expr $inst_count+1]
close $write_pwl

}
close $fp_input_file;
close $GPS_extra_gsr;

                      };#END OF PROC


