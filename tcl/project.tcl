################################################################################
# University of Florida Senior Design Stereo Vision Project
# Steven Long and Adam Perkins
# 14 Feb 2016
################################################################################
#
################################################################################

# Create project to interface camera module
create_project project G:/zynq_project/camera2640_project -part xc7z020clg484-1
set_property board_part em.avnet.com:zed:part0:1.3 [current_project]
set_property target_language VHDL [current_project]

# Add the IP repo for the custom camera module
set_property  ip_repo_paths  G:/zynq_project/repo [current_project]
update_ip_catalog

# Create the block digram to build the project
create_bd_design "design_1"

# Add the Zynq system, config it for the zedBoard, and run block automation
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" }  [get_bd_cells processing_system7_0]
set_property -dict [list CONFIG.preset {ZedBoard}] [get_bd_cells processing_system7_0]
set_property -dict [list CONFIG.PCW_USE_S_AXI_HP0 {1}] [get_bd_cells processing_system7_0]
endgroup

# Add the custom camera module
startgroup
create_bd_cell -type ip -vlnv xilinx.com:user:camera2640_module:1.0 camera2640_module_0
endgroup

# Add the DMA, configure, and run block automation
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_0
set_property -dict [list CONFIG.c_include_sg {0} CONFIG.c_include_mm2s {0} CONFIG.c_sg_include_stscntrl_strm {0}] [get_bd_cells axi_dma_0]
endgroup

# Connect the camera module to the DMA and DMA to Zynq
startgroup
connect_bd_intf_net [get_bd_intf_pins camera2640_module_0/m_axis] [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/axi_dma_0/M_AXI_S2MM" Clk "Auto" }  [get_bd_intf_pins processing_system7_0/S_AXI_HP0]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins axi_dma_0/S_AXI_LITE]
connect_bd_net [get_bd_pins camera2640_module_0/m_axis_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net [get_bd_pins camera2640_module_0/m_axis_aresetn] [get_bd_pins processing_system7_0_axi_periph/M00_ARESETN]
endgroup

# Create external connections
startgroup
create_bd_port -dir I capture
connect_bd_net [get_bd_pins /camera2640_module_0/capture] [get_bd_ports capture]
create_bd_port -dir I vsync
connect_bd_net [get_bd_pins /camera2640_module_0/vsync] [get_bd_ports vsync]
create_bd_port -dir I href
connect_bd_net [get_bd_pins /camera2640_module_0/href] [get_bd_ports href]
create_bd_port -dir I pclk
connect_bd_net [get_bd_pins /camera2640_module_0/pclk] [get_bd_ports pclk]
create_bd_port -dir I -from 7 -to 0 data_in
connect_bd_net [get_bd_pins /camera2640_module_0/data_in] [get_bd_ports data_in]
create_bd_port -dir IO sda
connect_bd_net [get_bd_pins /camera2640_module_0/sda] [get_bd_ports sda]
create_bd_port -dir IO scl
connect_bd_net [get_bd_pins /camera2640_module_0/scl] [get_bd_ports scl]
create_bd_port -dir O -from 3 -to 0 debug
connect_bd_net [get_bd_pins /camera2640_module_0/debug] [get_bd_ports debug]
endgroup

# Clean up the display
regenerate_bd_layout
