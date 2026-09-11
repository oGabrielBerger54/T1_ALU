module MUL #(parameter WIDTH = 8) (
    input  logic [WIDTH-1:0] A, B,
    output logic [(2*WIDTH)-1:0] Saida,
    output logic zero
);

// matriz de produtos parciais gerados pelas portas AND (linha = bit de B, coluna = bit de A)
logic [WIDTH-1:0] currentMultiplication [WIDTH-1:0];

// matriz com o bit de soma produzido por cada soma
logic [WIDTH-1:0] sumBit [WIDTH-1:0];

// matriz com o bit de carry produzido por cada soma para cada bit da próxima soma
logic [WIDTH-1:0] carryBit [WIDTH-1:0];

// matriz com a segunda entrada de cada somador (o número que vem de cima)
logic [WIDTH-1:0] sumIn [WIDTH-1:0];

genvar i, j;

generate
    for(i = 0; i < WIDTH; i++) begin
        for(j = 0; j < WIDTH; j++) begin
            assign currentMultiplication[i][j] = A[j] & B[i];
        end
    end
endgenerate

generate
    for(j = 0; j < WIDTH; j++) begin
        // coloca na primeira linha do sumBit já o primeiro termo da soma, que é a primeira linha do currentMultiplication!
        assign sumBit[0][j] = currentMultiplication[0][j];
        // coloca na primeira linha do carry tudo zero, visto que não há carry na primeira linha de currentMultiplication!
        assign carryBit[0][j] = 0;
    end
endgenerate

generate
    // agora, faremos o procedimentos das linhas 1 em diante
    for(i = 1; i < WIDTH; i++) begin
        for(j = 0; j < WIDTH; j++) begin

            // primeiramente selecionamos o sumIn (que vem de cima)
            if(j == WIDTH-1) begin
                // por não ter diagonal equivalente em sumBit, utiliza-se sempre o ultimo carry da ultima linha
                assign sumIn[i][j] = carryBit[i-1][WIDTH-1];
            end
            else begin
                // As demais colunas recebem o bit de diagonal do sumBit, simulando um shift left
                assign sumIn[i][j] = sumBit[i-1][j+1];
            end

            // após isso, finalmente somamos, se for o primeiro bit, usamos um H.A., caso contrario, utilizamos um F.A.
            if(j == 0) begin
                HA halfAdder (
                    .A(currentMultiplication[i][j]),
                    .B(sumIn[i][j]),
                    .Saida(sumBit[i][j]),
                    .cout(carryBit[i][j])
                );
            end
            else begin
                FA fullAdder (
                    .A(currentMultiplication[i][j]),
                    .B(sumIn[i][j]),
                    .cin(carryBit[i][j-1]),
                    .Saida(sumBit[i][j]),
                    .cout(carryBit[i][j])
                );
            end
        end
    end
endgenerate

// O primeiro bit da saida não está ligado a nenhum H.A. ou F.A.
assign Saida[0] = sumBit[0][0];

generate
    for(i = 1; i < WIDTH-1; i++) begin
        assign Saida[i] = sumBit[i][0];
    end
endgenerate

generate
    for(j = 0; j < WIDTH; j++) begin
        assign Saida[WIDTH-1+j] = sumBit[WIDTH-1][j];
    end
endgenerate

assign Saida[(2*WIDTH)-1] = carryBit[WIDTH-1][WIDTH-1];

assign zero = (Saida == '0) ? 1 : 0;

endmodule

