# $Revision: 1.1 $
eval '(exit $?0)' && eval 'exec perl -S $0 ${1+"$@"}'

&& eval 'exec perl -S $0 $argv:q' if 0;

######################
#
# rev 1.0 - divide each current in pad.current into an out and ta0 file
#
######################

sub usage {
print "USAGE: process_pad_current.pl -dir <directory to store waveforms>\n";
print "        This program must be executed in the Redhawk run directory\n";

}

   foreach $i (0 .. $#ARGV) {
     if ($ARGV[$i] eq "-dir") {
       $dirname = $ARGV[$i+1];
     }
     if ($ARGV[$i] eq "-h") {
       $help = 1;
     }
   }

   if ($help) {
    &usage;
    exit (0) ;
   }

   if ($dirname eq "") {
     print "ERROR: directory is a required input\n";
     &usage;
     exit (1);
   } elsif ( !(-d $dirname ) ) {
     system ("mkdir $dirname") ;
   } 

$infile = "adsRpt/Dynamic/pad.current";
if( !(-e $infile) ) {
    print "ABORT !! Could not find $infile\n";
    exit(1);
}

$inprocess = 0 ;
open(IN1, "$infile");
while( <IN1> ) {
    chomp;
 if (!/^$/) {
    if( (/^"/) and !$inprocess ) {
        $name = (split '\"')[1] ;
        $inprocess = 1;
        open (OUTF , ">$dirname\/$name\.out");
        print OUTF "Time   i($name)\n";
    } elsif (/^"/) {
        close (OUTF);
        system ("cd $dirname ; prraw $name\.out $name\.ta0");
        $name = (split '\"')[1] ;
        open (OUTF , ">$dirname\/$name\.out");
        print OUTF "Time   i($name)\n";
    } elsif ($inprocess) {
        print OUTF "$_\n";
    }
  }
}
close(IN1);
close(OUTF); 
system ("cd $dirname ; prraw $name\.out $name\.ta0");

