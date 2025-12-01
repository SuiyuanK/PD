########################### puts the usage ###########################
proc atcl_adec_help {} {
   puts {Usage: atcl_adec [-h | -p | -d <dir_name> | -o <output_file>]}
   puts {                         -h: print help message}
   puts {                         -p: collect data for accupower}
   puts {                         -d: input directory name (default to ".apache")}  
   puts {                         -o: output file name (default to "to_apache")}
}

proc atcl_adec {args} {
set argv [split $args]
set argc [llength $argv]
if {$argc >0 && [lindex $argv 0] eq "-h"} {
   atcl_adec_help; return
}
  
####################### compress accupower files #######################
puts "*********************************\n*  Apache Debug Data Collector  *\n*********************************"
set temp ""
set accupower_list {
adsNets.out apache.hierarchy cluster.insts .ads.lib.power apache.min
cell.current cell.cdev vmemory.current vmemory.cdev apache.pgarc
}
if {$argc >0 && [lindex $argv 0] eq "-p"} {    
   puts {[Collecting debug data for accupower session]}
     for {set i 1} {$i < $argc} {incr i} {
     set A($i) [lindex $argv $i]
     append temp "$A($i) "  
   }
   if {[lsearch -exact $temp -d] != -1} {
      set a [lsearch -exact $temp -d]
      set indir [lindex $temp [expr $a+1]]
   } else {
      set indir .apache
   }
   if {[lsearch -exact $temp -o] != -1} {
      set b [lsearch -exact $temp -o]
      set outfile [lindex $temp [expr $b+1]]
   } else {
      set outfile to_apache_accupower
   }  
   if {[file exists $outfile] && [file isdirectory $outfile]} {
      exec rm -r $outfile
   }
   exec mkdir $outfile
   foreach filename $accupower_list { 
     if {[file exists $indir/$filename]} {
        puts "adding file $filename...yes"
        exec cp -rL $indir/$filename $outfile
     } else {
        puts "adding file $filename...no"
     }
   }
   puts {[Compressing data]}
   exec tar cf $outfile.tar $outfile
   exec rm -r $outfile
   puts "\n****\n**** Please upload the debug data file '$outfile.tar' to ftp.apache-da.com"
   return
}
##################### compress dynamic files #########################  
set dynamic_list {
apache.ind .debug.dynamic  apache.v apache.pwr apache.imap apache.nloc 
apache.cap apache.decap apache.cluster adsLib.output apache.pad apache.pgarc 
apache.dvd apache.scenario apache.dsw apache.switch apache.pid apache.maxid
apache.ldo apache.sub apache.smt apache.freqr apache.csw apache.well 
apache.swn apache.dgf apache.srs apache.str apache.cis apache.gsr apache.sip 
apache.statemap apache.mgsc apache.gsc cell.current cell.cdev cell.pwc
vmemory.current vmemory.cdev apache.ldo.model apache.ldo.inst
}
if {$argc >0} {
   for {set i 0} {$i < $argc} {incr i} {
   set A($i) [lindex $argv $i]
   append temp "$A($i) "
   }
}
if {[lsearch -exact $temp -d] != -1} {
   set a [lsearch -exact $temp -d]
   set indir [lindex $temp [expr $a+1]]
} else {
   set indir .apache
}
if {[file exists $indir/.debug.dynamic]} {
   puts {[Collecting debug data for dynamic session]}
   if {[lsearch -exact $temp -o] != -1} {
      set b [lsearch -exact $temp -o]
      set outfile [lindex $temp [expr $b+1]]
   } else {
      set outfile to_apache_dynamic
   }
   if {![file exists $indir/.multidie]} {
      if {[file exists $outfile] && [file isdirectory $outfile]} {
         exec rm -r $outfile
      }
      exec mkdir $outfile
      foreach filename $dynamic_list {
        if {[file exists $indir/$filename]} {
           puts "adding file $filename...yes"
           exec cp -rL $indir/$filename $outfile
        } else {
           puts "adding file $filename...no"
        }
      }
      puts {[Compressing data]}
      exec tar cf $outfile.tar $outfile
      exec rm -r $outfile
      puts "\n****\n**** Please upload the debug data file '$outfile.tar' to ftp.apache-da.com"
   }
   if {[file exists $indir/.multidie]} {
      if {[file exists $outfile] && [file isdirectory $outfile]} {
         exec rm -r $outfile
      }
      set die 0
      foreach line [qa::get_file_data $indir/.multidie 1] {
         if [regexp {^\s*$} $line] {continue}
         incr die
         set diename($die) [lindex $line 0]
         exec mkdir -p $outfile/$diename($die)
         foreach filename $dynamic_list {
            if {[file exists $indir/$diename($die)/$filename]} {
               puts "adding file $diename($die)/$filename...yes"
               exec cp -rL $indir/$diename($die)/$filename $outfile/$diename($die)
            } else {
               puts "adding file $diename($die)/$filename...no"
            }
         }
         puts {[Compressing data]}
         cd $outfile
         exec tar cf $diename($die).tar $diename($die)
         exec rm -r $diename($die)
         cd ..
      }
      exec tar cf $outfile.tar $outfile
      exec rm -r $outfile
      puts "\n****\n**** Please upload the debug data file '$outfile.tar' to ftp.apache-da.com"
   }
}
###################### compress static files #########################
set temp1 ""
set static_list {
apache.res .debug.static apache.i apache.v apache.pad apache.switch apache.gsr
}
if {$argc >0} {
   for {set i 0} {$i < $argc} {incr i} {
   set B($i) [lindex $argv $i]
   append temp1 "$B($i) "
   }
}
if {[lsearch -exact $temp1 -d] != -1} {
   set m [lsearch -exact $temp1 -d]
   set indir [lindex $temp [expr $m+1]]
} else {
   set indir .apache
}
if {[file exists $indir/.debug.static]} {
   puts {[Collecting debug data for static session]}
   if {[lsearch -exact $temp1 -o] != -1} {
      set n [lsearch -exact $temp1 -o]
      set outfile [lindex $temp1 [expr $n+1]]
   } else {
      set outfile to_apache_static
   }
   if {![file exists $indir/.multidie]} {
      if {[file exists $outfile] && [file isdirectory $outfile]} {
         exec rm -r $outfile
      }
      exec mkdir $outfile
      foreach filename $static_list {
        if {[file exists $indir/$filename]} {
           puts "adding file $filename...yes"
           exec cp -rL $indir/$filename $outfile
        } else {
           puts "adding file $filename...no"
        }
      }
      puts {[Compressing data]}
      exec tar cf $outfile.tar $outfile
      exec rm -r $outfile
      puts "\n****\n**** Please upload the debug data file '$outfile.tar' to ftp.apache-da.com"
   }
   if {[file exists $indir/.multidie]} {
      if {[file exists $outfile] && [file isdirectory $outfile]} {
         exec rm -r $outfile
      }
      set die 0
      foreach line [qa::get_file_data $indir/.multidie 1] {
         if [regexp {^\s*$} $line] {continue}
         incr die
         set diename($die) [lindex $line 0]
         exec mkdir -p $outfile/$diename($die)
         foreach filename $static_list {
            if {[file exists $indir/$diename($die)/$filename]} {
               puts "adding file $diename($die)/$filename...yes"
               exec cp -rL $indir/$diename($die)/$filename $outfile/$diename($die)
            } else {
               puts "adding file $diename($die)/$filename...no"
            }
         }
         puts {[Compressing data]}
         cd $outfile
         exec tar cf $diename($die).tar $diename($die)
         exec rm -r $diename($die)
         cd ..
      }
      exec tar cf $outfile.tar $outfile
      exec rm -r $outfile
      puts "\n****\n**** Please upload the debug data file '$outfile.tar' to ftp.apache-da.com"
   }
}
}

