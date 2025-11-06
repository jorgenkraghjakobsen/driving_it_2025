/*
 * Character ROM - 5x7 font for displaying "Driving IT 2025"
 * Each character is 5 pixels wide and 7 pixels tall
 */

`default_nettype none

module char_rom (
    input wire [7:0] char_code,
    input wire [2:0] row,
    input wire [2:0] col,
    output reg pixel
);

    reg [4:0] char_row;

    // Get the 5-bit row data for the current character and row
    always @(*) begin
        case (char_code)
            // Space (0x20)
            8'h20: char_row = 5'b00000;

            // '0' (0x30)
            8'h30: begin
                case (row)
                    3'd0: char_row = 5'b01110;
                    3'd1: char_row = 5'b10001;
                    3'd2: char_row = 5'b10011;
                    3'd3: char_row = 5'b10101;
                    3'd4: char_row = 5'b11001;
                    3'd5: char_row = 5'b10001;
                    3'd6: char_row = 5'b01110;
                    default: char_row = 5'b00000;
                endcase
            end

            // '2' (0x32)
            8'h32: begin
                case (row)
                    3'd0: char_row = 5'b01110;
                    3'd1: char_row = 5'b10001;
                    3'd2: char_row = 5'b00001;
                    3'd3: char_row = 5'b00010;
                    3'd4: char_row = 5'b00100;
                    3'd5: char_row = 5'b01000;
                    3'd6: char_row = 5'b11111;
                    default: char_row = 5'b00000;
                endcase
            end

            // '5' (0x35)
            8'h35: begin
                case (row)
                    3'd0: char_row = 5'b11111;
                    3'd1: char_row = 5'b10000;
                    3'd2: char_row = 5'b11110;
                    3'd3: char_row = 5'b00001;
                    3'd4: char_row = 5'b00001;
                    3'd5: char_row = 5'b10001;
                    3'd6: char_row = 5'b01110;
                    default: char_row = 5'b00000;
                endcase
            end

            // 'D' (0x44)
            8'h44: begin
                case (row)
                    3'd0: char_row = 5'b11110;
                    3'd1: char_row = 5'b10001;
                    3'd2: char_row = 5'b10001;
                    3'd3: char_row = 5'b10001;
                    3'd4: char_row = 5'b10001;
                    3'd5: char_row = 5'b10001;
                    3'd6: char_row = 5'b11110;
                    default: char_row = 5'b00000;
                endcase
            end

            // 'I' (0x49)
            8'h49: begin
                case (row)
                    3'd0: char_row = 5'b01110;
                    3'd1: char_row = 5'b00100;
                    3'd2: char_row = 5'b00100;
                    3'd3: char_row = 5'b00100;
                    3'd4: char_row = 5'b00100;
                    3'd5: char_row = 5'b00100;
                    3'd6: char_row = 5'b01110;
                    default: char_row = 5'b00000;
                endcase
            end

            // 'T' (0x54)
            8'h54: begin
                case (row)
                    3'd0: char_row = 5'b11111;
                    3'd1: char_row = 5'b00100;
                    3'd2: char_row = 5'b00100;
                    3'd3: char_row = 5'b00100;
                    3'd4: char_row = 5'b00100;
                    3'd5: char_row = 5'b00100;
                    3'd6: char_row = 5'b00100;
                    default: char_row = 5'b00000;
                endcase
            end

            // 'g' (0x67)
            8'h67: begin
                case (row)
                    3'd0: char_row = 5'b00000;
                    3'd1: char_row = 5'b00000;
                    3'd2: char_row = 5'b01110;
                    3'd3: char_row = 5'b10001;
                    3'd4: char_row = 5'b01111;
                    3'd5: char_row = 5'b10001;
                    3'd6: char_row = 5'b01110;
                    default: char_row = 5'b00000;
                endcase
            end

            // 'i' (0x69)
            8'h69: begin
                case (row)
                    3'd0: char_row = 5'b00100;
                    3'd1: char_row = 5'b00000;
                    3'd2: char_row = 5'b01100;
                    3'd3: char_row = 5'b00100;
                    3'd4: char_row = 5'b00100;
                    3'd5: char_row = 5'b00100;
                    3'd6: char_row = 5'b01110;
                    default: char_row = 5'b00000;
                endcase
            end

            // 'n' (0x6E)
            8'h6E: begin
                case (row)
                    3'd0: char_row = 5'b00000;
                    3'd1: char_row = 5'b00000;
                    3'd2: char_row = 5'b10110;
                    3'd3: char_row = 5'b11001;
                    3'd4: char_row = 5'b10001;
                    3'd5: char_row = 5'b10001;
                    3'd6: char_row = 5'b10001;
                    default: char_row = 5'b00000;
                endcase
            end

            // 'r' (0x72)
            8'h72: begin
                case (row)
                    3'd0: char_row = 5'b00000;
                    3'd1: char_row = 5'b00000;
                    3'd2: char_row = 5'b10110;
                    3'd3: char_row = 5'b11001;
                    3'd4: char_row = 5'b10000;
                    3'd5: char_row = 5'b10000;
                    3'd6: char_row = 5'b10000;
                    default: char_row = 5'b00000;
                endcase
            end

            // 'v' (0x76)
            8'h76: begin
                case (row)
                    3'd0: char_row = 5'b00000;
                    3'd1: char_row = 5'b00000;
                    3'd2: char_row = 5'b10001;
                    3'd3: char_row = 5'b10001;
                    3'd4: char_row = 5'b10001;
                    3'd5: char_row = 5'b01010;
                    3'd6: char_row = 5'b00100;
                    default: char_row = 5'b00000;
                endcase
            end

            default: char_row = 5'b00000;
        endcase
    end

    // Extract pixel from the row based on column
    always @(*) begin
        pixel = char_row[4 - col];  // MSB is leftmost pixel
    end

endmodule
