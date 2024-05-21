class iDriver extends uvm_driver #(packet);
    `uvm_component_utils(iDriver)
    
     virtual cache_if vif;           // DUT virtual interface
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
    endfunction: new
    
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
        uvm_config_db#(virtual cache_if)::get(this, "", "vif", vif);
    endfunction: build_phase

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
        if (vif == null) begin
        `uvm_fatal("CFGERR", "Interface for input driver agent not set");
        end
  endfunction: end_of_elaboration_phase
    
    virtual function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
    endfunction: start_of_simulation_phase
    
    virtual task run_phase(uvm_phase phase);
        `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
        reset();
        forever begin
            seq_item_port.get_next_item(req);
            `uvm_info("DRV_RUN", {"\n", req.sprint()}, UVM_MEDIUM);
            write(req);
            seq_item_port.item_done();
        end
    endtask: run_phase
    
    virtual task reset();
        `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
        vif.req_i <= '0;
        vif.req_i_valid <= '0;
        wait(vif.rst_n == 1'b1);
    endtask:reset
    
    virtual task write(packet tr);
      `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
          @ (posedge vif.clk);
          vif.req_i_valid = tr.req_i_valid;
          vif.req_i = tr.req_i;
          @ (posedge vif.clk);
          vif.req_i_valid = '0;
          // add driver
    endtask: write

endclass: iDriver
