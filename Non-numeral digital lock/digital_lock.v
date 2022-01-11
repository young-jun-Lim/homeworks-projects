
module digital_lock(
    input wire clk,
	input wire switch,
	input wire led_mat_s5witch,
    input wire rst,
    input wire [11:0] key, //key[0] = 1, key[12] #

	 output wire [3:0] led_array,

	 output wire [6:0] seg_display,
	 output wire [7:0] array_en,

     output wire servo,

     output wire piezo,
     

	
		output wire [3:0] R, G, B
);
//key 1~9 = password input
//key # = cancel
//key 0 = password enter
//key * : undo
wire [1:0] mode;
wire [1:0] cursor;
wire [8:0] pw_ent;
wire pwset_available;

wire motorclk;
//*0#




main m1(.rst(rst), .clk(clk), .button(key[11:9]), .key(key[8:0]), .switch(switch), .mode(mode),
        .cursor(cursor), .current_pw(pw_ent), .pwset_available(pwset_available));
 
led_arr ledar(.rst(rst), .clk(clk), .mode(mode), .cursor(cursor), .led_array(led_array));

segmentcontrol segcon(.rst(rst), .pwset_available(pwset_available), .mode(mode), .clk(clk),
                      .seg_display(seg_display), .array_en(array_en)); 

							 
piezo pz(.rst(rst), .clk(clk), .mode(mode), .piezo(piezo));


servo sv(.rst(rst), .clk(clk), .mode(mode), .servo(servo));

colorLED cld(.mode(mode), .rst(rst), .clk(clk), .R(R), .G(G), .B(B));


endmodule




module main(
	 input wire rst,
    input wire clk,          // clock
    input wire [2:0] button, // button[2] = # cancel button[1] = 0 enter button[0] = * undo
    input wire [8:0] key,    // key input
	input wire switch,
    output reg [1:0] mode,
    output reg [1:0] cursor,
    output reg [8:0] current_pw,
	 output reg pwset_available
    );

//reg [1:0] mode;
//mode : 0 normal state
//mode : 1 password setting
//mode : 2 opened
//mode : 3 password locked
 // cursor to locate present location


 
reg [11:0] modetime0;
reg [11:0] modetime1;

reg [8:0] pw_0_set, pw_1_set, pw_2_set, pw_3_set;//set password
reg [8:0] pw_0_ent, pw_1_ent, pw_2_ent, pw_3_ent;//entered password

reg pw_check;
//reg pwset_available;
reg [1:0] button_precedent; //only used for button 2 and 3



function [8:0] password_enter; //entering password task
    input [8:0] key;
    input [8:0] pw_en;
    begin
        password_enter = pw_en | key;
    end
endfunction

function password_check;
    input [8:0] current_pw_0;
    input [8:0] current_pw_1;
    input [8:0] current_pw_2;
    input [8:0] current_pw_3;

    input [8:0] entered_pw_0;
    input [8:0] entered_pw_1;
    input [8:0] entered_pw_2;
    input [8:0] entered_pw_3;


    reg [3:0] check;

    begin 
    check[0] = (current_pw_0 == entered_pw_0);
    check[1] = (current_pw_1 == entered_pw_1);
    check[2] = (current_pw_2 == entered_pw_2);
    check[3] = (current_pw_3 == entered_pw_3);

    password_check = &check;
    end
endfunction

task reset; //reset cursor and entered password
    output cursor;
    output [8:0] pw_0_new;
    output [8:0] pw_1_new;
    output [8:0] pw_2_new;
    output [8:0] pw_3_new;
	 output [8:0] current_pw_new;

    begin
        cursor = 2'd0;
        pw_0_new = 9'd0;
        pw_1_new = 9'd0;
        pw_2_new = 9'd0;
        pw_3_new = 9'd0;
		  current_pw_new = 9'd0;
    end
endtask

initial begin 
    mode <= 2'd0; 
    cursor <= 2'd0;
    pw_check <= 1'd0;
    pwset_available <= 1'd0;
    button_precedent <= 2'd0; 

    pw_0_set <= 9'd0;
    pw_1_set <= 9'd0;
    pw_2_set <= 9'd0;
    pw_3_set <= 9'd0;

    pw_0_ent <= 9'd0;
    pw_1_ent <= 9'd0;
    pw_2_ent <= 9'd0;
    pw_3_ent <= 9'd0;
	 current_pw <= 9'd0;
	 
	 modetime0 <= 12'd0;
	 modetime1 <= 12'd0;
    
end // initial setting

always @(posedge clk or posedge rst) begin
// or posedge button[0] or posedge button[1] or posedge button[2] or posedge button[3]
if (rst) begin
mode <= 2'd0; 
    cursor <= 2'd0;
    pw_check <= 1'd0;
    pwset_available <= 1'd0;
    button_precedent <= 2'd0; 

    pw_0_set <= 9'd0;
    pw_1_set <= 9'd0;
    pw_2_set <= 9'd0;
    pw_3_set <= 9'd0;

    pw_0_ent <= 9'd0;
    pw_1_ent <= 9'd0;
    pw_2_ent <= 9'd0;
    pw_3_ent <= 9'd0;
	 current_pw <= 9'd0;
	 modetime0 <= 12'd0;
	 modetime1 <= 12'd0;
end
else begin
	  
	  if(mode == 2'd2 || mode == 2'd3) begin
			modetime0 = modetime0 + 1'b1;
			if(modetime0 == 12'b1111_1111_1111) begin 
			modetime1 = modetime1 + 1'b1;
			modetime0 = 12'b0;
			end
			if(modetime1 == 12'b0000_0000_1111) begin
				modetime0 = 12'b0;
				modetime1 = 10'd0;
				mode = 2'd0;
			end
	  end
	 else begin
    if (button[2] == 1'd1) begin // cancel
        mode <= 2'd0; // mode : normal state
        pw_0_ent <= 9'd0;
        pw_1_ent <= 9'd0;
        pw_2_ent <= 9'd0;
        pw_3_ent <= 9'd0; //entered password initialize
        cursor <= 2'd0;
        pw_check <= 1'd0;
    end

    else begin //if button[0] == 0

        if (switch == 1'd1) begin //pwsetting
            mode <= 2'd1; // mode : password setting
            pw_0_ent <= 9'd0;
            pw_1_ent <= 9'd0;
            pw_2_ent <= 9'd0;
            pw_3_ent <= 9'd0; //entered password initialize
            cursor <= 2'd0;
            pw_check <= 1'd0;
        end

        else begin //if button[1] == 0

            if (button[1] == 1'd0 && button[0] == 1'd0) begin  // if no button is pushed

                if (cursor == 2'd0) begin 
                    pw_0_ent = password_enter (key, pw_0_ent); 
                    current_pw = pw_0_ent;
                end
                else if (cursor == 2'd1) begin 
                    pw_1_ent = password_enter (key, pw_1_ent); 
                    current_pw = pw_1_ent;
                end
                else if (cursor == 2'd2) begin 
                    pw_2_ent = password_enter (key, pw_2_ent); 
                    current_pw = pw_2_ent;
                end
                else if (cursor == 2'd3) begin 
                    pw_3_ent = password_enter (key, pw_3_ent); 
                    current_pw = pw_3_ent;
                end
                
                button_precedent = 2'd0;
            end //entering password

            else if ((button[1] == 1'd1 && button[0] == 1'd0) && button_precedent[1] == 1'd0) begin // if 'enter' button pushed

                if (cursor == 2'd3) begin //if password is full-entered
                    if (pwset_available == 1'd1) begin
                        pw_0_set <= pw_0_ent;
                        pw_1_set <= pw_1_ent;
                        pw_2_set <= pw_2_ent;
                        pw_3_set <= pw_3_ent; //current password change
                        reset(cursor, pw_0_ent, pw_1_ent, pw_2_ent, pw_3_ent, current_pw);
                        pwset_available = 1'd0;
                        mode = 2'd0; //return to normal state
                        //password_reset;
                    end
                    else begin
                        pw_check = password_check (pw_0_set, pw_1_set, pw_2_set, pw_3_set, pw_0_ent, pw_1_ent, pw_2_ent, pw_3_ent);

                        if (mode == 2'd0) begin // normal state
                            if (pw_check == 1'd1) begin //password correct
                                mode = 2'd2;
                                pw_check = 1'd0;   
                                reset(cursor, pw_0_ent, pw_1_ent, pw_2_ent, pw_3_ent, current_pw);
                                //open; // TBD
                            end
                            else if (pw_check == 1'd0) begin //password wrong
                                mode = 2'd3;
                                reset(cursor, pw_0_ent, pw_1_ent, pw_2_ent, pw_3_ent, current_pw);
                                //lock; // TBD
                            end
									 
                        end
                    
                        else if (mode == 2'd1) begin //password setting
                            if(pw_check == 1'd1) begin //password correct
                                pwset_available <= 1'd1;
                                pw_check = 1'd0;
                                reset(cursor, pw_0_ent, pw_1_ent, pw_2_ent, pw_3_ent, current_pw); 
                            end
                            else if(pw_check == 1'd0) begin //password correct
                                mode = 2'd3;
                                reset(cursor, pw_0_ent, pw_1_ent, pw_2_ent, pw_3_ent, current_pw); 
                            //lock; // TBD
                            end
                        end // if password is fully entered, do password check
                    end
                end
                else begin
                    cursor = cursor + 1'b1;
                end //else, cursor moved

                button_precedent[1] = 1'd1; // button already pushed
            end

            else if (button[0] == 1'd1 && button_precedent[0] == 1'd0) begin //if 'undo' button entered
                if (cursor == 2'd0) begin
                    pw_0_ent = 9'd0;
						  pw_1_ent = 9'd0;
					   	pw_2_ent = 9'd0;
							pw_3_ent = 9'd0;
                end
                else if (cursor == 2'd1) begin
                    if(pw_1_ent == 9'd0) begin // when password wasn't entered, go to previous password
                        cursor = cursor - 1'd1;
								pw_0_ent = 9'd0;
                    end
                    else begin                //when password was being entered, reset the current-entered password
                        pw_1_ent = 9'd0;
								pw_2_ent = 9'd0;
								pw_3_ent = 9'd0;
                    end
                end
                else if (cursor == 2'd2) begin
                    if(pw_2_ent == 9'd0) begin
								pw_1_ent = 9'd0;
                        cursor = cursor - 1'd1;
                    end
                    else begin
                        pw_2_ent = 9'd0;
								pw_3_ent = 9'd0;
                    end
                end
                else if (cursor == 2'd3) begin
                    if(pw_3_ent == 12'd0) begin
						  pw_2_ent = 9'd0;
                        cursor = cursor - 1'd1;
                    end
                    else begin
                        pw_3_ent = 9'd0;
                    end
                end 
					 current_pw = 9'd0;
                button_precedent[0] = 1'd1; //button already pushed
            end
        end
    end
	 end
end
end




endmodule





module led_arr(
    input wire rst,
	input wire clk,
	input wire [1:0] mode,
	input wire [1:0] cursor,
	output reg [3:0] led_array
); //module to use LED array
initial led_array <= 4'b0000;


always @(posedge clk or posedge rst) begin
    if(rst) begin
        led_array <= 4'b0000;
    end
    else begin
	if(mode == 2'd0 || mode == 2'd1) begin
		if(cursor == 2'd1) led_array <= 4'b0001;
		else if(cursor == 2'd2) led_array <= 4'b0011;
		else if(cursor == 2'd3) led_array <= 4'b0111;
		else led_array <= 4'b0000;
	end
	else begin
		led_array <= 4'b1111;
	end
    end
end

endmodule

module segmentcontrol(
input rst,
input wire pwset_available,
input wire [1:0] mode,
input wire clk,
output reg [6:0] seg_display,
output reg [7:0] array_en 
); //module to use 7-segment display
reg [6:0] seg0;
reg [6:0] seg1;
reg [6:0] seg2;
reg [6:0] seg3;
reg [6:0] seg4;
reg [6:0] seg5;
reg [6:0] seg6;
reg [6:0] seg7;


initial begin
array_en <= 8'b0000_0001; seg_display <= 7'd0;
seg0 <= 7'd0;
seg1 <= 7'd0;
seg2 <= 7'd0;
seg3 <= 7'd0;
seg4 <= 7'd0;
seg5 <= 7'd0;
seg6 <= 7'd0;
seg7 <= 7'd0;
end
//mode : 0 normal state
//mode : 1 password setting
//mode : 2 opened
//mode : 3 password locked
always @(posedge clk or posedge rst) begin
    if(rst) begin
        array_en <= 8'b1111_1110; seg_display <= 7'd0;
seg0 <= 7'd0;
seg1 <= 7'd0;
seg2 <= 7'd0;
seg3 <= 7'd0;
seg4 <= 7'd0;
seg5 <= 7'd0;
seg6 <= 7'd0;
seg7 <= 7'd0;
    end
    else begin
	if(pwset_available == 1'b1) begin
		seg0 <= 7'b0010101; // n
		seg1 <= 7'b1001111; // E
		seg2 <= 7'b0011100; // w
		seg3 <= 7'b0011000; // w
		seg4 <= 7'b0000000; // 
		seg5 <= 7'b1100111; // P
		seg6 <= 7'b0011100; // w
		seg7 <= 7'b0011000; // w
	end
	else if(mode == 2'd0) begin
		seg0 <= 7'b1001111; // E
		seg1 <= 7'b0010101; // n
		seg2 <= 7'b0001111; // t
		seg3 <= 7'b1001111; // E
		seg4 <= 7'b0000101; // r
		seg5 <= 7'b0000000;
		seg6 <= 7'b0000000;
		seg7 <= 7'b0000000;
	end
	else if(mode == 2'd1) begin 
		seg0 <= 7'b1001111; // E
		seg1 <= 7'b0010101; // n
		seg2 <= 7'b0001111; // t
		seg3 <= 7'b1001111; // E
		seg4 <= 7'b0000101; // r
		seg5 <= 7'b1100111; // P
		seg6 <= 7'b0011100; // w
		seg7 <= 7'b0011000; // w
	end
	else if(mode == 2'd2) begin
		seg0 <= 7'b0000000;
		seg1 <= 7'b0000000;
		seg2 <= 7'b1111110; // O
		seg3 <= 7'b1100111; // P
		seg4 <= 7'b1001111; // E
		seg5 <= 7'b0010101; // n
		seg6 <= 7'b0000000;
		seg7 <= 7'b0000000;
	end
	else if(mode == 2'd3) begin
		seg0 <= 7'b0000000; 
		seg1 <= 7'b0000000; // 
		seg2 <= 7'b0001110; // L
		seg3 <= 7'b1111110; // O
		seg4 <= 7'b1001110; // C
		seg5 <= 7'b1010111; // K
		seg6 <= 7'b0000000; // 
		seg7 <= 7'b0000000;
	end
	else begin
		seg0 <= 7'd0;
		seg1 <= 7'd0;
		seg2 <= 7'd0;
		seg3 <= 7'd0;
		seg4 <= 7'd0;
		seg5 <= 7'd0;
		seg6 <= 7'd0;
		seg7 <= 7'd0;
	end
     array_en = {array_en[6:0] , array_en[7]};
	
	if(array_en == 8'b1111_1110) seg_display <= seg0;
	else if(array_en == 8'b1111_1101) seg_display <= seg1;
	else if(array_en == 8'b1111_1011) seg_display <= seg2;
	else if(array_en == 8'b1111_0111) seg_display <= seg3;
	else if(array_en == 8'b1110_1111) seg_display <= seg4;
	else if(array_en == 8'b1101_1111) seg_display <= seg5;
	else if(array_en == 8'b1011_1111) seg_display <= seg6;
	else if(array_en == 8'b0111_1111) seg_display <= seg7;
    end
	
end


endmodule


module piezo (
    input rst,
    input clk,
    input [1:0] mode,
    output reg piezo
); //module to use piezo, alert when pw is wrong




initial begin 
    piezo = 0;
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        piezo <= 0;

    end
    else begin
        if(mode == 2'd3) begin   //if mode == lock, alert'
		   piezo <= ~piezo;
        end
        else begin
            piezo <= 0;

        end
    end
    
end

endmodule

module servo(
    input rst,
    input clk,
    input [1:0] mode,
    output reg servo
); //module to make servo move

integer register, count;



always @(posedge clk or posedge rst) begin
if(rst) begin
	register = 0;
end
else begin
    if(mode == 2'd2) begin
        register = 23; //angle 180
    end
    else begin
        register = 7; //angle 0
    end
end
end

always @(posedge clk or posedge rst) begin
if(rst) begin
    count = 0;
end
else begin
    if (count >= 199)  count = 0;
    else  count = count + 1;

end
end //time-controlled servo movement

always @(count or register) begin
    if (count < register)
    servo = 1;
	 else
    servo = 0;

end


endmodule

module colorLED(
input wire [1:0] mode,
input rst,
input clk,
output reg [3:0] R, G, B
);



initial begin

R = 4'd0;
G = 4'd0;
B = 4'd0;
end


always @(posedge clk or posedge rst) begin
if(rst) begin
R = 4'd0;
G = 4'd0;
B = 4'd0;
end
else begin
	case(mode)
	
	2'd0: begin R<= 4'b1111; G <= 4'b1111; B <= 4'b1111; end
	2'd1: begin R<= 4'b0000; G <= 4'b0000; B <= 4'b1111; end
	2'd2: begin R<= 4'b0000; G <= 4'b1111; B <= 4'b0000; end
	default : begin R<= 4'b1111; G <= 4'b0000; B <= 4'b0000; end
	endcase
end
end
endmodule