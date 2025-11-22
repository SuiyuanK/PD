# awk '{ gsub(/^PLCORNER/,"\/\/PLCORNER"); print $0 }' aes_ASIC_sim.vg > aes_ASIC.vg


# 有只读cdl的 
# -l ./verilog/RAMSP1024X16.v -l ./verilog/RAMTP1024X16.v -l ./verilog/scc40nll_vhsc40_hvt_pg.v -l ./verilog/scc40nll_vhsc40_lvt_pg.v -l ./verilog/scc40nll_vhsc40_rvt_pg.v \
# -s0 GND -s1 VDD
v2lvs -64 -v /mnt/hgfs/Em/PD/eco/outputs/image_icb.pg.v.gz \
      -s ./cdl/RAMSP1024X16.cdl -s ./cdl/RAMTP1024X16.cdl -s ./cdl/scc40nll_vhsc40_hvt.cdl -s ./cdl/scc40nll_vhsc40_lvt.cdl -s ./cdl/scc40nll_vhsc40_rvt.cdl\
      -s ./cdl/empty_subckt.sp \
      -o top.spi 


# echo '.GLOBAL VDD' >> top.spi
# echo '.GLOBAL VSS' >> top.spi
