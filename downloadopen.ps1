Invoke-WebRequest -Uri https://raw.githubusercontent.com/marwinkloefer/DuckyPiPico/main/index.html -OutFile C:\Bachelorarbeit\index.html
Invoke-WebRequest -Uri https://raw.githubusercontent.com/marwinkloefer/DuckyPiPico/main/style.css -OutFile C:\Bachelorarbeit\style.css

Start-Sleep -Seconds 2
while (!(Test-Path -Path C:\Bachelorarbeit\index.html)) { Start-Sleep -Seconds 2 }

$browser = ""
if (Test-Path -Path "$env:ProgramFiles\Google\Chrome\Application\chrome.exe") {
    $browser = "$env:ProgramFiles\Google\Chrome\Application\chrome.exe"
}
elseif (Test-Path -Path "$env:ProgramFiles(x86)\Google\Chrome\Application\chrome.exe") {
    $browser = "$env:ProgramFiles(x86)\Google\Chrome\Application\chrome.exe"
}
elseif (Test-Path -Path "$env:ProgramFiles\Internet Explorer\iexplore.exe") {
    $browser = "$env:ProgramFiles\Internet Explorer\iexplore.exe"
}
elseif (Test-Path -Path "$env:ProgramFiles(x86)\Internet Explorer\iexplore.exe") {
    $browser = "$env:ProgramFiles(x86)\Internet Explorer\iexplore.exe"
}
elseif (Test-Path -Path "$env:ProgramFiles\Mozilla Firefox\firefox.exe") {
    $browser = "$env:ProgramFiles\Mozilla Firefox\firefox.exe"
}
elseif (Test-Path -Path "$env:ProgramFiles(x86)\Mozilla Firefox\firefox.exe") {
    $browser = "$env:ProgramFiles(x86)\Mozilla Firefox\firefox.exe"
}

Start-Process -FilePath $browser -ArgumentList C:\Bachelorarbeit\index.html