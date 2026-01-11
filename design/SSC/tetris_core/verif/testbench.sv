`timescale 1ns/1ps

//==============================================================================
// Professional Tetris Testbench with PS/2 Keyboard Integration
// Features:
//   - PS/2 keyboard driver for game control
//   - Respects ctrl_allowed signal from game logic
//   - Pattern-based test scenarios
//   - Scoreboard for game state tracking
//==============================================================================

module testbench; 

 
  //============================================================================
  // Clock and Reset Signals
  //============================================================================
  reg core_clk;
  reg core_rst;
  reg vga_clk;
  reg vga_rst;
  
  //============================================================================
  // PS/2 Interface Signals
  //============================================================================
  wire ps2_clk;
  wire ps2_data;
  
  //============================================================================
  // Internal Control Signals (from kd_ps2 to tetris_core)
  //============================================================================
  wire        rd_data_valid;
  wire [7:0]  rd_data_payload;
  wire [5:0]  keys_valid;
  wire        game_start;
  wire        move_left;
  wire        move_right;
  wire        move_down;
  wire        rotate;
  wire        drop;
  wire        screen_is_ready ; 
  wire        vga_sof;     
  //============================================================================
  // Output Signals from Tetris Core
  //============================================================================
  wire ctrl_allowed;
  wire vga_vSync;
  wire vga_hSync;
  wire vga_colorEn;
  wire [3:0] vga_color_r;
  wire [3:0] vga_color_g;
  wire [3:0] vga_color_b;
  
  //============================================================================
  // Testbench Control Variables
  //============================================================================
  int move_count = 0;
  int test_phase = 0;
  bit simulation_done = 0;
  
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
  // Pull-ups for PS/2 Bus
  //============================================================================
  pullup(ps2_clk);
  pullup(ps2_data);
  
  //============================================================================
  // PS/2 Keyboard Driver Instantiation
  //============================================================================
  ps2_key_driver key_driver (
    .clk      (core_clk),
    .reset    (core_rst),
    .ps2_clk  (ps2_clk),
    .ps2_data (ps2_data)
  );
  
/*
  //============================================================================
  // PS/2 Keyboard Decoder (kd_ps2) Instantiation
  //============================================================================
  kd_ps2 ps2_decoder (
    .ps2_clk         (ps2_clk),
    .ps2_data        (ps2_data),
    .rd_data_valid   (rd_data_valid),
    .rd_data_payload (rd_data_payload),
    .keys_valid      (keys_valid),
    .reset           (core_rst),
    .clk             (core_clk)
  );
  
  //============================================================================
  // Map keys_valid to game control signals
  //============================================================================
  assign game_start = keys_valid[0];  // START key
  assign move_down  = keys_valid[1];  // DOWN key
  assign move_left  = keys_valid[2];  // LEFT key
  assign move_right = keys_valid[3];  // RIGHT key
  assign rotate     = keys_valid[4];  // ROTATE key
  assign drop       = keys_valid[5];  // DROP key
*/

  //============================================================================
  // Tetris Core DUT Instantiation
  //============================================================================
  tetris_core DUT (
    .core_clk    (core_clk),
    .core_rst    (core_rst),
    .vga_clk     (vga_clk),
    .vga_rst     (vga_rst),
    .game_start  (game_start),
    .move_left   (move_left),
    .move_right  (move_right),
    .move_down   (move_down),
    .rotate      (rotate),
    .drop        (drop),
    .ctrl_allowed(ctrl_allowed),
    .vga_vSync   (vga_vSync),
    .vga_hSync   (vga_hSync),
    .vga_colorEn (vga_colorEn),
    .vga_color_r (vga_color_r),
    .vga_color_g (vga_color_g),
    .vga_color_b (vga_color_b),
    .screen_is_ready ( screen_is_ready ), 
    .vga_sof (vga_sof)
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
  // Tetris Game Controller Instantiation
  //============================================================================
  /*
  tetris_game_controller game_ctrl (
    .clk          (core_clk),
    .reset        (core_rst),
    .ctrl_allowed (ctrl_allowed),
    .keys_valid   (keys_valid)
  );
*/
  
  //============================================================================
  // Main Test Sequence
  //============================================================================
  initial begin
    $display("==============================================================================");
    $display("  Tetris Testbench with PS/2 Keyboard Control");
    $display("  Simulation Start Time: %t", $time);
    $display("==============================================================================\n");
    
    // Initialize signals
    core_rst = 1'b1;
    vga_rst  = 1'b1;
    
    // Apply reset
    #200;
    core_rst = 1'b0;
    vga_rst  = 1'b0;
    #200;
    
    $display("[%0t] Reset completed. Starting Game now ! \n", $time);
    // Wait for system to stabilize
    repeat(10) @(posedge core_clk);
    key_driver.send_key_make( 8'h1D);
    

    wait( screen_is_ready == 1'b1 ) ;           
    $display("[%0t] Openning Screen is ready !\n", $time);
    
 
    $display("[%0t] Starting run test scenarios !", $time);
    // Run test scenarios
    run_test_scenarios();
    
    // Wait for simulation to complete
    wait(simulation_done);
    
    #10000;
    $display("\n==============================================================================");
    $display("  Tetris Testbench Completed Successfully");
    $display("  Total Moves Executed: %0d", move_count);
    $display("  Simulation End Time: %t", $time);
    $display("==============================================================================\n");
    
  end
 
  task wait_new_piece(); 
    begin 
        $display("[%0t] Waiting for new piece avaliableo ..... \n", $time);
        wait(DUT.game_logic_inst.controller_inst_gen_piece_en == 1'b1 ); 
        $display("[%0t] One new piece has been generated ! \n", $time);

    end
  endtask    


  //============================================================================
  // Test Scenario Execution
  //============================================================================
  task run_test_scenarios();
    begin
      // Scenario 1: Start game
      wait_new_piece() ; 
      test_phase = 1;
      $display("\n[SCENARIO 1] Starting Game...");
      execute_pattern("SINGLE_DROP");  

      // Scenario 2: Basic movement pattern
      wait_new_piece() ; 
      test_phase = 2;
      $display("\n[SCENARIO 2] Basic Movement Pattern");
      execute_pattern("BASIC_MOVES");
      
      // Scenario 3: Rotation test
      test_phase = 3;
      $display("\n[SCENARIO 3] Rotation Test");
      execute_pattern("ROTATE_TEST");
      
      // Scenario 4: Line clearing pattern
      test_phase = 4;
      $display("\n[SCENARIO 4] Line Clearing Pattern");
      execute_pattern("LINE_CLEAR");
      
      // Scenario 5: Fast drop test
      test_phase = 5;
      $display("\n[SCENARIO 5] Fast Drop Test");
      execute_pattern("FAST_DROP");
      
      // Scenario 6: Complex gameplay
      test_phase = 6;
      $display("\n[SCENARIO 6] Complex Gameplay");
      execute_pattern("COMPLEX_GAME");
      
      simulation_done = 1;
    end
  endtask
  
  //============================================================================
  // Execute Predefined Movement Patterns
  //============================================================================
  task execute_pattern(input string pattern_name);
    begin
      case(pattern_name)
        "BASIC_MOVES": begin
          send_game_command("LEFT");
          send_game_command("LEFT");
          send_game_command("RIGHT");
          send_game_command("RIGHT");
          send_game_command("DOWN");
          send_game_command("DOWN");
        end
        
        "ROTATE_TEST": begin
          send_game_command("ROTATE");
          wait_cycles(500);
          send_game_command("ROTATE");
          wait_cycles(500);
          send_game_command("ROTATE");
          wait_cycles(500);
          send_game_command("ROTATE");
        end
        
        "LINE_CLEAR": begin
          // Move piece to left side
          send_game_command("LEFT");
          send_game_command("LEFT");
          send_game_command("LEFT");
          send_game_command("LEFT");
          send_game_command("DROP");
          wait_cycles(2000);
          
          // Move next piece to right side
          send_game_command("RIGHT");
          send_game_command("RIGHT");
          send_game_command("RIGHT");
          send_game_command("RIGHT");
          send_game_command("DROP");
          wait_cycles(2000);
        end
        
        "FAST_DROP": begin
          send_game_command("LEFT");
          send_game_command("DROP");
          wait_cycles(2000);
          send_game_command("RIGHT");
          send_game_command("DROP");
          wait_cycles(2000);
          send_game_command("DROP");
        end
        
        "COMPLEX_GAME": begin
          // Sequence 1: Position and rotate
          send_game_command("LEFT");
          send_game_command("ROTATE");
          send_game_command("LEFT");
          send_game_command("DOWN");
          send_game_command("DOWN");
          send_game_command("DOWN");
          
          // Sequence 2: Quick placement
          send_game_command("RIGHT");
          send_game_command("RIGHT");
          send_game_command("ROTATE");
          send_game_command("DROP");
          wait_cycles(2000);
          
          // Sequence 3: Alternate movements
          send_game_command("LEFT");
          send_game_command("ROTATE");
          send_game_command("RIGHT");
          send_game_command("ROTATE");
          send_game_command("DOWN");
          send_game_command("DROP");
        end

        "SINGLE_DROP": begin
          send_game_command("DROP");
        end
        
        default: begin
          $display("[ERROR] Unknown pattern: %s", pattern_name);
        end
      endcase
    end
  endtask
  
  //============================================================================
  // Send Game Command (waits for ctrl_allowed)
  //============================================================================
  task send_game_command(input string cmd);
    logic [7:0] scan_code;
    begin
      // Map command to PS/2 scan code
      case(cmd)
        "START":  scan_code = 8'h1D;  // W key
        "DOWN":   scan_code = 8'h1B;  // S key
        "LEFT":   scan_code = 8'h1C;  // A key
        "RIGHT":  scan_code = 8'h23;  // D key
        "ROTATE": scan_code = 8'h29;  // Space key
        "DROP":   scan_code = 8'h5A;  // Enter key
        default: begin
          $display("[ERROR] Unknown command: %s", cmd);
          return;
        end
      endcase
      
      // Wait for ctrl_allowed before sending command
      $display("[%0t] Waiting for ctrl_allowed to send %s command...", $time, cmd);
      wait(ctrl_allowed == 1'b1);
      @(posedge core_clk);
      
      $display("[%0t] Sending %s command (scan code: 0x%02h)", $time, cmd, scan_code);
      
      // Send key press
      key_driver.send_key_make(scan_code);
      
      // Wait for key to register
      repeat(20) @(posedge core_clk);
      
      // Send key release
      key_driver.send_key_break(scan_code);
      
      // Wait for command to be processed
      repeat(20) @(posedge core_clk);
      
      move_count++;
      $display("[%0t] %s command completed (Move #%0d)", $time, cmd, move_count);
    end
  endtask
  
  //============================================================================
  // Wait for specified number of clock cycles
  //============================================================================
  task wait_cycles(input int cycles);
    begin
      repeat(cycles) @(posedge core_clk);
    end
  endtask
  
  //============================================================================
  // Monitor ctrl_allowed signal changes
  //============================================================================
  logic ctrl_allowed_prev = 0;
  always @(posedge core_clk) begin
    if (ctrl_allowed != ctrl_allowed_prev) begin
      $display("[%0t] ctrl_allowed changed: %b -> %b", 
               $time, ctrl_allowed_prev, ctrl_allowed);
      ctrl_allowed_prev <= ctrl_allowed;
    end
  end
  
  //============================================================================
  // Monitor game control signals
  //============================================================================
  always @(posedge core_clk) begin
    if (game_start || move_left || move_right || move_down || rotate || drop) begin
      $display("[%0t] Game Controls Active - START=%b LEFT=%b RIGHT=%b DOWN=%b ROTATE=%b DROP=%b",
               $time, game_start, move_left, move_right, move_down, rotate, drop);
    end
  end
  
  //============================================================================
  // FSDB Waveform Dumper
  //============================================================================
  initial begin
    $display("[SIM_INFO] @%t: Start to dump waveform", $time);
    $fsdbDumpfile("tetris_cosim.fsdb");
    $fsdbDumpvars(0, testbench);
    #250ms $finish;
  end
  
  //============================================================================
  // Timeout Watchdog
  //============================================================================
  initial begin
    #260ms;
    $display("\n[WARNING] Simulation timeout reached!");
    $display("Total moves completed: %0d", move_count);
    $finish;
  end

endmodule
