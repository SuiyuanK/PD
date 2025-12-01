# $Revision: 2.1 $
################################################################
# (C) COPYRIGHT 2015 ANSYS Inc
# ALL RIGHTS RESERVED
#
#
#   $Author: indqa $
#   $Date: 2015/08/10 09:46:03 $
#   $Revision: 2.1 $
#   $Id: atcl_dumpCriticalSignalNets.tcl,v 2.1 2015/08/10 09:46:03 indqa Exp $
#   Description :
#   atcl_dumpCriticalSignalNets.tcl is an Ansys AE TCL utility for listing out the critical nets for signalEM analysis based on user-specified list of      cellnames for drivers
#   Usage: source atcl_dumpCriticalSignalNets.tcl
#   atcl_dumpCriticalSignalNets -driver_list <file which contains driver cells> -exclude  <when used, all the signal/clock nets in the design excuding the nets driven by instances of specified driver cell will be outputted> -warncount <Specify no of warning messages to be printed in total, when queried instances has no output pins> -o <output file>
# TclPro::Compiler::Include

if {[catch {package require tbcload 1.6} err] == 1} {
    return -code error "[info script]: The TclPro ByteCode Loader is not available or does not support the correct version -- $err"
}
tbcload::bceval {
TclPro ByteCode 2 0 1.7 8.4
2 0 22 8 0 0 24 0 4 2 2 -1 -1
22
+EE<!(H&s!/HW<!.E`<!3)Ppv%!!
2
,B!
2
6?!
8
x
4
,CHr@
x
35
qQ%hCrA90DxRZlBnvO:@y:(5BV?F2:#=UZ?w*K,EOef+
x
0

p
1 0 7 2 0 0 8 0 2 1 1 -1 -1
7
w0E<!)'!!
1
z
1
'!
2
x
4
DP)*F
x
1054
7Y5|=b7wc;=%;:+LdV<+8x?3@o4jY?.`B,E_b5DFfgggC^Z*JDM&RPAVWq=F%5qcB/ZFIDd8
F)Fo51p5s0>W6v^JEF*Q5DF;,:eD4ovlB63=JD8C/`F=APQB'5paE!%gq@(bNBD9XME+4CDE
+)x*JD,lrg9rK|;@9QelB#@C:@)&oC+?RbWFDEPT/#VBq@jaGSA&ovlBC.j|DpicRAtm|;@2
+ME+4CDE+-uk%G!6L?wjbUu5-P::+LdV<+8x?3@o4jY?.`B,E_b5DFfgggC^Z*JDM&RPA/!J
9>'`>_F,ZbDFqC;:+LdV<+6HU6wLdV<+LdV<+y_>_F,ZbDFNBV6wLdV<+LdV<+9`xlBw_KZ?
4/;EFMIBkBmX|;@RE4s4LdV<+LdV<+%lR)EdabnA5KAkB5IC9G2k>D+-uk%G'f#j@*kbD+nj
kSAL`Z^D#?#j@#-XJDuC#D+/lYKAn7>D+u3uSA@SRB;,EvmB6OAn/6dV<+LdV<+LH&yGu|D9
A<eV<+LdV<+LdV<+LdV<+LdV<+LdV<+*2m|;n^(kBC/;s+:QDs@vqoRA9+:eD4ovlB63=JD8
C/`F.HegC5APQB.DblBo3hgC:oreD)_NBD9XME+8IG<FsG>0AuE)5B8v&yGu|D9A+S5D+.5#
D+2u(*F,`xlB6btD+1yqcB.R?<@!jJ(F7O,D+#VBq@jaGSA';wbE.E0bE!*7hCO_.>+a.?0A
nly^FNVq=+)^xlBH!D9G.kbD+1-=JDEC/`F=APQB.DblBo3hgC4>fCF<APQB#ZB3@(H>0A.d
hTA6n%vH7yG)Fs^>r@*+ME+5(,!Fn^(kBeI|7A!*7hCO_.>+i;nlBv4hgCDvV<+LdV<+xpa:
Gq<?r@>5cDFoHLs#s^hm#%lR)EdabnACy-fD7O,D+009KD+S5D+0ot)FmuJ(FE?)E+w_/wE5
fbDFtqpcB>+dfD:aS8/19?SAAOA`Fr0HSA(5:JD.XIID(+ME+)tLE+9ti|DFG;`F:2GlBuOW
n6nly^F6MqcB|-Y>+6dV<+LdV<+Sh&E+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+&cUE:
FG;`F0KAkB,MNBDuC#D+#Vfq@'osdDw+ljB:em`C=xVE+%B#j@0'nlBrIbD+2u(*FnXIOAu/
siC4WrSAVWq=F84<:+LdV<+Y/cK/bY/C+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+,DN?<mF5S
A&97hC1#V<+LdV<+?sg:>,sX<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+ej.8@,?m;@mx;:+L
dV<+6HU6wLdV<+LdV<+a,v
0
0
0 0
x
27
qQ%hCrA90DxRZlBnvO:@y:(5BV?F2:n6<-
x
4
%N|(F
p
124 0 975 70 10 3 592 3 8 124 140 -1 -1
975
,|&v!;A,>!7nMH&)B`W!9EW<!;2Bs!:eCVv8tVH&5oA=!*QxN6ze!!!!WLp=!3AU3w/#Gpv9
`MNm,NW<!2|/=!6`8s!?=!5w8tVH&>>YUvv9o7-EOJI&_xh3wNb5t!4K`W!(#1=!m1>q+/cS
s!f!!!!9qH4wAS:qvH%Zt!IdR!v%9Vh%>Mo=!?1fg&B:3-&>u/X!-BW<!Mgm<v5JL3w`dhI/
ojA(!w6N<!Ke>>!L4`H&9B`W!*V!S7PkL3wndhI/k@mf%Q?,+'=>Ks!-BW<!Mgm<vVlGmwF^
JE'-BW<!+<W<!X7hqvK=)u!Hp+'(V0GB(1`8X!Gd`5w>Z/s!@gFF'DVTs!K&X<!QLxrvEwba
'9)yN6v*<<!e!!!!IAv!!qdeZ)<@=)!%K58-9/p<v,NW<!e-96wS4`H&`Hw%)P8ME0H!!!!?
q(K&,i-(!g>mi6#3WW!^8D(!'Hi<!f3B6w^=V?!i!FsvYw/!vIdR!v3b(>*LLD?!P7&.0`ty
t*c9<?!TOm4wc#g`:7AL3wc#g`:d:>;+bErZ!WTK6w9vNV,+)Jp+mnK=!C1@4wEOGI'T2ro+
kb86,lkSQ,3f8X!Nivpv77L6,P)D`KimL!+JP#pv7vx>!`|,7we6XXv/Z/s!L`&s!5Ta<!MU
%!sDR%@!>k64wh2!Q/e.mf%Qv:X!+HW!!NivpvGd`5w<Z/s!>yQK%uAv!!ClyUv.|o7-Q'fI
&V_s<!Kb5t!DCmjw<>Ts!WJX<!g<FsvY<S!ve%TU+-BW<!twy@!gh1qvmt?(!*Z/=!D;T=!H
4`H&KB`W!*V!S7bLM3w+ehI/i:mf%cKnjw0|8X!+HW!!NivpvR6vA!.pftv`dhI/)fji-!tL
K.ZIp9vNivpvR6vA!/!ptv`dhI/)fji-!tLK.xLp9vNivpvR6vA!0'wuv`dhI/)fji-!tLK.
yOp9vNivpvB+;?!1xXA!5gjA!9s'B!`)fs!p6``036BB19`YZ23s**03TW<!.*:B!+I=A!<'
wuv7GpiwdQOH&`4Un,6+SC!e;p*:T7ME0NK`W!VyQK%U.L=!Kc=L8'|kn-xGl!,)6LB!N>S9
w5l)xv.NW<!;Vmmw_%PR,Z(Us!NivpvmIe9w7,W!#YI.'1U%)pvGd`5wPZ/s!iIkm,Omm<v,
NW<!6Z-C!)i1qv#Y^|:v9o7-<2o=!8s%p+@2o=!&<T=!s#5pv.o=6#pY*07**!!
124
//PUv5&,UvP_PUv825Uv6iSTvG@7Ow5cSTvIRm0%5NE!!>r`!!GY,#!=ALNw=Sfv!GR!9#4A
tQ#;hg3wLm`PwG4mK%8P:R#?JYpv1c/v!<#0v!A.@8#AY-0%LL/h%PNY+'NyLNwBRWPwD^/2
%C#0v!HR!1%
140
:),UvQ#&U+>2,UvK+N-&^KO5wQv-t!MLO5wT1?t!:AkpvHk^R#(w*!!)>gqv5u/sr.C?fxww
*!!?.:w*j&do.?_Cm#0`S9vk|?<*JXFB(52P6#v-<<!U?|9vCPkpvbJx)(X99QwRU%4wkru!
*Y|(,'BjW!<nZi<!^nCR#b>;4%EngR#
70
x
5
0a%lB@v
x
4
gU54B
i
0
x
6
?r5DFByw
x
2
&Tv
x
660
Fngm#gU54B%#um#Z-WsE/Fur@>6Y.B*8|C+jZnT,'_5D+crgm#i^;I/OeXQH%-ur@qiv_F_e
O^E!%gq@VhAiBo3hgCgt(*FhBIIDjF5SAdFdZE8JlcE7%O@wEngm#:yiD+=;?CF_.'7Abm?Z
60'nlBPl#f;l^|;@`3eCFm@T;@sa54BW|L?+82_`FJE<3IFngm#o)y1A.dhTAs-%lBOExQH9
MfCF5Q?<@/upcB?PMEFgU54B')um#Engm#:QDs@vqoRAPf,!F+)ZKA#PK;@jj%#4>N<:+LdV
<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+Y/cK/009KD-lTKDOwf*F9R,!F&@VTA
6_PcEgU54B',24wEngm#<h&E+Pf,!F9R,!F&@VTAELMEF70roA!,5D+ergm#KPi-Anly^FHE
xQH6_PcEEo:s+qQ%hCrA90DxRZlBnvO:@y:(5BV?F2:9XME+ekTfDc_`WF.?0fD8utfA!,5D
++E%6B@wO@wEngm#ergm#f1;4w6dV<+LdV<+LdV<+LdV<+um74wS1PaB?PMEFgU54B<H<:+L
dV<+9MfCF!*7hCgF|;@8ZpT,fB4>wLdV<+:tJTAHR8EF'Y#D+gU54B6dV<+JS)!F/MqcB?PM
EF&M5D+97N@w/LMEF70roA!,5D+<#V<+LdV<+91VE+EaVE++E%6B6dV<+JS)!F9R,!F&@VTA
uNK;@(#V<+LdV<+91VE+60roAF+(d0g1;4w'p_oA!,5D+*3JTA8A-bE/TbDF94^aEk2JTAHR
8EF'Y#D+gU54B#MfCF6_PcE&M5D+97N@w
x
0

x
6
sN;oAGYw
x
6
mB.hCMYw
x
3
|ho+
x
8
2u(*FxmhEF
i
3
x
4
*dmID
x
1
Cv
i
1
x
4
DP)*F
x
48
ekTfDcWC?+mliJDG!D9G,XVTA8ebDF?.!-EdabnAt%oC+@5--E<2ufA'A#D+
x
1
>v
x
29
ekTfDcWC?+XUBq@jaGSA(5:JDFaVE+m'cSAA!
x
92
%*)TA=y-fD>v&yGK/)p/c0bSA&V#D+#VBq@5R.F+.)QcE)+VE+45;`F0KAkBmX|;@47bWF)F
V5BEawbE.E0bEtGo(F@kQ,E26sJDufY8A680bESP.>+
x
63
Z(tJ:seq`:rW&(F5.!-EdabnA5KAkBmX|;@+;m`C1EnlB&N>0A.dhTA'jcRA3bNBDs2K(F-`
WXGuGQw
x
4
i%97A
x
16
aBHr@,?elB(`tfA'A#D+
x
4
!bSh/
x
5
)lP)F1v
x
1
+!
x
31
jA0bE/FV5B4>fCF8G6bE-`>0Ae@XU@&V#D+Vlo%
x
2
nJv
x
3
bdD-
x
10
6>;EFj=fRAOhw
x
4
6>;EF
x
13
:#sJDvmSCF4o5DFEv
x
10
9&TbErimlBTnw
x
6
@5--E`+%
x
9
ZAX/::q)_3A!
x
30
)`&(F?-)E+@5--EF70wER:,*4`N)JD0-=JDS-v
x
1
O!
x
30
ZAX/::q)_3t!(E+6>;EFdUfRA5fAoA!*7hCX-v
x
20
7k1`F(rpcB7APQBpolRA)x*JD
x
108
ekTfDHk,s=3:)E+6>;EFdUfRAB/sSA:/ufA.OZ8A9mtD+.5#D+ridlB(utfAC^bWFDEPT/#V
Bq@jaGSAnicRAFito/c0bSA&V#D+`=Bq@4APQB(;wbE.E0bE5Go(F0KAkBA5.>+
x
4
rmBq@
x
2
Vkw
x
3
'7p+
x
48
ekTfDcWC?+MliJDG!D9G,XVTA8ebDF?.!-EdabnAt%oC+@5--E<2ufA'A#D+
x
4
m'cSA
x
5
1lo(F@v
x
7
>myn/idD-
x
7
59,o/idD-
x
7
4?5o/idD-
x
3
idD-
x
1
K!
x
5
<&seD.v
x
5
WOZ-E1v
x
6
)x*JDDhw
x
2
hpw
x
5
n0Hr@7v
x
3
ZXD-
x
1
_!
x
4
wm<eD
x
6
1lo(F^(%
x
4
Fwau-
x
1
J!
x
4
+u(*F
x
4
u3uSA
x
2
QMw
x
2
egw
x
36
B;gQ60'nlBrIbD+gt(*F7k1`F(rpcB7APQBpolRA)x*JD
x
46
^|xlB72ufA+No(Fs%oC+&Y0q@)wioA>;.#H4,ayFEPMEF(KxhC.bl(Fa,v
x
2
b/v
x
2
Tnw
10
L 1 51 10 64 44 -1
C 1 125 10 -1 -1 140
C 1 183 10 -1 -1 198
L 1 310 211 527 300 -1
L 2 366 116 488 359 -1
C 3 371 16 -1 -1 392
L 3 411 21 445 433 -1
L 3 433 3 445 -1 -1
C 1 631 10 -1 -1 646
L 1 827 65 906 893 -1
3
F
1 7 8
1
9
F
1 22 23
1
24
F
1 26 27
1
28
1 39
4
%N|(F
0 0 257
4
(iY%G
1 0 9
5
49BCF1v
2 0 9
8
45;`F%1D5B
3 0 9
6
'p@hC?Yw
4 0 9
6
60roAJYw
5 0 9
6
'p_oAJYw
6 0 9
0

7 0 521
0

8 0 521
3
y=w,
9 0 9
5
-lTKD@v
10 0 9
3
g*E-
11 0 9
7
60roAytf+
12 0 9
3
%@E-
13 0 8
6
wUcr@Y+%
14 0 9
4
8`PcE
15 0 9
8
sj|Z?m'cSA
16 0 9
4
3`PcE
17 0 9
9
mZ!iCgKxhC1v
18 0 9
9
mZ!iCh<..D1v
19 0 8
9
mZ!iCtGo(F@v
20 0 9
5
mZ!iC?v
21 0 9
0

22 0 521
0

23 0 521
4
mZ!iC
24 0 9
9
6>;EFtGo(F@v
25 0 9
0

26 0 521
0

27 0 521
4
6>;EF
28 0 9
3
k*3-
29 0 9
8
sj|Z?4/;EF
30 0 9
1
5v
31 0 9
3
sdu,
32 0 10
9
Euwm0gKxhC1v
33 0 9
4
2u(*F
34 0 9
4
G;hl0
35 0 9
8
p@sY?2u(*F
36 0 9
4
BK:l0
37 0 9
4
u3uSA
38 0 8
x
15
rpwhC;Z2b3<?<+EfqT+
0
0
}
