// Testbench self-checking da ALU

`timescale 1ns / 1ps

import alu_pkg::*;

module tb_ALU();

    localparam WIDTH = 8;

    // niveis de verbosidade: 0 = so o resumo, 1 = fases, 2 = cada vetor
    localparam NONE = 0, LOW = 1, ALTO = 2;
    int verb = LOW;

    // 1 = testa todas as combinacoes, 0 = so os casos dirigidos
    localparam EXAUSTIVO = 1;

    logic [WIDTH-1:0]     A, B;
    op_code               op;
    logic [(2*WIDTH)-1:0] Saida;
    logic zero, overflow, negative, equal, gtThan, lsThan;

    // valores esperados, calculados pelo modelo de referencia
    logic [(2*WIDTH)-1:0] eSaida;
    logic eZero, eOvf, eNeg, eEq, eGt, eLs;

    int testes = 0, erros = 0;

    ALU #(.WIDTH(WIDTH)) dut (
        .A(A), .B(B), .op(op), .Saida(Saida),
        .zero(zero), .overflow(overflow), .negative(negative),
        .equal(equal), .gtThan(gtThan), .lsThan(lsThan)
    );

    // calcula o que a ALU deveria responder
    task automatic modelo(input logic [WIDTH-1:0] a, b, input op_code o);
        logic [WIDTH-1:0]     bb, soma, res;
        logic [WIDTH-2:0]     low;
        logic                 cin, c7, c8;
        logic [(2*WIDTH)-1:0] prod;

        // a ALU zera todas as flags antes do case
        eSaida = '0;
        eZero = 0; eOvf = 0; eNeg = 0; eEq = 0; eGt = 0; eLs = 0;

        case (o)
            SUM, SUB: begin
                cin = (o == SUB);            // subtrair = somar ~B + 1
                bb  = cin ? ~b : b;
                {c7, low}  = a[WIDTH-2:0] + bb[WIDTH-2:0] + cin;
                {c8, soma} = a + bb + cin;
                eSaida = {{WIDTH{1'b0}}, soma};
                eZero  = (soma == '0);
                eNeg   = soma[WIDTH-1];
                eOvf   = c8 ^ c7;            // overflow em complemento de dois
            end

            MUL: begin
                prod   = a * b;              // multiplicacao sem sinal, 16 bits
                eSaida = prod;
                eZero  = (prod == '0);
            end

            COM: begin                       // a comparacao vem de A - B, logo e com sinal
                eEq = (a == b);
                eLs = ($signed(a) < $signed(b));
                eGt = !(eEq || eLs);
            end

            AND, OR, XOR, NOT: begin
                case (o)
                    AND:     res = a & b;
                    OR:      res = a | b;
                    XOR:     res = a ^ b;
                    default: res = ~a;       // NOT usa so o A
                endcase
                eSaida = {{WIDTH{1'b0}}, res};
                eZero  = (res == '0);
            end

            default: ;                       // op invalido: tudo em zero
        endcase
    endtask

    // aplica um vetor e confere saida e flags
    task automatic testa(input logic [WIDTH-1:0] a, b, input op_code o);
        A = a; B = b; op = o;
        #1;
        modelo(a, b, o);
        testes++;

        if (verb >= ALTO)
            $display("[%0t] %-3s A=%3d B=%3d -> Saida=%04h z=%b ovf=%b neg=%b eq=%b gt=%b ls=%b",
                     $time, o.name(), a, b, Saida, zero, overflow, negative, equal, gtThan, lsThan);

        assert ({Saida, zero, overflow, negative, equal, gtThan, lsThan} ===
                {eSaida, eZero, eOvf, eNeg, eEq, eGt, eLs})
        else begin
            erros++;
            if (erros <= 20)   // evita encher o log se o erro for sistematico
                $error("%s A=%0d B=%0d | obtido %04h %b%b%b%b%b%b | esperado %04h %b%b%b%b%b%b",
                       o.name(), a, b,
                       Saida,  zero,  overflow, negative, equal, gtThan, lsThan,
                       eSaida, eZero, eOvf, eNeg, eEq, eGt, eLs);
        end
    endtask

    // casos de borda, um por linha
    task automatic dirigidos();
        if (verb >= LOW) $display("[%0t] casos dirigidos", $time);

        testa(8'd0,   8'd0,   SUM);   // resultado zero
        testa(8'd127, 8'd1,   SUM);   // overflow
        testa(8'd128, 8'd128, SUM);   // overflow + cout

        testa(8'd10,  8'd4,   SUB);
        testa(8'd4,   8'd10,  SUB);   // resultado negativo
        testa(8'd7,   8'd7,   SUB);   // resultado zero
        testa(8'd128, 8'd1,   SUB);   // overflow

        testa(8'd0,   8'd37,  MUL);
        testa(8'd5,   8'd3,   MUL);
        testa(8'd255, 8'd255, MUL);   // maior produto

        testa(8'd7,   8'd10,  COM);   // menor
        testa(8'd10,  8'd7,   COM);   // maior
        testa(8'd9,   8'd9,   COM);   // igual
        testa(8'd200, 8'd50,  COM);   // negativo vs positivo

        testa(8'h0F,  8'h33,  AND);
        testa(8'hF0,  8'h0F,  AND);   // zera
        testa(8'hF0,  8'h0F,  OR);
        testa(8'hAA,  8'h55,  XOR);
        testa(8'hAA,  8'hAA,  XOR);   // zera
        testa(8'h00,  8'h00,  NOT);
        testa(8'hFF,  8'h00,  NOT);   // zera
    endtask

    // todas as combinacoes de A, B e op
    task automatic exaustivo();
        op_code o;
        for (int k = 0; k < 8; k++) begin
            o = op_code'(k);
            if (verb >= LOW) $display("[%0t] varrendo %s", $time, o.name());
            for (int i = 0; i < 256; i++)
                for (int j = 0; j < 256; j++)
                    testa(i[WIDTH-1:0], j[WIDTH-1:0], o);
        end
    endtask

    // op fora dos valores validos, para cobrir o default do case da ALU
    task automatic opInvalido();
        logic [2:0] raw = 3'bxxx;
        if (verb >= LOW) $display("[%0t] operacao invalida", $time);
        A = 8'hA5; B = 8'h5A; op = op_code'(raw);
        #1;
        testes++;
        assert (Saida === '0 && {zero,overflow,negative,equal,gtThan,lsThan} === 6'b0)
        else begin
            erros++;
            $error("op invalida deveria zerar tudo, veio Saida=%04h", Saida);
        end
        op = SUM;
        #1;
    endtask

    initial begin
        void'($value$plusargs("VERB=%d", verb));   // ex: vsim ... +VERB=2

        A = '0; B = '0; op = SUM;
        #2;

        dirigidos();
        if (EXAUSTIVO) exaustivo();
        opInvalido();

        $display("");
        $display("testes: %0d   erros: %0d   -> %s", testes, erros, (erros == 0) ? "PASS" : "FAIL");
        $finish;
    end

endmodule
