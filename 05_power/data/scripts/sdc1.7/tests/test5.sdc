#####################################################

#  Created by Design Compiler write_sdc on Fri Mar 30 17:18:30 2001

#####################################################
set sdc_version 1.2

create_clock -period 12 -waveform {0 6} [get_ports {CLK}]
set_clock_transition -rise 0.1 [get_clocks {CLK}]
set_clock_transition -fall 0.1 [get_clocks {CLK}]
set_clock_uncertainty  0.2 [get_clocks {CLK}]
set_clock_latency  0.1 [get_clocks {CLK}]
set_clock_latency -source  0.2 -early [get_clocks {CLK}]
set_clock_latency -source  0.25 -late [get_clocks {CLK}]
set_operating_conditions "WCCOM" -library "pt_lib"
set_wire_load_model  -name "05x05" -library "pt_lib"
