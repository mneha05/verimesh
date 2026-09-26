class switch_base_test extends uvm_test;
  `uvm_component_utils(switch_base_test)

  switch_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = switch_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    switch_random_sequence seq =
        switch_random_sequence::type_id::create("random_sequence");

    phase.raise_objection(this);
    seq.count = 256;
    seq.start(env.seqr);

    // Let the final accepted transaction propagate through the combinational
    // fabric and monitors before check_phase inspects scoreboard queues.
    repeat (10) @(posedge env.drv.vif.clk);
    phase.drop_objection(this);
  endtask
endclass


class switch_hotspot_test extends switch_base_test;
  `uvm_component_utils(switch_hotspot_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    switch_hotspot_sequence seq =
        switch_hotspot_sequence::type_id::create("hotspot_sequence");

    phase.raise_objection(this);
    seq.count = 192;
    seq.hotspot = 2;
    sequence.start(env.seqr);
    repeat (10) @(posedge env.drv.vif.clk);
    phase.drop_objection(this);
  endtask
endclass
