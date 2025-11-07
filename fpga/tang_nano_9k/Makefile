# Makefile for Tang Nano 9K FPGA build
# Requires Gowin EDA installed and in PATH

PROJECT = driving_it_2025
TOP_MODULE = tang_nano_9k_top
DEVICE = GW1NR-LV9QN88PC6/I5
FAMILY = GW1NR-9C

# Source files
VERILOG_SOURCES = \
	src/tang_nano_9k_top.v \
	src/hdmi_output.v \
	src/tmds_encoder.v \
	src/gowin_rpll.v \
	../../src/project.v \
	../../src/hvsync_generator.v \
	../../src/char_rom.v

CONSTRAINTS = constraints/tang_nano_9k.cst

# Gowin tool paths (adjust if needed)
GOWINHOME ?= /opt/gowin
GOWIN = $(GOWINHOME)/IDE/bin/gw_sh

.PHONY: all clean program

all: $(PROJECT).fs

# Synthesis and Place & Route
$(PROJECT).fs: $(VERILOG_SOURCES) $(CONSTRAINTS) $(PROJECT).gprj
	@echo "Building FPGA bitstream..."
	$(GOWIN) $(PROJECT).gprj

# Program the FPGA
program: $(PROJECT).fs
	@echo "Programming Tang Nano 9K..."
	openFPGALoader -b tangnano9k $(PROJECT).fs

# Clean build artifacts
clean:
	rm -rf impl/
	rm -f *.fs *.rpt

help:
	@echo "Tang Nano 9K FPGA Build"
	@echo ""
	@echo "Targets:"
	@echo "  all       - Build the FPGA bitstream"
	@echo "  program   - Program the Tang Nano 9K via USB"
	@echo "  clean     - Remove build artifacts"
	@echo ""
	@echo "Requirements:"
	@echo "  - Gowin EDA (set GOWINHOME if not in /opt/gowin)"
	@echo "  - openFPGALoader for programming"
