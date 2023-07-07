module BITONIC_S1(  number_in1, number_in2, number_in3, number_in4,
                    number_in5, number_in6, number_in7, number_in8,
                    number_out1, number_out2, number_out3, number_out4,
                    number_out5, number_out6, number_out7, number_out8);

input  [7:0] number_in1;
input  [7:0] number_in2;
input  [7:0] number_in3;
input  [7:0] number_in4;
input  [7:0] number_in5;
input  [7:0] number_in6;
input  [7:0] number_in7;
input  [7:0] number_in8;

output  [7:0] number_out1;
output  [7:0] number_out2;
output  [7:0] number_out3;
output  [7:0] number_out4;
output  [7:0] number_out5;
output  [7:0] number_out6;
output  [7:0] number_out7;
output  [7:0] number_out8;

/*
    Write your design here!
*/

//as上到下 ds下到上

BITONIC_AS task1(number_in1,number_in2,number_out1,number_out2);
BITONIC_DS task2(number_in3,number_in4,number_out3,number_out4);
BITONIC_AS task3(number_in5,number_in6,number_out5,number_out6);
BITONIC_DS task4(number_in7,number_in8,number_out7,number_out8);


endmodule