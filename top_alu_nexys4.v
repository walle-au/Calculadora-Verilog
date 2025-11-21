// top_alu_nexys4.v
`timescale 1ns/1ps

module top_alu_nexys4(
  input  wire        clk100mhz,     // reloj de la Nexys4 DDR
  input  wire        btnC,          // reset activo en 1 (botón central)
  input  wire [15:0] sw,            // switches
  output wire [15:0] led,           // leds
  output reg  [6:0]  seg,           // segmentos a-g, ACTIVO EN BAJO
  output reg         dp,            // punto decimal, ACTIVO EN BAJO
  output reg  [7:0]  an             // ánodos, ACTIVO EN BAJO (an[7] = dígito más a la izquierda)
);

  // ============== Entradas desde switches ==============
  wire [2:0] A       = sw[2:0];
  wire [2:0] B       = sw[5:3];
  wire [1:0] op      = sw[7:6];     // 00 suma, 01 resta, 10 mult
  wire        sub_dir = sw[8];      // 0 A-B, 1 B-A
  wire        rst     = btnC;

  // ============== ALU ==============
  wire [3:0] add4, sub4;            // suma y resta (4 bits)
  wire [5:0] mul6;                  // multiplicación (6 bits)
  wire [5:0] Y6;                    // salida "general" de 6 bits (tu ALU ya la entrega)
  wire       sign_sub;              // 1 si la resta es negativa (borrow)

  alu3 u_alu(
    .A(A), .B(B), .op(op), .sub_dir(sub_dir),
    .add4(add4), .sub4(sub4), .mul6(mul6), .Y6(Y6), .sign_sub(sign_sub)
  );

  // ============== LEDs (resultado + info) ==============
  // - Resultado:
  //   * SUMA (op=00)  -> led[3:0] = add4
  //   * RESTA(op=01)  -> led[3:0] = sub4   (sub4[3]=borrow/signo)
  //   * MULT (op=10)  -> led[5:0] = mul6
  // - Info (no interfiere con los bits de resultado):
  //   * led[9]   = signo en resta (borrow) cuando op=01
  //   * led[8]   = sub_dir
  //   * led[7:6] = op
  //   * led[12:10]= A
  //   * led[15:13]= B
  reg [15:0] led_r;

  always @* begin
    led_r = 16'b0;                // apaga todo por defecto

    // Resultado en la parte baja sin "fugas"
    case (op)
      2'b00: begin                // SUMA: 4 bits
        led_r[3:0] = add4;
      end
      2'b01: begin                // RESTA: 4 bits {borrow, diff[2:0]}
        led_r[3:0] = sub4;
      end
      2'b10: begin                // MULT: 6 bits
        led_r[5:0] = mul6;
      end
      default: begin
        led_r[5:0] = 6'b0;
      end
    endcase

    // Información útil en los bits altos (no afecta el resultado)
    led_r[9]     = (op==2'b01) ? sign_sub : 1'b0;
    led_r[8]     = sub_dir;
    led_r[7:6]   = op;
    led_r[12:10] = A;
    led_r[15:13] = B;
  end

  assign led = led_r;

  // ============== Conversión a decimal (0..63) ==============
  // Para mostrar en 7-seg (decenas/unidades) usando Y6 (6 bits)
  wire [3:0] dec_tens;
  wire [3:0] dec_ones;

  assign dec_tens = (Y6 >= 6'd50) ? 4'd5 :
                    (Y6 >= 6'd40) ? 4'd4 :
                    (Y6 >= 6'd30) ? 4'd3 :
                    (Y6 >= 6'd20) ? 4'd2 :
                    (Y6 >= 6'd10) ? 4'd1 : 4'd0;

  assign dec_ones = Y6 - (dec_tens * 6'd10);

  // ============== Driver 7-seg de 8 dígitos ==============
  // Divisor a ~1kHz para multiplexado
  wire tick1k;
  clk_divider #(.INPUT_HZ(100_000_000), .TARGET_HZ(1_000)) u_div (
    .clk_in(clk100mhz), .rst(rst), .clk_out(tick1k)
  );

  reg [2:0] scan;          // 0..7
  always @(posedge tick1k or posedge rst) begin
    if (rst) scan <= 3'd0;
    else     scan <= scan + 3'd1;
  end

  // Encoders de segmentos (activo en bajo)
  function [6:0] seg7_num(input [3:0] v);
    begin
      case (v)
        4'd0: seg7_num = 7'b1000000;
        4'd1: seg7_num = 7'b1111001;
        4'd2: seg7_num = 7'b0100100;
        4'd3: seg7_num = 7'b0110000;
        4'd4: seg7_num = 7'b0011001;
        4'd5: seg7_num = 7'b0010010;
        4'd6: seg7_num = 7'b0000010;
        4'd7: seg7_num = 7'b1111000;
        4'd8: seg7_num = 7'b0000000;
        4'd9: seg7_num = 7'b0010000;
        default: seg7_num = 7'b1111111; // blank
      endcase
    end
  endfunction

  localparam [6:0] SEG_BLANK = 7'b1111111;
  localparam [6:0] SEG_DASH  = 7'b0111111; // solo 'g' encendida (activo en bajo)

  // Dígitos que mostraremos (AN7..AN0)
  // AN7 = op[1], AN6 = op[0], AN2 = signo si resta negativa, AN1=decenas, AN0=unidades
  reg [6:0] dig7, dig6, dig5, dig4, dig3, dig2, dig1, dig0;

  always @* begin
    // por defecto
    dig7 = seg7_num({3'b000, op[1]}); // 0/1
    dig6 = seg7_num({3'b000, op[0]}); // 0/1
    dig5 = SEG_BLANK;
    dig4 = SEG_BLANK;
    dig3 = SEG_BLANK;

    // Tercer dígito desde la derecha (AN2): signo de resta si negativa
    if (op == 2'b01 && sign_sub) dig2 = SEG_DASH;
    else                         dig2 = SEG_BLANK;

    // AN1, AN0: decenas/unidades del resultado Y6 (0..63)
    dig1 = seg7_num(dec_tens);
    dig0 = seg7_num(dec_ones);
  end

  // Multiplexado de los 8 dígitos (ánodos activos en bajo)
  always @* begin
    an  = 8'b1111_1111;     // todos apagados
    seg = SEG_BLANK;
    dp  = 1'b1;             // punto decimal apagado

    case (scan)
      3'd7: begin an = 8'b0111_1111; seg = dig7; end // AN7
      3'd6: begin an = 8'b1011_1111; seg = dig6; end // AN6
      3'd5: begin an = 8'b1101_1111; seg = dig5; end // AN5
      3'd4: begin an = 8'b1110_1111; seg = dig4; end // AN4
      3'd3: begin an = 8'b1111_0111; seg = dig3; end // AN3
      3'd2: begin an = 8'b1111_1011; seg = dig2; end // AN2  (signo '-')
      3'd1: begin an = 8'b1111_1101; seg = dig1; end // AN1  (decenas)
      3'd0: begin an = 8'b1111_1110; seg = dig0; end // AN0  (unidades)
      default: begin an = 8'b1111_1111; seg = SEG_BLANK; end
    endcase
  end

endmodule

