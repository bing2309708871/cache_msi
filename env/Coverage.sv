class Coverage extends uvm_component;
    `uvm_component_utils(Coverage)
    virtual cache_if vif;

    covergroup cov_write;
        // add coverpoint
        //WINC:coverpoint vif_w.winc {option.auto_bin_max = 2;}
        //WFULL:coverpoint vif_w.wfull {option.auto_bin_max = 2;}
        //AWFULL:coverpoint vif_w.awfull {option.auto_bin_max = 2;}
    endgroup

    
    function new(string name="Coverage", uvm_component parent);
		super.new(name, parent);
        `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
        // add cov new
		this.cov_write = new();
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
        `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
        // add covorage virtual interface
        uvm_config_db#(virtual cache_if)::get(this, "", "vif", vif);
	endfunction

    virtual task run_phase(uvm_phase phase);
        `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
        fork 
            // add sample
            this.do_write_sample();
        join
    endtask

    virtual task do_write_sample();
        forever begin
            @(posedge vif.clk iff vif.rst_n);
            // add sample
            this.cov_write.sample();
        end
    endtask

    function void report_phase(uvm_phase phase);
        string s;
        super.report_phase(phase);
        s = "\n---------------------------------------------------------------\n";
        s = {s, "COVERAGE SUMMARY \n"}; 
        s = {s, $sformatf("total coverage: %.1f \n", $get_coverage())}; 
        // print coverage
        s = {s, $sformatf("write coverage: %.1f \n", this.cov_write.get_coverage())}; 
        s = {s, "---------------------------------------------------------------\n"};
        `uvm_info(get_type_name(), s, UVM_LOW)
    endfunction

endclass
