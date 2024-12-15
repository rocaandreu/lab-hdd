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
PACKAGE mult_add_pipeline_mgc_io_sync_pkg_v2 IS

COMPONENT mult_add_pipeline_mgc_io_sync_v2
  GENERIC (
    valid    :  INTEGER RANGE 0 TO 1
  );
  PORT (
    ld       : IN    std_logic;
    lz       : OUT   std_logic
  );
END COMPONENT;

END mult_add_pipeline_mgc_io_sync_pkg_v2;

library ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all; -- Prevent STARC 2.1.1.2 violation

ENTITY mult_add_pipeline_mgc_io_sync_v2 IS
  GENERIC (
    valid    :  INTEGER RANGE 0 TO 1
  );
  PORT (
    ld       : IN    std_logic;
    lz       : OUT   std_logic
  );
END mult_add_pipeline_mgc_io_sync_v2;

ARCHITECTURE beh OF mult_add_pipeline_mgc_io_sync_v2 IS
BEGIN

  lz <= ld;

END beh;

