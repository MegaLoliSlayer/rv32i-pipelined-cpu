//Ripple adder module
module ripple_adder #(parameter int WIDTH = 32)(
	input logic [WIDTH-1:0] a,
	input logic [WIDTH-1:0] b,
	input logic cin,
	output logic [WIDTH-1:0] sum,
	output logic cout
);

//internal carry signal for carry propagation within full adders
logic [WIDTH:0] carry;

//the first carry is carry in
assign carry[0] = cin;
//the last carry is carry out
assign cout = carry[WIDTH];

//declare generate variable named i
genvar i;

//starts a generation block
generate
  //starts a generate for loop
  //map input and output signals to the 1 bit full adder and compute
  for (i = 0; i < WIDTH; i = i + 1) begin: gen_full_adders
	  full_adder fa(
		  .a(a[i]),
		  .b(b[i]),
		  .cin(carry[i]),
		  .sum(sum[i]),
		  .cout(carry[i+1])
          );
  end
endgenerate

endmodule
