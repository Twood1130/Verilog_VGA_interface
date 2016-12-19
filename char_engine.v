//char_engine
//version 1 revision 2

//This character display engine works binary data sources, and outputs the corresponding values in hexadecimal.
//This implementation was designed for use as a debugging interface for a MIPS processor project. However any data can be used.
//Characters are 8 * 8 pixels each with a blank line above each character, allowing allowing 80 * 53 characters on screen.



module char_engine(
	input wire clock25,

	input wire [31:0] ins_data,
	input wire [31:0] mem_data,
	input wire [31:0] reg_data,
	
	output reg [0:7] mem_out,
	output reg [15:0] mem_add,
	output mem_write,
	
	output reg [4:0] reg_sw,
	output reg [4:0] ins_sw,
	output reg [4:0] mem_sw);
	
	assign mem_write = 1;
	
	reg [3:0] hex_digit;
	reg [31:0] data;
	reg [3:0] hex_buffer[0:7];
	reg [63:0] mem_buffer;
	integer data_index, reg_index, row, column, slice_delay, decode_delay, num_chars, k, x, y;
	
	initial begin
	slice_delay = 0;
	decode_delay = 0;
	x = 0;
	y = -1;
	data_index = 4;
	reg_index = 0;
	end
	
	always @(posedge clock25) begin //semi-pipelined design, only executes one if statement per clock
				
		if (x < 0) begin //source and slice steps
			if (slice_delay == 0) data_index = data_index + 1;
			source_data();
			slice_data ();
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
			mem_add <= (80 * y) + (800 * row) + (8 - (x + 1)) + (column); //this complicated formula tranlates information into a linear address
			mem_out <= mem_buffer[k -: 8];
			y = y - 1;
		end
	end
	
	task decode_hex;	
		case (hex_digit) 
						
			4'h0: begin //zero
					mem_buffer[7:0] <=   8'b00111100;
					mem_buffer[15:8] <=  8'b01000010;
					mem_buffer[23:16] <= 8'b01000010;
					mem_buffer[31:24] <= 8'b01000010;
					mem_buffer[39:32] <= 8'b01000010;
					mem_buffer[47:40] <= 8'b01000010;
					mem_buffer[55:48] <= 8'b01000010;
					mem_buffer[63:56] <= 8'b00111100;
					end
			
			4'h1: begin //one
					mem_buffer[7:0] <=   8'b00011000;
					mem_buffer[15:8] <=  8'b00111000;
					mem_buffer[23:16] <= 8'b01111000;
					mem_buffer[31:24] <= 8'b00011000;
					mem_buffer[39:32] <= 8'b00011000;
					mem_buffer[47:40] <= 8'b00011000;
					mem_buffer[55:48] <= 8'b00011000;
					mem_buffer[63:56] <= 8'b01111110;
					end
			
			4'h2: begin //two
					mem_buffer[7:0] <=   8'b00111100;
					mem_buffer[15:8] <=  8'b01100110;
					mem_buffer[23:16] <= 8'b01100110;
					mem_buffer[31:24] <= 8'b00001100;
					mem_buffer[39:32] <= 8'b00011000;
					mem_buffer[47:40] <= 8'b00110000;
					mem_buffer[55:48] <= 8'b01100000;
					mem_buffer[63:56] <= 8'b01111110;
					end
					
			4'h3: begin //three
					mem_buffer[7:0] <=   8'b01111100;
					mem_buffer[15:8] <=  8'b00000110;
					mem_buffer[23:16] <= 8'b00000110;
					mem_buffer[31:24] <= 8'b01111100;
					mem_buffer[39:32] <= 8'b00000110;
					mem_buffer[47:40] <= 8'b00000110;
					mem_buffer[55:48] <= 8'b00000110;
					mem_buffer[63:56] <= 8'b01111100;
					end
				
			4'h4: begin //four
					mem_buffer[7:0] <=   8'b00001110;
					mem_buffer[15:8] <=  8'b00010110;
					mem_buffer[23:16] <= 8'b00100110;
					mem_buffer[31:24] <= 8'b01000110;
					mem_buffer[39:32] <= 8'b01000110;
					mem_buffer[47:40] <= 8'b01111110;
					mem_buffer[55:48] <= 8'b00000110;
					mem_buffer[63:56] <= 8'b00000110;
					end
					
			4'h5: begin //five
					mem_buffer[7:0] <=   8'b01111110;
					mem_buffer[15:8] <=  8'b01100000;
					mem_buffer[23:16] <= 8'b01100000;
					mem_buffer[31:24] <= 8'b01111000;
					mem_buffer[39:32] <= 8'b00001100;
					mem_buffer[47:40] <= 8'b00000110;
					mem_buffer[55:48] <= 8'b00001100;
					mem_buffer[63:56] <= 8'b01111000;
					end
					
			4'h6: begin //six
					mem_buffer[7:0] <=   8'b00111100;
					mem_buffer[15:8] <=  8'b01000000;
					mem_buffer[23:16] <= 8'b01000000;
					mem_buffer[31:24] <= 8'b01111100;
					mem_buffer[39:32] <= 8'b01000010;
					mem_buffer[47:40] <= 8'b01000010;
					mem_buffer[55:48] <= 8'b01000010;
					mem_buffer[63:56] <= 8'b00111100;
					end
					
			4'h7: begin //seven
					mem_buffer[7:0] <=   8'b01111110;
					mem_buffer[15:8] <=  8'b00000110;
					mem_buffer[23:16] <= 8'b00000110;
					mem_buffer[31:24] <= 8'b00000110;
					mem_buffer[39:32] <= 8'b00001100;
					mem_buffer[47:40] <= 8'b00011000;
					mem_buffer[55:48] <= 8'b00110000;
					mem_buffer[63:56] <= 8'b01100000;
					end
					
			4'h8: begin //eight
					mem_buffer[7:0] <=   8'b00111100;
					mem_buffer[15:8] <=  8'b01000010;
					mem_buffer[23:16] <= 8'b01000010;
					mem_buffer[31:24] <= 8'b00111100;
					mem_buffer[39:32] <= 8'b01000010;
					mem_buffer[47:40] <= 8'b01000010;
					mem_buffer[55:48] <= 8'b01000010;
					mem_buffer[63:56] <= 8'b00111100;
					end
					
			4'h9: begin //nine
					mem_buffer[7:0] <=   8'b00111100;
					mem_buffer[15:8] <=  8'b01000110;
					mem_buffer[23:16] <= 8'b01000110;
					mem_buffer[31:24] <= 8'b01000110;
					mem_buffer[39:32] <= 8'b00111110;
					mem_buffer[47:40] <= 8'b00000110;
					mem_buffer[55:48] <= 8'b00000110;
					mem_buffer[63:56] <= 8'b00000110;
					end
					
			4'hA: begin //A
					mem_buffer[7:0] <=   8'b00111100;
					mem_buffer[15:8] <=  8'b01000010;
					mem_buffer[23:16] <= 8'b01000010;
					mem_buffer[31:24] <= 8'b01000010;
					mem_buffer[39:32] <= 8'b01111110;
					mem_buffer[47:40] <= 8'b01000010;
					mem_buffer[55:48] <= 8'b01000010;
					mem_buffer[63:56] <= 8'b01000010;
					end
					
			4'hB: begin //B
					mem_buffer[7:0] <=   8'b01111100;
					mem_buffer[15:8] <=  8'b01000010;
					mem_buffer[23:16] <= 8'b01000010;
					mem_buffer[31:24] <= 8'b01111100;
					mem_buffer[39:32] <= 8'b01000110;
					mem_buffer[47:40] <= 8'b01000010;
					mem_buffer[55:48] <= 8'b01000110;
					mem_buffer[63:56] <= 8'b01111100;
					end
					
			4'hC: begin //C
					mem_buffer[7:0] <=   8'b00111110;
					mem_buffer[15:8] <=  8'b01100000;
					mem_buffer[23:16] <= 8'b01100000;
					mem_buffer[31:24] <= 8'b01100000;
					mem_buffer[39:32] <= 8'b01100000;
					mem_buffer[47:40] <= 8'b01100000;
					mem_buffer[55:48] <= 8'b01100000;
					mem_buffer[63:56] <= 8'b00111110;
					end
					
			4'hD: begin //D
					mem_buffer[7:0] <=   8'b01111100;
					mem_buffer[15:8] <=  8'b01100010;
					mem_buffer[23:16] <= 8'b01100010;
					mem_buffer[31:24] <= 8'b01100010;
					mem_buffer[39:32] <= 8'b01100010;
					mem_buffer[47:40] <= 8'b01100010;
					mem_buffer[55:48] <= 8'b01100010;
					mem_buffer[63:56] <= 8'b01111100;
					end
					
			4'hE: begin //E
					mem_buffer[7:0] <=   8'b00111110;
					mem_buffer[15:8] <=  8'b01100000;
					mem_buffer[23:16] <= 8'b01100000;
					mem_buffer[31:24] <= 8'b01111110;
					mem_buffer[39:32] <= 8'b01100000;
					mem_buffer[47:40] <= 8'b01100000;
					mem_buffer[55:48] <= 8'b01100000;
					mem_buffer[63:56] <= 8'b00111110;
					end
					
			4'hF: begin //F
					mem_buffer[7:0] <=   8'b01111110;
					mem_buffer[15:8] <=  8'b01100000;
					mem_buffer[23:16] <= 8'b01100000;
					mem_buffer[31:24] <= 8'b01111110;
					mem_buffer[39:32] <= 8'b01100000;
					mem_buffer[47:40] <= 8'b01100000;
					mem_buffer[55:48] <= 8'b01100000;
					mem_buffer[63:56] <= 8'b01100000;
					end
			default: mem_buffer <= 63'h0000000000000000;
		endcase	
	endtask
	
	task source_data;
			
		ins_sw <= reg_index;
		mem_sw <= reg_index;
		
		case (data_index)
			
			0: begin 
					data <= reg_index;
					column = 2;
					row = reg_index;
					num_chars = 2;
				end
			
			1: begin 
					data <= ins_data;
					column = 11;
					row = reg_index;
					num_chars = 8;
				end
			
			2: begin 
					data <= reg_index;
					column = 21;
					row = reg_index;
					num_chars = 2;
				end
			
			3: begin 
					data <= mem_data;
					column = 30;
					row = reg_index;
					num_chars = 8;
				end
			
			4: begin
					data <= 0;
					data[4:0] <= reg_index;
					column = 40;
					row = reg_index;
					num_chars = 2;
				end
				
			5: begin // 4 and 5 are the loop that prints the register data, exiting at the end of the 32nd loop
					reg_sw <= reg_index;
					data <= reg_data;
					column = 49;
					row = reg_index;
					num_chars = 8;
					if (slice_delay == 1) reg_index = reg_index + 1;
					if (reg_index == 32) begin
						reg_index = 0;
					end
				end
							
			default: data_index = -1;
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