create_clock -period 100MHz -name clk [get_ports {clk}]
#derive_pll_clocks -create_base_clock
derive_clock_uncertainty

set_false_path -from [get_keepers *por*] -to [get_keepers *por*]
set_false_path -from [get_keepers *reset*]

#if {$::quartus(nameofexecutable) == "quartus_fit"} {
#set_max_delay -from *symbolsPerTransfer* -to *i1_outstandingTransactions* -10.000
#set_min_delay -from *symbolsPerTransfer* -to *i1_outstandingTransactions* -10.000

##set_max_delay -to [get_clocks clk] 20
#}
