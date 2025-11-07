/*
 * TMDS Encoder for HDMI/DVI output
 * Converts 8-bit RGB data to 10-bit TMDS encoded data
 */

`default_nettype none

module tmds_encoder (
    input wire clk,
    input wire [7:0] data,
    input wire c0,
    input wire c1,
    input wire de,
    output reg [9:0] encoded
);

    // Count number of 1s in data
    function [3:0] count_ones;
        input [7:0] d;
        integer i;
        begin
            count_ones = 0;
            for (i = 0; i < 8; i = i + 1)
                count_ones = count_ones + d[i];
        end
    endfunction

    // XOR or XNOR encoding decision
    wire [8:0] q_m;
    wire [3:0] num_ones = count_ones(data);
    wire use_xnor = (num_ones > 4) || (num_ones == 4 && data[0] == 0);

    assign q_m[0] = data[0];
    assign q_m[1] = use_xnor ? (q_m[0] ~^ data[1]) : (q_m[0] ^ data[1]);
    assign q_m[2] = use_xnor ? (q_m[1] ~^ data[2]) : (q_m[1] ^ data[2]);
    assign q_m[3] = use_xnor ? (q_m[2] ~^ data[3]) : (q_m[2] ^ data[3]);
    assign q_m[4] = use_xnor ? (q_m[3] ~^ data[4]) : (q_m[3] ^ data[4]);
    assign q_m[5] = use_xnor ? (q_m[4] ~^ data[5]) : (q_m[4] ^ data[5]);
    assign q_m[6] = use_xnor ? (q_m[5] ~^ data[6]) : (q_m[5] ^ data[6]);
    assign q_m[7] = use_xnor ? (q_m[6] ~^ data[7]) : (q_m[6] ^ data[7]);
    assign q_m[8] = use_xnor ? 1'b0 : 1'b1;

    // DC bias counter
    reg signed [4:0] dc_bias = 0;

    always @(posedge clk) begin
        if (de) begin
            // Count ones in q_m[7:0]
            integer i;
            integer q_m_ones;
            q_m_ones = 0;
            for (i = 0; i < 8; i = i + 1)
                q_m_ones = q_m_ones + q_m[i];

            if (dc_bias == 0 || q_m_ones == 4) begin
                encoded[9] <= ~q_m[8];
                encoded[8] <= q_m[8];
                encoded[7:0] <= q_m[8] ? q_m[7:0] : ~q_m[7:0];

                if (q_m[8] == 0) begin
                    dc_bias <= dc_bias + (4 - q_m_ones) * 2;
                end else begin
                    dc_bias <= dc_bias + (q_m_ones - 4) * 2;
                end
            end else begin
                if ((dc_bias > 0 && q_m_ones > 4) || (dc_bias < 0 && q_m_ones < 4)) begin
                    encoded[9] <= 1'b1;
                    encoded[8] <= q_m[8];
                    encoded[7:0] <= ~q_m[7:0];
                    dc_bias <= dc_bias + q_m[8] * 2 + (4 - q_m_ones) * 2;
                end else begin
                    encoded[9] <= 1'b0;
                    encoded[8] <= q_m[8];
                    encoded[7:0] <= q_m[7:0];
                    dc_bias <= dc_bias - (~q_m[8]) * 2 + (q_m_ones - 4) * 2;
                end
            end
        end else begin
            // Control period
            dc_bias <= 0;
            case ({c1, c0})
                2'b00: encoded <= 10'b1101010100;
                2'b01: encoded <= 10'b0010101011;
                2'b10: encoded <= 10'b0101010100;
                2'b11: encoded <= 10'b1010101011;
            endcase
        end
    end

endmodule
