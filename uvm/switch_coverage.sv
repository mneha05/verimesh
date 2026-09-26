class switch_coverage extends uvm_subscriber #(switch_item);
  `uvm_component_utils(switch_coverage)

  switch_item tr;

  covergroup route_cg;
    option.per_instance = 1;

    src_cp: coverpoint tr.src {
      bins ports[] = {[0:3]};
    }

    dst_cp: coverpoint tr.dst {
      bins ports[] = {[0:3]};
    }

    payload_class_cp: coverpoint tr.data[3:0] {
      bins low[] = {[0:15]};
    }

    route_cross: cross src_cp, dst_cp;
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    route_cg = new();
  endfunction

  function void write(switch_item t);
    tr = t;
    route_cg.sample();
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(
      "COVERAGE",
      $sformatf("route coverage = %0.2f%%", route_cg.get_inst_coverage()),
      UVM_LOW
    )
  endfunction
endclass
