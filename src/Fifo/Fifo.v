module router_fifo(clk, rstn, wr_enb, rd_enb, sft_rst, lfd_state, data_in, empty, full, data_out);

  input clk, rstn, wr_enb, rd_enb, sft_rst, lfd_state;
  input [7:0] data_in;
  output empty, full;
  output reg [7:0] data_out;

reg [8:0] mem[15:0];


reg [4:0]rd_ptr,wr_ptr;
reg [6:0] fifo_counter;
integer i;



always@(posedge clk)
begin
if(!rstn)
fifo_counter<=7'h0;
else if(sft_rst)
fifo_counter<=7'h0;
else if(rd_enb && ~empty)
begin
if(mem[rd_ptr[3:0]][8]==1'b1)
fifo_counter<=mem[rd_ptr[3:0]][7:2]+1'b1;
else if(fifo_counter !=0)
fifo_counter <= fifo_counter-1'b1;
end
end


//read operation
always@(posedge clk)
begin
if(!rstn)
data_out<=8'h0;
else if(sft_rst)
data_out<=8'hz;
else if(rd_enb && ~empty)
data_out<= mem[rd_ptr[3:0]];
else if(fifo_counter==0)
data_out <=8'hz;
else 
data_out<=data_out;
end


//write operation
always@(posedge clk)
begin
if(!rstn)
begin
for(i=0;i<16;i=i+1)
mem[i]<=0;
end
else if(sft_rst)
begin
for(i=0;i<16;i=i+1)
mem[i]<=0;
end
else
begin
if(wr_enb && !full)
mem[wr_ptr[3:0]] <={lfd_state,data_in};
end
end

always @(posedge clk)
begin
if(!rstn)
begin
rd_ptr<=5'b00000;
wr_ptr<=5'b00000;
end
else if(sft_rst)
begin
rd_ptr<=5'b00000;
wr_ptr<=5'b00000;
end
else begin
if(!full && wr_enb)
wr_ptr<=wr_ptr+1;
else
wr_ptr<=wr_ptr;
if(!empty && rd_enb)
rd_ptr<=rd_ptr+1;
else
rd_ptr<=rd_ptr;
end
end

assign full=(wr_ptr=={~rd_ptr[4],rd_ptr[3:0]})?1'b1:1'b0;
assign empty=(wr_ptr==rd_ptr)?1'b1:1'b0;
endmodule
