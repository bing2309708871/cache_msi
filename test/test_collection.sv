class test_base extends uvm_test;
    `uvm_component_utils(test_base)
    
    rtl_env env;
    virtual cache_if vif;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
    endfunction: new
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
        env = rtl_env::type_id::create("env",this);
        uvm_resource_db#(virtual cache_if)::read_by_type("vif",vif,this);
        uvm_config_db#(virtual cache_if)::set(this,"env","vif",vif);
        set_type_override_by_type(scoreboard::get_type(), ms_scoreboard::get_type());
    endfunction: build_phase
    
    virtual task shutdown_phase(uvm_phase phase);
        super.shutdown_phase(phase);
        `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
        phase.raise_objection(this);
        env.sb.wait_for_done();
        phase.drop_objection(this);
    endtask: shutdown_phase
    
    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
        `uvm_info("SB_REPORT", {"\n", env.sb.convert2string()}, UVM_MEDIUM);
    endfunction: report_phase
    
    virtual function void final_phase(uvm_phase phase);
        super.final_phase(phase);
        if (uvm_report_enabled(UVM_HIGH, UVM_INFO, "TOPOLOGY")) begin
          uvm_root::get().print_topology();
        end
        if (uvm_report_enabled(UVM_HIGH, UVM_INFO, "FACTORY")) begin
          uvm_factory::get().print();
        end
    endfunction: final_phase    
    
endclass: test_base


