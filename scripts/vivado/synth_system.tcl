
read_verilog system.v
read_verilog ../../picorv32.v
read_verilog axi4_memory.v
#add Chipwhisperer Files
read_verilog cw305_axi.v
read_verilog cw305_registers.v
read_verilog cw305_usb_module.v
read_xdc synth_system.xdc

synth_design -part xc7a100tftg256-2 -top system
opt_design
place_design
route_design

report_utilization
report_timing

write_verilog -force synth_system.v
write_bitstream -force synth_system.bit
# write_mem_info -force synth_system.mmi

