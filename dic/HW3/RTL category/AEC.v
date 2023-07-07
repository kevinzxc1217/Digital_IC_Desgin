module AEC(clk, rst, ascii_in, ready, valid, result);

// Input signal
input clk;
input rst;
input ready;
input [7:0] ascii_in;


// Output signal
output valid;
output [6:0] result;


//reg
reg valid_b;
reg [6:0] result_b;
reg [7:0] store_vec [0:15];
reg [7:0] output_vec [0:15];
reg [1:0] state;
reg [3:0] store_index;
reg [3:0] store_index2;
reg [3:0] output_index;
reg [3:0] output_index2;
reg [8:0] src1;
reg [8:0] src2;
reg pass;
reg [6:0] ans;
//int
integer sIdle=0, sStore=1, sIn2post=2 , sCalculate=3;

integer equal=61,sub=45,add=43,mul=42,R_par=41,L_par=40;
integer idx;
//stack
reg [3:0] sp;
reg [7:0] stack [0:4];


//-----Your design-----//
always@(posedge clk)begin
	if(rst||valid ==1)begin
		valid_b = 0;
		result_b = 0;
		sp = 0;
		store_index = 0;
		store_index2 = 0;
		output_index = 0;
		output_index2 = 0;
		src1 = 0;
		src2 = 0;
		pass = 0;
		ans = 0;
		state = sStore;
		for (idx=0;idx<=15;idx=idx+1)	begin
			store_vec[idx]=0;
			output_vec[idx]=0;
		end
	end
	
	else begin
	
		//Next State Decoder
		case(state)
			default:begin
				//$display("fail");
			end
			
			sStore:begin
				//判斷是否讀到底
				
				if( equal == ascii_in )begin
					state = sIn2post;
				end
			end
			
			sIn2post:begin
				if(pass==1)begin
					state = sCalculate;
					pass=0;
				end
			end
			
			sCalculate:begin
			
			end
			
			
		endcase
		
		//=============store============
		if(state === sStore)begin
			store_vec[store_index] = ascii_in;
			store_index = store_index + 1;
		end
		//============sIn2post==========
		if(state === sIn2post)begin	
			if(store_vec[store_index2]!=0)begin
				//$display(":",store_vec[store_index2]);
				if(store_vec[store_index2]>=48)begin//num
					output_vec[output_index] = store_vec[store_index2];
					output_index = output_index + 1;
					store_index2 = store_index2 + 1;
				end
				else if(store_vec[store_index2] <=45 && store_vec[store_index2] >=40)begin//operate
					//pop
					//$display("put:",store_vec[store_index2],"top:",stack[sp-1]);
					if((stack[sp-1]=="*"|(store_vec[store_index2]==add|store_vec[store_index2]==sub)&(stack[sp-1]==sub|stack[sp-1]==add))&store_vec[store_index2]!=L_par)begin//if the stack top is higher or equ than store
						
						output_vec[output_index] = stack[sp-1];
						stack[sp-1]=" ";
						sp = sp -1;
						output_index = output_index +1;
					end
					else if(store_vec[store_index2] == R_par)begin
						if(stack[sp-1] != L_par)begin
						
							output_vec[output_index] = stack[sp-1];
							//stack[sp-1]=" ";
							sp = sp -1;
							output_index = output_index+1;	
						end
						else begin
							store_index2 = store_index2 + 1;
							//stack[sp-1]=" ";
							sp = sp -1;
						end
						//pop "("
					end
					else begin
						stack[sp] = store_vec[store_index2];
						store_index2 = store_index2 + 1;
						sp = sp+1;
					end
				end
			end
			else begin
				//$display("cnt:",cnt);
				if(sp!=0)begin
					sp=sp-1;
					output_vec[output_index] = stack[sp];
					//$display("output_vec3:",output_vec[output_index]," output_index:",output_index,"pop rem");
					output_index = output_index + 1;
				end
				//pass = 1;
				if(sp==0)begin
					pass = 1;
				end
			end
		
		end
		
		//==========sCalculate=========
		if(state === sCalculate)begin
			//$display("output_index2:",output_vec[output_index2] );

			if(output_vec[output_index2] >= 97)begin
				stack[sp] = output_vec[output_index2]-87;
				sp = sp + 1;
			end
			else if(output_vec[output_index2] >= 48)begin
				stack[sp] = output_vec[output_index2]-48;
				sp = sp + 1;
			end

			else begin
				//$display("output_vec: ",output_vec[output_index2]);
				sp = sp-1;
				src2 = stack[sp];
				sp = sp-1;
				src1 = stack[sp];
				//運算
				if(output_vec[output_index2]==add)begin
					//$display("add");
					src1 = src1 + src2;
				end
				
				else if(output_vec[output_index2]==sub)begin
					//$display("sub");
					src1 = src1 - src2;
				end
				
				else if(output_vec[output_index2]==mul)begin
					//$display("mul");
					src1 = src1 * src2;
				end
				stack[sp] = src1;
				sp = sp + 1;
			end
			
			output_index2 = output_index2+1;

			if(output_index2 == output_index) begin
				ans = stack[sp-1];
				valid_b = 1;
				result_b = ans;
			end
		end
	end
end

assign valid = valid_b;
assign result = result_b;	

endmodule