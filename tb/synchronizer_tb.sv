module synchronizer_tb ();
    localparam POINTER_WIDTH = 5;
    reg receiving_clk = 0;
    reg [POINTER_WIDTH-1:0] unsynced_ptr = 0;
    reg reset = 1;

    wire [POINTER_WIDTH-1:0] synced_ptr;

    synchronizer #(.POINTER_WIDTH(POINTER_WIDTH)) dut (
        .receiving_clk(receiving_clk),
        .unsynced_ptr(unsynced_ptr),
        .reset(reset),
        .synced_ptr(synced_ptr)
    );

    always #5 receiving_clk = ~receiving_clk;

    initial begin
    $dumpfile("synchronizer.vcd");
    $dumpvars;

    reset = 0;
    #8
    assert(synced_ptr == 0 && dut.intermediate_signal == 0);
    #6
    reset = 1;

    /*
    2 transmissions
    1. just 14
    2. 14 and 15, each taking one cycle
    starting 1 ns before posedge, each test will last for 2 cycles
    */
    unsynced_ptr = 5'b01001;
    #10
    assert(dut.intermediate_signal == unsynced_ptr);
    assert(synced_ptr != unsynced_ptr);
    #10
    assert(dut.intermediate_signal == unsynced_ptr);
    assert(synced_ptr == unsynced_ptr);

    unsynced_ptr = 5'b01001;
    #5
    unsynced_ptr = 5'b01000;
    #15
    assert(dut.intermediate_signal == 5'b01000);
    assert(synced_ptr == 5'b01001);

    $finish;
    end

endmodule
