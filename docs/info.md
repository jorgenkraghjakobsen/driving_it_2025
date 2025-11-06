<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project implements a VGA text display that shows "Driving IT 2025" on a standard VGA monitor. The design consists of three main components:

### VGA Sync Generator (`hvsync_generator.v`)

Generates the horizontal and vertical sync signals required for VGA 640x480 @ 60Hz display:
- **Pixel Clock**: 25.175 MHz
- **Horizontal Timing**: 640 visible pixels + 16 front porch + 96 sync + 48 back porch = 800 total
- **Vertical Timing**: 480 visible lines + 10 front porch + 2 sync + 33 back porch = 525 total
- Outputs HSYNC, VSYNC signals and current pixel position (hpos, vpos)

### Character ROM (`char_rom.v`)

Contains a 5x7 pixel font for the characters needed to display "Driving IT 2025":
- Stores character patterns for: D, r, i, v, n, g, space, I, T, 2, 0, 5
- Each character is 5 pixels wide and 7 pixels tall
- Takes character code, row, and column as inputs and outputs a single pixel value

### Text Display Logic (`project.v`)

The main module that ties everything together:
- Instantiates the VGA sync generator
- Stores the text string "Driving IT 2025" in a 16-byte array
- Calculates which character to display based on current pixel position
- Centers the text on the screen (approximately position 220, 236)
- Looks up pixels from the character ROM
- Outputs white text on a black background
- Maps RGB signals to the VGA Pmod pinout

The design is fully combinational (except for the sync counters), making it very compact and efficient for TinyTapeout constraints.

## How to test

1. **Hardware Setup**:
   - Connect a VGA Pmod to the TinyTapeout board output pins
   - Connect the VGA Pmod to a VGA monitor or VGA-compatible display

2. **Clock Configuration**:
   - The design requires a 25.175 MHz clock (standard VGA pixel clock)
   - This can be generated from the TinyTapeout demo board's RP2040

3. **Expected Output**:
   - You should see "Driving IT 2025" displayed in white text
   - The text will be centered on a black background
   - Resolution: 640x480 @ 60Hz

4. **Pin Connections** (VGA Pmod):
   - uo[7] → HSYNC
   - uo[3] → VSYNC
   - uo[0], uo[4] → Red (both bits tied together)
   - uo[1], uo[5] → Green (both bits tied together)
   - uo[2], uo[6] → Blue (both bits tied together)

## External hardware

- **VGA Pmod**: Required for VGA output
  - Standard TinyTapeout VGA Pmod with VGA connector
  - Provides proper electrical interface for VGA signals

- **VGA Monitor**: Any standard VGA monitor supporting 640x480 @ 60Hz
