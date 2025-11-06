/*
 * VGA Horizontal/Vertical Sync Generator
 * Based on 640x480 @ 60Hz VGA timing
 * Pixel clock: 25.175 MHz
 */

`default_nettype none

module hvsync_generator (
    input wire clk,
    input wire reset,
    output reg hsync,
    output reg vsync,
    output reg display_on,
    output reg [9:0] hpos,
    output reg [9:0] vpos
);

    // VGA 640x480 @ 60Hz timing parameters
    // Horizontal timing (pixels)
    parameter H_DISPLAY       = 640;
    parameter H_FRONT_PORCH   = 16;
    parameter H_SYNC_PULSE    = 96;
    parameter H_BACK_PORCH    = 48;
    parameter H_TOTAL         = 800;  // 640 + 16 + 96 + 48

    // Vertical timing (lines)
    parameter V_DISPLAY       = 480;
    parameter V_FRONT_PORCH   = 10;
    parameter V_SYNC_PULSE    = 2;
    parameter V_BACK_PORCH    = 33;
    parameter V_TOTAL         = 525;  // 480 + 10 + 2 + 33

    // Horizontal counter
    always @(posedge clk) begin
        if (reset) begin
            hpos <= 0;
        end else begin
            if (hpos == H_TOTAL - 1)
                hpos <= 0;
            else
                hpos <= hpos + 1;
        end
    end

    // Vertical counter
    always @(posedge clk) begin
        if (reset) begin
            vpos <= 0;
        end else begin
            if (hpos == H_TOTAL - 1) begin
                if (vpos == V_TOTAL - 1)
                    vpos <= 0;
                else
                    vpos <= vpos + 1;
            end
        end
    end

    // Generate HSYNC
    always @(posedge clk) begin
        if (reset)
            hsync <= 1;
        else
            hsync <= (hpos >= (H_DISPLAY + H_FRONT_PORCH)) &&
                     (hpos < (H_DISPLAY + H_FRONT_PORCH + H_SYNC_PULSE));
    end

    // Generate VSYNC
    always @(posedge clk) begin
        if (reset)
            vsync <= 1;
        else
            vsync <= (vpos >= (V_DISPLAY + V_FRONT_PORCH)) &&
                     (vpos < (V_DISPLAY + V_FRONT_PORCH + V_SYNC_PULSE));
    end

    // Display enable signal
    always @(posedge clk) begin
        if (reset)
            display_on <= 0;
        else
            display_on <= (hpos < H_DISPLAY) && (vpos < V_DISPLAY);
    end

endmodule
