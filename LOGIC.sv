// Referente a materiais de Lógica Booleana nos materiais de FSD!
module LOGIC #(parameter WIDTH = 8) (
  input  logic [WIDTH-1:0] A, B,
  output logic [WIDTH-1:0] SaidaAnd,
  output logic [WIDTH-1:0] SaidaOr,
  output logic [WIDTH-1:0] SaidaXor,
  output logic [WIDTH-1:0] SaidaNot
);

assign SaidaAnd = A & B; 
assign SaidaOr  = A | B; 
assign SaidaXor = A ^ B; 
assign SaidaNot = ~A;

endmodule


