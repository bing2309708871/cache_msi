//Environment Config Class
class env_config extends uvm_object;

	`uvm_object_utils (env_config)
	
    int master_is_active = 1;
    int slave_is_active = 0;

	function new(string name = "env_config");
    	super.new(name);
	endfunction
	
endclass
