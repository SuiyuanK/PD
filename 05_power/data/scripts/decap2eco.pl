eval '(exit $?0)' && eval 'exec perl -S $0 ${1+"$@"}'
    && eval 'exec perl -S $0 $argv:q'
    if 0;

$Id = "Version Info" ;
$foo = "0/0/0" ;
$id = "$Id: decap2eco.pl,v 1.1 2006/01/25 00:35:40 ben Exp $foo" ;

################################################################
# This software is confidential and proprietary information which may only be
# used with an authorized licensing agreement from Apache Design Systems
# In the event of publication, the follow notice is applicable:
# (C) COPYRIGHT 2005 Apache Design Systems 
# ALL RIGHTS RESERVED
# 
# This entire notice must be reproduced in all copies.
#
#  $RCSfile: decap2eco.pl,v $
#   $Author: Ben Hsu
#     $Date: 00/00/2005
# $Revision: 1.0: Initial version
#
#  Abstract: convert Redhawk decap file to Apollo/Astro eco and scheme
#
# Usage:
#  decap2eco.pl
# 
# Features:
#
#   $Log: decap2eco.pl,v $
#   Revision 1.1  2006/01/25 00:35:40  ben
#   initial check-in
#
#
###############################################################

# use strict ;

###############################################################################
# include my handy-dandy subroutines
#unshift(@INC,"/home/ben/scripts");   # do not use search path
#require "/home/ben/scripts/mysubs.pl"; # include with full path
# Available subroutines: myhex, mymodulo, readLEF, readDEF,
#   startlog, logmsg, endlog, bynum, bynumr, genHeader
# The following section is recommended for using the logging subroutines
my $PROGRAM = "decap2eco.pl" ;
$id =~ /$PROGRAM,v\s+(\S+\s+\S+\s+\S+)/ ;
my $VERSION = $1 ;
$QUIET = 0 ;  # Set to "1" to prevent log messages from going to STDOUT
#$LOGFILE = "decap2eco.log" ;  # if logging is enabled, then output logs to this file

# Examples of using the logging subroutines
#startlog($PROGRAM, $VERSION) ; # initialize logging

#logmsg("run-time message; goes to logfile and STDOUT") ;
#logmsg("cfg","a message that can also be used as a directive in a cfg file; goes to logfile only") ;
#logmsg("info","an informational; goes to logfile only") ;
#logmsg("warning","a warning; goes to logfile and STDOUT") ;
#logmsg("error","an error; goes to logfile and STDOUT") ;
#logmsg("severe","a severe error; goes to logfile and STDOUT") ;
#logmsg("fatal","a fatal error; goes to logfile and STDOUT; closes logfile and ends program") ;

#endlog($PROGRAM, $VERSION) ; # end logging and program
###############################################################################

###############################################################################
# Also include the time expression subroutine
require "ctime.pl";
my $date = ctime(time) ;
chomp $date ;
###############################################################################

###############################################################################
# Global Variables
###############################################################################
# configuration variables

# temporary variables for general use
my $i ;
my $j ;
my $k ;
my $key ;
my $value ;
my $systat ;
my @tmplist ;
my @arglist ;
my %tmphash ;

# variables for command line arguments
my $cfgfile ;

# data storage variables

# flow control variables
my $getline = 0 ;

# generate time stamp string
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdat) = localtime ;
$year -= 100 ;
if ( length $year == 1 ) { $year = "0" . $year ; }
$mon += 1 ;
if ( length $mon == 1 ) { $mon = "0" . $mon ; }
if ( length $mday == 1 ) { $mday = "0" . $mday ; }
if ( length $hour == 1 ) { $hour = "0" . $hour ; }
if ( length $min == 1 ) { $min = "0" . $min ; }
my $tstamp = "$year$mon${mday}_$hour$min" ;

# header for output files
#my $user = $ENV{USER} ;
#my $pwd  = $ENV{PWD} ;
#my $host = $ENV{HOST} ;
#my @fileheader = genHeader("#", $PROGRAM, $VERSION, $user, $pwd, $host) ;

# for debug mode
my $DEBUG = 0 ;


###############################################################################
# Usage Message
###############################################################################
my @USAGE = ( "USAGE: $PROGRAM [ -h ] <decap_file> <cellsize_file>\n",
              "       -h     - show this help message and exit\n",
              #"       -q     - quiet; little or no output to STDOUT\n",
              #"       -d     - debug mode\n",
              #"       -log   - send log messages to this file\n",
# Add additional options here
              "\n**** IMPORTANT NOTES ****\n",
              "1.   The cellsize file is needed so that the correct placement command\n",
              "     in scheme can be created.  The cell size file should have this format:\n\n",
              "     <cellname> <xsize_in_um> <ysize_in_um>\n\n",
              "     For example:\n\n",
              "     decap1 8.8 4.6\n\n",
              "2.   The default output files will be decap.eco and decap.scm.\n"
            ) ;


###############################################################################
# Give Help If Needed
###############################################################################
# make sure there are arguments
if ( !@ARGV ) {
  print @USAGE ;
  exit 0 ;
}
for ( $i=0 ; $i<=$#ARGV ; $i++ ) {
  if ( $ARGV[$i] eq "-h" or  $ARGV[$i] eq "-help" ) {
    print @USAGE ;
    exit ;
#  } elsif ( $ARGV[$i] eq "-q" ) {
#    $QUIET = 1 ;
#  } elsif ( $ARGV[$i] eq "-d" ) {
#    $DEBUG = 1 ;
#  } elsif ( $ARGV[$i] eq "-log" ) {
#    $LOGFILE = $ARGV[++$i] ;
  } else { push @tmplist, $ARGV[$i] }
}
@arglist = @tmplist ;


###############################################################################
# Start Log File
###############################################################################
#startlog($PROGRAM, $VERSION) ; # initialize logging
#startlog($PROGRAM, $VERSION, $tstamp) ; # initialize logging with time stamped log file


###############################################################################
# Get Configuration File From Command Line
###############################################################################
#@tmplist = () ;
#for ( $i=0 ; $i<=$#arglist ; $i++ ) {
#  if ( $arglist[$i] eq "-cfg" ) {
#    $cfgfile = $arglist[++$i] ;
#  } else { push @tmplist, $arglist[$i] }
#}
#@arglist = @tmplist ;


############################################################################### 
# Get Info From Config File
###############################################################################
#if ( -e $cfgfile ) { require $cfgfile ; }
#else { logmsg("w","Could not find the config file '$cfgfile', or no config file given") ;
#open(CFG, $cfgfile) || logmsg("w","Could not open the config file '$cfgfile', or no config file given") ;
#while( <CFG> ) {
#  chomp ;
#  if ( /^\s*MGC_HOME\s+(\S+)/ ) {
#    $MGC_HOME = $1 ;
#  } elsif ( /^\s*$/ or /^\s*#/ ) {
#    # ignore comment or blank line
#  } else {
#    logmsg("warning","(CFG) line '$_' was ignored") ;
#  }
#}
#close(CFG) ;


###############################################################################
# Get Remaining Command Line Arguments 
###############################################################################
#@tmplist = () ;
#for ( $i=0 ; $i<=$#arglist ; $i++ ) {
#  if ( $arglist[$i] eq "-foo" ) {
#  } else { push @tmplist, $arglist[$i] }
#}
#@arglist = @tmplist ;


###############################################################################
# Tool Set-up
###############################################################################
# Apache set-up
#my $APACHEROOT = "/tools/apache" ;
#$ENV{APACHEROOT} = $APACHEROOT ;


###############################################################################
# Start Main
###############################################################################

$decapfile = shift @arglist ;
$cellsizefile = shift @arglist ;

open(CS, $cellsizefile) ;
while ( <CS> ) {
  if ( /^\s*(\S+)\s+([\d\.]+)\s+([\d\.]+)/ ) {
    $cellinfo{$1}{width} = $2 ;
    $cellinfo{$1}{height} = $3 ;
  }
}
close(CS) ;

open(ECO, ">decap.eco") ;
open(SCM, ">decap.scm") ;

print SCM "define _cell (geGetEditCell)\n" ;
$celljstfy = "origin" ;

# Here is the expected format of the decap file:
# NOTE: the coordinates are in DEF units
#DESIGN NB_TOP
#UNIT 2000
#ADD    decap   spwrcap32_SH0  spwrcap32  N  1735900 6442850 
#ADD    decap   spwrcap16_SH1  spwrcap16  N  1771100 6442850 
#ADD    decap   spwrcap7_SH2  spwrcap7  N  1788700 6442850 

open(DC, $decapfile) ;
while ( <DC> ) {
  if ( /UNIT\s+(\d+)/ ) {
    $uu = $1 ;
    #print "$uu\n" ;
  } elsif ( /^ADD/ ) {
    ($action, $cat, $instname, $type, $defori, $defx, $defy) = split() ;
    print ECO "+I $instname $type\n" ;

    $cellheight = $cellinfo{$type}{height} ;
    $cellwidth = $cellinfo{$type}{width} ;

    if ( $defori eq "N" ) {
      $ori = "\"0\" \"no\"" ; 
      $xcoord =  ($defx/$uu) ;
      $ycoord =  ($defy/$uu) ;
    } elsif ( $defori eq "W" ) { 
      $ori = "\"90\" \"no\"" ; 
      $xcoord =  ($defx/$uu) + $cellheight ;
      $ycoord =  ($defy/$uu) ;
    } elsif ( $defori eq "S" ) { 
      $ori = "\"180\" \"no\"" ;
      $xcoord =  ($defx/$uu) + $cellwidth ;
      $ycoord =  ($defy/$uu) + $cellheight ;
    } elsif ( $defori eq "E" ) {
      $ori = "\"270\" \"no\"" ;
      $xcoord =  ($defx/$uu) ;
      $ycoord =  ($defy/$uu) + $cellwidth ;
    } elsif ( $defori eq "FN" ) {
      $ori = "\"0\" \"X\"" ;
      $xcoord =  ($defx/$uu) + $cellwidth ;
      $ycoord =  ($defy/$uu) ;
    } elsif ( $defori eq "FE" ) {
      $ori = "\"270\" \"X\"" ;
      $xcoord =  ($defx/$uu) + $cellheight ;
      $ycoord =  ($defy/$uu) + $cellwidth ;
    } elsif ( $defori eq "FS" ) {
      $ori = "\"180\" \"X\"" ;
      $xcoord =  ($defx/$uu) ;
      $ycoord =  ($defy/$uu) + $cellheight ;
    } elsif ( $defori eq "FW" ) {
      $ori = "\"90\" \"X\"" ;
      $xcoord =  ($defx/$uu) ;
      $ycoord =  ($defy/$uu) ;
    }

    # dbSetCellInstPlacement cellId cellInstName rotationStr mirrorStr justStr Point
    print SCM "dbSetCellInstPlacement _cell \"$instname\" $ori \"$celljstfy\" '($xcoord $ycoord)\n" ;

  }
}
close(DC) ;
close(ECO) ;
close(SCM) ;


###############################################################################
# End Log File
###############################################################################
#endlog($PROGRAM, $VERSION) ; # end logging and program


###############################################################################
# End Main
###############################################################################
# Subroutines
###############################################################################

