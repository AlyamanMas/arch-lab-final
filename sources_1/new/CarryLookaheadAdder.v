module CarryLookaheadAdder #(
    parameter WIDTH = 4
) (
    input clk,
    input rst,
    input [WIDTH-1:0] i_add1,
    input [WIDTH-1:0] i_add2,
    output [WIDTH:0] o_result
);
  wire [WIDTH:0] w_C;
  wire [WIDTH-1:0] w_G, w_P, w_SUM;

  // reg [WIDTH:0] r_C;
  reg [WIDTH-1:0] r_G, r_P;

  // Create the Full Adders
  genvar ii;
  generate
    for (ii = 0; ii < WIDTH; ii = ii + 1) begin
      assign w_SUM[ii] = i_add1[ii] + i_add2[ii] + w_C[ii];
    end
  endgenerate

  // Create the Generate (G) Terms:  Gi=Ai*Bi
  // Create the Propagate Terms: Pi=Ai+Bi
  // Create the Carry Terms: C_{i+1} = Gi | (Pi & Ci)
  genvar jj;
  generate
    for (jj = 0; jj < WIDTH; jj = jj + 1) begin
      assign w_G[jj]   = i_add1[jj] & i_add2[jj];
      assign w_P[jj]   = i_add1[jj] | i_add2[jj];
      assign w_C[jj+1] = r_G[jj] | (r_P[jj] & w_C[jj]);
    end
  endgenerate

  integer i;
  always @(posedge clk, posedge rst) begin
    if (rst) begin
      for (i = 0; i < WIDTH; i = i + 1) begin
        r_G[i] <= 0;
        r_P[i] <= 0;
        // r_C[i] <= 0;
      end
      // r_C[WIDTH] <= 0;
    end // rst
    else begin
      for (i = 0; i < WIDTH; i = i + 1) begin
        r_G[i] <= w_G[i];
        r_P[i] <= w_P[i];
        // r_C[i+1] <= r_G[i] | (r_P[i] & r_C[i]);
      end
    end
  end

  assign w_C[0]   = 1'b0;  // no carry input on first adder

  assign o_result = {w_C[WIDTH], w_SUM};  // Verilog Concatenation
endmodule  // carry_lookahead_adder
