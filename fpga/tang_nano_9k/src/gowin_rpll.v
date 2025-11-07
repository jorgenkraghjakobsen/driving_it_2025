/*
 * Gowin rPLL Configuration
 * Input: 27 MHz
 * Output 1: 25 MHz (pixel clock)
 * Output 2: 125 MHz (5x pixel clock for TMDS)
 *
 * This file can be generated using Gowin IP Core Generator
 * or written manually with rPLL primitive
 */

module Gowin_rPLL (
    output clkout,      // 25 MHz
    output clkoutd,     // 125 MHz
    output lock,
    input clkin
);

    // For 27 MHz input:
    // To get 25 MHz: FCLKIN * FBDIV / IDIV / ODIV = 27 * 50 / 54 / 1 = 25 MHz
    // To get 125 MHz: FCLKIN * FBDIV / IDIV / ODIVD = 27 * 50 / 54 / 0.2 = 125 MHz
    //
    // Alternative simpler calculation:
    // 27 MHz * (125/27) = 125 MHz (for 5x)
    // 27 MHz * (25/27) = 25 MHz
    //
    // Using integer math:
    // FBDIV_SEL = 4 (means FBDIV = 5)
    // IDIV_SEL = 26 (means IDIV = 27)
    // ODIV_SEL = 4 (means ODIV = 5)
    // For CLKOUTD: additional divider of 5

    rPLL #(
        .FCLKIN("27"),           // Input frequency in MHz
        .IDIV_SEL(26),           // Input divider (27)
        .FBDIV_SEL(124),         // Feedback divider (125)
        .ODIV_SEL(8),            // Output divider for CLKOUT (5 for 25MHz: 27*125/27/5 = 125/5 = 25)
        .DUTYDA("50"),           // Duty cycle 50%
        .DYN_SDIV_SEL(8)         // Dynamic output divider for CLKOUTD (1 for 125MHz)
    ) rpll_inst (
        .CLKOUT(clkout),         // 25 MHz output
        .CLKOUTD(clkoutd),       // 125 MHz output
        .LOCK(lock),
        .CLKIN(clkin),
        .CLKFB(1'b0),
        .RESET(1'b0),
        .RESET_P(1'b0),
        .FBDSEL(6'b0),
        .IDSEL(6'b0),
        .ODSEL(6'b0),
        .PSDA(4'b0),
        .DUTYDA(4'b0),
        .FDLY(4'b0)
    );

endmodule
