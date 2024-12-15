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

PACKAGE mult_add_pipeline_ccs_in_pkg_v1 IS

COMPONENT mult_add_pipeline_ccs_in_v1
  GENERIC (
    rscid    :  INTEGER;
    width    :  INTEGER
  );
  PORT (
    idat   : OUT std_logic_vector(width-1 DOWNTO 0);
    dat    : IN  std_logic_vector(width-1 DOWNTO 0)
  );
END COMPONENT;

END mult_add_pipeline_ccs_in_pkg_v1;

library ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all; -- Prevent STARC 2.1.1.2 violation

ENTITY mult_add_pipeline_ccs_in_v1 IS
  GENERIC (
    rscid :  INTEGER;
    width :  INTEGER
  );
  PORT (
    idat  : OUT std_logic_vector(width-1 DOWNTO 0);
    dat   : IN  std_logic_vector(width-1 DOWNTO 0)
  );
END mult_add_pipeline_ccs_in_v1;

ARCHITECTURE beh OF mult_add_pipeline_ccs_in_v1 IS
BEGIN

  idat <= dat;

END beh;

