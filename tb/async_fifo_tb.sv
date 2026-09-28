module async_fifo_tb ();
    localparam  DEPTH = 4, WIDTH = 4;
    reg [WIDTH-1:0] write_data = 0;
    reg write_en = 0;
    reg write_clk;
    reg read_en = 0;
    reg read_clk;
    reg reset = 1;

    wire [WIDTH-1:0] read_data;
    wire full;
    wire empty;

    async_fifo #(.DEPTH(DEPTH), .WIDTH(WIDTH)) dut (
        .write_data(write_data),
        .write_en(write_en),
        .write_clk(write_clk),
        .read_en(read_en),
        .read_clk(read_clk),
        .reset(reset),
        .read_data(read_data),
        .full(full),
        .empty(empty)
    );

    integer write_attempts = 0;
    integer successful_writes = 0;
    integer successful_reads = 0;
    reg [WIDTH-1:0] q[$];
    reg element_read;

    real write_half_period;
    real read_half_period;


    //different clock periods
    initial begin
        if (!$value$plusargs("write_half_period=%f", write_half_period)) begin
            write_half_period = 5.5;
        end
        if (!$value$plusargs("read_half_period=%f", read_half_period)) begin
            read_half_period = 5.0;
        end
        $display("Running with write_period=%0.2f read_period=%0.2f", write_half_period, read_half_period);
        write_clk = 0;
        read_clk = 0;

        forever #(write_half_period) write_clk = ~write_clk;
        forever #(read_half_period) read_clk = ~read_clk;
    end

    initial begin
        fork 
            begin : write_simulation
                forever @(posedge write_clk) begin
                    if (!full && write_en) begin
                        successful_writes <= successful_writes + 1;
                        q.push_back(write_data);
                    end

                    if ($urandom_range(1,100) <= 70) begin
                        write_en <= 1;
                        write_attempts <= write_attempts + 1;
                    end else begin
                        write_en <= 0;
                    end

                    write_data <= $urandom_range(0, {WIDTH{1'b1}});
                end
            end

            begin : read_simulation
                forever @(posedge read_clk) begin
                    if (!empty && read_en) begin
                        successful_reads <= successful_reads + 1;
                        
                    end

                    if ($urandom_range(1, 100) <= 70) begin
                        read_en <= 1;
                    end else begin
                        read_en <= 0;
                    end
                end
            end

    
            begin : checking_process
                forever @(posedge read_clk) begin
                    if (!empty && read_en && q.size() > 0) begin
                        automatic reg [WIDTH-1:0] current_front_element = q.pop_front();
                        if (current_front_element != read_data) begin
                            $display("ERROR");
                            $display("the current front element is %0d and read data is %0d", current_front_element, read_data);
                            $display("the successful reads are %0d, the successful writes are %0d", successful_reads, successful_writes);
                        end else begin
                            $display("OKAY");
                            $display("the current front element is %0d and read data is %0d", current_front_element, read_data);
                            $display("the successful reads are %0d, the successful writes are %0d", successful_reads, successful_writes);
                        end
                        assert(current_front_element == read_data);
                    end
                    #1; //done to avoid race conditions between posedge write_clk and posedge read_clk
                    assert(successful_reads <= successful_writes);
                end
            end
    
            
        join 
    end
    

    initial begin
        wait (write_attempts > 1000*DEPTH);
        $finish;
    end

    initial begin
    $dumpfile("async_fifo.vcd");
    $dumpvars;
    end

endmodule
