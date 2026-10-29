#1. Clock Definition (100MHz)
create_clock -name clk -period 10.0 -waveform {0 5.0} [get_ports "clk"]
set_clock_transition -rise 0.1 [get_clocks "clk"]
set_clock_transition -fall 0.1 [get_clocks "clk"]
set_clock_uncertainty 0.01 [get_ports "clk"]

#2. Synchronous Data IO Constraints
set_input_delay -max 1.0 -clock clk [get_ports -exclude "clk rst_n"]
set_input_delay -min 0.2 -clock clk [get_ports -exclude "clk rst_n"]

set_output_delay -max 1.0 -clock clk [get_ports "read_data1* read_data2*"]
set_output_delay -min 0.1 -clock clk [get_ports "read_data1* read_data2*"]

#3. Asynchronous Reset False Path
set_false_path -from [get_ports rst_n]
