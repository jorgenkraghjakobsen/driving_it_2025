# Makefile for Tang Nano 9K - Driving IT 2025 VGA Display
# Open Source FPGA Toolchain: Yosys + nextpnr-himbaechel + gowin_pack + openFPGALoader

# Project name
PROJ = driving_it_2025
TOP = tang_nano_9k_top

# Board selection
BOARD ?= tangnano9k

# Source directories
SRC_DIR = src
CORE_SRC_DIR = ../../src
OBJ = obj

# Device parameters
ifeq ($(BOARD), tangnano9k)
    FAMILY = GW1N-9C
    DEVICE = GW1NR-LV9QN88PC6/I5
else
    $(error Unsupported board: $(BOARD))
endif

# Source files
VERILOG_SOURCES = \
    $(SRC_DIR)/tang_nano_9k_top.v \
    $(SRC_DIR)/hdmi_output.v \
    $(SRC_DIR)/tmds_encoder.v \
    $(SRC_DIR)/gowin_rpll.v \
    $(CORE_SRC_DIR)/project.v \
    $(CORE_SRC_DIR)/hvsync_generator.v \
    $(CORE_SRC_DIR)/char_rom.v

# Constraint file
CST = constraints/$(BOARD).cst

# Device file for openFPGALoader
DEVICE_FILE = .device

# Default target
.PHONY: all
all: build

# Create obj directory
$(OBJ):
	mkdir -p $(OBJ)

# Synthesis with Yosys
$(OBJ)/$(PROJ).json: $(VERILOG_SOURCES) | $(OBJ)
	@echo "==> Synthesizing with Yosys..."
	yosys -p "read_verilog -sv $(VERILOG_SOURCES); \
	         synth_gowin -top $(TOP) -json $@"

# Place and Route with nextpnr-himbaechel
$(OBJ)/$(PROJ)_pnr.json: $(OBJ)/$(PROJ).json $(CST)
	@echo "==> Place and Route with nextpnr-himbaechel..."
	nextpnr-himbaechel --json $< \
	    --write $@ \
	    --device $(DEVICE) \
	    --vopt family=$(FAMILY) \
	    --vopt cst=$(CST)

# Generate bitstream with gowin_pack
$(OBJ)/$(PROJ).fs: $(OBJ)/$(PROJ)_pnr.json
	@echo "==> Packing bitstream with gowin_pack..."
	gowin_pack -d $(FAMILY) -o $@ $<

# Complete build
.PHONY: build
build: $(OBJ)/$(PROJ).fs
	@echo "==> Build complete: $(OBJ)/$(PROJ).fs"

# Find and select FPGA device
.PHONY: find-device
find-device:
	@echo "==> Scanning for FPGA devices..."
	@openFPGALoader --detect | tee $(DEVICE_FILE)
	@echo "Device saved to $(DEVICE_FILE)"

# Show currently selected device
.PHONY: show-device
show-device:
	@if [ -f $(DEVICE_FILE) ]; then \
		echo "==> Currently selected device:"; \
		cat $(DEVICE_FILE); \
	else \
		echo "No device selected. Run 'make find-device' first."; \
	fi

# Clear device selection
.PHONY: clear-device
clear-device:
	@rm -f $(DEVICE_FILE)
	@echo "Device selection cleared."

# Load bitstream to SRAM (temporary)
.PHONY: load
load: $(OBJ)/$(PROJ).fs
	@echo "==> Loading bitstream to FPGA SRAM (temporary)..."
	openFPGALoader -b $(BOARD) $<

# Flash bitstream to EPROM (persistent)
.PHONY: flash
flash: $(OBJ)/$(PROJ).fs
	@echo "==> Flashing bitstream to FPGA EPROM (persistent)..."
	openFPGALoader -b $(BOARD) -f $<

# Clean build artifacts
.PHONY: clean
clean:
	@echo "==> Cleaning build artifacts..."
	rm -rf $(OBJ)

# Show build information
.PHONY: info
info:
	@echo "==> Build Configuration"
	@echo "Project:     $(PROJ)"
	@echo "Top Module:  $(TOP)"
	@echo "Board:       $(BOARD)"
	@echo "Family:      $(FAMILY)"
	@echo "Device:      $(DEVICE)"
	@echo "Constraints: $(CST)"
	@echo ""
	@echo "==> Toolchain Check"
	@which yosys || echo "yosys: NOT FOUND"
	@which nextpnr-himbaechel || echo "nextpnr-himbaechel: NOT FOUND"
	@which gowin_pack || echo "gowin_pack: NOT FOUND"
	@which openFPGALoader || echo "openFPGALoader: NOT FOUND"

# Help
.PHONY: help
help:
	@echo "Tang Nano 9K - Driving IT 2025 VGA Display"
	@echo "Open Source FPGA Build System"
	@echo ""
	@echo "Targets:"
	@echo "  build        - Synthesize, place & route, and generate bitstream"
	@echo "  load         - Load bitstream to FPGA SRAM (temporary)"
	@echo "  flash        - Flash bitstream to EPROM (persistent)"
	@echo "  find-device  - Scan and select FPGA device"
	@echo "  show-device  - Display currently selected device"
	@echo "  clear-device - Clear device selection"
	@echo "  clean        - Remove build artifacts"
	@echo "  info         - Show build configuration"
	@echo "  help         - Show this help message"
	@echo ""
	@echo "Board Selection:"
	@echo "  make BOARD=tangnano9k build"
	@echo ""
	@echo "Required Tools:"
	@echo "  - yosys"
	@echo "  - nextpnr-himbaechel (nextpnr with Gowin support)"
	@echo "  - gowin_pack (from Project Apicula)"
	@echo "  - openFPGALoader"
