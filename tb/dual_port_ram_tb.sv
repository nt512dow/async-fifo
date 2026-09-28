module dual_port_ram_tb ();
    localparam DEPTH = 16, WIDTH = 4;
    
    reg [WIDTH-1:0] write_data = 0;
    reg write_en = 1;
    reg write_full = 0;
    reg [$clog2(DEPTH)-1:0] write_address = 0;
    reg write_clk = 0;
    reg read_clk = 0;
    reg [$clog2(DEPTH)-1:0] next_read_address = 0;
    wire [WIDTH-1:0] read_data;

    dual_port_ram #(.DEPTH(DEPTH), .WIDTH(WIDTH)) dut (
        .write_data(write_data),
        .write_en(write_en),
        .write_full(write_full),
        .write_address(write_address),
        .write_clk(write_clk), 
        .read_clk(read_clk),
        .next_read_address(next_read_address),
        .read_data(read_data)
    );

    always #5 write_clk = ~write_clk;
    always #7 read_clk = ~read_clk;

    initial begin

    //able to write flag
    #1 
    assert(dut.able_to_write == 1);
    #1
    write_en = 0;
    #1
    assert(dut.able_to_write == 0);
    write_en = 1;

    //writing 
    write_data = 4'b1000;
    #3
    assert(dut.ram[write_address] == write_data);
    #2
    write_data = 4'b1001;
    write_address = write_address + 1;
    #14
    //reading 
    assert(read_data == 4'b1000);
    $finish;
    end

    initial begin
    $dumpfile("dual_port_ram.vcd");
    $dumpvars;
    end

endmodule
