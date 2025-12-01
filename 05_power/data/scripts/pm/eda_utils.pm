# $Revision: 1.12 $

# Revision history
# Rev 1.11c1 by Chester
# Fix bug, support multi vcd file in BLOCK_VCD_FILE section 
# Rev 1.11 by Vinayakam
# - Commented out removal of comma in edaConvert2List function
# Rev 1.10 by Vinayakam
# - Added support for start brace in new line for a *_FILE* keyword in parseGSR function
# Rev 1.8
# - Made parseGSR function more robust
# Rev 1.7
# - Added parseGSR and mergeGSR functions
# Rev 1.5
# - Fixed bug preventing correct extraction of design name from STA 
# Rev 1.4
# - reading zipped files through 'less' didn't work on Solaris
#   edaOpenFile uses gunzip -c from now on
# Rev 1.3
# - Adding functions edaGetOptions and edaGenerateApl
# Rev 1.2
# - edaOpenFile can read zipped file by piping from 'less'

############################################################################
# This file contains a bunch of perl routines which can be used in all
# kinds of EDA flows
# All major functions should have prefix "eda"
#
# At the beginning of your perl script, put
#  push(@INC,split(":",<full_path_to_dir_with_eda_utils.pl>));
#   or if your script resides in the same dir with eda_utils.pl
#  push(@INC,dirname($0));
# require "eda_utils.pl";
#
# Current list of functions:
# General
#  edaGetOptions
#  edaGetScriptRevision
#  edaSortHashByValue
#  edaInArray
#  edaCleanLine
#  edaUniqArray
#  edaConvert2List
#  edaPrintHash
# For building flows
#  edaError
#  edaGrepLog
#  edaExecute
#  edaCommandStackLoop
#  edaCommandStack
#  edaMsg
#  edaGetDate
# For handling files
#  edaRemoveFiles
#  edaCreateDirs
#  edaCopyFiles
#  edaLinkFiles
#  edaMoveFile
#  edaCheckInputFiles
#  edaCheckOutputFiles
#  edaAreFileTimeStampsInSequence
#  edaOpenFile
#  edaPrependDirToFileList
#  edaGetFileNames
#  edaConvertToAbsolutePath
# DEF - related
#  edaDumpDefHash
#  edaParseDefFile
#  edaAdjustDefRows
#  edaAdjustDefTracks
#  edaMergeDefSections
#  edaGetDefDesignName
# Verilog - related
#  edaParseVerilogFiles
#  edaFindReferencedModules
#  edaFindAllMasterNames
#  edaDumpVerilogHash
# LEF - related
#  edaCreateMacroHashFromLefFiles
#  edaProcessLefMacro
#  edaParseLefFiles
# SPEF/DSPF - related
#  edaGetSpfDesignName
# GSR - related
# Misc
#  edaGenerateApl
#  edaDoSegmentsCross
##########################################################################
use File::Path;
use File::Basename;
#============================================================
# General  routines
#============================================================
sub min {
  my $a = shift(@_);
  my $b = shift(@_);

  if ($a < $b) {
    return $a;
  } else {
    return $b;
  }
}

# This is my own version of argument processing. It accepts multiple values per flag
# and also can expand incomplete flag is unambiguous (ex. -def => -def_files)
# %VarHash is a being populated like this: $VarHash{def_file} = "a.def b.def .... z.def"
# @VarNamesList is optional list of all legal variables
# Example:
# @VarNamesList = ("help","block_name","lef_files","ploc_file","on_layers");
# edaGetOptions(\@ARGV,\%VarHash,\@VarNamesList);
sub edaGetOptions {
  my(@MatchingVars,$arg,$var_name,$legal_var);

  my $ArgRef = shift(@_);
  my @Args = @{$ArgRef};

  my $VarHashRef = shift(@_);
  my $VarListRef = shift(@_);

  while (@Args) {
    $arg = shift(@Args);
# 1. If current argument starts with "-", it's a name of the variable
    if ($arg =~ m/^-/) {
      ($var_name = $arg) =~ s/^-//;

# Flags may be incomplete, for ex: -vdd_n -> -vdd_nets
      @MatchingVars = ();
      foreach $legal_var (@$VarListRef) {
        if ($legal_var =~ m/^$var_name/) {
          push(@MatchingVars,$legal_var)
        }
      }

      if ($#MatchingVars < 0) {
        edaError("Flag $arg is illegal!");
      } elsif ($#MatchingVars > 0) {
        edaError("Flag $arg is ambiguous: matches '@MatchingVars'");
      }

# If there is only one matching legal flag - OK
      $var_name = shift(@MatchingVars);
# Reset the value of the new argument
      $VarHashRef->{$var_name} = "";
      next;
    }

# 2. If argument doesn't start with "-" - it's a value
# start new record in $VarHash or append if such already exists
    if ($VarHashRef->{$var_name} eq "") {
      $VarHashRef->{$var_name} = $arg;
    } else {
      $VarHashRef->{$var_name} .= " $arg";
    }
  }
}


# This function accepts 2 segment (8 coordinates) and returns (x,y) coordinates
# of intersection or -1 if don't cross
# Segements can be given in def notation: ( 215050 34080  218960 * )
# Segments can on;y be horizontal or vertical
# ex: $status = edaDoSegmentsCross(0,1,10,1, 9,0,"*",0.9);
sub edaDoSegmentsCross {
  my ($seg_id,$x1_hor,$x2_hor,$y_hor,$x_ver,$y1_ver,$y2_ver);
  my %S1 = ();
  my %S2 = ();
  $S{1,x1} = shift(@_);
  $S{1,y1} = shift(@_);
  $S{1,x2} = shift(@_);
  $S{1,y2} = shift(@_);

  $S{2,x1} = shift(@_);
  $S{2,y1} = shift(@_);
  $S{2,x2} = shift(@_);
  $S{2,y2} = shift(@_);

# Determine the orientation 
  foreach $seg_id ("1", "2") {
    if (($S{$seg_id,x2} eq "*") || ($S{$seg_id,x1} == $S{$seg_id,x2})) {
      $S{$seg_id,orient} = "ver";
    } elsif (($S{$seg_id,y2} eq "*") || ($S{$seg_id,y1} == $S{$seg_id,y2})) {
      $S{$seg_id,orient} = "hor";
    } else {
      edaError("Segment $S{$seg_id,x1} $S{$seg_id,y1}) ($S{$seg_id,x2} $S{$seg_id,y2}) is illegal!");
      return(-1); 
    }

#print "($S{$seg_id,x1} $S{$seg_id,y1}) ($S{$seg_id,x2} $S{$seg_id,y2}) - $S{$seg_id,orient}\n";
  }

# If both segments are horizontal or vertical - they cant intersect
  if ($S{1,orient} eq $S{2,orient}) {
    return -1;
  }

# Copy coords to one vertical and one horisontal data triplet
  if ($S{1,orient} eq "hor") {
    $x1_hor = $S{1,x1};
    $x2_hor = $S{1,x2};
    $y_hor = $S{1,y1};

    $x_ver = $S{2,x1};
    $y1_ver = $S{2,y1};
    $y2_ver = $S{2,y2};
  } else {
    $x1_hor = $S{2,x1};
    $x2_hor = $S{2,x2};
    $y_hor = $S{2,y1};

    $x_ver = $S{1,x1};
    $y1_ver = $S{1,y1};
    $y2_ver = $S{1,y2};
  }

# Finally intersection test
  if ((($x1_hor <= $x_ver) && ($x_ver <= $x2_hor)) &&
      (($y1_ver <= $y_hor) && ($y_hor <= $y2_ver))) {
    return ($x_ver,$y_hor);
  }

  return -1;

}

# Extract and return the revision of the script
sub edaGetScriptRevision {
  $script = $_[0];
  edaOpenFile(SCR, "$script", "r");
  while (<SCR>) {
    chomp();
    if ($_ =~ s/^# \$Revision: //) {	
      $_ =~ s/\s.*$//;
    return $_;
  }
  }
  edaMsg("Can't extract version information from '$script'", "W");
  return "NA";
  close SCR;
}


# Two following functions are a bundle - don't separate them!
# Main function 'sortHashByValue' accepts a reference to a hash and 
# returns array of indexes, after sorting values  
# Usage: sortHashByValue(\%HashName) [inc/dec]
# * Call by reference 
sub byvalue {$LocalHash{$a} <=> $LocalHash{$b};}
sub edaSortHashByValue {
  $hash_ref = $_[0];
  $inc_or_dec = $_[1];

  *LocalHash = $hash_ref;
  @Indexes = sort byvalue (keys %LocalHash);

  if ($inc_or_dec eq "inc") {
    return @Indexes;
  } else {
    return reverse @Indexes;
  }
} 

# Prints hash to a text file - may be hash of hashes of hashes ...
# It can be loaded with a simple "require" command 
# Usage: edaPrintHash(\%HashName)
sub edaPrintHash {
  my($key,$buf,$indent,$hash_ref,$level,$LocalHash,$i,$n,$tmpval);
  $hash_ref = shift(@_);
  if (@_) {
    $level = shift(@_);
  } else {
    $level = 0;
  }

  *LocalHash = $hash_ref;

  if ($level == 0) {$buf = "(\n"};
  $i = $level*4+4;
#  $indent = sprintf("%-$i","");
  $indent = "";
  for ($n = 0 ; $n < $i ; $n++) {
    $indent .= " " ;
  }
  foreach $key (sort keys(%{$hash_ref})) {
    $tmpval = "";
    $tmpval .= ${$hash_ref}{$key};
#    if (${$hash_ref}{$key} =~ m/^HASH\(.*\)$/) {
  if ($tmpval =~ m/^HASH\(.*\)$/) {
#      print "Sub-Hash found. Recursing ... \n";
    $buf .= $indent . "$key => {\n" ;
    $buf .= edaPrintHash(\%{${$hash_ref}{$key}}, $level+1);
    $buf .= $indent . "\},\n" ;
  } else {
    $buf .= $indent . "$key => \"${$hash_ref}{$key}\",\n" ;
  }
}
if ($level == 0) {$buf .= ");\n"};
return $buf;
}

# Function returns index of the element who is equal to given string
# -1 returned if element is not found  
# Usage: edaInArray(<string>,\@Arr);  - Array is passed by reference 
sub edaInArray {
  my $elem = shift(@_);
  my $arr_ref = shift(@_);

  my $len = $#$arr_ref;
  my $i;

  for ($i=0;$i<=$len;$i++) {
    if ($elem eq @$arr_ref[$i]) {
      return $i;
    }
  }
  return -1;
}

# Function removes newlines, replaces tabs with spaces, remove leading, 
# trailing and multiple spaces
sub edaCleanLine {
  my $line = shift(@_);
  $line =~ s/\n/ /g;
  $line =~ s/\t/ /g;
  $line =~ s/^\s*//;
  $line =~ s/\s*$//;
  $line =~ s/\s+/ /g;

  return $line;
}

# This function accepts array and returns a new one without duplicate elements
# Ex: @NewArr = edaUniqArray(@OldArr);
sub edaUniqArray {
  my %Hash = ();
  my $item;

  foreach $item (@_) {
    $Hash{$item} = 1;
  }

  return(keys(%Hash));
} 


#This function converts list with composite elements to list with
# simple elements, like: ("a,b","c","d  e") => ("a',"b","c","d","e")   
sub edaConvert2List {
  local($my_str) = join(" ",@_);

#  $my_str =~ s/,/ /g;
  $my_str =~ s/\n/ /g;
  $my_str =~ s/\s+/ /g;

  return(split(" ",$my_str));
}

# Functions issues error message, then gracefully abort the flow
# Usage: edaError <message>
sub edaError {
  my $err_msg = shift(@_);
  my $step_status;
  edaMsg("$err_msg","E");

# If we are not running from within the flow, just quit
  exit(-1);

  $date = edaGetDate();

  edaMsg("------------------------------------------------------\nstep '$step_name' failed at $date\n------------------------------------------------------");
  push(@edaStepsStatus,"step '$step_name' failed at $date");
  edaMsg("=============================================================");
  edaMsg("Summary for flow '$edaFlowName' (started at $flow_started_at)");
  edaMsg("=============================================================");
  foreach $step_status (@edaStepsStatus) {
    edaMsg("$step_status");
  }
  edaMsg("=============================================================");

  exit(-1);
}

# This function look if error message is found in the log   
# Usage:  edaGrepLog <log_file> <string_to_search>
sub edaGrepLog {
  my $log_file = shift(@_);
  my(@Strings2Search,$string2search); 

  while (@_) {
    if ($_[0] eq "-must_be_in_file") {
      $must_be_in_file = 1;
    } else {
      push(@Strings2Search,$_[0]);
    }
    shift(@_);
  }

  edaMsg("Checking '$log_file' for '@Strings2Search'...","I");

  edaOpenFile(LOG, "$log_file", "r");
  while(<LOG>) {
    foreach $string2search (@Strings2Search) {
      if ($_ =~ m/$string2search/) {
        edaError("String '$string2search' found in $log_file!");
      }
    }
  }

  close LOG;

  edaMsg("'$log_file' is clean","I");
  return1
}

# Usage: edaExecute <command> {options]
# The function executes given UNIX command. 
# * Don't use this function if you send your command to another 
#   host for execution 
  sub edaExecute {
    my $command = shift(@_);
    my $option;
    my $parallel = 0;
    my $quiet = 0;
    my $silent = 0;
    my $background = 0;

    foreach $option (@_) {
      if ($option eq "-silent") {
        $silent = 1;
      } elsif ($option eq "-bg") {
        $background = 1;
      }
      elsif ($option eq "-parallel") {
        $parallel = 1;
      }
    }

    if ($edaNoRun) {
      edaMsg("Norun mode. Skipping '$command'...","W");
      return 1;
    }

    if ($parallel) {
      edaMsg("Scheduling '$command' for remote execution...","I");
      edaCommandStack("-push",$command);
      return 1;
    }


    edaMsg("Executing '$command'","I");


    if ($background) {
      system("$command &");
      return 1;
    }

    if (!(open COMMAND, "$command |")) {
      edaError("Can't execute '$command'!");
      return 0;
    }

# Wait until output stream is exhausted
    while (<COMMAND>) {
      if (!$silent) {
        print $_;
      }
    }

    close COMMAND;

    return 1;
  }

# This functions just polls command stack until all jobs are executed
# (or until the timeout)
# Usage: edaCommandStackLoop -pollInterval <seconds> -timeOut <seconds>
  sub edaCommandStackLoop {
    my($host_list);
    @myargs = edaConvert2List(shift(@_));
    while (@myargs){
      $flag   = shift(@myargs);  
      if($flag eq "-pollInterval"){
        $pollInterval = shift(@myargs);
      } elsif($flag eq "-timeOut"){
        $timeOut = shift(@myargs);
      } else {
        edaMsg("Flag '$flag' is illegal! Aborting...\n","E");
        exit -1;
      }
    }

    $host_list = join(" ",@glbHostList);
    print JNL "==================================================
      Available hosts:   $host_list
      Max CPU load:      $glbMaxCpuLoad
      Max jobs per host: $glbMaxJobsPerHost
      Poll interval:     $pollInterval sec
      Time out:          $timeOut sec
      =====================================================\n";

    if (($pollInterval eq "") || ($timeOut eq "")) {
      edaMsg("Polling interval and time out must be defined!","E");
      exit -1;
    }



    edaMsg("Starting execution of the command stack ($CommandQueue{last_id} jobs)","I");
    my $timer = 0;
    while (edaCommandStack("-poll") > 0) {
      if ($timer > $timeOut) {
        edaMsg("Timeout of $edaCommandStackTimeout seconds reached!","E");
        exit -1; 
      }
      sleep($pollInterval);
      $timer += $pollInterval;
    }

    return 1;
  }

#========================================================================
# This is a command dispatcher
# Usage:
#  1) edaCommandStack("-setHostList","hostname1 num_of_cpus hostname2 num_of_cpus ...")
#     If this command wasn't used - only current host is available
#  2) edaCommandStack("-setMaxCpuLoad",<number>)
#  3) edaCommandStack("-reset")  - completely cleares command stack. 
#     Should be used with caution since processes may still run on other machines
#  4) edaCommandStack("-push","command") - schedules command for the execution
#  5) edaCommandStack("-poll") - checks the status of the queue, find available
#     unloaded machines and sends jobs to them. 
#     Returns number of non-completed commands
#
# All variables which should "live" beyound one invocation of the function 
# have prefix "glb"
#======================================================================
  sub edaCommandStack {
    my($id,$command,$host,@IdleHosts,@WaitingCommands,$truncated_cmd_name);
    my $operation = shift(@_);


#============================================================
# (2) Reset command stack
#============================================================
    if ($operation eq "-reset") {
      %CommandQueue = {};
      $CommandQueue{last_id} = 0;
      edaRemoveFiles("*.completed");
      edaRemoveFiles("*.running");
      edaRemoveFiles("*.stdout");
      edaRemoveFiles("command_stack.jnl");
      edaOpenFile(JNL, "command_stack.jnl", "w");

# Set defaults
      edaCommandStack("-setHostList",`hostname`);
      edaCommandStack("-setMaxCpuLoad",1);
      edaCommandStack("-setMaxJobsPerHost",2);

      return 1;    
    }

#===============================================================
# Set list of hosts, max cpu load and max number of jobs per CPU
#===============================================================
    if ($operation eq "-setHostList") {
      @glbHostList = edaConvert2List(shift(@_));
      %glbHostTable = {};
      foreach $host (@glbHostList) {
        $glbHostTable{$host,"num_of_cpus"} = `rsh -n $host /usr/sbin/psrinfo | wc -l`;

        $glbHostTable{$host,"num_of_cpus"} =~ s/\s*//;
        chomp($glbHostTable{$host,"num_of_cpus"});

        $glbHostTable{$host,"num_of_running_jobs"} = 0;
      }
      return 1;
    }  

    if ($operation eq "-setMaxCpuLoad") {
      $glbMaxCpuLoad = shift(@_);
      return 1;
    }

    if ($operation eq "-setMaxJobsPerHost") {    
      $glbMaxJobsPerHost = shift(@_);
      return 1;
    }


#============================================================
# (3) Push new command to the stack
#============================================================
    if ($operation eq "-push") {
      $command = shift(@_);
      $id = $CommandQueue{last_id} + 1;
      $CommandQueue{$id,"name"} = $command;
      $CommandQueue{$id,"status"} = "waiting";
      $CommandQueue{$id,"host"} = "";
      $CommandQueue{$id,"sent_at"} = "";
      $CommandQueue{$id,"completed_at"} = "";
      $CommandQueue{last_id} = $id;

      return 1;
    }

#============================================================
# (4) Poll command stack
#============================================================

#-------------------------------------------------------------
# a. Print a report about available machines
#-------------------------------------------------------------
    $current_time = edaGetDate();
    edaExecute("clear");
    edaMsg("\n$current_time");

    edaMsg("-----------------------------------------------------------------------");
    edaMsg(sprintf("%-12s | %s | %s | %s | %s","Host","CPUs", "Load per CPU", "running jobs","Available?"));
    edaMsg("-----------------------------------------------------------------------");

    foreach $host (@glbHostList) {        
      $host_load = `rup -l $host`;
      $host_load =~ s/^.*load average:\s*//;
      $host_load =~ s/,.*$//;

      $glbHostTable{$host,"load_per_cpu"} = $host_load / $glbHostTable{$host,"num_of_cpus"};

      if (($glbHostTable{$host,"load_per_cpu"} <= $glbMaxCpuLoad) &&
          ($glbHostTable{$host,"num_of_running_jobs"} < $glbMaxJobsPerHost)) {
        $host_available = "yes"; 
      } else {
        $host_available = "no";
      }
      edaMsg(sprintf("%-12s |  %3d |         %.2f |          %3d | %-5s ",
            $host,
            $glbHostTable{$host,"num_of_cpus"},
            $glbHostTable{$host,"load_per_cpu"},
            $glbHostTable{$host,"num_of_running_jobs"},
            $host_available
            ));

    }
    edaMsg("-----------------------------------------------------------------------");


#----------------------------------------------------------------
# b. Get and print command queue status
#----------------------------------------------------------------

    edaMsg("----------------------------------------------------------------------------------------------------------------------");
    edaMsg(sprintf("%2s | %-61s| %-9s | %-8s | %-15s | %-15s","ID","Command","Status","Host","Sent at","Completed at"));
    edaMsg("----------------------------------------------------------------------------------------------------------------------");
    for ($id = 1; $id <= $CommandQueue{last_id}; $id++) {

# If "completed" file found - change status to completed and release host
      if (-r "$id.completed") {
        $CommandQueue{$id,"status"} = "completed";
        if (-r "$id.running") {edaRemoveFiles("$id.running")};
        $CommandQueue{$id,"completed_at"} = edaGetDate();

# Decrement the counter of jobs currently running on this host 
        $glbHostTable{$CommandQueue{$id,"host"},"num_of_running_jobs"}--;
        edaRemoveFiles("$id.completed");
        print JNL "$current_time: $CommandQueue{$id,'name'} - COMPLETED\n";
      }

# If command is too long to fit in one line - truncate it
      if (length($CommandQueue{$id,"name"}) > 58) {
        $truncated_cmd_name = substr($CommandQueue{$id,"name"},0,58);
        $truncated_cmd_name.= "...";
      } else {
        $truncated_cmd_name = $CommandQueue{$id,"name"};
      }
      edaMsg(sprintf("%2d | %-61s| %-9s | %-8s | %15s | %15s",$id,$truncated_cmd_name,$CommandQueue{$id,"status"},$CommandQueue{$id,"host"},$CommandQueue{$id,"sent_at"},$CommandQueue{$id,"completed_at"}));

      if ($CommandQueue{$id,"status"} eq "waiting") {
        push(@WaitingCommands,$id);
      }

    }
    edaMsg("----------------------------------------------------------------------------------------------------------------------");

# If there are no commands in waiting queue - exit
# return the number of non-completed (i.e running) commands
    if ($#WaitingCommands < 0) {   
      return(edaGetNumOfNonCompletedCommands());
    }


#-----------------------------------------------------------------
# 4. Loop over all waiting commands and launch as many as there 
#    are available machines
#-----------------------------------------------------------------
    foreach $id (@WaitingCommands) {    

      $available_host = "";
      foreach $host (@glbHostList) {      
        if (($glbHostTable{$host,"load_per_cpu"} <= $glbMaxCpuLoad) &&
            ($glbHostTable{$host,"num_of_running_jobs"} < $glbMaxJobsPerHost)) {
          $available_host = $host;
          last;
        }    
      }

      if ($available_host eq "") {
        return 1;
      } 

      $host = $available_host;
      $cwd = `pwd`;
      chomp($cwd);
      print JNL "$current_time: \"$CommandQueue{$id,'name'}\" - SENT to host $host\n";
      $full_command = "rsh -n $host \"cd $cwd;($CommandQueue{$id,'name'}) >& $cwd/$id.stdout; echo $CommandQueue{$id,'name'} > $cwd/$id.completed\" &";  

# Register the command you are about to launch
      $CommandQueue{$id,"status"} = "running";
      $CommandQueue{$id,"host"} = $host;
      $CommandQueue{$id,"sent_at"} = edaGetDate();    

# Show output of each job in a separate window
      edaExecute("touch $id.stdout");
      $displacement = ($id - 1)* 25 ;
      $viewing_command = "xterm -fn fixed -bg pink -geometry 60x10-$displacement+$displacement -title \"($id) '$CommandQueue{$id,'name'}' running on '$host'\" -e tail -f $id.stdout";
#print "$viewing_command";
      edaExecute($viewing_command,"-bg","-quiet");

# This is for debug of killed or zombied commands
      system("echo \"$CommandQueue{$id,'name'} on $host\" > $id.running");
      system($full_command);

# Increment the amount of jobs running on this machine
      $glbHostTable{$host,"num_of_running_jobs"}++;

    }   


# Get and return the number of non completed commands
# When it reaches 0, edaCommandStackLoop terminates iterations

    return(edaGetNumOfNonCompletedCommands());

  }

  sub edaGetNumOfNonCompletedCommands {
    my $num_of_non_completed_commands = 0;

    for ($id = 1; $id <= $CommandQueue{last_id}; $id++) {
      if ($CommandQueue{$id,"status"} ne "completed") {
        $num_of_non_completed_commands++;
      }
    }
    return $num_of_non_completed_commands;
  }


# Use only this function for printing!
# There are 3 types of messages Info, Warning and Error
# Function looks at verbose level, set as global parameter $GLOBAL_PARMS{VerboseLevel}
# Usage: edaMsg "<text>" [I|W|E]

  sub edaMsg {
    my $msg = shift(@_);
    my %VerboseTable = (
        "dbg" => 0,
        "I" => 1,
        "W" => 2,
        "E" => 3,
        "S" => 99,
        );
# Default message type is Simple - always printed
    my $msg_type = "S";
    my $final_msg;

    if ($#_ >= 0) {
      $msg_type = shift(@_);
    }
# If message is below verbose level - don't print
    if ($VerboseTable{$msg_type} < $VerboseTable{$GLOBAL_PARMS{"VerboseLevel"}}) {
      return 0;
    }


    if ($msg_type eq "S") {
      $final_msg =  "$msg\n";
    } else {
      $final_msg = "-$msg_type- $msg\n";
    }

    print STDERR $final_msg;
  }

  sub edaGetDate {
    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    $mon =("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")[($mon)];
    $year += 1900;
    if ($hour < 10) {$hour = "0$hour";}
    if ($min < 10) {$min = "0$min";}
    if ($sec < 10) {$sec = "0$sec";}

    return("$hour:$min:$sec $mday $mon");
  }

###########################################################
# File and directory oriented functions
###########################################################

# Remove specified files (pattern may be passed) 
  sub edaRemoveFiles {
    my($file_pat,$file,@Files);    
    foreach $file_pat (edaConvert2List(@_)) {
# 1. If it's not a pattern but a file name
      if (-r $file_pat) {
        edaExecute("\\rm $file_pat","-quiet");
        next;
      }

# 2. Try file pattern match
      eval "\@Files = <$file_pat>";
      foreach $file (@Files) {
        if (! -d $file) {
          edaExecute("\\rm $file","-quiet");
        }      
      } 

    }
  }


# Check, that all specified directories exist 
# Return string of missing directories
  sub edaCheckDirStruct {
    my($dir, $MissingDirs);
    $MissingDirs = "";

    foreach $dir (edaConvert2List(@_)) {
      if (! (-d $dir)) {
        $MissingDirs .= " $dir"; 
      }
    }

    return $MissingDirs;

  }

# Create directory structure
#Usage: edaCreateDirs(<dir1>,<dir2>)
# * dirs may be in style "XX/YY" 
  sub edaCreateDirs {
    my($dir);

    foreach $dir (edaConvert2List(@_)) {
      if (! -e $dir) {
        if (! mkpath($dir,1,0777) ) {
          edaError("Can't create directory '$dir'!");
          return 0;
        } 
      } else {
        edaMsg("Directory $dir already exists...","I");
      }
    }
    return 1;
  }


# Copies or links files
# Usage: edaCopyFiles <source_files> <target_dir> [optional_args]
#   -nocheck   don't check if files exist at source and copied successfully
#   -link      symbolic link instead of copy
#   -force     copy/link file even if already exists      
  sub edaCopyFiles {
    my $from = shift(@_);
    my $to = shift(@_);
    my ($source_file, $link_files, $force, @Sources, $target_file, $basename, $dirname);

# Defaults
    $link_files = 0;
    $check_files = 1;
    $force = 0;

# Additional args
    while(@_) {
      $flag = shift;
      if ($flag eq "-nocheck") {
        $check_files = 0;
      }
      if ($flag eq "-link") {
        $link_files = 1;
      }
      if ($flag eq "-force") {
        $force = 1;
      }
    }

# Check if at least one file is there, unless user said "-nocheck"
    if ($check_files) {
      edaCheckInputFiles($from);
    }

# It can be a file pattern  
    @Sources = glob($from);
# Exit if it's empty
    if ($#Sources < 0) {
      return 0
    }

    foreach $source_file (@Sources) {    
      $basename = basename($source_file);
      $dirname = dirname($source_file);

      if (-d $to) {
        $target_file = "$to/$basename";
      } else {
        $target_file = $to;
      }

      if (-d $source_file) {
        edaMsg("$source_file is a directory - will not be copied","W");
        next;
      }


      if (-f $target_file) {
        if ($force) {
          edaMsg("File '$target_file' already exists, but WILL BE overwritten", "W");
        } else {
          edaMsg("File '$target_file' already exists, and will not overwritten", "I");
          next;
        }      
      }

      if ($link_files) {

# Can't use edaCheckOutputFiles because time stamp of the link is not updated
        edaRemoveFiles($target_file);
        edaExecute("/bin/ln -s $source_file $target_file");

        edaCheckInputFiles($target_file) if ($check_files);     
      } else {

        edaExecute("/bin/cp $source_file $target_file");
        edaCheckOutputFiles($target_file) if ($check_files);
      }

    }

    return 1;
  }


# Just call edaCopyFiles
  sub edaLinkFiles {    
    edaCopyFiles(@_,"-link");
    return 1;
  }

  sub edaMoveFile {
    my $orig_file = shift(@_);
    my $new_file = shift(@_);
    if(!edaExecute("/bin/mv $orig_file $new_file")) {
      edaMsg("Can't move file '$orig_file' to '$new_file'","W");
      return 0;
    }
    return 1;
  }

# Check that all files exist. Return 1 if yes, 0 if at least
# one file is missign
  sub edaCheckInputFiles {
    my $status = 1;
    my(@Files,$num_of_matches);

    if ($edaNoRun) {return 1;}

    my $cwd = `pwd`;
    chomp($cwd);
    edaMsg("Checking input files in '$cwd':","I");
    foreach $file (edaConvert2List(@_)) {

# For clearer message - convert to full path (if relative path is given)  
      if (!($file =~ m/^\//)) {
        $file = "$cwd/$file";
    }

# 1) Check if this a file pattern
    if ($file =~ m/\*/) {
      eval "\@Files = <$file>";
      $num_of_matches = $#Files + 1;

      if ($num_of_matches > 0) {
        edaMsg("'$file' matches $num_of_matches files - OK","I");
      } else {
        $msg = "No files match to '$file'";
# If relative path - show $cwd
        if (!($file =~ m/\/.*/)) {
          $msg .= " in $cwd";
        }
        edaMsg("$msg","E");
        exit(-1);
      }
    } elsif (!(-r $file)) {
# 2) It's a static file name
      edaError("'$file' - doesn't exist or unreadable!\n","E");
    } else {
      edaMsg("'$file' - OK","I");
    }
    }

    return $status;
  }

# Function checks that all output files exist and they are 
# newer than the time stamp stored in $edaTimeStamp  
  sub edaCheckOutputFiles {
    my($file,@FileParms);
    my ($status) = 1;

    if ($edaNoRun) {return 1;}

    edaMsg("Checking output files:","I");
    foreach $file (edaConvert2List(@_)) {
      if (! (-r $file)) {
        edaMsg("Output file '$file' doesn't exist!","E");
        $status = 0;
        next;
      } 
      @FileParms = stat("$file");
#print "==>$edaTimeStamp > $FileParms[10]\n\n"; 
      if ($edaTimeStamp > $FileParms[10]) {
        edaMsg("Output file '$file' wasn't updated since the beginning of the step!","W");
        $status = 0;
        next;
      }
      if ($FileParms[7] == 0) {
        edaMsg("Output file '$file' has 0 size!","W");
        $status = 0;
        next;
      }
      edaMsg("'$file' - OK","I");
    }

    if (!$status) {
      edaError();
    }
    return $status;
  }

# If invoked with arguments: <file1> <file2> <file3> ...
# it will return 1 only if <file1> is older than <file2> which is older
# than <file3> ... and so forth. If time stamp sequence is broken - return 0  
  sub edaAreFileTimeStampsInSequence {  
    my($file,$file_time_stamp,$prev_file_time_stamp,$prev_file);

    $prev_file_time_stamp = -1;
    $prev_file = "";
    foreach $file (edaConvert2List(@_)) {
      if (!(-r $file)) {
        edaMsg("'$file' doesn't exist or not readable!","E");
        return 0;
      }
      $file_time_stamp = (stat("$file"))[10];    
      if ($file_time_stamp < $prev_file_time_stamp) {
        edaMsg("$prev_file in newer than $file!","W");
        return 0;
      } else {
        if ($prev_file ne "") {
          edaMsg("$file in newer than $prev_file - OK","I");
        }
      }
      $prev_file_time_stamp = $file_time_stamp;
      $prev_file = $file;
    }

    return 1;
  }

# Usage:  edaOpenFile <FILE_DESCRIPTOR> <file_name> <mode>
# modes: "r", "w", "a", "wf" (force write even if file exists) 
# Ex: edaOpenFile(MAC, file.mac, w);
  sub edaOpenFile {
    my $descr_name = shift(@_);
    my $file_name = shift(@_); 
    my $file_mode = shift(@_);
    my $str;

    if ($file_mode eq "r") {
# piping from gunzip allows reading of zipped files
      if ($file_name =~ m/\.gz$/) {
        open($descr_name,"\gunzip -c $file_name |") || edaError("Can't open file $file_name f");
      } else {
        open ($descr_name,"$file_name") || edaError("Can't open file '$file_name' for reading");
      }
      edaMsg("Reading from $file_name...","I");
    } elsif (($file_mode eq "w") || ($file_mode eq "wf")) {
      if ((-r $file_name) && ($file_mode eq "w")) {
        edaMsg("File '$file_name' exists and will not be overwritten","I");
        return 1;
      } elsif ((-r $file_name) && ($file_mode eq "wf"))  {
        edaMsg("File '$file_name' exists, but WILL BE ovewrtitten","I");
      } 
      if (!open ($descr_name,"> $file_name")) {
        edaError("Can't open file '$file_name' for writing");
      }
    } elsif ($file_mode eq "a") {
      if (!open ($descr_name,">> $file_name")) {
        edaError("Can't open file '$file_name' for appending");
      }
    } else {
      edaError("Attempt to open file '$file_name' in illegal file mode '$file_mode'!"); 
    }

    return 1;
  }

# This function returns a list of files from specified 
# directories and which match specified pattern

# Usage ex: edaGetListOfFiles("dir1 dir2 ...", "*.py")  
  sub edaGetListOfFiles {
    my @DirList = edaConvert2List(shift(@_));
    my $pattern = shift(@_);
    my $dir;
    my @FileList;
    foreach $dir (@DirList) {
      chdir($dir);
      push(@FileList,(glob($pattern)));
    }

    return @FileList;
  }


# This function accepts list of files and returns them
# as a string with given directory prepended 
# Usage: edaPrependDirToFileList($dir_string,@FileList)
  sub edaPrependDirToFileList {
    my $dir_string = shift(@_);
    my @FileList = @_;
    my $files_string = join(" $dir_string/",@FileList);
    $files_string = "$dir_string/".$files_string;

    return $files_string;
  }

# Returns list of files without directory prefix
# Usage ex: edaGetFileNames("inputs/*lef")
  sub edaGetFileNames {
    my $pattern = shift(@_);
    my ($file,@FileList); 
    foreach $file (glob($pattern)) {
      $file = basename($file);
      push(@FileList,$file);
    }
    return @FileList
  }

# Convert relative file name to an absolute one
# Usage: edaConvertToAbsolutePath(<file_name>)
  sub edaConvertToAbsolutePath {
    my $file = shift(@_);
    my($dir_name,$base_name);
    edaCheckInputFiles($file);

    $orig_dir = `pwd`;
    chomp($orig_dir);

# If passed parameter is a directory
    if (-d $file) {
      $dir_name = $file;
      $base_name = "";
    } else { 
# If it's a file
      $dir_name = dirname($file);
      $base_name = basename($file);
    }

    chdir($dir_name);
    my $cwd = `pwd`;
    chomp($cwd);

    if ($base_name eq "") {
      $abs_path = $cwd;
    } else {
      $abs_path = "$cwd/$base_name";
    }
    chdir($orig_dir);
    return $abs_path;
  }

#################################################################
#                    Backend related functions
#################################################################

# This is a global variable on purpose!
  use vars qw(@edaDefSectionTags);
  @edaDefSectionTags = ("HEADER","DIEAREA","ROW","TRACKS","GCELLGRID","VIAS","PINS","COMPONENTS","NETS","SPECIALNETS");
  use vars qw(%DefHash);

# Prints the content of the def hash to the file
# Usage: edaDumpDefHash(\%hash,<file_name>)
#   * hash is passed by reference
  sub edaDumpDefHash {
    my $hash_name = shift(@_);
    my $file = shift(@_);
    my $section;

    if (!open (DEF,"> $file")) {
      edaMsg("Can't open $file for writing!","E");
      return 0;
    }

    edaMsg("Writing DEF file '$file'\n","I");

    foreach $section (@edaDefSectionTags) {
      if (defined $$hash_name{$section}) {
        print DEF $$hash_name{$section};
      }
    }
    print DEF "END DESIGN\n";

    close DEF;

    return 1;
  }


# Extract design name from def file
  sub edaGetDefDesignName {
    my $file = shift(@_);
    edaOpenFile(DEF,$file,"r");
    while(<DEF>) {
      @Line = split(" ",$_);
      if ($Line[0] eq "DESIGN") {
        close DEF;
        return $Line[1];
      }
    }
    close DEF;
    edaError("Can't extract design name from $file!");
  }

# This function dissects given DEF file to sections and returns
# reference to hash which contains the whole def file
# Usage: *myhash = edaParseDefFile("newBlkSet23.def");
# Then to print any section just: print $myhash{<section_name>}
  sub edaParseDefFile {
    my $file = shift(@_);
#my %DefHash;
    my $section = "HEADER";
    my(%Counter,%DefSectionTagsHash,$tag,@line);

    foreach $tag (@edaDefSectionTags) {
      $Counter{$tag} = 0;
      $DefSectionTagsHash{$tag} = 1;
    }

    edaOpenFile(DEF,"$file","r");

    edaMsg("Parsing DEF file '$file'","I");

    while(<DEF>) {

# Skip empty lines
      if ($_ =~ m/^\s*$/) {
        next;
      }

# Don't read "END DESIGN" and further
      if ($_ =~ m/^END DESIGN/) {
        last;
      }

      @line = split(" ",$_);

# Look if this a beginning of section
      if (defined($DefSectionTagsHash{$line[0]})) {
        $section = $line[0];
        edaMsg("Parsing section $section","dbg");
      }

# Update the line counter of current section
      $Counter{$section}++;

# Append the line to the section
      $DefHash{$section} .= $_;
    }

    close DEF;


# Join split lines of some sections
    $DefHash{"COMPONENTS"} =~ s/\n/ /g; 
    $DefHash{"COMPONENTS"} =~ s/;/;\n/g;
    $DefHash{"COMPONENTS"} .= "\n";
    $DefHash{"SPECIALNETS"} =~ s/\n/ /g;
    $DefHash{"SPECIALNETS"} =~ s/;/;\n/g;
    $DefHash{"SPECIALNETS"} .= "\n";

# Return whole array
    return \%DefHash;
  }

  sub edaPrintDefStatistics {
    edaMsg("Def summary:");
    foreach $section (@edaDefSectionTags) {
      edaMsg("   $section : $Counter{$section} lines");
    }
  }

# Input: ROW's section of the def file as a single "\n" separated string
# The function changes rows definition by creating proper insets
# and then returns modified ROW section. 
# Usage: edaAdjustDefRows <orig_rows_section> <x_inset> <y_inset> <chip_width> <chip_height>
  sub edaAdjustDefRows {
    my $orig_rows_section =  shift(@_);
    my $x_inset = shift(@_);
    my $y_inset = shift(@_);
    my $chip_width = shift(@_);
    my $chip_height = shift(@_);

    my $new_rows_section = "";
    my $row_count = 0;
    my($x_shift,$y_shift,$sites_in_row,@Row);

    edaMsg("Adjusting DEF rows. X inset = $x_inset  Y inset = $y_inset","I");

    foreach $row (split("\n",$orig_rows_section)) {
      $row_count++;
      @Row = split(" ",$row);
# ROW ROW_1 CORE 420 840 FS DO 4860 BY 1 STEP 84 840 ;
# 0 - "ROW"
# 1 - <name> 
# 2 - site
# 3,4 - coordinates of low left corner of the row
# 5 - orientation
# 6 - "DO" ,7 - number of sites in the row
# 8,9 - "BY 1" 
# 10,11,12 - "STEP", site width, site height

# from the first row: 
      if ($row_count == 1) {
# Determine the original inset and 
# calculate how much should we shift it
        $x_shift = $x_inset - $Row[3];
        $y_shift = $y_inset - $Row[4];

# Recalculate the number of sites in the row, to have
# approx. the same x inset from both sides 
        $sites_in_row = int(($chip_width - 2*$x_inset) / $Row[11]);
      }

# Adjust row origin and length
      $Row[3] += $x_shift;
      $Row[4] += $y_shift;
      $Row[7] = $sites_in_row; 

# If the distance to the top of the chip from the top 
# of the row, we are about to put, is less then y inset
# then don't any more rows
      if (($chip_height - $Row[4] - $Row[12]) < $y_inset) {
        last;
      }

      $new_rows_section .= join(" ",@Row)."\n";    
    }

    return $new_rows_section;
  }


# Usage ex: edaAdjustDefTracks "Y 2 METAL1 METAL3 METAL5" <tracks section>
# Will chop 2 Y-oriented  tracks in M1,M3,M5 from each side of the partition
# I.e "TRACKS Y 0 DO 5000 STEP 84 LAYER METAL1 ;" will be transformed to
#     "TRACKS Y 2 DO 4096 STEP 84 LAYER METAL1 ;"

  sub edaAdjustDefTracks {
    my @Command = split(" ",shift(@_));
    my $orig_tracks_section =  shift(@_);
    my $new_tracks_section = "";
    my($track,@Track);

    my $orientation = shift(@Command);
    my $inset = shift(@Command);
    my @Metals = @Command;

    edaMsg("Adjusting DEF tracks: $orientation inset - $inset tracks in metals '@Metals'","I");

    foreach $track (split("\n",$orig_tracks_section)) {
      @Track = split(" ",$track);
      if (($Track[1] eq $orientation) && (edaInArray($Track[8],\@Metals) >= 0)) {
#print "=>$Track[1] - $Track[8] - @Metals\n";
        $Track[2] = $inset;
        $Track[4] -= 2*$inset;
      }

      $new_tracks_section .= join(" ",@Track)."\n";
    }
    return $new_tracks_section;
  }

# Merges def sections - they must be of the same type!
# Usage: MergeSections <section1> <section2> ...
  sub edaMergeDefSections {
    my ($line,$line_count,$section,@line_arr);
    my @ValidSectionTypes = ("VIAS","PINS","COMPONENTS","NETS","SPECIALNETS"); 

    my $section_count = 0;
    my $total_count = 0;
    my $section_type = "NONE";
    my $merged_section = "";
    my $num_of_sections = $#_ + 1;
    edaMsg("Merging $num_of_sections def sections...","I");

    foreach $section (@_) {
      $section_count++;
      $line_count = 0;

      foreach $line (split("\n",$section)) {

# Only lines starting with "- " are counted
        if ($line =~ m/^-\s/) {
          $line_count ++;
        }
        @line_arr = split(" ",$line);

# 1. Extract section type from the first line of the section
        if ($line_count == 0) {	
# a. Is it a first section that we read ?
          if ($section_type eq "NONE") {	  
            if (edaInArray($line_arr[0],\@ValidSectionTypes) == -1) {
              edaMsg("Can't merge DEF sections of type '$line_arr[0]'! (section $section_count)","E"); 
              return 0;
            }
            $section_type = $line_arr[0];
          } elsif ($section_type ne $line_arr[0]) {
# b. We already read in one or more sections. Check that new section is of the same type
            edaMsg("Can't merge sections of different types: '$section_type' and '$line_arr[0]'!",E);
            return 0;

          } 

# If everything is OK - go the next line of the section
          next;
        } # End of the first line reading 

# 2. If it's an end of the section - break loop
        if (($line_arr[0] eq "END") && ($line_arr[1] eq "$section_type")) {
#$line_count -= 2; # First and last lines of section don't count

          last;
        }

# 3. From the second line to the end of section - just append line 
        $merged_section .= "$line\n";

      } # End of loop of lines in one section 
      edaMsg("  '$section_type' of file no. $section_count contributed $line_count lines");
      $total_count += $line_count;
    } # End of loop of sections

    return "$section_type $total_count ;\n$merged_section"."END $section_type\n";

  }



#===============================================================
#      Verilog related functions
#===============================================================

# This function parses given list and stores it into hash
# in a way that every module name is a key and module body is a value
# Usage: *myhash = edaParseVerilogFiles("newBlkSet23.v ");
  sub edaParseVerilogFiles {
    my $file;
    my %VerilogHash = ();

    edaMsg("Parsing verilog files",I);

    if (!@_) {
      edaError("No verilog files found!",E);
    }

# Loop over all passed files  
    while(@_) {
      $file = shift(@_);   

# Read in the current verilog
      edaOpenFile(VER, "$file", "r");
      $module_count = 0;
      while(<VER>) {
# Skip empty line
        if ($_ =~ m/^\s*$/) {
          next;
        }
# If it's a module line - open new hash record for it
        if ($_ =~ m/^\s*module/) { 
          $module_count++;
          $line = edaCleanLine($_);
#Put space before "(" - this is to separate module name from interface list
          $line =~ s/\(/ (/;
                @Line = split(" ",$line);
                $module = $Line[1];     

# Store the name of the file where module was found
                $ModuleFileNamesHash{$module} .= "$file ";		
                } 	

# Append line to the current module record
                $VerilogHash{$module} .= $_;

                } # End of current verilog file parse
                close VER;
                edaMsg("Found $module_count modules",I);

                } # End of loop over all files

# Check duplicate module declaration
                edaMsg("Checking duplicate module declaration",I);
                foreach $module (keys(%ModuleFileNamesHash)) {
                @FilesWhereModuleFound = edaConvert2List($ModuleFileNamesHash{$module});
                if ($#FilesWhereModuleFound > 0) {
                  edaMsg("Multiple declarations of module '$module' found in:\n $ModuleFileNamesHash{$module}",E);
                }
                }

# Return reference to array
                return \%VerilogHash;
  }


# Function finds master names of all instantiations in the design
# Usage: @MasterNames = edaFindAllMasterNames(\%VerilogHash));
  sub edaFindAllMasterNames {
    my(%ReservedWords,$module_name);
    %ReservedWords = ("module",1,"endmodule",1,"input",1,"output",1,"inout",1,"wire",1,"assign",1,"//",1);

    *hash_ref = shift(@_);

# Loop over all modules in the design	
    foreach $module_name (keys(%hash_ref)) {
      $module_body = $hash_ref{$module_name};

# Remove single comment lines "//" before we remove new lines
      $module_body =~ s/\/\/.*\n//g;

# Turn the entire module into one line
      $module_body =~ s/\n/ /g;

# Remove multi-line comments
      $module_body =~ s/\/\*.*\*\///g; 

# Remove multiple spaces, etc		
        $module_body = edaCleanLine($module_body);

# Remove spaces after ";" 
      $module_body =~ s/;\s*/;/g;

# Loop over all lines in the module
# Verilog statements can be multyline - ";" indicates the end  
      foreach $line (split(";",$module_body)) {
        @Line = split(" ",$line);

# Master name is the first word of the line
        $master = $Line[0];	

# Ignore special words	
        if (exists($ReservedWords{$master})) {next;}

# If not special word - store master name
        $MasterNamesHash{$master} = 1;

# Count the number of instances
#if (exists($MasterNamesHash{$master})
#   $MasterNamesHash{$master}++;
#} else {
#   $MasterNamesHash{$master} = 0;
#}				
    }
    }

# the list of keys of accumulated hash - is the list of all masters 
    return sort(keys(%MasterNamesHash));	
    }

# Given the raw text of the module - it returns a reference to a hash
# whose keys are module names , which are instantiated from this module
# values - instance names of those modules
# *myhash = edaFindReferencedModules(module_name,\%VerilogHash) ;
    sub edaFindReferencedModules {
    my %FoundModulesHash = ();
    %ReservedWords = ("module",1,"endmodule",1,"input",1,"output",1,"ioput",1,"wire",1);
    my $module_name = shift(@_);
    *hash_ref = shift(@_);

    my($module_body);

    if (! exists($hash_ref{$module_name})) {
      edaMsg("Module '$module_name' doesn't exist in the verilog!",E);
      return -1;
    }

# Remove multiple spaces, etc/ 
    $module_body = edaCleanLine($hash_ref{$module_name});
    $module_body =~ s/;\s*/;/g;


# Loop over all statements in the module and single out 
# instantiations of other modules or cells
# Each $line contains one verilog statement up to ";"
# Originally it may be multyline
    foreach $line (split(";",$module_body)) {
      @Line = split(" ",$line);

      if (exists($ReservedWords{$Line[0]})) {
        next;
      }

# Is this word a module? If yes - store the name the module (key)
# and name of instance (append to value)
      if (exists($hash_ref{$Line[0]})) {
# Strip interface from instance name
        $Line[1] =~ s/\(.*//;
        if (exists $FoundModulesHash{$Line[0]}) {
          $FoundModulesHash{$Line[0]} .= " $Line[1]";
        } else {
          $FoundModulesHash{$Line[0]} = $Line[1];
        }
      }
    }

    return(\%FoundModulesHash); 
    }

# Usage: edaDumpVerilogHash(\%hash,<file_name>,module1,module2,...)
# if no module names are specified - all modules will be printed
#   * hash is passed by reference
sub edaDumpVerilogHash {
  *hash_ref = shift(@_);
  my $file = shift(@_);
  my @ListOfModules = @_;

  edaOpenFile(VER, "$file", "wf");

  if ($#ListOfModules < 0) {
    @ListOfModules = keys(%hash_ref);
  }
  foreach $module (@ListOfModules) {
    print VER "$hash_ref{$module}";
  }
  close VER;

  return 1;
}

#===============================================================
#      LEF related functions
#===============================================================
@edaLefSectionTags = ("SITE","SPACING");

# This function browses specified lef files and creates a hash, whose 
# keys are macro names and values are class types: CORE, BLOCK, RING
# Usage: *myhash = edaCreateMacroHashFromLefFiles("*.lef);

sub edaCreateMacroHashFromLefFiles {
  my @Files = edaConvert2List(@_);
  my(%MacroHash,$file,@Line,$macro_name);

  $macro_name = "NONE";

  edaMsg("Processing lef files...",I);
# Loop over each file
  foreach $file (@Files) {
    edaOpenFile(LEF, "$file", "r");
    $macro =0; 
    while(<LEF>) {
      $line = $_;
# Remove tabs, multiple, leading and trailing spaces
      $line =~ s/\t/ /g;
      $line =~ s/^\s*//;
      $line =~ s/\s*$//;
      $line =~ s/\s+/ /g;
      @Line = split(" ",$line);

      if ($Line[0] eq "MACRO") {
        $macro =1;
        $macro_name = $Line[1];
# default macro class is CORE
        $MacroHash{$macro_name} = "CORE";
        $MacroHash{$macro_name,"file"} = $file;
      }
      if ($Line[0] eq "CLASS" && $macro==1) {
        $MacroHash{$macro_name} = $Line[1];
        next;
      } 	
    }		
  }
  return \%MacroHash;	
}


# This function parses given list of lef files and extracts the
# reference to a hash where macro name is a key and entire macro text is 
# a value
# Usage: *myhash = edaParseLefFiles("*.lef");
sub edaParseLefFiles {
  my @Files = edaConvert2List(@_);
  my(%LefHash,$file,$macro_name);

  if (!@Files) {
    edaError("No lef files found!",E);
  }



# Loop over each file
  foreach $file (@Files) {
    edaOpenFile(LEF, "$file", "r");
    $macro_name = "NA";

    while(<LEF>) {

# Skip empty line
      if ($_ =~ m/^\s*$/) {
        next;
      }

      $line = $_;
# Remove tabs, multiple, leading and trailing spaces
      $line =~ s/\t/ /g;
      $line =~ s/^\s*//;
      $line =~ s/\s*$//;
      $line =~ s/\s+/ /g;

      @Line = split(" ",$line);
      $line .= "\n";


# Is it a beginning of the MACRO?
      if ($Line[0] eq "MACRO") {
        $macro_name = $Line[1];
        $LefHash{$macro_name} .= $line;
      }
# Is it the end of MACRO?
      if (($Line[0] eq "END") && ($Line[1] eq $macro_name)) {
        $LefHash{$macro_name} .= $line;
        $macro_name = "NA";
      }
# Append the line to the section
      if ($macro_name ne "NA") {
        $LefHash{$macro_name} .= $line;
      }
    }
  } # End of loop over files

  return \%LefHash;
}

# This routine takes the full text of the lef macro as an input adn
# returns a reference to a hash with following keys:
# CLASS
# SIZE
#  <pin>,USE
#  <pin>,DIRECTION
#  <pin>,PORT  (port is a simple multiline text)
# Usage: *myhash = edaProcessLefMacro($macro_text);
sub edaProcessLefMacro {
  my $macro_text = $_[0];
  my $pin_name = "NA";
  my $port_read = 0;

  foreach $line (split("\n",$macro_text)) {
    @Line = split(" ",$line);
    if ($Line[0] eq "CLASS") {
      $MacroHash{CLASS} = $Line[1];
    } elsif ($Line[0] eq "SIZE") {
#$MacroHash{SIZE} = ($Line[1],$Line[3]);
    } elsif ($Line[0] eq "PIN") {
      $pin_name = $Line[1];
    } elsif (($Line[0] eq "END") && ($Line[1] eq $pin_name)) {
      $pin_name = "NA";
    }

# We are inside pin section
    if ($pin_name ne "NA") {
      if ($Line[0] eq "DIRECTION") {
        $MacroHash{PINS}{$pin_name}{DIRECTION} = $Line[1];
      } elsif ($Line[0] eq "USE") {
        $MacroHash{PINS}{$pin_name}{USE} = $Line[1];
      } elsif ($Line[0] eq "PORT") {
        $port_read = 1;
        next;
      } elsif ($Line[0] eq "END") {
        $port_read = 0;
        next;
      } elsif ($Line[0] eq "LAYER") {
        $layer = $Line[1];
        next;
      }
      if ($port_read == 1) {
        if ($Line[0] eq "RECT") {
          $MacroHash{PINS}{$pin_name}{$layer} .= "$Line[1] $Line[2] $Line[3] $Line[4]\n";
        }
      }
    }
  }


  return \%MacroHash;
}

# Extract design name from spf file
sub edaGetSpfDesignName {
  my $file = shift(@_);
  edaOpenFile(SPEF,$file,"r");
  while(<SPEF>) {
    @Line = split(" ",$_);
    if (($Line[0] eq "*DESIGN") or ($Line[0] eq "*|DESIGN")) {
      close SPEF;
      my $design_name = $Line[1];
      $design_name =~ s/\"//g;
      return $design_name;
    }
  }
  close SPEF;
  return "???";
}

# Extract design name from STA file
sub edaGetStaDesignName {
  my $file = shift(@_);
  edaOpenFile(STA,$file,"r");
  while(<STA>) {
    chomp();
    if ($_ =~ s/# Design Name\s*: //) {
      close STA;
    return $_;
  }
  }
  close STA;
  return "???";
}

#====================================================================
# This function returns APL section for one cell given cell name and
# PWL description of the current
# Required units, metric: time - 1s, current - 1A
# Usage: generateApl(number_of_points,@PWL)
# Ex: generateApl(cell1,0,0,1e-9,30e-6,2e-9,0);
#====================================================================
sub edaGenerateApl {
  my $num_of_apl_points = shift(@_);
  my @PWL = @_;
  my $num_of_pwl_points = $#PWL + 1;
# defaults

  my($Currents,$time_step,$pwl_index,$i,$t,$t1,$t2,$curr1,$curr2,$curr);
  $Currents = "";

# Chop measurement before $start_time
# Transform  from metric to internal APL units - 1uA and 1ps 
  for ($i = 0; $i <= $#PWL; $i += 2) {
# time
    $PWL[$i] = int($PWL[$i]*1e12);

# current
    $PWL[$i+1] = $PWL[$i+1]*1e6;
  }

# Determine the time step
  $time_step = $PWL[-2]/($num_of_apl_points-1);
  edaMsg("Converting PWL to APL","I");
  edaMsg(" Number of PWL points: $num_of_pwl_points");
  edaMsg(" PWL time range: $PWL[0] ps - $PWL[-2] ps");
  edaMsg(" Number of APL points: $num_of_apl_points");
  edaMsg(" APL time step: $time_step ps");


# Point to the first time sampling in PWL
  $j = 0;
# Here is starting APL time point
  $t = 0;

# Walk through all measurements points and calculate currents
  $count = 0;
  while ($t < $PWL[-2]) {
# $PWL record may start with time larger than 0
# Print 0 current until $t surpasses first time point in $PWL
    if ($t < $PWL[0]) {
      $Currents .= "0 ";
      $count++;
      $t += $time_step;
      next;
    }

# If current time has surpassed time from the next point i.e $PWL[$j+2]
# - advance the index of PWL. $t should be in between $PWL[$j] and $PWL[$j+2]
    while ($t > $PWL[$j+2]) {
      $j += 2;
    }

# Ignore multiple records for the same timing point
    while ($PWL[$j] == $PWL[$j+2]) {
      edaMsg("Warning: multiple records found for timing point of $PWL[$j+2] ps!","W");
      $j = $j+2;
    }

# Figure out t1-t2 interval from PWL where current "t" falls
    $t1 = $PWL[$j];
    $t2 = $PWL[$j+2];
    $curr1 = $PWL[$j+1];
    $curr2 = $PWL[$j+3];

    $curr = int($curr1 + ($curr2-$curr1)*($t-$t1)/($t2-$t1));
    $Currents .= "$curr ";
    $count++;
    $t += $time_step;

  }

# Sometimes last point is missing due to rounding
  if ($count < $num_of_apl_points) {
    $Currents .= "$curr ";
    $count++;
    $t += $time_step;
  }

  $t -= $time_step;
  $t = int($t);
  edaMsg(" APL time range: 0 - $t ps");

# Form and return entire apl section
# round time step
  $time_step = int($time_step);
  edaMsg(" $count APL sample points created","I"); 
  return ($time_step,$Currents);
}

#======================================================================== 
# Read in entire GSR file into hash 
# There are two record types:
# "$gsrRef->{$keyword}->{text}" and "$gsrRef->{$keyword}->{help}"
# A contiguous commented text message immediately abouve GSR keyword is 
# recognized as help
#
# Usage ex: 
#   %MyGSR = ();
#  @GSR_keywords = parseGSR($file_name,\%MyGSR); 
#========================================================================
sub parseGSR {
  $gsr_file = shift(@_);
  $gsrRef = shift(@_);

  edaOpenFile(GSR,"$gsr_file","r");
  my $text_acc = "";
  my $help_acc = "";
  my $keyword = "";
  my @GSR = ();
  my @Keywords = ();
  my @Line = ();

# Store all GSR text in array line by line. Convert tabs to spaces, remove multiple
# and trailing spaces. (Don't touch  leading spaces - for clarity)
  while (<GSR>) {
    chomp($_);
    $line = $_;
    $line =~ s/\t/ /g;
    $line =~ s/\s*$//;
    $line =~ s/\s+/ /g;
    push (@GSR,$line);
  }

# Walk through entire GSR and store it in a hash, where GSR 
# keywords become keys of the hash
  while (@GSR) {
# Pop one line ouf of @GSR array
    $line = shift(@GSR);

# If it's a comment - add to a help accumulator 
    if ($line =~ m/^\#/) {
      $help_acc .= "$line\n";
      next;
    } 

# Empty line - sign that we're going to start new GSR section
# reset help accumulator
    if ($line =~ m/^\s*$/)  {
      $help_acc = "";
      next;
    }

# This a real GSR keyword
    @Line = split(" ",$line);
    $keyword = shift(@Line);
    push (@Keywords,$keyword);


    $text_acc = join(" ",@Line);

# If it's a multiline section(there is only the keyword with brace in the next line), scroll through GSR array until finishing "}"
    if($keyword =~ /_FILE/ && (! defined $Line[0]) ) {
      $vcd_stack = 0;
      while (@GSR && ($GSR[0] == "{")) {
        if ( $GSR[0] == "{" ) {
          $vcd_stack += 1;
        }
        $text_acc .= "\n".shift(@GSR);
#        print "text_acc1: $text_acc \n";
        while (@GSR && ($GSR[0] ne "}")) {
          if ( $GSR[0] == "}" ) { $vcd_stack -= 1; }
          $text_acc .= "\n".shift(@GSR);
#          print "text_acc2: $text_acc \n";
        }
# Save "}" as well
        $text_acc .= "\n".shift(@GSR);
#        print "text_acc3: $text_acc \n";
        last;
      }

    }

#1.11c1 Chester: start
# If it's a multiline section(has a brace after the keyword), scroll through GSR array until finishing "}"
    $vcd_stack = 0;
    if ($Line[0] =~ m/^{/) {
      $vcd_stack += 1;
      while (@GSR && ($vcd_stack != 0)) {
        $tmp = shift(@GSR);
        if ( $tmp =~ m/}/ ) { $vcd_stack -= 1; }
        if ( $tmp =~ m/{/ ) { $vcd_stack += 1; }
        $text_acc .= "\n".$tmp;
#        print "vcd_stack = $vcd_stack ; text_acc4: $text_acc \n";
      }
# Save "}" as well
      $text_acc .= "\n".shift(@GSR);
#      print "vcd_stack = $vcd_stack ; text_acc5: $text_acc \n";

    }
#1.11c1 Chester: end

    chomp $help_acc;
    chomp $text_acc;
    

# Save actual text and help
    if ($help_acc ne "") {
      $gsrRef->{$keyword}->{help} = $help_acc;
    }
    $gsrRef->{$keyword}->{text} = $text_acc;
    $help_acc = "";
    $text_acc = "";
    }

    close GSR;

    return @Keywords;
  }


#==============================================================================
# Merges two GSR hashes
# Usage: mergeGSR($srcRef1,$srcRef2,$targetRef)
# First GSR takes precedence unless the key doesn't exist or value is "???"
# Ex: mergeGSR(\%CentralGSR,\%DefaultGSR,\%MyGSR);
#==============================================================================
  sub mergeGSR {
    $srcRef1 = shift(@_);
    $srcRef2 = shift(@_);
    $trgRef = shift(@_);

    foreach $key (keys(%{$srcRef1}),keys(%{$srcRef2})) {
      if ((defined $srcRef1->{$key}->{text}) && 
          ($srcRef1->{$key}->{text} ne "???")) {
        $trgRef->{$key}->{text} = $srcRef1->{$key}->{text}
      } elsif (defined $srcRef2->{$key}->{text}) {
        $trgRef->{$key}->{text} = $srcRef2->{$key}->{text}
      }

      if (defined $srcRef1->{$key}->{help}) {
        $trgRef->{$key}->{help} = $srcRef1->{$key}->{help}
      } elsif (defined $srcRef2->{$key}->{help}) {
        $trgRef->{$key}->{help} = $srcRef2->{$key}->{help}
      }
    }
  }

# Don't remove this 1 !
  1;

