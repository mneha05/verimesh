`uvm_analysis_imp_decl(_input)
`uvm_analysis_imp_decl(_output)

class switch_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(switch_scoreboard)

  uvm_analysis_imp_input  #(switch_item, switch_scoreboard) input_imp;
  uvm_analysis_imp_output #(switch_item, switch_scoreboard) output_imp;

  switch_item expected[4][$];
  int unsigned accepted[4];
  int unsigned observed[4];
  int unsigned mismatches;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    input_imp = new("input_imp", this);
    output_imp = new("output_imp", this);
  endfunction

  function void write_input(switch_item tr);
    switch_item clone;
    $cast(clone, tr.clone());
    expected[tr.dst].push_back(clone);
    accepted[tr.dst]++;
    `uvm_info(
      "SCORE_IN",
      $sformatf("queued dst=%0d data=%08x depth=%0d",
                tr.dst, tr.data, expected[tr.dst].size()),
      UVM_HIGH
    )
  endfunction

  function void write_output(switch_item tr);
    switch_item exp;

    observed[tr.dst]++;

    if (expected[tr.dst].size() == 0) begin
      mismatches++;
      `uvm_error(
        "UNEXPECTED",
        $sformatf("dst=%0d produced data=%08x with empty expected queue",
                  tr.dst, tr.data)
      )
      return;
    end

    exp = expected[tr.dst].pop_front();
    if (tr.data !== exp.data) begin
      mismatches++;
      `uvm_error(
        "MISMATCH",
        $sformatf("dst=%0d expected=%08x observed=%08x src=%0d",
                  tr.dst, exp.data, tr.data, exp.src)
      )
    end else begin
      `uvm_info(
        "MATCH",
        $sformatf("dst=%0d data=%08x remaining=%0d",
                  tr.dst, tr.data, expected[tr.dst].size()),
        UVM_HIGH
      )
    end
  endfunction

  function void check_phase(uvm_phase phase);
    super.check_phase(phase);

    for (int dst = 0; dst < 4; dst++) begin
      if (expected[dst].size() != 0) begin
        mismatches += expected[dst].size();
        `uvm_error(
          "DROPPED",
          $sformatf("dst=%0d has %0d accepted packets with no matching output",
                    dst, expected[dst].size())
        )
      end
    end

    if (mismatches == 0) begin
      `uvm_info("SCOREBOARD", "all accepted packets matched output payloads", UVM_LOW)
    end
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    for (int dst = 0; dst < 4; dst++) begin
      `uvm_info(
        "SUMMARY",
        $sformatf("port=%0d accepted=%0d observed=%0d",
                  dst, accepted[dst], observed[dst]),
        UVM_LOW
      )
    end
    `uvm_info("SUMMARY", $sformatf("mismatches=%0d", mismatches), UVM_LOW)
  endfunction
endclass
