IVERILOG ?= iverilog
VVP      ?= vvp
GTKWAVE  ?= gtkwave

ADDER_BUILD_DIR := build/adders
ADDER_WAVE_DIR  := waves/adders

COMMON_ADDER_TB := tb/adders/tb_adder_common.sv

RIPPLE_SRCS := \
	rtl/adders/full_adder.sv \
	rtl/adders/ripple_adder.sv

CLA_SRCS := \
	rtl/adders/cla4_block.sv \
	rtl/adders/cla_adder.sv

.PHONY: adders \
	ripple ripple-wave ripple-clean \
	cla cla-wave cla-clean \
	test-ripple test-cla \
	adder-clean

adders: ripple cla

$(ADDER_BUILD_DIR):
	mkdir -p $(ADDER_BUILD_DIR)

$(ADDER_WAVE_DIR):
	mkdir -p $(ADDER_WAVE_DIR)

ripple: $(ADDER_BUILD_DIR) $(ADDER_WAVE_DIR)
	$(IVERILOG) -g2012 \
		-DADDER_MODULE=ripple_adder \
		-o $(ADDER_BUILD_DIR)/ripple_adder.vvp \
		$(RIPPLE_SRCS) \
		$(COMMON_ADDER_TB)
	$(VVP) $(ADDER_BUILD_DIR)/ripple_adder.vvp \
		+ADDER=ripple_adder \
		+VCD=$(ADDER_WAVE_DIR)/ripple_adder.vcd

cla: $(ADDER_BUILD_DIR) $(ADDER_WAVE_DIR)
	$(IVERILOG) -g2012 \
		-DADDER_MODULE=cla_adder \
		-o $(ADDER_BUILD_DIR)/cla_adder.vvp \
		$(CLA_SRCS) \
		$(COMMON_ADDER_TB)
	$(VVP) $(ADDER_BUILD_DIR)/cla_adder.vvp \
		+ADDER=cla_adder \
		+VCD=$(ADDER_WAVE_DIR)/cla_adder.vcd

ripple-wave:
	$(GTKWAVE) $(ADDER_WAVE_DIR)/ripple_adder.vcd

cla-wave:
	$(GTKWAVE) $(ADDER_WAVE_DIR)/cla_adder.vcd

ripple-clean:
	rm -f $(ADDER_BUILD_DIR)/ripple_adder.vvp
	rm -f $(ADDER_WAVE_DIR)/ripple_adder.vcd

cla-clean:
	rm -f $(ADDER_BUILD_DIR)/cla_adder.vvp
	rm -f $(ADDER_WAVE_DIR)/cla_adder.vcd

adder-clean:
	rm -f $(ADDER_BUILD_DIR)/*.vvp
	rm -f $(ADDER_WAVE_DIR)/*.vcd

# Backward-compatible names
test-ripple: ripple
test-cla: cla
