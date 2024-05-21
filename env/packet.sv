// All transaction classes must be extended from the uvm_sequence_item base class.
import cache_pkg::*;
class packet extends uvm_sequence_item;

    rand bit [L1_NUM-1:0][3:0] req_i;
    rand bit [L1_NUM-1:0]   req_i_valid;
    
    `uvm_object_utils_begin(packet)
        `uvm_field_int(req_i, UVM_ALL_ON);
        `uvm_field_int(req_i_valid, UVM_ALL_ON);
    `uvm_object_utils_end

   // constraint valid{
   //     req_i[0] inside {transaction_type},
   //     req_i[1] inside (transaction_type},
   // };
    
    function new(string name = "packet");
      super.new(name);
      `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
    endfunction: new

endclass: packet
