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

`ifndef __EX_SCOREBOARD
`define __EX_SCOREBOARD

class ex_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(ex_scoreboard)
	//analysis imports
	`uvm_analysis_imp_decl(_collected_item_in)
	uvm_analysis_imp_collected_item_in#(ex_in_cmd, ex_scoreboard) in_port;

	`uvm_analysis_imp_decl(_collected_item_out)
	uvm_analysis_imp_collected_item_out#(ex_out_serial_obj, ex_scoreboard) out_port;

	ex_in_cmd 			fifo_in[$];
	ex_out_serial_obj 	fifo_out[$];

	function new(string name, uvm_component parent);
		super.new(name, parent);
		in_port = new("in_port", this);
		out_port = new("out_port", this);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase

	virtual task run_phase(uvm_phase phase);
		process main;// Used by the reset handling mechanism
		super.run_phase(phase);
	endtask : run_phase

	virtual function void extract_phase(uvm_phase phase);
		//TODO: add stuff here
		super.extract_phase(phase);
		`uvm_info(get_type_name(), $sformatf("scoreboard in extract_phase"), UVM_MEDIUM);
		if(fifo_in.size() != 0 || fifo_out.size() != 0)
			`uvm_error(get_type_name(),$sformatf("[SCOREBOARD] FIFOS not empty"))

	endfunction : extract_phase

	function void write_collected_item_in(ex_in_cmd item_in);
		//TODO: add stuff here
		fifo_in.push_back(item_in);
		`uvm_info("scoreboard in write_collected_item_in",
					 { "\n", item_in.sprint() }, UVM_LOW);
	endfunction
	
	function void write_collected_item_out(ex_out_serial_obj item_out);
		//TODO: add stuff here
		uvm_table_printer p_out = new;
		fifo_out.push_back(item_out);
		`uvm_info("scoreboard in write_collected_item_OUTTTTTT",
					 { "\n", item_out.sprint(p_out) }, UVM_LOW);
		compare();
	endfunction
	
	virtual function void compare();
		ex_in_cmd 			fifo_in_elem;
		ex_out_serial_obj 	fifo_out_elem;
		
		if((fifo_in.size() != 0) && (fifo_out.size() != 0) ) begin
			fifo_in_elem = fifo_in.pop_front();
			fifo_out_elem = fifo_out.pop_front();
			
			if((fifo_in_elem.address != fifo_out_elem.address) || (fifo_in_elem.data != fifo_out_elem.data) || (fifo_in_elem.rnw != fifo_out_elem.rnw) 
				|| (fifo_out_elem.start_pattern != 4'b1010) || (fifo_out_elem.crc != fifo_out_elem.compute_crc()))
				`uvm_fatal(get_type_name(),$sformatf("[SCOREBOARD] FIFOS not equal"))
			else
				`uvm_info(get_type_name(), $sformatf("scoreboard OKAY. No missmatch."), UVM_MEDIUM);
		end
		else `uvm_fatal(get_type_name(),$sformatf("[SCOREBOARD] FIFO EMPTY"))
			
	endfunction

endclass : ex_scoreboard

`endif
