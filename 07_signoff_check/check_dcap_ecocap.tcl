change_selection [get_cells *ECOCAP*]
change_selection [get_cells *DCAP*]
change_selection [get_cells *FILLTIE*]
change_selection [get_cells *F_FILL*]
change_selection [get_flat_cells "*eco_cell*"]
change_selection [get_cells -physical_context * -filter "is_physical_only == false"]

change_selection [get_flat_cells * -filter is_hard_macro==true]