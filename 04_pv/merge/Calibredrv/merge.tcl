layout filemerge -mode append -precision 1000.0 -verbose -topcell top \
    -in /mnt/hgfs/Em/PD/04_pv/data/pr_outputs/top.gds.gz \
    -in /mnt/hgfs/Em/PD/04_pv/data/layout_files/SP40NLLD2RN_3P3V_V0p5_7MT_1TM.gds \
    -in /mnt/hgfs/Em/PD/04_pv/data/layout_files/scc40nll_vhsc40_hvt.gds \
    -in /mnt/hgfs/Em/PD/04_pv/data/layout_files/scc40nll_vhsc40_lvt.gds \
    -in /mnt/hgfs/Em/PD/04_pv/data/layout_files/scc40nll_vhsc40_rvt.gds \
    -in /mnt/hgfs/Em/PD/04_pv/data/layout_files/RAMSP1024X16.gds2 \
    -in /mnt/hgfs/Em/PD/04_pv/data/layout_files/RAMSP128X16.gds2 \
    -in /mnt/hgfs/Em/PD/04_pv/data/layout_files/RAMSP2048X16.gds2 \
    -in /mnt/hgfs/Em/PD/04_pv/data/layout_files/RAMSP4096X16.gds2 \
    -in /mnt/hgfs/Em/PD/04_pv/data/layout_files/RAMTP1024X16.gds2 \
    -in /mnt/hgfs/Em/PD/04_pv/data/layout_files/RAMTP128X16.gds2 \
-out ./top_merge.gds


