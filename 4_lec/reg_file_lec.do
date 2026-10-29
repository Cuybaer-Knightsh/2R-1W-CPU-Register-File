set log file reg_file_lec.log -replace

// 1. Read Standard Cell Library FIRST
read library slowlib_verilog_generated.v -verilog -both

// 2. Read Golden RTL
read design ../1_design/reg_file_2r1w.v -verilog -golden

// 3. Read Revised Gate-Level Netlist
read design ../3_synthesis/reg_file_2r1w_netlist_dft.v -verilog -revised

// 4. Set Scan Pin Constraints to Force Functional Mode
add ignored inputs scan_in -revised
add ignored outputs scan_out -revised
add pin constraints 0 SE -revised

// 5. Change System Mode to LEC
set system mode lec

// 6. Map and Compare Points
add compare point -all
compare
report verification -verbose
