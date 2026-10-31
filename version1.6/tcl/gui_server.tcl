#!/usr/bin/env tclsh
package require Tk

# 配置 tk_tunnel 包路径 (根据你的安装路径修改)

#**********************************************
# 1 变量初始化
set initialization_tcl_gui {
	# 控制变量
	set ::global_var_1 "";
	set ::tcl_path ""           ;# tcl path
	set ::pending_cmd ""        ;# 待执行的命令
	set ::result ""             ;# 命令执行结果
	set ::vivado_connected 0   ;# 连接标志变量:由Vivado 置 1：vivado 端（客户机）成功连接到Tcl端（服务器端）
	set ::poll_loop_startup 0   ;# start_poll_loop 轮询循环 启动标志变量：由 Vivado端 start_poll_loop 置 1：启动标志变量
}
#**********************************************
# 2 通信部分
# 成功、占用、启动失败三种情况都用弹窗告知用户，同时保留 puts 输出到控制台，方便日志排查。
set communication_tcl_start_server {
    set tk_tunnel_root "E:/vivado2018_3/Vivado/2018.3/data/XilinxTclStore/tclapp/xilinx"
    set auto_path [linsert $auto_path 0 $tk_tunnel_root]

    # Load the tk_tunnel package
    package require ::tclapp::xilinx::tk_tunnel

    # ---- Port availability check ----
    set port 9001
    set port_available 1
    if {[catch {socket -server {} $port} testChan]} {
        set port_available 0
        puts "\[WARNING\] Port $port is already in use. Cannot start the server."
        puts "          Error: $testChan"
        tk_messageBox -icon warning -type ok -title "Port In Use" \
            -message "Port $port is already in use. Cannot start the server.\n\nPlease close the program occupying this port, or use a different port and try again."
    } else {
        # Port is free; close the temporary channel and hand it over to tk_tunnel
        close $testChan
    }

    if {!$port_available} {
        # Port is occupied; stop here after showing the warning
        return
    }

    # GUI side acts as the server; Vivado connects to it as the client
    if {[catch {::tclapp::xilinx::tk_tunnel::start_server $port} err]} {
        puts "\[ERROR\] Failed to start the tk_tunnel server: $err"
        tk_messageBox -icon error -type ok -title "Startup Failed" \
            -message "Failed to start the tk_tunnel server:\n\n$err"
    } 
}
#**********************************************
namespace eval tcl_gui {}
proc send_command {cmd} {
    global tcl_path
    global pending_cmd
    global result
    global vivado_connected   ;# 建议在 start_server 成功后由客户端连接时置为 1
    global poll_loop_startup   ;# 建议在 start_server 成功后由客户端连接时置为 1

    # ---- 客户端连接检测 ----
    # 方式一：若你已维护连接标志变量，直接检查
    if {![info exists ::vivado_connected] || !$::vivado_connected} {
        # tk_messageBox -icon warning -type ok -title "Client Not Connected" \
            # -message "Vivado side (client) is not connected to the Tcl side.\n\nPlease confirm the connection is established before triggering any button operation."
        # return "Error: Vivado client not connected"
        return "Error: Vivado client not connected. \n\n Suggestion: Please confirm the connection is established before triggering any button operation."
    }
    # ---- 启动轮询循环检测 ----
    if {![info exists ::poll_loop_startup] || !$::poll_loop_startup} {
        # tk_messageBox -icon warning -type ok -title "poll loop mechanism Not startup" \
            # -message "Vivado side (client) is not startup poll loop mechanism.\n\nPlease confirm the poll loop mechanism is established before triggering any button operation."
        return "Error: poll loop mechanism not startup in Vivado client. \n\n Suggestion:  Please confirm the poll loop mechanism is established before triggering any button operation."
    }
    # 清空旧结果
    set ::result ""
    # 设置待执行命令
    set ::pending_cmd $cmd
    set ::tcl_path ${tcl_path}

    # 等待 Vivado 执行并返回结果（轮询）
    set timeout 0
    set max_timeout 25  ;# 2.5秒超时

    while {$timeout < $max_timeout} {
        after 100
        update
        if {$::result ne ""} {
            set ret $::result
            set ::result ""
            return $ret
        }
        incr timeout
    }

    return "Error:Command execution timeout"
}


#**********************************************
proc end_server_listenning {} {
	# 定义端口
	set port 9001

	# 创建临时批处理文件
	set bat_file [file join [pwd] "kill_port_temp.bat"]

	# 写入批处理内容（注意：批处理中变量用 %%a）
	set bat_content "for /f \"tokens=5\" %%a in ('netstat -ano ^| findstr \" :$port \" ^| findstr LISTENING') do taskkill /PID %%a /F"

	# 写入文件
	set fh [open $bat_file "w"]
	puts $fh $bat_content
	close $fh

	# 执行批处理文件（静默）
	exec cmd.exe /c $bat_file

	# 执行完毕后删除临时文件
	after 500;
	file delete $bat_file
}


#**********************************************
# 获取当前脚本的完整路径
set script_path [file normalize [info script]];
# 提取所在目录
set script_dir [file dirname $script_path];
puts "$script_path";
puts "$script_dir";
cd $script_dir;
pwd;

# cd E:/tcl/lianxi_003/tcl;

set tcl_gui {
	# 3 gui
	set	global_var_1 [toplevel .gui_server];
	# 设置global_var_6位置和大小
	# 400x300大小，位置在x=100, y=50
	wm geometry $global_var_1 "800x400+700+300"
	# labelframe
	# tcl path
	labelframe $global_var_1.labelframe_1 -text "tcl path";
	# work flow
	labelframe $global_var_1.labelframe_2 -text "work flow";
	# special control
	labelframe $global_var_1.labelframe_3 -text "special control";
	# version info
	labelframe $global_var_1.labelframe_4 -text "version info";

	# tcl path
	entry	$global_var_1.labelframe_1.entry_1 -bg pink -textvariable tcl_path; 
	label	$global_var_1.labelframe_1.label_1 -textvariable vivado_work_dir -width 20 -bg white;
	button  $global_var_1.labelframe_1.button_1 -text "cd_to_tcl" -width 15 -relief raised -bd 7 -command {
		set result [send_command {cd_to_tcl}]
	}

	button  $global_var_1.labelframe_1.button_2 -text "vivado work dir" -width 15 -relief raised -bd 7 -command {
		set result [send_command {pwd}];
		set vivado_work_dir $result;
	}
	# work flow
	# src_pre
	button	$global_var_1.labelframe_2.button_3 -text "src_pre" -width 15  -relief raised -bd 7 -command {
		set result [send_command {source src_pre.tcl}]
		tk_messageBox -message "src_pre done,time taken(ms):\n$result"
	}
	
	# mangen
	button	$global_var_1.labelframe_2.button_4 -text "mangen" -width 15  -relief raised -bd 7 -command {
		set result [send_command {source mangen.tcl}]
		tk_messageBox -message "mangen done,time taken(ms):\n$result"
	}

	# corgen
	button	$global_var_1.labelframe_2.button_5 -text "corgen" -width 15  -relief raised -bd 7 -command {
		set result [send_command {source corgen.tcl}]
		tk_messageBox -message "corgen done,time taken(ms):\n$result"
	}
	# special control
	button	$global_var_1.labelframe_3.button_6 -text "exit polling" -width 15  -relief raised -bd 7 -command {
		set result [send_command "EXIT_POLL"]
	}
	button	$global_var_1.labelframe_3.button_7 -text "get_ips"  -width 15 -relief raised -bd 7 -command {
		set result [send_command "get_ips"]
		tk_messageBox -message "IPs list:\n$result"
	}
	# current_project
	button	$global_var_1.labelframe_3.button_8 -text "current_project"  -width 15 -relief raised -bd 7 -command {
		set result [send_command "current_project"];
		tk_messageBox -message "current project:\n$result"
	}
	# end server listenning
	button	$global_var_1.labelframe_3.button_9 -text "end server listenning"  -width 15 -relief raised -bd 7 -command {
		end_server_listenning;
	}
	# bind $global_var_6.labelframe_3.button_9 <Button-1> {control_pad::quit_force_cmd}
	# version info
	label	$global_var_1.labelframe_4.label_1 -text "version 1.6" -width 15;

	# grid/pack/place
	pack $global_var_1.labelframe_1\
		 $global_var_1.labelframe_2\
		 $global_var_1.labelframe_3\
		 $global_var_1.labelframe_4 -side top -fill x -padx 20;
	# 第一行
	# labelframe_1
	grid $global_var_1.labelframe_1.entry_1 	-row 0 -column 0 -sticky nswe
	grid $global_var_1.labelframe_1.button_1 	-row 0 -column 1 -sticky nswe
	grid columnconfigure $global_var_1.labelframe_1 {0} -weight 1
	grid $global_var_1.labelframe_1.label_1     -row 1 -column 0 -sticky nswe
	grid $global_var_1.labelframe_1.button_2    -row 1 -column 1 -sticky nswe
	grid columnconfigure $global_var_1.labelframe_1 {0} -weight 1
	# labelframe_2
	pack $global_var_1.labelframe_2.button_3 \
		 $global_var_1.labelframe_2.button_4 \
		 $global_var_1.labelframe_2.button_5 -side left  -expand 1 -fill x
	# labelframe_3
	pack $global_var_1.labelframe_3.button_6 \
		 $global_var_1.labelframe_3.button_7 \
		 $global_var_1.labelframe_3.button_8 \
		 $global_var_1.labelframe_3.button_9 -side left -expand 1 -fill x
	# labelframe_4	 
	pack $global_var_1.labelframe_4.label_1  -side right
}
# run
eval $initialization_tcl_gui;
eval $communication_tcl_start_server;
eval $tcl_gui;
vwait forever;