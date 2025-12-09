cmd.exe /c C:\Windows\System32\calc.exe
cmd.exe /k "wmic useraccount get name,sid & ipconfig /all & netstat -na & wmic process get name,processid,executablepath /format:list"