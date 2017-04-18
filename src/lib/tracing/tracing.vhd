-----------------------------------------------------------------------------
-- Component:   tracing
-- File:        tracing.vhd
-- Author(s):   Van Bui - ARCADE @ Columbia University
--              Paolo Mantovani - SLD @ Columbia University 
-- Description: Logger for processor signals
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- pragma translate_off
use std.textio.all;
-- pragma translate_on
library grlib;
use grlib.amba.all;
use grlib.config_types.all;
use grlib.config.all;
use grlib.stdlib.all;
library techmap;
use techmap.gencomp.all;

package tracing is

  constant PCOUTLOW        : integer range 0 to 2 := 0;
  constant MEM_SIZE_LOG    : integer := 20;
  constant MEM_BITS        : integer := 32;  
  constant WIN_SIZE_LOG    : integer := 21;
  constant BANK_SIZE_LOG   : integer := 14;  
  constant COUNT_BITS      : integer := MEM_SIZE_LOG;
  constant ACTIVITY_BITS   : integer := 4;
  constant AHB_BITS        : integer := 2;
  constant NUM_SRAMS       : integer := 60;
  constant NUM_SAMPLES     : integer := 983040;
  constant PC_BITS : integer := MEM_BITS;
  constant haddr_mask      : std_logic_vector(MEM_BITS-1 downto 0) := X"000FFFFF";  
  constant zero_adx        : std_logic_vector(MEM_SIZE_LOG - 1 downto 0) := (others => '0');
  constant one_adx         : std_logic_vector(MEM_SIZE_LOG - 1 downto 0) := conv_std_logic_vector(1, MEM_SIZE_LOG);
  constant one_count       : std_logic_vector(COUNT_BITS - 1 downto 0) := conv_std_logic_vector(1, COUNT_BITS);  
  constant pc_adx          : std_logic_vector(MEM_SIZE_LOG - 1 downto 0) := conv_std_logic_vector(4, MEM_SIZE_LOG);
  constant pc_act          : std_logic_vector(ACTIVITY_BITS - 1 downto 0) := conv_std_logic_vector(0, ACTIVITY_BITS);  
  constant inst_adx        : std_logic_vector(MEM_SIZE_LOG - 1 downto 0) := conv_std_logic_vector(6, MEM_SIZE_LOG);
  constant inst_act        : std_logic_vector(ACTIVITY_BITS - 1 downto 0) := conv_std_logic_vector(1, ACTIVITY_BITS);  
  constant ahb_adx         : std_logic_vector(MEM_SIZE_LOG - 1 downto 0) := conv_std_logic_vector(7, MEM_SIZE_LOG);
  constant ahb_act         : std_logic_vector(ACTIVITY_BITS - 1 downto 0) := conv_std_logic_vector(2, ACTIVITY_BITS);
  constant nop_sig         : std_logic_vector(MEM_BITS-1 downto 0) := X"01000000";
  constant memop           : std_logic_vector(1 downto 0) := conv_std_logic_vector(3,2);
  constant NWIN            : integer := 8;
  constant RFBITS : integer range 6 to 10 := log2(NWIN+1) + 4;
  
  subtype pcouttype is std_logic_vector(MEM_BITS-1 downto PCOUTLOW);
  subtype word is std_logic_vector(MEM_BITS-1 downto 0);
  subtype rfatype is std_logic_vector(RFBITS-1 downto 0);
  type uvector is array (integer range <>) of std_ulogic;
  type vectorarray is array (integer range <>) of std_logic_vector(MEM_BITS-1 downto 0);

  type dcachestatetype is (idle, wread, rtrans, wwrite, wtrans, wflush,
                                              asi_idtag, dblwrite, loadpend);
  type icachestatetype is (idle, trans, streaming, stop);

  type exceptionstatetype is (run, trap, dsu1, dsu2);
  
  -- pipeline outputs

  type fetch_reg_out_type is record
    pc    : pcouttype;
    branch : std_ulogic;
  end record;

  type decode_reg_out_type is record
    pc      : pcouttype;
    inst    : word;
    pv      : std_ulogic;
    annul   : std_ulogic;
  end record;

  type regacc_reg_out_type is record
    pc      : pcouttype;
    inst    : word;
    pv      : std_ulogic;
    rfe1    : std_ulogic;
    rfe2    : std_ulogic;
    annul   : std_ulogic;
    rfa1    : rfatype;
    rfa2    : rfatype;
  end record;

  type execute_reg_out_type is record
    pc      : pcouttype;
    inst    : word;
    pv      : std_ulogic;
    rfe     : std_ulogic;
    annul   : std_ulogic;
    op1     : word;
    op2     : word;
    cnt     : std_logic_vector(1 downto 0);
    ld      : std_ulogic;
  end record;

  type memory_reg_out_type is record
    pc      : pcouttype;
    inst    : word;
    pv      : std_ulogic;
    dci_enaddr : std_ulogic;
    annul   : std_ulogic;
    ld      : std_ulogic;
    result  : word;
  end record;
  
  type exception_reg_out_type is record
    pc     : pcouttype;
    rstate : exceptionstatetype;
    inst   : word;
    annul  : std_ulogic;
    annul_all : std_ulogic;
    result : word;
    ld     : std_ulogic;
    pv     : std_ulogic;
  end record;

  type write_reg_out_type is record
    wreg   : std_ulogic;
    result : word;
    wa     : rfatype;
  end record;

  type trace_dcache_type is record
    enaddr    : std_ulogic;
    nullify   : std_ulogic;
    read      : std_ulogic;
    regread   : std_ulogic;
    dstate    : dcachestatetype;
    hit       : std_ulogic;
    valid     : std_ulogic;
    forcemiss : std_ulogic;
    pagefault : std_ulogic;
    lock      : std_ulogic;
    asi       : std_ulogic;
  end record;

  type trace_icache_type is record
    inull : std_ulogic;
    istate : icachestatetype;
    fault  : std_ulogic;
  end record;
  
  type ipreg_out_type is record 
    f  : fetch_reg_out_type;
    d  : decode_reg_out_type;                                              
    a  : regacc_reg_out_type;
    e  : execute_reg_out_type;
    m  : memory_reg_out_type;
    x  : exception_reg_out_type;
    w  : write_reg_out_type;

    holdn       : std_ulogic;
    fpohold     : std_ulogic;
    dcohold     : std_ulogic;
    icohold     : std_ulogic;
    dcache      : trace_dcache_type;
    icache      : trace_icache_type;
    bpmiss      : std_ulogic;
    muli        : std_ulogic;
    divi        : std_ulogic;
    exbpmiss    : std_ulogic;
    rabpmiss    : std_ulogic;
    deannul     : std_ulogic;
    muloready    : std_ulogic;
    divoready    : std_ulogic;
  end record;

  type ipsigs is record
     sig1 : std_logic_vector(7 downto 0);
     sig2 : std_logic_vector(7 downto 0);
     sig3 : std_logic_vector(7 downto 0);
     sig4 : std_logic_vector(7 downto 0);
  end record;

  type softsigs is record
     reset_stats  : std_ulogic;
     dump_stats   : std_ulogic;
     sample_rate  : std_ulogic;
     sample_event : std_ulogic;
  end record;
  
  component ahb_rate_trace is
    generic (
      tech        : integer := virtex7;
      hindex      : integer range 0 to NAHBSLV-1 := 5;
      hmask       : integer := 16#ffc#;
      haddr       : integer := 16#b00#;
      pirq        : integer := 0);
    port (
      rst      : in  std_ulogic;
      clk      : in  std_ulogic;
      ahbsi    : in  ahb_slv_in_type;
      ipreg    : in  ipreg_out_type;
      ahbso    : out ahb_slv_out_type);
  end component;

   component packer
     port (
       rst             : in std_ulogic;
       clk             : in std_ulogic;
       ipreg           : in ipreg_out_type;
       mem_selected    : in std_logic_vector(AHB_BITS-1 downto 0);
       activity        : in std_logic_vector(ACTIVITY_BITS-1 downto 0);  
       packsigs        : out std_logic_vector(MEM_BITS-1 downto 0) := (others => '0'));

   end component;  -- packer

  component syncram_dp_wrapper
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
  end component;      

  component detect_mem_access is
    port (
      ahbsi        : in  ahb_slv_in_type;
      mem_selected : out std_logic_vector(AHB_BITS-1 downto 0));
  end component;

end tracing;
