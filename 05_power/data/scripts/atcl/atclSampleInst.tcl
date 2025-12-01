# $Revision: 1.11 $
################################################################
# (C) COPYRIGHT 2010 Apache Design Systems
# ALL RIGHTS RESERVED
#
#
#   $Author: pritesh $
#   $Date: 2011/06/29 00:58:40 $
#   $Revision: 1.11 $
#   $Id: atclSampleInst.tcl,v 1.11 2011/06/29 00:58:40 pritesh Exp $
#
#   Description :
#     atclSampleInst.tcl is an Apache-AE TCL utility for listing out desired % of instances from the design
#
#   Usage: source atclSampleInst.tcl
#     atclSampleInst -xrange <xvalue> -yrange <yvalue> -n <percentage value> -max <max limit> -type <MASTER/INST> -include_file <pattern_file> -exclude_file <pattern_file> -o <output_filename>
#
#   Last Modified $Date: 2011/06/29 00:58:40 $
#
#   $Log: atclSampleInst.tcl,v $
#   Revision 1.11  2011/06/29 00:58:40  pritesh
#   Resolved an issue related to incorrect instance filtering based on exclude_file pattern, when one of the pattern does not match any instances in the design.
#
#   Revision 1.10  2010/11/11 21:36:26  pritesh
#   Reports instance selection runtime
#
#   Revision 1.9  2010/11/11 18:38:41  pritesh
#   Fixed a bug in instance selection when -exclude_file and/or max/n/ specified.
#
#   Revision 1.8  2010/11/04 19:39:56  pritesh
#   Updated instance selection handling for large designs
#
#   Revision 1.7  2010/11/04 17:40:50  pritesh
#   Fixed a bug related to instance selection when either only -exclude_file
#   or -exclude_file with -max/-n was specified. Earlier it was selecting few
#   instances belonging to exclude file also.
#
#   Revision 1.6  2010/10/21 18:17:00  pritesh
#   Initial Check-in  (updated headers)
#
#
###############################################################

proc atclTemplate_manpage {} {
  puts "

SYNOPSIS
        atclSampleInst.tcl is an Apache-AE TCL utility for listing out user defined % of instances from fullchip

USAGE
        atclSampleInst.tcl \[arguments\]
        
        arguments: 
        -n <% value>                   Value to decide how many instances to be picked
        -max <max_value>               Max number of instances to be listed
        -type <MASTER/INST>            Applies to include or exclude pattern selection 
        -exclude_file <pattern_file>   Exclude instances matching exclude pattern based on -type 
        -include_file <pattern_file>   Include instances matching include based on -type 
        -xrange <value>                Grid size in um along x-axis  
        -yrange <value>                Grid size in um along y-axis  
        -o <output_file>               Output selected instance file name 
        \[-h\]                         Usage help
        \[-man\]                       Man page
        
        Notes: 
          1. All arguments are optional.
          2. If no argument specified, all instances will be selected. 
          3. If include/exclude pattern specified, the pattern 
             file must contain one pattern per line 
          3. Default output file name : selected_instances.txt
          4. Default xrange/yrange : 500/500um 
          5. Default type : INST 
"
}

proc atclTemplate_help {} {
  puts "Usage: atclSampleInst -xrange <xvalue> -yrange <yvalue> -n <percentage value> -max <max limit> -type <MASTER/INST> -include_file <pattern_file> -exclude_file <pattern_file> -o <output_filename>" 
}


proc GetMatchedInsts {} {
  global patterntypename 
  global includeinstfile 
  global excludeinstfile 
  global includeinstlist
  global excludeinstlist 
  global excludepattern
  global DEBUGF
  set temp ""
  set includeinstlist ""
  if {$includeinstfile != " "} {
    if {[file exists $includeinstfile]} {
      puts "File specified for inclusion of the matching instances: $includeinstfile"
      #puts $DEBUGF "File specified for inclusion of the matching instances: $includeinstfile"
      set INCLUDE [open "$includeinstfile" r]
      if { $patterntypename eq "MASTER" } {
        while {[gets $INCLUDE line ]>= 0} {
          if { $line ne "" } {
            regsub -all " +$" $line "" new_line
            if { [ regexp "^#" $new_line ] } {
              continue
            }
          
            if { [catch { get instofcell $new_line -glob}] == 0} {
              set temp [get instofcell $new_line -glob]
              set includeinstlist [concat $includeinstlist $temp] 
            } else {
              puts "Error: Problem with instance selection for cell $new_line"
              #puts $DEBUGF "Error: Problem with instance selection for cell $new_line"
              ###return
            }
          } 
        }
      } elseif {$patterntypename eq "INST" } {
        while {[gets $INCLUDE line ]>= 0} {
          if { $line ne "" } {
            regsub -all " +$" $line "" new_line
            if { [ regexp "^#" $new_line ] } {
              continue
            }
            if { [catch { get inst $new_line -glob -type leaf}] == 0} {
              set temp [get inst $new_line -glob -type leaf]
              set includeinstlist [concat $includeinstlist $temp]
            } elseif { [catch { get inst $new_line -glob }] == 0} {
              set temp [get inst $new_line -glob]
              set includeinstlist [concat $includeinstlist $temp]
            } else {
              puts "Error: Problem with instance selection for inst $new_line" 
              #puts $DEBUGF "Error: Problem with instance selection for inst $new_line" 
              ###return
            }
          }
        }
      } else {
        puts "Error: Invalid pattern matching type"
        #puts $DEBUGF "Error: Invalid pattern matching type"
        return
      }
    } else {
      puts "Error: Cannot open $includeinstfile for reading"
      #puts $DEBUGF "Error: Cannot open $includeinstfile for reading"
      return
    }
  } 
  
  set temp ""
  set excludeinstlist ""
  if {$excludeinstfile != " "} {
    if {[file exists $excludeinstfile]} {
      puts "File specified for exclusion of the matching instances: $excludeinstfile"
      #puts $DEBUGF "File specified for exclusion of the matching instances: $excludeinstfile"
      set EXCLUDE [open "$excludeinstfile" r]
      if { $patterntypename eq "MASTER" } {
        while {[gets $EXCLUDE line ]>= 0} {
          if { $line ne "" } {
            regsub -all " +$" $line "" new_line
            if { [ regexp "^#" $new_line ] } {
              continue
            }
          
            if { [catch { get instofcell $new_line -glob }] == 0} {
              set temp [get instofcell $new_line -glob]
              set excludeinstlist [concat $excludeinstlist $temp]
            } else {
              puts "Error: Problem with instance selection for cell $new_line"
              #puts $DEBUGF "Error: Problem with instance selection for cell $new_line"
              ###return
            }
          } 
        }
      } elseif {$patterntypename eq "INST" } {
        while {[gets $EXCLUDE line ]>= 0} {
          if { $line ne "" } {
            regsub -all " +$" $line "" new_line
            if { [ regexp "^#" $new_line ] } {
              continue
            }
            ##puts $DEBUGF "Line from exclude file: $new_line ($line)"
            if { [catch { get inst $new_line -glob -type leaf}] == 0} {
              set temp [get inst $new_line -glob -type leaf]
              set excludeinstlist [concat $excludeinstlist $temp]
            } elseif { [catch { get inst $new_line -glob}] == 0} {
              set temp [get inst $new_line -glob]
              set excludeinstlist [concat $excludeinstlist $temp]
            } else {
              puts "Error: Problem with instance selection for inst $new_line"
              #puts $DEBUGF "Error: Problem with instance selection for inst $new_line"
              ###return
            }
          }
        }
      } else {
        puts "Error: Invalid pattern matching type"
        #puts $DEBUGF "Error: Invalid pattern matching type"
        return
      }
      foreach inst1 $excludeinstlist {
        set excludepattern($inst1) "set"
      }
    } else {
      puts "Error: Cannot open $excludeinstfile for reading"
      puts $DEBUGF "Error: Cannot open $excludeinstfile for reading"
      return
    }
  } 
}

proc PrintTime { args } { 
  set stopclk [clock seconds]  
  set tsecs [ expr ($stopclk - $args) ]
  set hrs [ expr $tsecs/3600 ]
  set mins [ expr ($tsecs - ($hrs*3600))/60 ]
  set secs [ expr (($tsecs - ($hrs*3600)) -($mins*60)) ] 
  puts "Total time taken for instance selection: $hrs hrs $mins mins $secs secs"
  return
}

set tempinst "" 
proc GetAllInst { args } { 
   global tempinst 
   set tempinst "" 
   set tempinstid "" 
   if { [ llength $args ] == 4 } { 
     set x1 [ lindex $args 0 ] 
     set y1 [ lindex $args 1 ] 
     set x2 [ lindex $args 2 ] 
     set y2 [ lindex $args 3 ]
     if { [catch { get inst_by_cid * -glob -bbox $x1 $y1 $x2 $y2 -type leaf }] == 0} {
        set tempinstid [  get inst_by_cid * -glob -bbox $x1 $y1 $x2 $y2  -type leaf ]
     } 
   } else { 
     puts "get all instances" 
     if { [catch { get inst_by_cid * -glob -type leaf }] == 0} {
        set tempinstid [  get inst_by_cid * -glob -type leaf ]
     }
   } 

   set ltempinstid [ llength $tempinstid ] 
   if { $ltempinstid != "" } { 
      foreach tinstid $tempinstid { 
        set inst [ get inst_by_cid $tinstid -name ] 
        lappend tempinst $inst 
      }
   }
}

set patterntypename "INST"
set includeinstfile " "
set excludeinstfile " "
set includeinstlist " "
set excludeinstlist " "

proc atclSampleInst { args } {
  global patterntypename 
  global includeinstfile 
  global excludeinstfile 
  global includeinstlist
  global excludeinstlist 
  global excludepattern
  global tempinst 
  global DEBUGF 
  set argv [split $args]
  set state flag
  set n " "
  set max_inst_limit " "
  set pattern_flag 0
  set xrange 0
  set yrange 0
  set outputfile "selected_instances.txt"
  set include_file " "
  set exclude_file " "
  set includeinstfile " "
  set excludeinstfile " "
  set include_count 0

  foreach arg $argv {
    switch -- $state {
      flag {
        switch -glob -- $arg {
          -h* { atclTemplate_help ; return }
          -man { atclTemplate_manpage ; return }
          -n { set state perc_val }
          -max { set state max_limit }
          -type { set state pattern_type }
          -include_file { set state includeinst }
          -exclude_file { set state excludeinst }
          -xrange { set state rectx_area }
          -yrange { set state recty_area }
          -o { set state outputf }
          default { error "Error: Unknown flag $arg" }
        }
      }
      
      perc_val {
        set  n $arg
        set state flag
      }
      max_limit {
        set max_inst_limit $arg
        set state flag
      }
      pattern_type {
        set patterntypename $arg
        set state flag
      } 
      includeinst {
        set includeinstfile $arg
        set state flag
      }   
      excludeinst {
        set excludeinstfile $arg
        set state flag
      }
      rectx_area {
        set xrange $arg
        set state flag
      }
      recty_area {
        set yrange $arg
        set state flag
      }
      outputf {
        set outputfile $arg
        set state flag
      }
    }
  }
  
  select clearall 
  
  set INSTFILE [open "$outputfile" w]
  set DEBUGF [open ".debug.txt" w]
  puts $DEBUGF "R2.0 : atclSampleInst -xrange $xrange -yrange $yrange -n $n -max $max_inst_limit -type $patterntypename -include_file $include_file -exclude_file $exclude_file -o $outputfile " 
  set  strtclk [clock seconds]
  puts $DEBUGF $strtclk
  
  set a [config cmdlog off] 

  if {$n == " " && $max_inst_limit == " "} {
    if {$includeinstfile == " " && $excludeinstfile == " "} {
       set caseid 1
    } else {
       set caseid 2 
    }  
  } else {
    set instcnt [get design -stats -count instances]
    if {$n != " " && $max_inst_limit == " "} {
      set max_inst_limit [ expr int(($instcnt/100)*$n)]
    } elseif {$n != " " && $max_inst_limit != " "} {
      puts "Both \'n\' and \'max\' specified, ignoring \'n\'"
    }
    
    if {$instcnt < $max_inst_limit} {
      set max_inst_limit $instcnt
      puts "Specified max inst limit exceeds total inst count" 
      if {$includeinstfile == " " && $excludeinstfile == " "} {
         set caseid 1
      } else { 
         set caseid 2
      }
    } else {
      set caseid 3
    }
  }
   
  
  switch -- $caseid {
    1 {
        puts $DEBUGF "1"
        puts "Selecting all instances in the design"
        puts -nonewline  ""
        GetAllInst 
        set instlist $tempinst 
        #set instlist [get inst * -glob -type leaf]
        set llst [llength $instlist]
        foreach inst $instlist {
          puts $INSTFILE "$inst"
        }
        puts $DEBUGF "E1 [clock seconds]"
        close $DEBUGF
        close $INSTFILE
        puts "$llst instances selected" 
        puts "Output instance file: $outputfile" 
        puts "Finished instance selection"
        PrintTime $strtclk
        return  
      }

    2 {
        puts $DEBUGF "2"
        puts "Selecting instances based on include/exclude patterns"
        puts "Pattern matching type : $patterntypename"
        GetMatchedInsts
 
        if {$includeinstfile == " "} {
          GetAllInst 
          set includeinstlist $tempinst 
          #set includeinstlist [get inst * -glob -type leaf]
        }
        
        set cnt [llength $includeinstlist]
        puts $DEBUGF  "Inc inst cnt $cnt"

        if {$excludeinstfile == " "} {
          foreach inst2 $includeinstlist {
            puts $INSTFILE "$inst2"
          }
        } else {
          set cnt1 [llength $excludeinstlist]
          set cnt 0 
          foreach inst2 $includeinstlist {
            if { ![ info exists excludepattern($inst2)] } {
              puts $INSTFILE "$inst2"
              incr cnt 
            }
          }
        }
        puts $DEBUGF "E2 [clock seconds]"
        close $DEBUGF
        close $INSTFILE 
        puts "$cnt instances selected" 
        puts "Output instance file: $outputfile" 
        puts "Finished instance selection"
        PrintTime $strtclk
        return 
      }
                
    3 {
        puts $DEBUGF "3"
        puts "Selecting $max_inst_limit instances"

        if {$includeinstfile != " " || $excludeinstfile != " "} { 
          puts "Pattern matching type : $patterntypename"
          GetMatchedInsts
        }
        
        if {$includeinstfile != " "} {
          if {$excludeinstfile != " "} {
            foreach inst1 $includeinstlist {
              if { ![ info exists excludepattern($inst1)] } {
                set includepattern($inst1) "set"
              } 
            }
          } else {
            foreach inst1 $includeinstlist {
              set includepattern($inst1) "set"
            }
          }  
        
          set incpatcnt [array size includepattern]
          puts $DEBUGF "Inc pat size $incpatcnt"
          puts $DEBUGF "max lmt $max_inst_limit" 
          if {$incpatcnt <= $max_inst_limit} {
            puts "\'max\' instance limit exceeds matching instances" 
            foreach inst [array names includepattern] {
              puts $INSTFILE "$inst"  
            }
            puts $DEBUGF "E3a [clock seconds]"
            close $DEBUGF
            close $INSTFILE
            puts "$incpatcnt instances selected"
            puts "Output instance file: $outputfile" 
            puts "Finished instance selection"
            PrintTime $strtclk
            return 
          }
        }
        
        puts $DEBUGF "sample inst..." 
        puts "Sampling instances..."
        if {$xrange == 0} {
          set xrange 500 
        }
        if {$yrange == 0} {
          set yrange 500 
        }

        set d_bbox [get design -bbox]
        set dx1 [lindex $d_bbox 0]
        set dy1 [lindex $d_bbox 1]
        set dx2 [lindex $d_bbox 2]
        set dy2 [lindex $d_bbox 3]
    
        set x_grd [expr {$dx2/$xrange}]
        set x_grd [expr round($x_grd)]
        set y_grd [expr {$dy2/$yrange}]
        set y_grd [expr round($y_grd)]
        set t_grd [expr {$x_grd*$y_grd}]
        puts $DEBUGF "xg:$x_grd yg:$y_grd tg:$t_grd"
        puts "Grid size: \($xrange, $yrange\)" 
        
        set selinstcnt 0 
        set grdid 0  
        for {set x1 0} {$x1<$x_grd} {incr x1} {
          for {set y1 0} {$y1<$y_grd} {incr y1} {
            incr grdid 
            puts $DEBUGF "gid:$grdid"
            set grdinst ""
            set llx [expr $x1*$xrange]
            set lly [expr $y1*$yrange]
            set urx [expr $llx+$xrange]
            set ury [expr $lly+$yrange]
            set chx [expr $x_grd-$x1]
            set chy [expr $y_grd-$y1]
            if {$chx == 1} {
              set urx $dx2
            } 
            if {$chy == 1} {
              set ury $dy2
            } 
            
            plot line -color white -width 2 -position $llx $lly $llx $ury
            plot line -color white -width 2 -position $llx $ury $urx $ury
            plot line -color white -width 2 -position $urx $lly $urx $ury
            plot line -color white -width 2 -position $llx $lly $urx $lly

            set g($grdid) $grdinst 
            if {$max_inst_limit <= $t_grd} {
              puts $DEBUGF "> 3a"

              GetAllInst $llx $lly $urx $ury
              set grdinst $tempinst 
              
              #if { [catch { get inst * -glob -bbox $llx $lly $urx $ury -type leaf }] == 0} {
                #} 
              #  set grdinst [get inst * -glob -bbox $llx $lly $urx $ury -type leaf]
              if { $grdinst != "" } {
                set lgrdinst [llength $grdinst]
                if {$includeinstfile != " " } {
                  set temp ""
                  foreach inst2 $grdinst {
                    if { [ info exists includepattern($inst2)] } {
                      lappend temp $inst2 
                    }
                  }
                  set grdinst $temp 
                  set lgrdinst [llength $grdinst]
                } elseif {$excludeinstfile != " "} {
                  set temp ""
                  foreach inst2 $grdinst {
                    if { ![ info exists excludepattern($inst2)] } {
                      lappend temp $inst2 
                    }
                  }
                  set grdinst $temp 
                  set lgrdinst [llength $grdinst]
                }
                if { $lgrdinst != 0 } {
                  puts $INSTFILE [lindex $grdinst 0]
                  incr selinstcnt 
                  if {$selinstcnt == $max_inst_limit} {
                    puts $DEBUGF "E3b [clock seconds]"
                    close $DEBUGF 
                    close $INSTFILE 
                    puts "Output instance file: $outputfile" 
                    puts "Finished instance selection"
                    PrintTime $strtclk
                    return
                  }
                  set grdinst [lrange $grdinst 1 end] 
                  set g($grdid) $grdinst 
                }
              } else {
                set g($grdid) 0
                # puts "Error: instance selection from grid $x1 $y1 failed" 
              }
            } else { 
              puts $DEBUGF "> 3b"
              set inst_grd [expr {$max_inst_limit/$t_grd}]
              set inst_grd [expr round($inst_grd)]
              GetAllInst $llx $lly $urx $ury
              set grdinst $tempinst 
              
              #if { [catch { get inst * -glob -bbox $llx $lly $urx $ury -type leaf}] == 0} {
                #}
              #  set grdinst [get inst * -glob -bbox $llx $lly $urx $ury -type leaf]
              if { $grdinst != "" } { 
                set lgrdinst [llength $grdinst]
                puts $DEBUGF ">> lgrd: $lgrdinst" 
                if {$includeinstfile != " " } {
                  set temp ""
                  foreach inst2 $grdinst {
                    if { [ info exists includepattern($inst2)] } {
                      lappend temp $inst2 
                    }
                  }
                  set grdinst $temp 
                  set lgrdinst [llength $grdinst]
                } elseif {$excludeinstfile != " "} {
                  set temp ""
                  foreach inst2 $grdinst {
                    if { ![ info exists excludepattern($inst2)] } {
                      lappend temp $inst2 
                    }
                  }
                  set grdinst $temp 
                  set lgrdinst [llength $grdinst]
                }
                set cur_inst_grd [ expr $inst_grd + [expr [expr $grdid*$inst_grd] - $selinstcnt] ]
                puts $DEBUGF " >> lgrd: $lgrdinst curgrd $cur_inst_grd" 
                if { $lgrdinst != 0 } {
                  if {$lgrdinst <= $inst_grd} {
                    puts $DEBUGF "  >>> 3b1"
                    foreach inst $grdinst {
                      puts $INSTFILE "$inst"
                    }
                    set selinstcnt [expr $selinstcnt + $lgrdinst]
                    set grdinst 0 
                    set g($grdid) $grdinst 
                  } elseif {$lgrdinst <= $cur_inst_grd} {
                    puts $DEBUGF "  >>> 3b2"
                    foreach inst $grdinst {
                      puts $INSTFILE "$inst"
                    }
                    set selinstcnt [expr $selinstcnt + $lgrdinst]
                    set grdinst 0 
                    set g($grdid) $grdinst 
                  } else {    
                    puts $DEBUGF "  >>> 3b3"
                    for {set i 1} {$i<=$inst_grd} {incr i} {
                      set num [expr {int(rand()*[expr $lgrdinst-1])}]
                      puts $INSTFILE [lindex $grdinst $num]
                      if {$num == 0} {
                        set grdinst [lrange $grdinst 1 end] 
                      } elseif {$num == [expr $lgrdinst-1]} {
                          set grdinst [lrange $grdinst 0 [expr $num-1]] 
                      } else {
                        set t2grdinst [lrange $grdinst [expr $num+1] end]
                        set grdinst [lrange $grdinst 0 [expr $num-1]]
                        set grdinst [concat $grdinst $t2grdinst]
                      }
                      set lgrdinst [llength $grdinst]
                    }
                    set g($grdid) $grdinst 
                    set selinstcnt [expr $selinstcnt + $inst_grd]
                  }
                }
              } else {
                set g($grdid) 0 
              }
            }
          } ;# for
        } ;# for

        puts $DEBUGF "$selinstcnt sel\'ed"

        if {$selinstcnt < $max_inst_limit} {
          set dif [expr $max_inst_limit - $selinstcnt]
          puts $DEBUGF "selecting $dif"
          for {set i 1} {$i <= $t_grd} {incr i} {
            set dif [expr $max_inst_limit - $selinstcnt]
            set gi $g($i)
            set lgi [llength $gi]
            if {$lgi > $dif} {
              set gi [lrange $gi 1 $dif] 
              set lgi [llength $gi]
            }  
            foreach inst $gi {
              if { $inst != 0 } { 
                puts $INSTFILE "$inst"
                incr selinstcnt 
              }
            }
            #set selinstcnt [expr $selinstcnt + $lgi]
            if {$selinstcnt >= $max_inst_limit} {
              puts $DEBUGF "E3c [clock seconds]"
              close $DEBUGF
              close $INSTFILE 
              puts "Output instance file: $outputfile" 
              puts "Finished instance selection"
              PrintTime $strtclk
              return 
            }
          }
          close $INSTFILE 
          puts "Output instance file: $outputfile" 
          puts "Finished instance selection"
          PrintTime $strtclk
          return 
        } else {
          puts $DEBUGF "E3d [clock seconds]"
          close $DEBUGF 
          close $INSTFILE 
          puts "Output instance file: $outputfile" 
          puts "Finished instance selection"
          PrintTime $strtclk
          return
        }  
        
        PrintTime $strtclk
        return  
      }
  } ;# switch 
  PrintTime $strtclk
  return 
}
