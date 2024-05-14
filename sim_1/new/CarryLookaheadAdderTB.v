`timescale 1ns / 1ps

module CarryLookaheadAdderTB;
  reg [7:0] a;
  reg [7:0] b;
  wire [8:0] s_o;
  wire [8:0] s_p;
  reg clk;
  reg rst;

  initial begin
    forever begin
      #5 clk = !clk;
    end
  end

  CarryLookaheadAdderOriginal #(
      .WIDTH(8)
  ) original (
      .i_add1  (a),
      .i_add2  (b),
      .o_result(s_o)
  );

  CarryLookaheadAdder #(
      .WIDTH(8)
  ) pipelined (
      .clk(clk),
      .rst(rst),
      .i_add1(a),
      .i_add2(b),
      .o_result(s_p)
  );

  initial begin
    clk = 1;
    rst = 1;

    #10;
    rst = 0;
    a   = 10;
    b   = 7;

    #10;
    if (s_o != s_p) begin
      $display("ERROR: Outputs not the same:");
      $finish;
    end
    $display("Original output %d. Pipelined output: %d", s_o, s_p);

    a = 20;
    b = 31;

    #10;
    if (s_o != s_p) begin
      $display("ERROR: Outputs not the same:");
      $finish;
    end
    $display("Original output %d. Pipelined output: %d", s_o, s_p);

    a = 5;
    b = 23;

    #10;
    if (s_o != s_p) begin
      $display("ERROR: Outputs not the same:");
      $finish;
    end
    $display("Original output %d. Pipelined output: %d", s_o, s_p);

    a = 107;
    b = 72;

    #10;
    if (s_o != s_p) begin
      $display("ERROR: Outputs not the same:");
      $finish;
    end
    $display("Original output %d. Pipelined output: %d", s_o, s_p);

    $finish;
  end
endmodule
