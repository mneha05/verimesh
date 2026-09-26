class switch_input_monitor extends uvm_monitor;
  `uvm_component_utils(switch_input_monitor)

  virtual switch_if vif;
  uvm_analysis_port #(switch_item) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual switch_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", "input monitor missing switch_if")
    end
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      @(posedge vif.clk);
      if (!vif.rst_n) continue;

      for (int src = 0; src < 4; src++) begin
        if (vif.in_valid[src] && vif.in_ready[src]) begin
          switch_item tr = switch_item::type_id::create($sformatf("accepted_%0d", src));
          tr.src = src;
          tr.dst = vif.in_dst[src];
          tr.data = vif.in_data[src];
          tr.stall_cycles = 0;
          ap.write(tr);
          `uvm_info("IN_MON", tr.sprint(), UVM_HIGH)
        end
      end
    end
  endtask
endclass


class switch_output_monitor extends uvm_monitor;
  `uvm_component_utils(switch_output_monitor)

  virtual switch_if vif;
  uvm_analysis_port #(switch_item) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual switch_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", "output monitor missing switch_if")
    end
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      @(posedge vif.clk);
      if (!vif.rst_n) continue;

      for (int dst = 0; dst < 4; dst++) begin
        if (vif.out_valid[dst] && vif.out_ready[dst]) begin
          switch_item tr = switch_item::type_id::create($sformatf("observed_%0d", dst));
          tr.src = 0;
          tr.dst = dst;
          tr.data = vif.out_data[dst];
          tr.stall_cycles = 0;
          ap.write(tr);
          `uvm_info("OUT_MON", tr.sprint(), UVM_HIGH)
        end
      end
    end
  endtask
endclass
