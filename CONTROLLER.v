`timescale 1ns/1ps

`include "FILTER.v"

module CONTROLLER(
    input              reset,           // Reset signal
    input              phase_clk,       // Phase clock signal
    input              p_up,            // Phase up signal
    input              p_down,          // Phase down signal
    input  wire [6:0]  DADDR,           // Dynamic reconfiguration address
    input  wire [15:0] DI,              // Dynamic reconfiguration data input
    input  wire        DCLK,            // Dynamic reconfiguration clock
    input  wire        DEN,             // Dynamic reconfiguration enable
    input  wire        DWE,             // Dynamic reconfiguration write enable
    input  wire        PSCLK,           // Phase shift clock
    input  wire        PSEN,            // Phase shift enable
    input  wire        PSINCDEC,        // Phase shift increment/decrement
    output reg         freq_lock,       // Frequency lock output
    output reg         polarity,        // Polarity output
    output reg [128:0] dco_code,        // DCO control code output
    output wire [15:0]  DO,              // Dynamic reconfiguration data output
    output reg         DRDY,            // Dynamic reconfiguration ready
    output reg         PSDONE           // Phase shift done
);

    reg [7:0] dco_code_int = 8'd0;      // Integer DCO code
    reg [128:0] dco_code_bit = 129'h0;  // DCO code in binary
    reg p_history;                      // History of phase signal
    wire [7:0] avg_code_int;            // Integer DCO code after FILTER

    // Dynamic Reconfiguration Registers
    reg [15:0] config_reg [0:127];      // Configuration registers
    reg [6:0]  reconf_addr;             // Reconfiguration address
    reg [15:0] reconf_data;             // Reconfiguration data

    // Fine Phase Shifting
    reg [7:0] phase_shift = 8'd0;       // Phase shift value

    // FILTER Module
    FILTER FILTER(
        .rst(reset),
        .clk(phase_clk),
        .lock(freq_lock),
        .p_up(p_up),
        .p_down(p_down),
        .code(dco_code_int),
        .avg_code(avg_code_int)
    );

    // DCO Code Mapping
    always @(*) begin
        dco_code_bit = (129'h1 << avg_code_int) - 1; // Efficient binary mapping
    end

    // DCO Code Output
    always @(*) begin
        if (reset) dco_code = 129'h0;
        else dco_code = dco_code_bit;
    end

    // DCO Code Adjustment
    always @(negedge phase_clk or posedge reset) begin
        if (reset) begin
            dco_code_int <= 8'd32; // Initialize DCO code
        end else if (!p_up && p_down && (dco_code_int < 128)) begin
            dco_code_int <= dco_code_int + 1; // Increase frequency
        end else if (p_up && !p_down && (dco_code_int > 0)) begin
            dco_code_int <= dco_code_int - 1; // Decrease frequency
        end
    end

    // Frequency Lock Detection
    always @(negedge phase_clk or posedge reset) begin
        if (reset) begin
            freq_lock <= 1'b0;
        end else if ((dco_code_int >= 8'd20) && (dco_code_int <= 8'd136)) begin
            freq_lock <= 1'b1; // Locked within a specific range
        end else begin
            freq_lock <= 1'b0;
        end
    end

    // Polarity Detection
    always @(negedge phase_clk or posedge reset) begin
        if (reset) begin
            polarity <= 1'b0;
        end else if (p_up != p_history) begin
            polarity <= 1'b1; // Polarity switched
        end else begin
            polarity <= 1'b0;
        end
    end

    // Store Previous Phase Down Signal
    always @(negedge phase_clk) begin
        p_history <= p_down;
    end
    
    // Initialize Configuration Registers
integer i;
initial begin
    for (i = 0; i < 128; i = i + 1) begin
        config_reg[i] = 16'h0000;
    end
end

    // Dynamic Reconfiguration Logic
    // Dynamic Reconfiguration Logic
always @(posedge DCLK or posedge reset) begin
    if (reset) begin
        reconf_addr <= 7'h0;
        reconf_data <= 16'h0;
        DRDY <= 1'b0;
    end else if (DEN) begin
        if (DWE) begin
            // Write operation
            config_reg[DADDR] <= DI; // Write to configuration register
        end else begin
            // Read operation
            reconf_data <= config_reg[DADDR]; // Read from configuration register
            DRDY <= 1'b1; // Data is ready
        end
    end else begin
        DRDY <= 1'b0; // Deassert DRDY when DEN is low
    end
end

// Assign DO to reconf_data
assign DO = reconf_data;

    // Fine Phase Shifting Logic
    always @(posedge PSCLK or posedge reset) begin
        if (reset) begin
            phase_shift <= 8'd0;
            PSDONE <= 1'b0;
        end else if (PSEN) begin
            if (PSINCDEC) begin
                phase_shift <= phase_shift + 1; // Increment phase
            end else begin
                phase_shift <= phase_shift - 1; // Decrement phase
            end
            PSDONE <= 1'b1; // Phase shift done
        end else begin
            PSDONE <= 1'b0;
        end
    end

endmodule
