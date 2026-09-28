module write_handler #(parameter DEPTH = 16) (
    input write_en,
    input write_clk,
    input write_reset,
    input [$clog2(DEPTH):0] synced_read_ptr,

    output reg full,
    output reg [$clog2(DEPTH)-1:0] write_address,
    output reg [$clog2(DEPTH):0] write_ptr
);

    localparam ADDR_BITS = $clog2(DEPTH);

    reg [ADDR_BITS:0] current_bin = 0;
    wire [ADDR_BITS:0] next_bin;
    wire [ADDR_BITS:0] next_write_ptr;


    assign next_bin = current_bin + (write_en & (~full));
    assign next_write_ptr = next_bin ^ (next_bin >> 1);

    always @ (posedge write_clk) begin
        if (!write_reset) begin
            write_ptr <= 0;
            current_bin <= 0;
        end else if (!full && write_en) begin
            //increment write_ptr and write_address
            current_bin <= next_bin;
            write_ptr <= next_write_ptr;
        end
    end

    //ensures full flag is updated in the same clock cycle that the last element is written
    always @ (posedge write_clk) begin
        if (!write_reset) begin
            full <= 0;
        end else begin
            full <= (next_write_ptr[ADDR_BITS] != synced_read_ptr[ADDR_BITS] &&
        next_write_ptr[ADDR_BITS-1] != synced_read_ptr[ADDR_BITS-1] &&
        next_write_ptr[ADDR_BITS-2:0] == synced_read_ptr[ADDR_BITS-2:0]
        );
        end
    end

    assign write_address = current_bin[ADDR_BITS-1:0];
endmodule
