include makefiles/basic_gates/and_gate.mk
include makefiles/muxes/mux2.mk
include makefiles/adders/adder_common.mk
include makefiles/adders/adder_synth.mk

.DEFAULT_GOAL := help 

.PHONY: help all \
	      test test-ripple test-cla \
				synth synth-ripple synth-cla \
				timing timing-ripple timing-cla \
				compare wave \
				clean distclean

all: test

help:
	@echo "RV32I pipelined CPU project"
	@echo
	@echo "Simulation:"
	@echo "  make test                   Run all simulation tests"
	@echo "  make test-ripple            Run ripple adder simulation"
	@echo "  make test-cla               Run CLA adder simulation"
	@echo "  make test-carry-skip        Run carry-skip adder simulation"
	@echo
	@echo "Synthesis:"
	@echo "  make synth                  Synthesize all adders"
	@echo "  make synth-ripple           Synthesize ripple adder"
	@echo "  make synth-cla              Synthesize CLA adder"
	@echo "  make synth-carry-skip       Synthesize carry-skip adder"
	@echo
	@echo "Timing:"
	@echo "  make timing                 Run timing for all adders"
	@echo "  make timing-ripple          Run timing for ripple adder"
	@echo "  make timing-cla             Run timing for CLA adder"
	@echo "  make timing-carry-skip      Run timing for carry-skip adder"
	@echo
	@echo "Comparison:"
	@echo "  make compare                Run synth, timing, and comparison table"
	@echo
	@echo "Waveforms:"
	@echo "  make wave ADDER=ripple      Open ripple adder waveform"
	@echo "  make wave ADDER=cla         Open CLA adder waveform"
	@echo "  make wave ADDER=carry-skip  Open carry-skip adder wave form"
	@echo
	@echo "Cleanup:"
	@echo "  make clean                  Remove generated files"
	@echo "  make distclean              Remove generated directories"
	@echo
	@echo "Useful variables:"
	@echo "  WIDTH=32                    Adder width used for synthesis"
	@echo "  LIBERTY=path/to.lib         Liberty timing library"

test: and mux2 test-adders

synth: synth-ripple synth-cla synth-carry-skip

timing: timing-ripple timing-cla timing-carry-skip

compare: timing
	./scripts/compare_adders.sh

wave: wave-adder

clean: and-clean mux2-clean adder-clean synth-clean timing-clean
	rm -f abc.history
	rm -f *.history
	rm -f reports/adders/adder_comparison.csv

distclean: clean
	rm -rf build
	rm -rf waves
	rm -rf reports




