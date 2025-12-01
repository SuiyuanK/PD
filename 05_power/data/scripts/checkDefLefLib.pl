eval '(exit $?0)' && eval 'exec perl -w -S $0 ${1+"$@"}'
    && eval 'exec perl -w -S $0 $argv:q' if 0;

$Id = "Version Info" ;
$End = " " ;
$id = "$Id: checkDefLefLib.pl,v 1.1 2006/02/17 08:28:21 ericku Exp $End" ;
################################################################
# This software is confidential and proprietary information which may only be
# used with an authorized licensing agreement from Apache Design Systems
# In the event of publication, the follow notice is applicable:
# (C) COPYRIGHT 2002-2005 Apache Design Systems
# ALL RIGHTS RESERVED
#
# This entire notice must be reproduced in all copies.
#
#  Abstract: Data integrity checking between DEF/LEF/LIB
#
#  Features: Only checking cell name
#
#  $Log: checkDefLefLib.pl,v $
#  Revision 1.1  2006/02/17 08:28:21  ericku
#  new check-in
#
#
#
#  $RCSfile: checkDefLefLib.pl,v $
#   $Author: Eric Ku
#     $Date: 2006/02/14
# $Revision: 1.0: Initial version
#
###############################################################

use Getopt::Long;
use Pod::Usage;

GetOptions("h", "c=s", "g=s", "d") or pod2usage(-exitval => 1, -verbose => 0);

system("clear");
print $id,"\n";

#--- help
if (defined $opt_h ) {
        # Exit with exit status 0, verbose level 2 (full man page)
        pod2usage(-exitval => 0, -verbose => 2);
        $opt_h = ""; # Dummy line, gets rid of perl "used only once" warning
};

#=======
#--- check -c && -g
if ( !defined $opt_c && !defined $opt_g ){
    print "\n\n\"checkDefLefLib.pl -h\" for more detail usage.\n\n";
    exit;
};
if ( defined $opt_c && defined $opt_g ){
    print "\n\n\"checkDefLefLib.pl -h\" for more detail usage.\n\n";
    exit;
};


#=====================================================================================
#--- global variable
#--- tcl cmd as input
if( defined $opt_c ){
	print "parsing TCL: ",$opt_c,"\n";
	open ( TCL,"$opt_c" ) or die "File $opt_c does not exist!!";
	$cmdDefFlag=0;
	while ( <TCL> ){
		if( $_ =~ /^\s*import\s+gsr\s+(\S+)/i ){
			$cmdGsr=$1;
		};
		if( $_ =~ /^\s*import\s+def\s+(\S+)/i ){
			$cmdDefFlag=1;
			next;
		};
	};
	close TCL;
	#--- readGSR --> tmp.defs/tmp.lefs/tmp.libs
	if( $cmdDefFlag == 0 && defined $cmdGsr ){
		readGSR( $cmdGsr );	
	};
}elsif( defined $opt_g ){
	#--- gsr as input, DEF/LEF/LIB in gsr
	readGSR( $opt_g );
};

#--- tmp.defs
open ( DEFS, "tmp.defs" ) or die "$!";
system("rm -rf tmp.allDEF ") if ( -e "tmp.allDEF" );
while ( <DEFS> ){
	chomp;
	@defLine=split(' ',$_);
	$local_def=$defLine[0];
	DefCell( $defLine[0] );
	open ( allDEF, "tmp.allDEF" ) or die "$!";
	while ( <allDEF> ){
		chomp;
		if( !defined $topDefH{$_} ){
			$topDefH{$_}=$local_def;
		};
	};
	close allDEF;
};	
close DEFS;

#--- tmp.lefs
open ( LEFS, "tmp.lefs" ) or die "$!";
system("rm -rf tmp.allLEF ") if ( -e "tmp.allLEF" );
while ( <LEFS> ){
	chomp;
	@lefLine=split(' ',$_);
	$local_lef=$lefLine[0];
	LefCell( $lefLine[0] );

	open ( allLEF, "tmp.allLEF" ) or die "$!";
	while ( <allLEF> ){
        chomp;
        if( !defined $topLefH{$_} ){
            $topLefH{$_}=$local_lef;
        };
    };
    close allLEF;
};	
close LEFS;


#--- tmp.libs
open ( LIBS, "tmp.libs" ) or die "$!";
system("rm -rf tmp.allLIB ") if ( -e "tmp.allLIB" );
while ( <LIBS> ){
	chomp;
	if( -d $_ ){
		foreach $libFile ( `ls $_/*.lib` ){
			LibCell( $libFile );
			open ( allLIB, "tmp.allLIB" ) or die "$!";
			while ( <allLIB> ) {
				chomp;
				if( !defined $topLibH{$_} ){
					$topLibH{$_}=$libFile;
				};
			};
			close allLIB;
		};
	}elsif( -f $_ ){
		LibCell( $_ );
		open ( allLIB, "tmp.allLIB" ) or die "$!";
		while ( <allLIB> ) {
			chomp;
			if( !defined $topLibH{$_} ){
				$topLibH{$_}=$_;
			};
		};
		close allLIB;

	};
	open ( allLIB, "tmp.allLIB" ) or die "$!";
	while ( <allLIB> ) {
		chomp;
		if( !defined $topLibH{$_} ){
			$topLibH{$_}=$_;
		};
	};
	close allLIB;
};	
close LIBS;

#--- checking LEF <-> DEF
open( noLEF,">cell.noLEF.rpt" );
foreach $cellInDef ( keys(%topDefH) ){
	if( !defined $topLefH{$cellInDef} ){
		print noLEF $cellInDef,"\n";
	};
};
close noLEF;

#--- checking LIB <-> DEF
open ( noLIB,">cell.noLIB.rpt" );
foreach $cellInDef ( keys(%topDefH) ){
	if( !defined $topLibH{$cellInDef} ){
		print noLIB $cellInDef,"\n";
	};
};
close noLIB;

#=====================================================================================
#--- re-print command
print "\n %",$0," ";
print "-c ",$opt_c," " if defined $opt_c;
print "-g ",$opt_g," " if defined $opt_g;
print "-d " if defined $opt_d;
print "\n\n";
print "*** Please review the following files ***\n";
system("ls -l cell.noLEF.rpt cell.noLIB.rpt\n\n");
system("rm -rf tmp.allDEF  tmp.allLEF  tmp.allLIB  tmp.defs  tmp.lefs  tmp.libs") if !defined $opt_d;
#=====================================================================================
#======= parsing GSR
sub readGSR {
	my( $gsrFile )=@_;
	print "parsing ",$gsrFile,"\n";
	open ( GSR, $gsrFile ) or die "File $gsrFile does not exist!!";
	open ( DEFS,">tmp.defs" );
	open ( LEFS,">tmp.lefs" );
	open ( LIBS,">tmp.libs" );
######
	$defFlag=0;
	$lefFlag=0;
	$libFlag=0;

	while ( <GSR> ){
		#-- DEFS
		if($_ =~ /^\s*DEF_FILES/i){
			$defFlag=1;
			next;	
		};
		if( $defFlag == 1 && $_ =~ /^\s*}/ ){
			$defFlag=0;
		};
		if( $defFlag == 1 ){
			chomp;
			$_ =~ s/{//g;
			next if $_ =~ /^\s*$/;
			next if $_ =~ /^\s*#/;
			print DEFS $_,"\n";
		};
	
		#-- LEFS
		if($_ =~ /^\s*LEF_FILES/i){
			$lefFlag=1;
			next;	
		};
		if( $lefFlag == 1 && $_ =~ /^\s*}/ ){
			$lefFlag=0;
		};
		if( $lefFlag == 1 ){
			chomp;
			$_ =~ s/{//g;
			next if $_ =~ /^\s*$/;
			next if $_ =~ /^\s*#/;
			print LEFS $_,"\n";
		};
	
		#-- LIBS
		if($_ =~ /^\s*LIB_FILES/i){
			$libFlag=1;
			next;	
		};
		if( $libFlag == 1 && $_ =~ /^\s*}/ ){
			$libFlag=0;
		};
		if( $libFlag == 1 ){
			chomp;
			$_ =~ s/{//g;
			next if $_ =~ /^\s*$/;
			next if $_ =~ /^\s*#/;
			print LIBS $_,"\n";
		};
	
	};
	close GSR;
	close DEFS;
	close LEFS;
	close LIBS;
};
#======= collect cells in DEF
sub DefCell {
    my( $defFile )=@_;
	print "parsing DEF: ",$defFile,"\n";
    open ( DEF ,$defFile ) or die "File $defFile does not exist!!";
	open ( allDEF,">>tmp.allDEF" ) or die "$!";
######
	$comFlag=0;
	while ( <DEF> ){
		if( $_ =~ /^\s*COMPONENTS/i ){
			$comFlag=1;
			next;
		};
		if( $comFlag == 1 && $_ =~ /^\s*END\s*COMPONENTS/i ){
			$comFlag=0;
			next;
		};
		if( $comFlag == 1 ){
$/=";";
			if( $_ =~ /^\s*-\s+\S+\s+(\S+)/ ){
				if( !defined $defH{$1} ){
					$defH{$1}=$defFile;
					print allDEF $1,"\n";
					next;
				};
			};
		};
		

	};
	close DEF;
	close allDEF;
};
#======= collect cells in LEF
sub LefCell {
    my( $lefFile )=@_;
	print "parsing LEF: ",$lefFile,"\n";
    open ( LEF ,$lefFile ) or die "File $lefFile does not exist!!";
	open ( allLEF,">>tmp.allLEF" ) or die "$!";
######
	while ( <LEF> ){
		if($_ =~ /^\s*MACRO\s+(\S+)/i){
			if( !defined $lefH{$1} ){
				$lefH{$1}=$lefFile;
				print allLEF $1,"\n";
			};
		};
	};
    close LEF;
	close allLEF;
};
#======= collect cells in LIB
sub LibCell {
    my( $libFile )=@_;
	open ( LIB, "$libFile" ) or die "File $libFile does not exist!!";
	open ( allLIB,">>tmp.allLIB" ) or die "$!";
######
	while ( <LIB> ){
		if($_ =~ /^\s*cell\s+\((\S+)\)/i){
			if( !defined $libH{$1} ){
				$libH{$1}=$libFile;
				print allLIB $1,"\n";
			};
		};
	};
	close LIB;
	close allLIB;

};
#############################################################################

=head1 SYNOPSIS

  Usage: perl checkDefLefLib.pl [-h] [-c tcl_cmd] [-g gsr_latest_format] 

    -h:  Print this help message.
    -c:  static/dynamic.tcl
    -g:  gsr in 5.x or latest format

  Description: checkDefLefLib.pl will print cells exist in DEF but miss in 
			   LEF or LIB

