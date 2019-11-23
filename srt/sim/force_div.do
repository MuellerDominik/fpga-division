# Reset and Clock (50 MHz)
force rst_n 0 0 ns, 1 50 ns
force clk 0 0 ns, 1 10 ns -repeat 20 ns

force start 0 0 ns, 1 60 ns, 0 80 ns, 1 300 ns, 0 320 ns
force num 10#8 0 ns, 10#255 300 ns
force den 10#3 0 ns, 10#2 300 ns

# Run
run 600 ns
