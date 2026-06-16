#set liberty_file to the environment variable LIBERTY
set liberty_file $::env(LIBERTY)
#set netlist_file to the environment variable NETLIST
set netlist_file $::env(NETLIST)
#set top_module to the environment variable TOP
set top_module $::env(TOP)

#read the standard-cell library provided
read_liberty $liberty_file
#read the synthesized gate-level netlist provided
read_verilog $netlist_file
#Use top_module as the top-level design and link the netlist to the standard-cells from standard-cell library
link_design $top_module

#Virtual clock (10 ns) for combinational timing measurement
#The adder itself is not clocked 
create_clock -name vclk -period 10

#All input signals arrive at time 0 relative to vclk
set_input_delay 0 -clock vclk [all_inputs]
#All output signals are required with 0 ns external output delay
set_output_delay 0 -clock vclk [all_outputs]

puts "=============================================="
puts "Timing report for $top_module"
puts "=============================================="

puts "Max delay / worst-case path"
puts "MAX_DELAY_REPORT_BEGIN"
#report maximum delay paths
#start paths from all input ports
#end paths at all output ports
#together: find the worst combinational delay from any input to any output
#filed controls what extra information appeaars in the report
#show slew(signal transition speed)
#show cap(load capacitance)
#show input_pins(input pins of cells)
#show nets(wires/nets between gates)
#show fanout (how many loads a net drives)
#4 digit precision
report_checks \
  -path_delay max \
  -from [all_inputs] \
  -to [all_outputs] \
  -fields {slew cap input_pins fanout} \
  -digits 4
puts "MAX_DELAY_REPORT_END"


puts "Min delay / shortest structural path"
puts "MIN_DELAY_REPORT_BEGIN"

report_checks \
  -path_delay min \
  -from [all_inputs] \
  -to [all_outputs] \
  -fields {slew cap input_pins fanout} \
  -digits 4
puts "MIN_DELAY_REPORT_END"


puts "=============================================="
puts "Summary"
puts "=============================================="

#report worst negative slack
report_wns
#report total negative slack 
report_tns
