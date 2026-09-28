module read_handler #(parameter DEPTH) (
    input read_en,
    input [$clog2(DEPTH):0] synced_write_ptr,
    input read_reset,
    input read_clk,

    output [$clog2(DEPTH)-1:0] next_read_address,
    output reg [$clog2(DEPTH):0] read_ptr,
    output reg empty
);

    localparam ADDR_BITS = $clog2(DEPTH);

    reg [ADDR_BITS:0] current_bin = 0;
    wire [ADDR_BITS:0] next_bin;
    wire [ADDR_BITS:0] next_read_ptr;

    assign next_bin = current_bin + ((~empty) & read_en);
    assign next_read_ptr = next_bin ^ (next_bin >> 1);

    always @(posedge read_clk) begin
        if (!read_reset) begin 
            current_bin <= 0;
            read_ptr <= 0;
        end else begin
            if ((!empty) && read_en) begin
                current_bin <= next_bin;
                read_ptr <= next_read_ptr;
            end
        end
    end


    always @(posedge read_clk) begin
        if (!read_reset) begin
            empty <= 1; 
        end else 
            //empty flag turns on when the last element is read
            empty <= (synced_write_ptr == next_read_ptr); 
    end

    assign next_read_address = next_bin[ADDR_BITS-1:0];

endmodule
