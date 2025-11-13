#### driver太弱 loading 太多 fanout 一般不咋修 不会对design造成影响
### icc22 pt 同时开
#          ／＞　　フ
#          |  x　 x |
# 　 　　　／` ミ＿꒳ノ
# 　　 　 /　　　 　 |
# 　　　 /　 ヽ　　 ﾉ
# 　 　 │　　|　|　|
# 　／￣|　　 |　|　|
# 　| (￣ヽ＿_ヽ_)__)
# 　＼二つ
### fix_eco_drc    max_capacitance
set clk_buf            "CLKBUFV10RQ_12TR40 CLKBUFV10_12TR40 CLKBUFV2_12TR40 CLKBUFV3_12TR40 CLKBUFV4RQ_12TR40 CLKBUFV4_12TR40 CLKBUFV5_12TR40 CLKBUFV6RQ_12TR40 CLKBUFV6_12TR40 CLKBUFV7_12TR40 CLKBUFV8RQ_12TR40 CLKBUFV8_12TR40 CLKBUFV10RQ_12TR40 CLKBUFV10_12TR40 CLKBUFV2_12TR40 CLKBUFV3_12TR40 CLKBUFV4RQ_12TR40 CLKBUFV4_12TR40 CLKBUFV5_12TR40 CLKBUFV6RQ_12TR40 CLKBUFV6_12TR40 CLKBUFV7_12TR40 CLKBUFV8RQ_12TR40 CLKBUFV8_12TR40"
set other_buf               "BUFV10RD_12TR40 BUFV10RO_12TR40 BUFV10RQ_12TR40 BUFV10_12TR40 BUFV12RD_12TR40 BUFV12RO_12TR40 BUFV12RQ_12TR40 BUFV12_12TR40 BUFV16RD_12TR40 BUFV16RO_12TR40 BUFV16RQ_12TR40 BUFV16_12TR40 BUFV1RD_12TR40 BUFV1_12TR40 BUFV20RD_12TR40 BUFV20RO_12TR40 BUFV20RQ_12TR40 BUFV20_12TR40 BUFV24RD_12TR40 BUFV24RO_12TR40 BUFV24RQ_12TR40 BUFV24_12TR40 BUFV2RD_12TR40 BUFV2RQ_12TR40 BUFV2_12TR40 BUFV32RD_12TR40 BUFV32RO_12TR40 BUFV32RQ_12TR40 BUFV32_12TR40 BUFV3RD_12TR40 BUFV3RQ_12TR40 BUFV3_12TR40 BUFV4RD_12TR40 BUFV4RO_12TR40 BUFV4RQ_12TR40 BUFV4_12TR40 BUFV5RD_12TR40 BUFV5RO_12TR40 BUFV5RQ_12TR40 BUFV5_12TR40 BUFV6RD_12TR40 BUFV6RO_12TR40 BUFV6RQ_12TR40 BUFV6_12TR40 BUFV7RD_12TR40 BUFV7RO_12TR40 BUFV7RQ_12TR40 BUFV7_12TR40 BUFV8RD_12TR40 BUFV8RO_12TR40 BUFV8RQ_12TR40 BUFV8_12TR40"
fix_eco_drc -type max_transition -buffer_list   $other_buf 

### size driver
### change_selection [get_nets -of [get_pins dasdad/Y]] 再找drive    -to -from
size_cell $inst_name $cell

### add buf on route         split fanout
set net mcu_top_mbist_inst/PA10_BCELL/selecttagInput
# 一分二 二前插
add_buff_on_route $net -location {545 772} -lib_cell BUF_XX -detect_layer -punch_port
# 更长 更大 不止插一个
add_buffer_on_route $net -lib_cell BUFXX -detect_layer -punch_port -repeater_distance 200

### insert buf on driver output
insert_buffer $pin $cell

### change net layer to fix net delay 变高层
set net mcu_top_i/HFSNET_799
remove_shapes [get_shapes -of [get_nets $net]]
remove_vias [get_vias -of [get_nets $net]]
set_routing_rule [get_nets $net] -min_routing_layer xx -max_routing_layer xx



### 再pt检查
report_global_timing > ./rpts/timing.sum
report_timing -nosplit -input_pins -significant_digits 3 -nets -slack_lesser_than 0 -max_paths 9999 > ./rpts/timing.rpt
report_constraint -max_transition -all_violators  -significant_digits 3 -nosplit  >  ./rpts/tran.rpt
report_constraint -max_capacitance -all_violators  -significant_digits 3 -nosplit  >  ./rpts/cap.rpt
report_constraint -max_fanout -all_violators  -significant_digits 3 -nosplit  >  ./rpts/fanout.rpt
