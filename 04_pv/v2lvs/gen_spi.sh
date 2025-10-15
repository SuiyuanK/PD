# awk '{ gsub(/^PLCORNER/,"\/\/PLCORNER"); print $0 }' aes_ASIC_sim.vg > aes_ASIC.vg




v2lvs -v ../data/pr_outputs/top.lvs.v.gz \
      -l ./verilog/RAMSP4096X16.v -l ./verilog/scc40nll_vhsc40_hvt_pg.v -l ./verilog/scc40nll_vhsc40_lvt_pg.v -l ./verilog/scc40nll_vhsc40_rvt_pg.v \
      -s ./cdl/RAMSP4096X16.cdl -s ./cdl/scc40nll_vhsc40_hvt.cdl -s ./cdl/scc40nll_vhsc40_lvt.cdl -s ./cdl/scc40nll_vhsc40_rvt.cdl\
      -o top.spi -s0 GND -s1 VDD


echo '.GLOBAL VDD' >> top.spi
echo '.GLOBAL VSS' >> top.spi
# echo '.GLOBAL POS_E3V' >> aes_ASIC.spi
