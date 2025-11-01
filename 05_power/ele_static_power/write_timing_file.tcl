source /export/SoftWare/Ansys/Redhawk2021/RedHawk_Linux64e6_V2021R1.1/bin/pt2timing.tcl

set ADS_ALLOWED_PCT_OF_NON_CLOCKED_REGISTERS 30

getSTA * -b -output data/image_process

