// Referente a materiais de F.A nos materiais de FSD!
module FA (
  input logic A, B, cin,
  output logic Saida,
  output logic cout
);

assign Saida = A ^ B ^ cin; 
assign cout = (A & B) | (A & cin) | (B & cin);

endmodule
