# T1_ALU
Projeto referente ao trabalho 1 da disciplina Sistemas Digitais da PUCRS

Foi descrita uma ULA (Unidade Lógica Aritmética) em SystemVerilog para ser programada na placa FPGA Nexys A7, com os resultados numéricos exibidos nos LEDs monocromáticos e casos especiais (overflow, zero, negativo) e de comparação(equal, greater than, less than) nos LEDs RGB direito e esquerdo, respectivamente.

O design inteiro é puramente combinacional — não existe clock, latch nem flip-flop em nenhum ponto.

## Inputs:
Os inputs são as variáveis A e B, e o opcode. Tanto A quanto B são definidos bit a bit nos switchs de 0 a 15, onde de 0 a 7 é o valor de A, de 8 a 15 o valor de B. O opcode é um vetor de 3 bits, cada bit é definido pelos botões BTNL, BTNC e BTNR, as operações são dadas pela tabela abaixo:

BTNL | BTNU | BTNR | op

  0  |   0  |  0   | SUM
  
  0  |   0  |  1   | SUB
  
  0  |   1  |  0   | MUL
  
  0  |   1  |  1   | COM
  
  1  |   0  |  0   | AND
  
  1  |   0  |  1   | OR
  
  1  |   1  |  0   | XOR
  
  1  |   1  |  1   | NOT
  
  Por motivos de economia de recursos, é necessário segurar os botões para realizar as operações. Por padrão o opcode é definido para soma.

## Output
Os LEDs RGB indicam os casos abaixo:

LED-esquerda:   Azul  |    Verde      |    Vermelho

              equal | A maior que B | B Maior que A                             

 LED-esquerda:   Azul  |    Verde    | Vermelho
 
                 Zero  |   Negativo  | Overflow

## Fluxo

 SW[7:0]  ────────────► A[7:0] ──┐
 
                                 │
                                 
 SW[15:8]  ────────────► B[7:0] ──┼──►  [ ALU ]  ──► result[15:0] ──► LED[15:0]
 
                                 │ 
                                 
{BTNL,BTNU,BTNR} ───► opcode[2:0]┘
