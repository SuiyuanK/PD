namespace eval __GUI {
	variable fontVec

	set __GUI::fontVec(0) [list "0 1 0 5" "0 5 1 6" "1 6 3 6" "3 6 4 5" "4 5 4 1" "4 1 3 0" "3 0 1 0" "1 0 0 1" \
		"0 1 4 5"]
	set __GUI::fontVec(1) [list "2 0 2 6" "2 6 1 5"]
	set __GUI::fontVec(2) [list "0 5 1 6" "1 6 3 6" "3 6 4 5" "4 5 4 4" "4 4 0 0" "0 0 4 0"]
	set __GUI::fontVec(3) [list "0 5 1 6" "1 6 3 6" "3 6 4 5" "4 5 4 4" "4 4 3 3" "3 3 2 3" "3 3 4 2" "4 2 4 1" \
		"4 1 3 0" "3 0 1 0" "1 0 0 1"]
	set __GUI::fontVec(4) [list "3 6 3 0" "3 6 0 2" "0 2 4 2"]
	set __GUI::fontVec(5) [list "0 6 4 6" "0 6 0 4" "0 4 3 4" "3 4 4 3" "4 3 4 1" "4 1 3 0" "3 0 1 0" "1 0 0 1"]
	set __GUI::fontVec(6) [list "0 1 0 5" "0 5 1 6" "1 6 3 6" "3 6 4 5" "0 3 3 3" "3 3 4 2" "4 2 4 1" "4 1 3 0" \
		"3 0 1 0" "1 0 0 1"]
	set __GUI::fontVec(7) [list "0 6 4 6" "4 6 1 0"]
	set __GUI::fontVec(8) [list "0 5 1 6" "1 6 3 6" "3 6 4 5" "4 5 4 4" "4 4 3 3" "3 3 1 3" "1 3 0 4" "0 4 0 5" \
		"3 3 4 2" "4 2 4 1" "4 1 3 0" "3 0 1 0" "1 0 0 1" "0 1 0 2" "0 2 1 3"]
	set __GUI::fontVec(9) [list "0 5 1 6" "1 6 3 6" "3 6 4 5" "4 5 4 1" "4 1 3 0" "3 0 1 0" "1 0 0 1" "0 5 0 4" \
		"0 4 1 3" "1 3 4 3"]
	set __GUI::fontVec(.) [list "1 0 1 1" "1 1 2 1" "2 1 2 0" "2 0 1 0"]
	set __GUI::fontVec(,) [list "1 0 1 1" "1 1 2 1" "2 1 2 0" "2 0 1 0" "2 0 1 -1"]
	set __GUI::fontVec(-) [list "0 3 4 3"]
	set __GUI::fontVec(_) [list "-1 0 5 0"]
	set __GUI::fontVec(+) [list "0 3 4 3" "2 1 2 5"]
	set __GUI::fontVec(/) [list "0 0 4 6"]
	set __GUI::fontVec(\) [list "0 6 4 0"]
	set __GUI::fontVec(() [list "2 1 2 5" "2 1 3 0" "2 5 3 6"]
	set __GUI::fontVec()) [list "2 1 2 5" "2 1 1 0" "2 5 1 6"]
	set __GUI::fontVec(<) [list "1 3 4 6" "1 3 4 0"]
	set __GUI::fontVec(>) [list "1 6 4 3" "1 0 4 3"]
	set __GUI::fontVec(\[) [list "2 0 2 6" "2 0 3 0" "2 6 3 6"]
	set __GUI::fontVec(\]) [list "2 0 2 6" "2 0 1 0" "2 6 1 6"]
	set __GUI::fontVec(?) [list "0 5 1 6" "1 6 3 6" "3 6 4 5" "4 5 4 4" "4 4 2 2" "2 1 2 0"]
	set __GUI::fontVec(:) [list "1 0 1 1" "1 1 2 1" "2 1 2 0" "2 0 1 0" "1 3 1 4" "1 4 2 4" "2 4 2 3" "2 3 1 3"]
	set __GUI::fontVec(\;) [list "1 0 1 1" "1 1 2 1" "2 1 2 0" "2 0 1 0" "2 0 1 -1" "1 3 1 4" "1 4 2 4" "2 4 2 3" \
		"2 3 1 3"]
	set __GUI::fontVec(a) [list "1 0 4 0" "4 0 4 3" "4 3 3 4" "3 4 1 4" "1 0 0 1" "0 1 1 2" "1 2 4 2"]
	set __GUI::fontVec(b) [list "0 1 1 0" "0 0 0 6" "1 0 3 0" "3 0 4 1" "4 1 4 3" "4 3 3 4" "3 4 1 4" "1 4 0 3"]
	set __GUI::fontVec(c) [list "1 0 3 0" "3 0 4 1" "1 0 0 1" "0 1 0 3" "0 3 1 4" "1 4 3 4" "3 4 4 3"]
	set __GUI::fontVec(d) [list "4 6 4 0" "4 1 3 0" "3 0 1 0" "1 0 0 1" "0 1 0 3" "0 3 1 4" "1 4 3 4" "3 4 4 3"]
	set __GUI::fontVec(e) [list "1 0 3 0" "3 0 4 1" "1 0 0 1" "0 1 0 3" "0 3 1 4" "1 4 3 4" "3 4 4 3" "4 3 3 2" \
		"3 2 0 2"]
	set __GUI::fontVec(f) [list "1 0 1 5" "1 5 2 6" "2 6 3 6" "3 6 4 5" "0 3 3 3"]
	set __GUI::fontVec(g) [list "4 3 4 -1" "4 -1 3 -2" "3 -2 1 -2" "1 -2 0 -1" "4 1 3 0" "3 0 1 0" "1 0 0 1" \
		"0 1 0 3" "0 3 1 4" "1 4 3 4" "3 4 4 3"]
	set __GUI::fontVec(h) [list "0 0 0 6" "4 0 4 3" "4 3 3 4" "3 4 1 4" "1 4 0 3"]
	set __GUI::fontVec(i) [list "2 0 2 4" "2 5 2 6"]
	set __GUI::fontVec(j) [list "3 0 3 4" "3 0 2 -1" "2 -1 1 -1" "1 -1 0 0" "3 5 3 6"]
	set __GUI::fontVec(k) [list "0 0 0 6" "1 2 4 0" "1 2 4 4" "0 2 1 2"]
	set __GUI::fontVec(l) [list "2 0 2 6"]
	set __GUI::fontVec(m) [list "0 0 0 4" "4 0 4 3" "1 4 2 3" "2 3 2 0" "2 3 3 4" "3 4 4 3" "1 4 0 3"]
	set __GUI::fontVec(n) [list "0 0 0 4" "0 3 1 4" "4 0 4 3" "4 3 3 4" "3 4 1 4" "1 4 0 3"]
	set __GUI::fontVec(o) [list "1 0 3 0" "3 0 4 1" "1 0 0 1" "0 1 0 3" "0 3 1 4" "1 4 3 4" "3 4 4 3" "4 3 4 1"]
	set __GUI::fontVec(p) [list "0 1 1 0" "0 -1 0 4" "1 0 3 0" "3 0 4 1" "4 1 4 3" "4 3 3 4" "3 4 1 4" "1 4 0 3"]
	set __GUI::fontVec(q) [list "1 0 3 0" "3 0 4 1" "1 0 0 1" "0 1 0 3" "0 3 1 4" "1 4 3 4" "3 4 4 3" "4 4 4 -1"]
	set __GUI::fontVec(r) [list "0 0 0 4" "0 3 1 4" "1 4 3 4" "3 4 4 3"]
	set __GUI::fontVec(s) [list "0 1 1 0" "1 0 3 0" "3 0 4 1" "4 1 0 3" "0 3 1 4" "1 4 3 4" \
		"3 4 4 3"]
	set __GUI::fontVec(t) [list "2 6 2 1" "2 1 3 0" "3 0 4 0" "1 4 4 4"]
	set __GUI::fontVec(u) [list "1 0 3 0" "3 0 4 1" "1 0 0 1" "0 1 0 4" "4 4 4 0"]
	set __GUI::fontVec(v) [list "0 4 2 0" "2 0 4 4"]
	set __GUI::fontVec(w) [list "0 1 0 4" "0 1 1 0" "1 0 2 1" "2 1 2 2" "2 1 3 0" "3 0 4 1" "4 1 4 4"]
	set __GUI::fontVec(x) [list "0 4 4 0" "0 0 4 4"]
	set __GUI::fontVec(y) [list "4 4 4 -1" "4 -1 3 -2" "3 -2 1 -2" "1 -2 0 -1" "4 1 3 0" "3 0 1 0" "1 0 0 1" \
		"0 1 0 4"]
	set __GUI::fontVec(z) [list "0 4 4 4" "0 0 4 0" "0 0 4 4"]
	set __GUI::fontVec(A) [list "0 0 0 5" "0 5 1 6" "1 6 3 6" "3 6 4 5" "4 5 4 0" "0 3 4 3"]
	set __GUI::fontVec(B) [list "0 0 0 6" "0 6 3 6" "3 6 4 5" "4 5 4 4" "4 4 3 3" "3 3 0 3" "0 0 3 0" "3 0 4 1" \
		"4 1 4 2" "4 2 3 3"]
	set __GUI::fontVec(C) [list "0 1 0 5" "0 5 1 6" "1 6 3 6" "3 6 4 5" "0 1 1 0" "1 0 3 0" "3 0 4 1"]
	set __GUI::fontVec(D) [list "0 0 0 6" "0 6 3 6" "3 6 4 5" "4 5 4 1" "4 1 3 0" "3 0 0 0"]
	set __GUI::fontVec(E) [list "0 0 0 6" "0 6 4 6" "0 3 3 3" "0 0 4 0"]
	set __GUI::fontVec(F) [list "0 0 0 6" "0 6 4 6" "0 3 3 3"]
	set __GUI::fontVec(G) [list "0 1 0 5" "0 5 1 6" "1 6 3 6" "3 6 4 5" "0 1 1 0" "1 0 3 0" "3 0 4 1" "4 1 4 3" \
		"4 3 2 3"]
	set __GUI::fontVec(H) [list "0 0 0 6" "4 0 4 6" "0 3 4 3"]
	set __GUI::fontVec(I) [list "2 0 2 6"]
	set __GUI::fontVec(J) [list "0 2 0 1" "0 1 1 0" "1 0 3 0" "3 0 4 1" "4 1 4 6"]
	set __GUI::fontVec(K) [list "0 0 0 6" "1 3 4 6" "1 3 4 0" "0 3 1 3"]
	set __GUI::fontVec(L) [list "0 0 0 6" "0 0 4 0"]
	set __GUI::fontVec(M) [list "0 0 0 6" "4 0 4 6" "0 6 2 3" "2 3 4 6"]
	set __GUI::fontVec(N) [list "0 0 0 6" "4 0 4 6" "0 6 4 0"]
	set __GUI::fontVec(O) [list "0 1 0 5" "0 5 1 6" "1 6 3 6" "3 6 4 5" "0 1 1 0" "1 0 3 0" "3 0 4 1" "4 1 4 5"]
	set __GUI::fontVec(P) [list "0 0 0 6" "0 6 3 6" "3 6 4 5" "4 5 4 4" "4 4 3 3" "3 3 0 3"]
	set __GUI::fontVec(Q) [list "0 1 0 5" "0 5 1 6" "1 6 3 6" "3 6 4 5" "0 1 1 0" "1 0 3 0" "3 0 4 1" "4 1 4 5" \
		"2 2 4 0"]
	set __GUI::fontVec(R) [list "0 0 0 6" "0 6 3 6" "3 6 4 5" "4 5 4 4" "4 4 3 3" "3 3 0 3" "3 3 4 2" "4 2 4 0"]
	set __GUI::fontVec(S) [list "0 1 1 0" "1 0 3 0" "3 0 4 1" "4 1 4 2" "4 2 3 3" "3 3 1 3" "1 3 0 4" "0 4 0 5" \
		"0 5 1 6" "1 6 3 6" "3 6 4 5"]
	set __GUI::fontVec(T) [list "2 0 2 6" "0 6 4 6"]
	set __GUI::fontVec(U) [list "0 1 0 6" "0 1 1 0" "1 0 3 0" "3 0 4 1" "4 1 4 6"]
	set __GUI::fontVec(V) [list "0 6 0 2" "0 2 2 0" "2 0 4 2" "4 2 4 6"]
	set __GUI::fontVec(W) [list "0 0 0 6" "4 0 4 6" "0 0 2 3" "2 3 4 0"]
	set __GUI::fontVec(X) [list "0 6 4 0" "4 6 0 0"]
	set __GUI::fontVec(Y) [list "0 6 2 3" "4 6 2 3" "2 3 2 0"]
	set __GUI::fontVec(Z) [list "0 6 4 6" "0 0 4 0" "4 6 0 0"]
	

proc    putMsg  { arg x y {xh 6} {yh 7} {c white} {w 1}}        {
                set len [string length $arg]
                for     {set i 0} { $i < $len } {incr i}        {
                        set char [string index $arg $i]
                        if      { $char == " " }        {
                                set x [expr $x+$xh]
                                continue
                        }
                        set fV [expr {[info exists __GUI::fontVec($char)] ? \
                                $__GUI::fontVec([string index $arg $i]) : $__GUI::fontVec(-)}]
                        foreach ld $fV  {
                                set x1 [expr [lindex $ld 0]*$xh/6.0 + $x]
                                set y1 [expr [lindex $ld 1]*$yh/7.0 + $y]
                                set x2 [expr [lindex $ld 2]*$xh/6.0 + $x]
                                set y2 [expr [lindex $ld 3]*$yh/7.0 + $y]
                                plot line -position $x1 $y1 $x2 $y2 -color $c -width $w
                        }
                        set x [expr $x+$xh]
                }
        }
}
proc  add_label_man {} {
 	puts "
	add_label -t <text> -position <x> <y> ?-size <size>? ?-color <color>? ?-h?
	where:
	<text>	: specifies the text_label to place
	<x> <y>	: specifies the x,y location (in  microns) of the text label
	-size <size> : specifies the size of text. Default 3
	-color <color> : specifies the color of text label. Default green
"
}
proc add_label { args } {
	set argv [split $args]
	set argc [llength $argv]

if {$argc == 0} {
        puts "Please refer to the usage"
        add_label_man; return
}

if {$argc == 1} {
        if {[regexp {\-h} [lindex $argv 0]]} {
                add_label_man;return
        } elseif  {[regexp {\-help} [lindex $argv 0]]} {
                add_label_man; return
        } elseif  {[regexp {\-m} [lindex $argv 0]]} {
                add_label_man; return
        }
}
set s 3; set c green; set text 0; set pos 0;
for {set j 0} {$j < $argc} {incr j 1} {
        if  {[regexp {\-h} [lindex $argv $j]]} {
        add_label_man;return
        } elseif  {[regexp {\-m} [lindex $argv $j]]} {
               add_label_man;return
        } elseif  {[regexp {\-help} [lindex $argv $j]]} {
               add_label_man;return
        } elseif {[regexp {\-t} [lindex $argv $j]]} {
                set text 1
		set t [lindex $argv [expr $j + 1]]
	} elseif {[regexp {\-position} [lindex $argv $j]]} {
		set pos 1
		set a [lindex $argv [expr $j + 1]]
		set b [lindex $argv [expr $j + 2]]
		if { [string is double $a] ==1 && [string is double $b] ==1 } {
			set x $a
			set y $b
		} else {
		puts "\n wrong # args: should be \"-position <x> <y>\"\n"
		return
		}	
	} elseif {[regexp {\-size} [lindex $argv $j]]} {
		set s [lindex $argv [expr $j + 1]]
	} elseif {[regexp {\-color} [lindex $argv $j]]} {
		set c [lindex $argv [expr $j + 1]]
	}
}

if {$text == 0} {
 	puts "please put -t <text_label>\n"
	add_label_man;return
}
if {$pos == 0} {
	puts "please put -position <x> <y> \n"
	add_label_man;return
}

      	__GUI:::putMsg $t $x $y $s $s $c
}
