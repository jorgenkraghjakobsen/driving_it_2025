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
    wire async_reset = !btn_rst || !pll_lock;

    always @(posedge clk_pixel) begin
        if (async_reset)
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

    // Simple display enable: track position with counters
    // VGA 640x480: 800 total horizontal, 525 total vertical
    reg [9:0] h_counter = 0;
    reg [9:0] v_counter = 0;
    reg hsync_prev = 0;
    reg vsync_prev = 0;

    always @(posedge clk_pixel) begin
        if (reset) begin
            h_counter <= 0;
            v_counter <= 0;
            hsync_prev <= 0;
            vsync_prev <= 0;
        end else begin
            hsync_prev <= hsync;
            vsync_prev <= vsync;

            // Increment horizontal counter
            h_counter <= h_counter + 1;

            // Reset on HSYNC rising edge
            if (hsync && !hsync_prev) begin
                h_counter <= 0;
                v_counter <= v_counter + 1;
            end

            // Reset on VSYNC rising edge
            if (vsync && !vsync_prev) begin
                v_counter <= 0;
            end
        end
    end

    // Display enable: active during visible area (0-639, 0-479)
    wire de = (h_counter < 640) && (v_counter < 480);

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
