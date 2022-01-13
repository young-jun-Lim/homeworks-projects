
module register_4bitX4(
    input load_enable,
    input [1:0] A_select, B_select, D_address,
    input [3:0] bus_D,
    output [3:0] bus_A, bus_B
);

reg [3:0] R0, R1, R2, R3;
initial begin
    R0<=4'b0000; R1<=4'b0000; R2<=4'b0000; R3<=4'b0000;
end

wire [3:0] address, load;

decoder2to4_4bit d2to4(.address(D_address), .out(load));

MUX4to1_4bit muxA(.select(A_select), .data_00(R0), .data_01(R1), .data_10(R2), .data_11(R3), .out(bus_A)),
                 (.select(B_select), .data_00(R0), .data_01(R1), .data_10(R2), .data_11(R3), .out(bus_B));

and and0(load[0],load_enable, address[0]), 
    and1(load[1],load_enable, address[1]), 
    and2(load[2],load_enable, address[2]), 
    and3(load[3],load_enable, address[3]);

always @(load[3:0], bus_D[3:0]) begin
    case(load[3:0])
        4'b0001: R0<=bus_D;
        4'b0010: R1<=bus_D;
        4'b0100: R2<=bus_D;
        4'b1000: R3<=bus_D;
        default: ;
    endcase
end

endmodule


module MUX4to1_4bit(
    input [1:0] select,
    input [3:0] data_00, data_01, data_10, data_11,
    output [3:0] out
);
assign out = (select == 2'b00) ? data_00:
             (select == 2'b01) ? data_01:
             (select == 2'b10) ? data_10:
             (select == 2'b11) ? data_11: 4'b0000;
/*always @(*) begin
    case (select)
        2'b00: out <= data_00;
        2'b01: out <= data_01;
        2'b10: out <= data_10;
        2'b11: out <= data_11;
    default: ;
    endcase
end*/
endmodule

module decoder2to4_4bit(
    input [1:0] address,
    output [3:0] out
);
assign out = (address == 2'b00) ? 4'b0001:
             (address == 2'b01) ? 4'b0010:
             (address == 2'b10) ? 4'b0100:
             (address == 2'b11) ? 4'b1000: 4'b0000;
/*always @(*) begin
    case (address)
        2'b00: out<=4'b0001;
        2'b01: out<=4'b0010;
        2'b10: out<=4'b0100;
        2'b11: out<=4'b1000;
    endcase
end*/
endmodule