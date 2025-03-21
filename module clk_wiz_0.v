module clk_wiz_0 
(
  // Clock out ports
  output        clk_out1,
  output        clk_out2,
  output        clk_out3,
  output        clk_out4,
  output        clk_out5,
  output        clk_out6,
  // Status and control signals
  input         resetn,
  output        locked,
  // Clock gating control signal
  input         clk_gate_en,
  // Clock in ports
  input         clk_in1
);

  clk_wiz_0_clk_wiz inst
  (
    // Clock out ports  
    .clk_out1(clk_out1),
    .clk_out2(clk_out2),
    .clk_out3(clk_out3),
    .clk_out4(clk_out4),
    .clk_out5(clk_out5),
    .clk_out6(clk_out6),
    // Status and control signals               
    .resetn(resetn), 
    .locked(locked),
    // Clock gating control signal
    .clk_gate_en(clk_gate_en),
    // Clock in ports
    .clk_in1(clk_in1)
  );

endmodule
