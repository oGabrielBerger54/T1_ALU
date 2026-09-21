# compilacao, simulacao e cobertura de codigo
# uso: vsim -c -do sim.do        (ou +VERB=2 para ver cada vetor)

if {[file isdirectory work]} {vdel -all -lib work}
vlib work
vmap work work

set TOP_ENTITY {work.tb_ALU}

# RTL com instrumentacao de cobertura (b=branch c=condition e=expression s=statement f=fsm)
vlog -work work +cover=bcesf HA.sv
vlog -work work +cover=bcesf FA.sv
vlog -work work +cover=bcesf SUMSUB.sv
vlog -work work +cover=bcesf LOGIC.sv
vlog -work work +cover=bcesf MUL.sv
vlog -work work aluPKG.sv
vlog -work work +cover=bcesf ALU.sv

# testbench sem cobertura, ele nao faz parte do projeto
vlog -work work tbALU.sv

vsim -voptargs=+acc -coverage -t ns ${TOP_ENTITY}

set StdArithNoWarnings 1
set StdVitalGlitchNoWarnings 1

run -all

coverage save cobertura.ucdb
coverage report -summary
coverage report -detail -file cobertura.txt
