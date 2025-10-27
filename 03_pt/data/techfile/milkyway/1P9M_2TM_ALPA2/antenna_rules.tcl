## Antenna TCL file for IC Compiler
#
#     Copyright (c) 2016 ARM, Inc.
#
#     ALL RIGHTS RESERVED
#
#     The confidential and proprietary information contained in this file
#     may only be used by a person authorised under and to the extent
#     permitted by a subsisting licensing agreement from ARM Limited.
#
#     This entire notice must be reproduced on all copies of this file
#     and copies of this file may only be made by a person if such person
#     is permitted to do so under the terms of a subsisting license
#     agreement from ARM Limited.

set lib [current_mw_lib]
remove_antenna_rules $lib

define_antenna_rule $lib -mode 2 -diode_mode 4 -metal_ratio 0 -cut_ratio 0
define_antenna_layer_rule $lib -mode 2 -layer "M1" -ratio 5000.0 -diode_ratio {0.0 0.0 500.0 44000.0}
define_antenna_rule $lib -mode 1 -diode_mode 4 -metal_ratio 0 -cut_ratio 0
define_antenna_layer_rule $lib -mode 1 -layer "V1" -ratio 20.0 -diode_ratio {0.0 0.0 200.0 0.0}
define_antenna_layer_rule $lib -mode 2 -layer "V1" -ratio 50.0 -diode_ratio {0.0 0.0 200.0 1000.0}
define_antenna_layer_rule $lib -mode 2 -layer "M2" -ratio 5000.0 -diode_ratio {0.0 0.0 500.0 44000.0}
define_antenna_layer_rule $lib -mode 1 -layer "V2" -ratio 20.0 -diode_ratio {0.0 0.0 200.0 0.0}
define_antenna_layer_rule $lib -mode 2 -layer "V2" -ratio 50.0 -diode_ratio {0.0 0.0 200.0 1000.0}
define_antenna_layer_rule $lib -mode 2 -layer "M3" -ratio 5000.0 -diode_ratio {0.0 0.0 500.0 44000.0}
define_antenna_layer_rule $lib -mode 1 -layer "V3" -ratio 20.0 -diode_ratio {0.0 0.0 200.0 0.0}
define_antenna_layer_rule $lib -mode 2 -layer "V3" -ratio 50.0 -diode_ratio {0.0 0.0 200.0 1000.0}
define_antenna_layer_rule $lib -mode 2 -layer "M4" -ratio 5000.0 -diode_ratio {0.0 0.0 500.0 44000.0}
define_antenna_layer_rule $lib -mode 1 -layer "V4" -ratio 20.0 -diode_ratio {0.0 0.0 200.0 0.0}
define_antenna_layer_rule $lib -mode 2 -layer "V4" -ratio 50.0 -diode_ratio {0.0 0.0 200.0 1000.0}
define_antenna_layer_rule $lib -mode 2 -layer "M5" -ratio 5000.0 -diode_ratio {0.0 0.0 500.0 44000.0}
define_antenna_layer_rule $lib -mode 1 -layer "V5" -ratio 20.0 -diode_ratio {0.0 0.0 200.0 0.0}
define_antenna_layer_rule $lib -mode 2 -layer "V5" -ratio 50.0 -diode_ratio {0.0 0.0 200.0 1000.0}
define_antenna_layer_rule $lib -mode 2 -layer "M6" -ratio 5000.0 -diode_ratio {0.0 0.0 500.0 44000.0}
define_antenna_layer_rule $lib -mode 1 -layer "V6" -ratio 20.0 -diode_ratio {0.0 0.0 200.0 0.0}
define_antenna_layer_rule $lib -mode 2 -layer "V6" -ratio 50.0 -diode_ratio {0.0 0.0 200.0 1000.0}
define_antenna_layer_rule $lib -mode 2 -layer "M7" -ratio 5000.0 -diode_ratio {0.0 0.0 500.0 44000.0}
define_antenna_layer_rule $lib -mode 1 -layer "TV1" -ratio 20.0 -diode_ratio {0.0 0.0 200.0 0.0}
define_antenna_layer_rule $lib -mode 2 -layer "TV1" -ratio 50.0 -diode_ratio {0.0 0.0 200.0 1000.0}
define_antenna_layer_rule $lib -mode 1 -layer "TM1" -ratio 5000.0 -diode_ratio {0.0 0.0 9984.0 55000.0}
define_antenna_layer_rule $lib -mode 2 -layer "TM1" -ratio 5000.0 -diode_ratio {0.0 0.0 0.0 0.0}
define_antenna_layer_rule $lib -mode 1 -layer "TV2" -ratio 20.0 -diode_ratio {0.0 0.0 200.0 0.0}
define_antenna_layer_rule $lib -mode 2 -layer "TV2" -ratio 50.0 -diode_ratio {0.0 0.0 200.0 1000.0}
define_antenna_layer_rule $lib -mode 1 -layer "TM2" -ratio 5000.0 -diode_ratio {0.0 0.0 9984.0 55000.0}
define_antenna_layer_rule $lib -mode 2 -layer "TM2" -ratio 5000.0 -diode_ratio {0.0 0.0 0.0 0.0}
define_antenna_layer_rule $lib -mode 1 -layer "PA" -ratio 200.0 -diode_ratio {0.0 0.0 100.0 400.0}
define_antenna_rule $lib -mode 5 -diode_mode 4 -metal_ratio 0 -cut_ratio 0
define_antenna_layer_rule $lib -mode 5 -layer "ALPA" -ratio 1000.0 -diode_ratio {0.0 0.0 8500.0 30000.0}
