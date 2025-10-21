create_workspace -flow aggregate aa12345aa

read_ndm ./aa12345aa_ff_1p_c.ndm
read_ndm ./aa12345aa_ss_c.ndm
read_ndm ./aa12345aa_tt_1p_25c.ndm
get_libs

set_lib_order {aa12345aa_tt_1p_25c aa12345aa_ff_1p_c aa12345aa_ss_c}

check_workspace
commit_workspace 
remove_workspace

exit
set_process -libraries aa12aa_ff_1p10v_1p10v_125c -label ff -number 1.1
set_process -libraries aa12aa_ff_1p21v_1p21v_125c -label ff -number 1.21
set_process -libraries aa12aa_ff_1p26v_1p26v_125c -label ff -number 1.26
set_process -libraries aa12aa_ff_1p10v_1p10v_m40c -label ff -number 1.1
set_process -libraries aa12aa_ff_1p21v_1p21v_m40c -label ff -number 1.21
set_process -libraries aa12aa_ff_1p26v_1p26v_m40c -label ff -number 1.26

set_process -libraries aa12aa_ss_0p90v_0p90v_125c -label ss -number 0.9
set_process -libraries aa12aa_ss_0p99v_0p99v_125c -label ss -number 0.99
set_process -libraries aa12aa_ss_1p08v_1p08v_125c -label ss -number 1.08
set_process -libraries aa12aa_ss_0p90v_0p90v_m40c -label ss -number 0.9
set_process -libraries aa12aa_ss_0p99v_0p99v_m40c -label ss -number 0.99
set_process -libraries aa12aa_ss_1p08v_1p08v_m40c -label ss -number 1.08

set_process -libraries aa12aa_tt_1p00v_1p00v_125c -label tt -number 1
set_process -libraries aa12aa_tt_1p10v_1p10v_125c -label tt -number 1.1
set_process -libraries aa12aa_tt_1p20v_1p20v_125c -label tt -number 1.2
set_process -libraries aa12aa_tt_1p00v_1p00v_25c  -label tt -number 1
set_process -libraries aa12aa_tt_1p10v_1p10v_25c  -label tt -number 1.1
set_process -libraries aa12aa_tt_1p20v_1p20v_25c  -label tt -number 1.2