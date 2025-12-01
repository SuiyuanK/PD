eval '(exit $?0)' && eval 'exec perl -w -S $0 ${1+"$@"}'
    && eval 'exec perl -w -S $0 $argv:q' if 0;

$Id = "Version Info" ;
$End = " " ;
$id = "$Id: adsTechConverter.pl,v 1.24 2015/01/16 09:33:11 rnr Exp $End" ;
################################################################
# This software is confidential and proprietary information which may only be
# used with an authorized licensing agreement from Apache Design Systems
# In the event of publication, the follow notice is applicable:
# (C) COPYRIGHT 2002-2006 Apache Design Systems
# ALL RIGHTS RESERVED
#
# This entire notice must be reproduced in all copies.
#
#  Abstract: convert itf/nxtgrd/ict tech files to Apache tech file format
#
#  Features: supports width dependent R
#
#  $Log: adsTechConverter.pl,v $
#  Revision 1.24  2015/01/16 09:33:11  rnr
#  include RES and CAP ETCH
#
#  Revision 1.23  2014/05/05 14:18:11  rraman
#  BugID:25272 ;
#  This script was modified for Infinion by Ralf and Eriki. Requested by Mithun to check in CVS area on May 05 2014
#
#  Revision 1.24  2015/01/02 15:51:00  ralf
#  Invert CAPACITIVE/RESISTIVE_ONLY_ETCH value if
#  input tech is an ict file. This is needed to
#  account for the different interpretation of
#  these values between ict and nxgrd.
#
#  Revision 1.23  2014/01/16 16:02:00  ralf
#  changed units within 'header_ict' sub
#  added power unit w
#
#  Revision 1.22  2013/11/20 02:51:14  ralf
#  support temp_tc1,2 in ict
#  support diffusion in ict
#  support rho in ict
#  support wire_thickness_ratio in ict
#  support tnom and tnom_em option for ict convertion
#
#  Revision 1.21  2008/07/21 01:51:26  ericku
#  support area in ict
#
#  Revision 1.20  2008/07/17 02:12:30  ericku
#  Support area_resistance in ict
#
#  Revision 1.19  2006/05/21 14:41:01  ericku
#  revise by pass ETCH_VS_WIDTH_AND_SPACING
#
#  Revision 1.17  2006/03/10 09:02:42  ericku
#  EM+EM_Adjust table natively support
#
#  Revision 1.15  2005/12/07 06:40:42  ericku
#  fix upper/lower order in via section
#
#  Revision 1.14  2005/11/10 15:19:48  ericku
#  natively support EFFECTIVE_RPSQ_TABLE
#
#  Revision 1.13  2005/10/27 09:41:31  ericku
#  support UMC like itf
#
#  Revision 1.12  2005/10/26 06:59:11  ericku
#  ignore thickness=0, take care R of poly/od
#
#  Revision 1.11  2005/10/20 07:19:15  ericku
#  unit correction
#
#  Revision 1.10  2005/08/16 13:50:16  ericku
#  natively support temperature coefficients
#
#  Revision 1.9  2005/08/15 08:07:26  ericku
#  add -i
#
#  Revision 1.7  2005/08/09 10:20:12  ericku
#  bug fix
#
#  Revision 1.6  2005/08/08 09:48:11  ericku
#  minor change in header
#
#  Revision 1.5  2005/08/08 09:40:10  ericku
#  nxtgrd/itf width-depend R natively support
#
#  Revision 1.4  2005/08/08 09:36:58  ericku
#  *** empty log message ***
#
#
#  $RCSfile: adsTechConverter.pl,v $
#   $Author: Eric Ku
#     $Date: 2005/08/05
# $Revision: 1.2: Initial version
#
###############################################################

use Getopt::Long;
use Pod::Usage;

GetOptions("h", "s=s", "c=s", "o=s", "m=s", "i", "t=s", "e=s", "tnom=i", "tnom_em=i" ) or pod2usage(-exitval => 1, -verbose => 0);

system("clear");
print << "VERSION_END"

adsTechConverter.pl (Aug 08 15:07 2005)-- apache.tech generator
Copyright (c) 2002-2005 Apache Design Solutions, Inc. All rights reserved.
VERSION_END
;

#--- help
if (defined $opt_h ) {
        # Exit with exit status 0, verbose level 2 (full man page)
        pod2usage(-exitval => 0, -verbose => 2);
        $opt_h = ""; # Dummy line, gets rid of perl "used only once" warning
        $id = ""; # Dummy line, gets rid of perl "used only once" warning
};

if ( !defined $opt_o && ( !defined $opt_s || !defined $opt_c ) ){
    pod2usage(-exitval => 0, -verbose => 2);
};
#=======
$preCheck_flag=0;
#--- check -o
if ( !defined $opt_o ){
    print "argument -o is a must input\n";
    print "ex: -o apache.tech\n";
    $preCheck_flag=1;
};

#-- check -s or -c
if ( !defined $opt_s && !defined $opt_c ){
    print "argument -s or -c is a must input\n";
    print "ex: -s synps.itf\n";
    print "ex: -s synps.nxtgrd\n";
    print "ex: -c simplex.itf\n";
    $preCheck_flag=2;
};

#-- check -i must go with -m
if ( defined $opt_i && !defined $opt_m ){
    print "argument -i must go with -m\n";
    print "ex: -m layer.map -i\n";
    $preCheck_flag=2.4;
};
if ( defined $opt_s && defined $opt_c ){
    print "only one of \"-s\" or \"-c\" is needed\n";
    $preCheck_flag=2.5;
};
#-- check file exist for -s
if ( defined $opt_s ){
    if( !-e $opt_s ){
        print "\n\nFile: \"$opt_s\" does not exist!!\n\n";
    $preCheck_flag=3;
  };
};

#-- check file exist for -c
if ( defined $opt_c ){
    if( !-e $opt_c ){
        print "\n\nFile: \"$opt_c\" does not exist!!\n\n";
        $preCheck_flag=4;
    };
};

#-- check file exist for -t
if ( defined $opt_t ){
        if( !-e $opt_t ){
                print "\n\nFile: \"$opt_t\" does not exist!!\n\n";
                $preCheck_flag=5;
        };
};

#--
if ( $preCheck_flag != 0 ){
    print "\n\n\"adsTechConverter.pl -h\" for more detail usage.\n\n";
    exit;
};

#=====================================================================================
#--- nxtgrd or itf
if( defined $opt_o && defined $opt_s ){
        $input=$opt_s;
    open ( TECH ,">$opt_o" ) or die "$!";

    print "\n$opt_s ---> $opt_o\n";
    print "\nWARNING: EM should be manually added!\n\n" if !defined $opt_e;

    #=== pre-process
    $itf=0;
    $nxtgrd=0;

    open ( preSNP ,$opt_s ) or die "$!";
    while ( <preSNP> ){
        if ( $_ =~ /\s*technology\s*=\s*(\S+)/i ){
                print $1,"\n";
                $TECHNOLOGY=$1;
                if ( $_ =~ /^\s*\$/ ){
                        $nxtgrd=1;
                        print "... NXTGRD format ...\n";
                        goto NEXT1;
                }else{
                        $itf=1;
                        print "... ITF format ...\n";
                        goto NEXT1;
                };
        };
    };
    NEXT1: close ( preSNP );

    #=== itf
    if ( $itf == 1 ) {

        Print_header( $TECHNOLOGY );

        #--- grep "RPSQ_VS_WIDTH_AND_SPACING" $opt_s
        open ( SNPS , $opt_s ) or die "$!";
        open ( preITF,">itf.tmp" ) or die "$!";
        $width_dependent = 0;
        while ( <SNPS> ){
            if( $_ =~ /^\s*RPSQ_VS_WIDTH_AND_SPACING/ ){
                $width_dependent = 1;
                #last;
            };
            if( $_ =~ /^\s*EFFECTIVE_RPSQ_TABLE/ ){
            	$width_dependent = 2;
            };
            ### Skip dielectric layer if thickness == 0
            ### DIELECTRIC SPACER	 {THICKNESS=0.0 
            if ( $_ =~ /DIELECTRIC/i && $_ =~ /THICKNESS\s*=\s*(\S+)\s*/i ){
            	if ( $1 == 0 ){
			print "\n";
			print "*** Skip\n";
			print $_;
			next;
		};
            };
            print preITF $_;
        };
        close ( SNPS );
        close ( preITF );
        if( $width_dependent == 0 ){
            #SNPS( $opt_s );
            SNPS( "itf.tmp" );
        }elsif( $width_dependent == 1 ){
            #SNPS_WD( $opt_s );
            SNPS_WD( "itf.tmp" );
        }elsif( $width_dependent == 2 ){
        		SNPS_WD_EFF( "itf.tmp" );	
		  };
    };

    #=== NXTGRD
    if ( $nxtgrd == 1 ) {
        open ( NXTGRD ,">nxtgrd.tmp" ) or die "$!";
        open ( preSNP,$opt_s ) or die "$!";
        $nxtFlag=0;
        $width_dependent = 0;
        while ( <preSNP> ){
                #=== remove $$
                $_ =~ s/^\s*\$+//g;

                #--- grep "RPSQ_VS_WIDTH_AND_SPACING" preSNP
                if( $_ =~ /^\s*RPSQ_VS_WIDTH_AND_SPACING/i ){
                            $width_dependent = 1;
                        };
                if( $_ =~ /^\s*EFFECTIVE_RPSQ_TABLE/ ){
            			$width_dependent = 2;
            	 };
                if ( $_ =~ /^\s*technology\s*=\s*(\S+)/i ){
                        $nxtFlag=1;
                        print NXTGRD $_;
                        next;
                };
                if ( $_ =~ /end\s+of\s+itf\s+file/i ){
                        $nxtFlag=0;
                        goto NEXT2;
                };
            	### Skip dielectric layer if thickness == 0
	        ### DIELECTRIC SPACER	 {THICKNESS=0.0 
            	if ( $_ =~ /DIELECTRIC/i && $_ =~ /THICKNESS\s*=\s*(\S+)\s*/i ){
            		if ( $1 == 0 ){
				print "\n";
				print "*** Skip\n";
				print $_;
				next;
			};
            	};
                if ( $nxtFlag == 1 ){
                        print NXTGRD $_;
                };
        };
        NEXT2: close ( NXTGRD );
        close ( preSNP );

        Print_header( $TECHNOLOGY );
        if( $width_dependent == 0 ){
            SNPS( "nxtgrd.tmp" );
        }elsif( $width_dependent == 1 ){
            SNPS_WD( "nxtgrd.tmp" );
        }elsif( $width_dependent == 2 ){
        		SNPS_WD_EFF( "nxtgrd.tmp" );	
		  };;
    };


    close( TECH );
	 system(" rm nxtgrd.tmp " ) if -e "nxtgrd.tmp" ;
	 system(" rm pre_nxtgrd.tmp " ) if -e "pre_nxtgrd.tmp" ;
	 system(" rm itf.tmp " ) if -e "itf.tmp" ;

#-- simplex.ict
}elsif( defined $opt_o && defined $opt_c ){
        $input=$opt_c;
    #open ( TECH ,">$opt_o") or die "$!";

    print "\n$opt_c ---> $opt_o\n";
    print "\nWARNING: EM should be manually added!\n\n";
    CAD( $opt_c );

    #close ( TECH );
    system( "cat tmp.de >> $opt_o" );
    system( " rm tmp.de tmp.ict1 tmp.ict0" );

}else{
        pod2usage(-exitval => 0, -verbose => 2);
    #Print_help();
    exit;
};
#======= post-process: changing naming style from map file
if ( !defined $opt_m ){
    print "\n\n";
    print "*** < using naming rule in $opt_s as golden > \n" if defined $opt_s;
    print "*** < using naming rule in $opt_c as golden > \n" if defined $opt_c;
    print "Be aware of the naming in .tech should be consistent with .lef\n";
    print "***\n";
    print "\n\n";
} elsif ( defined $opt_m && !defined $opt_i ){
    print "\n\n";
    print "*** < renaming > \n";
    print "*** < All layers are kept > \n";
    print "*** < In case only layers in $opt_m is prefered, please use -i  > \n";
    namingCorrelation();
}elsif( defined $opt_m && defined $opt_i ){
    print "\n\n";
    print "*** < renaming > \n";
    print "*** < Only layers in $opt_m will be kept > \n";
    namingCorrelation();
};

#======= post-process: modify R base on TC map file
if( defined $opt_t ){
    print "*** < Modify R base on $opt_t temperature coefficients > \n";
	TC();
};

#======= post-process: modify EM base on EM map file
if( defined $opt_e ){
    print "*** < Modify EM base on $opt_e > \n";
	EM();
};

#======= print command

print "\nadsTechConverter.pl ";
print " -s $opt_s " if defined $opt_s;
print " -c $opt_c " if defined $opt_c;
print " -m $opt_m " if defined $opt_m;
print " -t $opt_t " if defined $opt_t;
print " -o $opt_o " if defined $opt_o;
print " -e $opt_e " if defined $opt_e;
print " -tnom $opt_tnom " if defined $opt_tnom;
print " -tnom_em $opt_tnom_em " if defined $opt_tnom_em;
print " -i " if defined $opt_i;
print "\n";
#=====================================================================================
#======= Synopys itf/nxtgrd Width-independent
sub SNPS {
    my( $itf )=@_;
    open ( ITF ,$itf ) or die "$!";
######
	#pre process: for conductor w/ multi-lines
	open ( preITF,">pre_nxtgrd.tmp" );
	$brace_flag=0;
	$etch_flag=0;

	while ( <ITF> ){
		chomp;
		#--- ETCH_VS_WIDTH_AND_SPACING
		if($_ =~ /^\s*ETCH_VS_WIDTH_AND_SPACING/i){
			$etch_flag=1;
			next;
		};
		if( $etch_flag == 1 && $_ =~ /^\s*DIELECTRIC/i ){
			$etch_flag = 0;
			$brace_flag=0;
			print preITF "}\n";
		};
		if( $etch_flag==1 ){
			next;
		};
		#--- 

		if ( ( $_ =~ /{/ ) && ( $_ !~ /}/) ){
			$brace_flag=1;
			print preITF $_," ";
			next;
		};
		if( $brace_flag == 1 && ( $_ =~ /}/ ) ){
			print preITF $_,"\n";
			$brace_flag=0;
			next;				
		};
		if( $brace_flag == 1 ){
			print preITF $_," ";
			next;
		};
		print preITF $_,"\n";
	};
	close preITF;
	close ITF;
######
	open ( preITF,"pre_nxtgrd.tmp" );
    $flag=0;

	$metal_counter=0;
    foreach ( <preITF> ){
        if( $_ =~ /^\s*$/ ){
                next;
        };
        chomp;
        $_ =~ s/{//g;
        $_ =~ s/}//g;
        $_ =~ s/(\s+=)/=/g;
        $_ =~ s/(=\s+)/=/g;
            my @line=split(' ',$_);
            if( $_ =~ /CONDUCTOR/i ){
				$flag="metal";
            	$metalName=$line[1];
				$metalInSeq{$metalName}=$metal_counter++;
            	for($i=2;$i<=$#line;$i++){
            	        if( $line[$i] =~ /=/ ){
							@item=split('=',$line[$i]);
							$metal{$item[0]}=$item[1]; # %metal
            	        }else{
							print "WARNING:Watch out this!\n";
							print "WARNING:undefined: $line[$i]\n";
            	        };
				};
			}elsif( $line[0] =~ /VIA/i ){
			$flag="via";
			$viaName=$line[1];
			for($i=2;$i<=$#line;$i++){
				if( $line[$i] =~ /=/ ){
					@item=split('=',$line[$i]);
					$via{$item[0]}=$item[1]; # %via
				}else{
					print "WARNING:Watch out this!\n";
            		print "WARNING:undefined: $line[$i]\n";
				};
			};
    }elsif( $line[0] eq "DIELECTRIC"){
        if( $flag eq "metal"){
        $metal{"Above"}=$line[1];
        };
        unshift(@dielectric,$_);
        $flag="dielectric";
    };

    if( defined $metal{"Above"} ){
        print TECH "metal ",$metalName,"\n{\n";
        print TECH " Width { ",$metal{"WMIN"}," }\n";
        print TECH " Spacing { { ",$metal{"SMIN"}," } }\n";
        print TECH " Thickness ",$metal{"THICKNESS"},"\n";
        print TECH " Resistance ",$metal{"RPSQ"},"\n";
        print TECH " EM 1.0\n";
        print TECH " Above ",$metal{"Above"},"\n";
        print TECH "}\n\n";
        undef %metal;
    };

    if( defined $via{"AREA"} && defined $via{"RPV"} ){
            print TECH "via ",$viaName,"\n{\n";
            print TECH " Width { ",sqrt( $via{"AREA"} )," }\n";
            print TECH " Resistance ",$via{"RPV"},"\n";
            print TECH " EM 1.0\n";
			if( !defined $metalInSeq{$via{"TO"}} ){
                $metalInSeq{$via{"TO"}}=$metal_counter++ if defined $via{"TO"};
			};
			if( !defined $metalInSeq{$via{"FROM"}} ){
                $metalInSeq{$via{"FROM"}}=$metal_counter++ if defined $via{"FROM"};
			};

            if( $metalInSeq{$via{"TO"}} < $metalInSeq{$via{"FROM"}} ){
            	print TECH " UpperLayer ",$via{"TO"},"\n";
            	print TECH " LowerLayer ",$via{"FROM"},"\n";
         	}else{
            	print TECH " UpperLayer ",$via{"FROM"},"\n";
            	print TECH " LowerLayer ",$via{"TO"},"\n";
         	};
            print TECH "}\n\n";
        undef %via;
    };

    };

#=======
    $count=0;
    foreach $d ( @dielectric ){
            @line=split(' ',$d);
            $dielectricName=$line[1];
            push(@dielectricNameContainer,$line[1]);
            for($i=2;$i<=$#line;$i++){
            if( $line[$i] =~ /=/ ){
                    @item=split('=',$line[$i]);
                    $dielectric{$item[0]}=$item[1]; # %dielectric
            }else{
                print "WARNING:Watch out this!\n";
                print "WARNING:undefined: $line[$i]\n";
            };
            };
    if( defined %dielectric ){
        print TECH "dielectric ",$dielectricName,"\n{\n";
        print TECH " constant  ",$dielectric{"ER"},"\n";
        print TECH " thickness ",$dielectric{"THICKNESS"},"\n";
        print TECH " Height    0.0\n" if( $#dielectricNameContainer == 0);
        if( $count > 0 ) {
            print TECH " Above     ",$dielectricNameContainer[$#dielectricNameContainer -1],"\n";
        };
        print TECH "}\n\n";
        undef %via;
        $count++;
    };
    };
    close ( preITF );
};
#======= Synopys itf/nxtgrd Width-Dependent
sub SNPS_WD {
    my( $itf )=@_;
    open ( ITF ,$itf ) or die "$!";

    $flag=0;
    $con_flag=0;
    $rpsq_flag=0;
    $brace_counter=0;
    @RPSQ=();
    $metal_counter=0;
    foreach ( <ITF> ){
        if( $_ =~ /^\s*$/ ){
            next;
       };
    chomp;
          $_ =~ s/(\s*=\s*)/=/g;
    if( $_ =~ /CONDUCTOR/i ){
        $con_flag=1;
        $flag="metal";
        my @line=split(' ',$_);
        $metalName=$line[1];
        $metalInSeq{$metalName}=$metal_counter++;
        if( $_ =~ /THICKNESS=(\S+)/ ) {
        		$metal{"THICKNESS"}=$1;
        };
        if( $_ =~ /RPSQ\s*=\s*(\S+)/ ) {
        		$metal{"RPSQ"}=$1;
        };
        next;
    };
    #if( $rpsq_flag == 1 && $_ =~ /^\s*ETCH_VS_WIDTH_AND_SPACING/i ){
    if( $rpsq_flag == 1 && $brace_counter == 4 ){
          $con_flag=0;
          $rpsq_flag=0;
          $brace_counter=0;
          next;
    };
    if( $con_flag == 1 && $_ =~ /^\s*RPSQ_VS_WIDTH_AND_SPACING/i ){
            $rpsq_flag=1;
            push(@RPSQ,$_);
            next;
        };
        if( $rpsq_flag == 1 ){
            push(@RPSQ,$_);
            #-- counting # of }
         if($_ =~ /}/){
         	$brace_counter++;
         };
            next;
        };
        #}elsif( $line[0] =~ /VIA/i && $#line == 5 ){
            if( $_ =~ /VIA/i ){
                $con_flag=0;
              $_ =~ s/{//g;
          $_ =~ s/}//g;
          my @line=split(' ',$_);
            $flag="via";
            $viaName=$line[1];
            for($i=2;$i<=$#line;$i++){
                    if( $line[$i] =~ /=/ ){
                    @item=split('=',$line[$i]);
                    $via{$item[0]}=$item[1]; # %via
                    }else{
                    print "WARNING:Watch out this!\n";
                    print "WARNING:undefined: $line[$i]\n";
                    };
            };
        };
            if( $_ =~ /DIELECTRIC/i){
                $con_flag=0;
                $_ =~ s/{//g;
          $_ =~ s/}//g;
          my @line=split(' ',$_);
            if( $flag eq "metal"){
                    $metal{"Above"}=$line[1];
            };
            unshift(@dielectric,$_);
            $flag="dielectric";
            };

        if( defined $metal{"Above"} ){
        print TECH "metal ",$metalName,"\n{\n";
        print TECH " Thickness ",$metal{"THICKNESS"},"\n";
        for($i=0;$i<=$#RPSQ;$i++){
			print TECH $RPSQ[$i],"\n";
		};
		if( defined $metal{"RPSQ"} ){
			print TECH " Resistance ",$metal{"RPSQ"},"\n";
		};
        print TECH " EM 1.0\n";
        print TECH " Above ",$metal{"Above"},"\n";
        print TECH "}\n\n";
        undef %metal;
        @RPSQ=();
        };

        if( defined $via{"AREA"} && defined $via{"RPV"} ){
            print TECH "via ",$viaName,"\n{\n";
            print TECH " Width { ",sqrt( $via{"AREA"} )," }\n";
            print TECH " Resistance ",$via{"RPV"},"\n";
            print TECH " EM 1.0\n";
            if( $metalInSeq{$via{"TO"}} < $metalInSeq{$via{"FROM"}} ){
            	print TECH " UpperLayer ",$via{"TO"},"\n";
            	print TECH " LowerLayer ",$via{"FROM"},"\n";
         	}else{
            	print TECH " UpperLayer ",$via{"FROM"},"\n";
            	print TECH " LowerLayer ",$via{"TO"},"\n";
         	};
               print TECH "}\n\n";
        undef %via;
        };

    }; # foreach

#=======
    $count=0;
    foreach $d ( @dielectric ){
            @line=split(' ',$d);
            $dielectricName=$line[1];
            push(@dielectricNameContainer,$line[1]);
            for($i=2;$i<=$#line;$i++){
            if( $line[$i] =~ /=/ ){
                    @item=split('=',$line[$i]);
                    $dielectric{$item[0]}=$item[1]; # %dielectric
            }else{
                print "WARNING:Watch out this!\n";
                print "WARNING:undefined: $line[$i]\n";
            };
            };
    if( defined %dielectric ){
        print TECH "dielectric ",$dielectricName,"\n{\n";
        print TECH " constant  ",$dielectric{"ER"},"\n";
        print TECH " thickness ",$dielectric{"THICKNESS"},"\n";
        print TECH " Height    0.0\n" if( $#dielectricNameContainer == 0);
        if( $count > 0 ) {
            print TECH " Above     ",$dielectricNameContainer[$#dielectricNameContainer -1],"\n";
        };
        print TECH "}\n\n";
        undef %via;
        $count++;
    };
    };
    close ( ITF );
};
#======= Cadence ict
sub CAD {
  my( $ict )=@_;
  open ( TECH, ">$opt_o" ) or die "$!";
  open ( ICT ,$ict ) or die "$!";
  open ( TMP1 , ">tmp.ict0" ) or die "$!";
  
  #======= re-format ICT
  foreach (<ICT>){
    if( $_ =~ /^\s*$/ || $_ =~ /^\s*#/ ){
      next;
    };
    if( $_ =~ /#/ ){
      @line=split('#',$_);
      $_ = $line[0];
    };
    chomp;
    if( $_ =~ /^\s*process\s*/i){
      @pro=split('"',$_);
      $TECHNOLOGY = $pro[1];
      print "Process: ",$TECHNOLOGY,"\n";
      Print_header_ict( $TECHNOLOGY, $ict );
      next;
    };
    $_ =~ s/\"//g;
    if( $_ =~ /\{/){
      $_ =~ s/\{//g;
      $_ =~ s/
//g if $_ =~ /
/;
      print TMP1 $_," ";
    }elsif( $_ !~ /\{/ && $_ !~ /^\}/){
      @section=split(' ',$_);
      $section=join('=',@section);
      print TMP1 $section," ";
    }else{
      print TMP1 "\n";
    };
  };
  #=======
  close ( TMP1 );
  open ( TMP2, "tmp.ict0" ) or die "$!";
  open ( TMP, ">tmp.ict1" ) or die "$!";
  #======= end re-format
  foreach ( <TMP2> ){
    chomp;
    if(/^\s*conductor/i){ push(@conductor,$_);}
    elsif(/^\s*via/i){ push(@via,$_);}
    elsif(/^\s*diffusion/i){ push(@diffusion,$_);}
    elsif(/^\s*dielectric/i){ 
      ### Skip dielectric layer if thickness == 0
      ### DIELECTRIC SPACER	 {THICKNESS=0.0 
      if ( /\bTHICKNESS\b\s*=\s*(\S+)\s*/i ){
	if ( $1 == 0 ){
	  @skip=split(' ',$_);
	  print "\n";
	  print "*** Skip\n";
	  print "dielectric layer: ",$skip[1]," thickness=",$1,"\n";
	}else{
	  push(@dielectric,$_);
	}; # if
      }; # if
    }; # elsif
  };# foreach
  foreach ( @conductor,@via,@dielectric,@diffusion){
    print TMP $_,"\n";
  };
  #=======
  close ( TMP );
  close ( TMP2 );
  open ( TMP, "tmp.ict1" ) or die "$!";
  open ( DE, ">tmp.de" ) or die "$!";
  #======= end re-format
  foreach (<TMP>){
    chomp;
    @line=split(' ',$_);
    if($line[0] eq "conductor"){
      $conductor{"name"}=$line[1];
      for($idx_line=2;$idx_line<=$#line;$idx_line++){
	@item=split('=',$line[$idx_line]);
	if($item[0] eq "rho") {
	  $conductor{$item[0]}="RHO_VS_WIDTH_AND_SPACING";
	  $rhoValues = 0;
	  $cnt_rhoValues = 0;
	  $idx_rhoValues = 0;
	  $rhoSpacing = "";
	  $cnt_rhoSpacing = 0;
	  $idx_rhoSpacing = 0;
	  $rhoWidth = "";
	  $cnt_rhoWidth = 0;
	  $idx_rhoWidth = 0;
	  $width_before_spacing = 0;
	  $rho_widths = 0;
	} elsif($item[0] eq "rho_spacings") {
	  if($rho_widths) {
	    $width_before_spacing = 1;
	  } else {
	    $width_before_spacing = 0;
	  }
	  for($idx_item=1;$idx_item<=$#item;$idx_item++){
	    $cnt_rhoSpacing++;
	    $rhoSpacing = "$rhoSpacing $item[$idx_item]";
	  }
	} elsif($item[0] eq "rho_widths") {
	  $rho_widths = 1;
	  for($idx_item=1;$idx_item<=$#item;$idx_item++){
	    $cnt_rhoWidth++;
	    $rhoWidth = "$rhoWidth $item[$idx_item]";
	  }
	} elsif($item[0] eq "rho_values") {
	  $rhoValues = 1;
	  $idx_rhoSpacing = 0;
	  for($idx_item=1;$idx_item<=$#item;$idx_item++){
	    $rhoValues[$idx_rhoSpacing][$idx_item] = "$item[$idx_item]";
	  }
	} elsif ($rhoValues) {
	  $idx_rhoSpacing++;
	  for($idx_item=0;$idx_item<=$#item;$idx_item++){
	    $rhoValues[$idx_rhoSpacing][$idx_item] = "$item[$idx_item]";
	  }
	  if ($idx_rhoSpacing eq $cnt_rhoSpacing) {
	    $rhoValues = 0;
	  }
	} else {
	  $conductor{$item[0]}=$item[1];
	}
	if($item[0] eq "wire_thickness_ratio") {
	  $conductor{$item[0]}="POLYNOMIAL_BASED_thickness_VARIATION";
	  $p = 0;
	} elsif($item[0] eq "wtr_width_ranges") {
	  $cnt_table = 1;
	  $conductor{$item[0]} = "$item[2]";
	  for($idx_item=3;$idx_item<=$#item;$idx_item++){
	    $conductor{$item[0]}="$conductor{$item[0]} $item[$idx_item]";
	    $cnt_table++;
	  }
	} elsif($item[0] eq "wtr_density_polynomial_order") {
	  $conductor{$item[0]}="0";
	  $cnt_wtrDens = $item[1];
	  $cnt_wtrDensM1  = $cnt_wtrDens - 1;
	  $cnt_wtrDensP1  = $cnt_wtrDens + 1;
	  if($item[1]>1) {
	    for($idx_wtrDens1=1;$idx_wtrDens1<=$item[1];$idx_wtrDens1++){
	      $conductor{$item[0]}="$idx_wtrDens1 $conductor{$item[0]}";
	    }
	  }
	  if( defined $conductor{"wtr_width_polynomial_order"} ) {
	    $width_before_density = 1;
	  } else {
	    $width_before_density = 0;
	  }
	} elsif($item[0] eq "wtr_width_polynomial_order") {
	  $conductor{$item[0]}="0";
	  $cnt_wtrWidth = $item[1];
	  $cnt_wtrWidthM1 = $cnt_wtrWidth - 1;
	  $cnt_wtrWidthP1 = $cnt_wtrWidth + 1;
	  if($item[1]>1) {
	    for($idx_wtrWidth1=1;$idx_wtrWidth1<=$item[1];$idx_wtrWidth1++){
	      $conductor{$item[0]}="$idx_wtrWidth1 $conductor{$item[0]}";
	    }
	  }
	} elsif($polynomial_coefficients) {
	  if( $item[0] ne "\}" && $item[0] ne "\{") {
	    for($idx_item=0;$idx_item<=$#item;$idx_item++){
	      $polyCoeff[$idx_table1][$idx_wtrWidth1][$idx_item] = "$item[$idx_item]";
	    }
	    if ($idx_wtrWidth1 >= $cnt_wtrWidth) {
	      $idx_table1++;
	      $idx_wtrWidth1 = 0;
	      if ($idx_table1 >= $cnt_table) {
		$polynomial_coefficients = 0;
	      }
	    } else {
	      $idx_wtrWidth1++;
	    }
	  }
	} elsif($item[0] eq "wtr_polynomial_coefficients") {
	  $conductor{$item[0]}="POLYNOMIAL_COEFFICIENTS";
	  $polynomial_coefficients = 1;
	  $idx_wtrWidth1 = 0;
	  $idx_table1 = 0;
	  for($iwtr=0;$iwtr<$cnt_wtrWidthP1;$iwtr++) {
	    for($jwtr=0;$jwtr<$cnt_wtrDensP1;$jwtr++) {
	      $polyCoeff[2][$iwtr][$jwtr] = "0";
	    }
	  }
	}
      }
      $flag="conductor";
    }elsif($line[0] eq "diffusion"){
      $diffusion{"name"}=$line[1];
      for($i=2;$i<=$#line;$i++){
	@item=split('=',$line[$i]);
	$diffusion{$item[0]}=$item[1];
      };
      $flag="diffusion";
    }elsif($line[0] eq "dielectric"){
      $dielectric{"name"}=$line[1];
      for($i=2;$i<=$#line;$i++){
	@item=split('=',$line[$i]);
	$dielectric{$item[0]}=$item[1];
      };
      $flag="dielectric";
    }elsif($line[0] eq "via"){
      $via{"name"}=$line[1];
      for($i=2;$i<=$#line;$i++){
	@item=split('=',$line[$i]);
	if( $item[0] =~ /area_resistance/i ){
	  $via{"area"}=$item[2];	
	};
	$via{$item[0]}=$item[1];
      };
      $flag="via";
    };
    if( $flag eq "conductor" ){
            print TECH "metal ",$conductor{"name"}," {\n";
            if(($conductor{"name"} =~ /PO/) || ($conductor{"name"} =~ /po/)) {
                print TECH " Type D\n";
            }
            if( defined $conductor{"Tnom"} ) {
                print TECH " Tnom ",$conductor{"Tnom"},"\n";
                undef $conductor{"Tnom"};
            } elsif (defined $opt_tnom) {
                print TECH " Tnom $opt_tnom\n";
            }
            if( defined $conductor{"Tnom_em"} ) {
                print TECH " Tnom_em ",$conductor{"Tnom_em"},"\n";
                undef $conductor{"Tnom_em"};
            } elsif (defined $opt_tnom_em) {
                print TECH " Tnom_em $opt_tnom_em\n";
            }
            if( defined $conductor{"temp_tc1"} ) {
                print TECH " Coeff_RT1 ",$conductor{"temp_tc1"},"\n";
                undef $conductor{"temp_tc1"};
            }
            if( defined $conductor{"rho"} ) {
                print TECH " RHO_VS_WIDTH_AND_SPACING \{\n";
                if($width_before_spacing) {
                    print TECH "  WIDTHS \{ $rhoWidth \}\n";
                    print TECH "  SPACINGS  \{ $rhoSpacing \}\n";
                } else {
                    print TECH "  SPACINGS  \{ $rhoSpacing \}\n";
                    print TECH "  WIDTHS \{ $rhoWidth \}\n";
                }
                print TECH "  VALUES  \{\n";
  		    for($idx_rhoSpacing=0;$idx_rhoSpacing<$cnt_rhoSpacing;$idx_rhoSpacing++) {
                        print TECH "    {";
  		        for($idx_rhoWidth=0;$idx_rhoWidth<=$cnt_rhoWidth;$idx_rhoWidth++) {
                            print TECH " $rhoValues[$idx_rhoSpacing][$idx_rhoWidth]";
                        if ( $idx_rhoWidth eq $cnt_rhoWidth) {
                            print TECH " }\n";
			}
                        if ( $idx_rhoSpacing eq $cnt_rhoSpacing) {
                            print TECH " }\n";
			}
                    }
                }
                print TECH " \}\n";
		undef $rhoValues;
                undef $conductor{"rho"};
            }
            if( defined $conductor{"min_width"} ) {
                print TECH " MINWIDTH  ",$conductor{"min_width"},"\n";
                undef $conductor{"min_width"};
            }
            if( defined $conductor{"temp_tc2"} ) {
                print TECH " Coeff_RT2 ",$conductor{"temp_tc2"},"\n";
                undef $conductor{"temp_tc2"};
            }
            if( defined $conductor{"min_spacing"} ) {
                print TECH " MINSPACE  ",$conductor{"min_spacing"},"\n";
                undef $conductor{"min_spacing"};
            }
            if( defined $conductor{"wire_thickness_ratio"} ) {
                print TECH " POLYNOMIAL_BASED_THICKNESS_VARIATION \{\n";
                if( defined $conductor{"wtr_width_ranges"} ) {
                    print TECH "  WIDTH_RANGES \{ ",$conductor{"wtr_width_ranges"},"\ }\n";
                    undef $conductor{"wtr_width_ranges"}
                }
                if($width_before_density) {
                    print TECH "  WIDTH_POLYNOMIAL_ORDERS \{ ",$conductor{"wtr_width_polynomial_order"},"\ }\n";
                    print TECH "  DENSITY_POLYNOMIAL_ORDERS  \{ ",$conductor{"wtr_density_polynomial_order"},"\ }\n";
                } else {
                    print TECH "  DENSITY_POLYNOMIAL_ORDERS  \{ ",$conductor{"wtr_width_polynomial_order"},"\ }\n";
                    print TECH "  WIDTH_POLYNOMIAL_ORDERS \{ ",$conductor{"wtr_density_polynomial_order"},"\ }\n";
                }
		if( defined $conductor{"wtr_polynomial_coefficients"} ) {
		  for($idx_table2=0;$idx_table2<=$cnt_table;$idx_table2++) {
		    print TECH "   POLYNOMIAL_COEFFICIENTS {\n";
		    for($idx_wtrWidth2=0;$idx_wtrWidth2<$cnt_wtrWidthP1;$idx_wtrWidth2++) {
		      print TECH "    {";
		      for($idx_wtrDens2=0;$idx_wtrDens2<=$cnt_wtrDensP1;$idx_wtrDens2++) {
			print TECH " $polyCoeff[$idx_table2][$idx_wtrWidth2][$idx_wtrDens2]";
			if ( $idx_wtrDens2 eq $cnt_wtrDens) {
			  print TECH " }\n";
			}
		      }
		      if ( $idx_wtrWidth2 eq $cnt_wtrWidth) {
			print TECH "   }\n";
		      }
		    }
		    if ( $idx_table2 eq $cnt_table) {
		      print TECH "  }\n";
		    }
		  }
		}
                print TECH " }\n";
                undef $polyCoeff;
                undef $conductor{"wtr_polynomial_coefficients"};
                undef $conductor{"wtr_width_ranges"};
                undef $conductor{"wtr_width_polynomial_order"};
                undef $conductor{"wtr_density_polynomial_order"};
                undef $conductor{"wire_thickness_ratio"};
            }
            print TECH " EM 1.0\n";
            if( defined $conductor{"CAPACITIVE_ONLY_ETCH"} ) {
                my $capacitiveOnlyEtch = -1*$conductor{"CAPACITIVE_ONLY_ETCH"};
                print TECH " CAPACITIVE_ONLY_ETCH ",$capacitiveOnlyEtch,"\n";
                undef $conductor{"CAPACITIVE_ONLY_ETCH"};
            }
            if( defined $conductor{"RESISTIVE_ONLY_ETCH"} ) {
                my $capacitiveOnlyEtch = -1*$conductor{"RESISTIVE_ONLY_ETCH"};
                print TECH " RESISTIVE_ONLY_ETCH ",$capacitiveOnlyEtch,"\n";
                undef $conductor{"RESISTIVE_ONLY_ETCH"};
            }
            if( defined $conductor{"thickness"} ) {
                print TECH " THICKNESS ",$conductor{"thickness"},"\n";
                undef $conductor{"thickness"};
            }
            if( defined $conductor{"resistivity"} ) {
                print TECH " Resistance ",$conductor{"resistivity"},"\n";
                undef $conductor{"resistivity"};
            }
            if( defined $conductor{"height"} ) {
                print TECH " Height ",$conductor{"height"},"\n";
                undef $conductor{"height"};
            }
            print TECH "}\n\n";
            undef $conductor;
            next;
        };
        if( $flag eq "diffusion" ){
            print TECH "metal ",$diffusion{"name"}," {\n";
            print TECH " Type D\n";
            if( defined $diffusion{"Tnom"} ) {
                print TECH " Tnom ",$diffusion{"Tnom"},"\n";
                undef $diffusion{"Tnom"};
            } elsif (defined $opt_tnom) {
                print TECH " Tnom $opt_tnom\n";
            }
            if( defined $diffusion{"Tnom_em"} ) {
                print TECH " Tnom_em ",$diffusion{"Tnom_em"},"\n";
                undef $diffusion{"Tnom_em"};
            } elsif (defined $opt_tnom_em) {
                print TECH " Tnom_em $opt_tnom_em\n";
            }
            if( defined $diffusion{"temp_tc1"} ) {
                print TECH " Coeff_RT1 ",$diffusion{"temp_tc1"},"\n";
                undef $diffusion{"temp_tc1"};
            }
            if( defined $diffusion{"min_width"} ) {
                print TECH " MINWIDTH  ",$diffusion{"min_width"},"\n";
                undef $diffusion{"min_width"};
            }
            if( defined $diffusion{"temp_tc2"} ) {
                print TECH " Coeff_RT2 ",$diffusion{"temp_tc2"},"\n";
                undef $diffusion{"temp_tc2"};
            }
            if( defined $diffusion{"min_spacing"} ) {
                print TECH " MINSPACE  ",$diffusion{"min_spacing"},"\n";
                undef $diffusion{"min_spacing"};
            }
            print TECH " EM 1.0\n";
            if( defined $diffusion{"CAPACITIVE_ONLY_ETCH"} ) {
                my $capacitiveOnlyEtch = -1*$diffusion{"CAPACITIVE_ONLY_ETCH"};
                print TECH " CAPACITIVE_ONLY_ETCH ",$capacitiveOnlyEtch,"\n";
                undef $diffusion{"CAPACITIVE_ONLY_ETCH"};
            }
            if( defined $diffusion{"RESISTIVE_ONLY_ETCH"} ) {
                my $capacitiveOnlyEtch = -1*$diffusion{"RESISTIVE_ONLY_ETCH"};
                print TECH " RESISTIVE_ONLY_ETCH ",$capacitiveOnlyEtch,"\n";
                undef $diffusion{"RESISTIVE_ONLY_ETCH"};
            }
            if( defined $diffusion{"thickness"} ) {
                print TECH " THICKNESS ",$diffusion{"thickness"},"\n";
                undef $diffusion{"thickness"};
            }
            if( defined $diffusion{"resistivity"} ) {
                print TECH " Resistance ",$diffusion{"resistivity"},"\n";
                undef $diffusion{"resistivity"};
            }
            if( defined $diffusion{"height"} ) {
                print TECH " Height ",$diffusion{"height"},"\n";
                undef $diffusion{"height"};
            }
            print TECH "}\n\n";
            undef $diffusion;
            next;
        };
        if( $flag eq "dielectric" ){
            print DE "dielectric ",$dielectric{"name"}," {\n";
            if( defined $dielectric{"dielectric_constant"} ) {
                print DE " constant ",$dielectric{"dielectric_constant"},"\n";
                undef $dielectric{"dielectric_constant"};
            }
            if( defined $dielectric{"thickness"} ) {
                print DE " thickness ",$dielectric{"thickness"},"\n";
                undef $dielectric{"thickness"};
            }
            if( defined $dielectric{"height"} ) {
                print DE " Height ",$dielectric{"height"},"\n";
                undef $dielectric{"height"};
            }
            print DE "}\n\n";
            undef $dielectric;
            next;
        };
        if( $flag eq "via" ){
            print TECH "via ",$via{"name"}," {\n";
            if( defined $via{"Tnom"} ) {
                print TECH " Tnom ",$via{"Tnom"},"\n";
                undef $via{"Tnom"};
            } elsif (defined $opt_tnom) {
                print TECH " Tnom $opt_tnom\n";
            }
            if( defined $via{"Tnom_em"} ) {
                print TECH " Tnom_em ",$via{"Tnom_em"},"\n";
                undef $via{"Tnom_em"};
            } elsif (defined $opt_tnom_em) {
                print TECH " Tnom_em $opt_tnom_em\n";
            }
            if( defined $via{"contact_resistance"} ) {
                print TECH " Resistance ",$via{"contact_resistance"},"\n";
                undef $via{"contact_resistance"};
            } elsif ( defined $via{"area_resistance"} ){
                print TECH " Resistance ",$via{"area_resistance"},"\n";
                print TECH " AREA ",$via{"area"},"\n";
                undef $via{"area_resistance"};
            };
            if( defined $via{"temp_tc1"} ) {
                print TECH " Coeff_RT1 ",$via{"temp_tc1"},"\n";
                undef $via{"temp_tc1"};
            }
            if( defined $via{"temp_tc2"} ) {
                print TECH " Coeff_RT2 ",$via{"temp_tc2"},"\n";
                undef $via{"temp_tc2"};
            }
            print TECH " EM 1.0\n";
            if( defined $via{"top_layer"} ) {
                print TECH " UpperLayer ",$via{"top_layer"},"\n";
                undef $via{"top_layer"};
            }
            if( defined $via{"bottom_layer"} ) {
                print TECH " LowerLayer ",$via{"bottom_layer"},"\n";
                undef $via{"bottom_layer"};
            }
            print TECH " }\n\n";
            undef $via;
            next;
        };
    };

    #=======
    close ( DE );
    close ( TMP );
    close ( ICT );
    close ( TECH );
};
#======= Synopys itf/nxtgrd Width-Dependent-EFFECTIVE_RPSQ_TABLE
sub SNPS_WD_EFF {
    my( $itf )=@_;
    open ( ITF ,$itf ) or die "$!";

    $flag=0;
    $con_flag=0;
    $rpsq_flag=0;
    @RPSQ=();
    $metal_counter=0;
    foreach ( <ITF> ){
        if( $_ =~ /^\s*$/ ){
            next;
       	};
    	chomp;
        $_ =~ s/(\s*=\s*)/=/g;
    	if( $_ =~ /CONDUCTOR/i ){
        	$con_flag=1;
        	$flag="metal";
        	my @line=split(' ',$_);
        	$metalName=$line[1];
        	$metalInSeq{$metalName}=$metal_counter++;
        	if( $_ =~ /THICKNESS=(\S+)/ ) {
        		$metal{"THICKNESS"}=$1;
			};
			if( $_ =~ /RPSQ\s*=\s*(\S+)/ ) {
        		$metal{"RPSQ"}=$1;
			};
			next;
		};
		if( $con_flag == 1 && $_ =~ /^\s*EFFECTIVE_RPSQ_TABLE/i ){
			$_ =~ s/( |{|}|\))//g;
			@eff_rpsq=split('\(',$_);
			@W=();
			@R=();
			for($i=1;$i<=$#eff_rpsq;$i++){
				@W_R=split(',',$eff_rpsq[$i]);
				push(@W,$W_R[0]);
				push(@R,$W_R[1]);
			};
			push(@RPSQ," RPSQ_VS_WIDTH_AND_SPACING {");
			push(@RPSQ,"   SPACINGS { 1 }");
			$width_elements=join(' ',@W);
			$width="   WIDTHS   { ".$width_elements." }";
			push(@RPSQ,$width);
			push(@RPSQ,"\tVALUES {");
			foreach ( @R ){
				push(@RPSQ,"\t\t$_");
			};
			push(@RPSQ,"\t}");
			push(@RPSQ," }");
			
            $rpsq_flag=1;
			$con_flag=0;
            $rpsq_flag=0;
            next;
        };
        if( $_ =~ /VIA/i ){
			$con_flag=0;
            $_ =~ s/{//g;
			$_ =~ s/}//g;
			my @line=split(' ',$_);
            $flag="via";
            $viaName=$line[1];
            for($i=2;$i<=$#line;$i++){
                    if( $line[$i] =~ /=/ ){
						@item=split('=',$line[$i]);
						$via{$item[0]}=$item[1]; # %via
                    }else{
						print "WARNING:Watch out this!\n";
						print "WARNING:undefined: $line[$i]\n";
                    };
            };
        };
        if( $_ =~ /DIELECTRIC/i){
			$con_flag=0;
            $_ =~ s/{//g;
			$_ =~ s/}//g;
			my @line=split(' ',$_);
            if( $flag eq "metal"){
				$metal{"Above"}=$line[1];
            };
            unshift(@dielectric,$_);
            $flag="dielectric";
        };

        if( defined $metal{"Above"} ){
			print TECH "metal ",$metalName,"\n{\n";
			print TECH " Thickness ",$metal{"THICKNESS"},"\n";
			for($i=0;$i<=$#RPSQ;$i++){
				print TECH $RPSQ[$i],"\n";
			};
			if( defined $metal{"RPSQ"} ){
				print TECH " Resistance ",$metal{"RPSQ"},"\n";
			};
			print TECH " EM 1.0\n";
			print TECH " Above ",$metal{"Above"},"\n";
			print TECH "}\n\n";
			undef %metal;
			@RPSQ=();
		};

        if( defined $via{"AREA"} && defined $via{"RPV"} ){
            print TECH "via ",$viaName,"\n{\n";
            print TECH " Width { ",sqrt( $via{"AREA"} )," }\n";
            print TECH " Resistance ",$via{"RPV"},"\n";
            print TECH " EM 1.0\n";
            if( $metalInSeq{$via{"TO"}} < $metalInSeq{$via{"FROM"}} ){
            	print TECH " UpperLayer ",$via{"TO"},"\n";
            	print TECH " LowerLayer ",$via{"FROM"},"\n";
         	}else{
            	print TECH " UpperLayer ",$via{"FROM"},"\n";
            	print TECH " LowerLayer ",$via{"TO"},"\n";
         	};
               print TECH "}\n\n";
        undef %via;
        };

    }; # foreach

#=======
    $count=0;
    foreach $d ( @dielectric ){
            @line=split(' ',$d);
            $dielectricName=$line[1];
            push(@dielectricNameContainer,$line[1]);
            for($i=2;$i<=$#line;$i++){
            if( $line[$i] =~ /=/ ){
                    @item=split('=',$line[$i]);
                    $dielectric{$item[0]}=$item[1]; # %dielectric
            }else{
                print "WARNING:Watch out this!\n";
                print "WARNING:undefined: $line[$i]\n";
            };
            };
    if( defined %dielectric ){
        print TECH "dielectric ",$dielectricName,"\n{\n";
        print TECH " constant  ",$dielectric{"ER"},"\n";
        print TECH " thickness ",$dielectric{"THICKNESS"},"\n";
        print TECH " Height    0.0\n" if( $#dielectricNameContainer == 0);
        if( $count > 0 ) {
            print TECH " Above     ",$dielectricNameContainer[$#dielectricNameContainer -1],"\n";
        };
        print TECH "}\n\n";
        undef %via;
        $count++;
    };
    };
    close ( ITF );
};

#======= post-process: changing naming style from map file
sub namingCorrelation {
    open( TECH , "$opt_o" )or die "$!";
    open( LMap , "$opt_m" ) or die "$!";
    $new_tech = $opt_o.".rename";
    open( newTECH , ">$new_tech" ) or die "$!";
    #-- define % for each layer
    foreach ( <LMap> ){
        if( $_ =~ /^\s*\#/ || $_ =~ /^\s*$/ ){
            next;
        };
        chomp;
        @line_map=split(' ',$_);
        $layer{$line_map[0]}=$line_map[1];
    };

    #-- renaming layer in TECH
    @misLayer=();
    if( !defined $opt_i ) {
        foreach ( <TECH> ) {
            if( $_ =~ /^\s*$/ ){
                next;
            };
            chomp;
            @line_tech=split(' ',$_);
            if( $line_tech[0] =~ /^\s*(metal)|(via)/i && defined $layer{$line_tech[1]}){
                print newTECH $line_tech[0]," ",$layer{$line_tech[1]}," ";
#                    print "newTECH '$line_tech[0]' '$layer{$line_tech[1]}'\n";
                for($i=2;$i<=$#line_tech;$i++){
		  if ($line[$i] != /conformal/) {
                    print newTECH $line[$i]," ";
#                    print "newTECH $line[$i]\n";
		  }
                };
                print newTECH "\n";
                next;
            };
            if( $#line_tech >= 1 && defined $layer{$line_tech[1]} ){
                print newTECH " ",$line_tech[0]," ",$layer{$line_tech[1]}," ";
                for($i=2;$i<=$#line_tech;$i++){
                    print newTECH $line[$i]," ";
                };
                print newTECH "\n";
                next;
            };
            if( $line_tech[0] =~ /((metal)|(via))/i && !defined $layer{$line_tech[1]}){
                push(@misLayer,$line_tech[1]);
            };
            print newTECH $_,"\n";
        };
    }elsif( defined $opt_i ){
        $filter_flag=0;
        foreach ( <TECH> ) {
            if( $_ =~ /^\s*$/ ){
                next;
            };
            chomp;
            @line_tech=split(' ',$_);
            if( $filter_flag == 1 && $_ =~ /^\s*(upper)|(lower)/i ){
                    next;
            };
            if( $filter_flag == 1 && $line_tech[0] =~ /^\s*(metal)|(via)/ && defined $layer{$line_tech[1]}){
                print newTECH $line_tech[0]," ",$layer{$line_tech[1]}," ";
                for($i=2;$i<=$#line_tech;$i++){
                    print newTECH $line[$i]," ";
                };
                print newTECH "\n";
                $filter_flag = 0;
                next;
            };
            if( $filter_flag == 1 && $line_tech[0] =~ /dielectric/i ){
                $filter_flag = 0;
            };
            if( $filter_flag == 0 && $#line_tech >= 1 && defined $layer{$line_tech[1]} ){
                print newTECH $line_tech[0]," ",$layer{$line_tech[1]}," ";
                for($i=2;$i<=$#line_tech;$i++){
                    print newTECH $line[$i]," ";
                };
                print newTECH "\n";
                next;
            };
            if( $filter_flag == 1 && $#line_tech >= 1 && defined $layer{$line_tech[1]} ){
                next;
            };
            if( $line_tech[0] =~ /(metal)|(via)/ && !defined $layer{$line_tech[1]}){
                $filter_flag=1;
                next;
            };
            if( $filter_flag == 1 ){
                next;
            };

            print newTECH $_,"\n";
        };
    };
    #-- close TECH, LMap
    close ( TECH );
    close ( LMap );
    close ( newTECH );
    system ( "mv $new_tech $opt_o" );

    #-- printing warning msg:
    if( $#misLayer > 0 ) {
        print "\n\nWARNING ***\n";
        print "The following layers exist in < $input >\n";
        print "             but not exist in < $opt_m >\n";
        print "Naming for those layers will be kept as in < $input >\n";
        print "---------------------\n";
        for($i=0;$i<=$#misLayer;$i++){
            print $misLayer[$i],"\n";
        };
        print "---------------------\n";
        print "\n\nPlease check $opt_m or manually changing $opt_o respectively\n";
    };
};

#======= post-process: modify R base on TC map file
sub TC {
    open( TMap , "$opt_t" ) or die "$!";
    $new_tech = $opt_o.".Trename";
    open( newTECH , ">$new_tech" ) or die "$!";

	#-- grep RPSQ_VS_WIDTH_AND_SPACING
    open( TECH , "$opt_o" )or die "$!";
    $width_dependent = 0;
    while ( <TECH> ){
		if( $_ =~ /^\s*RPSQ_VS_WIDTH_AND_SPACING/i ){
            $width_dependent = 1;
            last;
        };
    };
	close( TECH );
    #-- define % for each layer
    foreach ( <TMap> ){
        if( $_ =~ /^\s*\#/ || $_ =~ /^\s*$/ ){
            next;
        };
        chomp;
        @line_map=split(' ',$_);
        $name{$line_map[0]}=$line_map[0];
        $deltaT{$line_map[0]}=$line_map[2] - $line_map[1];
        $TC1{$line_map[0]}=$line_map[3];
        $TC2{$line_map[0]}=$line_map[4];
    };
    open( TECH , "$opt_o" )or die "$!";

    #-- Modify R in TECH
	if( $width_dependent == 0 ){
		$layer_flag=0;
	    while ( <TECH> ) {
	        if( $_ =~ /^\s*$/ ){
				next;
	        };
	        chomp;
	        @line_tech=split(' ',$_);
	        if( $line_tech[0] =~ /^\s*(metal)|(via)/i && defined $name{$line_tech[1]}){
				$layer_name=$line_tech[1];
				$layer_flag=1;
				print newTECH $_,"\n";
				next;
			};
			if( $layer_flag == 1 && $_ =~ /^\s*}/ ){
				$layer_flag=0;
                print newTECH $_,"\n";
				next;
			};
			if( $layer_flag == 1 && $_ =~ /Resistance/i ){
				#newR = old R * ( 1 + (TC1 * (delta T)) + ( TC2 * delta T * delta T ) )
				$newR=$line_tech[1]*( 1 + $TC1{$layer_name} * $deltaT{$layer_name}
				+ $TC2{$layer_name} * $deltaT{$layer_name} * $deltaT{$layer_name} );
				print newTECH " ",$line_tech[0]," ",$newR,"\n";
				next;
			};
			print newTECH $_,"\n";
	    };
	}elsif( $width_dependent == 1 ){
		$metal_flag=0;
		$via_flag=0;
		while ( <TECH> ){
			if( $_ =~ /^\s*$/ ){
                next;
            };
			chomp;
			@line_tech=split(' ',$_);
            if( $line_tech[0] =~ /^\s*metal/i && defined $name{$line_tech[1]}){
                $metal_name=$line_tech[1];
                $metal_flag=1;
                print newTECH $_,"\n";
                next;
            };
			if( $metal_flag == 1 && $_ =~ /RPSQ_VS_WIDTH_AND_SPACING/i ){
				$metal_flag = 2;
				print newTECH $_,"\n";
				next;
			};
			if( $metal_flag == 2 && $_ =~ /VALUES/i ){
				$metal_flag = 3;
				print newTECH $_,"\n";
				next;
			};
			if( $metal_flag == 3 && $_ =~ /^\s*}/ ){
				$metal_flag = 0;
				print newTECH $_,"\n";
				next;
			};
			if( $metal_flag == 3 ){
				@R = map ( $_*( 1 + $TC1{$metal_name} * $deltaT{$metal_name}
					+ $TC2{$metal_name} * $deltaT{$metal_name} *
					$deltaT{$metal_name} ),	@line_tech);
				for($i=0;$i<=$#R;$i++){
					print newTECH $R[$i]," ";
				};
				print newTECH "\n";
				next;
			};
            if( $line_tech[0] =~ /^\s*via/i && defined $name{$line_tech[1]}){
                $via_name=$line_tech[1];
                $via_flag=1;
                print newTECH $_,"\n";
                next;
            };
            if( $via_flag == 1 && $_ =~ /^\s*}/ ){
                $layer_flag=0;
                print newTECH $_,"\n";
                next;
            };
            if( $via_flag == 1 && $_ =~ /Resistance/i ){
                $newR=$line_tech[1]*( 1 + $TC1{$via_name} * $deltaT{$via_name}
					+ $TC2{$via_name} * $deltaT{$via_name} * $deltaT{$via_name} );
                print newTECH " ",$line_tech[0]," ",$newR,"\n";
                next;
            };
            print newTECH $_,"\n";
		};
	};
    #-- close TECH, TMap
    close ( TECH );
    close ( TMap );
    close ( newTECH );
    system ( "mv $new_tech $opt_o" );

};

#======= post-process: modify EM base on EM map file
sub EM {
    open( EMap , "$opt_e" ) or die "$!";
	#-- read EM map file
	while (<EMap>){
		next if $_ =~ /^\s*#/;
		chomp;
		@line=split(' ',$_);
		$EM{$line[0]}=$line[1];
		$EMAdjust{$line[0]}=$line[2] if $#line == 2;
	};
	close EMap;

    $new_tech = $opt_o.".Erename";
    open( newTECH , ">$new_tech" ) or die "$!";
    open( TECH , "$opt_o" )or die "$!";

    #-- Modify EM in TECH
	while ( <TECH> ){
		if( $_ =~ /^\s*$/ ){
            next;
        };
		chomp;
        if( $_ =~ /^\s*(metal)|(via)/i ){
			@line_tech=split(' ',$_);
            $metal_name=$line_tech[1];
            print newTECH $_,"\n";
            next;
        };
		if( $_ =~ /^\s*em\s+/i ){
			if( defined $EM{$metal_name} ){
				print newTECH " EM ",$EM{$metal_name},"\n";
			}else{
				print "\n** Please put EM value for < ",$metal_name," > in ",$opt_e,"\n";
				print newTECH $_,"\n";
			};
			if( defined $EMAdjust{$metal_name} ){
				print newTECH " EM_Adjust ",$EMAdjust{$metal_name},"\n";
			};
			next;
		};
        print newTECH $_,"\n";
	};

    #-- close TECH, TMap
    close ( TECH );
    close ( newTECH );
    system ( "mv $new_tech $opt_o" );
};

#======= print header
sub Print_header {
    my( $technology )=@_;
    print TECH "# Apache technology file\n";
    print TECH "#\n";
    print TECH "# This file contains the technology parameters for running\n";
    print TECH "# RedHawk-S, RedHawk-SD, RedHawk-SDL, and SkyHawk tools, and utilities such as\n";
    print TECH "# gds2def and gdsmem.\n";
    print TECH "\n\n";
    print TECH "#---  < ",$technology," >  ---\n";
    print TECH "\n";
    print TECH "units {\n";
    print TECH " capacitance 1p\n";
    print TECH " inductance  1n\n";
    print TECH " resistance  1ohm\n";
    print TECH " length      1u\n";
    print TECH " current     1m\n";
    print TECH " voltage     1v\n";
    print TECH " time        1n\n";
    print TECH " frequency   1me\n";
    print TECH "}\n";
    print TECH "\n";
    print TECH "\n";
};
#======= print header
sub Print_header_ict {
    my( $technology, $ict )=@_;
    print TECH "# Apache RedHawk and Totem technology file\n";
    print TECH "# Generated by 'adsTechConverter.pl'\n";
    print TECH "# From: '$ict'\n";
    ($sec,$min,$h,$mtag,$mon,$year,$wday,$ytag,$idst) = localtime(time);
    $year = $year + 1900;
    $today = (Mon,Tue,Wed,Thu,Fri,Sat,Sun)[(localtime)[6]];
    $month = (Jan,Feb,Mar,Apr,Mai,Jun,Jul,Aug,Sep,Oct,Nov,Dec)[(localtime)[4]];
    print TECH "# Date: $today $month $mtag $h:$min:$sec $year\n#\n";
    print TECH "#---  < ",$technology," >  ---\n";
    print TECH "\n";
    print TECH "units {\n";
    print TECH " capacitance 1pf\n";
    print TECH " inductance  1nh\n";
    print TECH " resistance  1ohm\n";
    print TECH " length      1um\n";
    print TECH " current     1ma\n";
    print TECH " voltage     1v\n";
    print TECH " power       1w\n";
    print TECH " time        1n\n";
    print TECH " frequency   1MHz\n";
    print TECH "}\n";
    print TECH "\n";
    print TECH "\n";
};

#############################################################################

=head1 SYNOPSIS

  Usage: perl adsTechConverter.pl [-h] [-s itf/nxtgrd | -c ict] [-o file] [-m optional/layer_map] [-i optional] [ -t optional ]

    -h:  Print this help message.
    -s:  Synopys.itf or .nxtgrd
    -c:  Cadence.ict
    -m:  Layer mapping file [ optional ]
         if this is specified, naming rule will be changed
         Syntax as following "LAYER MAPPING EXAMPLE"
    -i:  This option shoule go with -m
         If "-i" is specified, layers will be drop
         which does not exist in Layer mapping file
    -o:  Output apache tech file
    -t:  temperature coefficients table
         Syntax as following "TEMPERATURE COEFFICIENTS EXAMPLE"
	-e:	 EM table

    -tnom:    add Tnom for via and metal layers (ict convertion only)
    -tnom_em: add Tnom_em for via and metal layers (ict convertion only)

    ** LAYER MAPPING EXAMPLE
    #<layer_in_itf/nxtgrd/ict>    <layer_in_lef>
    metal1    MET1
    metal2    MET2
    via1	  VIA1

    ** TEMPERATURE COEFFICIENTS EXAMPLE
    #<metal_in_lef> <temperature of tech file> <desired temperature> <TC1> <TC2>
    MET1 25 125 2 5
    MET2 25 125 0.2 0.5

	** EM TABLE EXAMPLE
	# metal EM: mA/u
	# VIA EM: mA/via
	#<metal_in_lef>		<EM>	<EM_Adjust>
	MET1	22	0.66
	MET2	22	0.67

