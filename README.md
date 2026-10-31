# Extraction-FPGA-files-for-simulaton_v1.6
************************************************************
(1)Function
function: Extraction of RTL code and IP core files for FPGA simulation 
************************************************************
(2)Operating Instructions
1 run gui_server.tcl on Tcl 8.5 interpreter
2 on vivado 2018.3 Tcl Console:
cd E:/tcl;
source vivado_console.tcl;
note:
(1)destination file path in  E:/tcl
(2)If the destination  file path contains spaces, enclose the cd operation path in double or single quotes (e.g., cd 'E:/t cl' or cd "E:/t cl").
3 test procedure:
vivado work dir:to check vivado work directory(E:/tcl);
current_project:to check communication mechanism between tcl side(user side) and Vivado side;
4 Simulation file extraction procedure:
(Click the buttons in the following order)
src_pre->mangen->corgen/src_pre->corgen->mangen
5 exit procedure：
(Click the buttons in the following order)
exit polling->end server listenning
6 user can find the extracted results in corgen, mangen, others folder.
************************************************************
(3)version:1.6
update:
1 src_pre.tcl add "-used_in synthesis" restricion.
2. Add a completion prompt and display the time taken for the operation.
3. Save the operation time to the others/log.txt file.
Format:
Operation name start: time
Operation name done: time
************************************************************
(4)Applicable Vivado Versions (Verified)
Verified Vivado version range:
vivado2018.3~vivado2022.1
************************************************************
