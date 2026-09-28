module read_handler_tb ();
    localparam TEST_DEPTH = 16;
    reg read_en = 0;
    reg [$clog2(TEST_DEPTH):0] synced_write_ptr = 0;
    reg read_reset = 1;
    reg read_clk = 0;

    wire [$clog2(TEST_DEPTH)-1:0] next_read_address;
    wire [$clog2(TEST_DEPTH):0] read_ptr;
    wire empty;

    read_handler #(.DEPTH(TEST_DEPTH)) dut (
        .read_en(read_en),
        .synced_write_ptr(synced_write_ptr),
        .read_reset(read_reset),
        .read_clk(read_clk),
        .next_read_address(next_read_address),
        .read_ptr(read_ptr),
        .empty(empty)
    );

    always #5 read_clk = ~read_clk;

    reg [$clog2(TEST_DEPTH):0] write_ptr_bin = 5'd8;


    initial begin
        $dumpfile("read_handler.vcd");
        $dumpvars;
        read_reset = 0;
        #8
        assert(empty == 1 && next_read_address == 0 && read_ptr == 0);

        synced_write_ptr = write_ptr_bin ^ (write_ptr_bin >> 1);
        read_reset = 1;
        
        @(posedge read_clk);
        #1
        read_en = 1;
        assert(empty == 0);

        repeat(8) @ (posedge read_clk);
        #1
        assert(empty == 1);
        $finish;
    end
endmodule
