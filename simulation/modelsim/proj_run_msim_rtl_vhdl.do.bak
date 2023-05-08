transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {C:/Users/91937/OneDrive/Desktop/IITB/309_project/IITB-RISC-23/pipeline_controller.vhd}
vcom -93 -work work {C:/Users/91937/OneDrive/Desktop/IITB/309_project/IITB-RISC-23/up.vhd}
vcom -93 -work work {C:/Users/91937/OneDrive/Desktop/IITB/309_project/IITB-RISC-23/Sign_Ext_9.vhd}
vcom -93 -work work {C:/Users/91937/OneDrive/Desktop/IITB/309_project/IITB-RISC-23/Sign_Ext_6.vhd}
vcom -93 -work work {C:/Users/91937/OneDrive/Desktop/IITB/309_project/IITB-RISC-23/shifter_multiplybytwo.vhd}
vcom -93 -work work {C:/Users/91937/OneDrive/Desktop/IITB/309_project/IITB-RISC-23/RR_EX.vhd}
vcom -93 -work work {C:/Users/91937/OneDrive/Desktop/IITB/309_project/IITB-RISC-23/Register_File.vhd}
vcom -93 -work work {C:/Users/91937/OneDrive/Desktop/IITB/309_project/IITB-RISC-23/Register_1.vhd}
vcom -93 -work work {C:/Users/91937/OneDrive/Desktop/IITB/309_project/IITB-RISC-23/mux81.vhd}
vcom -93 -work work {C:/Users/91937/OneDrive/Desktop/IITB/309_project/IITB-RISC-23/MUX_6_to_1.vhd}
vcom -93 -work work {C:/Users/91937/OneDrive/Desktop/IITB/309_project/IITB-RISC-23/MUX_4_to_1_16bit.vhd}
vcom -93 -work work {C:/Users/91937/OneDrive/Desktop/IITB/309_project/IITB-RISC-23/MUX_3_to_1_3bit.vhd}
vcom -93 -work work {C:/Users/91937/OneDrive/Desktop/IITB/309_project/IITB-RISC-23/MUX_2_to_1_16bit.vhd}
vcom -93 -work work {C:/Users/91937/OneDrive/Desktop/IITB/309_project/IITB-RISC-23/MUX_2_to_1_3bit.vhd}
vcom -93 -work work {C:/Users/91937/OneDrive/Desktop/IITB/309_project/IITB-RISC-23/MEM_WB.vhd}
vcom -93 -work work {C:/Users/91937/OneDrive/Desktop/IITB/309_project/IITB-RISC-23/LMSM.vhd}
vcom -93 -work work {C:/Users/91937/OneDrive/Desktop/IITB/309_project/IITB-RISC-23/Instr_Mem.vhd}
vcom -93 -work work {C:/Users/91937/OneDrive/Desktop/IITB/309_project/IITB-RISC-23/IF_ID.vhd}
vcom -93 -work work {C:/Users/91937/OneDrive/Desktop/IITB/309_project/IITB-RISC-23/ID_RR.vhd}
vcom -93 -work work {C:/Users/91937/OneDrive/Desktop/IITB/309_project/IITB-RISC-23/EX_MEM.vhd}
vcom -93 -work work {C:/Users/91937/OneDrive/Desktop/IITB/309_project/IITB-RISC-23/DUT.vhd}
vcom -93 -work work {C:/Users/91937/OneDrive/Desktop/IITB/309_project/IITB-RISC-23/Datapath.vhd}
vcom -93 -work work {C:/Users/91937/OneDrive/Desktop/IITB/309_project/IITB-RISC-23/Data_Mem.vhd}
vcom -93 -work work {C:/Users/91937/OneDrive/Desktop/IITB/309_project/IITB-RISC-23/ALU23.vhd}
vcom -93 -work work {C:/Users/91937/OneDrive/Desktop/IITB/309_project/IITB-RISC-23/ALU.vhd}

vcom -93 -work work {C:/Users/91937/OneDrive/Desktop/IITB/309_project/IITB-RISC-23/Testbench.vhd}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L fiftyfivenm -L rtl_work -L work -voptargs="+acc"  Testbench

add wave *
view structure
view signals
run -all
