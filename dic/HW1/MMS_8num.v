
module MMS_8num(result, select, number0, number1, number2, number3, number4, number5, number6, number7);

input        select;
input  [7:0] number0;
input  [7:0] number1;
input  [7:0] number2;
input  [7:0] number3;
input  [7:0] number4;
input  [7:0] number5;
input  [7:0] number6;
input  [7:0] number7;
output [7:0] result; 

wire	[7:0]result1;
wire	[7:0]result2;

MMS_4num task_a(result1, select, number0, number1, number2, number3);
MMS_4num task_b(result2, select, number4, number5, number6, number7);
combin task_c(result1,result2,select,result);

endmodule