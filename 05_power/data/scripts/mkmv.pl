eval '(exit $?0)' && eval 'exec perl -w -S $0 ${1+"$@"}'
    && eval 'exec perl -w -S $0 $argv:q'
    if 0;
	
#############################################################################
# Name       : mkmv.pl
# Description: A script to convert the .gif files found in a .apache/.movie 
#              directory into an antimated gif.
# $Revision  : 1.1 $
# Author     : Jeffrey Smith
# Created    : 3/25/05
# Copyright (c) 2004 by Apache Design Solutions, Inc. All rights reserved.
# 
# Revision History
#
# Rev 1.5
#  - Changed default l value to 0 for PowerPoint compatability
#
# Rev 1.4
#  - Corrected some spelling errors
#
# Rev 1.3
#  - Added output optimization via "gifsicle" to reduce the size of the 
#    resulting anamation.
#
# Rev 1.2
#  - Added support for RH 5.1.X (user specifies movie dir instead of RH
#    working dir)
#
# Rev 1.1
#  - Better usage/man page
#  - Added -b, -e, and -s options to taylor final animation
#  - Added some "info" to the output so script progress can be tracked
#
# Rev 1.0
#  - Initial release. 
#
#############################################################################

=head1 NAME

mkmv.pl - make a DvD movie (animated gif) 

=head1 SYNOPSIS

mkmv.pl [options] arguments

Options: -h, -help, -man, -d n, -l n, -b n, -e n, -s n
         where "n" is an integer value
  
Arguments: -i movie_dir, -o output_gif

=head1 DESCRIPTION

mkmv.pl creates a gif anamation from the idividual gifs stored in the RedHawk movie directory 
(typically .apache/.movie). 
The pvi.control file is used so that the individual gifs are included in the proper sequence. 
Numerious option are provide to control various aspects of the final animation (see below).

=head1 OPTIONS

=over 

=item -h

Prints a short synopsis.

=item -help

Prints a synopsis and a description of program options and arguments.

=item -man

Prints the entire man page.

=item -d n

Sets the frame delay time to n * 10 milliseconds. 
Use this option to set the time lapse between frames in the output gif. 
The default is 10 which sets the frame delay to 100mS or 10 frames/second.

=item -l n

Specifies the number of times the animation will loop (repeat) before stopping.
Specifying a loop count of 0 causes the animation to loop forever (default).
Note that some versions of PowerPoint require that the gif be generated 
with l=0.

=item -b n

Specifies the beginning frame number to use in the animation. 
Use this option to skip unwanted frames at the beginning of the animation. 
The default value is 1 (the first frame in the sequence).

=item -e n

Specifies the ending frame number to use in the animation sequence. 
Use this option to skip unwanted frames at the end of the animation. 
By default, all frames will be included.

=item -s n

Specifies the number of frames to skip in the animation sequence. 
Use this option to specify the number of interleaved frames that will be 
omitted from the animation. If specified, the program will output the 
first frame specified (see -b option), skip the next n-1 frames, 
output the next frame, skip the next n-1 frames, and so forth until  
all frames are processed. In other words, 1 of n frames are included in 
the final animation. The default value is 1 (output all frames).

=head1 ARGUMENTS

=item -i movie_dir

The path to the directory where the DvD movie was stored. RedHawk will by
default store the DvD movie in ".apache/.movie" but the user also has the option to 
specify a custom movie directory.  Use this option to specify the same directory 
as that specified in the RedHawk GUI when the movie was generated. You may use 
realitive or absolute paths.

=item -o output_gif

The path to the output file for the animated gif. Once again, you may specify 
realitive or absolute paths.

=back

=head1 EXAMPLES

1. Create an animated gif called out.gif from the movie generated in the current RedHawk working directory-

=over

mkmv.pl -i .apache/.movie -o out.gif

=back

2. Create an animated gif called out.gif from the movie stored in ~/movies/sim1-

=over 

mkmv.pl -i ~/movies/sim1 -o out.gif

=back

3. Create the same gif as above but with a frame to frame delay of 50 mS (makes the animated gif go faster)-

=over 

mkmv.pl -d 5 -i ~/movies/sim1 -o out.gif

=back

4. Create the same gif as above but start the animation at frame # 10 and end the animation at frame # 100-

=over

mkmv.pl -b 10 -e 100 -d 5 -i ~/movies/sim1 -o out.gif

=back

5. Create the same gif as above but only use 1 in 3 (frame # 10, 13, 16, 19...) of the original gifs -

=over

mkmv.pl -s 3 -b 10 -e 100 -d 5 -i ~/movies/sim1 -o out.gif

=back

=head1 REQUIREMENTS

You must have the ImageMagick tools on your machine (see http://www.imagemagick.org/). More specifically, 
the ImageMagick "convert" routine must be in your path. Also, if "gifsicle" (http://www.lcdf.org/~eddietwo/gifsicle/) 
is found in your path it will be used to optimize the animation which will *significantly* 
reduce the size of the final result. 

=head1 COPYRIGHT

COPYRIGHT (c) 2005 Apache Design Solutions. All right reserved.

=cut

# end program documentation...

use strict;
# use diagnostics;
use Getopt::Long;
use Pod::Usage;

# begin main program...
{

	# define script command line options
    my $opt_h	='';		# short help
    my $opt_help='';		# long help
    my $opt_man	='';		# man page
    my $opt_d	='';		# delay 
	my $opt_l 	='';		# loop count
    my $opt_i	='';		# input directory
    my $opt_o	='';		# output file
	my $opt_b	='';		# beginning frame
	my $opt_e	='';		# ending frame
	my $opt_s	='';		# frames top skip
	
	# program vars
	my $pvi_control_file;	# path to the pvi.control file
	my $gif_list;			# list of gif files to process
	my $frame_delay;		# delay between subsequent frames
	my $loop_count;			# number of times to repeat the animation
	my @gifs;				# individual gifs
	my $gif_count;			# number of gigs to be processed
	my $gif;				# individual gif file
	my $beginning_frame;	# beginning frame
	my $ending_frame;		# ending frame
	my $skip_count;			# frames to skip
	my $i;					# index vars
	my $output_gif_count;	# number of gifs included in the animated gif
	
	# get input options..
    GetOptions(	'h'    => \$opt_h,
				'help' => \$opt_help,
				'man'  => \$opt_man,
				'd=i'  => \$opt_d,
				'l=i'  => \$opt_l,
				'i=s'  => \$opt_i,
				'o=s'  => \$opt_o,
				'b=i'  => \$opt_b,
				'e=i'  => \$opt_e,
				's=i'  => \$opt_s ) or pod2usage(0);
								
	# a little documentation for the user...				
	pod2usage (-exitval => 0, -verbose => 2) if $opt_man;
	pod2usage (-exitval => 0, -verbose => 1) if $opt_help;
	pod2usage (-exitval => 0, -verbose => 0) if $opt_h;
			
	# check for required arguments...	
	if (!$opt_i and !$opt_o) { pod2usage(-exitval => 1, -verbose => 0) };
	
	# check for existance/size of pvi.control file...
	$pvi_control_file = "$opt_i/pvi.control";		
	!(-r $pvi_control_file) && die "ERROR:   Cannot find pvi.control file!\n         Check your path to the movie directory and make sure\n         you generated a movie from the RedHawk gui.\n";
	(-z $pvi_control_file) && die "ERROR:   pvi.control file is empty!\n         Make sure you generated a movie from the RedHawk gui.\n";
	
	# set the frame delay...
	if ( $opt_d ) {
		$frame_delay = $opt_d;
	} else {
		$frame_delay = 10;
	}
		
	# set the loop count...
	if ( $opt_l eq '' ) {
		$loop_count = 0;
	} else {
		$loop_count = $opt_l;
	}	
	
	# set the beginning frame...
	if ( $opt_b ) {
		$beginning_frame = $opt_b;
	} else {
		$beginning_frame = 1;
	}	
	
	# set the skip count...
	if ( $opt_s ) {
		$skip_count = $opt_s;
	} else {
		$skip_count= 1;
	}	
				
	# get the list of gifs
	$gif_list = `cat $pvi_control_file`;
	chomp ($gif_list); 
	
	# get the individual gifs
	@gifs = split /^/, $gif_list;
	
	# get the number of gifs
	$gif_count = shift @gifs;
	chomp ($gif_count);
	
	# a little status for the user
	print "INFO:    There is a total of $gif_count gifs in the .movie directory.\n";
	
	# set the ending frame...
	if ( $opt_e ) {
		$ending_frame = $opt_e;
	} else {
		$ending_frame = $gif_count;
	}		
	
	# check frame related options
	if ( $ending_frame > $gif_count) { 
		print "WARNING: The ending frame ($ending_frame) is greater than the total number of frames ($gif_count)!\n         Setting the the ending frame to $gif_count.\n";
		$ending_frame = $gif_count;
	}	
	die "ERROR:   The beginning frame ($beginning_frame) is greater than the total number of frames ($gif_count). Abort!\n" if ( $beginning_frame > $gif_count );
	die "ERROR:   The ending frame ($ending_frame) is greater than the beginning frame ($beginning_frame). Abort!\n" if ( $beginning_frame > $ending_frame );
	
	# remove any realitive paths from gif names (present in older 4.3.X pvi.control files)
	# and build the full path to the gif file
	$i=0;
	foreach $gif (@gifs) {
		chomp ($gif);
		$gif =~ s/(^.*\/)(.+$)/$2/;
		$gif = "$opt_i/" . "$gif";
		++$i;
	}	
	
	# build the gif list as specified by the user...
	$gif_list="";
	$i = $beginning_frame;
	$output_gif_count = 0;
	while ( $i <= $ending_frame ) {
		$gif_list = "$gif_list" . "$gifs[($i-1)] ";
		$i += $skip_count;
		++$output_gif_count;
	}
	
	# check for an empty list
	die "ERROR:   pvi.control file is empty! Please check your input options.\n" if ($gif_list eq "");
	
	# more status
	print "INFO:    The output animation will contain $output_gif_count frames.\n";
	print "INFO:    Generating the animation...\n";
	
	# generate the gif!
	system ("convert -delay $frame_delay $gif_list -loop $loop_count $opt_o");	
	
	# check to see if gifsicle is in the path	
	if ( !system ("which gifsicle &> /dev/null") ) { 	# gifsicle is on the machine so lets crunch (optomize) the gif
	
		# status...
		print "INFO:    Optimizing the animation...\n";
		
		# crunch the file
		system ("mv $opt_o $opt_o.big");
		system ("gifsicle -O2 -o $opt_o < $opt_o.big");
		system ("rm  $opt_o.big");
		
	} else {	# no gifsicle so can't compress the result
		
		print "INFO:    Unable to optimize (compress) the animation - \"gifsicle\" not found in your path... \n";
			
	}	
	
	print "INFO:    Done!\n";
				
}

# that's it!
exit;
