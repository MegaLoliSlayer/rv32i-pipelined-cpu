AND_SIM=and_gate.vvp
AND_WAVE=waves/and_gate.vcd

AND_SRC=rtl/and_gate.sv
AND_TB=tb/tb_and_gate.sv

and:
	iverilog -g2012 -o $(AND_SIM) $(AND_SRC) $(AND_TB)
	vvp $(AND_SIM)

and-wave:
	gtkwave $(AND_WAVE)

and-clean:
	rm -f $(AND_SIM)
	rm -f $(AND_WAVE)


