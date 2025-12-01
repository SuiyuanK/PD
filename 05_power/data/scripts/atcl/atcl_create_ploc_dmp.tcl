############################################################################################################
#USAGE:
#atcl_create_ploc_dmp -layer <layer_name> -pitch <pitch_value> -net <net_name> -type <P/G_name> -region <region bbox> -file <required output file name> -place_ploc <specify 1 for placing plocs automatically> \[-h\] \[-m\]"
# Copyright 2008 Apache Design Solutions, Inc.
# All rights reserved.
#
# Revision history
# Modification:Enabled to handle large number of wires in design.
# Rev 1.2 
# - Created by Gireesh 01/07/09
# - Initial version
# - Modified by Ashish
# - Modified by Ajosh K Jose for DMP
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
30
qQ%hCd-ur@S.CTAW`=h:O.:t6!7q-Dm*p;@CSw
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
1331
&LC0:|G/Q8ivV<+LdV<+hTY'E^R>SAJRS@+%.>A+6!yhCC'/F+4CDE+hIa:@*FV5B8AseD2+
j|D7APQB5.!-EdjCkB#A3'DsEhgC3Mt!H%TB3@1neZEqiWeD0;?CF5|2TAdaGSA*2GlB,8>D
+6dV<+LdV<+U'0=<BXT776dV<+LdV<+%-ur@mHraEl?VTAvBseD`!I.D'?+dD4<XeDm<`aE&
RlSA*+t#?u!V<+LdV<+!T.)E26sJDN/::+LdV<+Y/cK/#^.UAyhicC)N0bEh<..DZjW<+LdV
<+LdV<+LdV<+*>a&F*+G<F?.!-EdabnABAPQBt&I;@=%DE+;dC9GiabOB8AseD+;GQB,CH8A
)v#D+m1sp@jkW6wLdV<+LdV<+Gy5DFI<S<4(Fur@k!Q<@QkS%5LdV<+LdV<+LdV<+,DN?<)&
oC+CC,!Fn^(kB@jG<FsG>0A)R?<@#&#D+*D@BG%btD+&1Hr@l.JOAu/siC8cN<@3y#D+*RGY
F.#V<+LdV<+RtlCDW`S<4sj|Z?njkSAjdV<+LdV<+LdV<+LdV<+LdV<+oiLTA4+dfD5|2TA#
cLvH.0?SA4>fCF;G0bE.MCiC2t+!F0ZsiCmcZRA*mK;@'OAn/=(j:@BFVE+&kbD+2u(*F9)y
hCucZRA:uMTApb;I/:p2TARbO20BF|;@;pMs#5dV<+^g|7AE?)E+#VBq@5R.F+.5#D+|(e@+
njkSA?>m;@8XG<F9<K(F%3DTAXZkr6qDg|DvFfj7PQB=+4CDE+3'rTA.ZFID*M?bE.OZ8A6d
V<+LdV<+F@BTA%6sJDUmBTA%6sJDu/mdDmjW<+LdV<+LdV<+LdV<+^g|7AE?)E+#VBq@5R.F
+.5#D+t!MkBAdC9G)S#D+&1Hr@72OeD2;oC+w_/wEb.fRA%#V<+LdV<+J,>hA'A#D+Q/jFE-
LDTA5C/`FEPMEF(KxhCn<..DZjW<+^0-.D'fAoA.0?SA(KxhC5+dfD)v#D+hIa:@*&oC+t1+
D+>OVE+,ZbDF#FuSAoolRAu/siC0KAkBmX|;@7:#%E%M.MA=5V=+0g!iC)v#D+)h|7A6dV<+
LdV<+KsCiCU_*Y?&1Hr@LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+M1sp@.MCiC2%ME+1,gfD#d
mlBiN!iC5B`nA9MfCFE?)E+GHU6wLdV<+LdV<+5sGnA91VE+LdV<+LdV<+LdV<+LdV<+LdV<
+LdV<+,DN?<)&oC+7,;-B1_#D++qi|DqHMTA6,:eD;MCiChT<JD0MCiCy0tm#GuMTAs>fCFh
<..DLogm#q|E37jgpgC:U/*FdjtSAoF|;@.Vi|D4<XeD25:JDw?!eDk*T7AvF97A6vV<+LdV
<+?>'R/'sX<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+:mui@vkT;@44bWFmF5SA6dV<+LdV<+
7sS(D4eV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+0,R;@,?m;@W?:4wS5ae:(_O?<BXT77Ld
V<+6dV<+LdV<+LdV<+LdV<+8x?3@o4jY?hIa:@u0m*EjvnX?.12E+@Mt!HfIvd9HW2L9h1N%
Eu-cOB(4GJ0btlCDqKlZ<jtdK/:p2TAp5wr6KsCiCU_*Y?&1Hr@jbcK/m'cSAILu)FaF97A2
?!eDUh'v
0
0
0 0
x
27
qQ%hCd-ur@S.CTAW`=h:O.:t6q^>OBcau,
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
254
qQ%hCf9DTAf=+Y?&1Hr@<MI;@=%DE+OMt!HqE7ID>SS%5HXGlB,8>D+Vy5DFmoewGtf_TApt
lCDW`S<4sj|Z?njkSA!Ve=F;M#D+wyxk7h<..Dg5dK/t!MkBxNS<4t!MkB,Q|N@T!V'5D7Bo
A*NfCFb.h|DqHMTA/LhgCZ@j?+GuMTAs>fCFh<..DLK_H0qccK/m'cSAUmBTA9ZTbE%Si|DF
G;`F0KAkB,MNBD>SS%5KsCiCU_*Y?&1Hr@a,v-EdabnAa!G>+4CDE+m1sp@+S5D+&1Hr@6DZ
^F)qT;@nvO:@ys^'52F!JB'?'R/A;w
0
0
0 0
x
20
qQ%hCf9DTAf=+Y?&1Hr@m,B,E
x
4
%N|(F
p
278 0 2297 122 14 4 1244 2 14 278 310 -1 -1
2297
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
1.EW<!?%:-8F5uH/PK`W!JE`W!sRND!jCP##f/kvvhBe+0<7&I&Rk6?;g%Y<!AS:qviG:#vc
gDI/)xVs!9e64wXw.<w`r+pv25:3wYZ4<<c:1X!.EW<!x^4A!/a8s!*VMT=a7:X!0pVs!,R#
F!kT?uv:JZXv5Ta<!Icqo+N/cl>pZOH&S@QpvHOq?!X`3=wH>,>!WrSs!ht86,LC+((?i^i?
1NW<!hU%@!/-kA!^9jsvMcqo+J_B9vf/HF'@rw0@2QW<!b8(B!L4`H&CFsw2;puP&EFsw2Wn
sP&FFsw2<suP&GFsw2VksP&HFsw2@)sP&go=6#j#265&9LE'2iSs!;#1=!sG6!,rjKN&Nj5=
3c=.8-G1LN&Nao!3#:N3wUlp#vrUv-AK5uH/`&<HA<uPsvwRBy2JE`W!d2tA!'VUq4d2tA!)
_p75f>1B!.A%pvuAv!!4H275`JvL'bul)2*ON3wK>,>!P;!5wDJCm#+RN3w-vu)2,UN3ws'8
J/|YJR5AuKV,P&Jp+<_1;vBcIR5HPln-xGl!,Jc%p++K/s!E*<<!0v,:wtRbd')0PH&GPQH&
DD,Uv*Mmwv5Ta<!9(ic&wZR<*Z;L3wd'8J/Emgm5OE;N&h;S`BoiKE'COAI&HTIR5OE;N&i;
S`BplKE'COAI&_5:3wnmo&C)0PH&twh9v.EW<!cW+A!SZ,>!nLn@!+2IC!vQLB!lc=A!q8^Y
vX#/p+'#,:wt,g+0CMB>wjt^VvmKe+0#qv:wu5-G0CMB>wkt^VvnT+G09e64wnSK>w);!5wp
)>pv25:3wo!6BCT+P|ChBOH&+6PH&vpOH&lNOH&l<Ajw7AL3wq4uH/p1k#DV_OZDadKR5R!n
<v1>L3wu>,>!P;!5wCJCm#+RN3w3vw10E!<rr9o@6,=qfuDVhq!3G#ki-6tPn5G.l>!PG9>w
=ieTv);4S5vkn9w::Mk6A_5>!RcSX+8GEC(&fs<!NSa<!cNBU#:Y&%)OWYXv5Ta<!JSa<!IR
_w!=:!5w/e|00Q5JR5Gy8EBLmig%EUAI&sAl!,+K/s!ls6P-m/o@!2ZW<!9-_p>R2^a0F6tv
voC)+0>AKs!m5tvvQ/^a0G<(#vpLDF0>AKs!n;(#vcgDI/-?hm5()JR53lSs!9e64woYT>wT
_|>wh:!5w+;!5wv;!5wm:!5whY1qvXh+=w*Yb_2|je+0CMB>wjt^VvmKe+0#qv:wu5-G0CMB
>wkt^VvnT+G09e64wnSK>w);!5wp)>pv25:3wo!6BCT+P|ChBOH&+6PH&vpOH&lNOH&l<Ajw
7AL3wq4uH/p1k#DV_OZDadKR5R!n<v1>L3wt>,>!P;!5wCJCm#*ON3w4.610E!<rrlM/s!Ad
Z;r>K/s!Y(wpv.Gg=!MSj&#)B`W!HSa<!kt?(!-lJ=!1xXA!Ia8s!MpR!va1%pv&ls<!JSa<
!!P:B:`4:X!KF;?!oihs4JLHWE@&0X!-BW<!`?yH!BeIWv/`8s!MgDTFK@NH&1`8X!0iA=!'
q0Yv.Z/s!Ow&6Gy%1X!Yr(O%P-AQGkiylG1`8X!iF#!!_x_`0qf.<E.EW<!?%:-8F5uH/0y_
`0qf.<EPpm<vlS<07.A-0%1*''1G`Ws!M&Jp+^TfC!1Pmmw1*''1G`Ws!JE`W!z
278
//PUvL7;Vv8D>Uv;yLNwO4EH&AGLNw<JLNw<JLNw;>PUv3l`!!L_fv!4Qi!!1Qi!!F2O!!4Q
i!!1Qi!!KtLNw<JLNw2|STvd6Bh%C2fv!`6|I&?l`!!VA0v!VRVm#2|STvQ>GUv72>Uv<5Tv
!Fhcf%A(l#!;&,Uv@=*1%9iSX!=D(qv|0Bh%=c/v!1Qi!!1Qi!!@h^qv7,,Uv6>tpv2Qi!!6
oAv!>,|v!R!a5w=q)-&72Y6#5Pgiw5Pgiwy%QQ#58PQ#_+>V+Z)NT+>.*-&H<C^(7Z`!!@ue
9v0Qi!!5Qi!!`!Ww!7i8v!FXyI&ZGfv!yS:R#Hg*9#MxN1%E>Bv!GVBv!:|!
310
:),Uvp!N9FB%*g%|#*=*gZX1%N7)7#O7)7#TF)7#/Nirr>)Hr`Ck^R#T4_R#;8GUv;8GUvOe
^R#;8GUv;8GUva7)7#uT*7#gQyS#XB#J&_09M%gm!sv,w*!!QfnW%:T9u+H2P6#.yrf&5u+U
v9>b6#PjEkwcbJ:+Pn^R#9JCm#JUN1%w?rr!/n:qvJqlf%_B#J&AAGUv;8GUv;8GUvS2|9v_
&,UvBly9v;8GUv#6WW!w1R4wKPGUvh,Frr=p|Z)yS|=!*03<!;-Ue#CnLR#LjAI&Zn?jwCn?
jwsC'a(VgN1%P=qR#mTE?!v-<<!#Oj1%+K`rr5-S&^Ct-n#Ct-n#cR;7#CDGUvgnv;+aj`1%
aiM9+?77^:QOmOwq4FI'jv=I'19!
122
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
2667
6dV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+uNK;@&nLE+<#V<+LdV<+LdV<+LdV<+Ld
V<+LdV<+LdV<+LdV<+LdV<+LdV<+Ll4BGu-cOBB=GhC@MeK/Isc3@AsZQH6dV<+LdV<+LdV<
+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+VCLV.>nB3@o4jY?qQ%hCHIa:@b
yvfCPl%+DiF>SAYK8!48JfCFB4uD+>#V<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV
<+LdV<+LdV<+LdV<+QkQ(Dy4>F+qQ%hCd-ur@S.CTAW`=h:O.:t6!7q-Dm*p;@I*8!48JfCF
B4uD+>#V<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+Pb6bC)N
0bEPf,!F9R,!F&@VTA3Mt!H!si'F>N<:+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<
+LdV<+LdV<+LdV<+Y/cK/(Fur@E5>F+91VE+49BCF+2GlBkqEY?<%O@wLdV<+LdV<+LdV<+L
dV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+A>fCFPf,!F9R,!F&@VTA4>fCF<T<
3IFngm#i^;I/:p2TAPf,!F9R,!F&@VTAJOZ-EwnLE+>#V<+LdV<+LdV<+LdV<+LdV<+LdV<+
LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+VC/yEqiWeDK5>F+91VE+49BCF)oATA%6sJD<T<3I6d
V<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+>qAkB9mZQH9MfC
F5Q?<@,ZtfAf%+Y?<%O@wLdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+L
dV<+LdV<+7mK;@d0m*E+>fC+@uJTAHR8EF'Y#D+m1sp@m`EiCqEi'F>N<:+LdV<+LdV<+LdV
<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+Y/cK/&wT(FAExQH9MfCF5Q?<@5Vi|D
qHMTA3nLE+ergm#Engm#GuMTAs>fCFh<..DB5>F+91VE+49BCF:U/*FdjtSAoF|;@qKi'F>N
<:+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+TX93I6dV<+LdV<+LdV<+LdV<
+LdV<+LdV<+LdV<+LdV<+')um#y?8UFrs6IDsK7ID_(+Y?:n<@wEngm#vMfCF:uMTAs>fCFh
<..D,tc3@c<tm#Engm#91VE+gU54Bw!NTAs>fCFN`/*FdjtSAoF|;@y6tm#Engm#DP)*FkTo
dCGBnW48q=hCicJ^Frs6IDp9qHD<arm#d2g0I6dV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+
LdV<+3Mt!H!si'F<H<:+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+JS)!F2h
m`C)N0bE94^aE(#V<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+:tJTAHR8E
F'Y#D+gU54Bs0<:+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+TX93I6dV<+LdV<+LdV<+L
dV<+LdV<+LdV<+LdV<+LdV<+:y5DFjTi'F<H<:+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV
<+LdV<+LdV<+JS)!F670wEu-cOB94^aE(#V<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+
LdV<+LdV<+:tJTAHR8EF'Y#D+gU54Bs0<:+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+TX
93I6dV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+4>fCF:BxQH6dV<+LdV<+LdV<+LdV<
+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+9MfCF4>fCF94^aE(#V<+LdV<+LdV<+LdV<+LdV<+L
dV<+LdV<+LdV<+LdV<+LdV<+:tJTAHR8EF'Y#D+gU54Bs0<:+LdV<+LdV<+LdV<+LdV<+LdV
<+LdV<+LdV<+TX93I6dV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+JOZ-EwnLE+<#V<+
LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+:tJTAN0t#H;ZpT,fB4>wLdV<+Ld
V<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+91VE+49BCFwf=hCgQi'F6dV<+LdV<
+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+>N<:+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+=
3rfAf%+Y?:n<@wLdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+91VE+m'c
SA94^aE(#V<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+:tJTAHR8EF'Y#D+
gU54Bs0<:+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+TX93I6dV<+LdV<+LdV<+LdV<+Ld
V<+LdV<+LdV<+LdV<++*Z4Brd'Z?:n<@wLdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<
+LdV<+JS)!F8IfZEqiWeD5tc3@%b;:+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+L
dV<+:tJTAHR8EF'Y#D+gU54Bs0<:+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV
<+>wO@wLdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+m1sp@m`EiCqEi'F<H<:+LdV<+
LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+:tJTA=MCiCU_*Y?&1Hr@94^aE(#V<+Ld
V<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+9MfCF5Q?<@,ZtfA`e<Y?4#V<+LdV<
+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+>N<:+LdV<+LdV<+LdV<+LdV<+LdV<+L
dV<+LdV<+F/g|DqHMTA3nLE+<#V<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV
<+9MfCF(sGnA91VE++E%6B6dV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+
91VE+49BCFwf=hCgQi'F6dV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+LdV<+>N<:+LdV<+Ld
V<+LdV<+LdV<+LdV<+,CEw
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
1
>v
i
2000
x
15
`Xy7A#3jNCC4udD80-&
x
7
G&/Q8,wGw
x
5
bhT(<A!
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
4
@?0!.
x
4
o%%@+
x
8
`UJ@+vonC+
x
1
+v
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
36
Z(tJ:k>`bD?_TbE*uJTAtZmID=JqcB7APQB)oATA%6sJD
x
3
s^;-
x
30
N)yI:/F><@'k|7A*mK;@nEV5B8AseD,JqcBZ-v
x
6
-QBfD|+%
x
3
Y@l,
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
L 1 1071 1000 2077 1071 -1
L 2 1425 265 1701 1691 -1
L 2 1791 267 2069 2059 -1
C 1 2107 8 -1 -1 2120
C 1 2226 8 -1 -1 2239
C 1 2264 8 -1 -1 2277
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
1 69
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
0-00D<v
47 0 9
5
1-00D<v
48 0 9
8
xk3Y?8W5DF
49 0 9
11
ridlBo97IDUvg+
50 0 9
5
/LDTA?v
51 0 8
4
u3uSA
52 0 8
5
4U)9A?v
53 0 9
1
5v
54 0 8
3
ad2-
55 0 9
3
fe|+
56 0 9
3
a@c,
57 0 9
6
%Nt!HN%%
58 0 9
5
sjtSA@v
59 0 9
8
sj|Z?:p2TA
60 0 9
4
.0B,E
61 0 9
3
r<i-
62 0 9
3
sBr-
63 0 9
8
aS!Y?/1Hr@
64 0 9
8
aS!Y?.1Hr@
65 0 9
3
#Oi-
66 0 9
4
:p2TA
67 0 8
3
'Cr-
68 0 9
x
15
rpwhC;Z2b3<?<+EfqT+
0
0
}
