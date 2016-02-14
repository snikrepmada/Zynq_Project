create_project managed_ip_project G:/zynq_project/repo/managed_ip_project -part xc7z020clg484-1 -ip

set_property board_part em.avnet.com:zed:part0:1.3 [current_project]
set_property target_language VHDL [current_project]
set_property target_simulator ModelSim [current_project]
create_peripheral xilinx.com user camera2640_module 1.0 -dir G:/zynq_project/repo
add_peripheral_interface m_axis -interface_mode master -axi_type stream [ipx::find_open_core xilinx.com:user:camera2640_module:1.0]
generate_peripheral [ipx::find_open_core xilinx.com:user:camera2640_module:1.0]
write_peripheral [ipx::find_open_core xilinx.com:user:camera2640_module:1.0]
set_property  ip_repo_paths  G:/zynq_project/repo/camera2640_module_1.0 [current_project]
update_ip_catalog -rebuild


update_compile_order -fileset sim_1
add_files -norecurse {G:/zynq_project/hdl/edge_detector.v G:/zynq_project/hdl/i2cm.vhd G:/zynq_project/hdl/camera_init.vhd G:/zynq_project/hdl/camera2640.vhd G:/zynq_project/hdl/capture_frame.vhd G:/zynq_project/hdl/ov2640reg_rom.vhd}
update_compile_order -fileset sources_1
create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.0 -module_name frame_fifo -dir g:/zynq_project/repo/camera2640_module_1.0/src
set_property -dict [list CONFIG.Fifo_Implementation {Independent_Clocks_Block_RAM} CONFIG.synchronization_stages {4} CONFIG.Input_Data_Width {8} CONFIG.Input_Depth {16384} CONFIG.Output_Data_Width {32} CONFIG.Almost_Full_Flag {true} CONFIG.Almost_Empty_Flag {true} CONFIG.Output_Depth {4096} CONFIG.Reset_Type {Asynchronous_Reset} CONFIG.Full_Flags_Reset_Value {1} CONFIG.Data_Count_Width {14} CONFIG.Write_Data_Count_Width {14} CONFIG.Read_Data_Count_Width {12} CONFIG.Full_Threshold_Assert_Value {16381} CONFIG.Full_Threshold_Negate_Value {16380}] [get_ips frame_fifo]
generate_target {instantiation_template} [get_files g:/zynq_project/repo/camera2640_module_1.0/src/frame_fifo/frame_fifo.xci]

update_compile_order -fileset sources_1
set_property generate_synth_checkpoint false [get_files  g:/zynq_project/repo/camera2640_module_1.0/src/frame_fifo/frame_fifo.xci]
generate_target all [get_files  g:/zynq_project/repo/camera2640_module_1.0/src/frame_fifo/frame_fifo.xci]

export_ip_user_files -of_objects [get_files g:/zynq_project/repo/camera2640_module_1.0/src/frame_fifo/frame_fifo.xci] -no_script -force -quiet
export_simulation -of_objects [get_files g:/zynq_project/repo/camera2640_module_1.0/src/frame_fifo/frame_fifo.xci] -directory g:/zynq_project/repo/managed_ip_project/managed_ip_project.tmp/camera2640_module_v1_0_v1_0_project/camera2640_module_v1_0_v1_0_project.ip_user_files/sim_scripts -force -quiet

ipx::merge_project_changes files [ipx::current_core]
ipx::merge_project_changes hdl_parameters [ipx::current_core]

launch_runs synth_1 -jobs 2
launch_runs impl_1 -jobs 2

set_property core_revision 2 [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
