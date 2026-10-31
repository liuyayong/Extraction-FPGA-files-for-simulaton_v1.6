
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
set start_time_ms [write_log "corgen start"];
puts "$start_time_ms";
# --------------------------------------------------------
# 功能：IP核 仿真文件获取 不包括时钟IP
# 1 top及与top文件有例化关系的IP核名称  注意 不包括时钟IP核
# 从src_pre report.txt文件中获取



# 1 获取 current_project 的设计文件中的IP核名称
# (A) 获取 current_project 的设计文件（手写RTL代码和IP核）
pwd;
current_project;
set ip_names {}; # 创建空列表
# 所有current_project 的设计文件（手写RTL代码和IP核）
set files [get_files -of_objects [get_filesets sources_1]\
-compile_order sources -used_in synthesis \
]
# 去除重复操作
set design_src_files [lsort -unique $files]
# 打印文件列表
foreach file $design_src_files {
	puts $file
}
# (B) 提取 IP 核名称 （正则表达式/regular expression）
# 最后一个 "/"到".dcp"之间的字符串

foreach file $design_src_files {
	if {[regexp {/([^/]+)\.dcp$} $file match filename]} {
		lappend ip_names $filename;
	}
}

foreach ip_name $ip_names {
	puts $ip_name;
}
# (C)将IP核名称保存到 ip_list.txt 
current_project;
set source_report_compile_order ../others
set fn $source_report_compile_order/ip_list.txt
set fid [open $fn a];
puts $fid "1 all ip names:";
foreach ip_name $ip_names {
	puts $fid $ip_name;
}
close $fid;
# 2 获取IP核（有synth文件夹）的IP核名称、（没有synth文件夹）的IP核名称
# (A) 获取IP核（有synth文件夹）的IP核名称、（没有synth文件夹）的IP核名称
set ip_synth_names     {}; # 空列表 存放 有synth文件夹的IP核名称
set ip_non_synth_names {}; # 空列表 存放 没有synth文件夹的IP核名称
foreach ip_name $ip_names {
	puts $ip_name;
	# 编译顺序 -compile_order -used_in 配合使用确定编译阶段 -of_objects 确定特定IP核
	set ip_name_files [get_files -compile_order sources -used_in synthesis \
	-of_objects [get_files $ip_name.xci]];
	# 提取含synth文件夹的IP核文件
	set flag -1;
	set flag [lsearch $ip_name_files */synth/*];
	if {$flag != -1} {
		puts $ip_name;
		lappend ip_synth_names $ip_name;
	} else {
		puts $ip_name;
		lappend ip_non_synth_names $ip_name;
	}
}
# (B) 将有synth文件的 IP核 名称保存到 ip_list.txt 中
set fid [open $fn a];# a （写文件访问模式）: 将始终访问位置设为文件尾，故新写入的内容将添加到原有内容之后
puts $fid "2 names that have synth folder:";
foreach ip_synth_name $ip_synth_names {
	puts $fid $ip_synth_name;
}
close $fid;
# (C) 将没有synth文件的ip核名称保存到 ip_list.txt 中
set fid [open $fn a];
puts $fid "3 names that don't have synth folder:";
foreach ip_non_synth_name $ip_non_synth_names {
	puts $fid $ip_non_synth_name;
}
close $fid;

# 3 获取IP核（有synth文件夹）仿真文件（synth文件夹中的.vhd）
# (A) 获取IP核（有synth文件夹）仿真文件（synth文件夹中的.vhd）

set ip_synth_files {}; #空列表
foreach ip_name $ip_names {
	puts $ip_name;
	# 编译顺序 -compile_order -used_in 配合使用确定编译阶段 -of_objects 确定特定IP核
	set ip_name_files [get_files -compile_order sources -used_in synthesis \
	-of_objects [get_files $ip_name.xci]]
	# 提取含 synth 文件夹的 ip 核文件
	set flag -1;
	set flag [lsearch $ip_name_files */synth/*];
	if {$flag != -1} {
		set ip_name_file [lsearch -inline $ip_name_files */synth/*];
		puts $ip_name_file;
		lappend ip_synth_files $ip_name_file;
	} 
}

# (B) 将所有synth文件的ip核文件保存到 ip_list.txt 中
set fid [open $fn a];
puts $fid " ********* 4 ip files that have synth folder: ********* "

foreach ip_synth_file $ip_synth_files {
	puts $fid $ip_synth_file;
}
close $fid;

# 4 将IP核（有synth文件夹的）对应的仿真文件提取保存到指定路径

set corgen ../corgen
foreach ip_synth_file $ip_synth_files {
	file copy $ip_synth_file $corgen
}
# 5 ip核（没有synth文件夹）仿真文件需要用户自己手动进行提取
# 此类ip核数量极为有限，常见的有：时钟ip核、温度采集XADC ip核
# 6 结束
# --------------------------------------------------------
set end_time_ms [write_log "corgen done"];
puts "$end_time_ms";
set run_time [expr {$end_time_ms - $start_time_ms}];
puts " Execution time of the corgen operation:\n$run_time";

return $run_time;

