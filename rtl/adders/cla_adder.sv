//this module builds a larger adder using many cla4_block modules
//ex. if WIDTH = 32, then 32/4 = 8 blocks of cla4_block are cascaded to make
//32 bit cla_adder

module cla_adder #(parameter int WIDTH = 32) (
  input logic [WIDTH-1:0] a,
  input logic [WIDTH-1:0] b,
  input logic cin,
  output logic [WIDTH-1:0] sum,
  output logic cout 
  );

//cla4_block size(4 bit)
localparam int BLOCK_SIZE = 4;
//number of cla4_block needed
localparam int NUM_BLOCKS = WIDTH / BLOCK_SIZE;

//carry signals between 4bit blocks
logic [NUM_BLOCKS:0] block_carry;
//one group propagate signal per block 
logic [NUM_BLOCKS-1:0] group_p;
//one group generate signal per block 
logic [NUM_BLOCKS-1:0] group_g;

initial begin
  //if the WIDTH set is smaller than 4 bit, display fatal error message and
  //exit
  if (WIDTH < 4) begin
    $fatal(1, "CLA adder WIDTH must be at least 4.");
  end

  //if the WIDTH set is not a multiple of 4, display fatal error message and
  //exit
  if (WIDTH % 4 != 0) begin
    $fatal(1, "CLA adder WIDTH must be a multiple of 4");
  end

end

//connect the first block carry to the input carry
assign block_carry[0] = cin;
//connects the final block carry to the module output cout 
assign cout = block_carry[NUM_BLOCKS];

genvar i;

generate 
  //generate loop used to creaate one 4-bit CLA block for each block of the
  //full adder
  //for WIDTH = 32, it creaates 8 4-bit CLA block, each one handles 4 bit 
  for(i = 0; i < NUM_BLOCKS; i = i + 1) begin: gen_cla4_blocks
    //instantiate one cla4_block(instance named block)
    //a[(4*i +: 4)] means start at bit 4*i, take 4 bit upward
    //ex: when i = 0 a[(4*0 +: 4)] = a[0 +: 4] = a[3:0]
    //then assign this 4 bit to input a of cla4_block
    //same as input b, whereas this 4 bit of cla4_block sum is returned to the
    //sum of the full adder
    //.cin(block_carry[i]) connects the carry-in of the current 4-bit block
    //.cout() is unconnected since at the top level, we are calculating block
    //carries using group_g[i] | (group_p[i] & block_carry[i])
    //.group_p(group_p[i]) connects the block's group propagate output to the
    //top-level group_p array
    //.group_g(group_g[i]) connects the block's group generate output to the
    //top-level group_g array
    cla4_block block (
      .a(a[(4*i) +: 4]),
      .b(b[(4*i) +: 4]),
      .cin(block_carry[i]),
      .sum(sum[(4*i) +: 4]),
      .cout(),
      .group_p(group_p[i]),
      .group_g(group_g[i])
      );

      //calculate the carry going into the next 4 bit block  
      //next block carry = current block generates carry or current block
      //propagates incoming carry
      assign block_carry[i+1] = group_g[i] | (group_p[i] & block_carry[i]);
  end       
endgenerate

endmodule

