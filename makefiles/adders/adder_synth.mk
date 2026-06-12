YOSYS   ?= yosys
OPENSTA ?= sta

WIDTH ?= 32

LIBERTY ?= libs/asic/nangate45/NangateOpenCellLibrary_typical.lib

SYNTH_BUILD_DIR   := build/synth/adders
SYNTH_REPORT_DIR  := reports/adders
TIMING_REPORT_DIR := reports/timing/adders

OPENSTA_ADDER_SCRIPT := scripts/opensta_adder.tcl

RIPPLE_SYNTH_SRCS := \
	rtl/adders/full_adder.sv \
	rtl/adders/ripple_adder.sv

CLA_SYNTH_SRCS := \
	rtl/adders/cla4_block.sv \
	rtl/adders/cla_adder.sv

.PHONY: synth-ripple synth-cla \
	timing-ripple timing-cla \
	synth-clean timing-clean

$(SYNTH_BUILD_DIR):
	mkdir -p $(SYNTH_BUILD_DIR)

$(SYNTH_REPORT_DIR):
	mkdir -p $(SYNTH_REPORT_DIR)

$(TIMING_REPORT_DIR):
	mkdir -p $(TIMING_REPORT_DIR)

synth-ripple: $(SYNTH_BUILD_DIR) $(SYNTH_REPORT_DIR)
	$(YOSYS) -l $(SYNTH_REPORT_DIR)/ripple_adder.rpt -p "\
		read_verilog -sv $(RIPPLE_SYNTH_SRCS); \
		chparam -set WIDTH $(WIDTH) ripple_adder; \
		hierarchy -top ripple_adder; \
		flatten; \
		proc; \
		opt; \
		techmap; \
		opt; \
		abc -liberty $(LIBERTY); \
		clean; \
		stat -liberty $(LIBERTY); \
		write_verilog -noattr $(SYNTH_BUILD_DIR)/ripple_adder_mapped.v"

synth-cla: $(SYNTH_BUILD_DIR) $(SYNTH_REPORT_DIR)
	$(YOSYS) -l $(SYNTH_REPORT_DIR)/cla_adder.rpt -p "\
		read_verilog -sv $(CLA_SYNTH_SRCS); \
		chparam -set WIDTH $(WIDTH) cla_adder; \
		hierarchy -top cla_adder; \
		flatten; \
		proc; \
		opt; \
		techmap; \
		opt; \
		abc -liberty $(LIBERTY); \
		clean; \
		stat -liberty $(LIBERTY); \
		write_verilog -noattr $(SYNTH_BUILD_DIR)/cla_adder_mapped.v"

timing-ripple: synth-ripple $(TIMING_REPORT_DIR)
	LIBERTY=$(LIBERTY) \
	NETLIST=$(SYNTH_BUILD_DIR)/ripple_adder_mapped.v \
	TOP=ripple_adder \
	$(OPENSTA) -exit $(OPENSTA_ADDER_SCRIPT) \
	> $(TIMING_REPORT_DIR)/ripple_adder_timing.rpt 2>&1

timing-cla: synth-cla $(TIMING_REPORT_DIR)
	LIBERTY=$(LIBERTY) \
	NETLIST=$(SYNTH_BUILD_DIR)/cla_adder_mapped.v \
	TOP=cla_adder \
	$(OPENSTA) -exit $(OPENSTA_ADDER_SCRIPT) \
	> $(TIMING_REPORT_DIR)/cla_adder_timing.rpt 2>&1

synth-clean:
	rm -f $(SYNTH_REPORT_DIR)/*.rpt
	rm -f $(SYNTH_BUILD_DIR)/*.v

timing-clean:
	rm -f $(TIMING_REPORT_DIR)/*.rpt
