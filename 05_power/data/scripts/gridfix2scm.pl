eval '(exit $?0)' && eval 'exec perl -S $0 ${1+"$@"}'
    && eval 'exec perl -S $0 $argv:q' if 0;

$Id = "Version Info" ;
$End = " " ;
$id = "$Id: gridfix2scm.pl,v 1.1 2006/01/25 00:35:40 ben Exp $End" ;

################################################################
# This software is confidential and proprietary information which may only be
# used with an authorized licensing agreement from Apache Design Systems
# In the event of publication, the follow notice is applicable:
# (C) COPYRIGHT 2005 Apache Design Systems 
# ALL RIGHTS RESERVED
# 
# This entire notice must be reproduced in all copies.
#
#  $RCSfile: gridfix2scm.pl,v $
#   $Author: Ben Hsu
#     $Date: 00/00/2005
# $Revision: 1.0: Initial version
#
#  Abstract: convert Apache cell grid fix file to scheme
#
#  Features:
#
#  $Log: gridfix2scm.pl,v $
#  Revision 1.1  2006/01/25 00:35:40  ben
#  initial check-in
#
#
###############################################################

# use strict ;

###############################################################################
# The following section is recommended for using the logging subroutines
my $PROGRAM = "gridfix2scm.pl" ;
$id =~ /$PROGRAM,v\s+(\S+\s+\S+\s+\S+)/ ;
my $VERSION = $1 ;
$QUIET = 0 ;                    # Set to "1" to prevent log messages from going to STDOUT
#$LOGFILE = "gridfix2scm.log" ;  # if logging is enabled, then output logs to this file
my %LOGSTAT = () ;              # store the log statistics here for a summary and end of log file

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
# built in default layermap
my %layernum = ( "metal1" => 31,
                 "metal2" => 32,
                 "metal3" => 33,
                 "metal4" => 34 
               ) ;

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
my @USAGE = ( "USAGE: $PROGRAM [ -h ] [ -m <layermap_file> ] <gridfix_file>\n",
              "       -h     - show this help message and exit\n",
              "       -m     - use this layer map file\n",
              #"       -q     - quiet; little or no output to STDOUT\n",
              #"       -d     - debug mode\n",
              #"       -log   - send log messages to this file\n",
# Add additional options here
              "\n**** IMPORTANT NOTES ****\n",
              "1.   The default output file will be gridfix.scm\n",
              "2.   This program will ignore the \"ADD via\" commands in the gridfix file.\n",
              "     It will assume that Apollo/Astro will automatically drop vias\n",
              "     where possible.\n",
              "3.   The layer map file is optional but highly recommended.\n",
              "     The format of the layer map file are just layer and number pairs:\n\n",
              "     metal1 31\n",
              "     metal2 32\n",
              "     metal3 33\n",
              "     metal4 34\n\n",
              "     These layer names and numbers must correspond to the input files and\n",
              "     Apollo/Astro technology files\n",
              "4.   This script will issue one \"axgCreateStraps\" command for each\n",
              "     \"ADD wire\" command in the gridfix file.  This may be inefficient in terms\n",
              "     of scheme code but it is a more reliable way of translating the added wires\n",
              "5.   The \"DELETE wire\" and \"DELETE via\" commands translate into select and delete\n",
              "     commands in scheme.   Although the deletion process is done as selectively as\n",
              "     Apollo/Astro will allow, it is still a good idea to double check\n",
              "     what has been deleted b/c of the nature of the selection command, some unintentional\n",
              "     things may be selected and deleted\n"
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
  } elsif ( $ARGV[$i] eq "-m" ) {
    $layermapfile = $ARGV[++$i] ;
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
#  if ( /^\s*APACHEROOT\s+(\S+)/ ) {
#    $APACHEROOT = $1 ;
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
#my $APACHEROOT = "/nfs/apache/Releases" ;
#$ENV{APACHEROOT} = $APACHEROOT ;


###############################################################################
# Start Main
###############################################################################

if ( -e $layermapfile ) {
  %layernum = () ;  # get rid of default layer map
  open(M, $layermapfile) ;
  while ( <M> ) {
    s/^\s+// ;  # whack any leading spaces
    ($name, $num) = split ;
    $layernum{$name} = $num ;
  }
  close(M) ;
}

open(SCM, ">gridfix.scm") ;

open(CS, $arglist[0]) ;
while ( <CS> ) {
  if ( /UNIT\s+(\d+)/ ) {
    $uu = $1 ;
    #print "$uu\n" ;
  } elsif ( /^ADD\s+wire/ ) {
    ($action, $type, $wirename, $net, $layer, $def1x, $def1y, $def2x, $def2y) = split ;

    if ( ! defined $layernum{$layer} ) {
      logmsg("w", "The layer \"$layer\" has no mapping to a layer number") ;
    }

    if ( abs($def2x - $def1x) > abs($def2y - $def1y) ) { # horizontal strap
      $width = abs($def2y - $def1y)/$uu ;
      if ( $def2y > $def1y ) { 
        $start = $def1y/$uu ;           # strap given by lower left
        #$start = $width + $def1y/$uu ; # strap given by centerline
        $stop = $width + $def2y/$uu ;   # add a width as buffer for stop point
      } else {
        $start = $def2y/$uu ;           # strap given by lower left
        #$start = $width + $def2y/$uu ; # strap given by centerline
        $stop = $width + $def1y/$uu ;   # add a width as buffer for stop point
      }
      if ( $def2x > $def1x ) { $hi = $def2x/$uu ; $lo = $def1x/$uu ; }
      else { $hi = $def1x/$uu ; $lo = $def2x/$uu ; }
      
      print SCM "; gridfix line: $_" ;
      print SCM "axgCreateStraps\n" ;
      print SCM "setFormField \"Create Straps\" \"Layer\" \"$layernum{$layer}\"\n" ;
      print SCM "setFormField \"Create Straps\" \"Direction\" \"Horizontal\"\n" ;
      print SCM "setFormField \"Create Straps\" \"Width\" \"$width\"\n" ;
      print SCM "setFormField \"Create Straps\" \"Configure by\" \"Step & Stop\"\n" ;
      print SCM "setFormField \"Create Straps\" \"Pitch within Group\" \"500\"\n" ;
      print SCM "setFormField \"Create Straps\" \"Step\" \"1000\"\n" ;
      print SCM "setFormField \"Create Straps\" \"Low Ends\" \"At\"\n" ;
      print SCM "setFormField \"Create Straps\" \"Low at\" \"$lo\"\n" ;
      print SCM "setFormField \"Create Straps\" \"High Ends\" \"At\"\n" ;
      print SCM "setFormField \"Create Straps\" \"High at\" \"$hi\"\n" ;
      print SCM "setFormField \"Create Straps\" \"Start Y\" \"$start\"\n" ;
      print SCM "setFormField \"Create Straps\" \"Stop\" \"$stop\"\n" ;
      print SCM "setFormField \"Create Straps\" \"Net Name(s)\" \"$net\"\n" ;
      print SCM "setFormField \"Create Straps\" \"Keep Floating Pieces\" \"1\"\n" ;
      print SCM "formOK \"Create Straps\"\n\n" ;

    } else { # vertical strap
      $width = abs($def2x - $def1x)/$uu ;
      if ( $def2x > $def1x ) { 
        $start = $def1x/$uu ;           # strap given by lower left
        #$start = $width + $def1x/$uu ; # strap given by centerline
        $stop = $width + $def2x/$uu ;   # add a width as buffer for stop point
      } else {
        $start = $def2x/$uu ;           # strap given by lower left
        #$start = $width + $def2x/$uu ; # strap given by centerline
        $stop = $width + $def1x/$uu ;   # add a width as buffer for stop point
      }
      if ( $def2y > $def1y ) { $hi = $def2y/$uu ; $lo = $def1y/$uu ; }
      else { $hi = $def1y/$uu ; $lo = $def2y/$uu ; }
      
      print SCM "; gridfix line: $_" ;
      print SCM "axgCreateStraps\n" ;
      print SCM "setFormField \"Create Straps\" \"Layer\" \"$layernum{$layer}\"\n" ;
      print SCM "setFormField \"Create Straps\" \"Direction\" \"Vertical\"\n" ;
      print SCM "setFormField \"Create Straps\" \"Width\" \"$width\"\n" ;
      print SCM "setFormField \"Create Straps\" \"Configure by\" \"Step & Stop\"\n" ;
      print SCM "setFormField \"Create Straps\" \"Pitch within Group\" \"500\"\n" ;
      print SCM "setFormField \"Create Straps\" \"Step\" \"1000\"\n" ;
      print SCM "setFormField \"Create Straps\" \"Low Ends\" \"At\"\n" ;
      print SCM "setFormField \"Create Straps\" \"Low at\" \"$lo\"\n" ;
      print SCM "setFormField \"Create Straps\" \"High Ends\" \"At\"\n" ;
      print SCM "setFormField \"Create Straps\" \"High at\" \"$hi\"\n" ;
      print SCM "setFormField \"Create Straps\" \"Start X\" \"$start\"\n" ;
      print SCM "setFormField \"Create Straps\" \"Stop\" \"$stop\"\n" ;
      print SCM "setFormField \"Create Straps\" \"Net Name(s)\" \"$net\"\n" ;
      print SCM "setFormField \"Create Straps\" \"Keep Floating Pieces\" \"1\"\n" ;
      print SCM "formOK \"Create Straps\"\n\n" ;

    }

  } elsif ( /^DELETE\s+wire/ ) {
    ($action, $type, $wirename, $net, $layer, $def1x, $def1y, $def2x, $def2y) = split ;

    if ( ! defined $layernum{$layer} ) {
      logmsg("w", "The layer \"$layer\" has no mapping to a layer number") ;
    }

    print SCM "; gridfix line: $_" ;

    # set the select point
    $selptx1 = $def1x/$uu ;
    $selpty1 = $def1y/$uu ;

    # make only the target layer selectable
    print SCM "geLayerPanel\n" ;
    print SCM "lpnButton \"panel0\"\n" ;
    print SCM "lpnButton \"allSelOff\"\n" ;
    print SCM "lpnSetSelectable $layernum{$layer} 1\n" ;
    print SCM "lpnButton \"panel1\"\n" ;
    print SCM "lpnButton \"allSelOff\"\n" ;
    print SCM "lpnButton \"panel2\"\n" ;
    print SCM "lpnButton \"allSelOff\"\n" ;
    print SCM "lpnButton \"panel3\"\n" ;
    print SCM "lpnButton \"allSelOff\"\n" ;
    print SCM "lpnButton \"apply\"\n\n" ;

    # select the item
    print SCM "gePointSelect\n" ;
    print SCM "addPoint 1 '($selptx1 $selpty1)\n" ;
    print SCM "geDelete\n" ;
    print SCM "abortCommand\n\n" ;

    # make everything selectable again
    print SCM "lpnButton \"allSelOn\"\n" ;
    print SCM "lpnButton \"panel2\"\n" ;
    print SCM "lpnButton \"allSelOn\"\n" ;
    print SCM "lpnButton \"panel1\"\n" ;
    print SCM "lpnButton \"allSelOn\"\n" ;
    print SCM "lpnButton \"panel0\"\n" ;
    print SCM "lpnButton \"allSelOn\"\n" ;
    print SCM "lpnButton \"apply\"\n" ;
    print SCM "lpnButton \"hide\"\n\n" ;

  } elsif ( /^DELETE\s+via/ ) {
    ($action, $type, $cmdname, $net, $vianame, $num1, $def1x, $def1y) = split ;
    ($layer) = split(/_/, $vianame) ;

    if ( ! defined $layernum{$layer} ) {
      logmsg("w", "The layer \"$layer\" has no mapping to a layer number") ;
    }

    print SCM "; gridfix line: $_" ;

    # set the select point
    $selptx1 = $def1x/$uu ;
    $selpty1 = $def1y/$uu ;

    # make only the target layer selectable
    print SCM "geLayerPanel\n" ;
    print SCM "lpnButton \"panel0\"\n" ;
    print SCM "lpnButton \"allSelOff\"\n" ;
    print SCM "lpnSetSelectable $layernum{$layer} 1\n" ;
    print SCM "lpnButton \"panel1\"\n" ;
    print SCM "lpnButton \"allSelOff\"\n" ;
    print SCM "lpnButton \"panel2\"\n" ;
    print SCM "lpnButton \"allSelOff\"\n" ;
    print SCM "lpnButton \"panel3\"\n" ;
    print SCM "lpnButton \"allSelOff\"\n" ;
    print SCM "lpnButton \"apply\"\n\n" ;

    # select the item
    print SCM "gePointSelect\n" ;
    print SCM "addPoint 1 '($selptx1 $selpty1)\n" ;
    print SCM "geDelete\n" ;
    print SCM "abortCommand\n\n" ;

    # make everything selectable again
    print SCM "lpnButton \"allSelOn\"\n" ;
    print SCM "lpnButton \"panel2\"\n" ;
    print SCM "lpnButton \"allSelOn\"\n" ;
    print SCM "lpnButton \"panel1\"\n" ;
    print SCM "lpnButton \"allSelOn\"\n" ;
    print SCM "lpnButton \"panel0\"\n" ;
    print SCM "lpnButton \"allSelOn\"\n" ;
    print SCM "lpnButton \"apply\"\n" ;
    print SCM "lpnButton \"hide\"\n\n" ;

  }
}
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


###############################################################################
# Subroutine Name: startlog
# Description: 
# Arguments: program name, version, quiet(optional), time(optional)
# Modifies:
# Returns: 1 for success, 0 for failure
###############################################################################
sub startlog {
  my $pn = shift ;
  my $v = shift ;
  my $q = shift ;
  my $t = shift ;

  # determine if the quiet option is an argument
  if ( $q != 1 and $q != 0 ) { 
    $t = $q ; 
    if ( $QUIET == 1 or $QUIET == 0 ) { $q = $QUIET ; }
    else { $q = 0 ; }
  } elsif ( defined $QUIET ) { $q = $QUIET ; 
  } else { $q = 0 ; }

  my $logfile = $pn ;
  my $host = $ENV{HOST} ;

  my $date = ctime(time) ;
  chomp $date ;

  if ( $LOGFILE and $t ) { 
    if ( $LOGFILE =~ /\.log$/ ) {
      @tmplist = split(/\./, $LOGFILE) ;
      pop @tmplist ;
      $logfile = join(".", @tmplist, $t, "log") ;
    } else { $logfile = "$LOGFILE.$t" ; }

  } elsif ( $LOGFILE ) { $logfile = $LOGFILE ; 
  } elsif ( $pn =~ /(\S+)\.\w+$/ and $t ) { $logfile = "$1.$t.log" ; 
  } elsif ( $pn =~ /(\S+)\.\w+$/ ) { $logfile = $1 . ".log" ; }

  my @message = ( "Start $pn version $v at $date, on host $host\n",
                  "  commandline: $0 " . join(" ", @ARGV) . "\n\n" ) ;

  $LOGSTAT{w} = 0 ;
  $LOGSTAT{e} = 0 ;
  $LOGSTAT{s} = 0 ;

  if ( open(LOGFILE, ">$logfile") ) {
    print LOGFILE @message ;
  } else {
    print STDERR "ERROR - $pn: Could not open log file '$logfile'; no log file will be output\n" ;
    return 0 ;
  }

  if ( ! defined $q or $q == 0 ) {
    print STDOUT @message ;
  }

  return 1 ;
} # startlog


###############################################################################
# Subroutine Name: logmsg
# Description: 
# Arguments: quiet(optional), type(optional), list of message strings 
# Modifies: %LOGSTAT
# Returns: 
###############################################################################
sub logmsg {
  my @msg = @_ ;

  my @message = () ;
  my $q = 0 ;
  my $type = "MSG: " ;
  my $line ;

  if ( ! defined $msg[0] and ! defined $QUIET ) {
    $q = 1 ;
    shift @msg ;
  } elsif ( $msg[0] =~ /^(0|1)$/ ) {
    $q = shift @msg ;
  } elsif ( $QUIET =~ /^(0|1)$/ ) {
    $q = $QUIET ;
  }

  # default type is message
  # possible types are:
  # message - a run-time message
  # cfg - directive for a configuration file; not sent to STDOUT
  # info - an informational; not sent to STDOUT
  # warning - warning
  # error - error
  # severe - severe error
  # fatal - fatal error; ends the script
  if ( $msg[0] =~ /^(m|message)$/i ) {
    shift @msg ;
  } elsif ( $msg[0] =~ /^(c|cfg)$/i ) {
    $type = "" ;
    shift @msg ;
  } elsif ( $msg[0] =~ /^(i|info)$/i ) {
    $type = "INFO: " ;
    shift @msg ;
  } elsif ( $msg[0] =~ /^(w|warning)$/i ) {
    $type = "WARNING: " ;
    $LOGSTAT{w}++ ;
    shift @msg ;
  } elsif ( $msg[0] =~ /^(e|error)$/i ) {
    $type = "ERROR: " ;
    $LOGSTAT{e}++ ;
    shift @msg ;
  } elsif ( $msg[0] =~ /^(s|severe)$/i ) {
    $type = "SEVERE: " ;
    $LOGSTAT{s}++ ;
    shift @msg ;
  } elsif ( $msg[0] =~ /^(f|fatal)$/i ) {
    $type = "FATAL: " ;
    shift @msg ;
  }

  while ( @msg ) {
    $line = shift @msg ;
    push @message, "$type$line\n" ;
  }

  if ( @message ) {
    if ( stat LOGFILE ) { 
      print LOGFILE @message ;
    }
    if ( $type and $type ne "INFO: " and $q == 0 ) {
      print STDOUT @message ;
    }
  }

  if ( $type eq "FATAL: " ) {
    @message = ( "\nSUMMARY - warnings:        $LOGSTAT{w}\n",
                  "SUMMARY - errors:          $LOGSTAT{e}\n",
                  "SUMMARY - severe errors:   $LOGSTAT{s}\n",
                  "\nEnding $0 because of a FATAL error; terminated on " . ctime(time) ) ;

    if ( stat LOGFILE ) { 
      print LOGFILE @message ;
      close(LOGFILE) ;
    }
    if ( $q == 0 ) {
      print STDERR @message ;
    }

    exit 1 ;
  }
} # logmsg


###############################################################################
# Subroutine Name: endlog
# Description: 
# Arguments: program name, version, quiet(optional)
# Modifies:
# Returns: 
###############################################################################
sub endlog {
  my $pn = shift ;
  my $v = shift ;
  my $q = shift ;

  my @message = ( "\nSUMMARY - warnings:        $LOGSTAT{w}\n",
                  "SUMMARY - errors:          $LOGSTAT{e}\n",
                  "SUMMARY - severe errors:   $LOGSTAT{s}\n",
                  "\nEnd $pn version $v on " . ctime(time) ) ;

  if ( ! defined $q and defined $QUIET ) { $q = $QUIET ; }

  if ( stat LOGFILE ) { 
    print LOGFILE @message ;
    close(LOGFILE) ;
  }
  if ( -e $LOGFILE ) { system("chmod 660 $LOGFILE") ; }

  if ( ! defined $q or $q == 0 ) {
    print STDOUT @message ;
  }

  exit 0 ;
} # endlog

