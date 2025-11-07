# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge
from PIL import Image
import numpy as np


@cocotb.test()
async def test_vga_display(dut):
    """Test VGA display and generate an image"""
    dut._log.info("Start VGA display test")

    # VGA 640x480 @ 60Hz requires 25.175 MHz clock
    # Period = 1/25.175MHz = 39.72 ns, we'll use 40ns for simplicity
    clock = Clock(dut.clk, 40, units="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 10)

    dut._log.info("Capturing VGA frame...")

    # VGA timing: 800 x 525 total (including blanking)
    # Visible: 640 x 480
    H_TOTAL = 800
    V_TOTAL = 525
    H_VISIBLE = 640
    V_VISIBLE = 480

    # Create image buffer
    frame = np.zeros((V_VISIBLE, H_VISIBLE, 3), dtype=np.uint8)

    # Capture one complete frame
    pixel_count = 0
    line = 0
    col = 0
    in_visible_area = False
    frame_started = False

    # Run for slightly more than one frame to ensure we capture it
    total_cycles = H_TOTAL * V_TOTAL + 1000

    for cycle in range(total_cycles):
        await RisingEdge(dut.clk)

        # Get VGA signals
        # Pinout: uo[0]=R1, uo[1]=G1, uo[2]=B1, uo[3]=VSYNC,
        #         uo[4]=R0, uo[5]=G0, uo[6]=B0, uo[7]=HSYNC
        uo = int(dut.uo_out.value)

        hsync = (uo >> 7) & 1
        vsync = (uo >> 3) & 1
        r1 = (uo >> 0) & 1
        g1 = (uo >> 1) & 1
        b1 = (uo >> 2) & 1
        r0 = (uo >> 4) & 1
        g0 = (uo >> 5) & 1
        b0 = (uo >> 6) & 1

        # Combine 2-bit color (R1R0, G1G0, B1B0)
        r = (r1 << 1) | r0
        g = (g1 << 1) | g0
        b = (b1 << 1) | b0

        # Scale 2-bit color to 8-bit (0-3 -> 0-255)
        r_byte = r * 85  # 0, 85, 170, 255
        g_byte = g * 85
        b_byte = b * 85

        # Detect start of visible area (after vsync goes high)
        if vsync == 0:
            frame_started = True

        # Simple position tracking
        # We're in visible area when we see RGB values (text) or black background
        # For simplicity, count pixels and wrap at H_TOTAL
        if frame_started:
            h_pos = pixel_count % H_TOTAL
            v_pos = pixel_count // H_TOTAL

            # Store pixel if in visible region
            if h_pos < H_VISIBLE and v_pos < V_VISIBLE:
                frame[v_pos, h_pos] = [r_byte, g_byte, b_byte]

            pixel_count += 1

            # Stop after capturing one full frame
            if v_pos >= V_VISIBLE:
                break

    dut._log.info(f"Captured {pixel_count} pixels")

    # Save the frame as PNG
    img = Image.fromarray(frame, 'RGB')
    img.save('vga_output.png')
    dut._log.info("VGA frame saved to vga_output.png")

    # Also save as PPM (simpler format, no dependencies)
    with open('vga_output.ppm', 'w') as f:
        f.write(f'P3\n{H_VISIBLE} {V_VISIBLE}\n255\n')
        for row in frame:
            for pixel in row:
                f.write(f'{pixel[0]} {pixel[1]} {pixel[2]} ')
            f.write('\n')
    dut._log.info("VGA frame saved to vga_output.ppm")

    dut._log.info("Test complete!")


@cocotb.test()
async def test_basic_signals(dut):
    """Basic test to verify VGA signals are generated"""
    dut._log.info("Start basic signal test")

    clock = Clock(dut.clk, 40, units="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 100)

    # Check that HSYNC and VSYNC are toggling
    hsync_values = set()
    vsync_values = set()

    for _ in range(1000):
        await RisingEdge(dut.clk)
        uo = int(dut.uo_out.value)
        hsync = (uo >> 7) & 1
        vsync = (uo >> 3) & 1
        hsync_values.add(hsync)
        vsync_values.add(vsync)

    dut._log.info(f"HSYNC values seen: {hsync_values}")
    dut._log.info(f"VSYNC values seen: {vsync_values}")

    # Both should toggle between 0 and 1
    assert len(hsync_values) == 2, "HSYNC should toggle"
    assert len(vsync_values) == 2, "VSYNC should toggle"

    dut._log.info("Basic signal test passed!")
