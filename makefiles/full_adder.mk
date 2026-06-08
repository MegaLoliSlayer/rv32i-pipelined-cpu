FULL_ADDER_SIM=full_adder.vvp
FULL_ADDER_WAVE=waves/full_adder.vcd

FULL_ADDER_SRC=rtl/full_adder.sv
FULL_ADDER_TB=tb/tb_full_adder.sv

full-adder:
	iverilog -g2012 -o $(FULL_ADDER_SIM) $(FULL_ADDER_SRC) $(FULL_ADDER_TB)
	vvp $(FULL_ADDER_SIM)

full-adder-wave:
	gtkwave $(FULL_ADDER_WAVE)

full-adder-clean:
	rm -f $(FULL_ADDER_SIM)
	rm -f $(FULL_ADDER_WAVE)

