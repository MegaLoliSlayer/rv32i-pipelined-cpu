`timescale 1ns/1ps

module tb_ripple_adder;

//32 bit adder testbench signals
logic [31:0] a32;
logic [31:0] b32;
logic cin32;
logic [31:0] sum32;
logic cout32;
logic [32:0] expected32;

//8 bit adder testbench signals
logic [7:0] a8;
logic [7:0] b8;
logic cin8;
logic [7:0] sum8;
logic cout8;
logic [8:0] expected8;

//Instatiate 32 bit ripple adder
ripple_adder #(.WIDTH(32)) dut32 (
	.a(a32),
	.b(b32),
	.cin(cin32),
	.sum(sum32),
	.cout(cout32)
);

//Instantiate 8 bit ripple adder
ripple_adder #(.WIDTH(8)) dut8 (
	.a(a8),
	.b(b8),
	.cin(cin8),
	.sum(sum8),
	.cout(cout8)
);

//start a reusable test task for the 32-bit adder
task check32;
	input logic [31:0] test_a;
	input logic [31:0] test_b;
	input logic test_cin;
        begin 
	  //drive the 32 bit addeer inputs
	  a32 = test_a;
	  b32 = test_b;
	  cin32 = test_cin;

	  //calculate the correct expected result
	  //{1'b0, test_a} concatenates a leading 0 with test_a
	  //{1'b0, test_b} concaatenates a leading 0 with test_b 
	  //we are using 33 bit here so that the overflow carry can be kept
	  expected32 = {1'b0, test_a} + {1'b0, test_b} + test_cin;

	  #10;

	  if ({cout32, sum32} !== expected32) begin
		  $display("FAIL 32-bit: a=%h b=%h cin=%b cout=%b sum=%h expected=%h", a32, b32, cin32, cout32, sum32, expected32);
		  $finish;
	  end
	end
endtask

//start a reusable test task for the 8bit adder
task check8;
	input logic [7:0] test_a;
	input logic [7:0] test_b;
	input logic test_cin;
        begin
	  a8 = test_a;
	  b8 = test_b;
	  cin8 = test_cin;

	  expected8 = {1'b0, test_a} + {1'b0, test_b} + test_cin;

	  #10;
	  if ({cout8, sum8}!==expected8) begin
		  $display("FAIL 8-bit: a=%h b=%h cin=%b cout=%b sum=%h expected=%h", a8, b8, cin8, cout8, sum8, expected8);
		  $finish;
	  end
	end
endtask

initial begin
	$dumpfile("waves/ripple_adder.vcd");
	$dumpvars(0, tb_ripple_adder);

	//check 32 bit case
	check32(32'd0, 32'd0, 1'b0);
	check32(32'd1, 32'd1, 1'b0);
	check32(32'd10, 32'd20, 1'b0);
	check32(32'hFFFF_FFFF, 32'd1, 1'b0);
	check32(32'hFFFF_FFFF, 32'hFFFF_FFFF, 1'b0);
	check32(32'h1234_5678, 32'h1111_1111, 1'b0);
	check32(32'hAAAA_AAAA, 32'h5555_5555, 1'b1);
	check32(32'h8000_0000, 32'h8000_0000, 1'b0);

	//check 8 bit case
	check8(8'd0, 8'd0, 1'b0);
	check8(8'd1, 8'd1, 1'b0);
	check8(8'd10, 8'd20, 1'b0);
	check8(8'hFF, 8'd1, 1'b0);
	check8(8'hAA, 8'h55, 1'b1);
	check8(8'h80, 8'h80, 1'b0);

	$display("ALL parameterized ripple adder tests passsed");
	$finish;

end
endmodule
