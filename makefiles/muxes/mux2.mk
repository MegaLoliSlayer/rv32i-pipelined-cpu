MUX2_SIM=mux2.vvp
MUX2_WAVE=waves/mux2.vcd

MUX2_SRC=rtl/muxes/mux2.sv
MUX2_TB=tb/muxes/tb_mux2.sv

mux2:
	iverilog -g2012 -o $(MUX2_SIM) $(MUX2_SRC) $(MUX2_TB)
	vvp $(MUX2_SIM)

mux2-wave:
	gtkwave $(MUX2_WAVE)

mux2-clean:
	rm -f $(MUX2_SIM)
	rm -f $(MUX2_WAVE)

