#!/usr/bin/perl - w

use strict  ; 

my $case_var  ; 
my $output_var ; 
my $max_var ; 
my $final_var ; 
my $sel_var ; 
my $tb = " " x 3 ; 
my $tb2 = $tb x 2 ; 
my $tb3 = $tb x 3 ; 
my $tb4 = $tb x 4 ; 
my $i = 0 ; 
my %comments ; 

while (<>) { 
  chomp ; 
  if ( /(\w+)\s*:\s*(\S.*\S)/ )  {
     my $idx_name = uc $1; 
     print  "parameter $idx_name = $i ;\n" ; 
     $i++ ; 
     $comments{$idx_name} = $2 ; 
  } elsif ( /case_var\s*=\s*(\w+)/ ) {
     $case_var  = $1 ;  
  } elsif ( /output_var\s*=\s*(\w+)/ ) {
     $output_var = $1 ; 
  } elsif ( /sel_var\s*=\s*(\w+)/ ) {
     $sel_var = $1 ; 
  } elsif ( /final_var\s*=\s*(\w+)/ ) {
     $final_var = $1 ; 
  } elsif ( /max_var\s*=\s*(\w+)/ ) {
     $max_var = uc $1 ; 
  }    
}    

print "\nparameter $max_var = $i ;\n\n" ; 

#print "always @(*) begin\n" ; 
#print "$tb genvar i;\n";
#print "$tb generate\n" ; 
#print "$tb2 for ( i = 0 ; i < $max_var ; i = i + 1 ) begin\n";
#print "$tb3 if ( ${sel_var}[i] == 1\'b1 ) begin\n" ; 
#print "$tb4 $final_var = ${output_var}[i] ;\n" ; 
#print "$tb3 end\n";
#print "$tb2 end\n";
#print "$tb endgenerate\n";
#print "end\n"; 
#print "\n" ;    
 
print "always @( ${sel_var} " ; 
for ( my $j=0 ; $j < $i ; $j++ ) {
   print ( "or ${output_var}[$j]" ) ; 
}
print ") begin\n" ;
print "$tb $final_var = 8'h00;\n" ;
print "$tb for ( i = 0 ; i < `$max_var ; i = i + 1 ) begin\n";
print "$tb2 case ( 1'b1 )\n";
print "$tb3 ${sel_var}[i] : begin\n";
print "$tb4 $final_var = ${output_var}[i] | $final_var;\n" ; 
print "$tb3 end\n" ; 
print "$tb3 default : $final_var = $final_var; \n" ;
print "$tb2 endcase\n" ;
print "$tb end\n";
print "end\n" ; 







while ( my ( $comment_idx, $comment_value ) = each %comments ) {
 my $idx = 0 ; 
 my @chars = unpack( "C*", $comment_value ) ;      
 print "// ROM for \"$comment_value \"\n" ;  
 print "always @(*) begin\n" ; 
 print "${tb}case ( $case_var ) \n" ;    
 foreach  ( @chars ) {
   printf("$tb2%2d : ${output_var}[ $comment_idx ] = 8\'h%2x ;//%c\n", $idx, $_, $_ ) ;    
   $idx++ ; 
 }    
 printf("${tb2}default : ${output_var}[ $comment_idx ] = 8\'h0a; //CR\n" ) ;    
 print "${tb}endcase\n";  
 print "end\n" ;    
 print "\n" ;    
}    



