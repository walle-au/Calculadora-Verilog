`timescale 1ns/1ps
// Sumador de 3 bits usando arrastre de acarreo. Salida de 4 bits.
module adder3(
  input  wire [2:0] A,
  input  wire [2:0] B,
  output wire [3:0] SUM4
);
  wire s0, c0, s1, c1, s2, c2;

  full_adder fa0(.a(A[0]), .b(B[0]), .cin(1'b0), .sum(s0), .cout(c0));
  full_adder fa1(.a(A[1]), .b(B[1]), .cin(c0  ), .sum(s1), .cout(c1));
  full_adder fa2(.a(A[2]), .b(B[2]), .cin(c1  ), .sum(s2), .cout(c2));

  assign SUM4 = {c2, s2, s1, s0};  // 4 bits
endmodule
