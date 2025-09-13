module router_reg(clk, rstn, pkt_valid, fifo_full, rst_int_reg, detect_add,
                  ld_state, laf_state, full_state, lfd_state, data_in,
                  parity_done, low_pkt_valid, err, dout);

  input clk, rstn, pkt_valid, fifo_full, rst_int_reg, detect_add, ld_state, laf_state, full_state, lfd_state;
  input [7:0] data_in;

  output reg parity_done, low_pkt_valid, err;
  output reg [7:0] dout;
reg [7:0] header,parity,packet_parity,fifo_full_state;
//reg [1:0] addr;

always@(posedge clk)
begin
if(!rstn)
begin
dout<=8'b0;
end
else if(detect_add && pkt_valid && data_in[1:0]!=2'b11)
dout<=dout;
else
begin
if(lfd_state)
dout<=header;
else if(ld_state && !fifo_full)
dout<=data_in;
else
begin
if(ld_state && fifo_full)
dout<=dout;
else if(laf_state)
dout<=fifo_full_state;
end
end
end 

always@(posedge clk)
begin
if(!rstn)
header<=8'h0;
else if(detect_add && pkt_valid && data_in[1:0]!=3)
header<=data_in;
end

always@(posedge clk)
begin
if(!rstn)
parity<=8'h0;
else if(detect_add)
parity<=8'h0;
else 
begin
if(lfd_state)
parity<=parity^header;
else if(pkt_valid && ld_state && !full_state)
parity<=parity^data_in;
end
end

always@(posedge clk)
begin
if(!rstn)
packet_parity<=8'h0;
else begin
if(detect_add)
packet_parity<=8'h0;
else if(ld_state && !pkt_valid)
packet_parity<=data_in;
end
end

always@(*)
begin
if(parity_done)
err=(parity!=packet_parity);
else
err=0;
end

//fifo full register logic
always@(posedge clk)
begin
 if(!rstn)
  fifo_full_state<=8'b0;
 else if(ld_state && fifo_full)
  fifo_full_state<=data_in;
 else 
  fifo_full_state<=fifo_full_state;
end

always@(posedge clk or negedge rstn)
begin
if(detect_add)
parity_done<=0;
else if(ld_state && !(fifo_full && pkt_valid))
parity_done<=1;
else if((laf_state && low_pkt_valid) &&(!parity_done))
parity_done<=1;
else
parity_done<=parity_done;
end

always@(posedge clk or negedge rstn) 
begin
if(rst_int_reg)
low_pkt_valid<=0;
else if(ld_state && !(pkt_valid))
low_pkt_valid<=1;
else
low_pkt_valid<=low_pkt_valid;
end

endmodule