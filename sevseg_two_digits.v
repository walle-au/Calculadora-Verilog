
module sevseg_two_digits(
    input  wire       clk,     // 100 MHz
    input  wire       reset,   // síncrono
    input  wire [3:0] ones,
    input  wire [3:0] tens,
    output reg  [6:0] seg,     // {a,b,c,d,e,f,g} activos en bajo
    output reg        dp,      // punto decimal activo en bajo
    output reg  [7:0] an       // ánodos activos en bajo
);
    // ===== divisor simple: usa el bit 16 (~1.5 kHz con 100 MHz)
    reg [16:0] divcnt;
    always @(posedge clk) begin
        if (reset) divcnt <= 0;
        else       divcnt <= divcnt + 1'b1;
    end

    wire sel = divcnt[16]; // 0: unidades (AN0), 1: decenas (AN1)

    // ===== decodificador 4-bit -> 7 segmentos (común ánodo: activo en bajo)
    function [6:0] seven_of;
        input [3:0] n;
        case (n)
            4'd0: seven_of = 7'b1000000; // 0
            4'd1: seven_of = 7'b1111001; // 1
            4'd2: seven_of = 7'b0100100; // 2
            4'd3: seven_of = 7'b0110000; // 3
            4'd4: seven_of = 7'b0011001; // 4
            4'd5: seven_of = 7'b0010010; // 5
            4'd6: seven_of = 7'b0000010; // 6
            4'd7: seven_of = 7'b1111000; // 7
            4'd8: seven_of = 7'b0000000; // 8
            4'd9: seven_of = 7'b0010000; // 9
            default: seven_of = 7'b1111111; // blanco (apagado)
        endcase
    endfunction

    always @(posedge clk) begin
        if (reset) begin
            an  <= 8'b1111_1111;
            seg <= 7'b1111111;
            dp  <= 1'b1;
        end else begin
            dp <= 1'b1; // sin punto decimal
            if (sel == 1'b0) begin
                // Unidades en AN0
                an  <= 8'b1111_1110;     // solo AN0 activo (bajo)
                seg <= seven_of(ones);
            end else begin
                // Decenas en AN1
                an  <= 8'b1111_1101;     // solo AN1 activo
                seg <= seven_of(tens);
            end
        end
    end
endmodule
