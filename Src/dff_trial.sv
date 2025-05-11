//Design under test
module dff(input clk,
	    input D,
	    input reset,	
	    output reg Q,
	    output reg Qb	
	);

initial begin
	Q = 1'b0;
	Qb = 1'b1;
end
always@(posedge clk) begin
	if(reset) begin
	Q <= 1'b0;
	Qb <= 1'b1;
	end else begin
	Q <= D;
	Qb <= ~D;
	end
end

endmodule


//transaction object
class dff_item;
	rand bit D;
	rand bit reset;
	logic Q;
	logic Qb;

	constraint reset_freq {reset dist {1:=10 , 0:=90};}
	constraint D_freq {D dist{1:=50 , 0:=50};}

	function void print(string tag = "");
		$display("Time = %0t | %s | reset = %0b | D = %0b | Q = %0b | Qb = %0b ",$time,tag,reset,D,Q,Qb);
	endfunction
endclass

//interface 
interface dff_if(input bit clk);
	logic reset;
	logic D;
	logic Q;
	logic Qb;
endinterface


//generator
class generator;
	mailbox drv_mbx;
	mailbox gen2scb_mbx;
	event drv_done;
	dff_item item;
	int num = 10; 
		
	task run();
	for(int i = 0; i < num; i++) begin
	item = new();
	item.randomize();
	$display("Time = %0t | reset = %0b | generator | D = %0b ",$time,item.reset,item.D);
	drv_mbx.put(item);
	gen2scb_mbx.put(item);
	@(drv_done);
	end
	$display("Time = %0t | generation complete",$time);
	endtask
endclass


//driver
class driver;
	 
	virtual dff_if vif;
	mailbox drv_mbx;
	event drv_done;
	dff_item item;
	
	task run();
	repeat(10) begin	
	@(posedge vif.clk);
	drv_mbx.get(item);

	$display("Time = %0t | reset = %0b | driver | D = %0b ",$time,item.reset,item.D);
	vif.reset = item.reset;
	vif.D = item.D;
	$display("Time = %0t | vif.reset = %0b | vif.D = %0b ",$time,vif.reset,vif.D);
	
	@(posedge vif.clk);

	->drv_done;
	end
	endtask

endclass

//monitor
class monitor;
	virtual dff_if vif;
	mailbox scb_mbx;
	dff_item item;

	task run();
	repeat(10) begin
		item = new();
		@(posedge vif.clk); 
		@(posedge vif.clk); 
		#1;
		item.D = vif.D;
        	item.reset = vif.reset;
		item.Q = vif.Q;
		item.Qb = vif.Qb;
		
		//@(posedge vif.clk);
		$display("Time = %0t | monitor | Q = %0b | Qb = %0b",$time,vif.Q,vif.Qb);
		scb_mbx.put(item);

	end
	endtask
endclass

//scoreboard
class scoreboard;
	mailbox gen2scb_mbx;
	mailbox scb_mbx;
	
	task run();
	repeat (10) begin
		dff_item gen_item;
		dff_item mon_item;
			
		gen2scb_mbx.get(gen_item);
		scb_mbx.get(mon_item);
		$display("Time = %0t | gen_item | reset = %0b | D = %0b ",$time,gen_item.reset,gen_item.D);
		$display("Time = %0t | mon_item | reset = %0b | D = %0b | Q = %0b | Qb = %0b ",$time,mon_item.reset,mon_item.D,mon_item.Q,mon_item.Qb);
		
		if(gen_item.reset) begin
			if(mon_item.Q == 1'b0 && mon_item.Qb == 1'b1)
			$display("Time = %0t | reset condition passed",$time);
			else 
			$display("Time = %0t | reset condition failed",$time);
		end else begin 
			if(mon_item.Q == gen_item.D && mon_item.Qb == ~mon_item.Q)
			$display("Time = %0t | valid output ",$time);
			else 
			$display("Time = %0t | invalid output",$time);
		end	
	end	
	endtask

endclass

//environment 
class environment;
	generator g0;
	driver d0;
	monitor m0;
	scoreboard s0;

	mailbox drv_mbx; 
	mailbox scb_mbx;
	mailbox gen2scb_mbx;
	event drv_done;

	virtual dff_if vif;

	function new();
		g0 = new();
		d0 = new();
		m0 = new();
		s0 = new();
		drv_mbx = new();
		scb_mbx = new();
		gen2scb_mbx = new();

		g0.drv_mbx = drv_mbx;
		d0.drv_mbx = drv_mbx;
	
		m0.scb_mbx = scb_mbx;
		s0.scb_mbx = scb_mbx;

		g0.gen2scb_mbx = gen2scb_mbx;
		s0.gen2scb_mbx = gen2scb_mbx;
		
		g0.drv_done = drv_done;
		d0.drv_done = drv_done;	
	endfunction

	virtual task run();
	d0.vif = vif;
	m0.vif = vif;
	fork
		g0.run();
		d0.run();
		m0.run();
		s0.run();
	join_any
endtask

endclass

class test;
	environment e0;
	
	function new();
		e0 = new();
	endfunction
	
	task run();
		e0.run;
	endtask

endclass 

module tb;
reg clk;

dff_if if1(clk);
dff dut(.clk(if1.clk),
	.reset(if1.reset),
	.D(if1.D),
	.Q(if1.Q),
	.Qb(if1.Qb));

test t0;

always #5 clk = ~clk;
	initial begin
	clk = 0;
	//if1.reset = 1;
		//#20;
	if1.reset = 0;
	t0 = new();	
	t0.e0.vif = if1;
	t0.run();

	#200;
	$finish;
	end

initial begin
	$shm_open("wave.shm");
	$shm_probe("ACTMF");
end

endmodule
