program automatic test;
    import uvm_pkg::*;
    import test_pkg::*;

    initial begin
        $fsdbDumpfile("tb.fsdb");
        $fsdbDumpvars("+all");
        $timeformat(-9, 1, "ns", 10);
        uvm_resource_db#(virtual cache_if)::set("vif","",tb.vif);
        run_test("test_base");
    end

endprogram

