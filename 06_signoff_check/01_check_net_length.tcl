set nets [get_object_name [get_nets * -physical_context]]

foreach net $nets {
    set type [get_attr [get_nets $net] net_type]
    set length [get_attr [get_nets $net] dr_length]
    if {$type == "clock" && $length > 600 } {
        add_buffer_on_route $net -lib_cell CLKBUFV10RQ_12TR40  -punch_port -repeater_distance 350
    } elseif {$type == "signal" && $length > 600 } {
        add_buffer_on_route $net -lib_cell BUFV20RO_12TR40  -punch_port -repeater_distance 200
    }
    
}
set nets [get_object_name [get_nets * -physical_context]]
foreach net $nets {
    set type [get_attr [get_nets $net] net_type]
    set length [get_attr [get_nets $net] dr_length]
    if {$type == "clock" && $length > 600 } {
        echo "$type $length $net" >> ./rpts/clock_length.rpt
    } elseif {$type == "signal" && $length > 600 } {
        echo "$type $length $net" >> ./rpts/signal_length.rpt
    }
}