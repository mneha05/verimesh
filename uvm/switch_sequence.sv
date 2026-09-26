class switch_random_sequence extends uvm_sequence #(switch_item);
  `uvm_object_utils(switch_random_sequence)

  rand int unsigned count = 256;

  function new(string name = "switch_random_sequence");
    super.new(name);
  endfunction

  task body();
    repeat (count) begin
      req = switch_item::type_id::create("req");
      start_item(req);
      if (!req.randomize()) begin
        `uvm_fatal("RAND", "switch_item randomization failed")
      end
      finish_item(req);
    end
  endtask
endclass

class switch_hotspot_sequence extends uvm_sequence #(switch_item);
  `uvm_object_utils(switch_hotspot_sequence)

  rand int unsigned count = 192;
  rand bit [1:0] hotspot = 2;

  function new(string name = "switch_hotspot_sequence");
    super.new(name);
  endfunction

  task body();
    repeat (count) begin
      req = switch_item::type_id::create("hotspot_req");
      start_item(req);
      if (!req.randomize() with {
            dst == local::hotspot;
            stall_cycles dist {0 := 4, [1:2] := 3, [3:5] := 1};
          }) begin
        `uvm_fatal("RAND", "hotspot item randomization failed")
      end
      finish_item(req);
    end
  endtask
endclass
