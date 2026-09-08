// Referente a materiais de H.A. nos materiais de FSD!
module HA (
  input logic A, B,
  output logic Saida,
  output logic cout
);

assign Saida = A ^ B;
assign cout = A & B;

endmodule

