read_verilog ../../picorv32.v
read_xdc synth_area.xdc

synth_design -part xc7a100tftg256-2 -top picorv32_axi
opt_design -resynth_seq_area

report_utilization
report_timing
