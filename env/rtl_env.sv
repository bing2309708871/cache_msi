class rtl_env extends uvm_env;
    `uvm_component_utils(rtl_env)

    input_agent     i_agt;
    output_agent    o_agt;
    scoreboard      sb;
    Coverage        cov;
    virtual cache_if vif;
        
    function new(string name, uvm_component parent);
        super.new(name, parent);
        `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
    endfunction: new
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
        i_agt = input_agent::type_id::create("i_agt", this);
        o_agt = output_agent::type_id::create("o_agt", this);
        uvm_config_db #(uvm_object_wrapper)::set(this, "i_agt.sqr.main_phase", "default_sequence", packet_sequence::get_type());
        uvm_config_db #(uvm_object_wrapper)::set(this, "o_agt.sqr.main_phase", "default_sequence", packet_sequence::get_type());
        
        sb = scoreboard::type_id::create("sb", this);
        cov = Coverage::type_id::create("cov",this);
        
        uvm_config_db#(virtual cache_if)::get(this, "", "vif", vif);
        uvm_config_db#(virtual cache_if)::set(this, "*", "vif", vif); 
    endfunction: build_phase
    
    virtual function void connect_phase(uvm_phase phase);
        `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
        i_agt.analysis_port.connect(sb.before_export);
        o_agt.analysis_port.connect(sb.after_export);
    endfunction: connect_phase
  
endclass: rtl_env
