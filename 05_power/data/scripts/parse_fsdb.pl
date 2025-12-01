# NOTE:
# There can be following kind of upscope:
# vcd_module
# vcd_generate
# vhdl_architecture

# vcd_task
# vhdl_block
# vhdl_for_generate
# vhdl_if_generate
# vcd_fork
# vcd_function
# vcd_begin
# vcd_task
# sv_interface
# Only vcd_module and vcd_generate are actual logical hierarchy.

%cmd=@ARGV;

if(@ARGV != 12){
    print "Usage :\n\t$0 -fsdb_file <rtl_fsdb> -topinst <rtl_top_in_fsdb> -run_dir <map_run_dir_path> -out_reg <out_reg_file> -out_inst <out_instance_file> -rule_file <rule_file>\n";
    exit(1);
}

$topinst = $cmd{-topinst};
$fsdb_file = $cmd{-fsdb_file};
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
# convert /top/block/ to top/block
if($topinst=~/^\/(.*)/) {
    $topinst=$1;
}
if($topinst=~/(.*)\/$/){
    $topinst=$1;
}

$hierarchy="";
$start=0;
$finish=0;
$ignore_hierarchy=0;
$pending_write = 0;
$curr_instance = "";
open (fsdb_file, "<", "$fsdb_file") or die "didnt find FSDB file\n";
open (rtl_regs, ">", $out_reg  ) or die "couldnt open output rtl regs file\n";
open (rtl_inst, ">", $out_inst ) or die "couldnt open output rtl insts file\n";
while(<fsdb_file>) {
	chomp;
    if($_=~/Scope: (\S+) (\S+)/){
        $current_hierarchy=$2;
        # Remove "\" 
        if ($current_hierarchy=~m/\\(\S+)/) {
          $current_hierarchy=$1;
        }
        push(@hierarchy_array,$current_hierarchy);
		if($hierarchy eq "") {
			$hierarchy=$current_hierarchy;
		}else{
			$hierarchy="${hierarchy}/$current_hierarchy";
		}
		#print "hierarchy=$hierarchy start=$start, finish=$finish line=$_\n";
        		if(($start==1)){
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
	} elsif ($_=~/Upscope:/) {
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
	} elsif (     ($start==1) && ($finish==0) && (($_=~/Var: vcd_reg ([^\]\[]+) l:0 r:0/) || ($_=~/Var: vhdl_signal ([^\]\[]+) l:0 r:0/) || (($include_rtl_wire==1) && ($_=~/Var: vcd_wire ([^\]\[]+) l:0 r:0/)) )     ) {
		if($hierarchy eq "") {
			$out="$1\n";
		}else{
			$out="${hierarchy}/$1\n";
		}
        		$out=~s/\Q${topinst}\E\///;
		print rtl_regs $out;
	} elsif (    ($start==1) && ($finish==0) &&    (($_=~/Var: vcd_reg (\S+)\s{0,1}\[-{0,1}\d+:-{0,1}\d+\] l:(-{0,1}\d+) r:(-{0,1}\d+)/) || ($_=~/Var: vhdl_signal (\S+)\s{0,1}\[-{0,1}\d+:-{0,1}\d+\] l:(-{0,1}\d+) r:(-{0,1}\d+)/) || (($include_rtl_wire==1) && ($_=~/Var: vcd_wire (\S+)\s{0,1}\[-{0,1}\d+:-{0,1}\d+\] l:(-{0,1}\d+) r:(-{0,1}\d+)/))  )        ) {
		if($2>$3){
			$max=$2;
			$min=$3;
		}else{
			$max=$3;
			$min=$2;
		}
		$name=$1;
		for($j=$min;$j<=$max;$j++){
			if($hierarchy eq "") {
				$out="${name}\[$j\]\n";
			}else{
				$out="${hierarchy}/${name}\[$j\]\n";
			}
        $out=~s/\Q${topinst}\E\///;
		print rtl_regs $out;
		}	
	} elsif ($_=~/Var: vcd_reg /){
		#print "current hierarchy = $hierarchy start=$start finish=$finish and line=$_\n";
	}
}

close $rtl_regs;
#$var reg 1 $ en $end
#$var reg 32 % in00 [31:0] $end
