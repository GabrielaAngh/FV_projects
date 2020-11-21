
/**
 * TODO: declare an interface ex_in_if that has 2 ports:
 * - input logic clk
 * - input logic rst_n
 * 
 * TODO: declare inside ex_in_if 2 signals:
 * - o_data : 8 bits, of type logic
 * - o_valid : 1 bit, of type logic
 * 
 * TODO: implement a task drive_data inside ex_in_if that:
 * - drives 5 random data on the bus, with [0..5] cc in between
 * - each data is driven on posedge of the clock
 * - when o_valid signal is asserted it indicates the data is valid
 * - for each of the 5 data the task prints its value
 * - after it finishes to send data, it waits for 3 cc and stops the simulation (use $stop) 
 * 
 */

interface ex_in_if(
	input logic clk,
	input logic rst_n);

	logic[7:0]	o_data;
	logic		o_valid;
	
	task drive_data();
		int x;
		
		repeat(5) begin		
			o_valid = 1;
			randomize(o_data);
			//$display("randomized data is %h",o_data);
			@(posedge clk);
			o_valid = 0;
			randomize(x) with { x inside { 0 , 5 };};	
			//$display("RRradomized cc are %d",x);
			repeat(x) @(posedge clk);
		end
		
		repeat(3) @(posedge clk);
		$stop();
	endtask
endinterface

/**
 * TODO: declare an interface ex_out_if that has 2 ports:
 * - input logic clk
 * - input logic rst_n
 * 
 * TODO: declare inside ex_in_if 2 signals:
 * - i_data : 8 bits, of type logic
 * - i_valid : 1 bit, of type logic
 * 
 * TODO: implement a function format_data that
 * - has one byte argument
 * - creates a string that prints the byte in hexadecimal format (e.g. "Data is 0xAB")
 * - returns the string
 * 
 * TODO: implement a task monitor_data inside ex_out_if that:
 * - it monitors continuously the i_data and i_valid signals
 * - it samples the i_data/i_valid signals on the posedge of the clock
 * - when i_valid signal is asserted it indicates the data is valid 
 * - prints the data on the screen using the format_data function 
 * 
**/

interface ex_out_if(
	input logic clk,
	input logic rst_n);
	
	logic[7:0] i_data;
	logic i_valid;
	
	function format_data(
		input byte argument);		
		$display("Data is 0x%h",argument);
	endfunction
	
	task monitor_data();
		while(1) begin
			@(posedge clk) begin
				if(i_valid)
					format_data(i_data);
			end
		end
	endtask
	
endinterface