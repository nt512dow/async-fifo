module dual_port_ram #(parameter DEPTH = 16, WIDTH = 4) (
    input [WIDTH-1:0] write_data,
    input write_en,
    input write_full,
    input [$clog2(DEPTH)-1:0] write_address,
    input write_clk,
    
    input read_clk,
    input [$clog2(DEPTH)-1:0] next_read_address,
    output reg [WIDTH-1:0] read_data
);
    reg able_to_write;
    reg [WIDTH-1:0] ram[DEPTH];
    always @(posedge write_clk) begin 
        if (able_to_write) begin
            ram[write_address] <= write_data;
        end
    end

    always @(posedge read_clk) begin
        read_data <= ram[next_read_address]; //this ensures that the data is valid on the next posedge, no lag
    end

    assign able_to_write = write_en & (~write_full);
endmodule
