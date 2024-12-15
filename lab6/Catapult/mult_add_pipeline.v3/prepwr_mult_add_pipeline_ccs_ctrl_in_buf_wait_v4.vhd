--------------------------------------------------------------------------------
-- Catapult Synthesis - Sample I/O Port Library
--
-- Copyright (c) 2003-2017 Mentor Graphics Corp.
--       All Rights Reserved
--
-- This document may be used and distributed without restriction provided that
-- this copyright statement is not removed from the file and that any derivative
-- work contains this copyright notice.
--
-- The design information contained in this file is intended to be an example
-- of the functionality which the end user may study in preparation for creating
-- their own custom interfaces. This design does not necessarily present a
-- complete implementation of the named protocol or standard.
--
-- Change History:
--    2019-01-04 - Fixed bug 54073 - rdy signal should not be asserted during
--                 reset
--    2018-11-19 - Improved code coverage of is_idle
--    2018-08-22 - Added is_idle to interface (as compared to
--                 ccs_ctrl_in_buf_wait_v2)
--    2018-07-05 - Fixed VHDL version to match Verilog
--------------------------------------------------------------------------------

library ieee;
USE ieee.std_logic_1164.all;
PACKAGE mult_add_pipeline_ccs_ctrl_in_buf_wait_pkg_v4 IS

COMPONENT mult_add_pipeline_ccs_ctrl_in_buf_wait_v4
  GENERIC (
    rscid    :  INTEGER := 1;
    width    :  INTEGER := 8;
    ph_clk   :  INTEGER RANGE 0 TO 1 := 1;
    ph_en    :  INTEGER RANGE 0 TO 1 := 1;
    ph_arst  :  INTEGER RANGE 0 TO 1 := 1;
    ph_srst  :  INTEGER RANGE 0 TO 1 := 1
  );
  PORT (
    clk     : IN  std_logic;
    en      : IN  std_logic;
    arst    : IN  std_logic;
    srst    : IN  std_logic;
    idat    : OUT std_logic_vector(width-1 DOWNTO 0);
    rdy     : OUT std_logic;
    ivld    : OUT std_logic;
    dat     : IN  std_logic_vector(width-1 DOWNTO 0);
    irdy    : IN  std_logic;
    vld     : IN  std_logic;
    is_idle : out std_logic
   );
END COMPONENT;

END mult_add_pipeline_ccs_ctrl_in_buf_wait_pkg_v4;

library ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all; -- Prevent STARC 2.1.1.2 violation

ENTITY mult_add_pipeline_ccs_ctrl_in_buf_wait_v4 IS
  GENERIC (
    rscid    :  INTEGER := 1;
    width    :  INTEGER := 8;
    ph_clk   :  INTEGER RANGE 0 TO 1 := 1;
    ph_en    :  INTEGER RANGE 0 TO 1 := 1;
    ph_arst  :  INTEGER RANGE 0 TO 1 := 1;
    ph_srst  :  INTEGER RANGE 0 TO 1 := 1
  );
  PORT (
    clk     : IN  std_logic;
    en      : IN  std_logic;
    arst    : IN  std_logic;
    srst    : IN  std_logic;
    idat    : OUT std_logic_vector(width-1 DOWNTO 0);
    rdy     : OUT std_logic;
    ivld    : OUT std_logic;
    dat     : IN  std_logic_vector(width-1 DOWNTO 0);
    irdy    : IN  std_logic;
    vld     : IN  std_logic;
    is_idle : OUT std_logic
  );
END mult_add_pipeline_ccs_ctrl_in_buf_wait_v4;

ARCHITECTURE beh OF mult_add_pipeline_ccs_ctrl_in_buf_wait_v4 IS
  SIGNAL filled     :  std_logic;
  SIGNAL filled_next:  std_logic;

  SIGNAL abuf       :  std_logic_vector(width-1 DOWNTO 0);
  SIGNAL lbuf       :  std_logic;
  SIGNAL active     :  std_logic;
  SIGNAL hs_init    :  std_logic;
  SIGNAL rdy_int    :  std_logic;
  SIGNAL vld_int    :  std_logic;
  SIGNAL ivld_int   :  std_logic;
BEGIN

  lbuf <= NOT filled OR irdy;
  filled_next <= vld_int WHEN lbuf = '1' ELSE filled;

  vld_int <= vld AND hs_init;
  rdy_int <= lbuf AND hs_init;
  rdy <= rdy_int;

  ivld_int <= filled_next;
  ivld <= ivld_int;
  idat <= abuf;

  active <= (rdy_int AND vld_int) OR (irdy AND ivld_int);
  is_idle <= NOT active AND NOT lbuf;

  POSEDGE: IF ph_clk=1 GENERATE
    STATEPOS: PROCESS ( clk, arst )
    BEGIN
      IF conv_integer(arst) = ph_arst THEN
        filled <= '0';
        hs_init <= '0';
      ELSIF clk'EVENT AND clk = '1' THEN
        IF conv_integer(srst) = ph_srst THEN
          filled <= '0';
          hs_init <= '0';
        ELSIF conv_integer(en) = ph_en THEN
          filled <= filled_next;
          hs_init <= '1';
        END IF;
      END IF;
    END PROCESS;

    BUFPOS: PROCESS ( clk, arst )
    BEGIN
      IF conv_integer(arst) = ph_arst THEN
        abuf  <= (others => '0');
      ELSIF clk'EVENT AND clk = '1' THEN
        IF conv_integer(srst) = ph_srst THEN
          abuf  <= (others => '0');
        ELSIF (conv_integer(en) = ph_en) AND (conv_integer(lbuf) = 1) THEN
          abuf <= dat;
        END IF;
      END IF;
    END PROCESS;
  END GENERATE;

  NEGEDGE: IF ph_clk=0 GENERATE
    STATENEG: PROCESS ( clk, arst )
    BEGIN
      IF conv_integer(arst) = ph_arst THEN
        filled <= '0';
        hs_init <= '0';
      ELSIF clk'EVENT AND clk = '0' THEN
        IF conv_integer(srst) = ph_srst THEN
          filled <= '0';
          hs_init <= '0';
        ELSIF conv_integer(en) = ph_en THEN
          filled <= filled_next;
          hs_init <= '1';
        END IF;
      END IF;
    END PROCESS;

    BUFNEG: PROCESS ( clk, arst )
    BEGIN
      IF conv_integer(arst) = ph_arst THEN
        abuf  <= (others => '0');
      ELSIF clk'EVENT AND clk = '0' THEN
        IF conv_integer(srst) = ph_srst THEN
          abuf  <= (others => '0');
        ELSIF (conv_integer(en) = ph_en) AND (conv_integer(lbuf) = 1) THEN
          abuf <= dat;
        END IF;
      END IF;
    END PROCESS;
  END GENERATE;
END beh;

