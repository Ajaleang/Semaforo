`timescale 1ns / 1ps

module testbench;

    reg clk;
    reg rst_n;
    reg enable;
    wire red, yellow, green;
    wire [3:0] state_out;

    semaforo_fsm uut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .red(red),
        .yellow(yellow),
        .green(green),
        .state_out(state_out)
    );

    initial begin
        // Simulación del reloj
        clk = 0;
        forever #5 clk = ~clk;

        // Inicialización
        rst_n = 0;
        enable = 0;

        // Espera un poco antes de activar el reset
        #20 rst_n = 1;

        // Simulación de eventos
        #50 enable = 1;  // Habilita el semáforo
        #200 enable = 0; // Deshabilita el semáforo
        #50 enable = 1;  // Habilita el semáforo nuevamente

        // Espera suficiente tiempo para ver el comportamiento en GTKWave
        #1000 $finish;
    end

    // Dumpfile para GTKWave
    initial begin
        $dumpfile("semaforo_fsm_wave.vcd");
        $dumpvars(0, testbench);
        #1000 $finish;
    end

endmodule
