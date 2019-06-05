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
use ieee.std_logic_misc.all;

package UtilInt_pkg is

  -- Array of naturals.
  type nat_array is array (natural range <>) of natural;

  -- Takes a natural array of lengths and returns an index array with similar
  -- semantics to Arrow index buffers. That is, the output is one entry longer
  -- than the input, the first (low) entry is zero, the last (high) entry is
  -- the sum of the sizes array, and the values in between are the sum of the
  -- sizes array up to the index.
  function cumul(sizes: nat_array) return nat_array;

  -- Returns the sum of an array of naturals.
  function sum(nats: nat_array) return natural;

  -- Returns (s ? t : f).
  function sel(s: boolean; t: integer;          f: integer)          return integer;
  function sel(s: boolean; t: boolean;          f: boolean)          return boolean;
  function sel(s: boolean; t: std_logic_vector; f: std_logic_vector) return std_logic_vector;
  function sel(s: boolean; t: unsigned;         f: unsigned)         return unsigned;
  function sel(s: boolean; t: signed;           f: signed)           return signed;
  function sel(s: boolean; t: std_logic;        f: std_logic)        return std_logic;

  -- Min/max functions.
  function imin(a: integer; b: integer) return integer;
  function imax(a: integer; b: integer) return integer;

  -- Returns ceil(log2(i)).
  function log2ceil(i: natural) return natural;

  -- Returns floor(log2(i)).
  function log2floor(i: natural) return natural;

  -- Returns (n + d - 1) / d == ceil(n / d).
  function divCeil(n: natural; d: natural) return natural;

  -- Returns a with its byte endianness swapped.
  function endianSwap(a : in std_logic_vector) return std_logic_vector;

  -- Returns the number of '1''s in a
  function countOnes(a : in std_logic_vector) return natural;

  -- Returns the first integer multiple of 2^b below or equal to a
  function alignDown(a : in unsigned; b : in natural) return unsigned;

  -- Returns the first integer multiple of 2^b above or equal to a
  function alignUp(a : in unsigned; b : in natural) return unsigned;

  -- Returns true if a is an integer multiple of 2^b, false otherwise
  function isAligned(a : in unsigned; b : natural) return boolean;

  -- Returns the one-hot encoded version of a count with implicit '1' MSB
  function cnt2oh(a: in unsigned; bits : natural) return std_logic_vector;

  -- Returns the count with implicit '1' MSB of a one-hot encoded value
  function oh2cnt(a: in std_logic_vector) return unsigned;

end UtilInt_pkg;

package body UtilInt_pkg is

  function cumul(sizes: nat_array) return nat_array is
    variable result : nat_array(sizes'length downto 0);
  begin
    result(0) := 0;
    for i in 0 to sizes'length-1 loop
      result(i+1) := result(i) + sizes(i);
    end loop;
    return result;
  end function;

  function sum(nats: nat_array) return natural is
    variable res  : natural;
  begin
    res := 0;
    for i in nats'range loop
      res := res + nats(i);
    end loop;
    return res;
  end function;

  function sel(s: boolean; t: integer; f: integer) return integer is
  begin
    if s then
      return t;
    else
      return f;
    end if;
  end function;

  function sel(s: boolean; t: boolean; f: boolean) return boolean is
  begin
    if s then
      return t;
    else
      return f;
    end if;
  end function;

  function sel(s: boolean; t: std_logic_vector; f: std_logic_vector) return std_logic_vector is
  begin
    if s then
      return t;
    else
      return f;
    end if;
  end function;

  function sel(s: boolean; t: unsigned; f: unsigned) return unsigned is
  begin
    if s then
      return t;
    else
      return f;
    end if;
  end function;

  function sel(s: boolean; t: signed; f: signed) return signed is
  begin
    if s then
      return t;
    else
      return f;
    end if;
  end function;

  function sel(s: boolean; t: std_logic; f: std_logic) return std_logic is
  begin
    if s then
      return t;
    else
      return f;
    end if;
  end function;

  function imin(a: integer; b: integer) return integer is
  begin
    return sel(a < b, a, b);
  end function;

  function imax(a: integer; b: integer) return integer is
  begin
    return sel(a > b, a, b);
  end function;

  function log2ceil(i: natural) return natural is
    variable x, y : natural;
  begin
    x := i;
    y := 0;
    while x > 1 loop
      x := (x + 1) / 2;
      y := y + 1;
    end loop;
    return y;
  end function;

  function log2floor(i: natural) return natural is
    variable x, y : natural;
  begin
    x := i;
    y := 0;
    while x > 1 loop
      x := x / 2;
      y := y + 1;
    end loop;
    return y;
  end function;

  function divCeil(n: natural; d: natural) return natural is
  begin
    return (n + d - 1) / d;
  end function;

  function endianSwap(a : in std_logic_vector) return std_logic_vector is
    variable result         : std_logic_vector(a'range);
    constant bytes          : natural := a'length / 8;
  begin
    for i in 0 to bytes - 1 loop
      result(8 * i + 7 downto 8 * i) := a((bytes - 1 - i) * 8 + 7 downto (bytes - 1 - i) * 8);
    end loop;
    return result;
  end function;

  function countOnes(a : in std_logic_vector) return natural is
    variable result : natural := 0;
  begin
    for i in a'range loop
      if a(i) = '1' then
        result := result + 1;
      end if;
    end loop;
    return result;
  end function;

  function alignDown(a : in unsigned; b : in natural) return unsigned is
    variable arg_v : unsigned(a'length-1 downto 0);
  begin
    if b /= 0 then
      arg_v := shift_right(a,b);
    else
      arg_v := a;
    end if;
    return shift_left(arg_v, b);
  end function;

  function alignUp(a : in unsigned; b : in natural) return unsigned is
    variable arg_v : unsigned(a'length-1 downto 0);
    variable lsb_v : unsigned(b-1 downto 0);
  begin
    -- Do this all over again because xsim seems to have trouble
    -- with specific functions in functions so we cant use
    -- shift_right_round_up
    if b /= 0 then -- prevent null ranges on lsb_v
      arg_v := shift_right(a, b);
      lsb_v := a(b-1 downto 0);
      if (lsb_v /= 0) then
        arg_v := arg_v + 1;
      end if;
    else
      arg_v := a;
    end if;
    return shift_left(arg_v, b);
  end function;

  function isAligned(a : in unsigned; b : natural) return boolean is
    variable lsb_v : unsigned(b-1 downto 0);
  begin
    if b > 0 then
      lsb_v := a(b-1 downto 0);
      if (lsb_v = 0) then
        return true;
      else
        return false;
      end if;
    else
      return true;
    end if;
  end function;

  function cnt2oh(a: in unsigned; bits: natural) return std_logic_vector is
    type ret_array_type is array(0 to bits-1) of std_logic_vector(bits-1 downto 0);
    variable ret_array : ret_array_type;
  begin
    for i in 0 to bits-1 loop
      for j in 0 to i loop
        ret_array(i)(j) := '1';
      end loop;
      for j in i to bits-1 loop
        ret_array(i)(j) := '0';
      end loop;
    end loop;

    -- all zeros is max count
    ret_array(0) := (others => '1');

    return ret_array(to_integer(a) mod bits);
  end function;

  function oh2cnt(a: in std_logic_vector) return unsigned is
    variable cnt : unsigned(log2ceil(a'length)-1 downto 0) := (others => '0');
  begin
    for i in 0 to a'length-1 loop
      if a(i) = '1' then
        cnt := cnt or to_unsigned(i, log2ceil(a'length));
      end if;
    end loop;
    return cnt;
  end function;

end UtilInt_pkg;
