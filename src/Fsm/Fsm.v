module router_fsm(clk, rstn, pkt_valid, parity_done, soft_rst_0, soft_rst_1, soft_rst_2,
                  fifo_full, low_pkt_valid, fifo_empty_0, fifo_empty_1, fifo_empty_2,
                  data_in, busy, detect_add, ld_state, laf_state, full_state,
                  write_enb_reg, rst_int_reg, lfd_state);

  input clk, rstn, pkt_valid, parity_done, soft_rst_0, soft_rst_1, soft_rst_2;
  input fifo_full, low_pkt_valid, fifo_empty_0, fifo_empty_1, fifo_empty_2;
  input [1:0] data_in;
  output busy, detect_add, ld_state, laf_state, full_state, write_enb_reg, rst_int_reg, lfd_state;reg [1:0] addr;
parameter decode_address=3'b000, load_first_data=3'b001,load_data=3'b010,fifo_full_state=3'b011,load_after_full=3'b100,load_parity=3'b101,check_parity_error=3'b110,wait_till_empty=3'b111;
reg [2:0] present_state, next_state;

always@(posedge clk)
begin
if(~rstn)
present_state<=decode_address;
else if(soft_rst_0&& data_in==2'b00|| soft_rst_1&& data_in==2'b01|| 
soft_rst_2&& data_in==2'b10)
present_state<=decode_address;
else
present_state<=next_state;
end


always@(posedge clk)
begin
if(~rstn)
addr<=0;
else if(soft_rst_0&& data_in==2'b00|| soft_rst_1&& data_in==2'b01|| 
soft_rst_2&& data_in==2'b10)
addr<=0;
else if(detect_add)
addr<=data_in;
end 

always@(*)
begin
next_state=present_state;
begin
case(present_state)
decode_address: if((pkt_valid && (data_in[1:0]==0) && fifo_empty_0) || (pkt_valid && (data_in[1:0]==1) && fifo_empty_1) 
||(pkt_valid && (data_in[1:0]==2) && fifo_empty_2) )
next_state=load_first_data;
else if((pkt_valid && (data_in[1:0]==0) && !fifo_empty_0) || (pkt_valid && (data_in[1:0]==1) && !fifo_empty_1) 
||(pkt_valid && (data_in[1:0]==2) && !fifo_empty_2) )
next_state=wait_till_empty;
else next_state=decode_address;

load_first_data: next_state=load_data;

load_data:if((!fifo_full) && (!pkt_valid))
next_state=load_parity;
else if(fifo_full)
next_state=fifo_full_state;
else next_state=load_data;

fifo_full_state:if (!fifo_full)
next_state=load_after_full;
else 
next_state=fifo_full_state;

load_after_full:if((!parity_done) && (low_pkt_valid))
next_state=load_parity;
else if((!parity_done) && (!low_pkt_valid))
next_state=load_data;
else if(parity_done)
next_state=decode_address;

load_parity: next_state=check_parity_error;

check_parity_error:if(!fifo_full)
next_state=decode_address;
else
next_state=fifo_full_state;

wait_till_empty: if((fifo_empty_0 && (addr==0)) || (fifo_empty_1 && (addr==1)) || (fifo_empty_2 && (addr==2)))
next_state=load_first_data;
else
next_state=wait_till_empty;
default: next_state=decode_address;
endcase
end
end

assign detect_add=(present_state==decode_address)?1'b1:1'b0;
assign lfd_state=(present_state==load_first_data)?1'b1:1'b0;
assign busy=(present_state==load_first_data|| present_state==load_parity||present_state==fifo_full_state|| present_state==load_after_full|| present_state==wait_till_empty|| present_state==check_parity_error)?1'b1:1'b0;
assign ld_state=(present_state==load_data)?1'b1:1'b0;
assign write_enb_reg =((present_state==load_data|| present_state==load_parity|| present_state==load_after_full))?1'b1:1'b0;
//assign parity_done=(present_state==load_after_full) ?1'b1:1'b0;
//assign low_pkt_valid=(present_state==load_after_full)?1'b1:1'b0;
assign rst_int_reg=(present_state==check_parity_error)?1'b1:1'b0;
assign laf_state=(present_state==load_after_full)?1'b1:1'b0;
assign full_state= (present_state==fifo_full_state)?1'b1:1'b0;

endmodule
