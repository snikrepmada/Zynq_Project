#Create project to interface camera module

create_project camera_project G:/Zynq_Project/project -part xc7z020clg484-1
set_property board_part em.avnet.com:zed:part0:1.3 [current_project]
set_property target_language VHDL [current_project]

set_property  ip_repo_paths  G:/Zynq_Project/repo [current_project]
update_ip_catalog

create_bd_design "design_1"

startgroup
create_bd_cell -type ip -vlnv AP:user:camera2640_module:1.0 camera2640_module_0
endgroup
