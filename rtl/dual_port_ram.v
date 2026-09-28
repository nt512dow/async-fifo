module dual_port_ram #(parameter DEPTH = 16, WIDTH = 4) (
    input [WIDTH-1:0] write_data,
    input write_en,
    input write_full,
    input [$clog2(DEPTH)-1:0] write_address,
    input write_clk,
    
    input read_clk,
    input [$clog2(DEPTH)-1:0] read_address,
    output [WIDTH-1:0] read_data
);
    reg able_to_write;
    reg [WIDTH-1:0] ram[DEPTH];
    always @(posedge write_clk) begin 
        if (able_to_write) begin
            ram[write_address] <= write_data;
        end
    end

    assign read_data = ram[read_address];
    assign able_to_write = write_en & (~write_full);
endmodule
