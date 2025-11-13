set nets [get_object_name [get_nets * -physical_context]]

foreach net $nets {
    set type [get_attr [get_nets $net] net_type]
    set length [get_attr [get_nets $net] dr_length]
    if {$type == "clock"} {
        echo "$type $length $net" >> ./rpts clock_length.rpt
    } elseif {$type == "signal"} {
        echo "$type $length $net" >> ./rpts signal_length.rpt
    }
    
}



