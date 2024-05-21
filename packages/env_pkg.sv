package env_pkg;

    import uvm_pkg::*;
    import stimulus_pkg::*;
    
    `include "env/env_config.sv" 
 
    `include "master/iDriver.sv"
    `include "master/iMonitor.sv"
    `include "master/input_agent.sv"
    
    `include "slave/oDriver.sv"
    `include "slave/oMonitor.sv"
    `include "slave/output_agent.sv"
    
    `include "env/Coverage.sv"
    `include "env/scoreboard.sv"
    `include "env/ms_scoreboard.sv"
    
    `include "env/rtl_env.sv"

endpackage
