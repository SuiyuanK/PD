#!/usr/bin/perl
$bucket_size = 500;
unless (-e ".apache/apache.nloc")  {
  print "File .apache/apache.nloc could not be found. Exiting...\n";
  exit;
}
$xmin=1000000;
$ymin=1000000;
$xmax=-1000000;
$ymax=-1000000;

open IN1,".apache/apache.nloc";
while (<IN1>)  {
  chomp;split;
  $layer=$_[3];
  unless ($pushed{$layer} ==1)  {
    push @layers, $layer;
    $pushed{$layer}=1;
  }
  $lcnt{$layer}++;
  if ($_[1]<$xmin)  {$xmin=$_[1]};
  if($_[1]>$xmax)  {$xmax=$_[1]}
  if ($_[2]<$ymin)  {$ymin=$_[2]};
  if($_[2]>$ymax)  {$ymax=$_[2]}
  
  $x_id=int($_[1]/$bucket_size);
  $y_id=int($_[2]/$bucket_size);
  $bucket_id="${x_id}_${y_id}";
  $rcnt{$bucket_id}++;
  unless ($pushed{$bucket_id} ==1)  {
    push @bucket_ids, $bucket_id;
    $pushed{$bucket_id}=1;
  }
  $ncnt++;
}

print "DIE = $xmin $ymin $xmax $ymax\n";
$area= sprintf "%.1f", ($xmax-$xmin)*($ymax-$ymin)/1e6;

open OUT1, "> $ENV{HOME}/.tmp1";
foreach $layer ( @layers)  {
  $l=$lcnt{$layer}/1e6;
  $l=sprintf "%.1f", $l;

  print OUT1 "$layer $l\n";
}

system   "sort -r -n -k2,2 $ENV{HOME}/.tmp1 > $ENV{HOME}/.tmp11";

print "\nLayer Based Profile:\n\n";
print "Layer \t\tNodes\n";
open IN1,"$ENV{HOME}/.tmp11";
while (<IN1>)  {
  chomp;split;
  print "$_[0] \t\t$_[1] M\n";;
}


 
open OUT1, "> $ENV{HOME}/.tmp2";
foreach $bucket_id ( @bucket_ids)  {
  $r=$rcnt{$bucket_id}/1e6;
  $r=sprintf "%.2f", $r;
  print OUT1 "$bucket_id $r\n";
  $nbucket++;
}

  
system   "sort -r -n -k2,2 $ENV{HOME}/.tmp2 | head -10 > $ENV{HOME}/.tmp22";

print "\n\nRegion Based Profile (Top 10 regions):\n\n";
print "        X1         Y1         X2         Y2                   Nodes\n";

open IN1,"$ENV{HOME}/.tmp22";
while (<IN1>)  {
  chomp;split;
  $bucket_id=$_[0];
  @tmp=split ('_', $bucket_id);
  $x1=$tmp[0]*$bucket_size;
  $y1=$tmp[1]*$bucket_size;
  $x2=$x1+$bucket_size;
  $y2=$y1+$bucket_size;
  printf "%10d %10d %10d %10d\t\t%10s M\n",$x1, $y1, $x2, $y2, ,$_[1] ;
}

$nodes_per_bucket = sprintf "%.3f", $ncnt/($nbucket*1e6) ;
$nodes_per_sqmm = sprintf "%.2f", $ncnt/($area*1e6);
$ncnt_M=sprintf "%.1f", $ncnt/1e6;

$b = sprintf "%.2f", ($bucket_size*$bucket_size)/1e6;

print "\n\nNumber of Nodes         = $ncnt_M M \n";
print "Number of partitions    = $nbucket (Partition size = $b sqmm)\n";
print "Die Area                = $area sqmm\n";
print "Avg Nodes per partition = $nodes_per_bucket M\n";
print "Avg Nodes per Sqmm      = $nodes_per_sqmm M/sqmm\n\n";
  
