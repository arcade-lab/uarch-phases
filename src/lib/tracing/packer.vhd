------------------------------------------------------------------------------
--  This file is part of a signal tracing utility for the LEON3 processor 
--  Copyright (C) 2017, ARCADE Lab @ Columbia University
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--  
--  You should have received a copy of the GNU General Public License
--  along with this program. If not, see <http://www.gnu.org/licenses/>. 
--
-----------------------------------------------------------------------------
-- Entity:      packer
-- File:        packer.vhd
-- Author:      Van Bui - ARCADE @ Columbia University
-- Description: packs data
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library sld;
use sld.tracing.all;

library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;

entity packer is
  port (
    rst             : in std_ulogic;
    clk             : in std_ulogic;
    ipreg           : in ipreg_out_type;
    mem_selected    : in std_logic_vector(AHB_BITS-1 downto 0);
    activity        : in std_logic_vector(ACTIVITY_BITS-1 downto 0);
    packsigs        : out std_logic_vector(MEM_BITS-1 downto 0) := (others => '0'));
end packer;

architecture beh of packer is

signal flastpc : std_logic_vector(MEM_BITS-1 downto 0) := (others => '0');
signal fnextpc : std_logic_vector(MEM_BITS-1 downto 0) := (others => '0');
signal elastpc : std_logic_vector(MEM_BITS-1 downto 0) := (others => '0');
signal enextpc : std_logic_vector(MEM_BITS-1 downto 0) := (others => '0');

begin  --beh
  
  pack_sigs : process (clk, rst)
   begin
     if rst = '0' then
        flastpc <= (others => '0');
        elastpc <= (others => '0');
     elsif clk'event and clk = '1' then
        flastpc <= fnextpc;
        elastpc <= enextpc;
      end if;
   end process;

   next_pc : process(ipreg)
   begin
     fnextpc <= ipreg.f.pc;
     enextpc <= ipreg.e.pc;
   end process;

   packit : process(ipreg, flastpc, fnextpc, elastpc, enextpc)
   begin

     packsigs(0) <= ipreg.icohold or ipreg.holdn;
     packsigs(1) <= ipreg.dcohold or ipreg.holdn;
     packsigs(2) <= ipreg.fpohold or ipreg.holdn;

     if (ipreg.dcache.pagefault='1') then   -- page fault from data access
       packsigs(3) <= '1';
     else
       packsigs(3) <= '0';
     end if;

     if (ipreg.icache.fault='1') then   -- page fault from instruction access
       packsigs(4) <= '1';
     else
       packsigs(4) <= '0';
     end if;
     
     if ((ipreg.d.annul='1')) then
       packsigs(5) <= '1';
     else
       packsigs(5) <= '0';
     end if;

     if ((ipreg.d.pv='0')) then
       packsigs(6) <= '1';
     else
       packsigs(6) <= '0';
     end if;

     if ((ipreg.a.annul='1')) then
       packsigs(7) <= '1';
     else
       packsigs(7) <= '0';
     end if;

     if ((ipreg.a.pv='0')) then
       packsigs(8) <= '1';
     else
       packsigs(8) <= '0';
     end if;

     if ((ipreg.e.annul='1')) then
       packsigs(9) <= '1';
     else
       packsigs(9) <= '0';
     end if;

     if ((ipreg.e.pv='0')) then
       packsigs(10) <= '1';
     else
       packsigs(10) <= '0';
     end if;

     if ((ipreg.m.annul='1')) then
       packsigs(11) <= '1';
     else
       packsigs(11) <= '0';
     end if;

     if ((ipreg.m.pv='0')) then
       packsigs(12) <= '1';
     else
       packsigs(12) <= '0';
     end if;

     if ((ipreg.x.annul='1')) then
       packsigs(13) <= '1';
     else
       packsigs(13) <= '0';
     end if;

     if ((ipreg.x.pv='0')) then
       packsigs(14) <= '1';
     else
       packsigs(14) <= '0';
     end if;

     packsigs(15) <= ipreg.a.rfe1;
     packsigs(16) <= ipreg.a.rfe2;

     packsigs(18 downto 17) <= ipreg.e.inst(31 downto 30);
     packsigs(20 downto 19) <= ipreg.m.inst(31 downto 30); 
     packsigs(22 downto 21) <= ipreg.x.inst(31 downto 30); 

     packsigs(23) <= ipreg.m.ld;
     packsigs(24) <= ipreg.x.ld;
     packsigs(25) <= ipreg.w.wreg;
     
     if ipreg.x.rstate=run then
       packsigs(27 downto 26) <= "00";
     elsif ipreg.x.rstate=trap then
       packsigs(27 downto 26) <= "01";
     elsif ipreg.x.rstate=dsu1 then
       packsigs(27 downto 26) <= "10";
     else
       packsigs(27 downto 26) <= "11";
     end if;

     packsigs(29 downto 28) <= mem_selected(1 downto 0);

     packsigs(31 downto 30) <= ipreg.e.cnt;
     
   end process;
   
end beh;
     
