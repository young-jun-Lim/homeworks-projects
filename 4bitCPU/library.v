module SRlatch(
    input S,   input R,   input C,    output Q,    output notQ
);
wire n1, n2;
nand nand1(n1,S,C),
     nand2(n2,C,R),
     nand3(Q,notQ,n1),
     mamd4(notQ,Q,n2);
endmodule

module Dlatch(
    input D,    input C,    output Q,    output notQ
);
wire n1, n2;
nand nand1(n1,D,C),
     nand2(n2,C,D),
     nand3(Q,notQ,n1),
     mamd4(notQ,Q,n2);
endmodule

module flipflop_SR(
    input S,    input R,    input C,    output Q,    output notQ
);
wire master_Q, master_notQ, notC;
not not1(notC,C);
SRlatch master(.S(S), .C(C), .R(R), .Q(master_Q), .notQ(master_notQ)),
        slave(.S(master_Q), .C(notC), .R(master_notQ), .Q(Q), .notQ(notQ));
endmodule

module flipflop_D(
    input D,    input C,    output Q,    output notQ
);
wire master_Q, master_notQ, notC;
not not1(notC,C);
Dlatch master(.D(D), .C(C), .Q(master_Q), .notQ(master_notQ));
SRlatch slave(.S(master_Q), .C(notC), .R(master_notQ), .Q(Q), .notQ(notQ));
endmodule

module flipflop_JK(
    input J,    input K,    input C,    output Q,    output notQ
);
wire w1,w2,w3;
wire D;
and and1(w1,J,notQ),
    and2(w3,w2,Q);
not not1(w2,K);
or or1(D,w1,w3);
Dlatch dlatch(.D(D), .C(C), .Q(Q), .notQ(notQ));
endmodule

module flipflop_T(
    input T,    input C,    output Q,    output notQ
);
wire D;
xor xor1(D,T,Q);
Dlatch dlatch(.D(D), .C(C), .Q(Q), .notQ(notQ));
endmodule

module full_adder(
    input A,B,Cin,
    output S,Cout
);
wire p, r, s;
xor (p,A,B),
    (S,p,Cin);
and (r,p,Cin),
    (s,A,B);
or (Cout,r,s);
endmodule