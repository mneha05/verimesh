TEST ?= switch_base_test
QUESTA ?= vsim
VCS ?= vcs
XRUN ?= xrun
RTL=rtl/packet_switch.sv rtl/packet_switch_sva.sv
UVM=uvm/tb_top.sv
questa:
	vlib work && vlog -sv +incdir+uvm $(RTL) $(UVM) && $(QUESTA) -c tb_top +UVM_TESTNAME=$(TEST) -do "run -all; quit"
vcs:
	$(VCS) -sverilog -ntb_opts uvm-1.2 +incdir+uvm $(RTL) $(UVM) -o simv && ./simv +UVM_TESTNAME=$(TEST)
xrun:
	$(XRUN) -uvm -sv +incdir+uvm $(RTL) $(UVM) +UVM_TESTNAME=$(TEST)
lint:
	verilator --lint-only -Wall -Wno-fatal rtl/packet_switch.sv
