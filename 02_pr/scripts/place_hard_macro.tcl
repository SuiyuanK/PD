################################################################################
#
# Created by icc2 write_floorplan on Wed Nov 12 23:12:28 2025
#
################################################################################


set _dirName__0 [file dirname [file normalize [info script]]]

################################################################################
# Cells
################################################################################

set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_31__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 141.7850 328.0100 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_31__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_31__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 278.5500 328.0100 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_31__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_30__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 141.7850 163.1550 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_30__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_30__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 552.0800 328.0100 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_30__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_29__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 825.6100 827.6150 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_29__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_29__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 688.8450 827.6150 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_29__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_28__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 962.3750 827.6150 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_28__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_28__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 415.3150 492.8650 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_28__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_27__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 278.5500 492.8650 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_27__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_27__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 1235.9050 827.6150 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_27__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_26__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1235.9050 657.7200 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_26__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_26__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 1235.9050 662.7600 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_26__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_25__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MYR90
set_attribute -quiet -objects $cellInst -name origin -value { 116.1350 492.8650 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_25__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_25__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 278.5500 163.1550 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_25__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_24__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 552.0800 163.1550 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_24__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_24__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 116.1350 827.6150 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_24__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_23__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1235.9050 492.8650 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_23__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_23__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 962.3750 492.8650 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_23__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_22__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 552.0800 827.6150 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_22__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_22__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 278.5500 827.6150 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_22__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_21__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 552.0800 492.8650 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_21__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_21__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 141.7850 492.8650 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_21__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_20__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 141.7850 992.4700 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_20__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_20__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MYR90
set_attribute -quiet -objects $cellInst -name origin -value { 116.1350 657.7200 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_20__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_19__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 415.3150 163.1550 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_19__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_19__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 415.3150 328.0100 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_19__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_18__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 1099.1400 827.6150 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_18__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_18__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1099.1400 492.8650 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_18__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_17__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 825.6100 492.8650 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_17__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_17__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 415.3150 827.6150 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_17__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_16__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 141.7850 827.6150 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_16__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_16__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 688.8450 492.8650 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_16__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_15__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 825.6100 992.4700 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_15__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_15__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 552.0800 992.4700 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_15__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_14__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 116.1350 992.4700 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_14__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_14__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 1235.9050 992.4700 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_14__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_13__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 1099.1400 992.4700 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_13__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_13__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 116.1350 662.7600 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_13__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_12__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 688.8450 328.0100 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_12__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_12__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 825.6100 328.0100 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_12__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_11__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 415.3150 1157.3250 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_11__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_11__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 278.5500 992.4700 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_11__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_10__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 1235.9050 1157.3250 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_10__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_10__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 962.3750 1157.3250 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_10__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_9__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MYR90
set_attribute -quiet -objects $cellInst -name origin -value { 116.1350 163.1550 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_9__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_9__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1235.9050 163.1550 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_9__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_8__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1099.1400 163.1550 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_8__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_8__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 962.3750 163.1550 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_8__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_7__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 825.6100 163.1550 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_7__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_7__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 688.8450 163.1550 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_7__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_6__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 415.3150 992.4700 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_6__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_6__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 278.5500 1157.3250 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_6__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_5__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 141.7850 1157.3250 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_5__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_5__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1235.9050 328.0100 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_5__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_4__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1099.1400 328.0100 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_4__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_4__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 962.3750 328.0100 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_4__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_3__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 552.0800 1157.3250 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_3__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_3__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MYR90
set_attribute -quiet -objects $cellInst -name origin -value { 116.1350 328.0100 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_3__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_2__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 688.8450 1157.3250 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_2__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_2__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 825.6100 1157.3250 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_2__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_1__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 1099.1400 1157.3250 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_1__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_1__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 688.8450 992.4700 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_1__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_0__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 116.1350 1157.3250 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_0__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_0__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 962.3750 992.4700 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_sram_ram_inst_0__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_VIP_horizon_projection_u_projection_ram_u_projection_ram }]
set_attribute -quiet -objects $cellInst -name orientation -value MYR90
set_attribute -quiet -objects $cellInst -name origin -value { 252.9000 659.7490 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_VIP_horizon_projection_u_projection_ram_u_projection_ram }


set cellInst [get_cells { u_axi_image_top/u_image_process_u_VIP_Char_Divide_u_VIP_vertical_projection_char_u_projection_ram_u_projection_ram }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 962.5450 660.7310 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_image_process_u_VIP_Char_Divide_u_VIP_vertical_projection_char_u_projection_ram_u_projection_ram }


set cellInst [get_cells { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_VIP_vertical_projection_u_projection_ram_u_projection_ram }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1099.3100 659.7490 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_VIP_vertical_projection_u_projection_ram_u_projection_ram }


set cellInst [get_cells { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_VIP_Bit_Erosion_Detector_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_0_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 1099.3100 660.7310 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_VIP_Bit_Erosion_Detector_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_0_u_ram_1024x8_0 }


set cellInst [get_cells { u_axi_image_top/u_image_process_u_VIP_Char_Divide_u_VIP_Bit_Dilation_Detector_red_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_1_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 252.9000 744.1730 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_image_process_u_VIP_Char_Divide_u_VIP_Bit_Dilation_Detector_red_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_1_u_ram_1024x8_0 }


set cellInst [get_cells { u_axi_image_top/u_image_process_u_VIP_Char_Divide_u_VIP_Bit_Dilation_Detector_red_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_0_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value MYR90
set_attribute -quiet -objects $cellInst -name origin -value { 252.9000 576.3070 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_image_process_u_VIP_Char_Divide_u_VIP_Bit_Dilation_Detector_red_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_0_u_ram_1024x8_0 }


set cellInst [get_cells { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_Sobel_Edge_Detector_u_matrix_generate_3x3_8bit_u_line_shift_ram_8bit_u_ram_1024x8_1_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 252.9000 660.7310 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_Sobel_Edge_Detector_u_matrix_generate_3x3_8bit_u_line_shift_ram_8bit_u_ram_1024x8_1_u_ram_1024x8_0 }


set cellInst [get_cells { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_Sobel_Edge_Detector_u_matrix_generate_3x3_8bit_u_line_shift_ram_8bit_u_ram_1024x8_0_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 962.5450 576.3070 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_Sobel_Edge_Detector_u_matrix_generate_3x3_8bit_u_line_shift_ram_8bit_u_ram_1024x8_0_u_ram_1024x8_0 }


set cellInst [get_cells { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_VIP_Bit_Erosion_Detector_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_1_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 1099.3100 744.1730 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_VIP_Bit_Erosion_Detector_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_1_u_ram_1024x8_0 }


set cellInst [get_cells { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_VIP_Bit_Dilation_Detector_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_0_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 962.5450 744.1730 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_VIP_Bit_Dilation_Detector_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_0_u_ram_1024x8_0 }


set cellInst [get_cells { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_VIP_Bit_Dilation_Detector_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_1_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 389.6650 744.1730 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_VIP_Bit_Dilation_Detector_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_1_u_ram_1024x8_0 }


set cellInst [get_cells { u_axi_image_top/u_image_process_u_VIP_Char_Divide_u_VIP_Bit_Erosion_Detector_red_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_0_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1099.3100 576.3070 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_image_process_u_VIP_Char_Divide_u_VIP_Bit_Erosion_Detector_red_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_0_u_ram_1024x8_0 }


set cellInst [get_cells { u_axi_image_top/u_image_process_u_VIP_Char_Divide_u_VIP_Bit_Erosion_Detector_red_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_1_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 962.5450 659.7490 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 5.0200 2.5200 5.0200 2.5200 } { u_axi_image_top/u_image_process_u_VIP_Char_Divide_u_VIP_Bit_Erosion_Detector_red_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_1_u_ram_1024x8_0 }



