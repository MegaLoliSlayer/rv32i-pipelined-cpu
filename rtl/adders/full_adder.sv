//1 bit full adder module
module full_adder(
	input logic a,
	input logic b,
	input logic cin,
	output logic sum,
	output logic cout
);

//sum = a XOR b XOR cin
assign sum = a ^ b ^ cin;

//cout = (a AND b) OR (a AND cin) OR (b AND cin)
assign cout = (a & b) | (a & cin) | (b & cin);

endmodule
