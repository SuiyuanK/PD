################################################################################
#
# Created by icc2 write_floorplan on Wed Nov 12 23:50:35 2025
#
################################################################################


set _dirName__0 [file dirname [file normalize [info script]]]

################################################################################
# Cells
################################################################################

set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_31__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 141.7850 331.7900 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_31__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_31__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 278.5500 331.7900 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_31__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_30__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 141.7850 164.4150 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_30__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_30__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 552.0800 331.7900 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_30__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_29__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 825.6100 841.4750 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_29__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_29__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 688.8450 841.4750 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_29__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_28__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 962.3750 841.4750 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_28__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_28__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 415.3150 499.1650 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_28__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_27__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 278.5500 499.1650 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_27__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_27__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 1235.9050 841.4750 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_27__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_26__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1235.9050 666.5400 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_26__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_26__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 1235.9050 674.1000 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_26__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_25__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MYR90
set_attribute -quiet -objects $cellInst -name origin -value { 116.1350 499.1650 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_25__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_25__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 278.5500 164.4150 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_25__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_24__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 552.0800 164.4150 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_24__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_24__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 116.1350 841.4750 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_24__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_23__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1235.9050 499.1650 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_23__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_23__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 962.3750 499.1650 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_23__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_22__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 552.0800 841.4750 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_22__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_22__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 278.5500 841.4750 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_22__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_21__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 552.0800 499.1650 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_21__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_21__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 141.7850 499.1650 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_21__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_20__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 141.7850 1008.8500 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_20__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_20__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MYR90
set_attribute -quiet -objects $cellInst -name origin -value { 116.1350 666.5400 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_20__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_19__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 415.3150 164.4150 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_19__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_19__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 415.3150 331.7900 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_19__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_18__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 1099.1400 841.4750 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_18__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_18__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1099.1400 499.1650 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_18__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_17__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 825.6100 499.1650 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_17__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_17__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 415.3150 841.4750 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_17__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_16__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 141.7850 841.4750 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_16__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_16__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 688.8450 499.1650 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_16__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_15__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 825.6100 1008.8500 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_15__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_15__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 552.0800 1008.8500 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_15__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_14__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 116.1350 1008.8500 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_14__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_14__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 1235.9050 1008.8500 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_14__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_13__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 1099.1400 1008.8500 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_13__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_13__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 116.1350 674.1000 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_13__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_12__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 688.8450 331.7900 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_12__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_12__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 825.6100 331.7900 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_12__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_11__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 415.3150 1176.2250 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_11__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_11__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 278.5500 1008.8500 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_11__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_10__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 1235.9050 1176.2250 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_10__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_10__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 962.3750 1176.2250 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_10__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_9__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MYR90
set_attribute -quiet -objects $cellInst -name origin -value { 116.1350 164.4150 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_9__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_9__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1235.9050 164.4150 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_9__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_8__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1099.1400 164.4150 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_8__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_8__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 962.3750 164.4150 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_8__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_7__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 825.6100 164.4150 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_7__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_7__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 688.8450 164.4150 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_7__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_6__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 415.3150 1008.8500 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_6__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_6__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 278.5500 1176.2250 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_6__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_5__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 141.7850 1176.2250 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_5__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_5__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1235.9050 331.7900 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_5__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_4__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1099.1400 331.7900 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_4__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_4__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 962.3750 331.7900 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_4__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_3__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 552.0800 1176.2250 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_3__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_3__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MYR90
set_attribute -quiet -objects $cellInst -name origin -value { 116.1350 331.7900 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_3__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_2__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 688.8450 1176.2250 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_2__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_2__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 825.6100 1176.2250 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_2__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_1__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 1099.1400 1176.2250 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_1__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_1__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 688.8450 1008.8500 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_1__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_0__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 116.1350 1176.2250 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_0__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_0__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 962.3750 1008.8500 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_0__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_VIP_horizon_projection_u_projection_ram_u_projection_ram }]
set_attribute -quiet -objects $cellInst -name orientation -value MYR90
set_attribute -quiet -objects $cellInst -name origin -value { 252.9000 605.4550 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_VIP_horizon_projection_u_projection_ram_u_projection_ram }


set cellInst [get_cells { u_axi_image_top/u_image_process_u_VIP_Char_Divide_u_VIP_vertical_projection_char_u_projection_ram_u_projection_ram }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 962.5450 629.1550 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_image_process_u_VIP_Char_Divide_u_VIP_vertical_projection_char_u_projection_ram_u_projection_ram }


set cellInst [get_cells { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_VIP_vertical_projection_u_projection_ram_u_projection_ram }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1099.3100 605.4550 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_VIP_vertical_projection_u_projection_ram_u_projection_ram }


set cellInst [get_cells { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_VIP_Bit_Erosion_Detector_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_0_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 1099.3100 629.1550 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_VIP_Bit_Erosion_Detector_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_0_u_ram_1024x8_0 }


set cellInst [get_cells { u_axi_image_top/u_image_process_u_VIP_Char_Divide_u_VIP_Bit_Dilation_Detector_red_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_1_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 252.9000 735.3150 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_image_process_u_VIP_Char_Divide_u_VIP_Bit_Dilation_Detector_red_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_1_u_ram_1024x8_0 }


set cellInst [get_cells { u_axi_image_top/u_image_process_u_VIP_Char_Divide_u_VIP_Bit_Dilation_Detector_red_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_0_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 825.7800 735.3150 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_image_process_u_VIP_Char_Divide_u_VIP_Bit_Dilation_Detector_red_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_0_u_ram_1024x8_0 }


set cellInst [get_cells { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_Sobel_Edge_Detector_u_matrix_generate_3x3_8bit_u_line_shift_ram_8bit_u_ram_1024x8_1_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 252.9000 629.1550 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_Sobel_Edge_Detector_u_matrix_generate_3x3_8bit_u_line_shift_ram_8bit_u_ram_1024x8_1_u_ram_1024x8_0 }


set cellInst [get_cells { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_Sobel_Edge_Detector_u_matrix_generate_3x3_8bit_u_line_shift_ram_8bit_u_ram_1024x8_0_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 389.6650 629.1550 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_Sobel_Edge_Detector_u_matrix_generate_3x3_8bit_u_line_shift_ram_8bit_u_ram_1024x8_0_u_ram_1024x8_0 }


set cellInst [get_cells { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_VIP_Bit_Erosion_Detector_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_1_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 1099.3100 735.3150 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_VIP_Bit_Erosion_Detector_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_1_u_ram_1024x8_0 }


set cellInst [get_cells { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_VIP_Bit_Dilation_Detector_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_0_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 962.5450 735.3150 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_VIP_Bit_Dilation_Detector_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_0_u_ram_1024x8_0 }


set cellInst [get_cells { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_VIP_Bit_Dilation_Detector_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_1_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 389.6650 735.3150 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_VIP_Bit_Dilation_Detector_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_1_u_ram_1024x8_0 }


set cellInst [get_cells { u_axi_image_top/u_image_process_u_VIP_Char_Divide_u_VIP_Bit_Erosion_Detector_red_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_0_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value MYR90
set_attribute -quiet -objects $cellInst -name origin -value { 389.6650 605.4550 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_image_process_u_VIP_Char_Divide_u_VIP_Bit_Erosion_Detector_red_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_0_u_ram_1024x8_0 }


set cellInst [get_cells { u_axi_image_top/u_image_process_u_VIP_Char_Divide_u_VIP_Bit_Erosion_Detector_red_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_1_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 962.5450 605.4550 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_image_process_u_VIP_Char_Divide_u_VIP_Bit_Erosion_Detector_red_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_1_u_ram_1024x8_0 }



