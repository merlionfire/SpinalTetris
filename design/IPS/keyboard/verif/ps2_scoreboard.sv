//==============================================================================
// PS/2 Scoreboard Module
// Purpose: Track test results, compare expected vs actual, coverage tracking
// Pure module-based design - no classes
//==============================================================================

module ps2_scoreboard;
  
  // Statistics
  int total_checks = 0;
  int pass_checks = 0;
  int fail_checks = 0;
  
  // Coverage bins
  int key_press_count[6];     // Count presses per key (0-5)
  int key_release_count[6];   // Count releases per key (0-5)
  int break_code_count = 0;   // Count break codes received
  
  // Initialize
  initial begin
    for (int i = 0; i < 6; i++) begin
      key_press_count[i] = 0;
      key_release_count[i] = 0;
    end
  end
  
  //============================================================================
  // Record key activity
  //============================================================================
  task automatic record_key_activity(input int key_index, input logic is_release);
    begin
      if (key_index >= 0 && key_index < 6) begin
        if (is_release)
          key_release_count[key_index]++;
        else
          key_press_count[key_index]++;
      end
    end
  endtask
  
  //============================================================================
  // Record break code
  //============================================================================
  task automatic record_break_code();
    begin
      break_code_count++;
    end
  endtask
  
  //============================================================================
  // Simple pass/fail reporting
  //============================================================================
  task automatic report_pass();
    begin
      pass_checks++;
      total_checks++;
    end
  endtask
  
  task automatic report_fail();
    begin
      fail_checks++;
      total_checks++;
    end
  endtask
  
  //============================================================================
  // Check expected vs actual
  //============================================================================
  task automatic check_result(
    input logic [5:0] expected,
    input logic [5:0] actual,
    input string test_name
  );
    begin
      total_checks++;
      if (expected == actual) begin
        pass_checks++;
        $display("[%0t] PASS: %s - Expected 0b%06b, Got 0b%06b", 
                 $time, test_name, expected, actual);
      end else begin
        fail_checks++;
        $display("[%0t] FAIL: %s - Expected 0b%06b, Got 0b%06b", 
                 $time, test_name, expected, actual);
      end
    end
  endtask
  
  //============================================================================
  // Print coverage report
  //============================================================================
  task automatic print_coverage();
    begin
      $display("\n==============================================================================");
      $display("  COVERAGE REPORT");
      $display("==============================================================================");
      $display("  Key Press Coverage:");
      $display("    START  (key 0): %0d presses, %0d releases", 
               key_press_count[0], key_release_count[0]);
      $display("    DOWN   (key 1): %0d presses, %0d releases", 
               key_press_count[1], key_release_count[1]);
      $display("    LEFT   (key 2): %0d presses, %0d releases", 
               key_press_count[2], key_release_count[2]);
      $display("    RIGHT  (key 3): %0d presses, %0d releases", 
               key_press_count[3], key_release_count[3]);
      $display("    ROTATE (key 4): %0d presses, %0d releases", 
               key_press_count[4], key_release_count[4]);
      $display("    DROP   (key 5): %0d presses, %0d releases", 
               key_press_count[5], key_release_count[5]);
      $display("\n  Protocol Coverage:");
      $display("    Break codes received: %0d", break_code_count);
      $display("==============================================================================\n");
    end
  endtask
  
  //============================================================================
  // Print statistics
  //============================================================================
  task automatic print_stats();
    real pass_rate;
    begin
      if (total_checks > 0)
        pass_rate = (real'(pass_checks) / real'(total_checks)) * 100.0;
      else
        pass_rate = 0.0;
      
      $display("\n==============================================================================");
      $display("  SCOREBOARD STATISTICS");
      $display("==============================================================================");
      $display("  Total Checks: %0d", total_checks);
      $display("  Passed:       %0d", pass_checks);
      $display("  Failed:       %0d", fail_checks);
      $display("  Pass Rate:    %.2f%%", pass_rate);
      $display("==============================================================================\n");
    end
  endtask
  
  //============================================================================
  // Get statistics
  //============================================================================
  function int get_total_checks();
    return total_checks;
  endfunction
  
  function int get_pass_checks();
    return pass_checks;
  endfunction
  
  function int get_fail_checks();
    return fail_checks;
  endfunction
  
endmodule
