
eval '(exit $?0)' && eval 'exec perl -S $0 ${1+"$@"}'
&& eval 'exec perl -S $0 $argv:q'
if 0;

# (C) Apache Design Solutions - 2007
# 2645 Zanker Road
# San Jose , CA 95134 
# USA

#$Id: ta2excel.pl,v 1.1 2009/04/09 19:48:08 srini Exp $
#$Log: ta2excel.pl,v $
#Revision 1.1  2009/04/09 19:48:08  srini
#Script to convert raw ta0 file to excel
#
#Revision 1.2  2009/04/08 03:07:53  srini
#Header and Formatting fixed
#
#Revision 1.1  2009/04/08 03:04:06  srini
#Initial revision
#

# Usage:
# perl ta2excel.pl <input_ta0_file>  >  <output_file_name>

## ta0 parser ##
$header = 1 ;
while(<>) {
        if(/^Variables:/) {
                $collect_variables = 1 ;
                next ;
        }
        if(/^Values:/) {
                $header = 0 ;
                $collect_variables = 0 ;
                $collect_values = 1 ;
                next ;
        }
        if($collect_variables) {
                split ;
                $v_name{$_[0]} = $_[1] ;
                $signal_nr++ ;
                next ;
        }
        if($collect_values) {
                split ;
                $i = @_ ;
                if($i > 1) {
                        $v = 0 ;
                        $sample_nr = $_[0] ;
                        $val{$v}{$sample_nr} = $_[1] ;
                } else {
                        $v++ ;
                        $val{$v}{$sample_nr} = $_[0] ;
                }
        }
        if($header) {
                push(@header_array, $_) ;
        }
}

print @header_array , "\n" ;

for($i = 0; $i < $signal_nr ; $i++) {
	print "$v_name{$i}\t" ;
}
print "\n" ;

for($s=0; $s <= $sample_nr; $s++) {
	for($i = 0; $i < $signal_nr ; $i++) {
		print "$val{$i}{$s}\t" ;
	}
		print "\n" ;
}



