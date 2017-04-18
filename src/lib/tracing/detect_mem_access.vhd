-----------------------------------------------------------------------------
-- Entity:      detect_mem_access
-- File:        detect_mem_access.vhd
-- Author:      Paolo Mantovani - SLD @ Columbia University
--              Van Bui - ARCADE @ Columbia University
-- Description: Detects a memory access over the bus
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;

library sld;
use sld.tracing.all;

entity detect_mem_access is

  port (
    ahbsi        : in  ahb_slv_in_type;
    mem_selected : out std_logic_vector(AHB_BITS-1 downto 0));

end detect_mem_access;

architecture beh of detect_mem_access is

begin  --beh

  check_mem_access: process (ahbsi)
    variable haddr : std_logic_vector(1 downto 0);
  begin  -- process detect_mem_access
    haddr := ahbsi.haddr(31 downto 30);
    if (haddr = "01" and (ahbsi.htrans = HTRANS_NONSEQ)) then
      mem_selected <= "01";
    elsif (haddr = "01" and (ahbsi.htrans = HTRANS_SEQ)) then
      mem_selected <= "10";
    elsif (haddr = "01" and (ahbsi.htrans = HTRANS_BUSY)) then
      mem_selected <= "11";
    else
      mem_selected <= "00";
    end if;
  end process check_mem_access;

end beh;
