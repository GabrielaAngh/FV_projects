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

`ifndef __EX_OUT_MONITOR
`define __EX_OUT_MONITOR

//TODO: add ex_out_monitor here
class ex_out_monitor extends uvm_monitor;
	`uvm_component_utils(ex_out_monitor)

	protected virtual ex_out_intf out_vif;

	ex_out_serial_obj my_item;

	event new_serial_out_e;

	covergroup item_cg @(new_serial_out_e);
	//TODO: add coverpoints here
		 c1out: coverpoint my_item.address { bins b1a[4] = {[0:100]};
                        bins b2a[3] = {[101:199]};
                        bins b3a    = {[200:255]};
                        bins b4a = default;}
   		c2out: coverpoint  my_item.data { bins b1d[4] = {[0:100]};
                        bins b2d[3] = {[101:199]};
                        bins b3d    = {[200:255]};
                        bins b4d = default;}
   		c3out: coverpoint  my_item.rnw;
		cross c1out, c2out, c3out;
	endgroup

	uvm_analysis_port #(ex_out_serial_obj) collected_item_port;

	function new (string name, uvm_component parent);
		super.new(name, parent);
		collected_item_port = new("collected_item_port", this);
		item_cg=new();
		item_cg.set_inst_name({get_full_name(), ".item_addr_cg"});
		my_item = ex_out_serial_obj::type_id::create(.name("my_item"), .parent(this),.contxt(get_full_name()));
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual ex_out_intf)::get(this, "", "out_vif", out_vif))
			`uvm_fatal("NOVIF", {"virtual interface must be set for: ", get_full_name(), ".out_vif"})
	endfunction: build_phase

	virtual task run_phase(uvm_phase phase);
		process main_thread; // main thread
		process rst_mon_thread; // reset monitor thread
		@(negedge out_vif.rst_n);
		forever     // Start monitoring
		begin
			@(posedge out_vif.rst_n);
			fork

				begin                                           // Start the monitoring thread
					main_thread=process::self();
					forever
					begin
						
						monitor_bus();
						collected_item_port.write(my_item);
						->new_serial_out_e;
					end
				end//end thread actual monitoring thread

				begin                                       // Monitor the reset signal
					rst_mon_thread = process::self();
					@(negedge out_vif.rst_n)
					begin
						// Interrupt current item at reset
						if(main_thread)
						begin
							main_thread.kill();
						end//end if main thread exists
					end//end if received reset
				end//end thread monitor reset signal

			join_none
		end//end forever
	endtask : run_phase

	virtual protected task monitor_bus();
		//TODO: add stuff here
		//fills "my_item" with correct data. monitors one package

		logic [3:0] start_pattern;// = 4'b1010;
		int i = 3;
		int j = 7;

		while(out_vif.sdata == 0)
		begin
			//ASTEPT
			@(posedge out_vif.clk);
		end
		start_pattern[i]= out_vif.sdata;
		i--;
		repeat(3)
		begin
			@(posedge out_vif.clk);
			start_pattern[i] = out_vif.sdata;
			i--;
		end

		if(start_pattern == 4'b1010)
		begin
			my_item.start_pattern = start_pattern;
			@(posedge out_vif.clk);
			if(out_vif.sdata == 1)
				my_item.rnw = EX_READ;
			else
				my_item.rnw = EX_WRITE;

			repeat(8)
			begin
				@(posedge out_vif.clk);
				my_item.address[j] = out_vif.sdata;
				j--;
			end
			j = 7;
			repeat(8)
			begin
				@(posedge out_vif.clk);
				my_item.data[j] = out_vif.sdata;
				j--;
			end
			j = 3;
			repeat(4)
			begin
				@(posedge out_vif.clk);
				my_item.crc[j] = out_vif.sdata;
				j--;
			end
		end
		else
		begin
			my_item.start_pattern = start_pattern;
			my_item.rnw 	= EX_READ;
			my_item.address = 0;
			my_item.data 	= 0;
			my_item.crc 	= 0;
		end

		@(posedge out_vif.clk);

	endtask : monitor_bus

endclass : ex_out_monitor

`endif

