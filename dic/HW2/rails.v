module rails(clk, reset, data, valid, result);

input clk;
input reset;
input [3:0] data;
output valid;
output result;

reg valid;
reg result;
reg [4:0]count;
reg [3:0] total;
reg [3:0] num;
reg [3:0] stack [0:10]; // 10-level stack
reg [4:0] sp;
reg [1:0]start;

always @(posedge clk) begin
	
	if(reset | (valid==1 & count==0))begin
		sp = 0;
		num =1;
		assign result = 0;  
		assign valid = 0;
		total =3;
		count = 0;
		stack[0] = 4'b0000;
	end
	
	else begin
		//失敗
		if(sp>=1 && count==0)begin
		$display("fail");
			assign result = 0;
			assign valid = 1;
			start = 2;
		end
		
		//成功
		else if (num == total && count==0)begin
		$display("succ");
			assign result = 1;
			assign valid = 1;
			start = 2;
		end
		
		//繼續
		else begin
			//total
			if(count==0)begin
				total = data;
				count = data;
				$display("total",total);
			end
			
			else begin
				count = count-1;
			
				while(stack[sp]!=data && num<total)begin
					sp = sp +1;
					stack[sp] = num;

					num = num+1;
					
				end
				
				if(stack[sp]==data) begin		
					stack[sp] = 0;
					sp = sp-1;
				end
				else begin
					sp = sp;
				end

				
			end
		end
	end
end



endmodule
