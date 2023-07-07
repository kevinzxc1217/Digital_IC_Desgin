module BITONIC_S3(  number_in1, number_in2, number_in3, number_in4,
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

wire [7:0] buf11;
wire [7:0] buf12;
wire [7:0] buf13;
wire [7:0] buf14;
wire [7:0] buf15;
wire [7:0] buf16;
wire [7:0] buf17;
wire [7:0] buf18;


/*
    Write your design here!
*/


//as上到下 ds下到上

BITONIC_AS task13(number_in1,number_in5,buf1,buf5);
BITONIC_AS task14(number_in2,number_in6,buf2,buf6);
BITONIC_AS task15(number_in3,number_in7,buf3,buf7);
BITONIC_AS task16(number_in4,number_in8,buf4,buf8);

BITONIC_AS task17(buf1,buf3,buf11,buf13);
BITONIC_AS task18(buf2,buf4,buf12,buf14);
BITONIC_AS task19(buf5,buf7,buf15,buf17);
BITONIC_AS task20(buf6,buf8,buf16,buf18);

BITONIC_AS task21(buf11,buf12,number_out1,number_out2);
BITONIC_AS task22(buf13,buf14,number_out3,number_out4);
BITONIC_AS task23(buf15,buf16,number_out5,number_out6);
BITONIC_AS task24(buf17,buf18,number_out7,number_out8);



endmodule
