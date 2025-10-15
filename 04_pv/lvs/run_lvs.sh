calibre -hier -lvs -hyper -spice ./bx1soc_top.ext -hcell cell.list -turbo -turbo_all -64 -lvs ~/TestPD/pv/lvs/SMIC_CalLVS_018MSE_1833_V1.11_1.lvs | tee lvs.log
touch lvs_ok.flag
