// Técnica referente aos packages das aulas de SD!
import alu_pkg::*;

module ALU #(parameter WIDTH = 8) 
(
    input logic [WIDTH-1:0] A, B,
    input op_code op,
    output logic [(2*WIDTH)-1:0] Saida, // (***)
    output logic zero, overflow, negative, equal, gtThan, lsThan
);


// Solda intermediária dos resultados de LOGIC com ALU
logic [WIDTH-1:0] resAndLogic, resOrLogic, resXorLogic, resNotLogic;

// Soldas intermediárias do ALU com SUMSUB
logic overflowSomaSub, zeroSomaSub, negativeSomaSub, coutSomaSub, equalSomaSub, gtSomaSub, ltSomaSub;

// Fio para modo aritimético (adição ou subtração)
logic mode;
assign mode = (op == SUB || op == COM) ? 1 : 0;

// Soldas intermediárias do resultado de SUMSUB com ALU
logic [WIDTH-1:0] resSomaSub;

// Soldas intermediárias do ALU com MUL
logic zeroMul;

// Soldas intermediárias do resultado de MUL com ALU
logic [(2*WIDTH)-1:0] resMul; // (***)

// Fio para saída do mux na ALU
logic [(2*WIDTH)-1:0] saidaMux; 

LOGIC #(.WIDTH(WIDTH)) LogicUnit (
    .A(A),
    .B(B),
    .SaidaAnd(resAndLogic),
    .SaidaOr(resOrLogic),
    .SaidaXor(resXorLogic),
    .SaidaNot(resNotLogic)
);

SUMSUB #(.WIDTH(WIDTH)) SumSubUnit (
    .A(A),
    .B(B),
    .cin(mode),
    .Saida(resSomaSub),
    .overflow(overflowSomaSub),
    .negative(negativeSomaSub),
    .zero(zeroSomaSub),
    .cout(coutSomaSub),
    .equal(equalSomaSub),
    .gtThan(gtSomaSub),
    .lsThan(ltSomaSub)
);

MUL #(.WIDTH(WIDTH)) MulUnit (
    .A(A),
    .B(B),
    .Saida(resMul),
    .zero(zeroMul)
);

always_comb begin
    // as flags de controle iniciam-se com zero, e só mudam a depender da operação realizada
    zero     = 1'b0;
    overflow = 1'b0;
    negative = 1'b0;
    //cout     = 1'b0;
    equal    = 1'b0;
    gtThan   = 1'b0;
    lsThan   = 1'b0;

    case(op)
        SUM: 
            begin
                saidaMux = {{WIDTH{1'b0}}, resSomaSub};
                zero = zeroSomaSub;
                overflow = overflowSomaSub;
                negative = negativeSomaSub;
                //cout = coutSomaSub;
            end
        SUB:
            begin
                saidaMux = {{WIDTH{1'b0}}, resSomaSub};
                zero = zeroSomaSub;
                overflow = overflowSomaSub;
                negative = negativeSomaSub;
                //cout = coutSomaSub;
            end
        MUL:
            begin
                saidaMux = resMul;
                zero = zeroMul;
            end
        COM:  
            begin
                saidaMux = '0; // os resultados de uma comparação são descritos nos sinais
                equal = equalSomaSub;
                gtThan = gtSomaSub;
                lsThan = ltSomaSub;
            end
        AND:  
            begin
                saidaMux = {{WIDTH{1'b0}}, resAndLogic};
                zero     = (!resAndLogic) ? 1 : 0;
            end
        OR:   
            begin 
                saidaMux = {{WIDTH{1'b0}}, resOrLogic};
                zero     = (!resOrLogic) ? 1 : 0;
            end
        XOR:  
            begin 
                saidaMux = {{WIDTH{1'b0}}, resXorLogic};
                zero     = (!resXorLogic) ? 1 : 0;
            end
        NOT:  
            begin 
                saidaMux = {{WIDTH{1'b0}}, resNotLogic};
                zero     = (!resNotLogic) ? 1 : 0;
            end
        default: saidaMux = '0;
    endcase
end

assign Saida = saidaMux;

endmodule
