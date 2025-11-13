### 先restore_session pt的结果 03_pt/sta/func.ff1p21v.bc.cmin_m40c.hold/func.ff1p21v.bc.cmin_m40c.hold

### report_global_timing

### fix_eco_timing 
fix_eco_timing -type setup
report_global_timing
write_changes -format icc2tcl -output ./scripts/fix_ecotiming.tcl

### size cell 看timing.rpt 换vt rvt->lvt 优先 可以先导出来一条的 替换掉 /Y /CO为空格 换
size_cell $inst_name $cell

### delay capture clock delay前report timingfrom ck 看看后面的咋样(有margin再插 slack为+)
insert_buffer $pin $cell
#上面是虚拟的 在pt 看完结果后放icc2里

### early launch clock 这个要在icc里操作
connect_pins -driver $driver_pin $load_pin

# 触发器之间的时序路径可简化为：源触发器（FF1）→ 组合逻辑（Combinational Logic）→ 目标触发器（FF2）
# FF1 由 launch clock 驱动：在时钟沿（如上升沿）触发，Q 端输出数据（D1→Q1）。
# 数据通过组合逻辑传输，产生延时（Tcomb）。
# FF2 由 capture clock 驱动：在时钟沿（如上升沿）触发，D 端接收组合逻辑输出的数据，锁存到 FF2 内部。
# 此时序路径的核心约束是：数据必须在 capture clock 的有效沿到来前，稳定到达目标触发器的 D 端（即满足建立时间 Setup Time）。

### change net layer to fix net delay 变高层
set net mcu_top_i/HFSNET_799
remove_shapes [get_shapes -of [get_nets $net]]
remove_vias [get_vias -of [get_nets $net]]
set_routing_rule [get_nets $net] -min_routing_layer xx -max_routing_layer xx

### split fanout
set net xxxxxxxxx
add_buff_on_route $net -location {545 772} -lib_cell BUF_XX -detect_layer -punch_port
report_global_timing > ./rpts/timing.sum

report_timing -nosplit -input_pins -significant_digits 3 -nets -slack_lesser_than 0 -max_paths 9999 > ./rpts/timing.rpt
report_constraint -max_transition -all_violators  -significant_digits 3 -nosplit  >  ./rpts/tran.rpt
report_constraint -max_capacitance -all_violators  -significant_digits 3 -nosplit  >  ./rpts/cap.rpt
report_constraint -max_fanout -all_violators  -significant_digits 3 -nosplit  >  ./rpts/fanout.rpt