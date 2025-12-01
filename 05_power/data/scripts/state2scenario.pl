# $Revision: 1.5 
eval '(exit $?0)' && eval 'exec perl -S $0 ${1+"$@"}' 
&& eval 'exec perl -S $0 $argv:q' if 0;
#!/usr/local/bin/perl 
%cmd = @ARGV;
$dir = $cmd{-run_dir};
$power1 = $cmd{-power_start};
$power2 = $cmd{-power_end};
$clkcycles = $cmd{-clock_cycles};
$design = $cmd{-design_name};
$sim_time1 = $cmd{-clock_period};
$power_file = $cmd{-cycle_based_power};
$input = $cmd{-ipfile};
$vcdrun_only = $cmd{-vcdrun_only};
#$setup_only = $cmd{-setup_only};
$vcd_onerun = $cmd{-vcd_onerun};
$run_mode = $cmd{-run_mode};
$format = $cmd{-old_firingT_out};
$help1 = $cmd{-help};
$debug = $cmd{-debug};
$cpm = $cmd{-cpm};
if(!defined $run_mode){
    $run_mode = 1;
}
if(!defined $debug){
    $debug = 0;
}
if(!defined $dir){
    $dir = ".";
}
if(!defined $vcdrun_only){ 
    $vcdrun_only = 0 ;
}else{
    $vcdrun_only = 1;
}
  $help = "\nUsage:This script can be used in 3 modes.\nMode 1: vectorless and vcd/cpm runs execution will be in one RH session only to save run time by performing \"gsr setup , extraction\" only one time.Mode 1 again has two options like\n\t\t i) we can provide power targets in a file \n\t\t\t\tor\n\t\t ii) we can provide start_power,end_power,clock_cycles info to the tool\n Example:\n\t\t perl $0 -run_dir <run directory> -power_start <Power Number in watts> -power_end <Power Number in watts> -clock_cycles <No.of Clock Cycles> -design_name <Design name> -clock_period <clock period in ps> -run_mode 1;\n \t\t\t\t\t\tor\n  perl $0 -run_dir <run directory> -design_name <Design name> -clock_period <clock period in ps> -cycle_based_power <power_file> -run_mode 1;\n\npower_file format:\n\t<cycle_number>\t<power in watts>\n\t1\t\t0.2\n\t2\t\t0.4\n\tfor CPM (Chip Power Model) creation we can use \"-cpm 1\" switch\nExample: \n\t\t perl $0 -run_dir <run directory> -power_start <Power Number in watts> -power_end <Power Number in watts> -clock_cycles <No.of Clock Cycles> -design_name <Design name> -clock_period <clock period in ps> -run_mode 1 -cpm 1;\n \t\t\t\t\t\tor\n  perl $0 -run_dir <run directory> -design_name <Design name> -clock_period <clock period in ps> -cycle_based_power <power_file> -run_mode 1 -cpm 1;\n\npower_file format:\n\t<cycle_number>\t<power in watts>\n\t1\t\t0.2\n\t2\t\t0.4\n\n Mode 2: Tool creates n <No.of clock Cycles + 1> run directories and runs redhawk seperately. Those directory names are newrun.$n which are created parallel to run directory. Then it runs all vectorless runs in different run areas and later converts state.out files into scenario file.Finally it creates one more directory called final_run and performing scenario based simulation\n  Examples::\n\t\t perl $0 -run_dir <run directory> -power_start <Power Number in watts> -power_end <Power Number in watts> -clock_cycles <No.of Clock Cycles> -design_name <Design name> -clock_period <clock period in ps> -run_mode 2;\n \t\t\t\t\t\tor\n  perl $0 -run_dir <run directory> -design_name <Design name> -clock_period <clock period in ps> -cycle_based_power <power_file> -run_mode 2;\n\npower_file format:\n\t<cycle_number>\t<power in watts>\n\t1\t\t0.2\n\t2\t\t0.4\n\n for CPM (Chip Power Model) creation we can use \"-cpm 1\" switch\nExample: \n\t\t perl $0 -run_dir <run directory> -power_start <Power Number in watts> -power_end <Power Number in watts> -clock_cycles <No.of Clock Cycles> -design_name <Design name> -clock_period <clock period in ps> -run_mode 2 -cpm 1;\n \t\t\t\t\t\tor\n  perl $0 -run_dir <run directory> -design_name <Design name> -clock_period <clock period in ps> -cycle_based_power <power_file> -run_mode 2 -cpm 1;\n\npower_file format:\n\t<cycle_number>\t<power in watts>\n\t1\t\t0.2\n\t2\t\t0.4\n\n  Mode 3: It creates n <No. of clock cycles + 1> directories and will do the setup.So that user can go to each individual run and can run all RH runs paralally.Once it finishes user can use $0 -ipfile <inputfile> -vcdrun_only <1> to perform scenario based simulation in the directory final_run,which is parallel to run area.\nExamples:\n\t\t perl $0 -run_dir <run directory> -power_start <Power Number in watts> -power_end <Power Number in watts> -clock_cycles <No.of Clock Cycles> -design_name <Design name> -clock_period <clock period in ps> -run_mode 3;\n \t\t\t\t\t\tor\n  perl $0 -run_dir <run directory> -design_name <Design name> -clock_period <clock period in ps> -cycle_based_power <power_file> -run_mode <3> -setup_only <0/1>;\n\npower_file format:\n\t<cycle_number>\t<power in watts>\n\t1\t\t0.2\n\t2\t\t0.4\n\n for CPM (Chip Power Model) creation we can use -cpm 1 switch \n Example: $0 -ipfile <inputfile> -vcdrun_only 1 -cpm 1 to perform scenario based simulation ";
  if((defined $help1) || ($#ARGV < 1)){
      print "$help\n";
      exit(0);
  }
			#print "\n script output files : Creates n <No.of clock Cycles + 1> run directories and runs redhawk. Those directory names are newrun.$n which are created parallel to run directory.Then combines state.outs from all run directories and converts to apache.scenario file. Finally creating one more directory called final_run and performing vcd simulation in that area";
if (($vcdrun_only == 0) && ($run_mode == 1) && ($vcd_onerun != 1)) {
    if(!(((defined $power1) && (defined $dir) && (defined $power2) && (defined $clkcycles) && (defined $design) && (defined $sim_time1)) || ((defined $power_file) && (defined $dir) && (defined $sim_time1) && (defined $design)))){
        print "$help"; exit(0);
    }
			$sim_time = "$sim_time1"."e-12";
			$simtot = 0;
			$freq = 1/$sim_time;
			$power = $power1;
			$i = 0;
			$one = 0;
			$s = 0;
			if(-d "$ENV{PWD}/$dir/run_scripts/"){
          print "removing old $ENV{PWD}/$dir/run_scripts directory \n";
			   system "rm -rf $ENV{PWD}/$dir/run_scripts ";
			}
			system("mkdir -p $ENV{PWD}/$dir/run_scripts");
			    @gsr = <$ENV{PWD}/$dir/*.gsr>;   
			    $gsr1 = "$gsr[0]";
			    $temp = rindex($gsr1,"/");
			    $gsr = substr($gsr1,$temp+1);
			    if(!defined $gsr){
			        print "gsr file is missing in run area $dir\n";
			    }
#          print "step - $step; gsr - $gsr\n";
          if($debug == 0){
              $step = `egrep DYNAMIC_TIME_STEP $gsr | grep -v ^# | awk '{print \$2}'`;
              if($step == " "){
                $step = "20e-12";
              }else{
                  $step = $step * 2;
              }
           }
#$step = `egrep DYNAMIC_TIME_STEP $gsr | grep -v \# | awk '{print \$2}'`;
# print "step - $step \n";
			    @tcl = <$ENV{PWD}/$dir/*.tcl>;   
			    $tcl1 = "$tcl[0]";
			    $temp1 = rindex($tcl1,"/");
			    $tcl = substr($tcl1,$temp1+1);
			    if(!defined $tcl){
			        print "run.tcl file is missing in run area $dir\n";
			    }
			#system("cp $tcl $ENV{PWD}/$ENV{PWD}/$dir/myrun.tcl");
			    $gsr_orig = "$ENV{PWD}/$dir/$gsr".".orig";
			    print "original gsr file $gsr_orig\n";
			    system("cp $ENV{PWD}/$dir/$gsr $gsr_orig");
			    $first = 1;
			if(!defined $power_file){
			while("$power" <= "$power2"){
			    @bpfs = ""; pop(@bpfs);
			    open(tcl,">>$ENV{PWD}/$dir/run_scripts/myrun.tcl") || die "i am not able to open $ENV{PWD}/$dir/run_scripts/myrun.tcl .do i have RH run.tcl file in the $dir\n";
			    $i = $i + 1;
			    open(gsr,"$gsr_orig") || die "gsr $gsr_orig file cant be opened\n";
			#$gsrnew = "$dir"."/run_scripts/"."$gsr"."new";
			    open(gsrnew,">$gsr") || die "$gsr file cant be opened\n";
			    $count = 0;
			    $count_bpfs = 0;
			    while(<gsr>){
			    chomp;
			        if ($_ =~ /^#/){
			          print gsrnew "$_\n";
			          next;
			        };
			        if($_ =~ /^BLOCK_POWER/){
			         $count = 1;
			         $count_bpfs = 1;
			         next;
			        }
			        if ($count != 0){
			         if ($_ =~ /FULLCHIP\s+$design/) {
			         }elsif($_ =~ /^\}/){
			               push(@bpfs,"FULLCHIP $design $power");
			            $count = 0;
			            next;
			         }else{
			               push(@bpfs,"$_");
			               next;
			         }
			       }elsif($_ =~ /DYNAMIC_SIMULATION_TIME/){
			            print gsrnew "#$_\n";
			       }else{
			          print gsrnew "$_\n";
			      }
			    }
			    close(gsr);
			    if($count_bpfs != 1){
			#print gsrnew "BLOCK_POWER_FOR_SCALING {\n\tFULLCHIP $design $power\n}\n";
			       push(@bpfs,"FULLCHIP $design $power");
			    }
              if ($debug != 0){
      			        print gsrnew "DYNAMIC_SIMULATION_TIME $sim_time\n";
              }else{
      			        print gsrnew "DYNAMIC_SIMULATION_TIME $step\n";
              }
			        if($first == 1){
			            print tcl "setup design $gsr\n";
                  if ($debug != 0){
                      print tcl "gsr set DYNAMIC_SIMULATION_TIME $sim_time\n";
                  }else{
                        print tcl "gsr set DYNAMIC_SIMULATION_TIME $step\n";
                  }
			            print tcl "gsr set APACHE_FILES DEBUG\n";
			            print tcl "gsr set DYNAMIC_PRESIM_TIME 0\n";
			            print tcl "perform extraction -power -ground -c\n";
			            $first = 0;
			        }
			    print gsrnew "APACHE_FILES DEBUG\n";
			    print gsrnew "DYNAMIC_PRESIM_TIME 0\n";
			    close(gsrnew);
			        open(bpfs,">$ENV{PWD}/$dir/run_scripts/bpfs.$i.rpt") || die "$ENV{PWD}/$dir/run_scripts/bpfs.$i.rpt";
			        foreach (@bpfs){
			             print bpfs "$_";
			        }
			        close(bpfs);
			        print tcl "gsr set BLOCK_POWER_FOR_SCALING_FILE $ENV{PWD}/$dir/run_scripts/bpfs.$i.rpt\n";
			        print tcl "perform pwrcalc\n";
			        print tcl "perform analysis -vectorless\n";
              
		        print tcl "catch { exec cp $ENV{PWD}/$dir/.apache/state.out $ENV{PWD}/$dir/run_scripts/state.out.$i }\n";
			
			    open(input,">$ENV{PWD}/$dir/run_scripts/../input.$i") || die "$ENV{PWD}/$dir/run_scripts/../input.$i file cant be opened \n";
			      print input ". $sim_time1\n";
			    close(input);
			     $simtot = $simtot + $sim_time1;
			      print tcl "catch {exec perl $0 -run_mode 1 -vcd_onerun 1 -ipfile $ENV{PWD}/$dir/input.$i}\n";
			      print tcl "catch {exec cp $ENV{PWD}/$dir/run_scripts/apache.scenario.1 $ENV{PWD}/$dir/run_scripts/apache.scenario.1.$i}\n";
			    $power = $power1 + (($power2 - $power1)/$clkcycles) * $i;
			}
			}else{
			   open(pf,"$power_file") || die "power_file can not be opened \n";
			   $l = 0;
			       while(<pf>){
			             next if($_ =~ /^$/);
			             next if($_ =~ /^#/);
			            chomp;split;
			              $l++;
			            $hash{$l}{$_[0]} = $_[1];
			       }
			        close(pf);
			$lines = keys (%hash);
			$i = 0;
			  for ($j = 1; $j <= $lines; $j++){
			    @bpfs = ""; pop(@bpfs);
			      @one = keys (%{$hash{$j}});
			      if($j == $lines){
			        $cycles = 1;
			      }else{
			        @two = keys (%{$hash{$j+1}});
			        $cycles = $two[0] - $one[0];
			      }
			      $simtime1 = $cycles * $sim_time1;
			      $simtime = "$simtime1"."e-12";
			      $power = $hash{$j}{$one[0]};
			    open(tcl,">>$ENV{PWD}/$dir/run_scripts/myrun.tcl") || die "i am not able to open $ENV{PWD}/$dir/run_scripts/myrun.tcl .do i have RH run.tcl file in the $dir\n";
			    $i = $i + 1;
			            open(gsr,"$gsr_orig") || die "gsr $gsr_orig file cant be opened\n";
			            open(gsrnew,">$gsr") || die "$gsr file cant be opened\n";
			            $count = 0;
			            $count_bpfs = 0;
			            while(<gsr>){
			            chomp;
			                if ($_ =~ /^#/){
			                  print gsrnew "$_\n";
			                  next;
			                };
			                if($_ =~ /^BLOCK_POWER/){
			                 $count = 1;
			                 $count_bpfs = 1;
			                 next;
			                }
			                if ($count != 0){
			                 if ($_ =~ /FULLCHIP\s+$design/) {
			                 }elsif($_ =~ /\}/){
			                     push(@bpfs,"FULLCHIP $design $power");
			                    $count = 0;
			                 }else{
			                    push(@bpfs,"$_");
			                 }
			                 
			               }elsif($_ =~ /DYNAMIC_SIMULATION_TIME/){
			                    print gsrnew "#$_\n";
			               }else{
			                  print gsrnew "$_\n";
			              }
			            }
			            close(gsr);
			            if($count_bpfs != 1){
			                 push(@bpfs,"FULLCHIP $design $power");
			            }
			        if($first == 1){
			            print tcl "setup design $gsr\n";
			            print tcl "gsr set APACHE_FILES DEBUG\n";
			            print tcl "gsr set DYNAMIC_PRESIM_TIME 0\n";
			            print tcl "perform extraction -power -ground -c\n";
			            $first = 0;
			        }
			            print gsrnew "APACHE_FILES DEBUG\n";
			            print gsrnew "DYNAMIC_PRESIM_TIME 0\n";
                  if ($debug != 0){
                      print  gsrnew "DYNAMIC_SIMULATION_TIME $simtime\n";
                  }else{
                        print gsrnew "DYNAMIC_SIMULATION_TIME $step\n";
                  }
#print gsrnew "DYNAMIC_SIMULATION_TIME $simtime\n";
			            close(gsrnew);
			        open(bpfs,">$ENV{PWD}/$dir/run_scripts/bpfs.$i.rpt") || die "$ENV{PWD}/$dir/run_scripts/bpfs.$i.rpt";
			        foreach (@bpfs){
			             print bpfs "$_";
			        }
			       close(bpfs);
              if ($debug != 0){
      			        print tcl "gsr set DYNAMIC_SIMULATION_TIME $simtime\n";
              }else{
      			        print tcl "gsr set DYNAMIC_SIMULATION_TIME $step\n";
              }
#print tcl "gsr set DYNAMIC_SIMULATION_TIME $simtime\n";
			        print tcl "gsr set BLOCK_POWER_FOR_SCALING_FILE $ENV{PWD}/$dir/run_scripts/bpfs.$i.rpt\n";
			        print tcl "perform pwrcalc\n";
			        print tcl "perform analysis -vectorless\n";
#			        print tcl "catch {exec cp $ENV{PWD}/$dir/.apache/state.out $ENV{PWD}/$dir/run_scripts/state.out.$i}\n";
			    open(input,">$ENV{PWD}/$dir/input.$i") || die "$ENV{PWD}/$dir/input.$i file cant be opened \n";
			      print input ". $simtime1\n";
			    close(input);
			     $simtot = $simtot + $simtime1;
			      print tcl "catch {exec perl $0 -run_mode 1 -vcd_onerun 1 -ipfile $ENV{PWD}/$dir/input.$i}\n";
            print tcl "catch {exec cp $ENV{PWD}/$dir/run_scripts/apache.scenario.1 $ENV{PWD}/$dir/run_scripts/apache.scenario.1.$i}\n";
			    }
			}
			
			system("cat $ENV{PWD}/$dir/run_scripts/header $ENV{PWD}/$dir/run_scripts/apache.scenario.2 > $ENV{PWD}/$dir/run_scripts/apache.scenario");
			 $sim_timef = "$simtot"."e-12";
  print tcl "gsr set DYNAMIC_SIMULATION_TIME $sim_timef\n";
			 print tcl "perform powercalc\n";
#print tcl "perform extraction -power -ground -c\n";
			print tcl "catch {exec  cat $ENV{PWD}/$dir/run_scripts/header $ENV{PWD}/$dir/run_scripts/apache.scenario.2 > $ENV{PWD}/$dir/run_scripts/apache.scenario}\n";
			 if(defined $cpm){
              print  tcl "gsr set DYNAMIC_SIMULATION_TIME 25e-12\n";
              print tcl "catch { exec cp $ENV{PWD}/$dir/run_scripts/apache.scenario  $ENV{PWD}/$dir/.apache/.}\n";
              print tcl "perform powermodel -nx 1 -ny 1 -pincurrent\n";
              $cpm_cmd = `egrep "perform powermodel" $tcl | grep -v ^#`;
              print tcl "gsr set DYNAMIC_SIMULATION_TIME $sim_timef\n";
              print "cpm command : $cpm_cmd \n";
       #print tcl "proc change_asim_cpm \{ args \} \{\n";
              print tcl "set new_start_sim_end_time $simtot\n";
              print tcl "set enter_loop 0\n";
              print tcl "if \{ \[file exists .apache/.run.setting \] \} \{\n";
              print tcl "set fp \[ open \".apache/.run.setting\" r \]\n";
              print tcl "set new_line \"\"\n";
              print tcl "set gap \" \"\n";
              print tcl "while \{ \[ gets \$fp line \] >= 0 && \$enter_loop == 0\} \{\n";
              print tcl "if \{ \[ regexp -all \"asim_cpm\" \$line \] \} \{\n";
              print tcl "set enter_loop 1\n";
              print tcl "regsub -all \{\t\}  \$line \" \" line1\n";
              print tcl "        regsub -all -- \{\[\[:space:\]\]+\} \$line1 \" \" line2\n";
              print tcl "set words \[ split \$line2 \]\n";
              print tcl "for \{ set i 0 \} \{ \$i < \[ llength \$words \] \} \{ incr i \} \{\n";
              print tcl "set word \[ lindex \$words \$i \]\n";
              print tcl "if \{ \$word eq \"-st\" \} \{\n";
              print tcl "set replaced_index \[ expr \$i + 2 \]\n";
              print tcl "set start_replace 1\n";
              print tcl "set new_line \$new_line\$gap\$word\n";
              print tcl "\} else \{\n";
              print tcl "if \{ !\[ info exists start_replace \] || \$i != \$replaced_index \} \{\n";
              print tcl "set new_line \$new_line\$gap\$word\n";
              print tcl "\} else \{\n";
              print tcl "set new_line \$new_line\$gap\$new_start_sim_end_time\n";
              print tcl "unset start_replace\n";
              print tcl "\}\n";
              print tcl "\}\n";
              print tcl "\}\n";
              print tcl "\}\n";
              print tcl "\}\n";
              print tcl "\}\n";
              print tcl "close \$fp\n";
              print tcl "regsub -all \"asim_cpm\" \$new_line \"asim_cpm_vcd\" new_line1 \n";
              print tcl "set f1 \[ open \"./run_scripts/cpm.cmd\" w \]\n";
              print tcl "puts \$f1 \"catch {exec \$new_line1 }\" \n";
              print tcl "close \$f1\n";
              print tcl "source ./run_scripts/cpm.cmd\n";
              
           }else{
      			 print  tcl "perform analysis -vcd -scenario $ENV{PWD}/$dir/run_scripts/apache.scenario\n";
           }
			 close(tcl);
       chdir("$ENV{PWD}/$dir");			
       system("redhawk -f $ENV{PWD}/$dir/run_scripts/myrun.tcl");
}
if ($vcd_onerun == 1) {
    if(!((defined $input) && (defined $run_mode))){
          print "Provide the input file/run_mode to do scenario based simulation only.\n";
          print "input file format;\n\t\t./../directory_name1\t0.2\n\t\t./../directory_name2\t0.4\n\t\t./../directory_name3\t0.5\n";
          print "Example: perl $0 -vcd_onerun 1 -run_mode 1/2 -ipfile ./input.txt\n";
          exit(0);
      }
		#$input = $cmd{-ipfile};
		system("mkdir -p $ENV{PWD}/$dir/run_scripts");
		$op = "$ENV{PWD}/$dir"."/run_scripts". "/apache.scenario.1";
		open(output,">$op") || die "output $op file can't be opened\n";
		$sim_time = 0;
		$sim_prev = 0;
		$count1 = 0;
		$count = 0;
		$pin = "ck";
		print "input file - $input\n";
    if ($run_mode == 1){
        $n = rindex($input,"\.");
        $i = substr($input,$n+1);
        $k = $i - 1;
    }
		#print "i -- $i";
		open(in,"$input") || die "input $input file - input file cant be opened\n";
		    while(<in>){
		        chomp;
		        split;
		        $sim_time1 = $_[1];
             if($_[0] =~ /^\//){
		          $run_vector = $_[0];
            }else{
              $run_vector = "$ENV{PWD}/$dir/$_[0]";
            }
            $file = "$run_vector"."/.apache/state.out";
            open(state,"$file") || die "file $file cant be opened \n";
             while(<state>){
                     chomp;split;
                     if(($_[1] == 3) || ($_[1] == 4) || ($_[1] == 7) || ($_[1] == 8) || ($_[1] == 16)) {
                     $hash_state{$_[0]} = $_[1];$hash_sw{$_[0]} = $_[2];
                     }
             }
            close(state);
		        system("gunzip -c $run_vector/.apache/inst_tw.out.gz > $ENV{PWD}/$dir/run_scripts/inst_tw");
		        open(tw,"$ENV{PWD}/$dir/run_scripts/inst_tw") || die "TW $ENV{PWD}/$dir/.apache/inst_tw.out.gz file cant be opened \n";
		            while(<tw>){
		                chomp;split;
                    if (defined $hash_state{$_[0]}){
		                $hash_tw{$_[0]} = $_[4];
		                if (defined $_[5]){
		                    $hash_rf{$_[0]} = $_[5];
		                }
                  }
		            }    
		        close(tw);
		        @imap = <$run_vector/.apache/apache.imap>;
		        $imap = $imap[0];
		        open(imap,"$imap") || die "\nimap $imap file cant be opened\n";
		          while(<imap>){
		            chomp;split;
                if (defined $hash_state{$_[0]}){
		            $hash_map{$_[0]} = $_[1] ;
                $hash_id{$_[1]} = $_[0] ;
                }
#$hash_map{$_[1]} = $_[0] ;
		          }
		        close(imap);
		        @power = <$run_vector/adsPower/*.power>;
		        $power = $power[0];                    
		        open(power,"$power")|| die "power $power file cant be opened\n";
		          while(<power>){
		            if($_ =~ /^$/){next;}
		            chomp;split;
                 if (defined $hash_state{$hash_id{$_[0]}}){
		                 $hash_pin{$_[0]} = $_[19];
		                 $hash_ptype{$_[0]} = $_[2];
                  }
		           }
		        close(power);
		        $pwr = "$run_vector/.apache/apache.pwr";
		        open(pwr,"$pwr")|| die "$pwr file cant be opened\n";
		          while(<pwr>){
		            next if($_ !~ /^[1-9]/);
		            chomp;split;
                  if (defined $hash_state{$_[0]}){
		            $hash_clkpin_minD{$_[0]} = $_[20];
		            $hash_clkpin_maxD{$_[0]} = $_[21];
                }
		        }
		        close(pwr);
#$file = "$ENV{PWD}/$dir/$run_dir"."/.apache/state.out";
          if ($run_mode == 1){
		        $simtime_f = "$ENV{PWD}/$dir/run_scripts/simtime".".$k";
           if(-e "$simtime_f"){
		          $sim_time = `cat $simtime_f`;
		          $sim_time =~ chomp($sim_time);
		        }
          }
		        $sim_prev = $sim_time ;
		        $sim_time = int($sim_time + $sim_time1); 
          if ($run_mode == 1){
		        open(simtime,">$ENV{PWD}/$dir/run_scripts/simtime.$i");
		          print simtime "$sim_time";
		        close(simtime);
          }
		        $file_tw1 = "$run_vector"."/.apache/firingT.out.gz";
		        system("gunzip -c $file_tw1 > $ENV{PWD}/$dir/run_scripts/file_tw");
		        open(tw,"$ENV{PWD}/$dir/run_scripts/file_tw")|| die "TW $ENV{PWD}/$dir/run_scripts/file_tw cant be opened \n";
		          while(<tw>){
		              chomp;split;
                   if (defined $hash_state{$_[0]}){

		              $hash_delay{$_[0]}{c01} = $_[1];
                  	if(defined $format){
		              $hash_delay{$_[0]}{c10} = $_[1];
		              $hash_delay{$_[0]}{clk} = $_[1];
                  }else{
		              $hash_delay{$_[0]}{c10} = $_[2];
		              $hash_delay{$_[0]}{clk} = $_[3];
                  }
                  }
		          }
		        close(tw);
          if ($run_mode == 1){
		        if(-s "$ENV{PWD}/$dir/run_scripts/states.txt"){
		            open(states1,"$ENV{PWD}/$dir/run_scripts/states.txt") || die "$ENV{PWD}/$dir/run_scripts/states.txt file cant be opened\n";
		            while(<states1>){
		                chomp;split;
		                if($_ =~ /clk/){ $clk{$_[0]} = $_[2] }           
		                if($_ =~ /output/){ $charge{$_[0]} = $_[2] }           
		             }
		            close(states1);
		        }
		            open(states,"> $ENV{PWD}/$dir/run_scripts/states.txt") || die "$ENV{PWD}/$dir/run_scripts/states.txt file cant be opened\n";
           }    
		        

            foreach  $id (keys %hash_state){
          if(defined $hash_map{$id}) {

		                 $inst = $hash_map{$id};
		                     $cycle = int($hash_tw{$id});
		                 if ($hash_state{$id} == 3 || $hash_state{$id} == 4 || $hash_state{$id} == 7 || $hash_state{$id} == 8){
		                     $switchtime_clk = int($hash_sw{$id} + $hash_delay{$id}{clk});
		                 }
		                 if ($hash_state{$id} == 3 || $hash_state{$id} == 4 || $hash_state{$id} == 7 || $hash_state{$id} == 8){
		                        if(!defined $clk{$inst}){
		                                $avg = ($hash_clkpin_minD{$id} + $hash_clkpin_maxD{$id})/2;
		                                $clk_pt5_period = $hash_tw{$id}/2;
		                                if($avg >= $clk_pt5_period){
		                                    $clk{$inst} = "c00"; 
		                                }else{
		                                    $clk{$inst} = "c11"; 
		                                }
		                            }elsif($clk{$inst} eq "c00"){
		                                $clk{$inst} = "c11"; 
		                            }else{
		                                $clk{$inst} = "c00"; 
		                                }
		                   }
		                if($hash_state{$id} == 7){
		                     $pin = ck;
		                }elsif($hash_state{$id} == 8){
		                      $pin = ck;
		                  }elsif ($hash_state{$id} == 3){
		                     if (!defined $charge{$inst}){
		                      $charge{$inst} = "c01";
		                         $switchtime = int($hash_sw{$id} + $hash_delay{$id}{c01});
		                     }elsif($charge{$inst} eq "c01"){
		                         $charge{$inst} = "c10"; 
		                         $switchtime = int($hash_sw{$id} + $hash_delay{$id}{c10});
		                        }else{
		                         $charge{$inst} = "c01"; 
		                         $switchtime = int($hash_sw{$id} + $hash_delay{$id}{c01});
		                        }
		                      $pin = $hash_pin{$inst};
		                 }elsif ($hash_state{$id} == 4){
		                     if (!defined $charge{$inst}){
		                      $charge{$inst} = "c10";
		                         $switchtime = int($hash_sw{$id} + $hash_delay{$id}{c10});
                                    print "0. inst - $inst ; i.d - $id ; charge - $charge{$inst}, sw - $switchtime\n";
		                     }elsif($charge{$inst} eq "c10"){
		                         $charge{$inst} = "c01"; 
		                         $switchtime = int($hash_sw{$id} + $hash_delay{$id}{c01});
		                        }else{
		                         $charge{$inst} = "c10"; 
		                         $switchtime = int($hash_sw{$id} + $hash_delay{$id}{c10});
		                        }
		                      $pin = $hash_pin{$inst};
		                  }elsif ($hash_state{$id} == 16){
		                      if($hash_rf{$id} == 1){
		                     if (!defined $charge{$inst}){
		                           $charge{$inst} = "c01";
		                         $switchtime = int($hash_sw{$id} + $hash_delay{$id}{c01});
		                        }elsif($charge{$inst} eq "c01"){
		                         $charge{$inst} = "c10"; 
		                         $switchtime = int($hash_sw{$id} + $hash_delay{$id}{c10});
		                        }else{
		                         $charge{$inst} = "c01";
		                         $switchtime = int($hash_sw{$id} + $hash_delay{$id}{c01});
		                        }
		                           $pin = $hash_pin{$inst};
		                      }else{
		                         if (!defined $charge{$inst}){
		                                $charge{$inst} = "c10";
		                         $switchtime = int($hash_sw{$id} + $hash_delay{$id}{c10});
		                         }elsif($charge{$inst} eq "c10"){
		                             $charge{$inst} = "c01"; 
		                         $switchtime = int($hash_sw{$id} + $hash_delay{$id}{c01});
		                            }else{
		                                $charge{$inst} = "c10";
		                         $switchtime = int($hash_sw{$id} + $hash_delay{$id}{c10});
		                            }
		                                $pin = $hash_pin{$inst};
		                      }
		                  }else{
		                       next;
		                   }
		                  if ($i > 1){
		                            $switchtime = int($switchtime + $sim_prev);
		                   }
		                      $count = 0;
		                      $count_7 = 0;
		 $count_8 = 0;
		                      $count_clk = 0;
		                              $charge_ck = int($switchtime_clk + $sim_prev);
		                              $cycle1 = int($cycle/2);
		                              $repeat = 0;
                                  if($cycle1 != 0){
		            for ($j = $charge_ck ; $j <= $sim_time ; $j = $j + $cycle1){
		                            if(($hash_sw{$id} < 0) && ($sim_prev > 0) && ($repeat == 0)){
		                                $repeat = 1;
		                                next;
		                              }
		                            
		                          if(($hash_state{$id} == 3) || ($hash_state{$id} == 4)){
		                              if($hash_ptype{$id} != 0){
		                                if($count_clk == "0") { 
		                                    $count_clk = 1;
		                                }else{
		                                  if($clk{$inst} eq "c00"){
		                                      $clk{$inst} = "c11";
		                                  }elsif($clk{$inst} eq "c11"){
		                                      $clk{$inst} = "c00";
		                                  }
		                                }
                          if($id == 1241664){
                                    print "1. inst - $inst ; i.d - $id ; \n";
                          }
		                                    print output "$inst $clk{$inst} $j ck\n";
                                    if ($run_mode == 1){
		                                    print states "$inst clk $clk{$inst}\n";
                                    }
		                            }
		                          }elsif($hash_state{$id} == 7){
		                                if($count_7 == 0) { 
		                                    $count_7 = 1;
		                                 }else{
		                                  if($clk{$inst} eq "c00"){
		                                      $clk{$inst} = "c11";
		                                  }elsif($clk{$inst} eq "c11"){
		                                      $clk{$inst} = "c00";
		                                  }
		                                }
		                                    print output "$inst $clk{$inst} $j ck\n";
		                                    print states "$inst clk $clk{$inst}\n";
		                          }elsif($hash_state{$id} == 8){
		                                if($count_8 == "0") { 
		                                    $count_8 = 1;
		                                }else{
		                                  if($clk{$inst} eq "c11"){
		                                      $clk{$inst} = "c00";
		                                  }elsif($clk{$inst} eq "c00"){
		                                      $clk{$inst} = "c11";
		                                  }
		                                }
		                                    print output "$inst $clk{$inst} $j ck\n";
                                      if ($run_mode == 1){
		                                    print states "$inst clk $clk{$inst}\n";
                                      }
		                          }
		                        }
        }else{
          if(($hash_sw{$id} < 0) && ($sim_prev > 0) && ($repeat == 0)){
		                                $repeat = 1;
		                                next;
		                              }
		                            
		                          if(($hash_state{$id} == 3) || ($hash_state{$id} == 4)){
		                              if($hash_ptype{$id} != 0){
		                                if($count_clk == "0") { 
		                                    $count_clk = 1;
		                                }else{
		                                  if($clk{$inst} eq "c00"){
		                                      $clk{$inst} = "c11";
		                                  }elsif($clk{$inst} eq "c11"){
		                                      $clk{$inst} = "c00";
		                                  }
		                                }
		                                    print output "$inst $clk{$inst} $charge_ck ck\n";
		                            }
		                          }elsif($hash_state{$id} == 7){
		                                if($count_7 == 0) { 
		                                    $count_7 = 1;
		 }else{
		                                  if($clk{$inst} eq "c00"){
		                                      $clk{$inst} = "c11";
		                                  }elsif($clk{$inst} eq "c11"){
		                                      $clk{$inst} = "c00";
		                                  }
		                                }
		                                    print output "$inst $clk{$inst} $charge_ck ck\n";
		                          }elsif($hash_state{$id} == 8){
		                                if($count_8 == "0") { 
		                                    $count_8 = 1;
		                                }else{
		                                  if($clk{$inst} eq "c11"){
		                                      $clk{$inst} = "c00";
		                                  }elsif($clk{$inst} eq "c00"){
		                                      $clk{$inst} = "c11";
		                                  }
		                                }
	                                    print output "$inst $clk{$inst} $charge_ck ck\n";
                                  

                  }
          }
		            if($cycle != 0) {
                     if($hash_state{$id} == 3 || $hash_state{$id} == 4 || $hash_state{$id} == 16){
		              for ($i = $switchtime;$i <= $sim_time;$i = $i + $cycle){
		                   if($count == "0"){
		                      $count = 1;
		                    } else {
		                      if($charge{$inst} eq "c00"){
		                          $charge{$inst} = "c00" ;
		}elsif($charge{$inst} eq "c11"){
		                           $charge{$inst} = "c11" ;
		                      }elsif($charge{$inst} eq "c01"){
		                          $charge{$inst} = "c10" ;
		                      }elsif($charge{$inst} eq "c10"){ 
		                          $charge{$inst} = "c01" ;
		                      }
		                  }
		                  if (defined $charge{$inst}){
		                          print output "$inst $charge{$inst} $i $pin\n";
                                      if ($run_mode == 1){
		                          print states "$inst output $charge{$inst}\n";
                                      }
		                  }
		               }
		              }
                }else {
                  if($hash_state{$id} == 3 || $hash_state{$id} == 4 || $hash_state{$id} == 16){
		                   if($count == "0"){
		                      $count = 1;
		                    } else {
		                      if($charge{$inst} eq "c00"){
		                          $charge{$inst} = "c00" ;
		                      }elsif($charge{$inst} eq "c11"){
		                           $charge{$inst} = "c11" ;
		                      }elsif($charge{$inst} eq "c01"){
		                          $charge{$inst} = "c10" ;
		                      }elsif($charge{$inst} eq "c10"){ 
		                          $charge{$inst} = "c01" ;
		                      }
		                  }
		                  if (defined $charge{$inst}){
		                          print output "$inst $charge{$inst} $switchtime $pin\n";
		                  }
		          }
            }
        }
        }
		          $count1 = $count1 + 1;
               %hash_rf = %hash_pin = %hash_ptype = %hash_delay = %hash_clkpin_avg = %hash_state = ();

		 }
		close(in);
		close(output);
		close(states);
		`mv $op $op.orig`;
open(ip,"$op.orig") || die "$op.orig can not be opened for reading\n";
open(op,">$op") || die "$op can not be opened for writing\n";
while(<ip>){
	chop;split;
      $hash{$_[2]}{$_[0]} = "$_[0]"."  "."$_[1]"."  "."$_[3]" ;
}
close(ip);
foreach $d (sort {$a<=>$b} keys %hash){
     foreach $inst (keys %{$hash{$d}}) {
     @values = split(/\s+/,$hash{$d}{$inst});
	print op "$values[0]  $values[1]  $d  $values[2]\n";
    }
}
    
#		`sort -n -k3 $op.orig > $op`;
		open(ip,">$ENV{PWD}/$dir/run_scripts/header")||die "$ENV{PWD}/$dir/run_scripts/header file cant be opened in run area\n";
		        print ip "#### switching scenario v.1 (true timing)\n";
		        print ip "#../../design_data/vcd/GENERIC.vcd -tt -msg .apache/vcd_output.msg -f $sim_time1 -w \"test_bench1/GENERIC/\" \"\" -s 0 -e $sim_time -a 0 $sim_time\n";
		        print ip "# frame size $sim_time1\n";
		close(ip);
		system("touch $ENV{PWD}/$dir/run_scripts/apache.scenario.2");
		system("cat $ENV{PWD}/$dir/run_scripts/apache.scenario.1 >> $ENV{PWD}/$dir/run_scripts/apache.scenario.2");
}

if ($run_mode == 2){
		    if(!(((defined $power1) && (defined $dir) && (defined $power2) && (defined $clkcycles) && (defined $design) && (defined $sim_time1)) || ((defined $power_file) && (defined $dir) && (defined $sim_time1) && (defined $design)))){
		        print "$help"; exit(0);
		    }
		$sim_time = "$sim_time1"."e-12";
		$freq = 1/$sim_time;
		$power = $power1;
		$i = 0;
		$one = 0;
		$s = 0;
		if(!defined $power_file){
		
		while("$power" <= "$power2"){
		    $i = $i + 1;
		    $file = "newrun.$i";
		    if (-e "$ENV{PWD}/$dir/../$file"){  
		        system("rm -rf $ENV{PWD}/$dir/../$file");
		    }
		    system("mkdir $ENV{PWD}/$dir/../$file");
		    system("mkdir $ENV{PWD}/$dir/../$file/run_scripts");
		    print "new directory $ENV{PWD}/$dir/../$file created \n";
		    @gsr = <$ENV{PWD}/$dir/*.gsr>;   
		    $gsr1 = "$gsr[0]";
		    $temp = rindex($gsr1,"/");
		    $gsr = substr($gsr1,$temp+1);
		    @tcl = <$ENV{PWD}/$dir/*.tcl>;   
		    $tcl1 = "$tcl[0]";
		    $temp1 = rindex($tcl1,"/");
		    $tcl = substr($tcl1,$temp1+1);
		    system("cp $tcl1 $ENV{PWD}/$dir/../$file/.");
		    open(gsr,"$gsr[0]") || die "gsr $gsr[0] file cant be opened\n";
          if($debug == 0){
              $step = `egrep DYNAMIC_TIME_STEP $gsr[0] | grep -v ^# | awk '{print \$2}'`;
              if($step == " "){
                $step = "20e-12";
              }else{
                  $step = $step * 2;
              }
           }
		    $gsrnew = "$ENV{PWD}/$dir/../$file/$gsr";
		    open(gsrnew,">$gsrnew") || die "$gsrnew file cant be opened\n";
		    $count = 0;
		    $count_bpfs = 0;
		    while(<gsr>){
		    chomp;
		        if ($_ =~ /^#/){
		          print gsrnew "$_\n";
		          next;
		        };
		        if($_ =~ /^BLOCK_POWER/){
		         $count = 1;
		         $count_bpfs = 1;
		        }
		        if ($count != 0){
		         if ($_ =~ /FULLCHIP\s+$design/) {
		         }elsif($_ =~ /\}/){
		            print gsrnew "FULLCHIP $design $power\n}\n";
		            $count = 0;
		         }else{
		            print gsrnew "$_\n";
		         }
		         
		       }elsif($_ =~ /DYNAMIC_SIMULATION_TIME/){
		            print gsrnew "#$_\n";
		       }else{
		          print gsrnew "$_\n";
		      }
		    }
		    close(gsr);
		    if($count_bpfs != 1){
		      print gsrnew "BLOCK_POWER_FOR_SCALING {\n\tFULLCHIP $design $power\n}\n";
		    }
              if ($debug != 0){
      			        print gsrnew "DYNAMIC_SIMULATION_TIME $sim_time\n";
              }else{
      			        print gsrnew "DYNAMIC_SIMULATION_TIME $step\n";
              }
#print gsrnew "DYNAMIC_SIMULATION_TIME $sim_time\n";
		    print gsrnew "APACHE_FILES DEBUG\n";
		    print gsrnew "DYNAMIC_PRESIM_TIME 0\n";
		    close(gsrnew);
		    $newdir = "$ENV{PWD}/$dir/../$file";
		    chdir "$newdir";
        print "present run directory is $newdir\n";
		    system("redhawk -b $tcl");
		    if($s == 0){
		        if (-e "$ENV{PWD}/$dir/../input"){ 
		            system"rm $ENV{PWD}/$dir/../input";
		        }
		      $s = 1;
		    } 
		    open(input,">>$ENV{PWD}/$dir/../input") || die "$ENV{PWD}/$dir/../input file cant be opened \n";
		      print input "../$file $sim_time1\n";
		    close(input);
		    $power = $power1 + (($power2 - $power1)/$clkcycles) * $i;
		}
		}else{
		    $cycle_pr = 0;
		   open(pf,"$power_file") || die "power_file can not be opened \n";
		   $l = 0;
		       while(<pf>){
		             next if($_ =~ /^$/);
		             next if($_ =~ /^#/);
		            chomp;split;
		              $l++;
		            $hash{$l}{$_[0]} = $_[1];
		       }
		        close(pf);
		$lines = keys (%hash);
		$i = 0;
		  for ($j = 1; $j <= $lines; $j++){
		      @one = keys (%{$hash{$j}});
		      if($j == $lines){
		        $cycles = 1;
		      }else{
		        @two = keys (%{$hash{$j+1}});
		        $cycles = $two[0] - $one[0];
		      }
		      $simtime1 = $cycles * $sim_time1;
		      $simtime = "$simtime1"."e-12";
		      $power = $hash{$j}{$one[0]};
		      $i++;
		           
		            $file = "newrun.$i";
		            if (-e "$ENV{PWD}/$dir/../$file"){  
		                system("rm -rf $ENV{PWD}/$dir/../$file");
		            }
		            system("mkdir $ENV{PWD}/$dir/../$file");
		            print "new directory $ENV{PWD}/$dir/../$file created \n";
		            @gsr = <$ENV{PWD}/$dir/*.gsr>;   
		            $gsr1 = "$gsr[0]";
		            $temp = rindex($gsr1,"/");
		            $gsr = substr($gsr1,$temp+1);
		            @tcl = <$ENV{PWD}/$dir/*.tcl>;   
		            $tcl1 = "$tcl[0]";
		            $temp_tcl = rindex($tcl1,"/");
		            $tcl = substr($tcl1,$temp_tcl + 1);
                if ($tcl eq '') {
                   @tcl = <$run_vector/*.cmd>;   
		               $tcl1 = "$tcl[0]";
		               $temp_tcl = rindex($tcl1,"/");
		               $tcl = substr($tcl1,$temp_tcl + 1); 
                }
		            print "tcl - $tcl,dir - $dir, tcl - $ENV{PWD}/$dir/../$file/$tcl\n";
		            system("cp $tcl1 $ENV{PWD}/$dir/../$file");
		            open(gsr,"$gsr[0]") || die "gsr $gsr[0] file cant be opened\n";
		            $gsrnew = "$ENV{PWD}/$dir/../$file/$gsr";
          if($debug == 0){
              $step = `egrep DYNAMIC_TIME_STEP $gsr[0] | grep -v ^# | awk '{print \$2}'`;
              if($step == " "){
                $step = "20e-12";
              }else{
                  $step = $step * 2;
              }
           }
		            open(gsrnew,">$gsrnew") || die "$gsrnew file cant be opened\n";
		            $count = 0;
		            $count_bpfs = 0;
		            while(<gsr>){
		            chomp;
		                if ($_ =~ /^#/){
		                  print gsrnew "$_\n";
		                  next;
		                };
		                if($_ =~ /^BLOCK_POWER/){
		                 $count = 1;
		                 $count_bpfs = 1;
		                }
		                if ($count != 0){
		                 if ($_ =~ /FULLCHIP\s+$design/) {
		                 }elsif($_ =~ /\}/){
		                    print gsrnew "FULLCHIP $design $power\n}\n";
		                    $count = 0;
		                 }else{
		                    print gsrnew "$_\n";
		                 }
		                 
		               }elsif($_ =~ /DYNAMIC_SIMULATION_TIME/){
		                    print gsrnew "#$_\n";
		               }else{
		                  print gsrnew "$_\n";
		              }
		            }
		            close(gsr);
		            if($count_bpfs != 1){
		              print gsrnew "BLOCK_POWER_FOR_SCALING {\n\tFULLCHIP $design $power\n}\n";
		            }
		            print gsrnew "APACHE_FILES DEBUG\n";
		            print gsrnew "DYNAMIC_PRESIM_TIME 0\n";
              if ($debug != 0){
      			        print gsrnew "DYNAMIC_SIMULATION_TIME $simtime\n";
              }else{
      			        print gsrnew "DYNAMIC_SIMULATION_TIME $step\n";
              }
#		            print gsrnew "DYNAMIC_SIMULATION_TIME $simtime\n";
		            close(gsrnew);
		            $newdir = "$ENV{PWD}/$dir/../$file";
		            chdir "$newdir";
		            system("redhawk -b $tcl");
		            if($s == 0){
		                if (-e "$ENV{PWD}/$dir/../input"){ 
		                    system"rm $ENV{PWD}/$dir/../input";
		                }
		              $s = 1;
		            } 
		            open(input,">>$ENV{PWD}/$dir/../input") || die "$ENV{PWD}/$dir/../input file cant be opened \n";
		              print input "../$file $simtime1\n";
		            close(input);
		            $cycle_p = $cycle_p - 1 ;
		          $cycle_pr = $cyc;
		    }
		}
    $vcdrun_only = 1;
    $input = "$ENV{PWD}/$dir/../input";
    }
if($vcdrun_only == 1) {
    if($run_mode == 2){
		    $input = "$ENV{PWD}/$dir/../input";
    }
    if(!defined $input){
          print "Usage:\nProvide the input file to do scenario based simulation only.\n";
          print "input file format;\n\t\t./../directory_name1\t2560\n\t\t./../directory_name2\t3000\n\t\t./../directory_name3\t5120\n";
          print "Example: perl $0 -vcd_onerun 1 -ipfile ./input.txt\n";
          exit(0);
      }
		chdir "$ENV{PWD}/$dir";
		$run_dir = $dir;
		$op = "$ENV{PWD}/$dir"."/apache.scenario";
		open(output,">$op") || die "output $op file can't be opened\n";
		$sim_time = 0;
		$sim_prev = 0;
		$count1 = 0;
		$count = 0;
		$pin = "ck";
            %hash_tw = ();
		open(in,"$input") || die "input $input file cant be opened\n";
in1:		    while(<in>){
		        chomp;
		        split;
		        $sim_time1 = $_[1];
            if($_[0] =~ /^\//){
		          $run_vector = $_[0];
            }elsif($_[0] eq '0'){
		          $run_vector = 0;
        		}else{
              $run_vector = "$ENV{PWD}/$dir/$_[0]";
            }
        if($run_vector eq '0'){
            print "0-entered\n";
                   $sim_time = int($sim_time + $sim_time1);
                   goto in1;
        }
#        print "simulation - $sim_time\n";
		        $file = "$run_vector"."/.apache/state.out";
            open(state,"$file") || die "file $file cant be opened \n";
             while(<state>){
                     chomp;split;
                     if(($_[1] == 3) || ($_[1] == 4) || ($_[1] == 7) || ($_[1] == 8) || ($_[1] == 16)) {
                     $hash_state{$_[0]} = $_[1];$hash_sw{$_[0]} = $_[2];
                     }
             }
            close(state);
#          print "started reading inst_tw.out \n";
                system("gunzip -c $run_vector/.apache/inst_tw.out.gz >$ENV{PWD}/$dir/inst_tw");
                open(tw,"$ENV{PWD}/$dir/inst_tw") || die "TW $ENV{PWD}/$dir/$run_dir/.apache/inst_tw.out.gz file cant be opened \n";
                    while(<tw>){
                        chomp;split;
		                 if (defined $hash_state{$_[0]}){
                        $hash_tw{$_[0]} = $_[4];
                        if (defined $_[5]){
                            $hash_rf{$_[0]} = $_[5];
                        }
                     }
                    }    
                close(tw);
#          print "started reading imap \n";
                @imap = <$run_vector/.apache/apache.imap>;
                $imap = $imap[0];
                open(imap,"$imap") || die "imap file cant be opened\n";
                  while(<imap>){
                    chomp;split;
		                 if (defined $hash_state{$_[0]}){
                    $hash_map{$_[0]} = $_[1] ;
                    $hash_id{$_[1]} = $_[0] ;
                     }
                  }
                close(imap);
#          print "finished reading imap file \n";
#          print "started reading TW from power file\n";
		        @power = <$run_vector/adsPower/*.power>;
		        $power = $power[0];                    
		        open(power,"$power")|| die "power $power file cant be opened\n";
		          while(<power>){
		            if($_ =~ /^$/){next;}
		            chomp;split;
		                 if (defined $hash_state{$hash_id{$_[0]}}){
		            $hash_pin{$hash_id{$_[0]}} = $_[19];
		            $hash_ptype{$hash_id{$_[0]}} = $_[2];
                }
		        }
		        close(power);
#          print "started reading TW from .pwr file\n";
		        $pwr = "$run_vector/.apache/apache.pwr";
		        open(pwr,"$pwr")|| die "$pwr file cant be opened\n";
		          while(<pwr>){
		            next if($_ !~ /^[1-9]/);
		            chomp;split;
		                 if (defined $hash_state{$_[0]}){
                next if (($_[21] || $_[20]) == -9);
		            $hash_clkpin_avg{$_[0]} = ($_[20] + $_[21])/2;
                }
		        }
		        close(pwr);
#print "started reading firingT.out.gz file \n";
      $file = "$run_vector"."/.apache/state.out";
		        $sim_prev = $sim_time ;
		        $sim_time = int($sim_time + $sim_time1);
		        $file_tw1 = "$run_vector"."/.apache/firingT.out.gz";
		        system("gunzip -c $file_tw1 > file_tw");
		        open(tw,"file_tw")|| die "TW file_tw cant be opened \n";
		          while(<tw>){
		              chomp;split;
		                 if (defined $hash_state{$_[0]}){
		              $hash_delay{$_[0]}{c01} = $_[1];
				if(defined $format){
		              $hash_delay{$_[0]}{c10} = $_[1];
		              $hash_delay{$_[0]}{clk} = $_[1];
				}else{
		              $hash_delay{$_[0]}{c10} = $_[2];
		              $hash_delay{$_[0]}{clk} = $_[3];
				}
		          }
              }
		        close(tw);
#            print " reached here \n" ;
#          print "started reading state.out file \n";
         foreach  $id (keys %hash_state){
          if(defined $hash_map{$id}) {
		                 $inst = $hash_map{$id};
		                     $cycle = int($hash_tw{$id});
		                 if ($hash_state{$id} == 3 || $hash_state{$id} == 4 || $hash_state{$id} == 7 || $hash_state{$id} == 8){
		                     $switchtime_clk = int($hash_sw{$id} + $hash_delay{$id}{clk});
		                        if(!defined $clk{$inst}){
		                                $clk_pt5_period = $hash_tw{$id}/2;
		                                if($hash_clkpin_avg{$id} >= $clk_pt5_period){
		                                    $clk{$inst} = "c00"; 
		                                }else{
		                                    $clk{$inst} = "c11"; 
		                                }
		                            }elsif($clk{$inst} eq "c00"){
		                                $clk{$inst} = "c11"; 
		                            }else{
		                                $clk{$inst} = "c00"; 
		                                }
		                   }
		                if($hash_state{$id} == 7){
		                     $pin = ck;
		                }elsif($hash_state{$id} == 8){
		                      $pin = ck;
		                  }elsif ($hash_state{$id} == 3){
		                     if (!defined $charge{$inst}){
		                      $charge{$inst} = "c01";
		                         $switchtime = int($hash_sw{$id} + $hash_delay{$id}{c01});
		                     }elsif($charge{$inst} eq "c01"){
		                         $charge{$inst} = "c10"; 
		                         $switchtime = int($hash_sw{$id} + $hash_delay{$id}{c10});
		                        }else{
		                         $charge{$inst} = "c01"; 
		                         $switchtime = int($hash_sw{$id} + $hash_delay{$id}{c01});
		                        }
		                      $pin = $hash_pin{$id};
		                 }elsif ($hash_state{$id} == 4){
		                     if (!defined $charge{$inst}){
		                      $charge{$inst} = "c10";
		                         $switchtime = int($hash_sw{$id} + $hash_delay{$id}{c10});
		                     }elsif($charge{$inst} eq "c10"){
		                         $charge{$inst} = "c01"; 
		                         $switchtime = int($hash_sw{$id} + $hash_delay{$id}{c01});
		                        }else{
		                         $charge{$inst} = "c10"; 
		                         $switchtime = int($hash_sw{$id} + $hash_delay{$id}{c10});
		                        }
		                      $pin = $hash_pin{$id};
		                  }elsif ($hash_state{$id} == 16){
		                      if($hash_rf{$id} == 1){
		                     if (!defined $charge{$inst}){
		                           $charge{$inst} = "c01";
		                         $switchtime = int($hash_sw{$id} + $hash_delay{$id}{c01});
		                      }elsif($charge{$inst} eq "c01"){
		                         $charge{$inst} = "c10"; 
		                         $switchtime = int($hash_sw{$id} + $hash_delay{$id}{c10});
		                        }else{
		                         $charge{$inst} = "c01";
		                         $switchtime = int($hash_sw{$id} + $hash_delay{$id}{c01});
		                        }
		                           $pin = $hash_pin{$id};
		                      }else{
		                         if (!defined $charge{$inst}){
		                                $charge{$inst} = "c10";
		                         $switchtime = int($hash_sw{$id} + $hash_delay{$id}{c10});
		                         }elsif($charge{$inst} eq "c10"){
		                             $charge{$inst} = "c01"; 
		                         $switchtime = int($hash_sw{$id} + $hash_delay{$id}{c01});
		                            }else{
		                                $charge{$inst} = "c10";
		                         $switchtime = int($hash_sw{$id} + $hash_delay{$id}{c10});
		                            }
		                                $pin = $hash_pin{$id};
		                      }
		                  }else{
		                       next;
		                   }
		                  if ($count1 != 0){
		                            $switchtime = int($switchtime + $sim_prev);
		                   }
		                      $count = 0;
		                      $count_7 = 0;
		 $count_8 = 0;
		                      $count_clk = 0;
		                              $charge_ck = int($switchtime_clk + $sim_prev);
		                              $cycle1 = int($cycle/2);
		                              $repeat = 0;
                                  if($cycle1 != 0){
		            for ($j = $charge_ck ; $j <= $sim_time ; $j = $j + $cycle1){
		                            if(($hash_sw{$id} < 0) && ($sim_prev > 0) && ($repeat == 0)){
		                                $repeat = 1;
		                                next;
		                              }
		                            
		                          if(($hash_state{$id} == 3) || ($hash_state{$id} == 4)){
		                              if($hash_ptype{$id} != 0){
		                                if($count_clk == "0") { 
		                                    $count_clk = 1;
		                                }else{
		                                  if($clk{$inst} eq "c00"){
		                                      $clk{$inst} = "c11";
		                                  }elsif($clk{$inst} eq "c11"){
		                                      $clk{$inst} = "c00";
		                                  }
		                                }
		                                    print output "$inst $clk{$inst} $j ck\n";
		                            }
		                          }elsif($hash_state{$id} == 7){
		                                if($count_7 == 0) { 
		                                    $count_7 = 1;
		 }else{
		                                  if($clk{$inst} eq "c00"){
		                                      $clk{$inst} = "c11";
		                                  }elsif($clk{$inst} eq "c11"){
		                                      $clk{$inst} = "c00";
		                                  }
		                                }
		                                    print output "$inst $clk{$inst} $j ck\n";
		                          }elsif($hash_state{$id} == 8){
		                                if($count_8 == "0") { 
		                                    $count_8 = 1;
		                                }else{
		                                  if($clk{$inst} eq "c11"){
		                                      $clk{$inst} = "c00";
		                                  }elsif($clk{$inst} eq "c00"){
		                                      $clk{$inst} = "c11";
		                                  }
		                                }
	                                    print output "$inst $clk{$inst} $j ck\n";
		                          }
		                        }
                                  }else{
		                            if(($hash_sw{$id} < 0) && ($sim_prev > 0) && ($repeat == 0)){
		                                $repeat = 1;
		                                next;
		                              }
		                            
		                          if(($hash_state{$id} == 3) || ($hash_state{$id} == 4)){
		                              if($hash_ptype{$id} != 0){
		                                if($count_clk == "0") { 
		                                    $count_clk = 1;
		                                }else{
		                                  if($clk{$inst} eq "c00"){
		                                      $clk{$inst} = "c11";
		                                  }elsif($clk{$inst} eq "c11"){
		                                      $clk{$inst} = "c00";
		                                  }
		                                }
		                                    print output "$inst $clk{$inst} $charge_ck ck\n";
		                            }
		                          }elsif($hash_state{$id} == 7){
		                                if($count_7 == 0) { 
		                                    $count_7 = 1;
		 }else{
		                                  if($clk{$inst} eq "c00"){
		                                      $clk{$inst} = "c11";
		                                  }elsif($clk{$inst} eq "c11"){
		                                      $clk{$inst} = "c00";
		                                  }
		                                }
		                                    print output "$inst $clk{$inst} $charge_ck ck\n";
		                          }elsif($hash_state{$id} == 8){
		                                if($count_8 == "0") { 
		                                    $count_8 = 1;
		                                }else{
		                                  if($clk{$inst} eq "c11"){
		                                      $clk{$inst} = "c00";
		                                  }elsif($clk{$inst} eq "c00"){
		                                      $clk{$inst} = "c11";
		                                  }
		                                }
	                                    print output "$inst $clk{$inst} $charge_ck ck\n";
                                  
                                  }
                                  }
		            if($cycle != 0) {
                      if($hash_state{$id} == 3 || $hash_state{$id} == 4 || $hash_state{$id} == 16){
		              for ($i = $switchtime;$i <= $sim_time;$i = $i + $cycle){
		                   if($count == "0"){
		                      $count = 1;
		                    } else {
		                      if($charge{$inst} eq "c00"){
		                          $charge{$inst} = "c00" ;
		                      }elsif($charge{$inst} eq "c11"){
		                           $charge{$inst} = "c11" ;
		                      }elsif($charge{$inst} eq "c01"){
		                          $charge{$inst} = "c10" ;
		                      }elsif($charge{$inst} eq "c10"){ 
		                          $charge{$inst} = "c01" ;
		                      }
		                  }
		                  if (defined $charge{$inst}){
		                          print output "$inst $charge{$inst} $i $pin\n";
		                  }
		               }
		             }
                }else{
                      if($hash_state{$id} == 3 || $hash_state{$id} == 4 || $hash_state{$id} == 16){
		                   if($count == "0"){
		                      $count = 1;
		                    } else {
		                      if($charge{$inst} eq "c00"){
		                          $charge{$inst} = "c00" ;
		                      }elsif($charge{$inst} eq "c11"){
		                           $charge{$inst} = "c11" ;
		                      }elsif($charge{$inst} eq "c01"){
		                          $charge{$inst} = "c10" ;
		                      }elsif($charge{$inst} eq "c10"){ 
		                          $charge{$inst} = "c01" ;
		                      }
		                  }
		                  if (defined $charge{$inst}){
		                          print output "$inst $charge{$inst} $switchtime $pin\n";
		                  }
		               }
                }
                }
        } 
		          $count1 = $count1 + 1;
#close(state);
    %hash_rf = %hash_pin = %hash_ptype = %hash_delay = %hash_clkpin_avg = %hash_state = ();
		 }
		close(in);
		close(output);
		`mv $op $op.orig`;

open(ip,"$op.orig") || die "$op.orig can not be opened for reading\n";
open(op,">$op") || die "$op can not be opened for writing\n";
while(<ip>){
	chop;split;
      $hash{$_[2]}{$_[0]} = "$_[0]"."  "."$_[1]"."  "."$_[3]" ;
}
close(ip);
foreach $d (sort {$a<=>$b} keys %hash){
     foreach $inst (keys %{$hash{$d}}) {
     @values = split(/\s+/,$hash{$d}{$inst});
	print op "$values[0]  $values[1]  $d  $values[2]\n";
    }
}

#		`sort -n -k3 $op.orig > $op`;
		open(ip,">./header")||die "header file cant be opened\n";
		        print ip "#### switching scenario v.1 (true timing)\n";
		        print ip "#../../design_data/vcd/GENERIC.vcd -tt -msg .apache/vcd_output.msg -f $sim_time1 -w \"test_bench1/GENERIC/\" \"\" -s 0 -e $sim_time -a 0 $sim_time\n";
		        print ip "# frame size $sim_time1\n";
		close(ip);
		`mv $op $op.orig.1`;
		`cat header $op.orig.1 > $op`;
		$final_run = "final_run";
		
		system("mkdir -p $run_vector/../$final_run");
		system("mkdir -p $run_vector/../$final_run/run_scripts");
    $final = "$run_vector/../final_run";
		chdir("$final");
# print "$cwd,$final,HI"; <stdin>;
		            @gsr = <$run_vector/*.gsr>;   
		            $gsr1 = "$gsr[0]";
		            $temp = rindex($gsr1,"/");
		            $gsr = substr($gsr1,$temp+1);
		            @tcl = <$run_vector/*.tcl>;   
		            $tcl1 = "$tcl[0]";
		            $temp_tcl = rindex($tcl1,"/");
		            $tcl = substr($tcl1,$temp_tcl + 1);
                if ($tcl eq '') {
                   @tcl = <$run_vector/*.cmd>;   
		               $tcl1 = "$tcl[0]";
		               $temp_tcl = rindex($tcl1,"/");
		               $tcl = substr($tcl1,$temp_tcl + 1); 
                }
		system("cp $run_vector/$tcl .");
		system("cp $run_vector/$gsr .");
		open(gsr,">>$gsr") || die "$run_vector/../$final_run/$gsr file can not be opened for writing\n";
		$sim_final = "$sim_time"."e-12";
      			        print gsr "DYNAMIC_SIMULATION_TIME $sim_final\n";
#		print gsr "\nDYNAMIC_SIMULATION_TIME $sim_final\n";
		close(gsr);
		$tcl_final = "$run_vector/../final_run/$tcl";
                chdir("$run_vector/../final_run");
		if (!defined $cpm){
		        system("perl -pi -e 's#perform analysis.*#perform analysis -vcd -scenario $op#gc' $tcl_final");
		        system("redhawk -f $tcl_final");
     }else{
            $my_tcl = "$run_vector/../final_run/cpmrun.tcl";
            $pwd_m = 0;
                 open (tcl_f,">$my_tcl") ||die "not able to open $my_tcl for writing \n";
                 open (tcl_o,"$tcl_final") ||die "not able to open $tcl_final for reading \n";
                 while(<tcl_o>){
                    if($_ =~ /^perform\s+analysis/){
                    }elsif($_ =~ /^perform\s+powermodel/){
                        $pwd_m = 1;
                        $ppm = $_;
                      }else{
                        print tcl_f "$_";
                     }
                 }
                 close(tcl_o);
              print  tcl_f "gsr set DYNAMIC_SIMULATION_TIME 25e-12\n";
              print tcl_f "catch { exec cp $op $run_vector/../final_run/.apache/.}\n";
              if($pwd_m == 0){
                  print tcl_f "perform powermodel -nx 1 -ny 1 -pincurrent\n";
              }else{
                  print tcl_f "$ppm\n";
              }

              print tcl_f "gsr set DYNAMIC_SIMULATION_TIME $sim_final\n";
              print tcl_f "set new_start_sim_end_time $sim_time\n";
              print tcl_f "set enter_loop 0\n";
              print tcl_f "if \{ \[file exists .apache/.run.setting \] \} \{\n";
              print tcl_f "set fp \[ open \".apache/.run.setting\" r \]\n";
              print tcl_f "set new_line \"\"\n";
              print tcl_f "set gap \" \"\n";
              print tcl_f "while \{ \[ gets \$fp line \] >= 0 && \$enter_loop == 0\} \{\n";
              print tcl_f "if \{ \[ regexp -all \"asim_cpm\" \$line \] \} \{\n";
              print tcl_f "set enter_loop 1\n";
              print tcl_f "regsub -all \{\t\}  \$line \" \" line1\n";
              print tcl_f "        regsub -all -- \{\[\[:space:\]\]+\} \$line1 \" \" line2\n";
              print tcl_f "set words \[ split \$line2 \]\n";
              print tcl_f "for \{ set i 0 \} \{ \$i < \[ llength \$words \] \} \{ incr i \} \{\n";
              print tcl_f "set word \[ lindex \$words \$i \]\n";
              print tcl_f "if \{ \$word eq \"-st\" \} \{\n";
              print tcl_f "set replaced_index \[ expr \$i + 2 \]\n";
              print tcl_f "set start_replace 1\n";
              print tcl_f "set new_line \$new_line\$gap\$word\n";
              print tcl_f "\} else \{\n";
              print tcl_f "if \{ !\[ info exists start_replace \] || \$i != \$replaced_index \} \{\n";
              print tcl_f "set new_line \$new_line\$gap\$word\n";
              print tcl_f "\} else \{\n";
              print tcl_f "set new_line \$new_line\$gap\$new_start_sim_end_time\n";
              print tcl_f "unset start_replace\n";
              print tcl_f "\}\n";
              print tcl_f "\}\n";
              print tcl_f "\}\n";
              print tcl_f "\}\n";
              print tcl_f "\}\n";
              print tcl_f "\}\n";
              print tcl_f "close \$fp\n";
              print tcl_f "regsub -all \"asim_cpm\" \$new_line \"asim_cpm_vcd\" new_line1 \n";
              print tcl_f "set f1 \[ open \"./run_scripts/cpm.cmd\" w \]\n";
              print tcl_f "puts \$f1 \"catch {exec \$new_line1 } \"\n";
              print tcl_f "close \$f1\n";
              print tcl_f "source ./run_scripts/cpm.cmd\n";
                 
                 close(tcl_f);
		        system("redhawk -f $my_tcl");
     }
                system("which redhawk > $run_vector/../final_run/redhawk");
		}

if (($vcdrun_only == 0) && ($run_mode == 3)) {
			    if(!(((defined $power1) && (defined $dir) && (defined $power2) && (defined $clkcycles) && (defined $design) && (defined $sim_time1) ) || ((defined $power_file) && (defined $dir) && (defined $sim_time1) && (defined $design)))){
			        print "$help"; exit(0);
			    }
			if ($run_mode == 3){
			    $sim_time = "$sim_time1"."e-12";
			    $freq = 1/$sim_time;
			    $power = $power1;
			    $i = 0;
			    $one = 0;
			    $s = 0;
			if(!defined $power_file){
			
			while("$power" <= "$power2"){
			    $i = $i + 1;
			    $file = "newrun.$i";
			    if (-e "$ENV{PWD}/$dir/../$file"){  
			        print "old directory $ENV{PWD}/$dir/../$file is deleted \n";
			        system("rm -rf $ENV{PWD}/$dir/../$file");
			    }
			    system("mkdir $ENV{PWD}/$dir/../$file");
			    print "new directory $ENV{PWD}/$dir/../$file created \n";
			    @gsr = <$ENV{PWD}/$dir/*.gsr>;   
			    $gsr1 = "$gsr[0]";
			    $temp = rindex($gsr1,"/");
			    $gsr = substr($gsr1,$temp+1);
			    @tcl = <$ENV{PWD}/$dir/*.tcl>;   
			    $tcl1 = "$tcl[0]";
			    $temp1 = rindex($tcl1,"/");
			    $tcl = substr($tcl1,$temp1+1);
			    system("cp $tcl1 $ENV{PWD}/$dir/../$file/.");
			    open(gsr,"$gsr[0]") || die "gsr $gsr[0] file cant be opened\n";
          if($debug == 0){
              $step = `egrep DYNAMIC_TIME_STEP $gsr[0] | grep -v ^# | awk '{print \$2}'`;
              if($step == " "){
                $step = "20e-12";
              }else{
                  $step = $step * 2;
              }
           }
			    $gsrnew = "$ENV{PWD}/$dir/../$file/$gsr";
			    open(gsrnew,">$gsrnew") || die "$gsrnew file cant be opened\n";
			    $count = 0;
			    $count_bpfs = 0;
			    while(<gsr>){
			    chomp;
			        if ($_ =~ /^#/){
			          print gsrnew "$_\n";
			          next;
			        };
			        if($_ =~ /^BLOCK_POWER/){
			         $count = 1;
			         $count_bpfs = 1;
			        }
			        if ($count != 0){
			         if ($_ =~ /FULLCHIP\s+$design/) {
			         }elsif($_ =~ /\}/){
			            print gsrnew "FULLCHIP $design $power\n}\n";
			            $count = 0;
			         }else{
			            print gsrnew "$_\n";
			         }
			         
			       }elsif($_ =~ /DYNAMIC_SIMULATION_TIME/){
			            print gsrnew "#$_\n";
			       }else{
			          print gsrnew "$_\n";
			      }
			    }
			    close(gsr);
			    if($count_bpfs != 1){
			      print gsrnew "BLOCK_POWER_FOR_SCALING {\n\tFULLCHIP $design $power\n}\n";
			    }
              if ($debug != 0){
      			        print gsrnew "DYNAMIC_SIMULATION_TIME $sim_time\n";
              }else{
      			        print gsrnew "DYNAMIC_SIMULATION_TIME $step\n";
              }
#			    print gsrnew "DYNAMIC_SIMULATION_TIME $sim_time\n";
			    print gsrnew "APACHE_FILES DEBUG\n";
			    print gsrnew "DYNAMIC_PRESIM_TIME 0\n";
			    close(gsrnew);
			    $newdir = "$ENV{PWD}/$dir/../$file";
			#   chdir "$newdir";
			#system("redhawk -b $tcl");
			    if($s == 0){
			        if (-e "$ENV{PWD}/$dir/../input"){ 
			            system"rm $ENV{PWD}/$dir/../input";
			            print "file $ENV{PWD}/$dir/../input is deleted \n";
			        }
			      $s = 1;
			    } 
			    open(input,">>$ENV{PWD}/$dir/../input") || die "$ENV{PWD}/$dir/../input file cant be opened \n";
			      print input "$ENV{PWD}/$dir/../$file $sim_time1\n";
			    close(input);
			    $power = $power1 + (($power2 - $power1)/$clkcycles) * $i;
			}
			}else{
			    $cycle_pr = 0;
			   open(pf,"$power_file") || die "power_file can not be opened \n";
			   $l = 0;
			       while(<pf>){
			             next if($_ =~ /^$/);
			             next if($_ =~ /^#/);
			            chomp;split;
			              $l++;
			            $hash{$l}{$_[0]} = $_[1];
			       }
			        close(pf);
			$lines = keys (%hash);
			$i = 0;
			  for ($j = 1; $j <= $lines; $j++){
			      @one = keys (%{$hash{$j}});
			      if($j == $lines){
			        $cycles = 1;
			      }else{
			        @two = keys (%{$hash{$j+1}});
			        $cycles = $two[0] - $one[0];
			      }
			      $simtime1 = $cycles * $sim_time1;
			      $simtime = "$simtime1"."e-12";
			      $power = $hash{$j}{$one[0]};
			      $i++;
			           
			            $file = "newrun.$i";
			            if (-e "$ENV{PWD}/$dir/../$file"){  
			                system("rm -rf $ENV{PWD}/$dir/../$file");
			            }
			            system("mkdir $ENV{PWD}/$dir/../$file");
			            print "new directory $ENV{PWD}/$dir/../$file created \n";
			            @gsr = <$ENV{PWD}/$dir/*.gsr>;   
			            $gsr1 = "$gsr[0]";
			            $temp = rindex($gsr1,"/");
			            $gsr = substr($gsr1,$temp+1);
			            @tcl = <$ENV{PWD}/$dir/*.tcl>;   
			            $tcl1 = "$tcl[0]";
			            $temp_tcl = rindex($tcl1,"/");
			            $tcl = substr($tcl1,$temp_tcl + 1);
			#           print "tcl - $tcl,dir - $dir, tcl - $ENV{PWD}/$dir/../$file/$tcl\n";
			            system("cp $tcl1 $ENV{PWD}/$dir/../$file");
			            open(gsr,"$gsr[0]") || die "gsr $gsr[0] file cant be opened\n";
			            $gsrnew = "$ENV{PWD}/$dir/../$file/$gsr";
          if($debug == 0){
              $step = `egrep DYNAMIC_TIME_STEP $gsr[0] | grep -v ^# | awk '{print \$2}'`;
              if($step == " "){
                $step = "20e-12";
              }else{
                  $step = $step * 2;
              }
           }
			            open(gsrnew,">$gsrnew") || die "$gsrnew file cant be opened\n";
			            $count = 0;
			            $count_bpfs = 0;
			            while(<gsr>){
			            chomp;
			                if ($_ =~ /^#/){
			                  print gsrnew "$_\n";
			                  next;
			                };
			                if($_ =~ /^BLOCK_POWER/){
			                 $count = 1;
			                 $count_bpfs = 1;
			                }
			                if ($count != 0){
			                 if ($_ =~ /FULLCHIP\s+$design/) {
			                 }elsif($_ =~ /\}/){
			                    print gsrnew "FULLCHIP $design $power\n}\n";
			                    $count = 0;
			                 }else{
			                    print gsrnew "$_\n";
			                 }
			                 
			               }elsif($_ =~ /DYNAMIC_SIMULATION_TIME/){
			                    print gsrnew "#$_\n";
			               }else{
			                  print gsrnew "$_\n";
			              }
			            }
			            close(gsr);
			            if($count_bpfs != 1){
			              print gsrnew "BLOCK_POWER_FOR_SCALING {\n\tFULLCHIP $design $power\n}\n";
			            }
			            print gsrnew "APACHE_FILES DEBUG\n";
			            print gsrnew "DYNAMIC_PRESIM_TIME 0\n";
              if ($debug != 0){
      			        print gsrnew "DYNAMIC_SIMULATION_TIME $simtime\n";
              }else{
      			        print gsrnew "DYNAMIC_SIMULATION_TIME $step\n";
              }
			            print gsrnew "DYNAMIC_SIMULATION_TIME $simtime\n";
			            close(gsrnew);
			            $newdir = "$ENV{PWD}/$dir/../$file";
			#        chdir "$newdir";
			#            system("redhawk -b $tcl");
			            if($s == 0){
			                if (-e "$ENV{PWD}/$dir/../input"){ 
			                    system"rm $ENV{PWD}/$dir/../input";
			                }
			              $s = 1;
			            } 
			            open(input,">>$ENV{PWD}/$dir/../input") || die "$ENV{PWD}/$dir/../input file cant be opened \n";
			              print input "$ENV{PWD}/$dir/../$file $simtime1\n";
			            close(input);
			            $cycle_p = $cycle_p - 1 ;
			          $cycle_pr = $cyc;
			    }
			}
			print "\nFile \"$ENV{PWD}/$dir/../input\" is generated through this script which lists all run directories and corresponding simulation times. After Redhawk runs, this can be passed to state2scenario.pl\" which combines all runs to create final run and runs it.\n\n";
			}
}
