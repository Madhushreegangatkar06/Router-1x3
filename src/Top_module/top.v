module router_top(input clk,rstn,pkt_valid,read_enb_0,read_enb_1,read_enb_2,input [7:0] data_in, output [7:0] data_out_0,data_out_1,data_out_2,
output vald_out_0,vald_out_1,vald_out_2, output err,busy);

wire fifo_full,write_enb_reg,detect_add,ld_state,laf_state,
full_state,rst_int_reg,lfd_state,parity_done,low_pkt_valid,soft_rst_0,
soft_rst_1,soft_rst_2,sft_rst;
wire [2:0] empty,full,write_enb;
wire [7:0] dout;



router_fifo fifo1 (
    .clk(clk),
    .rstn(rstn),
    .wr_enb(write_enb[0]),
    .rd_enb(read_enb_0),
    .sft_rst(soft_rst_0),
    .data_in(dout),
    .lfd_state(lfd_state),
    .empty(empty[0]),
    .full(full[0]),
    .data_out(data_out_0)
);


router_fifo fifo2 (
    .clk(clk),
    .rstn(rstn),
    .wr_enb(write_enb[1]),
    .rd_enb(read_enb_1),
    .sft_rst(soft_rst_1),
    .data_in(dout),
    .lfd_state(lfd_state),
    .empty(empty[1]),
    .full(full[1]),
    .data_out(data_out_1)
);


router_fifo fifo3 (
    .clk(clk),
    .rstn(rstn),
    .wr_enb(write_enb[2]),
    .rd_enb(read_enb_2),
    .sft_rst(soft_rst_2),
    .data_in(dout),
    .lfd_state(lfd_state),
    .empty(empty[2]),
    .full(full[2]),
    .data_out(data_out_2)
);



router_fsm fsm (
    .clk(clk),
    .rstn(rstn),
    .pkt_valid(pkt_valid),
    .parity_done(parity_done),
    .soft_rst_0(soft_rst_0),
    .soft_rst_1(soft_rst_1),
    .soft_rst_2(soft_rst_2),
    .fifo_full(fifo_full),
    .low_pkt_valid(low_pkt_valid),
    .fifo_empty_0(empty[0]),
    .fifo_empty_1(empty[1]),
    .fifo_empty_2(empty[2]),
    .data_in(dout[1:0]),
    .busy(busy),
    .detect_add(detect_add),
    .ld_state(ld_state),
    .laf_state(laf_state),
    .full_state(full_state),
    .write_enb_reg(write_enb_reg),
    .rst_int_reg(rst_int_reg),
    .lfd_state(lfd_state)
);


router_sync sync (
    .detect_add(detect_add),
    .write_enb_reg(write_enb_reg),
    .clk(clk),
    .rstn(rstn),
    .vald_out_0(vald_out_0),
    .vald_out_1(vald_out_1),
    .vald_out_2(vald_out_2),
    .read_enb_0(read_enb_0),
    .read_enb_1(read_enb_1),
    .read_enb_2(read_enb_2),
    .data_in(data_in[1:0]),
    .fifo_full(fifo_full),
    .empty_0(empty[0]),
    .empty_1(empty[1]),
    .empty_2(empty[2]),
    .soft_rst_0(soft_rst_0),
    .soft_rst_1(soft_rst_1),
    .soft_rst_2(soft_rst_2),
    .full_0(full[0]),
    .full_1(full[1]),
    .full_2(full[2]),
    .write_enb(write_enb)
);


router_reg register (
    .clk(clk),
    .rstn(rstn),
    .pkt_valid(pkt_valid),
    .fifo_full(fifo_full),
    .rst_int_reg(rst_int_reg),
    .detect_add(detect_add),
    .ld_state(ld_state),
    .laf_state(laf_state),
    .full_state(full_state),
    .lfd_state(lfd_state),
    .data_in(data_in),
    .parity_done(parity_done),
    .low_pkt_valid(low_pkt_valid),
    .err(err),
    .dout(dout)
);

endmodule
