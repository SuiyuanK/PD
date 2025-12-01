#
#
# -------------------------------------------------------
# Resource Prediction Utility
# For Redhawk run resources
#
# Aveek Sarkar
# June 12, 2008
# -------------------------------------------------------
#
# -------------------------------------------------------
# Purpose of the script is as follows:
#
# 1) Check for proper RH settings:
#   - S/R
#   - Recommended caching mode/size
#   - asim timestep
#
# 2) Machine configuration (memory, swap space, disk size)
#   - Impact of large number of nodes to asim memory usage
#   - A few of our customers are using 64G machines 
#     for running 200M node large designs. This causes
#     resources waste and customer frustration
#
# 3) Unreasonable user's settings
#   - Long simulation span, pre-sim span, etc.
#
# --------------------------------------------------------
#
#

use Getopt::Long;
$options = GetOptions ("gsr:s" => \$gsr, "stat=s" => \$stat, "help" => \$help );

if($help) {
    print STDOUT "Usage:\n";
    print STDOUT "perl predictResource.pl [-gsr <name of GSR>] [-stat <name of .statistic file] [-help]\n";
    exit(0);
}

print STDOUT "--------------------------------------------------------\n\n";


if( (-e "$gsr") ) {
    print STDOUT "INFO: Opening $gsr as GSR file\n";
    open( GSR,"$gsr");
    $got_gsr = "yes";
}
elsif( ($gsr) && !(-e "$gsr")) {
    print STDOUT "INFO: Missing $gsr. Not found\n";
    exit(0);
}
elsif( !($gsr) && (-e ".apache/apache.gsr") ) {
    print STDOUT "INFO: Opening .apache/apache.gsr as GSR file\n";
    open( GSR,".apache/apache.gsr");
    $got_gsr = "yes";
}
else {
    print STDOUT "INFO: No GSR found. Will request user inputs\n";
    $got_gsr = "no";
}

if( $got_gsr =~ /yes/ ) {
    while( <GSR> ) {
	chomp;

	if( /^\s*DYNAMIC_SIMULATION_TIME\s+(\S+)$/ ) {
	    $sim_time = $1;

	    if( $sim_time =~ /[p|n]/ && $sim_time =~ /[e]/ ) {
		print STDOUT "ERROR: Simulation time has double units. Please check\n";
		exit(0);
	    }

	    $sim_time =~ s/ps/e-12/;
	    $sim_time =~ s/ns/e-9/;

	    # change time to ps
	    $sim_time = $sim_time*1e12; 
	}

	if( /^\s*DYNAMIC_TIME_STEP\s+(\S+)$/ ) {
	    $step_time = $1;

	    if( $step_time =~ /[p|n]/ && $sim_time =~ /[e]/ ) {
		print STDOUT "ERROR: Simulation time step has double units. Please check.\n";
		exit(0);
	    }

	    $step_time =~ s/ps/e-12/;
	    $step_time =~ s/ns/e-9/;

	    # change time to ps
	    $step_time = $step_time*1e12; 

	}

	if( /^\s*DYNAMIC_PRESIM_TIME\s+(\S+)\s+(\S+)/ ) {
	    $presim_time = $1;
	    $psf = $2;

	    if( $presim_time =~ /[p|n]/ && $presim_time =~ /[e]/ ) {
		print STDOUT "ERROR: Pre-simulation time has double units. Please check.\n";
		exit(0);
	    }

	    $presim_time =~ s/ps/e-12/;
	    $presim_time =~ s/ns/e-9/;

	    if( $presim_time =~ /^-1$/ ) {
		$presim_time = 3.5e-9;
	    }

	    # change time to ps
	    $presim_time = $presim_time*1e12; 
	}

	if( /^\s*FREQ\s+(\S+)$/ ) {
	    $freq = $1;

	    if( $freq =~ /[G|M]/ && $freq =~ /[e]/ ) {
		print STDOUT "ERROR: Freq has double units. Please check.\n";
		exit(0);
	    }

	    $freq =~ s/M/e6/;
	    $freq =~ s/G/e9/;

	}
    }
    close(GSR) ;

    if( $sim_time !~ /[0-9]/ ) {
	$sim_time = (1/$freq)*1e12; # change to ps
    }

    if( $psf =~ /^0$/ || !($psf)) {
	$psf = 1;
    }


    if( $step_time < 0 ) {
	print STDOUT "ERROR: -ve tstep.\n";
	exit(0);
    }
    elsif( $step_time > 0 ) {
	$time_points = (($sim_time/$step_time)+($presim_time/($psf*$step_time)));
    }
    else {
	$step_time = 10;
	$time_points = (($sim_time/$step_time)+($presim_time/($psf*$step_time)));
    }

    $time_points = int($time_points);

}
else {
    print STDOUT "\n\n";
    print STDOUT "Please enter the total simulation time including pre-sim time (in ps):\n";
    $_ = <STDIN>;
    chomp;
    $sim_time = $_;
   

    print STDOUT "\n\nPlease enter the time step (in ps)\n";
    $_ = <STDIN>;
    chomp;
    $step_time = $_;

    print STDOUT "\n\nPlease enter the pre-simulation speedup (enter 1 if you are not sure what it means)\n";
    $_ = <STDIN>;
    chomp;
    $psf = $_;

    if( $psf <= 0 ) {
	$psf = 1.0;
    }

    #print STDOUT "\n\n";
    $time_points = (($sim_time/$step_time)+($presim_time/($psf*$step_time)));
}

print STDOUT "\n\n";
print STDOUT "INFO: SIM_TIME = $sim_time\n";
print STDOUT "INFO: TIME POINTS = $time_points\n\n";


if( $step_time > 50 ) {
    print STDOUT "INFO: Simulation time-step is high. Please use 10-50ps especially for CPM\n";
}


print STDOUT "\n\n-----------------------------------------------------------\n\n";




if( (-e "$stat") ) {
    print STDOUT "INFO: Opening $stat as statistics file\n";
    open( STAT,"$stat");
    $got_stat = "yes";
}
elsif( ($stat) && !(-e "$stat")) {
    print STDOUT "INFO: Missing $stat. Not found\n";
    exit(0);
}
elsif( !($stat) && (-e ".apache/.statistic") ) {
    print STDOUT "INFO: Opening .apache/.statistic as STAT file\n";
    open( STAT, ".apache/.statistic");
    $got_stat = "yes";
}
else {
    print STDOUT "INFO: No statistics file found. Will request user inputs\n";
    $got_stat = "no";
}

if( $got_stat =~ /yes/ ) {
    while( <STAT> ) {
	chomp;
	split;
	if( /^Leaf Inst/ ) {
	    $cell_count = 0.99*$_[3]/1000000;
	}
	if( /^Decap Inst/ ) {
	    $decap_count = $_[3]/1000000;
	}
	if(/^Node/) {
	    $node_count = $_[2]/1000000;
	}
	if( /^Resistor/ ) {
	    $res_count = $_[2]/1000000;
	}

    }
    close(STAT) ;
}


if( $cell_count <= 0 ) {
    print STDOUT "What is the number of instances (not gates) excluding filler and decap cells (in millions)?\n";
    $_ = <STDIN>;
    chomp;
    $cell_count = $_;
}
if( $decap_count <= 0 ) {
    print STDOUT "What is the number of filler and decap cells (in millions)?\n";
    $_ = <STDIN>;
    chomp;
    $decap_count = $_;
}
if( $node_count <= 0 ) {
    print STDOUT "What is the number of nodes (in millions)?\n";
    $_ = <STDIN>;
    chomp;
    $node_count = $_;
}
if( $res_count <= 0 ) {
    print STDOUT "What is the number of resistors (in millions)?\n";
    $_ = <STDIN>;
    chomp;
    $res_count = $_;
}

print STDOUT "

Values in millions:

Number of cells (excluding decaps/fillers) = $cell_count
Number of decaps and fillers               = $decap_count
Number of nodes                            = $node_count
Number of resistors                        = $res_count
-----------------------------------------------------------
\n\n";



$total_cell_count = $cell_count + $decap_count;

# predict total memory usage

# for 8.1
# $total_mem = int(13.91929958273361 + 0.21338858740509137*$node_count + 0.15043904911050493*$res_count - 0.16537119859033347*$cell_count)+1;


# Updated for 9.1 June 19, 2009
$total_mem = int(13.994019634252986 + 0.36174690971149864*$node_count + 0.03715023389743581*$res_count - 0.23002787641103994*$cell_count)+1;

$rh_peak_mem = int($total_mem * 0.52);
$asim_mem_dvd   = $rh_peak_mem; # assume
$asim_mem_sta   = 0.25*$rh_peak_mem; # assume

$mm_size     = int((1.36*$total_mem) - $rh_peak_mem);


$total_peak_mem_dyn = int(0.4*$rh_peak_mem + $asim_mem_dvd);
$total_peak_mem_sta = int(0.4*$rh_peak_mem + $asim_mem_sta);

print STDOUT "

Running static?

  You must have at least $rh_peak_mem\GB of physical RAM available.
  You must have at least $mm_size of LOCAL disk for .MM (cache_dir).

  If you don't have that much physical RAM, RedHawk will swap.

Running dynamic/CPM?

  You must have at least $total_peak_mem_dyn\GB of physical RAM available.
  You must have at least $mm_size of LOCAL disk for .MM (cache_dir).

  If you do not have it, but you have at least $rh_peak_mem\GB, then you the SAVE-RELOAD option available for dynamic analysis. Use the -sir option along with your \"perform analysis -vless command\". Check with RnD prior to doing so. 

  If your machine less than $rh_peak_memGB, RedHawk will swap. So better to get bigger machine.


******* NOTE: The machine you think you have may not be the one you get. Check
*******       the .apache/.run.setting to see what memory you have access to.

---------------------------------------------------------------
\n";



