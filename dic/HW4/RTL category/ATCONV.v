`timescale 1ns/10ps
module  ATCONV(
	input		clk,
	input		reset,
	output	reg	busy,	
	input		ready,	
			
	output reg	[11:0]	iaddr,
	input signed [12:0]	idata,
	
	output	reg 	cwr,
	output  reg	[11:0]	caddr_wr,
	output reg 	[12:0] 	cdata_wr,
	
	output	reg 	crd,
	output reg	[11:0] 	caddr_rd,
	input 	[12:0] 	cdata_rd,
	
	output reg 	csel
	);
//state
localparam Padding = 0;
localparam Atrous_conv = 2;
localparam ReLU = 3;
localparam Readmem1 = 4;
localparam Stop = 5;
localparam Row_major = 6;
localparam Maxpooling = 7;
localparam Readmem2 = 8;
localparam Maxpooling_addr = 9;
localparam Writemem = 10;
localparam Max = 11;
localparam Writemem2 = 12;

//reg
reg [4:0] state;
reg [4:0] nextstate;
reg [6:0] i,j,i_begin,j_begin;
reg [6:0] ii,jj,k,right,down;
reg [12:0] temp,times,data,now,out1,out2,mem_addr,mem_addr2;

//size,個數(用數量表達)
reg [12:0] kernel [8:0];
reg [12:0] bias;
reg [12:0] maxpooling_matrix [3:0];
reg [1:0] maxpooling_index,sel;
//=================================================
//            write your design below
//=================================================


always @(*)begin
	//判斷後會等到下個clock才更新，後面計算仍用目前state
	case(state)

		Padding:begin
			//換下一行，重跑padding
			if(right == 2)
				nextstate = Padding;
			else
				nextstate = Row_major;
		end
		
		Row_major:begin
			nextstate = Readmem1;
		end
		
		Readmem1:begin
			nextstate = Atrous_conv;
		end
		
		Atrous_conv:begin
			if(k == 8)begin
				nextstate = ReLU;
			end
			else
				nextstate = Padding;
		end
		
		ReLU:begin

			nextstate = Writemem;

		end
		
		Writemem:begin

			if(times == 4095)
				nextstate = Maxpooling_addr;
			else
				nextstate = Padding;
		end
		
		Maxpooling_addr:begin
			nextstate = Readmem2;

		end
		Readmem2:begin
			if(maxpooling_index == 3) begin
				nextstate = Maxpooling;
			end
			else
				nextstate = Maxpooling_addr;
		end
		
		Maxpooling:begin
			nextstate = Max;
		end
		
		Max:begin
			nextstate = Writemem2;
		end
		
		Writemem2:begin
			if(now ==4030)
				nextstate = Stop;
			else
				nextstate = Maxpooling_addr;

		end
		
		default:begin
		
		end
	endcase
end

always @(posedge clk)begin
	if(reset)
		state <= Padding;
	else
		state <= nextstate;
end

always @(posedge clk)begin

	if(reset)begin
	//kernel
	kernel[0] <=13'h1FFF;
	kernel[1] <=13'h1FFE;
	kernel[2] <=13'h1FFF;
	kernel[3] <=13'h1FFC;
	kernel[4] <=13'h0010;
	kernel[5] <=13'h1FFC;
	kernel[6] <=13'h1FFF;
	kernel[7] <=13'h1FFE;
	kernel[8] <=13'h1FFF;
	bias <= 13'h1FF4;
	maxpooling_matrix[0] = 0;
	maxpooling_matrix[1] = 0;
	maxpooling_matrix[2] = 0;
	maxpooling_matrix[3] = 0;
	//初始化
	busy <= 0;
	i <= 0;
	j <= 0;
	k <= 0;
	ii <= 0;
	jj <= 0;
	temp <= 0;
	right <= 0;
	down <= 0;
	mem_addr <= 0;
	mem_addr2 <= 0;
	i_begin <= 0;
	j_begin <= 0;
	times <= 0;
	maxpooling_index <= 0;
	now <= 0;
	sel <= 0;
	end
	else begin
		if(ready == 1)
			busy <= 1;
		case(state)
			Padding:begin
				cwr <= 0;
				csel <= 0;
				//i,j = padded row/col
				//ii,jj = img row/col
				if(down < 3)begin
					if(right < 3)begin
						//$display("Padding");
						//$display("temp %b",temp);
						//$display("=============");				
						//$display("down",down);
						//$display("right",right);
						//$display("i",i);
						//$display("j",j);
						//if (ii < 0)
						if (i < 2) 
							ii <= 0;
							
						//else if (ii >= img_size)
						else if (i-2 >= 63)
							ii <= 63;
							
						else
						// ii = i - kernel_size
							ii <= i - 2;
						
						if (j < 2) 
							jj <= 0;
							
						else if (j-2 >= 63) 
							jj <= 63;
							
						else
							jj <= j-2;
							
						right <= right + 1;
						j <= j + 2;
					end
					
					else begin
						down <= down + 1;
						right <= 0;
						i <= i + 2;
						j <= j_begin;
					end
				end
				else begin
					right <= 0;
					down <= 0;
				end
				
			end
			
			Row_major:begin
				//$display("Row_major");
				//iaddr要等下個clock才有值
				iaddr <= ii * 64 + jj;
			end
			
			Readmem1:begin
				//$display("Readmem1");
				data <= idata>>4;
				//$display("ii",ii);
				//$display("jj",jj);
				//$display("iaddr ",iaddr);
				//$display("idata ",idata);
			end
			
			Atrous_conv:begin
				//$display("Atrous_conv");
				if(k == 8) begin
					temp <= temp + data * kernel[k] + bias;
					k <= 0;
				end
				else begin
					temp <= temp + data * kernel[k];
					k <= k + 1;
				end
				//$display("data %b", data);
				//$display("kernel[k] %b", kernel[k]);
			end
			
			ReLU:begin
				//$display("ReLU");

				//走到最右
				if(j_begin == 63) begin
					i_begin <= i_begin + 1;
					j_begin <= 0;
					end
				else 
					j_begin <= j_begin + 1;


				
				caddr_wr <= mem_addr;
				mem_addr <= mem_addr + 1;
					
				down <= 0;
				right <= 0;
				//ReLU function
				if(temp >= 4096)
					cdata_wr <= 0;
				else
					cdata_wr <= temp;
			end
			
			Writemem:begin
				cwr <= 1;
				csel <= 0;
				i <= i_begin;
				j <= j_begin;
				if(times == 4095) begin
					times <= 0;
				end
				else begin
					times <= times+1;
					temp <= 0;
				end
				
				
				//$display("caddr_wr",caddr_wr);
				//$display("cdata_wr",cdata_wr);
				//$display("============");
				
			end
			
			Maxpooling_addr:begin
				//$display("cdata_rd",cdata_rd);
				//$display("maxpooling_index",maxpooling_index);
				//$display("maxpooling_matrix",maxpooling_matrix[maxpooling_index]);
				cwr <= 0;
				csel <= 0;
				crd <= 1;
				times <= times+1;
				case(sel)
					0:caddr_rd <= now;
					1:caddr_rd <= now+1;
					2:caddr_rd <= now+64;
					3:caddr_rd <= now+65;
				endcase
				
				sel <= sel+1;
			end
			
			Readmem2:begin
				//crd <= 0;
				//$display("caddr_rd",caddr_rd);
				maxpooling_matrix[maxpooling_index] <= cdata_rd;
				maxpooling_index <= maxpooling_index + 1;
			end
			
			Maxpooling:begin
				//$display("cdata_rd",cdata_rd);
				//$display("maxpooling_matrix[0]",maxpooling_matrix[0]);
				//$display("maxpooling_matrix[1]",maxpooling_matrix[1]);
				//$display("maxpooling_matrix[2]",maxpooling_matrix[2]);
				//$display("maxpooling_matrix[3]",maxpooling_matrix[3]);
				if(maxpooling_matrix[maxpooling_index]<maxpooling_matrix[maxpooling_index+1])
					out1 <= maxpooling_matrix[maxpooling_index+1];
				else
					out1 <= maxpooling_matrix[maxpooling_index];
					
				if(maxpooling_matrix[maxpooling_index+2]<maxpooling_matrix[maxpooling_index+3])
					out2 <= maxpooling_matrix[maxpooling_index+3];
				else
					out2 <= maxpooling_matrix[maxpooling_index+2];	
				caddr_wr <=  mem_addr2;
				mem_addr2 <= mem_addr2 + 1;
			end
			
			Max:begin
				cwr <= 1;
				csel <= 1;
				//$display("out1 %b",out1);
				//$display("out2 %b",out2);
				if(out1<out2) begin
					//$display("out2 %b",out2);
					if(out2<<9 >= 13'b0001000000000)begin
						//無條件進位
						cdata_wr <=((out2>>4)+1)<<4;
						//$display("out2>>4+1",(out2>>4)+1);
					end
					else begin
						cdata_wr <= (out2>>4)<<4;
						//$display("out2>>4",out2>>4);
					end
				end
				else begin
					//$display("out1 %b",out1);
					if(out1<<9 >= 13'b0001000000000)begin
						cdata_wr <= ((out1>>4)+1)<<4;
						//$display("out1>>4+1 %b",(out1>>4)+1);
					end
					else begin
						cdata_wr <= (out1>>4)<<4;
						//$display(" out1>>4", out1>>4);
					end
				end
			end
			Writemem2:begin
				//mem_addr會在前面先+1，所以若為32，本輪為31
				if(mem_addr2%32==0 && now!=0)
					//跳兩行
					now <= now + 66;
				else
					now <= now + 2;
				
				//$display("cdata_wr",cdata_wr);
			end
			Stop:begin
				busy <= 0;
			end
			default:begin
		
			end
		
		endcase
	
	
	end


end

endmodule
