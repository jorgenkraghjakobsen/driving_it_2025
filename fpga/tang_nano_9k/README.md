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

### Gowin EDA

Download and install Gowin EDA (Educational/Free version):
- Website: https://www.gowinsemi.com/en/support/download_eda/
- Install to `/opt/gowin` or set `GOWINHOME` environment variable

### openFPGALoader

For programming the board via command line:

```bash
# Ubuntu/Debian
sudo apt install openfpgaloader

# From source
git clone https://github.com/trabucayre/openFPGALoader.git
cd openFPGALoader
mkdir build && cd build
cmake ..
make
sudo make install
```

## Building the Project

### Using Gowin IDE (GUI)

1. Open Gowin FPGA Designer
2. Open project: `driving_it_2025.gprj`
3. Click "Run" or "Process" → "Run All"
4. The bitstream will be generated as `driving_it_2025.fs`

### Using Command Line (Makefile)

```bash
# Build the bitstream
make

# Program the FPGA
make program

# Clean build artifacts
make clean
```

## Project Structure

```
tang_nano_9k/
├── src/
│   ├── tang_nano_9k_top.v      # Top-level module
│   ├── hdmi_output.v            # HDMI/DVI output module
│   ├── tmds_encoder.v           # TMDS encoding
│   └── gowin_rpll.v             # PLL clock generator
├── constraints/
│   └── tang_nano_9k.cst         # Pin constraints
├── driving_it_2025.gprj         # Gowin project file
├── Makefile                     # Build automation
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

### Using openFPGALoader

```bash
# Program SRAM (temporary, lost on power cycle)
openFPGALoader -b tangnano9k driving_it_2025.fs

# Program Flash (permanent)
openFPGALoader -b tangnano9k -f driving_it_2025.fs
```

### Using Gowin Programmer

1. Open Gowin Programmer
2. Select device: GW1NR-9C
3. Add file: `driving_it_2025.fs`
4. Click "Program/Configure"

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
- Ensure Gowin EDA is properly installed
- Check that all source files exist in correct locations
- Verify GOWINHOME environment variable

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
- [Gowin FPGA Resources](https://www.gowinsemi.com/)
- [HDMI/DVI Specification](https://www.hdmi.org/)
