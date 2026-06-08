include makefiles/and_gate.mk
include makefiles/mux2.mk

.PHONY: all clean and and-wave and-clean mux2 mux2-wave mux2-clean

all: and mux2

clean: 
	rm -f *.vvp
	rm -f waves/*.vcd
