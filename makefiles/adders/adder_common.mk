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

CARRY_SKIP_SRCS := \
	rtl/adders/full_adder.sv \
	rtl/adders/carry_skip_adder.sv

.PHONY: test-adders test-ripple test-cla test-carry-skip\
	wave-adder \
	adder-clean

test-adders: test-ripple test-cla test-carry-skip

$(ADDER_BUILD_DIR):
	mkdir -p $(ADDER_BUILD_DIR)

$(ADDER_WAVE_DIR):
	mkdir -p $(ADDER_WAVE_DIR)

test-ripple: $(ADDER_BUILD_DIR) $(ADDER_WAVE_DIR)
	$(IVERILOG) -g2012 \
		-DADDER_MODULE=ripple_adder \
		-o $(ADDER_BUILD_DIR)/ripple_adder.vvp \
		$(RIPPLE_SRCS) \
		$(COMMON_ADDER_TB)
	$(VVP) $(ADDER_BUILD_DIR)/ripple_adder.vvp \
		+ADDER=ripple_adder \
		+VCD=$(ADDER_WAVE_DIR)/ripple_adder.vcd

test-cla: $(ADDER_BUILD_DIR) $(ADDER_WAVE_DIR)
	$(IVERILOG) -g2012 \
		-DADDER_MODULE=cla_adder \
		-o $(ADDER_BUILD_DIR)/cla_adder.vvp \
		$(CLA_SRCS) \
		$(COMMON_ADDER_TB)
	$(VVP) $(ADDER_BUILD_DIR)/cla_adder.vvp \
		+ADDER=cla_adder \
		+VCD=$(ADDER_WAVE_DIR)/cla_adder.vcd

test-carry-skip: $(ADDER_BUILD_DIR) $(ADDER_WAVE_DIR)
	$(IVERILOG) -g2012 \
		-DADDER_MODULE=carry_skip_adder \
		-o $(ADDER_BUILD_DIR)/carry_skip_adder.vvp \
		$(CARRY_SKIP_SRCS) \
		$(COMMON_ADDER_TB)
	$(VVP) $(ADDER_BUILD_DIR)/carry_skip_adder.vvp \
		+ADDER=carry_skip_adder \
		+VCD=$(ADDER_WAVE_DIR)/carry_skip_adder.vcd

wave-adder:
	@if [ "$(ADDER)" = "ripple" ]; then \
		$(GTKWAVE) $(ADDER_WAVE_DIR)/ripple_adder.vcd; \
	elif [ "$(ADDER)" = "cla" ]; then \
		$(GTKWAVE) $(ADDER_WAVE_DIR)/cla_adder.vcd; \
	elif [ "$(ADDER)" = "carry-skip" ]; then \
	  $(GTKWAVE) $(ADDER_WAVE_DIR)/carry_skip_adder.vcd; \
	else \
		echo "Usage:"; \
		echo "  make wave ADDER=ripple"; \
		echo "  make wave ADDER=cla"; \
		exit 1; \
	fi

adder-clean:
	rm -f $(ADDER_BUILD_DIR)/*.vvp
	rm -f $(ADDER_WAVE_DIR)/*.vcd
