`timescale 1ns / 1ps

import alu_pkg::*;

module tb_ALU();

    parameter WIDTH = 8;

    logic [WIDTH-1:0] A;
    logic [WIDTH-1:0] B;
    op_code op;

    logic [(2*WIDTH)-1:0] Saida;
    logic zero, overflow, negative, cout, equal, gtThan, lsThan;

    ALU #(.WIDTH(WIDTH)) dut (
        .A(A),
        .B(B),
        .op(op),
        .Saida(Saida),
        .zero(zero),
        .overflow(overflow),
        .negative(negative),
        .cout(cout),
        .equal(equal),
        .gtThan(gtThan),
        .lsThan(lsThan)
    );

    initial begin
        A = '0;
        B = '0;
        op = SUM;
        #10;

        A = 8'd5;
        B = 8'd3;
        op = SUM;
        #10;
        $display("SUM: %0d + %0d = %0d (zero=%b, cout=%b)", A, B, Saida[WIDTH-1:0], zero, cout);

        A = 8'd10;
        B = 8'd4;
        op = SUB;
        #10;
        $display("SUB: %0d - %0d = %0d (zero=%b, negative=%b)", A, B, Saida[WIDTH-1:0], zero, negative);

        A = 8'd5;
        B = 8'd3;
        op = MUL;
        #10;
        $display("MUL: %0d * %0d = %0d", A, B, Saida);

        A = 8'd15;
        B = 8'd10;
        op = MUL;
        #10;
        $display("MUL: %0d * %0d = %0d", A, B, Saida);

        A = 8'd7;
        B = 8'd10;
        op = COM;
        #10;
        $display("COM: %0d vs %0d -> equal=%b, gtThan=%b, lsThan=%b", A, B, equal, gtThan, lsThan);

        A = 8'h0F;
        B = 8'h33;
        op = AND;
        #10;
        $display("AND: %b & %b = %b", A, B, Saida[WIDTH-1:0]);

        #10;
        $finish;
    end

endmodule
