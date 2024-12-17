# TCL File Generated by Component Editor 18.1
# Tue Dec 17 02:03:27 CET 2024
# DO NOT MODIFY


# 
# neopixel_alone_cinquante "neopixel_alone_cinquante" v1.50
#  2024.12.17.02:03:27
# 
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module neopixel_alone_cinquante
# 
set_module_property DESCRIPTION ""
set_module_property NAME neopixel_alone_cinquante
set_module_property VERSION 1.50
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME neopixel_alone_cinquante
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL DE10_Lite_Neopixel_50MHz_Alone
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file DE10_Lite_Neopixel_50MHz_Alone.vhd VHDL PATH ../../src/DE10_Lite_Neopixel_50MHz_Alone.vhd TOP_LEVEL_FILE


# 
# parameters
# 


# 
# display items
# 


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock CMSIS_SVD_VARIABLES ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock clk clk Input 1


# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset CMSIS_SVD_VARIABLES ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset reset_n reset_n Input 1


# 
# connection point avalon_alone
# 
add_interface avalon_alone conduit end
set_interface_property avalon_alone associatedClock clock
set_interface_property avalon_alone associatedReset ""
set_interface_property avalon_alone ENABLED true
set_interface_property avalon_alone EXPORT_OF ""
set_interface_property avalon_alone PORT_NAME_MAP ""
set_interface_property avalon_alone CMSIS_SVD_VARIABLES ""
set_interface_property avalon_alone SVD_ADDRESS_GROUP ""

add_interface_port avalon_alone commande commande_neopixel Output 1
add_interface_port avalon_alone nb_led nb_led Input 8

