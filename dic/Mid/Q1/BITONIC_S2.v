module BITONIC_S2(  number_in1, number_in2, number_in3, number_in4,
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

wire [7:0] buf1;
wire [7:0] buf2;
wire [7:0] buf3;
wire [7:0] buf4;
wire [7:0] buf5;
wire [7:0] buf6;
wire [7:0] buf7;
wire [7:0] buf8;
/*
    Write your design here!
*/

//as上到下 ds下到上

BITONIC_AS task5(number_in1,number_in3,buf1,buf3);
BITONIC_AS task6(number_in2,number_in4,buf2,buf4);

BITONIC_DS task7(number_in6,number_in8,buf6,buf8);
BITONIC_DS task8(number_in5,number_in7,buf5,buf7);

BITONIC_AS task9(buf1,buf2,number_out1,number_out2);
BITONIC_AS task10(buf3,buf4,number_out3,number_out4);
BITONIC_DS task11(buf5,buf6,number_out5,number_out6);
BITONIC_DS task12(buf7,buf8,number_out7,number_out8);


endmodule