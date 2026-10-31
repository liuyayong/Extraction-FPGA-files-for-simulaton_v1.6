#*********************************************************************************
#*********************************************************************************
# 20260815
# --------------------------------------------------------------------------
# vivado端：client
# 1 通信部分 vivado -> tcl gui
# 当vivado作为客户机连接到Tcl端（服务器）后，通过 "set ::vivado_connected 1" 握手告知 Tcl端连接成功
set communication_vivado_start_client {
    package require ::tclapp::xilinx::tk_tunnel

    # 确保已连接（如果尚未连接，则连接）start_client
    if {[catch {::tclapp::xilinx::tk_tunnel::start_client localhost 9001} err]} {
        puts "\[ERROR\] Failed to connect to Tcl server: $err"
        return
    }
    puts "Vivado client linked to Tcl server on port 9001"

    # ---- 通知 Tcl 端：客户端已连接 ----
    # 发送一条握手命令，Tcl 端收到后将 vivado_connected 置为 1
    if {[catch {::tclapp::xilinx::tk_tunnel::rexec {set ::vivado_connected 1}} rexecErr]} {
        puts "\[WARNING\] Connected, but failed to notify Tcl server: $rexecErr"
    } else {
        puts "Tcl server has been notified of the connection."
    }

    # 2 定义过程、变量
    set tcl_path ""
}
# --------------------------------------------------------------------------
# 定义过程：启动轮询循环
proc ::start_poll_loop {} {
    global keep_running;
    global tcl_path;
    # ---- 通知 Tcl 端：已启动轮询循环 ----
    # 发送一条握手命令，Tcl 端收到后将 poll_loop_startup 置为 1
    if {[catch {::tclapp::xilinx::tk_tunnel::rexec {set ::poll_loop_startup 1}} rexecErr]} {
        puts "\[WARNING\] poll loop mechanism startuped, but failed to notify Tcl server: $rexecErr"
    } else {
        puts "Tcl server has been notified of the startup of poll loop mechanism."
    }
	# ---------------------------------
    puts "entering poll ..."
    set keep_running 1

    # 进入 while 循环（会阻塞 Console）
    while {$keep_running} {
        # 从 Tcl 端读取待执行命令（阻塞等待）
        set cmd [::tclapp::xilinx::tk_tunnel::rexec_wait {set ::pending_cmd}]
        set tcl_path [::tclapp::xilinx::tk_tunnel::rexec_wait {set ::tcl_path}]
        
        # 检查是否收到退出信号
        if {$cmd eq "EXIT_POLL"} {
            puts "Received exit polling signal"
            break;
        }
        
        # 如果命令为空，等待
        if {$cmd eq ""} {
            after 200;
            continue;
        }
		
        
        # 执行 Vivado 命令
        puts "execute command：$cmd"
        if {[catch {eval $cmd} result]} {
            set result "Error: $result"
            puts "error：$result"
        } else {
            puts "command is successfully done"
        }
        
        # 将结果写回 Tcl 端
        ::tclapp::xilinx::tk_tunnel::rexec "set ::result \{$result\}"
        # 清除待处理命令标志
        ::tclapp::xilinx::tk_tunnel::rexec {set ::pending_cmd ""}
    }
	# 清除待处理命令标志
	::tclapp::xilinx::tk_tunnel::rexec {set ::pending_cmd ""}
    puts "Polling cycle has exited and Vivado  Tcl Console resumes interaction"
    set keep_running 0
    # ---- 通知 Tcl 端：轮询循环 退出 ----
    # 发送一条握手命令，Tcl 端收到后将 poll_loop_startup 置为 0
    if {[catch {::tclapp::xilinx::tk_tunnel::rexec {set ::poll_loop_startup 0}} rexecErr]} {
        puts "\[WARNING\] Exit of poll loop mechanism, but failed to notify Tcl server: $rexecErr"
    } else {
        puts "Tcl server has been notified of the exit of poll loop mechanism."
    }
	# ---------------------------------
}
# 在tcl端 gui界面控制 vivado切换工作路径
proc cd_to_tcl {} {
    global tcl_path;
	cd $tcl_path;
	pwd;
}
eval $communication_vivado_start_client;
start_poll_loop;
#*********************************************************************************
#*********************************************************************************
#*********************************************************************************
#*********************************************************************************
#*********************************************************************************
