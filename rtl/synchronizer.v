module synchronizer #(parameter POINTER_WIDTH = 5)(
    input receiving_clk,
    input [POINTER_WIDTH-1:0] unsynced_ptr,
    input reset,

    output reg [POINTER_WIDTH-1:0] synced_ptr
);

reg [POINTER_WIDTH-1:0] intermediate_signal;

always @(posedge receiving_clk) begin
    if (!reset) begin
        synced_ptr <= 0;
        intermediate_signal <= 0;
    end else begin
        intermediate_signal <= unsynced_ptr;
        synced_ptr <= intermediate_signal;
    end
end


endmodule
