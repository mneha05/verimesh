class switch_driver extends uvm_driver #(switch_item);
  `uvm_component_utils(switch_driver)

  virtual switch_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual switch_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", "switch_if missing from config DB")
    end
  endfunction

  task run_phase(uvm_phase phase);
    reset_drive_state();

    forever begin
      seq_item_port.get_next_item(req);
      drive(req);
      seq_item_port.item_done();
    end
  endtask

  task reset_drive_state();
    vif.in_valid <= '0;
    vif.in_data  <= '0;
    vif.in_dst   <= '0;
    vif.out_ready <= '1;
    wait (vif.rst_n === 1'b1);
    @(posedge vif.clk);
  endtask

  task drive(switch_item item);
    // Inject downstream pressure before presenting the packet. The input must
    // remain valid and stable until the selected output becomes ready.
    if (item.stall_cycles > 0) begin
      vif.out_ready[item.dst] <= 1'b0;
    end

    @(posedge vif.clk);
    vif.in_data[item.src]  <= item.data;
    vif.in_dst[item.src]   <= item.dst;
    vif.in_valid[item.src] <= 1'b1;

    repeat (item.stall_cycles) begin
      @(posedge vif.clk);
    end
    vif.out_ready[item.dst] <= 1'b1;

    do begin
      @(posedge vif.clk);
    end while (!vif.in_ready[item.src]);

    // Hold through the handshake edge, then release the source one cycle later.
    @(posedge vif.clk);
    vif.in_valid[item.src] <= 1'b0;
    vif.out_ready[item.dst] <= 1'b1;

    `uvm_info(
      "DRV",
      $sformatf("src=%0d dst=%0d data=%08x stall=%0d",
                item.src, item.dst, item.data, item.stall_cycles),
      UVM_HIGH
    )
  endtask
endclass
