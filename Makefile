include makefiles/basic_gates/and_gate.mk
include makefiles/muxes/mux2.mk
include makefiles/adders/full_adder.mk
include makefiles/adders/ripple_adder.mk

.PHONY: all clean and and-wave and-clean mux2 mux2-wave mux2-clean full-adder full-adder-wave full-adder-clean ripple ripple-wave ripple-clean

all: and mux2 full-adder ripple

clean: 
	rm -f *.vpp
	rm -f waves/*.vcd
