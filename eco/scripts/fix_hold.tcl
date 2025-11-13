### 先restore pt的结果 03_pt/sta/func.ff1p21v.bc.cmin_m40c.hold/func.ff1p21v.bc.cmin_m40c.hold

### report_global_timing
set clk_buf            "CLKBUFV10RQ_12TR40 CLKBUFV10_12TR40 CLKBUFV2_12TR40 CLKBUFV3_12TR40 CLKBUFV4RQ_12TR40 CLKBUFV4_12TR40 CLKBUFV5_12TR40 CLKBUFV6RQ_12TR40 CLKBUFV6_12TR40 CLKBUFV7_12TR40 CLKBUFV8RQ_12TR40 CLKBUFV8_12TR40 CLKBUFV10RQ_12TR40 CLKBUFV10_12TR40 CLKBUFV2_12TR40 CLKBUFV3_12TR40 CLKBUFV4RQ_12TR40 CLKBUFV4_12TR40 CLKBUFV5_12TR40 CLKBUFV6RQ_12TR40 CLKBUFV6_12TR40 CLKBUFV7_12TR40 CLKBUFV8RQ_12TR40 CLKBUFV8_12TR40"
set other_buf               "BUFV10RD_12TR40 BUFV10RO_12TR40 BUFV10RQ_12TR40 BUFV10_12TR40 BUFV12RD_12TR40 BUFV12RO_12TR40 BUFV12RQ_12TR40 BUFV12_12TR40 BUFV16RD_12TR40 BUFV16RO_12TR40 BUFV16RQ_12TR40 BUFV16_12TR40 BUFV1RD_12TR40 BUFV1_12TR40 BUFV20RD_12TR40 BUFV20RO_12TR40 BUFV20RQ_12TR40 BUFV20_12TR40 BUFV24RD_12TR40 BUFV24RO_12TR40 BUFV24RQ_12TR40 BUFV24_12TR40 BUFV2RD_12TR40 BUFV2RQ_12TR40 BUFV2_12TR40 BUFV32RD_12TR40 BUFV32RO_12TR40 BUFV32RQ_12TR40 BUFV32_12TR40 BUFV3RD_12TR40 BUFV3RQ_12TR40 BUFV3_12TR40 BUFV4RD_12TR40 BUFV4RO_12TR40 BUFV4RQ_12TR40 BUFV4_12TR40 BUFV5RD_12TR40 BUFV5RO_12TR40 BUFV5RQ_12TR40 BUFV5_12TR40 BUFV6RD_12TR40 BUFV6RO_12TR40 BUFV6RQ_12TR40 BUFV6_12TR40 BUFV7RD_12TR40 BUFV7RO_12TR40 BUFV7RQ_12TR40 BUFV7_12TR40 BUFV8RD_12TR40 BUFV8RO_12TR40 BUFV8RQ_12TR40 BUFV8_12TR40"
### fix_eco_timing buf叫dlyXXX 驱动能力极弱 只能在input pin上 
fix_eco_timing -type hold -buffer_list $clk_buf 
report_global_timing
write_changes -format icc2tcl -output ./scripts/fix_ecotiming.tcl

### size cell 看timing.rpt 换vt lvt->rvt 优先  驱动强度X1 -> X8  .XXX=XXXpf
size_cell $inst_name $cell

### insert buf
insert_buffer $pin $cell

### delay launch clock
insert_buffer $pin $cell

### early capture clock 这个要在icc里操作
connect_pins -driver $driver_pin $load_pin

### 再pt检查
report_global_timing > ./rpts/timing.sum
report_timing -nosplit -input_pins -significant_digits 3 -nets -slack_lesser_than 0 -max_paths 9999 > ./rpts/timing.rpt
report_constraint -max_transition -all_violators  -significant_digits 3 -nosplit  >  ./rpts/tran.rpt
report_constraint -max_capacitance -all_violators  -significant_digits 3 -nosplit  >  ./rpts/cap.rpt
report_constraint -max_fanout -all_violators  -significant_digits 3 -nosplit  >  ./rpts/fanout.rpt