include makefiles/basic_gates/and_gate.mk
include makefiles/muxes/mux2.mk
include makefiles/adders/adder_common.mk

.PHONY: all clean \
	and and-wave and-clean \
	mux2 mux2-wave mux2-clean \
	adders \
	ripple ripple-wave ripple-clean \
	cla cla-wave cla-clean \
	test-ripple test-cla \
	adder-clean

all: and mux2 adders

clean:
	rm -f *.vvp
	rm -f build/adders/*.vvp
	rm -f waves/*.vcd
	rm -f waves/adders/*.vcd
