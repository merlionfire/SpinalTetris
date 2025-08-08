module btn_filter #( parameter PIN_NUM = 3 ) 
(
   input   clk , 
   input   [ PIN_NUM-1 : 0 ]   pin_in    , 
   output  [ PIN_NUM-1 : 0 ]   pin_out    
) ; 


   wire [ PIN_NUM-1 : 0 ] pin_in_sync ; 

   genvar i ; 
   generate 
      for ( i = 0 ; i < PIN_NUM ; i = i+1 ) begin : io_sync_db   

         synchro #(.INITIALIZE("LOGIC0")) io_btn_sync_inst (
            .clk    (  clk            ),
            .async  (  pin_in[i]      ),
	    .sync   (  pin_in_sync[i] )
	);


         debounce btn_db_inst (
            .Clk       ( clk ), 
            .DataNoisy ( pin_in_sync[i]  ),
            .DataClean ( pin_out[i]    ) 
         );
      end 
   endgenerate 

endmodule 
