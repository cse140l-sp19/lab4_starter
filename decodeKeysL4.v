
// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Copyright (c) 2019 by UCSD CSE 140L
// --------------------------------------------------------------------
//
// Permission:
//
//   This code for use in UCSD CSE 140L.
//   It is synthesisable for Lattice iCEstick 40HX.  
//
// Disclaimer:
//
//   This Verilog source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  
//
// -------------------------------------------------------------------- //           
//                     Lih-Feng Tsaur
//                     Bryan Chin
//                     UCSD CSE Department
//                     9500 Gilman Dr, La Jolla, CA 92093
//                     U.S.A
//
// --------------------------------------------------------------------
//
//
//  decodeKeys
//
// decode the 8 bit ascii input charData when
// charDataValid is asserted.
//
module decodeKeysL4(
		    output wire      de_esc,          // esc key
		    output wire      de_validAscii,   // valid ascii 0x20 to 0x7e
		    output wire      de_bigD,         // "D"
		    output wire      de_bigE,         // "E"
		    output wire      de_bigL,         // "L"
		    output wire      de_bigP,         // "P"
		    output wire      de_bigS,         // "S"
		    output wire      de_hex,          // 0-9a-f
		    output wire      de_cr,           // carriage return

		    input wire [7:0] charData,
		    input wire 	     charDataValid
		  );


   wire 		      is_b0_1 = charData[0];
   wire 		      is_b1_1 = charData[1];
   wire 		      is_b2_1 = charData[2];
   wire 		      is_b3_1 = charData[3];
   wire 		      is_b4_1 = charData[4];
   wire 		      is_b5_1 = charData[5];
   wire 		      is_b6_1 = charData[6];
   wire 		      is_b7_1 = charData[7];
   wire 		      is_b0_0 = ~charData[0];
   wire 		      is_b1_0 = ~charData[1];
   wire 		      is_b2_0 = ~charData[2];
   wire 		      is_b3_0 = ~charData[3];
   wire 		      is_b4_0 = ~charData[4];
   wire 		      is_b5_0 = ~charData[5];
   wire 		      is_b6_0 = ~charData[6];
   wire 		      is_b7_0 = ~charData[7];
   

   // esc - 1b
   assign de_esc = &{is_b7_0, is_b6_0, is_b5_0, is_b4_1,
                     is_b3_1, is_b2_0, is_b1_1, is_b0_1} & charDataValid;

   // validAscii >=0x20 <=7e.
   assign de_validAscii =
			&{is_b7_0, is_b6_0, is_b5_1}& charDataValid | // 0x2x 0x3x
			// 0x4x, 0x5x, 0x6x, 0x7x except 0x7f
			&{is_b7_0, is_b6_1} & ~(is_b5_1 & is_b4_1 & is_b3_1 & is_b2_1 & is_b1_1 & is_b0_1)
			  & charDataValid;
   // "D" = 0x44
   assign de_bigD = &{is_b7_0, is_b6_1, is_b5_0, is_b4_0, is_b3_0, is_b2_1, is_b1_0, is_b0_0} & 
		    charDataValid;
   // "E" = 0x45
   assign de_bigE = &{is_b7_0, is_b6_1, is_b5_0, is_b4_0, is_b3_0, is_b2_1, is_b1_0, is_b0_1} & 
		    charDataValid;
   // "L" = 0x4C
   assign de_bigL = &{is_b7_0, is_b6_1, is_b5_0, is_b4_0, is_b3_1, is_b2_1, is_b1_0, is_b0_0} & 
		    charDataValid;
   // "P" = 0x50
   assign de_bigP = &{is_b7_0, is_b6_1, is_b5_0, is_b4_1, is_b3_0, is_b2_0, is_b1_0, is_b0_0} & 
		    charDataValid;
   // "S" = 0x53
   assign de_bigS = &{is_b7_0, is_b6_1, is_b5_0, is_b4_1, is_b3_0, is_b2_0, is_b1_1, is_b0_1} & 
		    charDataValid;

   // valid hex  (0x30-0x39, 0x61-0x66)
   assign de_hex = &{is_b7_0, is_b6_0, is_b5_1, is_b4_1} & charDataValid |
		   &{is_b7_0, is_b6_1, is_b5_1, is_b4_0} &
		   (&{is_b3_0, is_b2_1, is_b1_0} | &{is_b3_0, is_b2_0, is_b0_1} |
		    &{is_b3_0, is_b1_1, is_b0_0}) & charDataValid;
   // "cr" = 0xd
   assign de_cr = &{is_b7_0, is_b6_0, is_b5_0, is_b4_0, is_b3_1, is_b2_1, is_b1_0, is_b0_1} & 
		  charDataValid;

   
endmodule
