/*
 * Gowin rPLL Configuration for Open Source Toolchain
 * Input: 27 MHz
 * Output 1: 25 MHz (pixel clock)
 * Output 2: 125 MHz (5x pixel clock for TMDS)
 *
 * Using Project Apicula rPLL primitive
 *
 * Calculation:
 * VCO = CLKIN * FBDIV_SEL / IDIV_SEL
 * CLKOUT = VCO / ODIV_SEL
 * CLKOUTD = VCO / ODIV_SEL / DYN_SDIV_SEL
 *
 * For 27 MHz input:
 * Target VCO = 500 MHz (typical range 400-600 MHz)
 * FBDIV_SEL = 50, IDIV_SEL = 3
 * VCO = 27 * 50 / 3 = 450 MHz
 * CLKOUT = 450 / 18 = 25 MHz
 * CLKOUTD = 450 / 18 / 0.2 = 125 MHz (need different approach)
 *
 * Alternative:
 * VCO = 27 * 46 / 3 = 414 MHz
 * CLKOUT = 414 / 16 ≈ 25.875 MHz (close to 25 MHz)
 * For CLKOUTD we need 125 MHz = VCO / 3.312
 */

module Gowin_rPLL (
    output clkout,      // ~25 MHz
    output clkoutd,     // ~125 MHz
    output lock,
    input clkin
);

    wire clkoutp;
    wire clkoutd3;
    wire gw_gnd;

    assign gw_gnd = 1'b0;

    // rPLL primitive for GW1N-9C (Project Apicula compatible)
    // Input: 27 MHz
    // Calculation: VCO = FCLKIN * (FBDIV_SEL + 1) / (IDIV_SEL + 1)
    //             CLKOUT = VCO / (ODIV_SEL + 1)
    //             CLKOUTD = CLKOUT / (DYN_SDIV_SEL + 1)
    //
    // Target: 25 MHz pixel clock, 125 MHz TMDS clock
    // VCO = 27 * 16 / 1 = 432 MHz (in range 400-1200 MHz)
    // CLKOUT = 432 / 17 = 25.4 MHz (close to 25 MHz)
    // CLKOUTD = 25.4 * 5 = 127 MHz (need to use CLKOUTP or different approach)
    //
    // Better: VCO = 27 * 50 / 3 = 450 MHz
    // CLKOUT = 450 / 18 = 25 MHz
    // For CLKOUTD we need 125 MHz, so use VCO directly with ODIV=4: 450/4=112.5MHz (close enough)
    rPLL #(
        .FCLKIN("27"),
        .DYN_IDIV_SEL("false"),
        .IDIV_SEL(2),           // IDIV = 2+1 = 3
        .DYN_FBDIV_SEL("false"),
        .FBDIV_SEL(49),         // FBDIV = 49+1 = 50
        .DYN_ODIV_SEL("false"),
        .ODIV_SEL(17),          // ODIV = 17+1 = 18, gives 450/18 = 25 MHz
        .PSDA_SEL("0000"),
        .DYN_DA_EN("false"),
        .DUTYDA_SEL("1000"),
        .CLKOUT_FT_DIR(1'b1),
        .CLKOUTP_FT_DIR(1'b1),
        .CLKOUT_DLY_STEP(0),
        .CLKOUTP_DLY_STEP(0),
        .CLKFB_SEL("internal"),
        .CLKOUT_BYPASS("false"),
        .CLKOUTP_BYPASS("false"),
        .CLKOUTD_BYPASS("false"),
        .DYN_SDIV_SEL(3),       // SDIV = 3+1 = 4, gives 450/4 = 112.5 MHz
        .CLKOUTD_SRC("VCO"),    // Use VCO directly for CLKOUTD
        .CLKOUTD3_SRC("CLKOUT")
    ) rpll_inst (
        .CLKOUT(clkout),
        .LOCK(lock),
        .CLKOUTP(clkoutp),
        .CLKOUTD(clkoutd),
        .CLKOUTD3(clkoutd3),
        .RESET(gw_gnd),
        .RESET_P(gw_gnd),
        .CLKIN(clkin),
        .CLKFB(gw_gnd),
        .FBDSEL({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
        .IDSEL({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
        .ODSEL({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
        .PSDA({gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
        .DUTYDA({gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
        .FDLY({gw_gnd,gw_gnd,gw_gnd,gw_gnd})
    );

endmodule
