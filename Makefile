include makefiles/and_gate.mk
include makefiles/mux2.mk
include makefiles/full_adder.mk

.PHONY: all clean and and-wave and-clean mux2 mux2-wave mux2-clean full-adder full-adder-wave full-adder-clean

all: and mux2 full-adder

clean: 
	rm -f *.vvp
	rm -f waves/*.vcd
