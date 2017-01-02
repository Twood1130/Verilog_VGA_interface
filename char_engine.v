//char_engine
//version 2 (in progress)
//changed from previous: extending the character set to support the full alphabet, and special characters

//This character display enginne is designed to work with CPU developement projects, and displays various information from the project onto a vga-monitor.
//There is a built in hex engine that runs off the 3 data sources from the project.
//Characters are 8 * 8 pixels each with a blank line above each character, allowing allowing 80 * 53 characters on screen.



module char_engine(
	input wire clock,

	input wire [31:0] ins_data,
	input wire [31:0] mem_data,
	input wire [31:0] reg_data,
	
	output reg [7:0] mem_out,
	output reg [15:0] mem_add,
	output mem_write,
	
	output reg [4:0] reg_sw,
	output reg [4:0] ins_sw,
	output reg [4:0] mem_sw);
	
	assign mem_write = 1;
	
	reg [6:0] hex_digit;
	reg [31:0] data;
	reg [5:0] hex_buffer[0:11];
	reg [63:0] mem_buffer;
	integer data_index, reg_index, row, column, slice_delay, decode_delay, num_chars, k, x, y;
	
	initial begin
	slice_delay = 0;
	decode_delay = 0;
	x = 0;
	y = -1;
	data_index = -1;
	reg_index = 0;
	end
	
	always @(posedge clock) begin //semi-pipelined design, only executes one if statement per clock
				
		if (x < 0) begin //source and slice steps
			if (slice_delay == 0) data_index = data_index + 1;
			source_data();
			if (data_index > 2) slice_data ();
			slice_delay = slice_delay + 1;
			if (slice_delay == 2) begin
				x = num_chars - 1;
				slice_delay = 0;
			end
		end
		
		else if (y < 0) begin //decode steps
			hex_digit <= hex_buffer[x];
			if (decode_delay == 0) begin
				x = x - 1;
			end
			decode_hex();
			decode_delay = decode_delay + 1;
			if (decode_delay == 3) begin
				y = 8;
				decode_delay = 0;
			end
		end
		
		else if (y >= 0) begin //this step writes to memory
			k = (y * 8) - 1;
			mem_add <= (80 * y) + (800 * row) + (num_chars - (x + 1)) + (column) + 80; //this complicated formula tranlates information into a linear address
			mem_out <= mem_buffer[k -: 8];
			y = y - 1;
		end
	end
	
	task decode_hex;	
		case (hex_digit) 
						
			6'h00: begin //zero
					mem_buffer[7:0] <=   8'b00111100;
					mem_buffer[15:8] <=  8'b01000010;
					mem_buffer[23:16] <= 8'b01000010;
					mem_buffer[31:24] <= 8'b01000010;
					mem_buffer[39:32] <= 8'b01000010;
					mem_buffer[47:40] <= 8'b01000010;
					mem_buffer[55:48] <= 8'b01000010;
					mem_buffer[63:56] <= 8'b00111100;
					end
			
			6'h01: begin //one
					mem_buffer[7:0] <=   8'b00011000;
					mem_buffer[15:8] <=  8'b00111000;
					mem_buffer[23:16] <= 8'b01111000;
					mem_buffer[31:24] <= 8'b00011000;
					mem_buffer[39:32] <= 8'b00011000;
					mem_buffer[47:40] <= 8'b00011000;
					mem_buffer[55:48] <= 8'b00011000;
					mem_buffer[63:56] <= 8'b01111110;
					end
			
			6'h02: begin //two
					mem_buffer[7:0] <=   8'b00111100;
					mem_buffer[15:8] <=  8'b01100110;
					mem_buffer[23:16] <= 8'b01100110;
					mem_buffer[31:24] <= 8'b00001100;
					mem_buffer[39:32] <= 8'b00011000;
					mem_buffer[47:40] <= 8'b00110000;
					mem_buffer[55:48] <= 8'b01100000;
					mem_buffer[63:56] <= 8'b01111110;
					end
					
			6'h03: begin //three
					mem_buffer[7:0] <=   8'b01111100;
					mem_buffer[15:8] <=  8'b00000110;
					mem_buffer[23:16] <= 8'b00000110;
					mem_buffer[31:24] <= 8'b01111100;
					mem_buffer[39:32] <= 8'b00000110;
					mem_buffer[47:40] <= 8'b00000110;
					mem_buffer[55:48] <= 8'b00000110;
					mem_buffer[63:56] <= 8'b01111100;
					end
				
			6'h04: begin //four
					mem_buffer[7:0] <=   8'b00001110;
					mem_buffer[15:8] <=  8'b00010110;
					mem_buffer[23:16] <= 8'b00100110;
					mem_buffer[31:24] <= 8'b01000110;
					mem_buffer[39:32] <= 8'b01000110;
					mem_buffer[47:40] <= 8'b01111110;
					mem_buffer[55:48] <= 8'b00000110;
					mem_buffer[63:56] <= 8'b00000110;
					end
					
			6'h05: begin //five
					mem_buffer[7:0] <=   8'b01111110;
					mem_buffer[15:8] <=  8'b01100000;
					mem_buffer[23:16] <= 8'b01100000;
					mem_buffer[31:24] <= 8'b01111000;
					mem_buffer[39:32] <= 8'b00001100;
					mem_buffer[47:40] <= 8'b00000110;
					mem_buffer[55:48] <= 8'b00001100;
					mem_buffer[63:56] <= 8'b01111000;
					end
					
			6'h06: begin //six
					mem_buffer[7:0] <=   8'b00111100;
					mem_buffer[15:8] <=  8'b01000000;
					mem_buffer[23:16] <= 8'b01000000;
					mem_buffer[31:24] <= 8'b01111100;
					mem_buffer[39:32] <= 8'b01000010;
					mem_buffer[47:40] <= 8'b01000010;
					mem_buffer[55:48] <= 8'b01000010;
					mem_buffer[63:56] <= 8'b00111100;
					end
					
			6'h07: begin //seven
					mem_buffer[7:0] <=   8'b01111110;
					mem_buffer[15:8] <=  8'b00000110;
					mem_buffer[23:16] <= 8'b00000110;
					mem_buffer[31:24] <= 8'b00000110;
					mem_buffer[39:32] <= 8'b00001100;
					mem_buffer[47:40] <= 8'b00011000;
					mem_buffer[55:48] <= 8'b00110000;
					mem_buffer[63:56] <= 8'b01100000;
					end
					
			6'h08: begin //eight
					mem_buffer[7:0] <=   8'b00111100;
					mem_buffer[15:8] <=  8'b01000010;
					mem_buffer[23:16] <= 8'b01000010;
					mem_buffer[31:24] <= 8'b00111100;
					mem_buffer[39:32] <= 8'b01000010;
					mem_buffer[47:40] <= 8'b01000010;
					mem_buffer[55:48] <= 8'b01000010;
					mem_buffer[63:56] <= 8'b00111100;
					end
					
			6'h09: begin //nine
					mem_buffer[7:0] <=   8'b00111100;
					mem_buffer[15:8] <=  8'b01000110;
					mem_buffer[23:16] <= 8'b01000110;
					mem_buffer[31:24] <= 8'b01000110;
					mem_buffer[39:32] <= 8'b00111110;
					mem_buffer[47:40] <= 8'b00000110;
					mem_buffer[55:48] <= 8'b00000110;
					mem_buffer[63:56] <= 8'b00000110;
					end
					
			6'h0A: begin //A
					mem_buffer[7:0] <=   8'b00111100;
					mem_buffer[15:8] <=  8'b01000010;
					mem_buffer[23:16] <= 8'b01000010;
					mem_buffer[31:24] <= 8'b01000010;
					mem_buffer[39:32] <= 8'b01111110;
					mem_buffer[47:40] <= 8'b01000010;
					mem_buffer[55:48] <= 8'b01000010;
					mem_buffer[63:56] <= 8'b01000010;
					end
					
			6'h0B: begin //B
					mem_buffer[7:0] <=   8'b01111100;
					mem_buffer[15:8] <=  8'b01000010;
					mem_buffer[23:16] <= 8'b01000010;
					mem_buffer[31:24] <= 8'b01111100;
					mem_buffer[39:32] <= 8'b01000110;
					mem_buffer[47:40] <= 8'b01000010;
					mem_buffer[55:48] <= 8'b01000110;
					mem_buffer[63:56] <= 8'b01111100;
					end
					
			6'h0C: begin //C
					mem_buffer[7:0] <=   8'b00111110;
					mem_buffer[15:8] <=  8'b01100000;
					mem_buffer[23:16] <= 8'b01100000;
					mem_buffer[31:24] <= 8'b01100000;
					mem_buffer[39:32] <= 8'b01100000;
					mem_buffer[47:40] <= 8'b01100000;
					mem_buffer[55:48] <= 8'b01100000;
					mem_buffer[63:56] <= 8'b00111110;
					end
					
			6'h0D: begin //D
					mem_buffer[7:0] <=   8'b01111100;
					mem_buffer[15:8] <=  8'b01100010;
					mem_buffer[23:16] <= 8'b01100010;
					mem_buffer[31:24] <= 8'b01100010;
					mem_buffer[39:32] <= 8'b01100010;
					mem_buffer[47:40] <= 8'b01100010;
					mem_buffer[55:48] <= 8'b01100010;
					mem_buffer[63:56] <= 8'b01111100;
					end
					
			6'h0E: begin //E
					mem_buffer[7:0] <=   8'b00111110;
					mem_buffer[15:8] <=  8'b01100000;
					mem_buffer[23:16] <= 8'b01100000;
					mem_buffer[31:24] <= 8'b01111110;
					mem_buffer[39:32] <= 8'b01100000;
					mem_buffer[47:40] <= 8'b01100000;
					mem_buffer[55:48] <= 8'b01100000;
					mem_buffer[63:56] <= 8'b00111110;
					end
					
			6'h0F: begin //F
					mem_buffer[7:0] <=   8'b01111110;
					mem_buffer[15:8] <=  8'b01100000;
					mem_buffer[23:16] <= 8'b01100000;
					mem_buffer[31:24] <= 8'b01111110;
					mem_buffer[39:32] <= 8'b01100000;
					mem_buffer[47:40] <= 8'b01100000;
					mem_buffer[55:48] <= 8'b01100000;
					mem_buffer[63:56] <= 8'b01100000;
					end
				
			6'h10: begin //G
					mem_buffer[7:0] <=   8'b00111100;
					mem_buffer[15:8] <=  8'b01100000;
					mem_buffer[23:16] <= 8'b01100000;
					mem_buffer[31:24] <= 8'b01101110;
					mem_buffer[39:32] <= 8'b01100110;
					mem_buffer[47:40] <= 8'b01100110;
					mem_buffer[55:48] <= 8'b01100110;
					mem_buffer[63:56] <= 8'b00111100;
					end
					
			6'h11: begin //H
					mem_buffer[7:0] <=   8'b01100110;
					mem_buffer[15:8] <=  8'b01100110;
					mem_buffer[23:16] <= 8'b01100110;
					mem_buffer[31:24] <= 8'b01111110;
					mem_buffer[39:32] <= 8'b01100110;
					mem_buffer[47:40] <= 8'b01100110;
					mem_buffer[55:48] <= 8'b01100110;
					mem_buffer[63:56] <= 8'b01100110;
					end
					
			6'h12: begin //I
					mem_buffer[7:0] <=   8'b01111110;
					mem_buffer[15:8] <=  8'b00011000;
					mem_buffer[23:16] <= 8'b00011000;
					mem_buffer[31:24] <= 8'b00011000;
					mem_buffer[39:32] <= 8'b00011000;
					mem_buffer[47:40] <= 8'b00011000;
					mem_buffer[55:48] <= 8'b00011000;
					mem_buffer[63:56] <= 8'b01111110;
					end
					
			6'h13: begin //J
					mem_buffer[7:0] <=   8'b01111110;
					mem_buffer[15:8] <=  8'b00000110;
					mem_buffer[23:16] <= 8'b00000110;
					mem_buffer[31:24] <= 8'b00000110;
					mem_buffer[39:32] <= 8'b00000110;
					mem_buffer[47:40] <= 8'b00000110;
					mem_buffer[55:48] <= 8'b01100110;
					mem_buffer[63:56] <= 8'b00111100;
					end
					
			6'h14: begin //K
					mem_buffer[7:0] <=   8'b01100110;
					mem_buffer[15:8] <=  8'b01100110;
					mem_buffer[23:16] <= 8'b01101100;
					mem_buffer[31:24] <= 8'b01110000;
					mem_buffer[39:32] <= 8'b01110000;
					mem_buffer[47:40] <= 8'b01101100;
					mem_buffer[55:48] <= 8'b01100110;
					mem_buffer[63:56] <= 8'b01100110;
					end
					
			6'h15: begin //I
					mem_buffer[7:0] <=   8'b01100000;
					mem_buffer[15:8] <=  8'b01100000;
					mem_buffer[23:16] <= 8'b01100000;
					mem_buffer[31:24] <= 8'b01100000;
					mem_buffer[39:32] <= 8'b01100000;
					mem_buffer[47:40] <= 8'b01100000;
					mem_buffer[55:48] <= 8'b01100000;
					mem_buffer[63:56] <= 8'b01111110;
					end
					
			6'h16: begin //M
					mem_buffer[7:0] <=   8'b01000010;
					mem_buffer[15:8] <=  8'b01100110;
					mem_buffer[23:16] <= 8'b01011010;
					mem_buffer[31:24] <= 8'b01011010;
					mem_buffer[39:32] <= 8'b01000010;
					mem_buffer[47:40] <= 8'b01000010;
					mem_buffer[55:48] <= 8'b01000010;
					mem_buffer[63:56] <= 8'b01000010;
					end
					
			6'h17: begin //N
					mem_buffer[7:0] <=   8'b01000010;
					mem_buffer[15:8] <=  8'b01000010;
					mem_buffer[23:16] <= 8'b01100010;
					mem_buffer[31:24] <= 8'b01010010;
					mem_buffer[39:32] <= 8'b01001010;
					mem_buffer[47:40] <= 8'b01000110;
					mem_buffer[55:48] <= 8'b01000010;
					mem_buffer[63:56] <= 8'b01000010;
					end
					
			6'h18: begin //O
					mem_buffer[7:0] <=   8'b00111100;
					mem_buffer[15:8] <=  8'b01000010;
					mem_buffer[23:16] <= 8'b01000010;
					mem_buffer[31:24] <= 8'b01000010;
					mem_buffer[39:32] <= 8'b01000010;
					mem_buffer[47:40] <= 8'b01000010;
					mem_buffer[55:48] <= 8'b01000010;
					mem_buffer[63:56] <= 8'b00111100;
					end
					
			6'h19: begin //P
					mem_buffer[7:0] <=   8'b01111100;
					mem_buffer[15:8] <=  8'b01000010;
					mem_buffer[23:16] <= 8'b01000010;
					mem_buffer[31:24] <= 8'b01000010;
					mem_buffer[39:32] <= 8'b01111100;
					mem_buffer[47:40] <= 8'b01100000;
					mem_buffer[55:48] <= 8'b01100000;
					mem_buffer[63:56] <= 8'b01100000;
					end
					
			6'h1A: begin //Q
					mem_buffer[7:0] <=   8'b00111100;
					mem_buffer[15:8] <=  8'b01000010;
					mem_buffer[23:16] <= 8'b01000010;
					mem_buffer[31:24] <= 8'b01000010;
					mem_buffer[39:32] <= 8'b01000010;
					mem_buffer[47:40] <= 8'b01000010;
					mem_buffer[55:48] <= 8'b01000100;
					mem_buffer[63:56] <= 8'b00111010;
					end
					
			6'h1B: begin //R
					mem_buffer[7:0] <=   8'b00111100;
					mem_buffer[15:8] <=  8'b01000010;
					mem_buffer[23:16] <= 8'b01000010;
					mem_buffer[31:24] <= 8'b01000010;
					mem_buffer[39:32] <= 8'b01111100;
					mem_buffer[47:40] <= 8'b01011000;
					mem_buffer[55:48] <= 8'b01001100;
					mem_buffer[63:56] <= 8'b01000110;
					end
					
			6'h1C: begin //S
					mem_buffer[7:0] <=   8'b00111100;
					mem_buffer[15:8] <=  8'b01000000;
					mem_buffer[23:16] <= 8'b01000000;
					mem_buffer[31:24] <= 8'b00111100;
					mem_buffer[39:32] <= 8'b00000010;
					mem_buffer[47:40] <= 8'b00000010;
					mem_buffer[55:48] <= 8'b00000010;
					mem_buffer[63:56] <= 8'b00111100;
					end
					
			6'h1D: begin //T
					mem_buffer[7:0] <=   8'b01111110;
					mem_buffer[15:8] <=  8'b00011000;
					mem_buffer[23:16] <= 8'b00011000;
					mem_buffer[31:24] <= 8'b00011000;
					mem_buffer[39:32] <= 8'b00011000;
					mem_buffer[47:40] <= 8'b00011000;
					mem_buffer[55:48] <= 8'b00011000;
					mem_buffer[63:56] <= 8'b00011000;
					end
					
			6'h1E: begin //U
					mem_buffer[7:0] <=   8'b01000010;
					mem_buffer[15:8] <=  8'b01000010;
					mem_buffer[23:16] <= 8'b01000010;
					mem_buffer[31:24] <= 8'b01000010;
					mem_buffer[39:32] <= 8'b01000010;
					mem_buffer[47:40] <= 8'b01000010;
					mem_buffer[55:48] <= 8'b01000010;
					mem_buffer[63:56] <= 8'b00111100;
					end
					
			6'h1F: begin //V
					mem_buffer[7:0] <=   8'b01000010;
					mem_buffer[15:8] <=  8'b01000010;
					mem_buffer[23:16] <= 8'b01000010;
					mem_buffer[31:24] <= 8'b01000010;
					mem_buffer[39:32] <= 8'b01000010;
					mem_buffer[47:40] <= 8'b01000010;
					mem_buffer[55:48] <= 8'b00100100;
					mem_buffer[63:56] <= 8'b00011000;
					end
					
			6'h20: begin //W
					mem_buffer[7:0] <=   8'b01000010;
					mem_buffer[15:8] <=  8'b01000010;
					mem_buffer[23:16] <= 8'b01000010;
					mem_buffer[31:24] <= 8'b01000010;
					mem_buffer[39:32] <= 8'b01011010;
					mem_buffer[47:40] <= 8'b01011010;
					mem_buffer[55:48] <= 8'b01100110;
					mem_buffer[63:56] <= 8'b01000010;
					end
					
			6'h21: begin //X
					mem_buffer[7:0] <=   8'b01000010;
					mem_buffer[15:8] <=  8'b01000010;
					mem_buffer[23:16] <= 8'b00100100;
					mem_buffer[31:24] <= 8'b00011000;
					mem_buffer[39:32] <= 8'b00011000;
					mem_buffer[47:40] <= 8'b00100100;
					mem_buffer[55:48] <= 8'b01000010;
					mem_buffer[63:56] <= 8'b01000010;
					end
					
			6'h22: begin //Y
					mem_buffer[7:0] <=   8'b01000010;
					mem_buffer[15:8] <=  8'b01000010;
					mem_buffer[23:16] <= 8'b01000010;
					mem_buffer[31:24] <= 8'b00100100;
					mem_buffer[39:32] <= 8'b00011000;
					mem_buffer[47:40] <= 8'b00011000;
					mem_buffer[55:48] <= 8'b00011000;
					mem_buffer[63:56] <= 8'b00011000;
					end
					
			6'h23: begin //Z
					mem_buffer[7:0] <=   8'b01111110;
					mem_buffer[15:8] <=  8'b00000110;
					mem_buffer[23:16] <= 8'b00000110;
					mem_buffer[31:24] <= 8'b00001100;
					mem_buffer[39:32] <= 8'b00110000;
					mem_buffer[47:40] <= 8'b01100000;
					mem_buffer[55:48] <= 8'b01100000;
					mem_buffer[63:56] <= 8'b01111110;
					end
					
			6'h24: begin //space
					mem_buffer[7:0] <=   8'b00000000;
					mem_buffer[15:8] <=  8'b00000000;
					mem_buffer[23:16] <= 8'b00000000;
					mem_buffer[31:24] <= 8'b00000000;
					mem_buffer[39:32] <= 8'b00000000;
					mem_buffer[47:40] <= 8'b00000000;
					mem_buffer[55:48] <= 8'b00000000;
					mem_buffer[63:56] <= 8'b00000000;
					end
					
			6'h25: begin //Filled
					mem_buffer[7:0] <=   8'b11111111;
					mem_buffer[15:8] <=  8'b11111111;
					mem_buffer[23:16] <= 8'b11111111;
					mem_buffer[31:24] <= 8'b11111111;
					mem_buffer[39:32] <= 8'b11111111;
					mem_buffer[47:40] <= 8'b11111111;
					mem_buffer[55:48] <= 8'b11111111;
					mem_buffer[63:56] <= 8'b11111111;
					end
					
			6'h26: begin //-
					mem_buffer[7:0] <=   8'b00000000;
					mem_buffer[15:8] <=  8'b00000000;
					mem_buffer[23:16] <= 8'b00000000;
					mem_buffer[31:24] <= 8'b01111110;
					mem_buffer[39:32] <= 8'b00000000;
					mem_buffer[47:40] <= 8'b00000000;
					mem_buffer[55:48] <= 8'b00000000;
					mem_buffer[63:56] <= 8'b00000000;
					end
					
			6'h27: begin //:
					mem_buffer[7:0] <=   8'b00000000;
					mem_buffer[15:8] <=  8'b00011000;
					mem_buffer[23:16] <= 8'b00011000;
					mem_buffer[31:24] <= 8'b00000000;
					mem_buffer[39:32] <= 8'b00000000;
					mem_buffer[47:40] <= 8'b00011000;
					mem_buffer[55:48] <= 8'b00011000;
					mem_buffer[63:56] <= 8'b00000000;
					end
					
			6'h28: begin //.
					mem_buffer[7:0] <=   8'b00000000;
					mem_buffer[15:8] <=  8'b00000000;
					mem_buffer[23:16] <= 8'b00000000;
					mem_buffer[31:24] <= 8'b00000000;
					mem_buffer[39:32] <= 8'b00000000;
					mem_buffer[47:40] <= 8'b00000000;
					mem_buffer[55:48] <= 8'b11000000;
					mem_buffer[63:56] <= 8'b11000000;
					end
					
			default: mem_buffer <= 63'h0000000000000000;
		endcase	
	endtask
	
	task source_data;
			
		ins_sw <= reg_index;
		mem_sw <= reg_index;
		
		case (data_index)
			0: begin //"INS. MEMORY" label
				hex_buffer[10] <= 6'h12;
				hex_buffer[9] <= 6'h17;
				hex_buffer[8] <= 6'h1C;
				hex_buffer[7] <= 6'h28;
				hex_buffer[6] <= 6'h24;
				hex_buffer[5] <= 6'h16;
				hex_buffer[4] <= 6'h0E;
				hex_buffer[3] <= 6'h16;
				hex_buffer[2] <= 6'h18;
				hex_buffer[1] <= 6'h1B;
				hex_buffer[0] <= 6'h22;
				
				row = 0;
				column = 0;
				num_chars = 11;
				end
			
			1: begin //"DATA MEMORY" label
					hex_buffer[10] <= 6'h0D;
					hex_buffer[9] <= 6'h0A;
					hex_buffer[8] <= 6'h1D;
					hex_buffer[7] <= 6'h0A;
					hex_buffer[6] <= 6'h24;
					hex_buffer[5] <= 6'h16;
					hex_buffer[4] <= 6'h0E;
					hex_buffer[3] <= 6'h16;
					hex_buffer[2] <= 6'h18;
					hex_buffer[1] <= 6'h1B;
					hex_buffer[0] <= 6'h22;
					
					row = 0;
					column = 13;
					num_chars = 11;
				end
				
			2: begin //"REGISTERS" label
					hex_buffer[8] <= 6'h1B;
					hex_buffer[7] <= 6'h0E;
					hex_buffer[6] <= 6'h10;
					hex_buffer[5] <= 6'h12;
					hex_buffer[4] <= 6'h1C;
					hex_buffer[3] <= 6'h1D;
					hex_buffer[2] <= 6'h0E;
					hex_buffer[1] <= 6'h1B;
					hex_buffer[0] <= 6'h1C;
					
					row = 0;
					column = 26;
					num_chars = 9;
				end
				
			3: begin //instruction memory indexes
					data <= reg_index;
					column = 0;
					row = reg_index + 1;
					num_chars = 2;
				end
				
			4: begin //register indexes
					data <= 0;
					data[4:0] <= reg_index;
					column = 26;
					row = reg_index + 1;
					num_chars = 2;
				end
						
			5: begin //data_memory indexes
					data <= reg_index;
					column = 13;
					row = reg_index + 1;
					num_chars = 2;
				end
			
			6: begin //instruction memory data
					data <= ins_data;
					column = 2;
					row = reg_index + 1;
					num_chars = 9;
					hex_buffer[8] <= 6'h27;
				end
			
			7: begin //data memory data
					data <= mem_data; 
					column = 15;
					row = reg_index + 1;
					num_chars = 9;
					hex_buffer[8] <= 6'h27;
				end
				
			8: begin // register data
					reg_sw <= reg_index;
					data <= reg_data;
					column = 28;
					row = reg_index + 1;
					num_chars = 9;
					hex_buffer[8] <= 6'h27;
					if (slice_delay == 1) reg_index = reg_index + 1;
					if (reg_index == 32) begin
						reg_index = 0;
					end
				end
							
			default: data_index = 2;
		endcase
	endtask
	
	task slice_data; //I tried other ways of doing this, but the straightforward approach works better.
		hex_buffer[7] <= data[31:28];
		hex_buffer[6] <= data[27:24];
		hex_buffer[5] <= data[23:20];
		hex_buffer[4] <= data[19:16];
		hex_buffer[3] <= data[15:12];
		hex_buffer[2] <= data[11:8];
		hex_buffer[1] <= data[7:4];
		hex_buffer[0] <= data[3:0];
	endtask
endmodule	