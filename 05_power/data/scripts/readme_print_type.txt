perl print_type.pl [Options] arguments

       arguments : RH path & design name

       Options :    -d, -outdir, -resolution, -start, -end, -man ,
       -bbox, -block,-net,-help


      
      
       Options & arguments Elaborated :

       -h  Prints a synopsis and a description of program options.

       -man
           Prints the entire man page

  
   

       -design
           Specify the   <design name > ( compulsory )

       -resolution
           Specify the   <resolution in ns>

           ( Default value is 100ns )

       -start
           Specify the   <start time in ns>

       -end
           Specify the   <end time in ns>

           ( Default values of start & end are first & last switching times )

       -bbox
           Specify the   "<x1 y1 x2  y2>"  co-ordinates of the rectangular
           region you want to look for.  <x1 y1 > are co-ordinates of the
           lower left corner of the box & <x2  y2>  co-ordinates of the upper
           right corner.  Note : Please give all co-ordinates with in double
           quotes.

       -net
           Specify the vdd-domain as <net>.

       -block
           Specify the block/instance name(top level).

      
      
       Examples :   
       perl print_type.pl   -design GENERIC -d /home/RH_run -resolution 0.2 -start 2 -end 20  -bbox " 200 100 300 600" -net vdd

       The output directory is outdir if not specified
   
    perl print_type.pl -design GENERIC -d /home/RH_run
    This will just emulate the "Print Type " tcl command of RH.
