# 2011/11/16
namespace	eval	__MMX	{
	variable	fontVec
	set __MMX::fontVec(0) [list "0 1 0 5" "0 5 1 6" "1 6 3 6" "3 6 4 5" "4 5 4 1" "4 1 3 0" "3 0 1 0" "1 0 0 1" \
		"0 1 4 5"]
	set __MMX::fontVec(1) [list "2 0 2 6" "2 6 1 5"]
	set __MMX::fontVec(2) [list "0 5 1 6" "1 6 3 6" "3 6 4 5" "4 5 4 4" "4 4 0 0" "0 0 4 0"]
	set __MMX::fontVec(3) [list "0 5 1 6" "1 6 3 6" "3 6 4 5" "4 5 4 4" "4 4 3 3" "3 3 2 3" "3 3 4 2" "4 2 4 1" \
		"4 1 3 0" "3 0 1 0" "1 0 0 1"]
	set __MMX::fontVec(4) [list "3 6 3 0" "3 6 0 2" "0 2 4 2"]
	set __MMX::fontVec(5) [list "0 6 4 6" "0 6 0 4" "0 4 3 4" "3 4 4 3" "4 3 4 1" "4 1 3 0" "3 0 1 0" "1 0 0 1"]
	set __MMX::fontVec(6) [list "0 1 0 5" "0 5 1 6" "1 6 3 6" "3 6 4 5" "0 3 3 3" "3 3 4 2" "4 2 4 1" "4 1 3 0" \
		"3 0 1 0" "1 0 0 1"]
	set __MMX::fontVec(7) [list "0 6 4 6" "4 6 1 0"]
	set __MMX::fontVec(8) [list "0 5 1 6" "1 6 3 6" "3 6 4 5" "4 5 4 4" "4 4 3 3" "3 3 1 3" "1 3 0 4" "0 4 0 5" \
		"3 3 4 2" "4 2 4 1" "4 1 3 0" "3 0 1 0" "1 0 0 1" "0 1 0 2" "0 2 1 3"]
	set __MMX::fontVec(9) [list "0 5 1 6" "1 6 3 6" "3 6 4 5" "4 5 4 1" "4 1 3 0" "3 0 1 0" "1 0 0 1" "0 5 0 4" \
		"0 4 1 3" "1 3 4 3"]
	set __MMX::fontVec(.) [list "1 0 1 1" "1 1 2 1" "2 1 2 0" "2 0 1 0"]
	set __MMX::fontVec(,) [list "1 0 1 1" "1 1 2 1" "2 1 2 0" "2 0 1 0" "2 0 1 -1"]
	set __MMX::fontVec(-) [list "0 3 4 3"]
	set __MMX::fontVec(_) [list "-1 0 5 0"]
	set __MMX::fontVec(+) [list "0 3 4 3" "2 1 2 5"]
	set __MMX::fontVec(/) [list "0 0 4 6"]
	set __MMX::fontVec(\) [list "0 6 4 0"]
	set __MMX::fontVec(() [list "2 1 2 5" "2 1 3 0" "2 5 3 6"]
	set __MMX::fontVec()) [list "2 1 2 5" "2 1 1 0" "2 5 1 6"]
	set __MMX::fontVec(<) [list "1 3 4 6" "1 3 4 0"]
	set __MMX::fontVec(>) [list "1 6 4 3" "1 0 4 3"]
	set __MMX::fontVec(\[) [list "2 0 2 6" "2 0 3 0" "2 6 3 6"]
	set __MMX::fontVec(\]) [list "2 0 2 6" "2 0 1 0" "2 6 1 6"]
	set __MMX::fontVec(?) [list "0 5 1 6" "1 6 3 6" "3 6 4 5" "4 5 4 4" "4 4 2 2" "2 1 2 0"]
	set __MMX::fontVec(:) [list "1 0 1 1" "1 1 2 1" "2 1 2 0" "2 0 1 0" "1 3 1 4" "1 4 2 4" "2 4 2 3" "2 3 1 3"]
	set __MMX::fontVec(\;) [list "1 0 1 1" "1 1 2 1" "2 1 2 0" "2 0 1 0" "2 0 1 -1" "1 3 1 4" "1 4 2 4" "2 4 2 3" \
		"2 3 1 3"]
	set __MMX::fontVec(a) [list "1 0 4 0" "4 0 4 3" "4 3 3 4" "3 4 1 4" "1 0 0 1" "0 1 1 2" "1 2 4 2"]
	set __MMX::fontVec(b) [list "0 1 1 0" "0 0 0 6" "1 0 3 0" "3 0 4 1" "4 1 4 3" "4 3 3 4" "3 4 1 4" "1 4 0 3"]
	set __MMX::fontVec(c) [list "1 0 3 0" "3 0 4 1" "1 0 0 1" "0 1 0 3" "0 3 1 4" "1 4 3 4" "3 4 4 3"]
	set __MMX::fontVec(d) [list "4 6 4 0" "4 1 3 0" "3 0 1 0" "1 0 0 1" "0 1 0 3" "0 3 1 4" "1 4 3 4" "3 4 4 3"]
	set __MMX::fontVec(e) [list "1 0 3 0" "3 0 4 1" "1 0 0 1" "0 1 0 3" "0 3 1 4" "1 4 3 4" "3 4 4 3" "4 3 3 2" \
		"3 2 0 2"]
	set __MMX::fontVec(f) [list "1 0 1 5" "1 5 2 6" "2 6 3 6" "3 6 4 5" "0 3 3 3"]
	set __MMX::fontVec(g) [list "4 3 4 -1" "4 -1 3 -2" "3 -2 1 -2" "1 -2 0 -1" "4 1 3 0" "3 0 1 0" "1 0 0 1" \
		"0 1 0 3" "0 3 1 4" "1 4 3 4" "3 4 4 3"]
	set __MMX::fontVec(h) [list "0 0 0 6" "4 0 4 3" "4 3 3 4" "3 4 1 4" "1 4 0 3"]
	set __MMX::fontVec(i) [list "2 0 2 4" "2 5 2 6"]
	set __MMX::fontVec(j) [list "3 0 3 4" "3 0 2 -1" "2 -1 1 -1" "1 -1 0 0" "3 5 3 6"]
	set __MMX::fontVec(k) [list "0 0 0 6" "1 2 4 0" "1 2 4 4" "0 2 1 2"]
	set __MMX::fontVec(l) [list "2 0 2 6"]
	set __MMX::fontVec(m) [list "0 0 0 4" "4 0 4 3" "1 4 2 3" "2 3 2 0" "2 3 3 4" "3 4 4 3" "1 4 0 3"]
	set __MMX::fontVec(n) [list "0 0 0 4" "0 3 1 4" "4 0 4 3" "4 3 3 4" "3 4 1 4" "1 4 0 3"]
	set __MMX::fontVec(o) [list "1 0 3 0" "3 0 4 1" "1 0 0 1" "0 1 0 3" "0 3 1 4" "1 4 3 4" "3 4 4 3" "4 3 4 1"]
	set __MMX::fontVec(p) [list "0 1 1 0" "0 -1 0 4" "1 0 3 0" "3 0 4 1" "4 1 4 3" "4 3 3 4" "3 4 1 4" "1 4 0 3"]
	set __MMX::fontVec(q) [list "1 0 3 0" "3 0 4 1" "1 0 0 1" "0 1 0 3" "0 3 1 4" "1 4 3 4" "3 4 4 3" "4 4 4 -1"]
	set __MMX::fontVec(r) [list "0 0 0 4" "0 3 1 4" "1 4 3 4" "3 4 4 3"]
	set __MMX::fontVec(s) [list "0 1 1 0" "1 0 3 0" "3 0 4 1" "4 1 0 3" "0 3 1 4" "1 4 3 4" \
		"3 4 4 3"]
	set __MMX::fontVec(t) [list "2 6 2 1" "2 1 3 0" "3 0 4 0" "1 4 4 4"]
	set __MMX::fontVec(u) [list "1 0 3 0" "3 0 4 1" "1 0 0 1" "0 1 0 4" "4 4 4 0"]
	set __MMX::fontVec(v) [list "0 4 2 0" "2 0 4 4"]
	set __MMX::fontVec(w) [list "0 1 0 4" "0 1 1 0" "1 0 2 1" "2 1 2 2" "2 1 3 0" "3 0 4 1" "4 1 4 4"]
	set __MMX::fontVec(x) [list "0 4 4 0" "0 0 4 4"]
	set __MMX::fontVec(y) [list "4 4 4 -1" "4 -1 3 -2" "3 -2 1 -2" "1 -2 0 -1" "4 1 3 0" "3 0 1 0" "1 0 0 1" \
		"0 1 0 4"]
	set __MMX::fontVec(z) [list "0 4 4 4" "0 0 4 0" "0 0 4 4"]
	set __MMX::fontVec(A) [list "0 0 0 5" "0 5 1 6" "1 6 3 6" "3 6 4 5" "4 5 4 0" "0 3 4 3"]
	set __MMX::fontVec(B) [list "0 0 0 6" "0 6 3 6" "3 6 4 5" "4 5 4 4" "4 4 3 3" "3 3 0 3" "0 0 3 0" "3 0 4 1" \
		"4 1 4 2" "4 2 3 3"]
	set __MMX::fontVec(C) [list "0 1 0 5" "0 5 1 6" "1 6 3 6" "3 6 4 5" "0 1 1 0" "1 0 3 0" "3 0 4 1"]
	set __MMX::fontVec(D) [list "0 0 0 6" "0 6 3 6" "3 6 4 5" "4 5 4 1" "4 1 3 0" "3 0 0 0"]
	set __MMX::fontVec(E) [list "0 0 0 6" "0 6 4 6" "0 3 3 3" "0 0 4 0"]
	set __MMX::fontVec(F) [list "0 0 0 6" "0 6 4 6" "0 3 3 3"]
	set __MMX::fontVec(G) [list "0 1 0 5" "0 5 1 6" "1 6 3 6" "3 6 4 5" "0 1 1 0" "1 0 3 0" "3 0 4 1" "4 1 4 3" \
		"4 3 2 3"]
	set __MMX::fontVec(H) [list "0 0 0 6" "4 0 4 6" "0 3 4 3"]
	set __MMX::fontVec(I) [list "2 0 2 6"]
	set __MMX::fontVec(J) [list "0 2 0 1" "0 1 1 0" "1 0 3 0" "3 0 4 1" "4 1 4 6"]
	set __MMX::fontVec(K) [list "0 0 0 6" "1 3 4 6" "1 3 4 0" "0 3 1 3"]
	set __MMX::fontVec(L) [list "0 0 0 6" "0 0 4 0"]
	set __MMX::fontVec(M) [list "0 0 0 6" "4 0 4 6" "0 6 2 3" "2 3 4 6"]
	set __MMX::fontVec(N) [list "0 0 0 6" "4 0 4 6" "0 6 4 0"]
	set __MMX::fontVec(O) [list "0 1 0 5" "0 5 1 6" "1 6 3 6" "3 6 4 5" "0 1 1 0" "1 0 3 0" "3 0 4 1" "4 1 4 5"]
	set __MMX::fontVec(P) [list "0 0 0 6" "0 6 3 6" "3 6 4 5" "4 5 4 4" "4 4 3 3" "3 3 0 3"]
	set __MMX::fontVec(Q) [list "0 1 0 5" "0 5 1 6" "1 6 3 6" "3 6 4 5" "0 1 1 0" "1 0 3 0" "3 0 4 1" "4 1 4 5" \
		"2 2 4 0"]
	set __MMX::fontVec(R) [list "0 0 0 6" "0 6 3 6" "3 6 4 5" "4 5 4 4" "4 4 3 3" "3 3 0 3" "3 3 4 2" "4 2 4 0"]
	set __MMX::fontVec(S) [list "0 1 1 0" "1 0 3 0" "3 0 4 1" "4 1 4 2" "4 2 3 3" "3 3 1 3" "1 3 0 4" "0 4 0 5" \
		"0 5 1 6" "1 6 3 6" "3 6 4 5"]
	set __MMX::fontVec(T) [list "2 0 2 6" "0 6 4 6"]
	set __MMX::fontVec(U) [list "0 1 0 6" "0 1 1 0" "1 0 3 0" "3 0 4 1" "4 1 4 6"]
	set __MMX::fontVec(V) [list "0 6 0 2" "0 2 2 0" "2 0 4 2" "4 2 4 6"]
	set __MMX::fontVec(W) [list "0 0 0 6" "4 0 4 6" "0 0 2 3" "2 3 4 0"]
	set __MMX::fontVec(X) [list "0 6 4 0" "4 6 0 0"]
	set __MMX::fontVec(Y) [list "0 6 2 3" "4 6 2 3" "2 3 2 0"]
	set __MMX::fontVec(Z) [list "0 6 4 6" "0 0 4 0" "4 6 0 0"]
	
	proc	addMarker	{ x y {color white} {size 1} }	{
		marker add -position $x $y -color $color -size $size
	}
	proc	checkVer	{ tVer }	{
		return
		if	{ [catch { set iVer [get ver] }] }	{
			error	"this feature requires RH/TM $tVer or above"
		}
		set nIVer [__MMX::ver2num $iVer]; set nTVer [__MMX::ver2num $tVer]
		if	{ $nIVer < $nTVer }	{
			error	"this feature requires RH/TM $tVer or above"
		}
	}
	proc	drawLine	{ blx bly trx try {col 9} {width 1} }	{
		set color [getColorTxt $col]
		plot line -position $blx $bly $trx $try -color $color -width $width
	}
	proc	drawDetourLine	{ blx bly trx try col width al sf {ua 0} }	{
		set offset [list {1 2} {1 2} {2 -1} {1 -2} {-1 -2} {-2 -1} {-2 1} {-1 2}]
		set ddx [expr abs($trx-$blx)]; set ddy [expr abs($try-$bly)]
		if	{ $ddx < [expr $al*$ddy] || $ddy < [expr $al*$ddx] }	{
			set xy1 [lindex $offset [expr int(rand()*8)]]
			set xy2 [lindex $offset [expr int(rand()*8)]]
			set sx1 [lindex $xy1 0]; set sy1 [lindex $xy1 1]
			set sx2 [lindex $xy2 0]; set sy2 [lindex $xy2 1]
			if	{ $ddx < [expr $al*$ddy] }	{
				set sx1 [expr $sx1*$sf*$ddy]; set sy1 [expr $sy1*$sf*$ddy]
				set sx2 [expr $sx2*$sf*$ddy]; set sy2 [expr $sy2*$sf*$ddy]
			}	else	{
				set sx1 [expr $sx1*$sf*$ddx]; set sy1 [expr $sy1*$sf*$ddx]
				set sx2 [expr $sx2*$sf*$ddx]; set sy2 [expr $sy2*$sf*$ddx]
			}
			set x1p [expr $blx+$sx1]; set y1p [expr $bly+$sy1]
			set x2p [expr $trx+$sx2]; set y2p [expr $try+$sy2]
			plot line -position $blx $bly $x1p $y1p -color $col -width $width
			plot line -position $trx $try $x2p $y2p -color $col -width $width
			plot line -position $x1p $y1p $x2p $y2p -color $col -width $width
			set cx [expr 0.5*($x1p+$x2p)]; set cy [expr 0.5*($y1p+$y2p)]
			if	{ $ua }	{
				set rad 0.5
				set dx [expr $x1p-$cx]; set dy [expr $y1p-$cy]
				set nx1 [expr 0.1*($dx*cos($rad)-$dy*sin($rad))+$cx]
				set ny1 [expr 0.1*($dx*sin($rad)+$dy*cos($rad))+$cy]
				set nx2 [expr 0.1*($dx*cos($rad)+$dy*sin($rad))+$cx]
				set ny2 [expr 0.1*(-$dx*sin($rad)+$dy*cos($rad))+$cy]
				plot line -position $cx $cy $nx1 $ny1 -color $col -width $width
				plot line -position $cx $cy $nx2 $ny2 -color $col -width $width
			}
		}	else	{
			plot line -position $blx $bly $trx $try -color $col -width $width
			set cx [expr 0.5*($blx+$trx)]; set cy [expr 0.5*($bly+$try)]
			if	{ $ua }	{
				set rad 0.5
				set dx [expr $blx-$cx]; set dy [expr $bly-$cy]
				set nx1 [expr 0.1*($dx*cos($rad)-$dy*sin($rad))+$cx]
				set ny1 [expr 0.1*($dx*sin($rad)+$dy*cos($rad))+$cy]
				set nx2 [expr 0.1*($dx*cos($rad)+$dy*sin($rad))+$cx]
				set ny2 [expr 0.1*(-$dx*sin($rad)+$dy*cos($rad))+$cy]
				plot line -position $cx $cy $nx1 $ny1 -color $col -width $width
				plot line -position $cx $cy $nx2 $ny2 -color $col -width $width
			}
		}
		return	[list $ddx $ddy $cx $cy]
	}
	proc	drawDetourLineMsg	{ blx bly trx try col width al sf txt fs }	{
		set offset [list {1 2} {1 2} {2 -1} {1 -2} {-1 -2} {-2 -1} {-2 1} {-1 2}]
		set ddx [expr abs($trx-$blx)]; set ddy [expr abs($try-$bly)]; set d [expr ($ddx > $ddy) ? 1 : 0]
		if	{ $ddx < [expr $al*$ddy] || $ddy < [expr $al*$ddx] }	{
			set xy1 [lindex $offset [expr int(rand()*8)]]
			set xy2 [lindex $offset [expr int(rand()*8)]]
			set sx1 [lindex $xy1 0]; set sy1 [lindex $xy1 1]
			set sx2 [lindex $xy2 0]; set sy2 [lindex $xy2 1]
			if	{ $ddx < [expr $al*$ddy] }	{
				set sx1 [expr $sx1*$sf*$ddy]; set sy1 [expr $sy1*$sf*$ddy]
				set sx2 [expr $sx2*$sf*$ddy]; set sy2 [expr $sy2*$sf*$ddy]
			}	else	{
				set sx1 [expr $sx1*$sf*$ddx]; set sy1 [expr $sy1*$sf*$ddx]
				set sx2 [expr $sx2*$sf*$ddx]; set sy2 [expr $sy2*$sf*$ddx]
			}
			set x1p [expr $blx+$sx1]; set y1p [expr $bly+$sy1]
			set x2p [expr $trx+$sx2]; set y2p [expr $try+$sy2]
			plot line -position $blx $bly $x1p $y1p -color $col -width $width
			plot line -position $trx $try $x2p $y2p -color $col -width $width
			plot line -position $x1p $y1p $x2p $y2p -color $col -width $width
			set cx [expr 0.5*($x1p+$x2p)]; set cy [expr 0.5*($y1p+$y2p)]
		}	else	{
			plot line -position $blx $bly $trx $try -color $col -width $width
			set cx [expr 0.5*($blx+$trx)]; set cy [expr 0.5*($bly+$try)]
		}
		__MMX::putMsg $txt $cx $cy $fs $fs $col 1 $d
		return	[list $ddx $ddy $cx $cy]
	}
	proc	drawRect	{ blx bly trx try {col 9} {width 1} }	{
		set color [getColorTxt $col]
		plot line -position $blx $bly $blx $try -color $color -width $width
		plot line -position $blx $try $trx $try -color $color -width $width
		plot line -position $trx $try $trx $bly -color $color -width $width
		plot line -position $trx $bly $blx $bly -color $color -width $width
	}
	proc	drawCircle	{ x y r {col 9} {width 1} }	{
		set color [getColorTxt $col]
		for {set d 0} {$d <= 90} {set d [expr $d+10]}	{
			set rad [expr $d*0.0174533]; set radr [expr (90-$d)*0.0174533]
			set x1 [expr $x+$r*cos($rad)]; set y1 [expr $y+$r*sin($rad)]
			set x2 [expr $x1-2*$r*cos($rad)]; set y2 [expr $y1-2*$r*sin($rad)]
			set x1r [expr $x+$r*cos($radr)]; set y1r [expr $y+$r*sin($radr)]
			set x2r [expr $x1r-2*$r*cos($radr)]; set y2r [expr $y1r-2*$r*sin($radr)]
			lappend posL1 [list $x1 $y1]; lappend posL3 [list $x2 $y2]
			lappend posL2 [list $x1r $y2r]; lappend posL4 [list $x2r $y1r]
		}
		set posL [concat $posL1 $posL4 $posL3 $posL2]
		set l [llength $posL]
		set xy [lindex $posL 0]; set px [lindex $xy 0]; set py [lindex $xy 1]
		for {set i 1} {$i < $l} {incr i}	{
			set xy [lindex $posL $i]; set x [lindex $xy 0]; set y [lindex $xy 1]
			plot line -position $px $py $x $y -color $color -width $width
			set px $x; set py $y
		}
	}
	proc	drawCrossedRect	{ blx bly trx try {col 9} {width 1} }	{
		set color [getColorTxt $col]
		plot line -position $blx $bly $blx $try -color $color -width $width
		plot line -position $blx $try $trx $try -color $color -width $width
		plot line -position $trx $try $trx $bly -color $color -width $width
		plot line -position $trx $bly $blx $bly -color $color -width $width
		plot line -position $blx $bly $trx $try -color $color -width $width
		plot line -position $blx $try $trx $bly -color $color -width $width
	}
	proc	drawStripedRect	{ blx bly trx try {col 9} {width 1} }	{
		set color [getColorTxt $col]
		plot line -position $blx $bly $blx $try -color $color -width $width
		plot line -position $blx $try $trx $try -color $color -width $width
		plot line -position $trx $try $trx $bly -color $color -width $width
		plot line -position $trx $bly $blx $bly -color $color -width $width
		set dx [expr {($trx-$blx)/4.0}]
		set dy [expr {($try-$bly)/4.0}]
		for	{set i [expr {$blx+$dx}]} {$i < $trx} {set i [expr $i+$dx]}	{
			plot line -position $i $bly $i $try -color $color -width $width
		}
		for	{set i [expr {$bly+$dy}]} {$i < $try} {set i [expr $i+$dy]}	{
			plot line -position $blx $i $trx $i -color $color -width $width
		}
	}
	proc	drawContact	{ x y {s 2} {col white} {width 1} }	{
		set x1 [expr {$x-$s}]; set y1 [expr {$y-$s}]
		set x2 [expr {$x+$s}]; set y2 [expr {$y+$s}]
		plot line -position $x1 $y1 $x1 $y2 -color $col -width $width
		plot line -position $x1 $y2 $x2 $y2 -color $col -width $width
		plot line -position $x2 $y2 $x2 $y1 -color $col -width $width
		plot line -position $x2 $y1 $x1 $y1 -color $col -width $width
		plot line -position $x1 $y1 $x2 $y2 -color $col -width $width
		plot line -position $x1 $y2 $x2 $y1 -color $col -width $width
	}
	proc	eng2val	{ args }	{
		regsub -nocase {(S|HZ|H)$} $args {} args
		regsub {(A|F)$} $args {} args
		regsub {([TGMkmunpf])f$} $args \1 args
		if	{ ![regexp {^(([+-]?)(\d|\.\d)\d*(\.\d*)?([Ee]([+-]?\d+))?)([TGMkmunpf]?)$} \
			$args match val 2 3 4 5 6 pfx] }	{
			error	"incorrect number or unit prefix (TGMkmunpf): $args"
		}
		switch	$pfx	{
			T	{ return [format "%e" [expr {$val * 1e12}]] }
			G	{ return [format "%e" [expr {$val * 1e9}]] }
			M	{ return [format "%e" [expr {$val * 1e6}]] }
			k	{ return [format "%e" [expr {$val * 1e3}]] }
			m	{ return [format "%e" [expr {$val * 1e-3}]] }
			u	{ return [format "%e" [expr {$val * 1e-6}]] }
			n	{ return [format "%e" [expr {$val * 1e-9}]] }
			p	{ return [format "%e" [expr {$val * 1e-12}]] }
			f	{ return [format "%e" [expr {$val * 1e-15}]] }
			default	{ return [format "%e" $val] }
		}
	}
	proc	getBinName	{ args }	{
		if	{ [file exists $args] }	{
			return	"./$args"
		}	elseif	{ [info exists ::env(APACHEROOT)] && [file exists "$::env(APACHEROOT)/scripts/$args"]	}	{
			return	"$::env(APACHEROOT)/scripts/$args"
		}	else	{
			return	"./$args"
		}
	}
	proc	getColorCode	{ val }	{
		#	0 =< val < 1
		set val [expr int([expr {$val * 16}])]
		if	{$val >= 16}	{ set val 15 }
		set col {#0000ff #0066ff #0099ff #00ccff #00ffff #00ffcc #00ff99 #00ff66 \
			#00ff33 #00ff00 #ffff00 #ffcc00 #ff9900 #ff6600 #ff3300 #ff0000}
		return	[lindex $col $val]
	}
	proc	getCC16	{ val }	{
		#	0 =< val < 16
		set val [expr {$val % 16}]
		set col {#0000ff #0066ff #0099ff #00ccff #00ffff #00ffcc #00ff99 #00ff66 \
			#00ff33 #00ff00 #ffff00 #ffcc00 #ff9900 #ff6600 #ff3300 #ff0000}
		return	[lindex $col $val]
	}
	proc	getColorTxt	{ val }	{
		#	0 =< val < 10
		set val [expr {$val % 10}]
		set col {brown red orange yellow green cyan blue purple grey white}
		return	[lindex $col $val]
	}
	proc	getVerNum	{}	{
		if	{ [catch { set ver [get ver] }] }	{ return -1 }
		return	[__MMX::ver2num $ver]
	}
	proc	putMsg	{ arg x y {w 6} {h 7} {c white} {lw 1} {d 0} }	{
		set len [string length $arg]
		if	{ $d }	{
			for	{set i 0} { $i < $len } {incr i}	{
				set char [string index $arg $i]
				if	{ $char == " " }	{
					set y [expr $y+$w]
					continue
				}
				set fV [expr {[info exists __MMX::fontVec($char)] ? \
					$__MMX::fontVec([string index $arg $i]) : $__MMX::fontVec(-)}]
				foreach	ld $fV	{
					set x1 [expr [lindex $ld 1]*$h/-7.0 + $x]
					set y1 [expr [lindex $ld 0]*$w/6.0 + $y]
					set x2 [expr [lindex $ld 3]*$h/-7.0 + $x]
					set y2 [expr [lindex $ld 2]*$w/6.0 + $y]
					plot line -position $x1 $y1 $x2 $y2 -color $c -width $lw
				}
				set y [expr $y+$w]
			}
		}	else	{
			for	{set i 0} { $i < $len } {incr i}	{
				set char [string index $arg $i]
				if	{ $char == " " }	{
					set x [expr $x+$w]
					continue
				}
				set fV [expr {[info exists __MMX::fontVec($char)] ? \
					$__MMX::fontVec([string index $arg $i]) : $__MMX::fontVec(-)}]
				foreach	ld $fV	{
					set x1 [expr [lindex $ld 0]*$w/6.0 + $x]
					set y1 [expr [lindex $ld 1]*$h/7.0 + $y]
					set x2 [expr [lindex $ld 2]*$w/6.0 + $x]
					set y2 [expr [lindex $ld 3]*$h/7.0 + $y]
					plot line -position $x1 $y1 $x2 $y2 -color $c -width $lw
				}
				set x [expr $x+$w]
			}
		}
	}
	proc	setCmdLog	{ flag }	{
		set cs [config cmdlog]
		config cmdlog $flag
		return	[lindex $cs end]
	}
	proc	val2eng	{ args }	{
		set val [eng2val $args]
		if	{ abs($val) >= 1e12 }	{ return [format "%.3fT" [expr {$val * 1e-12}]] }
		if	{ abs($val) >= 1e9 }	{ return [format "%.3fG" [expr {$val * 1e-9}]] }
		if	{ abs($val) >= 1e6 }	{ return [format "%.3fM" [expr {$val * 1e-6}]] }
		if	{ abs($val) >= 1e3 }	{ return [format "%.3fk" [expr {$val * 1e-3}]] }
		if	{ abs($val) >= 1 }	{ return [format "%.3f" $val] }
		if	{ abs($val) >= 1e-3 }	{ return [format "%.3fm" [expr {$val * 1e3}]] }
		if	{ abs($val) >= 1e-6 }	{ return [format "%.3fu" [expr {$val * 1e6}]] }
		if	{ abs($val) >= 1e-9 }	{ return [format "%.3fn" [expr {$val * 1e9}]] }
		if	{ abs($val) >= 1e-12 }	{ return [format "%.3fp" [expr {$val * 1e12}]] }
		if	{ abs($val) >= 1e-15 }	{ return [format "%.3ff" [expr {$val * 1e15}]] }
		return	[format "%.3f" $val]
	}
	proc	ver2num	{ ver }	{
		regexp {^(\S+)} $ver match ver; regsub -all {\.} $ver {} ver
		regsub {p} $ver {.} ver; regsub {[a-z].*} $ver {0} ver
		return	$ver
	}
	variable	mmxData
	variable	varMap
	set varList	{ \
		{max_allowed_peak_drop <mV>} \
		{max_allowed_average_drop <mV>} \
		{peak_count_threshold <%>} \
		{region {<llx lly urx ury>}} \
		{net <netName(s)>}
		{layer <layerName(s)>}
		{lower_limit <mV>}
		{upper_limit <mV>}
		{bin_size <mV>}
		{bin_number <integer>}
		{output_file <fileName>}
		{batch_file <fileName>}
		{viewer <commandName>}
	}
	foreach var $varList	{
		set __MMX::varMap([lindex $var 0]) [lindex $var 1]
	}	
}
proc	mmx_help	{}	{
	puts	"
	List of MMX Tcl Commands:

	mmx_dump_dvd
		- 
	mmx_plot_histogram
		- 
	mmx_plot_resistance_histogram
		-
	mmx_set
		-
	mmx_show_xtor
		-
	mmx_show_decap
		-
	mmx_show_decap_cell
		- display decap cells
	mmx_show_lef_pin
		-
	mmx_show_missing_via
		-
	mmx_show_inst_state
		- display instance state and timing
	mmx_add_decap_cell
		- place decap cells
	mmx_change_decap
		-
	mmx_clear
		- clear screen

	use -h option with each command for detailed information
"
}

proc	mmx_add_decap_cell_man	{}	{
	puts	"
	mmx_add_decap_cell
		-net <vddNet> <gndNet>
		-layer <layerName>
		?-region <llx lly urx ury>?
		?-cap <value>?
		?-res <value>?
		?-leak <value>?
		?-place?
		?-ncap <value>?
		?-overlay/-ov?

		-place   : execute 'eco add decap'
		-ncap    : specify # of decap cells per rail (default 10)
		-overlay : preserve previous drawing

	<usage>
		1. without -place : show p/g rails where decaps can be placed
		mmx_add_decap_cell -net VDD VSS -layer METAL3 -cap 100p

		2. with -place : place decap cells over the rails
		mmx_add_decap_cell -net VDD VSS -layer METAL3 -cap 100p -place
"
}
proc	mmx_add_decap_cell	{ args }	{
	set argv [split $args]

	set state option
	set useDebug 0; set useRegion 0; set useOverlay 0; set usePlace 0
	set res 0; set leak 0; set cap 0; set ncap 10
	foreach arg $argv	{
		switch	$state	{
			option	{
				switch -- $arg	{
					-layer	{ set state flag_layer }
					-net	{ set state flag_vdd }
					-region	{ set state flag_region_llx; set useRegion 1 }
					-cap	{ set state flag_cap }
					-res	{ set state flag_res }
					-leak	{ set state flag_leak }
					-ncap	{ set state flag_ncap }
					-place	{ set usePlace 1 }
					-debug	{ set useDebug 1 }
					-overlay	{ set useOverlay 1 }
					-ov	{ set useOverlay 1 }
					-h	{ mmx_add_decap_cell_man; return }
					-help	{ mmx_add_decap_cell_man; return }
					default		{ error	"unknown option: $arg" }
				}
			}
			flag_layer	{ set layer $arg; set state option }
			flag_vdd	{ set vdd $arg; set state flag_gnd }
			flag_gnd	{ set gnd $arg; set state option }
			flag_region_llx	{ set llx [__MMX::eng2val $arg]; set state flag_region_lly }
			flag_region_lly	{ set lly [__MMX::eng2val $arg]; set state flag_region_urx }
			flag_region_urx	{ set urx [__MMX::eng2val $arg]; set state flag_region_ury }
			flag_region_ury	{ set ury [__MMX::eng2val $arg]; set state option }
			flag_cap	{ set cap [expr [__MMX::eng2val $arg]*1e12]; set state option }
			flag_res	{ set res [__MMX::eng2val $arg]; set state option }
			flag_leak	{ set leak [__MMX::eng2val $arg]; set state option }
			flag_ncap	{ set ncap [__MMX::eng2val $arg]; set state option }
			default		{ error "internal error: $state" }
		}
	}
	if	{ [regexp {^flag} $state] }	{ error	"missing required option(s) or value(s)" }
	if	{ ![info exists vdd] }		{ error	"missing option: -net <vddNet> <gndNet>" }
	if	{ ![info exists layer] }	{ error	"missing option: -layer <layerName>" }
	if	{ $usePlace && $cap == 0 }	{ error "missing option: -cap <value>" }

	set cmdLog [__MMX::setCmdLog off]
	if	{ !$useRegion }	{
		set regionL [zoom get]
		set llx [lindex $regionL 0]; set lly [lindex $regionL 1]
		set urx [lindex $regionL 2]; set ury [lindex $regionL 3]
	}
	set dllx [__MMX::val2eng $llx]; set dlly [__MMX::val2eng $lly]
	set durx [__MMX::val2eng $urx]; set dury [__MMX::val2eng $ury]
	if	{ $llx > $urx || $lly > $ury }	{
		__MMX::setCmdLog $cmdLog
		error "incorrect range: -region $dllx $dlly $durx $dury"
	}
	puts	"info: region \[$dllx $dlly $durx $dury\]"
	set hCnt 0; set vCnt 0
	puts	"info: analyzing wires. please wait"; puts -nonewline ""
	foreach wire [get wire *]	{
		if	{ ![regexp "^(\\d+)\\s+($vdd|$gnd)\\s+$layer" $wire match id pg] }	{ continue }
		if	{ ![regexp {(\S+)\s+(\S+)\s+\((\S+),\s*(\S+)\)\s+\((\S+),\s*(\S+)\)\s+\((\S+),\s*(\S+)\)\s+\((\S+),\s*(\S+)\)} \
			$wire match w l x0 y0 x1 y1 x2 y2 x3 y3] }	{ continue }
		set xL [list $x0 $x1 $x2 $x3]; set yL [list $y0 $y1 $y2 $y3]
		set xL [lsort -real $xL]; set yL [lsort -real $yL]
		set x1 [lindex $xL 0]; set x2 [lindex $xL end]
		set y1 [lindex $yL 0]; set y2 [lindex $yL end]
		if	{ $x2 < $llx || $x1 > $urx || $y2 < $lly || $y1 > $ury }	{ continue }
		set dx [expr $x2-$x1]; set dy [expr $y2-$y1]
		if	{ $dy > $dx }	{
			set d 1; set vCnt [expr $vCnt+($dx*$dy)]
		}	else	{
			set d 0; set hCnt [expr $hCnt+($dx*$dy)]
		}
		if	{ [string compare $pg $vdd] }	{
			set gndWireRM($id,x1) $x1; set gndWireRM($id,y1) $y1
			set gndWireRM($id,x2) $x2; set gndWireRM($id,y2) $y2
			set gndWireDM($id) $d
		}	else	{
			set vddWireRM($id,x1) $x1; set vddWireRM($id,y1) $y1
			set vddWireRM($id,x2) $x2; set vddWireRM($id,y2) $y2
			set vddWireDM($id) $d
		}
#		if	{ $useDebug }	{ puts "debug: ID $id / PG $pg / BBOX $x1 $y1 $x2 $y2 / D $dx $dy / ISV $d" }
	}
	__MMX::setCmdLog $cmdLog
	if	{ $useDebug }	{ puts	"debug: hCnt = $hCnt / vCnt = $vCnt" }
	if	{ $hCnt == 0 && $vCnt == 0 }	{ error "wire not found. please check if region/net/layer are correct" }
	if	{ ![info exists vddWireDM] }	{ error "$vdd wire not found. please check if region/net/layer are correct" }
	if	{ ![info exists gndWireDM] }	{ error "$gnd wire not found. please check if region/net/layer are correct" }
	set isV [expr $vCnt > $hCnt ? 1 : 0]
	if	{ $useDebug }	{ puts	"debug: direction $isV" }

	# merge wires
	set vddGID 0; set vddWireL [array names vddWireDM]
	foreach id1 $vddWireL	{
		if	{ $vddWireDM($id1) != $isV }	{ continue }
		set x11 $vddWireRM($id1,x1); set y11 $vddWireRM($id1,y1)
		set x21 $vddWireRM($id1,x2); set y21 $vddWireRM($id1,y2)
		if	{ [info exists vddWGM($id1)] }	{
			set gId1 $vddWGM($id1)
		}	else	{
			set gId1 $vddGID; incr vddGID
			set vddWGM($id1) $gId1; set vddGWM($gId1,$id1) 1
		}
		foreach id2 $vddWireL	{
			if	{ $vddWireDM($id2) != $isV }	{ continue }
			if	{ $id1 == $id2 }	{ continue }
			set x12 $vddWireRM($id2,x1); set y12 $vddWireRM($id2,y1)
			set x22 $vddWireRM($id2,x2); set y22 $vddWireRM($id2,y2)
			if	{ $x11 > $x22 || $x21 < $x12 || $y11 > $y22 || $y21 < $y12 }	{ continue }
#			if	{ $useDebug }	{ puts "debug: $id1 and $id2 are connected" }
			if	{ [info exists vddWGM($id2)] && $vddWGM($id2) != $gId1 }	{
#				if	{ $useDebug }	{ puts "debug: $id2 has already GID $vddWGM($id2)" }
				set gId2 $vddWGM($id2)
				lappend vddAdjM($gId1) $gId2
				lappend vddAdjM($gId2) $gId1
			}	else	{
				set vddWGM($id2) $gId1; set vddGWM($gId1,$id2) 1
			}
		}
	}
	set gndGID 0; set gndWireL [array names gndWireDM]
	foreach id1 $gndWireL	{
		if	{ $gndWireDM($id1) != $isV }	{ continue }
		set x11 $gndWireRM($id1,x1); set y11 $gndWireRM($id1,y1)
		set x21 $gndWireRM($id1,x2); set y21 $gndWireRM($id1,y2)
		if	{ [info exists gndWGM($id1)] }	{
			set gId1 $gndWGM($id1)
		}	else	{
			set gId1 $gndGID; incr gndGID
			set gndWGM($id1) $gId1; set gndGWM($gId1,$id1) 1
		}
		foreach id2 $gndWireL	{
			if	{ $gndWireDM($id2) != $isV }	{ continue }
			if	{ $id1 == $id2 }	{ continue }
			set x12 $gndWireRM($id2,x1); set y12 $gndWireRM($id2,y1)
			set x22 $gndWireRM($id2,x2); set y22 $gndWireRM($id2,y2)
			if	{ $x11 > $x22 || $x21 < $x12 || $y11 > $y22 || $y21 < $y12 }	{ continue }
#			if	{ $useDebug }	{ puts "debug: $id1 and $id2 are connected" }
			if	{ [info exists gndWGM($id2)] && $gndWGM($id2) != $gId1 }	{
#				if	{ $useDebug }	{ puts "debug: $id2 has already GID $gndWGM($id2)" }
				set gId2 $gndWGM($id2)
				lappend gndAdjM($gId1) $gId2
				lappend gndAdjM($gId2) $gId1
			}	else	{
				set gndWGM($id2) $gId1; set gndGWM($gId1,$id2) 1
			}
		}
	}

	for	{set i 0} {$i < $vddGID} {incr i}	{
		if	{ [info exists vddDonM($i)] }	{ continue }
		set xL {}; set yL {}
		if	{ $useDebug }	{ puts "debug: processing group $i" }
		foreach	id [array names vddGWM $i,*]	{
			regexp {\S+,(\S+)} $id match id
			if	{ $useDebug }	{ puts "debug: group $i / wire $id" }
			set x1 $vddWireRM($id,x1); set y1 $vddWireRM($id,y1)
			set x2 $vddWireRM($id,x2); set y2 $vddWireRM($id,y2)
			lappend xL $x1;	lappend xL $x2; lappend yL $y1;	lappend yL $y2
		}
		if	{ [info exists vddAdjM($i)] }	{
			if	{ $useDebug }	{ puts "debug: processing eqv group $i" }
			foreach g $vddAdjM($i)	{
				foreach	id [array names vddGWM $g,*]	{
					regexp {\S+,(\S+)} $id match id
					if	{ $useDebug }	{ puts "debug: eqv group $g / wire $id" }
					set x1 $vddWireRM($id,x1); set y1 $vddWireRM($id,y1)
					set x2 $vddWireRM($id,x2); set y2 $vddWireRM($id,y2)
					lappend xL $x1;	lappend xL $x2; lappend yL $y1;	lappend yL $y2
				}
				set vddDonM($g) 1
			}
		}
		set xL [lsort -real $xL]; set yL [lsort -real $yL]
		set x1 [lindex $xL 0]; set x2 [lindex $xL end]
		set y1 [lindex $yL 0]; set y2 [lindex $yL end]
		set cx [expr ($x1+$x2)/2]; set cy [expr ($y1+$y2)/2]
		set dx [expr $x2-$x1]; set dy [expr $y2-$y1]
		set vddXWM($cx) [expr $dx/2]; set vddYWM($cy) [expr $dy/2]
		if	{ [info exists vddXLM($cx)] }	{
			set vddXLM($cx) [expr $vddXLM($cx)+$dy]
		}	else	{
			set vddXLM($cx) $dy
		}
		if	{ [info exists vddYLM($cy)] }	{
			set vddYLM($cy) [expr $vddYLM($cy)+$dx]
		}	else	{
			set vddYLM($cy) $dx
		}
	}

	for	{set i 0} {$i < $gndGID} {incr i}	{
		if	{ [info exists gndDonM($i)] }	{ continue }
		set xL {}; set yL {}
		if	{ $useDebug }	{ puts "debug: processing group $i" }
		foreach	id [array names gndGWM $i,*]	{
			regexp {\S+,(\S+)} $id match id
			if	{ $useDebug }	{ puts "debug: group $i / wire $id" }
			set x1 $gndWireRM($id,x1); set y1 $gndWireRM($id,y1)
			set x2 $gndWireRM($id,x2); set y2 $gndWireRM($id,y2)
			lappend xL $x1;	lappend xL $x2; lappend yL $y1;	lappend yL $y2
		}
		if	{ [info exists gndAdjM($i)] }	{
			if	{ $useDebug }	{ puts "debug: processing eqv group $i" }
			foreach g $gndAdjM($i)	{
				foreach	id [array names gndGWM $g,*]	{
					regexp {\S+,(\S+)} $id match id
					if	{ $useDebug }	{ puts "debug: eqv group $g / wire $id" }
					set x1 $gndWireRM($id,x1); set y1 $gndWireRM($id,y1)
					set x2 $gndWireRM($id,x2); set y2 $gndWireRM($id,y2)
					lappend xL $x1;	lappend xL $x2; lappend yL $y1;	lappend yL $y2
				}
				set gndDonM($g) 1
			}
		}
		set xL [lsort -real $xL]; set yL [lsort -real $yL]
		set x1 [lindex $xL 0]; set x2 [lindex $xL end]
		set y1 [lindex $yL 0]; set y2 [lindex $yL end]
		set cx [expr ($x1+$x2)/2]; set cy [expr ($y1+$y2)/2]
		set dx [expr $x2-$x1]; set dy [expr $y2-$y1]
		set gndXWM($cx) [expr $dx/2]; set gndYWM($cy) [expr $dy/2]
		if	{ [info exists gndXLM($cx)] }	{
			set gndXLM($cx) [expr $gndXLM($cx)+$dy]
		}	else	{
			set gndXLM($cx) $dy
		}
		if	{ [info exists gndYLM($cy)] }	{
			set gndYLM($cy) [expr $gndYLM($cy)+$dx]
		}	else	{
			set gndYLM($cy) $dx
		}
	}

	if	{ $isV }	{
		set vddXL [lsort -real [array names vddXLM]]
		set vddRCnt 0; set gndRCnt 0
		foreach x $vddXL	{
			if	{ $vddXLM($x) < [expr ($ury-$lly)*0.7] }	{ set vddXDM($x) 1; continue }
			incr vddRCnt
			if { $useDebug }	{
				plot line -position $x $lly $x $ury -color red
			}
			
		}
		set gndXL [lsort -real [array names gndXLM]]
		foreach x $gndXL	{
			if	{ $gndXLM($x) < [expr ($ury-$lly)*0.7] }	{ set gndXDM($x) 1; continue }
			incr gndRCnt
			if { $useDebug }	{
				plot line -position $x $lly $x $ury -color cyan
			}
		}
	}	else	{
		set vddYL [lsort -real [array names vddYLM]]
		set vddRCnt 0; set gndRCnt 0
		foreach y $vddYL	{
			if	{ $vddYLM($y) < [expr ($urx-$llx)*0.7] }	{ set vddYDM($y) 1; continue }
			incr vddRCnt
			if { $useDebug }	{
				plot line -position $llx $y $urx $y -color red
			}
		}
		set gndYL [lsort -real [array names gndYLM]]
		foreach y $gndYL	{
			if	{ $gndYLM($y) < [expr ($urx-$llx)*0.7] }	{ set gndYDM($y) 1; continue }
			incr gndRCnt
			if { $useDebug }	{
				plot line -position $llx $y $urx $y -color cyan
			}
		}
	}
	if	{ $useDebug }	{ puts "debug: VDD rail(s) $vddRCnt / GND rail(s) $gndRCnt" }
	if	{ $vddRCnt == 0 || $gndRCnt == 0 }	{ error "wires are too short" }
	if	{ $isV }	{
		# VERTICAL & VDD RAIL FIRST
		if	{ $vddRCnt < $gndRCnt }	{
			foreach vddX $vddXL	{
				if	{ [info exists vddXDM($vddX)] }	{ continue }
				set minDX 1e99
				foreach gndX $gndXL	{
					if	{ [info exists gndXDM($gndX)] }	{ continue }
					set dx [expr abs($vddX-$gndX)]
					if	{ $dx < $minDX }	{ set minDX $dx; set minX $gndX }
				}
				lappend railL [list $vddX $minX]
				if	{ $useDebug }	{ puts "debug: P $vddX / G $minX" }
				set gndXDM($minX) 1
				foreach vddX $vddXL	{
					if	{ $vddX < $minX }	{ set vddXDM($vddX) 1 }
				}
			}
		# VERTICAL & GND RAIL FIRST
		}	else	{
			foreach gndX $gndXL	{
				if	{ [info exists gndXDM($gndX)] }	{ continue }
				set minDX 1e99
				foreach vddX $vddXL	{
					if	{ [info exists vddXDM($vddX)] }	{ continue }
					set dx [expr abs($vddX-$gndX)]
					if	{ $dx < $minDX }	{ set minDX $dx; set minX $vddX }
				}
				lappend railL [list $minX $gndX]
				set vddXDM($minX) 1
				foreach gndX $gndXL	{
					if	{ $gndX < $minX }	{ set gndXDM($gndX) 1 }
				}
			}
		}
	}	else	{
		# HORIZONTAL & VDD RAIL FIRST
		if	{ $vddRCnt < $gndRCnt }	{
			foreach vddY $vddYL	{
				if	{ [info exists vddYDM($vddY)] }	{ continue }
				set minDY 1e99
				foreach gndY $gndYL	{
					if	{ [info exists gndYDM($gndY)] }	{ continue }
					set dy [expr abs($vddY-$gndY)]
					if	{ $dy < $minDY }	{ set minDY $dy; set minY $gndY }
				}
				lappend railL [list $vddY $minY]
				set gndYDM($minY) 1
				foreach vddY $vddYL	{
					if	{ $vddY < $minY }	{ set vddYDM($vddY) 1 }
				}
			}
		# HORIZONTAL & GND RAIL FIRST
		}	else	{
			foreach gndY $gndYL	{
				if	{ [info exists gndYDM($gndY)] }	{ continue }
				set minDY 1e99
				foreach vddY $vddYL	{
					if	{ [info exists vddYDM($vddY)] }	{ continue }
					set dy [expr abs($vddY-$gndY)]
					if	{ $dy < $minDY }	{ set minDY $dy; set minY $vddY }
				}
				lappend railL [list $minY $gndY]
				set vddYDM($minY) 1
				foreach gndY $gndYL	{
					if	{ $gndY < $minY }	{ set gndYDM($gndY) 1 }
				}
			}
		}
	}

	set cmdLog [__MMX::setCmdLog off]
	if	{ $useOverlay == 0 }	{ plot line -clearall; marker delete -all; select clearall; refresh }
	set nRail [llength $railL]
	set nCell [expr $ncap*$nRail]
	set uCap [format "%.3f" [expr $cap/double($nCell)]]
	set nPlaced 0; set nMissed 0
	if	{ $isV }	{
		set cw [expr ($ury-$lly)/double($ncap)]
	}	else	{
		set cw [expr ($urx-$llx)/double($ncap)] 
	}
	if	{ $usePlace }	{
		set decapGL [gsr get decap_cell]
		if	{ [__MMX::getVerNum] >= 910 && [string equal [lindex $decapGL 0] #] }	{ set decapGL {} }
		set railId 0
		foreach	rail $railL	{
			set p [lindex $rail 0]; set g [lindex $rail 1]
			set ch [expr abs($p-$g)]
			set uRes [expr $res*$nCell]
			set uLeak [expr $leak/double($nCell)]
			set eFlag 0
			foreach	decap $decapGL	{
				set i [split $decap];
				if	{ [llength $i] < 7 } { lappend i 0 }
				set gn [lindex $i 0]; set cnM($gn) 1
				set gw [lindex $i 1]; set gh [lindex $i 2]; set gc [lindex $i 3]
				set gr [lindex $i 4]; set gm [lindex $i 5]; set gl [lindex $i 6]
				set g [format "%f %f %e %e %s %e" $gw $gh $gc $gr $gm $gl]
				set i [format "%f %f %e %e %s %e" $cw $ch $uCap $uRes $layer $uLeak]
				if	{ [string equal $i $g] } { set eFlag 1; break; }
			}
			if	{ $eFlag == 1 }	{
				set capName $gn
			}	else	{
#				set capName [format "%s_%.1f_%.1f_%.1f_%d" $metal $uCap $uRes $uLeak $railId]
				set capName [format "c%df_%d" [expr int($uCap*1000)] $railId]
				while	{ [info exists cnM($capName)] }	{
#					error "internal error: duplicated decap cell $capName"
					set capName "$capName\c"
				}
				set i [format "%s %f %f %e %e %s %e"	\
					$capName $cw $ch $uCap $uRes $layer $uLeak]
				lappend decapGL $i
				lappend decapL $i
			}
			set capM($railId) $capName
			incr railId
		}
		if	{ [info exists decapL] } { gsr append decap_cell $decapL }
	}
	set railId 0
	foreach	rail $railL	{
		set p [lindex $rail 0]; set g [lindex $rail 1]
		if	{ $isV }	{
			if	{ $usePlace == 0 } 	{
				set pm [expr $p-$vddXWM($p)]; set pp [expr $p+$vddXWM($p)]
				set gm [expr $g-$gndXWM($g)]; set gp [expr $g+$gndXWM($g)]
				__MMX::drawRect $pm $lly $pp $ury 3 2
				__MMX::drawRect $gm $lly $gp $ury 9 2
			}
			set n [expr int($ncap)]
			for	{ set i 0 } { $i < $n } { incr i }	{
				set ii [expr $lly+($i*$cw)]
				if	{ $usePlace  } 	{
					set rstList [eco add decap -metal $layer -decap $capM($railId) -power $p $ii -ground $g $ii]
					if	{ ![regexp {there} $rstList] }	{
						set clr 2
						incr nPlaced
					}	else	{
						set clr 4
						incr nMissed
					}
					if	{ $p > $g }	{
						__MMX::drawCrossedRect $g $ii $p [expr $ii+$cw] $clr 1
					}	else	{
						__MMX::drawCrossedRect $p $ii $g [expr $ii+$cw] $clr 1
					}
				}	else	{
					__MMX::addMarker $p $ii orange 4 
					__MMX::addMarker $g $ii white 4 
				}
			}
		}	else	{
			if	{ $usePlace == 0 } 	{
				set pm [expr $p-$vddYWM($p)]; set pp [expr $p+$vddYWM($p)]
				set gm [expr $g-$gndYWM($g)]; set gp [expr $g+$gndYWM($g)]
				__MMX::drawRect $llx $pm $urx $pp 3 2
				__MMX::drawRect $llx $gm $urx $gp 9 2
			}
			set n [expr int($ncap)]
			for	{ set i 0 } { $i < $n } { incr i }	{
				set ii [expr $llx+($i*$cw)]
				if	{ $usePlace } 	{
					set rstList [eco add decap -metal $layer -decap $capM($railId) -power $ii $p -ground $ii $g]
					if	{ ![regexp {there} $rstList] }	{
						set clr 2
						incr nPlaced
					}	else	{
						set clr 4
						incr nMissed
					}
					if	{ $p > $g }	{
						__MMX::drawCrossedRect $ii $g [expr $ii+$cw] $p $clr 1
					}	else	{
						__MMX::drawCrossedRect $ii $p [expr $ii+$cw] $g $clr 1
					}
				}	else	{
					__MMX::addMarker $ii $p orange 4 
					__MMX::addMarker $ii $g white 4 
				}
			}
		}
		incr railId
	}
	__MMX::setCmdLog $cmdLog
	puts	"info: $nRail pg rail(s) in the region"
	puts	"info: [expr int($ncap)] decap cell(s)/rail"
	puts	"info: number of decap cells to be placed: [expr int($nCell)]"
	puts	"info: capacitance of unit cell: [__MMX::val2eng [expr $uCap*1e-12]]F"
	puts	"info: resistance of unit cell: [__MMX::val2eng [expr $res*$nCell]]ohm"
	puts	"info: leakage of unit cell: [__MMX::val2eng [expr $leak/double($nCell)]]A"
	if	{ $usePlace } 	{
		puts	"info: successfully placed: $nPlaced cell(s)"
		puts	"info: unsuccessfully placed: $nMissed cell(s)"
		puts	"info: total capacitance of placed cell(s): [__MMX::val2eng [expr $nPlaced*$uCap*1e-12]]F"
		puts	"info: please perform extraction and run dynamic analysis"
	}	else	{
		puts	"info: please use -place option to place decap cells"
	}
}
proc	mmx_clear_man	{}	{
	puts	"
	mmx_clear
		?-sa?

		-sa : show all nets and layers after clear screen

	<usage>
		mmx_clear
		mmx_clear -sa
"
}
proc	mmx_clear	{ args }	{
	__MMX::checkVer 8.1.4
	set argv [split $args]
	set useSA 0
	set cState option; set pState na
	foreach arg $argv	{
		switch	$cState	{
			option	{
				switch -- $arg	{
					-sa		{ set pState na; set useSA 1 }
					-h		{ mmx_clear_man; return }
					-help		{ mmx_clear_man; return }
					default		{ error "unknown option: $arg" }
				}
			}
			default		{ error "internal error: $cState" }
		}
	}
	if	{ [regexp {^flag} $cState] }	{ error "missing required option(s) or value(s)" }
	set cmdLog [__MMX::setCmdLog off]
	plot line -clearall; marker delete -all; select clearall; refresh
	if	{ $useSA }	{
		show sa
		config viewnet -name all -mode on
		config viewlayer -name all -style fill
		config viewlayer -name instance -style outline
	}
	__MMX::setCmdLog $cmdLog
	return
}
proc	mmx_change_decap_man	{}	{
	puts	"
	mmx_change_decap
		-pg <p1> <g1> ... -pg <pN> <gN>
		-region <llx1 lly1 urx1 ury1> ... -region <llxN llyN urxN uryN> 
		?-o <output_file>?
		?-cap <c1> ... -cap <cN>?
		?-res <r1> ... -res <rN>?
		?-leakage <l1> ... -leakage <lN>?
		?-change?
		?-run?

		# possible format of cap/res/leakage : <value/#x/->
		# 'value' : F/ohm/A
		# '#x' : multiplied factor (ex) 2x, 3x, 0.5x
		# '-'  : don't change
		# -change : to change cdev
		# -run : to change cdev and run dynamic analysis
"
}
proc	mmx_change_decap	{ args }	{
	__MMX::checkVer 8.1.4
	set argv [split $args]
	if	{ [llength $argv] == 0 }	{ mmx_change_decap_man; return }
	set state option; set run 0; set change 0; set cdevFile {custom.cdev}
	foreach arg $argv	{
		switch	$state	{
			option	{
				switch -- $arg	{
					-pg	{ set state flag_pg_power }
					-region	{ set state flag_region_x1 }
					-cap	{ set state flag_cap }
					-res	{ set state flag_res }
					-leakage	{ set state flag_leakage }
					-o	{ set state flag_o }
					-change	{ set change 1 }
					-run	{ set change 1; set run 1 }
					-h	{ mmx_change_decap_man; return }
					-help	{ mmx_change_decap_man; return }
					default { error "unknown option: $arg" }
				}
			}
			flag_pg_power	{ set pgMap($arg) 1; set state flag_pg_ground }
			flag_pg_ground	{ set pgMap($arg) 1; set state option }
			flag_o		{ set cdevFile $arg; set state option }
			flag_region_x1	{ lappend x1L [__MMX::eng2val $arg]; set state flag_region_y1 }
			flag_region_y1	{ lappend y1L [__MMX::eng2val $arg]; set state flag_region_x2 }
			flag_region_x2	{ lappend x2L [__MMX::eng2val $arg]; set state flag_region_y2 }
			flag_region_y2	{ lappend y2L [__MMX::eng2val $arg]; set state option }
			flag_cap	{
				if	{ [regexp {^-$} $arg] || [regexp -nocase {\S+x} $arg] }	{
					lappend capL $arg
				}	else	{
					lappend capL [__MMX::eng2val $arg]
				}
				set state option
			}
			flag_res	{
				if	{ [regexp {^-$} $arg] || [regexp -nocase {\S+x} $arg] }	{
					lappend resL $arg
				}	else	{
					lappend resL [__MMX::eng2val $arg]
				}
				set state option
			}
			flag_leakage	{
				if	{ [regexp {^-$} $arg] || [regexp -nocase {\S+x} $arg] }	{
					lappend leakL $arg
				}	else	{
					lappend leakL [__MMX::eng2val $arg]
				}
				set state option
			}
			default		{ error "internal error: $state" }
		}
	}
	if	{ [regexp {^flag} $state] }	{ error	"missing required option(s) or value(s)" }
	if	{ ![array exists pgMap] }	{ error	"missing option: -pg <power> <ground>" }
	if	{ ![info exists x1L] }		{ error "missing option: -region <llx lly urx ury>" }

	set bFile {.show.decap.l}
	set gpdciBin [__MMX::getBinName gpdci]
	if	{ ![file exists $bFile] || \
		[expr [file mtime $bFile]-[file mtime ".apache/cell.cdev"]] != 0 }	{
		exec $gpdciBin -rhdir . -o $bFile
	}
	if	[catch { open $bFile r } FF]	{ error	"file not found: $bFile" }
	mmx_clear
	set cmdLog [__MMX::setCmdLog off]
	while	{[gets $FF line] >= 0}	{
		if	{ [regexp {(\S+) (\S+) (\S+) (\S+) (\S+) (\S+) (\S+)} \
			$line match xtor p px py g gx gy] }	{
			set pName [lindex [split $p .] 0]; set gName [lindex [split $g .] 0]
			if	{ ![info exists pgMap($pName)] }	{ continue }
			if	{ ![info exists pgMap($gName)] }	{ continue }
			for	{ set i 0 } { $i < [llength $x1L] } { incr i }	{
				set x1 [lindex $x1L $i]
				set y1 [lindex $y1L $i]
				set x2 [lindex $x2L $i]
				set y2 [lindex $y2L $i]
				if	{ !($px >= $x1 && $px <= $x2 && $py >= $y1 && $py <= $y2 && \
					$gx >= $x1 && $gx <= $x2 && $gy >= $y1 && $gy <= $y2) }	{ continue }
				lappend rplMap($i) "$p $g"
				if	{ $run == 0 }	{
					__MMX::drawLine $px $py $gx $gy [expr $i+4]
					__MMX::addMarker $px $py white 4
					__MMX::addMarker $gx $gy white 4
				}
			}
		}	else	{ __MMX::setCmdLog $cmdLog; error "internal error" }
	}
	close	$FF
	if	{ $run == 0 }	{
		for	{ set i 0 } { $i < [llength $x1L] } { incr i }	{
			set x1 [lindex $x1L $i]
			set y1 [lindex $y1L $i]
			set x2 [lindex $x2L $i]
			set y2 [lindex $y2L $i]
			__MMX::drawRect $x1 $y1 $x2 $y2 [expr $i+4] 2
		}
	}
	__MMX::setCmdLog $cmdLog
	set dataFile {.change.decap}
	if	[catch { open $dataFile w } DD]	{ error	"can't create a file: $dataFile" }
	for	{ set i 0 } { $i < [llength $x1L] } { incr i }	{
		puts	"\n><>< INFO @ [string toupper [__MMX::getColorTxt [expr $i+4]]] ><><"
		if	{ [info exists rplMap($i)] }	{
			set nDev [llength $rplMap($i)]
			puts	"decap devices: $nDev"
		}	else	{ puts	"no decap devices"; continue }
		if	{ [info exists capL] && $i < [llength $capL] }	{
			set capT [lindex $capL $i]
			if	{ ![regexp {^-$} $capT] && ![regexp -nocase {\S+x} $capT] }	{
				set cap [__MMX::eng2val [expr $capT/double($nDev)]]
				puts	"target cap : $capT F ($cap F/decap)"
				set cap [__MMX::eng2val [expr $cap*2e12]]
			}	else	{ set cap $capT; puts	"target cap : $cap" }
		}	else	{ set cap - }
		if	{ [info exists resL] && $i < [llength $resL] }	{
			set resT [lindex $resL $i]
			if	{ ![regexp {^-$} $resT] && ![regexp -nocase {\S+x} $resT] }	{
				set res [__MMX::eng2val [expr $resT*double($nDev)]]
				puts	"target res : $resT ohm ($res ohm/decap)"
				set res [__MMX::eng2val [expr $res/2.0]]
			}	else	{ set res $resT; puts	"target res : $res" }
		}	else	{ set res - }
		if	{ [info exists leakL] && $i < [llength $leakL] }	{
			set leakT [lindex $leakL $i]
			if	{ ![regexp {^-$} $leakT] && ![regexp -nocase {\S+x} $leakT] }	{
				set leak [__MMX::eng2val [expr $leakT/double($nDev)]]
				puts	"target leakage : $leakT A ($leak A/decap)"
			}	else	{ set leak $leakT; puts	"target leakage : $leak" }
		}	else	{ set leak - }		
		foreach	ppp $rplMap($i)	{
			if	{ $cap != "-" || $res != "-" || $leak != "-" }	{
				set temp [split $ppp]
				puts	$DD	"[lindex $temp 0] $cap $res $leak"
				puts	$DD	"[lindex $temp 1] $cap $res $leak"
			}
		}
	}
	close	$DD
	if	{ $change == 1 }	{
		puts	"\ngenerating $cdevFile..."
		set rnmcvBin [__MMX::getBinName rnmcv]
		exec $rnmcvBin -scdev .apache/cell.cdev -dcdev $cdevFile -import .change.decap
		puts	"completed..."
	}
	if	{ $run == 1 }	{
		import apl -c $cdevFile
		perform analysis -vectorless
	}
}
proc	mmx_dump_dvd_man	{}	{
	puts	"
	mmx_dump_dvd
		-o <output_file>
		?-index_range <from> <to>?
		?-region <llx lly urx ury>?
		?-time_base <time>?
		?-nocap?
		?-pwl?

		# -index_range : to dump waveforms only in the range (default: 0 ~ 999)
		# -time_base : to set the time base of waveforms
		# -nocap : to exclude decap xtors
		# -pwl : to generate pwl
"
}
proc	mmx_dump_dvd	{ args }	{
	__MMX::checkVer 8.1.4
	set argv [split $args]
	if	{ [llength $argv] == 0 }	{ mmx_dump_dvd_man; return }
	set indexFrom 0; set indexTo 999
	set x1 -1e99; set y1 -1e99; set x2 1e99; set y2 1e99
	set timeBase 0; set noCap 0; set pwl 0
	set state option
	foreach arg $argv	{
		switch $state	{
			option	{
				switch -- $arg	{
					-o		{ set state flag_outfile }
					-index_range	{ set state flag_index_range_from }
					-region		{ set state flag_region_x1 }
					-time_base	{ set state flag_time_base }
					-nocap		{ set noCap 1 }
					-pwl		{ set pwl 1 }
					-h		{ mmx_dump_dvd; return }
					-help		{ mmx_dump_dvd; return }
					default		{ error	"unknown option: $arg" }
				}
			}
			flag_outfile	{ set outFile $arg; set state option }
			flag_index_range_from	{ set indexFrom $arg; set state flag_index_range_to }
			flag_index_range_to	{ set indexTo $arg; set state option }
			flag_region_x1	{ set x1 $arg; set state flag_region_y1 }
			flag_region_y1	{ set y1 $arg; set state flag_region_x2 }
			flag_region_x2	{ set x2 $arg; set state flag_region_y2 }
			flag_region_y2	{ set y2 $arg; set state option }
			flag_time_base	{ set timeBase [__MMX::eng2val $arg]; set state option }
			default		{ error "internal error: $state" }
		}
	}
	if	{ [regexp {^flag} $state] }	{ error	"missing required option(s) or value(s)" }
	if	{ ![info exists outFile] }	{ error	"missing option: -o <output_file>" }

	set bFile {.show.decap.l}
	set cFile {.dump.dvd.cap}
	set gpdciBin [__MMX::getBinName gpdci]
	if	{ ![file exists $bFile] || \
		[expr [file mtime $bFile]-[file mtime ".apache/cell.cdev"]] != 0 }	{
		exec $gpdciBin -rhdir . -o $bFile
	}
	if	[catch { open $bFile r } FF]	{ error	"file not found: $bFile" }
	if	[catch { open $cFile w } DD]	{ error	"can't create a file: $cFile" }
	while	{[gets $FF line] >= 0}	{
		if	{ [regexp {(\S+) (\S+) (\S+) (\S+) (\S+)} \
			$line match xtor p px py g] }	{
			puts	$DD	$p
			puts	$DD	$g
		}
	}
	close	$FF
	close	$DD
	set extract_mmxBin [__MMX::getBinName extract_mmx]
	set argu "-rhDir . -o $outFile -index $indexFrom $indexTo -region $x1 $y1 $x2 $y2 -timeShift $timeBase"
	if	{ $noCap }	{ append argu " -exclude $cFile" }
	if	{ $pwl }	{ append argu " -pwl" }
	eval "exec $extract_mmxBin $argu"
	if	{ $noCap }	{ file delete -force $cFile }
	puts	"completed..."
}
proc	mmx_show_missing_via_man	{}	{
	puts	"
	mmx_show_missing_via
		-range <minV> <maxV>
		?-pg <net1> ... -pg <netN>?
		?-gif <file_name>?

		# -range : to set the color range of voltage difference
"
}
proc	mmx_show_missing_via	{ args }	{
	__MMX::checkVer 8.1.4
	set argv [split $args]
	if	{ [llength $argv] == 0 }	{ mmx_show_missing_via_man; return }
	set state option
	foreach arg $argv	{
		switch	$state	{
			option	{
				switch -- $arg	{
					-range	{ set state flag_range_min }
					-pg	{ set state flag_pg }
					-gif	{ set state flag_gif }
					-h	{ mmx_show_missing_via_man; return }
					-help	{ mmx_show_missing_via_man; return }
					default { error "unknown option: $arg" }
				}
			}
			flag_range_min	{ set min [__MMX::eng2val $arg]; set state flag_range_max }
			flag_range_max	{ set max [__MMX::eng2val $arg]; set state option }
			flag_pg		{ set pgMap($arg) 1; set state option }
			flag_gif	{ set gif $arg; set state option }
			default		{ error "internal error: $state" }
		}
	}
	if	{ [regexp {^flag} $state] }	{ error	"missing required option(s) or value(s)" }
	if	{ ![info exists min] }	{ error	"missing option: -range <minV> <maxV>" }
	if	{ $min >= $max }	{ error	"incorrect range: \[ $min, $max \]" }
	set rptName {adsRpt/apache.missingVias}
	if	{ ![file exists $rptName] }	{ mesh vias -report_missing -gds }
	if	[catch { open $rptName r } FD]	{ error	"file not found: $rptName" }
	puts	"reading .missingVias..."
	mmx_clear
	set index 0
        while	{[gets $FD line] >= 0}	{
		if	{ ![regexp {^#} $line]}	{
			set pg [lindex $line 0]
	                set xPos [lindex $line 3]
        	        set yPos [lindex $line 4]
	                set vDiff [expr {abs([lindex $line 5])}]
			set pgArr($index) $pg
			set xArr($index) $xPos
			set yArr($index) $yPos
			set vArr($index) $vDiff
			incr index
		}
	}
        close	$FD
	puts	"$index missingVia(s) found..."
	set range [expr {$max - $min}]
	set nVia 0
	set cmdLog [__MMX::setCmdLog off]
	for	{ set i 0 } { $i < $index } { incr i }	{
		if	{ ![array exists pgMap] || [info exists pgMap($pgArr($i))] }	{
			if	{ $vArr($i) >= $min }	{
				set val [expr {($vArr($i)-$min)/double($range)}]
				__MMX::addMarker	$xArr($i) $yArr($i) [__MMX::getColorCode $val] 4
				incr nVia
			}
		}
	}
	puts	"$nVia missingVia(s) displayed..."
	if	{ [info exists gif] }	{ dump gif -o $gif }
	__MMX::setCmdLog $cmdLog
	return
}
proc	mmx_show_decap_man	{}	{
	puts	"
	mmx_show_decap
		-pg <p1> <g1> ... -pg <pN> <gN>
		?-region <llx lly urx ury>?
		?-name?
		?-conn?
		?-mono?

		# -name : to show decap names
		# -conn : to show pg connectivity
		# -mono : to use monochrome markers (faster)
"
}
proc	mmx_show_decap	{ args }	{
	__MMX::checkVer 8.1.4
	set argv [split $args]
	if	{ [llength $argv] == 0 }	{ mmx_show_decap_man; return }
	set state option
	set mono 0; set conn 0; set name 0; set useRegion 0; set maxCap -1; set tCap 0
	foreach arg $argv	{
		switch	$state	{
			option	{
				switch -- $arg	{
					-pg	{ set state flag_pg_power }
					-region	{ set state flag_region_x1; set useRegion 1 }
					-mono	{ set mono 1 }
					-conn	{ set conn 1 }
					-name	{ set name 1 }
					-h	{ mmx_show_decap_man; return }
					-help	{ mmx_show_decap_man; return }
					default { error "unknown option: $arg" }
				}
			}
			flag_pg_power	{ set pgMap($arg) 1; set state flag_pg_ground }
			flag_pg_ground	{ set pgMap($arg) 1; set state option }
			flag_region_x1	{ set x1 [__MMX::eng2val $arg]; set state flag_region_y1 }
			flag_region_y1	{ set y1 [__MMX::eng2val $arg]; set state flag_region_x2 }
			flag_region_x2	{ set x2 [__MMX::eng2val $arg]; set state flag_region_y2 }
			flag_region_y2	{ set y2 [__MMX::eng2val $arg]; set state option }
			default		{ error "internal error: $state" }
		}
	}
	if	{ [regexp {^flag} $state] }	{ error	"missing required option(s) or value(s)" }
	if	{ ![array exists pgMap] }	{ error	"missing option: -pg <power> <ground>" }

	set bFile {.show.decap.l}
	set fFile {.show.decap.lcrl}
	set gpdciBin [__MMX::getBinName gpdci]
	if	{ $mono == 1 }	{
		if	{ ![file exists $bFile] || \
			[expr [file mtime $bFile]-[file mtime ".apache/cell.cdev"]] != 0 }	{
			exec $gpdciBin -rhdir . -o $bFile
		}
		if	[catch { open $bFile r } FF]	{ error	"file not found: $bFile" }
	}	else	{
		if	{ ![file exists $fFile] || \
			[expr [file mtime $fFile]-[file mtime ".apache/cell.cdev"]] != 0 }	{
			exec $gpdciBin -rhdir . -o $fFile -c
		}
		if	[catch { open $fFile r } FF]	{ error	"file not found: $fFile" }
	}
	while	{[gets $FF line] >= 0}	{
		if	{ [regexp {(\S+) (\S+) (\S+) (\S+) (\S+) (\S+) (\S+) (\S+) (\S+) (\S+)} \
			$line match xtor p px py g gx gy c r l] }	{
			set pName [lindex [split $p .] 0]; set gName [lindex [split $g .] 0]
			if	{ ![info exists pgMap($pName)] }	{ continue }
			if	{ ![info exists pgMap($gName)] }	{ continue }
			if	{ $useRegion == 1 && !($px >= $x1 && $px <= $x2 && $py >= $y1 && $py <= $y2 && \
				$gx >= $x1 && $gx <= $x2 && $gy >= $y1 && $gy <= $y2) }	{ continue }
			lappend xtorL $xtor
			set pMap($xtor) $p; set pxMap($xtor) $px; set pyMap($xtor) $py
			set gMap($xtor) $g; set gxMap($xtor) $gx; set gyMap($xtor) $gy
			set cMap($xtor) $c; set rMap($xtor) $r; set lMap($xtor) $l
			if	{ $mono == 0 }	{
				if	{ $maxCap < $c }	{ set maxCap $c }
				set tCap [expr $tCap+$c]
			}
		}	else	{ error "internal error" }
	}
	close	$FF
	if	{ ![info exists xtorL] }	{ error	"can't find decap devices: incorrect region/pg?" }
	mmx_clear
	set cmdLog [__MMX::setCmdLog off]
	if	{ $useRegion == 1 }	{ __MMX::drawRect $x1 $y1 $x2 $y2 4 2 }
	foreach xtor $xtorL	{
		set px $pxMap($xtor); set py $pyMap($xtor)
		set gx $gxMap($xtor); set gy $gyMap($xtor)
		if	{ $conn == 1 }	{ __MMX::drawLine $px $py $gx $gy }
		if	{ $mono == 0 }	{
			set c $cMap($xtor)
			set code [expr {$c/double($maxCap)}]
			__MMX::addMarker $px $py [__MMX::getColorCode $code] 4
			__MMX::addMarker $gx $gy [__MMX::getColorCode $code] 4
		}	else	{
			__MMX::addMarker $px $py white 4
			__MMX::addMarker $gx $gy white 4
		}
	}
	__MMX::setCmdLog $cmdLog
	puts	"\n><>< INFO ><><"
	puts	"# of decap devices : [llength $xtorL]"
	if	{ $mono == 0 }	{
		if	{ $useRegion == 0 }	{
			puts	"total cap : [format "%.3f" $tCap] pF"
		}	else	{
			puts	"region cap : [format "%.3f" $tCap] pF"
		}
	}
	if	{ $name == 1 }	{
		if	{ $mono == 0 }	{
			puts	"\n><>< NAME-CAP-RES-LEAKAGE LIST ><><"
		}	else	{
			puts	"\n><>< NAME LIST ><><"
		}
		foreach xtor $xtorL	{
			set px $pxMap($xtor); set py $pyMap($xtor)
			set gx $gxMap($xtor); set gy $gyMap($xtor)
			set c $cMap($xtor); set r $rMap($xtor); set l $lMap($xtor)
			if	{ $mono == 0 }	{
				puts	"$xtor\t[format "%.3f" $c] pF\t[format "%.3f" $r] ohm\t[format "%.3f" $l] A"
			}	else	{
				puts	$xtor
			}
		}
	}
}
proc	mmx_show_lef_pin_man	{}	{
	puts	"
	mmx_show_lef_pin
		-lef <lef_file>
		-def <def_file>
		?-cell <cell_list_file>? ?-cell <cell_1> ... <cell_N>?
		?-inst <instance_list_file>? ?-inst <instance_1> ... <instance_N>?
		?-n?
		?-pn? ?-pn <pin_1> ... <pin_N>?
		?-m <layer_1> ... <layer_N>?
		?-ncls?
		?-limit <number>? ?-all?
		?-region <llx lly urx ury>?
		?-o <output_file>?

		-n	: show cell/inst name
		-pn	: show pin name
		-m	: specify pin layers
		-ncls	: not clear screen before showing
		-limit	: limit the number of instances (default: 10)
		-all	: increase limit to 100
		-o	: dump instance or cell list
"
}
proc	mmx_show_lef_pin	{ args }	{
	__MMX::checkVer 8.1.4
	set argv [split $args]
	if	{ [llength $argv] == 0 }	{ mmx_show_lef_pin_man; return }
	set useCell 0; set useInst 0; set useRegion 0; set useDebug 0; set useLC 0; set useLayer 0
	set usePB 1; set usePC 0; set usePN 0; set useDump 0; set useLN 0; set useCLS 1; set useN 0
	set limit 10
	set cState option; set pState na
	foreach arg $argv	{
		switch	$cState	{
			option	{
				switch -- $arg	{
					-lef	{ set cState flag_lef }
					-def	{ set cState flag_def }
					-cell	{ set cState flag_cell; set useCell 1 }
					-inst	{ set cState flag_inst; set useInst 1 }
					-m	{ set cState flag_layer; set useLayer 1 }
					-region	{ set cState flag_region_x1; set useRegion 1 }
					-limit	{ set cState flag_limit }
					-o	{ set cState flag_dump; set useDump 1 }
					-debug	{ set pState na; set useDebug 1 }
					-n	{ set pState na; set useN 1 }
					-pc	{ set pState na; set usePC 1 }
					-pn	{ set pState flag_pn; set usePN 1 }
					-ln	{ set pState flag_ln; set useLN 1 }
					-lc	{ set pState na; set useLC 1 }
					-ncls	{ set pState na; set useCLS 0 }
					-all	{ set pState na; set limit 100 }
					-h	{ mmx_show_lef_pin_man; return }
					-help	{ mmx_show_lef_pin_man; return }
					default	{
						if	{ [regexp {^-} $arg] }	{ error "unknown option: $arg" }
						if	{ ![string compare $pState flag_cell] }	{
							lappend cellL $arg
						}	elseif	{ ![string compare $pState flag_inst] }	{
							lappend instL $arg
						}	elseif	{ ![string compare $pState flag_layer] }	{
							set layerM($arg) 1
						}	elseif	{ ![string compare $pState flag_pn] }	{
							set usePN 2; set pinM($arg) 1
						}	elseif	{ ![string compare $pState flag_ln] }	{
							set useLN 2; set netM($arg) 1
						}	else	{ error	"unknown option: $arg" }
					}
				}
			}
			flag_lef	{ set lefFile $arg; set pState na; set cState option }
			flag_def	{ set defFile $arg; set pState na; set cState option }
			flag_cell	{ lappend cellL $arg; set pState $cState; set cState option }
			flag_inst	{ lappend instL $arg; set pState $cState; set cState option }
			flag_layer	{ set layerM($arg) 1; set pState $cState; set cState option }
			flag_region_x1	{ set x1 [__MMX::eng2val $arg]; set pState na; set cState flag_region_y1 }
			flag_region_y1	{ set y1 [__MMX::eng2val $arg]; set pState na; set cState flag_region_x2 }
			flag_region_x2	{ set x2 [__MMX::eng2val $arg]; set pState na; set cState flag_region_y2 }
			flag_region_y2	{ set y2 [__MMX::eng2val $arg]; set pState na; set cState option }
			flag_limit	{ set limit [__MMX::eng2val $arg]; set pState na; set cState option }
			flag_dump	{ set outFile $arg; set pState na; set cState option }
			default		{ error "internal error: $cState" }
		}
	}
	if	{ [regexp {^flag} $cState] }	{ error "missing required option(s) or value(s)" }
	if	{ ![info exists lefFile] || ![info exists defFile] }	{ error	"missing option: -lef <lef_file> -def <def_file>" }
	if	{ $useRegion }	{
		if	{ $x1 > $x2 || $y1 > $y2 }	{ error "incorrect range: -region $x1 $y1 $x2 $y2" }
	}	else	{
		set rect [zoom get]
		set x1 [lindex $rect 0]; set y1 [lindex $rect 1]; set x2 [lindex $rect 2]; set y2 [lindex $rect 3]
		set useRegion 1
	}
	if	{ !$useCell && !$useInst }	{ set instL {.*}; set useInst 1 }
	if	{ $useInst }	{
		if	{ [file exists [lindex $instL 0]] }	{
			set instFile [lindex $instL 0]; unset instL
			if	{ [catch { open $instFile r } IN] }	{ error "can't open a file: $instFile" }
			while	{[gets $IN line] >= 0}	{
				regexp {(.*?)[#\$]} $line match line
				if	{ ![regexp {\S} $line] }	{ continue }
				regsub {^\s+} $line {} line
				regsub {\s+$} $line {} line
				lappend instL $line
			}
			close	$IN
		}
		set cmdLog [__MMX::setCmdLog off]
		foreach inst $instL	{
			set tL [split [eval "get inst $inst -regexp"]]
			foreach t $tL	{ lappend eInstL $t }
		}
		__MMX::setCmdLog $cmdLog
	}
	if	{ $useCell }	{
		if	{ [file exists [lindex $cellL 0]] }	{
			set cellFile [lindex $cellL 0]; unset cellL
			if	{ [catch { open $cellFile r } IN] }	{ error "can't open a file: $cellFile" }
			while	{[gets $IN line] >= 0}	{
				regexp {(.*?)[#\$]} $line match line
				if	{ ![regexp {\S} $line] }	{ continue }
				regsub {^\s+} $line {} line; regsub {\s+$} $line {} line
				lappend cellL $line
			}
			close	$IN
		}
		set cmdLog [__MMX::setCmdLog off]
		foreach cell $cellL	{
			set tL [split [eval "get cell $cell -regexp"]]
			foreach t $tL	{ lappend eCellL $t }
		}
		__MMX::setCmdLog $cmdLog
	}
	set pFile {.slp.loc}
	set gapipBin [__MMX::getBinName gapip]
	if	{ [catch { set v [eval "exec $gapipBin -v"] } ] }	{ error "version mismatch: gapip" }
	if	{ $v != "0.91" }	{ error "version mismatch: gapip" }
	set cmdLine "$gapipBin -lef $lefFile -def $defFile -o $pFile -slp";
	if	{ $useRegion }	{ append cmdLine " -region $x1 $y1 $x2 $y2" }
	if	{ $useCell }	{
		if	[catch { open .slp.cell.lst w } FILE] { error "can't make a file: .slp.cell.lst" }
		foreach cell $eCellL	{ puts $FILE $cell }
		close	$FILE
		append cmdLine " -cell .slp.cell.lst"
	}
	if	{ $useInst }	{
		if	[catch { open .slp.inst.lst w } FILE] { error "can't make a file: .slp.inst.lst" }
		foreach inst $eInstL	{ puts $FILE $inst }
		close	$FILE
		append cmdLine " -inst .slp.inst.lst"
	}
	if	{ $useLN || $useLC }	{
		set gsrFile [lindex [glob -nocomplain *.gsr] 0]
		append cmdLine " -gsr $gsrFile"
	}
	if	{ $useDebug }	{ puts	$cmdLine }
	puts	[eval	"exec $cmdLine"]
	if	{ $useCLS }	{ mmx_clear }
	if	[catch { open $pFile r } PF]	{ error	"file not found: $pFile" }
	set cmdLog [__MMX::setCmdLog off]
	if	{ $useRegion } { zoom rect $x1 $y1 $x2 $y2 }
	set cntAll 0; set cntView 0; set cCol 4
	while	{[gets $PF line] >= 0}	{
		if	{ ![regexp {(\S+) (\S+) (\S+) (\S+) (\S+) (\S+) (\S+) (\S+) (\S+) (.*)} \
			$line match inst cell x1 y1 x2 y2 cx cy 3 4] }	{ continue }
		incr cntAll
		if	{ $cntAll > $limit }	{ continue }
		incr cntView
		if	{ [info exists cColM($cell)] }	{
			set c $cColM($cell)
		}	else	{
			set c $cCol; set cColM($cell) $cCol; incr cCol
			if	{ $cCol >= 10 }	{ set cCol 1 }
		}
		eval "select add $inst -color [__MMX::getColorTxt $c] -linewidth 2"
		if	{ $useN }	{
			set l [expr [string length $cell]+2]
			set w [expr abs(($x2-$x1)/$l)]; set h [expr abs(($y2-$y1)/$l)]; set s [expr $h > $w ? $w : $h] 
			set cx [expr $x1+$s]
			__MMX::putMsg $cell $cx $cy $s $s $c
			__MMX::putMsg $inst $cx [expr $cy-1.2*$s] $s $s $c
		}
		set dataL [split $4]; set pCol 3
		for	{ set i 0 } { $i < $3 } { incr i }	{
			set pin [lindex $dataL 0]; set net [lindex $dataL 1];
			set nRect [lindex $dataL 2]; set dataL [lreplace $dataL 0 2]
			for	{ set j 0 } { $j < $nRect} { incr j }	{
				set rect [lrange $dataL 0 6]; set rectL [split $rect]; set layer [lindex $rectL 0]
				set dataL [lreplace $dataL 0 6]
				if	{ $useLayer && ![info exists layerM($layer)] }	{ continue }
				if	{ [info exists pColM($pin$layer)] }	{
					set c $pColM($pin$layer)
				}	else	{
					set c $pCol; set pColM($pin$layer) $pCol; incr pCol
					if	{ $pCol >= 10 }	{ set pCol 1 }
				}
				set x1 [expr double([lindex $rectL 1])]; set y1 [expr double([lindex $rectL 2])]
				set x2 [expr double([lindex $rectL 3])]; set y2 [expr double([lindex $rectL 4])]
				if	{ $usePB }	{ __MMX::drawRect $x1 $y1 $x2 $y2 $c 1 }
				set cx [expr double([lindex $rectL 5])]; set cy [expr double([lindex $rectL 6])]
				if	{ $usePC }	{ __MMX::addMarker $cx $cy [__MMX::getColorTxt $c] 2 }
				if	{ $usePN || $useLN }	{
					set l [string length $pin]; set w [expr abs(($x2-$x1)/$l)]
					set h [expr abs(($y2-$y1)/$l)]; set s [expr $h > $w ? $w : $h]
					set cy2 [expr $cy-1.2*$s]
					if	{ $useLN == 2 && [info exists netM($net)] }	{
						__MMX::putMsg $net $cx $cy2 $s $s $c
					}
					if	{ $useLN == 1 }	{
						__MMX::putMsg $net $cx $cy2 $s $s $c
					}
					if	{ $usePN == 2 && [info exists pinM($pin)] }	{
						__MMX::putMsg $pin $cx $cy $s $s $c
					}
					if	{ $usePN == 1 }	{
						__MMX::putMsg $pin $cx $cy $s $s $c
					}
				}
				if	{ $useLC }	{
					if	{ $net == "?" }	{
						__MMX::drawCrossedRect $x1 $y1 $x2 $y2 2 1
					}	else	{
						__MMX::drawCrossedRect $x1 $y1 $x2 $y2 5 1
					}
				}
			}
		}
	}
	__MMX::setCmdLog $cmdLog
	close	$PF

	if	{ $useDump }	{
		if	[catch { open $outFile w } FILE] { error "can't make a file: $outFile" }
		if	[catch { open $pFile r } PF]	{ error	"file not found: $pFile" }
		while	{[gets $PF line] >= 0}	{
			if	{ ![regexp {(\S+) (\S+)} $line match inst cell] }	{ continue }
			if	{ $useCell && $useInst }	{
				puts	$FILE	"$inst\t$cell";
			}	elseif	{ $useCell }	{
				puts	$FILE	$cell;
			}	else	{
				puts	$FILE	$inst;
			}
		}
		close $PF
		close $FILE
	}
	if	{ $useDebug == 0 }	{
		file delete -force $pFile
		file delete -force .slp.cell.lst
		file delete -force .slp.inst.lst
	}
	if	{ $cntView == $cntAll }	{
		puts	"$cntView/$cntAll instance(s) displayed"
	}	else	{
		puts	"$cntView/$cntAll instance(s) displayed, use -limit to see more instances"
	}
}
proc	mmx_show_xtor_man	{}	{
	puts	"
	mmx_show_xtor
		-pg <net1> ... -pg <netN>
		-dir <gdsmmx_dir>
		?-region <llx lly urx ury>?
		?-nocap?
		?-n <value>?

		# -nocap : to hide decap xtors
		# -n : to set the max number of displayed xtors (default: 1000)
"
}
proc	mmx_show_xtor	{ args }	{
	__MMX::checkVer 8.1.4
	set argv [split $args]
	if	{ [llength $argv] == 0 }	{ mmx_show_xtor_man; return }
	set state option; set pgId 2; set n 1000; set useRegion 0; set noCap 0
	foreach arg $argv	{
		switch	$state	{
			option	{
				switch -- $arg	{
					-dir	{ set state flag_dir }
					-pg	{ set state flag_pg }
					-region	{ set state flag_region_x1; set useRegion 1 }
					-n	{ set state flag_n }
					-nocap	{ set noCap 1 }
					-h	{ mmx_show_xtor_man; return }
					-help	{ mmx_show_xtor_man; return }
					default { error "unknown option: $arg" }
				}
			}
			flag_pg		{
				set pgcMap($arg) $pgId
				set pgMap($arg) 0
				set state option
				incr pgId 2
				if	{ $pgId >= 10 }	{ set pgId 2 }
			}
			flag_dir	{ set gdsmmxDir $arg; set state option }
			flag_n		{ set n [__MMX::eng2val $arg]; set state option }
			flag_region_x1	{ set x1 [__MMX::eng2val $arg]; set state flag_region_y1 }
			flag_region_y1	{ set y1 [__MMX::eng2val $arg]; set state flag_region_x2 }
			flag_region_x2	{ set x2 [__MMX::eng2val $arg]; set state flag_region_y2 }
			flag_region_y2	{ set y2 [__MMX::eng2val $arg]; set state option }
			default		{ error "internal error: $state" }
		}
	}
	if	{ [regexp {^flag} $state] }	{ error	"missing required option(s) or value(s)" }
	if	{ ![array exists pgcMap] }	{ error	"missing option: -pg <net>" }
	if	{ ![info exists gdsmmxDir] }	{ error	"missing option: -dir <gdsmmx_dir>" }
	if	{ ![file isdirectory $gdsmmxDir] }	{ error "can't find directory: $gdsmmxDir" }
	if	{ $useRegion && ($x1 > $x2 || $y1 > $y2) }	{ error "incorrect range: -region $x1 $y1 $x2 $y2" }
	if	{ $noCap }	{
		set bFile {.show.decap.l}
		set gpdciBin [__MMX::getBinName gpdci]
		if	{ ![file exists $bFile] || \
			[expr [file mtime $bFile]-[file mtime ".apache/cell.cdev"]] != 0 }	{
			exec $gpdciBin -rhdir . -o $bFile
		}
		if	[catch { open $bFile r } FF]	{ error	"file not found: $bFile" }
		while	{[gets $FF line] >= 0}	{
			if	{ [regexp {(\S+) (\S+) (\S+) (\S+) (\S+)} \
				$line match xtor p px py g] }	{
				set decapM($p) 1; set decapM($g) 1
			}
		}
		close	$FF
	}
	set cmdLog [__MMX::setCmdLog off]
	__MMX::setCmdLog $cmdLog
	set pFile {.sx.loc}
	set gxlilBin [__MMX::getBinName gxlil]
	exec $gxlilBin -gdsmmxdir $gdsmmxDir -o $pFile
	if	[catch { open $pFile r } PF]	{ error	"file not found: $pFile" }
	mmx_clear
	set cmdLog [__MMX::setCmdLog off]
	if	{ $useRegion == 1 } { __MMX::drawRect $x1 $y1 $x2 $y2 3 2 }
	set nXtor 0; set tXtor 0;
	while	{[gets $PF line] >= 0}	{
		if	{ [regexp {(\S+) (\S+) (\S+) (\S+) (\S+)} $line match 1 2 3 4 5] }	{
			if	{ $noCap && [info exists decapM($1)] }	{ continue }
			set pg [lindex [split $1 .] 0]
			if	{ ![info exists pgcMap($pg)] }	{ continue }
			if	{ $useRegion == 1 && !($2 >= $x1 && $2 <= $x2 && $3 >= $y1 && $3 <= $y2 && \
				$4 >= $x1 && $4 <= $x2 && $5 >= $y1 && $5 <= $y2) } { continue }
			incr tXtor
			if	{ $pgMap($pg) >= $n }	{ continue }
			set c $pgcMap($pg)
			__MMX::drawLine $2 $3 $4 $5 8 1
			__MMX::addMarker $2 $3 [__MMX::getColorTxt [expr $c+1]] 2
			__MMX::addMarker $4 $5 [__MMX::getColorTxt $c] 4
			incr nXtor; incr pgMap($pg)
		}
	}
	__MMX::setCmdLog $cmdLog
	close	$PF
	file delete -force $pFile
	puts	"$nXtor/$tXtor transistor(s) displayed..."
}
proc	mmx_get_resistance_man	{}	{
	puts	"
	mmx_get_resistance
		-position/-p <sx sy ex ey>
		?-overlay/-ov?

		-overlay : preserve previous drawing
"
}
proc	mmx_get_resistance	{ args }	{
	set argv [split $args]
	set usePosition 0; set useDebug 0; set useOverlay 0
	set cState option; set pState na
	foreach arg $argv	{
		switch	$cState	{
			option	{
				switch -- $arg	{
					-position	{ set cState flag_position_sx; set usePosition 1 }
					-p		{ set cState flag_position_sx; set usePosition 1 }
					-overlay	{ set pState na; set useOverlay 1 }
					-ov		{ set pState na; set useOverlay 1 }
					-debug	{ set pState na; set useDebug 1 }
					-h		{ mmx_get_resistance_man; return }
					-help		{ mmx_get_resistance_man; return }
					default		{ error "unknown option: $arg" }
				}
			}
			flag_position_sx	{ set sx [__MMX::eng2val $arg]; set pState na; set cState flag_position_sy }
			flag_position_sy	{ set sy [__MMX::eng2val $arg]; set pState na; set cState flag_position_ex }
			flag_position_ex	{ set ex [__MMX::eng2val $arg]; set pState na; set cState flag_position_ey }
			flag_position_ey	{ set ey [__MMX::eng2val $arg]; set pState na; set cState option }
			default		{ error "internal error: $cState" }
		}
	}
	if	{ [regexp {^flag} $cState] }	{ error "missing required option(s) or value(s)" }
	if	{ $usePosition == 0 }	{ error "missing option: -position <sx sy ex ey>" }
	if	{ $useDebug }	{ puts "debug: perform res_calc -from { $sx $sy } -to { $ex $ey }" }
	puts	"info: calculating resistance. please wait";  puts -nonewline ""
	eval "perform res_calc -from { $sx $sy } -to { $ex $ey }"
	set rstFile "adsRpt/[get design].res_calc"
	if	{ [catch { open $rstFile r } FILE] }	{ error "file not found: $rstFile" }
	puts	"info: reading $rstFile"
	while	{[gets $FILE line] >= 0}	{
		if	{ ![regexp {^# Starting point:\s+\((\S+)\s+(\S+)\s+(\S+)}	\
			$line match sx sy sl] }	{ continue }
		puts	"info: starting point \[$sx $sy $sl\]"
		while	{[gets $FILE line] >= 0}	{
			if	{ [regexp {^#} $line] } { continue }
			if	{ ![regexp {^(\S+)\s+(\S+)\s+(\S+)\s+(\S+)}	\
				$line match r ex ey el] }	{ continue }
			puts	"info: ending point \[$ex $ey $el\]"
			puts	"info: resistance: $r"
			break
		}
		break
	}
	close	$FILE
	if	{ $useOverlay == 0 }	{ plot line -clearall; marker delete -all; select clearall; refresh }
	set rL [__MMX::drawDetourLineMsg $sx $sy $ex $ey 4 2 1 0.02 $r 30]
	set ddx [lindex $rL 0]; set ddy [lindex $rL 1]; set cs [expr sqrt($ddx*$ddx+$ddy*$ddy)/40]
	__MMX::drawContact $sx $sy $cs 4
	__MMX::drawContact $ex $ey $cs 4
}
proc	mmx_plot_histogram_man	{}	{
	puts	"
	mmx_plot_histogram
		?-region <llx lly urx ury>?
		?-net <netName>?
		?-layer <layerName>?
		?-lower_limit <mV>?
		?-upper_limit <mV>?
		?\[-bin_size <mV> | -bin_number <number>\]? (default: -bin_number 100)
		?-max_allowed_peak_drop <mV>?
		?-max_allowed_average_drop <mV>?
		?-peak_count_threshold <%>?
		?-output_file <fileName>?
		?-viewer <commandName>?
		?-wire?

		-peak_count_threshold :	find a peak bin which contains more than
					the threshold percentage of the total samples

	mmx_plot_histogram
		-batch_file <fileName>

####### Batch File Example #######
NET_NAME	VDD1 VDD2 VSS
#<NAME>     <REGION>      ?<options>?
Area1   100 100 200 200   -peak_count_threshold 5
Area2   200 200 300 300   -wire -lower_limit 10
"
}
proc	mmx_plot_histogram	{ args }	{
	set argv [split $args]

	set cmdLog [__MMX::setCmdLog off]
	set aMode [get analysis_mode]
	set vddNets [get net * -glob -type power]
	set gndNets [get net * -glob -type ground]
	foreach pg $vddNets	{ set pwrM($pg) [get net $pg -ideal_voltage] }
	foreach pg $gndNets	{ set gndM($pg) 0 }
	__MMX::setCmdLog $cmdLog

	set useRegion 0; set useNet 0; set useLayer 0; set useLower 0; set usePCT 0
	set useUpper 0; set useBS 0; set useBN 0; set useWire 0; set useViewer 0; set useBatch 0
	set useOutFile 0; set useDebug 0; set useMAPD 0; set useMAAD 0; set useOverlay 0

	if	{ [info exists __MMX::mmxData(region)] }	{
		puts	"info: mmx_set region $__MMX::mmxData(region)"
		set regionL [split $__MMX::mmxData(region)]
		if	{ [llength $regionL] < 4 }	{ error "insufficient arguments for region" }
		set llx [__MMX::eng2val [lindex $regionL 0]]
		set lly [__MMX::eng2val [lindex $regionL 1]]
		set urx [__MMX::eng2val [lindex $regionL 2]]
		set ury [__MMX::eng2val [lindex $regionL 3]]
		set useRegion 1
	}
	if	{ [info exists __MMX::mmxData(net)] }	{
		puts	"info: mmx_set net $__MMX::mmxData(net)"
		set net $__MMX::mmxData(net)
		set useNet 1
	}
	if	{ [info exists __MMX::mmxData(layer)] }	{
		puts	"info: mmx_set layer $__MMX::mmxData(layer)"
		set layer $__MMX::mmxData(layer)
		set useLayer 1
	}
	if	{ [info exists __MMX::mmxData(viewer)] }	{
		puts	"info: mmx_set viewer $__MMX::mmxData(viewer)"
		set viewer $__MMX::mmxData(viewer)
		set useViewer 1
	}
	if	{ [info exists __MMX::mmxData(lower_limit)] }	{
		puts	"info: mmx_set lower_limit $__MMX::mmxData(lower_limit)"
		set lower [__MMX::eng2val $__MMX::mmxData(lower_limit)]
		set useLower 1
	}
	if	{ [info exists __MMX::mmxData(upper_limit)] }	{
		puts	"info: mmx_set upper_limit $__MMX::mmxData(upper_limit)"
		set upper [__MMX::eng2val $__MMX::mmxData(upper_limit)]
		set useUpper 1
	}
	if	{ [info exists __MMX::mmxData(bin_size)] }	{
		puts	"info: mmx_set bin_size $__MMX::mmxData(bin_size)"
		set binSize [__MMX::eng2val $__MMX::mmxData(bin_size)]
		set useBS 1
	}
	if	{ [info exists __MMX::mmxData(bin_number)] }	{
		puts	"info: mmx_set bin_number $__MMX::mmxData(bin_number)"
		set binNum [__MMX::eng2val $__MMX::mmxData(bin_number)]
		set useBN 1
	}
	if	{ [info exists __MMX::mmxData(max_allowed_peak_drop)] }	{
		puts	"info: mmx_set max_allowed_peak_drop $__MMX::mmxData(max_allowed_peak_drop)"
		set mapd [__MMX::eng2val $__MMX::mmxData(max_allowed_peak_drop)]
		set useMAPD 1
	}
	if	{ [info exists __MMX::mmxData(max_allowed_average_drop)] }	{
		puts	"info: mmx_set max_allowed_average_drop $__MMX::mmxData(max_allowed_average_drop)"
		set maad [__MMX::eng2val $__MMX::mmxData(max_allowed_average_drop)]
		set useMAAD 1
	}
	if	{ [info exists __MMX::mmxData(peak_count_threshold)] }	{
		puts	"info: mmx_set peak_count_threshold $__MMX::mmxData(peak_count_threshold)"
		set pct [__MMX::eng2val $__MMX::mmxData(peak_count_threshold)]
		set usePCT 1
	}
	if	{ [info exists __MMX::mmxData(output_file)] }	{
		puts	"info: mmx_set output_file $__MMX::mmxData(output_file)"
		set outFile $__MMX::mmxData(output_file)
		set useOutFile 1
	}
	if	{ [info exists __MMX::mmxData(batch_file)] }	{
		puts	"info: mmx_set batch_file $__MMX::mmxData(batch_file)"
		set batchFile $__MMX::mmxData(batch_file)
		set useBatch 1
	}
	set cState option; set pState na
	foreach arg $argv	{
		switch	$cState	{
			option	{
				switch -- $arg	{
					-region		{ set cState flag_region_llx; set useRegion 1 }
					-net		{ set cState flag_net; set useNet 1 }
					-layer		{ set cState flag_layer; set useLayer 1 }
					-viewer		{ set cState flag_viewer; set useViewer 1 }
					-lower_limit	{ set cState flag_lower; set useLower 1 }
					-upper_limit	{ set cState flag_upper; set useUpper 1 }
					-bin_size	{ set cState flag_bs; set useBS 1 }
					-bin_number	{ set cState flag_bn; set useBN 1 }
					-max_allowed_peak_drop		{ set cState flag_mapd; set useMAPD 1 }
					-max_allowed_average_drop	{ set cState flag_maad; set useMAAD 1 }
					-peak_count_threshold		{ set cState flag_pct; set usePCT 1 }
					-wire		{ set pState na; set useWire 1 }
					-overlay	{ set pState na; set useOverlay 1 }
					-debug		{ set pState na; set useDebug 1 }
					-output_file	{ set cState flag_output; set useOutFile 1 }
					-batch_file	{ set cState flag_batch; set useBatch 1 }
					-h		{ mmx_plot_histogram_man; return }
					-help		{ mmx_plot_histogram_man; return }
					default		{ error "unknown option: $arg" }
				}
			}
			flag_region_llx	{ set llx [__MMX::eng2val $arg]; set pState na; set cState flag_region_lly }
			flag_region_lly	{ set lly [__MMX::eng2val $arg]; set pState na; set cState flag_region_urx }
			flag_region_urx	{ set urx [__MMX::eng2val $arg]; set pState na; set cState flag_region_ury }
			flag_region_ury	{ set ury [__MMX::eng2val $arg]; set pState na; set cState option }
			flag_net	{ set net $arg; set pState na; set cState option }
			flag_layer	{ set layer $arg; set pState na; set cState option }
			flag_viewer	{ set viewer $arg; set pState na; set cState option }
			flag_lower	{ set lower [__MMX::eng2val $arg]; set pState na; set cState option }
			flag_upper	{ set upper [__MMX::eng2val $arg]; set pState na; set cState option }
			flag_bs		{ set binSize [__MMX::eng2val $arg]; set pState na; set cState option }
			flag_bn		{ set binNum [__MMX::eng2val $arg]; set pState na; set cState option }
			flag_mapd	{ set mapd [__MMX::eng2val $arg]; set pState na; set cState option }
			flag_maad	{ set maad [__MMX::eng2val $arg]; set pState na; set cState option }
			flag_pct	{ set pct [__MMX::eng2val $arg]; set pState na; set cState option }
			flag_output	{ set outFile $arg; set pState na; set cState option }
			flag_batch	{ set batchFile $arg; set pState na; set cState option }
			default		{ error "internal error: $cState" }
		}
	}
	if	{ [regexp {^flag} $cState] }	{ error "missing required option(s) or value(s)" }
	if	{ $useBatch }	{
		if	{ [catch { open $batchFile r } FILE] }	{ error "file not found: $batchFile" }
		puts	"info: reading $batchFile"
		while	{[gets $FILE line] >= 0}	{
			regexp {(.*?)#} $line match line
			if	{ ![regexp {^\s*NET_NAME\s+(.*)} $line match 1] }	{ continue }
			set netL [split $1]
			while	{[gets $FILE line] >= 0}	{
				regexp {(.*?)#} $line match line
				if	{ ![regexp {^\s*(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)(\s+.*)?} \
					$line match area llx lly urx ury options] }	{ continue }
				if	{ [info exist batchMap($area,REGION)] }	{ error "duplicated name: $area" }
				set batchMap($area,REGION) "$llx $lly $urx $ury"
#				set batchMap($area,MAAD) $maad
#				set batchMap($area,MAPD) $mapd
				set batchMap($area,O) $options
				puts	"info: $area found"
			}
			break
		}
		close	$FILE	
		if	{ ![info exists netL] }	{ error "missing keyword: NET_NAME" }
		puts	"info: [llength $netL] net(s) found"
		foreach net $netL	{
			if	{ ![info exists pwrM($net)] && ![info exists gndM($net)] }	{ error "unknown net: $net" }
		}
		foreach area [lsort [array names batchMap *,REGION]]	{
			regexp {(\S+),\S+} $area match area
			foreach net $netL	{
				puts	"info: processing $area/$net"; puts -nonewline ""
				set cmd "-net $net -output_file $area.$net.dat -region $batchMap($area,REGION)$batchMap($area,O)"
				if	{ $useDebug }	{ puts $cmd }
				eval mmx_plot_histogram $cmd
			}
		}
		mmx_clear
		set cId 1
		foreach area [lsort [array names batchMap *,REGION]]	{
			regexp {(\S+),\S+} $area match area
			set regionL [split $batchMap($area,REGION)]
			set x1 [lindex $regionL 0]; set y1 [lindex $regionL 1]
			set x2 [lindex $regionL 2]; set y2 [lindex $regionL 3]
			set width [expr $x2-$x1]; set height [expr $y2-$y1]
			__MMX::drawRect $x1 $y1 $x2 $y2 $cId 2
			set nl [string length $area]
			if	{ $width < $height }	{
				set fontSize [expr {double($height)/($nl+2)}]
				if	{ $fontSize > $width }	{
					set fontSize $width; set ym [expr {0.5*($height-$fontSize*$nl)}]; set xm $width
				}	else	{
					set ym $fontSize; set xm [expr {0.5*($width+$fontSize)}]
				}
				set d 1; set x [expr {$x1+$xm}]; set y [expr {$y1+$ym}]
			}	else	{
				set fontSize [expr {double($width)/($nl+2)}]
				if	{ $fontSize > $height }	{
					set fontSize $height; set xm [expr {0.5*($width-$fontSize*$nl)}]; set ym 0
				}	else	{
					set xm $fontSize; set ym [expr {0.5*($height-$fontSize)}]
				}
				set d 0; set x [expr {$x1+$xm}]; set y [expr {$y1+$ym}]
			}
			set col [__MMX::getColorTxt $cId]; incr cId
			__MMX::putMsg $area $x $y $fontSize $fontSize $col 1 $d
		}		
		return
	}
	if	{ $useBS && $useBN }	{ error "incorrect option: use one of -bin_size or -bin_number" }
	if	{ ($useBS || $useBN) && !($useLower && $useUpper) }	{ error "missing required option(s): -lower_limit and -upper_limit" }
	if	{ $useBS }	{ set binSize [expr abs($binSize)] }
	if	{ $useBN }	{ set binNum [expr int(abs($binNum))] }
	if	{ $useLayer && !$useWire }	{ error "incorrect option: use -layer with -wire" }
	set cmdLog [__MMX::setCmdLog off]
	if	{ !$useRegion }	{
		set regionL [zoom get]
		set llx [lindex $regionL 0]; set lly [lindex $regionL 1]
		set urx [lindex $regionL 2]; set ury [lindex $regionL 3]
	}
	set dllx [__MMX::val2eng $llx]; set dlly [__MMX::val2eng $lly]
	set durx [__MMX::val2eng $urx]; set dury [__MMX::val2eng $ury]
	if	{ $llx > $urx || $lly > $ury }	{
		__MMX::setCmdLog $cmdLog
		error "incorrect range: -region $dllx $dlly $durx $dury"
	}
	if	{ $useNet && ![info exists pwrM($net)] && ![info exists gndM($net)] }	{
		__MMX::setCmdLog $cmdLog; error "unknown net: $net"
	}
	if	{ !$useOverlay }	{ plot line -clearall; marker delete -all; select clearall; refresh }
	plot line -position $llx $lly $llx $ury -color white -width 2
	plot line -position $llx $ury $urx $ury -color white -width 2
	plot line -position $urx $ury $urx $lly -color white -width 2
	plot line -position $urx $lly $llx $lly -color white -width 2
	plot line -position $llx $lly $urx $ury -color white -width 2
	plot line -position $llx $ury $urx $lly -color white -width 2
	set dvdFile "adsRpt/Dynamic/[get design].dvd.mmx"
	__MMX::setCmdLog $cmdLog

	puts	"info: region \[$dllx $dlly $durx $dury\]"
	if	{ [regexp -nocase {^DYNAMIC.*VECTORLESS$} $aMode] }	{
		set type "DvD"
		if	{ !$useOutFile }	{ set outFile histogram_dvd.dat }
	}	elseif	{ [regexp -nocase {^STATIC(IR)?$} $aMode] }	{
		set type "StaticIR"
		if	{ !$useOutFile }	{ set outFile histogram_ir.dat }
	}	else	{ error "not supported: $aMode"	}
	puts	"info: analysis type \[$type\]"
	if	{ $useWire }	{
		set lt "ALL"; set nt "ALL"
		set cmdLine "plot analysis -type $type"
		if	{ $useNet }	{ set cmdLine "$cmdLine -net $net"; set nt $net }
		if	{ $useLayer }	{ set cmdLine "$cmdLine -layer $layer"; set lt $layer }
		if	{ $useLower }	{ set cmdLine "$cmdLine -lower $lower" }
		if	{ $useUpper }	{ set cmdLine "$cmdLine -upper $upper" }
		if	{ $useBS }	{ set cmdLine "$cmdLine -binsize $binSize" }
		if	{ $useBN }	{ set cmdLine "$cmdLine -binnumber $binNum" }

		set cmdLog [__MMX::setCmdLog off]
		condition set -xy $llx $lly $urx $ury
		if	{ $useDebug }	{ puts	"debug: [condition get -xy]" }
		if	{ !$useDebug }	{  set cmdLine "$cmdLine -nograph" }
		set cmdLine "$cmdLine -o $outFile" 
		if	{ $useDebug }	{ puts "debug: $cmdLine" }
		puts	"info: generating $outFile";  puts -nonewline ""
		eval $cmdLine
		condition unset -xy
		__MMX::setCmdLog $cmdLog

		set title "DvD by layer $lt and net $nt"
	}	else	{
		set title "DvD of MMX Xtor Pin"
		set minVd 1e99; set maxVd -1e99; set nDecap 0
		if	{ [catch { open $dvdFile r } FILE] }	{ error "file not found: $dvdFile" }
		puts	"info: reading $dvdFile"
		while	{[gets $FILE line] >= 0}	{
			if	{ ![regexp {^\d+\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+\S+\s+\S+\s+(\S+)}	\
				$line match 1 2 3 4 5 6] } { continue }
			if	{ $2 < $llx || $2 > $urx || $3 < $lly || $3 > $ury }	{ continue } 
			set pg [lindex [split $1 .] 0]
			if	{ $useNet && [string compare $pg $net] } { continue }
			if	{ [info exists pwrM($pg)] }	{
				set vD [expr $pwrM($pg)-$4]
			}	elseif	{ [info exists gndM($pg)] }	{
				set vD $5
			}	else	{ error "unknown pg found: $pg" }
			set vD [format "%e" [expr $vD*1000]]
			if	{ $vD > $maxVd } { set maxVd $vD }
			if	{ $vD < $minVd } { set minVd $vD }
			if	{ [info exists vDM($6)] }	{
				unset vDM($6); incr nDecap
				if	{ $useDebug }	{ puts "debug: decap xtor \[$6\]" }
			}	else	{
				set vDM($6) $vD
			}
		}
		close	$FILE
		puts	"info: $nDecap intentional decap transistor(s) found"
		foreach xtor [array names vDM]	{ lappend vDL $vDM($xtor) }
		if	{ ![info exists vDL] }	{ puts "no data"; return }
		if	{ $useLower } { set minVd $lower }
		if	{ $useUpper } { set maxVd $upper }
		if	{ $maxVd <= $minVd } { error "incorrect range: -min/-max ([__MMX::val2eng $minVd]/[__MMX::val2eng $maxVd])" }
		if	{ $useDebug }	{ puts "debug: min/max $minVd $maxVd" }
		if	{ $useBS }	{
			set dV [format "%e" $binSize]
		}	elseif	{ $useBN }	{
			set dV [format "%e" [expr ($maxVd-$minVd)/$binNum]]
		}	else	{
			set dV [format "%e" [expr ($maxVd-$minVd)/100]]
		}
		if	{ $useDebug }	{ puts "debug: bin_size $dV" }
		if	{ $dV > $maxVd } { set dV $maxVd }
		set maxVdd [expr $maxVd+$dV]
		for	{ set i $minVd } { $i < $maxVdd } { set i [expr $i+$dV] } {
			set hM([format "%e" $i]) 0
		}
		set nXtor 0; set tXtor [llength $vDL]
		foreach	vD $vDL	{
			if	{ $vD < $minVd || $vD > $maxVd } { continue }
			set quo [expr int(($vD-$minVd)/$dV)]
			set id [format "%e" [expr $quo*$dV+$minVd]]
			if	{ $id >= $minVd && $id <= $maxVd } {
				incr nXtor; incr hM([format "%e" $id])
			}
		}
		if	[catch { open $outFile w } FILE] { error "can't make a file: $outFile" }
		puts	"info: generating $outFile";  puts -nonewline ""
		### fix numerical error problem
		set maxVdVd [expr $maxVd+$dV]
		for	{ set i $minVd } { $i < $maxVdVd } { set i [expr $i+$dV] }	{
			puts $FILE "[format "%e\t%d" $i $hM([format "%e" $i])]"
		}
		close	$FILE
		if	{ $useDebug }	{
			exec xgraph -hist -ng -t "DvD of MMX Xtor Pin" -fmtx %g -fmty %g -x Voltage_Drop(mv) -y Counts $outFile &
		}
		puts	"info: $nXtor/$tXtor transistor(s) counted"
	}

	set minX 1e99; set maxX -1e99; set maxXT -1e99; set nL 0; set nD 0; set sum 0; set x NA
	set min 1e99; set max -1e99; set maxY -1e99
	if	[catch { open $outFile r } IN]	{ error	"file not found: $outFile" }
	while	{[gets $IN line] >= 0}	{
		set px $x
		if	{ ![regexp {(\S+)\s+(\S+)} $line m x y] }	{ continue }
		set sum [expr $sum+($x*$y)]; set nD [expr $nD + $y]
		if	{ $x < $min }	{ set min $x }
		if	{ $x > $max }	{ set max $x }
		if	{ $y < 1 }	{ continue }
		if	{ $x < $minX }	{ set minX $x }
		if	{ $x > $maxX }	{ set maxX $x }
		if	{ $y > $maxY }	{ set maxY $y }
		incr nL
	}
	close	$IN
	if	{ $nL == 0 || ![string compare $px NA] }	{ puts "no data"; return }
	if	{ !$usePCT }	{ set pct 0 }
	set peakThres [expr int($nD*$pct/100)];
	if	{ $useDebug}	{ puts "debug: PCT $pct SUM $nD THRES $peakThres" }
	if	[catch { open $outFile r } IN]	{ error	"file not found: $outFile" }
	while	{[gets $IN line] >= 0}	{
		if	{ ![regexp {(\S+)\s+(\S+)} $line m x y] }	{ continue }
		if	{ $y > $peakThres && $x > $maxXT }	{ set maxXT $x }
	}
	close	$IN
	if	{ $maxXT < 0 }	{
		puts	"warning: peak not found with peak_count_threshold \[$peakThres sample(s)(=[__MMX::val2eng $pct]%)\] (ignored)"
		set maxXT $maxX; set usePCT 0
	}
	set bs [expr $x-$px]; set avg [expr $sum/$nD]
	puts	"info: bin size \[$bs\]"
	puts	"info: mim/max/avg drop(bin) \[[__MMX::val2eng $minX]/[__MMX::val2eng $maxX]/[__MMX::val2eng $avg]\]"
	if	{ $usePCT }	{ puts	"info: peak count threshold \[$peakThres sample(s)(=[__MMX::val2eng $pct]%)\]" }
	if	{ $useMAPD }	{
		if	{ $max < $mapd }	{ set max $mapd }
		if	{ $min > $mapd }	{ set min $mapd }
	}
	if	{ $useMAAD }	{
		if	{ $max < $maad }	{ set max $maad }
		if	{ $min > $maad }	{ set min $maad }
	}
	set gmin [expr $min-($max-$min)*0.05]; set gmax [expr $max+($max-$min)*0.05]
	set maxY [expr $maxY*1.05]
	if	{ $useDebug}	{ puts "debug: min/max $min $max | gmin/gmax $gmin $gmax" }
	set gpHead "set terminal png\nset output \"$outFile.png\""
	set gpBody "set grid
set xrange \[$gmin:$gmax\]
set yrange \[0:$maxY\]
set xlabel \"Voltage Drop (mV)\"
set ylabel \"Counts\"
set title \"$title\"
set multiplot"
	set auxFile1 "$outFile.1"; set auxFile2 "$outFile.2"; set auxFile2a "$outFile.2a"
	set auxFile3 "$outFile.3"; set auxFile4 "$outFile.4"
	if	[catch { open $auxFile1 w } AUXFILE] { error "can't make a file: $auxFile1" }
	puts	$AUXFILE	"$avg $maxY"
	close	$AUXFILE
	set gpBody "$gpBody\nplot \"$auxFile1\" w impulses lt 3 lw 3 ti \"Avg. : [__MMX::val2eng $avg] mV\""
	if	{ $useMAAD }	{
		if	[catch { open $auxFile3 w } AUXFILE] { error "can't make a file: $auxFile3" }
		puts	$AUXFILE	"$maad $maxY"
		close	$AUXFILE
		set gpBody "$gpBody, \"$auxFile3\" w impulses lt 5 lw 3 ti \"Allowed Avg. : [__MMX::val2eng $maad] mV\""
	}
	if	{ $usePCT }	{
		if	[catch { open $auxFile2 w } AUXFILE] { error "can't make a file: $auxFile2" }
		puts	$AUXFILE	"$maxXT $maxY"
		close	$AUXFILE
		set gpBody "$gpBody, \"$auxFile2\" w impulses lt 1 lw 3 ti \"Peak(>[format "%.1f" $pct]%) : [__MMX::val2eng $maxXT] mV\""
	}
	if	[catch { open $auxFile2a w } AUXFILE] { error "can't make a file: $auxFile2a" }
	puts	$AUXFILE	"$maxX $maxY"
	close	$AUXFILE
	set gpBody "$gpBody, \"$auxFile2a\" w impulses lt 2 lw 3 ti \"Real Peak : [__MMX::val2eng $maxX] mV\""
	if	{ $useMAPD }	{
		if	[catch { open $auxFile4 w } AUXFILE] { error "can't make a file: $auxFile4" }
		puts	$AUXFILE	"$mapd $maxY"
		close	$AUXFILE
		set gpBody "$gpBody, \"$auxFile4\" w impulses lt 6 lw 3 ti \"Allowed Peak : [__MMX::val2eng $mapd] mV\""
	}
	set gpBody "$gpBody\nunset grid\nplot \"$outFile\" u (\$1+$bs/2):2 w histeps lw 3 ti \"\"\nset nomultiplot"
	set gpFile "$outFile.gp"
	if	[catch { open $gpFile w } GPFILE] { error "can't make a file: $gpFile" }
	puts	$GPFILE	"$gpHead\n$gpBody"
	close	$GPFILE
	puts	"info: generating $outFile.png";  puts -nonewline ""
	exec gnuplot $gpFile
	if	{ !$useDebug }	{ file delete -force $gpFile $auxFile1 $auxFile2 $auxFile2a $auxFile3 $auxFile4 }
	if	{ $useViewer }	{ exec $viewer $outFile.png & } else { puts "info: viewer is not defined" }
	puts	""
}
proc	mmx_plot_resistance_histogram_man	{}	{
	puts	"
	mmx_plot_resistance_histogram
		?-pg <pg1> ... -pg <pgN>?
		?-bn <bin_number>?
		?-bs <bin_size>?
		?-min <min_%>?
		?-max <max_%>?
		?-o <output_file>?
		?-log?

		# -log : to plot log of xtor counts
"
}
proc	mmx_plot_resistance_histogram	{ args }	{
	__MMX::checkVer 8.1.4
	set argv [split $args]
	set outFile resistance_histogram.out
	set binNum 100; set minVd 0.0; set maxVd 100000.0
	set useLog 0; set flagF 0; set state option
	set aMode gridcheck
	foreach arg $argv	{
		switch	$state	{
			option	{
				switch -- $arg	{
					-pg	{ set state flag_pg }
					-o	{ set state flag_o }
					-bn	{ set state flag_bn }
					-bs	{ set state flag_bs }
					-min	{ set state flag_min }
					-max	{ set state flag_max }
					-type	{ set state flag_type }
					-log	{ set useLog 1 }
					-h	{ mmx_plot_resistance_histogram_man; return }
					-help	{ mmx_plot_resistance_histogram_man; return }
					default { error "unknown option: $arg" }
				}
			}
			flag_pg		{ set pgMap($arg) 0; set state option }
			flag_o		{ set outFile $arg; set state option }
			flag_bn		{ set binNum [__MMX::eng2val $arg]; set state option }
			flag_bs		{ set binSize [expr [__MMX::eng2val $arg]*1e3]; set state option }
			flag_min	{ set minVd [expr ceil(double([expr [__MMX::eng2val $arg]*1e3]))]; set state option }
			flag_max	{ set maxVd [expr ceil(double([expr [__MMX::eng2val $arg]*1e3]))]; set state option }
			flag_type	{ set aMode $arg; set state option }
			default		{ error "internal error: $state" }
		}
	}
	if	{ [regexp {^flag} $state] } { error "missing required option(s) or value(s)" }
	set cmdLog [__MMX::setCmdLog off]
	set vddNets [split [gsr get vdd_nets] \n]
	foreach line $vddNets	{
		if	{ [regexp {[{}]} $line] } { continue }
		if 	{ [regexp {(\S+)\s+(\S+)} $line match 1 2] } { set pwrM($1) $2 }
	}
	set gndNets [split [gsr get gnd_nets] \n]
	foreach line $gndNets	{
		if	{ [regexp {[{}]} $line] } { continue }
		if 	{ [regexp {(\S+)\s+(\S+)} $line match 1 2] } { set gndM($1) $2 }
	}
	__MMX::setCmdLog $cmdLog
	if	{ [regexp -nocase {^gridcheck} $aMode] }	{
		set file [lindex [glob -nocomplain adsRpt/apache.macro.gridcheck] 0]
		if	{ $file == "" }	{ error	"can't find gridCheck result" }
		if	{ [catch { open $file r } FILE] } { error "can't open a file: $file" }
		while	{[gets $FILE line] >= 0}	{
			if	{ [regexp {^#} $line] } { continue }
			if	{ ![regexp {^\S+\s+(\S+)\s+(\S+)\s+\S+}	\
				$line match 1 vD] }	{ continue }
			set pg [lindex [split $1 .] 0]
			if	{ [array exists pgMap] && ![info exists pgMap($pg)] }	{ continue }
			set flagF 1
			set vD [expr $vD*1000]
			lappend vDL $vD
		}
		close	$FILE
		set title "Grid Check"
	}	elseif	{ [regexp -nocase {^rescalc$} $aMode] }	{
		error "not supported: $aMode"
	}	else	{ error "not supported: $aMode"	}
	if	{ $flagF }	{
		if	{ $maxVd <= $minVd } { error "incorrect range: -min/-max" }
		set dV [expr double(($maxVd-$minVd)/$binNum)]
		if	{ [info exists binSize] } { set dV $binSize }
		if	{ $dV < 1 } { set dV 1 }
		if	{ $dV > $maxVd } { set dV $maxVd }
		for	{ set i $minVd } { $i <= $maxVd } { set i [expr $i+$dV] } { set hM([expr double($i)]) 0 }
		set nXtor 0; set tXtor [llength $vDL]
		foreach	vD $vDL	{
			if	{ $vD < $minVd } { continue }
			set quo [expr int(ceil($vD-$minVd)/$dV)]
			set id [expr $quo*$dV+$minVd]
			if	{ $id >= $minVd && $id <= $maxVd } { incr nXtor; incr hM([expr double($id)]) }
		}
		if	[catch { open $outFile w } FILE] { error "can't make a file: $outFile" }
		puts	"generating $outFile..."
		if	{ $useLog }	{
			for	{ set i $minVd } { $i <= $maxVd } { set i [expr $i+$dV] }	{
				set v $hM([expr double($i)])
				set lv [expr $v > 0 ? log10($v) : 0]
				puts $FILE "[expr $i/1000]\t$lv"
			}
		}	else	{
			for	{ set i $minVd } { $i <= $maxVd } { set i [expr $i+$dV] }	{
				puts $FILE "[expr $i/1000]\t$hM([expr double($i)])"
			}
		}
		close	$FILE
		if	{ $nXtor }	{
			if	{ $useLog }	{
				exec xgraph -hist -ng -t $title -fmtx %g -fmty %g -x Resistance(%) -y Counts(log) $outFile &
			}	else	{
				exec xgraph -hist -ng -t $title -fmtx %g -fmty %g -x Resistance(%) -y Counts $outFile &
			}
		}
		puts	"$nXtor/$tXtor transistor(s) counted..."
	}
	return
}
proc	mmx_show_inst_state_man	{}	{
	puts	"
	mmx_show_inst_state
		?-inst/-i <inst_names>?
		?-overlay/-ov?
		?-iv?
		?-all? or ?-limit <number>?

		-overlay : preserve previous drawing
		-iv : make layers invisible for instance view
		-all : display all instances (default limit 500)

	<usage>
		mmx_show_inst_state 
"
}
proc	mmx_show_inst_state	{ args }	{
	__MMX::checkVer 9.1.0
	set argv [split $args]
	set nObj 0; set bm 1.004; set limit 500; set useLimit 1; set useOverlay 0; set useInstView 0
	set cState option; set pState na
	foreach arg $argv	{
		switch	$cState	{
			option	{
				switch -- $arg	{
					-limit		{ set cState flag_limit }
					-bm		{ set cState flag_bm }
					-overlay	{ set pState na; set useOverlay 1 }
					-ov		{ set pState na; set useOverlay 1 }
					-iv		{ set pState na; set useInstView 1 }
					-inst		{ set cState flag_inst; set useInst 1 }
					-i		{ set cState flag_inst; set useInst 1 }
					-h		{ mmx_show_inst_state_man; return }
					-help		{ mmx_show_inst_state_man; return }
					default	{
						if	{ [regexp {^-} $arg] }	{ error "unknown option: $arg" }
						if	{ ![string compare $pState flag_inst] }	{
							set instM($arg) 1
						}	else	{ error	"unknown option: $arg" }
					}
				}
			}
			flag_limit	{ set limit [expr {int([__MMX::eng2val $arg])}]; set pState na; set cState option }
			flag_bm		{ set bm [__MMX::eng2val $arg]; set pState na; set cState option }
			flag_inst	{ set instM($arg) 1; set pState $cState; set cState option }
			default		{ error "internal error: $cState" }
		}
	}
	if	{ [regexp {^flag} $cState] }	{ error "missing required option(s) or value(s)" }

	set cmdLog [__MMX::setCmdLog off]
	if	{ ![info exists instM] }	{
		set rect [zoom get]
		set x1 [expr [lindex $rect 0]/$bm]; set y1 [expr [lindex $rect 1]/$bm]
		set x2 [expr [lindex $rect 2]*$bm]; set y2 [expr [lindex $rect 3]*$bm]
		if	{ [catch { set instL [get inst * -glob -bbox $x1 $y1 $x2 $y2] }] }	{
			__MMX::setCmdLog $cmdLog
			error	"no instance found"
		}
		foreach inst $instL	{ set instM($inst) 1 }		
	}
	set mstFile ".apache/mstate.out"
	if	{ [catch { open $mstFile r } IN] }	{
		__MMX::setCmdLog $cmdLog
		error	"can't find dynamic analysis result"
	}
	while	{[gets $IN line] >= 0}	{
		regexp {(.*?)[#\$]} $line match line
		if	{ ![regexp {(\d+)\s+\d+\s+(\S+)\s+(\d+)} $line match id state tw] }	{ continue }
		if	{ [catch { set inst [get instbyid $id] }] }	{ continue }
		if	{ ![regexp {Name: (\S+)} $inst match inst] }	{ continue }
		if	{ ![info exists instM($inst)] }	{ continue }
		set stateM($inst) $state; set timingM($inst) [__MMX::val2eng "$tw\e-12"]
	}
	close	$IN
	set instL [array names stateM]
	set nTObj [llength $instL]
	if	{ $nTObj == 0 }	{
		__MMX::setCmdLog $cmdLog
		error	"no instance found"
	}
	set id 0; set nSV 0
	foreach inst $instL	{
		if	{ $useLimit && $id >= $limit }	{ break }
		set cell [get inst $inst -master]
		if	{ ![info exists cMap($cell)] }	{
			set cMap($cell) [string length $cell]
			set width [get cell $cell -width]
			set height [get cell $cell -height]
			set cwMap($cell) $width
			set chMap($cell) $height
		}
		set icMap($inst) $cell
		incr id
	}
	puts	"$nTObj instance(s)"
	set instL [array names icMap]
	set nObj [llength $instL]
	if	{ $nTObj > $nObj }	{
		puts	"$nObj instance(s) displayed, use -limit/-all at your own risk"
	}
	foreach inst $instL	{
		set cell $icMap($inst)
		set orient [get inst $inst -orientation]
		set location [get inst $inst -location]
		set x1 [lindex $location 0]; set y1 [lindex $location 1]
		set iMap($inst,x1) $x1; set iMap($inst,y1) $y1
		set n1 [string length $inst]
		set n2 [expr [string length $stateM($inst)]+4]
		set n3 [expr [string length $timingM($inst)]+4]
		set nl [expr $n1 > $n2 ? [expr $n1 > $n3 ? $n1 : $n3] : [expr $n2 > $n3 ? $n2 : $n3]]
		if	{ [regexp {(west|east)} $orient] }	{
			set height $cwMap($cell); set width $chMap($cell)
		}	else	{
			set width $cwMap($cell); set height $chMap($cell)
		}
		set iMap($inst,w) $width; set iMap($inst,h) $height
		if	{ $width < $height }	{
			set fontSize [expr {double($height)/($nl+2)}]
			if	{ $fontSize > [expr $width/5] }	{
				set fontSize [expr $width/5]; set ym [expr {0.5*($height-$fontSize*$nl)+$fontSize}]
			}	else	{
				set ym $fontSize
			}
			set xm [expr {2*$width/5}]
			set iMap($inst,fs) $fontSize; set iMap($inst,d) 1
			set iMap($inst,x) [expr {$x1+$xm}]; set iMap($inst,y) [expr {$y1+$ym}]
		}	else	{
			set fontSize [expr {double($width)/($nl+2)}]
			if	{ $fontSize > [expr $height/5] }	{
				set fontSize [expr $height/5]; set xm [expr {0.5*($width-$fontSize*$nl)+$fontSize}]
			}	else	{
				set xm $fontSize
			}
			set ym [expr {3*$height/5}]
			set iMap($inst,fs) $fontSize; set iMap($inst,d) 0
			set iMap($inst,x) [expr {$x1+$xm}]; set iMap($inst,y) [expr {$y1+$ym}]
		}
	}
	if	{ $useOverlay == 0 }	{ plot line -clearall; marker delete -all; select clearall; refresh }
	if	{ $useInstView }	{
		config viewlayer -name all -style invisible
		config viewlayer -name instance -style outline
	}
	set cId 3
	foreach inst $instL	{
		set cell $icMap($inst)
		if	{ $cMap($cell) == 0 }	{ continue }
		set x $iMap($inst,x); set y $iMap($inst,y)
		set d $iMap($inst,d); set fontSize $iMap($inst,fs)
		set st $stateM($inst); set tw $timingM($inst)
		if	{ [info exists colorM($st,$tw)] }	{
			set col $colorM($st,$tw)
		}	else	{
			set col [__MMX::getColorTxt $cId]; set colorM($st,$tw) $col; incr cId
		}
		if	{$d}	{
			set fs [expr 0.8*$fontSize]
			__MMX::putMsg $inst $x $y $fs $fs $col 1 1
			set x [expr $x+$fontSize]
			__MMX::putMsg "ST: $st" $x $y $fs $fs $col 1 1
			set x [expr $x+$fontSize]
			__MMX::putMsg "TW: $tw" $x $y $fs $fs $col 1 1
		}	else	{
			set fs [expr 0.8*$fontSize]
			__MMX::putMsg $inst $x $y $fs $fs $col 1 0
			set y [expr $y-$fontSize]
			__MMX::putMsg "ST: $st" $x $y $fs $fs $col 1 0
			set y [expr $y-$fontSize]
			__MMX::putMsg "TW: $tw" $x $y $fs $fs $col 1 0
		}
	}
	__MMX::setCmdLog $cmdLog
	return
}
proc	mmx_show_decap_cell_man	{}	{
	puts	"
	mmx_show_decap_cell
		?-cell/-c <cell_names>?
		?-pgarc/-pg <vdd1> <vss1> ...?
		?-overlay/-ov?
		?-iv?

		-pgarc : display decap cells only between specified pgarcs
		-overlay : preserve previous drawing
		-iv : make layers invisible for instance view

	<usage>
		mmx_show_decap_cell
		mmx_show_decap_cell -c DECAP*
		mmx_show_decap_cell -pg vdd vss vddq vssq
"
}
proc	mmx_show_decap_cell	{ args }	{
	__MMX::checkVer 9.1.0
	set argv [split $args]
	set nObj 0; set useCell 0; set useOverlay 0; set usePG 0
	set bm 1.004; set useInstView 0
	set cState option; set pState na
	foreach arg $argv	{
		switch	$cState	{
			option	{
				switch -- $arg	{
					-limit		{ set cState flag_limit }
					-bm		{ set cState flag_bm }
					-pgarc		{ set cState flag_np; set usePG 1 }
					-pg		{ set cState flag_np; set usePG 1 }
					-overlay	{ set pState na; set useOverlay 1 }
					-ov		{ set pState na; set useOverlay 1 }
					-iv		{ set pState na; set useInstView 1 }
					-cell		{ set cState flag_cell; set useCell 1 }
					-c		{ set cState flag_cell; set useCell 1 }
					-h		{ mmx_show_decap_cell_man; return }
					-help		{ mmx_show_decap_cell_man; return }
					default	{
						if	{ [regexp {^-} $arg] }	{ error "unknown option: $arg" }
						if	{ ![string compare $pState flag_cell] }	{
							lappend cellL $arg
						}	elseif	{ ![string compare $pState flag_np] }	{
							lappend netL $arg
						}	else	{ error	"unknown option: $arg" }
					}
				}
			}
			flag_cell	{ lappend cellL $arg; set pState $cState; set cState option }
			flag_bm		{ set bm [__MMX::eng2val $arg]; set pState na; set cState option }
			flag_np		{ lappend netL $arg; set pState $cState; set cState option }
			default		{ error "internal error: $cState" }
		}
	}
	if	{ [regexp {^flag} $cState] }	{ error "missing required option(s) or value(s)" }
	set cmdLog [__MMX::setCmdLog off]
	if	{ $usePG }	{
		foreach net $netL	{
			if	{ [catch { get net $net -exact }] }	{
				__MMX::setCmdLog $cmdLog
				error	"unknown net: $net"
			}
		}
		set l [llength $netL]
		if	{ [expr $l%2] != 0 }	{
			__MMX::setCmdLog $cmdLog
			error	"unpaired value(s): -pg <vdd1> <vss1> ..."
		}
		for {set i 0} {$i < $l} {set i [expr $i+2]}	{
			set n1 [lindex $netL $i]; set n2 [lindex $netL [expr $i+1]]
			set pgarc "$n1 $n2"
			set pgarcM($pgarc) 1
		}
	}
	if	{ $useCell }	{
		foreach cell $cellL	{
			if	{ [catch { set cCellL [get cell $cell -glob] }] }	{ continue }
			foreach cCell $cCellL	{
				set dM($cCell) 1
			}
		}
		set cellL [array names dM]
	}	else	{
		if	{ [catch { set cellL [get cell * -glob -type decap] }] }	{
			__MMX::setCmdLog $cmdLog
			error "no decap instance found"
		}
		set top [get design]
		foreach cell $cellL	{
			set dM($cell) 1
			if	{ ![regexp "^($top\_(\\S+)_)\\d+$" $cell match f oc] }	{ continue }
			if	{ [catch { set cCellL [get cell "$f\\d+" -regexp] }] }	{ continue }
			foreach cCell $cCellL	{
				set dM($cCell) 1
			}
		}
		set cellL [array names dM]
	}
	set rect [zoom get]
	set x1 [expr [lindex $rect 0]/$bm]; set y1 [expr [lindex $rect 1]/$bm]
	set x2 [expr [lindex $rect 2]*$bm]; set y2 [expr [lindex $rect 3]*$bm]
	set tC 0
	foreach cell $cellL	{
		if	{ [catch { set instL [get inst * -glob -master $cell -bbox $x1 $y1 $x2 $y2] }] }	{ continue }
		if	{ [catch { set pgarc [get cell $cell -pgarcs] }] }	{
			foreach inst $instL	{
				set idM($inst) 0
			}
			continue
		}
		foreach inst $instL	{
			set c [get inst $inst -decap -state high]
			if	{ $c > 0 }	{
				if	{ $usePG && ![info exists pgarcM($pgarc)] }	{ continue }
				set vdM($inst) $c; set tC [expr $tC+$c]
			}	else	{
				set idM($inst) $c
			}
		}
	}
	set vdL [array names vdM]; set idL [array names idM]
	set nVd [llength $vdL]; set nId [llength $idL]
	set nTObj [expr $nVd+$nId]
	if	{ $nTObj == 0 }	{
		__MMX::setCmdLog $cmdLog
		error "no decap instance found"
	}
	puts	"num of total decap inst(s)    :  $nTObj"
	puts	"num of valid decap inst(s)    :  $nVd"
	puts	"num of invalid decap inst(s)  :  $nId"
	puts	"total intentional cap         :  $tC pF"
	if	{ $useOverlay == 0 }	{ plot line -clearall; marker delete -all; select clearall; refresh }
	if	{ $useInstView }	{
		config viewlayer -name all -style invisible
		config viewlayer -name instance -style outline
	}
	marker add -instance $vdL -color blue
	marker add -instance $idL -color red
	__MMX::setCmdLog $cmdLog
	return
}
proc	mmx_show_bpa_cell_man	{}	{
	puts	"
	mmx_show_bpa_cell
		?-cell/-c <cell_names>?
		?-overlay/-ov?
		?-iv?

		-overlay : preserve previous drawing
		-iv : make layers invisible for instance view

	<usage>
		mmx_show_bpa_cell
		mmx_show_bpa_cell -c adsU1_*
"
}
proc	mmx_show_bpa_cell	{ args }	{
	__MMX::checkVer 9.1.0
	set argv [split $args]
	set nObj 0; set useCell 0; set useOverlay 0
	set bm 1.004; set useInstView 0
	set cState option; set pState na
	foreach arg $argv	{
		switch	$cState	{
			option	{
				switch -- $arg	{
					-limit		{ set cState flag_limit }
					-bm		{ set cState flag_bm }
					-overlay	{ set pState na; set useOverlay 1 }
					-ov		{ set pState na; set useOverlay 1 }
					-iv		{ set pState na; set useInstView 1 }
					-cell		{ set cState flag_cell; set useCell 1 }
					-c		{ set cState flag_cell; set useCell 1 }
					-h		{ mmx_show_bpa_cell_man; return }
					-help		{ mmx_show_bpa_cell_man; return }
					default	{
						if	{ [regexp {^-} $arg] }	{ error "unknown option: $arg" }
						if	{ ![string compare $pState flag_cell] }	{
							lappend cellL $arg
						}	else	{ error	"unknown option: $arg" }
					}
				}
			}
			flag_cell	{ lappend cellL $arg; set pState $cState; set cState option }
			flag_bm		{ set bm [__MMX::eng2val $arg]; set pState na; set cState option }
			default		{ error "internal error: $cState" }
		}
	}
	if	{ [regexp {^flag} $cState] }	{ error "missing required option(s) or value(s)" }
	set cmdLog [__MMX::setCmdLog off]
	if	{ $useCell }	{
		foreach cell $cellL	{
			if	{ [catch { set cCellL [get cell $cell -glob] }] }	{ continue }
			foreach cCell $cCellL	{
				set dM($cCell) 1
			}
		}
		set cellL [array names dM]
	}	else	{
		if	{ [catch { set cellL [get cell adsU1_* -glob] }] }	{
			__MMX::setCmdLog $cmdLog
			error "no BPA instance found"
		}
		set top [get design]
		foreach cell $cellL	{
			set dM($cell) 1
			if	{ ![regexp "^($top\_(\\S+)_)\\d+$" $cell match f oc] }	{ continue }
			if	{ [catch { set cCellL [get cell "$f\\d+" -regexp] }] }	{ continue }
			foreach cCell $cCellL	{
				set dM($cCell) 1
			}
		}
		set cellL [array names dM]
	}
	set rect [zoom get]
	set x1 [expr [lindex $rect 0]/$bm]; set y1 [expr [lindex $rect 1]/$bm]
	set x2 [expr [lindex $rect 2]*$bm]; set y2 [expr [lindex $rect 3]*$bm]
	set tC 0
	foreach cell $cellL	{
		if	{ [catch { set instL [get inst * -glob -master $cell -bbox $x1 $y1 $x2 $y2] }] }	{ continue }
#		if	{ [catch { set pgarc [get cell $cell -pgarcs] }] }	{ continue }
		foreach inst $instL	{
			set c [get inst $inst -power]
			if	{ $c > 0 }	{
				set vdM($inst) $c; set tC [expr $tC+$c]
			}	else	{
				set idM($inst) $c
			}
		}
	}
	set vdL [array names vdM]; set idL [array names idM]
	set nVd [llength $vdL]; set nId [llength $idL]
	set nTObj [expr $nVd+$nId]
	if	{ $nTObj == 0 }	{
		__MMX::setCmdLog $cmdLog
		error "no BPA instance found"
	}
	puts	"num of total BPA inst(s)    :  $nTObj"
	puts	"num of valid BPA inst(s)    :  $nVd"
	puts	"num of invalid BPA inst(s)  :  $nId"
	puts	"total instance power        :  $tC W"
	if	{ $useOverlay == 0 }	{ plot line -clearall; marker delete -all; select clearall; refresh }
	if	{ $useInstView }	{
		config viewlayer -name all -style invisible
		config viewlayer -name instance -style outline
	}
	marker add -instance $vdL -color blue
	marker add -instance $idL -color red
	__MMX::setCmdLog $cmdLog
	return
}
proc	mmx_set	{ args }	{
	set argv [split $args]
	if	{ [llength $argv] < 1 }	{
		puts	[format "\n%30s\t%s" variable value]
		puts	[format "%30s\t%s" -------- -----]
		foreach var [lsort [array names __MMX::varMap]]	{
			puts	[format "%30s\t%s" $var $__MMX::varMap($var)]
		}
		puts	""
		return
	}
	set var [lindex $argv 0]
	if	{ ![info exists __MMX::varMap($var)] }	{
		puts	"'$var' is not a valid mmx_set variable"
		return	
	}
	if	{ [llength $argv] < 2 }	{
		if	{ [info exists __MMX::mmxData($var)] }	{
			puts	$__MMX::mmxData($var)
		}
	}	else	{
		set data [join [lrange $argv 1 end]]
		if	{ ![string compare $data \{\}] }	{
			if	{ [info exists __MMX::mmxData($var)] }	{ unset __MMX::mmxData($var) }
		}	else	{
			set __MMX::mmxData($var) $data
		}
	}
	return
}
