module DSP48A1 #(
    parameter A0REG = 0,
    parameter A1REG = 1,
    parameter B0REG = 0,
    parameter B1REG = 1,
    parameter CREG = 1,
    parameter DREG = 1,
    parameter MREG = 1,
    parameter PREG = 1,
    parameter CARRYINREG = 1,
    parameter CARRYOUTREG = 1,
    parameter OPMODEREG = 1,
    parameter CARRYINSEL = "OPMODE5",
    parameter B_INPUT = "DIRECT",
    parameter RSTTYPE = "SYNC"
)(
    input  [17:0] A,
    input  [17:0] B,
    input  [17:0] D,
    input  [47:0] C,
    input  CLK,
    input  CARRYIN,
    input  [7:0] OPMODE,
    input  [17:0] BCIN,
    input  RSTA,
    input  RSTB,
    input  RSTM,
    input  RSTP,
    input  RSTC,
    input  RSTD,
    input  RSTCARRYIN,
    input  RSTOPMODE,
    input  CEA,
    input  CEB,
    input  CEM,
    input  CEP,
    input  CEC,
    input  CED,
    input  CECARRYIN,
    input  CEOPMODE,
    input  [47:0] PCIN,
    output [17:0] BCOUT,
    output [47:0] PCOUT,
    output [47:0] P,
    output [35:0] M,
    output CARRYOUT,
    output CARRYOUTF
);

wire [17:0] b_sel;
assign b_sel = (B_INPUT == "CASCADE") ? BCIN : B;

reg [17:0] d_reg;
wire [17:0] d0;
generate
if (DREG == 1) begin : DREG_GEN
    if (RSTTYPE == "ASYNC") begin
        always @(posedge CLK or posedge RSTD)
            if (RSTD) d_reg <= 18'b0;
            else if (CED) d_reg <= D;
    end else begin
        always @(posedge CLK)
            if (RSTD) d_reg <= 18'b0;
            else if (CED) d_reg <= D;
    end
    assign d0 = d_reg;
end else begin
    assign d0 = D;
end
endgenerate

reg [17:0] a0_reg;
wire [17:0] a0;
generate
if (A0REG == 1) begin : A0REG_GEN
    if (RSTTYPE == "ASYNC") begin
        always @(posedge CLK or posedge RSTA)
            if (RSTA) a0_reg <= 18'b0;
            else if (CEA) a0_reg <= A;
    end else begin
        always @(posedge CLK)
            if (RSTA) a0_reg <= 18'b0;
            else if (CEA) a0_reg <= A;
    end
    assign a0 = a0_reg;
end else begin
    assign a0 = A;
end
endgenerate

reg [17:0] a1_reg;
wire [17:0] a1;
generate
if (A1REG == 1) begin : A1REG_GEN
    if (RSTTYPE == "ASYNC") begin
        always @(posedge CLK or posedge RSTA)
            if (RSTA) a1_reg <= 18'b0;
            else if (CEA) a1_reg <= a0;
    end else begin
        always @(posedge CLK)
            if (RSTA) a1_reg <= 18'b0;
            else if (CEA) a1_reg <= a0;
    end
    assign a1 = a1_reg;
end else begin
    assign a1 = a0;
end
endgenerate

reg [17:0] b0_reg;
wire [17:0] b0;
generate
if (B0REG == 1) begin : B0REG_GEN
    if (RSTTYPE == "ASYNC") begin
        always @(posedge CLK or posedge RSTB)
            if (RSTB) b0_reg <= 18'b0;
            else if (CEB) b0_reg <= b_sel;
    end else begin
        always @(posedge CLK)
            if (RSTB) b0_reg <= 18'b0;
            else if (CEB) b0_reg <= b_sel;
    end
    assign b0 = b0_reg;
end else begin
    assign b0 = b_sel;
end
endgenerate

reg [7:0] opmode_reg;
wire [7:0] opmode_int;
generate
if (OPMODEREG == 1) begin : OPMODEREG_GEN
    if (RSTTYPE == "ASYNC") begin
        always @(posedge CLK or posedge RSTOPMODE)
            if (RSTOPMODE) opmode_reg <= 8'b0;
            else if (CEOPMODE) opmode_reg <= OPMODE;
    end else begin
        always @(posedge CLK)
            if (RSTOPMODE) opmode_reg <= 8'b0;
            else if (CEOPMODE) opmode_reg <= OPMODE;
    end
    assign opmode_int = opmode_reg;
end else begin
    assign opmode_int = OPMODE;
end
endgenerate

wire [17:0] preadder_out;
assign preadder_out = opmode_int[4] ? (opmode_int[6] ? (d0 - b0) : (d0 + b0)) : b0;

reg [17:0] b1_reg;
wire [17:0] b1;
generate
if (B1REG == 1) begin : B1REG_GEN
    if (RSTTYPE == "ASYNC") begin
        always @(posedge CLK or posedge RSTB)
            if (RSTB) b1_reg <= 18'b0;
            else if (CEB) b1_reg <= preadder_out;
    end else begin
        always @(posedge CLK)
            if (RSTB) b1_reg <= 18'b0;
            else if (CEB) b1_reg <= preadder_out;
    end
    assign b1 = b1_reg;
end else begin
    assign b1 = preadder_out;
end
endgenerate

assign BCOUT = b1;

wire signed [35:0] mult_result;
assign mult_result = $signed(a1) * $signed(b1);

reg [35:0] m_reg;
wire [35:0] m_out;
generate
if (MREG == 1) begin : MREG_GEN
    if (RSTTYPE == "ASYNC") begin
        always @(posedge CLK or posedge RSTM)
            if (RSTM) m_reg <= 36'b0;
            else if (CEM) m_reg <= mult_result;
    end else begin
        always @(posedge CLK)
            if (RSTM) m_reg <= 36'b0;
            else if (CEM) m_reg <= mult_result;
    end
    assign m_out = m_reg;
end else begin
    assign m_out = mult_result;
end
endgenerate

assign M = m_out;

reg [47:0] c_reg;
wire [47:0] c0;
generate
if (CREG == 1) begin : CREG_GEN
    if (RSTTYPE == "ASYNC") begin
        always @(posedge CLK or posedge RSTC)
            if (RSTC) c_reg <= 48'b0;
            else if (CEC) c_reg <= C;
    end else begin
        always @(posedge CLK)
            if (RSTC) c_reg <= 48'b0;
            else if (CEC) c_reg <= C;
    end
    assign c0 = c_reg;
end else begin
    assign c0 = C;
end
endgenerate

reg cyi_reg;
wire cyi;
generate
if (CARRYINREG == 1) begin : CARRYINREG_GEN
    if (RSTTYPE == "ASYNC") begin
        always @(posedge CLK or posedge RSTCARRYIN)
            if (RSTCARRYIN) cyi_reg <= 1'b0;
            else if (CECARRYIN) cyi_reg <= CARRYIN;
    end else begin
        always @(posedge CLK)
            if (RSTCARRYIN) cyi_reg <= 1'b0;
            else if (CECARRYIN) cyi_reg <= CARRYIN;
    end
    assign cyi = cyi_reg;
end else begin
    assign cyi = CARRYIN;
end
endgenerate

wire cin_val;
assign cin_val = (CARRYINSEL == "CARRYIN") ? cyi :
                  (CARRYINSEL == "OPMODE5") ? opmode_int[5] : 1'b0;

wire [47:0] dab_concat;
assign dab_concat = {d0[11:0], a1, b1};

wire [47:0] p_out;

reg [47:0] x_mux, z_mux;
always @(*) begin
    case (opmode_int[1:0])
        2'b00: x_mux = 48'b0;
        2'b01: x_mux = {{12{m_out[35]}}, m_out};
        2'b10: x_mux = p_out;
        2'b11: x_mux = dab_concat;
        default: x_mux = 48'b0;
    endcase
    case (opmode_int[3:2])
        2'b00: z_mux = 48'b0;
        2'b01: z_mux = PCIN;
        2'b10: z_mux = p_out;
        2'b11: z_mux = c0;
        default: z_mux = 48'b0;
    endcase
end

wire signed [48:0] sum_result;
wire [47:0] post_result;
wire carry_bit;

assign sum_result = opmode_int[7] ? ({1'b0,z_mux} - ({1'b0,x_mux} + cin_val)) : ({1'b0,x_mux} + {1'b0,z_mux} + cin_val);
assign post_result = sum_result[47:0];
assign carry_bit = sum_result[48];

reg [47:0] p_reg;
generate
if (PREG == 1) begin : PREG_GEN
    if (RSTTYPE == "ASYNC") begin
        always @(posedge CLK or posedge RSTP)
            if (RSTP) p_reg <= 48'b0;
            else if (CEP) p_reg <= post_result;
    end else begin
        always @(posedge CLK)
            if (RSTP) p_reg <= 48'b0;
            else if (CEP) p_reg <= post_result;
    end
    assign p_out = p_reg;
end else begin
    assign p_out = post_result;
end
endgenerate

assign P = p_out;
assign PCOUT = p_out;

reg cyo_reg;
wire cyo;
generate
if (CARRYOUTREG == 1) begin : CARRYOUTREG_GEN
    if (RSTTYPE == "ASYNC") begin
        always @(posedge CLK or posedge RSTCARRYIN)
            if (RSTCARRYIN) cyo_reg <= 1'b0;
            else if (CECARRYIN) cyo_reg <= carry_bit;
    end else begin
        always @(posedge CLK)
            if (RSTCARRYIN) cyo_reg <= 1'b0;
            else if (CECARRYIN) cyo_reg <= carry_bit;
    end
    assign cyo = cyo_reg;
end else begin
    assign cyo = carry_bit;
end
endgenerate

assign CARRYOUT = cyo;
assign CARRYOUTF = cyo;

endmodule