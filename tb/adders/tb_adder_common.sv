`timescale 1ns/1ps

`ifndef ADDER_MODULE
  `define ADDER_MODULE ripple_adder
`endif

`ifndef ADDER_NAME
  `define ADDER_NAME "unknown_adder"
`endif

module tb_adder_common;

reg [1023:0] vcd_file;
reg [255:0] adder_name;
//32-bit test signals
logic [31:0] a32;
logic [31:0] b32;
logic cin32;
logic [31:0] sum32;
logic cout32;
logic [32:0] expected32;

//16-bit test signals
logic [15:0] a16;
logic [15:0] b16;
logic cin16;
logic [15:0] sum16;
logic cout16;
logic [16:0] expected16;

//8-bit test signals
logic [7:0] a8;
logic [7:0] b8;
logic cin8;
logic [7:0] sum8;
logic cout8;
logic [8:0] expected8;

//4-bit test signals
logic [3:0] a4;
logic [3:0] b4;
logic cin4;
logic [3:0] sum4;
logic cout4;
logic [4:0] expected4;

//32-bit adder instantiation 
`ADDER_MODULE #(.WIDTH(32)) dut32(
  .a(a32),
  .b(b32),
  .cin(cin32),
  .sum(sum32),
  .cout(cout32)
);

//16-bit adder instantiation 
`ADDER_MODULE #(.WIDTH(16)) dut16(
  .a(a16),
  .b(b16),
  .cin(cin16),
  .sum(sum16),
  .cout(cout16)
);

//8-bit adder instantiation 
`ADDER_MODULE #(.WIDTH(8)) dut8(
  .a(a8),
  .b(b8),
  .cin(cin8),
  .sum(sum8),
  .cout(cout8)
);

//4-bit adder instantiation 
`ADDER_MODULE #(.WIDTH(4)) dut4(
  .a(a4),
  .b(b4),
  .cin(cin4),
  .sum(sum4),
  .cout(cout4)
);

//32-bit case check 
task check32;
  input logic [31:0] test_a;
  input logic [31:0] test_b;
  input logic test_cin;
begin
  a32 = test_a;
  b32 = test_b;
  cin32 = test_cin;

  expected32 = {1'b0, test_a} + {1'b0, test_b} + test_cin;
  #10;

  if ({cout32, sum32} !== expected32) begin
    $display("FAIL %s 32-bit: a=%h b=%h cin=%b cout=%b sum=%h expected=%h", `ADDER_NAME, a32, b32, cin32, cout32, sum32, expected32);
    $finish;
  end 
end
endtask

//16-bit case check 
task check16;
  input logic [15:0] test_a;
  input logic [15:0] test_b;
  input logic test_cin;
begin
  a16 = test_a;
  b16 = test_b;
  cin16 = test_cin;

  expected16 = {1'b0, test_a} + {1'b0, test_b} + test_cin;
  #10;

  if ({cout16, sum16} !== expected16) begin
    $display("FAIL %s 16-bit: a=%h b=%h cin=%b cout=%b sum=%h expected=%h", `ADDER_NAME, a16, b16, cin16, cout16, sum16, expected16);
    $finish;
  end 
end 
endtask 

//8-bit case check 
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

  if ({cout8, sum8} !== expected8) begin
    $display("FAIL %s 8-bit: a=%h b=%h cin=%b cout=%b sum=%h expected=%h", `ADDER_NAME, a8, b8, cin8, cout8, sum8, expected8);
    $finish;
  end 
end
endtask

//4-bit case check 
task check4;
  input logic [3:0] test_a;
  input logic [3:0] test_b;
  input logic test_cin;
begin
  a4 = test_a;
  b4 = test_b;
  cin4 = test_cin;

  expected4 = {1'b0, test_a} + {1'b0, test_b} + test_cin;
  #10;

  if ({cout4, sum4} !== expected4) begin
    $display("FAIL %s 4-bit: a=%h b=%h cin=%b cout=%b sum=%h expected=%h", `ADDER_NAME, a4, b4, cin4, cout4, sum4, expected4);
    $finish;
  end
end
endtask

integer i;

initial begin

  if (!$value$plusargs("VCD=%s", vcd_file)) begin
    vcd_file = "waves/adders/adder_common.vcd";
  end

  if (!$value$plusargs("ADDER=%s", adder_name)) begin
    adder_name = "unknown_adder";
  end

  $dumpfile(vcd_file);
  $dumpvars(0, tb_adder_common);

  $display("Starting common adder testbench for %0s.", adder_name);

  a32 = 32'd0;
  b32 = 32'd0;
  cin32 = 1'b0;

  a16 = 16'd0;
  b16 = 16'd0;
  cin16 = 1'b0;

  a8 = 8'd0;
  b8 = 8'd0;
  cin8 = 1'b0;

  a4 = 4'd0;
  b4 = 4'd0;
  cin4 = 1'b0;
  
  #10;

  // Fixed 32-bit tests
  check32(32'd0,          32'd0,          1'b0);
  check32(32'd1,          32'd1,          1'b0);
  check32(32'd10,         32'd20,         1'b0);
  check32(32'hFFFF_FFFF,  32'd1,          1'b0);
  check32(32'hFFFF_FFFF,  32'hFFFF_FFFF,  1'b0);
  check32(32'h1234_5678,  32'h1111_1111,  1'b0);
  check32(32'hAAAA_AAAA,  32'h5555_5555,  1'b1);
  check32(32'h8000_0000,  32'h8000_0000,  1'b0);
  check32(32'h7FFF_FFFF,  32'd1,          1'b0);

  // Fixed 16-bit tests
  check16(16'd0,      16'd0,      1'b0);
  check16(16'd1,      16'd1,      1'b0);
  check16(16'd10,     16'd20,     1'b0);
  check16(16'hFFFF,   16'd1,      1'b0);
  check16(16'hAAAA,   16'h5555,   1'b1);
  check16(16'h8000,   16'h8000,   1'b0);

  // Fixed 8-bit tests
  check8(8'd0,      8'd0,      1'b0);
  check8(8'd1,      8'd1,      1'b0);
  check8(8'd10,     8'd20,     1'b0);
  check8(8'hFF,     8'd1,      1'b0);
  check8(8'hAA,     8'h55,     1'b1);
  check8(8'h80,     8'h80,     1'b0);

  //Exhaustive 4-bit tests
  //check every possible combination for 4-bit test 
  for (i = 0; i < 512 ; i = i + 1 ) begin
    check4(i[3:0], i[7:4], i[8]);
  end

  // Random 32-bit tests
  for (i = 0; i < 100; i = i + 1) begin
    check32($urandom, $urandom, $urandom_range(0, 1));
  end

  // Random 16-bit tests
  for (i = 0; i < 100; i = i + 1) begin
    check16($urandom, $urandom, $urandom_range(0, 1));
  end

  // Random 8-bit tests
  for (i = 0; i < 100; i = i + 1) begin
    check8($urandom, $urandom, $urandom_range(0, 1));
  end 

  $display("All common adder tests passed for %0s.", adder_name);
  $finish;
end


endmodule





















