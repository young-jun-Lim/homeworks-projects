
module dat_proc_unit_4bit(
    input load_enable,
    input [1:0] A_select, B_select, D_select, H_select,
    input MB_select, MF_select, MD_select,
    input [3:0]  constant_input, G_select, data_input,
    output [3:0] bus_A, bus_B,
    output V,C,N,Z
);
wire [3:0] B_beforeMUX, regdata, F, bus_D;
register_4bitX4 reg4bit(.load_enable(load_enable), .A_select(A_select), .B_select(B_select), .D_address(D_select),
                 .bus_D(regdata), .bus_A(bus_A), .bus_B(B_beforeMUX));
MUX4to1_4bit muxB(.select({MB_select, 1'b0}), .data_00(B_beforeMUX), .data_01(B_beforeMUX), 
                  .data_10(constant_input), .data_11(constant_input), .out(bus_B));
//2to1 mux using 4to1

function_unit_4bit funit(.busA(bus_A), .busB(bus_B), .G_select(G_select), .H_select(H_select), .MF_select(MF_select),
                         .F(F), .V(V), .C(C), .N(N), .Z(Z));
MUX4to1_4bit muxD(.select({MD_select, 1'b0}), .data_00(F), .data_01(F), 
                  .data_10(data_input), .data_11(data_input), .out(bus_D));
//2to1 mux using 4to1
endmodule


