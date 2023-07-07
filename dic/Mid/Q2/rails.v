module rails(clk, reset, number, data1, data2, valid, result1, result2);

input        clk;
input        reset;
input  [3:0] number;
input  [3:0] data1;
input  [3:0] data2;
output  reg     valid;
output  reg     result1; 
output  reg     result2;

reg [4:0] count;
reg [3:0] total;
reg [3:0] num;
reg [3:0] stack [0:10]; // 10-level stack
reg [4:0] sp;
reg [4:0] i;


reg [4:0] count2;
reg [3:0] total2;
reg [3:0] num2;
reg [3:0] stack2 [0:10]; // 10-level stack
reg [4:0] sp2;
reg [4:0] i2;

reg [3:0] stack3 [0:10]; // 10-level stack
reg [4:0] i3;
reg [4:0] sp3;
reg [4:0] data3;
reg state;


/*
    Write your design here!
*/



always @(posedge clk) begin
	
	if(reset | (valid==1))begin
		sp = 0;
		num =1;
		result1 = 0;  
		valid = 0;
		total =3;
		count = 0;
		//stack[0] = 0;
		for(i =0;i<=10;i=i+1) begin 
			stack[i] = 0; 
		end
		
		sp2 = 0;
		num2=1;
		result2 = 0;  
		total2 =3;
		count2 = 0;
		//stack[0] = 0;
		for(i2 =0;i2<=10;i2=i2+1) begin 
			stack2[i2] = 0; 
		end
		
		for(i3 =0;i3<=10;i3=i3+1) begin 
			stack2[i3] = 0; 
		end
		state = 0;
		data3 = 0;
		i3=0;
		sp3=0;
		//count = number;
	end
	
	else begin
		//失敗
		if(sp>=1 && count==0)begin
			result1 = 0;
			result2 = 0;
			valid = 1;
		end
		
		//成功
		else if (num == total && count==0)begin
			$display("pass");
			result1 = 1;
			if(sp2>=1 && count2==0)begin
				result2 = 0;
			end
			else if (num2 == total2)begin
				result2 = 1;
			end
			valid = 1;
		end
		
		//繼續
		else begin
			//計數
			if(count==0&&sp==0)begin
				total = number;
				count = number;
				total2 = number;
				count2 = number;
				$display("total",total);
			end
			
			else begin
				case(state)
					default:begin
					$display("fail");
					end
					0:begin
					
					if(count==0)begin
						state=1;
					end
					
					end
					1:begin
					
					if(valid==1)begin
						state=0;
					end
					
					end
				endcase
			
				if(state==0) begin
					count = count-1;
					stack3[sp3] = data1;
					sp3 = sp3+1;
					while(stack[sp]!=data1 && num<total)begin
						sp = sp +1;
						stack[sp] = num;
						num = num+1;
						
					end
					
					if(stack[sp]==data1) begin	
						
						stack[sp] = 0;
						sp = sp-1;
					end

					
				end
				else if(state==1) begin
					$display("count2 :",count2);
					count2 = count2-1;
					num2 = stack3[sp3];
					sp3 = sp3+1;
					while(stack2[sp2]!=data2 && num2<total2)begin
						sp2 = sp2 +1;
						stack2[sp] = num2;
						num2 = stack3[sp3];
						sp3 = sp3+1;
						
					end
					
					if(stack2[sp2]==data2) begin	
						
						stack2[sp2] = 0;
						sp2 = sp2-1;
					end
						
				end
			
			end
		end
	end
end


endmodule