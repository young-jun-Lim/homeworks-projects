`timescale 1ps/1ps
module tb_ALU_4bit;
reg [3:0] A, B, G_select;
wire [3:0] G;
wire C, V;

ALU_4bit alu(.A(A), .B(B), .G_select(G_select), .G(G), .V(V), .C(C));

initial begin
   A<=4'b0000; B<= 4'b0000; G_select<=4'b0000; 
    #10; A<= 4'b0011; B<=4'b1100; G_select <= 4'b0010;
    #10; A<= 4'b0011; B<=4'b1100; G_select <= 4'b0011;
    #10; A<= 4'b0011; B<=4'b1100; G_select <= 4'b0100;
    #10; A<= 4'b0011; B<=4'b1100; G_select <= 4'b0101;
    #10; A<= 4'b0011; B<=4'b1100; G_select <= 4'b1000;
    #10; A<= 4'b0011; B<=4'b1100; G_select <= 4'b1010;
end
endmodule