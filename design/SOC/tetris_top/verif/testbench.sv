`timescale 1ns/1ps

//==============================================================================
// Tetris Testbench with UART/PS2 Keyboard Integration
// DUT: tetris_top
// Features:
//   - Switchable UART/PS2 keyboard driver for game control
//   - Waits for screen_is_ready before starting gameplay
//   - Executes pattern per piece (waits for gen_piece_en)
//   - Pattern-based test scenarios
//==============================================================================

module testbench;
  
  //============================================================================
  // Compilation Switches
  //============================================================================
  `define UART    // Comment out to use PS2 mode
  //`define PS2  // Uncomment to use PS2 mode (alternative to UART)
  
  //============================================================================
  // Clock and Reset Signals
  //============================================================================
  reg core_clk;
  reg core_rst;
  reg vga_clk;
  reg vga_rst;
  
  //============================================================================
  // Button Interface (tied off - using UART/PS2 only)
  //============================================================================
  wire btns_btn_north  = 1'b0;
  wire btns_btn_east   = 1'b0;
  wire btns_btn_south  = 1'b0;
  wire btns_btn_west   = 1'b0;
  wire btns_rot_push   = 1'b0;
  wire btns_rot_pop    = 1'b0;
  wire btns_rot_left   = 1'b0;
  wire btns_rot_right  = 1'b0;
  wire btns_rot_clr;
  
  //============================================================================
  // PS/2 Interface Signals
  //============================================================================
  wire ps2_clk;
  wire ps2_data;
  
  //============================================================================
  // UART Interface Signals
  //============================================================================
  wire uart_txd;
  reg  uart_rxd;
  
  //============================================================================
  // VGA Output Signals
  //============================================================================
  wire vga_vSync;
  wire vga_hSync;
  wire vga_colorEn;
  wire [3:0] vga_color_r;
  wire [3:0] vga_color_g;
  wire [3:0] vga_color_b;
  
  //============================================================================
  // Internal Monitoring Signals
  //============================================================================
  wire screen_is_ready;
  wire gen_piece_en;
  wire sof;
  wire ctrl_allowed;
  
  //============================================================================
  // Testbench Control Variables
  //============================================================================
  int piece_count = 0;
  int move_count = 0;
  int test_scenario = 0;
  bit game_started = 0;
  bit simulation_done = 0;
  
  // UART timing parameters
  localparam int BAUD_RATE = 19200;
  localparam int CLOCK_FREQ = 50_000_000;  // 50MHz
  localparam int BIT_PERIOD_NS = 1_000_000_000 / BAUD_RATE;  // ~52083 ns
  
  //============================================================================
  // Clock Generation
  //============================================================================
  initial begin
    core_clk = 0;
    forever #10 core_clk = ~core_clk;  // 50MHz
  end
  
  initial begin
    vga_clk = 0;
    forever #20 vga_clk = ~vga_clk;    // 25MHz
  end
  
  //============================================================================
  // Conditional Compilation for UART vs PS2
  //============================================================================
`ifdef UART
  //==========================================================================
  // UART Mode Configuration
  //==========================================================================
  initial begin
    uart_rxd = 1'b1;  // UART idle state is high
    $display("╔═══════════════════════════════════════════════════════════════╗");
    $display("║              TESTBENCH MODE: UART                             ║");
    $display("║              Baud Rate: %0d                                ║", BAUD_RATE);
    $display("╚═══════════════════════════════════════════════════════════════╝\n");
  end
  
`else
  //==========================================================================
  // PS/2 Mode Configuration
  //==========================================================================
  pullup(ps2_clk);
  pullup(ps2_data);
  
  
  initial begin
    uart_rxd = 1'b1;  // Keep UART idle even in PS2 mode
    $display("╔═══════════════════════════════════════════════════════════════╗");
    $display("║              TESTBENCH MODE: PS2 Keyboard                     ║");
    $display("╚═══════════════════════════════════════════════════════════════╝\n");
  end
`endif
  
  ps2_key_driver key_driver (
    .clk      (core_clk),
    .reset    (core_rst),
    .ps2_clk  (ps2_clk),
    .ps2_data (ps2_data)
  );

  //============================================================================
  // Tetris Top DUT Instantiation
  //============================================================================
  tetris_top DUT (
    .core_clk        (core_clk),
    .core_rst        (core_rst),
    .vga_clk         (vga_clk),
    .vga_rst         (vga_rst),
    .btns_btn_north  (btns_btn_north),
    .btns_btn_east   (btns_btn_east),
    .btns_btn_south  (btns_btn_south),
    .btns_btn_west   (btns_btn_west),
    .btns_rot_push   (btns_rot_push),
    .btns_rot_pop    (btns_rot_pop),
    .btns_rot_left   (btns_rot_left),
    .btns_rot_right  (btns_rot_right),
    .btns_rot_clr    (btns_rot_clr),
    .ps2_clk         (ps2_clk),
    .ps2_data        (ps2_data),
    .uart_txd        (uart_txd),
    .uart_rxd        (uart_rxd),
    .vga_vSync       (vga_vSync),
    .vga_hSync       (vga_hSync),
    .vga_colorEn     (vga_colorEn),
    .vga_color_r     (vga_color_r),
    .vga_color_g     (vga_color_g),
    .vga_color_b     (vga_color_b)
  );
  
  //============================================================================
  // VGA Frame Monitor Instantiation
  //============================================================================
  vga_frame_monitor #(
    .H_DISPLAY(640),
    .V_DISPLAY(480)
  ) vga_mon (
    .vga_clk     (vga_clk),
    .vga_rst     (vga_rst),
    .vga_hSync   (vga_hSync),
    .vga_vSync   (vga_vSync),
    .vga_colorEn (vga_colorEn),
    .vga_color_r (vga_color_r),
    .vga_color_g (vga_color_g),
    .vga_color_b (vga_color_b)
  );
  
  //============================================================================
  // Connect Internal Signals for Monitoring
  //============================================================================
  assign screen_is_ready = DUT.tetris_core_inst.game_display_inst_screen_is_ready;
  assign gen_piece_en    = DUT.tetris_core_inst.game_logic_inst.controller_inst_gen_piece_en;
  assign ctrl_allowed    = DUT.tetris_core_inst_ctrl_allowed;
  assign sof             = DUT.tetris_core_inst.game_display_inst_sof;
  
  //============================================================================
  // Main Test Sequence
  //============================================================================
  initial begin
    $display("==============================================================================");
    $display("  Tetris Testbench - Keyboard Control");
    $display("  Start Time: %t", $time);
    $display("==============================================================================\n");
    
    // Initialize and Reset
    core_rst = 1'b1;
    vga_rst  = 1'b1;
    game_started = 0;
    
    #400;
    core_rst = 1'b0;
    vga_rst  = 1'b0;
    
    $display("[%0t] Reset released", $time);
    
    repeat(20) @(posedge core_clk);
    wait(sof);
    repeat(500) @(posedge core_clk);
    
    wait(sof);
    
    // Step 1: Send START key
    $display("\n[%0t] ========================================", $time);
    $display("[%0t] STEP 1: Sending START command", $time);
    $display("[%0t] ========================================", $time);
    send_key("START");
    game_started = 1;
    
    // Step 2: Wait for screen_is_ready
    $display("\n[%0t] ========================================", $time);
    $display("[%0t] STEP 2: Waiting for screen_is_ready", $time);
    $display("[%0t] ========================================", $time);
    wait(screen_is_ready == 1'b1);
    $display("[%0t] Screen is ready! Starting gameplay...\n", $time);
    
    // Step 3: Execute test patterns
    run_test_scenarios();
    
    // Wait for simulation to complete
    wait(simulation_done);
    
    #10000;
    print_final_summary();
    $finish;
  end
  
  //============================================================================
  // Wait for New Piece Task
  //============================================================================
  task wait_for_new_piece();
    begin
      $display("\n[%0t] ──────────────────────────────────────────", $time);
      $display("[%0t] Piece #%0d: Waiting for gen_piece_en...", $time, piece_count);
      wait(gen_piece_en == 1'b1);
      @(posedge core_clk);
      $display("[%0t] Piece #%0d: New piece detected!", $time, piece_count);
      piece_count++;
    end
  endtask
  
  //============================================================================
  // Run Test Scenarios - Execute Patterns Per Piece
  //============================================================================
  task run_test_scenarios();
    begin
      $display("\n╔═══════════════════════════════════════════════════════════════╗");
      $display("║              STARTING TEST SCENARIOS                          ║");
      $display("╚═══════════════════════════════════════════════════════════════╝\n");
      
      // Scenario 1: Basic movements
      test_scenario = 1;
      $display("\n[SCENARIO 1] Basic Movement Tests (4 pieces)");
      wait_for_new_piece();
      execute_piece_pattern("LEFT_SIDE");
      execute_piece_pattern("RIGHT_SIDE");
      execute_piece_pattern("WITH_ROTATION");
      execute_piece_pattern("QUICK_DROP");
      
      // Scenario 2: Wall interactions
      test_scenario = 2;
      $display("\n[SCENARIO 2] Wall Interaction Tests (4 pieces)");
      wait_for_new_piece();
      execute_piece_pattern("LEFT_WALL");
      execute_piece_pattern("RIGHT_WALL");
      execute_piece_pattern("LEFT_WALL");
      execute_piece_pattern("RIGHT_WALL");
      
      // Scenario 3: Rotation tests
      test_scenario = 3;
      $display("\n[SCENARIO 3] Rotation Tests (4 pieces)");
      execute_piece_pattern("ROTATE_1X");
      execute_piece_pattern("ROTATE_2X");
      execute_piece_pattern("ROTATE_3X");
      execute_piece_pattern("ROTATE_4X");
      
      // Scenario 4: Complex patterns
      test_scenario = 4;
      $display("\n[SCENARIO 4] Complex Patterns (5 pieces)");
      wait_for_new_piece();
      execute_piece_pattern("ZIGZAG_LEFT");
      execute_piece_pattern("ZIGZAG_RIGHT");
      execute_piece_pattern("SLOW_DESCENT");
      execute_piece_pattern("ROTATE_AND_PLACE_LEFT");
      execute_piece_pattern("ROTATE_AND_PLACE_RIGHT");
      
      // Scenario 5: Line clearing attempt
      test_scenario = 5;
      $display("\n[SCENARIO 5] Line Clearing Pattern (10 pieces)");
      for (int i = 0; i < 10; i++) begin
        case(i % 5)
          0: execute_piece_pattern("FAR_LEFT");
          1: execute_piece_pattern("LEFT_SIDE");
          2: execute_piece_pattern("CENTER");
          3: execute_piece_pattern("RIGHT_SIDE");
          4: execute_piece_pattern("FAR_RIGHT");
        endcase
      end
      
      simulation_done = 1;
      $display("\n[%0t] All test scenarios completed!", $time);
    end
  endtask
  
  //============================================================================
  // Execute Pattern for One Piece
  //============================================================================
  task execute_piece_pattern(input string pattern_name);
    begin
      piece_count++;
      $display("[%0t] Execute Control Pattern: %s", $time, pattern_name);
      
      // Small delay to let piece spawn
      repeat(50) @(posedge core_clk);
      
      // Execute the pattern for this piece
      case(pattern_name)
        "QUICK_DROP": begin
          send_key("DROP");
        end
        
        "LEFT_SIDE": begin
          send_key("LEFT");
          send_key("LEFT");
        end
        
        "RIGHT_SIDE": begin
          send_key("RIGHT");
          send_key("RIGHT");
        end
        
        "CENTER": begin
          // No movement, just let it drop naturally
          repeat(100) @(posedge core_clk);
        end
        
        "WITH_ROTATION": begin
          send_key("ROTATE");
        end
        
        "LEFT_WALL": begin
          repeat(5) send_key("LEFT");
        end
        
        "RIGHT_WALL": begin
          repeat(5) send_key("RIGHT");
        end
        
        "ROTATE_1X": begin
          send_key("ROTATE");
        end
        
        "ROTATE_2X": begin
          repeat(2) send_key("ROTATE");
        end
        
        "ROTATE_3X": begin
          repeat(3) send_key("ROTATE");
        end
        
        "ROTATE_4X": begin
          repeat(4) send_key("ROTATE");
        end
        
        "ZIGZAG_LEFT": begin
          send_key("LEFT");
          send_key("DOWN");
          send_key("RIGHT");
          send_key("DOWN");
          send_key("LEFT");
        end
        
        "ZIGZAG_RIGHT": begin
          send_key("RIGHT");
          send_key("DOWN");
          send_key("LEFT");
          send_key("DOWN");
          send_key("RIGHT");
        end
        
        "SLOW_DESCENT": begin
          send_key("LEFT");
          repeat(4) send_key("DOWN");
        end
        
        "ROTATE_AND_PLACE_LEFT": begin
          send_key("ROTATE");
          repeat(2) send_key("LEFT");
        end
        
        "ROTATE_AND_PLACE_RIGHT": begin
          send_key("ROTATE");
          repeat(2) send_key("RIGHT");
        end
        
        "FAR_LEFT": begin
          repeat(4) send_key("LEFT");
          send_key("DROP");
        end
        
        "FAR_RIGHT": begin
          repeat(4) send_key("RIGHT");
        end
        
        default: begin
          $display("[ERROR] Unknown pattern: %s", pattern_name);
          send_key("DROP");
        end
      endcase
      
      $display("[%0t] Pattern '%s' completed", $time, pattern_name);
      
      // Wait for piece to settle
      repeat(100) @(posedge core_clk);
    end
  endtask
  
  //============================================================================
  // High-level Send Key Task (Protocol Abstraction)
  //============================================================================
  task send_key(input string key_name);
    begin
      // Wait for control allowed if not START command
      $display("\n[%0t] ──────────────────────────────────────────", $time);
      $display("[%0t] Piece #%0d: Waiting for ctrl_allowed....", $time, piece_count);
      wait(sof);
      @(posedge core_clk);
      
      if (key_name != "START") begin
        wait(ctrl_allowed);
        @(posedge core_clk);
      end
      
      // Call protocol-specific implementation
`ifdef UART
      send_uart_key(key_name);
`else
      send_ps2_key(key_name);
`endif
      
      move_count++;
    end
  endtask
  
  //============================================================================
  // UART Low-level Key Transmission
  //============================================================================
  task send_uart_key(input string key_name);
    logic [7:0] ascii_code;
    begin
      // Map key name to ASCII code
      case(key_name)
        "START":  ascii_code = 8'h77;  // 'w'
        "DOWN":   ascii_code = 8'h73;  // 's'
        "LEFT":   ascii_code = 8'h61;  // 'a'
        "RIGHT":  ascii_code = 8'h64;  // 'd'
        "ROTATE": ascii_code = 8'h20;  // space
        "DROP":   ascii_code = 8'h0D;  // enter
        default: begin
          $display("[ERROR] Unknown key: %s", key_name);
          return;
        end
      endcase
      
      $display("[%0t]   -> Sending UART %s (ASCII 0x%02h)", $time, key_name, ascii_code);
      
      // Send UART byte with proper protocol timing
      uart_tx_byte(ascii_code);
      
      // Wait for key to register
      repeat(50) @(posedge core_clk);
    end
  endtask
  
  //============================================================================
  // UART Transmit Byte (following UART protocol)
  //============================================================================
  task uart_tx_byte(input [7:0] data);
    int i;
    begin
      // Start bit
      uart_rxd = 1'b0;
      #BIT_PERIOD_NS;
      
      // Data bits (LSB first)
      for (i = 0; i < 8; i++) begin
        uart_rxd = data[i];
        #BIT_PERIOD_NS;
      end
      
      // Stop bit
      uart_rxd = 1'b1;
      #BIT_PERIOD_NS;
    end
  endtask
  
  //============================================================================
  // PS/2 Low-level Key Transmission
  //============================================================================
  task send_ps2_key(input string key_name);
    logic [7:0] scan_code;
    begin
      // Map key name to PS/2 scan code
      case(key_name)
        "START":  scan_code = 8'h1D;  // W key
        "DOWN":   scan_code = 8'h1B;  // S key
        "LEFT":   scan_code = 8'h1C;  // A key
        "RIGHT":  scan_code = 8'h23;  // D key
        "ROTATE": scan_code = 8'h29;  // Space key
        "DROP":   scan_code = 8'h5A;  // Enter key
        default: begin
          $display("[ERROR] Unknown key: %s", key_name);
          return;
        end
      endcase
      
      $display("[%0t]   -> Sending PS2 %s (0x%02h)", $time, key_name, scan_code);
      
      // Send key press (make code)
      key_driver.send_key_make(scan_code);
      
      // Wait for key to register
      repeat(30) @(posedge core_clk);
      
      // Send key release (break code)
      key_driver.send_key_break(scan_code);
      
      // Wait between commands
      repeat(30) @(posedge core_clk);
    end
  endtask
  
  //============================================================================
  // Monitor gen_piece_en Signal
  //============================================================================
  always @(posedge core_clk) begin
    if (gen_piece_en && game_started) begin
      $display("[%0t] *** gen_piece_en asserted ***", $time);
    end
  end
  
  //============================================================================
  // Monitor screen_is_ready Signal
  //============================================================================
  always @(posedge core_clk) begin
    if (screen_is_ready && !game_started) begin
      $display("[%0t] *** screen_is_ready asserted ***", $time);
    end
  end
  
  //============================================================================
  // Print Final Summary
  //============================================================================
  task print_final_summary();
    string mode_str;
    begin
`ifdef UART
      mode_str = "UART";
`else
      mode_str = "PS2";
`endif
      
      $display("\n");
      $display("╔═══════════════════════════════════════════════════════════════╗");
      $display("║                    SIMULATION SUMMARY                         ║");
      $display("╠═══════════════════════════════════════════════════════════════╣");
      $display("║  Test Mode:              %-35s║", mode_str);
      $display("║  Total Pieces Played:    %-35d║", piece_count);
      $display("║  Total Moves Executed:   %-35d║", move_count);
      $display("║  Test Scenarios:         %-35d║", test_scenario);
      $display("║  Simulation Time:        %-35t║", $time);
      $display("║  Status:                 %-35s║", "COMPLETED");
      $display("╚═══════════════════════════════════════════════════════════════╝");
      $display("\n");
    end
  endtask
  
  //============================================================================
  // FSDB Waveform Dumper
  //============================================================================
  initial begin
    $display("[SIM_INFO] @%t: Start to dump waveform", $time);
    $fsdbDumpfile("cosim_verdi.fsdb");
    $fsdbDumpvars(0, testbench);
    #250ms $finish;
  end
  
  //============================================================================
  // Timeout Watchdog
  //============================================================================
  initial begin
    #255ms;
    $display("\n[WARNING] Simulation timeout reached!");
    print_final_summary();
    $finish;
  end

endmodule
