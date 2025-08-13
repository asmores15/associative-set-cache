```

module instr_cache(input [31:0] pc,
                   input clk, we,
                   input  [(ADRESSIZE*SETSIZE)-1:0] memIn,
                   output [(ADRESSIZE*SETSIZE)-1:0] instrOut,
					output hit,
                   output [SETSIZE-1:0] sets_index);
  
  
  
  
  //(ADRESSIZE*SETSIZE) is a valid MSB expression instead of manually evaluating expression
  //(ADRESSIZE*SETSIZE+DATASIZE) = 96 in current instance
//parameter ADRESSIZEXSETSIZE = 64;
parameter DATASIZE = 32;
parameter ADRESSIZE = 32;
parameter BLOCKS = 16;
//N-way N = 2 
parameter SETSIZE = 2;
  

  reg [(ADRESSIZE*SETSIZE+DATASIZE):0] sets[SETSIZE-1:0];
reg compare, isValid;
//latch address for read
reg [ADRESSIZE-1:0] rd_addr;
  //wire [SETSIZE-1:0] sets_index; commented while output
wire [ADRESSIZE-1:0] addr; 
wire [ADRESSIZE-1:0] memdata;

  
  
initial
begin
  sets[sets_index][(ADRESSIZE*SETSIZE+DATASIZE)] = 0;
end


always @(posedge clk)
begin
	if(we)
      begin
        sets[sets_index][(ADRESSIZE*SETSIZE)-1:0] <= memIn;
        sets[sets_index][(ADRESSIZE*SETSIZE+DATASIZE)-1:(ADRESSIZE*SETSIZE)] <= pc[31:SETSIZE+2];
        sets[sets_index][(ADRESSIZE*SETSIZE+DATASIZE)] <= 1;
      end	
rd_addr <= addr;
	

  compare <= (pc[31:SETSIZE+2] === sets[sets_index][(ADRESSIZE*SETSIZE+DATASIZE)-1:(ADRESSIZE*SETSIZE)]);
  isValid <= sets[sets_index][(ADRESSIZE*SETSIZE+DATASIZE)];
end
  
  
  //set internal and external signals
  assign sets_index = pc[SETSIZE+1:2];
  assign memdata = memIn[DATASIZE-1:0];	
  assign addr = pc[31:SETSIZE+2]; 
  assign instrOut = sets[sets_index][rd_addr];
  assign hit = isValid && compare;


endmodule



//memory module for testing
module memory1(input [28:0] pc, output [31:0] instr);
  reg [31:0] temp[11:0];
  reg [31:0] bank[11:0];
integer i = 0;
integer k = 0;

  
initial
begin
  $readmemh("mem1.dat", temp);
  for (i = 0; i < 11; i = i + 1)
  begin
    bank[k] = temp[i];
		 k = k + 1;
  end
end
  assign instr = bank[pc];
endmodule

module memory2(input [28:0] pc, output [31:0] instr);
  reg [31:0] temp[11:0];
  reg [31:0] bank[11:0];
integer i = 0;
integer k = 0;

  
initial
begin
  $readmemh("mem2.dat", temp);
  for (i = 0; i < 11; i = i + 1)
  begin
    bank[k] = temp[i];
		 k = k + 1;
  end
end
  assign instr = bank[pc];
endmodule


module testbench();
reg clk;
reg rd;
reg reset;
  wire [63:0] memIn;
  wire [63:0] instrOut;
reg we;
  reg [31:0] pc;
wire hit; 
  wire [31:0] mem1out;
  wire [31:0] mem2out;
  
  wire [1:0] sIndex;

  
  memory1 mem1(pc[31:3], mem1out);
  memory2 mem2(pc[31:3], mem2out);
// instantiate device to be tested
  instr_cache dut (pc, clk, we, memIn, instrOut, hit, sIndex);
// initialize test
initial
begin
pc <= 0;
we <= 1;
end
  
// generate clock to sequence tests
always
begin
clk <= 1;
 # 5; 
 clk <= 0;
 # 5; // clock duration
end
  
  //create memIn 
  assign memIn = {mem1out,mem2out};
  //PC counter
  
  always @ (negedge clk)
    begin
      $display ("hit: %0d, pc: %0h memIn: %0h, instruction: %0h, sIndex: %0h", hit, pc, memIn, instrOut, sIndex);
pc <= pc + 4;
    end
      
// check results
always @ (negedge clk)
begin
  if(pc === 40)
    $stop;
  
/*  if (we) begin
if (dataadr === 84 & writedata === 7) begin
$display ("Simulation succeeded");
//$stop;
end
    if (dataadr !== 80) begin
$display ("Simulation failed");
//$stop;
end

end
*/
end
endmodule
```