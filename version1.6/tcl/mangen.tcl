
# 功能：手写代码 仿真文件获取


# s
# proc write_log {op_name} {
    # set ts [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]
    # set fh [open "log.txt" a]
    # puts $fh "$op_name:$ts"
    # close $fh
# }


set start_time_ms 0;
set end_time_ms 0;
# ms
# 功能：将操作时间保存到 log.txt 文件中。 返回 当前操作时间 (ms)。
proc write_log {op_name} {
    set t [clock milliseconds]
	puts "t:$t";
    set sec [expr {$t / 1000}]
    set ms  [expr {$t % 1000}]
    set ts [format "%s.%03d" [clock format $sec -format "%Y-%m-%d %H:%M:%S"] $ms]
    set fh [open "../others/log.txt" a]
    puts $fh "$op_name:$ts"
    close $fh
	return $t
}
# 使用示例
# write_log "mangen"
set start_time_ms [write_log "mangen start"];
puts "$start_time_ms";

# --------------------------------------------------------
# --------------------------------------------------------
# 1 指定当前工程
pwd;
current_project
# 2 过滤出top及与top层有例化关系的手写代码
# 声明一个列表
set design_src_files [list]
# 从[get_files]中过滤出手写代码的仿真文件路径
# 设计源文件的文件集（sources_1）
# 编译顺序 -compile_order -used_in配合使用确定编译阶段
# -filter中通过属性FILE_TYPE过滤源文件类型
set files [get_files -of_objects [get_filesets sources_1]\
-compile_order sources -used_in synthesis \
-filter {(FILE_TYPE == "Verilog")||(FILE_TYPE == "VHDL")}]
# 将文件添加到列表中
# 去除重复操作
set design_src_files [lsort -unique $files]
# 打印文件列表
foreach file $design_src_files {
	puts "$file"
}
# 3将手写设计源文件保存到指定路径
# 相对路径
set mangen ../mangen
foreach file $design_src_files {
	file copy $file $mangen
}
#after 3000;#3s


# --------------------------------------------------------
set end_time_ms [write_log "mangen done"];
puts "$end_time_ms";
set run_time [expr {$end_time_ms - $start_time_ms}];
puts " Execution time of the mangen operation:\n$run_time";

return $run_time;