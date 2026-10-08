module counter_4bit (
    input        clk,
    input        rst_n,
    output reg [3:0] count
);

    always @(posedge clk) begin
        if (!rst_n)
            count <= 4'b0000;
        else
            count <= count + 1'b1;
    end

endmodule