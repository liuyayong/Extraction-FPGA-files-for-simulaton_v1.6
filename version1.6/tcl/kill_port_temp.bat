for /f "tokens=5" %%a in ('netstat -ano ^| findstr " :9001 " ^| findstr LISTENING') do taskkill /PID %%a /F
