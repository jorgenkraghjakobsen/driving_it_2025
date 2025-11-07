# Tang Nano 9K FPGA Implementation
## Driving IT 2025 VGA Display with HDMI Output

This directory contains the FPGA implementation of the "Driving IT 2025" VGA display for the Tang Nano 9K board with HDMI output.

## Features

- VGA signal generation (640x480 @ 60Hz)
- TMDS encoding for HDMI/DVI output
- Large 5x scaled text display
- 27 MHz to 25/125 MHz PLL clock generation
- 6 debug LEDs showing system status

## Hardware Requirements

- **Tang Nano 9K FPGA Board** (Gowin GW1NR-9C)
- HDMI monitor or display
- USB cable for programming
- (Optional) Buttons for reset

## Software Requirements

### Open Source FPGA Toolchain

This project uses a completely open source toolchain:

**Required Tools:**
- **Yosys** - HDL synthesis
- **nextpnr-himbaechel** - Place and route for Gowin FPGAs
- **Project Apicula** - Gowin FPGA bitstream tools (gowin_pack)
- **openFPGALoader** - FPGA programming tool

### Installation

**Option 1: OSS CAD Suite (Recommended)**
```bash
# Download OSS CAD Suite (includes all tools)
wget https://github.com/YosysHQ/oss-cad-suite-build/releases/latest/download/oss-cad-suite-linux-x64-<version>.tgz
tar -xzf oss-cad-suite-linux-x64-*.tgz
source oss-cad-suite/environment

# Or add to your shell profile
echo 'source /path/to/oss-cad-suite/environment' >> ~/.bashrc
```

**Option 2: Individual Tools (Ubuntu/Debian)**
```bash
# Install Yosys
sudo apt install yosys

# Install nextpnr with Gowin support (requires building from source)
git clone https://github.com/YosysHQ/nextpnr.git
cd nextpnr
cmake -DARCH=himbaechel -DHIMBAECHEL_GOWIN_DEVICES=all .
make -j$(nproc)
sudo make install

# Install Project Apicula (for gowin_pack)
pip3 install apycula

# Install openFPGALoader
sudo apt install openfpgaloader
```

## Building the Project

### Using Open Source Tools (Command Line)

```bash
# Show build configuration and check tools
make info

# Build the bitstream
make build

# Load to FPGA SRAM (temporary, lost on power cycle)
make load

# Flash to FPGA EPROM (persistent)
make flash

# Clean build artifacts
make clean
```

### Build Targets

- `make build` - Complete synthesis, place & route, and bitstream generation
- `make load` - Program FPGA SRAM (temporary)
- `make flash` - Program FPGA Flash memory (persistent)
- `make find-device` - Detect connected FPGA board
- `make info` - Show configuration and verify tools
- `make help` - Display help message

## Project Structure

```
tang_nano_9k/
├── src/
│   ├── tang_nano_9k_top.v      # Top-level module
│   ├── hdmi_output.v            # HDMI/DVI output module
│   ├── tmds_encoder.v           # TMDS encoding
│   └── gowin_rpll.v             # PLL clock generator
├── constraints/
│   └── tangnano9k.cst           # Pin constraints (OSS format)
├── makefile                     # Open source build system
└── README.md                    # This file
```

## Pin Mapping

| Signal | Pin | Description |
|--------|-----|-------------|
| clk_27mhz | 52 | 27 MHz input clock |
| btn_rst | 4 | Reset button (active low) |
| tmds_clk_p | 33 | HDMI clock positive |
| tmds_clk_n | 34 | HDMI clock negative |
| tmds_data_p[0] | 35 | HDMI blue positive |
| tmds_data_n[0] | 36 | HDMI blue negative |
| tmds_data_p[1] | 37 | HDMI green positive |
| tmds_data_n[1] | 38 | HDMI green negative |
| tmds_data_p[2] | 39 | HDMI red positive |
| tmds_data_n[2] | 40 | HDMI red negative |
| led[0:5] | 10,11,13,14,15,16 | Debug LEDs |

## Debug LEDs

The 6 LEDs on the Tang Nano 9K show system status:

- **LED0**: PLL locked (should be ON)
- **LED1**: Reset released (should be ON)
- **LED2**: HSYNC signal (blinks rapidly)
- **LED3**: VSYNC signal (blinks slowly ~60Hz)
- **LED4**: Display enable (ON during visible region)
- **LED5**: Any color active (ON when displaying text)

## Programming the FPGA

### Using openFPGALoader (Command Line)

```bash
# Detect connected FPGA board
make find-device

# Program SRAM (temporary, lost on power cycle)
make load

# Program Flash (persistent, survives power cycle)
make flash

# Or use openFPGALoader directly:
openFPGALoader -b tangnano9k obj/driving_it_2025.fs          # SRAM
openFPGALoader -b tangnano9k -f obj/driving_it_2025.fs       # Flash
```

## Expected Output

When programmed successfully:
- HDMI monitor should display "Driving IT 2025" in large white text
- Text centered on black background at 640x480 resolution
- LEDs 0-1 should be solid ON
- LEDs 2-5 should be blinking/active

## Troubleshooting

**No HDMI output:**
- Check all LEDs - LED0 (PLL lock) must be ON
- Try pressing reset button
- Check HDMI cable connection
- Some monitors may not support the simplified TMDS encoding - try a different monitor

**LEDs not blinking:**
- Check USB connection
- Reprogram the FPGA
- Try power cycling the board

**Build errors:**
- Run `make info` to verify all tools are installed
- Check OSS CAD Suite is properly sourced
- Ensure nextpnr-himbaechel has Gowin support enabled
- Verify all source files exist: `ls src/*.v ../../src/*.v`

**Tool not found errors:**
- Install OSS CAD Suite or individual tools (see Software Requirements)
- Add tools to PATH or source OSS CAD Suite environment
- For nextpnr-himbaechel: ensure built with `-DHIMBAECHEL_GOWIN_DEVICES=all`

## Clock Frequencies

- Input: 27 MHz (onboard oscillator)
- Pixel clock: 25 MHz (VGA timing)
- TMDS clock: 125 MHz (5x pixel clock)

## Resources Used

Approximate resource usage on GW1NR-9C:
- LUTs: ~2000-3000 (20-30%)
- Flip-Flops: ~500-1000 (5-10%)
- Block RAM: 0
- PLL: 1 (of 2 available)

## Notes

- The HDMI output uses simplified TMDS encoding (DVI mode)
- No audio is transmitted
- Some monitors may show "No Signal" briefly before recognizing the signal
- The design runs at true VGA timing (640x480 @ 60Hz)

## References

- [Tang Nano 9K Documentation](https://wiki.sipeed.com/hardware/en/tang/Tang-Nano-9K/Nano-9K.html)
- [OSS CAD Suite](https://github.com/YosysHQ/oss-cad-suite-build)
- [Project Apicula (Gowin FPGA Tools)](https://github.com/YosysHQ/apicula)
- [nextpnr Documentation](https://github.com/YosysHQ/nextpnr)
- [openFPGALoader](https://github.com/trabucayre/openFPGALoader)
- [HDMI/DVI Specification](https://www.hdmi.org/)
