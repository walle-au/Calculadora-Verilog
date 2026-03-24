// alu3.v
`timescale 1ns/1ps

module alu3(
  input  wire [2:0] A,
  input  wire [2:0] B,
  input  wire [1:0] op,        // 00:ADD, 01:SUB, 10:MUL, 11:RESERVADO
  input  wire       sub_dir,   // 0: A-B, 1: B-A
  output wire [3:0] add4,      // suma (0..14)
  output wire [3:0] sub4,      // {sign, mag[2:0]}  (sign=1 => negativo)
  output wire [5:0] mul6,      // producto (0..63)
  output wire [5:0] Y6,        // salida de 6 bits para LED/Display
  output wire       sign_sub   // signo de la resta (1 si negativo)
);

  // Suma
  wire [3:0] sum_w = {1'b0, A} + {1'b0, B};
  assign add4 = sum_w;

  // Resta dirigida (A-B o B-A) en signed de 4 bits
  wire signed [3:0] sdiff =
      sub_dir ? ( $signed({1'b0,B}) - $signed({1'b0,A}) )
              : ( $signed({1'b0,A}) - $signed({1'b0,B}) );

  assign sign_sub = (sdiff < 0);               // 1 si negativo
  wire [3:0] mag4 = sign_sub ? -sdiff : sdiff; 
  assign sub4 = {sign_sub, mag4[2:0]};

  // Multiplicación
  assign mul6 = A * B;

  // MUX a 6 bits para LEDs/Display.
  assign Y6 = (op == 2'b00) ? {2'b00, add4} :
              (op == 2'b01) ? {3'b000, mag4[2:0]} :
              (op == 2'b10) ? mul6 :
                              6'd0;

endmodule
