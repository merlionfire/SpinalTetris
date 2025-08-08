module pulse_gen (
   input  clk ,
   input  data_in , 
   output data_pulse 
);

   reg data_in_d1 = 1'b0  ; 

   always @( posedge clk ) 
      data_in_d1 <= data_in ; 
      
   assign data_pulse = data_in & ( ~data_in_d1 )  ; 

endmodule    

