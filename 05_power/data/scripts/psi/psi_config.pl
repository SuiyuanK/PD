#!/usr/bin/perl

$| = 1;

&main;

exit(0);

package main;

sub main
{
  my $flag = 0;
  my $case = "default";
  my $gsrFile = undef;
  my $aplFile = undef;
  my $templateFile = undef;
  my $outFile = undef;
  my %lib_inc = ();
  my %LEFPGPin = ();
  my %LEFPG2SPI = ();
  my @vdd_list = ();
  my @gnd_list = ();
  my @pg_list = ();
  my @gsr_vdd_list = ();
  my @gsr_gnd_list = ();
  my @spfFile = ();
  my @staFile = ();
  my @spiceFile = ();

  while (@ARGV) {
    $argm = shift @ARGV;
    if ($argm =~ /-?help/) {
      &showUsage(1);
    }
    elsif ($argm =~ /-gsr/) {
      $gsrFile = shift @ARGV;
    }
    elsif ($argm =~ /-apl/) {
      $aplFile = shift @ARGV;
    }
    elsif ($argm =~ /-template/) {
      $templateFile = shift @ARGV;
    }
    elsif ($argm =~ /-out/) {
      $outFile = shift @ARGV;
    }
    else {
      &showUsage(1);
    }
  }

  if (!defined $gsrFile) {
    &showUsage(0);
    die "\nERROR(PSI-310): -gsr option is not specified!\n\n";
  }
  elsif (! -e $gsrFile) {
    die "\nERROR(PSI-312): Can not access RedHawk gsr file \"$gsrFile\"!\n\n";
  }

  if (!defined $aplFile) {
    &showUsage(0);
    die "\nERROR(PSI-310): -apl option is not specified!\n\n";
  }
  elsif (! -e $aplFile) {
    die "\nERROR(PSI-312): Can not access apl config file \"$aplFile\"!\n\n";
  }

  if (!defined $templateFile) {
    &showUsage(0);
    die "\nERROR(PSI-310): -template option is not specified!\n\n";
  }
  elsif (! -e $templateFile) {
    die "\nERROR(PSI-312): Can not access psi example config file \"$templateFile\"!\n\n";
  }

  if (!defined $outFile) {
    &showUsage(0);
    die "\nERROR(PSI-310): -out option is not specified!\n\n";
  }
  
  if (!open(GSR, $gsrFile)) {
    die "\nERROR(PSI-312): Can not open RedHawk gsr file \"$gsrFile\" to read!\n\n";
  }
  if (!open(APL, $aplFile)) {
    die "\nERROR(PSI-312): Can not open apl config file \"$aplFile\" to read!\n\n";
  }
  if (!open(CFG, $templateFile)) {
    die "\nERROR(PSI-312): Can not open old psi config file \"$templateFile\" to read!\n\n";
  }
  if (!open(OUT, ">$outFile")) {
    die "\nERROR(PSI-313): Can not open new psi config file \"$outFile\" to write!\n\n";
  }

  while(<GSR>){
    if ($_ =~ /^\s*\#/) {
      next;
    }
    $_ =~ s/^\s*//g;
    @token = split(/\s+/,$_);
    if ($token[0] eq "INPUT_TRANSITION") {
      $value = $token[1];
      $value =~ s/s$//;
      if ($value =~ /f$/) {
        $scale = 1e-6;
      }
      elsif ($value =~ /p$/) {
        $scale = 1e-3;
      }
      elsif ($value =~ /n$/) {
        $scale = 1;
      }
      elsif ($value =~ /u$/) {
        $scale = 1e3;
      }
      elsif ($value =~ /m$/) {
        $scale = 1e6;
      }
      else {
        $scale = 1e9
      }
      $value =~ s/[fpnum]$//;

      $slew = $value*$scale;
      $variable{"RISE_SLOPE"} = $slew;
      $variable{"FALL_SLOPE"} = $slew;
      $variable{"RISE_SLOPE_AGRS"} = $slew;
      $variable{"FALL_SLOPE_AGRS"} = $slew;
      print "[INFO] Input Slew = $slew ns\n";
    }
    elsif ($token[0] eq "BUS_DELIMITER") {
      shift @token;
      $variable{"SPF_BUS_DELIMITER"} = "@token";
    }
    elsif ($token[0] eq "BUS_DELIMITER_STA") {
      shift @token;
      $variable{"STA_BUS_DELIMITER"} = "@token";
    }
    elsif ($token[0] eq "PIN_DELIMITER") {
      shift @token;
      $variable{"SPF_PIN_DELIMITER"} = "@token";
    }
    elsif ($token[0] eq "PIN_DELIMITER_STA") {
      shift @token;
      $variable{"STA_PIN_DELIMITER"} = "@token";
    }
    elsif ($token[0] eq "HIER_DIVIDER") {
      shift @token;
      $variable{"SPF_HIER_DIVIDER"} = "@token";
    }
    elsif ($token[0] eq "HIER_DIVIDER_STA") {
      shift @token;
      $variable{"STA_HIER_DIVIDER"} = "@token";
    }
    elsif ($token[0] =~ /^VDD_NETS$/i) {
      while (<GSR>) {
        if ($_ =~ /^\s*\#/) {
          next;
        }
        my ($nextLine) = $_;
        if ($_ =~ /{/) {
          next;
        }
        $_ =~ s/^\s*//g;
        chomp($_);
        @token = split(/\s+/,$_);
        if ($#token == 0 && $token[0] !~ /^}$/) {
          print "ERROR(PSI-310): No Voltage Settng in VDD_NETS \"$nextLine\" of GSR!\n";
        }
        elsif ($#token == 1) {
          push(@gsr_vdd_list, $token[0]);
          $LEFPGPin{"$token[0]"} = $token[1];
        }
        if ($nextLine =~ /}/) {
          last;
        }
      }
    }
    elsif ($token[0] =~ /^GND_NETS$/i) {
      while(<GSR>) {
        if ($_ =~ /^\s*\#/) {
          next;
        }
        my ($nextLine) = $_;
        if ($_ =~ /{/) {
          next;
        }
        $_ =~ s/^\s*//g;
        chomp($_);
        @token = split(/\s+/,$_);
        if ($#token == 0 && $token[0] !~ /^}$/) {
          print "ERROR(PSI-310): No Voltage Settng GND_NETS \"$nexLine\" of GSR!\n";
        }
        elsif ($#token == 1) {
          push(@gsr_gnd_list, $token[0]);
          $LEFPGPin{"$token[0]"} = $token[1];
        }
        if ($nextLine =~ /}/) {
          last;
        }
      }
    }
    elsif ($token[0] =~ /^\s*CELL_RC_FILE\s*({)?/i) {
      while (<GSR>) {
        $nextLine = $_;
        if ($_ =~ /^\s*\#/) {
          next;
        }
        $_ =~ s/^\s*//g;
        @token = split(/\s+/);
        if ($#token == 1) {
          if ($token[0] !~ /^EXTRACT_C1_R_C2$/i &&
              $token[0] !~ /^EXTRACT_RC$/i &&
	      $token[0] !~ /^CONDITION$/i) {
            if (! -e $token[1]) {
              print "ERROR(PSI-312): Can not access CELL_RC_FILE file \"$token[1]\"! Please check file path.\n";
              exit(2);
            }
            push(@spfFile, $token[1]);            
          }
        }
        if ($nextLine =~ /}\s*$/) {
          last;
        }
      }
      if (scalar(@spfFile) > 1) {
        print "WARNING(PSI-220): Design is using Hierarchical SPF flow! Please use \"setup psiwinder -dir <dir_name>\" to generate hier spef header file.\n";
        @spfFile = ();
      }
    }
    elsif ($token[0] =~ /^\s*STA_FILE\s*({)?/i) {
      while (<GSR>) {
        $nextLine = $_;
        if ($_ =~ /^\s*\#/) {
          next;
        }
        $_ =~ s/^\s*//g;
        @token = split(/\s+/);
        if ($#token == 1) {
          if ($token[0] !~ /^FREQ_OF_MISSING_INSTANCES$/i &&
              $token[0] !~ /^EXTRACT_CLOCK_NETWORK$/i) {
            if (! -e $token[1]) {
              print "ERROR(PSI-312): Can not access STA_FILE file \"$token[1]\"! Please check file path.\n";
              exit(2);
            }
            push(@staFile, $token[1]);
          }
        }
        if ($nextLine =~ /}\s*$/) {
          last;
        }
      }
    }
  }
  close(GSR);

  my ($cornerScope) = 0;
  while(<APL>) {
    my ($nextLine) = $_;
    if ($_ =~ /^\s*\#/) {
      next;
    }
    $_ =~ s/^\s*//g;
    @token = split(/\s+/);
    if ($token[0] =~ /^\s*DESIGN_CORNER/i) {
      if ($#token == 1 && $token[1] eq "{") {
        $cornerScope = 1;
      }
      my ($caseScope) = 0;
      my ($caseName) = "";
      my ($process) = "";
      my ($caseNum) = 0;
      while (<APL>) {
        $nextLine = $_;
        if ($_ =~ /^\s*\#/) {
          next;
        }
        $_ =~ s/^\s*//g;
        @token = split(/\s+/);
        if ($_ =~ /{\s*$/) { 
	  if ($cornerScope) {
            if (!$caseScope) {
              $caseScope = 1;
              $caseNum++;
              if ($#token == 1) {
                $caseName = $token[0];
              }
              else {
                $caseName = "case" . $caseNum;
              }
            }
            else {
              print "ERROR(PSI-320): syntax error at line \"$nextLine\" inside DESIGN_CORNER!\n";
	      exit(2);
            }
          }
          else {
            $cornerScope = 1;
          }
        }
        if (!$cornerScope) {
          last;
        }
        if (!$caseScope) {
          if ($#token == 0 && $token[0] eq "}") {
            last;
          }
          next;
        }
        if ($#token == 1 && $token[0] =~ /^\s*PROCESS$/i) {
          $process = $token[1];
        }
        elsif ($#token == 2 &&
               ($token[0] =~ /\s*DEVICE_MODEL_LIBRARY$/i ||
                $token[0] =~ /\s*MODEL$/i ||
                $token[0] =~ /\s*LIB_ENTRY$/i)) {
          if (! -e $token[1]) {
            print "ERROR(PSI-312): Can not access APL DEVICE_MODEL_LIBRARY file \"$token[1]\"! Please check file path.\n";
            exit(2);
          }
          $lib_inc{$caseName} .= "    .lib '$token[1]' $token[2]\n";
        }
        elsif ($#token == 1 && $token[0] =~ /^\s*INC(LUDE)?$/i) {
          if (! -e $token[1]) {
            print "ERROR(PSI-312): Can not access APL DEVICE_MODEL_LIBRARY file \"$token[1]\"! Please check file path.\n";
            exit(2);
          }
          $lib_inc{$caseName} .= "    .inc '$token[1]'\n";
        }
        elsif ($#token == 1 && $token[0] =~ /^\s*TEMP(ERATURE)?$/i) {
          $lib_inc{$caseName} .= "    .temperature $token[1]\n";
          print "INFO: Corner $caseName Temperature = $token[1]\n";
        }

        if ($_ =~ /}\s*$/) {
          if ($caseScope) {
            $caseScope = 0;
            $caseName = "";
          }
          else {
            $cornerScope = 0;
            last;
          }
        }
        if ($_ =~ /}.*}\s*$/) {
          $cornerScope = 0;
          last;
        }
      }
      next;
    }
    if ($#token == 1 && $token[0] =~ /^\s*PROCESS$/i) {
      $case = $token[1];
    }
    elsif ($#token == 2 &&
	   ($token[0] =~ /\s*DEVICE_MODEL_LIBRARY$/i ||
	    $token[0] =~ /\s*MODEL$/i ||
	    $token[0] =~ /\s*LIB_ENTRY$/i)) {
      if (! -e $token[1]) {
        print "ERROR(PSI-312): Can not access APL DEVICE_MODEL_LIBRARY file \"$token[1]\"! Please check file path.\n";
        exit(2);
      }
      $lib_inc{$case} .= "    .lib '$token[1]' $token[2]\n";
    }
    elsif ($#token == 1 && $token[0] =~ /^\s*INC(LUDE)?$/i) {
      if (! -e $token[1]) {
        print "ERROR(PSI-312): Can not access APL DEVICE_MODEL_LIBRARY file \"$token[1]\"! Please check file path.\n";
        exit(2);
      }
      $lib_inc{$case} .= "    .inc '$token[1]'\n";
    }
    elsif ($#token == 1 && $token[0] =~ /^\s*TEMP(ERATURE)?$/i) {
      $temperature = $token[1];
      print "INFO: Temperature = $temperature\n";
    }
    elsif($nextLine =~ /^\s*(\S+)_PIN_NAME\s+(.*)$/i || $nextLine =~ /^\s*(\S+)_NAME\s+(.*)$/i) {
      my ($pgPin) = $1;
      my ($spi_pin_list) = $2;
      my (@spi_pin_array) = split(" ", $spi_pin_list);
      foreach $spi_pin (@spi_pin_array) {
        push(@pg_list, $spi_pin);
        $LEFPG2SPI{$spi_pin} = $pgPin;
      }
    }
    elsif ($#token == 1 && ($token[0] =~ /^\s*SUBCKT/i || $token[0] =~ /^\s*SPICE_NETLIST/i)) {
      if (! -e $token[1]) {
        print "ERROR(PSI-312): Can not access APL $token[0] file \"$token[1]\"! Please check file path.\n";
        exit(2);
      }
      push(@spiceFile, $token[1]);
    }
    elsif($#token == 1 && $nextLine =~ /^\s*(\S+)\s+(\S+)\s*$/){
      my ($pgPin) = $1;
      my ($volt) = $2;
      $LEFPGPin{$pgPin} = $volt;
    }
  }
  close(APL);

  foreach $spi_pin (@pg_list) {
    if (defined $LEFPG2SPI{$spi_pin}) {
      my ($pgPin) = $LEFPG2SPI{$spi_pin};
      if (defined $LEFPGPin{$pgPin}) {
        my ($volt) = sprintf "%.3f", $LEFPGPin{$pgPin};
        print "[INFO] LEF PG Pin \"$pgPin\" maps to SPICE PG port \"$spi_pin\" with Voltage = $volt\n";
        $voltage{$spi_pin} = $volt;
        if ($volt > 0) {
          push(@vdd_list, $spi_pin);
        }
        else {
          push(@gnd_list, $spi_pin);
        }
      }
      elsif ($pgPin eq "GND") {
        print "[INFO] LEF PG Pin \"$pgPin\" maps to SPICE PG port \"$spi_pin\" with Voltage = 0\n";
        $voltage{$spi_pin} = 0;
        push(@gnd_list, $spi_pin);
      }
    }
  }

  print OUT "#| PsiWinder Config File:\n";
  print OUT "#| -----------------------------------------------------------\n";
  print OUT "\n";

  while(<CFG>){
    @token = split(/\s+/,$_);
    if ($token[0] eq "*Section") {
      $flag = 0;
      shift @token;
      print OUT "\n# --- @token --- #\n\n";
    }
    elsif ($token[0] eq "*Syntax") {
      $flag = 1;
      print OUT "##################################################################\n";
      print OUT "## \n";
      print OUT "## SYNTAX:\n";
      print OUT "## \n";
    }
    elsif($token[0] eq "*Example"){
      $flag = 2;
      print OUT "## Please Modify the Following Example to Fit Your Case !!!\n";
    }
    elsif($token[0] eq "*Add"){
      if($token[1] eq "DEFINE_LIBRARY_INCLUDE"){
        print OUT "DEFINE_LIBRARY_INCLUDE\n{\n";
        foreach $key (keys(%lib_inc)){
          print OUT "  include $key\n";
          print OUT "$lib_inc{$key}";
          print OUT "  endinclude\n";
        }
        if (!defined $lib_inc{"default"}) {
          foreach $key (keys(%lib_inc)){
            print OUT "  include default\n";
            print OUT "$lib_inc{$key}";
            print OUT "  endinclude\n";
            last;
          }
        }
        print OUT "}\n";
      }
    }
    elsif($token[0] eq "*Info"){
      shift @token;
      print "[INFO] @token\n";
    }
    elsif($token[0] eq "*Must"){
      print OUT "## Must Have Setting\n";
      $user_setting = "";
      $flag = 3;
    }
    elsif($token[0] eq "*Optional"){
      print OUT "## Optional Setting\n";
      $user_setting = "";
      $flag = 4;
    }
    elsif($token[0] eq "*End"){
      if($flag == 1){
        print OUT "## \n";
        print OUT "##################################################################\n\n";
      }
      else{
        print OUT "\n";
      }
      $flag = 0;
      if($user_setting ne ""){
        print OUT "\n## User Setting Derived from GSR or APL Configuration File\n";
        print OUT "$user_setting\n";
      }
    }
    elsif($flag == 1){
      print OUT "##   $_";
    }
    elsif($flag == 2){
      my $line = $_;
      if ($_ =~ /^\#SPF_FILE\s+/i && scalar(@spfFile) == 1) {
        print OUT "SPF_FILE  @spfFile[0]\n";
      }
      elsif ($_ =~ /^\#STA_FILE\s+/i && scalar(@staFile) == 1) {
        print OUT "STA_FILE  @staFile[0]\n";
      }
      elsif ($_ =~ /^\#SPICE_NETLIST_FILE\s+/i && scalar(@spiceFile) > 0) {
         $_ = (<CFG>);
         $_ = (<CFG>);
         $_ = (<CFG>);
         print OUT "SPICE_NETLIST_FILE\n";
         print OUT "{\n";
         foreach (@spiceFile) {
           print OUT "  $_\n";
         }
         print OUT "}\n";
      }
      else {
        print OUT "$line";
      }
    }
    elsif($flag == 3){
      # print OUT "#$_";
      @token = split(/\s+/,$_);
      if($token[0] eq "*VDD_NETS"){
        if(@vdd_list == 0){
          print "ERROR(PSI-320): Can NOT get VDD_NETS setting in GSR configuration file.\n";
        }
        else{
          $user_setting .= "VDD_NETS\n";
	  $user_setting .= "{\n";
          for($i=0; $i<=$#vdd_list; $i++){ 
            $user_setting .= "  $vdd_list[$i] $voltage{$vdd_list[$i]}\n";
          }
	  $user_setting .= "}\n";
        }
      }
      elsif($token[0] eq "*GND_NETS"){
        if(@gnd_list == 0){
          print "ERROR(PSI-320): Can NOT get GND_NETS setting in GSR configuration file.\n";
        }
        else{
	  $user_setting .= "GND_NETS\n";
	  $user_setting .= "{\n";
          for($i=0; $i<=$#gnd_list; $i++){ 
            $user_setting .= "  $gnd_list[$i] $voltage{$gnd_list[$i]}\n";
          }
          $user_setting .= "}\n";
        }
      }
      elsif($token[0] eq "*TEMPERATURE"){
        if(not defined $temperature){
          print "ERROR(PSI-320): Can NOT get TEMPERATURE setting in APL configuration file.\n";
        }
        else{
          $user_setting .= "TEMPERATURE $temperature\n";
        }
      }
      else{}
    }
    elsif($flag == 4){
      print OUT "#$_";
      @token = split(/\s+/,$_);
      if(exists $variable{"$token[0]"}){
        $user_setting .= "$token[0] $variable{\"$token[0]\"}\n";
      }
    }
  }
  close(CFG);
  close(OUT);
  print "[INFO] Generate psi config file to \"$outFile\"\n";
}

sub showUsage
{
  my ($quit) = @_;
  print "Generate psiwinder configuration file\n\n";
  print "Usage: perl psi_config.pl -gsr <rh_gsr_file> -apl <apl_conf_file>\n";
  print "       -template <psi_cfg_temp> -out <new_psi_cfg_file>\n";
  print "Example : perl psi_config.pl -gsr .apache/apache.gsr -apl APL/apl.config\n";
  print "          -template cfg.template -out psi.config\n";
  if ($quit) { 
    exit(0);
  }
}

