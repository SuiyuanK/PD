proc report_sigem {args} {
 
set var  [get design -bbox];
set var2 [get analysis mode];
set design_name [get design];
set var3 [llength [get net * -glob -type power]];
set FP [open "totcl.txt" w] ;
puts $FP "Designbbox: $var" ;
puts $FP "Mode: $var2";

set argv [split $args];
set state flag_s;
foreach arg $argv {
                        switch -- $state {
                                flag_s {
                                        switch -glob -- $arg {

                                                -thresh { set state thresh_s }
                                                -op { set state o_s }
                                                -em { set state em_s }  
                                                
                                                }
                                }
                                thresh_s {

                                        set thresh $arg
                                        set state flag_s
                                }
                                o_s {   
                                        set op $arg
                                        set state flag_s
                                }
                                em_s {
                                        set em $arg
                                        set state flag_s
                                }
                       
}
}

#puts $op ;
if {![info exists op]} {set op $design_name.signalRV_summary.rpt ; 
}

if {![info exists em]} {set em 100 ;
}


puts  $FP "Output_file $op";
puts  $FP "EM_THRESHOLD $em";
if {[info exists thresh]} {puts  $FP "Threshold_file $thresh";
}
puts $FP "VOLTAGE DOMAINS: $var3";
close $FP ;




exec perl /$env(APACHEROOT)/Scripts/totem_signalRV.pl ;

}
