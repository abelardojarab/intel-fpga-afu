module address_decode (
		input  wire        clk_csr_clk,                                                 //                                         clk_csr.clk
		input  wire        csr_reset_n,                                                 //                                             csr.reset_n
		output wire [11:0] eth_gen_mon_0_avalon_anti_slave_0_address,                   //               eth_gen_mon_0_avalon_anti_slave_0.address
		output wire        eth_gen_mon_0_avalon_anti_slave_0_write,                     //                                                .write
		output wire        eth_gen_mon_0_avalon_anti_slave_0_read,                      //                                                .read
		input  wire [31:0] eth_gen_mon_0_avalon_anti_slave_0_readdata,                  //                                                .readdata
		output wire [31:0] eth_gen_mon_0_avalon_anti_slave_0_writedata,                 //                                                .writedata
		input  wire        eth_gen_mon_0_avalon_anti_slave_0_waitrequest,               //                                                .waitrequest
		output wire [11:0] eth_gen_mon_1_avalon_anti_slave_0_address,                   //               eth_gen_mon_1_avalon_anti_slave_0.address
		output wire        eth_gen_mon_1_avalon_anti_slave_0_write,                     //                                                .write
		output wire        eth_gen_mon_1_avalon_anti_slave_0_read,                      //                                                .read
		input  wire [31:0] eth_gen_mon_1_avalon_anti_slave_0_readdata,                  //                                                .readdata
		output wire [31:0] eth_gen_mon_1_avalon_anti_slave_0_writedata,                 //                                                .writedata
		input  wire        eth_gen_mon_1_avalon_anti_slave_0_waitrequest,               //                                                .waitrequest
		output wire [11:0] eth_gen_mon_10_avalon_anti_slave_0_address,                  //              eth_gen_mon_10_avalon_anti_slave_0.address
		output wire        eth_gen_mon_10_avalon_anti_slave_0_write,                    //                                                .write
		output wire        eth_gen_mon_10_avalon_anti_slave_0_read,                     //                                                .read
		input  wire [31:0] eth_gen_mon_10_avalon_anti_slave_0_readdata,                 //                                                .readdata
		output wire [31:0] eth_gen_mon_10_avalon_anti_slave_0_writedata,                //                                                .writedata
		input  wire        eth_gen_mon_10_avalon_anti_slave_0_waitrequest,              //                                                .waitrequest
		output wire [11:0] eth_gen_mon_11_avalon_anti_slave_0_address,                  //              eth_gen_mon_11_avalon_anti_slave_0.address
		output wire        eth_gen_mon_11_avalon_anti_slave_0_write,                    //                                                .write
		output wire        eth_gen_mon_11_avalon_anti_slave_0_read,                     //                                                .read
		input  wire [31:0] eth_gen_mon_11_avalon_anti_slave_0_readdata,                 //                                                .readdata
		output wire [31:0] eth_gen_mon_11_avalon_anti_slave_0_writedata,                //                                                .writedata
		input  wire        eth_gen_mon_11_avalon_anti_slave_0_waitrequest,              //                                                .waitrequest
		output wire [11:0] eth_gen_mon_2_avalon_anti_slave_0_address,                   //               eth_gen_mon_2_avalon_anti_slave_0.address
		output wire        eth_gen_mon_2_avalon_anti_slave_0_write,                     //                                                .write
		output wire        eth_gen_mon_2_avalon_anti_slave_0_read,                      //                                                .read
		input  wire [31:0] eth_gen_mon_2_avalon_anti_slave_0_readdata,                  //                                                .readdata
		output wire [31:0] eth_gen_mon_2_avalon_anti_slave_0_writedata,                 //                                                .writedata
		input  wire        eth_gen_mon_2_avalon_anti_slave_0_waitrequest,               //                                                .waitrequest
		output wire [11:0] eth_gen_mon_3_avalon_anti_slave_0_address,                   //               eth_gen_mon_3_avalon_anti_slave_0.address
		output wire        eth_gen_mon_3_avalon_anti_slave_0_write,                     //                                                .write
		output wire        eth_gen_mon_3_avalon_anti_slave_0_read,                      //                                                .read
		input  wire [31:0] eth_gen_mon_3_avalon_anti_slave_0_readdata,                  //                                                .readdata
		output wire [31:0] eth_gen_mon_3_avalon_anti_slave_0_writedata,                 //                                                .writedata
		input  wire        eth_gen_mon_3_avalon_anti_slave_0_waitrequest,               //                                                .waitrequest
		output wire [11:0] eth_gen_mon_4_avalon_anti_slave_0_address,                   //               eth_gen_mon_4_avalon_anti_slave_0.address
		output wire        eth_gen_mon_4_avalon_anti_slave_0_write,                     //                                                .write
		output wire        eth_gen_mon_4_avalon_anti_slave_0_read,                      //                                                .read
		input  wire [31:0] eth_gen_mon_4_avalon_anti_slave_0_readdata,                  //                                                .readdata
		output wire [31:0] eth_gen_mon_4_avalon_anti_slave_0_writedata,                 //                                                .writedata
		input  wire        eth_gen_mon_4_avalon_anti_slave_0_waitrequest,               //                                                .waitrequest
		output wire [11:0] eth_gen_mon_5_avalon_anti_slave_0_address,                   //               eth_gen_mon_5_avalon_anti_slave_0.address
		output wire        eth_gen_mon_5_avalon_anti_slave_0_write,                     //                                                .write
		output wire        eth_gen_mon_5_avalon_anti_slave_0_read,                      //                                                .read
		input  wire [31:0] eth_gen_mon_5_avalon_anti_slave_0_readdata,                  //                                                .readdata
		output wire [31:0] eth_gen_mon_5_avalon_anti_slave_0_writedata,                 //                                                .writedata
		input  wire        eth_gen_mon_5_avalon_anti_slave_0_waitrequest,               //                                                .waitrequest
		output wire [11:0] eth_gen_mon_6_avalon_anti_slave_0_address,                   //               eth_gen_mon_6_avalon_anti_slave_0.address
		output wire        eth_gen_mon_6_avalon_anti_slave_0_write,                     //                                                .write
		output wire        eth_gen_mon_6_avalon_anti_slave_0_read,                      //                                                .read
		input  wire [31:0] eth_gen_mon_6_avalon_anti_slave_0_readdata,                  //                                                .readdata
		output wire [31:0] eth_gen_mon_6_avalon_anti_slave_0_writedata,                 //                                                .writedata
		input  wire        eth_gen_mon_6_avalon_anti_slave_0_waitrequest,               //                                                .waitrequest
		output wire [11:0] eth_gen_mon_7_avalon_anti_slave_0_address,                   //               eth_gen_mon_7_avalon_anti_slave_0.address
		output wire        eth_gen_mon_7_avalon_anti_slave_0_write,                     //                                                .write
		output wire        eth_gen_mon_7_avalon_anti_slave_0_read,                      //                                                .read
		input  wire [31:0] eth_gen_mon_7_avalon_anti_slave_0_readdata,                  //                                                .readdata
		output wire [31:0] eth_gen_mon_7_avalon_anti_slave_0_writedata,                 //                                                .writedata
		input  wire        eth_gen_mon_7_avalon_anti_slave_0_waitrequest,               //                                                .waitrequest
		output wire [11:0] eth_gen_mon_8_avalon_anti_slave_0_address,                   //               eth_gen_mon_8_avalon_anti_slave_0.address
		output wire        eth_gen_mon_8_avalon_anti_slave_0_write,                     //                                                .write
		output wire        eth_gen_mon_8_avalon_anti_slave_0_read,                      //                                                .read
		input  wire [31:0] eth_gen_mon_8_avalon_anti_slave_0_readdata,                  //                                                .readdata
		output wire [31:0] eth_gen_mon_8_avalon_anti_slave_0_writedata,                 //                                                .writedata
		input  wire        eth_gen_mon_8_avalon_anti_slave_0_waitrequest,               //                                                .waitrequest
		output wire [11:0] eth_gen_mon_9_avalon_anti_slave_0_address,                   //               eth_gen_mon_9_avalon_anti_slave_0.address
		output wire        eth_gen_mon_9_avalon_anti_slave_0_write,                     //                                                .write
		output wire        eth_gen_mon_9_avalon_anti_slave_0_read,                      //                                                .read
		input  wire [31:0] eth_gen_mon_9_avalon_anti_slave_0_readdata,                  //                                                .readdata
		output wire [31:0] eth_gen_mon_9_avalon_anti_slave_0_writedata,                 //                                                .writedata
		input  wire        eth_gen_mon_9_avalon_anti_slave_0_waitrequest,               //                                                .waitrequest
		input  wire [15:0] merlin_master_translator_0_avalon_anti_master_0_address,     // merlin_master_translator_0_avalon_anti_master_0.address
		output wire        merlin_master_translator_0_avalon_anti_master_0_waitrequest, //                                                .waitrequest
		input  wire        merlin_master_translator_0_avalon_anti_master_0_read,        //                                                .read
		output wire [31:0] merlin_master_translator_0_avalon_anti_master_0_readdata,    //                                                .readdata
		input  wire        merlin_master_translator_0_avalon_anti_master_0_write,       //                                                .write
		input  wire [31:0] merlin_master_translator_0_avalon_anti_master_0_writedata,   //                                                .writedata
		output wire [12:0] mac_0_avalon_anti_slave_0_address,                           //                       mac_0_avalon_anti_slave_0.address
		output wire        mac_0_avalon_anti_slave_0_write,                             //                                                .write
		output wire        mac_0_avalon_anti_slave_0_read,                              //                                                .read
		input  wire [31:0] mac_0_avalon_anti_slave_0_readdata,                          //                                                .readdata
		output wire [31:0] mac_0_avalon_anti_slave_0_writedata,                         //                                                .writedata
		input  wire        mac_0_avalon_anti_slave_0_waitrequest,                       //                                                .waitrequest
		output wire [12:0] mac_1_avalon_anti_slave_0_address,                           //                       mac_1_avalon_anti_slave_0.address
		output wire        mac_1_avalon_anti_slave_0_write,                             //                                                .write
		output wire        mac_1_avalon_anti_slave_0_read,                              //                                                .read
		input  wire [31:0] mac_1_avalon_anti_slave_0_readdata,                          //                                                .readdata
		output wire [31:0] mac_1_avalon_anti_slave_0_writedata,                         //                                                .writedata
		input  wire        mac_1_avalon_anti_slave_0_waitrequest,                       //                                                .waitrequest
		output wire [12:0] mac_10_avalon_anti_slave_0_address,                          //                      mac_10_avalon_anti_slave_0.address
		output wire        mac_10_avalon_anti_slave_0_write,                            //                                                .write
		output wire        mac_10_avalon_anti_slave_0_read,                             //                                                .read
		input  wire [31:0] mac_10_avalon_anti_slave_0_readdata,                         //                                                .readdata
		output wire [31:0] mac_10_avalon_anti_slave_0_writedata,                        //                                                .writedata
		input  wire        mac_10_avalon_anti_slave_0_waitrequest,                      //                                                .waitrequest
		output wire [12:0] mac_11_avalon_anti_slave_0_address,                          //                      mac_11_avalon_anti_slave_0.address
		output wire        mac_11_avalon_anti_slave_0_write,                            //                                                .write
		output wire        mac_11_avalon_anti_slave_0_read,                             //                                                .read
		input  wire [31:0] mac_11_avalon_anti_slave_0_readdata,                         //                                                .readdata
		output wire [31:0] mac_11_avalon_anti_slave_0_writedata,                        //                                                .writedata
		input  wire        mac_11_avalon_anti_slave_0_waitrequest,                      //                                                .waitrequest
		output wire [12:0] mac_2_avalon_anti_slave_0_address,                           //                       mac_2_avalon_anti_slave_0.address
		output wire        mac_2_avalon_anti_slave_0_write,                             //                                                .write
		output wire        mac_2_avalon_anti_slave_0_read,                              //                                                .read
		input  wire [31:0] mac_2_avalon_anti_slave_0_readdata,                          //                                                .readdata
		output wire [31:0] mac_2_avalon_anti_slave_0_writedata,                         //                                                .writedata
		input  wire        mac_2_avalon_anti_slave_0_waitrequest,                       //                                                .waitrequest
		output wire [12:0] mac_3_avalon_anti_slave_0_address,                           //                       mac_3_avalon_anti_slave_0.address
		output wire        mac_3_avalon_anti_slave_0_write,                             //                                                .write
		output wire        mac_3_avalon_anti_slave_0_read,                              //                                                .read
		input  wire [31:0] mac_3_avalon_anti_slave_0_readdata,                          //                                                .readdata
		output wire [31:0] mac_3_avalon_anti_slave_0_writedata,                         //                                                .writedata
		input  wire        mac_3_avalon_anti_slave_0_waitrequest,                       //                                                .waitrequest
		output wire [12:0] mac_4_avalon_anti_slave_0_address,                           //                       mac_4_avalon_anti_slave_0.address
		output wire        mac_4_avalon_anti_slave_0_write,                             //                                                .write
		output wire        mac_4_avalon_anti_slave_0_read,                              //                                                .read
		input  wire [31:0] mac_4_avalon_anti_slave_0_readdata,                          //                                                .readdata
		output wire [31:0] mac_4_avalon_anti_slave_0_writedata,                         //                                                .writedata
		input  wire        mac_4_avalon_anti_slave_0_waitrequest,                       //                                                .waitrequest
		output wire [12:0] mac_5_avalon_anti_slave_0_address,                           //                       mac_5_avalon_anti_slave_0.address
		output wire        mac_5_avalon_anti_slave_0_write,                             //                                                .write
		output wire        mac_5_avalon_anti_slave_0_read,                              //                                                .read
		input  wire [31:0] mac_5_avalon_anti_slave_0_readdata,                          //                                                .readdata
		output wire [31:0] mac_5_avalon_anti_slave_0_writedata,                         //                                                .writedata
		input  wire        mac_5_avalon_anti_slave_0_waitrequest,                       //                                                .waitrequest
		output wire [12:0] mac_6_avalon_anti_slave_0_address,                           //                       mac_6_avalon_anti_slave_0.address
		output wire        mac_6_avalon_anti_slave_0_write,                             //                                                .write
		output wire        mac_6_avalon_anti_slave_0_read,                              //                                                .read
		input  wire [31:0] mac_6_avalon_anti_slave_0_readdata,                          //                                                .readdata
		output wire [31:0] mac_6_avalon_anti_slave_0_writedata,                         //                                                .writedata
		input  wire        mac_6_avalon_anti_slave_0_waitrequest,                       //                                                .waitrequest
		output wire [12:0] mac_7_avalon_anti_slave_0_address,                           //                       mac_7_avalon_anti_slave_0.address
		output wire        mac_7_avalon_anti_slave_0_write,                             //                                                .write
		output wire        mac_7_avalon_anti_slave_0_read,                              //                                                .read
		input  wire [31:0] mac_7_avalon_anti_slave_0_readdata,                          //                                                .readdata
		output wire [31:0] mac_7_avalon_anti_slave_0_writedata,                         //                                                .writedata
		input  wire        mac_7_avalon_anti_slave_0_waitrequest,                       //                                                .waitrequest
		output wire [12:0] mac_8_avalon_anti_slave_0_address,                           //                       mac_8_avalon_anti_slave_0.address
		output wire        mac_8_avalon_anti_slave_0_write,                             //                                                .write
		output wire        mac_8_avalon_anti_slave_0_read,                              //                                                .read
		input  wire [31:0] mac_8_avalon_anti_slave_0_readdata,                          //                                                .readdata
		output wire [31:0] mac_8_avalon_anti_slave_0_writedata,                         //                                                .writedata
		input  wire        mac_8_avalon_anti_slave_0_waitrequest,                       //                                                .waitrequest
		output wire [12:0] mac_9_avalon_anti_slave_0_address,                           //                       mac_9_avalon_anti_slave_0.address
		output wire        mac_9_avalon_anti_slave_0_write,                             //                                                .write
		output wire        mac_9_avalon_anti_slave_0_read,                              //                                                .read
		input  wire [31:0] mac_9_avalon_anti_slave_0_readdata,                          //                                                .readdata
		output wire [31:0] mac_9_avalon_anti_slave_0_writedata,                         //                                                .writedata
		input  wire        mac_9_avalon_anti_slave_0_waitrequest,                       //                                                .waitrequest
		output wire [10:0] phy_0_avalon_anti_slave_0_address,                           //                       phy_0_avalon_anti_slave_0.address
		output wire        phy_0_avalon_anti_slave_0_write,                             //                                                .write
		output wire        phy_0_avalon_anti_slave_0_read,                              //                                                .read
		input  wire [31:0] phy_0_avalon_anti_slave_0_readdata,                          //                                                .readdata
		output wire [31:0] phy_0_avalon_anti_slave_0_writedata,                         //                                                .writedata
		input  wire        phy_0_avalon_anti_slave_0_waitrequest,                       //                                                .waitrequest
		output wire [10:0] phy_1_avalon_anti_slave_0_address,                           //                       phy_1_avalon_anti_slave_0.address
		output wire        phy_1_avalon_anti_slave_0_write,                             //                                                .write
		output wire        phy_1_avalon_anti_slave_0_read,                              //                                                .read
		input  wire [31:0] phy_1_avalon_anti_slave_0_readdata,                          //                                                .readdata
		output wire [31:0] phy_1_avalon_anti_slave_0_writedata,                         //                                                .writedata
		input  wire        phy_1_avalon_anti_slave_0_waitrequest,                       //                                                .waitrequest
		output wire [10:0] phy_10_avalon_anti_slave_0_address,                          //                      phy_10_avalon_anti_slave_0.address
		output wire        phy_10_avalon_anti_slave_0_write,                            //                                                .write
		output wire        phy_10_avalon_anti_slave_0_read,                             //                                                .read
		input  wire [31:0] phy_10_avalon_anti_slave_0_readdata,                         //                                                .readdata
		output wire [31:0] phy_10_avalon_anti_slave_0_writedata,                        //                                                .writedata
		input  wire        phy_10_avalon_anti_slave_0_waitrequest,                      //                                                .waitrequest
		output wire [10:0] phy_11_avalon_anti_slave_0_address,                          //                      phy_11_avalon_anti_slave_0.address
		output wire        phy_11_avalon_anti_slave_0_write,                            //                                                .write
		output wire        phy_11_avalon_anti_slave_0_read,                             //                                                .read
		input  wire [31:0] phy_11_avalon_anti_slave_0_readdata,                         //                                                .readdata
		output wire [31:0] phy_11_avalon_anti_slave_0_writedata,                        //                                                .writedata
		input  wire        phy_11_avalon_anti_slave_0_waitrequest,                      //                                                .waitrequest
		output wire [10:0] phy_2_avalon_anti_slave_0_address,                           //                       phy_2_avalon_anti_slave_0.address
		output wire        phy_2_avalon_anti_slave_0_write,                             //                                                .write
		output wire        phy_2_avalon_anti_slave_0_read,                              //                                                .read
		input  wire [31:0] phy_2_avalon_anti_slave_0_readdata,                          //                                                .readdata
		output wire [31:0] phy_2_avalon_anti_slave_0_writedata,                         //                                                .writedata
		input  wire        phy_2_avalon_anti_slave_0_waitrequest,                       //                                                .waitrequest
		output wire [10:0] phy_3_avalon_anti_slave_0_address,                           //                       phy_3_avalon_anti_slave_0.address
		output wire        phy_3_avalon_anti_slave_0_write,                             //                                                .write
		output wire        phy_3_avalon_anti_slave_0_read,                              //                                                .read
		input  wire [31:0] phy_3_avalon_anti_slave_0_readdata,                          //                                                .readdata
		output wire [31:0] phy_3_avalon_anti_slave_0_writedata,                         //                                                .writedata
		input  wire        phy_3_avalon_anti_slave_0_waitrequest,                       //                                                .waitrequest
		output wire [10:0] phy_4_avalon_anti_slave_0_address,                           //                       phy_4_avalon_anti_slave_0.address
		output wire        phy_4_avalon_anti_slave_0_write,                             //                                                .write
		output wire        phy_4_avalon_anti_slave_0_read,                              //                                                .read
		input  wire [31:0] phy_4_avalon_anti_slave_0_readdata,                          //                                                .readdata
		output wire [31:0] phy_4_avalon_anti_slave_0_writedata,                         //                                                .writedata
		input  wire        phy_4_avalon_anti_slave_0_waitrequest,                       //                                                .waitrequest
		output wire [10:0] phy_5_avalon_anti_slave_0_address,                           //                       phy_5_avalon_anti_slave_0.address
		output wire        phy_5_avalon_anti_slave_0_write,                             //                                                .write
		output wire        phy_5_avalon_anti_slave_0_read,                              //                                                .read
		input  wire [31:0] phy_5_avalon_anti_slave_0_readdata,                          //                                                .readdata
		output wire [31:0] phy_5_avalon_anti_slave_0_writedata,                         //                                                .writedata
		input  wire        phy_5_avalon_anti_slave_0_waitrequest,                       //                                                .waitrequest
		output wire [10:0] phy_6_avalon_anti_slave_0_address,                           //                       phy_6_avalon_anti_slave_0.address
		output wire        phy_6_avalon_anti_slave_0_write,                             //                                                .write
		output wire        phy_6_avalon_anti_slave_0_read,                              //                                                .read
		input  wire [31:0] phy_6_avalon_anti_slave_0_readdata,                          //                                                .readdata
		output wire [31:0] phy_6_avalon_anti_slave_0_writedata,                         //                                                .writedata
		input  wire        phy_6_avalon_anti_slave_0_waitrequest,                       //                                                .waitrequest
		output wire [10:0] phy_7_avalon_anti_slave_0_address,                           //                       phy_7_avalon_anti_slave_0.address
		output wire        phy_7_avalon_anti_slave_0_write,                             //                                                .write
		output wire        phy_7_avalon_anti_slave_0_read,                              //                                                .read
		input  wire [31:0] phy_7_avalon_anti_slave_0_readdata,                          //                                                .readdata
		output wire [31:0] phy_7_avalon_anti_slave_0_writedata,                         //                                                .writedata
		input  wire        phy_7_avalon_anti_slave_0_waitrequest,                       //                                                .waitrequest
		output wire [10:0] phy_8_avalon_anti_slave_0_address,                           //                       phy_8_avalon_anti_slave_0.address
		output wire        phy_8_avalon_anti_slave_0_write,                             //                                                .write
		output wire        phy_8_avalon_anti_slave_0_read,                              //                                                .read
		input  wire [31:0] phy_8_avalon_anti_slave_0_readdata,                          //                                                .readdata
		output wire [31:0] phy_8_avalon_anti_slave_0_writedata,                         //                                                .writedata
		input  wire        phy_8_avalon_anti_slave_0_waitrequest,                       //                                                .waitrequest
		output wire [10:0] phy_9_avalon_anti_slave_0_address,                           //                       phy_9_avalon_anti_slave_0.address
		output wire        phy_9_avalon_anti_slave_0_write,                             //                                                .write
		output wire        phy_9_avalon_anti_slave_0_read,                              //                                                .read
		input  wire [31:0] phy_9_avalon_anti_slave_0_readdata,                          //                                                .readdata
		output wire [31:0] phy_9_avalon_anti_slave_0_writedata,                         //                                                .writedata
		input  wire        phy_9_avalon_anti_slave_0_waitrequest,                       //                                                .waitrequest
		output wire [2:0]  rx_sc_fifo_0_avalon_anti_slave_0_address,                    //                rx_sc_fifo_0_avalon_anti_slave_0.address
		output wire        rx_sc_fifo_0_avalon_anti_slave_0_write,                      //                                                .write
		output wire        rx_sc_fifo_0_avalon_anti_slave_0_read,                       //                                                .read
		input  wire [31:0] rx_sc_fifo_0_avalon_anti_slave_0_readdata,                   //                                                .readdata
		output wire [31:0] rx_sc_fifo_0_avalon_anti_slave_0_writedata,                  //                                                .writedata
		output wire [2:0]  rx_sc_fifo_1_avalon_anti_slave_0_address,                    //                rx_sc_fifo_1_avalon_anti_slave_0.address
		output wire        rx_sc_fifo_1_avalon_anti_slave_0_write,                      //                                                .write
		output wire        rx_sc_fifo_1_avalon_anti_slave_0_read,                       //                                                .read
		input  wire [31:0] rx_sc_fifo_1_avalon_anti_slave_0_readdata,                   //                                                .readdata
		output wire [31:0] rx_sc_fifo_1_avalon_anti_slave_0_writedata,                  //                                                .writedata
		output wire [2:0]  rx_sc_fifo_10_avalon_anti_slave_0_address,                   //               rx_sc_fifo_10_avalon_anti_slave_0.address
		output wire        rx_sc_fifo_10_avalon_anti_slave_0_write,                     //                                                .write
		output wire        rx_sc_fifo_10_avalon_anti_slave_0_read,                      //                                                .read
		input  wire [31:0] rx_sc_fifo_10_avalon_anti_slave_0_readdata,                  //                                                .readdata
		output wire [31:0] rx_sc_fifo_10_avalon_anti_slave_0_writedata,                 //                                                .writedata
		output wire [2:0]  rx_sc_fifo_11_avalon_anti_slave_0_address,                   //               rx_sc_fifo_11_avalon_anti_slave_0.address
		output wire        rx_sc_fifo_11_avalon_anti_slave_0_write,                     //                                                .write
		output wire        rx_sc_fifo_11_avalon_anti_slave_0_read,                      //                                                .read
		input  wire [31:0] rx_sc_fifo_11_avalon_anti_slave_0_readdata,                  //                                                .readdata
		output wire [31:0] rx_sc_fifo_11_avalon_anti_slave_0_writedata,                 //                                                .writedata
		output wire [2:0]  rx_sc_fifo_2_avalon_anti_slave_0_address,                    //                rx_sc_fifo_2_avalon_anti_slave_0.address
		output wire        rx_sc_fifo_2_avalon_anti_slave_0_write,                      //                                                .write
		output wire        rx_sc_fifo_2_avalon_anti_slave_0_read,                       //                                                .read
		input  wire [31:0] rx_sc_fifo_2_avalon_anti_slave_0_readdata,                   //                                                .readdata
		output wire [31:0] rx_sc_fifo_2_avalon_anti_slave_0_writedata,                  //                                                .writedata
		output wire [2:0]  rx_sc_fifo_3_avalon_anti_slave_0_address,                    //                rx_sc_fifo_3_avalon_anti_slave_0.address
		output wire        rx_sc_fifo_3_avalon_anti_slave_0_write,                      //                                                .write
		output wire        rx_sc_fifo_3_avalon_anti_slave_0_read,                       //                                                .read
		input  wire [31:0] rx_sc_fifo_3_avalon_anti_slave_0_readdata,                   //                                                .readdata
		output wire [31:0] rx_sc_fifo_3_avalon_anti_slave_0_writedata,                  //                                                .writedata
		output wire [2:0]  rx_sc_fifo_4_avalon_anti_slave_0_address,                    //                rx_sc_fifo_4_avalon_anti_slave_0.address
		output wire        rx_sc_fifo_4_avalon_anti_slave_0_write,                      //                                                .write
		output wire        rx_sc_fifo_4_avalon_anti_slave_0_read,                       //                                                .read
		input  wire [31:0] rx_sc_fifo_4_avalon_anti_slave_0_readdata,                   //                                                .readdata
		output wire [31:0] rx_sc_fifo_4_avalon_anti_slave_0_writedata,                  //                                                .writedata
		output wire [2:0]  rx_sc_fifo_5_avalon_anti_slave_0_address,                    //                rx_sc_fifo_5_avalon_anti_slave_0.address
		output wire        rx_sc_fifo_5_avalon_anti_slave_0_write,                      //                                                .write
		output wire        rx_sc_fifo_5_avalon_anti_slave_0_read,                       //                                                .read
		input  wire [31:0] rx_sc_fifo_5_avalon_anti_slave_0_readdata,                   //                                                .readdata
		output wire [31:0] rx_sc_fifo_5_avalon_anti_slave_0_writedata,                  //                                                .writedata
		output wire [2:0]  rx_sc_fifo_6_avalon_anti_slave_0_address,                    //                rx_sc_fifo_6_avalon_anti_slave_0.address
		output wire        rx_sc_fifo_6_avalon_anti_slave_0_write,                      //                                                .write
		output wire        rx_sc_fifo_6_avalon_anti_slave_0_read,                       //                                                .read
		input  wire [31:0] rx_sc_fifo_6_avalon_anti_slave_0_readdata,                   //                                                .readdata
		output wire [31:0] rx_sc_fifo_6_avalon_anti_slave_0_writedata,                  //                                                .writedata
		output wire [2:0]  rx_sc_fifo_7_avalon_anti_slave_0_address,                    //                rx_sc_fifo_7_avalon_anti_slave_0.address
		output wire        rx_sc_fifo_7_avalon_anti_slave_0_write,                      //                                                .write
		output wire        rx_sc_fifo_7_avalon_anti_slave_0_read,                       //                                                .read
		input  wire [31:0] rx_sc_fifo_7_avalon_anti_slave_0_readdata,                   //                                                .readdata
		output wire [31:0] rx_sc_fifo_7_avalon_anti_slave_0_writedata,                  //                                                .writedata
		output wire [2:0]  rx_sc_fifo_8_avalon_anti_slave_0_address,                    //                rx_sc_fifo_8_avalon_anti_slave_0.address
		output wire        rx_sc_fifo_8_avalon_anti_slave_0_write,                      //                                                .write
		output wire        rx_sc_fifo_8_avalon_anti_slave_0_read,                       //                                                .read
		input  wire [31:0] rx_sc_fifo_8_avalon_anti_slave_0_readdata,                   //                                                .readdata
		output wire [31:0] rx_sc_fifo_8_avalon_anti_slave_0_writedata,                  //                                                .writedata
		output wire [2:0]  rx_sc_fifo_9_avalon_anti_slave_0_address,                    //                rx_sc_fifo_9_avalon_anti_slave_0.address
		output wire        rx_sc_fifo_9_avalon_anti_slave_0_write,                      //                                                .write
		output wire        rx_sc_fifo_9_avalon_anti_slave_0_read,                       //                                                .read
		input  wire [31:0] rx_sc_fifo_9_avalon_anti_slave_0_readdata,                   //                                                .readdata
		output wire [31:0] rx_sc_fifo_9_avalon_anti_slave_0_writedata,                  //                                                .writedata
		input  wire        rx_xcvr_clk_clk,                                             //                                     rx_xcvr_clk.clk
		input  wire        sync_rx_rst_reset_n,                                         //                                     sync_rx_rst.reset_n
		output wire [2:0]  tx_sc_fifo_0_avalon_anti_slave_0_address,                    //                tx_sc_fifo_0_avalon_anti_slave_0.address
		output wire        tx_sc_fifo_0_avalon_anti_slave_0_write,                      //                                                .write
		output wire        tx_sc_fifo_0_avalon_anti_slave_0_read,                       //                                                .read
		input  wire [31:0] tx_sc_fifo_0_avalon_anti_slave_0_readdata,                   //                                                .readdata
		output wire [31:0] tx_sc_fifo_0_avalon_anti_slave_0_writedata,                  //                                                .writedata
		output wire [2:0]  tx_sc_fifo_1_avalon_anti_slave_0_address,                    //                tx_sc_fifo_1_avalon_anti_slave_0.address
		output wire        tx_sc_fifo_1_avalon_anti_slave_0_write,                      //                                                .write
		output wire        tx_sc_fifo_1_avalon_anti_slave_0_read,                       //                                                .read
		input  wire [31:0] tx_sc_fifo_1_avalon_anti_slave_0_readdata,                   //                                                .readdata
		output wire [31:0] tx_sc_fifo_1_avalon_anti_slave_0_writedata,                  //                                                .writedata
		output wire [2:0]  tx_sc_fifo_10_avalon_anti_slave_0_address,                   //               tx_sc_fifo_10_avalon_anti_slave_0.address
		output wire        tx_sc_fifo_10_avalon_anti_slave_0_write,                     //                                                .write
		output wire        tx_sc_fifo_10_avalon_anti_slave_0_read,                      //                                                .read
		input  wire [31:0] tx_sc_fifo_10_avalon_anti_slave_0_readdata,                  //                                                .readdata
		output wire [31:0] tx_sc_fifo_10_avalon_anti_slave_0_writedata,                 //                                                .writedata
		output wire [2:0]  tx_sc_fifo_11_avalon_anti_slave_0_address,                   //               tx_sc_fifo_11_avalon_anti_slave_0.address
		output wire        tx_sc_fifo_11_avalon_anti_slave_0_write,                     //                                                .write
		output wire        tx_sc_fifo_11_avalon_anti_slave_0_read,                      //                                                .read
		input  wire [31:0] tx_sc_fifo_11_avalon_anti_slave_0_readdata,                  //                                                .readdata
		output wire [31:0] tx_sc_fifo_11_avalon_anti_slave_0_writedata,                 //                                                .writedata
		output wire [2:0]  tx_sc_fifo_2_avalon_anti_slave_0_address,                    //                tx_sc_fifo_2_avalon_anti_slave_0.address
		output wire        tx_sc_fifo_2_avalon_anti_slave_0_write,                      //                                                .write
		output wire        tx_sc_fifo_2_avalon_anti_slave_0_read,                       //                                                .read
		input  wire [31:0] tx_sc_fifo_2_avalon_anti_slave_0_readdata,                   //                                                .readdata
		output wire [31:0] tx_sc_fifo_2_avalon_anti_slave_0_writedata,                  //                                                .writedata
		output wire [2:0]  tx_sc_fifo_3_avalon_anti_slave_0_address,                    //                tx_sc_fifo_3_avalon_anti_slave_0.address
		output wire        tx_sc_fifo_3_avalon_anti_slave_0_write,                      //                                                .write
		output wire        tx_sc_fifo_3_avalon_anti_slave_0_read,                       //                                                .read
		input  wire [31:0] tx_sc_fifo_3_avalon_anti_slave_0_readdata,                   //                                                .readdata
		output wire [31:0] tx_sc_fifo_3_avalon_anti_slave_0_writedata,                  //                                                .writedata
		output wire [2:0]  tx_sc_fifo_4_avalon_anti_slave_0_address,                    //                tx_sc_fifo_4_avalon_anti_slave_0.address
		output wire        tx_sc_fifo_4_avalon_anti_slave_0_write,                      //                                                .write
		output wire        tx_sc_fifo_4_avalon_anti_slave_0_read,                       //                                                .read
		input  wire [31:0] tx_sc_fifo_4_avalon_anti_slave_0_readdata,                   //                                                .readdata
		output wire [31:0] tx_sc_fifo_4_avalon_anti_slave_0_writedata,                  //                                                .writedata
		output wire [2:0]  tx_sc_fifo_5_avalon_anti_slave_0_address,                    //                tx_sc_fifo_5_avalon_anti_slave_0.address
		output wire        tx_sc_fifo_5_avalon_anti_slave_0_write,                      //                                                .write
		output wire        tx_sc_fifo_5_avalon_anti_slave_0_read,                       //                                                .read
		input  wire [31:0] tx_sc_fifo_5_avalon_anti_slave_0_readdata,                   //                                                .readdata
		output wire [31:0] tx_sc_fifo_5_avalon_anti_slave_0_writedata,                  //                                                .writedata
		output wire [2:0]  tx_sc_fifo_6_avalon_anti_slave_0_address,                    //                tx_sc_fifo_6_avalon_anti_slave_0.address
		output wire        tx_sc_fifo_6_avalon_anti_slave_0_write,                      //                                                .write
		output wire        tx_sc_fifo_6_avalon_anti_slave_0_read,                       //                                                .read
		input  wire [31:0] tx_sc_fifo_6_avalon_anti_slave_0_readdata,                   //                                                .readdata
		output wire [31:0] tx_sc_fifo_6_avalon_anti_slave_0_writedata,                  //                                                .writedata
		output wire [2:0]  tx_sc_fifo_7_avalon_anti_slave_0_address,                    //                tx_sc_fifo_7_avalon_anti_slave_0.address
		output wire        tx_sc_fifo_7_avalon_anti_slave_0_write,                      //                                                .write
		output wire        tx_sc_fifo_7_avalon_anti_slave_0_read,                       //                                                .read
		input  wire [31:0] tx_sc_fifo_7_avalon_anti_slave_0_readdata,                   //                                                .readdata
		output wire [31:0] tx_sc_fifo_7_avalon_anti_slave_0_writedata,                  //                                                .writedata
		output wire [2:0]  tx_sc_fifo_8_avalon_anti_slave_0_address,                    //                tx_sc_fifo_8_avalon_anti_slave_0.address
		output wire        tx_sc_fifo_8_avalon_anti_slave_0_write,                      //                                                .write
		output wire        tx_sc_fifo_8_avalon_anti_slave_0_read,                       //                                                .read
		input  wire [31:0] tx_sc_fifo_8_avalon_anti_slave_0_readdata,                   //                                                .readdata
		output wire [31:0] tx_sc_fifo_8_avalon_anti_slave_0_writedata,                  //                                                .writedata
		output wire [2:0]  tx_sc_fifo_9_avalon_anti_slave_0_address,                    //                tx_sc_fifo_9_avalon_anti_slave_0.address
		output wire        tx_sc_fifo_9_avalon_anti_slave_0_write,                      //                                                .write
		output wire        tx_sc_fifo_9_avalon_anti_slave_0_read,                       //                                                .read
		input  wire [31:0] tx_sc_fifo_9_avalon_anti_slave_0_readdata,                   //                                                .readdata
		output wire [31:0] tx_sc_fifo_9_avalon_anti_slave_0_writedata,                  //                                                .writedata
		input  wire        tx_xcvr_clk_clk,                                             //                                     tx_xcvr_clk.clk
		input  wire        sync_tx_rst_reset_n,                                         //                                     sync_tx_rst.reset_n
		input  wire        tx_xcvr_half_clk_clk,                                        //                                tx_xcvr_half_clk.clk
		input  wire        sync_tx_half_rst_reset_n                                     //                                sync_tx_half_rst.reset_n
	);
endmodule

