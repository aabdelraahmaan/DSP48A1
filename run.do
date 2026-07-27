vlib work
vmap work work
vlog DSP48A1.v
vlog DSP48A1_tb.v
vsim -voptargs=+acc work.DSP48A1_tb
add wave -radix decimal /DSP48A1_tb/A
add wave -radix decimal /DSP48A1_tb/B
add wave -radix decimal /DSP48A1_tb/D
add wave -radix decimal /DSP48A1_tb/C
add wave -radix binary /DSP48A1_tb/OPMODE
add wave -radix decimal /DSP48A1_tb/PCIN
add wave -radix decimal /DSP48A1_tb/M
add wave -radix decimal /DSP48A1_tb/P
add wave /DSP48A1_tb/CARRYOUT
add wave /DSP48A1_tb/CARRYOUTF
run -all