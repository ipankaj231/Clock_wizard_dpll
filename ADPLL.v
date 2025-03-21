`timescale 1ns/1ps

`include "DCO.v"
`include "PFD.v"
`include "CONTROLLER.v"
`include "FREQ_DIV.v"

module ADPLL(
    input  wire        REF_CLK,          // Reference clock input
    input  wire        RESET,            // Active-high reset
    input  wire        M2, M1, M0,       // Frequency control inputs
    input  wire [6:0]  DADDR,            // Dynamic reconfiguration address
    input  wire [15:0] DI,               // Dynamic reconfiguration data input
    input  wire        DCLK,             // Dynamic reconfiguration clock
    input  wire        DEN,              // Dynamic reconfiguration enable
    input  wire        DWE,              // Dynamic reconfiguration write enable
    input  wire        PSCLK,            // Phase shift clock
    input  wire        PSEN,             // Phase shift enable
    input  wire        PSINCDEC,         // Phase shift increment/decrement
    output wire        LOCKED,           // Locked signal (similar to MMCME2_ADV)
    output wire        OUT_CLK,          // Primary output clock
    output wire        CLKOUT0,          // Secondary output clock 0
    output wire        CLKOUT1,          // Secondary output clock 1
    output wire        CLKOUT2,          // Secondary output clock 2
    output wire        CLKOUT3,          // Secondary output clock 3
    output wire        CLKOUT4,          // Secondary output clock 4
    output wire        CLKOUT5           // Secondary output clock 5
);

    // Internal signals
    wire Out_divM;
    wire flagu, flagd;
    wire [128:0] code;
    wire POLARITY;
    wire [15:0] DO;                      // Dynamic reconfiguration data output
    wire DRDY;                           // Dynamic reconfiguration ready
    wire PSDONE;                         // Phase shift done

     // PFD (Phase-Frequency Detector)
    pfd PFD(
        .IN(REF_CLK),       // Reference clock input
        .FB(Out_divM),      // Feedback clock input
        .RESET(RESET),      // Active-high reset
        .flagu(flagu),      // UP signal (increase frequency)
        .flagd(flagd)       // DOWN signal (decrease frequency)
    );

    // CONTROLLER (Digital Loop Filter and Control Logic)
    CONTROLLER CONTROLLER(
        .reset(RESET),
        .phase_clk(flagu & flagd),
        .p_up(flagu),
        .p_down(flagd),
        .freq_lock(LOCKED),
        .polarity(POLARITY),
        .dco_code(code),
        .DADDR(DADDR),
        .DI(DI),
        .DCLK(DCLK),
        .DEN(DEN),
        .DWE(DWE),
        .DO(DO),
        .DRDY(DRDY),
        .PSCLK(PSCLK),
        .PSEN(PSEN),
        .PSINCDEC(PSINCDEC),
        .PSDONE(PSDONE)
    );

    // DCO (Digitally Controlled Oscillator)
    DCO DCO(
        .RESET(RESET),
        .code(code),
        .OUT_CLK(OUT_CLK)
    );

    // Frequency Dividers for Multiple Output Clocks
    FREQ_DIV #(.DIVIDE(39.750)) DIV0 (
        .reset(RESET),
        .clk(OUT_CLK),
        .M2(M2),
        .M1(M1),
        .M0(M0),
        .out_clk(CLKOUT0)
    );

    FREQ_DIV #(.DIVIDE(5)) DIV1 (
        .reset(RESET),
        .clk(OUT_CLK),
        .M2(M2),
        .M1(M1),
        .M0(M0),
        .out_clk(CLKOUT1)
    );

    FREQ_DIV #(.DIVIDE(6)) DIV2 (
        .reset(RESET),
        .clk(OUT_CLK),
        .M2(M2),
        .M1(M1),
        .M0(M0),
        .out_clk(CLKOUT2)
    );

    FREQ_DIV #(.DIVIDE(42)) DIV3 (
        .reset(RESET),
        .clk(OUT_CLK),
        .M2(M2),
        .M1(M1),
        .M0(M0),
        .out_clk(CLKOUT3)
    );

    FREQ_DIV #(.DIVIDE(8)) DIV4 (
        .reset(RESET),
        .clk(OUT_CLK),
        .M2(M2),
        .M1(M1),
        .M0(M0),
        .out_clk(CLKOUT4)
    );

    FREQ_DIV #(.DIVIDE(4)) DIV5 (
        .reset(RESET),
        .clk(OUT_CLK),
        .M2(M2),
        .M1(M1),
        .M0(M0),
        .out_clk(CLKOUT5)
    );

    // Feedback Divider
    FREQ_DIV #(.DIVIDE(10)) DIV_FB (
        .reset(RESET),
        .clk(OUT_CLK),
        .M2(M2),
        .M1(M1),
        .M0(M0),
        .out_clk(Out_divM)
    );


endmodule
