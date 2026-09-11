if {[file isdirectory work]} {vdel -all -lib work}
vlib work
vmap work work

set TOP_ENTITY {work.tb_ALU}

vlog -work work HA.sv
vlog -work work FA.sv
vlog -work work SUMSUB.sv
vlog -work work LOGIC.sv
vlog -work work MUL.sv
vlog -work work aluPKG.sv
vlog -work work ALU.sv
vlog -work work tbALU.sv

vsim -voptargs=+acc -t ns ${TOP_ENTITY}

set StdArithNoWarnings 1
set StdVitalGlitchNoWarnings 1 

run -all
