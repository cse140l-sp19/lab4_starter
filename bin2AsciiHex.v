//
// bin2AsciiHex
// convert bin to 0-9a-f ascii
// bryan chin - derivation in cse140l sp 2019 - week 7 lecture
//
module bin2AsciiHex (
		  output wire [7:0] asciiHex,
		  input       [3:0] hx
		  );

   wire 			    lowerTen;
   assign lowerTen = ~hx[3]  | ~hx[2] & ~hx[1];

   assign asciiHex = lowerTen ? 
		  {4'h3, hx[3:0]} :
		  {4'h6, 1'b0,
                   ~hx[1] & hx[0] | hx[2] & hx[1],
                   ~hx[1] & ~hx[0] | hx[1] & hx[0],
                   ~hx[0]};
endmodule // hex2ascii


//
//
//module bin2AsciiHex (
//		  output reg [7:0] asciiHex,
//		  input [3:0]  inVal);
//
//   always @(*) begin
//      casex (inVal)
//	4'ha : asciiHex = 8'h61;
//	4'hb : asciiHex = 8'h62;
//	4'hc : asciiHex = 8'h63;
//	4'hd : asciiHex = 8'h64;
//	4'he : asciiHex = 8'h65;
//	4'hf : asciiHex = 8'h66;
//	default : asciiHex = {4'h3, inVal};
//    endcase // casex (inVal)
//   end // always @ (*)
//endmodule
