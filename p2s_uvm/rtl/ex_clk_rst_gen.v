/******************************************************************************
Copyright (c) 2004-2018, AMIQ Consulting srl. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
 *******************************************************************************/

`timescale 1ns / 1ps

// TODO: define the ex_clk_rst_gen module with 2 outputs:
// - clk  is the generated clock signal
// - rst_n is the negative logic reset signal (i.e. active low)
module ex_clk_rst_gen(
	output bit clk,
	output bit rst_n);

   // TODO: define the CLOCK_PERIOD parameter which determines the clock period
   parameter CLOCK_PERIOD = 10;
   // TODO: implement a clock generator
   initial begin
	   forever #CLOCK_PERIOD clk = ~clk;
   end
   	   
   // TODO: implement an initialization block for the reset&clock signals
   initial begin
	   clk = 0;
	   rst_n = 1;	   
   end
   
   // TODO: implement a task drive_reset() that drives the reset signal for 3cc
   task drive_reset();
	   rst_n = 0;
	   repeat(3) @(posedge clk);
	   rst_n = 1;
   endtask

endmodule






