set project_name "project_1"
set target_dir "../${project_name}"
# source dir is based on target dir
set source_dir "../src" 

# if target dir exists, remove the directory
if { [file exist $target_dir] } {
  file delete -force -- $target_dir
}
file mkdir $target_dir
cd $target_dir

create_project $project_name
set proj_dir [get_property directory [current_project]]

# Set project properties
set obj [get_projects $project_name]
set_property "board_part" "xilinx.com:zc706:part0:1.2" $obj
set_property "default_lib" "xil_defaultlib" $obj
set_property "sim.ip.auto_export_scripts" "1" $obj
set_property "simulator_language" "Mixed" $obj

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# create bd
source "${source_dir}/design_1.tcl"
save_bd_design

# generate block design
generate_target all [get_files  -filter { NAME =~ *.bd }]

# add top source
import_files -norecurse "${source_dir}/design_1_wrapper.v"
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# add constraints
add_files -fileset constrs_1 -norecurse "${source_dir}/pin.xdc"
import_files -fileset constrs_1 "${source_dir}/pin.xdc"

# run implementation
launch_runs impl_1 -to_step write_bitstream

# export
file mkdir project_1.sdk
file copy -force project_1.runs/impl_1/design_1_wrapper.sysdef project_1.sdk/design_1_wrapper.hdf


