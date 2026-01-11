`timescale 1ns/1ps

module vga_frame_monitor #(
    parameter H_DISPLAY = 640,
    parameter V_DISPLAY = 480
)(
    input wire vga_clk,
    input wire vga_rst,
    input wire vga_hSync,
    input wire vga_vSync,
    input wire vga_colorEn,
    input wire [3:0] vga_color_r,
    input wire [3:0] vga_color_g,
    input wire [3:0] vga_color_b
);

    // Frame buffer to store RGB values
    reg [11:0] frame_buffer [0:V_DISPLAY-1][0:H_DISPLAY-1]; // 4-bit per channel
    
    // Counters
    integer h_count;
    integer v_count;
    integer frame_count;
    
    // State detection
    reg vga_vSync_d;
    reg vga_hSync_d;
    wire frame_start;
    wire line_start;
   
    reg frame_preamp ; 
 
    assign frame_start = vga_vSync && !vga_vSync_d;  // Rising edge of vSync
    assign line_start = vga_hSync && !vga_hSync_d;   // Rising edge of hSync
    
    // File handling
    integer img_file;
    string img_folder = "vga_frames";
    string img_filename;
    
    // Initialize
    initial begin
        h_count = 0;
        v_count = 0;
        frame_count = 0;
        vga_vSync_d = 0;
        vga_hSync_d = 0;
        
        // Create output directory
        $system("mkdir -p vga_frames");
        $display("[VGA_MON] @%t: VGA Frame Monitor initialized", $time);
    end
    
    // Capture pixels and generate images
    always @(posedge vga_clk or posedge vga_rst) begin
        if (vga_rst) begin
            h_count <= 0;
            v_count <= 0;
            vga_vSync_d <= 0;
            vga_hSync_d <= 0;
            frame_preamp <= 0 ; 
        end else begin
            vga_vSync_d <= vga_vSync;
            vga_hSync_d <= vga_hSync;
            
            // Detect new frame
            if (frame_start) begin
                if (frame_count > 0) begin
                    // Save previous frame
                    save_frame_as_png(frame_count - 1);
                end
                frame_preamp <= 1 ;
                h_count <= 0;
                v_count <= 0;
                $display("[VGA_MON] @%t: Frame %0d started", $time, frame_count);
            end
            
            // Detect new line
            //if (line_start && !frame_start) begin
            if (line_start && !frame_preamp ) begin
                h_count <= 0;
                if (v_count < V_DISPLAY) begin
                    v_count <= v_count + 1;
                end
            end
           
            if (  vga_colorEn ) begin 
                frame_preamp <= 0 ; 
            end

            // Capture pixel data
            if (vga_colorEn && h_count < H_DISPLAY && v_count < V_DISPLAY) begin
                frame_buffer[v_count][h_count] <= {vga_color_r, vga_color_g, vga_color_b};
                h_count <= h_count + 1;

                // Debug: Print first few pixels
                if (v_count == 0 && h_count < 5) begin
                    $display("[VGA_MON] @%t: Pixel[%0d,%0d] = R:%h G:%h B:%h", 
                             $time, v_count, h_count, vga_color_r, vga_color_g, vga_color_b);
                end
            end
            
            // Check if frame is complete
            if (v_count >= V_DISPLAY && frame_start) begin
                frame_count <= frame_count + 1;
            end
        end
    end
    
    // Function to convert 4-bit color to 8-bit
    function automatic [7:0] vga4bit_to_8bit;
        input [3:0] color_4bit;
        begin
            // Replicate MSB: xxxx -> xxxxyyyy
            vga4bit_to_8bit = {color_4bit, color_4bit};
        end
    endfunction
    
    // Task to save frame as PNG using Python script
    task save_frame_as_png;
        input integer frame_num;
        integer x, y;
        reg [11:0] pixel;
        reg [7:0] r8, g8, b8;
        begin
            // Create filename
            img_filename = $sformatf("%s/frame_%04d.ppm", img_folder, frame_num);
            img_file = $fopen(img_filename, "w");
            
            if (img_file) begin
                // Write PPM header (P3 format - ASCII)
                $fwrite(img_file, "P3\n");
                $fwrite(img_file, "%0d %0d\n", H_DISPLAY, V_DISPLAY);
                $fwrite(img_file, "255\n");
                
                // Write pixel data
                for (y = 0; y < V_DISPLAY; y = y + 1) begin
                    for (x = 0; x < H_DISPLAY; x = x + 1) begin
                        pixel = frame_buffer[y][x];
                        r8 = vga4bit_to_8bit(pixel[11:8]);
                        g8 = vga4bit_to_8bit(pixel[7:4]);
                        b8 = vga4bit_to_8bit(pixel[3:0]);
                        $fwrite(img_file, "%0d %0d %0d ", r8, g8, b8);
                    end
                    $fwrite(img_file, "\n");
                end
                
                $fclose(img_file);
                $display("[VGA_MON] @%t: Frame %0d saved to %s", $time, frame_num, img_filename);
                
                // Convert PPM to PNG using ImageMagick
                //$system($sformatf("convert %s %s/frame_%04d.png 2>/dev/null", img_filename, img_folder, frame_num));
                //$system($sformatf("rm -f %s", img_filename)); // Remove temporary PPM
            end else begin
                $display("[VGA_MON] ERROR: Cannot open file %s", img_filename);
            end
        end
    endtask
    
endmodule
