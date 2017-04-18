------------------------------------------------------------------------------
--  This file is part of an extension to the GRLIB VHDL IP library.
--  Copyright (C) 2013, System Level Design (SLD) group @ Columbia University
--
--  GRLIP is a Copyright (C) 2008 - 2013, Aeroflex Gaisler
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  To receive a copy of the GNU General Public License, write to the Free
--  Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
--  02111-1307  USA.
-----------------------------------------------------------------------------
-- Entity:  ahb_rate_trace
-- File:    ahb_rate_trace.vhd
-- Authors: Paolo Mantovani - SLD @ Columbia University
--          Van Bui - ARCADE @ Columbia University
-- Description:	Amba 2.0 AHB Slave to Network Interface wrapper
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--pragma translate_off
use STD.textio.all;
use ieee.std_logic_textio.all;
--pragma translate_on

library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;

library techmap;
use techmap.gencomp.all;
use techmap.genacc.all;

library sld;
use sld.tracing.all;

entity ahb_rate_trace is
  generic (
    tech        : integer := virtex7;
    hindex      : integer range 0 to NAHBSLV-1 := 5;
    hmask       : integer := 16#ffc#;
    haddr       : integer := 16#b00#;
    pirq        : integer := 0);
  port (
    rst         : in  std_ulogic;
    clk         : in  std_ulogic;
    ahbsi       : in  ahb_slv_in_type;
    ipreg       : in  ipreg_out_type;
    ahbso       : out ahb_slv_out_type
  );

end ahb_rate_trace;

architecture rtl of ahb_rate_trace is

  -- We are interested in a period of time of roughly 2^30 cycles
  -- and we try to compute the derivative of the # of DRAM accesses
  -- every 2^14 cycles. We need a 2^16 words memory.
    
  signal memout        : std_logic_vector(MEM_BITS - 1 downto 0);
  signal hrdata        : std_logic_vector(31 downto 0);
  signal mem_selected  : std_logic_vector(AHB_BITS-1 downto 0);
  signal sram_input    : std_logic_vector((MEM_BITS -1) downto 0);
  signal rden          : std_ulogic;
  signal rdaddr        : std_logic_vector((MEM_SIZE_LOG-1) downto 0);
  signal sw            : softsigs;
  signal rate, rate_next         : std_logic_vector(MEM_SIZE_LOG - 1 downto 0);  
  signal activity, activity_next : std_logic_vector(ACTIVITY_BITS-1 downto 0);
  signal count, count_next  : std_logic_vector(COUNT_BITS - 1 downto 0);
  signal log                : std_ulogic;
  signal full_log           : std_ulogic;
  signal sample             : std_ulogic;
  signal irq    : std_logic_vector(NAHBIRQ-1 downto 0);
  
  constant hconfig : ahb_config_type := (
  0 => ahb_device_reg ( VENDOR_SLD, SLD_RATE_TRACE, 0, 0, 0),
  4 => ahb_membar(haddr, '0', '0', hmask),
  others => zero32);

begin  -- rtl

  -----------------------------------------------------------------------------
  -- SRAMS interface
  -----------------------------------------------------------------------------
  
  syncram_dp_1: syncram_dp_wrapper
    generic map (
      tech        => tech,
      pirq        => pirq)
    port map (
      rst         => rst,
      clk         => clk,
      rdaddr      => rdaddr,
      rden        => rden,
      packsigs    => sram_input,
      sample      => sample,
      reset_log   => sw.reset_stats,
      stop_log    => sw.dump_stats,
      full_log    => full_log,
      memout      => memout,
      irq         => irq);

  -----------------------------------------------------------------------------
  -- Pack pipeline signals
  -----------------------------------------------------------------------------

  packer_1 : packer
    port map(
      rst            => rst,
      clk            => clk,
      ipreg          => ipreg,
      mem_selected   => mem_selected,
      activity       => activity,
      packsigs       => sram_input);
  
  -----------------------------------------------------------------------------
  -- Memory access detection
  -----------------------------------------------------------------------------

  detect_mem_access_1 : detect_mem_access
    port map (
       ahbsi         => ahbsi,
       mem_selected  => mem_selected);

  -----------------------------------------------------------------------------
  -- AHB signal handler
  -----------------------------------------------------------------------------

  decode_address: process (ahbsi, rden, rate, activity)
    variable haddr : std_logic_vector(31 downto 0);
  begin  -- process address_decoder
      haddr := "00" & ahbsi.haddr(31 downto 2);
      haddr := haddr_mask and haddr;
      rdaddr <= haddr(MEM_SIZE_LOG - 1 downto 0);
      rate_next <= rate;
      activity_next <= activity;
      sw.sample_rate <= '0';
      sw.sample_event <= '0';
      sw.reset_stats <= '0';
      sw.dump_stats <= '0';
      
      if rden = '1' and ahbsi.htrans = HTRANS_NONSEQ
        and ahbsi.hwrite = '1' then
        if haddr(MEM_SIZE_LOG - 1 downto 0) = zero_adx then     -- 0
          sw.reset_stats <= '1';
        elsif haddr(MEM_SIZE_LOG - 1 downto 0) = one_adx then   -- 1
          sw.dump_stats <= '1';
        elsif haddr(MEM_SIZE_LOG - 1 downto 0) = ahb_adx then   -- 7
          activity_next <= ahb_act;
          sw.sample_event <= '1';
        elsif haddr(MEM_SIZE_LOG - 1 downto 0) = pc_adx then    -- 4
          activity_next <= pc_act;                    
          sw.sample_event <= '1';
        elsif haddr(MEM_SIZE_LOG - 1 downto 0) = inst_adx then  -- 6
          activity_next <= inst_act;
          sw.sample_event <= '1';
        else 
          rate_next <= haddr(MEM_SIZE_LOG - 1 downto 0);
          sw.sample_rate <= '1';
        end if;
      end if;
   end process decode_address;

  update_params: process (clk,rst)
    begin
      if rst = '0' then
        count <= conv_std_logic_vector(1, COUNT_BITS);
        log <= '0';
        rate <= conv_std_logic_vector(2, COUNT_BITS);
        activity <= conv_std_logic_vector(0, ACTIVITY_BITS);
      elsif clk'event and clk='1' then
        if sw.reset_stats = '1' then
          count <= conv_std_logic_vector(1, COUNT_BITS);
          log <= '1';
        elsif sw.dump_stats = '1' then
          count <= conv_std_logic_vector(1, COUNT_BITS);
          log <= '0';
        elsif sw.sample_rate = '1' then
          rate <= rate_next;
        elsif sw.sample_event = '1' then
          activity <= activity_next;
        elsif full_log = '1' then
          count <= conv_std_logic_vector(1, COUNT_BITS);
          log <= '0';
        elsif log = '1' then
          count <= count_next;
          if count_next = rate then
            count <= one_count;
          end if;
        end if;
      end if;
    end process update_params;

    sample <= '1' when ((log = '1') and (count_next = rate)) else '0';
    rden <= '1' when (ahbsi.hsel(hindex) = '1' and ahbsi.hready = '1') else '0';    
    count_next <= count + conv_std_logic_vector(1, COUNT_BITS);
    
  -----------------------------------------------------------------------------
  -- AHB output handling
  -----------------------------------------------------------------------------
  
  hrdata(MEM_BITS - 1 downto 0) <= memout;
  ahbso.hready <= '1';
  ahbso.hresp <= HRESP_OKAY;
  ahbso.hrdata <= hrdata;
  ahbso.hsplit <= (others => '0');
--  ahbso.hirq <= (others => '0');
  ahbso.hirq <= irq;    
  ahbso.hconfig <= hconfig;
  ahbso.hindex <= hindex;

end rtl;
