module dspmem(rdwr_row, rdwr_col, wr_data, rd_data, en, wr,
              clk, pixclk,
              txtrow, txtcol, attcode, chrcode,
              chrrow_in, chrcol_in, blank_in,
              hsync_in, vsync_in, blink_in,
              chrrow_out, chrcol_out, blank_out,
              hsync_out, vsync_out, blink_out);
    input [4:0] rdwr_row;
    input [6:0] rdwr_col;
    input [15:0] wr_data;
    output [15:0] rd_data;
    input en;
    input wr;
    input clk;
    input pixclk;
    input [4:0] txtrow;
    input [6:0] txtcol;
    output [7:0] attcode;
    output [7:0] chrcode;
    input [3:0] chrrow_in;
    input [2:0] chrcol_in;
    input blank_in;
    input hsync_in;
    input vsync_in;
    input blink_in;
    output reg [3:0] chrrow_out;
    output reg [2:0] chrcol_out;
    output reg blank_out;
    output reg hsync_out;
    output reg vsync_out;
    output reg blink_out;

  wire [11:0] rdwr_addr;
  wire [3:0] rdwr_din_n3;
  wire [3:0] rdwr_din_n2;
  wire [3:0] rdwr_din_n1;
  wire [3:0] rdwr_din_n0;
  wire [3:0] rdwr_dout_n3;
  wire [3:0] rdwr_dout_n2;
  wire [3:0] rdwr_dout_n1;
  wire [3:0] rdwr_dout_n0;

  wire [11:0] rfsh_addr;
  wire [3:0] rfsh_din_n3;
  wire [3:0] rfsh_din_n2;
  wire [3:0] rfsh_din_n1;
  wire [3:0] rfsh_din_n0;
  wire [3:0] rfsh_dout_n3;
  wire [3:0] rfsh_dout_n2;
  wire [3:0] rfsh_dout_n1;
  wire [3:0] rfsh_dout_n0;

  assign rdwr_addr[11:7] = rdwr_row[4:0];
  assign rdwr_addr[6:0] = rdwr_col[6:0];
  assign rdwr_din_n3 = wr_data[15:12];
  assign rdwr_din_n2 = wr_data[11: 8];
  assign rdwr_din_n1 = wr_data[ 7: 4];
  assign rdwr_din_n0 = wr_data[ 3: 0];
  assign rd_data[15:12] = rdwr_dout_n3;
  assign rd_data[11: 8] = rdwr_dout_n2;
  assign rd_data[ 7: 4] = rdwr_dout_n1;
  assign rd_data[ 3: 0] = rdwr_dout_n0;

  assign rfsh_addr[11:7] = txtrow[4:0];
  assign rfsh_addr[6:0] = txtcol[6:0];
  assign rfsh_din_n3 = 4'b0000;
  assign rfsh_din_n2 = 4'b0000;
  assign rfsh_din_n1 = 4'b0000;
  assign rfsh_din_n0 = 4'b0000;
  assign attcode[7:4] = rfsh_dout_n3;
  assign attcode[3:0] = rfsh_dout_n2;
  assign chrcode[7:4] = rfsh_dout_n1;
  assign chrcode[3:0] = rfsh_dout_n0;

//--------------------------------------------------------------

   // RAMB16_S4_S4: Virtex-II/II-Pro, Spartan-3 4k x 4 Dual-Port RAM
   // Xilinx HDL Language Template version 6.3.1i

   RAMB16_S4_S4 display_att_hi (
      .DOA(rdwr_dout_n3),  // Port A 4-bit Data Output
      .DOB(rfsh_dout_n3),  // Port B 4-bit Data Output
      .ADDRA(rdwr_addr),   // Port A 12-bit Address Input
      .ADDRB(rfsh_addr),   // Port B 12-bit Address Input
      .CLKA(clk),          // Port A Clock
      .CLKB(clk),          // Port B Clock
      .DIA(rdwr_din_n3),   // Port A 4-bit Data Input
      .DIB(rfsh_din_n3),   // Port B 4-bit Data Input
      .ENA(en),            // Port A RAM Enable Input
      .ENB(pixclk),        // Port B RAM Enable Input
      .SSRA(1'b0),         // Port A Synchronous Set/Reset Input
      .SSRB(1'b0),         // Port B Synchronous Set/Reset Input
      .WEA(wr),            // Port A Write Enable Input
      .WEB(1'b0)           // Port B Write Enable Input
   );

   // The following defparam declarations are only necessary if you wish to change the default behavior
   // of the RAM. If the instance name is changed, these defparams need to be updated accordingly.

   defparam display_att_hi.INIT_A = 18'h0; // Value of output RAM registers on Port A at startup
   defparam display_att_hi.INIT_B = 18'h0; // Value of output RAM registers on Port B at startup
   defparam display_att_hi.SRVAL_A = 18'h0; // Port A ouput value upon SSR assertion
   defparam display_att_hi.SRVAL_B = 18'h0; // Port B ouput value upon SSR assertion
   defparam display_att_hi.WRITE_MODE_A = "WRITE_FIRST"; // WRITE_FIRST, READ_FIRST or NO_CHANGE
   defparam display_att_hi.WRITE_MODE_B = "WRITE_FIRST"; // WRITE_FIRST, READ_FIRST or NO_CHANGE

   // The following defparam INIT_xx declarations are only necessary if you wish to change the initial
   // contents of the RAM to anything other than all zero's.

   defparam display_att_hi.INIT_00 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_01 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_02 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_03 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_04 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_05 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_06 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_07 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_08 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_09 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_0A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_0B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_0C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_0D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_0E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_0F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_10 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_11 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_12 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_13 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_14 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_15 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_16 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_17 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_18 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_19 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_1A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_1B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_1C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_1D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_1E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_1F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_20 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_21 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_22 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_23 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_24 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_25 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_26 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_27 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_28 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_29 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_2A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_2B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_2C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_2D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_2E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_2F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_30 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_31 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_32 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_33 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_34 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_35 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_36 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_37 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_38 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_39 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_3A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_3B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_3C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_3D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_3E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_hi.INIT_3F = 256'h0000000000000000000000000000000000000000000000000000000000000000;

//--------------------------------------------------------------

   // RAMB16_S4_S4: Virtex-II/II-Pro, Spartan-3 4k x 4 Dual-Port RAM
   // Xilinx HDL Language Template version 6.3.1i

   RAMB16_S4_S4 display_att_lo (
      .DOA(rdwr_dout_n2),  // Port A 4-bit Data Output
      .DOB(rfsh_dout_n2),  // Port B 4-bit Data Output
      .ADDRA(rdwr_addr),   // Port A 12-bit Address Input
      .ADDRB(rfsh_addr),   // Port B 12-bit Address Input
      .CLKA(clk),          // Port A Clock
      .CLKB(clk),          // Port B Clock
      .DIA(rdwr_din_n2),   // Port A 4-bit Data Input
      .DIB(rfsh_din_n2),   // Port B 4-bit Data Input
      .ENA(en),            // Port A RAM Enable Input
      .ENB(pixclk),        // Port B RAM Enable Input
      .SSRA(1'b0),         // Port A Synchronous Set/Reset Input
      .SSRB(1'b0),         // Port B Synchronous Set/Reset Input
      .WEA(wr),            // Port A Write Enable Input
      .WEB(1'b0)           // Port B Write Enable Input
   );

   // The following defparam declarations are only necessary if you wish to change the default behavior
   // of the RAM. If the instance name is changed, these defparams need to be updated accordingly.

   defparam display_att_lo.INIT_A = 18'h0; // Value of output RAM registers on Port A at startup
   defparam display_att_lo.INIT_B = 18'h0; // Value of output RAM registers on Port B at startup
   defparam display_att_lo.SRVAL_A = 18'h0; // Port A ouput value upon SSR assertion
   defparam display_att_lo.SRVAL_B = 18'h0; // Port B ouput value upon SSR assertion
   defparam display_att_lo.WRITE_MODE_A = "WRITE_FIRST"; // WRITE_FIRST, READ_FIRST or NO_CHANGE
   defparam display_att_lo.WRITE_MODE_B = "WRITE_FIRST"; // WRITE_FIRST, READ_FIRST or NO_CHANGE

   // The following defparam INIT_xx declarations are only necessary if you wish to change the initial
   // contents of the RAM to anything other than all zero's.

   defparam display_att_lo.INIT_00 = 256'h7777777777777777777777777777777777777777777777777777777777777777;
   defparam display_att_lo.INIT_01 = 256'h0000000000000000000000000000000000000000000000007777777777777777;
   defparam display_att_lo.INIT_02 = 256'h7777777777777777777777777777777777777777777777777777777777777777;
   defparam display_att_lo.INIT_03 = 256'h0000000000000000000000000000000000000000000000007777777777777777;
   defparam display_att_lo.INIT_04 = 256'h7777777777777777777777777777777777777777777777777777777777777777;
   defparam display_att_lo.INIT_05 = 256'h0000000000000000000000000000000000000000000000007777777777777777;
   defparam display_att_lo.INIT_06 = 256'h7777777777777777777777777777777777777777777777777777777777777777;
   defparam display_att_lo.INIT_07 = 256'h0000000000000000000000000000000000000000000000007777777777777777;
   defparam display_att_lo.INIT_08 = 256'h7777777777777777777777777777777777777777777777777777777777777777;
   defparam display_att_lo.INIT_09 = 256'h0000000000000000000000000000000000000000000000007777777777777777;
   defparam display_att_lo.INIT_0A = 256'h7777777777777777777777777777777777777777777777777777777777777777;
   defparam display_att_lo.INIT_0B = 256'h0000000000000000000000000000000000000000000000007777777777777777;
   defparam display_att_lo.INIT_0C = 256'h7777777777777777777777777777777777777777777777777777777777777777;
   defparam display_att_lo.INIT_0D = 256'h0000000000000000000000000000000000000000000000007777777777777777;
   defparam display_att_lo.INIT_0E = 256'h7777777777777777777777777777777777777777777777777777777777777777;
   defparam display_att_lo.INIT_0F = 256'h0000000000000000000000000000000000000000000000007777777777777777;
   defparam display_att_lo.INIT_10 = 256'h7777777777777777777777777777777777777777777777777777777777777777;
   defparam display_att_lo.INIT_11 = 256'h0000000000000000000000000000000000000000000000007777777777777777;
   defparam display_att_lo.INIT_12 = 256'h7777777777777777777777777777777777777777777777777777777777777777;
   defparam display_att_lo.INIT_13 = 256'h0000000000000000000000000000000000000000000000007777777777777777;
   defparam display_att_lo.INIT_14 = 256'h7777777777777777777777777777777777777777777777777777777777777777;
   defparam display_att_lo.INIT_15 = 256'h0000000000000000000000000000000000000000000000007777777777777777;
   defparam display_att_lo.INIT_16 = 256'h7777777777777777777777777777777777777777777777777777777777777777;
   defparam display_att_lo.INIT_17 = 256'h0000000000000000000000000000000000000000000000007777777777777777;
   defparam display_att_lo.INIT_18 = 256'h7777777777777777777777777777777777777777777777777777777777777777;
   defparam display_att_lo.INIT_19 = 256'h0000000000000000000000000000000000000000000000007777777777777777;
   defparam display_att_lo.INIT_1A = 256'h7777777777777777777777777777777777777777777777777777777777777777;
   defparam display_att_lo.INIT_1B = 256'h0000000000000000000000000000000000000000000000007777777777777777;
   defparam display_att_lo.INIT_1C = 256'h7777777777777777777777777777777777777777777777777777777777777777;
   defparam display_att_lo.INIT_1D = 256'h0000000000000000000000000000000000000000000000007777777777777777;
   defparam display_att_lo.INIT_1E = 256'h7777777777777777777777777777777777777777777777777777777777777777;
   defparam display_att_lo.INIT_1F = 256'h0000000000000000000000000000000000000000000000007777777777777777;
   defparam display_att_lo.INIT_20 = 256'h7777777777777777777777777777777777777777777777777777777777777777;
   defparam display_att_lo.INIT_21 = 256'h0000000000000000000000000000000000000000000000007777777777777777;
   defparam display_att_lo.INIT_22 = 256'h7777777777777777777777777777777777777777777777777777777777777777;
   defparam display_att_lo.INIT_23 = 256'h0000000000000000000000000000000000000000000000007777777777777777;
   defparam display_att_lo.INIT_24 = 256'h7777777777777777777777777777777777777777777777777777777777777777;
   defparam display_att_lo.INIT_25 = 256'h0000000000000000000000000000000000000000000000007777777777777777;
   defparam display_att_lo.INIT_26 = 256'h7777777777777777777777777777777777777777777777777777777777777777;
   defparam display_att_lo.INIT_27 = 256'h0000000000000000000000000000000000000000000000007777777777777777;
   defparam display_att_lo.INIT_28 = 256'h7777777777777777777777777777777777777777777777777777777777777777;
   defparam display_att_lo.INIT_29 = 256'h0000000000000000000000000000000000000000000000007777777777777777;
   defparam display_att_lo.INIT_2A = 256'h7777777777777777777777777777777777777777777777777777777777777777;
   defparam display_att_lo.INIT_2B = 256'h0000000000000000000000000000000000000000000000007777777777777777;
   defparam display_att_lo.INIT_2C = 256'h7777777777777777777777777777777777777777777777777777777777777777;
   defparam display_att_lo.INIT_2D = 256'h0000000000000000000000000000000000000000000000007777777777777777;
   defparam display_att_lo.INIT_2E = 256'h7777777777777777777777777777777777777777777777777777777777777777;
   defparam display_att_lo.INIT_2F = 256'h0000000000000000000000000000000000000000000000007777777777777777;
   defparam display_att_lo.INIT_30 = 256'h7777777777777777777777777777777777777777777777777777777777777777;
   defparam display_att_lo.INIT_31 = 256'h0000000000000000000000000000000000000000000000007777777777777777;
   defparam display_att_lo.INIT_32 = 256'h7777777777777777777777777777777777777777777777777777777777777777;
   defparam display_att_lo.INIT_33 = 256'h0000000000000000000000000000000000000000000000007777777777777777;
   defparam display_att_lo.INIT_34 = 256'h7777777777777777777777777777777777777777777777777777777777777777;
   defparam display_att_lo.INIT_35 = 256'h0000000000000000000000000000000000000000000000007777777777777777;
   defparam display_att_lo.INIT_36 = 256'h7777777777777777777777777777777777777777777777777777777777777777;
   defparam display_att_lo.INIT_37 = 256'h0000000000000000000000000000000000000000000000007777777777777777;
   defparam display_att_lo.INIT_38 = 256'h7777777777777777777777777777777777777777777777777777777777777777;
   defparam display_att_lo.INIT_39 = 256'h0000000000000000000000000000000000000000000000007777777777777777;
   defparam display_att_lo.INIT_3A = 256'h7777777777777777777777777777777777777777777777777777777777777777;
   defparam display_att_lo.INIT_3B = 256'h0000000000000000000000000000000000000000000000007777777777777777;
   defparam display_att_lo.INIT_3C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_lo.INIT_3D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_lo.INIT_3E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_att_lo.INIT_3F = 256'h0000000000000000000000000000000000000000000000000000000000000000;

//--------------------------------------------------------------

   // RAMB16_S4_S4: Virtex-II/II-Pro, Spartan-3 4k x 4 Dual-Port RAM
   // Xilinx HDL Language Template version 6.3.1i

   RAMB16_S4_S4 display_chr_hi (
      .DOA(rdwr_dout_n1),  // Port A 4-bit Data Output
      .DOB(rfsh_dout_n1),  // Port B 4-bit Data Output
      .ADDRA(rdwr_addr),   // Port A 12-bit Address Input
      .ADDRB(rfsh_addr),   // Port B 12-bit Address Input
      .CLKA(clk),          // Port A Clock
      .CLKB(clk),          // Port B Clock
      .DIA(rdwr_din_n1),   // Port A 4-bit Data Input
      .DIB(rfsh_din_n1),   // Port B 4-bit Data Input
      .ENA(en),            // Port A RAM Enable Input
      .ENB(pixclk),        // Port B RAM Enable Input
      .SSRA(1'b0),         // Port A Synchronous Set/Reset Input
      .SSRB(1'b0),         // Port B Synchronous Set/Reset Input
      .WEA(wr),            // Port A Write Enable Input
      .WEB(1'b0)           // Port B Write Enable Input
   );

   // The following defparam declarations are only necessary if you wish to change the default behavior
   // of the RAM. If the instance name is changed, these defparams need to be updated accordingly.

   defparam display_chr_hi.INIT_A = 18'h0; // Value of output RAM registers on Port A at startup
   defparam display_chr_hi.INIT_B = 18'h0; // Value of output RAM registers on Port B at startup
   defparam display_chr_hi.SRVAL_A = 18'h0; // Port A ouput value upon SSR assertion
   defparam display_chr_hi.SRVAL_B = 18'h0; // Port B ouput value upon SSR assertion
   defparam display_chr_hi.WRITE_MODE_A = "WRITE_FIRST"; // WRITE_FIRST, READ_FIRST or NO_CHANGE
   defparam display_chr_hi.WRITE_MODE_B = "WRITE_FIRST"; // WRITE_FIRST, READ_FIRST or NO_CHANGE

   // The following defparam INIT_xx declarations are only necessary if you wish to change the initial
   // contents of the RAM to anything other than all zero's.

   defparam display_chr_hi.INIT_00 = 256'h2222222222222222222222222222222222222222222222222222222222222222;
   defparam display_chr_hi.INIT_01 = 256'h0000000000000000000000000000000000000000000000002222222222222222;
   defparam display_chr_hi.INIT_02 = 256'h2222222222222222222222222222222222222222222222222222222222222222;
   defparam display_chr_hi.INIT_03 = 256'h0000000000000000000000000000000000000000000000002222222222222222;
   defparam display_chr_hi.INIT_04 = 256'h2222222222222222222222222222222222222222222222222222222222222222;
   defparam display_chr_hi.INIT_05 = 256'h0000000000000000000000000000000000000000000000002222222222222222;
   defparam display_chr_hi.INIT_06 = 256'h2222222222222222222222222222222222222222222222222222222222222222;
   defparam display_chr_hi.INIT_07 = 256'h0000000000000000000000000000000000000000000000002222222222222222;
   defparam display_chr_hi.INIT_08 = 256'h2222222222222222222222222222222222222222222222222222222222222222;
   defparam display_chr_hi.INIT_09 = 256'h0000000000000000000000000000000000000000000000002222222222222222;
   defparam display_chr_hi.INIT_0A = 256'h2222222222222222222222222222222222222222222222222222222222222222;
   defparam display_chr_hi.INIT_0B = 256'h0000000000000000000000000000000000000000000000002222222222222222;
   defparam display_chr_hi.INIT_0C = 256'h2726262727262422272627262627262624222626272626252222222222222222;
   defparam display_chr_hi.INIT_0D = 256'h0000000000000000000000000000000000000000000000002222222222222222;
   defparam display_chr_hi.INIT_0E = 256'h2222222222222222222222222222222222222222222222222222222222222222;
   defparam display_chr_hi.INIT_0F = 256'h0000000000000000000000000000000000000000000000002222222222222222;
   defparam display_chr_hi.INIT_10 = 256'h2222222222222222222222222222222222222222222222222222222222222222;
   defparam display_chr_hi.INIT_11 = 256'h0000000000000000000000000000000000000000000000002222222222222222;
   defparam display_chr_hi.INIT_12 = 256'h2222222222222222222222222222222222222222222222222222222222222222;
   defparam display_chr_hi.INIT_13 = 256'h0000000000000000000000000000000000000000000000002222222222222222;
   defparam display_chr_hi.INIT_14 = 256'h2727262726262726262422232322272227262626242223232222222222222222;
   defparam display_chr_hi.INIT_15 = 256'h0000000000000000000000000000000000000000000000002222222222222222;
   defparam display_chr_hi.INIT_16 = 256'h2222222222222222222222222222222222222222222222222222222222222222;
   defparam display_chr_hi.INIT_17 = 256'h0000000000000000000000000000000000000000000000002222222222222222;
   defparam display_chr_hi.INIT_18 = 256'h2222222222222222222222222222222222222222222222222222222222222222;
   defparam display_chr_hi.INIT_19 = 256'h0000000000000000000000000000000000000000000000002222222222222222;
   defparam display_chr_hi.INIT_1A = 256'h2222222222222222222222222222222222222222222222222222222222222222;
   defparam display_chr_hi.INIT_1B = 256'h0000000000000000000000000000000000000000000000002222222222222222;
   defparam display_chr_hi.INIT_1C = 256'h2222222222222222222222222222222222222222222222222222222222222222;
   defparam display_chr_hi.INIT_1D = 256'h0000000000000000000000000000000000000000000000002222222222222222;
   defparam display_chr_hi.INIT_1E = 256'h2222222222222222222222222222222222222222222222222222222222222222;
   defparam display_chr_hi.INIT_1F = 256'h0000000000000000000000000000000000000000000000002222222222222222;
   defparam display_chr_hi.INIT_20 = 256'h2222222222222222222222222222222222222222222222222222222222222222;
   defparam display_chr_hi.INIT_21 = 256'h0000000000000000000000000000000000000000000000002222222222222222;
   defparam display_chr_hi.INIT_22 = 256'h2222222222222227272627272627262625222222222222222222222222222222;
   defparam display_chr_hi.INIT_23 = 256'h0000000000000000000000000000000000000000000000002222222222222222;
   defparam display_chr_hi.INIT_24 = 256'h2222222222222222222222222222222222222222222222222222222222222222;
   defparam display_chr_hi.INIT_25 = 256'h0000000000000000000000000000000000000000000000002222222222222222;
   defparam display_chr_hi.INIT_26 = 256'h2222222222222222222222262622222222222222222222222222222222222222;
   defparam display_chr_hi.INIT_27 = 256'h0000000000000000000000000000000000000000000000002222222222222222;
   defparam display_chr_hi.INIT_28 = 256'h2222222222222222222222222222222222222222222222222222222222222222;
   defparam display_chr_hi.INIT_29 = 256'h0000000000000000000000000000000000000000000000002222222222222222;
   defparam display_chr_hi.INIT_2A = 256'h2222222227262626262626252226262626272724222222222222222222222222;
   defparam display_chr_hi.INIT_2B = 256'h0000000000000000000000000000000000000000000000002222222222222222;
   defparam display_chr_hi.INIT_2C = 256'h2222222222222222222222222222222222222222222222222222222222222222;
   defparam display_chr_hi.INIT_2D = 256'h0000000000000000000000000000000000000000000000002222222222222222;
   defparam display_chr_hi.INIT_2E = 256'h2222222222222222226262727262624222222222222222222222222222222222;
   defparam display_chr_hi.INIT_2F = 256'h0000000000000000000000000000000000000000000000002222222222222222;
   defparam display_chr_hi.INIT_30 = 256'h2222222222222222222222222222222222222222222222222222222222222222;
   defparam display_chr_hi.INIT_31 = 256'h0000000000000000000000000000000000000000000000002222222222222222;
   defparam display_chr_hi.INIT_32 = 256'h2222222222222222222222222222222222222222222222222222222222222222;
   defparam display_chr_hi.INIT_33 = 256'h0000000000000000000000000000000000000000000000002222222222222222;
   defparam display_chr_hi.INIT_34 = 256'h2222222222222222222222222222222222222222222222222222222222222222;
   defparam display_chr_hi.INIT_35 = 256'h0000000000000000000000000000000000000000000000002222222222222222;
   defparam display_chr_hi.INIT_36 = 256'h2222222222222222222222222222222222222222222222222222222222222222;
   defparam display_chr_hi.INIT_37 = 256'h0000000000000000000000000000000000000000000000002222222222222222;
   defparam display_chr_hi.INIT_38 = 256'h2222222222222222222222222222222222222222222222222222222222222222;
   defparam display_chr_hi.INIT_39 = 256'h0000000000000000000000000000000000000000000000002222222222222222;
   defparam display_chr_hi.INIT_3A = 256'h2222222222222222222222222222222222222222222222222222222222222222;
   defparam display_chr_hi.INIT_3B = 256'h0000000000000000000000000000000000000000000000002222222222222222;
   defparam display_chr_hi.INIT_3C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_hi.INIT_3D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_hi.INIT_3E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_hi.INIT_3F = 256'h0000000000000000000000000000000000000000000000000000000000000000;

//--------------------------------------------------------------

   // RAMB16_S4_S4: Virtex-II/II-Pro, Spartan-3 4k x 4 Dual-Port RAM
   // Xilinx HDL Language Template version 6.3.1i

   RAMB16_S4_S4 display_chr_lo (
      .DOA(rdwr_dout_n0),  // Port A 4-bit Data Output
      .DOB(rfsh_dout_n0),  // Port B 4-bit Data Output
      .ADDRA(rdwr_addr),   // Port A 12-bit Address Input
      .ADDRB(rfsh_addr),   // Port B 12-bit Address Input
      .CLKA(clk),          // Port A Clock
      .CLKB(clk),          // Port B Clock
      .DIA(rdwr_din_n0),   // Port A 4-bit Data Input
      .DIB(rfsh_din_n0),   // Port B 4-bit Data Input
      .ENA(en),            // Port A RAM Enable Input
      .ENB(pixclk),        // Port B RAM Enable Input
      .SSRA(1'b0),         // Port A Synchronous Set/Reset Input
      .SSRB(1'b0),         // Port B Synchronous Set/Reset Input
      .WEA(wr),            // Port A Write Enable Input
      .WEB(1'b0)           // Port B Write Enable Input
   );

   // The following defparam declarations are only necessary if you wish to change the default behavior
   // of the RAM. If the instance name is changed, these defparams need to be updated accordingly.

   defparam display_chr_lo.INIT_A = 18'h0; // Value of output RAM registers on Port A at startup
   defparam display_chr_lo.INIT_B = 18'h0; // Value of output RAM registers on Port B at startup
   defparam display_chr_lo.SRVAL_A = 18'h0; // Port A ouput value upon SSR assertion
   defparam display_chr_lo.SRVAL_B = 18'h0; // Port B ouput value upon SSR assertion
   defparam display_chr_lo.WRITE_MODE_A = "WRITE_FIRST"; // WRITE_FIRST, READ_FIRST or NO_CHANGE
   defparam display_chr_lo.WRITE_MODE_B = "WRITE_FIRST"; // WRITE_FIRST, READ_FIRST or NO_CHANGE

   // The following defparam INIT_xx declarations are only necessary if you wish to change the initial
   // contents of the RAM to anything other than all zero's.

   defparam display_chr_lo.INIT_00 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_01 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_02 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_03 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_04 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_05 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_06 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_07 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_08 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_09 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_0A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_0B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_0C = 256'h09010C000309040002050403010201080300050C000D09030000000000000000;
   defparam display_chr_lo.INIT_0D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_0E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_0F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_10 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_11 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_12 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_13 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_14 = 256'h0302050403010201080300000800080003050E090C0000030000000000000000;
   defparam display_chr_lo.INIT_15 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_16 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_17 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_18 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_19 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_1A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_1B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_1C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_1D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_1E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_1F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_20 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_21 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_22 = 256'h0000000000000009040903020506090E05000000000000000000000000000000;
   defparam display_chr_lo.INIT_23 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_24 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_25 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_26 = 256'h0000000000000000000000060F00000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_27 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_28 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_29 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_2A = 256'h000000000305030E05090303000405090C000001000000000000000000000000;
   defparam display_chr_lo.INIT_2B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_2C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_2D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_2E = 256'h000000000000000000E050303050907000000000000000000000000000000000;
   defparam display_chr_lo.INIT_2F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_30 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_31 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_32 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_33 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_34 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_35 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_36 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_37 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_38 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_39 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_3A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_3B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_3C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_3D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_3E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
   defparam display_chr_lo.INIT_3F = 256'h0000000000000000000000000000000000000000000000000000000000000000;

//--------------------------------------------------------------

  always @(posedge clk) begin
    if (pixclk == 1) begin
      chrrow_out <= chrrow_in;
      chrcol_out <= chrcol_in;
      blank_out <= blank_in;
      hsync_out <= hsync_in;
      vsync_out <= vsync_in;
      blink_out <= blink_in;
    end
  end

endmodule