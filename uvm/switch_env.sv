class switch_env extends uvm_env;
  `uvm_component_utils(switch_env)

  uvm_sequencer #(switch_item) seqr;
  switch_driver drv;
  switch_input_monitor in_mon;
  switch_output_monitor out_mon;
  switch_scoreboard sb;
  switch_coverage cov;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seqr    = uvm_sequencer#(switch_item)::type_id::create("seqr", this);
    drv     = switch_driver::type_id::create("drv", this);
    in_mon  = switch_input_monitor::type_id::create("in_mon", this);
    out_mon = switch_output_monitor::type_id::create("out_mon", this);
    sb      = switch_scoreboard::type_id::create("sb", this);
    cov     = switch_coverage::type_id::create("cov", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
    in_mon.ap.connect(sb.input_imp);
    out_mon.ap.connect(sb.output_imp);
    in_mon.ap.connect(cov.analysis_export);
  endfunction
endclass
