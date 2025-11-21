`timescale 1ns/1ps
// Resta de 3 bits A - B y B - A, usando complemento a 2.
// Salida de 4 bits: {signo, resultado[2:0]}.
// sign = 0 ? positivo, sign = 1 ? negativo
module sub3_c2(
  input  wire [2:0] A,
  input  wire [2:0] B,
  input  wire       sel,     // 0 = A - B, 1 = B - A
  output wire [3:0] DIFF4
);

  wire [2:0] A_in, B_in;
  assign A_in = (sel) ? B : A;
  assign B_in = (sel) ? A : B;

  // Complemento a dos del segundo operando
  wire [2:0] Bc2 = (~B_in) + 3'b001;
  wire [3:0] S;

  // Suma: A + (~B + 1)
  adder3 u_add(.A(A_in), .B(Bc2), .SUM4(S));

  // Signo: si el acarreo de salida es 0, resultado negativo
  wire sign = ~S[3];
  assign DIFF4 = {sign, S[2:0]};

endmodule

