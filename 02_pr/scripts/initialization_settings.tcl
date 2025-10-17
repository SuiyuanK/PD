### initialization settings for icc2
## time unit needs to match with SDC

# source data/techfile/milkyway/1P8M_2TM_ALPA2/icc_route_options.tcl
# read_tech_lef -merge_action update data/techfile/lef/1P8M_2TM_ALPA2/sc12mc_tech.lef
source data/techfile/milkyway/1P8M_2TM_ALPA2/antenna_rules.tcl
connect_pg_net  -all_blocks -automatic
set_app_options -list {
  route.common.connect_within_pins_by_layer_name {
    {M1 via_standard_cell_pins} 
  }
}
set_app_options -name route.common.net_min_layer_mode -value allow_pin_connection
remove_via_mappings -all
add_via_mapping -from_icc_file data/techfile/milkyway/1P8M_2TM_ALPA2/icc_route_options.tcl

set_user_units -type time -value 1ns

# set_attribute [get_site_defs unit] symmetry Y
# set_attribute [get_site_defs unit] is_default true

get_layers -filter "is_routing_layer==true"
set_attribute [get_layers {M1 M3 M5 TM1 ALPA}] routing_direction vertical
set_attribute [get_layers {GT M2 M4 M6 TM2}] routing_direction horizontal
get_attribute [get_layers {GT M? TM? ALPA}] routing_direction

set_ignored_layers -max_routing_layer M6
set_ignored_layers -min_routing_layer M1


