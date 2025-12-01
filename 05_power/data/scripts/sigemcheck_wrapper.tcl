
# $Revision: 1.6 $
################################################################
# (C) COPYRIGHT 2010 Apache Design Systems
# ALL RIGHTS RESERVED
#
#   $Author: pritesh $
#   $Date: 2011/11/15 04:40:11 $
#   $Revision: 1.6 $
#   $Id: sigemcheck_wrapper.tcl,v 1.6 2011/11/15 04:40:11 pritesh Exp $
#
#   Description :
#    Wrapper script which calls sigemcheck.pl script (main script) 
#
#   Usage: 
#    source sigemcheck_wrapper.tcl
#    sigemcheck [-viarms 0|1] [-viapeak 0|1] [-o <outdir>] [-help] 
#
#   Last Modified $Date: 2011/11/15 04:40:11 $
#
#   $Log: sigemcheck_wrapper.tcl,v $
#   Revision 1.6  2011/11/15 04:40:11  pritesh
#   - Added support for new 11.1 signalEM flow.  Set -ver 0 (default 0) for new signalEM flow
#
#   Revision 1.5  2011/07/01 01:34:01  pritesh
#   -filter 0|1 option added to control the sigem results filtering.
#    This option should be set to 0, if SEM_IGNORE_NETS_MISSING_DATA is set in GSR.
#
#   Revision 1.4  2010/10/22 21:16:04  pritesh
#   sigemcheck_wrapper to find sigemcheck.pl in APACHEROOT/scripts by default
#
#   Revision 1.3  2010/10/21 19:36:33  pritesh
#   Updated default call for  sigemcheck.pl from APACHEROOT/scripts/
#
#   Revision 1.2  2010/10/21 18:17:00  pritesh
#   Initial Check-in  (updated headers)
#
#
###############################################################

proc atclTemplate_manpage {} {
  puts "

SYNOPSIS
       sigemcheck_wrapper.tcl is the wrapper script which calls sigemcheck.pl. The sigemcheck.pl is 
       the main script which post processes the signalEM results.

USAGE
        sigemcheck  \[arguments\]
        
        arguments: 
        -viarms  0|1         (Optional)
         Enable/disable the via rms em violation reporting, 0 means disable.          
         Default:0 
        -viapeak  0|1        (Optional)
         Enable/disable the via peak em violation reporting, 0 means disable 
         Default:0
        -filter  0|1          (Optional) 
         Enable/disable the sigem results filtering. If the tool filtering using 
         SEM_IGNORE_NETS_MISSING_DATA is turned on in the gsr, then this option should 
         be set to 0. With -filter 0, the viarms and viapeak options have no effect. 
         Default: 0
        -ver   0|1           (Optional) 
         Set to 0, if running new 11.1 signalEM Flow. 
         Default: 0
        -o <output_dir>      (Optional)    
         Output directory name, where post-processing results to be generated
         Default: ./sigem_results
        -scriptPath <path>   (Optional)
         Provide path to the directory containing the perl script, sigemcheck.pl 
         Default: RedHawk build script area
        -help       
         Usage help
        
"
}

proc atclTemplate_help {} {
  puts "Usage:  sigemcheck (-viarms 0/1) (-viapeak 0|1) (-filter 0|1)  (-o <outdir>) (-help) (-scriptPath <>)" 
}

proc sigemcheck { args } {

  global env
  set root $env(APACHEROOT) 
  puts "Build path: $root"
  set scrroot "$root\/scripts/"
  #puts "Script root: $scrroot"
  array set opt [concat "-scriptPath $scrroot -ver 0 -filter 0 -viarms 0 -viapeak 0 -o ./sigem_results -help 0 -man 0 " $args ] 
  set scriptPath $opt(-scriptPath)
  set outdir $opt(-o)
  set viarms $opt(-viarms)
  set viapeak $opt(-viapeak)
  set filter $opt(-filter)
  set ver $opt(-ver)
  set help $opt(-help) 
  set man $opt(-man) 
  puts "Script search path: $scriptPath"
  
  if { $man==1 }  { 
    atclTemplate_manpage 
    return 
  } 
  
  if { $help==1 }  { 
    atclTemplate_help 
    return 
  } 
  exec perl $scriptPath/sigemcheck.pl -viarms $viarms -viapeak $viapeak -filter $filter -ver $ver -o $outdir 
}
 
 
