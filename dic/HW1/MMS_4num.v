module MMS_4num(result, select, number0, number1, number2, number3);

	input        select;
	input  [7:0] number0;
	input  [7:0] number1;
	input  [7:0] number2;
	input  [7:0] number3;
	output [7:0] result; 
	
	wire	[7:0]task1_out;
	wire	[7:0]task2_out;

	combin task1(number0,number1,select,task1_out);
	combin task2(number2,number3,select,task2_out);
	combin task3(task1_out,task2_out,select,result);
	//assign result = 1'b1;

endmodule



module combin(n1,n2,sel,out);
	input [7:0] n1;
	input [7:0] n2;
	input sel;
	output[7:0] out;
	reg [7:0] out;
	reg [7:0] min;
	reg [7:0] max;
	reg	cmp;
	always@(*)begin
		if(n1<n2)
			cmp = 1'b1;
		else
			cmp = 1'b0;
		case({sel,cmp})
			2'b00:
				out = n1;	
			2'b01:
				out = n2;
			2'b10:
				out = n2;
			2'b11:
				out = n1;
		endcase
	end

endmodule