# $Revision: 1.1 $

eval '(exit $?0)' && eval 'exec perl -S $0 ${1+"$@"}'
    && eval 'exec perl -S $0 $argv:q'
    if 0;

#==================================================================
# This script generates configuration file required for AVM characterization of memories
#==================================================================

# Revision history


# Put a directory with eda_utils.pm into search path
$script_installation_dir = dirname($0);
push(@INC,$script_installation_dir);
push(@INC,$script_installation_dir."/pm");


# Print Warnings and Errors by default
use vars qw(%GLOBAL_PARMS);
$GLOBAL_PARMS{VerboseLevel} = "W";
require "eda_utils.pm";
use File::Basename;

#--------------------------------------------------------------------

# Here is array of all variables
@VarList = ("vdd_value","apl_setup_dir","libs_file","mcf_file");

%VarProperties = ("vdd_value,expl" => "Value of supply voltage",
		  "vdd_value,optional" => 1,
		  "apl_setup_dir,expl" => "RedHawk run directory with APL setup",
	          "apl_setup_dir,optional" => 1,
		  #"gsr_file,expl" => "GSR file used for analysis",
		  #"gsr_file,optional" => 1,
	          "mcf_file,expl" => "apache.mcf file from Redhawk run directory",
	 	  "mcf_file,optional" => 1,
		  "libs_file,expl" => "List of memory .lib files used in analysis",
		  "libs_file,optional" => 1
);

# Preset values of all required variables
foreach $var_name (@VarList) {
    $VarHash{$var_name} = "???";
}
# Defaults
$VarHash{mcf_file} = "../../../setupApl/.apache/apache.mcf";
$VarHash{apl_setup_dir} =  "../../../setupApl";


@files = <../../lib/*.lib>;

foreach $file (@files) {
  print OUT "$cell_name  $file\n";
  $flag = 1;
  $out_files_found = 1;
}


# If avm_setup.init file with previously defined variables exists -
# parse it first
# Every line has following syntax:
# <var_name> : <value1> <value2> ...
if (-r "avm_setup.init") {
  edaOpenFile(IN, "avm_setup.init", "r");
  while (<IN>) {
    chomp();
    @Line = split(" ",$_);
    $var_name = shift(@Line);
    shift(@Line);
    $VarHash{$var_name} = join(" ",@Line);
  }
  close IN;
}


#if (-r "$VarHash{gsr_file}") {
#  edaOpenFile(IN, "$VarHash{gsr_file}", "r");
#  $start = 0;
#  while(<IN>) {
#        if($start == 1) {
#                split;
#                $VarHash{vdd_value} = $_[1];
#                $start = 0;
#        }
#
#        if(/VDD_NETS/) {
#                $start = 1;
#        }
#  }
#  close IN;
#}

#===============================================================================
# Usage info
sub usage {
  print "
SYNOPSIS
 Generates configuration file for running AVM for all memories used in design 

DESCRIPTION
 avm_setup.pl generates the configuration file required for AVM

 Script accepts user options from 2 sources:
 a. from \$cwd/avm_setup.init file
 b. from command line arguments, which are saved as well in avm_setup.init by the script

 Input to the script is incremental. The user may invoke the script with one or more options, then re-invoke the script adding more information, until all required information is complete. The user may add optional information at any time.

OPTIONS
";

  foreach $var (@VarList) {
    $var_expl = $VarProperties{$var.",expl"};
    $var_example = $VarProperties{$var.",example"};
    if (defined $VarProperties{$var.",default"}) {
      $var_default = $VarProperties{$var.",default"};
    } else {
      $var_default = "none";
    }
    print "  -$var\n    $var_expl\n";
  }
} # End of usage routine

# Read in command line variables
# * Catch the corner case if the very first argument doesn't start with "-"
if (@ARGV && !($ARGV[0] =~ m/^-/)) {
  edaError("Flag $ARGV[0] is illegal!");
}

while(@ARGV) {
  $arg = shift(@ARGV);
  # If current argument starts with "-", it's a name of the parameter
  if ($arg =~ m/^-/) {
    if ($arg eq "-h") {
      usage();
      exit(0);
    }
    ($var_name = $arg) =~ s/^-//;
    if (edaInArray($var_name,\@VarList) < 0) {
      edaError("Flag $arg is illegal!");
    }
    $VarHash{$var_name} = "";
    next;
  }

  # If not - it's a value of the parameter - store or append it


  if ($VarHash{$var_name} eq "") {
    $VarHash{$var_name} = $arg;
  } else {
    $VarHash{$var_name} .= " $arg";
  }
}

# Print all parameters with their values
# Check if all parameters were defined by the user
# Save all currently defined parameters in the extract_gds.init file
$all_parms_defined_flag = 1;
edaOpenFile(OUT, "avm_setup.init", "wf");
print "----------------------------------------------------------------\n option      | values\n----------------------------------------------------------------\n";
foreach $var (@VarList) {
  print OUT "$var : $VarHash{$var}\n";

  # If value is too long (too many files) , print only a portion
  if (length($VarHash{$var}) > 120) {
      printf("%-12s | %s...", -$var, substr($VarHash{$var},0,120));
  } else {
      printf("%-12s | %s", -$var, $VarHash{$var});
  }
  if (($VarHash{$var} eq "???") || ($VarHash{$var} eq "")) {
    if (defined $VarProperties{$var.",optional"}) {
      print " (optional)";
    } else {
      print " (REQUIRED)";
      $all_parms_defined_flag = 0;
    }
    if (defined $VarProperties{$var.",example"}) {
      $var_example = $VarProperties{$var.",example"};
      print "  Ex: $var_example";
    }
  }
  print "\n";
}
close OUT;
print "----------------------------------------------------------------\n";

if ($all_parms_defined_flag == 0) {
  edaError("Some of the required parameters were not defined!");
}


if (-r "$VarHash{mcf_file}") {
  edaOpenFile(IN, "$VarHash{mcf_file}", "r");

  while(<IN>) {
	if(/^cell/) {
		split;
		$mem_name = $_[1];
		$keep{"$mem_name"} = $mem_name;
		$mem{$mem_name}{"mem_name"} = $mem_name;
		
		if( $mem_name =~ /ram/i) {
			$mem{$mem_name}{"type"} = "SRAM";
		}
		elsif ( $mem_name =~ /rom/i) { 
			$mem{$mem_name}{"type"} = "ROM"
		}
		else {
			$mem{$mem_name}{"type"} = "RF";
		}
		#print "DBG: memory $mem_name ; type is $mem{$mem_name}{\"type\"}\n";
		
		if( $mem_name =~ /(\d+)x(\d+)/i ) {
			$mem{$mem_name}{"words"} = $1;
			$mem{$mem_name}{"bits"} = $2;
		}	 
		$mem{$mem_name}{"vdd"} = $VarHash{vdd_value};
 		#print "DBG: memory $mem_name ; VDD value is $VarHash{vdd_value}\n";

	}
  }
  close IN;
}


if (($VarHash{vdd_value} eq "???") || ($VarHash{$vdd_value} eq "")) {
  $apl_file = $VarHash{apl_setup_dir}."/.apache/apache.apl";
  if (-r "$apl_file") {
    edaOpenFile(IN, "$apl_file", "r");
    $start = 0;
    while(<IN>) {
      split;
      if (/ {/) {
        if (defined $keep{"$_[0]"}) {
	  $start = 1;
          $mem_name = $_[0];
        }
      }
      if (/^Vdd /) {
        if ($start == 1) {
	  $mem{$mem_name}{"vdd"} = $_[1];
	  $VarHash{vdd_value} = $_[1];
          $start = 0;
        } 
      }
    }
    close IN;
  }
}


if (($VarHash{libs_file} eq "???") || ($VarHash{libs_file} eq "") ) {
  @files = <../../lib/*.lib>;

  edaOpenFile(OUT, ".avm.libs", "wf");
  foreach $file (@files) {
    print OUT "$file\n";
  }
  close OUT;
  $VarHash{libs_file} = ".avm.libs";
}

if (-r "$VarHash{libs_file}") {
  edaOpenFile(lib, "$VarHash{libs_file}", "r");
}

edaOpenFile(conf, "avm.conf", "wf");
edaOpenFile(err, "avm_setup.err", "wf");
edaOpenFile(war, "avm_setup.warn", "wf");


while(<lib>){

    #print "Reading memory LIB files $opt_l\n";
    chop;
    if(/^LIB_FILE/) {
	next;
    }
    $file_name = $_;
    $brace_count=0;
    $is_clock = 0;
    $is_out = 0;
    $is_addr = 0;
    $done_cell = 0;
    $done_pin = 0;
    $block_count = 0;	
    $power_start = 0;
    $read_power = 0;
    $write_power = 0;
    $rise_delay = 0;
    $fall_delay = 0;


    open(f_lib, "$file_name");
    @fields = ();
    while(<f_lib>){
	@fields = split/\s+/,$_;
	$num = @fields;
	if( $num != 0) {
	if($fields[1] eq "time_unit"){

		@a = split/\"/,$fields[3];
		@b = split/\d+/,$a[1];
		$time_unit = $b[1];
	}
	elsif($fields[1] eq "capacitive_load_unit") {
                $line = $_;
                $line =~ s/^(\s+)//g;
                $line =~ s/\(/ /g;
                $line =~ s/\)/ /g;
                $line =~ s/\,/ /g;
                @a = split/\s+/,$line;

		$cap_unit = $a[2];
		if($cap_unit =~ /pf/i){
			$cap_unit = 1e-12;
		}
		elsif($cap_unit =~ /ff/i){
			$cap_unit = 1e-15;
		}
		elsif($cap_unit =~ /nf/i){
			$cap_unit = 1e-09;
		}
		elsif($cap_unit =~ /uf/i){
			$cap_unit = 1e-06;
		}
		elsif($cap_unit =~ /mf/i){
			$cap_unit = 1e-03;
		}
	}
	elsif($fields[1] eq "voltage_unit") {
		@a = split/\"/,$fields[3];
                @b = split/\d+/,$a[1];

		$voltage_unit = $b[1];
		if($voltage_unit =~ /mV/i) {
			$voltage_unit = 1e-03;
		}
		else {
			$voltage_unit = 1;
		}
	}
	elsif($fields[1] eq "nom_voltage") {
	    $nom_voltage = $fields[3];
	}
	elsif($fields[1] eq "leakage_power_unit") {
	    @a = split/\"/,$fields[3];
            @b = split/\d+/,$a[1];
	    $leakage_unit = $b[1];
	    
	     if($leakage_unit =~ /nW/i) {
			$leakage_unit = 1e-09;
	     }
	     elsif($leakage_unit =~ /pW/i) {
			$leakage_unit = 1e-12;
	     }
	     elsif($leakage_unit =~ /fW/i) {
			$leakage_unit = 1e-15;
	     }
             elsif($leakage_unit =~ /uW/i) {
			$leakage_unit = 1e-06;
	     }
	     elsif($leakage_unit =~ /mW/i) {
			$leakage_unit = 1e-03;
	     }
	     else {
		    $leakage_unit = 1;
	     }
	}

	$energy_unit = $cap_unit * $voltage_unit;

	if( (/cell \(/) || (/cell\(/) ) {
#	if($fields[0] eq "cell"){
	    @name = split/\((\S+)\)/,$_; 
	    $mem_name = $name[1];
	    $tsetup_rise = 0;
	    $tsetup_fall = 0;	
            $tsetup = 0;
            $energy = 0;
            $pin_name = "";
            $ck2q_rise_delay = 0;
            $ck2q_fall_delay = 0;
	    $ck2q_delay = 0;
	    $read_power = 0;
	    $write_power = 0;
	    $done_cell = 0;
	    $done_pin = 0;

	    if( defined  $mem{$mem_name}{"vdd"} ) {
		if($nom_voltage ne $mem{$mem_name}{"vdd"} ) {
		    print war "WARNING: Nominal Voltage in $file_name not consistent with that in $gsr_file\n";
		}
	    }
        	#print "Start Memory cell name is $mem_name\n";
	}

	if( $fields[1] eq "cell_leakage_power") {
	    $leakage_power = $fields[3];
	    if( defined $mem{$mem_name}{"vdd"} ) {
		$mem{$mem_name}{"leakage"} = $leakage_power/$mem{$mem_name}{"vdd"};
	    }
	}

	if( ($fields[1] eq "pin") || ($fields[1] eq "bus") ){
	    @name = split/\((\S+)\)/,$_;
	    $pin_name = $name[1];
	    $done_pin = 0;
	}

	if( (/\{/) && !($done_cell) ){
	    if(($fields[1] eq "pin") || ($fields[1] eq "bus")){
		$block_count = 0;
		#print "Start PIN $pin_name for $mem_name\n"; 
	    }

	    if($fields[0] eq "cell") {
		$brace_count = 0;
		#print "Begin memory $mem_name\n"; 
	    }

	    $brace_count++;
	    $block_count++;
	}

       	if( (/\}/) && !($done_cell) ){
	    $brace_count--;
	    $block_count--;
	}

	if( (/clock \: true/) && !($done_pin) ){
	    $is_clock = 1;
	}

	if( ($pin_name =~ /dout/) && !($done_pin) ) { #(/direction \: output/)
	    $is_out = 1;
	}

	if( ($pin_name =~ /addr/) && !($done_pin) ) { #(/direction \: input/)
	    $is_addr = 1;
	}

	if(!($done_pin) && ($is_clock)){
	    if(/internal_power/){
		$power_start = 1;
		$write_power = 0;
		$read_power = 0;
		$another_count = 0;
	    }

	    if( (/\!cs_n\*we_n/) && (/when/) ){	
	    #if(/when \: \"\!cs_n\*we_n\"/){
		$write_power = 1;
		$read_power = 0;
		$power_start = 0;
	    }

	    #elsif( ( (/\!cs_n\*\!we_n/) || (/\!cs_n/)  ) && (/when/) ) {
	    elsif( (/\!cs_n/) && (/when/) ){
		$read_power = 1;
		$write_power = 0;
		$power_start = 0;
	    }

	    if( ($power_start == 1) && (/\}/) ) {
		$another_count++;
		if($another_count == 2) {
			$read_power = 0;
			$write_power = 0;
			$power_start = 0;
		}	
	    }

	    if(/values /){
		@val = split/\"(\S+)\"/,$_;
		$energy = $val[1];
		if($read_power == 1){
		    if($energy > $Epd_read{"$mem_name"}){
			$Epd_read{"$mem_name"} = $energy;
		    }
		}
		elsif($write_power == 1){
		    if($energy > $Epd_write{"$mem_name"}){
			$Epd_write{"$mem_name"} = $energy;
		    }
		}

		elsif($power_start == 1) {
		    if($energy >= $Epd_standby{"$mem_name"}){
			$Epd_standby{"$mem_name"} = $energy;
		    }
		}
	    }
	}

	if(!($done_pin) && ($is_out)){
	    if( (/cell_rise\(/) || (/cell_rise \(/) ) {
	    #if($fields[1] eq "cell_rise"){
		$rise_delay = 1;
		$fall_delay = 0;
	    }

	   if( (/cell_fall\(/) || (/cell_fall \(/) ) { 
	    #if($fields[1] eq "cell_fall"){
		$rise_delay = 0;
		$fall_delay = 1;
	    }

            if(/related_pin/) {
		if(/clk/){
			$to_start = 1;
		}
		else {
			$to_start = 0;
		}
	    }				

	    if(/values/) {
		@_ = split;
		$delay = $_[2];
		if($rise_delay == 1) {
		    $ck2q_rise_delay = $delay;
		    #print "Rise delay is $ck2q_rise_delay\n"; 
		    $rise_delay = 0;
		}

	       	if($fall_delay == 1) {
		    $ck2q_fall_delay = $delay;
		    #print "Fall delay is $ck2q_fall_delay\n"; 
		    $fall_delay = 0; 
		}
	    }

	    if($to_start == 1) { 
		$ck2q_delay = 0.5 * ($ck2q_rise_delay + $ck2q_fall_delay); 
	        $mem{$mem_name}{"ck2q_delay"} = $ck2q_delay;	
	    }
	}

	if(!($done_pin) && ($is_addr)){
	    if(/timing_type \: setup/){
		$setup_start = 1;
		$hold_start = 0;
		$tsetup_rise = 0;
		$tsetup_fall = 0;
	    }

	    if(/timing_type \: hold/){
		$setup_start = 0;
		$hold_start = 1;
	    }	

	    if(/rise_constraint/){
		$rise = 1;
		$fall = 0;
	    }

	    if(/fall_constraint/){
		$rise = 0;
		$fall = 1;
	    }

	    if(($setup_start) && ($rise) && (/values/)){
		@val = split/\,/,$_;
		$tsetup_rise = $val[2];
		$rise = 0;
	    }

	    if(($setup_start) && ($fall) && (/values/)){
		@val = split/\,/,$_;
		$tsetup_fall = $val[2];
		$fall = 0;
	    }
	}

	$tsetup = 0.5 * ($tsetup_rise + $tsetup_fall);
	#print "Setup time is $tsetup\n";
	$mem{$mem_name}{"tsetup"} = $tsetup;

	if(($brace_count == 0)  && !($done_cell) ){
		#print "\n\n Done with Mem name is $mem_name\n\n";
		$done_cell = 1;
	}	

#	if(($brace_count==0) && !($done_cell)){
#	    $done_cell = 1;
	#    $mem{$mem_name}{"ck2q_delay"} = $ck2q_delay;
	#    $mem{$mem_name}{"tsetup"} = $tsetup;
#	   	if($mem_name eq "qcsram1fwdng00_288x8_8_fs") { 
#	    print "End memory $mem_name\n\n"; }
#	}

	if( ($block_count==0) && !($done_pin)){
	    $done_pin = 1;
	    $is_clock = 0;
	    $is_out = 0;
	    $is_addr = 0;
	    #print "Finish PIN $pin_name for $mem_name\n";
	}
    }
    }
    close f_lib;
  #  print "Done reading memory LIB file $opt_l\n";
}

close lib;

$apl_file = $VarHash{apl_setup_dir}."/.apache/apache.apl";
if (-r "$apl_file") {
  edaOpenFile(apl, "$apl_file", "r");
}

while(<apl>){
	#print "Reading APL file $apl_file\n";
	if(/\{/) {
		@_ = split;
		$mem_name = $_[0];
		$start{"$mem_name"} = 1; 
	}
	if( (/sampling/) && ($start{"$mem_name"} == 1) ) {
		@_ = split;
                $mem{"$mem_name"}{"tr_q"} = $_[1];
                $mem{"$mem_name"}{"tf_q"} = $_[2];
                $mem{"$mem_name"}{"Cload"} = $_[5];
	}

	if(/\}/) {
		$start{"$mem_name"} = 2;
	}		
	#print "Done reading APL file $apl_file\n";
    }
close apl;


$vdd_square = 1;
foreach $name (keys %keep) {
#	print "Memory name is $mem_name\n";
	$mem_name = $keep{"$name"};
	if (($mem{$mem_name}{"vdd"} eq "???") || ($mem{$mem_name}{"vdd"} eq "")) {
  	  $mem{$mem_name}{"vdd"} = $VarHash{vdd_value};
        }
	$vdd_square = $mem{$mem_name}{"vdd"} * $mem{$mem_name}{"vdd"};
        $mem{$mem_name}{"Cpd_write"} = $Epd_write{"$mem_name"}/$vdd_square;
        $mem{$mem_name}{"Cpd_read"} = $Epd_read{"$mem_name"}/$vdd_square;
        $mem{$mem_name}{"Cpd_standby"} = $Epd_standby{"$mem_name"}/$vdd_square;
	$equiv_gate_count = int( $mem{$mem_name}{"words"} * $mem{$mem_name}{"bits"} * 1.1 );
	$mem_type = $mem{$mem_name}{"type"};
	$vdd = $mem{$mem_name}{"vdd"};
	$Cpd_read = $mem{$mem_name}{"Cpd_read"};
        $Cpd_write = $mem{$mem_name}{"Cpd_write"};
        $Cpd_standby = $mem{$mem_name}{"Cpd_standby"};
        $ck2q_delay = $mem{$mem_name}{"ck2q_delay"};
        $tsu = $mem{$mem_name}{"tsetup"};
	$tr_q =  $mem{"$mem_name"}{"tr_q"};
	$tf_q = $mem{"$mem_name"}{"tf_q"};
	$Cload = $mem{"$mem_name"}{"Cload"};

	$Leakage_i = $mem{"$mem_name"}{"leakage"};

        #if( ($mem_name eq "") || ($equiv_gate_count == 0) || ($mem_type eq "") || ($vdd eq "") || ($Cpd_read == 0) || ($Cpd_write == 0) || ($Cpd_standby == 0) || ($ck2q_delay == 0) || ($tsetup == 0) ) {

	if($mem_name eq "") {
		print err "ERROR: Memory cell $mem_name does not exist\n";
		next;
	}

	if($equiv_gate_count == 0) {
		print err "ERROR: Memory cell $mem_name failed. Could not find memory word/bit count\n";
		next;
	}

	if($mem_type eq "") {
		print err "ERROR: Memory cell $mem_name failed. Could not find memory type (SRAM/REG_FILE)\n";
		next;	
	}

	if($vdd eq "") {
		print err "ERROR: Memory cell $mem_name failed. Could not find VDD value\n";
		next;
	}

	if($Cpd_read == 0) {
                print err "ERROR: Memory cell $mem_name failed. Could not find Cpd_read in LIB\n";
                next;
	}	

	if($Cpd_write == 0) {
	    $Cpd_write = $Cpd_standby;
                #print "#Unable to generate for cell $mem_name. Could not find parameter Cpd_write in LIB \n";
                #next;
	}

        if($Cpd_standby == 0) {
                print err "ERROR: Memory cell $mem_name failed. Could not find Cpd_standby in LIB\n";
                next;
	    }

	if($ck2q_delay == 0) {
                print err "ERROR: Memory cell $mem_name failed. Could not find ck2q_delay in LIB \n";
                next;
	    }

	if($tsetup == 0) {
                print err "ERROR: Memory cell $mem_name failed. Could not find tsetup in LIB \n";
                next;
	}

	if( !(defined $mem{"$mem_name"}{"tr_q"} ) || !(defined $mem{"$mem_name"}{"tf_q"}) || !(defined $mem{"$mem_name"}{"Cload"})) {	
		print err "ERROR: Memory cell $mem_name failed. Could not find required parameters in apache.apl\n"; 
		next;
	}
                $tr_q = $tr_q.("ns");
                $tf_q = $tf_q.("ns");
                $Cload = $Cload.("fF");
		$Cpd_read = $Cpd_read*$cap_unit;
		$Cpd_write = $Cpd_write*$cap_unit;
		$Cpd_standby = $Cpd_standby*$cap_unit;
	        $Leakage_i = $Leakage_i*$leakage_unit;

#	    	$Cpd_read = $Cpd_read.("pF");
#    		$Cpd_write = $Cpd_write.("pF");
#    		$Cpd_standby = $Cpd_standby.("pF");
    		$tsu = $tsu.("ns");
    		$ck2q_delay = $ck2q_delay.("ns");
		
		$date = `date`;

		print conf "# AVM configuration file generated by avm_setup.pl on $date\n\n";

                print conf "$mem_name\n";
                print conf "{\n";
                print conf "EQUIV_GATE_COUNT  $equiv_gate_count\n";
                print conf "MEMORY_TYPE  $mem_type\n";
                print conf "VDD   $vdd\n";
                print conf "Cpd_read    $Cpd_read\n";
                print conf "Cpd_write   $Cpd_write\n";
                print conf "Cpd_standby $Cpd_standby\n";
                print conf "tsu   $tsu\n";
                print conf "ck2q_delay  $ck2q_delay\n";
                print conf "tr_q   $tr_q\n";
                print conf "tf_q   $tf_q\n";
                print conf "Cload  $Cload\n";
	        print conf "Leakage_i $Leakage_i\n";
		print conf "WAVEFORM_TYPE trapezoidal\n";
                print conf "}\n\n";
    }

close out;
close err;
close war;

print STDOUT "\n\nGenerated AVM configuration file : ./avm.conf\n\n";


