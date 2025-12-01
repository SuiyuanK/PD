############################################################################################################
#USAGE:
#atcl_create_ploc -layer <layer_name> -pitch <pitch_value> -net <net_name> -region <region bbox> -file <required output file name> -place_ploc <specify 1 for placing plocs automatically> \[-h\] \[-m\]"
# Copyright 2008 Apache Design Solutions, Inc.
# All rights reserved.
#
# Revision history
# Modification:Enabled to handle large number of wires in design.
# Rev 1.2 
# - Created by Gireesh 01/07/09
# - Initial version
# - Modified by Ashish
#
#####################################################################################################################################################
# TclPro::Compiler::Include

if {[catch {package require tbcload 1.6} err] == 1} {
    return -code error "[info script]: The TclPro ByteCode Loader is not available or does not support the correct version -- $err"
}
tbcload::bceval {
TclPro ByteCode 2 0 1.7 8.4
3 0 33 10 0 0 36 0 4 3 3 -1 -1
33
-KE<!(H&s!/HW<!0E`<!/#Gpv2,tl#0#>6#4,o9vz
3
7/0v
3
A)'v
10
x
4
,CHr@
x
27
qQ%hCd-ur@S.CTAW`=h:jvnX?w*K,EOef+
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
1174
&LC0:|G/Q8ivV<+LdV<+hTY'E^R>SAJRS@+%.>A+6!yhCC'/F+4CDE+hIa:@*FV5B8AseD2+
j|D7APQB5.!-EdjCkB#A3'DsEhgC3Mt!H%TB3@1neZEqiWeD0;?CF5|2TAdaGSA*2GlB,8>D
+6dV<+LdV<+U'0=<BXT776dV<+LdV<+%-ur@mHraEl?VTAvBseDo>+dD4<XeDm<`aE&RlSA*
+t#?u!V<+LdV<+!T.)E26sJDN/::+LdV<+Y/cK/#^.UAyhicC)N0bEh<..DZjW<+LdV<+LdV
<+LdV<+*>a&F*+G<F?.!-EdabnABAPQBt&I;@=%DE+;dC9GiabOB8AseD+;GQB,CH8A)v#D+
m1sp@jkW6wLdV<+LdV<+Gy5DFI<S<4(Fur@k!Q<@QkS%5LdV<+LdV<+LdV<+,DN?<)&oC+CC
,!Fn^(kB@jG<FsG>0A)R?<@#&#D+*D@BG%btD+&1Hr@l.JOAu/siC8cN<@3y#D+*RGYF.#V<
+LdV<+RtlCDW`S<4sj|Z?njkSAjdV<+LdV<+LdV<+LdV<+LdV<+oiLTA4+dfD5|2TA#cLvH.
0?SA4>fCF;G0bE.MCiC2t+!F0ZsiCmcZRA*mK;@'OAn/=(j:@BFVE+&kbD+2u(*F9)yhCucZ
RA:uMTA%#V<+LdV<+VC/yEqiWeD^Ib|EqiWeDtH^U@gwk?+LdV<+LdV<+LdV<+oiLTA4+dfD
5|2TA#cLvH.0?SA+*Z4B3+uD++@DTA8AseD+;GQB,CH8A)v#D+m1sp@jX;:+LdV<+Y/cK/m'
cSAUmBTA9ZTbE%Si|DFG;`F0KAkBmX|;@R@j?+fp78@.Vi|D/APQB!KAkB2.G<F#dZRA'9DT
Akj|7AtT=kA>%lDF-ZmID26sJDoD>0Anly^F32ufAuWmID(7Rt-0CAn/-^r;.9)yhCucZRA:
uMTA%#V<+LdV<+T1N%Eb.fRAvBseD:eV<+LdV<+LdV<+LdV<+LdV<+LdV<+_aJ;@%_/wE)-9
(F7vMEF)wBCFfgggC;yqcB+uJTAD+dfD|BW<+6dV<+LdV<+D7BoA*NfCFLdV<+LdV<+LdV<+
LdV<+LdV<+LdV<+LdV<+^g|7AE?)E+#dhTA1UtD+&wT(F,2ufA>10wEfR(kB2e/wEj!e=w@&
0*FdjtSAoF|;@x0km#5dV<+C.XU@37bWFrs6IDsK7IDuC#D+4<nlB3;qcB#d?q@!U67Av?m;
@%69:+LdV<+2%G9>4Y/C+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+w3F/Du@oC+(k54B&
#V<+LdV<+?>'R/,sX<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+Dr0'D,%0wEYj!>wbyMg9#tS
@+R'Um7qdV<+6vV<+LdV<+LdV<+LdV<+LdV<+qQ%hCf9DTAf=+Y?&1Hr@<MI;@=%DE+?4Nc2
B(sSAPFkr6#2N%Eu-cOB*@YJ0K?!
0
0
0 0
x
24
qQ%hCd-ur@S.CTAW`=h:jvnX?!*9,E
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
237
qQ%hCf9DTAf=+Y?&1Hr@<MI;@=%DE+OMt!HqE7ID>SS%5HXGlB,8>D+Vy5DFmoewGtf_TApt
lCDW`S<4sj|Z?njkSAtC/yEqiWeD^Ib|EqiWeDtH^U@gwk?+5sGnA91VE+SeAoA*NfCF0Kk_
Fg5dK/w;+Y?sj|Z?njkSAcZZnHx,>hA'A#D+Q/jFE-LDTA5C/`FEPMEF(KxhC!3x;@R@j?+7
mK;@d0m*E+>fC+Q|2TA#cLvHNfrfA>10wEfR(kB2e/wE)-9(F7vMEF)wBCFfgggCe'k?+ofb
v?7sS(D)v
0
0
0 0
x
16
qQ%hCf9DTAf=+Y?&1Hr@
x
4
%N|(F
p
238 0 2012 125 14 4 1088 2 11 238 262 -1 -1
2012
,|&v!;A,>!7nMH&)B`W!BAL3w:2Bs!d!!!!eC#!!V8hj%*TA9v3ZyTvPr.p+kM/s!@.%8#-W
&=!9;kpv@=OO%8SUNw-BW<!N@T6?<k60%@.mf%=M5Uv>TW<!4#0=!L4`H&@bpm#-ZxN6v*<<
!e!!!!|0A4wTE:G'F/efn(BW<!2|/=!MGf=!C#5pvFsGI'BXe`'Pm+'(1`8X!'03!!JE`W!-
W&=!G:@rvAFjj%Esa|(-BW<!'8Gq++K/s!2/YQ#EYTs!?Mp=!MRdrv-fvpvhBn<v(BW<!2|/
=!.mbT4fh:3wGY9X!H*>J&J?ZW*iEn<v(BW<!M1lt!2/YQ#JhTs!Rk#I!Rp<sv3GpiwQ#WT+
N<k+'HOq?!sW#7wG>,>!UrSs!ht86,M543-QRNH&VOl6#/)13wOk^qvMC2u!GG#pvGPDu!S^
ic&HVMu!i%ki-IyVu!j.10.Jb_u!WkKK.TxNH&U^NH&VaNH&R+)R#>*S08W`Pe&/)13wf|Kt
vMC2u!GG#pvGPDu!S^ic&HVMu!i%ki-IyVu!j.10.Jb_u!WkKK.TxNH&U^NH&VaNH&R+)R#-
BW<!2|/=!>mbT4aY:3wW4:X!d(=M&cSa<!.o=6#Z=)*08GV9-biA=!yZ/s!UA`v*iF#!!U=_
`036BB1.EW<!?%:-8F5uH/0y_`036BB1Ppm<vJmm<v(BW<!hU%@!qY,>!O9jsvMcqo+&pvw2
Bu`W!UFQpvHOq?!JE`<!hvZ>!FXmrv8Gpiwuc=?2iTnf%fwRpvS>X<!K+;?!;w1B!pyuuvYw
/!v#M|t*g@#!!gk6(!I/=3-Xdh?!lES!v9jhW!|8VK&5i-(!hD!j6w<rr!,#km,n'75-:E.V
!a<TW3EM794i!q9v6r&=!H!>UGhlko4'`LI&>AKs!T9asvNwn<vy_nQ,;W&=!UVv:wLt^VvU
Y'j-?I<3w)Qhl50|8X!iF#!!3MpiwF,??2H+KN6)cdi6-u*07#si3wM&Jp+H9nX5`V:3wq-;
X!'03!!JE`W!ZP:3wr0;X!'03!!dUA(!(Nr<!qe?C!;w1B!(Hf=!^VAv#3fvpv*V!S7AGg=!
wyJv#)B`W!HSa<!-fvpv|yX<!c`4vvbal1.o:*D!!x/s!cj2M.o:*D!vx/s!dsMh.`5LB!EB
^B!BeIWv0fAs!gi@E9MM0X!wLVs!bkX<!W*Utvt=Y`9>7|x)wVU|:h'/J/iF#!!ZL_`036BB
1.EW<!?%:-8F5uH/^P:3wU6r#;Ppm<v(BW<!a)dC!85`H&QtQZ;YTnu;.EW<!-1@<wXHN<!/
a8s!*VMT=cCUs!w|S36JE`W!HOq?!THd<wc>,>!UrSs!ht86,F%JF'xeON-1NW<!hU%@!I#Z
>!A6hw#Mcqo+j+TQ,mQOH&S@QpvHOq?!JE`<!fkG>!B<qw#,0*!!oWOH&lKFb0`oOA!jG*D1
`oOA!5PE_1`oOA!mY`%2`oOA!6b&A2`oOA!!kAy2-W&=!sOn9wrt^Vvm2_Q53:su2=#QsvO.
yv3m.i8w'KLR-U+v>3sgsM&Gj5=3s*N3wWi749&Eo7-HbkR&(`s<!>g9u++K/s!k:yf@j#.w
vlCv-Ak)7wvl7AK@K5uH/I*<<!vSJ9wS^I>!rN)N&,7CC(DA<HAM!0.&EUAI&PsPX3QE)N&)
_ed&2io7-=YS9w=ibsvNwn<vy_nQ,wYS9wdPC7-9/p<vJmm<vJuI6,o8tAUWvSX3@mF5wq>,
>!M;!5wCJCm#_@B36JE`W!H*>J&>^ei.2,#t!2io7-|e64wj;'>wtA0>wvH9>w(NB>w#'n_v
6`8s!cgDI/ANWs!sF;3wjIXcAtms)Bv(:EB(@U`B*XQ|C8&Ts!9e64wk5=&#Mcu!*&Eo7-Ki
qG!_r#?wU5<!#MSa<!m8MU4DA<HALmig%EUAI&S9MU4hFhq,)ss2?GO_w!q#eLw-U<u4Ae+%
3R5IwvU^NH&Lt2.&0`Js!%/@wvPDuw2TAxwvPUic&J`^6wYsF,0RovpvZ+ic&xm%4wy3tG0a
yS36JE`W!JE`W!G5v!!N27:4fF.8-(|^B!D9)G!Pq1Vv'lq:47/p<v(BW<!nZ+vvmn's!A(i
c&>RN?!cW+A!(:(B!!F:B!'dgB!'^^B!QHkpvc9<?!cW+A!(:(B!!F:B!'dgB!'^^B!RHkpv
Mcu!*&Eo7-KiqG!_r#?wU5<!#MSa<!l/2:4DA<HALmig%EUAI&Q02:4iIhq,;k|uDJuI6,v9
&9v1>L3w'5uH/`V:3wH|<X!'03!!JE`W!iF#!!^X_`0t,+9F.EW<!?%:-8F5uH/^P:3ww'FT
FPpm<v(BW<!X0^tvLcu!*2io7-iiA=!_l(Vv.Z/s!<>BE9MM0X!-BW<!YRu?wFbCVv/Z/s!Q
6ylG|(1X!-BW<!x^2@wXr+pvT:g=!yd;@wi=gav/Z/s!f!!!!`TOA!wl9'#.fvpv*V!S7&Eo
7-`TOA!wl9'#KSa<!kt?(!/#|=!1xXA!La8s!MpR!va1%pv,;U=!1xXA!kw/p+(03!!
238
//PUvL7;Vv8D>Uv;yLNwO4EH&AGLNw<JLNw<JLNw;>PUv3l`!!L_fv!4Qi!!1Qi!!F2O!!4Q
i!!1Qi!!KtLNw<JLNw2|STvd6Bh%C2fv!`6|I&?l`!!VA0v!VRVm#2|STvQ>GUv72>Uv<5Tv
!Fhcf%Gs82%5>kl#9PLNwT0Bh%LbLNw1,PQ#1,PQ#:(EH&82>Uv5513w8/PQ#6Y-0%>.*-&H
<C^(7Z`!!@ue9vhMxx)BGfv!OoAv!@;(7#OGb6#<M5Uvc(T|)^Mel,7fi!!N@V7#KO<1%E>B
v!GVBv!:|!
262
:),Uvp!N9FB%*g%|#*=*gZX1%N7)7#O7)7#TF)7#/Nirr>)Hr`Ck^R#T4_R#;8GUv;8GUvOe
^R#;8GUv;8GUva7)7#uT*7#gQyS#XB#J&_09M%gm!sv,w*!!QfnW%:T9u+H2P6#.yrf&5u+U
v9>b6#PjEkwiCC4-Pv@Ow)w*!!?1*1%A80=!|0Bh%MeCR#;J(R#;J(R#TCc:v^O-UvCJf9v:
J(R#&w*!!/Sc0%P=qR#mTE?!!w!!!`Pj1%&qp|:gwFT#aj`1%Uji1%t-V@*vw*!!A;70&8fe
9vV;F`(_cC((enEI'1%V':OImOwq4FI'jv=I'19!
125
x
5
0a%lB@v
x
6
gU54BI(%
x
0

x
6
?r5DFByw
x
2
&Tv
x
2442
6dV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+uNK;@&nLE+<#V<+LdV<+LdV<+LdV<+Ld
V<+LdV<+LdV<+LdV<+LdV<+LdV<+Ll4BGu-cOBB=GhC@MeK/Isc3@AsZQH6dV<+LdV<+LdV<
+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+VCLV.>nB3@o4jY?qQ%hCHIa:@b
yvfCf7>OB..2E+TnATAAl9KD>N<:+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV
<+LdV<+LdV<+Y/cK/TeXQH%-ur@mNACFQYO^El?VTAx0Hr@hBIIDjF5SAdFdZE8JlcE7%O@w
LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+@Mt!H??xQH9M
fCF5Q?<@2;m`C)N0bE<T<3I6dV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<
+LdV<+LdV<+HXGlB,8>D+@uJTAHR8EF'Y#D+(Fur@'nLE+>#V<+LdV<+LdV<+LdV<+LdV<+L
dV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+RtlCDAExQH9MfCF5Q?<@4MNBD#wj'F>N<:+LdV
<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+Y/cK/t!MkBE3xQH9MfCF
5Q?<@8qeZEqiWeD-nLE+>#V<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+Ld
V<+LdV<+J,>hA'A#D+@uJTAHR8EF'Y#D+m'cSA<T<3I6dV<+LdV<+LdV<+LdV<+LdV<+LdV<
+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+KsCiCU_*Y?&1Hr@Pf,!F9R,!F&@VTA*mK;@d0m*Ej
vnX?<%O@wLdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+5sG
nA91VE+@uJTAHR8EF'Y#D+&wT(F#wj'F')um#Engm#@&0*FdjtSAoF|;@:mZQH9MfCF5Q?<@
;7bWFrs6IDsK7ID_(+Y?<%O@wLdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+Ld
V<+>#V<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+>wO@wEngm#w;+Y?sj|Z?njkSA:BxQ
HFngm#a.JTAIU/*FdjtSAoF|;@8ZpT,fB4>wEngm#vMfCFuNK;@&i1*FdjtSAO)/XFrs6IDs
K7ID_'v>wEngm#/OMEFrsrN7!,5D+^KAgA`e<Y?w;+Y?pOa|>LGK9wEngm#>#V<+LdV<+LdV
<+LdV<+LdV<+LdV<+LdV<+LdV<+/&I;@'_KZ?:n<@wLdV<+LdV<+LdV<+LdV<+LdV<+LdV<+
LdV<+LdV<+LdV<+LdV<+91VE+#^.UA9tc3@%b;:+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+Ld
V<+LdV<+LdV<+JS)!F9R,!F&@VTAuNK;@eQK?wLdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<
+LdV<+>#V<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+;1GlBkqEY?:n<@wLdV<+LdV<+L
dV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+91VE+(Fur@/tc3@%b;:+LdV<+LdV<+LdV
<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+JS)!F9R,!F&@VTAuNK;@eQK?wLdV<+LdV<+LdV<+
LdV<+LdV<+LdV<+LdV<+LdV<+>#V<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+5VrSA3n
LE+<#V<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+:tJTA4WrSA;tc3@%b;:
+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+JS)!F9R,!F&@VTAuNK;@eQK?wL
dV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+>#V<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV
<+LdV<+1JAkBpKi'F<H<:+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+JS)!F
,2ufA'A#D++E%6B6dV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+9MfCF5Q
?<@,ZtfA`e<Y?4#V<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+>wO@wLdV<+LdV<+LdV<
+LdV<+LdV<+LdV<+LdV<+LdV<+t!MkB'gi'F<H<:+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+L
dV<+LdV<+LdV<+:tJTA8oATA%6sJD94^aE(#V<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV
<+LdV<+LdV<+9MfCF5Q?<@,ZtfA`e<Y?4#V<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+
LdV<+LdV<+>N<:+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+G8-wEb.fRAvBseDvnLE+<#
V<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+9MfCF*mK;@d0m*E+>fC++E%6
B6dV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+91VE+49BCFwf=hCgQi'F6
dV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+>#V<+LdV<+LdV<+LdV<+LdV
<+LdV<+LdV<+LdV<+7eAoA*NfCF:BxQH6dV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+
LdV<+LdV<+91VE+&wT(F?2qT,fB4>wLdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+Ld
V<+JS)!F9R,!F&@VTAuNK;@eQK?wLdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+>#V<
+LdV<+LdV<+LdV<+LdV<+LdV<+a,v
i
0
x
4
wm<eD
x
6
1lo(F^(%
x
5
#^.UA>v
x
4
DP)*F
x
31
Z(tJ:seq`:rW&(FwQiSA2<XeD7APQBt&I;@rX2-
x
3
bdD-
x
6
ridlBLnw
x
7
@Mt!Hl0<-
x
5
WOZ-E1v
x
5
t'?<@8v
x
1
A!
i
1
x
9
u?q-DsEhgCI!
x
1
J!
x
21
Z(tJ:k>`bD3Mt!H2tNBDdU|7AA!
x
15
9mtD+.5#D+ridlBl/Hw
x
5
(Fur@4v
x
61
N)yI:5p#iB,8>D+0Kk_F/y-fD1QJkB6btD+_@=nA.)QDF0KhgCM%(d0fN70D9)yhCucZRA:u
MTA0v
i
120
x
6
&wT(FP+%
x
58
N)yI:1OskA*NfCF0KhgC5MNBD7;;-B*!nIDn-JOAu/siC8cN<@3y#D+Rx1mB'K|N@:U/*F@P
w
x
3
idD-
x
70
N)yI:/@OPABvOBDCR,!Fn^(kBeI|7A&6reD:sC9G.kbD+j,B3@^:|7A9mtD+&kbD+2u(*F9m
tD+.5#D+ridlBLnw
x
3
xIQ,
x
6
t!MkBTnw
x
56
N)yI:3XsPA%6sJD>%lDF5|2TAh'DkB9y+g/|5nlB(H>0A2IC9G.kbD+l>#j@10elBl6)9A
x
5
-0mdDDv
x
6
)'|(FNJw
x
4
3N!iC
x
2
G+%
x
5
u3uSAR!
x
12
0Nm#Ff.fRAAFZp.
x
5
u3uSAS!
i
2
i
3
x
29
N)yI:3QtPA%6sJDA,5T/&72kB2HK(F%3DTAA!
x
3
F<0%
x
4
m'cSA
x
61
N)yI:+4sgB,MNBDuC#D+>OVE+#VBq@jaGSAmTTn6nly^F32ufA'A#D+njkSA9)yhCucZRA:u
MTA0v
x
7
0CAn/Y@l,
x
10
m1sp@m`EiCIMw
x
64
N)yI:86ueC2%ME+0g!iC>%lDF)v#D+m1sp@h0-G:@d.F+@5--E<2ufA'A#D+0g!iC)v#D+hI
a:@*&oC+
x
6
sN;oAGYw
x
7
'm8bEbF-,
x
2
Tqw
x
2
N@%
x
2
PF%
x
1
K!
x
5
<&seD.v
x
5
3'rTA>v
x
6
5;2`FIPw
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
9
co/`FxQY|G@v
x
5
1lo(F@v
x
13
sj|Z?:p2TA0J)dEI!
x
13
sj|Z?:p2TAewZ8AI!
x
18
7k1`F(rpcBuKU:@eYE:@OSw
x
4
/LDTA
x
6
@Mt!HN%%
x
4
A>fCF
x
2
hpw
x
7
S5)p/-IE-
x
24
ekTfD>SkQB'A#D+,)DEF+S5D+/LDTA
x
56
41VE+>OVE+0lTKD(5:JD&|ACFdN&(FC|-wErW&(F%rjID8%DE+.)QcE)+VE+41VE+njkSA
x
6
q'-W@Dhw
x
9
Uy!Y?-lTKD@v
x
11
0F?<@j-!eDw+E-
x
7
WAHK;5G&&
x
4
*dmID
x
1
Cv
x
5
)lP)F1v
x
1
-v
x
18
-#sJD#D5D+'m8bE-h>D+Tqw
x
1
>v
x
4
+u(*F
x
5
/LDTA?v
x
2
FVw
x
3
y.p+
x
5
gIa:@7v
x
6
pR5SA_tw
x
7
Gr;mHv1B%
x
2
QHv
x
2
PEv
x
2
TQv
x
4
u3uSA
x
1
5v
i
7
i
4
x
8
c.Q)<;w2L9
x
10
T>&Q8m4-)<Yy#
i
5
i
6
x
1
L!
x
34
19Y<+8toB+h-ur@5P>UAuJB3@%y/wE4SeK/t'?<@X-v
x
7
yVt#HliGw
x
4
yI#F+
x
4
|O,F+
x
27
W&0*FdjtSAoF|;@<*<3IQ#nW4wp=>+:i,.
x
16
w!saEk*T7Asb1`FLW<3I
x
13
<P+p>1k_?+d@PF+Gv
x
6
#j<NCN%%
x
3
KV|+
x
9
LvQ)F-<XeD:v
x
34
19Y<+&(:p@m-cOBB=ZKAuJB3@%y/wE4SeK/t'?<@X-v
x
110
W&0*FdjtSAoF|;@<*<3IQ#nW4wp=>+Dn<@wLdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+Ld
V<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+@NncB0tCE+Uy!Y?-lTKDyrgm#Engm#RE%
x
149
<+-C+AM`H0Z_xQH6dV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+Ld
V<+LdV<+LdV<+LdV<+w!saEk*T7Asb1`F.GX6wLdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<
+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+Iv
x
36
Z(tJ:k>`bD?_TbE*uJTAtZmID=JqcB7APQB)oATA%6sJD
x
3
s^;-
x
19
-#sJD#D5D+'m8bE-h>D+s^;-
x
30
N)yI:/F><@'k|7A*mK;@nEV5B8AseD,JqcBZ-v
x
6
A;lcE?Sw
x
31
N)yI:wR;JD!.?SA-MCiChT<JD0MCiC2%ME+n/Hw
x
41
N)yI:E44w<(FhgC=_90D&%DE+2b/wE)-9(F'HmIDw3BCFEsqZ3A!
x
51
N)yI:?bAcD.JbD+*7pV@3(j|D/MCiC2%ME+&Y0q@)wioA>;.#H>LCiCZ7|7AF<Fw
x
27
N)yI:8/!fCk9MTAD=2`F'&#D+WAHK;5G&&
x
18
4P5cE*mK;@nEV5B8AseDM(%
14
L 1 36 10 49 29 -1
L 1 123 6 132 116 -1
C 1 518 8 -1 -1 531
L 1 653 6 662 646 -1
L 1 682 6 691 675 -1
C 1 770 22 -1 -1 797
C 1 835 18 -1 -1 858
C 1 974 8 -1 -1 987
L 1 1018 764 1788 1018 -1
L 2 1372 157 1540 1530 -1
L 2 1630 139 1780 1770 -1
C 1 1818 8 -1 -1 1831
C 1 1941 8 -1 -1 1954
C 1 1979 8 -1 -1 1992
4
F
1 4 5
1
6
F
1 10 11
1
12
F
1 31 32
1
33
F
1 35 36
1
37
1 64
4
%N|(F
0 0 257
4
(iY%G
1 0 9
5
49BCF1v
2 0 9
12
gU54Bw!NTAs>fCF
3 0 9
0

4 0 521
0

5 0 521
3
y=w,
6 0 9
12
gU54BeN!iCs>fCF
7 0 9
5
t'?<@8v
8 0 9
6
t'?<@V(%
9 0 9
0

10 0 521
0

11 0 521
1
9v
12 0 9
8
u?q-DsEhgC
13 0 10
5
#^.UA>v
14 0 8
5
(Fur@4v
15 0 9
6
&wT(FP+%
16 0 9
3
idD-
17 0 9
11
t!MkBoF|mAV_#,
18 0 9
6
t!MkBTnw
19 0 9
5
u3uSAR!
20 0 8
6
mERdDMPw
21 0 9
5
u3uSAS!
22 0 8
2
u`v
23 0 9
2
!av
24 0 9
2
!dv
25 0 9
2
vdv
26 0 9
4
m'cSA
27 0 9
10
m1sp@m`EiCIMw
28 0 9
8
3'rTA1?fCF
29 0 9
6
tWdIDP+%
30 0 9
0

31 0 521
0

32 0 521
5
3'rTA>v
33 0 9
12
sj|Z?:p2TA0J)dE
34 0 10
0

35 0 521
0

36 0 521
3
xt|+
37 0 9
12
sj|Z?:p2TAewZ8A
38 0 10
8
gU54Bj0Hr@
39 0 9
10
gU54BrMt!HN%%
40 0 9
8
gU54Bs>fCF
41 0 9
9
Uy!Y?-lTKD@v
42 0 9
11
0F?<@j-!eDw+E-
43 0 9
3
)G8&
44 0 9
2
Mtw
45 0 9
2
W=%
46 0 9
5
/LDTA?v
47 0 8
4
u3uSA
48 0 8
5
4U)9A?v
49 0 9
1
5v
50 0 8
3
ad2-
51 0 9
3
fe|+
52 0 9
3
a@c,
53 0 9
6
%Nt!HN%%
54 0 9
5
sjtSA@v
55 0 9
8
sj|Z?:p2TA
56 0 9
4
.0B,E
57 0 9
3
r<i-
58 0 9
3
sBr-
59 0 9
8
aS!Y?/1Hr@
60 0 9
8
aS!Y?.1Hr@
61 0 9
3
#Oi-
62 0 9
3
'Cr-
63 0 9
x
15
rpwhC;Z2b3<?<+EfqT+
0
0
}
