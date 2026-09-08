// Referente a materiais de SUMSUB nos materiais de FSD!
module SUMSUB #(parameter WIDTH = 8) (
    input logic [WIDTH-1:0] A, B,
    input logic cin,
    output logic [WIDTH-1:0] Saida, // saída é gerada bit a bit
    output logic overflow, negative, zero, cout, equal, gtThan, lsThan
);

// Vetor de Carrys entre F.A.s
logic [WIDTH:0] carry;

assign carry[0] = cin;

logic [WIDTH-1:0] BAfterMode;
always_comb begin 
    if(cin) begin
        BAfterMode = ~B;
    end
    else begin
        BAfterMode = B;
    end
end

FA fullAdder (
    .A(A[0]),
    .B(BAfterMode[0]),
    .Saida(Saida[0]),
    .cin(cin),
    .cout(carry[1])
);

// Gerando todos os outros F.A.s necessários para implementação do SOMASUB
genvar i;
generate
    for(i = 1; i < WIDTH; i++) begin
        FA fullAdder (
            .A(A[i]),
            .B(BAfterMode[i]),
            .cin(carry[i]),
            .Saida(Saida[i]),
            .cout(carry[i+1])
        );
    end
endgenerate

assign zero = (Saida == '0) ? 1 : 0;
assign negative = (Saida[WIDTH-1]) ? 1 : 0;
assign cout = carry[WIDTH];
assign overflow = carry[WIDTH] ^ carry[WIDTH-1];

// Parte comparadora
assign equal = zero;
assign lsThan = (!overflow) ? negative : ~negative; // inverte o resultado caso tenha algum overflow, evitando resultados incorretos
assign gtThan = ~(equal || lsThan);

endmodule

