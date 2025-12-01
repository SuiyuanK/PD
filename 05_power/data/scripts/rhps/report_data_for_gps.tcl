proc report_block_power { args } {

set argv [ split $args ]
set state flag
foreach arg $argv {
                switch -- $state {
                        flag {
                                switch -glob -- $arg {
			 		-i { set state input_file_state }
					-o { set state output_file_state }
                                }
			}	
			
			input_file_state {
			set input_file $arg
			set state flag
			}
			
			output_file_state {
			set output_file $arg
			set state flag
			}
	}

}

#puts "INPUT BLOCK LIST FILE is :$input_file"
#puts "OUTPUT POWER REPORT FILE is : $output_file"

set fp [ open "$input_file" r ]
set wr [ open "$output_file" w ]

while { [ gets $fp line ] >= 0 } {
set lines [ split $line "\n" ] ;
foreach line $lines {
if { $line ne ""} {
	regsub -all {\t} $line " " line1
        regsub -all -- {[[:space:]]+} $line1 " " line2
	regsub -all -- {^\s+} $line2 " " line3
set words [ split $line3 " "]
set type [ lindex $words 1 ]
if { $type eq "BLOCK" } {
set blockname [ lindex $words 0 ]
if { [ catch { report block $blockname -power  } ] == 0 } {

set power_info [ report block $blockname -power ]
puts $wr "$power_info"

set gnd_info [ report block $blockname -gnd_current ]
set lines [ split $gnd_info "\n" ]

foreach line1 $lines {

if { ![regexp "^Block :" $line1] && ![ regexp "^Domain" $line1] } {
puts $wr "$line1"
}

}

} else {

puts $wr "Block : $blockname NA"
}
}

if { $type eq "REGION" } {
set blockname [ lindex $words 0 ]
if { [ catch { report block $blockname -power  } ] == 0 } {

set power_info [ report block $blockname -power ]
puts $wr "$power_info"

set gnd_info [ report block $blockname -gnd_current ]
set lines [ split $gnd_info "\n" ]

foreach line1 $lines {

if { ![regexp "^Block :" $line1] && ![ regexp "^Domain" $line1] } {
puts $wr "$line1"
}

}

} else {

puts $wr "Block : $blockname NA"
}
}

if { $type eq "IP" } {
if { [ catch { unset power } ] == 0 } {

}
set IPname [ lindex $words 0 ]
if { [ catch { report inst $IPname -power } ] == 0 } {
set power_info [ report inst $IPname -power ]

puts $wr "Block : $IPname"
puts $wr "Domain\ttotal_pwr (Watt)"
#puts "$power_info"
set lines [ split $power_info "\n" ]
foreach line $lines {
#puts "$line"
if { ![ regexp "domain$" $line ] && ![ regexp "^\-" $line ] && $line ne ""} {

regsub -all {\t}  $line " " line1
regsub -all -- {[[:space:]]+} $line1 " " line2
set words [ split $line2 " "]
set dom [ lindex $words 3 ]
set pwr [ lindex $words 1 ]
if { [ info exists power($dom) ] && $pwr ne ""} {
set power($dom) [ expr $power($dom) + $pwr ] ;
} else {

set power($dom) 0
set power($dom) [ expr $power($dom) + $pwr ] 
}
        
}
}

if { [ catch { report inst $IPname -gnd_current } ] == 0 } {
set gnd_info [ report inst $IPname -gnd_current ]
set lines2 [ split $gnd_info "\n" ]
foreach line $lines2 {
if { ![ regexp "ground_current" $line ] }  {
puts $wr "$line"
}
}
}

} else {
puts $wr "Block : $IPname"
puts $wr "Domain\ttotal_pwr (Watt)"
}

foreach dom1 [ array names power ] { 
puts $wr "$dom1\t$power($dom1)" 
}

}


}
}
}
close $fp ; 
close $wr ;
}

proc report_block_cap { args } {

set argv [ split $args ]
set state flag
foreach arg $argv {
                switch -- $state {
                        flag {
                                switch -glob -- $arg {
			 		-i { set state input_file_state }
					-o { set state output_file_state }
                                }
			}	
			
			input_file_state {
			set input_file $arg
			set state flag
			}
			
			output_file_state {
			set output_file $arg
			set state flag
			}
	}

}

#puts "INPUT BLOCK LIST FILE is :$input_file"
#puts "OUTPUT POWER REPORT FILE is : $output_file"

set fp [ open "$input_file" r ]
set wr [ open "$output_file" w ]

while { [ gets $fp line ] >= 0 } {
set lines [ split $line "\n" ] ;
foreach line $lines {
if { $line ne ""} {
	regsub -all {\t} $line " " line1
        regsub -all -- {[[:space:]]+} $line1 " " line2
	regsub -all -- {^\s+} $line2 " " line3
set words [ split $line3 " "]
set type [ lindex $words 1 ]
if { $type eq "BLOCK" } {
set blockname [ lindex $words 0 ]
if { [ catch { report block $blockname -cap  } ] == 0 } {
set cap_info [ report block $blockname -cap ]
puts $wr "$cap_info"
} else {
puts $wr "Block : $blockname NA"
}
}
if { $type eq "IP" } {
set IPname [ lindex $words 0 ]
if { [ catch { report inst $IPname -cap } ] == 0  } {
set cap_info [ report inst $IPname -cap ]
if { ![ regexp "WARN" $cap_info ] } {
if { [ catch { unset total_cap } ] == 0 } {

}
puts $wr "Block : $IPname"
puts $wr "Domain          total_cap (F)"
set lines3 [ split $cap_info "\n" ]
foreach line $lines3 {
if { ! [ regexp "^Domain" $line ] } {

if { $line ne ""} {
	regsub -all {\t} $line " " line1
        regsub -all -- {[[:space:]]+} $line1 " " line2
	regsub -all -- {^\s+} $line2 " " line3
set words [ split $line3 " " ]
set dom [ lindex $words 0 ]
set cap [ lindex $words 1 ]
if { [ info exists total_cap($dom) ] && $cap ne "" ] } {
set total_cap($dom) [ expr $total_cap($dom) + $cap ] ;
} else {

set total_cap($dom) 0
set total_cap($dom) [ expr $total_cap($dom) + $cap ] 

}


}

}
}

foreach dom1 [ array names total_cap ] { 
puts $wr "$dom1\t$total_cap($dom1)" 
}

}

} else {
puts $wr "Block : $IPname"
puts $wr "Domain          total_cap (F)"
}
}


}
}
}
close $fp ; 
close $wr ;
}


