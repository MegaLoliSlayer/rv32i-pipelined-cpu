RIPPLE_SIM=ripple_adder.vvp
RIPPLE_WAVE=waves/ripple_adder.vcd

RIPPLE_SRC=rtl/adders/full_adder.sv rtl/adders/ripple_adder.sv
RIPPLE_TB=tb/adders/tb_ripple_adder.sv

ripple:
	iverilog -g2012 -o $(RIPPLE_SIM) $(RIPPLE_SRC) $(RIPPLE_TB)
	vvp $(RIPPLE_SIM)

ripple-wave:
	gtkwave $(RIPPLE_WAVE)

ripple-clean:
	rm -f $(RIPPLE_SIM)
	rm -f $(RIPPLE_WAVE)


