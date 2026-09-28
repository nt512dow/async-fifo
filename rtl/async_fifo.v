module async_fifo #(parameter DEPTH = 16, WIDTH = 4) (
    input [WIDTH-1:0] write_data,
    input write_en,
    input write_clk,

    input read_en,
    input read_clk,

    input reset,

    output [WIDTH-1:0] read_data,
    output full,
    output empty
);

    wire [$clog2(DEPTH)-1:0] write_address;
    wire [$clog2(DEPTH)-1:0] next_read_address;
    wire [$clog2(DEPTH):0] synced_read_ptr;
    wire [$clog2(DEPTH):0] synced_write_ptr; 
    wire [$clog2(DEPTH):0] unsynced_write_ptr;
    wire [$clog2(DEPTH):0] unsynced_read_ptr;


    dual_port_ram #(.DEPTH(DEPTH), .WIDTH(WIDTH)) fifo_ram (
        .write_data(write_data),
        .write_en(write_en),
        .write_full(full),
        .write_address(write_address),
        .write_clk(write_clk),
        .read_clk(read_clk),
        .next_read_address(next_read_address),
        .read_data(read_data)
    );

    write_handler #(.DEPTH(DEPTH)) write_block (
        .write_en(write_en),
        .write_clk(write_clk),
        .write_reset(reset),
        .synced_read_ptr(synced_read_ptr),
        .full(full),
        .write_address(write_address),
        .write_ptr(unsynced_write_ptr)
    );

    read_handler #(.DEPTH(DEPTH)) read_block (
        .read_en(read_en),
        .synced_write_ptr(synced_write_ptr),
        .read_reset(reset),
        .read_clk(read_clk),
        .next_read_address(next_read_address),
        .read_ptr(unsynced_read_ptr),
        .empty(empty)
    );

    synchronizer #(.POINTER_WIDTH($clog2(DEPTH)+1)) write_to_read (
        .receiving_clk(read_clk),
        .unsynced_ptr(unsynced_write_ptr),
        .reset(reset),
        .synced_ptr(synced_write_ptr)
    );

    synchronizer #(.POINTER_WIDTH($clog2(DEPTH)+1)) read_to_write (
        .receiving_clk(write_clk),
        .unsynced_ptr(unsynced_read_ptr),
        .reset(reset),
        .synced_ptr(synced_read_ptr)
    );


endmodule
