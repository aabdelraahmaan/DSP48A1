`timescale 1ns/1ps

module DSP48A1_tb;

reg [17:0] A, B, D;
reg [47:0] C;
reg CLK;
reg CARRYIN;
reg [7:0] OPMODE;
reg [17:0] BCIN;
reg RSTA, RSTB, RSTM, RSTP, RSTC, RSTD, RSTCARRYIN, RSTOPMODE;
reg CEA, CEB, CEM, CEP, CEC, CED, CECARRYIN, CEOPMODE;
reg [47:0] PCIN;
wire [17:0] BCOUT;
wire [47:0] PCOUT;
wire [47:0] P;
wire [35:0] M;
wire CARRYOUT, CARRYOUTF;

integer errors;

DSP48A1 dut (
    .A(A), .B(B), .D(D), .C(C), .CLK(CLK), .CARRYIN(CARRYIN),
    .OPMODE(OPMODE), .BCIN(BCIN),
    .RSTA(RSTA), .RSTB(RSTB), .RSTM(RSTM), .RSTP(RSTP), .RSTC(RSTC), .RSTD(RSTD),
    .RSTCARRYIN(RSTCARRYIN), .RSTOPMODE(RSTOPMODE),
    .CEA(CEA), .CEB(CEB), .CEM(CEM), .CEP(CEP), .CEC(CEC), .CED(CED),
    .CECARRYIN(CECARRYIN), .CEOPMODE(CEOPMODE),
    .PCIN(PCIN),
    .BCOUT(BCOUT), .PCOUT(PCOUT), .P(P), .M(M),
    .CARRYOUT(CARRYOUT), .CARRYOUTF(CARRYOUTF)
);

always #5 CLK = ~CLK;

task apply_reset;
begin
    RSTA = 1; RSTB = 1; RSTM = 1; RSTP = 1; RSTC = 1; RSTD = 1; RSTCARRYIN = 1; RSTOPMODE = 1;
    CEA = 0; CEB = 0; CEM = 0; CEP = 0; CEC = 0; CED = 0; CECARRYIN = 0; CEOPMODE = 0;
    A = 0; B = 0; C = 0; D = 0; CARRYIN = 0; OPMODE = 0; BCIN = 0; PCIN = 0;
    @(posedge CLK);
    RSTA = 0; RSTB = 0; RSTM = 0; RSTP = 0; RSTC = 0; RSTD = 0; RSTCARRYIN = 0; RSTOPMODE = 0;
    CEA = 1; CEB = 1; CEM = 1; CEP = 1; CEC = 1; CED = 1; CECARRYIN = 1; CEOPMODE = 1;
end
endtask

task check(input [47:0] actual, input [47:0] expected, input [127:0] name);
begin
    if (actual !== expected) begin
        errors = errors + 1;
        $display("FAIL %s expected=%0d actual=%0d time=%0t", name, expected, actual, $time);
    end else begin
        $display("PASS %s value=%0d time=%0t", name, actual, $time);
    end
end
endtask

initial begin
    CLK = 0;
    errors = 0;
    apply_reset;

    A = 18'd5; B = 18'd3; D = 18'd10; C = 48'd0; PCIN = 48'd0; CARRYIN = 0;
    OPMODE = 8'b00000001;
    @(posedge CLK); @(posedge CLK); @(posedge CLK); @(posedge CLK);
    check(P, 48'd15, "mult_5x3");

    A = 18'd7; B = 18'd2; D = 18'd4;
    OPMODE = 8'b00000001;
    @(posedge CLK); @(posedge CLK); @(posedge CLK); @(posedge CLK);
    check(P, 48'd14, "mult_7x2");

    A = 18'd6; B = 18'd4; D = 18'd9;
    OPMODE = 8'b00010001;
    @(posedge CLK); @(posedge CLK); @(posedge CLK); @(posedge CLK);
    check(P, 48'd78, "preadder_add_then_mult");

    A = 18'd0; B = 18'd0; D = 18'd0; C = 48'd100;
    OPMODE = 8'b00001100;
    @(posedge CLK); @(posedge CLK); @(posedge CLK); @(posedge CLK);
    check(P, 48'd100, "cport_passthrough");

    A = 18'd8; B = 18'd5; D = 18'd0; C = 48'd200;
    OPMODE = 8'b00001101;
    @(posedge CLK); @(posedge CLK); @(posedge CLK); @(posedge CLK);
    check(P, 48'd240, "multiply_add_c");

    A = 18'd8; B = 18'd5; D = 18'd0; C = 48'd240;
    OPMODE = 8'b10001101;
    @(posedge CLK); @(posedge CLK); @(posedge CLK); @(posedge CLK);
    check(P, 48'd200, "post_subtract");

    A = 18'd0; B = 18'd0; D = 18'd0; PCIN = 48'd500;
    OPMODE = 8'b00000100;
    @(posedge CLK); @(posedge CLK); @(posedge CLK); @(posedge CLK);
    check(P, 48'd500, "pcin_passthrough");

    A = 18'd0; B = 18'd0; D = 18'd0; C = 48'd50;
    OPMODE = 8'b00101100;
    @(posedge CLK); @(posedge CLK); @(posedge CLK); @(posedge CLK);
    check(P, 48'd51, "carryin_add");

    $display("TEST COMPLETE ERRORS=%0d", errors);
    $stop;
end

endmodule