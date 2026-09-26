TEST ?= switch_base_test
QUESTA ?= vsim
VCS ?= vcs
XRUN ?= xrun
VERILATOR ?= verilator
UVM_HOME ?= /tmp/uvm-verilator/src

RTL=rtl/packet_switch.sv rtl/packet_switch_sva.sv
UVM_SRC=uvm/switch_if.sv uvm/switch_pkg.sv uvm/tb_top.sv

questa:
	vlib work && vlog -sv +incdir+uvm $(RTL) $(UVM_SRC) && $(QUESTA) -c tb_top +UVM_TESTNAME=$(TEST) -do "run -all; quit"

vcs:
	$(VCS) -sverilog -ntb_opts uvm-1.2 +incdir+uvm $(RTL) $(UVM_SRC) -o simv && ./simv +UVM_TESTNAME=$(TEST)

xrun:
	$(XRUN) -uvm -sv +incdir+uvm $(RTL) $(UVM_SRC) +UVM_TESTNAME=$(TEST)

verilator-uvm:
	$(VERILATOR) -Wno-fatal --binary --timing -j 2 \
		--top-module tb_top \
		+incdir+$(UVM_HOME) +define+UVM_NO_DPI +incdir+uvm \
		$(UVM_HOME)/uvm_pkg.sv $(RTL) $(UVM_SRC) \
		-o simv
	./obj_dir/simv +UVM_TESTNAME=$(TEST) +UVM_VERBOSITY=UVM_LOW

lint:
	verilator --lint-only -Wall -Wno-fatal rtl/packet_switch.sv
