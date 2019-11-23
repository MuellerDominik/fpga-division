onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /div/clk
add wave -noupdate /div/rst_n
add wave -noupdate /div/start
add wave -noupdate -radix unsigned /div/num
add wave -noupdate -radix unsigned /div/den
add wave -noupdate -radix unsigned /div/quo
add wave -noupdate -radix unsigned /div/rmn
add wave -noupdate /div/done
add wave -noupdate -radix unsigned -expand /div/div_comb
add wave -noupdate -radix unsigned -expand /div/div_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 169
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {927 ns}
