 module router_sync (
    input detect_add,
    input write_enb_reg,
    input clk,
    input rstn,
    output vald_out_0,
    output vald_out_1,
    output vald_out_2,
    input read_enb_0,
    input read_enb_1,
    input read_enb_2,
    input [1:0] data_in,
    output reg fifo_full,
    input empty_0,
    input empty_1,
    input empty_2,
    output reg soft_rst_0,
    output reg soft_rst_1,
    output reg soft_rst_2,
    input full_0,
    input full_1,
    input full_2,
    output reg [2:0] write_enb
   /* output reg [1:0] temp_reg,
    output reg [4:0] count_0,
    output reg [4:0] count_1,
    output reg [4:0] count_2 */
);

reg [1:0] temp_reg;
reg [4:0] count_0;
reg [4:0] count_1;
 reg [4:0] count_2;

//address
always@(posedge clk)
begin
if(!rstn)
temp_reg<=2'b00;
else if(detect_add)
temp_reg<=data_in;
end

//write_logic
always @(*)
begin
write_enb=3'b000;
if(write_enb_reg)
begin
case(temp_reg)
2'b00:write_enb =3'b001;
2'b01:write_enb =3'b010;
2'b10:write_enb =3'b100;
default:write_enb=3'b000;
endcase
end
end

//both soft_rst and count for fifo_0;
always@(posedge clk)
begin
if(!rstn)
begin
count_0<=0;
soft_rst_0<=0;
end

else if(vald_out_0)
begin
if(!read_enb_0)
begin
if(count_0==5'd29)
begin
count_0<=0;
soft_rst_0<=1;
end
else
begin
soft_rst_0<=0;
count_0<=count_0+1'b1;
end
end
end
end

//fifo_1
always@(posedge clk)
begin
if(!rstn)
begin
count_1<=0;
soft_rst_1<=0;
end

else if(vald_out_1)
begin
if(!read_enb_1)
begin
if(count_1==5'd29)
begin
count_1<=0;
soft_rst_1<=1;
end
else
begin
soft_rst_1<=0;
count_1<=count_1+1'b1;
end
end
end
end

//fifo-2
always@(posedge clk)
begin
if(!rstn)
begin
count_2<=0;
soft_rst_2<=0;
end

else if(vald_out_2)
begin
if(!read_enb_2)
begin
if(count_2==5'd29)
begin
count_2<=0;
soft_rst_2<=1;
end
else
begin
soft_rst_2<=0;
count_2<= count_2+ 5'h1;
end
end
end
end



always@(*)
begin
case(temp_reg)
2'b00:fifo_full=full_0;
2'b01:fifo_full=full_1;
2'b10:fifo_full=full_2;
default:fifo_full=1'b0;
endcase
end

assign vald_out_0=~empty_0;
assign vald_out_1=~empty_1;
assign vald_out_2=~empty_2;
endmodule
