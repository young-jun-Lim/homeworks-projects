
module function_unit_4bit(
    input [3:0] busA, busB, G_select,
    input [1:0] H_select,
    input MF_select,
    output [3:0] F,
    output V,C,N,Z
);

wire [3:0] G, H;

ALU_4bit alu(.A(busA), .B(busB), .G_select(G_select), .G(G), .V(V), .C(C));
shifter_4bit_normal sfter(.B(busB), .S(H_select), .IR(1'b0), .IL(1'b0), .H(H));
assign N=G[3];
assign Z=|G; //Z=G[3]|G[2]|G[1]|G[0]
MUX4to1_4bit muxF(.select({MF_select, 1'b0}), .data_00(G), .data_01(G), .data_10(H), .data_11(H));


endmodule


module ALU_4bit(
    input [3:0] A, B, G_select,
    output [3:0] G,
    output V,C
);
wire [3:0] arithmetic_out, logical_out;
//G: |logic/arithmetic|[1:0]S|Cin|
arithmetic_4bit a4bit(.Cin(G_select[0]), .A(A), .B(B), .sel(G_select[2:1]), .G(arithmetic_out), .Cout(C), .V(V));
logic_4bit l4bit(.A(A), .B(B), .sel(G_select[2:1]), .G(logical_out));

MUX4to1_4bit two_one(.select({G_select[3], 1'b0}), .data_00(arithmetic_out), .data_01(arithmetic_out), .data_10(logical_out), .data_11(logical_out), .out(G));
//2to1 mux using 4to1
/*always @(*) begin
    case(G_select)
        4'b0000: G<=A;
        4'b0001: G<=A+1;
        4'b0010: G<=A+B;
        4'b0011: G<=A+B+1;
        4'b0100: G<=A+(B^4'b1111);
        4'b0101: G<=A+(B^4'b1111)+1;
        4'b0110: G<=A-1;
        4'b0111: G<=A;
        4'b1x00: G<=A&B;
        4'b1x01: G<=A|B;
        4'b1x10: G<=A^B;
        4'b1x11: G<=~A;
        default: ;
    endcase
end*/

endmodule

module arithmetic_4bit(
    input Cin,
    input [3:0] A, B,
    input [1:0] sel,
    output [3:0] G,
    output Cout,
    output V
);
wire [3:0] operand;
wire [2:0] carry;
assign operand = (B&{sel[0],sel[0],sel[0],sel[0]})|((~B)&{sel[1],sel[1],sel[1],sel[1]});
assign V=Cout^carry[2];
full_adder FA0(.A(A[0]), .B(operand[0]), .Cin(Cin), .S(G[0]), .Cout(carry[0])),
           FA1(.A(A[1]), .B(operand[1]), .Cin(carry[0]), .S(G[1]), .Cout(carry[1])),
           FA2(.A(A[2]), .B(operand[2]), .Cin(carry[1]), .S(G[2]), .Cout(carry[2])),
           FA3(.A(A[3]), .B(operand[3]), .Cin(carry[2]), .S(G[3]), .Cout(Cout));
endmodule

module logic_4bit(
    input [3:0] A, B,
    input [1:0] sel,
    output [3:0] G
);
wire [3:0] op_and, op_or, op_xor, op_not;
assign op_and=A&B;
assign op_or=A|B;
assign op_xor=A^B;
assign op_not=~A;

MUX4to1_4bit logmux(.select(sel), .data_00(op_and), .data_01(op_or), .data_10(op_xor), .data_11(op_not), .out(G));
endmodule

module shifter_4bit_normal(
    input [3:0] B,
    input [1:0] S,
    input IR, IL,
    output [3:0] H
);
mux4to1_1bit muxH3(.select(S), .data_0(B[3]), .data_1(IR), .data_2(B[2]), .data_3(B[3]), .out(H[3])),
             muxH2(.select(S), .data_0(B[2]), .data_1(B[3]), .data_2(B[1]), .data_3(B[2]), .out(H[2])),
             muxH1(.select(S), .data_0(B[1]), .data_1(B[2]), .data_2(B[0]), .data_3(B[1]), .out(H[1])),
             muxH0(.select(S), .data_0(B[0]), .data_1(B[1]), .data_2(IL), .data_3(B[0]), .out(H[0]));

endmodule

module shifter_4bit_barrel(
    input [3:0] B,
    input [1:0] S,
    output [3:0] H
);
mux4to1_1bit muxH3(.select(S), .data_0(B[3]), .data_1(B[2]), .data_2(B[1]), .data_3(B[0]), .out(H[3])),
             muxH2(.select(S), .data_0(B[2]), .data_1(B[1]), .data_2(B[0]), .data_3(B[3]), .out(H[2])),
             muxH1(.select(S), .data_0(B[1]), .data_1(B[0]), .data_2(B[3]), .data_3(B[2]), .out(H[1])),
             muxH0(.select(S), .data_0(B[0]), .data_1(B[3]), .data_2(B[2]), .data_3(B[1]), .out(H[0]));
/*always @(*) begin
    case(S)
    2'b00: H<=H;
    2'b01: rotate 1bit left
    2'b10: rotate 2bit left
    2'b11: rotate 3bit left
end*/
endmodule



module mux4to1_1bit(
    input [1:0] select,
    input data_0, data_1, data_2, data_3,
    output out
);
assign out= (select==2'b00) ? data_0:
           (select==2'b01) ? data_1:
           (select==2'b10) ? data_2:
           (select==2'b11) ? data_3: 1'b0;
endmodule