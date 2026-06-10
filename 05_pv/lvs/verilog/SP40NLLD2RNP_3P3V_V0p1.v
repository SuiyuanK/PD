//********************************************************************************//
//**********            (C) Copyright 2011 SMIC Inc.                    **********//
//**********                SMIC Verilog Models                         **********//
//********************************************************************************//
//       FileName   : SP40NLLD2RN_3P3V_V0p1.v                                    //
//       Function   : Verilog Models (zero timing)                                //
//       Version    : 0.1                                                         //
//       Author     : Shawn_Zhou     		       			 	  //
//       CreateDate : Jun-27-2011                                                 //
//********************************************************************************//
////////////////////////////////////////////////////////////////////////////////////
//DISCLAIMER                                                                      //
//                                                                                //
//   SMIC hereby provides the quality information to you but makes no claims,     //
// promises or guarantees about the accuracy, completeness, or adequacy of the    //
// information herein. The information contained herein is provided on an "AS IS" //
// basis without any warranty, and SMIC assumes no obligation to provide support  //
// of any kind or otherwise maintain the information.                             //
//   SMIC disclaims any representation that the information does not infringe any //
// intellectual property rights or proprietary rights of any third parties.SMIC   //
// makes no other warranty, whether express, implied or statutory as to any       //
// matter whatsoever,including but not limited to the accuracy or sufficiency of  //
// any information or the merchantability and fitness for a particular purpose.   //
// Neither SMIC nor any of its representatives shall be liable for any cause of   //
// action incurred to connect to this service.                                    //
//                                                                                //
// STATEMENT OF USE AND CONFIDENTIALITY                                           //
//                                                                                //
//   The following/attached material contains confidential and proprietary        //
// information of SMIC. This material is based upon information which SMIC        //
// considers reliable, but SMIC neither represents nor warrants that such         //
// information is accurate or complete, and it must not be relied upon as such.   //
// This information was prepared for informational purposes and is for the use    //
// by SMIC's customer only. SMIC reserves the right to make changes in the        //
// information at any time without notice.                                        //
//   No part of this information may be reproduced, transmitted, transcribed,     //
// stored in a retrieval system, or translated into any human or computer         //
// language, in any form or by any means, electronic, mechanical, magnetic,       //
// optical, chemical, manual, or otherwise, without the prior written consent of  //
// SMIC. Any unauthorized use or disclosure of this material is strictly          //
// prohibited and may be unlawful. By accepting this material, the receiving      //
// party shall be deemed to have acknowledged, accepted, and agreed to be bound   //
// by the foregoing limitations and restrictions. Thank you.                      //
////////////////////////////////////////////////////////////////////////////////////

// ****** (C) Copyright 2011 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbcd2rn.v
// Description          : 3-state Output Pad with Input and Enable Controlled Pulldown 
//
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBCD2RN (PAD,IE,OEN,REN,I,C);

output  C;
input   OEN,I,REN;
inout   PAD;
input   IE;

  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my0,REN);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify
// Parameter declarations
 specparam pad_lh_c_lh=0,pad_hl_c_hl=0,
 ie_lh_c_lz=0,ie_hl_c_zh=0,ie_lh_c_hz=0,ie_hl_c_zl=0,
 i_lh_pad_lh=0,i_hl_pad_hl=0,
 oen_lh_pad_lz=0,oen_hl_pad_zh=0,oen_lh_pad_hz=0,oen_hl_pad_zl=0,
 ren_hl_pad_hl=0,ren_lh_pad_hz=0,ren_lh_pad_lz=0;
// Delays
 (        OEN  => PAD) = (oen_lh_pad_lz,oen_lh_pad_hz,oen_lh_pad_lz,oen_hl_pad_zh,oen_lh_pad_hz,oen_hl_pad_zl);
 (        IE  => C) = (ie_lh_c_lz,ie_lh_c_hz,ie_lh_c_lz,ie_hl_c_zh,ie_lh_c_hz,ie_hl_c_zl);
 (        PAD   +=> C) = (pad_lh_c_lh,pad_hl_c_hl);
 (        I   +=> PAD) = (i_lh_pad_lh,i_hl_pad_hl);
 (        REN  => PAD) = (ren_lh_pad_lz,ren_lh_pad_hz,ren_hl_pad_hl);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults



// ****** (C) Copyright 2011 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbcd4rn.v
// Description          : 3-state Output Pad with Input and Enable Controlled Pulldown
//
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBCD4RN (PAD,IE,OEN,REN,I,C);

output  C;
input   OEN,I,REN;
inout   PAD;
input   IE;

  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my0,REN);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify
// Parameter declarations
 specparam pad_lh_c_lh=0,pad_hl_c_hl=0,
 ie_lh_c_lz=0,ie_hl_c_zh=0,ie_lh_c_hz=0,ie_hl_c_zl=0,
 i_lh_pad_lh=0,i_hl_pad_hl=0,
 oen_lh_pad_lz=0,oen_hl_pad_zh=0,oen_lh_pad_hz=0,oen_hl_pad_zl=0,
 ren_hl_pad_hl=0,ren_lh_pad_hz=0,ren_lh_pad_lz=0;
// Delays
 (        OEN  => PAD) = (oen_lh_pad_lz,oen_lh_pad_hz,oen_lh_pad_lz,oen_hl_pad_zh,oen_lh_pad_hz,oen_hl_pad_zl);
 (        IE  => C) = (ie_lh_c_lz,ie_lh_c_hz,ie_lh_c_lz,ie_hl_c_zh,ie_lh_c_hz,ie_hl_c_zl);
 (        PAD   +=> C) = (pad_lh_c_lh,pad_hl_c_hl);
 (        I   +=> PAD) = (i_lh_pad_lh,i_hl_pad_hl);
 (        REN  => PAD) = (ren_lh_pad_lz,ren_lh_pad_hz,ren_hl_pad_hl);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults


// ****** (C) Copyright 2011 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbcd8rn.v
// Description          : 3-state Output Pad with Input and Enable Controlled Pulldown
//
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBCD8RN (PAD,IE,OEN,REN,I,C);

output  C;
input   OEN,I,REN;
inout   PAD;
input   IE;

  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my0,REN);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end


`ifdef functional
`else
specify
// Parameter declarations
 specparam pad_lh_c_lh=0,pad_hl_c_hl=0,
 ie_lh_c_lz=0,ie_hl_c_zh=0,ie_lh_c_hz=0,ie_hl_c_zl=0,
 i_lh_pad_lh=0,i_hl_pad_hl=0,
 oen_lh_pad_lz=0,oen_hl_pad_zh=0,oen_lh_pad_hz=0,oen_hl_pad_zl=0,
 ren_hl_pad_hl=0,ren_lh_pad_hz=0,ren_lh_pad_lz=0;
// Delays
 (        OEN  => PAD) = (oen_lh_pad_lz,oen_lh_pad_hz,oen_lh_pad_lz,oen_hl_pad_zh,oen_lh_pad_hz,oen_hl_pad_zl);
 (        IE  => C) = (ie_lh_c_lz,ie_lh_c_hz,ie_lh_c_lz,ie_hl_c_zh,ie_lh_c_hz,ie_hl_c_zl);
 (        PAD   +=> C) = (pad_lh_c_lh,pad_hl_c_hl);
 (        I   +=> PAD) = (i_lh_pad_lh,i_hl_pad_hl);
 (        REN  => PAD) = (ren_lh_pad_lz,ren_lh_pad_hz,ren_hl_pad_hl);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults


// ****** (C) Copyright 2011 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbcd12rn.v
// Description          : 3-state Output Pad with Input and Enable Controlled Pulldown
//
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBCD12RN (PAD,IE,OEN,REN,I,C);

output  C;
input   OEN,I,REN;
inout   PAD;
input   IE;

  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my0,REN);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end


`ifdef functional
`else
specify
// Parameter declarations
 specparam pad_lh_c_lh=0,pad_hl_c_hl=0,
 ie_lh_c_lz=0,ie_hl_c_zh=0,ie_lh_c_hz=0,ie_hl_c_zl=0,
 i_lh_pad_lh=0,i_hl_pad_hl=0,
 oen_lh_pad_lz=0,oen_hl_pad_zh=0,oen_lh_pad_hz=0,oen_hl_pad_zl=0,
 ren_hl_pad_hl=0,ren_lh_pad_hz=0,ren_lh_pad_lz=0;
// Delays
 (        OEN  => PAD) = (oen_lh_pad_lz,oen_lh_pad_hz,oen_lh_pad_lz,oen_hl_pad_zh,oen_lh_pad_hz,oen_hl_pad_zl);
 (        IE  => C) = (ie_lh_c_lz,ie_lh_c_hz,ie_lh_c_lz,ie_hl_c_zh,ie_lh_c_hz,ie_hl_c_zl);
 (        PAD   +=> C) = (pad_lh_c_lh,pad_hl_c_hl);
 (        I   +=> PAD) = (i_lh_pad_lh,i_hl_pad_hl);
 (        REN  => PAD) = (ren_lh_pad_lz,ren_lh_pad_hz,ren_hl_pad_hl);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults

// ****** (C) Copyright 2011 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbcd16rn.v
// Description          : 3-state Output Pad with Input and Enable Controlled Pulldown
//
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBCD16RN (PAD,IE,OEN,REN,I,C);

output  C;
input   OEN,I,REN;
inout   PAD;
input   IE;

  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my0,REN);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end


`ifdef functional
`else
specify
// Parameter declarations
 specparam pad_lh_c_lh=0,pad_hl_c_hl=0,
 ie_lh_c_lz=0,ie_hl_c_zh=0,ie_lh_c_hz=0,ie_hl_c_zl=0,
 i_lh_pad_lh=0,i_hl_pad_hl=0,
 oen_lh_pad_lz=0,oen_hl_pad_zh=0,oen_lh_pad_hz=0,oen_hl_pad_zl=0,
 ren_hl_pad_hl=0,ren_lh_pad_hz=0,ren_lh_pad_lz=0;
// Delays
 (        OEN  => PAD) = (oen_lh_pad_lz,oen_lh_pad_hz,oen_lh_pad_lz,oen_hl_pad_zh,oen_lh_pad_hz,oen_hl_pad_zl);
 (        IE  => C) = (ie_lh_c_lz,ie_lh_c_hz,ie_lh_c_lz,ie_hl_c_zh,ie_lh_c_hz,ie_hl_c_zl);
 (        PAD   +=> C) = (pad_lh_c_lh,pad_hl_c_hl);
 (        I   +=> PAD) = (i_lh_pad_lh,i_hl_pad_hl);
 (        REN  => PAD) = (ren_lh_pad_lz,ren_lh_pad_hz,ren_hl_pad_hl);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults

// ****** (C) Copyright 2011 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbcd24rn.v
// Description          : 3-state Output Pad with Input and Enable Controlled Pulldown
//
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBCD24RN (PAD,IE,OEN,REN,I,C);

output  C;
input   OEN,I,REN;
inout   PAD;
input   IE;

  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my0,REN);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end


`ifdef functional
`else
specify
// Parameter declarations
 specparam pad_lh_c_lh=0,pad_hl_c_hl=0,
 ie_lh_c_lz=0,ie_hl_c_zh=0,ie_lh_c_hz=0,ie_hl_c_zl=0,
 i_lh_pad_lh=0,i_hl_pad_hl=0,
 oen_lh_pad_lz=0,oen_hl_pad_zh=0,oen_lh_pad_hz=0,oen_hl_pad_zl=0,
 ren_hl_pad_hl=0,ren_lh_pad_hz=0,ren_lh_pad_lz=0;
// Delays
 (        OEN  => PAD) = (oen_lh_pad_lz,oen_lh_pad_hz,oen_lh_pad_lz,oen_hl_pad_zh,oen_lh_pad_hz,oen_hl_pad_zl);
 (        IE  => C) = (ie_lh_c_lz,ie_lh_c_hz,ie_lh_c_lz,ie_hl_c_zh,ie_lh_c_hz,ie_hl_c_zl);
 (        PAD   +=> C) = (pad_lh_c_lh,pad_hl_c_hl);
 (        I   +=> PAD) = (i_lh_pad_lh,i_hl_pad_hl);
 (        REN  => PAD) = (ren_lh_pad_lz,ren_lh_pad_hz,ren_hl_pad_hl);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults


 
// ****** (C) Copyright 2011 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pbcu12rn.v
// Description  	: 3-state Output Pad with Input and Enable Controlled Pullup
//
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif 


module PBCU12RN (PAD,IE,OEN,REN,I,C);

output  C;
input   OEN,I,REN;
inout   PAD;
input   IE;

  supply1 my1;
  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my1,REN);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify
// Parameter declarations
 specparam pad_lh_c_lh=0,pad_hl_c_hl=0,
 ie_lh_c_lz=0,ie_hl_c_zh=0,ie_lh_c_hz=0,ie_hl_c_zl=0,
 i_lh_pad_lh=0,i_hl_pad_hl=0,
 oen_lh_pad_lz=0,oen_hl_pad_zh=0,oen_lh_pad_hz=0,oen_hl_pad_zl=0,
 ren_hl_pad_hl=0,ren_lh_pad_hz=0,ren_lh_pad_lz=0;
// Delays
 (        OEN  => PAD) = (oen_lh_pad_lz,oen_lh_pad_hz,oen_lh_pad_lz,oen_hl_pad_zh,oen_lh_pad_hz,oen_hl_pad_zl);
 (        IE  => C) = (ie_lh_c_lz,ie_lh_c_hz,ie_lh_c_lz,ie_hl_c_zh,ie_lh_c_hz,ie_hl_c_zl);
 (        PAD   +=> C) = (pad_lh_c_lh,pad_hl_c_hl);
 (        I   +=> PAD) = (i_lh_pad_lh,i_hl_pad_hl);
 (        REN  => PAD) = (ren_lh_pad_lz,ren_lh_pad_hz,ren_hl_pad_hl);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults
 
 
// ****** (C) Copyright 2011 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pbcu16rn.v
// Description  	: 3-state Output Pad with Input and Enable Controlled Pullup
//
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif 


module PBCU16RN (PAD,IE,OEN,REN,I,C);

output  C;
input   OEN,I,REN;
inout   PAD;
input   IE;

  supply1 my1;
  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my1,REN);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify
// Parameter declarations
 specparam pad_lh_c_lh=0,pad_hl_c_hl=0,
 ie_lh_c_lz=0,ie_hl_c_zh=0,ie_lh_c_hz=0,ie_hl_c_zl=0,
 i_lh_pad_lh=0,i_hl_pad_hl=0,
 oen_lh_pad_lz=0,oen_hl_pad_zh=0,oen_lh_pad_hz=0,oen_hl_pad_zl=0,
 ren_hl_pad_hl=0,ren_lh_pad_hz=0,ren_lh_pad_lz=0;
// Delays
 (        OEN  => PAD) = (oen_lh_pad_lz,oen_lh_pad_hz,oen_lh_pad_lz,oen_hl_pad_zh,oen_lh_pad_hz,oen_hl_pad_zl);
 (        IE  => C) = (ie_lh_c_lz,ie_lh_c_hz,ie_lh_c_lz,ie_hl_c_zh,ie_lh_c_hz,ie_hl_c_zl);
 (        PAD   +=> C) = (pad_lh_c_lh,pad_hl_c_hl);
 (        I   +=> PAD) = (i_lh_pad_lh,i_hl_pad_hl);
 (        REN  => PAD) = (ren_lh_pad_lz,ren_lh_pad_hz,ren_hl_pad_hl);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults
 
 

 
// ****** (C) Copyright 2011 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pbcu2rn.v
// Description  	: 3-state Output Pad with Input and Enable Controlled Pullup 
//
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif 


module PBCU2RN (PAD,IE,OEN,REN,I,C);

output  C;
input   OEN,I,REN;
inout   PAD;
input   IE;

  supply1 my1;
  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my1,REN);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify
// Parameter declarations
 specparam pad_lh_c_lh=0,pad_hl_c_hl=0,
 ie_lh_c_lz=0,ie_hl_c_zh=0,ie_lh_c_hz=0,ie_hl_c_zl=0,
 i_lh_pad_lh=0,i_hl_pad_hl=0,
 oen_lh_pad_lz=0,oen_hl_pad_zh=0,oen_lh_pad_hz=0,oen_hl_pad_zl=0,
 ren_hl_pad_hl=0,ren_lh_pad_hz=0,ren_lh_pad_lz=0;
// Delays
 (        OEN  => PAD) = (oen_lh_pad_lz,oen_lh_pad_hz,oen_lh_pad_lz,oen_hl_pad_zh,oen_lh_pad_hz,oen_hl_pad_zl);
 (        IE  => C) = (ie_lh_c_lz,ie_lh_c_hz,ie_lh_c_lz,ie_hl_c_zh,ie_lh_c_hz,ie_hl_c_zl);
 (        PAD   +=> C) = (pad_lh_c_lh,pad_hl_c_hl);
 (        I   +=> PAD) = (i_lh_pad_lh,i_hl_pad_hl);
 (        REN  => PAD) = (ren_lh_pad_lz,ren_lh_pad_hz,ren_hl_pad_hl);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults
 
 

 
// ****** (C) Copyright 2011 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pbcu24rn.v
// Description  	: 3-state Output Pad with Input and Enable Controlled Pullup
//
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif 


module PBCU24RN (PAD,IE,OEN,REN,I,C);

output  C;
input   OEN,I,REN;
inout   PAD;
input   IE;

  supply1 my1;
  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my1,REN);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify
// Parameter declarations
 specparam pad_lh_c_lh=0,pad_hl_c_hl=0,
 ie_lh_c_lz=0,ie_hl_c_zh=0,ie_lh_c_hz=0,ie_hl_c_zl=0,
 i_lh_pad_lh=0,i_hl_pad_hl=0,
 oen_lh_pad_lz=0,oen_hl_pad_zh=0,oen_lh_pad_hz=0,oen_hl_pad_zl=0,
 ren_hl_pad_hl=0,ren_lh_pad_hz=0,ren_lh_pad_lz=0;
// Delays
 (        OEN  => PAD) = (oen_lh_pad_lz,oen_lh_pad_hz,oen_lh_pad_lz,oen_hl_pad_zh,oen_lh_pad_hz,oen_hl_pad_zl);
 (        IE  => C) = (ie_lh_c_lz,ie_lh_c_hz,ie_lh_c_lz,ie_hl_c_zh,ie_lh_c_hz,ie_hl_c_zl);
 (        PAD   +=> C) = (pad_lh_c_lh,pad_hl_c_hl);
 (        I   +=> PAD) = (i_lh_pad_lh,i_hl_pad_hl);
 (        REN  => PAD) = (ren_lh_pad_lz,ren_lh_pad_hz,ren_hl_pad_hl);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults
 
 

 
// ****** (C) Copyright 2011 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pbcu4rn.v
// Description  	: 3-state Output Pad with Input and Enable Controlled Pullup
//
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif 


module PBCU4RN (PAD,IE,OEN,REN,I,C);

output  C;
input   OEN,I,REN;
inout   PAD;
input   IE;

  supply1 my1;
  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my1,REN);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify
// Parameter declarations
 specparam pad_lh_c_lh=0,pad_hl_c_hl=0,
 ie_lh_c_lz=0,ie_hl_c_zh=0,ie_lh_c_hz=0,ie_hl_c_zl=0,
 i_lh_pad_lh=0,i_hl_pad_hl=0,
 oen_lh_pad_lz=0,oen_hl_pad_zh=0,oen_lh_pad_hz=0,oen_hl_pad_zl=0,
 ren_hl_pad_hl=0,ren_lh_pad_hz=0,ren_lh_pad_lz=0;
// Delays
 (        OEN  => PAD) = (oen_lh_pad_lz,oen_lh_pad_hz,oen_lh_pad_lz,oen_hl_pad_zh,oen_lh_pad_hz,oen_hl_pad_zl);
 (        IE  => C) = (ie_lh_c_lz,ie_lh_c_hz,ie_lh_c_lz,ie_hl_c_zh,ie_lh_c_hz,ie_hl_c_zl);
 (        PAD   +=> C) = (pad_lh_c_lh,pad_hl_c_hl);
 (        I   +=> PAD) = (i_lh_pad_lh,i_hl_pad_hl);
 (        REN  => PAD) = (ren_lh_pad_lz,ren_lh_pad_hz,ren_hl_pad_hl);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults
 
 

 
// ****** (C) Copyright 2011 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pbcu8rn.v
// Description  	: 3-state Output Pad with Input and Enable Controlled Pullup
//
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif 


module PBCU8RN (PAD,IE,OEN,REN,I,C);

output  C;
input   OEN,I,REN;
inout   PAD;
input   IE;

  supply1 my1;
  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my1,REN);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify
// Parameter declarations
 specparam pad_lh_c_lh=0,pad_hl_c_hl=0,
 ie_lh_c_lz=0,ie_hl_c_zh=0,ie_lh_c_hz=0,ie_hl_c_zl=0,
 i_lh_pad_lh=0,i_hl_pad_hl=0,
 oen_lh_pad_lz=0,oen_hl_pad_zh=0,oen_lh_pad_hz=0,oen_hl_pad_zl=0,
 ren_hl_pad_hl=0,ren_lh_pad_hz=0,ren_lh_pad_lz=0;
// Delays
 (        OEN  => PAD) = (oen_lh_pad_lz,oen_lh_pad_hz,oen_lh_pad_lz,oen_hl_pad_zh,oen_lh_pad_hz,oen_hl_pad_zl);
 (        IE  => C) = (ie_lh_c_lz,ie_lh_c_hz,ie_lh_c_lz,ie_hl_c_zh,ie_lh_c_hz,ie_hl_c_zl);
 (        PAD   +=> C) = (pad_lh_c_lh,pad_hl_c_hl);
 (        I   +=> PAD) = (i_lh_pad_lh,i_hl_pad_hl);
 (        REN  => PAD) = (ren_lh_pad_lz,ren_lh_pad_hz,ren_hl_pad_hl);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults
 
 
 
// ****** (C) Copyright 2011 SMIC   Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pbs12rn.v
// Description  	: CMOS 3-state Output Pad with Schmitt Trigger Input 
//
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif 


module PBS12RN (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

and    #0.01 (C,PAD,IE);
bufif0 #0.01 (PAD,I,OEN);

`ifdef functional
`else
specify
// Parameter declarations
 specparam pad_lh_c_lh=0,pad_hl_c_hl=0,
 ie_lh_c_lz=0,ie_hl_c_zh=0,ie_lh_c_hz=0,ie_hl_c_zl=0,
 i_lh_pad_lh=0,i_hl_pad_hl=0,
 oen_lh_pad_lz=0,oen_hl_pad_zh=0,oen_lh_pad_hz=0,oen_hl_pad_zl=0;
// Delays
 (        OEN  => PAD) = (oen_lh_pad_lz,oen_lh_pad_hz,oen_lh_pad_lz,oen_hl_pad_zh,oen_lh_pad_hz,oen_hl_pad_zl);
 (        IE  => C) = (ie_lh_c_lz,ie_lh_c_hz,ie_lh_c_lz,ie_hl_c_zh,ie_lh_c_hz,ie_hl_c_zl);
 (        PAD   +=> C) = (pad_lh_c_lh,pad_hl_c_hl);
 (        I   +=> PAD) = (i_lh_pad_lh,i_hl_pad_hl);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults
 
 
// ****** (C) Copyright 2011 SMIC   Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pbs16rn.v
// Description  	: CMOS 3-state Output Pad with Schmitt Trigger Input 
//
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif 


module PBS16RN (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

and    #0.01 (C,PAD,IE);
bufif0 #0.01 (PAD,I,OEN);

`ifdef functional
`else
specify
// Parameter declarations
 specparam pad_lh_c_lh=0,pad_hl_c_hl=0,
 ie_lh_c_lz=0,ie_hl_c_zh=0,ie_lh_c_hz=0,ie_hl_c_zl=0,
 i_lh_pad_lh=0,i_hl_pad_hl=0,
 oen_lh_pad_lz=0,oen_hl_pad_zh=0,oen_lh_pad_hz=0,oen_hl_pad_zl=0;
// Delays
 (        OEN  => PAD) = (oen_lh_pad_lz,oen_lh_pad_hz,oen_lh_pad_lz,oen_hl_pad_zh,oen_lh_pad_hz,oen_hl_pad_zl);
 (        IE  => C) = (ie_lh_c_lz,ie_lh_c_hz,ie_lh_c_lz,ie_hl_c_zh,ie_lh_c_hz,ie_hl_c_zl);
 (        PAD   +=> C) = (pad_lh_c_lh,pad_hl_c_hl);
 (        I   +=> PAD) = (i_lh_pad_lh,i_hl_pad_hl);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults
 
 
// ****** (C) Copyright 2011 SMIC   Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pbs2rn.v
// Description  	: CMOS 3-state Output Pad with Schmitt Trigger Input 
//
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif 


module PBS2RN (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

and    #0.01 (C,PAD,IE);
bufif0 #0.01 (PAD,I,OEN);

`ifdef functional
`else
specify
// Parameter declarations
 specparam pad_lh_c_lh=0,pad_hl_c_hl=0,
 ie_lh_c_lz=0,ie_hl_c_zh=0,ie_lh_c_hz=0,ie_hl_c_zl=0,
 i_lh_pad_lh=0,i_hl_pad_hl=0,
 oen_lh_pad_lz=0,oen_hl_pad_zh=0,oen_lh_pad_hz=0,oen_hl_pad_zl=0;
// Delays
 (        OEN  => PAD) = (oen_lh_pad_lz,oen_lh_pad_hz,oen_lh_pad_lz,oen_hl_pad_zh,oen_lh_pad_hz,oen_hl_pad_zl);
 (        IE  => C) = (ie_lh_c_lz,ie_lh_c_hz,ie_lh_c_lz,ie_hl_c_zh,ie_lh_c_hz,ie_hl_c_zl);
 (        PAD   +=> C) = (pad_lh_c_lh,pad_hl_c_hl);
 (        I   +=> PAD) = (i_lh_pad_lh,i_hl_pad_hl);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults
 
 
// ****** (C) Copyright 2011 SMIC   Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pbs24rn.v
// Description  	: CMOS 3-state Output Pad with Schmitt Trigger Input 
//
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif 


module PBS24RN (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

and    #0.01 (C,PAD,IE);
bufif0 #0.01 (PAD,I,OEN);

`ifdef functional
`else
specify
// Parameter declarations
 specparam pad_lh_c_lh=0,pad_hl_c_hl=0,
 ie_lh_c_lz=0,ie_hl_c_zh=0,ie_lh_c_hz=0,ie_hl_c_zl=0,
 i_lh_pad_lh=0,i_hl_pad_hl=0,
 oen_lh_pad_lz=0,oen_hl_pad_zh=0,oen_lh_pad_hz=0,oen_hl_pad_zl=0;
// Delays
 (        OEN  => PAD) = (oen_lh_pad_lz,oen_lh_pad_hz,oen_lh_pad_lz,oen_hl_pad_zh,oen_lh_pad_hz,oen_hl_pad_zl);
 (        IE  => C) = (ie_lh_c_lz,ie_lh_c_hz,ie_lh_c_lz,ie_hl_c_zh,ie_lh_c_hz,ie_hl_c_zl);
 (        PAD   +=> C) = (pad_lh_c_lh,pad_hl_c_hl);
 (        I   +=> PAD) = (i_lh_pad_lh,i_hl_pad_hl);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults
 
 
// ****** (C) Copyright 2011 SMIC   Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pbs4rn.v
// Description  	: CMOS 3-state Output Pad with Schmitt Trigger Input 
//
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif 


module PBS4RN (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

and    #0.01 (C,PAD,IE);
bufif0 #0.01 (PAD,I,OEN);

`ifdef functional
`else
specify
// Parameter declarations
 specparam pad_lh_c_lh=0,pad_hl_c_hl=0,
 ie_lh_c_lz=0,ie_hl_c_zh=0,ie_lh_c_hz=0,ie_hl_c_zl=0,
 i_lh_pad_lh=0,i_hl_pad_hl=0,
 oen_lh_pad_lz=0,oen_hl_pad_zh=0,oen_lh_pad_hz=0,oen_hl_pad_zl=0;
// Delays
 (        OEN  => PAD) = (oen_lh_pad_lz,oen_lh_pad_hz,oen_lh_pad_lz,oen_hl_pad_zh,oen_lh_pad_hz,oen_hl_pad_zl);
 (        IE  => C) = (ie_lh_c_lz,ie_lh_c_hz,ie_lh_c_lz,ie_hl_c_zh,ie_lh_c_hz,ie_hl_c_zl);
 (        PAD   +=> C) = (pad_lh_c_lh,pad_hl_c_hl);
 (        I   +=> PAD) = (i_lh_pad_lh,i_hl_pad_hl);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults
 
 
// ****** (C) Copyright 2011 SMIC   Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
// 
// Model type   	: zero timing
// Filename     	: pbs8rn.v
// Description  	: CMOS 3-state Output Pad with Schmitt Trigger Input 
//
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif 


module PBS8RN (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

and    #0.01 (C,PAD,IE);
bufif0 #0.01 (PAD,I,OEN);

`ifdef functional
`else
specify
// Parameter declarations
 specparam pad_lh_c_lh=0,pad_hl_c_hl=0,
 ie_lh_c_lz=0,ie_hl_c_zh=0,ie_lh_c_hz=0,ie_hl_c_zl=0,
 i_lh_pad_lh=0,i_hl_pad_hl=0,
 oen_lh_pad_lz=0,oen_hl_pad_zh=0,oen_lh_pad_hz=0,oen_hl_pad_zl=0;
// Delays
 (        OEN  => PAD) = (oen_lh_pad_lz,oen_lh_pad_hz,oen_lh_pad_lz,oen_hl_pad_zh,oen_lh_pad_hz,oen_hl_pad_zl);
 (        IE  => C) = (ie_lh_c_lz,ie_lh_c_hz,ie_lh_c_lz,ie_hl_c_zh,ie_lh_c_hz,ie_hl_c_zl);
 (        PAD   +=> C) = (pad_lh_c_lh,pad_hl_c_hl);
 (        I   +=> PAD) = (i_lh_pad_lh,i_hl_pad_hl);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults
 
 
 
// ****** (C) Copyright 2011 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbsd2rn.v
// Description          : CMOS 3-state output pad with schmitt trigger input and pulldown
//
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBSD2RN (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my0,my0);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify
// Parameter declarations
 specparam pad_lh_c_lh=0,pad_hl_c_hl=0,
 ie_lh_c_lz=0,ie_hl_c_zh=0,ie_lh_c_hz=0,ie_hl_c_zl=0,
 i_lh_pad_lh=0,i_hl_pad_hl=0,
 oen_lh_pad_lz=0,oen_hl_pad_zh=0,oen_lh_pad_hz=0,oen_hl_pad_zl=0;
// Delays
 (        OEN  => PAD) = (oen_lh_pad_lz,oen_lh_pad_hz,oen_lh_pad_lz,oen_hl_pad_zh,oen_lh_pad_hz,
oen_hl_pad_zl);
 (        IE  => C) = (ie_lh_c_lz,ie_lh_c_hz,ie_lh_c_lz,ie_hl_c_zh,ie_lh_c_hz,ie_hl_c_zl);
 (        PAD   +=> C) = (pad_lh_c_lh,pad_hl_c_hl);
 (        I   +=> PAD) = (i_lh_pad_lh,i_hl_pad_hl);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults



// ****** (C) Copyright 2011 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbsd4rn.v
// Description          : CMOS 3-state output pad with schmitt trigger input and pulldown
//
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBSD4RN (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my0,my0);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify
// Parameter declarations
 specparam pad_lh_c_lh=0,pad_hl_c_hl=0,
 ie_lh_c_lz=0,ie_hl_c_zh=0,ie_lh_c_hz=0,ie_hl_c_zl=0,
 i_lh_pad_lh=0,i_hl_pad_hl=0,
 oen_lh_pad_lz=0,oen_hl_pad_zh=0,oen_lh_pad_hz=0,oen_hl_pad_zl=0;
// Delays
 (        OEN  => PAD) = (oen_lh_pad_lz,oen_lh_pad_hz,oen_lh_pad_lz,oen_hl_pad_zh,oen_lh_pad_hz,
oen_hl_pad_zl);
 (        IE  => C) = (ie_lh_c_lz,ie_lh_c_hz,ie_lh_c_lz,ie_hl_c_zh,ie_lh_c_hz,ie_hl_c_zl);
 (        PAD   +=> C) = (pad_lh_c_lh,pad_hl_c_hl);
 (        I   +=> PAD) = (i_lh_pad_lh,i_hl_pad_hl);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults


// ****** (C) Copyright 2011 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbsd8rn.v
// Description          : CMOS 3-state output pad with schmitt trigger input and pulldown
//
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBSD8RN (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my0,my0);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify
// Parameter declarations
 specparam pad_lh_c_lh=0,pad_hl_c_hl=0,
 ie_lh_c_lz=0,ie_hl_c_zh=0,ie_lh_c_hz=0,ie_hl_c_zl=0,
 i_lh_pad_lh=0,i_hl_pad_hl=0,
 oen_lh_pad_lz=0,oen_hl_pad_zh=0,oen_lh_pad_hz=0,oen_hl_pad_zl=0;
// Delays
 (        OEN  => PAD) = (oen_lh_pad_lz,oen_lh_pad_hz,oen_lh_pad_lz,oen_hl_pad_zh,oen_lh_pad_hz,
oen_hl_pad_zl);
 (        IE  => C) = (ie_lh_c_lz,ie_lh_c_hz,ie_lh_c_lz,ie_hl_c_zh,ie_lh_c_hz,ie_hl_c_zl);
 (        PAD   +=> C) = (pad_lh_c_lh,pad_hl_c_hl);
 (        I   +=> PAD) = (i_lh_pad_lh,i_hl_pad_hl);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults


// ****** (C) Copyright 2011 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbsd12rn.v
// Description          : CMOS 3-state output pad with schmitt trigger input and pulldown
//
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBSD12RN (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my0,my0);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify
// Parameter declarations
 specparam pad_lh_c_lh=0,pad_hl_c_hl=0,
 ie_lh_c_lz=0,ie_hl_c_zh=0,ie_lh_c_hz=0,ie_hl_c_zl=0,
 i_lh_pad_lh=0,i_hl_pad_hl=0,
 oen_lh_pad_lz=0,oen_hl_pad_zh=0,oen_lh_pad_hz=0,oen_hl_pad_zl=0;
// Delays
 (        OEN  => PAD) = (oen_lh_pad_lz,oen_lh_pad_hz,oen_lh_pad_lz,oen_hl_pad_zh,oen_lh_pad_hz,
oen_hl_pad_zl);
 (        IE  => C) = (ie_lh_c_lz,ie_lh_c_hz,ie_lh_c_lz,ie_hl_c_zh,ie_lh_c_hz,ie_hl_c_zl);
 (        PAD   +=> C) = (pad_lh_c_lh,pad_hl_c_hl);
 (        I   +=> PAD) = (i_lh_pad_lh,i_hl_pad_hl);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults


// ****** (C) Copyright 2011 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbsd16rn.v
// Description          : CMOS 3-state output pad with schmitt trigger input and pulldown
//
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBSD16RN (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my0,my0);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify
// Parameter declarations
 specparam pad_lh_c_lh=0,pad_hl_c_hl=0,
 ie_lh_c_lz=0,ie_hl_c_zh=0,ie_lh_c_hz=0,ie_hl_c_zl=0,
 i_lh_pad_lh=0,i_hl_pad_hl=0,
 oen_lh_pad_lz=0,oen_hl_pad_zh=0,oen_lh_pad_hz=0,oen_hl_pad_zl=0;
// Delays
 (        OEN  => PAD) = (oen_lh_pad_lz,oen_lh_pad_hz,oen_lh_pad_lz,oen_hl_pad_zh,oen_lh_pad_hz,
oen_hl_pad_zl);
 (        IE  => C) = (ie_lh_c_lz,ie_lh_c_hz,ie_lh_c_lz,ie_hl_c_zh,ie_lh_c_hz,ie_hl_c_zl);
 (        PAD   +=> C) = (pad_lh_c_lh,pad_hl_c_hl);
 (        I   +=> PAD) = (i_lh_pad_lh,i_hl_pad_hl);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults


// ****** (C) Copyright 2011 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbsd24rn.v
// Description          : CMOS 3-state output pad with schmitt trigger input and pulldown
//
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBSD24RN (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my0,my0);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify
// Parameter declarations
 specparam pad_lh_c_lh=0,pad_hl_c_hl=0,
 ie_lh_c_lz=0,ie_hl_c_zh=0,ie_lh_c_hz=0,ie_hl_c_zl=0,
 i_lh_pad_lh=0,i_hl_pad_hl=0,
 oen_lh_pad_lz=0,oen_hl_pad_zh=0,oen_lh_pad_hz=0,oen_hl_pad_zl=0;
// Delays
 (        OEN  => PAD) = (oen_lh_pad_lz,oen_lh_pad_hz,oen_lh_pad_lz,oen_hl_pad_zh,oen_lh_pad_hz,
oen_hl_pad_zl);
 (        IE  => C) = (ie_lh_c_lz,ie_lh_c_hz,ie_lh_c_lz,ie_hl_c_zh,ie_lh_c_hz,ie_hl_c_zl);
 (        PAD   +=> C) = (pad_lh_c_lh,pad_hl_c_hl);
 (        I   +=> PAD) = (i_lh_pad_lh,i_hl_pad_hl);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults




// ****** (C) Copyright 2011 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbsu2rn.v
// Description          : CMOS 3-state output pad with schmitt trigger input and pullup
//
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBSU2RN (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

  supply1 my1;
  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my1,my0);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify
// Parameter declarations
 specparam pad_lh_c_lh=0,pad_hl_c_hl=0,
 ie_lh_c_lz=0,ie_hl_c_zh=0,ie_lh_c_hz=0,ie_hl_c_zl=0,
 i_lh_pad_lh=0,i_hl_pad_hl=0,
 oen_lh_pad_lz=0,oen_hl_pad_zh=0,oen_lh_pad_hz=0,oen_hl_pad_zl=0;
// Delays
 (        OEN  => PAD) = (oen_lh_pad_lz,oen_lh_pad_hz,oen_lh_pad_lz,oen_hl_pad_zh,oen_lh_pad_hz,
oen_hl_pad_zl);
 (        IE  => C) = (ie_lh_c_lz,ie_lh_c_hz,ie_lh_c_lz,ie_hl_c_zh,ie_lh_c_hz,ie_hl_c_zl);
 (        PAD   +=> C) = (pad_lh_c_lh,pad_hl_c_hl);
 (        I   +=> PAD) = (i_lh_pad_lh,i_hl_pad_hl);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults

// ****** (C) Copyright 2011 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbsu4rn.v
// Description          : CMOS 3-state output pad with schmitt trigger input and pullup
//
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBSU4RN (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

  supply1 my1;
  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my1,my0);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify
// Parameter declarations
 specparam pad_lh_c_lh=0,pad_hl_c_hl=0,
 ie_lh_c_lz=0,ie_hl_c_zh=0,ie_lh_c_hz=0,ie_hl_c_zl=0,
 i_lh_pad_lh=0,i_hl_pad_hl=0,
 oen_lh_pad_lz=0,oen_hl_pad_zh=0,oen_lh_pad_hz=0,oen_hl_pad_zl=0;
// Delays
 (        OEN  => PAD) = (oen_lh_pad_lz,oen_lh_pad_hz,oen_lh_pad_lz,oen_hl_pad_zh,oen_lh_pad_hz,
oen_hl_pad_zl);
 (        IE  => C) = (ie_lh_c_lz,ie_lh_c_hz,ie_lh_c_lz,ie_hl_c_zh,ie_lh_c_hz,ie_hl_c_zl);
 (        PAD   +=> C) = (pad_lh_c_lh,pad_hl_c_hl);
 (        I   +=> PAD) = (i_lh_pad_lh,i_hl_pad_hl);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults


// ****** (C) Copyright 2011 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbsu8rn.v
// Description          : CMOS 3-state output pad with schmitt trigger input and pullup
//
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBSU8RN (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

  supply1 my1;
  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my1,my0);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify
// Parameter declarations
 specparam pad_lh_c_lh=0,pad_hl_c_hl=0,
 ie_lh_c_lz=0,ie_hl_c_zh=0,ie_lh_c_hz=0,ie_hl_c_zl=0,
 i_lh_pad_lh=0,i_hl_pad_hl=0,
 oen_lh_pad_lz=0,oen_hl_pad_zh=0,oen_lh_pad_hz=0,oen_hl_pad_zl=0;
// Delays
 (        OEN  => PAD) = (oen_lh_pad_lz,oen_lh_pad_hz,oen_lh_pad_lz,oen_hl_pad_zh,oen_lh_pad_hz,
oen_hl_pad_zl);
 (        IE  => C) = (ie_lh_c_lz,ie_lh_c_hz,ie_lh_c_lz,ie_hl_c_zh,ie_lh_c_hz,ie_hl_c_zl);
 (        PAD   +=> C) = (pad_lh_c_lh,pad_hl_c_hl);
 (        I   +=> PAD) = (i_lh_pad_lh,i_hl_pad_hl);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults


// ****** (C) Copyright 2011 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbsu12rn.v
// Description          : CMOS 3-state output pad with schmitt trigger input and pullup
//
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBSU12RN (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

  supply1 my1;
  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my1,my0);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify
// Parameter declarations
 specparam pad_lh_c_lh=0,pad_hl_c_hl=0,
 ie_lh_c_lz=0,ie_hl_c_zh=0,ie_lh_c_hz=0,ie_hl_c_zl=0,
 i_lh_pad_lh=0,i_hl_pad_hl=0,
 oen_lh_pad_lz=0,oen_hl_pad_zh=0,oen_lh_pad_hz=0,oen_hl_pad_zl=0;
// Delays
 (        OEN  => PAD) = (oen_lh_pad_lz,oen_lh_pad_hz,oen_lh_pad_lz,oen_hl_pad_zh,oen_lh_pad_hz,
oen_hl_pad_zl);
 (        IE  => C) = (ie_lh_c_lz,ie_lh_c_hz,ie_lh_c_lz,ie_hl_c_zh,ie_lh_c_hz,ie_hl_c_zl);
 (        PAD   +=> C) = (pad_lh_c_lh,pad_hl_c_hl);
 (        I   +=> PAD) = (i_lh_pad_lh,i_hl_pad_hl);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults


// ****** (C) Copyright 2011 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbsu16rn.v
// Description          : CMOS 3-state output pad with schmitt trigger input and pullup
//
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBSU16RN (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

  supply1 my1;
  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my1,my0);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify
// Parameter declarations
 specparam pad_lh_c_lh=0,pad_hl_c_hl=0,
 ie_lh_c_lz=0,ie_hl_c_zh=0,ie_lh_c_hz=0,ie_hl_c_zl=0,
 i_lh_pad_lh=0,i_hl_pad_hl=0,
 oen_lh_pad_lz=0,oen_hl_pad_zh=0,oen_lh_pad_hz=0,oen_hl_pad_zl=0;
// Delays
 (        OEN  => PAD) = (oen_lh_pad_lz,oen_lh_pad_hz,oen_lh_pad_lz,oen_hl_pad_zh,oen_lh_pad_hz,
oen_hl_pad_zl);
 (        IE  => C) = (ie_lh_c_lz,ie_lh_c_hz,ie_lh_c_lz,ie_hl_c_zh,ie_lh_c_hz,ie_hl_c_zl);
 (        PAD   +=> C) = (pad_lh_c_lh,pad_hl_c_hl);
 (        I   +=> PAD) = (i_lh_pad_lh,i_hl_pad_hl);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults


// ****** (C) Copyright 2011 SMIC Inc. ********
//  --    SMIC Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pbsu24rn.v
// Description          : CMOS 3-state output pad with schmitt trigger input and pullup
//
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PBSU24RN (PAD,IE,OEN,I,C);

output  C;
input   OEN,I;
inout   PAD;
input   IE;

  supply1 my1;
  supply0 my0;
  bufif0  (C_buf, I, OEN);
  pmos    (PAD,C_buf,my0);
  and        (C,PAD,IE);
  rpmos   #0.01 (C_buf,my1,my0);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify
// Parameter declarations
 specparam pad_lh_c_lh=0,pad_hl_c_hl=0,
 ie_lh_c_lz=0,ie_hl_c_zh=0,ie_lh_c_hz=0,ie_hl_c_zl=0,
 i_lh_pad_lh=0,i_hl_pad_hl=0,
 oen_lh_pad_lz=0,oen_hl_pad_zh=0,oen_lh_pad_hz=0,oen_hl_pad_zl=0;
// Delays
 (        OEN  => PAD) = (oen_lh_pad_lz,oen_lh_pad_hz,oen_lh_pad_lz,oen_hl_pad_zh,oen_lh_pad_hz,
oen_hl_pad_zl);
 (        IE  => C) = (ie_lh_c_lz,ie_lh_c_hz,ie_lh_c_lz,ie_hl_c_zh,ie_lh_c_hz,ie_hl_c_zl);
 (        PAD   +=> C) = (pad_lh_c_lh,pad_hl_c_hl);
 (        I   +=> PAD) = (i_lh_pad_lh,i_hl_pad_hl);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults



// ****** (C) Copyright 2011 SMIC  Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : picdrn.v
// Description          : Input Pad with Enable Controlled Pulldown
//
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PICDRN (PAD,IE,REN,C);

output  C;
input   PAD,IE,REN;

  supply0 my0;
  and        (C,PAD,IE);
  rpmos   #0.01 (PAD,my0,REN);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify
// Parameter declarations
 specparam pad_lh_c_lh=0,pad_hl_c_hl=0,
 ie_lh_c_lz=0,ie_hl_c_zh=0,ie_lh_c_hz=0,ie_hl_c_zl=0;
// Delays
 (        IE  => C) = (ie_lh_c_lz,ie_lh_c_hz,ie_lh_c_lz,ie_hl_c_zh,ie_lh_c_hz,ie_hl_c_zl);
 (        PAD   +=> C) = (pad_lh_c_lh,pad_hl_c_hl);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults



// ****** (C) Copyright 2011 SMIC  Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : picurn.v
// Description          : Input Pad with Enable Controlled Pullup
//
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PICURN (PAD,IE,REN,C);

output  C;
input   PAD,IE,REN;

  supply1 my1;
  and        (C,PAD,IE);
  rpmos   #0.01 (PAD,my1,REN);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify
// Parameter declarations
 specparam pad_lh_c_lh=0,pad_hl_c_hl=0,
 ie_lh_c_lz=0,ie_hl_c_zh=0,ie_lh_c_hz=0,ie_hl_c_zl=0;
// Delays
 (        IE  => C) = (ie_lh_c_lz,ie_lh_c_hz,ie_lh_c_lz,ie_hl_c_zh,ie_lh_c_hz,ie_hl_c_zl);
 (        PAD   +=> C) = (pad_lh_c_lh,pad_hl_c_hl);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults


// ****** (C) Copyright 2011 SMIC   Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pisrn.v
// Description          : Schmitt Trigger Input Pad
//
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PISRN (PAD,IE,C);

output  C;
input   PAD,IE;

and    #0.01 (C,PAD,IE);

`ifdef functional
`else
specify
// Parameter declarations
 specparam pad_lh_c_lh=0,pad_hl_c_hl=0,
 ie_lh_c_lz=0,ie_hl_c_zh=0,ie_lh_c_hz=0,ie_hl_c_zl=0;
// Delays
 (        IE  => C) = (ie_lh_c_lz,ie_lh_c_hz,ie_lh_c_lz,ie_hl_c_zh,ie_lh_c_hz,ie_hl_c_zl);
 (        PAD   +=> C) = (pad_lh_c_lh,pad_hl_c_hl);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults

// ****** (C) Copyright 2011 SMIC  Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pisdrn.v
// Description          : schmitt trigger input pad with pulldown
//
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PISDRN (PAD,IE,C);

output  C;
input   PAD,IE;

  supply0 my0;
  and        (C,PAD,IE);
  rpmos   #0.01 (PAD,my0,my0);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify
// Parameter declarations
 specparam pad_lh_c_lh=0,pad_hl_c_hl=0,
 ie_lh_c_lz=0,ie_hl_c_zh=0,ie_lh_c_hz=0,ie_hl_c_zl=0;
// Delays
 (        IE  => C) = (ie_lh_c_lz,ie_lh_c_hz,ie_lh_c_lz,ie_hl_c_zh,ie_lh_c_hz,ie_hl_c_zl);
 (        PAD   +=> C) = (pad_lh_c_lh,pad_hl_c_hl);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults

// ****** (C) Copyright 2011 SMIC  Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pisurn.v
// Description          : schmitt trigger input pad with pullup
//
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PISURN (PAD,IE,C);

output  C;
input   PAD,IE;

  supply1 my1;
  supply0 my0;
  and        (C,PAD,IE);
  rpmos   #0.01 (PAD,my1,my0);

   always @(PAD) begin
     if (PAD === 1'bx && !$test$plusargs("bus_conflict_off") &&
         $countdrivers(PAD))
        $display("%t --BUS CONFLICT-- : %m", $realtime);
   end

`ifdef functional
`else
specify
// Parameter declarations
 specparam pad_lh_c_lh=0,pad_hl_c_hl=0,
 ie_lh_c_lz=0,ie_hl_c_zh=0,ie_lh_c_hz=0,ie_hl_c_zl=0;
// Delays
 (        IE  => C) = (ie_lh_c_lz,ie_lh_c_hz,ie_lh_c_lz,ie_hl_c_zh,ie_lh_c_hz,ie_hl_c_zl);
 (        PAD   +=> C) = (pad_lh_c_lh,pad_hl_c_hl);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults


// ****** (C) Copyright 2011 SMIC   Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : px3rn.v
// Description          : Crystal oscillator with internal resistor 
//
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PX3RN (XIN,XOUT,XC);

output  XC;
input   XIN;
output  XOUT;

  not   (XOUT,XIN);
  buf   (XC  ,XIN);
`ifdef functional
`else
specify
// Parameter declarations
 specparam xin_lh_xout_hl=0,xin_hl_z_hl=0,xin_hl_xout_lh=0,xin_lh_z_lh=0;
// Delays
 (        XIN -=> XOUT) = (xin_hl_xout_lh,xin_lh_xout_hl);
 (        XIN +=> XC   ) = (xin_lh_z_lh,xin_hl_z_hl);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults
`timescale 1ns / 10ps


// ****** (C) Copyright 2011 SMIC   Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pxwe3rn.v
// Description          : Crystal oscillator with internal resistor and active high enable 
//
//
`celldefine
`suppress_faults
`enable_portfaults

`ifdef functional
 `timescale 1ns / 1ns
 `delay_mode_distributed
 `delay_mode_unit
`else
 `timescale 1ns / 10ps
 `delay_mode_path
`endif


module PXWE3RN (XIN,XOUT,XC,E);

output  XC;
input   XIN,E;
output   XOUT;

  nand           G2(XOUT,XIN,E);
  and            G5( XC ,XIN,E);

`ifdef functional
`else
specify
// Parameter declarations
 specparam e_lh_xc_lh_1=0,e_lh_xout_hxc=0,e_hl_xc_hl=0,
 e_hl_xout_xch=0,xin_lh_xout_hl=0,e_lh_xout_lxc=0,
 e_hl_xout_xcl=0,xin_hl_xc_hl=0,xin_hl_xout_lh=0,xin_lh_xc_lh=0;
// Delays
 (        E   => XOUT) = (e_lh_xout_lxc,e_lh_xout_hxc,e_lh_xout_lxc,e_hl_xout_xch,e_lh_xout_hxc,e_hl_xout_xcl);
 (        E  +=> XC   ) = (e_lh_xc_lh_1,e_hl_xc_hl);
 (        XIN -=> XOUT) = (xin_hl_xout_lh,xin_lh_xout_hl);
 (        XIN +=> XC   ) = (xin_lh_xc_lh,xin_hl_xc_hl);
endspecify
`endif

endmodule
`endcelldefine
`disable_portfaults
`nosuppress_faults
`timescale 1ns / 10ps


// ****** (C) Copyright 2011 SMIC   Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvdd1rn.v
// Description          : VDD Power Pad for I/O Pre-driver & Core
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVDD1RN (VDD);

   output VDD;
   pullup               G2(VDD);

   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine




// ****** (C) Copyright 2011 SMIC   Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvdd2rn.v
// Description          : VDD Power Pad for I/O Post-driver
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVDD2RN ();


   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine



// ****** (C) Copyright 2011 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvss1rn.v
// Description          : VSS Power Pad for I/O Pre-driver & Core
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVSS1RN (VSS);

   output VSS;
   pulldown             G2(VSS);

   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2011 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvss2rn.v
// Description          : VSS Power Pad for I/O Post-driver
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVSS2RN ();


   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2011 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvss3rn.v
// Description          : vss power pad for all(I/O pre-driver, post-driver &core) 
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVSS3RN (VSS);

   output VSS;
   pulldown             G2(VSS);

   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2011 SMIC   Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvdd1anprn.v
// Description          : VDD analog PAD within digital power domain 
// 
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVDD1ANPRN (SVDD1ANP);

   output SVDD1ANP;
   pullup               G2(SVDD1ANP);

   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2011 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvss1anprn.v
// Description          : VSS analog PAD within digital power domain 
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVSS1ANPRN (SVSS1ANP);

   output SVSS1ANP;
   pulldown             G2(SVSS1ANP);

   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2011 SMIC   Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvdd1canprn.v
// Description          : VDD analog PAD within digital power domain 
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVDD1CANPRN (SVDD1CANP);

   output SVDD1CANP;
   pullup               G2(SVDD1CANP);

   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2011 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvss1canprn.v
// Description          : VSS analog PAD within digital power domain 
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVSS1CANPRN (SVSS1CANP);

   output SVSS1CANP;
   pulldown             G2(SVSS1CANP);

   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine

// ****** (C) Copyright 2011 SMIC   Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pdiodern.v
// Description          : Power-Cut Cell for same voltage level between digital and analog 
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PDIODERN (VDD1,VDD2,VSS1,VSS2);

inout VDD1;
inout VDD2;
inout VSS1;
inout VSS2;

   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine

// ****** (C) Copyright 2011 SMIC   Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : p1diodern.v
// Description          : Power-Cut Cell for same voltage level between digital and analogbut it only includes two single diodes of opposite polarity connected in parallel 
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module P1DIODERN (VDD1,VDD2,VSS1,VSS2);

inout VDD1;
inout VDD2;
inout VSS1;
inout VSS2;

   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2011 SMIC   Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pdiode8rn.v
// Description          : Power-Cut Cell for High Voltage Drop for different voltage level between digital and analog 
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PDIODE8RN (VSS1,VSS2);

inout VSS1;
inout VSS2;

   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine

// ****** (C) Copyright 2011 SMIC   Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : p1diode8rn.v
// Description          : Power-Cut Cell for High Voltage Drop for difference voltage level between digital and analog, but it only includes two single diodes of opposite polarity connected in parallel 
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module P1DIODE8RN (VSS1,VSS2);

inout VSS1;
inout VSS2;

   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine

// ****** (C) Copyright 2011 SMIC   Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pdiode8srn.v
// Description          : Power-Cut Cell for High Voltage Drop for difference voltage level between digital and analog, but shorts ground 
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PDIODE8SRN ();

   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine

// ****** (C) Copyright 2011 SMIC   Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvdd1aprn.v
// Description          : VDD analog PAD (Not for 1.1V power/ground supplies which are connected to internal 1.1V circuitry)
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVDD1APRN (SVDD1AP);

   output SVDD1AP;
   pullup               G2(SVDD1AP);

   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2011 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvss1aprn.v
// Description          : VSS analog PAD (Not for 1.1V power/ground supplies which are connected to internal 1.1V circuitry)
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVSS1APRN (SVSS1AP);

   output SVSS1AP;
   pulldown             G2(SVSS1AP);

   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2011 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvdd3aprn.v
// Description          : VDD analog PAD (NOT for 1.1V power/ground supplies which are connected to internal 1.1V circuitry) 
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVDD3APRN (SAVDD);

   output SAVDD;
   pullup               G2(SAVDD);

   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2011 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvss3aprn.v
// Description          : VSS analog PAD (NOT for 1.1V power/ground supplies which are connected to internal 1.1V circuitry) 
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVSS3APRN (SAVSS);

   output SAVSS;
   pulldown             G2(SAVSS);

   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2011 SMIC   Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvdd1caprn.v
// Description          : VDD analog PAD (for 1.1V)
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVDD1CAPRN (SVDD1CAP);

   output SVDD1CAP;
   pullup               G2(SVDD1CAP);

   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2011 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvss1caprn.v
// Description          : VSS analog PAD (for 1.1V)
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVSS1CAPRN (SVSS1CAP);

   output SVSS1CAP;
   pulldown             G2(SVSS1CAP);

   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2011 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvdd3caprn.v
// Description          : VDD analog PAD (for 1.1V)
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVDD3CAPRN (SAVDD);

   output SAVDD;
   pullup               G2(SAVDD);

   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2011 SMIC Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvss3caprn.v
// Description          : VSS analog PAD (for 1.1V)
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVSS3CAPRN (SAVSS);

   output SAVSS;
   pulldown             G2(SAVSS);

   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2011 SMIC   Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pana1aprn.v
// Description          : Analog IO pad used with power-cut cell for low frequency application 
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PANA1APRN (PAD);
inout PAD;


   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine

// ****** (C) Copyright 2011 SMIC   Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pana1caprn.v
// Description          : Analog IO pad used with power-cut cell for low frequency application ( for 1.1V signal)
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PANA1CAPRN (PAD);
inout PAD;


   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2011 SMIC   Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pana1anprn.v
// Description          : Analog IO pad for low frequency aplication used within digital power domain
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PANA1ANPRN (PAD);
inout PAD;


   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine

// ****** (C) Copyright 2011 SMIC   Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pana1canprn.v
// Description          : Analog IO pad for high frequency aplication used within digital power domain
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PANA1CANPRN (PAD);
inout PAD;


   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2011 SMIC   Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvdd1cern.v
// Description          : One digital Vdd power cell for core ESD protection (without pad opening window)
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVDD1CERN (VDD);

   output VDD;
   pullup               G2(VDD);

   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine


// ****** (C) Copyright 2011 SMIC   Inc. ********
//  --    SMIC   Verilog Models
// **********************************************
//
// Model type           : zero timing
// Filename             : pvdd2cern.v
// Description          : One digital Vdd power cell for I/O ESD protection (without pad opening window)
//
//

`celldefine
`delay_mode_path
`suppress_faults
`enable_portfaults
`timescale 1 ns / 10 ps

module PVDD2CERN ();

   parameter ExtLoad = 50.0 ;

`ifdef NOTIMING
`else
   specify
      specparam cell_count    = 0.000000;
      specparam Transistors   = 0 ;

   endspecify
`endif

endmodule

`nosuppress_faults
`disable_portfaults
`endcelldefine



