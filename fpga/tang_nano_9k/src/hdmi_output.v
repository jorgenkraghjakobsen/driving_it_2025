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

    // Serialization counter (0-4)
    reg [2:0] serialize_cnt = 0;
    always @(posedge clk_5x_pixel) begin
        if (reset)
            serialize_cnt <= 0;
        else begin
            if (serialize_cnt == 4)
                serialize_cnt <= 0;
            else
                serialize_cnt <= serialize_cnt + 1;
        end
    end

    // Serialization registers
    reg [9:0] tmds_shift_red = 0;
    reg [9:0] tmds_shift_green = 0;
    reg [9:0] tmds_shift_blue = 0;

    always @(posedge clk_5x_pixel) begin
        if (serialize_cnt == 0) begin
            tmds_shift_red <= tmds_red;
            tmds_shift_green <= tmds_green;
            tmds_shift_blue <= tmds_blue;
        end else begin
            tmds_shift_red <= {1'b0, tmds_shift_red[9:1]};
            tmds_shift_green <= {1'b0, tmds_shift_green[9:1]};
            tmds_shift_blue <= {1'b0, tmds_shift_blue[9:1]};
        end
    end

    // Output serialized data
    wire tmds_clk_serial = (serialize_cnt < 5) ? serialize_cnt[0] : 1'b0;

    // Differential output (for Tang Nano 9K, these will be mapped to HDMI pins)
    assign tmds_data_p[2] = tmds_shift_red[0];
    assign tmds_data_p[1] = tmds_shift_green[0];
    assign tmds_data_p[0] = tmds_shift_blue[0];

    assign tmds_data_n[2] = ~tmds_shift_red[0];
    assign tmds_data_n[1] = ~tmds_shift_green[0];
    assign tmds_data_n[0] = ~tmds_shift_blue[0];

    assign tmds_clk_p = tmds_clk_serial;
    assign tmds_clk_n = ~tmds_clk_serial;

endmodule
