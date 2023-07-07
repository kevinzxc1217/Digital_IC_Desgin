module demosaic(
input clk,
input reset,
input in_en,
input [7:0] data_in,
output reg wr_r,
output reg [13:0] addr_r,
output reg[7:0] wdata_r,
input [7:0] rdata_r,
output reg wr_g,
output reg [13:0] addr_g,
output reg [7:0] wdata_g,
input [7:0] rdata_g,
output reg wr_b,
output reg [13:0] addr_b,
output reg [7:0] wdata_b,
input [7:0] rdata_b,
output reg done
);

reg [4:0] state,nextstate;
reg [15:0] cnt;
reg [15:0] blue_data,red_data,green_data;
reg [15:0] cnt_b,cnt_r,cnt_g;
//state
localparam Start = 0;
localparam Stop = 1;
localparam Blue_write1 = 2;
localparam Blue_write2 = 3;
localparam Blue_write3 = 4;
localparam Red_write1 = 5;
localparam Red_write2 = 6;
localparam Red_write3 = 7;
localparam Green_write1 = 8;
localparam Green_write2 = 9;
localparam Check1 = 10;
localparam Check2 = 11;
always @(*) begin
    case(state)
        Start:begin
            if(in_en)
                nextstate = Start;
            else
                nextstate = Blue_write1;
        end

        Blue_write1:begin
            if(addr_b+1==16382&&cnt_b%3==2)
                nextstate = Blue_write2;
            else 
                nextstate = Blue_write1;
        end
        Blue_write2:begin
            if(addr_b+128==16382&&cnt_b%3==2)
                nextstate = Blue_write3;
            else
                nextstate = Blue_write2;
        end
        Blue_write3:begin
            //if(addr_b>= 650)
            if(addr_b+129==16382&&cnt_b%5==4)
                nextstate = Red_write1;
            else
                nextstate = Blue_write3;
        end
        //ok
        Red_write1:begin
            //if(addr_r>=500)
            if(addr_r+1==16255&&cnt_r%3==2)
                nextstate = Red_write2;
            else
                nextstate = Red_write1;
        end
        Red_write2:begin
            //if(addr_r>=700)
            if(addr_r+128>=16255&&cnt_r%3==2)
                nextstate = Red_write3;
            else
                nextstate = Red_write2;
        end
        Red_write3:begin
            //if(addr_r>=600)
            if(addr_r+129>=16255&&cnt_r%5==4)
                nextstate = Green_write1;
            else
                nextstate = Red_write3;
        end
        Green_write1:begin
            //if(addr_g>=16381) 
            if(addr_g+128==16381&&cnt_g%5==4)
                nextstate = Stop;
            else
                nextstate = Green_write1;
        end
        Stop:begin
        
        end

		default:begin
            nextstate = Start;
		end
    endcase
end

always @(posedge clk ) begin
    if(reset)
        state <= Start;
    else
        state <= nextstate;
end

always @(posedge clk) begin
    if(reset)begin
        cnt <= 0;
        cnt_b <= 0;
        cnt_r <= 0;
        cnt_g <= 0;
        done <= 0;
    end
    else begin
        case(state)
            Start:begin
                if(in_en) begin
                    addr_r <= cnt;
                    addr_g <= cnt;
                    addr_b <= cnt;

                    //奇數列
                    if((cnt/128)%2==0) begin
                        //奇數行
                        if(cnt%2==0) begin
                            wr_r <= 0;
                            wr_g <= 1;
                            wr_b <= 0;
                            wdata_g <= data_in;
                            //$display("cnt",cnt);
                            //$display("data_in %h",data_in);
                        end
                        //偶數行
                        else begin
                            wr_r <= 1;
                            wr_g <= 0;
                            wr_b <= 0;
                            wdata_r <= data_in;
                            //$display("cnt",cnt);
                            //$display("data_in %h",data_in);
                        end
                    end
                    //偶數列
                    else begin
                        //奇數行
                        if(cnt%2==0) begin
                            wr_r <= 0;
                            wr_g <= 0;
                            wr_b <= 1;
                            wdata_b <= data_in;
                            //$display("cnt",cnt);
                            //$display("data_in %h",data_in);
                        end
                        //偶數行
                        else begin
                            wr_r <= 0;
                            wr_g <= 1;
                            wr_b <= 0;
                            wdata_g <= data_in;
                            //$display("cnt",cnt);
                            //$display("data_in %h",data_in);
                        end
                    end
                end
                else begin
                    wr_r <= 0;
                    wr_g <= 0;
                    wr_b <= 0;
                    addr_b <= 128;
                    addr_r <= 1;
                    addr_g <= 0;
                end
                cnt <= cnt+1;
            end

            Blue_write1: begin
                //blue
                if(cnt_b%3==0) begin
                    //初始
                    blue_data <= rdata_b;
                    addr_b <= addr_b+2;
                    //$display("n1_adr ",addr_b); 
                    //$display("n1 ",rdata_b);
                end
                else if(cnt_b%3==1) begin
                    //寫入
                    wr_b <= 1;
                    wdata_b <= (blue_data+rdata_b)>>1;
                    addr_b <= addr_b-1;
                    //$display("n2_adr ",addr_b);
                    
                    //$display("n2 ",rdata_b);
                
                   
                end
                else if(cnt_b%3==2) begin
                    //拿值
                    wr_b <= 0;

                    if((addr_b+3) % 128 == 0 && cnt_b != 0)//253 381跳
                        addr_b <= addr_b+131;//252 254
                    else
                        addr_b <= addr_b+1;
                    //$display("addr_b ",addr_b);
                    //$display("n1+n2 =  ",wdata_b);
                    
                end
                //$display("cnt_b ",cnt_b);

                //cnt_b <= cnt_b +1;
                if(addr_b+1==16382&&cnt_b%3==2) begin
                    cnt_b <= 0;
                    addr_b <=128;
                    wr_b <= 0;
                end
                else
                    cnt_b <= cnt_b +1;
            end
            Blue_write2: begin
                //blue
                if(cnt_b%3==0) begin
                    //初始
                    blue_data <= rdata_b;
                    addr_b <= addr_b+256;
                    //$display("n1_adr ",addr_b); 
                    //$display("n1 ",rdata_b);
                end
                else if(cnt_b%3==1) begin
                    //寫入
                    wr_b <= 1;
                    wdata_b <= (blue_data+rdata_b)>>1;
                    addr_b <= addr_b-128;
                    //$display("n2_adr ",addr_b);
                    
                    //$display("n2 ",rdata_b);
                
                   
                end
                else if(cnt_b%3==2) begin
                    //拿值
                    wr_b <= 0;
                    //換行條件
                    if((addr_b+2) % 128 == 0 && cnt_b != 0)//253 381跳
                        addr_b <= addr_b+2;//252 254
                    else
                        addr_b <= addr_b-128+2;
                    //$display("addr_b ",addr_b);
                    //$display("n1+n2 =  ",wdata_b);
                    
                end
                //$display("cnt_b ",cnt_b);
                //終止條件 16382結束
                if(addr_b+128==16382&&cnt_b%3==2) begin
                    cnt_b <= 0;
                    addr_b <=128;
                end
                else
                    cnt_b <= cnt_b +1;
            end
            Blue_write3: begin
                //red
                if(cnt_b%5==0) begin
                    //初始
                    blue_data <= rdata_b;
                    addr_b <= addr_b+2;
                    //$display("n1_adr ",addr_b);
                    //$display("n1 ",rdata_b);
                end
                else if(cnt_b%5==1) begin
                    blue_data <= blue_data+rdata_b;
                    addr_b <= addr_b+254;
                    //$display("n2_adr ",addr_b);
                    
                    //$display("n2 ",rdata_b);
                end
                else if(cnt_b%5==2) begin
                    blue_data <= blue_data+rdata_b;
                    addr_b <= addr_b+2;
                    //$display("n3_adr ",addr_b);
                    
                    //$display("n2 ",rdata_b);
                end
                else if(cnt_b%5==3) begin
                    //寫入
                    wr_b <= 1;
                    wdata_b <= (blue_data+rdata_b)>>2;
                    addr_b <= addr_b-129;
                    //$display("n4_adr ",addr_b);
                    
                    //$display("n2 ",rdata_b);
                end               
                else if(cnt_b%5==4) begin
                    //拿值
                    wr_b <= 0;
                    //???????????????????
                    if((addr_b+3) % 128 == 0 && cnt_b != 0)//253 381跳
                        addr_b <= addr_b+3;//252 254
                    else
                        addr_b <= addr_b-127;//回到下個位置
                    //$display("addr_b ",addr_b);
                    //$display("ans=  ",wdata_b);
                    
                end
                //$display("cnt_b ",cnt_b);

                //16254最後一個
                if(addr_b+129==16382&&cnt_b%5==4) begin
                    cnt_b <= 0;
                    wr_b <= 0;
                    addr_r <= 1;
                end
                else
                    cnt_b <= cnt_b +1;
            end
            Red_write1: begin
                //red
                if(cnt_r%3==0) begin
                    //初始
                    red_data <= rdata_r;
                    addr_r <= addr_r+2;
                    //$display("n1_adr ",addr_r); 
                    //$display("n1 %h",rdata_r);
                end
                else if(cnt_r%3==1) begin
                    //寫入
                    wr_r <= 1;
                    wdata_r <= (red_data+rdata_r)>>1;
                    addr_r <= addr_r-1;
                    //$display("n2_adr ",addr_r);             
                    //$display("n2 %h",rdata_r);
                
                   
                end
                else if(cnt_r%3==2) begin
                    //拿值
                    wr_r <= 0;

                    if((addr_r+2) % 128 == 0 && cnt_r != 0)//126跳
                        addr_r <= addr_r+131;
                    else
                        addr_r <= addr_r+1;

                    //$display("n1+n2 =  ",wdata_r);
                    //$display("addr_r ",addr_r);
                end
                //$display("cnt_r ",cnt_r);
                
                if(addr_r+1==16255&&cnt_r%3==2) begin
                    cnt_r <= 0;
                    addr_r <=1;
                    wr_r <= 0;
                end
                else
                    cnt_r <= cnt_r +1;

            end
            Red_write2: begin
                //blue
                if(cnt_r%3==0) begin
                    //初始
                    red_data <= rdata_r;
                    addr_r <= addr_r+256;
                    //$display("n1_adr ",addr_r); 
                    //$display("n1 ",rdata_b);
                end
                else if(cnt_r%3==1) begin
                    //寫入
                    wr_r <= 1;
                    wdata_r <= (red_data+rdata_r)>>1;
                    addr_r <= addr_r-128;
                    //$display("n2_adr ",addr_r);
                    
                    //$display("n2 ",rdata_b);
                
                   
                end
                else if(cnt_r%3==2) begin
                    //拿值
                    wr_r <= 0;
                    //換行條件
                    if((addr_r+1) % 128 == 0 && cnt_r != 0)//253 381跳
                        addr_r <= addr_r+2;//127
                    else
                        addr_r <= addr_r+2-128;//回到原本列

                    //$display("n1+n2 =  ",wdata_b);
                    //$display("addr_r ",addr_r);
                end
                //$display("cnt_b ",cnt_b);
                //終止條件 16255結束
                if(addr_r+128==16255&&cnt_r%3==2) begin
                    cnt_r <= 0;
                    addr_r <=1;
                end
                else
                    cnt_r <= cnt_r +1;
            end
            Red_write3: begin
                //red
                if(cnt_r%5==0) begin
                    //初始
                    red_data <= rdata_r;
                    addr_r <= addr_r+2;
                    //$display("n1_adr ",addr_r);
                    //$display("n1 ",rdata_b);
                end
                else if(cnt_r%5==1) begin
                    //寫入
                    red_data <= red_data+rdata_r;
                    addr_r <= addr_r+254;
                    //$display("n2_adr ",addr_r);
                    
                    //$display("n2 ",rdata_b);
                end
                else if(cnt_r%5==2) begin
                    //寫入
                    red_data <= red_data+rdata_r;
                    addr_r <= addr_r+2;
                    //$display("n3_adr ",addr_r);
                    
                    //$display("n2 ",rdata_b);
                end
                else if(cnt_r%5==3) begin
                    //寫入
                    wr_r <= 1;
                    wdata_r <= (red_data+rdata_r)>>2;
                    addr_r <= addr_r-129;
                    //$display("n4_adr ",addr_r);
                    
                    //$display("n2 ",rdata_b);
                end               
                else if(cnt_r%5==4) begin
                    //拿值
                    wr_r <= 0;

                    if((addr_r+2) % 128 == 0 && cnt_r != 0)//253 381跳
                        addr_r <= addr_r+3;
                    else
                        addr_r <= addr_r-127;

                    //$display("ans=  ",wdata_r);
                    //$display("addr_r ",addr_r);
                end
                //$display("cnt_b ",cnt_b);

                //16254最後一個
                if(addr_r+129==16255&&cnt_r%5==4) begin
                    cnt_r <= 0;
                    wr_r <= 0;
                    addr_g = 2;
                end
                else
                    cnt_r <= cnt_r +1;
            end
            Green_write1: begin
                //blue
                if(cnt_g%5==0) begin
                    //初始
                    green_data <= rdata_g;
                    addr_g <= addr_g+127;
                    //$display("1 ",addr_g); 
                    //$display("n1 ",rdata_g);
                end
                if(cnt_g%5==1) begin
                    //初始
                    green_data <= green_data + rdata_g;
                    addr_g <= addr_g+2;
                   //$display("2 ",addr_g); 
                    //$display("n1 ",rdata_g);
                end
               if(cnt_g%5==2) begin
                    //初始
                    green_data <= green_data + rdata_g;
                    addr_g <= addr_g+127;
                    //$display("3 ",addr_g); 
                    //$display("n1 ",rdata_g);
                end
                else if(cnt_g%5==3) begin
                    //寫入
                    wr_g <= 1;
                    wdata_g <= (green_data+rdata_g)>>2;
                    addr_g <= addr_g-128;
                    //$display("4 ",addr_g);
                    
                    //$display("n2 ",rdata_g);
                
                   
                end
                else if(cnt_g%5==4) begin
                    //拿值
                    wr_g <= 0;
                    //addr_g現在是取值的addr
                    if((addr_g+2) % 128 == 0 && cnt_g != 0)//253 381跳
                        addr_g <= addr_g-125;//252 254
                    else if((addr_g+3) % 128 == 0 && cnt_g != 0)
                        addr_g <= addr_g-123;
                    else
                        addr_g <= addr_g-128+2;

                    //$display("n1+n2 =  ",wdata_g);
                    //$display("ok ",addr_g);
                end
                //$display("cnt_b ",cnt_b);

                //cnt_b <= cnt_b +1;
                if(addr_g+128==16381&&cnt_g%5==4)  begin
                    cnt_g <= 0;
                    addr_g <= 0;
                    wr_g <=0;
                end
                else
                    cnt_g <= cnt_g +1;
            end
 
            Stop: begin
                //$display("addr_b",addr_b);
                //$display("wdata_b",wdata_b);
                done <= 1;
            end
            default: begin
                
            end



        endcase


    end
end




endmodule
