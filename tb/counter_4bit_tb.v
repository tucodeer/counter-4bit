`timescale 1ns/1ps

module counter_4bit_tb;

    reg clk;
    reg rst_n;
    wire [3:0] count;

    reg [3:0] expected;
    integer errors;

    counter_4bit dut (
        .clk(clk),
        .rst_n(rst_n),
        .count(count)
    );

    // Clock
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // Test
    initial begin
        errors = 0;
        expected = 4'd0;
        rst_n = 1'b0;

        // Reset
        @(posedge clk);
        #1;

        if (count !== 4'd0) begin
            $display("FAIL: Reset");
            errors = errors + 1;
        end
        else begin
            $display("PASS: Reset");
        end

        // Release reset
        @(negedge clk);
        rst_n = 1'b1;

        // Count 32 cycles
        repeat (32) begin
            @(posedge clk);
            #1;

            expected = expected + 1'b1;

            if (count !== expected) begin
                $display("FAIL: expected=%d actual=%d", expected, count);
                errors = errors + 1;
            end
            else begin
                $display("PASS: expected=%d actual=%d", expected, count);
            end
        end

        // Result
        if (errors == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED: %0d error(s)", errors);

        $finish;
    end

    // VCD waveform
    initial begin
        $dumpfile("sim/counter_4bit.vcd");
        $dumpvars(0, counter_4bit_tb);
    end

endmodule