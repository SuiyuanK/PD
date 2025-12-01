############################################################################
# RTL to GATE name mapping file
# Raj S Kashyap <rajs@apache-da.com>
############################################################################

%cmd=@ARGV;

if(@ARGV != 10){
    print "Usage :\n\t$0 -run_dir <map_run_dir_path>\n";
    exit(1);
}
$run_dir  = $cmd{-run_dir};
$rtl_map   =$cmd{-rtl_map};
$gate_insts=$cmd{-gate_insts};
$gate_ports=$cmd{-gate_ports};
$out_file  =$cmd{-out_file};

open (out  , ">>", $out_file ) or die "couldnt open out file\n";
open (file1, "<" , $rtl_map ) or die "couldnt find ./insts_map_rtl.map\n";
open (file2, "<" , $gate_insts ) or die "couldnt find ./insts_map_gate.map\n";
open (file3, "<" , $gate_ports) or die "couldnt find ./insts_map_ports.map\n";
@rtl_insts = <file1>;
@gate_insts = <file2>;
@ports = <file3>;
close $file1;
close $file2;
close $file3;
$i=0;
while($rtl_insts[$i]) {
    chomp($rtl_insts[$i]);
    chomp($gate_insts[$i]);
    chomp($ports[$i]);
	$j=0;
	@array=split (/ /, $ports[$i]);
	while($array[$j]){
        #print "$array[$j]\n";
		$from="$rtl_insts[$i]" . "/" . "$array[$j]";
		$to  ="$gate_insts[$i]" . "/" . "$array[$j]";
		print out "$from $to\n";
		$j=$j+1;
	}
	$i=$i+1;
}
close $out;
