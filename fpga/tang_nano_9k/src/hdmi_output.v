/*
 * HDMI/DVI Output Module
 * Takes VGA signals and outputs HDMI/DVI compatible signals
 * Uses TMDS encoding with 5x clock serialization
 */

`default_nettype none

module hdmi_output (
    input wire clk_pixel,      // 25.175 MHz pixel clock
    input wire clk_5x_pixel,   // 125.875 MHz (5x pixel clock)
    input wire reset,

    // VGA input signals
    input wire [2:0] rgb,      // Simple 3-bit RGB (R, G, B)
    input wire hsync,
    input wire vsync,
    input wire de,             // Display enable

    // HDMI output (TMDS)
    output wire tmds_clk_p,
    output wire tmds_clk_n,
    output wire [2:0] tmds_data_p,
    output wire [2:0] tmds_data_n
);

    // Expand 1-bit RGB to 8-bit for TMDS
    wire [7:0] red   = {8{rgb[2]}};
    wire [7:0] green = {8{rgb[1]}};
    wire [7:0] blue  = {8{rgb[0]}};

    // TMDS encoded data
    wire [9:0] tmds_red, tmds_green, tmds_blue;

    // TMDS Encoders
    tmds_encoder tmds_enc_red (
        .clk(clk_pixel),
        .data(red),
        .c0(1'b0),
        .c1(1'b0),
        .de(de),
        .encoded(tmds_red)
    );

    tmds_encoder tmds_enc_green (
        .clk(clk_pixel),
        .data(green),
        .c0(1'b0),
        .c1(1'b0),
        .de(de),
        .encoded(tmds_green)
    );

    tmds_encoder tmds_enc_blue (
        .clk(clk_pixel),
        .data(blue),
        .c0(hsync),
        .c1(vsync),
        .de(de),
        .encoded(tmds_blue)
    );

    // SIMPLIFIED: No 5x serialization for testing
    // Just output TMDS encoded bits directly (won't be proper HDMI, but might show something)
    // This is a temporary workaround until we have proper PLL working

    // Output lowest bit of TMDS data (cycling through the 10 bits each clock)
    reg [3:0] bit_counter = 0;

    always @(posedge clk_pixel) begin
        if (reset)
            bit_counter <= 0;
        else
            bit_counter <= (bit_counter == 9) ? 0 : bit_counter + 1;
    end

    // Output one bit at a time from the TMDS stream
    wire tmds_bit_red = tmds_red[bit_counter];
    wire tmds_bit_green = tmds_green[bit_counter];
    wire tmds_bit_blue = tmds_blue[bit_counter];

    // Differential output - simplified
    assign tmds_data_p[2] = tmds_bit_red;
    assign tmds_data_p[1] = tmds_bit_green;
    assign tmds_data_p[0] = tmds_bit_blue;

    assign tmds_data_n[2] = ~tmds_bit_red;
    assign tmds_data_n[1] = ~tmds_bit_green;
    assign tmds_data_n[0] = ~tmds_bit_blue;

    // Clock output (just pixel clock)
    assign tmds_clk_p = clk_pixel;
    assign tmds_clk_n = ~clk_pixel;

endmodule
