module write_handler_tb ();
    localparam TEST_DEPTH = 16;
    reg write_en = 0;
    reg write_clk = 0;
    reg write_reset = 1;
    reg [$clog2(TEST_DEPTH):0] synced_read_ptr = 0;

    wire full;
    wire [$clog2(TEST_DEPTH)-1:0] write_address;
    wire [$clog2(TEST_DEPTH):0] write_ptr;
    
    write_handler #(.DEPTH(TEST_DEPTH)) dut (
        .write_en(write_en),
        .write_clk(write_clk),
        .write_reset(write_reset),
        .synced_read_ptr(synced_read_ptr),
        .full(full),
        .write_address(write_address),
        .write_ptr(write_ptr)
    );

    always #5 write_clk = ~write_clk;

    initial begin
        $dumpfile("write_handler.vcd");
        $dumpvars;
        write_reset = 0;
        #8
        assert(full == 0 && write_ptr == 0 && write_address == 0);
        write_reset = 1;

        @(posedge write_clk);

        write_en = 1;

        repeat(15) @(posedge write_clk);
        #1
        assert(full == 0);

        repeat(2) @(posedge write_clk);
        #1
        assert(full == 1);
        $finish;
    end
endmodule
