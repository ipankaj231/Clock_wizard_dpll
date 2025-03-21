`timescale 1ns/1ps

module clk_wiz_0_clk_wiz (
    // Clock in ports
    input  wire clk_in1,       // External input clock (e.g., 100 MHz)
    input  wire resetn,        // Active-low reset
    // Clock out ports
    output wire clk_out1,      // Output clock 1 (e.g., 25.157 MHz)
    output wire clk_out2,      // Output clock 2 (e.g., 200 MHz)
    output wire clk_out3,      // Output clock 3 (e.g., 166.666 MHz)
    output wire clk_out4,      // Output clock 4 (e.g., 23.809 MHz)
    output wire clk_out5,      // Output clock 5 (e.g., 125 MHz)
    output wire clk_out6,      // Output clock 6 (e.g., 250 MHz)
    // Clock gating control signals
    input  wire clk_gate_en,   // Clock gating enable signal
    // Status and control signals
    output wire locked         // PLL lock status
);

    //------------------------------------
    // Input Clock Buffering
    //------------------------------------
    wire clk_in1_buffered;
    BUFFD1 clk_buf (
        .I(clk_in1),           // Input clock
        .O(clk_in1_buffered)   // Buffered input clock
    );

    //------------------------------------
    // ADPLL Instantiation
    //------------------------------------
    wire [5:0] pll_clk_out;    // 6 output clocks from ADPLL

    ADPLL adpll_inst (
        .REF_CLK(clk_in1_buffered),  // Buffered input clock
        .RESET(~resetn),             // Active-high reset
        .M2(1'b0),                   // Frequency control input (set to 0 if unused)
        .M1(1'b0),                   // Frequency control input (set to 0 if unused)
        .M0(1'b0),                   // Frequency control input (set to 0 if unused)
        .DADDR(7'h0),                // Dynamic reconfiguration address (set to 0 if unused)
        .DI(16'h0),                  // Dynamic reconfiguration data input (set to 0 if unused)
        .DCLK(1'b0),                 // Dynamic reconfiguration clock (set to 0 if unused)
        .DEN(1'b0),                  // Dynamic reconfiguration enable (set to 0 if unused)
        .DWE(1'b0),                  // Dynamic reconfiguration write enable (set to 0 if unused)
        .PSCLK(1'b0),                // Phase shift clock (set to 0 if unused)
        .PSEN(1'b0),                 // Phase shift enable (set to 0 if unused)
        .PSINCDEC(1'b0),             // Phase shift increment/decrement (set to 0 if unused)
        .LOCKED(locked),             // PLL lock status
        .OUT_CLK(pll_clk_out[0]),    // Primary output clock (CLKOUT0)
        .CLKOUT0(pll_clk_out[1]),    // Secondary output clock 0 (CLKOUT1)
        .CLKOUT1(pll_clk_out[2]),    // Secondary output clock 1 (CLKOUT2)
        .CLKOUT2(pll_clk_out[3]),    // Secondary output clock 2 (CLKOUT3)
        .CLKOUT3(pll_clk_out[4]),    // Secondary output clock 3 (CLKOUT4)
        .CLKOUT4(pll_clk_out[5]),    // Secondary output clock 4 (CLKOUT5)
        .CLKOUT5()                   // Secondary output clock 5 (unused)
    );

    //------------------------------------
    // Clock Gating (Optional)
    //------------------------------------
    wire [5:0] gated_clk_out;  // Gated output clocks

    CKGATE clk_gate_1 (
        .TE(1'b0),              // Test enable (optional, tie to 0 if unused)
        .E(clk_gate_en),        // Clock gating enable signal
        .CK(pll_clk_out[0]),    // Input clock 1
        .GCK(gated_clk_out[0])  // Gated clock output 1
    );

    CKGATE clk_gate_2 (
        .TE(1'b0),
        .E(clk_gate_en),
        .CK(pll_clk_out[1]),
        .GCK(gated_clk_out[1])
    );

    CKGATE clk_gate_3 (
        .TE(1'b0),
        .E(clk_gate_en),
        .CK(pll_clk_out[2]),
        .GCK(gated_clk_out[2])
    );

    CKGATE clk_gate_4 (
        .TE(1'b0),
        .E(clk_gate_en),
        .CK(pll_clk_out[3]),
        .GCK(gated_clk_out[3])
    );

    CKGATE clk_gate_5 (
        .TE(1'b0),
        .E(clk_gate_en),
        .CK(pll_clk_out[4]),
        .GCK(gated_clk_out[4])
    );

    CKGATE clk_gate_6 (
        .TE(1'b0),
        .E(clk_gate_en),
        .CK(pll_clk_out[5]),
        .GCK(gated_clk_out[5])
    );

    //------------------------------------
    // Assign Output Clocks
    //------------------------------------
    assign clk_out1 = gated_clk_out[0];  // 25.157 MHz
    assign clk_out2 = gated_clk_out[1];  // 200 MHz
    assign clk_out3 = gated_clk_out[2];  // 166.666 MHz
    assign clk_out4 = gated_clk_out[3];  // 23.809 MHz
    assign clk_out5 = gated_clk_out[4];  // 125 MHz
    assign clk_out6 = gated_clk_out[5];  // 250 MHz

endmodule
