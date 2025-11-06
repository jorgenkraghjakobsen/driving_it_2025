![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# Driving IT 2025 - VGA Text Display

A TinyTapeout project that displays "Driving IT 2025" on a VGA screen at 640x480 resolution.

- [Read the documentation for project](docs/info.md)

## Overview

This project implements a simple VGA text display that shows the text "Driving IT 2025" centered on a 640x480 VGA screen. The design uses:

- **VGA Sync Generator**: Generates proper horizontal and vertical sync signals for 640x480 @ 60Hz
- **Character ROM**: 5x7 pixel font for displaying characters
- **Text Display Logic**: Renders the text string at the center of the screen

## Specifications

- **Resolution**: 640x480 @ 60Hz
- **Clock Frequency**: 25.175 MHz (VGA pixel clock)
- **Color Depth**: 1-bit RGB (8 colors, white text on black background)
- **Character Size**: 5x7 pixels per character
- **Text**: "Driving IT 2025" (16 characters)

## Pin Configuration

The project uses the standard TinyTapeout VGA Pmod pinout:

| Pin | Signal | Description |
|-----|--------|-------------|
| uo[0] | VGA_R1 | Red MSB |
| uo[1] | VGA_G1 | Green MSB |
| uo[2] | VGA_B1 | Blue MSB |
| uo[3] | VGA_VSYNC | Vertical Sync |
| uo[4] | VGA_R0 | Red LSB |
| uo[5] | VGA_G0 | Green LSB |
| uo[6] | VGA_B0 | Blue LSB |
| uo[7] | VGA_HSYNC | Horizontal Sync |

## How to Test

1. Connect a VGA Pmod to the output pins
2. Connect to a VGA monitor
3. Apply a 25.175 MHz clock signal
4. You should see "Driving IT 2025" displayed in white text on a black background

## What is Tiny Tapeout?

Tiny Tapeout is an educational project that aims to make it easier and cheaper than ever to get your digital and analog designs manufactured on a real chip.

To learn more and get started, visit https://tinytapeout.com.

## Resources

- [FAQ](https://tinytapeout.com/faq/)
- [Digital design lessons](https://tinytapeout.com/digital_design/)
- [Learn how semiconductors work](https://tinytapeout.com/siliwiz/)
- [Join the community](https://tinytapeout.com/discord)
- [Build your design locally](https://www.tinytapeout.com/guides/local-hardening/)

## What next?

- [Submit your design to the next shuttle](https://app.tinytapeout.com/).
- Edit [this README](README.md) and explain your design, how it works, and how to test it.
- Share your project on your social network of choice:
  - LinkedIn [#tinytapeout](https://www.linkedin.com/search/results/content/?keywords=%23tinytapeout) [@TinyTapeout](https://www.linkedin.com/company/100708654/)
  - Mastodon [#tinytapeout](https://chaos.social/tags/tinytapeout) [@matthewvenn](https://chaos.social/@matthewvenn)
  - X (formerly Twitter) [#tinytapeout](https://twitter.com/hashtag/tinytapeout) [@tinytapeout](https://twitter.com/tinytapeout)
