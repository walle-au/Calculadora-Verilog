`timescale 1ns/1ps
// Multiplicación sin signo de 3x3 bits => 6 bits
module mul3(
  input  wire [2:0] A,
  input  wire [2:0] B,
  output wire [5:0] PROD6
);
  assign PROD6 = A * B;
endmodule

