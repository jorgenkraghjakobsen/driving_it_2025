/*
 * Tang Nano 9K Top Module
 * Driving IT 2025 VGA Display with HDMI Output
 *
 * Tang Nano 9K has 27 MHz input clock
 * We need:
 * - 25.175 MHz for VGA pixel clock (we'll use 25 MHz for simplicity)
 * - 125 MHz for HDMI serialization (5x pixel clock)
 */

`default_nettype none

module tang_nano_9k_top (
    input wire clk_27mhz,      // 27 MHz onboard clock
    input wire btn_rst,        // Reset button (active low)

    // HDMI output
    output wire tmds_clk_p,
    output wire tmds_clk_n,
    output wire [2:0] tmds_data_p,
    output wire [2:0] tmds_data_n,

    // Debug LEDs
    output wire [5:0] led
);

    // Clock generation
    wire clk_pixel;      // 25 MHz pixel clock
    wire clk_5x_pixel;   // 125 MHz for TMDS serialization
    wire pll_lock;

    // Gowin PLL IP for clock generation
    // 27 MHz input -> 25 MHz and 125 MHz outputs
    Gowin_rPLL pll_inst (
        .clkout(clk_pixel),     // 25 MHz output
        .clkoutd(clk_5x_pixel), // 125 MHz output (5x)
        .lock(pll_lock),
        .clkin(clk_27mhz)
    );

    // Reset synchronization
    reg [3:0] reset_sync = 4'b1111;
    wire reset = reset_sync[3];

    always @(posedge clk_pixel or negedge btn_rst or negedge pll_lock) begin
        if (!btn_rst || !pll_lock)
            reset_sync <= 4'b1111;
        else
            reset_sync <= {reset_sync[2:0], 1'b0};
    end

    // VGA signals from TinyTapeout design
    wire hsync, vsync;
    wire [7:0] vga_out;

    // Extract VGA signals from TinyTapeout output
    // uo[0]=R1, uo[1]=G1, uo[2]=B1, uo[3]=VSYNC,
    // uo[4]=R0, uo[5]=G0, uo[6]=B0, uo[7]=HSYNC
    assign hsync = vga_out[7];
    assign vsync = vga_out[3];
    wire [2:0] rgb = {vga_out[0], vga_out[1], vga_out[2]};  // R, G, B

    // Display enable (active during visible area)
    // We'll derive this from the sync signals
    wire de;

    // Instantiate the VGA display enable detector
    vga_display_enable de_gen (
        .clk(clk_pixel),
        .reset(reset),
        .hsync(hsync),
        .vsync(vsync),
        .de(de)
    );

    // Instantiate TinyTapeout VGA design
    tt_um_driving_it_2025 vga_display (
        .ui_in(8'h00),
        .uo_out(vga_out),
        .uio_in(8'h00),
        .uio_out(),
        .uio_oe(),
        .ena(1'b1),
        .clk(clk_pixel),
        .rst_n(~reset)
    );

    // Instantiate HDMI output
    hdmi_output hdmi_out (
        .clk_pixel(clk_pixel),
        .clk_5x_pixel(clk_5x_pixel),
        .reset(reset),
        .rgb(rgb),
        .hsync(hsync),
        .vsync(vsync),
        .de(de),
        .tmds_clk_p(tmds_clk_p),
        .tmds_clk_n(tmds_clk_n),
        .tmds_data_p(tmds_data_p),
        .tmds_data_n(tmds_data_n)
    );

    // Debug LEDs - show status
    assign led[0] = pll_lock;
    assign led[1] = ~reset;
    assign led[2] = hsync;
    assign led[3] = vsync;
    assign led[4] = de;
    assign led[5] = |rgb;  // Any color active

endmodule


// Simple display enable generator based on sync signals
module vga_display_enable (
    input wire clk,
    input wire reset,
    input wire hsync,
    input wire vsync,
    output reg de
);

    // Detect edges of sync signals to determine blanking periods
    reg hsync_r, vsync_r;
    reg [10:0] h_count = 0;
    reg [9:0] v_count = 0;

    always @(posedge clk) begin
        if (reset) begin
            h_count <= 0;
            v_count <= 0;
            hsync_r <= 0;
            vsync_r <= 0;
            de <= 0;
        end else begin
            hsync_r <= hsync;
            vsync_r <= vsync;

            // Horizontal counter
            if (hsync && !hsync_r) begin  // HSYNC rising edge
                h_count <= 0;
            end else if (h_count < 1023) begin
                h_count <= h_count + 1;
            end

            // Vertical counter
            if (vsync && !vsync_r) begin  // VSYNC rising edge
                v_count <= 0;
            end else if (hsync && !hsync_r && v_count < 1023) begin
                v_count <= v_count + 1;
            end

            // Display enable - active in visible region
            // Roughly: H: 0-640, V: 0-480
            de <= (h_count < 640) && (v_count < 480);
        end
    end

endmodule
