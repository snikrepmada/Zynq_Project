-- (c) Copyright 1995-2016 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- DO NOT MODIFY THIS FILE.

-- IP VLNV: xilinx.com:user:camera2640_module:1.0
-- IP Revision: 2

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY design_1_camera2640_module_0_0 IS
  PORT (
    capture : IN STD_LOGIC;
    sda : INOUT STD_LOGIC;
    scl : INOUT STD_LOGIC;
    vsync : IN STD_LOGIC;
    href : IN STD_LOGIC;
    pclk : IN STD_LOGIC;
    data_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    debug : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_tstrb : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axis_tlast : OUT STD_LOGIC;
    m_axis_tvalid : OUT STD_LOGIC;
    m_axis_tready : IN STD_LOGIC;
    m_axis_aclk : IN STD_LOGIC;
    m_axis_aresetn : IN STD_LOGIC
  );
END design_1_camera2640_module_0_0;

ARCHITECTURE design_1_camera2640_module_0_0_arch OF design_1_camera2640_module_0_0 IS
  ATTRIBUTE DowngradeIPIdentifiedWarnings : string;
  ATTRIBUTE DowngradeIPIdentifiedWarnings OF design_1_camera2640_module_0_0_arch: ARCHITECTURE IS "yes";

  COMPONENT camera2640_module_v1_0 IS
    GENERIC (
      WIDTH : INTEGER;
      DELAY : INTEGER;
      NUMBER_OF_PIXELS : INTEGER
    );
    PORT (
      capture : IN STD_LOGIC;
      sda : INOUT STD_LOGIC;
      scl : INOUT STD_LOGIC;
      vsync : IN STD_LOGIC;
      href : IN STD_LOGIC;
      pclk : IN STD_LOGIC;
      data_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      debug : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      m_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m_axis_tstrb : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      m_axis_tlast : OUT STD_LOGIC;
      m_axis_tvalid : OUT STD_LOGIC;
      m_axis_tready : IN STD_LOGIC;
      m_axis_aclk : IN STD_LOGIC;
      m_axis_aresetn : IN STD_LOGIC
    );
  END COMPONENT camera2640_module_v1_0;
  ATTRIBUTE X_CORE_INFO : STRING;
  ATTRIBUTE X_CORE_INFO OF design_1_camera2640_module_0_0_arch: ARCHITECTURE IS "camera2640_module_v1_0,Vivado 2015.4";
  ATTRIBUTE CHECK_LICENSE_TYPE : STRING;
  ATTRIBUTE CHECK_LICENSE_TYPE OF design_1_camera2640_module_0_0_arch : ARCHITECTURE IS "design_1_camera2640_module_0_0,camera2640_module_v1_0,{}";
  ATTRIBUTE CORE_GENERATION_INFO : STRING;
  ATTRIBUTE CORE_GENERATION_INFO OF design_1_camera2640_module_0_0_arch: ARCHITECTURE IS "design_1_camera2640_module_0_0,camera2640_module_v1_0,{x_ipProduct=Vivado 2015.4,x_ipVendor=xilinx.com,x_ipLibrary=user,x_ipName=camera2640_module,x_ipVersion=1.0,x_ipCoreRevision=2,x_ipLanguage=VHDL,x_ipSimLanguage=MIXED,WIDTH=32,DELAY=32,NUMBER_OF_PIXELS=76800}";
  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_INFO OF m_axis_tdata: SIGNAL IS "xilinx.com:interface:axis:1.0 m_axis TDATA";
  ATTRIBUTE X_INTERFACE_INFO OF m_axis_tstrb: SIGNAL IS "xilinx.com:interface:axis:1.0 m_axis TSTRB";
  ATTRIBUTE X_INTERFACE_INFO OF m_axis_tlast: SIGNAL IS "xilinx.com:interface:axis:1.0 m_axis TLAST";
  ATTRIBUTE X_INTERFACE_INFO OF m_axis_tvalid: SIGNAL IS "xilinx.com:interface:axis:1.0 m_axis TVALID";
  ATTRIBUTE X_INTERFACE_INFO OF m_axis_tready: SIGNAL IS "xilinx.com:interface:axis:1.0 m_axis TREADY";
  ATTRIBUTE X_INTERFACE_INFO OF m_axis_aclk: SIGNAL IS "xilinx.com:signal:clock:1.0 m_axis_CLK CLK";
  ATTRIBUTE X_INTERFACE_INFO OF m_axis_aresetn: SIGNAL IS "xilinx.com:signal:reset:1.0 m_axis_RST RST";
BEGIN
  U0 : camera2640_module_v1_0
    GENERIC MAP (
      WIDTH => 32,
      DELAY => 32,
      NUMBER_OF_PIXELS => 76800
    )
    PORT MAP (
      capture => capture,
      sda => sda,
      scl => scl,
      vsync => vsync,
      href => href,
      pclk => pclk,
      data_in => data_in,
      debug => debug,
      m_axis_tdata => m_axis_tdata,
      m_axis_tstrb => m_axis_tstrb,
      m_axis_tlast => m_axis_tlast,
      m_axis_tvalid => m_axis_tvalid,
      m_axis_tready => m_axis_tready,
      m_axis_aclk => m_axis_aclk,
      m_axis_aresetn => m_axis_aresetn
    );
END design_1_camera2640_module_0_0_arch;
