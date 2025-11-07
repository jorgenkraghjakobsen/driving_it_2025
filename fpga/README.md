# FPGA Implementations

This directory contains FPGA implementations for testing the "Driving IT 2025" VGA display design on real hardware.

## Available Implementations

### Tang Nano 9K

**Board**: Sipeed Tang Nano 9K (Gowin GW1NR-9C FPGA)
**Output**: HDMI
**Directory**: `tang_nano_9k/`

The Tang Nano 9K implementation includes:
- VGA to HDMI/DVI conversion with TMDS encoding
- PLL-based clock generation (27 MHz → 25/125 MHz)
- Full VGA timing (640x480 @ 60Hz)
- Debug LEDs for system status

See [tang_nano_9k/README.md](tang_nano_9k/README.md) for detailed instructions.

## Quick Start (Tang Nano 9K)

```bash
cd tang_nano_9k

# Build
make

# Program (requires openFPGALoader)
make program
```

## Adding New FPGA Boards

To add support for other FPGA boards:

1. Create a new directory for your board (e.g., `your_board/`)
2. Create a top-level module that:
   - Generates the 25.175 MHz VGA pixel clock
   - Instantiates the TinyTapeout design (`tt_um_driving_it_2025`)
   - Adapts output signals to your board's video interface
3. Create appropriate constraints file for pin mapping
4. Add build scripts/project files for your toolchain

The core VGA design is in `../src/` and is board-independent.

## Supported Video Outputs

- **VGA**: Direct VGA output (requires VGA connector)
- **HDMI/DVI**: Digital video with TMDS encoding
- **DisplayPort**: (Future implementation)

## Common Issues

**No display output:**
- Verify clock generation is working
- Check pin constraints match your board
- Ensure video output is enabled

**Incorrect colors:**
- Check RGB signal mapping in top module
- Verify bit widths match (the design outputs 1-bit per color)

**Timing issues:**
- The design requires 25.175 MHz pixel clock (25 MHz is acceptable)
- Some displays are sensitive to timing variations

## Resources

Each FPGA implementation includes:
- Top-level module
- Clock generation (PLL/MMCM)
- Video output adapter
- Pin constraints
- Build scripts
- README with instructions
