# $Revision: 1.145 $

#########################################################################
#
# Apache Design Solutions, Inc.
#
# Copyright 2007 Apache Design Solutions, Inc.
# All rights reserved.
#
# Revision history
#
# - Created by Bhavana Thudi 11-12-2007
# - Initial version
#
#########################################################################
proc atclPrintMissingData_manpage {} {
        puts "
SYNOPSIS
        TCL command to print missing data
USAGE
        atclPrintMissingData

        Options:
	None
"
}



proc atclPrintMissingData {} {

  set lib_count 0
  if { [file exists "adsRpt/apache.refCell.noLib"] } {
    set lib [ open "adsRpt/apache.refCell.noLib" r ]
    foreach line [split [read -nonewline $lib] \n] {
	if { ![regexp ^# $line] } {
	  set lib_count [expr $lib_count+1]
        }
    }
  }

  puts "Library physical(LEF)/electrical(LIB) definitions:"
  puts "Number of cells in design with no LIB definition: $lib_count"

  set lef_count 0
  if { [file exists "adsRpt/apache.refCell.noLef"] } {
    set lef [ open "adsRpt/apache.refCell.noLef" r ]
    foreach line [split [read -nonewline $lef] \n] {
        if { ![regexp ^# $line] } {
          set lef_count [expr $lef_count+1]
        }
    }
  }
  puts "Number of cells in design with no LEF definition: $lef_count"

  set leflib_count 0
  if { [file exists "adsRpt/apache.refCell.noLefLib"] } {
    set leflib [ open "adsRpt/apache.refCell.noLefLib" r ]
    foreach line [split [read -nonewline $leflib] \n] {
        if { ![regexp ^# $line] } {
          set leflib_count [expr $leflib_count+1]
        }
    }
  }
  puts "Number of cells in design with no LEF and LIB definition: $leflib_count"

  set pwrgndpin_count 0
  if { [file exists "adsRpt/apache.refCell.noPwrGndPins"] } {
    set pwrgndpin [ open "adsRpt/apache.refCell.noPwrGndPins" r ]
    foreach line [split [read -nonewline $pwrgndpin] \n] {
        if { ![regexp ^# $line] } {
          set pwrgndpin_count [expr $pwrgndpin_count+1]
        }
    }
  }
  puts "Number of cells in design with no PWR/GND pin definition in LEF: $pwrgndpin_count"

  set lefpin_count 0
  if { [file exists "adsRpt/apache.refCell.noLefPins"] } {
    set lefpin [ open "adsRpt/apache.refCell.noLefPins" r ]
    foreach line [split [read -nonewline $lefpin] \n] {
        if { ![regexp ^# $line] } {
          set lefpin_count [expr $lefpin_count+1]
        }
    }
  }
  puts "Number of cells in design with no pin definition in LEF: $lefpin_count"


  set libpin_count 0
  if { [file exists "adsRpt/apache.refCell.noLibPins"] } {
    set libpin [ open "adsRpt/apache.refCell.noLibPins" r ]
    foreach line [split [read -nonewline $libpin] \n] {
        if { ![regexp ^# $line] } {
          set libpin_count [expr $libpin_count+1]
        }
    }
  }
  puts "Number of cells in design with no pin definition in LIB: $libpin_count"


  set pwr_count 0
  if { [file exists "adsRpt/apache.refCell.noPwr"] } {
    set pwr [ open "adsRpt/apache.refCell.noPwr" r ]
    foreach line [split [read -nonewline $pwr] \n] {
        if { ![regexp ^# $line] } {
          set pwr_count [expr $pwr_count+1]
        }
    }
  }
  puts "Number of cells in design with no power tables in LIB: $pwr_count"

  set edge_count 0
  if { [file exists "adsRpt/apache.refCell.noTriggerEdge"] } {
    set edge [ open "adsRpt/apache.refCell.noTriggerEdge" r ]
    foreach line [split [read -nonewline $edge] \n] {
        if { ![regexp ^# $line] } {
          set edge_count [expr $edge_count+1]
        }
    }
  }
  puts "Number of cells in design with no trigger edge defined in LIB: $edge_count"

  set apl_count 0
  if { [file exists "adsRpt/apache.refCell.noAplCurrent"] } {
    set apl [ open "adsRpt/apache.refCell.noAplCurrent" r ]
    foreach line [split [read -nonewline $apl] \n] {
        if { ![regexp ^# $line] } {
          set apl_count [expr $apl_count+1]
        }
    }
  }
  puts "\nApache Power Library definitions:"
  puts "Number of cells in design with no APL current library: $apl_count"

  set aplcap_count 0
  if { [file exists "adsRpt/apache.refCell.noAplCap"] } {
    set aplcap [ open "adsRpt/apache.refCell.noAplCap" r ]
    foreach line [split [read -nonewline $aplcap] \n] {
        if { ![regexp ^# $line] } {
          set aplcap_count [expr $aplcap_count+1]
        }
    }
  }
  puts "Number of cells in design with no APL capacitance library: $aplcap_count"

  set aplpwcap_count 0
  if { [file exists "adsRpt/apache.refCell.noAplPwcap"] } {
    set aplpwcap [ open "adsRpt/apache.refCell.noAplPwcap" r ]
    foreach line [split [read -nonewline $aplpwcap] \n] {
        if { ![regexp ^# $line] } {
          set aplpwcap_count [expr $aplpwcap_count+1]
        }
    }
  }
  puts "Number of cells in design with no APL piece-wisie capacitance library: $aplpwcap_count"

  set driver_count 0
  if { [file exists "adsRpt/apache.rcNoDriver"] } {
    set driver [ open "adsRpt/apache.rcNoDriver" r ]
    foreach line [split [read -nonewline $driver ] \n] {
        if { ![regexp ^# $line] } {
          set driver_count [expr $driver_count+1]
        }
    }
  }
  puts "\nDesign signal parasitic data(SPEF/DSPF):"
  puts "Number of cells in design with no drivers: $driver_count"

  set incons_driver_count 0
  if { [file exists "adsRpt/apache.rcMismatch"] } {
    set incons_driver [ open "adsRpt/apache.rcMismatch" r ]
    foreach line [split [read -nonewline $incons_driver ] \n] {
        if { ![regexp ^# $line] } {
          set incons_driver_count [expr $incons_driver_count+1]
        }
    }
  }
  puts "Number of inconsistent drivers in SPEF and DEF: $incons_driver_count"


  set bogus_count 0
  if { [file exists "adsRpt/apache.rcBogus"] } {
    set bogus [ open "adsRpt/apache.rcBogus" r ]
    foreach line [split [read -nonewline $bogus ] \n] {
        if { ![regexp ^# $line] } {
          set bogus_count [expr $bogus_count+1]
        }
    }
  }
  puts "Number of nets in SPEF that cannot be mapped to design: $bogus_count"

  set zero_count 0
  if { [file exists "adsRpt/apache.rc0Net"] } {
    set zero [ open "adsRpt/apache.rc0Net" r ]
    foreach line [split [read -nonewline $zero ] \n] {
        if { ![regexp ^# $line] } {
          set zero_count [expr $zero_count+1]
        }
    }
  }
  puts "Number of nets in SPEF with zero capacitance value: $zero_count"

  set tw_count 0
  if { [file exists "adsRpt/apache.tw0"] } {
    set tw [ open "adsRpt/apache.tw0" r ]
    foreach line [split [read -nonewline $tw ] \n] {
        if { ![regexp ^# $line] } {
          set tw_count [expr $tw_count+1]
        }
    }
  }
  puts "\nDesign timing data (STA):"
  puts "Number of instances that do not have valid timing windows in STA: $tw_count"

  set clktw_count 0
  if { [file exists "adsRpt/apache.twclk0"] } {
    set clktw [ open "adsRpt/apache.twclk0" r ]
    foreach line [split [read -nonewline $clktw ] \n] {
        if { ![regexp ^# $line] } {
          set clktw_count [expr $clktw_count+1]
        }
    }
  }
  puts "Number of sequential instances whose clock pins do not have valid timing windows in STA: $clktw_count"

  set clklate_count 0
  if { [file exists "adsRpt/apache.twclkLate"] } {
    set clklate [ open "adsRpt/apache.twclkLate" r ]
    foreach line [split [read -nonewline $clklate ] \n] {
        if { ![regexp ^# $line] } {
          set clklate_count [expr $clklate_count+1]
        }
    }
  }
  puts "Number of sequential instances whose output pins switch before the clock pin in STA: $clklate_count"
 
  set stabogus_count 0
  if { [file exists "adsRpt/apache.staBogus"] } {
    set stabogus [ open "adsRpt/apache.staBogus" r ]
    foreach line [split [read -nonewline $stabogus ] \n] {
        if { ![regexp ^# $line] } {
          set stabogus_count [expr $stabogus_count+1]
        }
    }
  }
  puts "Number of incorrect lines in STA that cannot be mapped to design: $stabogus_count"

  set staflatten_count 0
  if { [file exists "adsRpt/apache.staFlatten"] } {
    set staflatten [ open "adsRpt/apache.staFlatten" r ]
    foreach line [split [read -nonewline $staflatten ] \n] {
        if { ![regexp ^# $line] } {
          set staflatten_count [expr $staflatten_count+1]
        }
    }
  }
  puts "Number of instances that are flattened inside RedHawk and whose timing windows will be ignored: $staflatten_count"

}


