// ==============================
// bin6_to_dec2.v  (0..63 -> decenas y unidades)
// ==============================
module bin_to_bcd_0_63(
  input  [5:0] bin,
  output [3:0] tens,   // 0..6
  output [3:0] ones    // 0..9
);
  // División simple (sintetizable)
  assign tens = bin / 10;
  assign ones = bin % 10;
endmodule

// ==============================
// sevenseg_encode.v
// Salida para display de ánodo común: seg[6:0] = {a,b,c,d,e,f,g}
// BLANK apaga (todas en 1).
// MINUS enciende solo el segmento g.
// ==============================
module sevenseg_encode(
  input  [3:0] val,     // 0..9, otros -> blank
  input        minus,   // 1 => símbolo '-'
  input        blank,   // 1 => apagado
  output reg [6:0] seg
);
  always @* begin
    if (blank) begin
      seg = 7'b111_1111;      // apagado (ánodo común)
    end else if (minus) begin
      seg = 7'b111_1110;      // solo 'g' encendida -> '-'
    end else begin
      case (val)
        4'd0: seg = 7'b000_0001;
        4'd1: seg = 7'b100_1111;
        4'd2: seg = 7'b001_0010;
        4'd3: seg = 7'b000_0110;
        4'd4: seg = 7'b100_1100;
        4'd5: seg = 7'b010_0100;
        4'd6: seg = 7'b010_0000;
        4'd7: seg = 7'b000_1111;
        4'd8: seg = 7'b000_0000;
        4'd9: seg = 7'b000_0100;
        default: seg = 7'b111_1111; // blank
      endcase
    end
  end
endmodule

