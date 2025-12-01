#!/usr/bin/wish

proc Scrolled_Canvas { c args } { 
	frame $c
	eval {canvas $c.canvas \
		-xscrollcommand [list $c.xscroll set] \
		-yscrollcommand [list $c.yscroll set] \
		-highlightthickness 0 \
		-borderwidth 0} $args
	scrollbar $c.xscroll -orient horizontal \
		-command [list $c.canvas xview]
	scrollbar $c.yscroll -orient vertical \
		-command [list $c.canvas yview]
	grid $c.canvas $c.yscroll -sticky news
	grid $c.xscroll -sticky ew
	grid rowconfigure $c 0 -weight 1
	grid columnconfigure $c 0 -weight 1
	return $c.canvas
}

set OUT [open atclSwitchCurrtemp.out r]
set i 1
while { [gets $OUT line] >=0 } {
        regsub -all -- {[[:space:]]+} $line " " line
        set line [split $line]
        set lowrange($i) [lindex $line 0] 
        set highrange($i) [lindex $line 1]
	set i [expr $i + 1]
} 
close $OUT
#set can [Scrolled_Canvas .c -width 40 -height 420 -scrollregion {0 0 40 420}]
set can [Scrolled_Canvas .c -width 400 -height 420 ]
pack .c -fill both -expand true
$can configure -background white

$can create text  150 10 -text "<Color>  <Current low(A)>   <Current high(A)> " -fill blue
$can create rect 0 20 20 40 -fill #15317E
$can create text  150 30 -text "\[$lowrange(1)  $highrange(1)\)" -fill blue
$can create rect 0 40 20 60 -fill #2554C7
$can create text  150 50 -text "\[$lowrange(2)  $highrange(2)\)" -fill blue
$can create rect 0 60 20 80 -fill #306EFF
$can create text  150 70 -text "\[$lowrange(3)  $highrange(3)\)" -fill blue
$can create rect 0 80 20 100 -fill #3BB9FF
$can create text  150 90 -text "\[$lowrange(4)  $highrange(4)\)" -fill blue
$can create rect 0 100 20 120 -fill #50EBEC
$can create text  150 110 -text "\[$lowrange(5)  $highrange(5)\)" -fill blue
$can create rect 0 120 20 140 -fill #307D7E
$can create text  150 130 -text "\[$lowrange(6)  $highrange(6)\)" -fill blue
$can create rect 0 140 20 160 -fill #617C58
$can create text  150 150 -text "\[$lowrange(7)  $highrange(7)\)" -fill blue
$can create rect 0 160 20 180 -fill #347C17
$can create text  150 170 -text "\[$lowrange(8)  $highrange(8)\)" -fill blue
$can create rect 0 180 20 200 -fill #00FF00
$can create text  150 190 -text "\[$lowrange(9)  $highrange(9)\)" -fill blue
$can create rect 0 200 20 220 -fill #B1FB17
$can create text  150 210 -text "\[$lowrange(10)  $highrange(10)\)" -fill blue
$can create rect 0 220 20 240 -fill #FFFF00
$can create text  150 230 -text "\[$lowrange(11)  $highrange(11)\)" -fill blue
$can create rect 0 240 20 260 -fill #FDD017
$can create text  150 250 -text "\[$lowrange(12)  $highrange(12)\)" -fill blue
$can create rect 0 260 20 280 -fill #F88017
$can create text  150 270 -text "\[$lowrange(13)  $highrange(13)\)" -fill blue
$can create rect 0 280 20 300 -fill #E56717
$can create text  150 290 -text "\[$lowrange(14)  $highrange(14)\)" -fill blue
$can create rect 0 300 20 320 -fill #C35617
$can create text  150 310 -text "\[$lowrange(15)  $highrange(15)\)" -fill blue
$can create rect 0 320 20 340 -fill #F75D59
$can create text  150 330 -text "\[$lowrange(16)  $highrange(16)\)" -fill blue
$can create rect 0 340 20 360 -fill #E55451
$can create text  150 350 -text "\[$lowrange(17)  $highrange(17)\)" -fill blue
$can create rect 0 360 20 380 -fill #FF0000
$can create text  150 370 -text "\[$lowrange(18)  $highrange(18)\)" -fill blue
$can create rect 0 380 20 400 -fill #F62217
$can create text  150 390 -text "\[$lowrange(19)  $highrange(19)\)" -fill blue
$can create rect 0 400 20 420 -fill #E41B17
$can create text  150 410 -text "\[$lowrange(20)  $highrange(20)\]" -fill blue
file delete -force atclSwitchCurrtemp.out
