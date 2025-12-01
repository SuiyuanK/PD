use Compress::Zlib;
%cmd=@ARGV;

if(@ARGV != 12){
    print "Usage :\n\t$0 -vcd_file <rtl_vcd> -topinst <rtl_top_in_vcd> -run_dir <map_run_dir_path> -out_reg <out_reg_file> -out_inst <out_instance_file> -rule_file <rule_file>\n";
    exit(1);
}

$topinst = $cmd{-topinst};
$vcd_file = $cmd{-vcd_file};
$run_dir  = $cmd{-run_dir};
$out_reg  = $cmd{-out_reg};
$out_inst = $cmd{-out_inst};
$rule_file= $cmd{-rule_file};
$include_rtl_wire=1;
if (-e $rule_file) {
open (rule_file , "<", $rule_file );
while(<rule_file>) {
	next if($_=~/^\s*$/); #Skip if blank line
	next if($_=~/^\s*#/); # Skip if commented lin
    $var=$_;
    $var =~ tr/\"//d;
    if ($var =~ m/include_rtl_wire ([01])$/) {
      $include_rtl_wire=$1;
    } 
}
close $rule_file;
}
#$topinst=~tr/\//\./d; #replace / with .
if($topinst=~/^\/(.*)/) {
    $topinst=$1;
}
if($topinst=~/(.*)\/$/){
    $topinst=$1;
}

$hierarchy="";
$start=0;
$finish=0;
$pending_write = 0;
$curr_instance = "";
$current_hierarchy="";
#open (vcd_file, "<", "$vcd_file") or die "didnt find VCD file\n";
open (rtl_regs, ">", $out_reg  ) or die "couldnt open output rtl regs file\n";
open (rtl_inst, ">", $out_inst ) or die "couldnt open output rtl insts file\n";
$vcd=gzopen($vcd_file, "r");
while ($vcd->gzreadline($_) > 0) {
	chomp;
	if($_=~/\$scope\s+(\S+)\s+(\S+)\s+\$end/){
        $current_hierarchy=$2;
        push(@hierarchy_array,$current_hierarchy);
		if($hierarchy eq "") {
			$hierarchy=$current_hierarchy;
		}else{
			$hierarchy="${hierarchy}/$current_hierarchy";
		}
        if($start==1) {
            $inst="$hierarchy\n";    
            $inst=~s/\Q${topinst}\E\///;
            $pending_write=1;
            $curr_instance=$inst;
            #print rtl_inst $inst;
        }
		if($hierarchy eq $topinst) {
			print "found FRONT_PATH $hierarchy\n";
			#$start=1 if($finish==0);
			$start=1;
			$finish=0;
		}
		#print "current hierarchy = $hierarchy start=$start finish=$finish\n";
	} elsif ($_=~/\$upscope\s+\$end/) {
        if($pending_write) {
            print rtl_inst $curr_instance;
            $pending_write=0;
        }
		$finish=1 if($hierarchy eq $topinst);
		$start =0 if($hierarchy eq $topinst);
        $current_hierarchy = pop(@hierarchy_array);
        if($hierarchy=~m/\//){
            $hierarchy=~m/(.*)\/\Q${current_hierarchy}\E/;
		    $hierarchy=$1;
        }else{
            $hierarchy="";
        }
		#print "current hierarchy = $hierarchy start=$start finish=$finish\n";
	} elsif (($start==1) && ($finish==0) && ($_=~m/\$var reg\s+-{0,1}\d+\s+\S+\s+(\S+)\s+(.*)\s{0,1}\[(-{0,1}\d+):(-{0,1}\d+)\] \$end/)){
##made a change here to consider 2D array with space between []. \s{0,1}. Atleast 0, or atmost 1 expected
		$name=$1 . $2;
		if($3>$4){
			$max=$3;
			$min=$4;
		}else{
			$max=$4;
			$min=$3;
		}

		for($j=$min;$j<=$max;$j++){
			if($hierarchy eq "") {
				$out="${name}\[$j\]\n";
			}else{
				$out="${hierarchy}/${name}\[$j\]\n";
			}
        $out=~s/\Q${topinst}\E\///;
		print rtl_regs $out;
		}
	} elsif (($start==1) && ($finish==0) && ($include_rtl_wire==1) && ($_=~m/\$var wire\s+-{0,1}\d+\s+\S+\s+(\S+)\s+(.*)\s{0,1}\[(-{0,1}\d+):(-{0,1}\d+)\] \$end/)){
		$name=$1 . $2;
		if($3>$4){
			$max=$3;
			$min=$4;
		}else{
			$max=$4;
			$min=$3;
		}

		for($j=$min;$j<=$max;$j++){
			if($hierarchy eq "") {
				$out="${name}\[$j\]\n";
			}else{
				$out="${hierarchy}/${name}\[$j\]\n";
			}
        $out=~s/\Q${topinst}\E\///;
		print rtl_regs $out;
		}

	} elsif (($start==1) && ($finish==0) && ($_=~m/\$var reg\s+1\s+\S+\s+(\S+.*)\$end/)){
		$var=$1;
		while ($var=~m/\s/) {
      $var=~s/\s+//;
    }
		#if ($var=~m/(\S+)\s+(\[\d+\])/) {
		#	$var="$1" . "$2"
		#} elsif ($var=~m/(\S+)\s+/) {
		#	$var=$1;
		#} 
		if($hierarchy eq "") {
			$out="$var\n";
		}else{
			$out="${hierarchy}/$var\n";
		}
        $out=~s/\Q${topinst}\E\///;
		print rtl_regs $out;
	} elsif (($start==1) && ($finish==0) && ($include_rtl_wire==1) && ($_=~m/\$var wire\s+1\s+\S+\s+(\S+.*)\$end/)){
		$var=$1;
		while ($var=~m/\s/) {
      $var=~s/\s+//;
    }
		#if ($var=~m/(\S+)\s+(\[\d+\])/) {
		#	$var="$1" . "$2"
		#} elsif ($var=~m/(\S+)\s+/) {
		#	$var=$1;
		#} 
		if($hierarchy eq "") {
			$out="$var\n";
		}else{
			$out="${hierarchy}/$var\n";
		}
        $out=~s/\Q${topinst}\E\///;
		print rtl_regs $out;		
	}
}
close $rtl_regs;
#$var reg 1 $ en $end
#$var reg 32 % in00 [31:0] $end:
