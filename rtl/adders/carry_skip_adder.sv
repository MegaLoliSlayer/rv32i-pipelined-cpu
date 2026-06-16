module carry_skip_adder #(
  parameter int WIDTH = 32,
  parameter int BLOCK_SIZE = 4 
  ) (
    input logic [WIDTH-1:0] a,
    input logic [WIDTH-1:0] b,
    input logic cin,
    output logic [WIDTH-1:0] sum,
    output logic cout 
  );

  localparam int NUM_BLOCKS = WIDTH/BLOCK_SIZE;
  logic [NUM_BLOCKS:0] block_carry;

  //Case check 
  initial begin
    if (WIDTH < BLOCK_SIZE) begin
      $fatal(1, "carry_skip_adder WIDTH must be >= BLOCK_SIZE.");
    end
    if (WIDTH % BLOCK_SIZE != 0) begin
      $fatal(1, "carry_skip_adder WIDTH must be a multiple of BLOCK_SIZE.");
    end
  end

  assign block_carry[0] = cin;
  assign cout = block_carry[NUM_BLOCKS];

  genvar blk;
  genvar bit_idx;

  //logic of carry_skip_adder
  generate
    //iterates through all the blocks 
    for (blk = 0; blk < NUM_BLOCKS; blk = blk + 1) begin: gen_blocks
      //carry signals winthin each block 
      logic [BLOCK_SIZE:0] local_carry;
      //propagate signals within each block 
      logic [BLOCK_SIZE-1:0] propagate;
      //initial assignment, assign the current block carry in to bit 0 of
      //local_carry(which will be used as carry in for that block)
      assign local_carry[0] = block_carry[blk];

      //iterates through all the bits within each block 
      for (bit_idx = 0; bit_idx < BLOCK_SIZE; bit_idx = bit_idx + 1) begin: gen_bits
        //bit index within the block(0+BLOCK_SIZE*block index, 1..., 2..., 3..., 4...)
        localparam int IDX = blk * BLOCK_SIZE + bit_idx;
        //determine whether the current bit will pass the input carry to the
        //next bit
        assign propagate[bit_idx] = a[IDX] ^ b[IDX];

        //full_adder still calculate the sum like ripple_adder
        full_adder u_full_adder(
          .a(a[IDX]),
          .b(b[IDX]),
          .cin(local_carry[bit_idx]),
          .sum(sum[IDX]),
          .cout(local_carry[bit_idx + 1])
        );
      end 

      //skip logic
      //&propagate means(propagate[0] & propagate[1] & propagate[2]
      //& propagate[3])
      //if &propagate = 1 meaning the entire block will pass the incoming
      //carry straight through then block_carry[blk+1] = block_carry[blk]
      //meaning carry into this block skips directly to the next block
      //so that we dont need to wait for local_carry[1] local_carry[2] ...
      //local_carry[4]
      //if &propagate = 0, we use the normal ripple result from inside the
      //block 
      //which means this adder cannot safely skip, it behaves like a normal
      //ripple adder for that block
      assign block_carry[blk+1] = (&propagate) ? block_carry[blk] : local_carry[BLOCK_SIZE];

    end 
  endgenerate

  endmodule
