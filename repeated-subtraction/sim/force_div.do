# Reset and Clock (50 MHz)
force rst_n 0 0 ns, 1 50 ns
force clk 0 0 ns, 1 10 ns -repeat 20 ns

force start 0 0 ns, 1 60 ns, 0 80 ns, 1 220 ns, 0 240 ns, 1 280 ns, 0 300 ns
force num 10#16 0 ns, 10#3 160 ns, 10#255 240 ns
force den 10#4 0 ns, 10#2 160 ns, 10#1 240 ns

# Run for 
run 6 us
