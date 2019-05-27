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
use work.TestCase_pkg.all;
use work.StreamSource_pkg.all;
use work.StreamSink_pkg.all;

entity StreamSync_tc is
end StreamSync_tc;

architecture TestCase of StreamSync_tc is
begin

  basic_tc: process is
    constant A_STR : string := "The Quick Brown Fox jumps over a Lazy Dog.";
    constant B_STR : string := "A Quick Brown Fox jumps over the Lazy Dog.";
    constant C_STR : string := "ThE quicK browN fox jumps over a Lazy Dog.";
    constant D_STR : string := "A quIck brOwn foX jumps over the Lazy Dog.";
    variable a : streamsource_type;
    variable b : streamsource_type;
    variable c : streamsink_type;
    variable d : streamsink_type;
  begin
    tc_open("StreamSync-basic", "tests basic sync functionality with random handshakes.");
    a.initialize("a");
    b.initialize("b");
    c.initialize("c");
    d.initialize("d");

    a.set_total_cyc(-5, 5);
    a.set_x("1"); -- advance b
    a.set_y("1"); -- use b
    a.set_z("1"); -- enable c
    a.push_str(A_STR);
    a.transmit;

    b.set_total_cyc(-5, 5);
    b.set_x("1"); -- advance a
    b.set_y("1"); -- use a
    b.set_z("1"); -- enable d
    b.push_str(B_STR);
    b.transmit;

    c.set_total_cyc(-5, 5);
    c.unblock;

    d.set_total_cyc(-5, 5);
    d.unblock;

    tc_wait_for(5 us);

    tc_check(a.cq_get_d_str, A_STR);
    tc_check(b.cq_get_d_str, B_STR);
    tc_check(c.cq_get_d_str, C_STR);
    tc_check(d.cq_get_d_str, D_STR);

    tc_pass;
    wait;
  end process;

  tb: entity work.StreamSync_tb;

end TestCase;

