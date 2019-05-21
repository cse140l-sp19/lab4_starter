//
// printable
//
// output a printable char (0x20 - 0x7e) or
// output a "#" sign
//
module printable(
		 output [7:0] pChar,  // printable char 
		 output       pValid, // valid printable char
		 input [7:0]  inByte
		 );

   assign pValid = ~inByte[7] & ~inByte[6] & inByte[5]   |    // 0x2_, 0x3_
		   ~inByte[7] & inByte[6]  & 
		   ~(inByte[5] & inByte[4] & inByte[3] &
		     inByte[2] & inByte[1] & inByte[0]); // 0x4_, 0x5_, 0x6_, x7_ except 0x7f);
   assign pChar = pValid ? inByte : "#";
endmodule // printable

   
		   



			
