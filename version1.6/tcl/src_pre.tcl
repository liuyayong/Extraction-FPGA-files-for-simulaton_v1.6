
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
set start_time_ms [write_log "src_pre start"];
puts "$start_time_ms";
# --------------------------------------------------------

# 1 将当前工程中的核容器（enable core container）设置的ip核解除核容器设置（disenable core container）
current_project
convert_ips -force -from_core_container [get_ips]
# 2 下面指令获得的文件是工程中用到的文件，即顶层构成层级例化关系的文件，也就是仿真文件的来源，包括设计源文件和ip核文件
# 采用相对路径
# 仿真文件的依据
current_project
set source_report_compile_order ../others
report_compile_order -of [get_filesets sources_1] -used_in synthesis -file $source_report_compile_order/report.txt -append
pwd;
# --------------------------------------------------------
set end_time_ms [write_log "src_pre done"];
puts "$end_time_ms";
set run_time [expr {$end_time_ms - $start_time_ms}];
puts " Execution time of the src_pre operation:\n$run_time";
return $run_time;