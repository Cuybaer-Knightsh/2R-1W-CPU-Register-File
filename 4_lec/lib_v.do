set log file lib_v.log -replace
read library ../3_synthesis/lib/slow.lib -liberty
write library slowlib_verilog_generated.v -verilog -replace
exit
