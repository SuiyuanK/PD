# $Revision: 2.1 $
#
# This script will select and highlite all instances that are active according to the 'print instance' TCL command
# The user provides an x y bound box (in microns) and start and end time (in ps)
#
# The command 'analyze dvd' has to be run before this script will work
#
proc hilite_active {x1 y1 x2 y2 stime etime} {
 
   set xyfile $stime\_$etime.inst.xy.file
   set activefile $stime\_$etime.inst.active.file

   condition set -xy $x1 $y1 $x2 $y2 -time $stime $etime 
   print instance -o $xyfile
   
   exec cp [pwd]/$xyfile [pwd]/$activefile
   
   set fileptr [open "/tmp/ads_tmpscript" "w"]
   
   puts $fileptr "#!/bin/tcsh -f"
   
   puts $fileptr "sed -e '1d' -e '\$d' \$1 > /tmp/\$1_file ; sed '\$d' /tmp/\$1_file > \$1 ; rm /tmp/\$1_file"
   puts $fileptr "grep '^1' \$1 > /tmp/\$1_file ; mv /tmp/\$1_file \$1"
   puts $fileptr "awk '{print \$2}' \$1 > /tmp/\$1_file ; mv /tmp/\$1_file \$1"
   
   flush $fileptr
   close $fileptr
   
   exec mv /tmp/ads_tmpscript ads_tmpscript
   exec chmod +x ads_tmpscript
   exec [pwd]/ads_tmpscript $activefile
   
   select addfile $activefile -linewidth 2 -color white
 
   exec rm $xyfile $activefile [pwd]/ads_tmpscript

}
