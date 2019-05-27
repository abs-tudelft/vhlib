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
use ieee.numeric_std.all;

library work;
use work.Stream_pkg.all;
use work.ClockGen_pkg.all;
use work.StreamSource_pkg.all;
use work.StreamSink_pkg.all;

entity StreamFIFO_tb is
  generic (
    IN_CLK_PERIOD               : in  time;
    OUT_CLK_PERIOD              : in  time
  );
end StreamFIFO_tb;

architecture TestBench of StreamFIFO_tb is

  constant DATA_WIDTH           : natural := 8;

  signal in_clk                 : std_logic;
  signal in_reset               : std_logic;

  signal out_clk                : std_logic;
  signal out_reset              : std_logic;

  signal valid_a                : std_logic;
  signal ready_a                : std_logic;
  signal data_a                 : std_logic_vector(DATA_WIDTH-1 downto 0);

  signal valid_b                : std_logic;
  signal ready_b                : std_logic;
  signal data_b                 : std_logic_vector(DATA_WIDTH-1 downto 0);

begin

  clkgen_in: ClockGen_mod
    generic map (
      NAME                      => "in",
      INIT_PERIOD               => IN_CLK_PERIOD
    )
    port map (
      clk                       => in_clk,
      reset                     => in_reset
    );

  clkgen_out: ClockGen_mod
    generic map (
      NAME                      => "out",
      INIT_PERIOD               => OUT_CLK_PERIOD
    )
    port map (
      clk                       => out_clk,
      reset                     => out_reset
    );

  source_a: StreamSource_mod
    generic map (
      NAME                      => "a",
      ELEMENT_WIDTH             => DATA_WIDTH
    )
    port map (
      clk                       => in_clk,
      reset                     => in_reset,
      valid                     => valid_a,
      ready                     => ready_a,
      data                      => data_a
    );

  uut: StreamFIFO
    generic map (
      DATA_WIDTH                => DATA_WIDTH,
      DEPTH_LOG2                => 5,
      XCLK_STAGES               => 2
    )
    port map (
      in_clk                    => in_clk,
      in_reset                  => in_reset,
      in_valid                  => valid_a,
      in_ready                  => ready_a,
      in_data                   => data_a,
      out_clk                   => out_clk,
      out_reset                 => out_reset,
      out_valid                 => valid_b,
      out_ready                 => ready_b,
      out_data                  => data_b
    );

  sink_b: StreamSink_mod
    generic map (
      NAME                      => "b",
      ELEMENT_WIDTH             => DATA_WIDTH
    )
    port map (
      clk                       => out_clk,
      reset                     => out_reset,
      valid                     => valid_b,
      ready                     => ready_b,
      data                      => data_b
    );

end TestBench;

