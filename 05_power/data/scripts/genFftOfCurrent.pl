eval '(exit $?0)' && eval 'exec perl -S $0 ${1+"$@"}'
  && eval 'exec perl -S $0 $argv:q'
  if 0;
 
#############################################################################
# Name       : genFftOfCurrent.pl
# Description:  To generate the FFT of current supplied for user-specified domain during RedHawk simulation.
# $Revision  :  1.2$
# Author     : Vinayakam Subramanian , email : vinayakam@apache-da.com
#############################################################################
# Updated 2009/04/02 Calvin 
# add enhancement for repeating time domain


=head1 NAME

genFftOfCurrent.pl - To generate the FFT of current supplied for user-specified domain during RedHawk simulation.

=head1 SYNOPSIS

genFftOfCurrent.pl [options] arguments

Options: -h, -help, -man , -o , -i , -domain, -p, -pad, -repeat_num, -repeat_start_time, -outputformat, -interp, -unit, -oversampling, -minFreq, -maxFreq, -sv

=head1 DESCRIPTION

B<genFftOfCurrent.pl> generates the FFT of a current waveform input.  This input can be either RedHawk's battery current output file adsRpt/Dynamic/<top-cell-name>.ivdd.vsrc or RedHawk's pad current waveform file adsRpt/Dynamic/pad.currrent

 
=head1 OPTIONS

=over

=item -h

Prints a short synopsis.

=item -help

Prints a synopsis and a description of program options.

=item -man

Prints the entire man page. 

=item -i

Specify the input current waveform file.  Default : adsRpt/Dynamic/*ivdd.vsrc

=item -domain

Specify the domain name. Applies only with -i option. Optional. Default : TOTAL ,ie, sum of all domains.

=item -o

Specify the output FFT report filename. Applies only with -i option. Default : redhawk_current_fft.rpt

=item -sv

Specify this option if you want sv-viewable ta0 files as output. Applies only with -i option. Output filenames are : <output_file_name>.1.ta0 and <output_file_name>.2.ta0

=item -p

Specify the input pad currents waveform file. Default : none

=item -pad

Specify the list of pad names for which you want to generate FFT. Applies only with -p option. Default : ALL

=item -repeat_num

Specify number of times to repeat current by extending time domain.  Default : none

=item -repeat_start_time

Specify starting time point for repeating the current.  Default : 0 

=item -minFreq

Specify the minimum frequency. Default :  minFreq = 1/(tmax-tmin)

=item -maxFreq

Specify the maximum frequency. Default : none

=item -oversampling

Specify the oversampling factor used for FFT claculation.. Default : 8

=item -interp

Specify the interpolation mode as linear or spline. Default : spline

=item -outputformat

Specify the output format of the FFT report. Possible values are ri or mp or db or dbm or dbu. Default : mp

=item -unit

Specify the time unit of input file. Possible values are ps, ns, us, ms, s. Default : ps


=head1 EXAMPLE

genFftOfCurrent.pl -i redhawk_run/adsRpt/Dynamic/design.ivdd.vsrc  -domain VDD  -o redawk_vdd_current_fft.rpt

=back

=head1 REQUIREMENTS

The APACHEROOT environment variable must be set to the desired RedHawk version. This is required for calling the current2fft utility.  

=head1 AUTHOR

Vinayakam Subramanian , Applications Engineer, Apache India.

email : vinayakam@apache-da.com

=head1 COPYRIGHT

COPYRIGHT (c) 2008 Apache Design Solutions. All right reserved.

=cut

# end program documentation

use Getopt::Long;
use Pod::Usage;

# begin main program...

        # define script command line options
        my $opt_h   ='';            # short help
        my $opt_help='';            # long help
        my $opt_man ='';            # man page
	my $opt_i = '';
	my $opt_domain = '';
	my $opt_o = '';
        # get input options..
        GetOptions( 'h'    => \$opt_h,
                    'help' => \$opt_help,
                    'man'  => \$opt_man,
		    'i=s' => \$opt_i,
		    'domain=s' => \$opt_domain,
		    'p=s' => \$opt_p,
		    'sv' => \$opt_sv,
		    'pad=s' => \$opt_pad,
                    'repeat_num=s' => \$opt_rnum,
                    'repeat_start_time=s' => \$opt_rtime,
		    'minFreq=s' => \$opt_minFreq,
		    'maxFreq=s' => \$opt_maxFreq,
		    'oversampling=s' => \$opt_oversampling,
		    'interp=s' => \$opt_interp,
		    'unit=s' => \$opt_unit,
		    'outputformat=s' => \$opt_outputformat,
		    'o=s' => \$opt_o ) || pod2usage (-verbose => 0);
                                
        # a little documentation for the user...
        pod2usage (-exitval => 0, -verbose => 2) if $opt_man;
        pod2usage (-exitval => 0, -verbose => 1) if $opt_help;
        pod2usage ( -msg => "The following is the usage .\n To learn more about the options, use --help\n", -exitval => 0 , -verbose => 0) if $opt_h;
	# set fftOptions
	$fftOptions = " ";
	if($opt_minFreq) {
		if($opt_maxFreq) {
			$fftOptions .= " -frequency $opt_minFreq $opt_maxFreq";
		} else {
			print "\nWARNING : minFreq is specified but maxFreq is not specified. Ignoring minFreq setting.";
		}
	} else {
		if($opt_maxFreq) {
			print "\nWARNING : maxFreq is specified but mainFreq is not specified. Ignoring maxFreq setting.";
		}
	}
	if($opt_oversampling) {
		$fftOptions .= " -oversampling $opt_oversampling";
	}
	if($opt_interp) {
		$fftOptions .= " -interp $opt_interp";
	}
	if($opt_unit) {
		$fftOptions .= " -unit $opt_unit";
	}
	if($opt_outputformat) {
		$fftOptions .= " -outputformat $opt_outputformat";
	}
	# current2fft mode
	if($opt_p) {
		#if input file does not exist, exit.
		unless( -e $opt_p ) { 
			die "\nFATAL : The input file $opt_p does not exist.\nProgram Exit!\n";
		}
		print "\nGiven Inputs:\nPad current waveform file - $opt_p\n";
		if($opt_pad) {
			$fftOptions .= " -pad $opt_pad";
			print "Pad - $opt_pad\n";
		}
		print "\nProcessing.....\n";
		# check whether APACHEROOT is set
        	$temp = `echo \"\$APACHEROOT\"`;
	        $aroot = $temp;
	        chomp($temp);
	        if($temp =~ /^\s*$/ || $temp =~ /APACHEROOT/) {
	                print "\nERROR: Environment variable APACHEROOT not set!\nEnter value for APACHEROOT:";
	                $apache_root = <STDIN>;
	                print "\nGiven value for APACHEROOT is $apache_root";
			$aroot = $apache_root;
	        }
	        chomp($aroot);  # remove trailing \n
	        $aroot =~ s/\s*$//; # remove trailing white space
	        $aroot =~ s/\/*$//; # remove trailing /
	        $aroot =~ s/^\s*//; # remove leading white space
	        print "\nApacheRoot : $aroot\n";
	        print "\nRunning current2fft with below command ...\n$aroot/bin/current2fft -file $opt_p $fftOptions\n";
		@temp = `$aroot/bin/current2fft -file $opt_p $fftOptions`;
	
		$exit_status= $? >> 8;
	        if($exit_status != 0) {
	                print "Exit status = $exit_status";
			print "\nErrors occured while running current2fft.Please see fft.log for more details!\n";
	         }
	        else {
	                #system("\\rm -rf fft.log ");
			print "\nFFT creation successful!\nOutput FFT report files are <padname>pad.fft\n";              
	
	        }
	}
	else {
	# ivdd.vsrc mode
	if($opt_i) {
		# $opt_sta = $opt_sta :) ;
		
	}
	else {
		$opt_i = <adsRpt/Dynamic/*ivdd.vsrc>;
		if($opt_i =~ /vsrc/ ) {
			print "\nWARNING: Current waveform file not specified with -i option. Assuming current waveform file is $opt_i .\n";
		}
		else {
			die "Current waveform file not specified with -i option and adsRpt/Dynamic/*ivdd.vsrc does not exist. Please specify current waveform file using -i option. Exit!\n";
		}
	}
	
	#if input file does not exist, exit.
	unless( -e $opt_i ) { 
		die "\nFATAL : The input file $opt_i does not exist.\nProgram Exit!\n";
	}

	
	# if domain name was not specified, assume total
	unless($opt_domain) {
		print "\nWARNING : Domain name not specified with -domain option.\nTaking total current waveform as input.\n";
		$opt_domain = "TOTAL";
	}

	if($opt_domain =~ /^\s*$/ || $opt_domain =~ /^\s*\#\s*$/ ) {
		die "\nFATAL : Domain name contains only blank/hash.\nProgram Exit!\n";
	}

	# print inputs
	print "\nGiven Inputs:\nCurrent waveform file - $opt_i\nDomain name - $opt_domain\n";
	print "\nProcessing.....\n";
	open CURFP , " $opt_i" or die "\nFATAL : Cannot open current waveform file $opt_i for reading : $!\n";
	if($opt_o) {
		# $opt_sta = $opt_sta :) ;
	}
	else {
		$opt_o = "redhawk_current_fft.rpt";
	}
	open OUTFP , "> $opt_o" or die "Cannot create output file $opt_o : $!\n";
	open TEMPFP ," > .cur.wave.temp" or die"Cannot write to file .cur.wave/temp: $!\n";
	print TEMPFP "\"Current\n";
		$foundDomainFlag = 0;
		$includePresim =0;
		if($opt_domain eq "TOTAL" ) {
			while(<CURFP>) {
				unless(/^\"/ || /^#/ || /^Title/ || /^\s*$/) {
					chomp;
					split;
					$value{$_[0]} += $_[1];
				}
			}
			#foreach $key (sort {$a <=> $b} keys %value) {
				#print "$key => $value{$key}\n";
			#}
			if($opt_rnum) {
				if (defined $opt_rtime) {
					print "\nTime domain will be extended by reusing data starting from $opt_rtime,  $opt_rnum times. \n";
				}
				else {
					print "\nNo start_time specified. Using start_time of 0.\n";
					$opt_rtime = 0;
				}
				%newvalue = extend_time(\%value, \$opt_rnum, \$opt_rtime);
				%value = %newvalue;
			}
			foreach $key (sort {$a <=> $b} keys %value) {
				
				if( ($includePresim == 0 && $key>= 0)  || ($includePresim == 1)) {
					print TEMPFP "$key $value{$key}\n";
				}
			}
		}
		else {
			while(<CURFP>) {
				if(/^\"$opt_domain\s*$/) {
					$foundDomainFlag = 1;
					while(<CURFP>) {
						unless(/^\"/ || /^#/ || /^Title/) {
							chomp;
							split;
							if( ($includePresim == 0 && $_[0]>= 0)  || ($includePresim == 1)) {
								print TEMPFP "$_[0] $_[1]\n";
							}
						}
						else {
							last;
						}
					}
						
					
				}
			}
			if($foundDomainFlag == 0) {
				die "\nERROR: Domain $opt_domain not found in current waveform file. Exit!\n";
			}
		}
		
	# check whether APACHEROOT is set
        $temp = `echo \"\$APACHEROOT\"`;
        $aroot = $temp;
        chomp($temp);
        if($temp =~ /^\s*$/ || $temp =~ /APACHEROOT/) {
                print "\nERROR: Environment variable APACHEROOT not set!\nEnter value for APACHEROOT:";
                $apache_root = <STDIN>;
                print "\nGiven value for APACHEROOT is $apache_root";
		$aroot = $apache_root;
        }
        chomp($aroot);  # remove trailing \n
        $aroot =~ s/\s*$//; # remove trailing white space
        $aroot =~ s/\/*$//; # remove trailing /
        $aroot =~ s/^\s*//; # remove leading white space
        print "\nApacheRoot : $aroot\n";
        
	@temp = `$aroot/bin/current2fft -pad Current -file .cur.wave.temp $fftOptions`;

	$exit_status= $? >> 8;
        if($exit_status != 0) {
                print "Exit status = $exit_status";
		print "\nErrors occured while running current2fft.Please see fft.log for more details!\n";
         }
        else {
                #system("\\rm -rf .cur.wave.temp ");
		system("mv Currentpad.fft $opt_o");
		print "\nFFT creation successful!\nOutput FFT report file is $opt_o\n";              
		if($opt_sv) {
			print "\nConverting to sv-viewable format using prraw...\n";
			system(" awk '{print \$1 \" \"  \$2}' $opt_o > .temp1 ");
			system(" awk '{print \$1 \" \"  \$3}' $opt_o > .temp2 ");
			system(" $aroot/bin/prraw .temp1 ${opt_o}.1.ta0");
			system(" $aroot/bin/prraw .temp2 ${opt_o}.2.ta0");
			print "\nOutput sv-viewable files are ${opt_o}.1.ta0 and ${opt_o}.2.tao!\n";
		}
			

        }
	}
	print "\nProgram Finished!\n";
	

sub extend_time
{
	my (%current) = %{$_[0]};
        my ($repeatnum) = ${$_[1]};
        my ($starttime) = ${$_[2]};
        my @time = sort {$a <=> $b} keys %current;
        my $maxindex = $#time;
        my $maxtime = $time[$#time];
        my ($startindex) = grep $time[$_] eq $starttime, 0 .. $#time;
        my $incr = $maxtime - @time[$maxindex-1];
        my $maxcount = $maxindex - $startindex + 1;
        for ($num = 0; $num < $repeatnum; $num++) {
		for ($count=1; $count <= $maxcount; $count++) {
        		$current{$maxtime + ($num * $maxcount * $incr) + $incr*$count} = $current{$starttime + $incr*($count-1)};
		}
	}
	return (%current);
}
