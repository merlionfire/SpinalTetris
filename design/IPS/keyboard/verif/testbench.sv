`timescale 1ns / 1ps

//==============================================================================
// Professional Testbench for kd_ps2 Module
// Purpose: Verify PS/2 keyboard interface with key detection FSM
// Author: IC Verification Expert
// Note: Pure module-based design for VCS compatibility
//==============================================================================

module testbench ; 

  //============================================================================
  // Parameters
  //============================================================================
  parameter CLK_PERIOD = 20;  // 50MHz clock
  parameter TEST_TIMEOUT = 100000;  // 100us timeout per test
  
  //============================================================================
  // DUT Signals
  //============================================================================
  logic        clk;
  logic        reset;
  wire         ps2_clk;
  wire         ps2_data;
  logic        rd_data_valid;
  logic [7:0]  rd_data_payload;
  logic [5:0]  keys_valid;
  
  //============================================================================
  // Testbench Variables
  //============================================================================
  int test_count = 0;
  int pass_count = 0;
  int fail_count = 0;
  
  // Key code definitions (PS/2 scan codes)
  localparam logic [7:0] KEY_START  = 8'h1D;  // W key
  localparam logic [7:0] KEY_DOWN   = 8'h1B;  // S key
  localparam logic [7:0] KEY_LEFT   = 8'h1C;  // A key
  localparam logic [7:0] KEY_RIGHT  = 8'h23;  // D key
  localparam logic [7:0] KEY_ROTATE = 8'h29;  // Space key
  localparam logic [7:0] KEY_DROP   = 8'h5A;  // Enter key
  
  //============================================================================
  // DUT Instantiation
  //============================================================================
  kd_ps2 dut (
    .ps2_clk         (ps2_clk),
    .ps2_data        (ps2_data),
    .rd_data_valid   (rd_data_valid),
    .rd_data_payload (rd_data_payload),
    .keys_valid      (keys_valid),
    .reset           (reset),
    .clk             (clk)
  );
  
  //============================================================================
  // PS/2 Key Driver (Custom VIP)
  //============================================================================
  ps2_key_driver key_driver (
    .clk      (clk),
    .reset    (reset),
    .ps2_clk  (ps2_clk),
    .ps2_data (ps2_data)
  );
  
  //============================================================================
  // Scoreboard for Checking
  //============================================================================
  ps2_scoreboard scoreboard();
  
  //============================================================================
  // Pull-ups for PS/2 bus
  //============================================================================
  pullup(ps2_clk);
  pullup(ps2_data);
  
  //============================================================================
  // Clock Generation
  //============================================================================
  initial clk = 0;
  always #(CLK_PERIOD/2) clk = ~clk;
  
  //============================================================================
  // Monitor for PS/2 Interface
  //============================================================================
  always @(posedge clk) begin
    if (rd_data_valid) begin
      $display("[%0t] PS/2 Data Received: 0x%02h", $time, rd_data_payload);
    end
  end
  
  //============================================================================
  // Keys Valid Monitor
  //============================================================================
  logic [5:0] keys_valid_prev = 6'b0;
  always @(posedge clk) begin
    if (keys_valid != keys_valid_prev) begin
      $display("[%0t] Keys Valid Changed: START=%b DOWN=%b LEFT=%b RIGHT=%b ROTATE=%b DROP=%b",
               $time, keys_valid[0], keys_valid[1], keys_valid[2], 
               keys_valid[3], keys_valid[4], keys_valid[5]);
      keys_valid_prev <= keys_valid;
    end
  end
  
  //============================================================================
  // Main Test Sequence
  //============================================================================
  initial begin
    $display("==============================================================================");
    $display("  KD_PS2 Testbench - PS/2 Keyboard Interface Verification");
    $display("==============================================================================");
    
    // Initialize
    reset_sequence();
    
    // Test Suite
    test_single_key_press(KEY_START, "START", 6'b000001);
    test_single_key_press(KEY_DOWN, "DOWN", 6'b000010);
    test_single_key_press(KEY_LEFT, "LEFT", 6'b000100);
    test_single_key_press(KEY_RIGHT, "RIGHT", 6'b001000);
    test_single_key_press(KEY_ROTATE, "ROTATE", 6'b010000);
    test_single_key_press(KEY_DROP, "DROP", 6'b100000);
    
    test_all_keys_sequence();
    test_rapid_key_presses();
    test_key_hold_and_release();
    test_simultaneous_key_attempts();
    test_invalid_scan_codes();
    test_break_code_timing();
    
    // Summary
    print_test_summary();
    
    #1000;
    $finish;
  end
  

  //*******************************************************************//
  //     FSDB dumper                                                   //
  //*******************************************************************//
  initial begin
    $display("[SIM_INFO] @%t: Start to dump waveform", $time);
    $fsdbDumpfile("cosim_verdi.fsdb");
    $fsdbDumpvars(0, "testbench");
    #250ms $finish;
  end

  
  //============================================================================
  // Reset Task
  //============================================================================
  task reset_sequence();
    begin
      $display("\n[%0t] === Reset Sequence ===", $time);
      reset = 1;
      repeat(10) @(posedge clk);
      reset = 0;
      repeat(5) @(posedge clk);
      $display("[%0t] Reset Complete\n", $time);
    end
  endtask
  
  //============================================================================
  // Test: Single Key Press
  //============================================================================
  task test_single_key_press(
    input logic [7:0] scan_code,
    input string key_name,
    input logic [5:0] expected_keys
  );
    begin
      test_count++;
      
      $display("\n[%0t] ========================================", $time);
      $display("[%0t] TEST %0d: Single Key Press - %s", $time, test_count, key_name);
      $display("[%0t] ========================================", $time);
      
      // Send key press (make code)
      key_driver.send_key_make(scan_code);
      
      // Wait for FSM to process
      repeat(10) @(posedge clk);
      
      // Check keys_valid after make
      if (keys_valid == expected_keys) begin
        $display("[%0t] PASS: Key %s pressed, keys_valid = 0b%06b", 
                 $time, key_name, keys_valid);
        scoreboard.report_pass();
        pass_count++;
      end else begin
        $display("[%0t] FAIL: Key %s pressed, expected 0b%06b, got 0b%06b", 
                 $time, key_name, expected_keys, keys_valid);
        scoreboard.report_fail();
        fail_count++;
      end
      
      // Send key release (break code)
      key_driver.send_key_break(scan_code);
      
      // Wait for FSM to process
      repeat(10) @(posedge clk);
      
      // Check keys_valid after break (should be 0)
      if (keys_valid == 6'b000000) begin
        $display("[%0t] PASS: Key %s released, keys_valid = 0b%06b", 
                 $time, key_name, keys_valid);
        scoreboard.report_pass();
        pass_count++;
      end else begin
        $display("[%0t] FAIL: Key %s released, expected 0b000000, got 0b%06b", 
                 $time, key_name, keys_valid);
        scoreboard.report_fail();
        fail_count++;
      end
      
      repeat(10) @(posedge clk);
    end
  endtask
  
  //============================================================================
  // Test: All Keys in Sequence
  //============================================================================
  task test_all_keys_sequence();
    begin
      test_count++;
      
      $display("\n[%0t] ========================================", $time);
      $display("[%0t] TEST %0d: All Keys Sequential Test", $time, test_count);
      $display("[%0t] ========================================", $time);
      
      // Press and release each key
      key_driver.send_key_make(KEY_START);
      repeat(5) @(posedge clk);
      key_driver.send_key_break(KEY_START);
      repeat(10) @(posedge clk);
      
      key_driver.send_key_make(KEY_DOWN);
      repeat(5) @(posedge clk);
      key_driver.send_key_break(KEY_DOWN);
      repeat(10) @(posedge clk);
      
      key_driver.send_key_make(KEY_LEFT);
      repeat(5) @(posedge clk);
      key_driver.send_key_break(KEY_LEFT);
      repeat(10) @(posedge clk);
      
      key_driver.send_key_make(KEY_RIGHT);
      repeat(5) @(posedge clk);
      key_driver.send_key_break(KEY_RIGHT);
      repeat(10) @(posedge clk);
      
      key_driver.send_key_make(KEY_ROTATE);
      repeat(5) @(posedge clk);
      key_driver.send_key_break(KEY_ROTATE);
      repeat(10) @(posedge clk);
      
      key_driver.send_key_make(KEY_DROP);
      repeat(5) @(posedge clk);
      key_driver.send_key_break(KEY_DROP);
      repeat(10) @(posedge clk);
      
      $display("[%0t] PASS: Sequential key test completed", $time);
      pass_count++;
    end
  endtask
  
  //============================================================================
  // Test: Rapid Key Presses
  //============================================================================
  task test_rapid_key_presses();
    begin
      test_count++;
      
      $display("\n[%0t] ========================================", $time);
      $display("[%0t] TEST %0d: Rapid Key Press Test", $time, test_count);
      $display("[%0t] ========================================", $time);
      
      for (int i = 0; i < 5; i++) begin
        key_driver.send_key_make(KEY_DOWN);
        repeat(5) @(posedge clk);
        key_driver.send_key_break(KEY_DOWN);
        repeat(5) @(posedge clk);
      end
      
      $display("[%0t] PASS: Rapid key press test completed", $time);
      pass_count++;
    end
  endtask
  
  //============================================================================
  // Test: Key Hold and Release
  //============================================================================
  task test_key_hold_and_release();
    begin
      test_count++;
      
      $display("\n[%0t] ========================================", $time);
      $display("[%0t] TEST %0d: Key Hold and Release", $time, test_count);
      $display("[%0t] ========================================", $time);
      
      // Press key
      key_driver.send_key_make(KEY_LEFT);
      repeat(10) @(posedge clk);
      
      // Hold for extended period
      $display("[%0t] Holding LEFT key...", $time);
      repeat(50) @(posedge clk);
      
      // Release
      key_driver.send_key_break(KEY_LEFT);
      repeat(10) @(posedge clk);
      
      if (keys_valid == 6'b000000) begin
        $display("[%0t] PASS: Key hold and release test", $time);
        pass_count++;
      end else begin
        $display("[%0t] FAIL: Keys not cleared after release", $time);
        fail_count++;
      end
    end
  endtask
  
  //============================================================================
  // Test: Simultaneous Key Attempts (PS/2 can only send one at a time)
  //============================================================================
  task test_simultaneous_key_attempts();
    begin
      test_count++;
      
      $display("\n[%0t] ========================================", $time);
      $display("[%0t] TEST %0d: Back-to-Back Key Presses", $time, test_count);
      $display("[%0t] ========================================", $time);
      
      // Press first key
      key_driver.send_key_make(KEY_ROTATE);
      repeat(5) @(posedge clk);
      
      // Press second key before releasing first
      key_driver.send_key_make(KEY_DROP);
      repeat(5) @(posedge clk);
      
      // Release both
      key_driver.send_key_break(KEY_ROTATE);
      repeat(5) @(posedge clk);
      key_driver.send_key_break(KEY_DROP);
      repeat(10) @(posedge clk);
      
      $display("[%0t] PASS: Back-to-back key test completed", $time);
      pass_count++;
    end
  endtask
  
  //============================================================================
  // Test: Invalid Scan Codes
  //============================================================================
  task test_invalid_scan_codes();
    logic [5:0] keys_before, keys_after;
    begin
      test_count++;
      
      $display("\n[%0t] ========================================", $time);
      $display("[%0t] TEST %0d: Invalid Scan Code Test", $time, test_count);
      $display("[%0t] ========================================", $time);
      
      keys_before = keys_valid;
      
      // Send invalid scan codes
      key_driver.send_raw_byte(8'hAA);
      repeat(10) @(posedge clk);
      
      key_driver.send_raw_byte(8'h99);
      repeat(10) @(posedge clk);
      
      keys_after = keys_valid;
      
      if (keys_before == keys_after && keys_after == 6'b000000) begin
        $display("[%0t] PASS: Invalid scan codes ignored correctly", $time);
        pass_count++;
      end else begin
        $display("[%0t] FAIL: Invalid scan codes affected keys_valid", $time);
        fail_count++;
      end
    end
  endtask
  
  //============================================================================
  // Test: Break Code Timing
  //============================================================================
  task test_break_code_timing();
    begin
      test_count++;
      
      $display("\n[%0t] ========================================", $time);
      $display("[%0t] TEST %0d: Break Code Timing Test", $time, test_count);
      $display("[%0t] ========================================", $time);
      
      // Normal sequence: Make -> Break (0xF0) -> Make code again
      key_driver.send_key_make(KEY_START);
      repeat(10) @(posedge clk);
      
      // Verify key is set
      if (keys_valid[0] == 1'b1) begin
        $display("[%0t] Key START active", $time);
      end
      
      // Send break code
      key_driver.send_key_break(KEY_START);
      repeat(10) @(posedge clk);
      
      // Verify key is cleared
      if (keys_valid[0] == 1'b0) begin
        $display("[%0t] PASS: Break code timing correct", $time);
        pass_count++;
      end else begin
        $display("[%0t] FAIL: Break code not processed correctly", $time);
        fail_count++;
      end
    end
  endtask
  
  //============================================================================
  // Print Test Summary
  //============================================================================
  task print_test_summary();
    int success_rate;
    begin
      if (test_count > 0)
        success_rate = (pass_count * 100) / test_count;
      else
        success_rate = 0;
        
      $display("\n==============================================================================");
      $display("  TEST SUMMARY");
      $display("==============================================================================");
      $display("  Total Tests:  %0d", test_count);
      $display("  Passed:       %0d", pass_count);
      $display("  Failed:       %0d", fail_count);
      $display("  Success Rate: %0d%%", success_rate);
      $display("==============================================================================\n");
      
      if (fail_count == 0) begin
        $display("  *** ALL TESTS PASSED ***");
      end else begin
        $display("  *** %0d TEST(S) FAILED ***", fail_count);
      end
      $display("==============================================================================\n");
    end
  endtask
  
  //============================================================================
  // Timeout Watchdog
  //============================================================================
  initial begin
    #(TEST_TIMEOUT * 100);
    $display("\n[%0t] ERROR: Global timeout reached!", $time);
    $finish;
  end

endmodule
