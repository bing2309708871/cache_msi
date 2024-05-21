import cache_pkg::*;
class packet_sequence extends uvm_sequence #(packet);
    `uvm_object_utils(packet_sequence)
    
    function new(string name = "packet_sequence");
        super.new(name);
        `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
        `ifndef UVM_VERSION_1_1
            set_automatic_phase_objection(1);
        `endif
    endfunction: new
    
    `ifndef UVM_VERSION_1_1
    virtual task pre_start();
      if ((get_parent_sequence() == null) && (starting_phase != null)) begin
        starting_phase.raise_objection(this);
      end
    endtask: pre_start
    
    virtual task post_start();
      if ((get_parent_sequence() == null) && (starting_phase != null)) begin
        starting_phase.drop_objection(this);
      end
    endtask: post_start
    `endif

    virtual task body();
        `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
        repeat(30) begin
        `uvm_do_with(req,{req_i[0]==Read;});
        end
    endtask: body

endclass: packet_sequence
