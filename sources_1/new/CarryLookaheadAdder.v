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

  reg [WIDTH-1:0] r_add1[WIDTH-1:0];
  reg [WIDTH-1:0] r_add2[WIDTH-1:0];
  reg [  WIDTH:0] r_C[WIDTH-1:0];
  reg [WIDTH-1:0] r_G [WIDTH-1:0], r_P[WIDTH-1:0], r_SUM[WIDTH:0];

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
      assign w_G[jj] = i_add1[jj] & i_add2[jj];
      assign w_P[jj] = i_add1[jj] | i_add2[jj];
      assign w_C[jj+1] = w_G[jj] | (w_P[jj] & w_C[jj]);
    end
  endgenerate

  integer i;
  integer j;
  always @(posedge clk, posedge rst) begin
    if (rst) begin
      for (i = 0; i < WIDTH; i = i + 1) begin
        r_G[i] <= 0;
        r_P[i] <= 0;
        r_C[i] <= 0;
        r_SUM[i] <= 0;
        r_add1[i] <= 0;
        r_add2[i] <= 0;
      end
      r_C[WIDTH] = 0;
    end // rst
    else begin
      r_add1[0] <= i_add1;
      r_add2[0] <= i_add2;
      r_SUM[WIDTH] <= r_SUM[WIDTH-1];
      for (j = 0; j < WIDTH; j = j + 1) begin
        r_SUM[0][j] <= r_add1[0][j] + r_add2[0][j] + r_C[0][j];
        r_G[0][j]   <= r_add1[0][j] & r_add2[0][j];
        r_P[0][j]   <= r_add1[0][j] | r_add2[0][j];
        r_C[0+1][j] = r_G[0][j] | (r_P[0][j] & r_C[0][j]);
      end
      for (i = 1; i < WIDTH; i = i + 1) begin
        r_add1[i] <= r_add1[i-1];
        r_add2[i] <= r_add2[i-1];
        for (j = 0; j < WIDTH; j = j + 1) begin
          r_SUM[i][j] <= r_add1[i][j] + r_add2[i][j] + r_C[i-1][j];
          r_G[i]   <= r_G[i-1];
          r_P[i]   <= r_P[i-1];
          r_C[i][j+1] = r_G[i][j] | (r_P[i][j] & r_C[i][j]);
        end
      end
    end
  end

  assign w_C[0]   = 1'b0;  // no carry input on first adder

  assign o_result = {r_C[WIDTH-1][WIDTH], r_SUM[WIDTH]};  // Verilog Concatenation
endmodule  // carry_lookahead_adder
