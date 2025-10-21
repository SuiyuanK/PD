set current_step "icw_merge_cells"
set design       "top"

set chipfinish_layout_id [layout open ../data/pr_outputs/*.gds.gz ?]
# dbu: database unit
set original_dbu [layout dbu -layout $chipfinish_layout_id]
set input_layouts "\"layout $chipfinish_layout_id {cell $design} \""

set merge_layouts ""
set layout_files  [glob ../data/layout_files/*gds*]
foreach layout $layout_files {
    puts "Information: Opening layout file ${layout}"
    set cell_layout_id [layout open $layout]
    set merge_layouts "${merge_layouts} \"layout ${cell_layout_id}\""
}

cell edit_state 1 -layout $chipfinish_layout_id

set cmd "layout merge extract ${input_layouts} ${merge_layouts} -dbu ${original_dbu} -format gds -output ../data/${design}_${current_step}.gds"
eval $cmd
exit    

