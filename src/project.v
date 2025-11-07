/*
 * Copyright (c) 2024 Driving IT 2025
 * SPDX-License-Identifier: Apache-2.0
 *
 * VGA Text Display: "Driving IT 2025"
 * Displays text on a 640x480 VGA screen @ 60Hz
 */

`default_nettype none

module tt_um_driving_it_2025 (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock (25.175 MHz for VGA)
    input  wire       rst_n     // reset_n - low to reset
);

    // VGA output signals
    wire hsync, vsync;
    wire [9:0] hpos, vpos;
    wire display_on;
    wire [2:0] rgb;

    // Instantiate VGA sync generator
    hvsync_generator vga_sync (
        .clk(clk),
        .reset(~rst_n),
        .hsync(hsync),
        .vsync(vsync),
        .display_on(display_on),
        .hpos(hpos),
        .vpos(vpos)
    );

    // Text display parameters
    // "Driving IT 2025" = 16 characters
    // Character size: 30 pixels wide (25 + 5 spacing), 40 pixels tall (35 + 5 spacing)
    // Each character scaled 5x from original 5x7 font
    parameter TEXT_START_X = 80;   // Center horizontally: (640 - 16*30)/2 = 80
    parameter TEXT_START_Y = 220;  // Center vertically: (480 - 40)/2 = 220
    parameter CHAR_WIDTH = 30;
    parameter CHAR_HEIGHT = 40;
    parameter SCALE = 5;           // 5x scaling factor
    parameter TEXT_LENGTH = 16;

    // Text string: "Driving IT 2025"
    reg [7:0] text_string [0:15];
    initial begin
        text_string[0]  = 8'h44;  // 'D'
        text_string[1]  = 8'h72;  // 'r'
        text_string[2]  = 8'h69;  // 'i'
        text_string[3]  = 8'h76;  // 'v'
        text_string[4]  = 8'h69;  // 'i'
        text_string[5]  = 8'h6E;  // 'n'
        text_string[6]  = 8'h67;  // 'g'
        text_string[7]  = 8'h20;  // ' '
        text_string[8]  = 8'h49;  // 'I'
        text_string[9]  = 8'h54;  // 'T'
        text_string[10] = 8'h20;  // ' '
        text_string[11] = 8'h32;  // '2'
        text_string[12] = 8'h30;  // '0'
        text_string[13] = 8'h32;  // '2'
        text_string[14] = 8'h35;  // '5'
        text_string[15] = 8'h20;  // ' '
    end

    // Calculate position within text region
    wire in_text_region_x = (hpos >= TEXT_START_X) && (hpos < TEXT_START_X + TEXT_LENGTH * CHAR_WIDTH);
    wire in_text_region_y = (vpos >= TEXT_START_Y) && (vpos < TEXT_START_Y + CHAR_HEIGHT);
    wire in_text_region = in_text_region_x && in_text_region_y;

    // Calculate character index and position within character
    wire [9:0] text_x = hpos - TEXT_START_X;
    wire [9:0] text_y = vpos - TEXT_START_Y;
    wire [4:0] char_index = text_x / CHAR_WIDTH;
    wire [5:0] char_col = text_x % CHAR_WIDTH;  // Wider to hold 0-29
    wire [5:0] char_row = text_y % CHAR_HEIGHT; // Wider to hold 0-39

    // Scale down to get font ROM position (divide by SCALE)
    wire [2:0] font_col = char_col / SCALE;  // 0-29 -> 0-5
    wire [2:0] font_row = char_row / SCALE;  // 0-39 -> 0-7

    // Get current character
    wire [7:0] current_char = (char_index < TEXT_LENGTH) ? text_string[char_index] : 8'h20;

    // Get pixel from character ROM
    wire char_pixel;
    char_rom font (
        .char_code(current_char),
        .row(font_row),
        .col(font_col),
        .pixel(char_pixel)
    );

    // Generate RGB output (check we're in the actual character area, not spacing)
    wire text_pixel = in_text_region && char_pixel && (char_col < 25) && (char_row < 35);

    // White text on black background
    wire r = text_pixel;
    wire g = text_pixel;
    wire b = text_pixel;

    // Assign outputs
    // VGA Pmod compatible pinout:
    // uo_out[0] = R1, uo_out[1] = G1, uo_out[2] = B1, uo_out[3] = VSync
    // uo_out[4] = R0, uo_out[5] = G0, uo_out[6] = B0, uo_out[7] = HSync
    assign uo_out[0] = r;        // R1
    assign uo_out[1] = g;        // G1
    assign uo_out[2] = b;        // B1
    assign uo_out[3] = vsync;    // VSync
    assign uo_out[4] = r;        // R0 (same as R1 for 1-bit color)
    assign uo_out[5] = g;        // G0
    assign uo_out[6] = b;        // B0
    assign uo_out[7] = hsync;    // HSync

    // All bidirectional pins set to output mode (not used)
    assign uio_out = 8'b0;
    assign uio_oe = 8'b0;

    // List all unused inputs to prevent warnings
    wire _unused = &{ena, ui_in, uio_in, 1'b0};

endmodule
