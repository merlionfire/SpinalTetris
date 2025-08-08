
# PlanAhead Launch Script for Post-Synthesis pin planning, created by Project Navigator

hdi::project new -name PS2_run -dir "/home/cct/FPGA_Project/PS2_run/ISE/PS2_run/planAhead_run_1" -netlist "/home/cct/FPGA_Project/PS2_run/ISE/PS2_run/pcb.ngc" -search_path { {/home/cct/FPGA_Project/PS2_run/ISE/PS2_run} {../../../Uart_run/ISE/uart_fifo} }
hdi::project setArch -name PS2_run -arch spartan3a
hdi::param set -name project.pinAheadLayout -bvalue yes
hdi::param set -name project.paUcfFile -svalue "/home/cct/FPGA_Project/PS2_run/ISE/ps2_run.ucf"
hdi::floorplan new -name floorplan_1 -part xc3s700anfgg484-5 -project PS2_run
hdi::pconst import -project PS2_run -floorplan floorplan_1 -file "/home/cct/FPGA_Project/PS2_run/ISE/ps2_run.ucf"
