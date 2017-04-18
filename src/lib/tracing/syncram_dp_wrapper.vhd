-----------------------------------------------------------------------------
-- Entity:      syncram_dp_wrapper
-- File:        syncram_dp_wrapper
-- Author:      Van Bui - ARCADE @ Columbia University
-- Description: wraps several 14 bit addressable dual port SRAMS
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--pragma translate_off
use STD.textio.all;
use ieee.std_logic_textio.all;
--pragma translate_on

library sld;
use sld.tracing.all;

library techmap;
use techmap.gencomp.all;
use techmap.genacc.all;

library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;

entity syncram_dp_wrapper is
    generic (
      tech   : integer := 0;
      pirq   : integer := 0);
      
    port (
      rst          : in std_ulogic;
      clk          : in std_ulogic;
      rdaddr       : in std_logic_vector((MEM_SIZE_LOG-1) downto 0);
      rden         : in std_ulogic;
      packsigs     : in std_logic_vector((MEM_BITS -1) downto 0);
      sample       : in std_ulogic;
      reset_log    : in std_ulogic;
      stop_log     : in std_ulogic;
      full_log     : out std_ulogic;
      memout       : out std_logic_vector(MEM_BITS-1 downto 0);
      irq          : out std_logic_vector(NAHBIRQ-1 downto 0));
end syncram_dp_wrapper;

architecture beh_wrapper of syncram_dp_wrapper is

  signal wrenarray : uvector(0 to NUM_SRAMS-1); 
  signal read_sig  : std_logic_vector(MEM_SIZE_LOG - 1 downto BANK_SIZE_LOG);
  signal outarray  : vectorarray(0 to (NUM_SRAMS - 1));
  signal write_window       : std_logic_vector((WIN_SIZE_LOG-1) downto 0);
  signal write_window_next  : std_logic_vector((WIN_SIZE_LOG-1) downto 0);
  signal sram_input         : std_logic_vector((MEM_BITS -1) downto 0);
  signal max_samples        : std_logic_vector((MEM_BITS-1) downto 0);
  signal buffer_full        : std_ulogic;
  signal dump_stats         : std_ulogic;
  signal cycle_count        : std_logic_vector((MEM_BITS-1) downto 0);
  signal cycle_count_next   : std_logic_vector((MEM_BITS-1) downto 0);
  signal irqset : std_ulogic;
  
begin
  GEN_SRAM:
  for n in 0 to (NUM_SRAMS-1) generate
    SRAMX : syncram_dp
    generic map (
      tech       => tech,
      abits      => BANK_SIZE_LOG,
      dbits      => MEM_BITS)
    port map (
      clk1      => clk,
      address1  => rdaddr(BANK_SIZE_LOG - 1 downto 0),
      datain1   => (others => '0'),
      dataout1  => outarray(n),
      enable1   => rden,
      write1    => '0',
      clk2      => clk,
      address2  => write_window(BANK_SIZE_LOG - 1 downto 0),
      datain2   => sram_input,
      dataout2  => open,
      enable2   => wrenarray(n),
      write2    => wrenarray(n));
  end generate GEN_SRAM;

    delay_selector: process (clk, rst)
  begin  -- process delay_selector
    if rst = '0' then                   -- asynchronous reset (active low)
      read_sig <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      read_sig <= rdaddr(MEM_SIZE_LOG - 1 downto BANK_SIZE_LOG);
    end if;
  end process delay_selector;
  
  write_select : process(clk, rst)
    variable baddr : std_logic_vector(MEM_SIZE_LOG-1 downto BANK_SIZE_LOG); 
  begin  -- process set_wren
    max_samples <= conv_std_logic_vector(NUM_SAMPLES, MEM_BITS);
    if rst = '0' then
      buffer_full <= '0';
      write_window <= (others => '0');
      for i in 0 to (NUM_SRAMS-1) loop
        wrenarray(i) <= '0';
      end loop;
      sram_input <= packsigs; 
--      sram_input <= (others => '0');      
      dump_stats <= '0';
      cycle_count <= (others => '0');
      irq <= (others => '0');
      irqset <= '0';
    elsif clk'event and clk='1' then
      cycle_count <= cycle_count_next;
      for j in 0 to (NUM_SRAMS-1) loop
        wrenarray(j) <= '0';
      end loop;
      if reset_log = '1' then
        sram_input <= packsigs;
--        sram_input <= (others => '0');              
        write_window <= (others => '0');
        buffer_full <= '0';
        dump_stats <= '0';
        cycle_count <= (others => '0');
      elsif dump_stats = '1' then
        wrenarray(0) <= '0';
      elsif (write_window_next = max_samples(WIN_SIZE_LOG-1 downto 0) and (dump_stats = '0')) then
        buffer_full <= '1';
--        sram_input((MEM_BITS -1) downto WIN_SIZE_LOG) <= (others => '0');
--        sram_input(WIN_SIZE_LOG - 1 downto 0) <= cycle_count;
        sram_input <= cycle_count;
        write_window <= (others => '0');
        wrenarray(0) <= '1';        
      elsif (stop_log = '1') and (buffer_full = '0') then
--        sram_input((MEM_BITS -1) downto WIN_SIZE_LOG) <= (others => '0');
--        sram_input(WIN_SIZE_LOG - 1 downto 0) <= cycle_count;
        sram_input <= cycle_count;
        write_window <= (others => '0');
        wrenarray(0) <= '1';
        dump_stats <= '1';
        cycle_count <= (others => '0');
      elsif (stop_log = '1') and (buffer_full = '1') then
        cycle_count <= (others => '0');
        sram_input <= cycle_count;
        wrenarray(0) <= '1';
        write_window <= (others => '0');
        dump_stats <= '1';
      elsif sample = '1' then
        sram_input <= packsigs;
--        sram_input(31 downto WIN_SIZE_LOG) <= (others => '0');
--        sram_input((WIN_SIZE_LOG-1) downto 0) <= write_window_next;

        write_window <= write_window_next;
        for k in 0 to (NUM_SRAMS-1) loop
          baddr := conv_std_logic_vector(k, MEM_SIZE_LOG-BANK_SIZE_LOG);
          if write_window_next(MEM_SIZE_LOG - 1 downto BANK_SIZE_LOG) = baddr(MEM_SIZE_LOG-1 downto BANK_SIZE_LOG) then
            wrenarray(k) <= '1';
          end if;
        end loop;
      end if;

      -- interrupt
      if irqset = '1' then
        irq(pirq) <= '0';
      elsif ((stop_log = '1') and (buffer_full = '0')) or (write_window_next = max_samples(WIN_SIZE_LOG-1 downto 0) and (dump_stats = '0')) or ((stop_log = '1') and (buffer_full = '0')) then
        irq(pirq) <= '1';
        irqset <= '1';
      end if;
      if reset_log = '1' then
        irqset <= '0';
      end if;

    end if;
  end process write_select;

  read_select: process (read_sig, outarray)
    variable bankaddr : std_logic_vector(MEM_SIZE_LOG-1 downto BANK_SIZE_LOG);
  begin  -- process selector
    memout <= (others => '0');
    for m in 0 to (NUM_SRAMS-1) loop
      bankaddr := conv_std_logic_vector(m, MEM_SIZE_LOG-BANK_SIZE_LOG);
      if read_sig = bankaddr(MEM_SIZE_LOG-1 downto BANK_SIZE_LOG) then
        memout <= outarray(m);
      end if;
    end loop;
  end process read_select;


  cycle_count_next <= cycle_count + conv_std_logic_vector(1, MEM_BITS);
  write_window_next <= write_window + conv_std_logic_vector(1, WIN_SIZE_LOG);
  full_log <= '1' when (write_window_next = max_samples(WIN_SIZE_LOG-1 downto 0)) else '0';  

end beh_wrapper;
      
