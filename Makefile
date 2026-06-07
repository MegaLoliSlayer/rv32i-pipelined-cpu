SIM=tb_and_gate.vvp
WAVE=waves/and_gate.vcd

all:
	iverilog -g2012 -o $(SIM) rtl/and_gate.sv tb/tb_and_gate.sv
	vvp $(SIM)


wave: 
	gtkwave $(WAVE)


clean:
	rm -f *.vvp
	rm -f waves/*.vcd
