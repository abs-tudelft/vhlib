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

entity StreamBuffer_tb is
  generic (
    MIN_DEPTH                   : natural
  );
end StreamBuffer_tb;

architecture TestBench of StreamBuffer_tb is

  constant DATA_WIDTH           : natural := 8;

  signal clk                    : std_logic;
  signal reset                  : std_logic;

  signal valid_a                : std_logic;
  signal ready_a                : std_logic;
  signal data_a                 : std_logic_vector(DATA_WIDTH-1 downto 0);

  signal valid_b                : std_logic;
  signal ready_b                : std_logic;
  signal data_b                 : std_logic_vector(DATA_WIDTH-1 downto 0);

begin

  clkgen: ClockGen_mod
    port map (
      clk                       => clk,
      reset                     => reset
    );

  source_a: StreamSource_mod
    generic map (
      NAME                      => "a",
      ELEMENT_WIDTH             => DATA_WIDTH
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      valid                     => valid_a,
      ready                     => ready_a,
      data                      => data_a
    );

  uut: StreamBuffer
    generic map (
      MIN_DEPTH                 => MIN_DEPTH,
      DATA_WIDTH                => DATA_WIDTH
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => valid_a,
      in_ready                  => ready_a,
      in_data                   => data_a,
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
      clk                       => clk,
      reset                     => reset,
      valid                     => valid_b,
      ready                     => ready_b,
      data                      => data_b
    );

end TestBench;

