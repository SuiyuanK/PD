################################################################################
#
# Created by icc2 write_floorplan on Wed Nov 12 14:54:42 2025
#
################################################################################


set _dirName__0 [file dirname [file normalize [info script]]]

################################################################################
# Cells
################################################################################

set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_31__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 140.1150 331.6300 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_31__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_31__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 276.2300 331.6300 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_31__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_30__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 140.1150 163.8150 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_30__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_30__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 548.4600 331.6300 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_30__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_29__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 820.6900 843.0750 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_29__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_29__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 684.5750 843.0750 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_29__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_28__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 956.8050 843.0750 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_28__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_28__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 412.3450 499.4450 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_28__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_27__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 276.2300 499.4450 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_27__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_27__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 1229.1350 843.0750 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_27__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_26__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1229.1350 667.2600 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_26__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_26__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 1229.1350 675.2600 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_26__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_25__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 956.8050 667.2600 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_25__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_25__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 276.2300 163.8150 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_25__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_24__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 548.4600 163.8150 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_24__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_24__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 956.8050 675.2600 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_24__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_23__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1229.1350 499.4450 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_23__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_23__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 956.8050 499.4450 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_23__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_22__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 548.4600 843.0750 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_22__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_22__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 276.2300 843.0750 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_22__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_21__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 548.4600 499.4450 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_21__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_21__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 140.1150 499.4450 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_21__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_20__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 140.1150 1010.8900 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_20__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_20__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1092.9200 667.2600 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_20__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_19__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 412.3450 163.8150 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_19__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_19__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 412.3450 331.6300 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_19__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_18__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 1092.9200 843.0750 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_18__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_18__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1092.9200 499.4450 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_18__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_17__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 820.6900 499.4450 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_17__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_17__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 412.3450 843.0750 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_17__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_16__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 140.1150 843.0750 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_16__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_16__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 684.5750 499.4450 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_16__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_15__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 820.6900 1010.8900 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_15__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_15__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 548.4600 1010.8900 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_15__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_14__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 115.1150 1010.8900 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_14__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_14__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 1229.1350 1010.8900 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_14__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_13__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 1092.9200 1010.8900 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_13__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_13__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 1092.9200 675.2600 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_13__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_12__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 684.5750 331.6300 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_12__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_12__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 820.6900 331.6300 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_12__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_11__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 412.3450 1178.7050 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_11__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_11__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 276.2300 1010.8900 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_11__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_10__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 1229.1350 1178.7050 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_10__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_10__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 956.8050 1178.7050 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_10__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_9__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MYR90
set_attribute -quiet -objects $cellInst -name origin -value { 115.1150 163.8150 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_9__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_9__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1229.1350 163.8150 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_9__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_8__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1092.9200 163.8150 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_8__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_8__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 956.8050 163.8150 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_8__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_7__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 820.6900 163.8150 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_7__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_7__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 684.5750 163.8150 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_7__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_6__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 412.3450 1010.8900 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_6__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_6__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 276.2300 1178.7050 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_6__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_5__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 140.1150 1178.7050 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_5__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_5__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1229.1350 331.6300 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_5__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_4__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 1092.9200 331.6300 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_4__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_4__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 956.8050 331.6300 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_4__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_3__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 548.4600 1178.7050 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_3__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_3__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MYR90
set_attribute -quiet -objects $cellInst -name origin -value { 115.1150 331.6300 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_3__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_2__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 684.5750 1178.7050 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_2__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_2__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 820.6900 1178.7050 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_2__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_1__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 1092.9200 1178.7050 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_1__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_1__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 684.5750 1010.8900 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_1__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_0__u2_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 115.1150 1178.7050 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_0__u2_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_sram_ram_inst_0__u1_RAMTP1024X16_rtl_top }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 956.8050 1010.8900 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_sram_ram_inst_0__u1_RAMTP1024X16_rtl_top }


set cellInst [get_cells { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_VIP_horizon_projection_u_projection_ram_u_projection_ram }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 548.6300 672.7680 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_VIP_horizon_projection_u_projection_ram_u_projection_ram }


set cellInst [get_cells { u_axi_image_top/u_image_process_u_VIP_Char_Divide_u_VIP_vertical_projection_char_u_projection_ram_u_projection_ram }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 684.7450 584.7060 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_image_process_u_VIP_Char_Divide_u_VIP_vertical_projection_char_u_projection_ram_u_projection_ram }


set cellInst [get_cells { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_VIP_vertical_projection_u_projection_ram_u_projection_ram }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 820.8600 669.9670 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_VIP_vertical_projection_u_projection_ram_u_projection_ram }


set cellInst [get_cells { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_VIP_Bit_Erosion_Detector_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_0_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 820.8600 672.7680 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_VIP_Bit_Erosion_Detector_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_0_u_ram_1024x8_0 }


set cellInst [get_cells { u_axi_image_top/u_image_process_u_VIP_Char_Divide_u_VIP_Bit_Dilation_Detector_red_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_1_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 548.6300 584.7060 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_image_process_u_VIP_Char_Divide_u_VIP_Bit_Dilation_Detector_red_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_1_u_ram_1024x8_0 }


set cellInst [get_cells { u_axi_image_top/u_image_process_u_VIP_Char_Divide_u_VIP_Bit_Dilation_Detector_red_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_0_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 548.6300 758.0290 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_image_process_u_VIP_Char_Divide_u_VIP_Bit_Dilation_Detector_red_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_0_u_ram_1024x8_0 }


set cellInst [get_cells { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_Sobel_Edge_Detector_u_matrix_generate_3x3_8bit_u_line_shift_ram_8bit_u_ram_1024x8_1_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 548.6300 669.9670 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_Sobel_Edge_Detector_u_matrix_generate_3x3_8bit_u_line_shift_ram_8bit_u_ram_1024x8_1_u_ram_1024x8_0 }


set cellInst [get_cells { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_Sobel_Edge_Detector_u_matrix_generate_3x3_8bit_u_line_shift_ram_8bit_u_ram_1024x8_0_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 412.5150 589.9050 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_Sobel_Edge_Detector_u_matrix_generate_3x3_8bit_u_line_shift_ram_8bit_u_ram_1024x8_0_u_ram_1024x8_0 }


set cellInst [get_cells { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_VIP_Bit_Erosion_Detector_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_1_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 820.8600 758.0290 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_VIP_Bit_Erosion_Detector_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_1_u_ram_1024x8_0 }


set cellInst [get_cells { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_VIP_Bit_Dilation_Detector_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_0_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 684.7450 758.0290 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_VIP_Bit_Dilation_Detector_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_0_u_ram_1024x8_0 }


set cellInst [get_cells { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_VIP_Bit_Dilation_Detector_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_1_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 684.7450 672.7680 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_image_process_u_VIP_Plate_Locate_u_VIP_Bit_Dilation_Detector_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_1_u_ram_1024x8_0 }


set cellInst [get_cells { u_axi_image_top/u_image_process_u_VIP_Char_Divide_u_VIP_Bit_Erosion_Detector_red_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_0_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 820.8600 584.7060 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_image_process_u_VIP_Char_Divide_u_VIP_Bit_Erosion_Detector_red_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_0_u_ram_1024x8_0 }


set cellInst [get_cells { u_axi_image_top/u_image_process_u_VIP_Char_Divide_u_VIP_Bit_Erosion_Detector_red_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_1_u_ram_1024x8_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 684.7450 669.9670 }
set_attribute -quiet -objects $cellInst -name status -value placed
create_keepout_margin -type hard -outer { 4.0000 4.0000 4.0000 4.0000 } { u_axi_image_top/u_image_process_u_VIP_Char_Divide_u_VIP_Bit_Erosion_Detector_red_u_matrix_generate_3x3_1bit_u_line_shift_ram_8bit_u_ram_1024x8_1_u_ram_1024x8_0 }



