/*******************************************************************************
Copyright (c) 2004-2017, AMIQ Consulting srl. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
******************************************************************************/


/**
 * TODO: define an unsized enumeration color_t that has the following items:
 * - RED, GREEN, BLUE, YELLOW, BROWN, ORANGE 
 * 
 * TODO: define a sized enumeration error_t on 2 bits that has the following items:
 * - NONE, INFO, WARNING, ERROR
 * 
 * TODO: declare a class "first_class"
 * - add 4 fields of type : color_t, byte, unsigned integer, 32x5-bit array 
 * - implement its constructor and initialize each element in the array to be equal to its index
 * - implement a function get_string() which returns a string similar to "My fields are: color=RED, byte=0x23, uint=14524535, array=[0x00, 0x1F, ....]"
 * - implement a function print_me() that displays the string returned by get_string()
 * - Implement a function compute_crc() that computes an 8bit crc by XOR-ing individual elements
 * 
 * TODO: declare a class "second_class" that inherits "first_class"
 * - declare an error_t field
 * - implement a constructor that calls the first_class constructor and then sets the error_t field to be INFO
 * - override the get_string() method to also include the error_t field 
 * 
 * TODO: declare a class called "run_container"
 * - declare a field of type first_class
 * - declare a field of type second_class
 * - initialize the two fields in the constructor
 * 
 * ----------------------------------------------------------------------------
 * Randomization, Constraints etc
 * 
 * TODO: declare the color_t, byte and the array fields of first_class as randomize-able
 * 
 * TODO: in the run_container play with the randomization: generate 100 items and print them.
 * Play with the following types of constraints: 
 * - constant value 
 * - values within a range
 * - values outside of a range
 * - conditional constraints
 * - iterating constraints
 * - order constraints
 * 
 */

typedef enum {RED, GREEN, BLUE, YELLOW, BROWN, ORANGE} color_t;
typedef enum bit [1:0] {NONE, INFO, WARNING, ERROR} error_t;

class first_class;
	rand color_t f_colors;
	rand byte f_byte;
	int unsigned f_uns_int;
	rand bit [31:0] f_array [4:0];
	
	function new( string name = "first_class");
		
		for(int i=0;i<5;i++) begin
			for(int j=0;j<32;j++)begin
				f_array[i][j] = {i,j};
			end			
		end
	endfunction
	
	//implement a function get_string() which returns a string similar to 
	//"My fields are: color=RED, byte=0x23, uint=14524535, array=[0x00, 0x1F, ....]"
	
	virtual function string get_string();
		string str1;		
		str1 =  {
			$sformatf("color = %d \n",f_colors),
			$sformatf("byte = %d \n",f_byte),
			$sformatf("unit = %s \n",f_uns_int),
			$sformatf("array = [%s] \n",f_array)
		};
		return str1;
	endfunction
	
	function void print_me();
		$display("My fields are: ",get_string());
	endfunction
	
	function bit [7:0] compute_crc();
		bit [7:0] crc;
		crc[0] = f_byte[0] ^ f_byte[1] ^ f_byte[2] ^ f_byte[3] ^ f_byte[4] ^ f_byte[5];
		crc[1] = f_byte[0] ^ f_byte[1] ^ f_byte[2] ^ f_byte[3] ^ f_byte[6] ^ f_byte[7];
		crc[2] = f_byte[0] ^ f_byte[1] ^ f_byte[2] ^ f_byte[3] ^ f_byte[4] ^ f_byte[6];
		crc[3] = f_byte[0] ^ f_byte[1] ^ f_byte[2] ^ f_byte[3] ^ f_byte[4] ^ f_byte[7];
		crc[4] = f_byte[0] ^ f_byte[1] ^ f_byte[2] ^ f_byte[3] ^ f_byte[6] ^ f_byte[5];
		crc[5] = f_byte[0] ^ f_byte[1] ^ f_byte[2] ^ f_byte[3] ^ f_byte[7] ^ f_byte[5];
		crc[6] = f_byte[0] ^ f_byte[1] ^ f_byte[2] ^ f_byte[3] ^ f_byte[4];
		crc[7] = f_byte[0] ^ f_byte[1] ^ f_byte[2] ^ f_byte[3] ^ f_byte[5];
		return crc;
	endfunction
	
endclass

class second_class extends first_class;
	error_t f_error;
		
	function new( string name = "second_class");
		super.new(name);
		//first_class.new();
		f_error = INFO;
	endfunction
	
	function string get_strimg();
		string str1 = super.get_string();
		string str2;		
		str2 =  { str1, $sformatf("error_t = %d \n",f_error) };
		return str2;
	endfunction
endclass

class run_container;
	first_class field_1;
	second_class field_2;
	
	constraint c1 { field_1.f_colors == RED; }
	constraint c2 { field_1.f_byte   inside {[10:20]};}
    constraint c3 { !(field_1.f_byte inside {[10:20]});}
    
	function new( string name = "run_container");
		//super.new(name);
		field_1 = new();
		field_2 = new();
	endfunction
	
	function void print_rand_stuff();
		repeat(100)	begin
			randomize(field_1);
			field_1.print_me();
			
			randomize(field_2);			
			field_2.print_me();
		end
	endfunction
	
endclass

