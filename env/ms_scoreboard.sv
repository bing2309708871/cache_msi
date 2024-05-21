class ms_scoreboard extends scoreboard;
    `uvm_component_utils(ms_scoreboard)
    `uvm_analysis_imp_decl(_before)
    `uvm_analysis_imp_decl(_after)
    
    uvm_analysis_imp_before #(packet, ms_scoreboard) ms_before_export;
    uvm_analysis_imp_after  #(packet, ms_scoreboard) ms_after_export;
    packet_cmp ms_comparator;
    int count = 0;
    realtime timeout = 10us;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
    endfunction: new
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
        ms_before_export = new("ms_before_export", this);
        ms_after_export  = new("ms_after_export", this);
        ms_comparator = uvm_in_order_class_comparator #(packet)::type_id::create("ms_comparator", this);
    endfunction: build_phase
    
    virtual function void connect_phase(uvm_phase phase);
        `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
        before_export.connect(ms_before_export);
        after_export.connect(ms_after_export);
    endfunction: connect_phase
    
    virtual function void write_before(packet pkt);
        `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
        ms_comparator.before_export.write(pkt);
        count++;
    endfunction: write_before
    
    virtual function void write_after(packet pkt);
        `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
        ms_comparator.after_export.write(pkt);
        count--;
    endfunction: write_after
    
    virtual task wait_for_done();
        `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
        fork 
        begin
            fork
                wait(count == 0);
                begin
                    #timeout;
                    `uvm_warning("TIMEOUT", $sformatf("Scoreboard has %0d unprocessed expected objects", count));
                end
            join_any
            disable fork;
        end
        join
    endtask: wait_for_done
    
    virtual function void set_timeout(realtime timeout);
        `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
        this.timeout=timeout;
    endfunction: set_timeout
    
    virtual function realtime get_timeout();
        `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
        return (timeout);
    endfunction: get_timeout
    
    virtual function string convert2string();
        convert2string = {convert2string, $sformatf("ms_comparator Matches = %0d, Mismatches = %0d\n",  ms_comparator.m_matches, ms_comparator.m_mismatches)} ;
    endfunction: convert2string

endclass: ms_scoreboard
