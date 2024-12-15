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
--------------------------------------------------------------------------------

library ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

PACKAGE mult_add_pipeline_ccs_out_buf_wait_pkg_v5 IS

COMPONENT mult_add_pipeline_ccs_out_buf_wait_v5
  GENERIC (
    rscid   :  INTEGER := 1;
    width   :  INTEGER := 8;
    ph_clk  :  INTEGER RANGE 0 TO 1 := 1;
    ph_en   :  INTEGER RANGE 0 TO 1 := 1;
    ph_arst :  INTEGER RANGE 0 TO 1 := 1;
    ph_srst :  INTEGER RANGE 0 TO 1 := 1;
    rst_val :  INTEGER := 0
  );
  PORT (
    clk     : IN  std_logic;
    en      : IN  std_logic;
    arst    : IN  std_logic;
    srst    : IN  std_logic;
    dat     : OUT std_logic_vector(width-1 DOWNTO 0);
    irdy    : OUT std_logic;
    vld     : OUT std_logic;
    idat    : IN  std_logic_vector(width-1 DOWNTO 0);
    rdy     : IN  std_logic;
    ivld    : IN  std_logic;
    is_idle : OUT std_logic
   );
END COMPONENT;

END mult_add_pipeline_ccs_out_buf_wait_pkg_v5;

library ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all; -- Prevent STARC 2.1.1.2 violation


ENTITY mult_add_pipeline_ccs_out_buf_wait_v5 IS
  GENERIC (
    rscid   :  INTEGER := 1;
    width   :  INTEGER := 8;
    ph_clk  :  INTEGER RANGE 0 TO 1 := 1;
    ph_en   :  INTEGER RANGE 0 TO 1 := 1;
    ph_arst :  INTEGER RANGE 0 TO 1 := 1;
    ph_srst :  INTEGER RANGE 0 TO 1 := 1;
    rst_val :  INTEGER := 0
  );
  PORT (
    clk     : IN  std_logic;
    en      : IN  std_logic;
    arst    : IN  std_logic;
    srst    : IN  std_logic;
    dat     : OUT std_logic_vector(width-1 DOWNTO 0);
    irdy    : OUT std_logic;
    vld     : OUT std_logic;
    idat    : IN  std_logic_vector(width-1 DOWNTO 0);
    rdy     : IN  std_logic;
    ivld    : IN  std_logic;
    is_idle : OUT std_logic
  );
END mult_add_pipeline_ccs_out_buf_wait_v5;

ARCHITECTURE beh OF mult_add_pipeline_ccs_out_buf_wait_v5 IS
  SIGNAL filled     :  std_logic;
  SIGNAL filled_next:  std_logic;

  SIGNAL abuf       :  std_logic_vector(width-1 DOWNTO 0);
  SIGNAL active     :  std_logic;
  SIGNAL lbuf       :  std_logic;
  SIGNAL lbuf_next  :  std_logic;
  SIGNAL is_idle_drv:  std_logic;
  SIGNAL irdy_int   :  std_logic;
  SIGNAL vld_int    :  std_logic;
BEGIN

  lbuf_next <= NOT vld_int OR rdy;
  filled_next <= ivld WHEN lbuf = '1' ELSE filled;

  irdy_int <= lbuf_next;
  irdy <= irdy_int;

  vld_int <= filled_next;
  vld <= vld_int;
  dat <= idat WHEN lbuf = '1' ELSE abuf;

  active <= (irdy_int AND ivld) OR (rdy AND vld_int);
  is_idle_drv <= NOT active AND NOT lbuf;

  lbufProc: PROCESS(lbuf, lbuf_next, is_idle_drv)
  BEGIN
    IF (lbuf = lbuf_next) THEN
      is_idle <= is_idle_drv;
    ELSE
      is_idle <= '0';
    END IF;
  END PROCESS;


  POSEDGE: IF ph_clk=1 GENERATE
    STATEPOS: PROCESS ( clk, arst )
    BEGIN
      IF conv_integer(arst) = ph_arst THEN
        filled <= '0';
        lbuf <= '0';
      ELSIF clk'EVENT AND clk = '1' THEN
        IF conv_integer(srst) = ph_srst THEN
          filled <= '0';
          lbuf <= '0';
        ELSIF conv_integer(en) = ph_en THEN
          filled <= filled_next;
          lbuf <= lbuf_next;
        END IF;
      END IF;
    END PROCESS;

    BUFPOS: PROCESS ( clk, arst )
    BEGIN
      IF conv_integer(arst) = ph_arst THEN
        abuf <= conv_std_logic_vector(rst_val, width);
      ELSIF clk'EVENT AND clk = '1' THEN
        IF conv_integer(srst) = ph_srst THEN
          abuf <= conv_std_logic_vector(rst_val, width);
        ELSIF (conv_integer(en) = ph_en) AND (conv_integer(lbuf) = 1) THEN
          abuf <= idat;
        END IF;
      END IF;
    END PROCESS;
  END GENERATE;

  NEGEDGE: IF ph_clk=0 GENERATE
    STATENEG: PROCESS ( clk, arst )
    BEGIN
      IF conv_integer(arst) = ph_arst THEN
        filled <= '0';
        lbuf <= '0';
      ELSIF clk'EVENT AND clk = '0' THEN
        IF conv_integer(srst) = ph_srst THEN
          filled <= '0';
          lbuf <= '0';
        ELSIF conv_integer(en) = ph_en THEN
          filled <= filled_next;
          lbuf <= lbuf_next;
        END IF;
      END IF;
    END PROCESS;

    BUFNEG: PROCESS ( clk, arst )
    BEGIN
      IF conv_integer(arst) = ph_arst THEN
        abuf <= conv_std_logic_vector(rst_val, width);
      ELSIF clk'EVENT AND clk = '0' THEN
        IF conv_integer(srst) = ph_srst THEN
          abuf <= conv_std_logic_vector(rst_val, width);
        ELSIF (conv_integer(en) = ph_en) AND (conv_integer(lbuf) = 1) THEN
          abuf <= idat;
        END IF;
      END IF;
    END PROCESS;
  END GENERATE;
END beh;

