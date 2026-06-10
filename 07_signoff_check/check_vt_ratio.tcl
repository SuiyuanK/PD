set lvt_insts [get_object_name [get_cells -physical_context * -filter "ref_name =~ *12TL* && is_physical_only == false"]]
set rvt_insts [get_object_name [get_cells -physical_context * -filter "ref_name =~ *12TR* && is_physical_only == false"]]
set hvt_insts [get_object_name [get_cells -physical_context * -filter "ref_name =~ *12TH* && is_physical_only == false"]]


set lvt_count [llength $lvt_insts]
set rvt_count [llength $rvt_insts]
set hvt_count [llength $hvt_insts]

set lvt_area 0
foreach lvt $lvt_insts {
    set area [get_attr [get_cells $lvt] area]
    set lvt_area [expr $lvt_area + $area]
}

set rvt_area 0
foreach rvt $rvt_insts {
    set area [get_attr [get_cells $rvt] area]
    set rvt_area [expr $rvt_area + $area]
}
set hvt_area 0
foreach hvt $hvt_insts {
    set area [get_attr [get_cells $hvt] area]
    set hvt_area [expr $hvt_area + $area]
}

echo "LVT inst count: $lvt_count"
echo "RVT inst count: $rvt_count"
echo "HVT inst count: $hvt_count"
echo "LVT inst area: $lvt_area"
echo "RVT inst area: $rvt_area"
echo "HVT inst area: $hvt_area"