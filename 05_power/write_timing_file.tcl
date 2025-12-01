pt_shell
source /export/SoftWare/Ansys/Redhawk2021/RedHawk_Linux64e6_V2021R1.1/bin/pt2timing.tcl

set ADS_ALLOWED_PCT_OF_NON_CLOCKED_REGISTERS 30

restore_session ../03_pt/sta/func.ss0p99v.typ_m40c/func.ss0p99v.typ_m40c
getSTA * -b -output data/image_icb_ss0p99v_typ_m40c.timing

pt_shell
source /export/SoftWare/Ansys/Redhawk2021/RedHawk_Linux64e6_V2021R1.1/bin/pt2timing.tcl

set ADS_ALLOWED_PCT_OF_NON_CLOCKED_REGISTERS 30

restore_session ../03_pt/sta/func.ff1p21v.typ_125c.hold/func.ff1p21v.typ_125c.hold
getSTA * -b -output data/image_icb_ff1p21v_typ_125c.timing