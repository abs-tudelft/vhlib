-- Copyright 2018 Delft University of Technology
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

-- This unit represents a memory with two read-write ports in separate clock
-- domains. It is described behaviorally in a way that synthesis tools should
-- infer the memory correctly, but modifications may need to be made for some
-- tools.

entity UtilRam2RW is
  generic (

    -- Width of a data word.
    WIDTH                       : natural;

    -- Depth of the memory as log2(depth in words).
    DEPTH_LOG2                  : natural;

    -- RAM configuration parameter. Unused by this default implementation. May
    -- be used to give different optimization options for different RAMs in the
    -- design if this unit is ported to exotic architectures (e.g. ASIC) or if
    -- more control over the implementation style is desired by the user.
    RAM_CONFIG                  : string := ""

  );
  port (

    -- Port A. When wren is high, wdata is written to the memory at address
    -- addr. When rden is high, rdata is read from the memory. A simultaneous
    -- read and write will return the previous value of the memory
    -- (read-first behavior).
    a_clk                       : in  std_logic;
    a_addr                      : in  std_logic_vector(DEPTH_LOG2-1 downto 0);
    a_wren                      : in  std_logic;
    a_wdata                     : in  std_logic_vector(WIDTH-1 downto 0);
    a_rden                      : in  std_logic;
    a_rdata                     : out std_logic_vector(WIDTH-1 downto 0);

    -- Port B. Same as port A, but independent. If A and B access the same
    -- memory location simultaneously, the result is usually undefined in
    -- practice.
    b_clk                       : in  std_logic;
    b_addr                      : in  std_logic_vector(DEPTH_LOG2-1 downto 0);
    b_wren                      : in  std_logic;
    b_wdata                     : in  std_logic_vector(WIDTH-1 downto 0);
    b_rden                      : in  std_logic;
    b_rdata                     : out std_logic_vector(WIDTH-1 downto 0)

  );
end UtilRam2RW;

architecture Behavioral of UtilRam2RW is

  -- Shared variable to represent the memory.
  type mem_type is array (2**DEPTH_LOG2-1 downto 0) of std_logic_vector(WIDTH-1 downto 0);
  signal mem : mem_type;
  
  -- RAM style pragmas:
  
  -- Vivado RAM style
  attribute ram_style : string;
  attribute ram_style of mem : signal is RAM_CONFIG;
  
  -- Quartus RAM style
  
  -- ... RAM style

begin

  -- Port A.
  a_proc: process (a_clk) is
  begin
    if rising_edge(a_clk) then
      if a_rden = '1' then
        a_rdata <= mem(to_integer(unsigned(a_addr)));
      end if;
      if a_wren = '1' then
        mem(to_integer(unsigned(a_addr))) <= a_wdata;
      end if;
    end if;
  end process;

  -- Port B.
  b_proc: process (b_clk) is
  begin
    if rising_edge(b_clk) then
      if b_rden = '1' then
        b_rdata <= mem(to_integer(unsigned(b_addr)));
      end if;
      if b_wren = '1' then
        mem(to_integer(unsigned(b_addr))) <= b_wdata;
      end if;
    end if;
  end process;

end Behavioral;
