// Master BFM
// `define MASTER_0 $root.memsys_bfm_tb.tb.avf_memsys_inst_avs_bfm

// // Slave BFM
// //`define SLAVE $root.memsys_bfm_tb.tb.avf_memsys_inst_mxu_m0_bfm
// `define SLAVE $root.memsys_bfm_tb.tb.avf_memsys_inst_wait_avm_bfm

//`define MXU_PIPELINE          3
// ------------------------------------------------------------
// Interface defines
// ------------------------------------------------------------
`define ADDRESS_W 32
`define CONTEXT_W 8
`define DATA_W  64  //512
`define BURSTCOUNT_W 11
//`include "avalon_mm_pkg.sv"
import avalon_mm_pkg::*;

   // Transaction request types
   typedef enum int {      // public 
      REQ_READ    = 0,     // Read Request
      REQ_WRITE   = 1,     // Write Request
      REQ_IDLE    = 2      // Idle
   } Request_t;

   // Slave BFM wait state logic operates in one of three distinct modes
   typedef enum int {          
           WAIT_FIXED = 0,  // default: fixed wait cycles per burst cycle
                     WAIT_RANDOM = 1, // random  min =< wait cycles <= max
           WAIT_ADDRESSABLE = 2 // fixed wait cycles per command address
                     } SlaveWaitMode_t;

   // Avalon MM transaction response status
   typedef enum logic[1:0] {
      AV_OKAY           = 0,
      AV_RESERVED       = 1,
      AV_SLAVE_ERROR    = 2,
      AV_DECODE_ERROR   = 3
   } AvalonResponseStatus_t;
   
   function automatic string request_string(Request_t request);
      case(request) 
      REQ_READ: return("read");
      REQ_WRITE: return("write");
      REQ_IDLE: return("idle");
      default: return("INVALID_REQUEST");
      endcase 
   endfunction



// ------------------------------------------------------------
// Test Plan defines
// ------------------------------------------------------------
`define TRANSLATION               0
`define NUM_AFU                   4
`define MAX_BACKPRESSURE          2
`define MAX_LATENCY               2
`define NUM_TRANS                 256

// ------------------------------------------------------------
// Derrived params
// ------------------------------------------------------------
// `define MAX_BURST ((2**`BURSTCOUNT_W)-1)
`define MAX_BURST 256
//`define MAX_ADDRESS ((2**`ADDRESS_W)-1)
`define MAX_ADDRESS 32'h1000
`define MAX_CTX 3
// `define MAX_CTX (2**(`CONTEXT_W)-1)
`define NUM_SYMBOLS (`DATA_W/8)


// structs

typedef struct {
   logic [(`ADDRESS_W + `CONTEXT_W)-1: 0] address;
   logic [`DATA_W-1:0] 		       data [`MAX_BURST-1:0];
   logic [`NUM_SYMBOLS-1:0] 		       byteenable [`MAX_BURST-1:0];
   logic [`BURSTCOUNT_W-1:0] 		       burstcount;
   Request_t                                   request;
} Command;

typedef struct {
   logic [`BURSTCOUNT_W-1:0] burstcount;
   logic [`DATA_W-1:0]   data [`MAX_BURST-1:0];
   int 			     latency [`MAX_BURST-1:0];
   Request_t                 request;
   AvalonResponseStatus_t    status [`MAX_BURST-1:0];
} Response;


// ------------------------------------------------------------
// Testing
// ------------------------------------------------------------

// status bit
bit success = 1;

// fail event
event assert_fail;

// scratch memory
logic [`DATA_W-1:0] memory [*];

//------------------------------------------------------------
// R/W command & response queues
//------------------------------------------------------------

// master commands

Command command_queue_master[$];

// slave commands
// Command write_command_queue_slave[$];
// Command read_command_queue_slave[$];

Command command_queue_slave[$];
// slave response
 Response response_queue_slave[$];


int in_flight_transactions;
Command cmd;
Response rsp;

//module memsys_test_plan();
   import verbosity_pkg::*;
   import avalon_mm_pkg::*;
   import avalon_utilities_pkg::*;
   
   // Slave BFM & memory control
   always @(`AVS.signal_command_received) begin
      automatic int backpressure;
      for(int idx = 0; idx < `MAX_BURST; idx = idx +1) begin
	 backpressure = $urandom_range(0,`MAX_BACKPRESSURE);
//	 `AVS.set_interface_wait_time(backpressure,idx);
      end
      // command processing
      cmd = get_command_from_slave();     
      // response handling
      rsp = memory_response(cmd);
      // response_queue_slave.push_back(rsp);
      configure_and_push_response_to_slave(rsp);
   end // always @ (`SLAVE.signal_command_received)

   // Pending read latency counter (for setting the response latency)
   int pending_read_latency = 0;
   always @(posedge `CLK.pClk) begin
      if(pending_read_latency > 0) begin
	 pending_read_latency--;
      end
   end

   // A basic test plan 
   event start;
   event setup_complete;
   
   initial begin
      in_flight_transactions = 0;
   // initialize
  //    set_verbosity(VERBOSITY_DEBUG);
      `AVS.init();
      `AVS.set_idle_state_output_configuration(LOW);
   end
      
   task automatic print_command(Command cmd);
      string req;
      string data;
      if(cmd.request == REQ_READ) req = "READ";
      else if(cmd.request == REQ_WRITE) req = "WRITE";
      if(cmd.request == REQ_WRITE) begin
	 data = "\{";
	 for(int idx=0; idx < cmd.burstcount; idx++) begin
	    if(idx > 0) $sformat(data,"%s%s",data,", ");
	    $sformat(data,"%s%0x",data,cmd.data[idx]);
	 end
	 $sformat(data,"%s%s",data,"\}");
      end
      $display("%t Printing Command: %s MEM[%0h] %s",$time,req,cmd.address,data);
   endtask // print_command
   
   // Slave command processing
   function automatic Command get_command_from_slave();
      Command cmd;
      int burst_cycle = 0, burst_count = 0;

      `AVS.pop_command();
      burst_cycle = `AVS.get_command_burst_cycle();
      cmd.burstcount = `AVS.get_command_burst_count();
      cmd.address    = `AVS.get_command_address();

      if(`AVS.get_command_request() == REQ_WRITE) begin
	 cmd.request = REQ_WRITE;
         burst_count = cmd.burstcount;
	 for(int idx=0; idx < burst_count; idx++) begin
	    cmd.data[idx] = `AVS.get_command_data(idx);
	    cmd.byteenable[idx] = `AVS.get_command_byte_enable(idx);
	 end
      end else begin
	 cmd.request = REQ_READ;
      end
      return cmd;
   endfunction // get_command_from_slave

   // Response issuing
   function automatic Response memory_response (Command cmd);
      Response rsp;
      // if write, drive memory, no response on EMIF
      if(cmd.request == REQ_WRITE) begin
	 for(int idx = 0; idx < cmd.burstcount; idx++) begin
	    memory[cmd.address+idx] = cmd.data[idx];
	 end
      end
      // respond
      print_command(cmd);
      rsp.request = cmd.request;
      rsp.burstcount = (cmd.request == REQ_READ) ? cmd.burstcount : 1;

      for(int idx = 0; idx < rsp.burstcount; idx++) begin
	 if(rsp.request == REQ_READ) begin
	    // drive with memory, otherwise assume init to -1
	    rsp.data[idx] =  memory.exists(cmd.address+idx) ? memory[cmd.address+idx] : `DATA_W'hdeadbeef;
	    rsp.latency[idx] = $urandom_range(0,`MAX_LATENCY); // set a random memory response latency
	    rsp.status[idx] = AV_OKAY; // we can test this more in the future
	 end
      end
      return rsp;
   endfunction // memory_response

   task automatic configure_and_push_response_to_slave (Response rsp);
      if(rsp.request == REQ_READ) begin
      int read_response_latency;
      string msg; 
  //    `AVS.set_response_request(rsp.request);
      `AVS.set_response_burst_size(rsp.burstcount);
   //   if(rsp.request == REQ_WRITE) begin
	// `AVS.set_write_response_status(AV_OKAY);
   //   end
      for(int idx = 0; idx < rsp.burstcount; idx++) begin
	 if(rsp.request == REQ_READ) begin
	    `AVS.set_response_data(rsp.data[idx],idx);
//	    `AVS.set_read_response_status(rsp.status[idx],idx);
	    `AVS.set_response_latency((idx==0) ? rsp.latency[0] + pending_read_latency : rsp.latency[idx],idx);
	    read_response_latency = read_response_latency + rsp.latency[idx];
	 end
      end
      `AVS.push_response();
      pending_read_latency = pending_read_latency + read_response_latency + rsp.burstcount + 2; // why 2? - also added the latency here
      if(rsp.request == REQ_READ) 
	$sformat(msg, "Rsp READ:  burst(%0d)",rsp.burstcount); 
      else if(rsp.request == REQ_WRITE) 
	$sformat(msg, "EMIF does not support posted WRITE"); 
      print(VERBOSITY_INFO,msg); 
      end
   endtask // configure_and_push_response_to_slave
   
//endmodule // tp
