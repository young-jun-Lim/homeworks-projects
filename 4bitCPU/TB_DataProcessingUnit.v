
module tb_dat_proc_unit_4bit;

reg load_enable, MB_select, MF_select, MD_select;
reg [1:0] A_select, B_select, D_select, H_select;
reg [3:0] constant_input, G_select, data_input;

wire [3:0] bus_A, bus_B;
wire V,C,N,Z;

dat_proc_unit_4bit d4bit(.load_enable(load_enable), .A_select(A_select), .B_select(B_select),
                         .D_select(D_select), .H_select(H_select), .MB_select(MB_select), .MD_select(MD_select),
                         .constant_input(constant_input), .G_select(G_select), .data_input(data_input), 
                         .bus_A(bus_A), .bus_B(bus_B), .V(V), .C(C), .N(N), .Z(Z));

initial begin
    load_enable<=0; MB_select<=0; MF_select<=0; MD_select<=0;
    A_select<=2'b00; B_select<=2'b00; D_select<=2'b00; H_select<=2'b00;
    constant_input<=4'b0000; G_select<=4'b0000; data_input<=4'b0000;
end

endmodule